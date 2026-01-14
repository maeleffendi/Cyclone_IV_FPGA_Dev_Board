LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY max6675_proc IS
	PORT (
		sys_clk : IN std_logic;
		reset : IN std_logic;
		Drdy : IN std_logic;
		Din : IN std_logic_vector(15 DOWNTO 0);
		Dout : OUT std_logic_vector (7 DOWNTO 0);
		Drdyo : OUT std_logic;
		led1 : OUT std_logic;
		led2 : OUT std_logic;
		led3 : OUT std_logic 
	);

END max6675_proc;

ARCHITECTURE behav OF max6675_proc IS

	SIGNAL led1_reg : std_logic;
	SIGNAL led2_reg : std_logic;
	SIGNAL led3_reg : std_logic;
	SIGNAL Din_reg : std_logic_vector(11 DOWNTO 0);
	SIGNAL Drdy_reg : std_logic;
	SIGNAL Dout_reg : std_logic_vector (15 DOWNTO 0);

BEGIN
	PROCESS (sys_clk, reset) IS
 
	VARIABLE temp_meas : INTEGER;
 
	BEGIN
		IF (reset = '1') THEN
			led1_reg <= '0';
			led2_reg <= '0';
			led3_reg <= '0';
			Din_reg <= (OTHERS => '0');
			Dout_reg <= (OTHERS => '0');
			Drdy_reg <= '0';
 
 
		ELSIF (rising_edge(sys_clk)) THEN
			IF (Drdy = '1') THEN
				Din_reg <= Din(14 DOWNTO 3);
			END IF;
 
			Drdy_reg <= Drdy;
			temp_meas := to_integer(unsigned(Din_reg)) * 250;
			Dout_reg <= std_logic_vector(to_unsigned(temp_meas, 16) SRL 8);
 
			IF (temp_meas < 15000) THEN
				led1_reg <= '0';
				led2_reg <= '0';
				led3_reg <= '0';
			ELSIF (temp_meas >= 15000 AND temp_meas < 20000) THEN
				led1_reg <= '1';
				led2_reg <= '0';
				led3_reg <= '0';
			ELSIF (temp_meas >= 20000 AND temp_meas < 35000) THEN
				led1_reg <= '0';
				led2_reg <= '1';
				led3_reg <= '0';
			ELSIF (temp_meas >= 35000) THEN
				led1_reg <= '0';
				led2_reg <= '0';
				led3_reg <= '1';
			ELSE
				led1_reg <= '1';
				led2_reg <= '1';
				led3_reg <= '1';
			END IF;
 
 
		END IF;
	END PROCESS;
	led1 <= NOT led1_reg;
	led2 <= NOT led2_reg;
	led3 <= NOT led3_reg;
	Drdyo <= Drdy_reg;
	Dout <= Dout_reg(7 DOWNTO 0);

END behav;
