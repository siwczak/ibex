`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2020 20:45:07
// Design Name: 
// Module Name: slave_to_wb
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


module slave_to_wb(
       ibex_if.master master,
       wishbone_if.slave wb
    );
    
       logic valid;

   assign valid       = wb.cyc & wb.stb;
   assign master.req   = valid;
   assign master.we    = wb.we;
   assign master.addr  = wb.adr;
   assign master.be    = wb.sel;
   assign master.wdata = wb.data_m;
   assign wb.data_s    = master.rdata;
   assign wb.stall    = ~master.gnt;
   assign wb.err      = master.err;

   always_ff @(posedge wb.clk_i or posedge wb.rst_ni)
     if (!wb.rst_ni)
       wb.ack <= 1'b0;
     else
       wb.ack <= valid & ~wb.stall;
    
endmodule
