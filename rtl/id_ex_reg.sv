import riscv_pkg::*;

module id_ex_reg (
    input logic clk,
    input logic rst_n,
    input logic [ADDR_WIDTH-1:0] pc,
    input logic [ADDR_WIDTH-1:0] pc_plus_4,
    input logic [OPCODE_WIDTH-1:0] opcode,
    input logic [REG_ADDR_BITS-1:0] rs1_addr,
    input logic [REG_ADDR_BITS-1:0] rs2_addr,
    input logic [REG_ADDR_BITS-1:0] rd_addr,
    input logic [DATA_WIDTH-1:0] read_data1,
    input logic [DATA_WIDTH-1:0] read_data2,
    input logic [DATA_WIDTH-1:0] imm_extended,
    input logic reg_write,
    input logic mem_write,
    input logic alu_src,
    input logic [1:0] wb_sel,
    input logic branch,
    input logic jump,
    input logic jalr,
    input logic stall,
    input logic pc_src,
    input logic hold,
    input alu_op_t alu_op,
    output logic [ADDR_WIDTH-1:0] pc_id_ex,
    output logic [ADDR_WIDTH-1:0] pc_plus_4_id_ex,
    output logic [OPCODE_WIDTH-1:0] opcode_id_ex,
    output logic [REG_ADDR_BITS-1:0] rs1_addr_id_ex,
    output logic [REG_ADDR_BITS-1:0] rs2_addr_id_ex,
    output logic [REG_ADDR_BITS-1:0] rd_addr_id_ex,
    output logic [DATA_WIDTH-1:0] read_data1_id_ex,
    output logic [DATA_WIDTH-1:0] read_data2_id_ex,
    output logic [DATA_WIDTH-1:0] imm_extended_id_ex,
    output logic reg_write_id_ex,
    output logic mem_write_id_ex,
    output logic alu_src_id_ex,
    output logic [1:0] wb_sel_id_ex,
    output logic branch_id_ex,
    output logic jump_id_ex,
    output logic jalr_id_ex,
    output alu_op_t alu_op_id_ex
);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n || pc_src) begin
            pc_id_ex <= '0;
            pc_plus_4_id_ex <= '0;
            opcode_id_ex <= '0;
            rs1_addr_id_ex <= '0;
            rs2_addr_id_ex <= '0;
            rd_addr_id_ex <= '0;
            read_data1_id_ex <= '0;
            read_data2_id_ex <= '0;
            imm_extended_id_ex <= '0;
            reg_write_id_ex <= '0;
            mem_write_id_ex <= '0;
            alu_src_id_ex <= '0;
            wb_sel_id_ex <= '0;
            branch_id_ex <= '0;
            jump_id_ex <= '0;
            jalr_id_ex <= '0;
            alu_op_id_ex <= ALU_ADD;
        end else if (hold) begin
            pc_id_ex <= pc_id_ex;
            pc_plus_4_id_ex <= pc_plus_4_id_ex;
            opcode_id_ex <= opcode_id_ex;
            rs1_addr_id_ex <= rs1_addr_id_ex;
            rs2_addr_id_ex <= rs2_addr_id_ex;
            rd_addr_id_ex <= rd_addr_id_ex;
            read_data1_id_ex <= read_data1_id_ex;
            read_data2_id_ex <= read_data2_id_ex;
            imm_extended_id_ex <= imm_extended_id_ex;
            reg_write_id_ex <= reg_write_id_ex;
            mem_write_id_ex <= mem_write_id_ex;
            alu_src_id_ex <= alu_src_id_ex;
            wb_sel_id_ex <= wb_sel_id_ex;
            branch_id_ex <= branch_id_ex;
            jump_id_ex <= jump_id_ex;
            jalr_id_ex <= jalr_id_ex;
            alu_op_id_ex <= alu_op_id_ex;
        end else if (stall) begin
            pc_id_ex <= '0;
            pc_plus_4_id_ex <= '0;
            opcode_id_ex <= '0;
            rs1_addr_id_ex <= '0;
            rs2_addr_id_ex <= '0;
            rd_addr_id_ex <= '0;
            read_data1_id_ex <= '0;
            read_data2_id_ex <= '0;
            imm_extended_id_ex <= '0;
            reg_write_id_ex <= '0;
            mem_write_id_ex <= '0;
            alu_src_id_ex <= '0;
            wb_sel_id_ex <= '0;
            branch_id_ex <= '0;
            jump_id_ex <= '0;
            jalr_id_ex <= '0;
            alu_op_id_ex <= ALU_ADD;
        end else begin
            pc_id_ex <= pc;
            pc_plus_4_id_ex <= pc_plus_4;
            opcode_id_ex <= opcode;
            rs1_addr_id_ex <= rs1_addr;
            rs2_addr_id_ex <= rs2_addr;
            rd_addr_id_ex <= rd_addr;
            read_data1_id_ex <= read_data1;
            read_data2_id_ex <= read_data2;
            imm_extended_id_ex <= imm_extended;
            reg_write_id_ex <= reg_write;
            mem_write_id_ex <= mem_write;
            alu_src_id_ex <= alu_src;
            wb_sel_id_ex <= wb_sel;
            branch_id_ex <= branch;
            jump_id_ex <= jump;
            jalr_id_ex <= jalr;
            alu_op_id_ex <= alu_op;
        end
    end

endmodule