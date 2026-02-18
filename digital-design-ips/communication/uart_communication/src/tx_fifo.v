`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.01.2026 15:04:37
// Design Name: 
// Module Name: tx_fifo
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


module tx_fifo #(
    parameter DEPTH = 8,
    parameter ADDR_W = $clog2(DEPTH)
)(
    input  wire       clk,
    input  wire       reset,

    input  wire       push,
    input  wire [7:0] push_data,

    input  wire       pop,
    output reg  [7:0] pop_data,

    output wire       full,
    output wire       empty
);

    reg [7:0] mem [0:DEPTH-1];
    reg [ADDR_W:0] wr_ptr, rd_ptr;

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[ADDR_W] != rd_ptr[ADDR_W]) &&
                   (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            
            if (push && !full) begin
                mem[wr_ptr[ADDR_W-1:0]] <= push_data;
                wr_ptr <= wr_ptr + 1'b1;
            end

            if (pop && !empty) begin
                pop_data <= mem[rd_ptr[ADDR_W-1:0]];
                rd_ptr   <= rd_ptr + 1'b1;
            end
        end
    end

endmodule

