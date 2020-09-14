class uart_trans extends uvm_sequence_item;


	`uvm_object_utils(uart_trans)

	bit rx;
	rand bit [7:0] tx_data_in;
	bit start;
	bit tx;
	bit [7:0] rx_data_out;
	bit tx_active;
	bit rx_data_vld_o;
	bit rx_parity_err_o;


	function new (string name = "");
		super.new(name);
	endfunction



endclass: uart_trans