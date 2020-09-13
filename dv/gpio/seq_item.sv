class seq_item extends uvm_sequence_item;

	`uvm_object_utils(seq_item)
	
	rand bit [4-1:0] data_m;
	rand bit [4-1:0] button;
	rand bit valid;
	rand bit sel_led;
	rand bit sel_but;
	rand bit we;
	
	bit [4-1:0] data_s;
	bit [4-1:0] led;
	
	function new(string name = "seq_item");
    	super.new(name);
	endfunction
	
	function string value();
		value = $sformatf("data_m%d, button %d, valid %d, sel_led %d, sel_but %d, we %d,data_s %d, led %d", data_m, button, valid, sel_led, sel_but, we, data_s, led);
	endfunction
	
	constraint c1 { sel_led!=sel_but ;}
	constraint c2 { we dist {1 := 70};}
	constraint c3 { valid dist {1 := 70};}
	constraint c4 { button!=5 ;}
	constraint c5 { sel_led dist {1 := 70};}
	
endclass
