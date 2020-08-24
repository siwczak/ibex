module i2c_master_byte_ctrl
import i2c_package::*;
	(
		input clk,
		input [6:0] my_addr,
		input rst,
		input nReset,
		input ena,
		input [15:0] clk_cnt,
		input start,
		input stop,
		input read,
		input write,
		input ack_in,
		input [7:0] din,
		output reg cmd_ack,
		output reg ack_out,
		output [7:0] dout,
		output i2c_busy,
		output i2c_al,
		input sl_cont,
		input scl_i,
		output scl_o,
		output scl_oen,
		input sda_i,
		output sda_o,
		output sda_oen,
		output reg slave_dat_req,
		input slave_en,
		output reg slave_dat_avail,
		output reg slave_act,
		output reg slave_cmd_ack
	);

	//
	// Variable declarations
	//

	// statemachine
	parameter [9:0] ST_IDLE       = 10'b00_0000_0000;
	parameter [9:0] ST_START      = 10'b00_0000_0001;
	parameter [9:0] ST_READ       = 10'b00_0000_0010;
	parameter [9:0] ST_WRITE      = 10'b00_0000_0100;
	parameter [9:0] ST_ACK        = 10'b00_0000_1000;
	parameter [9:0] ST_STOP       = 10'b00_0001_0000;
	parameter [9:0] ST_SL_ACK     = 10'b00_0010_0000;
	parameter [9:0] ST_SL_RD      = 10'b00_0100_0000;
	parameter [9:0] ST_SL_WR      = 10'b00_1000_0000;
	parameter [9:0] ST_SL_WAIT    = 10'b01_0000_0000;
	parameter [9:0] ST_SL_PRELOAD = 10'b10_0000_0000;


	reg        sl_wait;
	// signals for bit_controller
	wire [6:0] my_addr;
	reg  [3:0] core_cmd;
	reg        core_txd;
	wire       core_ack, core_rxd;
	wire   	   sl_cont;

	// signals for shift register
	reg [7:0] sr; //8bit shift register
	reg       shift, ld;
	reg 	  master_mode;
	reg [1:0] slave_cmd_out;
	// signals for state machine
	wire       go;
	reg  [2:0] dcnt;
	wire       cnt_done;
	wire       slave_ack;


	//Slave signals
	wire        slave_adr_received;
	wire [7:0] 	slave_adr;


	reg [1:0] 	slave_cmd;
	//
	// Module body
	//

	// hookup bit_controller
	i2c_master_bit_ctrl bit_controller (
		.clk     ( clk      ),
		.rst     ( rst      ),
		.nReset  ( nReset   ),
		.ena     ( ena      ),
		.clk_cnt ( clk_cnt  ),
		.cmd     ( core_cmd ),
		.cmd_ack ( core_ack ),
		.busy    ( i2c_busy ),
		.al      ( i2c_al   ),
		.din     ( core_txd ),
		.dout    ( core_rxd ),
		.scl_i   ( scl_i    ),
		.scl_o   ( scl_o    ),
		.scl_oen ( scl_oen  ),
		.sda_i   ( sda_i    ),
		.sda_o   ( sda_o    ),
		.sda_oen ( sda_oen  ),
		.slave_adr_received ( slave_adr_received  ),
		.slave_adr  ( slave_adr  ),
		.master_mode (master_mode),
		.cmd_slave_ack (slave_ack),
		.slave_cmd (slave_cmd_out),
		.sl_wait (sl_wait),
		.slave_reset (slave_reset)
	);

	reg 		slave_adr_received_d;
	// generate go-signal
	assign go = (read | write | stop) & ~cmd_ack;

	// assign dout output to shift-register
	assign dout = sr;

	always @(posedge clk or negedge nReset)
		if (!nReset)
			slave_adr_received_d <=  1'b0;
		else
			slave_adr_received_d <=   slave_adr_received;

	// generate shift register
	always @(posedge clk or negedge nReset)
		if (!nReset)
			sr <= 8'h0;
		else if (rst)
			sr <= 8'h0;
		else if (ld)
			sr <= din;
		else if (shift)
			sr <= {sr[6:0], core_rxd};
		else if (slave_adr_received_d & slave_act)
			sr <=  {slave_adr[7:1], 1'b0};



	// generate counter
	always @(posedge clk or negedge nReset)
		if (!nReset)
			dcnt <= 3'h0;
		else if (rst)
			dcnt <= 3'h0;
		else if (ld)
			dcnt <= 3'h7;
		else if (shift)
			dcnt <= dcnt - 3'h1;

	assign cnt_done = ~(|dcnt);

	//
	// state machine
	//
	reg [9:0] 	c_state; // synopsys enum_state



	always @(posedge clk or negedge nReset)
		if (!nReset)
		begin
			sl_wait <=  1'b0;
			core_cmd <= I2C_NOP;
			core_txd <= 1'b0;
			shift    <= 1'b0;
			ld       <= 1'b0;
			cmd_ack  <= 1'b0;
			c_state  <= ST_IDLE;
			ack_out  <= 1'b0;
			master_mode <= 1'b0;
			slave_cmd  <= 2'b0;
			slave_dat_req	<= 1'b0;
			slave_dat_avail	<= 1'b0;
			slave_act <= 1'b0;
			slave_cmd_out <= 2'b0;
			slave_cmd_ack <= 1'b0;
		end
		else if (rst | i2c_al | slave_reset)
		begin
			core_cmd <= I2C_NOP;
			core_txd <= 1'b0;
			shift    <= 1'b0;
			sl_wait  <=  1'b0;
			ld       <= 1'b0;
			cmd_ack  <= 1'b0;
			c_state  <= ST_IDLE;
			ack_out  <= 1'b0;
			master_mode <=  1'b0;
			slave_cmd  <=  2'b0;
			slave_cmd_out <=  2'b0;
			slave_dat_req	<=  1'b0;
			slave_dat_avail	<=  1'b0;
			slave_act <=  1'b0;
			slave_cmd_ack <=  1'b0;
		end
		else
		begin
			slave_cmd_out <=  slave_cmd;
			// initially reset all signals
			core_txd <= sr[7];
			shift    <= 1'b0;
			ld       <= 1'b0;
			cmd_ack  <= 1'b0;
			slave_cmd_ack <=  1'b0;

			case (c_state) // synopsys full_case parallel_case
				ST_IDLE:
				begin
					slave_act <=  1'b0;
					if (slave_en & slave_adr_received &
						(slave_adr[7:1] == my_addr )) begin

						c_state  <=  ST_SL_ACK;
						master_mode <=  1'b0;
						slave_act <=  1'b1;
						slave_cmd <=  I2C_SLAVE_WRITE;
						core_txd <=  1'b0;

					end
					else if (go && !slave_act )
					begin
						if (start)
						begin
							c_state  <= ST_START;
							core_cmd <= I2C_START;
							master_mode <=  1'b1;
						end
						else if (read)
						begin
							c_state  <= ST_READ;
							core_cmd <= I2C_READ;
						end
						else if (write)
						begin
							c_state  <= ST_WRITE;
							core_cmd <= I2C_WRITE;
						end
						else // stop
						begin
							c_state  <= ST_STOP;
							core_cmd <= I2C_STOP;
						end

						ld <= 1'b1;
					end

				end
				ST_SL_RD: //If master read, slave sending data
				begin
					slave_cmd <=  I2C_SLAVE_NOP;
					if (slave_ack) begin
						if (cnt_done) begin
							c_state   <=  ST_SL_ACK;
							slave_cmd <=  I2C_SLAVE_READ;
						end
						else
						begin
							c_state   <=  ST_SL_RD;
							slave_cmd <=  I2C_SLAVE_WRITE;
							shift     <=  1'b1;
						end
					end
				end
				ST_SL_WR: //If master write, slave reading data
				begin
					slave_cmd <=  I2C_SLAVE_NOP;
					if (slave_ack)
					begin
						if (cnt_done)
						begin
							c_state  <=  ST_SL_ACK;
							slave_cmd <=  I2C_SLAVE_WRITE;
							core_txd <=  1'b0;
						end
						else
						begin
							c_state  <=  ST_SL_WR;
							slave_cmd <=  I2C_SLAVE_READ;
						end
						shift    <=  1'b1;
					end
				end
				ST_SL_WAIT: //Wait for interupt-clear and hold SCL in waitstate
				begin
					sl_wait <=  1'b1;
					if (sl_cont) begin
						sl_wait <=  1'b0;
						ld <=  1'b1;
						slave_dat_req	<=  1'b0;
						slave_dat_avail	<=  1'b0;
						c_state   <=  ST_SL_PRELOAD;
					end
				end

				ST_SL_PRELOAD:
					if (slave_adr[0]) begin
						c_state   <=  ST_SL_RD;
						slave_cmd <=  I2C_SLAVE_WRITE;
					end
					else begin
						c_state  <=  ST_SL_WR;
						slave_cmd <=  I2C_SLAVE_READ;
					end

				ST_SL_ACK:
				begin
					slave_cmd <=  I2C_SLAVE_NOP;
					if (slave_ack)  begin
						ack_out <=  core_rxd;
						slave_cmd_ack  <=  1'b1;
						if (!core_rxd) begin // Valid ack recived
							// generate slave command acknowledge signal if
							// succesful transfer
							c_state   <=  ST_SL_WAIT;
							if (slave_adr[0]) begin // I2C read request
								slave_dat_req	<=  1'b1;
							end
							else begin              // I2C write request
								slave_dat_avail	<=  1'b1;
							end
						end
						else begin
							c_state   <=  ST_IDLE;
						end
					end
					else begin
						core_txd <=  1'b0;
					end
				end

				ST_START:
					if (core_ack)
					begin
						if (read)
						begin
							c_state  <= ST_READ;
							core_cmd <= I2C_READ;
						end
						else
						begin
							c_state  <= ST_WRITE;
							core_cmd <= I2C_WRITE;
						end

						ld <= 1'b1;
					end

				ST_WRITE:
					if (core_ack)
						if (cnt_done)
						begin
							c_state  <= ST_ACK;
							core_cmd <= I2C_READ;
						end
						else
						begin
							c_state  <= ST_WRITE;       // stay in same state
							core_cmd <= I2C_WRITE; // write next bit
							shift    <= 1'b1;
						end

				ST_READ:
					if (core_ack)
					begin
						if (cnt_done)
						begin
							c_state  <= ST_ACK;
							core_cmd <= I2C_WRITE;
						end
						else
						begin
							c_state  <= ST_READ;       // stay in same state
							core_cmd <= I2C_READ; // read next bit
						end

						shift    <= 1'b1;
						core_txd <= ack_in;
					end

				ST_ACK:
					if (core_ack)
					begin
						if (stop)
						begin
							c_state  <= ST_STOP;
							core_cmd <= I2C_STOP;
						end
						else
						begin
							c_state  <= ST_IDLE;
							core_cmd <= I2C_NOP;

							// generate command acknowledge signal
							cmd_ack  <= 1'b1;
						end

						// assign ack_out output to bit_controller_rxd (contains last received bit)
						ack_out <= core_rxd;

						core_txd <= 1'b1;
					end
					else
						core_txd <= ack_in;

				ST_STOP:
					if (core_ack)
					begin
						c_state  <= ST_IDLE;
						core_cmd <= I2C_NOP;

						// generate command acknowledge signal
						cmd_ack  <= 1'b1;
					end

			endcase
		end
endmodule