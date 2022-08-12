library ieee;
use ieee.std_logic_1164.all;

entity pwm_led is 
	port(
	
			clk : in std_logic;
			pwm_output : out std_logic
	);
end entity;

architecture behave of pwm_led is

signal counter : integer range 0 to 50000000;

begin

	pwnproc : process(clk)
	begin
			if rising_edge(clk) then
				if counter > 49999999 then
					counter <= 0;
				else 
					counter <= counter+1;
			   end if;
			
				if counter > 25000000 then
					pwm_output <= '1' ;
				else 
					pwm_output <= '0' ;
				end if;
			end if;
	end process;
end behave;
