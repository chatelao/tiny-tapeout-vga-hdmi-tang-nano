/*
 * HDMI Data Island FSM
 *
 * Manages the timing for a single HDMI Data Island packet:
 * - Preamble (8 pixels)
 * - Leading Guard Band (2 pixels)
 * - Data (32 pixels)
 * - Trailing Guard Band (2 pixels)
 *
 * Based on HDMI 1.3a Section 5.4.1.
 */

`default_nettype none

module hdmi_data_island_fsm (
    input  wire       clk,
    input  wire       reset,
    input  wire       start,      // Trigger to start a packet sequence
    output reg [2:0]  state,
    output reg [4:0]  cnt,        // Internal counter for current state
    output wire [4:0] packet_pixel_index, // 0-31 for hdmi_packet_packer
    output wire       active      // High during any part of the sequence
);

    // States
    localparam STATE_IDLE        = 3'd0;
    localparam STATE_PREAMBLE    = 3'd1; // 8 pixels
    localparam STATE_LEAD_GUARD  = 3'd2; // 2 pixels
    localparam STATE_DATA        = 3'd3; // 32 pixels
    localparam STATE_TRAIL_GUARD = 3'd4; // 2 pixels

    assign active = (state != STATE_IDLE);
    assign packet_pixel_index = (state == STATE_DATA) ? cnt : 5'd0;

    always @(posedge clk) begin
        if (reset) begin
            state <= STATE_IDLE;
            cnt   <= 5'd0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (start) begin
                        state <= STATE_PREAMBLE;
                        cnt   <= 5'd0;
                    end
                end

                STATE_PREAMBLE: begin
                    if (cnt == 5'd7) begin
                        state <= STATE_LEAD_GUARD;
                        cnt   <= 5'd0;
                    end else begin
                        cnt <= cnt + 5'd1;
                    end
                end

                STATE_LEAD_GUARD: begin
                    if (cnt == 5'd1) begin
                        state <= STATE_DATA;
                        cnt   <= 5'd0;
                    end else begin
                        cnt <= cnt + 5'd1;
                    end
                end

                STATE_DATA: begin
                    if (cnt == 5'd31) begin
                        state <= STATE_TRAIL_GUARD;
                        cnt   <= 5'd0;
                    end else begin
                        cnt <= cnt + 5'd1;
                    end
                end

                STATE_TRAIL_GUARD: begin
                    if (cnt == 5'd1) begin
                        state <= STATE_IDLE;
                        cnt   <= 5'd0;
                    end else begin
                        cnt <= cnt + 5'd1;
                    end
                end

                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
