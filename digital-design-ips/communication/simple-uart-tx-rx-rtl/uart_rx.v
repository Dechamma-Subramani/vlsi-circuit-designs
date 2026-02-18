`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.01.2026 10:31:02
// Design Name: 
// Module Name: uart_rx
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
module uart_rx #(
    parameter SYS_CLK_FREQ = 50000000,
    parameter BAUD_RATE    = 115200
)(
    input  sys_clk,
    input  reset,
    input  baud_tick,
    input  uart_rx,
    input  rx_clear,

    output reg  [7:0]  rx_data,
    output reg         rx_valid,
    output reg         framing_error
    
);

    /*----------------------------------------------------------
      Synchronizer (2 FF)
    ----------------------------------------------------------*/
    reg rx_ff1, rx_ff2;

    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            rx_ff1 <= 1'b1;
            rx_ff2 <= 1'b1;
        end else begin
            rx_ff1 <= uart_rx;
            rx_ff2 <= rx_ff1;
        end
    end

    wire rx_sync = rx_ff2;

    /*----------------------------------------------------------
      Baud parameters (local copy for half-bit)
    ----------------------------------------------------------*/
    localparam integer BAUD_DIV = SYS_CLK_FREQ / BAUD_RATE;
    localparam integer HALF_DIV = BAUD_DIV / 2;

    reg [$clog2(BAUD_DIV)-1:0] half_cnt;
    wire half_done = (half_cnt == HALF_DIV-1);

    /*----------------------------------------------------------
      FSM Declaration
    ----------------------------------------------------------*/
    localparam [2:0]
        IDLE  = 3'd0,
        START = 3'd1,
        DATA  = 3'd2,
        STOP  = 3'd3,
        DONE  = 3'd4;

    reg [2:0] state, next_state;

    /*----------------------------------------------------------
      State Register
    ----------------------------------------------------------*/
    always @(posedge sys_clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    /*----------------------------------------------------------
      Next-State Logic
    ----------------------------------------------------------*/
    always @(*) begin
        next_state = state;
        case (state)

            IDLE:
                if (rx_sync == 1'b0)
                    next_state = START;

            START:
                if (half_done)
                    next_state = (rx_sync == 1'b0) ? DATA : IDLE;

            DATA:
                if (baud_tick && bit_cnt == 3'd7)
                    next_state = STOP;

            STOP:
                if (baud_tick)
                    next_state = DONE;

            DONE:
                next_state = IDLE;

            default:
                next_state = IDLE;
        endcase
    end

    /*----------------------------------------------------------
      Data Path
    ----------------------------------------------------------*/
    reg [7:0] rx_shift;
    reg [2:0] bit_cnt;

    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            rx_shift      <= 8'd0;
            rx_data       <= 8'd0;
            rx_valid      <= 1'b0;
            framing_error <= 1'b0;
            bit_cnt       <= 3'd0;
            half_cnt      <= 0;
        end else begin
            rx_valid <= 1'b0; // default (1-cycle pulse)

            case (state)

                IDLE: begin
                    bit_cnt       <= 3'd0;
                    half_cnt      <= 0;
                    framing_error <= 1'b0;
                end

                START: begin
                    half_cnt <= half_cnt + 1'b1;
                end

                DATA: begin
                    if (baud_tick) begin
                        rx_shift <= {rx_sync, rx_shift[7:1]}; // LSB first
                        bit_cnt  <= bit_cnt + 1'b1;
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        if (rx_sync == 1'b1)
                            rx_data <= rx_shift;
                        else
                            framing_error <= 1'b1;
                    end
                end

                DONE: begin
                    rx_valid <= ~framing_error;
                end

            endcase
        end
    end

endmodule

