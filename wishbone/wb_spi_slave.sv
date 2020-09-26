module wb_spi_slave(
    output miso_o,
    input mosi_i,
    input sck_i,
	input cs_i,
    wishbone_if.slave wb
    );
    
    logic [8-1 : 0] data_out;
    assign wb.data_s = {24'h000000,data_out};
    assign wb.err = 1'b0;
    assign wb.stall = 1'b0;
    logic valid;
	
    spi_slave spi_slave(
    .clk_i(wb.clk_i),
    .rst_i(~wb.rst_ni),
    .tx_dv_i(valid),
    .tx_byte_i(wb.data_m[8-1:0]),
    .rx_byte_o(data_out),
    .rx_dv_o(wb.ack),
    .spi_clk_i(sck_i),
    .cs_i(cs_i),
    .mosi_i(mosi_i),
    .miso_o(miso_o)
    );
	
	assign valid = wb.cyc & wb.stb;
endmodule
