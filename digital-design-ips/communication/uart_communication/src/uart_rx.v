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

module uart_rx (
    input  wire        sys_clk,
    input  wire        reset,
    input  wire        baud_tick,

    input  wire        uart_rx,
    input  wire        rx_clear,

    output reg  [7:0]  rx_data,
    output reg         rx_valid,
    output reg         framing_error
);

    // --------------------------------------------------
    // Synchronize async UART RX
    // --------------------------------------------------
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

    // --------------------------------------------------
    // FSM states
    // --------------------------------------------------
    localparam [1:0]
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3;

    reg [1:0] state, next_state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    // --------------------------------------------------
    // State register
    // --------------------------------------------------
    always @(posedge sys_clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // --------------------------------------------------
    // Next-state logic
    // --------------------------------------------------
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:  if (rx_sync == 1'b0) next_state = START;
            START: if (baud_tick)       next_state = DATA;
            DATA:  if (baud_tick && bit_cnt == 3'd7) next_state = STOP;
            STOP:  if (baud_tick)       next_state = IDLE;
        endcase
    end

    // --------------------------------------------------
    // Datapath & outputs
    // --------------------------------------------------
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            rx_data       <= 8'd0;
            rx_valid      <= 1'b0;
            framing_error <= 1'b0;
            shift_reg     <= 8'd0;
            bit_cnt       <= 3'd0;
        end else begin

            case (state)

                IDLE: begin
                    bit_cnt       <= 3'd0;
                    framing_error <= 1'b0;
                end

                START: begin
                    // wait 1 baud tick before sampling data
                end

                DATA: begin
                    if (baud_tick) begin
                        shift_reg <= {rx_sync, shift_reg[7:1]}; // LSB first
                        bit_cnt   <= bit_cnt + 1'b1;
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        if (rx_sync == 1'b1) begin
                            rx_data  <= shift_reg;
                            rx_valid <= 1'b1;   // HOLD until rx_clear
                        end else begin
                            framing_error <= 1'b1;
                        end
                    end
                end

            endcase

            // clear from CSR
            if (rx_clear) begin
                rx_valid      <= 1'b0;
                framing_error <= 1'b0;
            end
        end
    end

endmodule


