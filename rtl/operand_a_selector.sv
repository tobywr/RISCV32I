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
    input logic [ADDR_WIDTH-1:0] pc,
    input logic [DATA_WIDTH-1:0] operand_a_val,
    input logic [OPCODE_WIDTH-1:0] opcode,
    output logic [DATA_WIDTH-1:0] operand_a
);

    always_comb begin
        case(opcode)
            OPCODE_JAL: operand_a = pc;
            OPCODE_LUI: operand_a = 32'b0;
            OPCODE_JALR: operand_a = operand_a_val;
            default: operand_a = operand_a_val;
        endcase
    end
endmodule