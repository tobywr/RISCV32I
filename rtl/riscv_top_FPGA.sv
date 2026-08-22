module riscv_top_fpga #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
) (
    input  logic clk,
    input  logic rst_n,
    output logic tx_out
);

  axi_top_level_slave_uart #(
  .CLK_FREQ(CLK_FREQ),
  .BAUD_RATE(BAUD_RATE)
  ) axi_top_level_slave_uart_0 (
      .clk  (clk),
      .rst_n(rst_n),
      .tx_o (tx_out)
  );

endmodule
