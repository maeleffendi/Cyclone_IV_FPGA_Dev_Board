This project demonstrates SPI interface implementation to temperature sensor MAX6675.
MAX6675 is a cold-junction compensated K-type thermocouple to digital converter. It digitizes the signal from a type-K thermocouple and outputs a 12-bit voltage (uV) over the SPI interface. The Serial Interface Protcol and the 16-bit sensor output is shown below.
Image
Image
A block diagram of the HDL implementation is shown below. A PLL is used to derive a 1MHz clock from the onboard 50MHz oscillator. This 1MHz clock is used to drive the SPI interface. The spi_controller block is responsible of the SPI protocol implementation. It receives the serial data and converts it to a parallel data on its output. This is fed to the max6675_proc block which converts the uV voltage value into temperature. 

A uart interface is implemented to allow for the temperature reading to be sent to the PC over UART interface. Refer to UART_PC for information about the UART implementation.

