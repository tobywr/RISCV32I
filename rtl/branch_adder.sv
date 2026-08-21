import riscv_pkg::*;

module branch_adder (
    input logic [ADDR_WIDTH-1:0] pc,
    input logic [DATA_WIDTH-1:0] imm_extended,
    input logic [DATA_WIDTH-1:0] operand_a_val,
    input logic jump,
    input logic branch,
    input logic jalr,
    input logic zero,
    output logic [ADDR_WIDTH-1:0] branch_target,
    output logic pc_src
);

always_comb begin
    if(jalr) begin
        branch_target = (operand_a_val + imm_extended) & 32'hFFFFFFFE;
    end else begin
        branch_target = pc + imm_extended;
    end
    pc_src = jump | (branch & zero) | jalr;
end

endmodule