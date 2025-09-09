/*
-----------------------------------------
|   Data Memory for RISC-V Single Core  |
|       Designed by Toby Wright         |
|           github.com/tobywr           |
|                V1.0.0                 |
-----------------------------------------
*/

import riscv_pkg::*;

module dmem (
    input logic clk,
    input logic we_i,
    input logic [ADDR_WIDTH-1:0] addr_i,
    input logic [DATA_WIDTH-1:0] wd_i,
    output logic [DATA_WIDTH-1:0] rd_o
);
    logic [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];

    always_comb begin
        if (addr_i < (MEM_WORDS * 4)) begin
            rd_o = mem[addr_i[MEM_ADDR_BITS+1 :2]];
        end else begin
            rd_o = '0;
        end
    end

    always_ff @(posedge clk) begin
        if (we_i && (addr_i < (MEM_WORDS * 4))) begin
            mem[addr_i[MEM_ADDR_BITS+1 :2]] <= wd_i;
        end
    end
endmodule