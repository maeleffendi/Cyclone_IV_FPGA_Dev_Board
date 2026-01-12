LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY uart_tx IS
	PORT (
		bclk : IN std_logic;
		data_in : IN std_logic_vector(7 DOWNTO 0);
		data_rdy : IN std_logic;
		tx : OUT std_logic
	);

END uart_tx;
ARCHITECTURE behav OF uart_tx IS

	TYPE uart_state IS (IDLE, START, DATA, STOP);

	SIGNAL tx_out : std_logic;
 
BEGIN
	-- this process implements the state machine for the transmitter
	PROCESS (bclk, data_rdy) IS
 
	VARIABLE tx_data : std_logic_vector (7 DOWNTO 0);
	VARIABLE new_data : std_logic;
	VARIABLE tx_current_state : uart_state;
	VARIABLE tx_next_state : uart_state;
	VARIABLE clk_counter : INTEGER RANGE 0 TO 15 := 0;
	VARIABLE data_counter : INTEGER RANGE 0 TO 7;

 
	BEGIN
		IF rising_edge(bclk) THEN
			IF (data_rdy = '1') THEN
				tx_data := data_in;
				new_data := '1';
			END IF;
 
			IF clk_counter = 15 THEN
				clk_counter := 0;
				CASE tx_current_state IS
					WHEN IDLE => 
						tx_out <= '1';
						IF new_data = '1' THEN
							tx_next_state := START;
							new_data := '0';
						END IF;
					WHEN START => 
						tx_out <= '0';
						tx_next_state := DATA;
						data_counter := 0;
					WHEN DATA => 
						tx_out <= tx_data(data_counter);
						IF data_counter = 7 THEN
							data_counter := 0;
							tx_next_state := STOP;
						ELSE
							data_counter := data_counter + 1;
						END IF;
					WHEN STOP => 
						tx_out <= '1';
						tx_next_state := IDLE;
					WHEN OTHERS => 
				END CASE;
			ELSE
				clk_counter := clk_counter + 1;
			END IF;
 
		END IF;
 
		tx_current_state := tx_next_state; 
	END PROCESS;
	tx <= tx_out;
END behav;
