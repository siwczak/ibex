import uvm_pkg::*;
`include "uvm_macros.svh"
module top;
	bit clk;
	
	initial forever #10 clk = ~clk;
	
	ram_if ram_interface(clk);
	
	p1_ram_data#(.AW(5), .SIZE(32))
	dut(
		.clk_i(clk),
		.addr_i(ram_interface.addr_i),
		.valid_i(ram_interface.valid_i),
		.we_i('1),
		.data_i(ram_interface.data_i),
		.data_o(ram_interface.data_o)
	);
	
	  initial begin
    clk <= 0;
    uvm_config_db#(virtual ram_if)::set(null, "uvm_test_top", "ram_vif", ram_interface);
    run_test("test_top");
  end
	
endmodule