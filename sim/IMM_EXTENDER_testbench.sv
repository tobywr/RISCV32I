/*
------------------------------------------------------
| Imediate Exender Test Bench for RISC-V Single Core |
|             Designed by Toby Wright                |
|                github.com/tobywr                   |
|                     V1.0.0                         |
------------------------------------------------------
*/
`timescale 1ns

import riscv_pkg::*;

module tb_imm_extender ();

  logic [31:0] instr;
  logic [31:0] imm_ext;

  imm_extender uut (.*);

  initial begin
    $display("Testing Immediate Extender...");

    // Test I-type (ADDI)
    instr = 32'h00500113;  // ADDI x2, x0, 5
    #10;
    $display("I-type: imm[11:0]=%h -> imm_ext=%h", instr[31:20], imm_ext);

    // Test S-type (SW)
    instr = 32'hFE112E23;  // SW x1, -4(x2)
    #10;

    // Test B-type (BEQ)
    instr = 32'h00208463;  // BEQ x1, x2, +8
    #10;

    // Test U-type (LUI)
    instr = 32'h12345137;  // LUI x2, 0x12345
    #10;

    // Test J-type (JAL)
    instr = 32'h004000EF;  // JAL x1, +4
    #10;

    $finish;
  end

endmodule
