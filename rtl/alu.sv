/*
-------------------------------------
| ALU Module for RISC-V Single Core |
|      Designed by Toby Wright      |
|         github.com/tobywr         |
|             V1.0.0                |
-------------------------------------
*/

import riscv_pkg::*;

module alu (
    input logic [31:0] operand_a,
    input logic [31:0] operand_b,
    input alu_op_t alu_op,
    output logic [31:0] alu_result,
    output logic zero
);
  always_comb begin
    alu_result = 32'b0;
    zero = 1'b0;

    case (alu_op)
      ALU_ADD:  alu_result = operand_a + operand_b;
      ALU_SUB:  alu_result = operand_a - operand_b;
      ALU_AND:  alu_result = operand_a & operand_b;
      ALU_PASS: alu_result = operand_b;  //Operand_b passes through.
      default:  alu_result = 32'b0;  //default case.
    endcase

    zero = (alu_result == 32'b0); //For BEQ rs1, rs2, label, ALU calculates rs1 - rs2 = 0; zero raised to 1, branch taken.

  end
endmodule

