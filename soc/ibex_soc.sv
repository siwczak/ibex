module ibex_soc
import addr_map_pkg::*;
	#(localparam SPI_SLAVE_NUMBER = 1)(
		input                    I_CLK,
		input                    I_RST_N,
		output [3:0]             O_LED,
		input [3:0]             I_BUTTON,
		input                    I_UART_RX,
		output                   O_UART_TX,
		inout                    IO_SDA,
		inout                    IO_SCL,
		input                    I_MISO,
		input                    I_MOSI,
		output                   O_MOSI,
		output                   O_MISO,
		output                   O_SCK,
		input                   I_SCK,
		input                   I_CS,
		output [SPI_SLAVE_NUMBER - 1:0] O_CS_SPI
	);

	logic clk_sys, rst_sys_n;
	logic irq_timer;
	logic irq_spi;
	logic [15-1:0] irq_fast;
	logic [8-1:0] isp_data;
	// Clock and reset
	clkgen
	clkgen(
		.IO_CLK(I_CLK),
		.IO_RST_N(I_RST_N),
		.clk_sys,
		.rst_sys_n
	);

	/////////////////wishbone/////////////////
	wishbone_if wb_master[NUM_MASTER](.clk_i(clk_sys),.rst_ni(rst_sys_n)); //0 for data, 1 for instr
	wishbone_if wb_slave[NUM_SLAVE](.clk_i(clk_sys),.rst_ni(rst_sys_n)) ; //0-ram,2-gpio,3-uart,4-i2c,5-spi,6-spi-slave,7-timer

	//////////////////////ibex core////////////////////
	ibex_wb ibex_wishbone (
		.clk_i(clk_sys),
		.rst_ni(rst_sys_n),
		.data_wb(wb_master[0]),
		.instr_wb(wb_master[1]),
		.test_en_i (1'b0),
		.hart_id_i (32'b0),
		.boot_addr_i (32'h00000000),
		.irq_software_i        (1'b0),
		.irq_timer_i           (),
		.irq_external_i        (1'b0),
		.irq_fast_i            (),
		.irq_nm_i              (1'b0),

		.debug_req_i           (1'b0),

		.fetch_enable_i        (1'b1),
		.core_sleep_o          ()
	);

	wishbone_sharedbus
	#(.num_master      (NUM_MASTER),
		.num_slave      (NUM_SLAVE),
		.base_addr ('{RAM_INSTR_BASE_ADDR,RAM_DATA_BASE_ADDR, LED_BASE_ADDR, UART_BASE_ADDR, I2C_BASE_ADDR, SPI_BASE_ADDR, TIMER_BASE_ADDR,SPI_SLAVE_BASE_ADDR}),
		.size      ('{RAM_INSTR_SIZE, RAM_DATA_SIZE,LED_SIZE, UART_SIZE, I2C_SIZE, SPI_SIZE, TIMER_SIZE,SPI_SLAVE_SIZE}))       
	wb_share_bus
	   (.wb_master(wb_master),
		.wb_slave(wb_slave));

`ifndef P2_RAM
	wb_2p_ram_instr #(
		.SIZE(RAM_INSTR_SIZE)
	) ram_instr (
		.wb_instr(wb_slave[0]),
		.wb_data(wb_slave[1])
	);
`else
	wb_1p_ram_instr #(
		.SIZE(RAM_INSTR_SIZE)
	) ram_instr (
		.wb(wb_slave[0])
	);

	wb_1p_ram_data #(
		.SIZE(RAM_DATA_SIZE)
	) ram_data (
		.wb(wb_slave[1])
	);
`endif
	wb_gpio wb_gpio
	(.wb(wb_slave[2]),
		.led(O_LED),
		.button(I_BUTTON));

	wb_uart wb_uart(
		.wb(wb_slave[3]),
		.uart_rx_i(I_UART_RX),
		.uart_tx_o(O_UART_TX)
	);

	wb_i2c wb_i2c(
		.wb(wb_slave[4]),
		.IO_SDA(IO_SDA),
		.IO_SCL(IO_SCL)
	);

	wb_spi_master#(
		.SPI_SLAVE(SPI_SLAVE_NUMBER)
	) wb_spi_master(
		.miso_i(I_MISO),
		.mosi_o(O_MOSI),
		.sck_o(O_SCK),
		.cs_o(O_CS_SPI),
		.irq_o(irq_spi),
		.wb(wb_slave[5])
	);

	wb_timer wb_timer(
		.wb(wb_slave[6]),
		.timer_irq_o(irq_timer)
	);

	wb_spi_slave wb_spi_slave(
		.miso_o(O_MISO),
		.mosi_i(I_MOSI),
		.sck_i(I_SCK),
		.cs_i(I_CS),
		.wb(wb_slave[7])
	);

	assign irq_fast = {14'd0,irq_spi};

endmodule
