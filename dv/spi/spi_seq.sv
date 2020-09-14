typedef uvm_sequencer #(spi_seq_item) spi_sequencer;

class spi_seq extends uvm_sequence #(spi_seq_item);

	`uvm_object_utils(spi_seq)
	int count;

	function new (string name = "spi_seq"); 
		super.new(name);
	endfunction

	task body;
		if (starting_phase != null)
			starting_phase.raise_objection(this);
		void'(uvm_config_db #(int)::get(null,"","no_of_transactions",count));
		repeat(count)
		begin
			req = spi_seq_item::type_id::create("req");
			start_item(req);
			if( !req.randomize() )
				`uvm_error("", "Randomize failed")
				finish_item(req);
		end

		if (starting_phase != null)
			starting_phase.drop_objection(this);
	endtask: body

endclass