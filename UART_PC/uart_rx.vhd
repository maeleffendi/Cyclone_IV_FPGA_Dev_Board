library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity uart_rx is
		port (
				bclk			:in 		std_logic;
				rx				:in 		std_logic;
				data_out		:out 		std_logic_vector(7 downto 0);
				data_rdy		:out		std_logic

		);

end uart_rx;

architecture behav of uart_rx is

	type uart_state is (IDLE, START, DATA, STOP);


begin

	
	process (bclk) is
			
			variable rx_current_state				: uart_state;
			variable rx_next_state					: uart_state;
			variable rx_data							: std_logic_vector (7 downto 0);
			variable clk_counter						: integer range 0 to 15 := 0;
			variable data_counter					: integer range 0 to 7 := 7;
			variable rx_prev							: std_logic;
	
	begin
	
	
			if rising_edge(bclk) then
					
					case rx_current_state is
						when IDLE =>
							if rx_prev = '1' and rx = '0' then
							-- a start bit has be received
								rx_next_state := START;
							end if;
						when START =>
							-- wait for 16 bclk before moving to the next state
							if clk_counter = 15 then
								rx_next_state := DATA;
								clk_counter := 0;
								data_counter := 0;
								data_rdy <= '0';
							else
								clk_counter := clk_counter + 1;
							end if;
						when DATA =>
							--sample data bits at 8 bclk and move to next bit after 16 bclk
							if clk_counter = 7 then
								rx_data(data_counter) := rx;
							elsif clk_counter = 15 then
								clk_counter := 0;
								if data_counter = 7 then
									rx_next_state := STOP;
								else
									data_counter := data_counter + 1;
								end if;
							end if;
							clk_counter := clk_counter + 1;
						when STOP =>
							-- wait for 16 bclk before moving to the next state
							if clk_counter = 15 then
								rx_next_state := IDLE;
								clk_counter := 0;
								data_rdy <= '1';
								data_out <= rx_data;
							else
								clk_counter := clk_counter + 1;
							end if;
						when others =>
					end case;
			rx_prev := rx;
			end if;
			rx_current_state := rx_next_state;
	end process;

end behav;