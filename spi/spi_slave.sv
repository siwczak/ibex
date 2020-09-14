module spi_slave  (
	// Control/Data Signals,
	input            rst_i,    // FPGA Reset
	input            clk_i,      // FPGA Clock
	output logic       rx_dv_o,    // Data Valid pulse (1 clock cycle)
	output logic [7:0] rx_byte_o,  // Byte received on MOSI
	input            tx_dv_i,    // Data Valid pulse to register i_TX_Byte
	input  [7:0]     tx_byte_i,  // Byte to serialize to MISO.

	// SPI Interface
	input      spi_clk_i,
	output     miso_o,
	input      mosi_i,
	input      cs_i
);


	wire w_SPI_MISO_Mux;

	reg [2:0] r_RX_Bit_Count;
	reg [2:0] r_TX_Bit_Count;
	reg [7:0] r_Temp_RX_Byte;
	reg [7:0] r_RX_Byte;
	reg r_RX_Done, r2_RX_Done, r3_RX_Done;
	reg [7:0] r_TX_Byte;
	reg r_SPI_MISO_Bit, r_Preload_MISO;



	// Purpose: Recover SPI Byte in SPI Clock Domain
	// Samples line on correct edge of SPI Clock
	always @(posedge spi_clk_i or posedge cs_i)
	begin
		if (rst_i) begin
			r_RX_Bit_Count <= 0;
		end else
		if (cs_i)
		begin
			r_RX_Bit_Count <= 0;
			r_RX_Done      <= 1'b0;
		end
		else
		begin
			r_RX_Bit_Count <= r_RX_Bit_Count + 1;

			// Receive in LSB, shift up to MSB
			r_Temp_RX_Byte <= {r_Temp_RX_Byte[6:0], mosi_i};

			if (r_RX_Bit_Count == 3'b111)
			begin
				r_RX_Done <= 1'b1;
				r_RX_Byte <= {r_Temp_RX_Byte[6:0], mosi_i};
			end
			else if (r_RX_Bit_Count == 3'b010)
			begin
				r_RX_Done <= 1'b0;        
			end

		end 
	end 



	// Purpose: Cross from SPI Clock Domain to main FPGA clock domain
	// Assert o_RX_DV for 1 clock cycle when o_RX_Byte has valid data.
	always @(posedge clk_i or posedge rst_i)
	begin
		if (rst_i)
		begin
			r2_RX_Done <= 1'b0;
			r3_RX_Done <= 1'b0;
			rx_dv_o    <= 1'b0;
			rx_byte_o  <= 8'h00;
		end
		else
		begin
			// Here is where clock domains are crossed.
			// This will require timing constraint created, can set up long path.
			r2_RX_Done <= r_RX_Done;

			r3_RX_Done <= r2_RX_Done;

			if (r3_RX_Done == 1'b0 && r2_RX_Done == 1'b1) // rising edge
			begin
				rx_dv_o   <= 1'b1;  // Pulse Data Valid 1 clock cycle
				rx_byte_o <= r_RX_Byte;
			end
			else
			begin
				rx_dv_o <= 1'b0;
			end
		end 
	end 


	// Control preload signal.  Should be 1 when CS is high, but as soon as
	// first clock edge is seen it goes low.
	always @(posedge spi_clk_i or posedge cs_i)
	begin
		if (cs_i)
		begin
			r_Preload_MISO <= 1'b1;
		end
		else
		begin
			r_Preload_MISO <= 1'b0;
		end
	end


	// Purpose: Transmits 1 SPI Byte whenever SPI clock is toggling
	// Will transmit read data back to SW over MISO line.
	// Want to put data on the line immediately when CS goes low.
	always @(posedge spi_clk_i or posedge cs_i)
	begin
		if (rst_i) begin
			r_TX_Bit_Count = '0;
			r_SPI_MISO_Bit = '0;
		end

		else if (cs_i)
		begin
			r_TX_Bit_Count <= 3'b111;  // Send MSb first
			r_SPI_MISO_Bit <= r_TX_Byte[3'b111];  // Reset to MSb
		end
		else begin
			r_TX_Bit_Count <= r_TX_Bit_Count - 1;

			// Here is where data crosses clock domains from i_Clk to w_SPI_Clk
			// Can set up a timing constraint with wide margin for data path.
			r_SPI_MISO_Bit <= r_TX_Byte[r_TX_Bit_Count];

		end // else: !if(i_SPI_CS_n)
	end // always @ (negedge w_SPI_Clk or posedge i_SPI_CS_n_SW)


	// Purpose: Register TX Byte when DV pulse comes.  Keeps registed byte in 
	// this module to get serialized and sent back to master.
	always @(posedge clk_i or posedge rst_i)
	begin
		if (rst_i)
		begin
			r_TX_Byte <= 8'h00;
		end
		else
		begin
			if (tx_dv_i)
			begin
				r_TX_Byte <= tx_byte_i; 
			end
		end 
	end 

	// Preload MISO with top bit of send data when preload selector is high.
	// Otherwise just send the normal MISO data
	assign w_SPI_MISO_Mux = r_Preload_MISO ? r_TX_Byte[3'b111] : r_SPI_MISO_Bit;

	// Tri-statae MISO when CS is high.  Allows for multiple slaves to talk.
	assign miso_o = cs_i ? 1'bZ : w_SPI_MISO_Mux;

endmodule
