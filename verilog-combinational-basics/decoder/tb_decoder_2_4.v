`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.01.2026 12:25:59
// Design Name: 
// Module Name: tb_decoder_2_4
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


module tb_decoder_2_4;

    reg        enable;
    reg  [1:0] d;
    wire [3:0] y;

    decoder_2_4 uut (
        .enable(enable),
        .d(d),
        .y(y)
    );

    initial begin
        $dumpfile("decoder_2_4.vcd");
        $dumpvars(0, tb_decoder_2_4);

        // Decoder disabled
        enable = 0;
        d = 2'b00; #10;
        d = 2'b01; #10;
        d = 2'b10; #10;
        d = 2'b11; #10;

        // Decoder enabled
        enable = 1;
        d = 2'b00; #10;
        d = 2'b01; #10;
        d = 2'b10; #10;
        d = 2'b11; #10;

        $finish;
    end

    initial begin
        $monitor("t=%0t | enable=%b d=%b | y=%b",
                 $time, enable, d, y);
    end

endmodule
