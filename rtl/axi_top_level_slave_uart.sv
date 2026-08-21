import riscv_pkg::*;

module axi_top_level_slave_uart #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input logic clk,
    input logic rst_n,
    output logic tx_o
);

    //AXI connections logic (not master or slave)
    logic axi_awready;
    logic [ADDR_WIDTH-1:0] axi_awaddr;
    logic axi_awvalid;
    logic axi_wready;
    logic [DATA_WIDTH-1:0] axi_wdata;
    logic [3:0] axi_wstrb;
    logic axi_wvalid;
    logic [1:0] axi_bresp;
    logic axi_bvalid;
    logic axi_bready;
    logic axi_arready;
    logic [ADDR_WIDTH-1:0] axi_araddr;
    logic axi_arvalid;
    logic [DATA_WIDTH-1:0] axi_rdata;
    logic [1:0] axi_rresp;
    logic axi_rvalid;
    logic axi_rready;

    //Instantiations
    riscv_top_core_wrapper riscv_top_core_wrapper_0 (
        .clk(clk),
        .rst_n(rst_n),
        .m_axi_awready(axi_awready),
        .m_axi_awaddr(axi_awaddr),
        .m_axi_awvalid(axi_awvalid),
        .m_axi_wready(axi_wready),
        .m_axi_wdata(axi_wdata),
        .m_axi_wstrb(axi_wstrb),
        .m_axi_wvalid(axi_wvalid),
        .m_axi_bresp(axi_bresp),
        .m_axi_bvalid(axi_bvalid),
        .m_axi_bready(axi_bready),
        .m_axi_arready(axi_arready),
        .m_axi_araddr(axi_araddr),
        .m_axi_arvalid(axi_arvalid),
        .m_axi_rdata(axi_rdata),
        .m_axi_rresp(axi_rresp),
        .m_axi_rvalid(axi_rvalid),
        .m_axi_rready(axi_rready)
    );

    axi_uart_slave #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) axi_uart_slave_0 (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_awready(axi_awready),
        .s_axi_awaddr(axi_awaddr),
        .s_axi_awvalid(axi_awvalid),
        .s_axi_wready(axi_wready),
        .s_axi_wdata(axi_wdata),
        .s_axi_wstrb(axi_wstrb),
        .s_axi_wvalid(axi_wvalid),
        .s_axi_bresp(axi_bresp),
        .s_axi_bvalid(axi_bvalid),
        .s_axi_bready(axi_bready),
        .s_axi_arready(axi_arready),
        .s_axi_araddr(axi_araddr),
        .s_axi_arvalid(axi_arvalid),
        .s_axi_rdata(axi_rdata),
        .s_axi_rresp(axi_rresp),
        .s_axi_rvalid(axi_rvalid),
        .s_axi_rready(axi_rready),
        .uart_tx_o(tx_o)
    );

endmodule