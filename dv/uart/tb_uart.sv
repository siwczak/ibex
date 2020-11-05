`include "uvm_macros.svh"
import uvm_pkg::*;
module tb_uart_top;


	bit clk;
	bit rst;

	uart_intf intf();

	uart    dut(
		.clk_i(intf.clk),
		.rst_i(intf.rst),
		.rx_i(intf.rx),
		.tx_data_i(intf.tx_data_in),
		.tx_data_vld_i(intf.start),
		.rx_data_o(intf.rx_data_out),
		.tx_o(intf.tx),
		.tx_active_o(intf.tx_active),
		.rx_data_vld_o(intf.rx_data_vld_o),
		.rx_parity_err_o(intf.rx_parity_err_o)
	);

	// Clock generator
	initial
	begin
		intf.clk = 0;
		forever #5 intf.clk = ~intf.clk;
	end

	initial
	begin
		intf.rst = 1;
		#1000;
		intf.rst = 0;
	end



	initial
	begin
		uvm_config_db #(virtual uart_intf)::set(null, "*", "uart_intf", intf);
		void'(uvm_config_db #(int)::set(null,"*","no_of_transactions",20));

		uvm_top.finish_on_completion = 1;

		run_test("uart_test");
	end

endmodule: tb_uart_top