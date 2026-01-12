library ieee;
use ieee.std_logic_1164.all;

entity uart_top is
		port (
			clk				: in 	std_logic;
			rx					: in 	std_logic;
			--tx_data			: in 	std_logic_vector (7 downto 0);
			tx_data_rdy		: in 	std_logic;
			rx_data_rdy 	: out std_logic;
			tx					: out std_logic;
			--rx_data			: out std_logic_vector (7 downto 0);
			led				: out std_logic
		);
end uart_top;

architecture structural of uart_top is
	

	signal baud_clock			: std_logic;
	--signal tx_data_reg		: std_logic_vector (7 downto 0) := "01001101";
	signal data_reg			: std_logic_vector (7 downto 0);

	
	begin

			led <= '1' when data_reg = "01001101" else '0';

			BAUD1: 	entity work.uart_baud(behav) 		
			port map (	clk => clk, 
							bclk => baud_clock
						);
			TX1: 		entity work.uart_tx(behav)
			port map (	bclk => baud_clock,
							data_in => data_reg,
							data_rdy => not tx_data_rdy,
							tx => tx
						); 
			RX1: 		entity work.uart_rx(behav)
			port map (	bclk => baud_clock,
							rx => rx,
							data_out => data_reg,
							data_rdy => rx_data_rdy
						); 
			


end structural;