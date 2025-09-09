/*
-------------------------------------------
| Operand A Module for RISC-V Single Core |
|        Designed by Toby Wright          |
|           github.com/tobywr             |
|               V1.0.0                    |
-------------------------------------------
*/

import riscv_pkg::*;


module operand_a_selector(
    input logic [31:0] pc,
    input logic [31:0] read_data1,
    input logic [6:0] opcode,
    output logic [31:0] operand_a
);

    always_comb begin
        case(opcode)
            OPCODE_JAL: operand_a = pc;
            OPCODE_LUI: operand_a = 32'b0;
            OPCODE_JALR: operand_a = read_data1;
            default: operand_a = read_data1;
        endcase
    end
endmodule