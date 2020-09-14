class uart_driver extends uvm_driver #(uart_trans);

	`uvm_component_utils(uart_driver)

	parameter clk_freq = 50000000; //MHz
	parameter baud_rate = 19200; //bits per second
	localparam clock_divide = (clk_freq/baud_rate);

	virtual uart_intf vif;
	reg [7:0] data;
	int no_transactions;


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		// Get interface reference from config database
		if( !uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf", vif) )
			`uvm_error("", "uvm_config_db::get failed")
			endfunction 

	task run_phase(uvm_phase phase);
		forever
		begin
			seq_item_port.get_next_item(req);


			`uvm_info(get_full_name(),"---------------------------------------------",UVM_LOW) 
			`uvm_info(get_full_name(), $sformatf("\t Transaction No. = %0d",no_transactions),UVM_LOW) 
			//Test tx
			vif.start <= 1;
			vif.rx <= 1;
			@(posedge vif.clk);
			vif.tx_data_in <= req.tx_data_in;
			@(posedge vif.clk);
			wait(vif.tx_active == 0);
			vif.start <= 0;
			if(vif.tx_active == 0) begin
				`uvm_info(get_full_name(), $sformatf("\t start = %0b, \t tx_data_in = %0h,\t tx_active = %0b",vif.start,req.tx_data_in,vif.tx_active),UVM_LOW)  
				`uvm_info(get_full_name(),"[TRANSACTION]::TX PASS",UVM_LOW)  
				end
			else begin
				`uvm_info(get_full_name(), $sformatf("\t start = %0b, \t tx_data_in = %0h,\t tx_active = %0b",vif.start,req.tx_data_in,vif.tx_active),UVM_LOW)  
				`uvm_info(get_full_name(),"[TRANSACTION]::TX PASS",UVM_LOW)  
				end  
			repeat(100) @(posedge vif.clk);
			//Test rx
			@(posedge vif.clk);
			data = $random;
			vif.rx <= 1'b0;
			repeat(clock_divide) @(posedge vif.clk);
			for(int i=0;i<8;i++) begin
				vif.rx <= data[i];
				repeat(clock_divide) @(posedge vif.clk);
			end
			vif.rx <= 1'b1;
			repeat(clock_divide) @(posedge vif.clk);
			repeat(100) @(posedge vif.clk); 
			`uvm_info(get_full_name(), $sformatf("\t Expected data = %0h, \t Obtained data = %0h", data,vif.rx_data_out),UVM_LOW)  
			begin
				if(vif.rx_data_out == data) begin
					`uvm_info(get_full_name(),"[TRANSACTION]::RX PASS",UVM_LOW)  
					`uvm_info(get_full_name(),"---------------------------------------------",UVM_LOW)  
					end
				else begin 
					`uvm_info(get_full_name(),"[TRANSACTION]::RX FAIL",UVM_LOW)  
					`uvm_info(get_full_name(),"---------------------------------------------",UVM_LOW)  
					end
			end

			seq_item_port.item_done();
			no_transactions++;
		end
	endtask

endclass: uart_driver