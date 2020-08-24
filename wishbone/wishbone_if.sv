`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2020 19:18:33
// Design Name: 
// Module Name: wishbone_if
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


interface wishbone_if(
        input rst_ni,
        input clk_i
    );
     logic [31:0] addr;   
     logic [31:0] data_m; //data master  
     logic [31:0] data_s; //data slave  
     logic we;
     logic [3:0] sel;
     logic stb;
     logic ack;
     logic cyc;
     logic err;
     logic stall;
     
     modport master(
        input clk_i,
        input rst_ni,
        output addr,
        output data_m,
        input data_s,
        output we,
        output sel,
        output stb,
        input ack,
        output cyc,
        input err,
        input stall);
        
     modport slave(
        input clk_i,
        input rst_ni,
        input addr,
        input data_m,
        output data_s,
        input we,
        input sel,
        input stb,
        output ack,
        input cyc,
        output err,
        output stall);
        
endinterface
