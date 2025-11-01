import riscv_pkg::*;

module riscv_fpga_top (
    input  logic clk,    // Board clock input
    input  logic rst_n,  // Reset button (active low)
    input  logic btn1,   // Button 1 - increment counter
    output logic led2,
    output logic led1
);

  // reset synch
  logic rst_n_sync_ff1;
  logic rst_n_sync;

  always_ff @(posedge clk) begin
    rst_n_sync_ff1 <= rst_n;
    rst_n_sync     <= rst_n_sync_ff1;
  end

  // Synchronize button input (prevent metastability)
  logic [1:0] btn1_sync;

  always_ff @(posedge clk or negedge rst_n_sync) begin
    if (!rst_n_sync) begin
      btn1_sync <= 2'b00;
    end else begin
      btn1_sync <= {btn1_sync[0], btn1};
    end
  end

  // GPIO registers (memory-mapped I/O)
  logic [31:0] gpio_in;
  logic [31:0] gpio_out;
  logic gpio_write;
  logic gpio_read;

  // Memory mapped addresses:
  // 0x100 - GPIO_IN  (button)
  // 0x104 - GPIO_OUT (LEDs)

  assign gpio_in = {31'b0, btn1_sync[1]};
  assign led1 = gpio_out[1];
  assign led2 = gpio_out[0];

  // CPU  signals
  logic [31:0] pc_debug;
  logic [31:0] alu_result_debug;
  logic [31:0] instr_debug;
  logic [31:0] mem_addr;
  logic mem_write;
  logic [31:0] mem_write_data;
  logic [31:0] mem_read_data;

  // Detect GPIO accesses
  assign gpio_write = mem_write && (mem_addr == 32'h104);
  assign gpio_read  = (mem_addr == 32'h100);

  // GPIO output register
  always_ff @(posedge clk or negedge rst_n_sync) begin
    if (!rst_n_sync) begin
      gpio_out <= 32'b0;
    end else if (gpio_write) begin
      gpio_out <= mem_write_data;
    end
  end

  // Instantiate CPU core
  riscv_top_core cpu (
      .clk(clk),
      .rst_n(rst_n_sync),
      .gpio_addr(mem_addr),
      .gpio_write(mem_write),
      .gpio_wdata(mem_write_data),
      .gpio_rdata_async(gpio_in),
      .pc_debug(pc_debug),
      .alu_result_debug(alu_result_debug),
      .instr_debug(instr_debug)
  );

endmodule
