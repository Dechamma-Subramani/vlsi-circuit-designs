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
    input        enable,
    input        fifo_empty,
    output reg   fifo_pop,
    input  [7:0] fifo_data,

    output reg   uart_tx,
    output reg   tx_busy
);

    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    reg [1:0] state, next_state;
    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;

    // State register
    always @(posedge sys_clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:  if (!fifo_empty) next_state = START;
            START: if (baud_tick)   next_state = DATA;
            DATA:  if (baud_tick && bit_cnt == 3'd7) next_state = STOP;
            STOP:  if (baud_tick)   next_state = IDLE;
        endcase
    end

    // Output & datapath
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            uart_tx   <= 1'b1;
            tx_busy   <= 1'b0;
            fifo_pop  <= 1'b0;
            shift_reg <= 8'd0;
            bit_cnt   <= 3'd0;
        end else begin
            fifo_pop <= 1'b0; // default
            
            case (state)
                IDLE: begin
                    uart_tx <= 1'b1;
                    tx_busy <= 1'b0;
                    bit_cnt <= 3'd0;

                    if (!fifo_empty) begin
                        fifo_pop <= 1'b1; // request FIFO data
                    end
                    if (state == IDLE && enable && !fifo_empty) begin
                        fifo_pop <= 1'b1;   // EXACTLY 1 cycle
                    end
                end

                START: begin
                    uart_tx   <= 1'b0;     // start bit
                    tx_busy   <= 1'b1;
                    shift_reg <= fifo_data; // NOW VALID
                end

                DATA: begin
                    uart_tx <= shift_reg[0];
                    tx_busy <= 1'b1;
                    if (baud_tick) begin
                        shift_reg <= shift_reg >> 1;
                        bit_cnt   <= bit_cnt + 1'b1;
                    end
                end

                STOP: begin
                    uart_tx <= 1'b1;
                    tx_busy <= 1'b1;
                end
            endcase
        end
    end

endmodule

