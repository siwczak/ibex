class spi_test extends uvm_test;

	`uvm_component_utils(spi_test)

	spi_env env;

	function new(string name = "spi_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		env = spi_env::type_id::create("env", this);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		`uvm_info(get_full_name(), this.sprint(), UVM_NONE)
	endfunction

	task run_phase(uvm_phase phase);
		spi_seq seqr;
		seqr = spi_seq::type_id::create("seqr");
		if( !seqr.randomize() ) 
			`uvm_error(get_full_name(), "Randomize failed")
			seqr.starting_phase = phase;
		seqr.start( env.agent.seqr );
	endtask

endclass