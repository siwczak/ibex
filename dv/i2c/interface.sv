interface spi_intf;
	
	logic       wb_clk_i;
	logic       wb_rst_i;        
	logic       arst_i;        
	logic [2:0] wb_adr_i;        
	logic [7:0] wb_dat_i;        
	logic  [7:0] wb_dat_o;        
	logic        wb_we_i;        
	logic        wb_stb_i;       
	logic        wb_cyc_i;       
	logic        wb_ack_o;       
	logic        wb_inta_o;       

	// I2C port
	logic        scl_pad_i;       
	logic [1-1:0] scl_pad_o;    
	logic       scl_padoen_o;       
	logic       sda_pad_i; 
	logic       sda_pad_o; 
	logic       sda_padoen_o; 
	

endinterface