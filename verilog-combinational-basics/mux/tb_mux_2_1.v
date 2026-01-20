`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2026 15:38:35
// Design Name: 
// Module Name: tb_mux_2_1
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


module tb_mux_2_1;
    reg a, b, sel;
    wire q;
    
    mux_2_1 uut(.a(a), .b(b), .sel(sel), .q(q));
    
    initial begin
    a = 1;
    b = 0;
    sel = 1'b0;
    #20 sel = 1'b1;
    a = 1;
    b = 0;
    #10 sel = 1'b0;
    #20 sel = 1'b1;
    
    $finish;
    end
endmodule
