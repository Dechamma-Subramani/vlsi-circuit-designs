`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2026 12:07:07
// Design Name: 
// Module Name: priority_encoder_4to2
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


module priority_encoder_4to2 (
    input  D0, D1, D2, D3,
    output reg Y1, Y0,
    output reg Valid
);
    always @(*) begin
        Valid = 1'b1;
        if (D3)      {Y1, Y0} = 2'b11;
        else if (D2) {Y1, Y0} = 2'b10;
        else if (D1) {Y1, Y0} = 2'b01;
        else if (D0) {Y1, Y0} = 2'b00;
        else begin
            {Y1, Y0} = 2'b00;
            Valid = 1'b0;
        end
    end
endmodule

