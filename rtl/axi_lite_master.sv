import riscv_pkg::*;

module axi_lite_master (
    input logic clk,
    input logic rst_n,
    input logic [ADDR_WIDTH-1:0] axi_addr,
    input logic [DATA_WIDTH-1:0] axi_wdata,
    input logic axi_write,
    input logic axi_read,
    output logic [DATA_WIDTH-1:0] axi_rdata,
    output logic busy,
    
    input logic m_axi_awready,
    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic m_axi_awvalid,

    input logic m_axi_wready,
    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    output logic [3:0] m_axi_wstrb,
    output logic m_axi_wvalid,

    input logic [1:0] m_axi_bresp,
    input logic m_axi_bvalid,
    output logic m_axi_bready,

    input logic m_axi_arready,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic m_axi_arvalid,

    input logic [DATA_WIDTH-1:0] m_axi_rdata,
    input logic [1:0] m_axi_rresp,
    input logic m_axi_rvalid,
    output logic m_axi_rready
);

    logic [ADDR_WIDTH-1:0] axi_addr_latched;
    logic [DATA_WIDTH-1:0] axi_wdata_latched;
    //latching addr/wdata
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            axi_addr_latched <= '0;
            axi_wdata_latched <= '0;
        end else if ((state == IDLE) && axi_write) begin
            axi_addr_latched <= axi_addr;
            axi_wdata_latched <= axi_wdata;
        end else if ((state == IDLE) && axi_read) begin
            axi_addr_latched <= axi_addr;
        end
    end


    typedef enum logic [2:0] { 
        IDLE, //idle
        AW,   //write addresds
        W,    //write data
        B,    //write response
        AR,   //read address
        R     //read response
    }state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        //DEFAULTS
        next_state = state;
        axi_rdata = '0;
        m_axi_awaddr = '0;
        m_axi_awvalid = '0;
        m_axi_bready = '0;
        m_axi_araddr = '0;
        m_axi_arvalid = '0;
        m_axi_rready = '0;
        m_axi_wdata = '0;
        m_axi_wstrb = '0;
        m_axi_wvalid = '0;

        case(state)
            IDLE: begin
                if (axi_write) begin
                    next_state = AW;
                end else if (axi_read) begin
                    next_state = AR;
                end
            end

            AW: begin
                m_axi_awvalid = 1;
                m_axi_awaddr = axi_addr_latched;
                if(m_axi_awready) begin
                    next_state = W;
                end else next_state = AW;
            end

            W: begin
                m_axi_wvalid = 1;
                m_axi_wdata = axi_wdata_latched;
                m_axi_wstrb = 4'b1111;
                if(m_axi_wready) begin
                    next_state = B;
                end else next_state = W;
            end

            B: begin
                m_axi_bready = 1;
                if(m_axi_bvalid) begin
                    next_state = IDLE;
                end
            end

            AR: begin
                m_axi_arvalid = 1;
                m_axi_araddr = axi_addr_latched;
                if(m_axi_arready) begin
                    next_state = R;
                end else next_state = AR;
            end

            R: begin
                m_axi_rready = 1;
                if(m_axi_rvalid) begin
                    axi_rdata = m_axi_rdata;
                    next_state = IDLE;
                end else next_state = R;
            end
        endcase
    end

    assign busy = (state != IDLE);
endmodule