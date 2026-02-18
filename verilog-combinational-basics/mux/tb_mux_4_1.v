`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2026 16:28:52
// Design Name: 
// Module Name: tb_mux_4_1
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


module tb_mux_4_1;
    reg a, b, c, d;
    reg [1:0] sel;
    wire q;
    
    mux_4_1 uut(a, b, c , d, sel, q);
    initial begin
        // Initialize inputs
        a = 0; b = 0; c = 0; d = 0; sel = 2'b00;
        #10;

        // Apply unique values to inputs
        a = 1; b = 0; c = 1; d = 0;

        // Test all select lines
        sel = 2'b00; #10; // expect q = a
        sel = 2'b01; #10; // expect q = b
        sel = 2'b10; #10; // expect q = c
        sel = 2'b11; #10; // expect q = d

        // Change inputs again
        a = 0; b = 1; c = 0; d = 1;

        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b10; #10;
        sel = 2'b11; #10;

        $finish;
    end
endmodule
