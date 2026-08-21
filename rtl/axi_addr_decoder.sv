import riscv_pkg::*;

module axi_addr_decoder (
    input logic [ADDR_WIDTH-1:0] alu_result,
    input logic [DATA_WIDTH-1:0] data_write,
    input logic mem_write,
    input logic [1:0] wb_sel,
    input logic [DATA_WIDTH-1:0] dmem_read_data,
    input logic [DATA_WIDTH-1:0] axi_read_data,
    output logic axi_write,
    output logic axi_read,
    output logic [ADDR_WIDTH-1:0] axi_addr,
    output logic [DATA_WIDTH-1:0] axi_wdata,
    output logic [DATA_WIDTH-1:0] mem_read_data
);


always_comb begin
    //defaults
    axi_write = '0;
    axi_read = '0;
    axi_addr = '0;
    axi_wdata = '0;
    mem_read_data = '0;

    if (alu_result >= (MEM_WORDS * 4)) begin
        axi_addr = alu_result;
        if(mem_write) begin
            axi_write = 1;
            axi_wdata = data_write;
        end else if (wb_sel == 2'b01) begin
            axi_read = 1;
            mem_read_data = axi_read_data;
        end
    end else begin
        mem_read_data = dmem_read_data;
    end
end


endmodule