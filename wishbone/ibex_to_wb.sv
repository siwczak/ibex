module ibex_to_wb(
	ibex_if.slave core,
	wishbone_if.master wb
);

	logic cyc;

	assign core.gnt    = core.req & ~wb.stall;
	assign core.rvalid = wb.ack;
	assign core.err    = wb.err;
	assign core.rdata  = wb.data_s;
	assign wb.stb      = core.req;
	assign wb.addr      = core.addr;
	assign wb.data_m    = core.wdata;
	assign wb.we       = core.we;
	assign wb.sel      = core.we ? core.be : '1;

	always_ff @(posedge wb.clk_i or posedge wb.rst_ni)
		if (!wb.rst_ni)
			cyc <= 1'b0;
		else
		if (core.req)
			cyc <= 1'b1;
		else if (wb.ack || wb.err)
			cyc <= 1'b0;

	assign wb.cyc = core.req | cyc;

endmodule
