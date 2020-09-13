class driver extends uvm_driver #(seq_item);
	`uvm_component_utils( driver )

	function new(string name = "driver", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	virtual gpio_if vif;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual gpio_if)::get(this, "", "gpio_vif", vif))
			`uvm_fatal("DRV", "Could not get vif")
			endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			seq_item m_seq_item;
			`uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
			seq_item_port.get_next_item(m_seq_item);
			drive_item(m_seq_item);
			seq_item_port.item_done();
		end
	endtask

	virtual task drive_item(seq_item m_seq_item);
		@(vif.cb);
		vif.cb.data_m <= m_seq_item.data_m;
		vif.cb.button <= m_seq_item.button;
		vif.cb.valid <= m_seq_item.valid;
		vif.cb.sel_led <= m_seq_item.sel_led;
		vif.cb.sel_but <= m_seq_item.sel_but;
		vif.cb.we <= m_seq_item.we;
	endtask
endclass
