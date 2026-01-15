library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity uart_baud is
		port (
				clk			:in 		std_logic;
				bclk			:out 		std_logic
		);

end uart_baud;

architecture behav of uart_baud is

	constant fclk_in			: integer := 50000000;
	constant baud_rate		: integer := 9600;
	constant f_bclk			: integer:= baud_rate*16;
	constant baud_divisor	: integer := fclk_in/f_bclk;
	
	signal bclk_out			: std_logic  := '0';
	
begin
	
	-- this process generates baud_clock
	process (clk) is
		variable bclk_counter		: integer :=0;
		
		begin
				if rising_edge(clk) then
					if (bclk_counter = baud_divisor) then
							bclk_counter := 0;
							bclk_out <= '1';
					else
							bclk_counter := bclk_counter + 1; 
							bclk_out <= '0';
					end if;
				end if;
					
		end process;	
		bclk <= bclk_out;	
end behav;
