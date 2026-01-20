`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2026 16:15:56
// Design Name: 
// Module Name: mux_4_1
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


module mux_4_1(
    input a,
    input b,
    input c,
    input d,
    input [1:0] sel,
    output reg q
    );
    
    always@(*) begin
        case(sel)
            2'b00: q = a;
            2'b01: q = b;
            2'b10: q = c;
            2'b11: q = d;
            default: q =1'b0;
        endcase
    end
endmodule
