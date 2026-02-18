`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.01.2026 16:56:27
// Design Name: 
// Module Name: uart_tx
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
module uart_tx (
    input        sys_clk,
    input        reset,
    input        baud_tick,
    input        tx_start,
    input  [7:0] tx_data,
    output reg   uart_tx,
    output reg   tx_busy,
    
    input  fifo_empty,
    output reg  fifo_pop,
    input  [7:0] fifo_data

);

    // FSM states
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    reg [1:0] state, next_state;
    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;

    // -------------------------
    // State register
    // -------------------------
    always @(posedge sys_clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // -------------------------
    // Next-state logic
    // -------------------------
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:  if (tx_start) next_state = START;
            START: if (baud_tick) next_state = DATA;
            DATA:  if (baud_tick && bit_cnt == 3'd7) next_state = STOP;
            STOP:  if (baud_tick) next_state = IDLE;
        endcase
    end

    // -------------------------
    // Output & data path logic
    // -------------------------
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            uart_tx   <= 1'b1;
            tx_busy   <= 1'b0;
            shift_reg <= 8'd0;
            bit_cnt   <= 3'd0;
        end else begin
            case (state)

                IDLE: begin
                    uart_tx <= 1'b1;
                    tx_busy <= 1'b0;
                    bit_cnt <= 3'd0;
                    fifo_pop <= 1'b0;
                    if (tx_start && !tx_busy) begin
                        shift_reg <= tx_data;
                        tx_busy   <= 1'b1;
                    end
                    
                    if (!fifo_empty) begin
                        fifo_pop <= 1'b1;          // POP ONE BYTE
                        shift_reg <= fifo_data;    // LOAD DATA
                        tx_busy <= 1'b1;
                        next_state = START;
                    end

                end

                START: begin
                    uart_tx <= 1'b0;   // HOLD start bit
                    tx_busy <= 1'b1;
                end

                DATA: begin
                    uart_tx <= shift_reg[0];  // HOLD data bit
                    tx_busy <= 1'b1;
                    if (baud_tick) begin
                        shift_reg <= shift_reg >> 1;
                        bit_cnt   <= bit_cnt + 1'b1;
                    end
                end

                STOP: begin
                    uart_tx <= 1'b1;   // HOLD stop bit
                    tx_busy <= 1'b1;
                end

            endcase
        end
    end

endmodule

