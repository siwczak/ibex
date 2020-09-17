`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2020 00:23:33
// Design Name: 
// Module Name: wb_led
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


module wb_gpio(
    output logic [3:0] led,
    input logic [3:0] button,
    wishbone_if.slave wb
    );
    
    logic valid;
    logic select_led;
    logic select_but;
    bit [3:0] data_s;
	gpio gpio(
	  .clk_i(wb.clk_i),
	  .rst_ni(wb.rst_ni),
	  .led(led),
	  .button(button),
	  .valid(valid),
	  .data_s(data_s),
	  .data_m(wb.data_m[3:0]),
	  .sel_led(select_led),
	  .sel_but(select_but),
	  .we(wb.we)
	);
           
   assign valid    = wb.cyc & wb.stb;
   assign select_led   = wb.addr[11:2] == 0;
   assign select_but   = wb.addr[11:2] == 1;
   assign wb.stall = 1'b0;
   assign wb.err   = 1'b0;

   always_ff @(posedge wb.clk_i or posedge wb.rst_ni)
     if (!wb.rst_ni)
       wb.ack <= 1'b0;
     else
       wb.ack <= valid & ~wb.stall;

   assign wb.data_s = {28'h0000000, data_s};          
    
endmodule
