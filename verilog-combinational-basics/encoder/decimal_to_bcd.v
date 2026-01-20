`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2026 12:16:07
// Design Name: 
// Module Name: decimal_to_bcd
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


module decimal_to_bcd (
    input  D0, D1, D2, D3, D4, D5, D6, D7, D8, D9,
    output B3, B2, B1, B0
);
    assign B0 = D1 | D3 | D5 | D7 | D9;
    assign B1 = D2 | D3 | D6 | D7;
    assign B2 = D4 | D5 | D6 | D7;
    assign B3 = D8 | D9;
endmodule

