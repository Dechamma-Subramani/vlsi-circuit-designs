`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2025 16:30:33
// Design Name: 
// Module Name: logic_gates
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


module logic_gates(
    input a,
    input b,
    output and_o,
    output or_o,
    output not_o,
    output nand_o,
    output nor_o,
    output xor_o,
    output nxor_o
    );
    
    
    //dataflow level
    
    assign and_o = a & b;
    assign or_o = a | b;
    assign not_o = ~a;
    assign nand_o = ~(a & b);
    assign nor_o = ~(a | b);
    assign xor_o = (a & ~b) | (~a & b);
    assign nxor_o = (~a & ~b) | (a & b);

endmodule
