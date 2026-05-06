/*
 * TMDS Encoder (8b10b) for DVI/HDMI
 *
 * This module implements the TMDS encoding algorithm as specified in the
 * DVI 1.0 specification. It converts 8-bit pixel data into 10-bit TMDS symbols.
 */

`default_nettype none

module tmds_encoder (
    input  wire       clk,     // Pixel clock
    input  wire       reset,   // Synchronous reset
    input  wire [7:0] data,    // 8-bit pixel data (R, G, or B)
    input  wire [1:0] ctrl,    // Control signals (C0, C1)
    input  wire       vde,     // Video Data Enable (active high)
    output reg  [9:0] tmds     // 10-bit encoded TMDS symbol
);

    // --- Stage 1: Minimize transitions ---
    wire [3:0] n1d = {3'b0, data[0]} + {3'b0, data[1]} + {3'b0, data[2]} + {3'b0, data[3]} +
                     {3'b0, data[4]} + {3'b0, data[5]} + {3'b0, data[6]} + {3'b0, data[7]};
    wire use_xnor = (n1d > 4'd4) || (n1d == 4'd4 && data[0] == 1'b0);

    /* verilator lint_off UNOPTFLAT */
    wire [8:0] q_m;
    /* verilator lint_on UNOPTFLAT */
    assign q_m[0] = data[0];
    assign q_m[1] = use_xnor ? (q_m[0] ~^ data[1]) : (q_m[0] ^ data[1]);
    assign q_m[2] = use_xnor ? (q_m[1] ~^ data[2]) : (q_m[1] ^ data[2]);
    assign q_m[3] = use_xnor ? (q_m[2] ~^ data[3]) : (q_m[2] ^ data[3]);
    assign q_m[4] = use_xnor ? (q_m[3] ~^ data[4]) : (q_m[3] ^ data[4]);
    assign q_m[5] = use_xnor ? (q_m[4] ~^ data[5]) : (q_m[4] ^ data[5]);
    assign q_m[6] = use_xnor ? (q_m[5] ~^ data[6]) : (q_m[5] ^ data[6]);
    assign q_m[7] = use_xnor ? (q_m[6] ~^ data[7]) : (q_m[6] ^ data[7]);
    assign q_m[8] = use_xnor ? 1'b0 : 1'b1;

    // --- Stage 2: DC Balance ---
    reg signed [4:0] cnt; // Running disparity
    wire [3:0] n1qm = {3'b0, q_m[0]} + {3'b0, q_m[1]} + {3'b0, q_m[2]} + {3'b0, q_m[3]} +
                      {3'b0, q_m[4]} + {3'b0, q_m[5]} + {3'b0, q_m[6]} + {3'b0, q_m[7]};
    wire [3:0] n0qm = 4'h8 - n1qm;
    wire signed [4:0] diff_qm = $signed({1'b0, n1qm}) - $signed({1'b0, n0qm});

    always @(posedge clk) begin
        if (reset) begin
            tmds <= 10'b0;
            cnt  <= 5'sh0;
        end else begin
            if (!vde) begin
                cnt <= 5'sh0;
                case (ctrl)
                    2'b00:   tmds <= 10'b1101010100;
                    2'b01:   tmds <= 10'b0010101011;
                    2'b10:   tmds <= 10'b0101010100;
                    default: tmds <= 10'b1010101100;
                endcase
            end else begin
                if (cnt == 5'sh0 || n1qm == 4'd4) begin
                    if (q_m[8] == 1'b0) begin
                        tmds <= {2'b10, ~q_m[7:0]};
                        cnt  <= cnt - diff_qm;
                    end else begin
                        tmds <= {2'b01, q_m[7:0]};
                        cnt  <= cnt + diff_qm;
                    end
                end else begin
                    if ((cnt > 5'sh0 && n1qm > 4'd4) || (cnt < 5'sh0 && n1qm < 4'd4)) begin
                        tmds <= {1'b1, q_m[8], ~q_m[7:0]};
                        cnt  <= cnt + $signed({3'b0, q_m[8], 1'b0}) - diff_qm;
                    end else begin
                        tmds <= {1'b0, q_m[8], q_m[7:0]};
                        cnt  <= cnt - $signed({3'b0, ~q_m[8], 1'b0}) + diff_qm;
                    end
                end
            end
        end
    end

endmodule
