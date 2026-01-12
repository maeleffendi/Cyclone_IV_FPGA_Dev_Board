library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity uart_tx is
		port (
				bclk			:in 		std_logic;
				data_in		:in 		std_logic_vector(7 downto 0);
				data_rdy		:in		std_logic;
				tx				:out 		std_logic
		);

end uart_tx;


architecture behav of uart_tx is

	type uart_state is (IDLE, START, DATA, STOP);

	signal tx_out				: std_logic;
	
	begin
	-- this process implements the state machine for the transmitter
	process (bclk, data_rdy) is
		
		variable tx_data							: std_logic_vector (7 downto 0);
		variable new_data							: std_logic;
		variable tx_current_state				: uart_state;
		variable tx_next_state					: uart_state;
		variable clk_counter						: integer range 0 to 15 := 0;
		variable data_counter					: integer range 0 to 7;

		
		begin
				
				if rising_edge(bclk) then
						if (data_rdy = '1') then
							tx_data := data_in;
							new_data := '1';
						end if;
				
						if clk_counter = 15 then
							clk_counter := 0;
							case tx_current_state is
								when IDLE =>
										tx_out <= '1';
										if new_data = '1' then
											tx_next_state := START;
											new_data := '0';
										end if;
								when START =>
										tx_out <= '0';
										tx_next_state := DATA;
										data_counter := 0;
								when DATA =>
										tx_out <= tx_data(data_counter);
										if data_counter = 7 then
											data_counter := 0;
											tx_next_state := STOP;
										else
											data_counter := data_counter + 1;
										end if;
								when STOP =>
										tx_out <= '1';
										tx_next_state := IDLE;
								when others =>
							end case;
						else
								clk_counter := clk_counter + 1;
						end if;
						
				end if;
				
			tx_current_state := tx_next_state;	
		end process;
		tx <= tx_out;
	end behav;