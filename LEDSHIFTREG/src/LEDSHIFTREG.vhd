library ieee;
use ieee.std_logic_1164.all;

entity LEDSHIFTREG is
port(
		clk	:	in  std_logic;
		rst   :  in  std_logic;
		sw1   :  in  std_logic;
		led   :  out std_logic_vector(1 to 4)

);
end entity;

architecture behave of LEDSHIFTREG is
constant Debouncedperiod : integer := 2500000;
signal shiftreg : std_logic_vector( 1 to 4);
signal buttonpressed   : std_logic;
signal sync     : std_logic_vector(1 downto 0);
signal delayed_switch  : std_logic;
signal counter  : integer;
signal debouncedsw1 : std_logic;


begin

	led <= shiftreg;
	
	syncproc : process(clk,rst)
	begin
		
		if rst = '0' then
			sync <= "11";
			
		elsif rising_edge(clk) then
			sync(0) <= sw1;
			sync(1) <= sync(0);	
		end if;
	end process;
	
	debounceproc : process(clk,rst)
	begin
		
	  if rst = '0' then
			counter <= 0;
			debouncedsw1 <= '1';  --inactive state
		elsif rising_edge(clk) then
		 if  sync(1) = '0' then   ---if the switch is in active state
			if  counter < debouncedperiod then
				counter <= counter + 1;
			end if;
		else                     ----if theswitch is inactive	state
			if  counter > 0 then
				counter <= counter - 1;
		end if;
	end if;
	
		if counter = debouncedperiod then
			debouncedsw1 <= '0';
		elsif counter = 0 then
			debouncedsw1 <= '1';
		end if;
	end if;	
	end process;
	
	buttonproc : process(clk,rst)
	begin
		
		if rst = '0' then
			delayed_switch <= '1'; --idle state
			buttonpressed <= '0';
		elsif rising_edge(clk) then
			delayed_switch <= debouncedsw1;
		if debouncedsw1 = '0' and delayed_switch = '1' then  --falling edge of button
			buttonpressed <= '1';
		else
			buttonpressed <= '0';
		end if;
	end if;
	
	end process;
	
	shiftproc : process(clk,rst)
	begin
		
		if rst = '0' then
			shiftreg <= "0111";
		
		elsif rising_edge(clk) then
		
		if buttonpressed  = '1' then
			shiftreg <= shiftreg(4) & shiftreg(1 to 3);	
		end if;
		end if;
	end process;
	
end behave;

