module wb_uart(
	input uart_rx_i,
	output uart_tx_o,
	wishbone_if.slave wb
);

	wire [7:0] uart_data_rx;
	// logic [7:0] test;

	//assign test = wb.data_m[7:0];
	assign wb.data_s = {24'h000000, uart_data_rx};  
	//  assign wb.stall = 1'b0;
	// assign wb.err   = 1'b0;

	uart#(
		.clk_freq(50000000),
		.baud_rate(19200),
		.data_bits(8),
		.parity_type(0),
		.parity_type(0),
		.stop_bits(0)
	)uart_top(
		.rx_i(uart_rx_i),
		.tx_data_i(wb.data_m[8-1:0]),
		.tx_data_vld_i(wb.stb),
		.rst_i(~wb.rst_ni),
		.clk_i(wb.clk_i),

		.rx_data_vld_o(wb.ack),
		.rx_data_o(uart_data_rx),
		.rx_parity_err_o(wb.err),
		.tx_o(uart_tx_o),
		.tx_active_o(wb.stall)
	);

endmodule