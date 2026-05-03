/*
 * HDMI Packet Framer
 *
 * This module takes raw header and subpacket data and integrates the ECC
 * encoders to produce complete 32-bit headers and 64-bit subpackets.
 *
 * According to HDMI 1.3a Section 5.3.1:
 * - Header is 32 bits (24 bits data + 8 bits ECC)
 * - Each Subpacket is 64 bits (56 bits data + 8 bits ECC)
 */

`default_nettype none

module hdmi_packet_framer (
    input  wire [23:0] header_data,
    input  wire [55:0] subpacket0_data,
    input  wire [55:0] subpacket1_data,
    input  wire [55:0] subpacket2_data,
    input  wire [55:0] subpacket3_data,
    output wire [31:0] header,
    output wire [63:0] subpacket0,
    output wire [63:0] subpacket1,
    output wire [63:0] subpacket2,
    output wire [63:0] subpacket3
);

    wire [7:0] header_parity;
    wire [7:0] sp0_parity;
    wire [7:0] sp1_parity;
    wire [7:0] sp2_parity;
    wire [7:0] sp3_parity;

    // Header ECC
    hdmi_header_ecc header_ecc_inst (
        .data(header_data),
        .parity(header_parity)
    );
    assign header = {header_parity, header_data};

    // Subpacket 0 ECC
    hdmi_subpacket_ecc sp0_ecc_inst (
        .data(subpacket0_data),
        .parity(sp0_parity)
    );
    assign subpacket0 = {sp0_parity, subpacket0_data};

    // Subpacket 1 ECC
    hdmi_subpacket_ecc sp1_ecc_inst (
        .data(subpacket1_data),
        .parity(sp1_parity)
    );
    assign subpacket1 = {sp1_parity, subpacket1_data};

    // Subpacket 2 ECC
    hdmi_subpacket_ecc sp2_ecc_inst (
        .data(subpacket2_data),
        .parity(sp2_parity)
    );
    assign subpacket2 = {sp2_parity, subpacket2_data};

    // Subpacket 3 ECC
    hdmi_subpacket_ecc sp3_ecc_inst (
        .data(subpacket3_data),
        .parity(sp3_parity)
    );
    assign subpacket3 = {sp3_parity, subpacket3_data};

endmodule
