library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_controller is
		port (
					sys_clk	:	in		std_logic;
					clk_1M	:	in		std_logic;
					reset		:	in		std_logic;
					SDI		:	in		std_logic;
					CS			: out		std_logic;
					SCLK		: out		std_logic;
					Drdy		:	out	std_logic;
					Dout		: out		std_logic_vector(15 downto 0)
		);

end spi_controller;




architecture behav of spi_controller is

	-- Declarations (optional)
	type spi_state is (IDLE, INIT, START, STOP);
	constant COUNTER_MAX	: integer := 10000000-1;		--MAX for 200ms for 50MHz clock
	
	signal Dout_reg 		: std_logic_vector(15 downto 0);
	signal CS_reg			: std_logic;
	signal Drdy_reg		: std_logic;
	signal SCLK_reg		: std_logic;

begin


	process(reset, sys_clk) is 
		-- Declaration(s) 
		variable bit_counter : integer range 0 to 15;
		variable current_state	: spi_state;
		variable next_state		: spi_state;
		variable	idle_counter	: integer;		--200ms counter 0 to 9,999,999
		variable init_counter	: integer;		--100ns counter 0 to 5
		variable sclk_ena			: std_logic;
		variable sclk_prev		: std_logic;
		

		
	begin 
		if(reset = '1') then
			-- Asynchronous Sequential Statement(s) 
			bit_counter := 0;
			idle_counter := 0;
			init_counter := 0;
			sclk_ena := '0';
			sclk_prev := '0';
			Dout_reg		<= "0000000000000000";
			CS_reg		<= '1';
			Drdy_reg			<= '0';
			SCLK_reg		<= '0';
			current_state := IDLE;
			next_state		:= IDLE;
		elsif(rising_edge(sys_clk)) then
			case current_state is
				when IDLE =>
					if idle_counter = COUNTER_MAX then
						--New conversion is ready. Start reading the data
						idle_counter := 0;
						next_state := INIT;
						CS_reg <= '1';
					else
						idle_counter := idle_counter + 1;
					end if;
					SCLK_reg <= '0';
				when INIT =>
					--CS goes low then wait for 100ns before SCLK starts
					CS_reg <= '0';
					SCLK_reg <= '0';
					Drdy_reg <= '0';
					if init_counter = 5 then
						--Start SCLK and shift the data
						init_counter := 0;
						next_state := START;
					else
						init_counter := init_counter + 1;
					end if;
					
				when START =>
					--turn SCLK on and start shifting data on falling edge
					--the reading cycle completes after 16 SCLK cycle
					sclk_ena := '1';
					if SCLK_reg = '0' and sclk_prev = '1' then
						--falling edge of SCLK
						Dout_reg(15 - bit_counter) <= SDI;
						if bit_counter = 15 then
							bit_counter := 0;
							next_state := STOP;
						else
							bit_counter := bit_counter + 1;
						end if;
					else
					
					end if;
					sclk_prev := SCLK_reg;
				when STOP =>
					--CS goes high and SCLK stops
					CS_reg <= '1';
					SCLK_reg <= '0';
					sclk_ena := '0';
					Drdy_reg <= '1';
					next_state := IDLE;
				When others =>
			end case;
				
			
		end if;
		
		if sclk_ena = '1' then
			SCLK_reg <= clk_1M;
		else
			SCLK_reg <= '0';
		end if;
		
		current_state := next_state;
		CS <= CS_reg;
		Drdy <= Drdy_reg;
		Dout <= Dout_reg;
		SCLK <= SCLK_reg;
	end process; 


end behav;

