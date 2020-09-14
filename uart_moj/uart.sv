module uart #(
	// Parameters
	parameter clk_freq = 50000000,             // Hz
	parameter baud_rate = 19200,               // bits per second
	parameter data_bits = 8,                   // Range:5-9
	parameter parity_type = 0,                 // Range:0=None,1=Odd,2=Even
	parameter stop_bits = 1                    // Range:1-2
)(
	// Inputs
	input                  rx_i,
	input [data_bits-1:0]  tx_data_i,
	input                  tx_data_vld_i,
	input                  rst_i,
	input                  clk_i,

	// Outputs
	output                 rx_data_vld_o,
	output [data_bits-1:0] rx_data_o,
	output                 rx_parity_err_o,
	output                 tx_o,
	output                 tx_active_o
);

	// Receiver
	uart_rx #(
		.clk_freq(clk_freq),
		.baud_rate(baud_rate))
	receiver(
		.clk(clk_i),
		.rst(rst_i),
		.rx(rx_i),
		.rx_data_out(rx_data_o),
		.rx_data_vld(rx_data_vld_o),
		.rx_parity_err(rx_parity_err_o)
	);

	// Transmitter
	uart_tx #(
		.clk_freq(clk_freq),
		.baud_rate(baud_rate))
	transmitter(
		.clk(clk_i),
		.rst(rst_i),
		.tx_data_vld(tx_data_vld_i),
		.tx_data_in(tx_data_i),
		.tx(tx_o),
		.tx_active(tx_active_o)
	);

endmodule

