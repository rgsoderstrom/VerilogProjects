--     __  ____                 _   __                
--    /  |/  (_)_____________  / | / /___ _   ______ _
--   / /|_/ / / ___/ ___/ __ \/  |/ / __ \ | / / __ `/
--  / /  / / / /__/ /  / /_/ / /|  / /_/ / |/ / /_/ / 
-- /_/  /_/_/\___/_/   \____/_/ |_/\____/|___/\__,_/                
-------------------------------------------------------------------------------
-- Title      : Mercury 2 DAC
-- Last update: 2019-04-02
-- Revision   : 1.0.139
-------------------------------------------------------------------------------
-- Copyright (c) 2018 MicroNova, LLC
-- www.micro-nova.com
-------------------------------------------------------------------------------
--
-- This module interfaces with Mercury's onboard MCP4812 DAC.
-- This is an 2-channel 10-bit DAC with an SPI interface.
--
-- To use this module:
-- 1. Drive "channel" with the desired DAC and present digital value to Din.
-- 2. Pulse "trigger" for a single cycle.
-- 3. Data and channel can be changed after trigger signal is asserted.
-- 4. Trigger is pulsed again after Busy signal is deasserted to low.
--
-- NOTE: Take care to not exceed the maximum DAC clock rate of 20 MHz. Default 
--       DAC clock is set to 12.5 MHz. See Microchip's datasheet for more details:
--       http://ww1.microchip.com/downloads/en/devicedoc/20002249b.pdf
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mercury2_DAC is
  port
    (
      -- command input
      clk_50MHZ : in  std_logic;         -- 50MHz onboard oscillator
      trigger   : in  std_logic;         -- assert to write Din to DAC
      channel   : in  std_logic;         -- 0 = DAC0/A, 1 = DAC1/B
      
      -- data input/output
      Din       : in  std_logic_vector(9 downto 0);  -- data for DAC
      Busy      : out std_logic; -- busy signal during conversion process
		
      -- DAC connection
      dac_csn   : out std_logic;         -- DAC SPI Chip Select
      dac_sdi   : out std_logic;         -- DAC SPI MOSI
      dac_ldac  : out std_logic;         -- DAC SPI Latch enable
      dac_sck   : out std_logic          -- DAC SPI CLOCK
      );

end Mercury2_DAC;

architecture RTL of Mercury2_DAC is

  -- clock
  signal clk_div      : unsigned(31 downto 0)         := (others => '0');
  signal dac_clock    : std_logic;

  -- control latch signals
  signal trigger_flag : std_logic                     := '0';
  signal device_busy  : std_logic                     := '0';
  
  -- SPI data registers
  -- cmd_reg[3:0] = {|channel|don't care|output gain|channel shutdown|}
  -- channel         : 0 = channel DAC0/A, 1 = channel DAC1/B
  -- output gain     : 0 = 2*output (0V, 4.096V), 1 = 1*output (0V, 2.048)
  -- channel shutdown: 0 = DAC channel shutdown, 1 = DAC channel shutdown disabled
  signal cmd_reg      : std_logic_vector(3 downto 0)  := (others => '0');
  -- data_reg[9:0] = Din[9:0]
  signal data_reg     : std_logic_vector(9 downto 0)  := (others => '0');
  
  -- SPI control signals
  signal csn          : std_logic                     := '0';
  signal done         : std_logic                     := '0';
  signal done_prev    : std_logic                     := '0';
    
  -- SPI state control
  signal state        : std_logic                     := '0';
  signal spi_count    : unsigned (3 downto 0)         := (others => '0');

begin
  -- purpose: clock divider
  -- type   : sequential
  -- inputs : clk_50MHZ
  -- outputs: clk_div
  -- main clock = 50MHz
  -- clk_div(0) = 25MHz
  -- clk_div(1) = 12.5MHz
  -- clk_div(2) = 6.25MHz
  -- clk_div(3) = 3.125MHz
  clock_divider : process(clk_50MHZ)
  begin
    if clk_50MHZ'event and clk_50MHZ = '1' then
      clk_div <= clk_div + 1;
    end if;
  end process clock_divider;
  dac_clock <= clk_div(1);
  
  -- purpose: produce control latches
  -- type   : sequential
  -- inputs : clk_50MHZ, trigger_flag, trigger, state, done
  -- outputs: trigger_flag, device_busy
  cntl_latches : process(clk_50MHZ)
  begin
    if clk_50MHZ'event and clk_50MHZ = '1' then
      -- conversion is allowed only when DAC is not busy with another conversion
      if device_busy = '0' and trigger = '1' then
        device_busy  <= '1';
        trigger_flag <= '1';
        -- cmd_reg[3:0] = {|channel|don't care|output gain|channel shutdown|}
        cmd_reg      <= channel & "111"; -- see lines 65 through 69
        -- data_reg[9:0] = Din[9:0]
        data_reg     <= Din;
      elsif state = '1' then
        trigger_flag <= '0';
      elsif done = '1' and done_prev = '0' then
        device_busy  <= '0'; 
      end if;  
      done_prev      <= done;  
    end if;
  end process cntl_latches;

  -- purpose: DAC state machine (falling edge)
  -- type   : sequential
  -- inputs : dac_clock, state
  -- outputs: done, csn, state, cmd_reg, data_reg, spi_count
  dac_sm : process(dac_clock)
  begin
    if dac_clock'event and dac_clock = '0' then
      -- default state
      if state = '0' then
		done        <= '0';
		csn         <= '1';
		if trigger_flag = '1' then
		  csn       <= '0';
		  state     <= '1';
		end if;
      -- spi control state
      else
		if spi_count = X"F" then
	      csn       <= '1';
          done      <= '1';
          spi_count <= (others => '0');
          state     <= '0';
		else
	      spi_count <= spi_count + 1;
		  state     <= '1';
		end if;
	  end if;
	end if;
  end process dac_sm;

  -- purpose: SPI inputs
  -- type   : combinational
  -- inputs : state, spi_count, cmd_reg, data_reg
  -- outputs: dac_sdi
  serial_input : process(state, spi_count, cmd_reg, data_reg)
  begin
    if state = '1' then
      case spi_count is
        when X"0"   => dac_sdi <= cmd_reg(3);
        when X"1"   => dac_sdi <= cmd_reg(2);
        when X"2"   => dac_sdi <= cmd_reg(1);
        when X"3"   => dac_sdi <= cmd_reg(0);
        when X"4"   => dac_sdi <= data_reg(9);
        when X"5"   => dac_sdi <= data_reg(8);
        when X"6"   => dac_sdi <= data_reg(7);
        when X"7"   => dac_sdi <= data_reg(6);
        when X"8"   => dac_sdi <= data_reg(5);
        when X"9"   => dac_sdi <= data_reg(4);
        when X"A"   => dac_sdi <= data_reg(3);
        when X"B"   => dac_sdi <= data_reg(2);
        when X"C"   => dac_sdi <= data_reg(1);
        when X"D"   => dac_sdi <= data_reg(0);
        when others => dac_sdi <= '0';
      end case;
    else
      dac_sdi <= '0';
    end if;
  end process serial_input;

  -- DAC driver connection
  Busy          <= device_busy;
  -- DAC signal connections
  dac_csn       <= csn;
  dac_sck       <= dac_clock;   -- 12.5 MHz
  dac_ldac      <= '0';         -- tie low to auto update dac on rising edge of csn
  
end RTL;
