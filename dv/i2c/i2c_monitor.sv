class spi_mon extends uvm_monitor;

	virtual spi_intf intf;
	spi_seq_item trans;
	uvm_analysis_port #(spi_seq_item) ap_port;
	`uvm_component_utils(spi_mon)

	function new(string name="spi_mon", uvm_component parent);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		ap_port = new("ap_port",this);
		trans = spi_seq_item::type_id::create("trans");
		if(!uvm_config_db #(virtual spi_intf)::get(this, "", "spi_intf", intf)) 
		begin
			`uvm_error("ERROR::", "UVM_CONFIG_DB FAILED in spi_mon")
			end
		//ap_port = new("ap_port", this);
	endfunction


	task run_phase(uvm_phase phase);
		while(1) begin
			@(posedge intf.clk_i);
			trans = spi_seq_item::type_id::create("trans");
			trans.cyc_i = intf.cyc_i;
			trans.stb_i = intf.stb_i;
			trans.adr_i = intf.adr_i;
			trans.we_i = intf.we_i;
			trans.dat_o = intf.dat_o;
			trans.ack_o = intf.ack_o;
			trans.inta_o = intf.inta_o;
			trans.sck_o = intf.sck_o;
			trans.cs_o = intf.cs_o;
			trans.mosi_o = intf.mosi_o;
			trans.miso_i = intf.miso_i;
			trans.rx_byte_o = intf.rx_byte_o;
			trans.rx_dv_o = intf.rx_dv_o;
			ap_port.write(trans);
		end
	endtask


endclass