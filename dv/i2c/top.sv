import uvm_pkg::*;
`include "uvm_macros.svh"

module top;

	spi_intf spi_interface();
logic cs=1;
	spi_master#(1) master(
	.clk_i(spi_interface.clk_i),
	.rst_i(spi_interface.rst_i),
	.cyc_i(spi_interface.cyc_i),
	.stb_i(spi_interface.stb_i),
	.adr_i(spi_interface.adr_i),
	.we_i(spi_interface.we_i),
	.dat_i(spi_interface.dat_i),
	.dat_o(spi_interface.dat_o),
	.ack_o(spi_interface.ack_o),
	.inta_o(spi_interface.inta_o),
	.sck_o(spi_interface.sck_o),
	.cs_o(spi_interface.cs_o),
	.mosi_o(spi_interface.mosi_o),
	.miso_i(spi_interface.miso_i)
	);

	spi_slave slave(
	.rst_i(spi_interface.rst_i),
	.clk_i(spi_interface.clk_i),
	.rx_dv_o(spi_interface.rx_dv_o),
	.rx_byte_o(spi_interface.dat_i),
	.tx_dv_i(spi_interface.ack_o),
	.tx_byte_i(spi_interface.dat_o),
	.spi_clk_i(spi_interface.sck_o),
	.miso_o(),
	.mosi_i(spi_interface.mosi_o),
	.cs_i(cs)
	);

	initial begin
		spi_interface.clk_i = 0;
		forever #5 spi_interface.clk_i = ~spi_interface.clk_i;
	end

	initial	begin
		spi_interface.rst_i = 1;
		#100;
		spi_interface.rst_i = 0;
		cs = 0;
	end

	initial
	begin
		uvm_config_db #(virtual spi_intf)::set(null, "*", "spi_intf", spi_interface);
		void'(uvm_config_db #(int)::set(null,"*","no_of_transactions",10));

		uvm_top.finish_on_completion = 1;

		run_test("spi_test");
	end

endmodule