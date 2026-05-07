`timescale 1ns / 1ps

module gpio_port #(
    parameter WIDTH = 32
)(
    input  sys_clk,
    input  reset,   // active-high

    // MMIO
    input  w_en,
    input  r_en,
    input  [7:0]addr,
    input  [WIDTH-1:0] w_data,
    output reg  [WIDTH-1:0] r_data,
    
    // GPIO pad
    inout  [WIDTH-1:0] gpio_pin,
    
    //Interrupt
    output irq
);

    // Internal registers
    reg  [WIDTH-1:0] data_reg;
    reg  [WIDTH-1:0] dir_reg;
    reg  [WIDTH-1:0] gpio_in_reg;

    //Interrupt Register
    
    reg [WIDTH-1:0] prev_gpio;
    reg [WIDTH-1:0] i_status;
    reg [WIDTH-1:0] i_en;
    wire [WIDTH-1:0]edge_detect;

    // ---------------------------
    // GPIO pad connection
    // ---------------------------
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gpio_bits
            assign gpio_pin = dir_reg[i] ? data_reg[i] : 1'bz;
        end
    endgenerate

    //Rise and fall edge detect
    assign edge_detect = ((~prev_gpio) & gpio_in_reg) | (prev_gpio & (~gpio_in_reg));
    //edge_detect = (gpio_in_reg ^ prev_gpio);
    // ---------------------------
    // Input synchronization
    // ---------------------------
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            gpio_in_reg <= 0;
            prev_gpio <= 0;
        end else begin
            prev_gpio <= gpio_in_reg;
            gpio_in_reg <= gpio_pin;
        end
    end
    
    // ---------------------------
    // Interrupt logic (CORRECT)
    // ---------------------------
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            i_status <= 1'b0;
            i_en     <= 1'b0;
        end else begin
            // Hardware sets interrupt on edge (INPUT only)
            //Only when interrupt is enabled
            //Only when an edge occurs
            //Only when GPIO is INPUT
            //if (i_en && edge_detect && (dir_reg == 0))
            // i_status <= 1'b1;
            i_status <= i_status | (edge_detect & i_en & ~dir_reg);

            // Software clears interrupt (W1C)
            if (w_en && addr == 8'h10)
                i_status <= i_status & ~w_data; //(Masking)

            // Interrupt enable
            if (w_en && addr == 8'h08)
                i_en <= w_data;
        end
    end
    // ---------------------------
    // Write logic
    // ---------------------------
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            data_reg <= 0;
            dir_reg  <= 0;
        end else if (w_en) begin
            case (addr)
                8'h0: data_reg <= w_data; // DATA
                8'h4: dir_reg  <= w_data; // DIR
            endcase
        end
    end

    // ---------------------------
    // Read logic
    // ---------------------------
    always @(*) begin
        r_data = 0;
        if (r_en) begin
            case (addr)
                8'h0: r_data = data_reg;    // DATA
                8'h4: r_data = dir_reg;     // DIR
                8'h8: r_data = gpio_in_reg; // INPUT
//                8'h0C: r_data = {{(WIDTH-1){1'b0}}, i_status}; // INT_STATUS
                8'h0C: r_data = i_status;
                default: r_data = 0;
            endcase
        end
    end
    assign irq = |i_status;
endmodule

