class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)
	function new(string name="scoreboard", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	bit[32-1:0] 	data_i[bit[4:0]];
	bit[32-1:0] 	data_o[bit[4:0]];
	bit[32-1:0] 	ref_pattern;
	uvm_analysis_imp #(seq_item, scoreboard) m_analysis_imp;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_analysis_imp = new("m_analysis_imp", this);
		if (!uvm_config_db#(bit[32-1:0])::get(this, "*", "ref_pattern", ref_pattern))
			`uvm_fatal("SCBD", "Did not get ref_pattern !")
	endfunction

	virtual function write(seq_item item);
	if(item.valid_i) begin
		`uvm_info( get_full_name(), "valid positive", UVM_LOW )
		data_i[item.addr_i] = item.data_i;
		data_o[item.addr_i] = item.data_o;
		$display("dupa");
	end
	endfunction
	
	function check_res;
		foreach(data_o[i]) begin
			if (data_i[i] == data_o[i])
				`uvm_info( get_full_name(), "data correct", UVM_LOW )
			else
				`uvm_error( get_full_name(), "data nie correct" )
		end
	endfunction
endclass