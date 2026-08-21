import riscv_pkg::*;

module axi_uart_slave #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 115200
)(
    input logic clk,
    input logic rst_n,

    output logic s_axi_awready,
    input logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input logic s_axi_awvalid,

    output logic s_axi_wready,
    input logic [DATA_WIDTH-1:0] s_axi_wdata,
    input logic [3:0] s_axi_wstrb,
    input logic s_axi_wvalid,

    output logic [1:0] s_axi_bresp,
    output logic s_axi_bvalid,
    input logic s_axi_bready,

    output logic s_axi_arready,
    input logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input logic s_axi_arvalid,

    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0] s_axi_rresp,
    output logic s_axi_rvalid,
    input logic s_axi_rready,

    output logic uart_tx_o
);

    logic tx_busy;

    typedef enum logic [1:0] {
        IDLE,
        W_DATA,
        B
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        //defaults
        next_state = state;
        s_axi_awready = '0;
        s_axi_wready = '0;
        s_axi_bvalid = '0;
        s_axi_bresp = '0;

        case(state)
            IDLE: begin
                if(!tx_busy) begin
                    s_axi_awready = 1;
                    if(s_axi_awvalid) begin
                        next_state = W_DATA;
                    end else next_state = IDLE;
                end else next_state = IDLE;
            end

            W_DATA: begin
                s_axi_wready = 1;
                if(s_axi_wvalid) begin
                    next_state = B;
                end else next_state = W_DATA;
            end

            B: begin
                s_axi_bvalid = 1;
                s_axi_bresp = 2'b00;
                if(s_axi_bready) begin
                    next_state = IDLE;
                end else next_state = B;
            end
        endcase
    end

    always_comb begin
        s_axi_arready = 1;
        s_axi_rvalid = s_axi_arvalid;
        s_axi_rdata = {31'b0, tx_busy};
        s_axi_rresp = 2'b00;
    end


    logic tx_start;
    assign tx_start = (state == W_DATA) && s_axi_wvalid;

    //instantate uart TX module
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    )uart_tx_0(
        .clk(clk),
        .rst_n(rst_n),
        .tx_data_i(s_axi_wdata[7:0]),
        .tx_start(tx_start),
        .tx_o(uart_tx_o),
        .tx_busy(tx_busy)
    );

endmodule