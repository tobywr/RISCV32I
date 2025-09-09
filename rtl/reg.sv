/*
-----------------------------------------
| Register Module for RISC-V Single Core|
|        Designed by Toby Wright        |
|            github.com/tobywr          |
|                V1.0.0                 |
-----------------------------------------
*/

import riscv_pkg::*;

module register (
    input logic                     clk,
    input logic                     rst_n,
    input logic [REG_ADDR_BITS-1:0] addr_read1,
    input logic [REG_ADDR_BITS-1:0] addr_read2,
    input logic [REG_ADDR_BITS-1:0] addr_write,
    input logic [   DATA_WIDTH-1:0] write_data,
    input logic                     write_enable,

    output logic [DATA_WIDTH-1:0] read_data1,
    output logic [DATA_WIDTH-1:0] read_data2
);
  logic [DATA_WIDTH-1:0] register[0:REG_FILE_SIZE-1];  //creating registers

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      //reset all registers to 0 when reset is true
      for (int i = 0; i < REG_FILE_SIZE; i = i + 1) begin
        register[i] <= '0;
      end
    end else if (write_enable && addr_write != 0) begin
      register[addr_write] <= write_data;
    end
  end

  // forcing address 0 to read as zero in all registers.
  always_comb begin
    if (addr_read1 == 0) begin
      read_data1 = '0;
    end else begin
      read_data1 = register[addr_read1];
    end

    if (addr_read2 == 0) begin
      read_data2 = '0;
    end else begin
      read_data2 = register[addr_read2];
    end
  end


endmodule
