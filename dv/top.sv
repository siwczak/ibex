`timescale 1ns / 1ps
module top;

	logic clk=0;
	logic rst=0;
	logic [3:0] led;
	logic uart_tx;
	logic uart_rx=0;

	ibex_soc dut(.I_CLK(clk), .I_RST_N(rst), .O_LED(led), .O_UART_TX(uart_tx), .I_UART_RX(uart_rx));

	initial begin
		rst=0;
		clk=0;
		#1 rst=1;
	end

	initial forever #5 clk=~clk;

	initial $monitor(led);

endmodule