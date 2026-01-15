-- Copyright (C) 2025  Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Altera and sold by Altera or its authorized distributors.  Please
-- refer to the Altera Software License Subscription Agreements 
-- on the Quartus Prime software download page.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 24.1std.0 Build 1077 03/04/2025 SC Lite Edition"
-- CREATED		"Tue Nov 25 17:33:48 2025"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY i2c_lm75 IS 
	PORT
	(
		clk_sys :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		SDA :  INOUT  STD_LOGIC;
		SCL :  OUT  STD_LOGIC;
		tx :  OUT  STD_LOGIC;
		led1 :  OUT  STD_LOGIC;
		led2 :  OUT  STD_LOGIC
	);
END i2c_lm75;

ARCHITECTURE bdf_type OF i2c_lm75 IS 

COMPONENT i2c_controller
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 SDA_in : IN STD_LOGIC;
		 SCL : OUT STD_LOGIC;
		 OE : OUT STD_LOGIC;
		 SDA_out : OUT STD_LOGIC;
		 Drdy : OUT STD_LOGIC;
		 led1 : OUT STD_LOGIC;
		 led2 : OUT STD_LOGIC;
		 Data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT uart_baud
	PORT(clk : IN STD_LOGIC;
		 bclk : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT uart_tx
	PORT(bclk : IN STD_LOGIC;
		 data_rdy : IN STD_LOGIC;
		 data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 tx : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT lm75_proc
	PORT(sys_clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 Drdy : IN STD_LOGIC;
		 Din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 Drdyo : OUT STD_LOGIC;
		 led1 : OUT STD_LOGIC;
		 Dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(7 DOWNTO 0);


BEGIN 



b2v_inst : i2c_controller
PORT MAP(clk => clk_sys,
		 reset => SYNTHESIZED_WIRE_9,
		 SDA_in => SDA,
		 SCL => SCL,
		 OE => SYNTHESIZED_WIRE_2,
		 SDA_out => SYNTHESIZED_WIRE_1,
		 Drdy => SYNTHESIZED_WIRE_10,
		 Data_out => SYNTHESIZED_WIRE_11);


PROCESS(SYNTHESIZED_WIRE_1,SYNTHESIZED_WIRE_2)
BEGIN
if (SYNTHESIZED_WIRE_2 = '1') THEN
	SDA <= SYNTHESIZED_WIRE_1;
ELSE
	SDA <= 'Z';
END IF;
END PROCESS;


b2v_inst3 : uart_baud
PORT MAP(clk => clk_sys,
		 bclk => SYNTHESIZED_WIRE_3);


b2v_inst4 : uart_tx
PORT MAP(bclk => SYNTHESIZED_WIRE_3,
		 data_rdy => SYNTHESIZED_WIRE_10,
		 data_in => SYNTHESIZED_WIRE_11,
		 tx => tx);


b2v_inst5 : lm75_proc
PORT MAP(sys_clk => clk_sys,
		 reset => SYNTHESIZED_WIRE_9,
		 Drdy => SYNTHESIZED_WIRE_10,
		 Din => SYNTHESIZED_WIRE_11,
		 led1 => led1);


SYNTHESIZED_WIRE_9 <= NOT(reset);



END bdf_type;