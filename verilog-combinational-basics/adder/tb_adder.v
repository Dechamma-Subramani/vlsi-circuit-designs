`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2025 10:30:29
// Design Name: 
// Module Name: tb_adder
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


module tb_half_adder;

    reg a, b;
    wire s;
    wire cout;
    half_adder u0(.a(a), .b(b), .sum(s), .carry(cout));
    
    initial begin
        $dumpfile("half_adder.vcd");
        $dumpvars(0, tb_adder);
    
        for (integer i = 0; i < 4; i = i + 1) begin
            {a, b} = i;   // Correct 2-bit assignment
            #10;
        end
    
        $finish;
    end   
endmodule
