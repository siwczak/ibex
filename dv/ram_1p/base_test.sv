class base_test extends uvm_test;
	`uvm_component_utils(base_test)
	function new(string name = "base_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	env  				e0;
	gen_item_seq 		seq;
	virtual  	ram_if 	vif;
	bit [32-1:0] pattern;
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Create the environment
		e0 = env::type_id::create("e0", this);

		// Get virtual IF handle from top level and pass it to everything
		// in env level
		if (!uvm_config_db#(virtual ram_if)::get(this, "", "ram_vif", vif))
			`uvm_fatal("TEST", "Did not get vif")
			uvm_config_db#(virtual ram_if)::set(this, "e0.a0.*", "ram_vif", vif);

		pattern = vif.data_o;
 		uvm_config_db#(bit[32-1:0])::set(this, "*", "ref_pattern", pattern);

		// Create sequence and randomize it
		seq = gen_item_seq::type_id::create("seq");
		seq.randomize();
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		apply_reset();
		seq.start(e0.a0.s0);
		#200;
		phase.drop_objection(this);
	endtask

	virtual task apply_reset();
		vif.addr_i <= 0;
		vif.valid_i <= 0;
		vif.we_i <= 0;
		vif.data_i <= 0;
		vif.data_o <= 0;
	endtask
endclass

class test_top extends base_test;
	`uvm_component_utils(test_top)
	function new(string name="test_top", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq.randomize();
	endfunction
endclass