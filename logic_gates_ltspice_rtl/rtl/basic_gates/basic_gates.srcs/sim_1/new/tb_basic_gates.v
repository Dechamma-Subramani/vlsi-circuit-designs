`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2025 16:37:08
// Design Name: 
// Module Name: tb_basic_gates
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


module tb_basic_gates();
    reg a, b;
    wire and_o, or_o, not_o, nand_o, nor_o, xor_o, nxor_o;
    logic_gates uut(.a(a), .b(b), .and_o(and_o), .or_o(or_o), .not_o(not_o), 
    .nand_o(nand_o), .nor_o(nor_o), .xor_o(xor_o), .nxor_o(nxor_o));
     integer i;

    initial begin
        $monitor("%b %b %b %b %b %b %b %b %b", a,b,and_o, or_o,
        not_o, nand_o, nor_o, xor_o, nxor_o);
        
        {a,b} = 0;
        
        for(i=0;i<=4;i=i+1)
        begin
            {a,b}= i;
            #100;
        end
    
    end
 endmodule

