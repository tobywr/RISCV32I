/*
-----------------------------------------
|   RISC-V Single Core Top level File   |
|        Designed by Toby Wright        |
|            github.com/tobywr          |
|                V1.0.0                 |
-----------------------------------------
*/
import riscv_pkg::*;
`timescale 1ps / 1ps

module riscv_top_core (
    input logic clk,
    input logic rst_n,
    output logic [31:0] pc_debug,
    output logic [31:0] alu_result_debug,
    output logic [31:0] instr_debug
);
  logic [31:0] pc;
  logic [31:0] pc_plus_4;
  logic [31:0] instr;
  logic [31:0] read_data1;
  logic [31:0] read_data2;
  logic [31:0] imm_extended;
  logic [31:0] alu_result;
  logic [31:0] mem_read_data;
  logic [31:0] write_data;
  logic [31:0] operand_a;
  logic [1:0]  wb_sel;

  logic    reg_write;
  logic    mem_write;
  logic    alu_src;
  logic    branch;
  logic    jump;
  logic    jalr;
  logic    zero;
  alu_op_t alu_op;

  //instantiate every module with correct logic

  program_counter program_counter_instance (
      .clk(clk),
      .rst_n(rst_n),
      .branch(branch),
      .jump(jump),
      .jalr(jalr),
      .zero(zero),
      .imm_extended(imm_extended),
      .read_data1(read_data1),
      .pc(pc)
  );

  register register_instance (
      .clk(clk),
      .rst_n(rst_n),
      .addr_read1(instr[19:15]),  //rs1
      .addr_read2(instr[24:20]),  //rs2
      .addr_write(instr[11:7]),  //rd
      .write_data(write_data),
      .write_enable(reg_write),
      .read_data1(read_data1),
      .read_data2(read_data2)
  );

  imm_extender imm_extender_instance (
      .instr(instr),
      .imm_extended(imm_extended)
  );

  decoder decoder_instance (
      .instr(instr),
      .reg_write(reg_write),
      .mem_write(mem_write),
      .alu_src(alu_src),
      .wb_sel(wb_sel),
      .branch(branch),
      .jump(jump),
      .alu_op(alu_op),
      .jalr(jalr)
  );

  dmem dmem_instance (
      .clk(clk),
      .we_i(mem_write),
      .addr_i(alu_result),
      .wd_i(read_data2),
      .rd_o(mem_read_data)
  );

  operand_a_selector operand_a_sel (
      .pc(pc),
      .read_data1(read_data1),
      .opcode(instr[6:0]),
      .operand_a(operand_a)
  );

  alu alu_instance (
      .operand_a(operand_a),
      .operand_b(alu_src ? imm_extended : read_data2),  //immediate or reg value / operation.
      .alu_op(alu_op),
      .alu_result(alu_result),
      .zero(zero)
  );

  imem imem_instance (
      .addr (pc),
      .instr(instr)
  );

  //result selector mux
  always_comb begin
    case(wb_sel)
        2'b00: write_data   = alu_result;
        2'b01: write_data   = mem_read_data;
        2'b10: write_data   = pc_plus_4;
        default: write_data = alu_result; //safe default
    endcase
  end

  assign pc_plus_4 = pc + 32'd4;

  //debug outputs
  assign pc_debug = pc;
  assign instr_debug = instr;
  assign alu_result_debug = alu_result;


endmodule
