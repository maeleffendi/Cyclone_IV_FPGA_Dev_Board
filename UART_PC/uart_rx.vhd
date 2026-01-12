LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY uart_rx IS
	PORT (
		bclk : IN std_logic;
		rx : IN std_logic;
		data_out : OUT std_logic_vector(7 DOWNTO 0);
		data_rdy : OUT std_logic
	);

END uart_rx;

ARCHITECTURE behav OF uart_rx IS

	TYPE uart_state IS (IDLE, START, DATA, STOP);
BEGIN
	PROCESS (bclk) IS
 
	VARIABLE rx_current_state : uart_state;
	VARIABLE rx_next_state : uart_state;
	VARIABLE rx_data : std_logic_vector (7 DOWNTO 0);
	VARIABLE clk_counter : INTEGER RANGE 0 TO 15 := 0;
	VARIABLE data_counter : INTEGER RANGE 0 TO 7 := 7;
	VARIABLE rx_prev : std_logic;
 
	BEGIN
		IF rising_edge(bclk) THEN
 
			CASE rx_current_state IS
				WHEN IDLE => 
					IF rx_prev = '1' AND rx = '0' THEN
						-- a start bit has be received
						rx_next_state := START;
					END IF;
				WHEN START => 
					-- wait for 16 bclk before moving to the next state
					IF clk_counter = 15 THEN
						rx_next_state := DATA;
						clk_counter := 0;
						data_counter := 0;
						data_rdy <= '0';
					ELSE
						clk_counter := clk_counter + 1;
					END IF;
				WHEN DATA => 
					--sample data bits at 8 bclk and move to next bit after 16 bclk
					IF clk_counter = 7 THEN
						rx_data(data_counter) := rx;
					ELSIF clk_counter = 15 THEN
						clk_counter := 0;
						IF data_counter = 7 THEN
							rx_next_state := STOP;
						ELSE
							data_counter := data_counter + 1;
						END IF;
					END IF;
					clk_counter := clk_counter + 1;
				WHEN STOP => 
					-- wait for 16 bclk before moving to the next state
					IF clk_counter = 15 THEN
						rx_next_state := IDLE;
						clk_counter := 0;
						data_rdy <= '1';
						data_out <= rx_data;
					ELSE
						clk_counter := clk_counter + 1;
					END IF;
				WHEN OTHERS => 
			END CASE;
			rx_prev := rx;
		END IF;
		rx_current_state := rx_next_state;
	END PROCESS;

END behav;
