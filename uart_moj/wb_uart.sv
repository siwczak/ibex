module wb_uart(
	input uart_rx_i,
	output uart_tx_o,
	wishbone_if.slave wb
);

	wire [7:0] uart_data_rx;
	logic valid_i;
	logic valid_o;

	assign wb.data_s = {24'h000000, uart_data_rx};  

	uart#(
		.clk_freq(50000000),
		.baud_rate(19200),
		.data_bits(8),
		.parity_type(0),
		.stop_bits(0)
	)uart_top(
		.rx_i(uart_rx_i),
		.tx_data_i(wb.data_m[8-1:0]),
		.tx_data_vld_i(valid_i),
		.rst_i(~wb.rst_ni),
		.clk_i(wb.clk_i),

		.rx_data_vld_o(valid_o),
		.rx_data_o(uart_data_rx),
		.rx_parity_err_o(wb.err),
		.tx_o(uart_tx_o),
		.tx_active_o(wb.stall)
	);

	assign valid_i = wb.cyc & wb.stb;

	always_ff @(posedge wb.clk_i or posedge wb.rst_ni)
		if (!wb.rst_ni)
			wb.ack <= 1'b0;
		else
			wb.ack <= valid_o & ~wb.stall;

endmodule