`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2025 11:11:28
// Design Name: 
// Module Name: tb_ripple_adder
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


module tb_ripple_adder;

    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    // DUT instantiation
    ripple_adder u1 (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        // Waveform dump
        $dumpfile("ripple_adder.vcd");
        $dumpvars(0, tb_ripple_adder);

        // Test cases
        cin = 0;
        a = 4'b0000; b = 4'b0000; #10;
        a = 4'b0001; b = 4'b0010; #10;
        a = 4'b0111; b = 4'b0001; #10; // carry propagation
        a = 4'b1111; b = 4'b0001; #10; // worst case carry
        a = 4'b1010; b = 4'b0101; #10;

        cin = 1;
        a = 4'b1111; b = 4'b1111; #10;

        $finish;
    end

    initial begin
        $monitor("t=%0t | a=%b b=%b cin=%b | sum=%b cout=%b",
                  $time, a, b, cin, sum, cout);
    end

endmodule

