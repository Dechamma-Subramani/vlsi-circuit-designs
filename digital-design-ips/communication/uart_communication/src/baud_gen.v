`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.01.2026 11:01:49
// Design Name: 
// Module Name: baud_gen
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


module baud_gen #(
    parameter SYS_CLK_FREQ = 50000000,  // 50 MHz
    parameter BAUD_RATE    = 115200
)(
    input  wire sys_clk,
    input  wire reset,
    output reg  baud_tick
);

    localparam integer BAUD_DIV = SYS_CLK_FREQ / BAUD_RATE;
    reg [$clog2(BAUD_DIV)-1:0] baud_cnt;

    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            baud_cnt  <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (baud_cnt == BAUD_DIV-1) begin
                baud_cnt  <= 0;
                baud_tick <= 1'b1;
            end else begin
                baud_cnt  <= baud_cnt + 1'b1;
                baud_tick <= 1'b0;
            end
        end
    end

endmodule

