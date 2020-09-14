interface spi_intf;
	
	logic       clk_i;
	logic       rst_i;        
	logic       cyc_i;        
	logic       stb_i;        
	logic [2:0] adr_i;        
	logic       we_i;         
	logic [7:0] dat_i;        
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
	
endinterface