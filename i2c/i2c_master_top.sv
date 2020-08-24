module i2c_master_top
import i2c_package::*;
	(
		//WISHBONE SIGNAL
		input wb_clk_i,
		input wb_rst_i,
		input arst_i,
		input [2:0] wb_adr_i,
		input [7:0] wb_dat_i,
		output [7:0] wb_dat_o,
		input wb_we_i,
		input wb_stb_i,
		input wb_cyc_i,
		output wb_ack_o,
		output wb_inta_o,
		//I2C SIGNAL
		input scl_pad_i,
		output scl_pad_o,
		output scl_padoen_o,
		input sda_pad_i,
		output sda_pad_o,
		output sda_padoen_o );

	// parameters
	parameter ARST_LVL = 1'b1; // asynchronous reset level
	parameter [6:0] DEFAULT_SLAVE_ADDR  = 7'b111_1110;

	reg [7:0] wb_dat_o;
	reg wb_ack_o;
	reg wb_inta_o;

	//
	// variable declarations
	//

	// registers
	reg  [15:0] prer; // clock prescale register
	reg  [ 7:0] ctr;  // control register
	reg  [ 7:0] txr;  // transmit register
	wire [ 7:0] rxr;  // receive register
	reg  [ 7:0] cr;   // command register
	wire [ 7:0] sr;   // status register
	reg  [ 6:0] sladr;// slave address register

	// done signal: command completed, clear command register
	wire done;
	wire slave_done;
	// core enable signal
	wire core_en;
	wire ien;
	wire slave_en;

	// status register signals
	wire irxack;
	reg  rxack;       // received aknowledge from slave
	reg  tip;         // transfer in progress
	reg  irq_flag;    // interrupt pending flag
	wire i2c_busy;    // bus busy (start signal detected)
	wire i2c_al;      // i2c bus arbitration lost
	reg  al;          // status register arbitration lost bit
	reg  slave_mode;
	//
	// module body
	//
	wire  slave_act;
	// generate internal reset
	wire rst_i = arst_i ^ ARST_LVL;

	// generate wishbone signals
	wire wb_wacc = wb_we_i & wb_ack_o;

	// generate acknowledge output signal ...
	always @(posedge wb_clk_i)
		// ... because timing is always honored.
		wb_ack_o <=  wb_cyc_i & wb_stb_i & ~wb_ack_o;

	// assign DAT_O
	always @(posedge wb_clk_i)
	begin
		case (wb_adr_i) // synopsys parallel_case
			3'b000: wb_dat_o <= prer[ 7:0];
			3'b001: wb_dat_o <= prer[15:8];
			3'b010: wb_dat_o <= ctr;
			3'b011: wb_dat_o <= rxr; // write is transmit register (txr)
			3'b100: wb_dat_o <= sr;  // write is command register (cr)
			3'b101: wb_dat_o <= txr; // Debug out of TXR
			3'b110: wb_dat_o <= cr;  // Debug out control reg
			3'b111: wb_dat_o <= {1'b0,sladr};   // slave address register
		endcase
	end

	// generate registers
	always @(posedge wb_clk_i or negedge rst_i)
		if (!rst_i)
		begin
			prer <= 16'hffff;
			ctr  <=  8'h0;
			txr  <=  8'h0;
			sladr <=  DEFAULT_SLAVE_ADDR;
		end
		else if (wb_rst_i)
		begin
			prer <= 16'hffff;
			ctr  <=  8'h0;
			txr  <=  8'h0;
			sladr <=  DEFAULT_SLAVE_ADDR;
		end
		else
		if (wb_wacc)
			case (wb_adr_i) // synopsys parallel_case
				3'b000 : prer [ 7:0] <= wb_dat_i;
				3'b001 : prer [15:8] <= wb_dat_i;
				3'b010 : ctr         <= wb_dat_i;
				3'b011 : txr         <= wb_dat_i;
				3'b111 : sladr       <=  wb_dat_i[6:0];
				default: ;
			endcase

	// generate command register (special case)
	always @(posedge wb_clk_i or negedge rst_i)
		if (!rst_i)
			cr <= 8'h0;
		else if (wb_rst_i)
			cr <= 8'h0;
		else if (wb_wacc)
		begin
			if (core_en & (wb_adr_i == 3'b100) )
				cr <= wb_dat_i;
		end
		else
		begin
			cr[1] <=  1'b0;
			if (done | i2c_al)
				cr[7:4] <= 4'h0;           // clear command bits when done
			// or when aribitration lost
			cr[2] <=  1'b0;             // reserved bits
			cr[0]   <= 1'b0;             // clear IRQ_ACK bit
		end


	// decode command register
	wire sta  = cr[7];
	wire sto  = cr[6];
	wire rd   = cr[5];
	wire wr   = cr[4];
	wire ack  = cr[3];
	wire sl_cont = cr[1];
	wire iack = cr[0];

	// decode control register
	assign core_en = ctr[7];
	assign ien = ctr[6];
	assign slave_en = ctr[5];


	// hookup byte controller block
	i2c_master_byte_ctrl byte_controller (
		.clk      ( wb_clk_i     ),
		.my_addr  ( sladr        ),
		.rst      ( wb_rst_i     ),
		.nReset   ( rst_i        ),
		.ena      ( core_en      ),
		.clk_cnt  ( prer         ),
		.start    ( sta          ),
		.stop     ( sto          ),
		.read     ( rd           ),
		.write    ( wr           ),
		.ack_in   ( ack          ),
		.din      ( txr          ),
		.cmd_ack  ( done         ),
		.ack_out  ( irxack       ),
		.dout     ( rxr          ),
		.i2c_busy ( i2c_busy     ),
		.i2c_al   ( i2c_al       ),
		.scl_i    ( scl_pad_i    ),
		.scl_o    ( scl_pad_o    ),
		.scl_oen  ( scl_padoen_o ),
		.sda_i    ( sda_pad_i    ),
		.sda_o    ( sda_pad_o    ),
		.sda_oen  ( sda_padoen_o ),
		.sl_cont  ( sl_cont       ),
		.slave_en ( slave_en      ),
		.slave_dat_req (slave_dat_req),
		.slave_dat_avail (slave_dat_avail),
		.slave_act (slave_act),
		.slave_cmd_ack (slave_done)
	);

	// status register block + interrupt request signal
	always @(posedge wb_clk_i or negedge rst_i)
		if (!rst_i)
		begin
			al       <= 1'b0;
			rxack    <= 1'b0;
			tip      <= 1'b0;
			irq_flag <= 1'b0;
			slave_mode <=  1'b0;
		end
		else if (wb_rst_i)
		begin
			al       <= 1'b0;
			rxack    <= 1'b0;
			tip      <= 1'b0;
			irq_flag <= 1'b0;
			slave_mode <=  1'b0;
		end
		else
		begin
			al       <= i2c_al | (al & ~sta);
			rxack    <= irxack;
			tip      <= (rd | wr);
			// interrupt request flag is always generated
			irq_flag <=  (done | slave_done| i2c_al | slave_dat_req |
				slave_dat_avail | irq_flag) & ~iack;
			if (done)
				slave_mode <=  slave_act;

		end

	// generate interrupt request signals
	always @(posedge wb_clk_i or negedge rst_i)
		if (!rst_i)
			wb_inta_o <= 1'b0;
		else if (wb_rst_i)
			wb_inta_o <= 1'b0;
		else
			// interrupt signal is only generated when IEN (interrupt enable bit
			// is set)
			wb_inta_o <=  irq_flag && ien;

	// assign status register bits
	assign sr[7]   = rxack;
	assign sr[6]   = i2c_busy;
	assign sr[5]   = al;
	assign sr[4]   = slave_mode; // reserved
	assign sr[3]   = slave_dat_avail;
	assign sr[2]   = slave_dat_req;
	assign sr[1]   = tip;
	assign sr[0]   = irq_flag;

endmodule