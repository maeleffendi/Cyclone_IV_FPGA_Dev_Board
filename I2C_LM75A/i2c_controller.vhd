-- Quartus Prime VHDL Template
-- Four-State Mealy State Machine

-- A Mealy machine has outputs that depend on both the state and
-- the inputs.	When the inputs change, the outputs are updated
-- immediately, without waiting for a clock edge.  The outputs
-- can be written more than once per state or per clock cycle.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_controller is
		port ( 
				clk	 : in 	std_logic;
				reset	 		: in  	std_logic;
				SCL		 : out	std_logic;
				OE			:out std_logic;
				SDA_in		 :in	std_logic;
				SDA_out		 :out	std_logic;
				Data_out : out 	std_logic_vector (7 downto 0);
				Drdy	 : out 	std_logic;
				led1		:out	std_logic;
				led2	: out std_logic
		);
end entity;

architecture rtl of i2c_controller is


	type i2c_state is (IDLE, START, ADDR, ACK1, MSB, ACK2, LSB, ACK3, STOP);
	
	constant scl_t					: integer := 400-1;	 -- one SCL period @ 400kHz
	constant scl_t4				: integer := 100-1;	 -- SCL period *0.25
	constant scl_t2				: integer := 200-1;	 -- SCL period * 0.5
	constant scl_t34				: integer := 300-1;		--SCL period * 0.75
	
	constant lm75a_addr			: std_logic_vector(7 downto 0) := "10010001";   --7-bit address followed by 1-bit R/W
	
	constant conversion_period : integer := 25000000-1;	--100ms period between conversions
	constant start_condition	 : integer := 20-1;		--200ns for start condition t4
	constant stop_condition	 : integer := 20-1;		--200ns for stop condition t5
	
	signal SCL_reg		: std_logic;
	signal SDA_reg		: std_logic;
	signal Data_reg	: std_logic_vector (15 downto 0);

begin

	process (clk, reset)
	
		variable clk_counter		: integer;
		variable scl_enable		: std_logic;
		variable	current_state	: i2c_state;
		variable bit_counter		: integer;
	
	begin

		if reset = '1' then
			
			current_state := IDLE;
			clk_counter := 0;
			bit_counter := 0;
			scl_enable := '0';
			SCL_reg <= '0';
			SDA_reg <= '0';
			SCL <= '0';
			SDA_out <= '0';
			OE <= '0';
			
		elsif (rising_edge(clk)) then
			
			clk_counter := clk_counter + 1;
			
			case current_state is
				when IDLE =>
					--wait for the conversion period to pass, then move to start
					SDA_out <= '1';
					SCL <= '1';
					OE <= '1';
					if clk_counter >= conversion_period then
						current_state := START;
						Drdy <= '0';
						clk_counter := 0;
					else
						current_state := IDLE;
					end if;
				when START =>
					SDA_out <= '0';
					OE <= '1';
					if clk_counter >= start_condition then
						scl_enable := '1';
						SCL_reg <= '0';
						clk_counter := 0;
						bit_counter := 0;
						current_state := ADDR;
					else
						current_state := START;
					end if;
				when ADDR =>
					if bit_counter > 7 then
						bit_counter := 0;
						current_state := ACK1;
					else 
						SDA_reg <= lm75a_addr(7 - bit_counter);
						current_state := ADDR;
					end if;
				when ACK1 =>
					SDA_reg <= '0';
					OE <= '1';
					if bit_counter = 1 then
						bit_counter := 0;
						current_state := MSB;
					else 
						current_state := ACK1;
					end if;
				when MSB =>
					SDA_reg <= 'Z';
					OE <= '0';
					if bit_counter > 7 then
						bit_counter := 0;
						current_state := ACK2;
					else 
						current_state := MSB;
					end if;
				when ACK2 =>
					SDA_reg <= '0';
					OE <= '1';
					if bit_counter = 1 then
						bit_counter := 7;
						current_state := LSB;
					else 
						current_state := ACK2;
					end if;
				when LSB =>
					--SDA_reg <= 'Z';
					OE <= '0';
					if bit_counter > 15 then
						bit_counter := 0;
						current_state := ACK3;
					else 
						current_state := LSB;
					end if;
				when ACK3 =>
					SDA_reg <= '1';
					OE <= '1';
					if bit_counter = 1 then
						SDA_reg <= '0';
					elsif bit_counter = 2 then
						bit_counter := 0;
						current_state := STOP;
						scl_enable := '0';
						SCL <= '1';
					else 
						current_state := ACK3;
					end if;
				when STOP =>
					--if clk_counter >= stop_condition then
						SCL <= '1';
						SDA_reg <= '1';
						OE <= '1';
						clk_counter := 0;
						Drdy <= '1';
						current_state := IDLE;
						
					--else
					--	current_state := STOP;

					--end if;
			end case;
			
			
			if scl_enable = '1' then
				if clk_counter = scl_t4 then
					--change SDA state for output
					SDA_out <= SDA_reg;
				elsif clk_counter = scl_t2 then
					--Flip SCL
					SCL_reg <= not SCL_reg;
				elsif clk_counter = scl_t34 then
					--Read SDA state for input
						if (current_state = MSB) or (current_state = LSB) then
							Data_reg(15 - bit_counter) <= SDA_in;
						end if;
				elsif clk_counter = scl_t then
					--Flip SCL
					SCL_reg <= not SCL_reg;
					bit_counter := bit_counter + 1;
					clk_counter := 0;
				end if;
				SCL <= SCL_reg;
			end if;
			
			
			Data_out <= Data_reg(14 downto 7);
			
			

		end if;
	end process;

end rtl;
