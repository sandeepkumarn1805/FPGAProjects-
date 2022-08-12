library ieee;
use ieee.std_logic_1164.all;

entity State_Machine is
port
(
	Clk  : in std_logic;
	Rst  : in std_logic;
	Sw	 : in std_logic;
	Temp : in std_logic;
	Water_level_ind : in std_logic;
	Ready_Led : out std_logic;
	error_Led : out std_logic;
	Heater    : out std_logic
);
end entity;

architecture behave of State_Machine is


type SMType is (IDLE, HEATING, READY);
signal State : SMType;


begin

	Water_Heater : process(Rst, Clk)
	
	begin
	   if rst = '1' then
		Ready_Led       <= '0';
		error_Led       <= '0';
		Heater          <= '0';
		State           <= IDLE;
		
	
		elsif rising_edge(clk1) then
		
			case State is
				when IDLE =>
					Ready_Led <= '0';
					error_Led <= '0';
					Heater <= '0';
					if Sw = '1' then
						State <= HEATING;
					end if;						
					
				when Heating =>
					Heater <= '1';
					error_Led <= '0';
					Ready_Led <= '0';
					if Sw = '0' then
						State <= IDLE;
					elsif Water_level_ind = '1' then
						error_Led <= '1';
						State <= IDLE;
					elsif Temp <= '1' then
						Ready_Led <= '1';
						State <= READY;
					end if;
			
				when READY =>
					Ready_Led <= '1';
					if Sw = '0' then
						Heater <= '0';
						Ready_Led <= '0';
						Error_Led <= '0';
					elsif Water_level_ind = '1' then
						error_Led <= '1';
						State <= IDLE;
					end if;
						
				when others =>
				State <= IDLE;
			end case;			
		end if;
	end process;

end behave;
	