`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.01.2026 12:48:24
// Design Name: 
// Module Name: tb_uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_uart_rx;

    // --------------------------------
    // Parameters
    // --------------------------------
    localparam SYS_CLK_FREQ = 20000;
    localparam BAUD_RATE    = 9600;
    localparam CLK_PERIOD   = 50000; // 50 MHz
    localparam BAUD_PERIOD  = 1_000_000_000 / BAUD_RATE; // ns

    // --------------------------------
    // DUT Signals
    // --------------------------------
    reg        sys_clk;
    reg        reset;
    reg        uart_rx;
    wire       baud_tick;
    wire [7:0] rx_data;
    wire       rx_valid;
    wire       framing_error;

    // --------------------------------
    // Clock Generation
    // --------------------------------
    always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

    // --------------------------------
    // Instantiate Baud Generator
    // --------------------------------
    baud_gen #(
        .SYS_CLK_FREQ(SYS_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_baud (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // --------------------------------
    // Instantiate UART RX
    // --------------------------------
    uart_rx #(
        .SYS_CLK_FREQ(SYS_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .uart_rx(uart_rx),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .framing_error(framing_error)
    );

    // --------------------------------
    // UART Transmit Task (TB-side)
    // --------------------------------
    task send_uart_byte;
        input [7:0] data;
        input       bad_stop;
        integer i;
        begin
            // Start bit
            uart_rx = 1'b0;
            #(BAUD_PERIOD);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(BAUD_PERIOD);
            end

            // Stop bit
            uart_rx = bad_stop ? 1'b0 : 1'b1;
            #(BAUD_PERIOD);

            // Idle
            uart_rx = 1'b1;
            #(BAUD_PERIOD);
        end
    endtask

    // --------------------------------
    // Test Sequence
    // --------------------------------
    initial begin
        sys_clk = 0;
        uart_rx = 1'b1;
        reset   = 1'b1;

        #(10 * CLK_PERIOD);
        reset = 0;

        // -----------------------------
        // Test 1: Valid Frame
        // -----------------------------
        $monitor("Sending valid byte 0x55");
        send_uart_byte(8'h55, 0);

        wait (rx_valid);
        if (rx_data == 8'h55 && !framing_error)
            $monitor("PASS: Correct data received");
        else
            $monitor("FAIL: Incorrect data");

        // -----------------------------
        // Test 2: Framing Error
        // -----------------------------
        $monitor("Sending byte with bad stop bit");
        send_uart_byte(8'hA3, 1);

        wait (rx_valid || framing_error);
        if (framing_error)
            $monitor("PASS: Framing error detected");
        else
            $monitor("FAIL: Framing error missed");

        // -----------------------------
        // Finish
        // -----------------------------
        #(10 * BAUD_PERIOD);
        $finish;
    end

endmodule

