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
    output logic [DATA_WIDTH-1:0] rd_o,
    input logic [DATA_WIDTH-1:0] gpio_rdata
);
    logic [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];
    logic is_gpio_addr;
    // address is in GPIO range (0x100 - 0x1FF)
    assign is_gpio_addr = (addr_i >= 32'h100) && (addr_i < 32'h200);

always_comb begin
        if (is_gpio_addr) begin
            // Priority 1: Handle GPIO reads
            rd_o = gpio_rdata; 
        end else if (addr_i < (MEM_WORDS * 4)) begin
            // Priority 2: Handle valid RAM reads
            rd_o = mem[addr_i[MEM_ADDR_BITS+1 :2]];
        end else begin
            // Priority 3: All other addresses read '0'
            rd_o = '0;
        end
    end

    always_ff @(posedge clk) begin
        if (we_i && !is_gpio_addr && (addr_i < (MEM_WORDS * 4))) begin
            mem[addr_i[MEM_ADDR_BITS+1 :2]] <= wd_i;
        end
    end
endmodule