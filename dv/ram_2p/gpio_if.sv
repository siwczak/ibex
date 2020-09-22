interface gpio_if (input bit clk);

    logic [3:0] led;
	logic [3:0] button;
	logic rst_ni;
	logic valid;
	logic [3:0] data_s;
	logic [3:0] data_m;
	logic  sel_led;
	logic sel_but;
	logic we;

	clocking cb @(posedge clk);
      default input #1step output #3ns;
		input data_s;
		input led;
		output data_m;
		output button;
		output valid;
		output sel_led;
		output sel_but;
		output we;
	endclocking

endinterface