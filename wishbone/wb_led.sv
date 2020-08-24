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


module wb_led(
    output logic [3:0] led,
    wishbone_if.slave wb
    );
    
    logic valid;
    logic select;
    
    always @(posedge wb.clk_i or posedge wb.rst_ni)
        if (!wb.rst_ni)
            led <= '0;
        else
            if (valid && wb.we && select)
                led <= wb.data_m[3:0];
                
   assign valid    = wb.cyc & wb.stb;
   assign select   = wb.addr[11:2] == 0;
   assign wb.stall = 1'b0;
   assign wb.err   = 1'b0;

   always_ff @(posedge wb.clk_i or posedge wb.rst_ni)
     if (!wb.rst_ni)
       wb.ack <= 1'b0;
     else
       wb.ack <= valid & ~wb.stall;

   assign wb.data_s = {28'h0000000, led};          
    
endmodule
