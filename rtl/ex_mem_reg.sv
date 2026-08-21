import riscv_pkg::*;

module ex_mem_reg (
    input logic clk,
    input logic rst_n,
    input logic [ADDR_WIDTH-1:0] pc_plus_4,
    input logic [REG_ADDR_BITS-1:0] rd_addr,
    input logic [DATA_WIDTH-1:0] alu_result,
    input logic [DATA_WIDTH-1:0] store_data,
    input logic reg_write,
    input logic mem_write,
    input logic hold,
    input logic [1:0] wb_sel,
    output logic [ADDR_WIDTH-1:0] pc_plus_4_ex_mem,
    output logic [REG_ADDR_BITS-1:0] rd_addr_ex_mem,
    output logic [DATA_WIDTH-1:0] alu_result_ex_mem,
    output logic [DATA_WIDTH-1:0] store_data_ex_mem,
    output logic reg_write_ex_mem,
    output logic mem_write_ex_mem,
    output logic [1:0] wb_sel_ex_mem
);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc_plus_4_ex_mem <= '0;
            rd_addr_ex_mem <= '0;
            alu_result_ex_mem <= '0;
            store_data_ex_mem <= '0;
            reg_write_ex_mem <= '0;
            mem_write_ex_mem <= '0;
            wb_sel_ex_mem <= '0;
        end else if (hold) begin
           pc_plus_4_ex_mem <= pc_plus_4_ex_mem;
           rd_addr_ex_mem <= rd_addr_ex_mem;
           alu_result_ex_mem <= alu_result_ex_mem;
           store_data_ex_mem <= store_data_ex_mem;
           reg_write_ex_mem <= reg_write_ex_mem;
           mem_write_ex_mem <= mem_write_ex_mem;
           wb_sel_ex_mem <= wb_sel_ex_mem; 
        end else begin
           pc_plus_4_ex_mem <= pc_plus_4;
           rd_addr_ex_mem <= rd_addr;
           alu_result_ex_mem <= alu_result;
           store_data_ex_mem <= store_data;
           reg_write_ex_mem <= reg_write;
           mem_write_ex_mem <= mem_write;
           wb_sel_ex_mem <= wb_sel; 
        end
    end

endmodule