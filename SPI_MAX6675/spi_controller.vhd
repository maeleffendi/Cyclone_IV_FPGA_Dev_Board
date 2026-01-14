LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY spi_controller IS
	PORT (
		sys_clk : IN std_logic;
		clk_1M : IN std_logic;
		reset : IN std_logic;
		SDI : IN std_logic;
		CS : OUT std_logic;
		SCLK : OUT std_logic;
		Drdy : OUT std_logic;
		Dout : OUT std_logic_vector(15 DOWNTO 0)
	);

END spi_controller;
ARCHITECTURE behav OF spi_controller IS

	-- Declarations (optional)
	TYPE spi_state IS (IDLE, INIT, START, STOP);
	CONSTANT COUNTER_MAX : INTEGER := 10000000 - 1; --MAX for 200ms for 50MHz clock
 
	SIGNAL Dout_reg : std_logic_vector(15 DOWNTO 0);
	SIGNAL CS_reg : std_logic;
	SIGNAL Drdy_reg : std_logic;
	SIGNAL SCLK_reg : std_logic;

BEGIN
	PROCESS (reset, sys_clk) IS
	-- Declaration(s)
	VARIABLE bit_counter : INTEGER RANGE 0 TO 15;
	VARIABLE current_state : spi_state;
	VARIABLE next_state : spi_state;
	VARIABLE idle_counter : INTEGER; --200ms counter 0 to 9,999,999
	VARIABLE init_counter : INTEGER; --100ns counter 0 to 5
	VARIABLE sclk_ena : std_logic;
	VARIABLE sclk_prev : std_logic;
 

 
	BEGIN
		IF (reset = '1') THEN
			-- Asynchronous Sequential Statement(s)
			bit_counter := 0;
			idle_counter := 0;
			init_counter := 0;
			sclk_ena := '0';
			sclk_prev := '0';
			Dout_reg <= "0000000000000000";
			CS_reg <= '1';
			Drdy_reg <= '0';
			SCLK_reg <= '0';
			current_state := IDLE;
			next_state := IDLE;
		ELSIF (rising_edge(sys_clk)) THEN
			CASE current_state IS
				WHEN IDLE => 
					IF idle_counter = COUNTER_MAX THEN
						--New conversion is ready. Start reading the data
						idle_counter := 0;
						next_state := INIT;
						CS_reg <= '1';
					ELSE
						idle_counter := idle_counter + 1;
					END IF;
					SCLK_reg <= '0';
				WHEN INIT => 
					--CS goes low then wait for 100ns before SCLK starts
					CS_reg <= '0';
					SCLK_reg <= '0';
					Drdy_reg <= '0';
					IF init_counter = 5 THEN
						--Start SCLK and shift the data
						init_counter := 0;
						next_state := START;
					ELSE
						init_counter := init_counter + 1;
					END IF;
 
				WHEN START => 
					--turn SCLK on and start shifting data on falling edge
					--the reading cycle completes after 16 SCLK cycle
					sclk_ena := '1';
					IF SCLK_reg = '0' AND sclk_prev = '1' THEN
						--falling edge of SCLK
						Dout_reg(15 - bit_counter) <= SDI;
						IF bit_counter = 15 THEN
							bit_counter := 0;
							next_state := STOP;
						ELSE
							bit_counter := bit_counter + 1;
						END IF;
					ELSE
 
					END IF;
					sclk_prev := SCLK_reg;
				WHEN STOP => 
					--CS goes high and SCLK stops
					CS_reg <= '1';
					SCLK_reg <= '0';
					sclk_ena := '0';
					Drdy_reg <= '1';
					next_state := IDLE;
				WHEN OTHERS => 
			END CASE;
 
 
		END IF;
 
		IF sclk_ena = '1' THEN
			SCLK_reg <= clk_1M;
		ELSE
			SCLK_reg <= '0';
		END IF;
 
		current_state := next_state;
		CS <= CS_reg;
		Drdy <= Drdy_reg;
		Dout <= Dout_reg;
		SCLK <= SCLK_reg;
	END PROCESS;
END behav;
