`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2020 20:54:59
// Design Name: 
// Module Name: ibex_wb
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

////////////IBEX wrapper for WB////////
module ibex_wb#(
    parameter bit          PMPEnable                = 1'b0,
    parameter int unsigned PMPGranularity           = 0,
    parameter int unsigned PMPNumRegions            = 4,
    parameter int unsigned MHPMCounterNum           = 0,
    parameter int unsigned MHPMCounterWidth         = 40,
    parameter bit          RV32E                    = 1'b0,
    parameter bit          RV32M                    = 1'b1,
    parameter bit          RV32B                    = 1'b0,
    parameter bit          BranchTargetALU          = 1'b0,
    parameter bit          WritebackStage           = 1'b0,
    parameter              MultiplierImplementation = "fast",
    parameter bit          ICache                   = 1'b0,
    parameter bit          ICacheECC                = 1'b0,
    parameter bit          DbgTriggerEn             = 1'b0,
    parameter int unsigned DmHaltAddr               = 32'h00000000,
    parameter int unsigned DmExceptionAddr          = 32'h00000000
)(

    input logic clk_i, //clock signal
    input logic rst_ni, //reset active low
    wishbone_if.master data_wb, //wishbone interface for data
    wishbone_if.master instr_wb, //wishbone iterface for instruction
   
    input  logic         test_en_i,                              // Test input, enables clock

    input  logic  [31:0] hart_id_i,                              // Hart ID, usually static, can be read from Hardware Thread ID (mhartid) CSR
    input  logic  [31:0] boot_addr_i,                            // First program counter after reset = boot_addr + 0x80

    input  logic         irq_software_i,                         // Connected to memory-mapped (inter-processor) interrupt register
    input  logic         irq_timer_i,                            // Connected to timer module
    input  logic         irq_external_i,                         // Connected to platform-level interrupt controller
    input  logic  [14:0] irq_fast_i,                             // 15 fast, local interrupts
    input  logic         irq_nm_i,                               // Non-maskable interrupt (NMI)

    input  logic         debug_req_i,                            // Request to enter debug mode

    input  logic         fetch_enable_i,                         // Enable the core, won't fetch when 0
    output logic         core_sleep_o                          // Core in WFI with no outstanding data or instruction accesses.
    );
    
    
    ibex_if data_core (
        .clk_i(clk_i),
        .rst_ni(rst_ni)
        );
        
    ibex_if instr_core (
        .clk_i(clk_i),
        .rst_ni(rst_ni)
        );
    
    ibex_core #(
         .PMPEnable                (PMPEnable),
         .PMPGranularity           (PMPGranularity),
         .PMPNumRegions            (PMPNumRegions),
         .MHPMCounterNum           (MHPMCounterNum),
         .MHPMCounterWidth         (MHPMCounterWidth),
         .RV32E                    (RV32E),
         .RV32M                    (RV32M),
         .MultiplierImplementation (MultiplierImplementation),
         .DbgTriggerEn             (DbgTriggerEn),
         .DmHaltAddr               (DmHaltAddr),
         .DmExceptionAddr          (DmExceptionAddr))
    u_core(
      .clk_i          (clk_i),
      .rst_ni         (rst_ni),

      .test_en_i      (test_en_i),
      .hart_id_i      (hart_id_i),
      .boot_addr_i    (boot_addr_i),

      .instr_req_o    (instr_core.req),    // Request valid, must stay high until instr_gnt is high for one cycle
      .instr_gnt_i    (instr_core.gnt),    // The other side accepted the request. instr_req may be deasserted in the next cycle.
      .instr_rvalid_i (instr_core.rvalid), // instr_rdata holds valid data when instr_rvalid is high. This signal will be high for exactly one cycle per request.
      .instr_addr_o   (instr_core.addr),   // Address, word aligned
      .instr_rdata_i  (instr_core.rdata),  // Data read from memory
      .instr_err_i    (instr_core.err),    // Error response from the bus or the memory: request cannot be handled. High in case of an error.

      .data_req_o     (data_core.req),     // Request valid, must stay high until data_gnt is high for one cycle
      .data_gnt_i     (data_core.gnt),     // The other side accepted the request. data_req may be deasserted in the next cycle.
      .data_rvalid_i  (data_core.rvalid),  // data_rdata holds valid data when data_rvalid is high.
      .data_we_o      (data_core.we),      // Write Enable, high for writes, low for reads. Sent together with data_req
      .data_be_o      (data_core.be),      // Byte Enable. Is set for the bytes to write/read, sent together with data_req
      .data_addr_o    (data_core.addr),    // Address, word aligned
      .data_wdata_o   (data_core.wdata),   // Data to be written to memory, sent together with data_req
      .data_rdata_i   (data_core.rdata),   // Data read from memory
      .data_err_i     (data_core.err),     // Error response from the bus or the memory: request cannot be handled. High in case of an error.

      .irq_software_i (irq_software_i),
      .irq_timer_i    (irq_timer_i),
      .irq_external_i (irq_external_i),
      .irq_fast_i     (irq_fast_i),
      .irq_nm_i       (irq_nm_i),

      .debug_req_i    (debug_req_i),

      .fetch_enable_i (fetch_enable_i),
      .core_sleep_o   (core_sleep_o)
      );
    
    ////////WB//////////////
   assign instr_core.we    = 1'b0;
   assign instr_core.be    = '0;
   assign instr_core.wdata = '0; 
    
    ibex_to_wb data_core2wb
     (.core (data_core),
      .wb   (data_wb));
    
    ibex_to_wb instr_core2wb
     (.core (instr_core),
      .wb   (instr_wb));
    
endmodule
