import uvm_pkg::*;
`include "uvm_macros.svh"
module top;
	bit clk;
	
	initial forever #10 clk = ~clk;
	
	gpio_if gpio_interface(clk);
	
	gpio dut(
	.led(gpio_interface.led),
	.button(gpio_interface.button),
	.clk_i(clk),
	.rst_ni(gpio_interface.rst_ni),
	.valid(gpio_interface.valid),
	.data_s(gpio_interface.data_s),
	.data_m(gpio_interface.data_m),
	.sel_led(gpio_interface.sel_led),
	.sel_but(gpio_interface.sel_but),
	.we(gpio_interface.we)
	);
	
	  initial begin
    clk <= 0;
    uvm_config_db#(virtual gpio_if)::set(null, "uvm_test_top", "gpio_vif", gpio_interface);
    run_test("test_top");
  end
	
endmodule