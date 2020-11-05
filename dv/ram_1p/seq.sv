class gen_item_seq extends uvm_sequence;

	`uvm_object_utils( gen_item_seq )

  function new(string name="gen_item_seq");
    super.new(name);
  endfunction
  
  rand int num_items;
  
  constraint c1 { num_items inside {[500:1000]};}
  
	virtual task body();
  		for (int i = 0; i < num_items; i++) begin
			seq_item m_seq_item = seq_item::type_id::create("m_seq_item");
			start_item(m_seq_item);
			m_seq_item.randomize();
			finish_item(m_seq_item);
		end
		`uvm_info("SEQ", $sformatf("Done generation of %0d items", num_items), UVM_LOW)
	endtask

endclass