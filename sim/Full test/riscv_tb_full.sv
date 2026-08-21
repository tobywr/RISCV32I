`timescale 1ns / 1ps
import riscv_pkg::*;

module tb_riscv_core ();

    localparam CLK_FREQ  = 100_000_000;  // matches #5 clk toggle -> 10ns period -> 100MHz
    localparam BAUD_RATE = 115200;

    // matches uart_tx's own localparam BAUD_TICK = CLK_FREQ/BAUD_RATE (integer division),
    // so this stays bit-exact with whatever the DUT actually realizes.
    localparam integer BIT_PERIOD_NS = (CLK_FREQ / BAUD_RATE) * 10;

    // "Hello, World\n"
    localparam int MSG_LEN = 13;
    logic [7:0] EXPECTED_MSG [0:MSG_LEN-1];

    logic clk;
    logic rst_n;
    logic tx_o;

    //instantiate the full SoC: core + AXI4-Lite master + UART slave
    axi_top_level_slave_uart #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk  (clk),
        .rst_n(rst_n),
        .tx_o (tx_o)
    );

    always #5 clk = ~clk;

    //start running clock and do reset.
    initial begin
        clk   = 0;
        rst_n = 0;
        #100;
        rst_n = 1;
    end

    //////////////////////////////////////////////////////////////
    // Watchdog - if the AXI write or UART transmission hangs,   //
    // don't let the simulation run forever. Generous margin for //
    // MSG_LEN bytes at ~87us/byte.                              //
    //////////////////////////////////////////////////////////////
    initial begin
        #3_000_000;
        $display("---------------------------------------------");
        $display("[FAIL] TIMEOUT: message did not finish transmitting");
        $display("---------------------------------------------");
        $finish;
    end

    //////////////////////////////////////////////////////////////
    // Bit-bang UART receiver task - decodes one 8-N-1 frame off //
    // tx_o the same way a real UART receiver would.             //
    //////////////////////////////////////////////////////////////
    task automatic uart_rx_byte(output logic [7:0] rx_byte, output logic frame_ok);
        rx_byte  = 8'h00;
        frame_ok = 1'b1;

        // idle line is high; wait for the falling edge that starts the frame
        @(negedge tx_o);

        // sample at the centre of each bit period: start bit first
        #(BIT_PERIOD_NS / 2);
        if (tx_o !== 1'b0) frame_ok = 1'b0;

        // 8 data bits, LSB first (matches uart_tx's shift order)
        for (int i = 0; i < 8; i++) begin
            #(BIT_PERIOD_NS);
            rx_byte[i] = tx_o;
        end

        // stop bit
        #(BIT_PERIOD_NS);
        if (tx_o !== 1'b1) frame_ok = 1'b0;
    endtask

    //////////////////////////////////////////////////////////////
    // Scoreboard: receive the whole "Hello, World\n" message    //
    // byte by byte off tx_o, printing each one as it lands and  //
    // the full string at the end.                               //
    //////////////////////////////////////////////////////////////

    int errors;
    logic [7:0] rx_byte;
    logic frame_ok;
    string received_str;

    initial begin
        EXPECTED_MSG[0]  = "H";
        EXPECTED_MSG[1]  = "e";
        EXPECTED_MSG[2]  = "l";
        EXPECTED_MSG[3]  = "l";
        EXPECTED_MSG[4]  = "o";
        EXPECTED_MSG[5]  = ",";
        EXPECTED_MSG[6]  = " ";
        EXPECTED_MSG[7]  = "W";
        EXPECTED_MSG[8]  = "o";
        EXPECTED_MSG[9]  = "r";
        EXPECTED_MSG[10] = "l";
        EXPECTED_MSG[11] = "d";
        EXPECTED_MSG[12] = "\n";

        errors       = 0;
        received_str = "";

        @(posedge rst_n);

        $display("---------------------------------------------");
        $display(" RISCV32I + AXI4-Lite + UART TX scoreboard");
        $display("---------------------------------------------");

        for (int idx = 0; idx < MSG_LEN; idx++) begin
            uart_rx_byte(rx_byte, frame_ok);
            received_str = {received_str, string'(rx_byte)};

            if (!frame_ok) begin
                $display("[FAIL] byte %0d: bad start/stop bit framing (got 0x%02h)", idx, rx_byte);
                errors++;
            end else if (rx_byte !== EXPECTED_MSG[idx]) begin
                $display("[FAIL] byte %0d: 0x%02h ('%c'), expected 0x%02h ('%c')",
                         idx, rx_byte, rx_byte, EXPECTED_MSG[idx], EXPECTED_MSG[idx]);
                errors++;
            end else begin
                $display("[PASS] byte %0d: 0x%02h ('%c')", idx, rx_byte, rx_byte);
            end
        end

        $display("---------------------------------------------");
        $display(" received string: \"%s\"", received_str);
        $display("---------------------------------------------");

        if (errors == 0) begin
            $display(" ALL CHECKS PASSED");
        end else begin
            $display(" %0d CHECK(S) FAILED", errors);
        end
        $display("---------------------------------------------");

        $finish;
    end

endmodule
