import riscv_pkg::*;

module operand_b_selector (
    input logic alu_src,
    input logic [DATA_WIDTH-1:0] imm_extended,
    input logic [DATA_WIDTH-1:0] operand_b_val,
    output logic [DATA_WIDTH-1:0] operand_b
);

    assign operand_b = alu_src ? imm_extended : operand_b_val;
    
endmodule