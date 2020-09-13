class base_test extends uvm_test;
	`uvm_component_utils(base_test)
	function new(string name = "base_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	env  				e0;
	bit[4-1:0]  pattern;
	gen_item_seq 		seq;
	virtual  	gpio_if 	vif;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Create the environment
		e0 = env::type_id::create("e0", this);

		// Get virtual IF handle from top level and pass it to everything
		// in env level
		if (!uvm_config_db#(virtual gpio_if)::get(this, "", "gpio_vif", vif))
			`uvm_fatal("TEST", "Did not get vif")
			uvm_config_db#(virtual gpio_if)::set(this, "e0.a0.*", "gpio_vif", vif);

		// Setup pattern queue and place into config db
		uvm_config_db#(bit[4-1:0])::set(this, "*", "ref_pattern", pattern);

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
		vif.rst_ni <= 0;
		vif.data_m <= 0;
		vif.button <= 0;
		vif.valid <= 0;
		vif.sel_led <= 0;
		vif.sel_but <= 0;
		vif.we <= 0;
		repeat(5) @ (posedge vif.clk);
		vif.rst_ni <= 1;
		repeat(10) @ (posedge vif.clk);
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