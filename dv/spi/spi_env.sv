class spi_env extends uvm_env;

	`uvm_component_utils(spi_env)

	spi_agent agent;

	function new(string name = "spi_env", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		agent = spi_agent::type_id::create("agent",this);  
	endfunction


endclass