library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lm75_proc is
		port (
			sys_clk		: in std_logic;
			reset			: in std_logic;
			Drdy			: in std_logic;
			Din			: in std_logic_vector(7 downto 0);
			Dout			: out std_logic_vector (7 downto 0);
			Drdyo			: out std_logic;
			led1			: out std_logic
		
		);

end lm75_proc;

architecture behav of lm75_proc is

	signal Drdy_reg	: std_logic;
	signal Dout_reg	: std_logic_vector (7 downto 0);
	signal led1_reg	: std_logic;

begin

	process (sys_clk, reset) is
	
	variable temp_meas	: integer;
	
	begin
	
			if (reset = '1') then
				Dout_reg <= (others => '0');
				Drdy_reg <= '0';
				led1_reg <= '0';
				
			elsif (rising_edge(sys_clk)) then
				if (Drdy = '1') then
					Dout_reg <= Din;
				end if;
				
				temp_meas := to_integer(unsigned(Dout_reg));
				
				if temp_meas > 20 then
					led1_reg <= '1';
				else
					led1_reg <= '0';
				end if;
				
				Drdy_reg <= Drdy;
				
				if (to_integer(unsigned(Dout_reg)) >= 41) then
					led1 <= '1';
				else
					led1 <= '0';
				end if;
			
			end if;
	end process;

	Drdyo <= Drdy_reg;
	Dout <= Dout_reg;

end behav;