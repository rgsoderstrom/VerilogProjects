--     __  ____                 _   __                
--    /  |/  (_)_____________  / | / /___ _   ______ _
--   / /|_/ / / ___/ ___/ __ \/  |/ / __ \ | / / __ `/
--  / /  / / / /__/ /  / /_/ / /|  / /_/ / |/ / /_/ / 
-- /_/  /_/_/\___/_/   \____/_/ |_/\____/|___/\__,_/                
-------------------------------------------------------------------------------
-- Title      : Mercury 2 Coordination Rotation Digital Computer (CORDIC)
-- Last update: 2019-04-24
-- Revision   : 1.0.0
-------------------------------------------------------------------------------
-- Copyright (c) 2018 MicroNova, LLC
-- www.micro-nova.com
-------------------------------------------------------------------------------
--
-- This module produces a 12-bit digital sine wave for a given phase shift that
-- determines the frequency of the sine wave. Produced wave is an unsigned, positive
-- value.  
--
-- To use this module:
-- 1. Determine the correct 16-bit binary input to phs_sft for the desired frequency.
-- 2. Drive cor_en high to start the pipelined CORDIC system
-- 3. Read outVal to obtain the 10-bit binary value each cor_clk cycle.
--
-- NOTE: This module requires both the p2r_cordic.vhd and p2r_CordicPipe.vhd files 
--       to be included in the source folder for operation.  
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mercury2_CORDIC is
  generic
    (
      WIDTH    : integer := 12;
      FS_INPUT : integer := 0
    );
  port
    (
      clk_50MHz	: in std_logic;
      cor_en    : in std_logic;
      phs_sft   : in signed(WIDTH + 3 downto 0);
      outVal    : out std_logic_vector(WIDTH + FS_INPUT -1 downto 0)
    );
end entity Mercury2_CORDIC;

architecture RTL of Mercury2_CORDIC is
  
  -- p2r_cordic component declaration
  component p2r_cordic
    generic
      (
        WIDTH     : integer := WIDTH;
        FS_INPUT  : integer := FS_INPUT
      );
    port
      (
        clk       : in std_logic;
        ena, rstn : in std_logic;

        Xi        : in signed(WIDTH -1 downto 0);
        Yi        : in signed(WIDTH -1 downto 0) := (others => '0');
        Zi        : in signed(WIDTH + 3 downto 0);
      
        Xo        : out signed(WIDTH + FS_INPUT -1 downto 0);
        Yo        : out signed(WIDTH + FS_INPUT -1 downto 0)
      );
  end component;
  
  -- clock
  signal clk_div   : unsigned(31 downto 0)                := (others => '0');
  signal cor_clk   : std_logic;
  
  -- CORDIC phase limits ranging from -90 degrees to 90 degrees
  constant LOW_LIM : signed(WIDTH + 3 downto 0)           := X"C000";
  constant UP_LIM  : signed(WIDTH + 3 downto 0)           := X"4000"; 
  
  -- CORDIC control signals
  constant Xin     : signed(WIDTH -1 downto 0)            := X"4DA";
  signal polarity  : signed(1 downto 0)                   := "01";
  signal phase     : signed(WIDTH + 3 downto 0)           := (others => '0');
  signal sin       : signed(WIDTH + FS_INPUT -1 downto 0);
  
begin

  -- purpose: clock divider
  -- type   : sequential
  -- inputs : clk_50MHZ
  -- outputs: clk_div
  clock_divider : process(clk_50MHZ)
  begin
    if clk_50MHZ'event and clk_50MHZ = '1' then
      clk_div <= clk_div + 1;
    end if;
  end process clock_divider;
  
  -- Base CORDIC frequency when phs_sft = X"0001"
  -- clk_div(0) = 380  Hz
  -- clk_div(1) = 190  Hz
  -- clk_div(2) = 95   Hz
  -- clk_div(3) = 47.5 Hz
  cor_clk <= clk_div(1);
  
  -- purpose: produce 12-bit binary values for sine wave
  -- type   : combinational
  -- inputs : cor_clk, phs_sft
  -- outputs: outVal, phase  
  process(cor_clk)
  begin
    if cor_clk'event and cor_clk = '1' then
      -- reset state
      if cor_en = '0' then
        outVal <= (others => '0');
        phase  <= (others => '0');
      -- CORDIC enabled state
      else
        outVal <= std_logic_vector(unsigned(sin) + X"800"); -- 12-bit unsigned output
        phase  <= phase + resize((polarity * phs_sft), 16); -- accumulator for phase
      end if;
    end if;
  end process;
  
  -- purpose: ensure that phase bounds are kept
  -- type   : combinational
  -- inputs : cor_clk, phase
  -- outputs: polarity
  process(cor_clk)
  begin
    if cor_clk'event and cor_clk = '1' then
      -- polarity = -1 if upper bound is hit
      if phase >= (UP_LIM - phs_sft) then
        polarity <= "11";
      -- polarity = 1 if lower bound is hit
      elsif phase <= (LOW_LIM + phs_sft) then
        polarity <= "01";
      else
        polarity <= polarity;
      end if;
    end if;
  end process;
  
  -- p2r_cordic entity port map
  u1 : entity work.p2r_cordic 	
    generic map
      (
        WIDTH    => WIDTH, 
        FS_INPUT => FS_INPUT
      )
    port map
      (
        clk      => clk_50MHz, 
        ena      => cor_en, 
        rstn     => cor_en, 
        Xi       => Xin, 
        Yi       => (others =>'0'), 
        Zi       => phase, 
        Xo       => open, 
        Yo       => sin
      );
end architecture RTL;
