`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.01.2026 17:13:51
// Design Name: 
// Module Name: tb_uart_apb
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


module tb_apb_uart;

    reg PCLK;
    reg PRESETn;
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PADDR;
    reg [31:0] PWDATA;

    wire [31:0] PRDATA;
    wire PREADY;
    wire IRQ;

    reg  uart_rx;
    wire uart_tx;

    // DUT
    apb_uart_wrapper dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .IRQ(IRQ),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // Clock
    always #5 PCLK = ~PCLK;
    reg [31:0] read_data;

    // APB write (CORRECT)
    task apb_write(input [31:0] addr, input [31:0] data);
    begin
        @(posedge PCLK);
        PSEL    <= 1;
        PENABLE <= 0;
        PWRITE  <= 1;
        PADDR   <= addr;
        PWDATA  <= data;

        @(posedge PCLK);
        PENABLE <= 1;

        @(posedge PCLK);
        PSEL    <= 0;
        PENABLE <= 0;
        PWRITE  <= 0;
    end
    endtask

    //APB READ
    task apb_read(
            input  [31:0] addr,
            output [31:0] data
        );
        begin
            // SETUP
            @(posedge PCLK);
            PSEL    <= 1;
            PENABLE <= 0;
            PWRITE  <= 0;
            PADDR   <= addr;

            // ENABLE
            @(posedge PCLK);
            PENABLE <= 1;

            // SAMPLE DATA
            @(posedge PCLK);
            data = PRDATA;

            // COMPLETE
            PENABLE <= 0;
        end
    endtask


    initial begin
        $dumpfile("UART.vcd");
        $dumpvars(0, tb_apb_uart);  // dump whole testbench hierarchy

        // init
        PCLK = 0;
        PRESETn = 0;
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        PADDR = 0;
        PWDATA = 0;
        uart_rx = 1'b1;

        // reset
        repeat(5) @(posedge PCLK);
        PRESETn = 1;

        $display("UART Enabled");
        apb_write(32'h00, 32'b0000_0111); // uart_en, tx_en, rx_en
        #10;
        $display("Write TXDATA");
        apb_write(32'h08, 32'h000000A5);

        // wait LONG ENOUGH
        repeat(500) @(posedge PCLK);
        apb_read(32'h0C, read_data);
        $display("Simulation finished");
        repeat (1000000) @(posedge PCLK);
        PSEL    <= 1;
        $finish;
    end
    
    // MONITOR (clock-aligned)
    always @(posedge PCLK) begin
    $display("t=%0t Received Data=%b ",
              $time,
              read_data);
    end


endmodule

