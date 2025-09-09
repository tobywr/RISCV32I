/*
-----------------------------------------
| Decoder Module for RISC-V Single Core |
|        Designed by Toby Wright        |
|            github.com/tobywr          |
|                V1.0.0                 |
-----------------------------------------
*/

import riscv_pkg::*;

module decoder (
    input  logic    [31:0] instr,
    output logic           reg_write,
    output logic           mem_write,
    output logic           alu_src,
    output logic    [ 1:0] wb_sel,
    output logic           branch,
    output logic           jump,
    output alu_op_t        alu_op,
    output logic           jalr
);

  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;


  assign opcode = instr[6:0];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];

  always_comb begin

    reg_write = 1'b0;
    mem_write = 1'b0;
    alu_src   = 1'b0;
    wb_sel    = 2'b0;
    branch    = 1'b0;
    jump      = 1'b0;
    alu_op    = ALU_ADD;  //safe default, stops latch

    case (opcode)
      OPCODE_IMM: begin  // ADDI
        reg_write = 1'b1;
        alu_src   = 1'b1; //for immediate 
        alu_op    = ALU_ADD;
      end

      OPCODE_R_TYPE: begin  //ADD, SUB, AND
        reg_write = 1'b1;
        case ({
          funct7, funct3
        })
          {7'b0000000, 3'b000} : alu_op = ALU_ADD;
          {7'b0100000, 3'b000} : alu_op = ALU_SUB;
          {7'b0000000, 3'b111} : alu_op = ALU_AND;
        endcase
      end

      OPCODE_LOAD: begin  //LW
        reg_write = 1'b1;
        alu_src   = 1'b1;
        wb_sel    = 2'b01;  //select data from memory
        alu_op    = ALU_ADD;
      end

      OPCODE_STORE: begin  //SW
        alu_src   = 1'b1;
        mem_write = 1'b1;
        alu_op    = ALU_ADD;
      end

      OPCODE_BRANCH: begin  //BEQ
        branch = 1'b1;
        alu_op = ALU_SUB;  //for comparason (Branch if Equal)
      end

      OPCODE_LUI: begin  //LUI
        reg_write = 1'b1;
        alu_src   = 1'b1;
        alu_op    = ALU_PASS;
      end

      OPCODE_JAL: begin  //JAL
        reg_write = 1'b1;
        jump      = 1'b1;
        alu_op    = ALU_ADD;
        wb_sel    = 2'b10;  //select data from memory
      end

      OPCODE_JALR: begin  //JALR
        reg_write = 1'b1;
        jalr = 1'b1;
        alu_src = 1'b1;
        alu_op = ALU_ADD;
      end

      default: alu_op = ALU_ADD;  //Default

    endcase
  end
endmodule
