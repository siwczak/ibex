package addr_map_pkg;

	parameter NUM_MASTER = 2;
	parameter NUM_SLAVE = 8;
	parameter RAM_INSTR_BASE_ADDR   = 'h00000000;
	parameter RAM_INSTR_SIZE        = 'h10000;
	parameter RAM_DATA_BASE_ADDR    = 'h00100000;
	parameter RAM_DATA_SIZE         = 'h10000;
	parameter LED_BASE_ADDR         = 'h10000000;
	parameter LED_SIZE              = 'h0fff;
	parameter UART_BASE_ADDR        = 'h10001000;
	parameter UART_SIZE             = 'h0fff;
	parameter I2C_BASE_ADDR         = 'h10002000;
	parameter I2C_SIZE              = 'h0fff;
	parameter SPI_BASE_ADDR         = 'h10003000;
	parameter SPI_SIZE              = 'h0fff;
	parameter TIMER_BASE_ADDR       = 'h10004000;
	parameter TIMER_SIZE            = 'h0fff;
	parameter SPI_SLAVE_BASE_ADDR   = 'h10005000;
	parameter SPI_SLAVE_SIZE        = 'h0fff;

endpackage