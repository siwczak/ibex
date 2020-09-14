class spi_cov extends uvm_subscriber #(spi_seq_item);

	`uvm_component_utils(spi_cov)
	spi_seq_item seq_item;


	covergroup cov_inst;
		CYC:coverpoint seq_item.cyc_i {option.auto_bin_max = 1;}
		STB:coverpoint seq_item.stb_i {option.auto_bin_max = 1;}
		ADDR:coverpoint seq_item.adr_i {option.auto_bin_max = 2;}
		WE:coverpoint seq_item.we_i {option.auto_bin_max = 1;}
		DAT_I:coverpoint seq_item.dat_i {option.auto_bin_max = 4;}
		DAT_O:coverpoint seq_item.dat_o {option.auto_bin_max = 8;}
		ACK:coverpoint seq_item.ack_o {option.auto_bin_max = 1;}
		INTA:coverpoint seq_item.inta_o {option.auto_bin_max = 1;}

	endgroup 


	function new(string name="spi_cov", uvm_component parent);
		super.new(name, parent);
		cov_inst = new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction


	virtual function void write(spi_seq_item t);
		$cast(seq_item, t);
		cov_inst.sample();
	endfunction

endclass