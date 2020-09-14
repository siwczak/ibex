`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2020 17:07:15
// Design Name: 
// Module Name: wb_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wb_uart(
	input uart_rx_i,
	output uart_tx_o,
	wishbone_if.slave wb
);

	wire [7:0] uart_data_rx;
	logic [7:0] test;


	assign test = wb.data_m[7:0];
	assign wb.data_s = {24'h000000, uart_data_rx};  
	assign wb.stall = 1'b0;
	assign wb.err   = 1'b0;
	uart_top uart16550_0
	(// Wishbone slave interface
		.wb_clk_i	(wb.clk_i),
		.wb_rst_i	(~wb.rst_ni),
		.wb_adr_i	(wb.addr[4:2]),
		.wb_dat_i	(wb.data_m[7:0]),
		.wb_we_i	(wb.we),
		.wb_cyc_i	(wb.cyc),
		.wb_stb_i	(wb.stb),
		.wb_sel_i	(4'b0), // Not used in 8-bit mode
		.wb_dat_o	(uart_data_rx),
		.wb_ack_o	(wb.ack),

		// Outputs
		.int_o     (),
		.stx_pad_o (uart_tx_o),
		.rts_pad_o (),
		.dtr_pad_o (),

		// Inputs
		.srx_pad_i (uart_rx_i),
		.cts_pad_i (1'b0),
		.dsr_pad_i (1'b0),
		.ri_pad_i  (1'b0),
		.dcd_pad_i (1'b0));


endmodule
