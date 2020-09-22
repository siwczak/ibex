class driver extends uvm_driver #(seq_item);
	`uvm_component_utils( driver )

	function new(string name = "driver", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	virtual ram_if vif;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual ram_if)::get(this, "", "ram_vif", vif))
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
		vif.cb.addr_i <= m_seq_item.addr_i;
		vif.cb.valid_i <= m_seq_item.valid_i;
		vif.cb.data_i <= m_seq_item.data_i;
		vif.cb.we_i <= m_seq_item.we_i;
	endtask
endclass
