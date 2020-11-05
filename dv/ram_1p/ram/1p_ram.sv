module p1_ram_instr#(
	parameter SIZE = -1,
	parameter AW = -1
) (
	input logic clk_i,
	input logic [AW-1:0] addr_i,
	input logic valid_i,
	//input logic [3:0] we_i,
	input logic [32-1:0] data_i,
	output logic [32-1:0] data_o
);

	logic [31:0] mem [SIZE];

	always_ff @(posedge clk_i)
		if (valid_i)
			data_o <= mem[addr_i];

	localparam MEM_FILE = "sw/blink_slow.mem";
	initial begin
		$display("Initializing SRAM from %s", MEM_FILE);
		$readmemh(MEM_FILE, mem);
	end

endmodule

module p1_ram_data#(
	parameter SIZE = -1,
	parameter AW = -1
) (
	input logic clk_i,
	input logic [AW-1:0] addr_i,
	input logic valid_i,
	input logic [3:0] we_i,
	input logic [32-1:0] data_i,
	output logic [32-1:0] data_o
);

	logic [31:0] mem [SIZE];

	always @(posedge clk_i)
		if (valid_i)
		begin
			if (we_i[0]) mem[addr_i][7:0]   = data_i[7:0];
			if (we_i[1]) mem[addr_i][15:8]  = data_i[15:8];
			if (we_i[2]) mem[addr_i][23:16] = data_i[23:16];
			if (we_i[3]) mem[addr_i][31:24] = data_i[31:24];
		end

	always_ff @(posedge clk_i)
		if (valid_i) begin
			data_o = mem[addr_i];
		end
			
endmodule
