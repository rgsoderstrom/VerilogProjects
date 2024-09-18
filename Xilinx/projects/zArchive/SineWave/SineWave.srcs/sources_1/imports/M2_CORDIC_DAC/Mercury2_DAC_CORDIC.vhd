--     __  ____                 _   __                
--    /  |/  (_)_____________  / | / /___ _   ______ _
--   / /|_/ / / ___/ ___/ __ \/  |/ / __ \ | / / __ `/
--  / /  / / / /__/ /  / /_/ / /|  / /_/ / |/ / /_/ / 
-- /_/  /_/_/\___/_/   \____/_/ |_/\____/|___/\__,_/                
-------------------------------------------------------------------------------
-- Title      : Mercury 2 DAC with CORDIC driver
-- Last update: 2019-04-25
-- Revision   : 1.0.0
-------------------------------------------------------------------------------
-- Copyright (c) 2018 MicroNova, LLC
-- www.micro-nova.com
-------------------------------------------------------------------------------
--
-- This module interfaces with Mercury 2's onboard MCP4812 DAC with the Coordination
-- Rotation Digital Computer (CORDIC)
--
-- To use this module:
-- 1. Set frequency by setting 5v tolerant inputs 0 through 7 to the appropriate
--    value. 
-- 2. set io(33) low to run DAC and CORDIC system.
--
-- NOTE: Output frequency of CORDIC/DAC system is determined by setting first the base
--       cordic clock found in Mercury2_CORDIC.vhd on line 102. Output frequency will 
--       be the base frequency multiplied by the binary value of the 5v tolerant
--       inputs [7 : 0]. For example, if the cordic clk is set to 190 Hz 
--       (cor_clk = clk_div(1)) and input is set to hex 0A then the output frequency
--       will be 190*10 = 1.9 kHz.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mercury2_DAC_CORDIC is
  generic
    (
      WIDTH    : integer := 12;
      FS_INPUT : integer := 0
    );
  port
    (
      -- inputs for CORDIC/DAC driver
      clk      : in  std_logic;
      io       : in  std_logic_vector (33 downto 0);
      
      -- DAC connection
      dac_csn  : out std_logic;         -- DAC SPI Chip Select
      dac_sdi  : out std_logic;         -- DAC SPI MOSI
      dac_ldac : out std_logic;         -- DAC SPI Latch enable
      dac_sck  : out std_logic          -- DAC SPI CLOCK
    );
end Mercury2_DAC_CORDIC;

architecture Behavorial of Mercury2_DAC_CORDIC is

  -- DAC component declaration
  component Mercury2_DAC is
    port 
	  (
        clk_50MHZ : in  std_logic;
	    trigger   : in  std_logic;
        channel   : in  std_logic;
        Din       : in  std_logic_vector(9 downto 0);
        Busy      : out std_logic;
        dac_csn   : out std_logic;
        dac_sdi   : out std_logic;
        dac_ldac  : out std_logic;
        dac_sck   : out std_logic
	  );
  end component Mercury2_DAC;
  
  -- cordic component declaration
  component Mercury2_CORDIC is
    port
      (
        clk_50MHz : in std_logic;
        cor_en    : in std_logic;
        phs_sft   : in signed(WIDTH + 3 downto 0);
        outVal	  : out signed(WIDTH + FS_INPUT -1 downto 0)
      );
  end component Mercury2_CORDIC;  
  
  -- control signals for CORDIC/DAC system
  signal phs_sft   : signed(WIDTH + 3 downto 0)           := (others => '0');
  signal run       : std_logic;
  signal outVal    : std_logic_vector(11 downto 0);
  
  -- DAC driver control input/output signals
  signal Dvalue    : std_logic_vector (9 downto 0)        := (others => '0');
  signal strt_conv : std_logic                            := '0';
  signal dac_stat  : std_logic                            := '0';
    
begin
          
  -- purpose: produce control signals for DAC
  -- type   : sequential
  -- inputs : clk, run, dac_stat
  -- outputs: strt_conv
  process(clk)
  begin
    if clk'event and clk = '1' then
      if run = '1' then
        if dac_stat = '0' then
          strt_conv <= '1';
        else
          strt_conv <= '0';
        end if;
      else
        strt_conv   <= '0';
      end if;
    end if;
  end process; 
  
  -- CORDIC/DAC/control signal connections
  run     <= not io(33);
  Dvalue  <= outVal(11 downto 2);
  phs_sft <= signed(X"00" & io(7 downto 0)) + 1;
  
  -- DAC entity port map	
  dac : entity work.Mercury2_DAC
    port map 
      (
        clk_50MHZ => clk,
        trigger   => strt_conv,
        channel   => '0',
        Din       => Dvalue,
	    Busy      => dac_stat,
	    dac_csn   => dac_csn,
        dac_sdi   => dac_sdi,
        dac_ldac  => dac_ldac,
        dac_sck   => dac_sck
      );
      
  -- CORDIC entity port map      
  cordic : entity work.Mercury2_CORDIC
    generic map
      (
        WIDTH     => WIDTH,
        FS_INPUT  => FS_INPUT
      )
    port map
      (
		clk_50MHz => clk,
        cor_en    => run,
        phs_sft   => phs_sft,
        outVal	  => outVal
      );
      
end Behavorial;
    