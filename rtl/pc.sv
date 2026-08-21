/*
-----------------------------------------
| Program Counter for RISC-V Single Core|
|        Designed by Toby Wright        |
|            github.com/tobywr          |
|                V1.0.1                 |
-----------------------------------------
*/

import riscv_pkg::*;

module program_counter (
    input logic clk,
    input logic rst_n,
    input logic stall,
    input logic [ADDR_WIDTH-1:0] pc_plus_4,
    input logic pc_src,
    input logic [ADDR_WIDTH-1:0] branch_target,
    output logic [ADDR_WIDTH-1:0] pc
);

  logic [ADDR_WIDTH-1:0] pc_next;


  always_comb begin
    if(stall) begin
      pc_next = pc;
    end else if (pc_src) begin
      pc_next = branch_target;
    end else begin
      pc_next = pc_plus_4;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc <= 32'h00000000;  //start at address 0 on reset.
    end else begin
      pc <= pc_next;  //Update PC (registerd)
    end
  end
endmodule
