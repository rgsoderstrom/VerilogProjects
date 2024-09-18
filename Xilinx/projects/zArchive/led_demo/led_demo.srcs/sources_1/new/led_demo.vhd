----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2023 04:05:19 PM
-- Design Name: 
-- Module Name: led_demo - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_demo is
  port
    (
      clk : in std_logic;
      led : out std_logic_vector(2 downto 0)    
    );
end led_demo;

architecture RTL of led_demo is

  signal count : integer range 0 to 49999999 := 0;
  signal pulse : std_logic := '0';

begin

  counter : process(clk)
  begin
    if clk'event and clk = '1' then
      if count = 49999999 then
        count <= 0;
        pulse <= not pulse;
      else
        count <= count + 1;
      end if;      
    end if;
  end process;

  led(2 downto 0) <= (others => pulse);

end RTL;
