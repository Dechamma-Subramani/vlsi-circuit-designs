`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.01.2026 12:18:19
// Design Name: 
// Module Name: decoder_3_8_predecoded
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
module decoder_3_8_predecoded (
    input        enable,
    input  [2:0] d,
    output reg [7:0] y
);

    wire [3:0] ab_dec;   // Pre-decode A,B
    wire [1:0] c_dec;    // Pre-decode C

    // 2:4 pre-decoder for A,B
    assign ab_dec[0] = ~d[2] & ~d[1];
    assign ab_dec[1] = ~d[2] &  d[1];
    assign ab_dec[2] =  d[2] & ~d[1];
    assign ab_dec[3] =  d[2] &  d[1];

    // 1:2 pre-decoder for C
    assign c_dec[0] = ~d[0];
    assign c_dec[1] =  d[0];

    // Final decode stage
    always @(*) begin
        if (!enable)
            y = 8'b0000_0000;
        else begin
            y[0] = ab_dec[0] & c_dec[0];
            y[1] = ab_dec[0] & c_dec[1];
            y[2] = ab_dec[1] & c_dec[0];
            y[3] = ab_dec[1] & c_dec[1];
            y[4] = ab_dec[2] & c_dec[0];
            y[5] = ab_dec[2] & c_dec[1];
            y[6] = ab_dec[3] & c_dec[0];
            y[7] = ab_dec[3] & c_dec[1];
        end
    end

endmodule
