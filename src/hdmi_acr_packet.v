/*
 * HDMI Audio Clock Regeneration (ACR) Packet Generator
 *
 * Generates an ACR packet containing CTS and N values.
 * Based on HDMI 1.3a Section 5.3.3 and Table 5-10.
 */

`default_nettype none

module hdmi_acr_packet (
    input  wire [19:0] cts,
    input  wire [19:0] n,
    output wire [23:0] header,
    output wire [55:0] sub0,
    output wire [55:0] sub1,
    output wire [55:0] sub2,
    output wire [55:0] sub3
);

    // Header: HB0=0x01 (Packet Type), HB1=0x00, HB2=0x00
    assign header = {8'h00, 8'h00, 8'h01};

    // Subpacket layout (HDMI 1.3a Table 5-10):
    // Byte 0: 0x00
    // Byte 1: [7:4] Reserved (0), [3:0] CTS [19:16]
    // Byte 2: [7:0] CTS [15:8]
    // Byte 3: [7:0] CTS [7:0]
    // Byte 4: [7:4] Reserved (0), [3:0] N [19:16]
    // Byte 5: [7:0] N [15:8]
    // Byte 6: [7:0] N [7:0]

    wire [55:0] acr_subpacket = {
        n[7:0],           // Byte 6
        n[15:8],          // Byte 5
        4'b0, n[19:16],   // Byte 4
        cts[7:0],         // Byte 3
        cts[15:8],        // Byte 2
        4'b0, cts[19:16], // Byte 1
        8'h00             // Byte 0
    };

    // All four subpackets are identical for ACR
    assign sub0 = acr_subpacket;
    assign sub1 = acr_subpacket;
    assign sub2 = acr_subpacket;
    assign sub3 = acr_subpacket;

endmodule
