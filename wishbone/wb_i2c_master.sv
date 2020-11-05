
module wb_i2c(
	inout               IO_SDA,
	inout               IO_SCL,
	wishbone_if.slave wb
);

	logic [7:0] data_o;
	logic scl_pad_i,scl_pad_o,scl_padoen_o;
	logic sda_pad_i,sda_pad_o,sda_padoen_o;
	assign wb.data_s = {24'h000000,data_o};
	assign wb.stall = 1'b0;
	assign wb.err   = 1'b0;

	i2c_top i2c(
		.wb_clk_i(wb.clk_i),
		.wb_rst_i(!wb.rst_ni),
		.arst_i(1'b0),
		.wb_adr_i(wb.addr[4:2]),
		.wb_dat_i(wb.data_m[7:0]),
		.wb_dat_o(data_o),
		.wb_we_i(wb.we),
		.wb_stb_i(wb.stb),
		.wb_cyc_i(wb.cyc),
		.wb_ack_o(wb.ack),
		.wb_inta_o(),

		.scl_pad_i(scl_pad_i),
		.scl_pad_o(scl_pad_o),
		.scl_padoen_o(scl_padoen_o),

		.sda_pad_i(sda_pad_i),
		.sda_pad_o(sda_pad_o),
		.sda_padoen_o(sda_padoen_o)
	);

	assign IO_SCL = scl_padoen_o ? 'bz : scl_pad_o;
	assign IO_SDA = sda_padoen_o ? 'bz : sda_pad_o;
	assign scl_pad_i = IO_SCL;
	assign sda_pad_i = IO_SDA;

endmodule
