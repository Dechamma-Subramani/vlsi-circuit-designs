`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.01.2026 16:02:02
// Design Name: 
// Module Name: rx_fifo
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


module rx_fifo#(
    parameter DEPTH = 8,
    parameter ADDR_W = $clog2(DEPTH)
)(
    input  wire       clk,
    input  wire       reset,

    input  wire       rx_valid,
    input  wire [7:0] rx_data,

    input  wire       csr_rx_read,
    output reg  [7:0] rx_fifo_data,

    output wire       full,
    output wire       empty
);

    reg [7:0] mem [0:DEPTH-1];
    reg [ADDR_W:0] wr_ptr, rd_ptr;

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[ADDR_W] != rd_ptr[ADDR_W]) &&
                   (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]);

    always @(posedge clk or posedge reset) begin
    $monitor("time = %0t rx_fifo_datatate = %b full =%b csr_rx_read =%b",
            $time, rx_fifo_data, full, csr_rx_read);
        if (reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (rx_valid && !full) begin
                mem[wr_ptr[ADDR_W-1:0]] <= rx_data;
                wr_ptr <= wr_ptr + 1'b1;
            end

            if (csr_rx_read && !(wr_ptr == rd_ptr)) begin
                rx_fifo_data <= mem[rd_ptr[ADDR_W-1:0]];
                rd_ptr   <= rd_ptr + 1'b1;
            end
        end
    end

endmodule