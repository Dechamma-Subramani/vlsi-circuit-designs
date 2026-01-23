`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.01.2026 12:10:23
// Design Name: 
// Module Name: tb_uart_tx
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


module tb_uart_tx;

    // ------------------------------
    // Parameters
    // ------------------------------
    localparam SYS_CLK_FREQ = 50_000_000;
    localparam BAUD_RATE    = 115200;
    localparam CLK_PERIOD   = 20; // 50 MHz
    localparam BAUD_PERIOD  = 1_000_000_000 / BAUD_RATE; // ns

    // ------------------------------
    // Signals
    // ------------------------------
    reg        sys_clk;
    reg        reset;
    wire       baud_tick;
    reg        tx_start;
    reg [7:0]  tx_data;
    wire       uart_tx;
    wire       tx_busy;

    // ------------------------------
    // Clock generation
    // ------------------------------
    initial sys_clk = 0;
    always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

    // ------------------------------
    // Baud generator instance
    // ------------------------------
    baud_gen #(
        .SYS_CLK_FREQ(SYS_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_baud (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // ------------------------------
    // UART TX instance
    // ------------------------------
    uart_tx u_tx (
        .sys_clk(sys_clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .uart_tx(uart_tx),
        .tx_busy(tx_busy)
    );

    // ------------------------------
    // UART capture task
    // ------------------------------
    task capture_uart_byte;
        output [7:0] data;
        integer i;
        begin
            data = 8'd0;
            // Wait for start bit
            wait(uart_tx == 1'b0);
            // Half-bit delay
            #(1_000_000_000 / BAUD_RATE / 2);
            // Sample data bits
            for (i = 0; i < 8; i = i + 1) begin
                #(1_000_000_000 / BAUD_RATE);
                data[i] = uart_tx;
            end
            // Stop bit
            #(1_000_000_000 / BAUD_RATE);
            if (uart_tx !== 1'b1)
                $fatal("STOP BIT ERROR");
        end
    endtask

    // ------------------------------
    // Test sequence
    // ------------------------------
    reg [7:0] received;

    initial begin
        reset    = 1;
        tx_start = 0;
        tx_data  = 8'h00;

        #(10*CLK_PERIOD);
        reset = 0;

        // Test 1
        $display("TX Test: Send 0xA5");
        tx_data = 8'hA5;
        @(posedge sys_clk); tx_start = 1;
        @(posedge sys_clk); tx_start = 0;
        capture_uart_byte(received);
        if (received !== 8'hA5)
            $fatal("FAIL: Expected A5, got %h", received);
        else
            $display("PASS: 0xA5");

        // Wait until TX is idle
        wait (!tx_busy);

        // Test 2
        $display("TX Test: Send 0x55");
        tx_data = 8'h55;
        @(posedge sys_clk); tx_start = 1;
        @(posedge sys_clk); tx_start = 0;
        capture_uart_byte(received);
        if (received !== 8'h55)
            $fatal("FAIL: Expected 55, got %h", received);
        else
            $display("PASS: 0x55");

        $display("=================================");
        $display(" UART TX ALL TESTS PASSED ");
        $display("=================================");
        $finish;
    end

endmodule

