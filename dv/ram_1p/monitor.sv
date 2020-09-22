class monitor extends uvm_monitor;
	`uvm_component_utils(monitor)
	function new(string name="monitor", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	uvm_analysis_port  #(seq_item) mon_analysis_port;
	virtual ram_if vif;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual ram_if)::get(this, "", "ram_vif", vif))
			`uvm_fatal("MON", "Could not get vif")
			mon_analysis_port = new ("mon_analysis_port", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		// This task monitors the interface for a complete
		// transaction and writes into analysis port when complete
		forever begin
			@ (vif.cb);
			if (1) begin
				seq_item item = seq_item::type_id::create("item");
				item.addr_i = vif.addr_i;
				item.valid_i = vif.valid_i;
				item.we_i = vif.we_i;
				item.data_i = vif.data_i;
				item.data_o = vif.data_o;
				mon_analysis_port.write(item);
				if(item.valid_i)
				`uvm_info("MON", $sformatf("Saw item %s", item.value()), UVM_MEDIUM)
				end
		end
	endtask
endclass