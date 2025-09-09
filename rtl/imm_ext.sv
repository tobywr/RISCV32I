/*
----------------------------------------------------
| Immediate Extender Module for RISC-V Single Core |
|             Designed by Toby Wright              |
|                github.com/tobywr                 |
|                     V1.0.0                       |
----------------------------------------------------
*/

import riscv_pkg::*;


module imm_extender (
    input  logic [DATA_WIDTH-1:0] instr,
    output logic [DATA_WIDTH-1:0] imm_extended
);

  logic [OPCODE_WIDTH-1 : 0] opcode;
  assign opcode = instr[6:0];

  always_comb begin
    case (opcode)
      // I-type instructions
      OPCODE_IMM, OPCODE_LOAD, OPCODE_JALR: begin
        imm_extended = {{20{instr[31]}}, instr[31:20]};
      end

      //S-type instructions
      OPCODE_STORE: begin
        imm_extended = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      end

      //B-type instructions
      OPCODE_BRANCH: begin
        imm_extended = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      end

      //U-type instructions
      OPCODE_LUI: begin
        imm_extended = {instr[31:12], 12'b0};
      end

      //J-type instructions
      OPCODE_JAL: begin
        imm_extended = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      end

      default: imm_extended = 32'b0;
    endcase
  end
endmodule
