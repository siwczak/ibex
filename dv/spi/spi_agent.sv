class spi_agent extends uvm_agent;

	`uvm_component_utils(spi_agent)

	spi_sequencer seqr;
	spi_driver    driv;
	spi_mon mon;
	spi_cov cov;

	function new(string name = "spi_agent", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		seqr = spi_sequencer::type_id::create("seqr", this);
		driv = spi_driver::type_id::create("driv", this);
		mon = spi_mon::type_id::create("mon", this);
		cov = spi_cov::type_id::create("cov", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		driv.seq_item_port.connect( seqr.seq_item_export);
		mon.ap_port.connect(cov.analysis_export);
	endfunction


endclass