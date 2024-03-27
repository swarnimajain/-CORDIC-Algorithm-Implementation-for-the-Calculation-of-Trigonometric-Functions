`timescale 1ns / 1ps

module cordic(
    input clk,
    input signed [7:0] xin, // initial x- coordinate 
    input signed [7:0] yin, // initial y-coordinate
    input signed [7:0] angle, // desired angle
    output reg signed [7:0] sine // sine of the angle
);

    // states
    parameter IDLE = 0;
    parameter STAGE_0 = 1;
    parameter STAGE_1 = 2;
    parameter STAGE_2 = 3;
    parameter STAGE_3 = 4;
    parameter STAGE_4 = 5;
    parameter STAGE_5 = 6;
    parameter STAGE_6 = 7;
    parameter STAGE_7 = 8;

    reg [3:0] state;  //state register

    // registers to store intermediate values of iterations
    reg signed [7:0] x_stage[0:7];
    reg signed [7:0] y_stage[0:7];
    reg signed [7:0] z_stage[0:7];


//arc tangent table to store cordic angles
   reg [7:0] atan_table [0:7];
// in fixed point format. Multiply by 2^6 for 2.6 format
always @(*) begin
    atan_table[0] = 8'b00110010; // 45.000 degrees -> 0.785 * 64
    atan_table[1] = 8'b00011101; // 26.565 degrees -> 0.463 * 64
    atan_table[2] = 8'b00001111; 
    atan_table[3] = 8'b00001000; 
    atan_table[4] = 8'b00000100; 
    atan_table[5] = 8'b00000010; 
    atan_table[6] = 8'b00000001; 
    atan_table[7] = 8'b00000000;
    
    end
     
   
    reg signed [7:0] x_shifted[0:7];
    reg signed [7:0] y_shifted[0:7];
    reg signed [7:0] z_sign[0:7];
    
    always @(posedge clk) begin
    state <= 4'b0000;
        case (state)
            IDLE: begin
                // Initialize
                x_stage[0] <= xin;
                y_stage[0] <= yin;
                z_stage[0] <= angle;
                state <= STAGE_0;
            end

            STAGE_0: begin
                // Stage 0
                // Calculate and shift values for stage 1
                x_shifted[0] = x_stage[0] >>> 0;
                y_shifted[0] = y_stage[0] >>> 0;
                z_sign[0] = z_stage[0][7];
                x_stage[1] <= (z_stage[0][7] ? x_stage[0] + (y_stage[0] >>> 0) : x_stage[0] - (y_stage[0] >>> 0));
                y_stage[1] <= (z_stage[0][7] ? y_stage[0] - (x_stage[0] >>> 0) : y_stage[0] + (x_stage[0] >>> 0));
                z_stage[1] <= (z_stage[0][7] ? z_stage[0] + atan_table[0] : z_stage[0] - atan_table[0]);
                state <= STAGE_1;
            end

            STAGE_1: begin
                x_shifted[1] = x_stage[1] >>> 1;
                y_shifted[1] = y_stage[1] >>> 1;
                z_sign[1] = z_stage[1][7];
                x_stage[2] <= (z_stage[1][7] ? x_stage[1] + (y_stage[1] >>> 2) : x_stage[1] - (y_stage[1] >>> 1));
                y_stage[2] <= (z_stage[1][7] ? y_stage[1] - (x_stage[1] >>> 2) : y_stage[1] + (x_stage[1] >>> 1));
                z_stage[2] <= (z_stage[1][7] ? z_stage[1] + atan_table[1] : z_stage[1] - atan_table[1]);
                state <= STAGE_2;
            end
            
            STAGE_2: begin
                x_shifted[2] = x_stage[2] >>> 2;
                y_shifted[2] = y_stage[2] >>> 2;
                z_sign[2] = z_stage[2][7];
                x_stage[3] <= (z_stage[2][7] ? x_stage[2] + (y_stage[2] >>> 2) : x_stage[2] - (y_stage[2] >>> 2));
                y_stage[3] <= (z_stage[2][7] ? y_stage[2] - (x_stage[2] >>> 2) : y_stage[2] + (x_stage[2] >>> 2));
                z_stage[3] <= (z_stage[2][7] ? z_stage[2] + atan_table[2] : z_stage[2] - atan_table[2]);
                state <= STAGE_3;
            end
             STAGE_3: begin
                // Stage 3
                x_shifted[3] <= x_stage[3] >>> 3;
                y_shifted[3] <= y_stage[3] >>> 3;
                z_sign[3] <= z_stage[3][7];
                x_stage[4] <= z_stage[3][7] ? x_stage[3] + (y_stage[3] >>> 3) : x_stage[3] - (y_stage[3] >>> 3);
                y_stage[4] <= z_stage[3][7] ? y_stage[3] - (x_stage[3] >>> 3) : y_stage[3] + (x_stage[3] >>> 3);
                z_stage[4] <= z_stage[3][7] ? z_stage[3] + atan_table[3] : z_stage[3] - atan_table[3];
                state <= STAGE_4;
            end

            STAGE_4: begin
                // Stage 4
                x_shifted[4] <= x_stage[4] >>> 4;
                y_shifted[4] <= y_stage[4] >>> 4;
                z_sign[4] <= z_stage[4][7];
                x_stage[5] <= z_stage[4][7] ? x_stage[4] + (y_stage[4] >>> 4) : x_stage[4] - (y_stage[4] >>> 4);
                y_stage[5] <= z_stage[4][7] ? y_stage[4] - (x_stage[4] >>> 4) : y_stage[4] + (x_stage[4] >>> 4);
                z_stage[5] <= z_stage[4][7] ? z_stage[4] + atan_table[4] : z_stage[4] - atan_table[4];
                state <= STAGE_5;
            end

            STAGE_5: begin
                // Stage 5
                x_shifted[5] = x_stage[5] >>> 5;
                y_shifted[5] = y_stage[5] >>> 5;
                z_sign[5] = z_stage[5][7];
                x_stage[6] <= z_stage[5][7] ? x_stage[5] + (y_stage[5] >>> 5) : x_stage[5] - (y_stage[5] >>> 5);
                y_stage[6] <= z_stage[5][7] ? y_stage[5] - (x_stage[5] >>> 5) : y_stage[5] + (x_stage[5] >>> 5);
                z_stage[6] <= z_stage[5][7] ? z_stage[5] + atan_table[5] : z_stage[5] - atan_table[5];
                state <= STAGE_6;
            end

            STAGE_6: begin
                // Stage 6
                x_shifted[6] <= x_stage[6] >>> 6;
                y_shifted[6] <= y_stage[6] >>> 6;
                z_sign[6] <= z_stage[6][7];
                x_stage[7] <= z_stage[6][7] ? x_stage[6] + (y_stage[6] >>> 6) : x_stage[6] - (y_stage[6] >>> 6);
                y_stage[7] <= z_stage[6][7] ? y_stage[6] - (x_stage[6] >>> 6) : y_stage[6] + (x_stage[6] >>> 6);
                z_stage[7] <= z_stage[6][7] ? z_stage[6] + atan_table[6] : z_stage[6] - atan_table[6];
                state <= STAGE_7;
            end

            STAGE_7: begin
                // Stage 7 (Final Stage)
               sine <= (z_stage[7][7] ? y_stage[7] - (x_stage[7] >>> 7) : y_stage[7] + (x_stage[7] >>> 7));
                state <= IDLE;  // Return to IDLE state
            end
        endcase
    end

endmodule