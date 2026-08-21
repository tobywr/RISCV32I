/*
-----------------------------------------
|   RISC-V Single Core Top level File   |
|        Designed by Toby Wright        |
|            github.com/tobywr          |
|                V1.0.0                 |
-----------------------------------------
*/

import riscv_pkg::*;
`timescale 1ns / 1ps

module riscv_top_core_wrapper (
  input logic clk,
  input logic rst_n,

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

  ////////////////////
  // Internal Logic //
  ////////////////////

  //IFID Reg
  logic [ADDR_WIDTH-1:0] pc_plus_4_if_id;
  logic [ADDR_WIDTH-1:0] pc_if_id;
  logic [ADDR_WIDTH-1:0] instr_if_id;
  //IDEX Reg
  logic [ADDR_WIDTH-1:0] pc_plus_4_id_ex;
  logic [ADDR_WIDTH-1:0] pc_id_ex;
  logic [OPCODE_WIDTH-1:0] opcode_id_ex;
  logic [REG_ADDR_BITS-1:0] rs1_addr_id_ex;
  logic [REG_ADDR_BITS-1:0] rs2_addr_id_ex;
  logic [REG_ADDR_BITS-1:0] rd_addr_id_ex;
  logic [DATA_WIDTH-1:0] read_data1_id_ex;
  logic [DATA_WIDTH-1:0] read_data2_id_ex;
  logic [DATA_WIDTH-1:0] imm_extended_id_ex;
  logic reg_write_id_ex;
  logic mem_write_id_ex;
  logic alu_src_id_ex;
  logic [1:0] wb_sel_id_ex;
  logic branch_id_ex;
  logic jump_id_ex;
  logic jalr_id_ex;
  alu_op_t alu_op_id_ex;
  //EXMEM Reg
  logic [ADDR_WIDTH-1:0] pc_plus_4_ex_mem;
  logic [REG_ADDR_BITS-1:0] rd_addr_ex_mem;
  logic [DATA_WIDTH-1:0] alu_result_ex_mem;
  logic [DATA_WIDTH-1:0] store_data_ex_mem;
  logic reg_write_ex_mem;
  logic mem_write_ex_mem;
  logic [1:0] wb_sel_ex_mem;
  //MEMWB Reg
  logic [DATA_WIDTH-1:0] pc_plus_4_mem_wb;
  logic [REG_ADDR_BITS-1:0] rd_addr_mem_wb;
  logic [DATA_WIDTH-1:0] alu_result_mem_wb;
  logic [DATA_WIDTH-1:0] mem_read_data_mem_wb;
  logic reg_write_mem_wb;
  logic [1:0] wb_sel_mem_wb;
  //All other signals.
  logic [ADDR_WIDTH-1:0] pc_plus_4;
  logic [ADDR_WIDTH-1:0] pc;
  logic [DATA_WIDTH-1:0] instr;
  logic [DATA_WIDTH-1:0] read_data1;
  logic [DATA_WIDTH-1:0] read_data2;
  logic [DATA_WIDTH-1:0] imm_extended;
  logic pc_src;
  logic stall;
  logic reg_write;
  logic mem_write;
  logic alu_src;
  logic [1:0] wb_sel;
  logic branch;
  logic jump;
  logic jalr;
  alu_op_t alu_op;
  logic [ADDR_WIDTH-1:0] branch_target;
  logic [DATA_WIDTH-1:0] operand_a_val;
  logic [DATA_WIDTH-1:0] operand_b_val;
  logic [1:0] forward_a;
  logic [1:0] forward_b;
  logic [DATA_WIDTH-1:0] write_data;
  logic [DATA_WIDTH-1:0] operand_a;
  logic [DATA_WIDTH-1:0] operand_b;
  logic [DATA_WIDTH-1:0] read_data;
  logic zero;
  logic [DATA_WIDTH-1:0] alu_result;

  //axi ports
  logic [ADDR_WIDTH-1:0] axi_addr;
  logic [DATA_WIDTH-1:0] axi_wdata;
  logic axi_write;
  logic axi_read;
  logic [DATA_WIDTH-1:0] axi_rdata;
  logic busy;
  logic hold;
  logic bubble;
  logic [DATA_WIDTH-1:0] mem_read_data_final;

  assign hold = busy;
  assign bubble = busy;

  logic pc_src_gated;
  assign pc_src_gated = pc_src & !busy;

  logic pc_ifid_stall;
  assign pc_ifid_stall = stall | busy;

  ///////////////////////////
  // Instantiating Modules //
  ///////////////////////////

  program_counter pc_0 (
    .clk(clk),
    .rst_n(rst_n),
    .stall(pc_ifid_stall),
    .pc_plus_4(pc_plus_4),
    .pc_src(pc_src_gated),
    .branch_target(branch_target),
    .pc(pc)
  );

  imem imem_0 (
    .addr(pc),
    .instr(instr)
  );

  pc_plus_4_adder pc_plus_4_adder_0 (
    .pc(pc),
    .pc_plus_4(pc_plus_4)
  );

  if_id_reg if_id_reg_0 (
    .clk(clk),
    .rst_n(rst_n),
    .pc_plus_4(pc_plus_4),
    .pc(pc),
    .instr(instr),
    .stall(pc_ifid_stall),
    .pc_src(pc_src_gated),
    .pc_plus_4_if_id(pc_plus_4_if_id),
    .pc_if_id(pc_if_id),
    .instr_if_id(instr_if_id)
  );

  imm_extender imm_extender_0 (
    .instr(instr_if_id),
    .imm_extended(imm_extended)
  );

  decoder decoder_0 (
    .instr(instr_if_id),
    .reg_write(reg_write),
    .mem_write(mem_write),
    .alu_src(alu_src),
    .wb_sel(wb_sel),
    .branch(branch),
    .jump(jump),
    .alu_op(alu_op),
    .jalr(jalr)
  );

  register reg_0 (
    .clk(clk),
    .rst_n(rst_n),
    .addr_read1(instr_if_id[19:15]),
    .addr_read2(instr_if_id[24:20]),
    .addr_write(rd_addr_mem_wb),
    .write_data(write_data),
    .write_enable(reg_write_mem_wb),
    .read_data1(read_data1),
    .read_data2(read_data2)
  );

  id_ex_reg id_ex_reg_0 (
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc_if_id),
    .pc_plus_4(pc_plus_4_if_id),
    .opcode(instr_if_id[6:0]),
    .rs1_addr(instr_if_id[19:15]),
    .rs2_addr(instr_if_id[24:20]),
    .rd_addr(instr_if_id[11:7]),
    .read_data1(read_data1),
    .read_data2(read_data2),
    .imm_extended(imm_extended),
    .reg_write(reg_write),
    .mem_write(mem_write),
    .alu_src(alu_src),
    .wb_sel(wb_sel),
    .branch(branch),
    .jump(jump),
    .jalr(jalr),
    .stall(stall),
    .pc_src(pc_src_gated),
    .hold(hold),
    .alu_op(alu_op),
    .pc_id_ex(pc_id_ex),
    .pc_plus_4_id_ex(pc_plus_4_id_ex),
    .opcode_id_ex(opcode_id_ex),
    .rs1_addr_id_ex(rs1_addr_id_ex),
    .rs2_addr_id_ex(rs2_addr_id_ex),
    .rd_addr_id_ex(rd_addr_id_ex),
    .read_data1_id_ex(read_data1_id_ex),
    .read_data2_id_ex(read_data2_id_ex),
    .imm_extended_id_ex(imm_extended_id_ex),
    .reg_write_id_ex(reg_write_id_ex),
    .mem_write_id_ex(mem_write_id_ex),
    .alu_src_id_ex(alu_src_id_ex),
    .wb_sel_id_ex(wb_sel_id_ex),
    .branch_id_ex(branch_id_ex),
    .jump_id_ex(jump_id_ex),
    .jalr_id_ex(jalr_id_ex),
    .alu_op_id_ex(alu_op_id_ex)
  );

  forward_a forward_a_0 (
    .read_data1(read_data1_id_ex),
    .alu_result(alu_result_ex_mem),
    .write_data(write_data),
    .forward_a(forward_a),
    .operand_a_val(operand_a_val)
  );

  forward_b forward_b_0 (
    .read_data2(read_data2_id_ex),
    .alu_result(alu_result_ex_mem),
    .write_data(write_data),
    .forward_b(forward_b),
    .operand_b_val(operand_b_val)
  );

  operand_a_selector operand_a_selector_0 (
    .pc(pc_id_ex),
    .operand_a_val(operand_a_val),
    .opcode(opcode_id_ex),
    .operand_a(operand_a)
  );

  operand_b_selector operand_b_selector_0 (
    .imm_extended(imm_extended_id_ex),
    .operand_b_val(operand_b_val),
    .operand_b(operand_b),
    .alu_src(alu_src_id_ex)
  );

  branch_adder branch_adder_0 (
    .pc(pc_id_ex),
    .imm_extended(imm_extended_id_ex),
    .operand_a_val(operand_a_val),
    .jump(jump_id_ex),
    .branch(branch_id_ex),
    .jalr(jalr_id_ex),
    .zero(zero),
    .branch_target(branch_target),
    .pc_src(pc_src)
  );

  alu alu_0 (
    .operand_a(operand_a),
    .operand_b(operand_b),
    .alu_op(alu_op_id_ex),
    .alu_result(alu_result),
    .zero(zero)
  );

  ex_mem_reg ex_mem_reg_0(
    .clk(clk),
    .rst_n(rst_n),
    .pc_plus_4(pc_plus_4_id_ex),
    .rd_addr(rd_addr_id_ex),
    .alu_result(alu_result),
    .store_data(operand_b_val),
    .reg_write(reg_write_id_ex),
    .mem_write(mem_write_id_ex),
    .wb_sel(wb_sel_id_ex),
    .pc_plus_4_ex_mem(pc_plus_4_ex_mem),
    .rd_addr_ex_mem(rd_addr_ex_mem),
    .alu_result_ex_mem(alu_result_ex_mem),
    .store_data_ex_mem(store_data_ex_mem),
    .reg_write_ex_mem(reg_write_ex_mem),
    .mem_write_ex_mem(mem_write_ex_mem),
    .wb_sel_ex_mem(wb_sel_ex_mem),
    .hold(hold)
  );

  dmem dmem_0 (
    .clk(clk),
    .write_ena(mem_write_ex_mem),
    .write_addr(alu_result_ex_mem),
    .write_data(store_data_ex_mem),
    .read_data(read_data)
  );

  mem_wb_reg mem_wb_reg_0(
    .clk(clk),
    .rst_n(rst_n),
    .pc_plus_4(pc_plus_4_ex_mem),
    .rd_addr(rd_addr_ex_mem),
    .alu_result(alu_result_ex_mem),
    .mem_read_data(mem_read_data_final),
    .reg_write(reg_write_ex_mem),
    .wb_sel(wb_sel_ex_mem),
    .pc_plus_4_mem_wb(pc_plus_4_mem_wb),
    .rd_addr_mem_wb(rd_addr_mem_wb),
    .alu_result_mem_wb(alu_result_mem_wb),
    .mem_read_data_mem_wb(mem_read_data_mem_wb),
    .reg_write_mem_wb(reg_write_mem_wb),
    .wb_sel_mem_wb(wb_sel_mem_wb),
    .bubble(bubble)
  );

  writeback_mux writeback_mux_0 (
    .wb_sel(wb_sel_mem_wb),
    .alu_result(alu_result_mem_wb),
    .mem_read_data(mem_read_data_mem_wb),
    .pc_plus_4(pc_plus_4_mem_wb),
    .write_data(write_data)
  );

  hazard_forward_unit hazard_forward_unit_0 (
    .id_rs1_addr(instr_if_id[19:15]),
    .id_rs2_addr(instr_if_id[24:20]),
    .ex_rd_addr(rd_addr_id_ex),
    .ex_wb_sel(wb_sel_id_ex),
    .ex_rs1_addr(rs1_addr_id_ex),
    .ex_rs2_addr(rs2_addr_id_ex),
    .mem_rd_addr(rd_addr_ex_mem),
    .mem_reg_write(reg_write_ex_mem),
    .wb_rd_addr(rd_addr_mem_wb),
    .wb_reg_write(reg_write_mem_wb),
    .stall(stall),
    .forward_a(forward_a),
    .forward_b(forward_b)
  );

  ///////////////////////
  // Axi Instantiation //
  ///////////////////////

  axi_addr_decoder axi_addr_decoder_0 (
    .alu_result(alu_result_ex_mem),
    .data_write(store_data_ex_mem),
    .mem_write(mem_write_ex_mem),
    .wb_sel(wb_sel_ex_mem),
    .dmem_read_data(read_data),
    .axi_read_data(axi_rdata),
    .axi_write(axi_write),
    .axi_read(axi_read),
    .axi_addr(axi_addr),
    .axi_wdata(axi_wdata),
    .mem_read_data(mem_read_data_final)
  );

  axi_lite_master axi_lite_master_0 (
    .clk(clk),
    .rst_n(rst_n),
    .axi_addr(axi_addr),
    .axi_wdata(axi_wdata),
    .axi_write(axi_write),
    .axi_read(axi_read),
    .axi_rdata(axi_rdata),
    .busy(busy),
    .m_axi_awready(m_axi_awready),
    .m_axi_awaddr(m_axi_awaddr),
    .m_axi_awvalid(m_axi_awvalid),
    .m_axi_wready(m_axi_wready),
    .m_axi_wdata(m_axi_wdata),
    .m_axi_wstrb(m_axi_wstrb),
    .m_axi_wvalid(m_axi_wvalid),
    .m_axi_bresp(m_axi_bresp),
    .m_axi_bvalid(m_axi_bvalid),
    .m_axi_bready(m_axi_bready),
    .m_axi_arready(m_axi_arready),
    .m_axi_araddr(m_axi_araddr),
    .m_axi_arvalid(m_axi_arvalid),
    .m_axi_rdata(m_axi_rdata),
    .m_axi_rresp(m_axi_rresp),
    .m_axi_rvalid(m_axi_rvalid),
    .m_axi_rready(m_axi_rready)
  );

endmodule
