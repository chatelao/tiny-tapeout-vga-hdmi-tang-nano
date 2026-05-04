/*
 * 1-bit PWM Audio Generator
 *
 * Converts 8-bit PCM audio samples to a 1-bit PWM signal.
 * Suitable for driving a simple RC filter or a TT Audio PMOD.
 */

`default_nettype none

module audio_pwm (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] sample_in,
    output reg        pwm_out
);

    reg [7:0] counter;

    always @(posedge clk) begin
        if (reset) begin
            counter <= 8'h0;
            pwm_out <= 1'b0;
        end else begin
            counter <= counter + 1'b1;
            // Registered output to avoid glitches
            pwm_out <= (counter < sample_in);
        end
    end

endmodule
