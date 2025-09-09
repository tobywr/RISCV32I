/*
-----------------------------------------
| Program Counter for RISC-V Single Core|
|        Designed by Toby Wright        |
|            github.com/tobywr          |
|                V1.0.0                 |
-----------------------------------------
*/

module program_counter (
    input logic clk,
    input logic rst_n,
    input logic branch,
    input logic jump,
    input logic jalr,
    input logic zero,
    input logic [31:0] imm_extended,
    input logic [31:0] read_data1,
    output logic [31:0] pc
);

  logic [31:0] pc_next;

  always_comb begin
    if (jalr) begin
      pc_next = (read_data1 + imm_extended) & 32'hFFFFFFFE;
    end else if (jump) begin
      pc_next = pc + imm_extended;
    end else if (branch & zero) begin
      pc_next = pc + imm_extended;
    end else begin
      pc_next = pc + 32'd4;
    end

  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc <= 32'h00000000;  //start at address 0 on reset.
    end else begin
      pc <= pc_next;  //Update PC on clk edge.
    end
  end
endmodule
