/*
 * TERC4 Encoder for HDMI Data Islands
 *
 * Maps 4-bit data to 10-bit TMDS symbols.
 * Based on HDMI 1.3a Section 5.4.3.
 */

`default_nettype none

module terc4_encoder (
    input  wire [3:0]  data,
    output reg  [9:0]  tmds
);

    always @(*) begin
        case (data)
            4'b0000: tmds = 10'b1010011100;
            4'b0001: tmds = 10'b1001100111;
            4'b0010: tmds = 10'b1010010110;
            4'b0011: tmds = 10'b1010101011;
            4'b0100: tmds = 10'b1011100100;
            4'b0101: tmds = 10'b1011100110;
            4'b0110: tmds = 10'b1011100101;
            4'b0111: tmds = 10'b1011100111;
            4'b1000: tmds = 10'b1011011100;
            4'b1001: tmds = 10'b1011001111;
            4'b1010: tmds = 10'b1011010110;
            4'b1011: tmds = 10'b1011010111;
            4'b1100: tmds = 10'b1011101100;
            4'b1101: tmds = 10'b1011101110;
            4'b1110: tmds = 10'b1011101101;
            4'b1111: tmds = 10'b1011101111;
            default: tmds = 10'b1010011100;
        endcase
    end

endmodule
