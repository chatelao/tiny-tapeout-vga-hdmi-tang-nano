/*
 * HDMI AVI InfoFrame Generator
 *
 * Generates an AVI InfoFrame for 640x480p (VIC 1).
 * Based on CTA-861 and HDMI 1.3a specifications.
 */

`default_nettype none

module hdmi_avi_infoframe (
    output wire [23:0] header,
    output wire [55:0] sub0,
    output wire [55:0] sub1,
    output wire [55:0] sub2,
    output wire [55:0] sub3
);

    // Header: Type=0x82, Version=0x02, Length=0x0D
    assign header = {8'h0D, 8'h02, 8'h82};

    // Data Bytes (DB)
    wire [7:0] db1; // Checksum
    wire [7:0] db2 = 8'h10; // RGB, Active Format Info = 1, Scan Info = 0
    wire [7:0] db3 = 8'h18; // Aspect Ratio = 4:3 (1), Active Format Aspect Ratio = 4:3 (8)
    wire [7:0] db4 = 8'h00; // Standard Colorimetry
    wire [7:0] db5 = 8'h01; // VIC 1 (640x480p)
    wire [7:0] db6 = 8'h00;
    wire [7:0] db7 = 8'h00;
    wire [7:0] db8 = 8'h00;
    wire [7:0] db9 = 8'h00;
    wire [7:0] db10 = 8'h00;
    wire [7:0] db11 = 8'h00;
    wire [7:0] db12 = 8'h00;
    wire [7:0] db13 = 8'h00;
    wire [7:0] db14 = 8'h00;

    // Checksum calculation
    hdmi_infoframe_checksum checksum_inst (
        .hb0(header[7:0]),
        .hb1(header[15:8]),
        .hb2(header[23:16]),
        .sub0_data({db7, db6, db5, db4, db3, db2, 8'h00}), // DB1 slot is 0 for sum
        .sub1_data({db14, db13, db12, db11, db10, db9, db8}),
        .sub2_data(56'h0),
        .sub3_data(56'h0),
        .checksum(db1)
    );

    // Packing into subpackets
    assign sub0 = {db7, db6, db5, db4, db3, db2, db1};
    assign sub1 = {db14, db13, db12, db11, db10, db9, db8};
    assign sub2 = 56'h0;
    assign sub3 = 56'h0;

endmodule
