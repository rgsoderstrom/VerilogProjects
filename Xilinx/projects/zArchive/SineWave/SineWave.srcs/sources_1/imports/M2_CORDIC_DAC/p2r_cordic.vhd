--
--	VHDL implementation of cordic algorithm
--
-- File: p2r_cordic.vhd
-- author: Richard Herveille
-- rev. 1.0 initial release
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p2r_cordic is 
  generic(
    WIDTH           : integer := 28;
    FS_INPUT        : integer := 0;
    PHASE_EXTRA     : integer := 4;
    XY_INT_EXTRA    : integer := 0;
    PHASE_INT_EXTRA : integer := 0);

  port(
    clk	: in std_logic;
    ena, rstn : in std_logic;
    
    Xi	: in signed(WIDTH -1 downto 0);
    Yi : in signed(WIDTH -1 downto 0);
    Zi	: in signed(WIDTH + PHASE_EXTRA -1 downto 0);
    
    Xo	: out signed(WIDTH + FS_INPUT -1 downto 0);
    Yo	: out signed(WIDTH + FS_INPUT -1 downto 0)
    );
end entity p2r_Cordic;

--                           PIPELINE : integer := PipeLength;
--                           PHWIDTH  : integer := PhWidth;
--     PHWIDTH  : integer := 32;
--     PIPELINE : integer := 27;


architecture dataflow of p2r_cordic is
  constant PWidth     : natural := WIDTH + XY_INT_EXTRA + FS_INPUT;
  constant PipeLength : natural := PWidth - 1;
  constant PhWidth    : natural := WIDTH + PHASE_EXTRA ;
  constant PPhWidth   : natural := PhWidth + PHASE_INT_EXTRA ;
  --
  --	TYPE defenitions
  --
  type XYVector is array(PipeLength downto 0) of signed(PWidth -1 downto 0);
  type ZVector is array(PipeLength downto 0) of signed(PPhWidth - 1 downto 0);
  type SVector is array (PipeLength downto 0) of std_logic;  -- Sign information out of preprocessor
  
  --
  --	COMPONENT declarations
  --
  component p2r_CordicPipe
    generic(
      WIDTH     : natural := WIDTH;
      WIDTH_P   : natural := PWidth;
      PHWIDTH   : natural := PhWidth;
      PHWIDTH_P : natural := PPhWidth;
      PIPEID	: natural := 1);
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
      negx_out  : out std_logic;
      negy_out  : out std_logic);
  end component p2r_CordicPipe;
  
  --
  --	SIGNALS
  --
  signal X, Y	    : XYVector;
  signal Z	    : ZVector;
  signal NegX, NegY : SVector;
  signal Xtmp       : signed(WIDTH -1 downto 0);
  signal Zhalf      : signed(PhWidth -1 downto 0);
  signal AngGT90    : std_logic;
  constant msbc     : signed(PhWidth -1 downto 0) := ('1', others =>'0');

  signal FlipBits   : signed(2 downto 0); 
  --
  --	ACHITECTURE BODY
  --
begin
  -- convert angle to between +- 90deg
  -- AngGT90 <= '0' when Zi(PhWidth - 1) = Zi(PhWidth - 2) else '1';
  -- 
  -- Zhalf <= Zi when AngGT90 ='0'
  --        else -(Zi xor msbc);
  -- NegX(0) <= AngGT90;

  FlipBits <= Zi(PhWidth -1 downto PhWidth -2) & Xi(WIDTH -1);
  -- purpose: flip angle into first quadrant, make r positive
  -- type   : combinational
  -- inputs : Xi, Zi
  -- outputs: NegX(0), NegY(0), Xtmp, Zhalf
  SwapSectors: process (Xi, Zi) is
  begin  -- process SwapSectors
    case FlipBits is
      when "000" => -- first quadrant, positive r
        NegX(0)  <= '0';
        NegY(0)  <= '0';
        Xtmp  <= Xi;
        Zhalf <= Zi;
        
      when "001" => -- first quadrant, negative r
        NegX(0)  <= '1';
        NegY(0)  <= '1';
        Xtmp  <= -Xi;
        Zhalf <= Zi;

      when "010" => -- second quadrant, positive r
        NegX(0)  <= '1';
        NegY(0)  <= '0';
        Xtmp  <= Xi;
        Zhalf <= -(Zi xor msbc);

      when "011" => -- second quadrant, negative r
        NegX(0)  <= '0';
        NegY(0)  <= '1';
        Xtmp  <= -Xi;
        Zhalf <= -(Zi xor msbc);

      when "100" => -- third quadrant,  positive r
        NegX(0)  <= '1';
        NegY(0)  <= '1';
        Xtmp  <= Xi;
        Zhalf <= (Zi xor msbc);

      when "101" => -- third quadrant,  negative r
        NegX(0)  <= '0';
        NegY(0)  <= '0';
        Xtmp  <= -Xi;
        Zhalf <= (Zi xor msbc);

      when "110" => -- fourth quadrant, positive r
        NegX(0)  <= '0';
        NegY(0)  <= '1';
        Xtmp  <= Xi;
        Zhalf <= -Zi;
        
      when "111" => -- fourth quadrant, negative r
        NegX(0)  <= '1';
        NegY(0)  <= '0';
        Xtmp  <= -Xi;
        Zhalf <= -Zi;
        
      when others => null;
    end case;
  end process SwapSectors;

  
  -- fill first nodes
  -- fill X
  -- X(0) <= Xi;
  X(0) (WIDTH - 1 downto 0) <= Xtmp;
  XHiBits: if PWidth > WIDTH generate
    X(0) (PWidth -1 downto WIDTH) <= (others => Xtmp(WIDTH - 1));  
  end generate XHiBits;
  

  -- fill Y
  -- Y(0) <= Yi;
  Y(0) (WIDTH - 1 downto 0) <= Yi;
  YHiBits: if PWidth > WIDTH generate
    Y(0) (PWidth -1 downto WIDTH) <= (others => Yi(WIDTH - 1));
  end generate YHiBits;
  
  -- fill Z
  -- Z(0) <= Zi;
  -- Z(0)(PhWidth - 1 downto PhWidth - WIDTH) <= Zi;
  -- Z(0)(PhWidth - WIDTH - 1 downto 0) <= (others => '0');
  Z(0)(PhWidth - 1 downto 0) <= Zhalf;
  ZHiBits: if PPhWidth > PhWidth generate
    Z(0)(PPhWidth - 1 downto PhWidth) <= (others => Zhalf(PhWidth - 1));
  end generate ZHiBits;
  
  --
  -- generate pipeline
  --
  gen_pipe:
  for n in 1 to PipeLength generate
    Pipe: p2r_CordicPipe 
      generic map(WIDTH => WIDTH, WIDTH_P =>PWidth, PHWIDTH => PhWidth, PHWIDTH_P => PPhWidth, PIPEID => n -1)
      port map ( clk, ena, rstn, X(n-1), Y(n-1), Z(n-1), NegX(n-1), NegY(n-1), X(n), Y(n), Z(n), NegX(n), NegY(n));
  end generate gen_pipe;
  

  -- purpose: latch outputs
  -- type   : sequential
  -- inputs : clk, rstn, X(PipeLength), Y(PipeLength), NegX(pipelength)
  -- outputs: Xo, Yo
  OutLatch: process (clk, rstn)
  begin  -- process OutLatch
    if rstn = '0' then                  -- asynchronous reset (active low)
      Xo <= (others => '0'); Yo <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if NegX(PipeLength) = '0' then
        Xo <= X(PipeLength)(WIDTH  + FS_INPUT - 1 downto 0);
      else
        Xo <= -X(PipeLength)(WIDTH + FS_INPUT - 1 downto 0);
      end if;

      if NegY(PipeLength) = '0' then
        Yo <= Y(PipeLength)(WIDTH  + FS_INPUT - 1 downto 0);
      else
        Yo <= -Y(PipeLength)(WIDTH + FS_INPUT - 1 downto 0);
      end if;
    end if;
  end process OutLatch;

end dataflow;


