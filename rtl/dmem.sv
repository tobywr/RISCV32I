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
    input logic write_ena,
    input logic [ADDR_WIDTH-1:0] write_addr,
    input logic [DATA_WIDTH-1:0] write_data,
    output logic [DATA_WIDTH-1:0] read_data
);
    logic [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];


always_comb begin
        if (write_addr < (MEM_WORDS * 4)) begin
            read_data = mem[write_addr[MEM_ADDR_BITS+1 :2]];
        end else begin
            read_data = '0;
        end
    end

    always_ff @(posedge clk) begin
        if (write_ena && (write_addr < (MEM_WORDS * 4))) begin
            mem[write_addr[MEM_ADDR_BITS+1 :2]] <= write_data;
        end
    end
endmodule