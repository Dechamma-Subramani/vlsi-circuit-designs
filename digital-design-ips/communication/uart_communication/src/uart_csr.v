`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.01.2026 10:51:32
// Design Name: 
// Module Name: uart_csr
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
module uart_csr (
    input  wire        sys_clk,
    input  wire        reset,

    input  wire        wr_en,
    input  wire        rd_en,
    input  wire [5:0]  addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,

    output reg         uart_en,
    output reg         tx_en,
    output reg         rx_en,
    output reg         tx_start,

    input  wire        tx_busy,
    input  wire        rx_valid,

    output reg         rx_clear,

    input  wire        rx_fifo_empty,
    output reg         rx_pop,

    output wire        irq
);

    reg rx_int_en, tx_int_en;
    reg rx_int_pending, tx_int_pending;

    reg tx_busy_d;
    always @(posedge sys_clk or posedge reset)
        if (reset) tx_busy_d <= 0;
        else       tx_busy_d <= tx_busy;

    wire tx_done = tx_busy_d & ~tx_busy;

    // ---------------- WRITE ----------------
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            uart_en  <= 0;
            tx_en    <= 0;
            rx_en    <= 0;
            tx_start <= 0;
            rx_clear <= 0;
        end else begin
            tx_start <= 0;
            rx_clear <= 0;

            if (wr_en) begin
                case (addr)
                    6'h00: begin
                        uart_en <= wdata[0];
                        tx_en   <= wdata[1];
                        rx_en   <= wdata[2];
                        if (wdata[3]) rx_clear <= 1;
                    end
                    6'h08: begin
                        if (uart_en && tx_en && !tx_busy)
                            tx_start <= 1; // pulse
                    end
                    default: rx_clear <= 0;
                endcase
            end
        end
    end

    // ---------------- READ ----------------
    always @(*) begin
        rdata = 0;
        if (rd_en) begin
            case (addr)
                6'h00: rdata = {29'b0, rx_en, tx_en, uart_en};
                6'h04: rdata = {30'b0, ~rx_fifo_empty, tx_busy};
                6'h10: rdata = {30'b0, tx_int_en, rx_int_en};
                6'h14: rdata = {30'b0, tx_int_pending, rx_int_pending};
                default: rdata = 32'b0;
            endcase
        end
    end

    // RX FIFO pop
    always @(posedge sys_clk or posedge reset) begin
        if (reset) rx_pop <= 0;
        else begin
            rx_pop <= 0;
            if (rd_en && addr == 6'h0C && !rx_fifo_empty)
                rx_pop <= 1;
        end
    end

    // Interrupts
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            rx_int_pending <= 0;
            tx_int_pending <= 0;
        end else begin
            if (!rx_fifo_empty) rx_int_pending <= 1;
            if (tx_done)        tx_int_pending <= 1;
            if (wr_en && addr == 6'h14) begin
                if (wdata[0]) rx_int_pending <= 0;
                if (wdata[1]) tx_int_pending <= 0;
            end
        end
    end

    always @(posedge sys_clk or posedge reset)
        if (reset) begin
            rx_int_en <= 0;
            tx_int_en <= 0;
        end else if (wr_en && addr == 6'h10) begin
            rx_int_en <= wdata[0];
            tx_int_en <= wdata[1];
        end

    assign irq = (rx_int_en & rx_int_pending) |
                 (tx_int_en & tx_int_pending);

endmodule

