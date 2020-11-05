class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)
	function new(string name="scoreboard", uvm_component parent=null);
		super.new(name, parent);
	endfunction

	bit[4-1:0] 	led_pattern;
	bit[4-1:0] 	slave_pattern;

	uvm_analysis_imp #(seq_item, scoreboard) m_analysis_imp;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_analysis_imp = new("m_analysis_imp", this);
	endfunction

	virtual function write(seq_item item);
		led_pattern = item.data_m;
		slave_pattern = item.button;

			if ((item.data_s != slave_pattern) && item.sel_but) begin
				`uvm_error("test_pass", $sformatf("ERROR ! out=%0d exp=%0d",
						item.data_s, slave_pattern))
				end else begin
				`uvm_info("test_pass", $sformatf("PASS ! out=%0d exp=%0d",
						item.data_s, slave_pattern), UVM_LOW)
				end
	
			if ((item.led != led_pattern) && item.sel_led) begin
				`uvm_info("test_pass", $sformatf("ERROR ! out=%0d exp=%0d",
						item.led, led_pattern), UVM_LOW)
				end else begin
				`uvm_info("test_pass", $sformatf("PASS ! out=%0d exp=%0d",
						item.led, led_pattern), UVM_LOW)
				end
 
	endfunction
endclass