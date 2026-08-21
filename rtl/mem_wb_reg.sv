import riscv_pkg::*;

module mem_wb_reg (
    input logic clk,
    input logic rst_n,
    input logic [DATA_WIDTH-1:0] pc_plus_4,
    input logic [REG_ADDR_BITS-1:0] rd_addr,
    input logic [DATA_WIDTH-1:0] alu_result,
    input logic [DATA_WIDTH-1:0] mem_read_data,
    input logic reg_write,
    input logic bubble,
    input logic [1:0] wb_sel,
    output logic [DATA_WIDTH-1:0] pc_plus_4_mem_wb,
    output logic [REG_ADDR_BITS-1:0] rd_addr_mem_wb,
    output logic [DATA_WIDTH-1:0] alu_result_mem_wb,
    output logic [DATA_WIDTH-1:0] mem_read_data_mem_wb,
    output logic reg_write_mem_wb,
    output logic [1:0] wb_sel_mem_wb
);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n || bubble) begin
            pc_plus_4_mem_wb <= '0;
            rd_addr_mem_wb <= '0;
            alu_result_mem_wb <= '0;
            mem_read_data_mem_wb <= '0;
            reg_write_mem_wb <= '0;
            wb_sel_mem_wb <= '0;
        end else begin
            pc_plus_4_mem_wb <= pc_plus_4;
            rd_addr_mem_wb <= rd_addr;
            alu_result_mem_wb <= alu_result;
            mem_read_data_mem_wb <= mem_read_data;
            reg_write_mem_wb <= reg_write;
            wb_sel_mem_wb <= wb_sel;
        end
    end

endmodule