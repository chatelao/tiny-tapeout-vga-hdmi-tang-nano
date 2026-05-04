/*
 * HDMI Data Island Scheduler
 *
 * Manages the timing and multiplexing of Data Island packets.
 * Triggers AVI InfoFrames once per frame and ACR packets periodically.
 */

`default_nettype none

module hdmi_data_island_scheduler (
    input  wire        clk,
    input  wire        reset,
    input  wire        vde,
    input  wire        hsync,
    input  wire        vsync,
    // Data Island Interface to hdmi_tx
    output reg         di_start,
    output reg  [23:0] di_header,
    output reg  [55:0] di_sub0,
    output reg  [55:0] di_sub1,
    output reg  [55:0] di_sub2,
    output reg  [55:0] di_sub3,
    input  wire        di_active
);

    // Packet Generators
    wire [23:0] avi_header;
    wire [55:0] avi_sub0, avi_sub1, avi_sub2, avi_sub3;
    hdmi_avi_infoframe avi_gen (
        .header(avi_header),
        .sub0(avi_sub0),
        .sub1(avi_sub1),
        .sub2(avi_sub2),
        .sub3(avi_sub3)
    );

    wire [23:0] acr_header;
    wire [55:0] acr_sub0, acr_sub1, acr_sub2, acr_sub3;
    // For 25.2MHz pixel clock and 48kHz audio:
    // N = 6144, CTS = 25200 (exact)
    hdmi_acr_packet acr_gen (
        .cts(20'd25200),
        .n(20'd6144),
        .header(acr_header),
        .sub0(acr_sub0),
        .sub1(acr_sub1),
        .sub2(acr_sub2),
        .sub3(acr_sub3)
    );

    // Trigger Logic
    reg vsync_prev;
    reg avi_pending;
    reg hsync_prev;

    always @(posedge clk) begin
        if (reset) begin
            vsync_prev <= 1'b1;
            hsync_prev <= 1'b1;
            avi_pending <= 1'b0;
            di_start <= 1'b0;
            di_header <= 24'b0;
            di_sub0 <= 56'b0;
            di_sub1 <= 56'b0;
            di_sub2 <= 56'b0;
            di_sub3 <= 56'b0;
        end else begin
            vsync_prev <= vsync;
            hsync_prev <= hsync;

            // Trigger AVI InfoFrame on falling edge of vsync
            if (vsync_prev && !vsync) begin
                avi_pending <= 1'b1;
            end

            // Data Island Transmission State Machine
            if (!di_active && !di_start) begin
                if (avi_pending && !vde) begin
                    // Send AVI InfoFrame during blanking
                    di_start <= 1'b1;
                    di_header <= avi_header;
                    di_sub0 <= avi_sub0;
                    di_sub1 <= avi_sub1;
                    di_sub2 <= avi_sub2;
                    di_sub3 <= avi_sub3;
                    avi_pending <= 1'b0;
                end else if (!vde && hsync_prev && !hsync) begin
                    // Send ACR packet at the start of every horizontal sync period
                    di_start <= 1'b1;
                    di_header <= acr_header;
                    di_sub0 <= acr_sub0;
                    di_sub1 <= acr_sub1;
                    di_sub2 <= acr_sub2;
                    di_sub3 <= acr_sub3;
                end
            end else begin
                di_start <= 1'b0;
            end
        end
    end

endmodule
