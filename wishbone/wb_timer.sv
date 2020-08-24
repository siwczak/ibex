`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2020 19:18:47
// Design Name: 
// Module Name: wb_timer
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


module wb_timer(
    output timer_irq_o,
    wishbone_if.slave wb
    );
    
    timer timer(
    .clk_i(wb.clk_i),
    .rst_ni(wb.rst_ni),
    .timer_req_i(wb.cyc),
    .timer_addr_i(wb.addr[7-1:2]),
    .timer_we_i(wb.we),
    .timer_be_i(wb.sel),
    .timer_wdata_i(wb.data_m),
    .timer_rvalid_o(wb.ack),
    .timer_rdata_o(wb.data_s),
    .timer_err_o(wb.err),
    .timer_intr_o(timer_irq_o)
    );
    
    assign wb.stall = 1'b0;
endmodule
