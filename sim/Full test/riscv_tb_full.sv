`timescale 1ns / 1ps
import riscv_pkg::*;

module tb_riscv_core ();

    logic clk;
    logic rst_n;

    //instantiate processor

    riscv_top_core dut(
        .clk(clk),
        .rst_n(rst_n),
        .pc_debug(pc_debug),
        .instr_debug(instr_debug),
        .alu_result_debug(alu_result_debug)
    );

    always #5 clk = ~clk;

    //start running clock and do reset.
    initial begin
        clk = 0;
        rst_n = 0;
        #100;
        rst_n = 1;
    end


    //run for only 10000ns
    initial begin
        #10000;
        $display("Finished Simulation");
        $finish;
    end


    //start monitoring results
    always_ff @(posedge clk) begin
        if (rst_n) begin //monitor after reset
            $display("PC = %h, INSTR = %h, ALU_RESULT = %h",
            dut.pc_debug, dut.instr_debug, dut.alu_result_debug);
        end
    end

endmodule


