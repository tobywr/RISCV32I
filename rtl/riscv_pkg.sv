/*
------------------------------------------
| Operation Codes for RISC-V Single Core |
|        Designed by Toby Wright         |
|           github.com/tobywr            |
|               V1.0.0                   |
------------------------------------------
*/

package riscv_pkg;

  //opcodes (inst[6:0])
  parameter OPCODE_LUI = 7'b0110111;
  parameter OPCODE_JAL = 7'b1101111;
  parameter OPCODE_JALR = 7'b1100111;
  parameter OPCODE_BRANCH = 7'b1100011;
  parameter OPCODE_LOAD = 7'b0000011;
  parameter OPCODE_STORE = 7'b0100011;
  parameter OPCODE_IMM = 7'b0010011;
  parameter OPCODE_R_TYPE = 7'b0110011;

  //funct3 codes (inst[14:12])
  parameter FUNCT3_BEQ = 3'b000;  //Funct3 code for BANCH instructions
  parameter FUNCT3_LW = 3'b010;  //Funct3 code for LOAD instructions
  parameter FUNCT3_SW = 3'b010;  //Funct3 code for STORE instructions
  parameter FUNCT3_ADDI = 3'b000;  //Funct3 code for IMM (I-Type) instructions
  parameter FUNCT3_ADD_SUB = 3'b000;  //Funct3 code for R-Type instructions
  parameter FUNCT3_AND = 3'b111;  //Funct3 code for R-Type instructions

  //funct7 codes for R_TYPE instructions (inst[31:25])
  parameter FUNCT7_ADD = 7'b0000000;
  parameter FUNCT7_SUB = 7'b0100000;
  parameter FUNCT7_AND = 7'b0000000;

  //Defining ALU internal control signals.
  typedef enum logic [2:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_AND,
    ALU_PASS
  } alu_op_t;

  //Global useful parameter definitions

  parameter ADDR_WIDTH = 32; //32-bit address space
  parameter DATA_WIDTH = 32; //32-bit data width
  parameter MEM_SIZE_KB = 1; //1kb memory
  parameter REG_FILE_SIZE = 32; //32 registers
  parameter OPCODE_WIDTH = 7;

  parameter MEM_BYTES = MEM_SIZE_KB * 1024; //no. bytes in memmory
  parameter MEM_WORDS = MEM_BYTES / 4; // 4 bytes in word in risc-v
  parameter MEM_ADDR_BITS = $clog2(MEM_WORDS); //round up log_2 value of mem_words (no. bits to represent bytes.)
  parameter REG_ADDR_BITS = $clog2(REG_FILE_SIZE); 

endpackage
