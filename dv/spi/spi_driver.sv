class spi_driver extends uvm_driver #(spi_seq_item);

	`uvm_component_utils(spi_driver)

	parameter SPCR = 3'b000;
	parameter SPSR = 3'b001;
	parameter SPDR = 3'b010;
	parameter SPER = 3'b011;

	virtual spi_intf vif;
	int no_transactions;


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		// Get interface reference from config database
		if( !uvm_config_db #(virtual spi_intf)::get(this, "", "spi_intf", vif) )
			`uvm_error("", "uvm_config_db::get failed")
			endfunction 

	task run_phase(uvm_phase phase);
		forever
		begin
			seq_item_port.get_next_item(req);
			`uvm_info(get_full_name(),"---------------------------------------------",UVM_LOW) 
			`uvm_info(get_full_name(), $sformatf("\t Transaction No. = %0d",no_transactions),UVM_LOW) 
			wait(!vif.rst_i);
			//Test tx
			vif.cyc_i <= 0;
			vif.stb_i <= 0;
			vif.we_i <= 0;
			@(posedge vif.clk_i);
			write(1,SPCR,4'b0101);
			compare(0,SPCR,4'b0101);
			write(1,SPER,4'b0000);
			compare(0,SPER,4'b0000);
			write(1,SPDR,req.dat_i);
			compare(0,SPDR,req.dat_i);
			@(posedge vif.clk_i);
			repeat(100) @(posedge vif.clk_i);
			seq_item_port.item_done();
			no_transactions++;
		end
	endtask

	task write(input [2:0] addr, input [3:0] data, int delay);
				repeat(delay) @(posedge vif.clk_i);
				vif.adr_i = addr;
				vif.dat_i = {data,req.dat_i};
				vif.cyc_i  = 1'b1;
				vif.stb_i  = 1'b1;
				vif.we_i   = 1'b1;
				
				#1000;
				vif.cyc_i  = 1'b0;
				vif.stb_i  = 1'b0;
				vif.we_i   = 1'b0;
				
	endtask
	
	task read(input [2:0] addr, output [7:0] data, int delay);
				repeat(delay) @(posedge vif.clk_i);
				vif.adr_i = addr;
				vif.dat_i = {data,req.dat_i};
				vif.cyc_i  = 1'b1;
				vif.stb_i  = 1'b1;
				vif.we_i   = 1'b0;
				
				#1000;
				vif.cyc_i  = 1'b0;
				vif.stb_i  = 1'b0;
				vif.we_i   = 1'b0;
				data = vif.dat_i;
	endtask
	
	task compare(input [2:0] addr, input [7:0] data_exp, int delay);
		logic [7:0] data;
		read (delay, addr, data);
		
		if(data==data_exp) begin
			`uvm_info(get_full_name(),$sformatf("data is data exp"), UVM_LOW)
			`uvm_info(get_full_name(),$sformatf("test_pass"), UVM_LOW)
		end 

	endtask

endclass