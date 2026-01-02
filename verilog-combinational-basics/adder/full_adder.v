`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2025 16:58:16
// Design Name: 
// Module Name: full_adder
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

//Method _1
//module full_adder(
//    input a,
//    input b,
//    input cin,
//    output sum,
//    output carry
//    );


//    assign sum = (a^b)^cin;
//    assign carry = (a&b) | ((a^b) & cin);
//endmodule

//Method_2
module full_adder(
    input a,
    input b,
    input cin,
    output reg sum,
    output reg carry
    );


    always@(a or b or cin)
        {carry, sum} = a+b+cin;
endmodule
