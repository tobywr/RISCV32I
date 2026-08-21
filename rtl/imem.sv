/*
---------------------------------------------
| Instruction Memory for RISC-V Single Core |
|          Designed by Toby Wright          |
|              github.com/tobywr            |
|                  V1.0.0                   |
---------------------------------------------
*/

import riscv_pkg::*;

`timescale 1ns / 1ps

module imem (
    input  logic [31:0] addr,  //Word alligned values (Divisable by 4)
    output logic [31:0] instr  //instruction at that address
);

  // 1KB instruction memory (256 instructions)
  logic [31:0] mem[0:255];

  //initialize memory with program from hex file

  initial begin
    $readmemh("C:/Users/toby/Desktop/CV_PROJECTS/RISCV32I/rtl/program.hex", mem);  //CHANGE TO YOUR PATH !!!!!!!
  end

  assign instr = mem[addr[9:2]];  // 1024/4 = 256 words. Need 8 bits to address 256 words.

endmodule
