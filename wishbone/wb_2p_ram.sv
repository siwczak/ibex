module wb_2p_ram_instr#(parameter SIZE = -1)
    (
                  wishbone_if.slave wb_instr,
                  wishbone_if.slave wb_data
    );
	
	    localparam ADDR_WIDTH = $clog2(SIZE);
    
    logic a_valid;
    logic [ADDR_WIDTH-1:0] a_ram_addr;
    logic a_ram_valid;
	logic [3:0] a_ram_we;
    logic [32-1:0] a_ram_data_i;
    logic [32-1:0] a_ram_data_o;
	
	logic b_valid;
    logic [ADDR_WIDTH-1:0] b_ram_addr;
    logic b_ram_valid;
    logic [32-1:0] b_ram_data_o;
    
    p2_ram#(
        .SIZE(SIZE),
        .AW(ADDR_WIDTH))
    ram(
        .clk_i(wb_data.clk_i),
		
        .a_addr_i(a_ram_addr),
        .a_valid_i(a_ram_valid),
        .a_we_i(a_ram_we),
        .a_data_i(a_ram_data_i),
        .a_data_o(a_ram_data_o),
		
		.b_addr_i(b_ram_addr),
        .b_valid_i(b_ram_valid),
		.b_we_i('0),
        .b_data_i('0),
        .b_data_o(b_ram_data_o)
    );
    ///////A port/////////////
    assign a_ram_addr = wb_data.addr[ADDR_WIDTH-1:2];
    assign a_ram_valid = a_valid;
	assign a_ram_we = {4{wb_data.we}} & wb_data.sel;
    assign a_ram_data_i = wb_data.data_m;
    assign wb_data.data_s = a_ram_data_o;
    
    
    assign a_valid = wb_data.cyc & wb_data.stb;
    assign wb_data.stall = 1'b0;
    assign wb_data.err = 1'b0;
    
    always_ff @(posedge wb_data.clk_i or posedge wb_data.rst_ni)
        if (!wb_data.rst_ni)
            wb_data.ack <= 1'b0;
        else
            wb_data.ack <= a_valid & ~wb_data.stall;
		
		
		///////B port////////
    assign b_ram_addr = wb_instr.addr[ADDR_WIDTH-1:2];
    assign b_ram_valid = b_valid;
    assign wb_instr.data_s = b_ram_data_o;
    
    
    assign b_valid = wb_instr.cyc & wb_instr.stb;
    assign wb_instr.stall = 1'b0;
    assign wb_instr.err = 1'b0;
    
    always_ff @(posedge wb_instr.clk_i or posedge wb_instr.rst_ni)
        if (!wb_instr.rst_ni)
            wb_instr.ack <= 1'b0;
        else
            wb_instr.ack <= b_valid & ~wb_instr.stall;
		
endmodule