--
-- file: p2r_CordicPipe.vhd
-- author: Richard Herveille
-- rev. 1.0 initial release

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p2r_CordicPipe is 
  generic(
    WIDTH     : natural := 16;
    WIDTH_P   : natural := 18;
    PHWIDTH   : natural := 20;
    PHWIDTH_P : natural := 22;
    PIPEID    : natural := 1);

  port(
    clk, ena  : in std_logic;
    rstn      : in std_logic;
    
    X_in      : in signed(WIDTH_P -1 downto 0); 
    Y_in      : in signed(WIDTH_P -1 downto 0);
    Z_in      : in signed(PHWIDTH_P -1  downto 0);
    negx_in   : in std_logic;
    negy_in   : in std_logic;
    
    X_out     : out signed(WIDTH_P -1 downto 0);
    Y_out     : out signed(WIDTH_P -1 downto 0);
    Z_out     : out signed(PHWIDTH_P -1  downto 0);
    negx_out     : out std_logic;
    negy_out     : out std_logic);
end entity p2r_CordicPipe;

architecture dataflow of p2r_CordicPipe is
  
  --
  -- functions
  --
  
  -- Function CATAN (constante arc-tangent).
  -- This is a lookup table containing pre-calculated arc-tangents.
  -- 'n' is the number of the pipe, returned is a 20bit arc-tangent value.
  -- The numbers are calculated as follows: Z(n) = atan(1/2^n)
  -- examples:
  -- 20bit values => 2^20 = 2pi(rad)
  --                 1(rad) = 2^20/2pi = 166886.053....
  -- n:0, atan(1/1) = 0.7853...(rad)
  --      0.7853... * 166886.053... = 131072(dec) = 20000(hex)
  -- n:1, atan(1/2) = 0.4636...(rad)
  --      0.4636... * 166886.053... = 77376.32(dec) = 12E40(hex)
  -- n:2, atan(1/4) = 0.2449...(rad)
  --      0.2449... * 166886.053... = 40883.52(dec) = 9FB3(hex)
  -- n:3, atan(1/8) = 0.1243...(rad)
  --      0.1243... * 166886.053... = 20753.11(dec) = 5111(hex)
  --
  function CATAN(n :natural) return signed is
    constant round : integer := 2**(40 - PHWIDTH - 1);
    constant shiftval: integer := 40 - PHWIDTH ;
    variable lval	: signed(39 downto 0);
    variable result : signed(39 downto 0);
  begin
    case n is
      when 0  => lval := X"2000000000" + round ;
      when 1  => lval := X"12E4051D9E" + round ;
      when 2  => lval := X"09FB385B5F" + round ;
      when 3  => lval := X"051111D41E" + round ;
      when 4  => lval := X"028B0D430E" + round ;
      when 5  => lval := X"0145D7E159" + round ;
      when 6  => lval := X"00A2F61E5C" + round ;
      when 7  => lval := X"00517C5512" + round ;
      when 8  => lval := X"0028BE5347" + round ;
      when 9  => lval := X"00145F2EBB" + round ;
      when 10 => lval := X"000A2F9801" + round ;
      when 11 => lval := X"000517CC15" + round ;
      when 12 => lval := X"00028BE60D" + round ;
      when 13 => lval := X"000145F307" + round ;
      when 14 => lval := X"0000A2F983" + round ;
      when 15 => lval := X"0000517CC2" + round ;
      when 16 => lval := X"000028BE61" + round ;
      when 17 => lval := X"0000145F30" + round ;
      when 18 => lval := X"00000A2F98" + round ;
      when 19 => lval := X"00000517CC" + round ;
      when 20 => lval := X"0000028BE6" + round ;
      when 21 => lval := X"00000145F3" + round ;
      when 22 => lval := X"000000A2FA" + round ;
      when 23 => lval := X"000000517D" + round ;
      when 24 => lval := X"00000028BE" + round ;
      when 25 => lval := X"000000145F" + round ;
      when 26 => lval := X"0000000A30" + round ;
      when 27 => lval := X"0000000518" + round ;
      when 28 => lval := X"000000028C" + round ;
      when 29 => lval := X"0000000146" + round ;
      when 30 => lval := X"00000000A3" + round ;
      when 31 => lval := X"0000000051" + round ;
      when 32 => lval := X"0000000029" + round ;
      when 33 => lval := X"0000000014" + round ;
      when 34 => lval := X"000000000A" + round ;
      when 35 => lval := X"0000000005" + round ;
      when 36 => lval := X"0000000003" + round ;
      when 37 => lval := X"0000000001" + round ;
      when 38 => lval := X"0000000001" + round ;
      when others => lval := X"0000000000";
    end case;
    -- lval := X"1234567890";
    result := shift_right(lval, shiftval);
    return result;
    -- return (X"0000000000" + round);
  end CATAN;
  
  -- function Delta is actually an arithmatic shift right
  -- This strange construction is needed for compatibility with Xilinx WebPack
  function Delta(Arg : signed; cnt : natural) return signed is
    variable tmp : signed(Arg'range);
    constant lo : integer := Arg'high -cnt +1;
  begin
    if Arg'high >= lo then               -- shut up compiler warnings
      for n in Arg'high downto lo loop
        tmp(n) := Arg(Arg'high);
      end loop;
    end if;
    for n in Arg'high -cnt downto 0 loop
      tmp(n) := Arg(n +cnt);
    end loop;
    return tmp;
  end function Delta;
  
  function AddSub(dataa, datab : in signed; add_sub : in std_logic) return signed is
  begin
    if (add_sub = '1') then
      return dataa + datab;
    else
      return dataa - datab;
    end if;
  end;
  
  --
  --	ARCHITECTURE BODY
  --
  signal dX, Xresult	 : signed(WIDTH_P -1 downto 0);
  signal dY, Yresult	 : signed(WIDTH_P -1 downto 0);
  signal atan, Zresult : signed(PHWIDTH_P - 1  downto 0);
  
  signal Zneg, Zpos	 : std_logic;
  
begin

  dX <= Delta(X_in, PIPEID);
  dY <= Delta(Y_in, PIPEID);
  atan <= resize(catan(PIPEID), PHWIDTH_P);
  
  -- generate adder structures
  Zneg <= '1' when (Z_in(PHWIDTH_P - 1))= '1' else '0';
  Zpos <= not Zneg;
  
  -- xadd
  Xresult <= AddSub(X_in, dY, Zneg);
  
  -- yadd 
  Yresult <= AddSub(Y_in, dX, Zpos);
  
  -- zadd
  Zresult <= AddSub(Z_in, atan, Zneg);

  gen_regs: process(clk, rstn)
  begin
    if rstn = '0' then                    -- asynchronous reset (active low)
      X_out <= (others => '0');
      Y_out <= (others => '0');
      Z_out <= (others => '0');
      negx_out <= '0';
      negy_out <= '0';
    elsif(clk'event and clk='1') then
      if (ena = '1') then
        X_out <= Xresult;
        Y_out <= Yresult;
        Z_out <= Zresult;
        negx_out <= negx_in;
        negy_out <= negy_in;
      end if;
    end if;
  end process;

end architecture dataflow;
