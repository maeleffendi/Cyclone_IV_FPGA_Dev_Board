LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY uart_baud IS
	PORT (
		clk : IN std_logic;
		bclk : OUT std_logic
	);

END uart_baud;

ARCHITECTURE behav OF uart_baud IS

	CONSTANT fclk_in : INTEGER := 50000000;
	CONSTANT baud_rate : INTEGER := 9600;
	CONSTANT f_bclk : INTEGER := baud_rate * 16;
	CONSTANT baud_divisor : INTEGER := fclk_in/f_bclk;
 
	SIGNAL bclk_out : std_logic := '0';
 
BEGIN
	-- this process generates baud_clock
	PROCESS (clk) IS
	VARIABLE bclk_counter : INTEGER := 0;
 
	BEGIN
		IF rising_edge(clk) THEN
			IF (bclk_counter = baud_divisor) THEN
				bclk_counter := 0;
				bclk_out <= '1';
			ELSE
				bclk_counter := bclk_counter + 1;
				bclk_out <= '0';
			END IF;
		END IF;
 
	END PROCESS; 
	bclk <= bclk_out; 
END behav;
