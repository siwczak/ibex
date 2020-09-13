module gpio(
    output logic [3:0] led,
	input logic [3:0] button,
	input clk_i,
	input rst_ni,
	input valid,
	output logic [3:0] data_s,
	input [3:0] data_m,
	input  sel_led,
	input sel_but,
	input we
);

logic [3:0] data_button='0;

    always @(posedge clk_i or posedge rst_ni)
        if (!rst_ni)
            led <= '0;
        else
            if (valid && we && sel_led) begin
                led <= data_m[3:0];
				data_s <= led;
			end
			
    always @(posedge clk_i or posedge rst_ni)
        if (!rst_ni)
            data_button <= '0;
        else
            if (valid && we && sel_but) begin
                data_button <= button;
				data_s <= data_button;
			end
	//assign data_s = led;

endmodule