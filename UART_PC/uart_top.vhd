LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY uart_top IS
	PORT (
		clk : IN std_logic;
		rx : IN std_logic;
		--tx_data : in std_logic_vector (7 downto 0);
		tx_data_rdy : IN std_logic;
		rx_data_rdy : OUT std_logic;
		tx : OUT std_logic;
		--rx_data : out std_logic_vector (7 downto 0);
		led : OUT std_logic
	);
END uart_top;

ARCHITECTURE structural OF uart_top IS
 

	SIGNAL baud_clock : std_logic;
	--signal tx_data_reg : std_logic_vector (7 downto 0) := "01001101";
	SIGNAL data_reg : std_logic_vector (7 DOWNTO 0);

 
BEGIN
	led <= '1' WHEN data_reg = "01001101" ELSE '0';

	BAUD1 : ENTITY work.uart_baud(behav) 
		PORT MAP(
			clk => clk, 
			bclk => baud_clock
		);
			TX1 : ENTITY work.uart_tx(behav)
				PORT MAP(
					bclk => baud_clock, 
					data_in => data_reg, 
					data_rdy => NOT tx_data_rdy, 
					tx => tx
				);
					RX1 : ENTITY work.uart_rx(behav)
						PORT MAP(
							bclk => baud_clock, 
							rx => rx, 
							data_out => data_reg, 
							data_rdy => rx_data_rdy
						);
 
END structural;
