interface uart_intf;

	logic clk,rst;
	logic rx;
	logic [7:0] tx_data_in;
	logic start;
	logic tx;
	logic [7:0] rx_data_out;
	logic tx_active;
	logic rx_data_vld_o; 
	logic rx_parity_err_o; 

endinterface