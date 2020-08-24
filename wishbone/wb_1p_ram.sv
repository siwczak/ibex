module wb_1p_ram_instr#(parameter SIZE = -1)
    (
                  wishbone_if.slave wb
    );
    
    localparam ADDR_WIDTH = $clog2(SIZE);
    
    logic valid;
    logic [ADDR_WIDTH-1:0] ram_addr;
    logic ram_valid;
    logic [32-1:0] ram_data_i;
    logic [32-1:0] ram_data_o;
    
    p1_ram_instr#(
        .SIZE(SIZE),
        .AW(ADDR_WIDTH))
    ram(
        .clk_i(wb.clk_i),
        .addr_i(ram_addr),
        .valid_i(ram_valid),
        .data_i(ram_data_i),
        .data_o(ram_data_o)
    );
    
    assign ram_addr = wb.addr[ADDR_WIDTH+1:2];
    assign ram_valid = valid;
    assign ram_data_i = wb.data_m;
    assign wb.data_s = ram_data_o;
    
    
    assign valid = wb.cyc & wb.stb;
    assign wb.stall = 1'b0;
    assign wb.err = 1'b0;
    
    always_ff @(posedge wb.clk_i or posedge wb.rst_ni)
        if (!wb.rst_ni)
            wb.ack <= 1'b0;
        else
            wb.ack <= valid & ~wb.stall;
    
endmodule

module wb_1p_ram_data#(parameter SIZE = -1)
    (
                  wishbone_if.slave wb
    );
    
    localparam ADDR_WIDTH = $clog2(SIZE);
    
    logic valid;
    logic [ADDR_WIDTH-1:0] ram_addr;
    logic ram_valid;
    logic [3:0] ram_we;
    logic [32-1:0] ram_data_i;
    logic [32-1:0] ram_data_o;
    
    p1_ram_data#(
        .SIZE(SIZE),
        .AW(ADDR_WIDTH))
    ram(
        .clk_i(wb.clk_i),
        .addr_i(ram_addr),
        .valid_i(ram_valid),
        .we_i(ram_we),
        .data_i(ram_data_i),
        .data_o(ram_data_o)
    );
    
    assign ram_addr = wb.addr[ADDR_WIDTH+1:2];
    assign ram_valid = valid;
    assign ram_we = {4{wb.we}} & wb.sel;
    assign ram_data_i = wb.data_m;
    assign wb.data_s = ram_data_o;
    
    
    assign valid = wb.cyc & wb.stb;
    assign wb.stall = 1'b0;
    assign wb.err = 1'b0;
    
    always_ff @(posedge wb.clk_i or posedge wb.rst_ni)
        if (!wb.rst_ni)
            wb.ack <= 1'b0;
        else
            wb.ack <= valid & ~wb.stall;
    
endmodule

