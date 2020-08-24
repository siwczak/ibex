`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2020 20:15:41
// Design Name: 
// Module Name: ibex_if
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


interface ibex_if(
          input clk_i,
          input rst_ni
          );
    
  logic req;  
  logic gnt;  
  logic rvalid;  
  logic we;  
  logic [3:0] be;  
  logic [31:0] addr;  
  logic [31:0] wdata;  
  logic [31:0] rdata;  
  logic err;
  
   modport master
     (input  clk_i,
      input  rst_ni,
      output req,
      input  gnt,
      input  rvalid,
      output we,
      output be,
      output addr,
      output wdata,
      input  rdata,
      input  err);

   modport slave
     (input  clk_i,
      input  rst_ni,
      input  req,
      output gnt,
      output rvalid,
      input  we,
      input  be,
      input  addr,
      input  wdata,
      output rdata,
      output err);
    
endinterface
