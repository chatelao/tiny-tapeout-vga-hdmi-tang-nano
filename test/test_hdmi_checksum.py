import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_hdmi_checksum(dut):
    """Test HDMI InfoFrame checksum calculation"""

    # Example AVI InfoFrame for 640x480p
    # HB0 = 0x82, HB1 = 0x02, HB2 = 0x0D
    # DB1 = Checksum (to be calculated)
    # DB2 = 0x10 (Scan info)
    # DB3 = 0x18 (Aspect ratio)
    # DB4 = 0x00
    # DB5 = 0x01 (VIC 1)
    # DB6..DB28 = 0

    dut.hb0.value = 0x82
    dut.hb1.value = 0x02
    dut.hb2.value = 0x0D

    # DB1 is at sub0[7:0], we set it to 0 as it shouldn't affect calculation
    # DB2..DB7 are sub0[15:8]..sub0[55:48]
    sub0 = 0x00000100181000 # DB7, DB6, DB5, DB4, DB3, DB2, DB1
    dut.sub0_data.value = sub0
    dut.sub1_data.value = 0
    dut.sub2_data.value = 0
    dut.sub3_data.value = 0

    await Timer(1, unit="ns")

    # Expected sum = 0x82 + 0x02 + 0x0D + 0x10 + 0x18 + 0x00 + 0x01 = 0xC0
    # Checksum = -0xC0 & 0xFF = 0x40

    expected_sum = (0x82 + 0x02 + 0x0D + 0x10 + 0x18 + 0x00 + 0x01) & 0xFF
    expected_checksum = (-expected_sum) & 0xFF

    assert dut.checksum.value == expected_checksum, f"Expected {hex(expected_checksum)}, got {hex(int(dut.checksum.value))}"

    # Test with non-zero sub1..sub3
    dut.sub1_data.value = 0x01020304050607
    dut.sub2_data.value = 0x08090A0B0C0D0E
    dut.sub3_data.value = 0x0F101112131415

    await Timer(1, unit="ns")

    sum_h = 0x82 + 0x02 + 0x0D
    sum_s0 = 0x10 + 0x18 + 0x00 + 0x01 + 0x00 + 0x00 # DB2..DB7
    sum_s1 = 0x07 + 0x06 + 0x05 + 0x04 + 0x03 + 0x02 + 0x01 # DB8..DB14 (LSB first in sub1_data)
    sum_s2 = 0x0E + 0x0D + 0x0C + 0x0B + 0x0A + 0x09 + 0x08 # DB15..DB21
    sum_s3 = 0x15 + 0x14 + 0x13 + 0x12 + 0x11 + 0x10 + 0x0F # DB22..DB28

    total_sum = (sum_h + sum_s0 + sum_s1 + sum_s2 + sum_s3) & 0xFF
    expected_checksum = (-total_sum) & 0xFF

    assert dut.checksum.value == expected_checksum, f"Expected {hex(expected_checksum)}, got {hex(int(dut.checksum.value))}"
