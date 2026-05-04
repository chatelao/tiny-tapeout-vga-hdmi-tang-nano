/*
 * HDMI Packet Packer
 *
 * Takes a packet header and 4 subpackets, calculates ECC,
 * and maps them to the 32-pixel Data Island format.
 *
 * Based on HDMI 1.3a Section 5.4.3 and 5.4.4.
 */

`default_nettype none

module hdmi_packet_packer (
    input  wire [23:0] header_data,
    input  wire [55:0] sub0_data,
    input  wire [55:0] sub1_data,
    input  wire [55:0] sub2_data,
    input  wire [55:0] sub3_data,
    input  wire        hsync,
    input  wire        vsync,
    input  wire [4:0]  pixel_index, // 0 to 31
    output wire [3:0]  chan0_out,
    output wire [3:0]  chan1_out,
    output wire [3:0]  chan2_out
);

    wire [7:0] header_parity;
    wire [7:0] sub0_parity;
    wire [7:0] sub1_parity;
    wire [7:0] sub2_parity;
    wire [7:0] sub3_parity;

    // ECC Encoders
    hdmi_header_ecc ecc_header (
        .data(header_data),
        .parity(header_parity)
    );

    hdmi_subpacket_ecc ecc_sub0 (
        .data(sub0_data),
        .parity(sub0_parity)
    );

    hdmi_subpacket_ecc ecc_sub1 (
        .data(sub1_data),
        .parity(sub1_parity)
    );

    hdmi_subpacket_ecc ecc_sub2 (
        .data(sub2_data),
        .parity(sub2_parity)
    );

    hdmi_subpacket_ecc ecc_sub3 (
        .data(sub3_data),
        .parity(sub3_parity)
    );

    // Full 32-bit header and 64-bit subpackets
    // Note: Specification says parity is appended after data.
    // BCH(32,24): Header bits 0-23 are data, 24-31 are parity.
    // BCH(64,56): Subpacket bits 0-55 are data, 56-63 are parity.
    wire [31:0] header = {header_parity, header_data};
    wire [63:0] sub0   = {sub0_parity,   sub0_data};
    wire [63:0] sub1   = {sub1_parity,   sub1_data};
    wire [63:0] sub2   = {sub2_parity,   sub2_data};
    wire [63:0] sub3   = {sub3_parity,   sub3_data};

    // Mapping to channels as per HDMI 1.3a Table 5-11
    // Channel 0: [0, VSync, HSync, Header bit]
    assign chan0_out = {1'b0, vsync, hsync, header[pixel_index]};
    // Channel 1: [Subpacket 1 bit i+32, Subpacket 0 bit i+32, Subpacket 1 bit i, Subpacket 0 bit i]
    assign chan1_out = {sub1[pixel_index+32], sub0[pixel_index+32], sub1[pixel_index], sub0[pixel_index]};
    // Channel 2: [Subpacket 3 bit i+32, Subpacket 2 bit i+32, Subpacket 3 bit i, Subpacket 2 bit i]
    assign chan2_out = {sub3[pixel_index+32], sub2[pixel_index+32], sub3[pixel_index], sub2[pixel_index]};

endmodule
