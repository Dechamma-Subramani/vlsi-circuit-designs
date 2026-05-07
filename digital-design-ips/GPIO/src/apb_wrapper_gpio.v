`timescale 1ns / 1ps

module apb_gpio_wrapper (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PADDR,
    input  wire [31:0] PWDATA,
    output wire [31:0] PRDATA,
    output wire        PREADY,

    input  wire [7:0]  gpio_in,
    output wire [7:0]  gpio_out
);

    //-----------------------------------------
    // APB Control Signals
    //-----------------------------------------
    wire wr_en = PSEL & PENABLE &  PWRITE;
    wire rd_en = PSEL & PENABLE & ~PWRITE;

    wire [5:0] addr = PADDR[5:0];

    //-----------------------------------------
    // Registers
    //-----------------------------------------
    reg        gpio_enable;
    reg [7:0]  dir_reg;      // 1 = output, 0 = input
    reg [7:0]  data_out_reg;

    //-----------------------------------------
    // WRITE LOGIC
    //-----------------------------------------
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            gpio_enable  <= 1'b0;
            dir_reg      <= 8'h00;
            data_out_reg <= 8'h00;
        end else begin
            if (wr_en) begin
                case (addr)

                    6'h00: gpio_enable  <= PWDATA[0];        // CTRL
                    6'h04: dir_reg      <= PWDATA[7:0];      // DIR
                    6'h08: data_out_reg <= PWDATA[7:0];      // DATA_OUT

                    default: ;
                endcase
            end
        end
    end

    //-----------------------------------------
    // GPIO OUTPUT LOGIC
    //-----------------------------------------
    assign gpio_out = (gpio_enable) ? 
                      (dir_reg & data_out_reg) : 
                      8'b0;

    //-----------------------------------------
    // READ LOGIC
    //-----------------------------------------
    reg [31:0] prdata_reg;

    always @(*) begin
        case (addr)

            6'h00: prdata_reg = {31'b0, gpio_enable};
            6'h04: prdata_reg = {24'b0, dir_reg};
            6'h08: prdata_reg = {24'b0, data_out_reg};
            6'h0C: prdata_reg = {24'b0, gpio_in};   // DATA_IN

            default: prdata_reg = 32'b0;

        endcase
    end

    //-----------------------------------------
    // APB Outputs
    //-----------------------------------------
    assign PRDATA = (rd_en) ? prdata_reg : 32'b0;
    assign PREADY = 1'b1;

endmodule


