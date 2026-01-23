`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.01.2026 17:13:06
// Design Name: 
// Module Name: apb_uart_wrapper
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
module apb_uart_wrapper (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PADDR,
    input  wire [31:0] PWDATA,
    output wire [31:0] PRDATA,
    output wire        PREADY,
    output wire        IRQ,

    // UART pins
    input  wire        uart_rx,
    output wire        uart_tx
);

    /*----------------------------------------------------------
      APB decode
    ----------------------------------------------------------*/
    wire wr_en = PSEL & PENABLE & PWRITE;
    wire rd_en = PSEL & PENABLE & ~PWRITE;
    wire [5:0] addr  = PADDR[5:0];
    wire [31:0] rdata;

    /*----------------------------------------------------------
      UART internal signals
    ----------------------------------------------------------*/
    wire uart_en, tx_en, rx_en;
    wire tx_start;
    wire tx_busy;
    wire rx_valid;
    wire rx_clear;

    wire [7:0] tx_fifo_data;
    wire [7:0] rx_fifo_data;

    wire tx_fifo_empty;
    wire rx_fifo_empty;

    wire tx_fifo_pop;
    wire rx_fifo_pop;

    wire baud_tick;

    /*----------------------------------------------------------
      UART CSR
    ----------------------------------------------------------*/
    uart_csr u_csr (
        .sys_clk(PCLK),
        .reset(~PRESETn),

        .wr_en(wr_en),
        .rd_en(rd_en),
        .addr(addr),
        .wdata(PWDATA),
        .rdata(rdata),

        .uart_en(uart_en),
        .tx_en(tx_en),
        .rx_en(rx_en),
        .tx_start(tx_start),

        .tx_busy(tx_busy),
        .rx_valid(~rx_fifo_empty),

        .rx_clear(rx_clear),

        .rx_fifo_empty(rx_fifo_empty),
        .rx_pop(rx_fifo_pop),

        .irq(IRQ)
    );

    /*----------------------------------------------------------
      TX FIFO
    ----------------------------------------------------------*/
    tx_fifo u_tx_fifo (
        .clk(PCLK),
        .reset(~PRESETn),

        .push(wr_en & (addr == 6'h08) & uart_en & tx_en),
        .push_data(PWDATA[7:0]),

        .pop(tx_fifo_pop),
        .pop_data(tx_fifo_data),

        .full(),
        .empty(tx_fifo_empty)
    );

    /*----------------------------------------------------------
      UART TX
    ----------------------------------------------------------*/
    uart_tx u_tx (
    .sys_clk   (PCLK),
    .reset     (~PRESETn),
    .baud_tick (baud_tick),
    .enable      (uart_en & tx_en),
    .fifo_empty(tx_fifo_empty),
    .fifo_pop  (tx_fifo_pop),
    .fifo_data (tx_fifo_data),

    .uart_tx   (uart_tx),
    .tx_busy   (tx_busy)

    );

    //assign tx_fifo_pop = tx_start & ~tx_fifo_empty;

    /*----------------------------------------------------------
      UART RX
    ----------------------------------------------------------*/
    uart_rx u_rx (
        .sys_clk(PCLK),
        .reset(~PRESETn),
        .baud_tick(baud_tick),

        .uart_rx(uart_tx),
        .rx_clear(rx_clear),

        .rx_data(rx_fifo_data),
        .rx_valid(rx_valid),
        .framing_error()
    );

    /*----------------------------------------------------------
      RX FIFO
    ----------------------------------------------------------*/
    rx_fifo u_rx_fifo (
        .clk(PCLK),
        .reset(~PRESETn),

        .rx_valid(rx_valid & uart_en & rx_en),
        .rx_data(rx_fifo_data),

        .csr_rx_read(rx_fifo_pop),

        .rx_fifo_data(rx_fifo_data),
        .empty(rx_fifo_empty),
        .full()
    );

    /*----------------------------------------------------------
      Baud Generator
    ----------------------------------------------------------*/
    baud_gen #(
        .SYS_CLK_FREQ(200000),
        .BAUD_RATE(9600)
    ) u_baud (
        .sys_clk(PCLK),
        .reset(~PRESETn),
        .baud_tick(baud_tick)
    );

    /*----------------------------------------------------------
      APB outputs
    ----------------------------------------------------------*/
    assign PRDATA = rdata;
    assign PREADY = 1'b1;

endmodule
