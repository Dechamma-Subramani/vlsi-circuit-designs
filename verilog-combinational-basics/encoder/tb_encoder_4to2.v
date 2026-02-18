`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2026 11:58:08
// Design Name: 
// Module Name: tb_encoder_4to2
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


module tb_encoder_4to2;
    reg D0, D1, D2, D3;
    wire Y1, Y0;

    // Instantiate the DUT (Device Under Test)
    encoder_4to2 DUT (
        .D0(D0),
        .D1(D1),
        .D2(D2),
        .D3(D3),
        .Y1(Y1),
        .Y0(Y0)
    );

    initial begin
        // Monitor outputs
        $monitor("Time=%0t | D3 D2 D1 D0 = %b%b%b%b | Y1 Y0 = %b%b",
                  $time, D3, D2, D1, D0, Y1, Y0);

        // Apply test vectors
        D3=0; D2=0; D1=0; D0=1;  #10; // 00
        D3=0; D2=0; D1=1; D0=0;  #10; // 01
        D3=0; D2=1; D1=0; D0=0;  #10; // 10
        D3=1; D2=0; D1=0; D0=0;  #10; // 11
        
        // End simulation
        $finish;
    end
endmodule
