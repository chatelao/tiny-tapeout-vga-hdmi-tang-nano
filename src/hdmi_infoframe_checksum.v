/*
 * HDMI InfoFrame Checksum Calculator
 *
 * Calculates the 8-bit checksum for an HDMI InfoFrame.
 * The checksum is the 2's complement of the 8-bit sum of all bytes in the
 * InfoFrame (header + data), where the checksum byte itself is treated as 0.
 *
 * This module accepts the 3 header bytes and 4 subpackets (28 data bytes)
 * and calculates the checksum intended for the first data byte (DB1).
 */

`default_nettype none

module hdmi_infoframe_checksum (
    input  wire [7:0]  hb0,
    input  wire [7:0]  hb1,
    input  wire [7:0]  hb2,
    input  wire [55:0] sub0_data, // DB1..DB7 (DB1 is the checksum slot)
    input  wire [55:0] sub1_data, // DB8..DB14
    input  wire [55:0] sub2_data, // DB15..DB21
    input  wire [55:0] sub3_data, // DB22..DB28
    output wire [7:0]  checksum
);

    // 8-bit summation will naturally wrap around (modulo 256)
    wire [7:0] sum_h  = hb0 + hb1 + hb2;

    // We sum DB2 through DB28. DB1 (sub0_data[7:0]) is excluded as it is the checksum slot.
    wire [7:0] sum_s0 = sub0_data[15:8] + sub0_data[23:16] + sub0_data[31:24] +
                        sub0_data[39:32] + sub0_data[47:40] + sub0_data[55:48];

    wire [7:0] sum_s1 = sub1_data[7:0]  + sub1_data[15:8]  + sub1_data[23:16] +
                        sub1_data[31:24] + sub1_data[39:32] + sub1_data[47:40] + sub1_data[55:48];

    wire [7:0] sum_s2 = sub2_data[7:0]  + sub2_data[15:8]  + sub2_data[23:16] +
                        sub2_data[31:24] + sub2_data[39:32] + sub2_data[47:40] + sub2_data[55:48];

    wire [7:0] sum_s3 = sub3_data[7:0]  + sub3_data[15:8]  + sub3_data[23:16] +
                        sub3_data[31:24] + sub3_data[39:32] + sub3_data[47:40] + sub3_data[55:48];

    wire [7:0] total_sum = sum_h + sum_s0 + sum_s1 + sum_s2 + sum_s3;

    // Checksum is the 2's complement of the sum
    assign checksum = -total_sum;

endmodule
