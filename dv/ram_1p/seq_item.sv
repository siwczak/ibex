class seq_item extends uvm_sequence_item;

	`uvm_object_utils(seq_item)
	
	logic clk;
	rand logic valid_i;
	rand logic [3:0] we_i;
	rand logic [5-1:0] addr_i;
	rand logic [32-1:0] data_i;
	logic [32-1:0] data_o;
	
	function new(string name = "seq_item");
    	super.new(name);
	endfunction
	
	function string value();
		value = $sformatf("clk%d, valid %d,we_i: %d, addr_i %d, data_i %d", clk, valid_i ,we_i , addr_i, data_i);
	endfunction
	
	constraint valid_status { valid_i dist {1 := 70 }; }
	
endclass
