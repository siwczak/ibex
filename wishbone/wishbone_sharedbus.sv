`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2020 23:44:59
// Design Name: 
// Module Name: wishbone_sharedbus
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


module wishbone_sharedbus#(
    parameter num_master = -1,
    parameter num_slave = -1,
    parameter bit [31:0] base_addr[num_slave] = '{-1},
    parameter bit [31:0] size[num_slave] = '{-1} 
    )(
    wishbone_if.slave wb_master[num_master],
    wishbone_if.master wb_slave[num_slave]
    );
    //wspolne sygnaly////
    logic cyc;
    logic stb;
    logic we;
    logic ack;
    logic err;
    logic stall;
    logic [31:0] addr;
    logic [3:0] sel;
    logic [31:0] data_wr;
    logic [31:0] data_rd;
    logic [num_master - 1:0] gnt,gnt1;
    logic [num_slave - 1:0] ss,ss1;
/////master signlas/////
    logic wb_master_cyc [num_master];
    logic wb_master_stb [num_master];
    logic wb_master_we [num_master];
    logic wb_master_ack [num_master];
    logic wb_master_err [num_master];
    logic wb_master_stall [num_master];
    logic [31:0] wb_master_addr [num_master];
    logic [3:0] wb_master_sel [num_master];
    logic [31:0] wb_master_data_o [num_master];
    logic [31:0] wb_master_data_i [num_master];
    
/////////////slave signlas//////////    
    logic wb_slave_cyc [num_slave];
    logic wb_slave_stb [num_slave];
    logic wb_slave_we [num_slave];
    logic wb_slave_ack [num_slave];
    logic wb_slave_err [num_slave];
    logic wb_slave_stall [num_slave];
    logic [31:0] wb_slave_addr [num_slave];
    logic [3:0] wb_slave_sel [num_slave];
    logic [31:0] wb_slave_data_o [num_slave];
    logic [31:0] wb_slave_data_i [num_slave];
    
    /////////reading from master/////////
    for (genvar i = 0; i < num_master; i++)
        begin
            assign wb_master_cyc[i] = wb_master[i].cyc;
            assign wb_master_stb[i] = wb_master[i].stb;
            assign wb_master_we[i] = wb_master[i].we;
            assign wb_master_addr[i] = wb_master[i].addr;
            assign wb_master_sel[i] = wb_master[i].sel;
            assign wb_master_data_i[i] = wb_master[i].data_m;
            
            assign wb_master[i].data_s = wb_master_data_o[i];
            assign wb_master[i].stall = wb_master_stall[i];
            assign wb_master[i].err = wb_master_err[i];
            assign wb_master[i].ack = wb_master_ack[i];            
         end
         
    ///////////////reading from slave///////////
        for (genvar i = 0; i < num_slave; i++)
        begin
            assign wb_slave[i].cyc = wb_slave_cyc[i];
            assign wb_slave[i].stb = wb_slave_stb[i];
            assign wb_slave[i].we = wb_slave_we[i];
            assign wb_slave[i].addr = wb_slave_addr[i];
            assign wb_slave[i].sel = wb_slave_sel[i];
            assign wb_slave[i].data_m = wb_slave_data_o[i];
            
            assign wb_slave_data_i[i] = wb_slave[i].data_s;
            assign wb_slave_stall[i] = wb_slave[i].stall;
            assign wb_slave_err[i] = wb_slave[i].err;
            assign wb_slave_ack[i] = wb_slave[i].ack;            
         end
         
         
     //////////addres for slave/////////
     always_comb
        for (int i = 0; i < num_slave; i++)
            ss[i] = addr inside {[base_addr[i]:(base_addr[i]+size[i])]};
            
     always_ff @(posedge wb_slave[0].clk_i or posedge wb_slave[0].rst_ni)
        if (!wb_slave[0].rst_ni)
            ss1 <= '0;
        else
        if (cyc && stb)
            ss1 <= ss;
            
     always_comb
     begin
        gnt = '0;
        for (int i = 0; i < num_master; i++)
          if (wb_master_cyc[i])
            begin
               gnt[i] = 1'b1;
               break;
            end
     end
     
     always_ff @(posedge wb_master[0].clk_i or posedge wb_master[0].rst_ni)
     if (!wb_master[0].rst_ni)
       gnt1 <= '0;
     else
       if (cyc && stb)
         gnt1 <= gnt;
         
   /* shared bus signals */
   always_comb
     begin
        cyc    = 1'b0;
        addr    = '0;
        stb    = 1'b0;
        we     = 1'b0;
        sel    = '0;
        data_wr = '0;
        for (int i = 0; i < num_master; i++)
          begin
             cyc |= wb_master_cyc[i];
             if (gnt[i])
               begin
                  addr    = wb_master_addr[i];
                  stb    = wb_master_stb[i];
                  we     = wb_master_we[i];
                  sel    = wb_master_sel[i];
                  data_wr = wb_master_data_i[i];
               end
          end
     end

   always_comb
     begin
        ack    = 1'b0;
        err    = 1'b0;
        stall  = 1'b0;
        data_rd = '0;
        for (int i = 0; i < num_slave; i++)
          begin
             ack   |= wb_slave_ack[i];
             err   |= wb_slave_err[i];
             stall |= wb_slave_stall[i];
             if (ss1[i])
               data_rd = wb_slave_data_i[i];
          end
     end

   /* interconnect */

   /* STALL must respond immediately. */
   always_comb
     begin
        for (int i = 0; i < num_master; i++)
          begin
             wb_master_stall[i] = 1'b1;
             if (gnt[i])
               wb_master_stall[i] = stall;
          end
     end

   /* Response signals are one cycle delayed. */
   always_comb
     begin
        for (int i = 0; i < num_master; i++)
          begin
             wb_master_ack[i]   = 1'b0;
             wb_master_err[i]   = 1'b0;
             wb_master_data_o[i] = '0;
             if (gnt1[i])
               begin
                  wb_master_ack[i]   = ack;
                  wb_master_err[i]   = err;
                  wb_master_data_o[i] = data_rd;
               end
          end
     end

   always_comb
     for (int i = 0; i < num_slave; i++)
       begin
          wb_slave_cyc[i]   = cyc;
          wb_slave_addr[i]   = '0;
          wb_slave_stb[i]   = 1'b0;
          wb_slave_we[i]    = we;
          wb_slave_sel[i]   = '0;
          wb_slave_data_o[i] = '0;
          if (ss[i])
            begin
               wb_slave_addr[i]   = addr;
               wb_slave_stb[i]   = cyc & stb;
               wb_slave_sel[i]   = sel;
               wb_slave_data_o[i] = data_wr;
            end
       end
endmodule
