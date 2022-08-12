
library ieee;
use ieee.std_logic_1164.all;

entity SevenSegmentDisplay is
port(

	rst : in std_logic; --asserted low from push
	clk : in std_logic; --50mhz
	sw1 : in std_logic;
	
	k   : out std_logic_vector(6 downto 0); --represents cathod segments from a to g
	Dp  : out std_logic; -- represets cathod segment for decimal
	A   : out std_logic_vector(3 downto 0)


);
end entity;

architecture behave of SevenSegmentDisplay is

signal sync        : std_logic_vector(1 downto 0); --registers for synchronising the sw1
signal SW1_synced  : std_logic;
signal DeBounceCount : integer; --counter for debouncing the sw1
constant DebouncePeriod: integer := 25000000;
signal SW1_Debounced : std_logic; -- represents the debounced version of switch input
signal k_int : std_logic_vector(6 downto 0);
type StateMachineType is (DIGIT_1, DIGIT_2, DIGIT_3, DIGIT_4 );
signal SMState : StateMachineType;
signal SW1_Debounced_delay : std_logic; 
signal NumberToDisplay : integer;
signal FallingEdgeonSW1 : std_logic;
signal Digit1 : integer;
signal Digit2 : integer;
signal Digit3 : integer;
signal Digit4 : integer;
signal PeriodCounter : integer;

begin

	Dp <= '1';
	k <= not(k_int);
	
	SW1_synced <= sync(1);

	synchroniseSW1 : process(clk,rst)
	begin
	
		if rst = '0' then
			sync <= "11";
			
		elsif rising_edge(clk) then
			sync(0) <= sw1;
			sync(1) <= sync(0); ---synchronising the sw1
		end if;
	end process;
	
	Debounceprocess : process(clk,rst)
	begin
	
		if rst = '0' then
			DeBounceCount <= 0;
			SW1_Debounced <= '1'; --switch is deasserted
			
		elsif rising_edge(clk) then
		
			if SW1_synced = '0' then 
				-- if switch is activated
				if DeBounceCount < DebouncePeriod then
					DeBounceCount <= DeBounceCount+1;
				end if;
			
			else
				-- if switch is activated
			if DeBounceCount > 0 then
				DeBounceCount <= DeBounceCount - 1;
			end if;	
		
			if DeBounceCount = DebouncePeriod then
				SW1_Debounced <= '0' ; --asserted state 
			elsif DeBounceCount = 0 then
				SW1_Debounced <= '1'; --deasserted state of synchronised Debounce switch
			end if;			
		 end if;
		end if;
	end process;
	
	DetectButtonFallingEdge : process(clk,rst)
	begin
	
		if rst = '0' then
			SW1_Debounced_delay <= '1';
			FallingEdgeonSW1 <= '0';
			
		elsif rising_edge(clk) then
			SW1_Debounced_delay <= SW1_Debounced;
		
			if SW1_Debounced = '0' and SW1_Debounced_delay = '1' then
				FallingEdgeonSW1 <= '1';
			else
				FallingEdgeonSW1 <= '0';
			end if;	
		end if;
	end process;
	
	CountButtonPresses : process(clk,rst)
	begin
	
		if rst = '0' then
			Digit1 <= 0;
			Digit2 <= 0;
			Digit3 <= 0;
			Digit4 <= 0;
			
		elsif rising_edge(clk) then
			if FallingEdgeonSW1 = '1' then
				--we detected a button press
				if Digit1 < 9 then
					Digit1 <= digit1 + 1;
				else 
					Digit1 <= 0;
				
				
					if Digit2 < 9 then
						Digit2 <= digit2 + 1;
					else 
						Digit2 <= 0;
					
						if Digit3 < 9 then
							Digit3 <= digit3 + 1;
						else 
							Digit3 <= 0;
							
							if Digit4 < 9 then
								Digit4 <= digit4 + 1;
							else 
								Digit4 <= 0;
							end if;
						end if;
					end if;
					
				end if;
				
			end if;
			
		end if;
	end process;
	
	Decoder : process(clk,rst)
	begin
	
		if rst = '0' then
			k_int <= "0000000";
			
		elsif rising_edge(clk) then
			case NumberToDisplay is 
				when 0 => k_int <= "0111111";
				when 1 => k_int <= "0000110";
				when 2 => k_int <= "1011011";
				when 3 => k_int <= "1001111";
				when 4 => k_int <= "1100110";
				when 5 => k_int <= "1101101";
				when 6 => k_int <= "1111001";
				when 7 => k_int <= "0000111";
				when 8 => k_int <= "1111111";
				when 9 => k_int <= "1100111";
				when others => k_int <= "0000000";		
			end case;		
		end if;
	end process;
	
	statemachine : process(clk,rst)
	begin
	
		if rst = '0' then
			SMState <= DIGIT_1;
			A <= "1111"; --this is to disable all four anodes(1111 is used because of inverter used in hardware)
			PeriodCounter <= 0;	
		elsif rising_edge(clk) then
			case SMState is
				when DIGIT_1 => 
					A <= "1110"; 
					NumberToDisplay <= Digit1;
					PeriodCounter <= PeriodCounter+1;
					if PeriodCounter = 50000 then -- to display number for 1msec
						SMState <= Digit_2;
						PeriodCounter <= 0;
					end if;	
					
				when DIGIT_2 => 
					A <= "1101";
					NumberToDisplay <= Digit2;
					PeriodCounter <= PeriodCounter+1;
					if PeriodCounter = 50000 then 
						SMState <= Digit_3;
						PeriodCounter <= 0;
					end if;
					
				when DIGIT_3 => 
					A <= "1011";
					NumberToDisplay <= Digit3;
					PeriodCounter <= PeriodCounter+1;
					if PeriodCounter = 50000 then
						SMState <= Digit_4;
						PeriodCounter <= 0;
					end if;
					
				when DIGIT_4 => 
					A <= "0111";
					NumberToDisplay <= Digit4;
					PeriodCounter <= PeriodCounter+1;
					if PeriodCounter = 50000 then
						SMState <= Digit_1;
						PeriodCounter <= 0;
					end if;
					
				when others => SMState <= DIGIT_1;
			end case;
			
		end if;
	end process;
	

	


end behave;