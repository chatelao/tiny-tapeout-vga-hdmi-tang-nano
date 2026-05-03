/*
 * HDMI BCH ECC Encoders
 *
 * Implements BCH(32, 24) for Header and BCH(64, 56) for Subpackets.
 * Generator Polynomial: G(x) = 1 + x + x^5 + x^6 + x^8 (0x163)
 */

`default_nettype none

module hdmi_header_ecc (
    input  wire [23:0] data,
    output wire [7:0]  parity
);

    assign parity[0] = data[1] ^ data[2] ^ data[4] ^ data[8] ^ data[9] ^ data[10] ^ data[11] ^ data[13] ^ data[14] ^ data[15] ^ data[19] ^ data[20] ^ data[21] ^ data[23];
    assign parity[1] = data[0] ^ data[2] ^ data[3] ^ data[4] ^ data[7] ^ data[11] ^ data[12] ^ data[15] ^ data[18] ^ data[21] ^ data[22] ^ data[23];
    assign parity[2] = data[1] ^ data[2] ^ data[3] ^ data[6] ^ data[10] ^ data[11] ^ data[14] ^ data[17] ^ data[20] ^ data[21] ^ data[22];
    assign parity[3] = data[0] ^ data[1] ^ data[2] ^ data[5] ^ data[9] ^ data[10] ^ data[13] ^ data[16] ^ data[19] ^ data[20] ^ data[21];
    assign parity[4] = data[0] ^ data[1] ^ data[4] ^ data[8] ^ data[9] ^ data[12] ^ data[15] ^ data[18] ^ data[19] ^ data[20];
    assign parity[5] = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[7] ^ data[9] ^ data[10] ^ data[13] ^ data[15] ^ data[17] ^ data[18] ^ data[20] ^ data[21] ^ data[23];
    assign parity[6] = data[0] ^ data[3] ^ data[4] ^ data[6] ^ data[10] ^ data[11] ^ data[12] ^ data[13] ^ data[15] ^ data[16] ^ data[17] ^ data[21] ^ data[22] ^ data[23];
    assign parity[7] = data[2] ^ data[3] ^ data[5] ^ data[9] ^ data[10] ^ data[11] ^ data[12] ^ data[14] ^ data[15] ^ data[16] ^ data[20] ^ data[21] ^ data[22];

endmodule

module hdmi_subpacket_ecc (
    input  wire [55:0] data,
    output wire [7:0]  parity
);

    assign parity[0] = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[8] ^ data[13] ^ data[14] ^ data[15] ^ data[18] ^ data[19] ^ data[20] ^ data[21] ^ data[26] ^ data[27] ^ data[29] ^ data[30] ^ data[33] ^ data[34] ^ data[36] ^ data[40] ^ data[41] ^ data[42] ^ data[43] ^ data[45] ^ data[46] ^ data[47] ^ data[51] ^ data[52] ^ data[53] ^ data[55];
    assign parity[1] = data[4] ^ data[5] ^ data[6] ^ data[7] ^ data[8] ^ data[12] ^ data[15] ^ data[17] ^ data[21] ^ data[25] ^ data[27] ^ data[28] ^ data[30] ^ data[32] ^ data[34] ^ data[35] ^ data[36] ^ data[39] ^ data[43] ^ data[44] ^ data[47] ^ data[50] ^ data[53] ^ data[54] ^ data[55];
    assign parity[2] = data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ data[11] ^ data[14] ^ data[16] ^ data[20] ^ data[24] ^ data[26] ^ data[27] ^ data[29] ^ data[31] ^ data[33] ^ data[34] ^ data[35] ^ data[38] ^ data[42] ^ data[43] ^ data[46] ^ data[49] ^ data[52] ^ data[53] ^ data[54];
    assign parity[3] = data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[10] ^ data[13] ^ data[15] ^ data[19] ^ data[23] ^ data[25] ^ data[26] ^ data[28] ^ data[30] ^ data[32] ^ data[33] ^ data[34] ^ data[37] ^ data[41] ^ data[42] ^ data[45] ^ data[48] ^ data[51] ^ data[52] ^ data[53];
    assign parity[4] = data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[9] ^ data[12] ^ data[14] ^ data[18] ^ data[22] ^ data[24] ^ data[25] ^ data[27] ^ data[29] ^ data[31] ^ data[32] ^ data[33] ^ data[36] ^ data[40] ^ data[41] ^ data[44] ^ data[47] ^ data[50] ^ data[51] ^ data[52];
    assign parity[5] = data[6] ^ data[11] ^ data[14] ^ data[15] ^ data[17] ^ data[18] ^ data[19] ^ data[20] ^ data[23] ^ data[24] ^ data[27] ^ data[28] ^ data[29] ^ data[31] ^ data[32] ^ data[33] ^ data[34] ^ data[35] ^ data[36] ^ data[39] ^ data[41] ^ data[42] ^ data[45] ^ data[47] ^ data[49] ^ data[50] ^ data[52] ^ data[53] ^ data[55];
    assign parity[6] = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[8] ^ data[10] ^ data[15] ^ data[16] ^ data[17] ^ data[20] ^ data[21] ^ data[22] ^ data[23] ^ data[28] ^ data[29] ^ data[31] ^ data[32] ^ data[35] ^ data[36] ^ data[38] ^ data[42] ^ data[43] ^ data[44] ^ data[45] ^ data[47] ^ data[48] ^ data[49] ^ data[53] ^ data[54] ^ data[55];
    assign parity[7] = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[7] ^ data[9] ^ data[14] ^ data[15] ^ data[16] ^ data[19] ^ data[20] ^ data[21] ^ data[22] ^ data[27] ^ data[28] ^ data[30] ^ data[31] ^ data[34] ^ data[35] ^ data[37] ^ data[41] ^ data[42] ^ data[43] ^ data[44] ^ data[46] ^ data[47] ^ data[48] ^ data[52] ^ data[53] ^ data[54];

endmodule
