interface ram_if
(input bit clk);

	logic [5-1:0] addr_i;
	logic valid_i;
	logic [3:0] we_i;
	logic [32-1:0] data_i;
	logic [32-1:0] data_o;


	clocking cb @(posedge clk);
    	default output #2;
		output addr_i;
		output valid_i;
		output data_i;
		output we_i;
		input data_o;
	endclocking

endinterface