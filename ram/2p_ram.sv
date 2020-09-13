module p2_ram#(
    parameter SIZE = -1,
    parameter AW = -1
    ) (
    input logic clk_i,
	
    input logic [AW-1:0] a_addr_i,
    input logic a_valid_i,
    input logic [3:0] a_we_i,
    input logic [32-1:0] a_data_i,
    output logic [32-1:0] a_data_o,
	
	input logic [AW-1:0] b_addr_i,
    input logic b_valid_i,
    input logic [3:0] b_we_i,
    input logic [32-1:0] b_data_i,
    output logic [32-1:0] b_data_o
    );
    
    logic [31:0] mem [SIZE];

   always @(posedge clk_i)
     if (a_valid_i)
       begin
          if (a_we_i[0]) mem[a_addr_i][7:0]   <= a_data_i[7:0];
          if (a_we_i[1]) mem[a_addr_i][15:8]  <= a_data_i[15:8];
          if (a_we_i[2]) mem[a_addr_i][23:16] <= a_data_i[23:16];
          if (a_we_i[3]) mem[a_addr_i][31:24] <= a_data_i[31:24];
       end

   always_ff @(posedge clk_i)
     if (a_valid_i)
       a_data_o <= mem[a_addr_i];

   always @(posedge clk_i)
     if (b_valid_i)
       begin
          if (b_we_i[0]) mem[b_addr_i][7:0]   <= b_data_i[7:0];
          if (b_we_i[1]) mem[b_addr_i][15:8]  <= b_data_i[15:8];
          if (b_we_i[2]) mem[b_addr_i][23:16] <= b_data_i[23:16];
          if (b_we_i[3]) mem[b_addr_i][31:24] <= b_data_i[31:24];
       end

   always_ff @(posedge clk_i)
     if (b_valid_i)
       b_data_o <= mem[b_addr_i];

    localparam MEM_FILE = "sw/blink_slow.mem";
    initial begin
      $display("Initializing SRAM from %s", MEM_FILE);
      $readmemh(MEM_FILE, mem);
    end

endmodule