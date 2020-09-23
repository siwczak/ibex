module uart_tx #(
	// Parameters
	parameter clk_freq = 50000000,             // Hz
	parameter baud_rate = 19200,               // bits per second
	parameter data_bits = 8,                   // Range:5-9
	parameter parity_type = 0,                 // Range:0=None,1=Odd,2=Even
	parameter stop_bits = 1                    // Range:1-2
)(
	// Outputs
	output                tx,                  // TX port
	output                tx_active,           // Indicating if idle
	// Inputs
	input                 tx_data_vld,         // Data valid
	input [data_bits-1:0] tx_data_in,          // Input data
	input                 rst,                 // Active high synchronous reset
	input                 clk                  // Clock
);

	localparam clock_divide = (clk_freq/baud_rate);


	localparam tx_IDLE = 3'b000;
	localparam tx_START = 3'b001;
	localparam tx_DATA = 3'b010;
	localparam tx_STOP = 3'b011;
	localparam tx_PARITY = 3'b100;
	logic [2:0] tx_STATE, tx_NEXT;

	logic [$clog2(clock_divide):0] clk_div_reg,clk_div_next;
	logic [data_bits-1:0] tx_data_reg, tx_data_next;
	logic tx_out_reg,tx_out_next;
	logic [$clog2(data_bits):0] index_bit_reg,index_bit_next;
	logic [1:0] stop_bits_remaining, stop_bits_remaining_next;

	assign tx_active = (tx_STATE != tx_IDLE);
	assign tx = tx_out_reg;

	// FSM definition
	/*
		Aldec enum fsm_enc CURRENT = tx_STATE
		Aldec enum fsm_enc STATES = tx_IDLE, tx_START, tx_DATA, tx_STOP, tx_PARITY
		Aldec enum fsm_enc TRANS = tx_IDLE -> tx_START,
			tx_IDLE -> tx_IDLE,
			tx_START -> tx_IDLE,
			tx_START -> tx_DATA,
			tx_START -> tx_START,
			tx_DATA -> tx_DATA,
			tx_DATA -> tx_STOP,
			tx_DATA -> tx_PARITY,
			tx_PARITY -> tx_PARITY,
			tx_PARITY -> tx_STOP,
			tx_STOP -> tx_STOP,
			tx_STOP -> tx_IDLE
			Aldec enum fsm_enc SEQ = tx_IDLE -> tx_START -> tx_DATA -> tx_STOP
	*/

	always_ff @(posedge clk) begin
		if(rst) begin
			tx_STATE <= tx_IDLE;
			clk_div_reg <= 0;
			tx_out_reg <= 0;
			tx_data_reg <= 0;
			index_bit_reg <= 0;
			stop_bits_remaining <= stop_bits;
		end
		else begin
			tx_STATE <= tx_NEXT;
			clk_div_reg <= clk_div_next;
			tx_out_reg <= tx_out_next;
			tx_data_reg <= tx_data_next;
			index_bit_reg <= index_bit_next;
			stop_bits_remaining <= stop_bits_remaining_next;
		end
	end

	always_comb begin
		tx_NEXT = tx_STATE;
		clk_div_next = clk_div_reg;
		tx_out_next = tx_out_reg;
		tx_data_next = tx_data_reg;
		index_bit_next = index_bit_reg;
		stop_bits_remaining_next = stop_bits_remaining;

		case(tx_STATE)

			tx_IDLE: begin
				tx_out_next = 1'b1;
				clk_div_next = 0;
				index_bit_next = 0;
				stop_bits_remaining_next = stop_bits;
				if(tx_data_vld == 1) begin
					tx_data_next = tx_data_in;
					tx_NEXT = tx_START;
				end
				else begin
					tx_NEXT = tx_IDLE;
				end
			end

			tx_START: begin
				tx_out_next = 1'b0;
				if(clk_div_reg < clock_divide[$clog2(clock_divide):0]-1'b1) begin
					clk_div_next = clk_div_reg + 1'b1;
					tx_NEXT = tx_START;
				end
				else begin
					clk_div_next = 0;
					tx_NEXT = tx_DATA;
				end
			end

tx_DATA: begin
	tx_out_next = tx_data_reg[index_bit_reg];
	if(clk_div_reg < clock_divide[$clog2(clock_divide):0]-1'b1) begin
		clk_div_next = clk_div_reg + 1'b1;
		tx_NEXT = tx_DATA;
	end
	else begin
		clk_div_next = 0;
		if(index_bit_reg < (data_bits-1)) begin
			index_bit_next = index_bit_reg + 1'b1;
			tx_NEXT = tx_DATA;
		end
		else begin
			index_bit_next = 0;
			if(parity_type == 0) begin
				tx_NEXT = tx_STOP;
			end
			else begin
				tx_NEXT = tx_PARITY;
			end
		end
	end
end

			tx_PARITY: begin
				if(parity_type == 1) begin
					tx_out_next = ^tx_data_reg;
				end
				else if(parity_type == 2) begin
					tx_out_next = ~^tx_data_reg;
				end
				if(clk_div_reg < clock_divide[$clog2(clock_divide):0]-1'b1) begin
					clk_div_next = clk_div_reg + 1'b1;
					tx_NEXT = tx_PARITY;
				end
				else begin
					clk_div_next = 0;
					tx_NEXT = tx_STOP;
				end
			end

			tx_STOP: begin
				tx_out_next = 1'b1;
				if(clk_div_reg < clock_divide[$clog2(clock_divide):0]-1'b1) begin
					clk_div_next = clk_div_reg + 1'b1;
					tx_NEXT = tx_STOP;
				end
				else begin
					clk_div_next = 0;
					stop_bits_remaining_next = stop_bits_remaining - 1'b1;
					if(stop_bits_remaining_next == 2'd0) begin
						tx_NEXT = tx_IDLE;
					end
					else begin
						tx_NEXT = tx_STOP;
					end
				end
			end

			default: tx_NEXT = tx_IDLE;
		endcase
	end

endmodule

