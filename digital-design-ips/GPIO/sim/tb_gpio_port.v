`timescale 1ns / 1ps
module tb_gpio_port;
    parameter WIDTH = 32;
    reg sys_clk;
    reg reset;
    reg [7:0] addr;
    reg [31:0] w_data;
    reg w_en;
    reg r_en;
    wire [31:0] r_data;
    wire [31:0] gpio_pin;
    wire irq;

    // For driving input pins
    reg [WIDTH-1:0] gpio_drive;
    reg [WIDTH-1:0] gpio_oe;  // 0 = drive from TB, 1 = driven by DUT

    // Bidirectional modeling
    assign gpio_pin = gpio_oe ? {WIDTH{1'bz}} : gpio_drive;

    // Instantiate DUT
    gpio_port #(
        .WIDTH(WIDTH)
    ) dut (
        .sys_clk(sys_clk),
        .reset(reset),
        .w_en(w_en),
        .r_en(r_en),
        .addr(addr),
        .w_data(w_data),
        .r_data(r_data),
        .gpio_pin(gpio_pin),
        .irq(irq)
    );

    //Clock generation

    always #5 sys_clk =~sys_clk; //10ns  

    //--------------------------------------
    // Write Task
    //--------------------------------------
    task write_reg(input [7:0] a, input [31:0] data);
        begin
            @(posedge sys_clk);
            addr = a;
            w_data = data;
            w_en = 1;
            @(posedge sys_clk);
            w_en = 0;
        end
    endtask

    //--------------------------------------
    // Read Task
    //--------------------------------------
    task read_reg(input [7:0] a);
    begin
        @(posedge sys_clk);
        addr = a;
        r_en = 1;
        @(posedge sys_clk);
        $display("Read Addr %h = %h", a, r_data);
        r_en = 0;
    end
    endtask

    initial begin
        $display("GPIO Testbench");
        $dumpfile("GPIO_MMO.vcd");
        $dumpvars(0, tb_gpio_port);  // dump whole testbench hierarchy
        sys_clk = 0;
        reset = 1;
        w_en = 0;
        r_en = 0;
        addr = 0;
        w_data = 0;
        gpio_drive = 0;
        gpio_oe = 1;   // default input mode

        #20;
        reset = 0;

        //--------------------------------------
        // Configure GPIO[0] as OUTPUT
        //--------------------------------------
        write_reg(8'h04, 8'b0000_0001);  // DIR bit0 = 1
        #20;

        //--------------------------------------
        // Write DATA = 1 to GPIO[0]
        //--------------------------------------
        write_reg(8'h00, 8'b0000_0001);
        #20;
        //--------------------------------------
        // Generate edge on GPIO[1]
        //--------------------------------------
        read_reg(8'h08);
        gpio_oe = 0; // TB drives pin (input mode)
        gpio_drive = 8'b0000_0000;
        #20;

        gpio_drive = 8'b0000_0010; // Rising edge
        #20;

        //--------------------------------------
        // Check interrupt status
        //--------------------------------------
        read_reg(8'h0C);
        #50;
        $finish;
    end
endmodule



