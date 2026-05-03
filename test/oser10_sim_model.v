/*
 * Behavioral model of Gowin OSER10 for simulation.
 */

`timescale 1ns/1ps

module OSER10 (
    output reg Q,
    input wire D0, D1, D2, D3, D4, D5, D6, D7, D8, D9,
    input wire PCLK,
    input wire FCLK,
    input wire RESET
);

    reg [9:0] latch;
    reg [3:0] count;

    // Use a helper to detect PCLK rising edge in FCLK domain
    reg pclk_d;
    always @(posedge FCLK) pclk_d <= PCLK;
    wire pclk_rise = (PCLK && !pclk_d);

    always @(posedge FCLK or posedge RESET) begin
        if (RESET) begin
            count <= 4'd0;
            Q <= 1'b0;
            latch <= 10'b0;
        end else begin
            if (pclk_rise) begin
                latch <= {D9, D8, D7, D6, D5, D4, D3, D2, D1, D0};
                Q <= D0;
                count <= 4'd1;
            end else begin
                Q <= latch[count];
                if (count == 4'd9)
                    count <= 4'd0;
                else
                    count <= count + 4'd1;
            end
        end
    end

endmodule
