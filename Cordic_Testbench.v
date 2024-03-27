Testbench:

`timescale 1ns / 1ps

module cordic_tb();
    reg clk;
  //  reg reset;
    reg signed [7:0] xin;
    reg signed [7:0] yin;
    reg signed [7:0] angle;
    wire signed [7:0] sine;

    cordic dut (
        .clk(clk),
        .xin(xin),
        .yin(yin),
        .angle(angle),
        .sine(sine)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
       // reset = 0;
        xin = 8'b00100111;
        yin = 8'b00000000;

        //#10; // Initial delay

        // Continuous angle changes
//        for (angle = 8'b00000000; angle <= 8'b11111111; angle = angle + 1) begin
//            #5; // Wait for the calculation to complete
        #5 angle  = 8'b01000011; // 60 degrees
        #10 angle = 8'b00100010; // 30 degrees
        #10 angle = 8'b00000001; // 1 degrees
        #10 angle = 8'b00110010; // 45 degrees
        #10 angle = 8'b01100100; // 90 degrees   
        #10 angle = 8'b00001011; // 10 degrees
        #10 angle = 8'b10100111; // -80 degrees
        #10 angle = 8'b00010001; //15 degrees
        #10 angle = 8'b00000000; //0 degrees;
        #10 angle = 8'b10110010; //-70 degrees
        #10 angle = 8'b00010110; // 20 degrees
        #10 angle = 8'b00110110; // 48.5 degrees
        #10 angle = 8'b01100100; // 90 degrees  
        #10 angle = 8'b01011111; // 85 degrees
        #10 angle = 8'b01010100; // 75 degrees 

        $display("Sine result for angle %h = %b", angle, sine);

       // $finish;
    end
endmodule