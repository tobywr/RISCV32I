import riscv_pkg::*;

module if_id_reg (
    input logic clk,
    input logic rst_n,
    input logic [ADDR_WIDTH-1:0] pc_plus_4,
    input logic [ADDR_WIDTH-1:0] pc,
    input logic [DATA_WIDTH-1:0] instr,
    input logic stall,
    input logic pc_src,
    output logic [ADDR_WIDTH-1:0] pc_plus_4_if_id,
    output logic [ADDR_WIDTH-1:0] pc_if_id,
    output logic [DATA_WIDTH-1:0] instr_if_id
);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n || pc_src) begin
            pc_plus_4_if_id <= '0;
            pc_if_id <= '0;
            instr_if_id <= '0;
        end else if (stall) begin
            pc_plus_4_if_id <= pc_plus_4_if_id;
            pc_if_id <= pc_if_id;
            instr_if_id <= instr_if_id;
        end else begin
            pc_plus_4_if_id <= pc_plus_4;
            pc_if_id <= pc;
            instr_if_id <= instr;
        end
    end

endmodule