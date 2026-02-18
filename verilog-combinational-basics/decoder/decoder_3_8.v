`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.01.2026 14:48:44
// Design Name: 
// Module Name: decoder_3_8
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


module decoder_3_8(
    input        enable,
    input  [2:0] d,
    output reg [7:0] y
);

always @(*) begin
    if (!enable)
        y = 8'b0000_0000;
    else begin
        case (d)
            3'b000: y = 8'b0000_0001;
            3'b001: y = 8'b0000_0010;
            3'b010: y = 8'b0000_0100;
            3'b011: y = 8'b0000_1000;
            3'b100: y = 8'b0001_0000;
            3'b101: y = 8'b0010_0000;
            3'b110: y = 8'b0100_0000;
            3'b111: y = 8'b1000_0000;
            default: y = 8'b0000_0000;
        endcase
    end
end

endmodule

