/*
 * HDMI Data Island Framer
 *
 * Integrates the FSM, Packet Packer, and TERC4 encoders to
 * produce the full 44-pixel Data Island sequence.
 */

`default_nettype none

module hdmi_data_island_framer (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [23:0] header_data,
    input  wire [55:0] sub0_data,
    input  wire [55:0] sub1_data,
    input  wire [55:0] sub2_data,
    input  wire [55:0] sub3_data,
    input  wire        hsync,
    input  wire        vsync,
    output reg  [9:0]  chan0_tmds,
    output reg  [9:0]  chan1_tmds,
    output reg  [9:0]  chan2_tmds,
    output wire        active
);

    // States from FSM
    localparam STATE_IDLE        = 3'd0;
    localparam STATE_PREAMBLE    = 3'd1;
    localparam STATE_LEAD_GUARD  = 3'd2;
    localparam STATE_DATA        = 3'd3;
    localparam STATE_TRAIL_GUARD = 3'd4;

    wire [2:0] state;
    wire [4:0] cnt;
    wire [4:0] packet_pixel_index;

    hdmi_data_island_fsm fsm_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .state(state),
        .cnt(cnt),
        .packet_pixel_index(packet_pixel_index),
        .active(active)
    );

    wire [3:0] packer_chan0, packer_chan1, packer_chan2;
    hdmi_packet_packer packer_inst (
        .header_data(header_data),
        .sub0_data(sub0_data),
        .sub1_data(sub1_data),
        .sub2_data(sub2_data),
        .sub3_data(sub3_data),
        .hsync(hsync),
        .vsync(vsync),
        .pixel_index(packet_pixel_index),
        .chan0_out(packer_chan0),
        .chan1_out(packer_chan1),
        .chan2_out(packer_chan2)
    );

    wire [9:0] terc4_chan0, terc4_chan1, terc4_chan2;
    terc4_encoder enc0 (.data(packer_chan0), .tmds(terc4_chan0));
    terc4_encoder enc1 (.data(packer_chan1), .tmds(terc4_chan1));
    terc4_encoder enc2 (.data(packer_chan2), .tmds(terc4_chan2));

    // Control Symbols
    function [9:0] get_ctrl_symbol(input [1:0] ctrl);
        case (ctrl)
            2'b00:   get_ctrl_symbol = 10'b1101010100;
            2'b01:   get_ctrl_symbol = 10'b0010101011;
            2'b10:   get_ctrl_symbol = 10'b0101010100;
            default: get_ctrl_symbol = 10'b1010101100;
        endcase
    endfunction

    always @(*) begin
        case (state)
            STATE_PREAMBLE: begin
                // Data Island Preamble: CTL0=1, CTL1=0, CTL2=1, CTL3=0
                // CTL0/1 on Channel 1, CTL2/3 on Channel 2
                chan0_tmds = get_ctrl_symbol({vsync, hsync});
                chan1_tmds = 10'b0010101011; // CTL 2'b01
                chan2_tmds = 10'b0010101011; // CTL 2'b01
            end

            STATE_LEAD_GUARD, STATE_TRAIL_GUARD: begin
                chan0_tmds = 10'b1011001100;
                chan1_tmds = 10'b0100110011;
                chan2_tmds = 10'b0100110011;
            end

            STATE_DATA: begin
                chan0_tmds = terc4_chan0;
                chan1_tmds = terc4_chan1;
                chan2_tmds = terc4_chan2;
            end

            default: begin
                chan0_tmds = 10'b0;
                chan1_tmds = 10'b0;
                chan2_tmds = 10'b0;
            end
        endcase
    end

endmodule
