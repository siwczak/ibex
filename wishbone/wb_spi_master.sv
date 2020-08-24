module wb_spi_master#(parameter SPI_SLAVE = -1)(
    input miso_i,
    output mosi_o,
    output sck_o,
    output [SPI_SLAVE-1:0] cs_o,
    output irq_o,
    wishbone_if.slave wb
    );
    
    logic [8-1 : 0] data_out;
    assign wb.data_s = {24'h000000,data_out};
    assign wb.err = 1'b0;
    assign wb.stall = 1'b0;
    
    spi_master#(SPI_SLAVE) spi_master(
    .clk_i(wb.clk_i),
    .rst_i(~wb.rst_ni),
    .cyc_i(wb.cyc),
    .stb_i(wb.stb),
    .adr_i(wb.addr[4:2]),
    .we_i(wb.we),
    .dat_i(wb.data_m[8-1:0]),
    .dat_o(data_out),
    .ack_o(wb.ack),
    .inta_o(irq_o),
    .sck_o(sck_o),
    .cs_o(cs_o),
    .mosi_o(mosi_o),
    .miso_i(miso_i)
    );
endmodule
