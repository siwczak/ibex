class monitor extends uvm_monitor;
	`uvm_component_utils(monitor)
	function new(string name="monitor", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	uvm_analysis_port  #(seq_item) mon_analysis_port;
	virtual gpio_if vif;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual gpio_if)::get(this, "", "gpio_vif", vif))
			`uvm_fatal("MON", "Could not get vif")
			mon_analysis_port = new ("mon_analysis_port", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		// This task monitors the interface for a complete
		// transaction and writes into analysis port when complete
		forever begin
			@ (vif.cb);
			if (vif.rst_ni) begin
				seq_item item = seq_item::type_id::create("item");
				item.data_m = vif.data_m;
				item.button = vif.button;
				item.valid = vif.valid;
				item.sel_led = vif.sel_led;
				item.sel_but = vif.sel_but;
				item.we = vif.we;
				item.data_s = vif.cb.data_s;
				item.led = vif.cb.led;
				mon_analysis_port.write(item);
				`uvm_info("MON", $sformatf("Saw item %s", item.value()), UVM_LOW)
				end
		end
	endtask
endclass