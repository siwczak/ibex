class spi_seq_item extends uvm_sequence_item;

	`uvm_object_utils(spi_seq_item)

	logic       clk_i;
	logic       rst_i;        
	logic       cyc_i;        
	logic       stb_i;        
	logic [2:0] adr_i;        
	logic       we_i;         
	rand logic   [3:0] dat_i;        
	logic  [7:0] dat_o;        
	logic        ack_o;        
	logic        inta_o;       

	// SPI port
	logic        sck_o;       
	logic [1-1:0] cs_o;    
	logic       mosi_o;       
	logic       miso_i; 
	
	logic      [7:0] rx_byte_o; 
	logic       rx_dv_o; 

	function new (string name = "spi_seq_item");
		super.new(name);
	endfunction

endclass