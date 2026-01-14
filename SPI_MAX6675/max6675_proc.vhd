library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity max6675_proc is
		port (
			sys_clk		: in std_logic;
			reset			: in std_logic;
			Drdy			: in std_logic;
			Din			: in std_logic_vector(15 downto 0);
			Dout			: out std_logic_vector (7 downto 0);
			Drdyo			: out std_logic;
			led1			: out std_logic;
			led2			: out	std_logic;
			led3			: out std_logic
		
		);

end max6675_proc;

architecture behav of max6675_proc is

	signal led1_reg	: std_logic;
	signal led2_reg	: std_logic;
	signal led3_reg	: std_logic;
	signal Din_reg		: std_logic_vector(11 downto 0);
	signal Drdy_reg	: std_logic;
	signal Dout_reg	: std_logic_vector (15 downto 0);

begin

	process (sys_clk, reset) is
	
	variable temp_meas	: integer;
	
	begin
	
			if (reset = '1') then
				led1_reg <= '0';
				led2_reg <= '0';
				led3_reg <= '0';
				Din_reg <= (others => '0');
				Dout_reg <= (others => '0');
				Drdy_reg <= '0';
				
				
			elsif (rising_edge(sys_clk)) then
				if (Drdy = '1') then
					Din_reg <= Din(14 downto 3);
				end if;
				
				Drdy_reg <= Drdy;
				temp_meas := to_integer(unsigned(Din_reg)) * 250;
				Dout_reg <= std_logic_vector(to_unsigned(temp_meas,16) srl 8);
				
					if (temp_meas < 15000) then
						led1_reg <= '0';
						led2_reg <= '0';
						led3_reg <= '0';
					elsif (temp_meas >= 15000 and temp_meas < 20000) then
						led1_reg <= '1';
						led2_reg <= '0';
						led3_reg <= '0';
					elsif (temp_meas >= 20000 and temp_meas < 35000) then
						led1_reg <= '0';
						led2_reg <= '1';
						led3_reg <= '0';
					elsif (temp_meas >= 35000) then
						led1_reg <= '0';
						led2_reg <= '0';
						led3_reg <= '1';
					else 
						led1_reg <= '1';
						led2_reg <= '1';
						led3_reg <= '1';
					end if;
				
			
			end if;
	end process;
	led1 <= not led1_reg;
	led2 <= not led2_reg;
	led3 <= not led3_reg;
	Drdyo <= Drdy_reg;
	Dout <= Dout_reg(7 downto 0);

end behav;