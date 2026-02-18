`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2026 12:08:29
// Design Name: 
// Module Name: tb_priority_encoder_4to2
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


module tb_priority_encoder_4to2;

    reg D0, D1, D2, D3;
    wire Y1, Y0;
    wire Valid;

    // Instantiate DUT
    priority_encoder_4to2 DUT (
        .D0(D0),
        .D1(D1),
        .D2(D2),
        .D3(D3),
        .Y1(Y1),
        .Y0(Y0),
        .Valid(Valid)
    );

    initial begin
        // Display format
        $monitor("Time=%0t | D3 D2 D1 D0 = %b%b%b%b | Y1 Y0 = %b%b | Valid=%b",
                  $time, D3, D2, D1, D0, Y1, Y0, Valid);

        // Test cases
        D3=0; D2=0; D1=0; D0=0; #10; // No input active
        D3=0; D2=0; D1=0; D0=1; #10; // D0 active
        D3=0; D2=0; D1=1; D0=1; #10; // D1 priority
        D3=0; D2=1; D1=1; D0=1; #10; // D2 priority
        D3=1; D2=1; D1=1; D0=1; #10; // D3 highest priority

        $finish;
    end

endmodule
