/*
-----------------------------------------
| ALU Test-Bench for RISC-V Single Core |
|       Designed by Toby Wright         |
|           github.com/tobywr           |
|              V1.0.0                   |
-----------------------------------------
*/


`timescale 1ns / 1ps
import riscv_pkg::*;

module test_bench_ALU ();
  logic [31:0] operand_a;
  logic [31:0] operand_b;
  alu_op_t alu_op;
  logic [31:0] alu_result;
  logic zero;


  //instantiating ALU module
  alu uut (
      .operand_a (operand_a),
      .operand_b (operand_b),
      .alu_op    (alu_op),
      .alu_result(alu_result),
      .zero      (zero)
  );

  initial begin
    //initialize values, set all to 0.
    operand_a = 32'b0;
    operand_b = 32'b0;
    alu_op = ALU_ADD;
    zero = 1'b0;T for 
    alu_result = 32'b0;
    #10
    $display("Test 1 : Addition");
    alu_op = ALU_ADD;
    operand_a = 32'd10;
    operand_b = 32'd15;
    #10 $display("Result : %d + %d = %d", operand_a, operand_b, alu_result);
    $display("");

    $display("Test 2 : Subtraction");
    alu_op = ALU_SUB;
    operand_a = 32'd15;
    operand_b = 32'd5;
    #10 $display("Result : %d - %d = %d", operand_a, operand_b, alu_result);
    $display("");

    $display("Test 3 : Subtraction for Zero flag");
    alu_op = ALU_SUB;
    operand_a = 32'd30;
    operand_b = 32'd30;
    #10 $display("Result : %d - %d = %d , zero = %d", operand_a, operand_b, alu_result, zero);
    $display("");

    $display("Test 4 : Bitwise AND");
    alu_op = ALU_AND;
    operand_a = 32'b1100_0110_1001_1111_1010_1111_0111_0011;
    operand_b = 32'b0000_0000_0000_0000_1111_1111_1111_1111;
    #10 $display("Result : %b & %b = %b", operand_a, operand_b, alu_result);
    $display("");

    $display("Test 5 : Pass through");
    alu_op = ALU_PASS;
    operand_a = 32'b1100_0110_1001_1111_1010_1111_0111_0011;
    operand_b = 32'b0000_0000_0000_0000_1111_1111_1111_1111;  //should be passed
    #10 $display("Result : %b , Should be : %b", alu_result, operand_b);
    $display("");

    $display("Test bench finished");
    #10 $finish;
  end
endmodule
