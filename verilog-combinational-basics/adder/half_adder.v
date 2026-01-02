`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2025 16:32:50
// Design Name: 
// Module Name: half_adder
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

//METHOD _ 1

//module half_adder(
//    input a,
//    input b,
//    output sum,
//    output carry
//    );
//   assign sum = a^b;
//   assign carry = a&b;
//endmodule

//METHOD _ 2
module half_adder(
    input a,
    input b,
    output reg sum,
    output reg carry
    );
    
   always@(a or b)
       {sum, carry} = a+b;
   
endmodule
