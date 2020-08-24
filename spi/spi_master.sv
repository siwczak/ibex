module spi_master #(
	parameter SPI_SLAVE = -1
)(
	// wishbone
	input  wire       clk_i,        
	input  wire       rst_i,        
	input  wire       cyc_i,        
	input  wire       stb_i,        
	input  wire [2:0] adr_i,        
	input  wire       we_i,         
	input  wire [7:0] dat_i,        
	output reg  [7:0] dat_o,        
	output reg        ack_o,        
	output reg        inta_o,       

	// SPI port
	output reg        sck_o,        
	output [SPI_SLAVE-1:0] cs_o,    
	output wire       mosi_o,       
	input  wire       miso_i        
);



	reg  [7:0]          spcr;       // Serial Peripheral Control  
	wire [7:0]          spsr;       // Serial Peripheral Status   
	reg  [7:0]          sper;       // Serial Peripheral Extension Register
	reg  [7:0]          treg;       // Transmit Register
	reg  [SPI_SLAVE-1:0] cs_r;       // Slave Select Register

	// fifo
	wire [7:0] rfdout;
	reg        wfre, rfwe;
	wire       rfre, rffull, rfempty;
	wire [7:0] wfdout;
	wire       wfwe, wffull, wfempty;

	// misc
	wire      tirq;     // transfer interrupt (selected number of transfers done)
	wire      wfov;     // write fifo overrun (writing while fifo full)
	reg [1:0] state;    // statemachine state
	reg [2:0] bcnt;

	//
	// Wishbone
	wire wb_acc = cyc_i & stb_i;   
	wire wb_wr  = wb_acc & we_i;   

	// dat_i
	always @(posedge clk_i)
		if (rst_i)
		begin
			spcr <= 8'h10;  // set master
			sper <= 8'h00;
			cs_r <= 0;
		end
		else if (wb_wr)
		begin
			if (adr_i == 3'b000)
				spcr <= dat_i | 8'h10; // always set master bit

			if (adr_i == 3'b011)
				sper <= dat_i;

			if (adr_i == 3'b100)
				cs_r <= dat_i[SPI_SLAVE-1:0];
		end


	assign cs_o = ~cs_r;

	// write fifo
	assign wfwe = wb_acc & (adr_i == 3'b010) & ack_o &  we_i;
	assign wfov = wfwe & wffull;

	// dat_o
	always @(posedge clk_i)
		case(adr_i) 
			3'b000: dat_o <= spcr;
			3'b001: dat_o <= spsr;
			3'b010: dat_o <= rfdout;
			3'b011: dat_o <= sper;
			3'b100: dat_o <= {{ (8-SPI_SLAVE){1'b0} }, cs_r};
			default: dat_o <= 0;
		endcase

	// read fifo
	assign rfre = wb_acc & (adr_i == 3'b010) & ack_o & ~we_i;

	// ack_o
	always @(posedge clk_i)
		if (rst_i)
			ack_o <= 1'b0;
		else
			ack_o <= wb_acc & !ack_o;

	// decode Serial Peripheral Control Register
	wire       spie = spcr[7];   // Interrupt enable bit
	wire       spe  = spcr[6];   // System Enable bit
	wire       dwom = spcr[5];   // Port D Wired-OR Mode Bit
	wire       mstr = spcr[4];   // Master Mode Select Bit
	wire       cpol = spcr[3];   // Clock Polarity Bit
	wire       cpha = spcr[2];   // Clock Phase Bit
	wire [1:0] spr  = spcr[1:0]; // Clock Rate Select Bits

	// decode Serial Peripheral Extension Register
	wire [1:0] icnt = sper[7:6]; // interrupt on transfer count
	wire [1:0] spre = sper[1:0]; // extended clock rate select

	wire [3:0] espr = {spre, spr};

	// generate status register
	wire wr_spsr = wb_wr & (adr_i == 3'b001);

	reg spif;
	always @(posedge clk_i)
		if (~spe | rst_i)
			spif <= 1'b0;
		else
			spif <= (tirq | spif) & ~(wr_spsr & dat_i[7]);

	reg wcol;
	always @(posedge clk_i)
		if (~spe | rst_i)
			wcol <= 1'b0;
		else
			wcol <= (wfov | wcol) & ~(wr_spsr & dat_i[6]);

	assign spsr[7]   = spif;
	assign spsr[6]   = wcol;
	assign spsr[5:4] = 2'b00;
	assign spsr[3]   = wffull;
	assign spsr[2]   = wfempty;
	assign spsr[1]   = rffull;
	assign spsr[0]   = rfempty;


	// generate IRQ output (inta_o)
	always @(posedge clk_i)
		inta_o <= spif & spie;

	//
	// hookup read/write buffer fifo
	fifo#(
		.DATA_WIDTH(8),
		.FIFO_DEPTH(4))
	rfifo(
		.clk_i   ( clk_i   ),
		.rst_i   ( rst_i  ),
		.clr_i   ( ~spe    ),
		.data_i   ( treg    ),
		.wr_i    ( rfwe    ),
		.data_o  ( rfdout  ),
		.rd_i    ( rfre    ),
		.full_o  ( rffull  ),
		.empty_o ( rfempty )
	);
	fifo#(
		.DATA_WIDTH(8),
		.FIFO_DEPTH(4))
	wfifo(
		.clk_i   ( clk_i   ),
		.rst_i   ( rst_i  ),
		.clr_i   ( ~spe    ),
		.data_i   ( dat_i   ),
		.wr_i    ( wfwe    ),
		.data_o  ( wfdout  ),
		.rd_i    ( wfre    ),
		.full_o  ( wffull  ),
		.empty_o ( wfempty )
	);

	//
	// generate clk divider
	reg [11:0] clkcnt;
	always @(posedge clk_i)
		if(spe & (|clkcnt & |state))
			clkcnt <= clkcnt - 11'h1;
		else
			case (espr) 
				4'b0000: clkcnt <= 12'h0;   // 2   
				4'b0001: clkcnt <= 12'h1;   // 4   
				4'b0010: clkcnt <= 12'h3;   // 16  
				4'b0011: clkcnt <= 12'hf;   // 32  
				4'b0100: clkcnt <= 12'h1f;  // 8
				4'b0101: clkcnt <= 12'h7;   // 64
				4'b0110: clkcnt <= 12'h3f;  // 128
				4'b0111: clkcnt <= 12'h7f;  // 256
				4'b1000: clkcnt <= 12'hff;  // 512
				4'b1001: clkcnt <= 12'h1ff; // 1024
				4'b1010: clkcnt <= 12'h3ff; // 2048
				4'b1011: clkcnt <= 12'h7ff; // 4096
				default : clkcnt <= 12'hfff;
			endcase

	// generate clock enable signal
	wire ena = ~|clkcnt;

	// transfer statemachine
	always @(posedge clk_i)
		if (~spe | rst_i)
		begin
			state <= 2'b00; // idle
			bcnt  <= 3'h0;
			treg  <= 8'h00;
			wfre  <= 1'b0;
			rfwe  <= 1'b0;
			sck_o <= 1'b0;
		end
		else
		begin
			wfre <= 1'b0;
			rfwe <= 1'b0;

			case (state) 
				2'b00: // idle state
				begin
					bcnt  <= 3'h7;   // set transfer counter
					treg  <= wfdout; // load transfer register
					sck_o <= cpol;   // set sck

					if (~wfempty) begin
						wfre  <= 1'b1;
						state <= 2'b01;
						if (cpha) sck_o <= ~sck_o;
					end
				end

				2'b01: // clock-phase2, next data
					if (ena) begin
						sck_o   <= ~sck_o;
						state   <= 2'b11;
					end

				2'b11: // clock phase1
					if (ena) begin
						treg <= {treg[6:0], miso_i};
						bcnt <= bcnt -3'h1;

						if (~|bcnt) begin
							state <= 2'b00;
							sck_o <= cpol;
							rfwe  <= 1'b1;
						end else begin
							state <= 2'b01;
							sck_o <= ~sck_o;
						end
					end

				2'b10: state <= 2'b00;
			endcase
		end

	assign mosi_o = treg[7];


	// count number of transfers (for interrupt generation)
	reg [1:0] tcnt; // transfer count
	always @(posedge clk_i)
		if (~spe)
			tcnt <= icnt;
		else if (rfwe) // rfwe gets asserted when all bits have been transfered
			if (|tcnt)
				tcnt <= tcnt - 2'h1;
			else
				tcnt <= icnt;

	assign tirq = ~|tcnt & rfwe;

endmodule
