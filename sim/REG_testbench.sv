/*
----------------------------------------------
| Register Test Bench for RISC-V Single Core |
|         Designed by Toby Wright            |
|             github.com/tobywr              |
|                V1.0.0                      |
----------------------------------------------
*/

`timescale 1ns/1ps
`include "riscv_opcodes.svh"

module REG_testbench();

    logic        clk;
    logic        rst_n;
    logic [4:0]  addr_read1;
    logic [4:0]  addr_read2;
    logic [4:0]  addr_write;
    logic [31:0] write_data;
    logic        write_enable;
    logic [31:0] read_data1;
    logic [31:0] read_data2;

    registers #(
    .DataWidth(32),
    .NumRegs(32),
    .IndexWidth(5)
    ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .addr_read1(addr_read1),
    .addr_read2(addr_read2),
    .addr_write(addr_write),
    .write_data(write_data),
    .write_enable(write_enable),
    .read_data1(read_data1),
    .read_data2(read_data2)
    );

    parameter CLK_PERIOD = 10; //10ns = 100MHz clock
    always #(CLK_PERIOD/2) clk = ~clk; //toggle clock every half period.

    initial begin
    //initialize values, set all to 0
    clk          = 1'b0;
    rst_n        = 1'b0;
    addr_read1   = '0;
    addr_read2   = '0;
    addr_write   = '0;
    write_data   = '0;
    write_enable = 1'b0;
    read_data1   = '0;
    read_data2   = '0;
    end

    #10;

    rst_n = 1'b1; //Setting active low reset to high (now test)
    @(posedge clk);
    //Test 1 : Write to reg 0 - should hardwrite to 0.
    $display("Test 1 : Writing to address 0");
    addr_write = 5'b00000;
    write_data = 32'b1100_0110_1001_1111_1010_1111_0111_0011;
    write_enable = 1'b1;
    @(posedge clk);
    write_enable = 0'b1;

    addr_read1 = 5'b00000;
    #10;
    $display("0x, should read 0 : %b", read_data1);
    $display("");
    
    //Test 2 : Write and read from one addresses.
    $display("Test 2 : Writing and reading from 1 address");
    addr_write = 5'b10110;
    write_data = 32'b1100_0110_1001_1111_1010_1111_0111_0011;
    write_enable = 1'b1;
    @(posedge clk);
    write_enable = 0'b1;

    addr_read1 = 5'b10110;
    #10;
    $display("%b should be equal to : %b", write_data, read_data1);
    $display(""); //making new line (readability)
    
    //Test 3 : Simaltaneous Read / Write

    $display("Test 3 : Simultaneous Read / Write");

    //writing two values to two different addresses
    addr_write = 5'b00101;
    write_data = 32'hAAAA_BBBB;
    write_enable = 1'b1;
    @(posedge clk);
    addr_write = 5'b00111;
    write_data = 32'hCCCC_DDDD;
    write_enable = 1'b1;
    @(posedge clk);

    //read from addresses at same time + write value to another address.

    addr_write = 5'b11111;
    write_data = 32'hEEEE_FFFF;
    write_enable = 1'b1;

    addr_read1 = 5'b00101;
    addr_read2 = 5'b00111;

    @(posedge clk);
    write_enable = 1'b0;

    #1;

    $display("Simaltaneours read during write : R1 = %h, R2 = %h", read_data1, read_data2);
    $display("");

    //Test 4 : Writing to multiple registers then confirming correct.

    for(int i = 1; i < 8; i = i + 1) begin
        addr_write = i;
        write_data = 32'h1000 + i; //unique for each reg.
        write_enable = 1'b1;
        @(posedge clk);
        write_enable = 1'b0;
    end

    //Verify all are correct.

    for(int i = 1; i < 8; i = i + 1) begin
        addr_read1 = i;
        #1;
        if(read_data1 === (32'h1000 + i)) begin
            $display("Pass: register %0d = %h", i, read_data1);
        end else begin
            $display("Fail: register %0d = %h", i, read_data1);
        end
    end

$finish;

endmodule