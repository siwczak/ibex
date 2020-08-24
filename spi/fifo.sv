module fifo#(
	parameter DATA_WIDTH = -1,
	parameter FIFO_DEPTH = -1,
	localparam FIFO_BIT = $clog2(FIFO_DEPTH))
(input clk_i,
	input rst_i,
	input [DATA_WIDTH - 1:0] data_i,
	input wr_i,
	input rd_i,
	output logic [DATA_WIDTH - 1:0] data_o,
	output full_o,
	output empty_o,
	input clr_i); 

	reg [FIFO_BIT:0] full_indicator;
	reg [FIFO_DEPTH - 1:0] wr_ptr; 
	reg [FIFO_DEPTH - 1:0] rd_ptr; 

	reg[23:0] fifo_mem[FIFO_DEPTH-1];

	assign full_o = (full_indicator == 2**FIFO_BIT);
	assign empty_o = (full_indicator == '0);

	always @(posedge clk_i)
		if (rst_i || clr_i) 
		begin
			wr_ptr <= '0;
			rd_ptr <= '0;
			full_indicator <= '0;
		end
		else
		begin
			case ({rd_i, wr_i})
				2'b00: // nothing
				begin
					full_indicator <= full_indicator;
				end
				2'b01: // write
				begin
					if  (full_indicator < 2**FIFO_BIT)
					begin
						full_indicator <= full_indicator + 1;
						fifo_mem[wr_ptr] <= data_i;
						wr_ptr <= wr_ptr + 1;
					end
				end
				2'b10: // read
				begin
					if (full_indicator > 0)
					begin
						data_o <= fifo_mem[rd_ptr];
						full_indicator <= full_indicator - 1;
						rd_ptr <= rd_ptr + 1;
					end
				end
				2'b11: // read+write
				begin
					wr_ptr <= wr_ptr + 1;
					rd_ptr <= rd_ptr + 1;
					data_o <= fifo_mem[rd_ptr];
					fifo_mem[wr_ptr] <= data_i;
					full_indicator <= full_indicator;
				end
			endcase
		end
endmodule

