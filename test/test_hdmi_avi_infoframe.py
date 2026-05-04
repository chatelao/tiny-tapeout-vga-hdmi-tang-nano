import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_hdmi_avi_infoframe(dut):
    """Test HDMI AVI InfoFrame generator for 640x480p"""

    await Timer(1, unit="ns")

    # Header: Type=0x82, Version=0x02, Length=0x0D
    # Header is {8'h0D, 8'h02, 8'h82}
    header = int(dut.header.value)
    assert header == 0x0D0282, f"Expected header 0x0D0282, got {hex(header)}"

    # Subpacket 0: {db7, db6, db5, db4, db3, db2, db1}
    # db1 = Checksum
    # db2 = 0x10, db3 = 0x18, db4 = 0x00, db5 = 0x01, db6 = 0x00, db7 = 0x00
    # Expected sum = 0x82 + 0x02 + 0x0D + 0x10 + 0x18 + 0x00 + 0x01 = 0xBA
    # Checksum (db1) = -0xBA & 0xFF = 0x46
    # sub0 = {0x00, 0x00, 0x01, 0x00, 0x18, 0x10, 0x46} = 0x00000100181046

    sub0 = int(dut.sub0.value)
    expected_sub0 = 0x00000100181046
    assert sub0 == expected_sub0, f"Expected sub0 {hex(expected_sub0)}, got {hex(sub0)}"

    sub1 = int(dut.sub1.value)
    assert sub1 == 0, f"Expected sub1 0, got {hex(sub1)}"

    sub2 = int(dut.sub2.value)
    assert sub2 == 0, f"Expected sub2 0, got {hex(sub2)}"

    sub3 = int(dut.sub3.value)
    assert sub3 == 0, f"Expected sub3 0, got {hex(sub3)}"

    dut._log.info("HDMI AVI InfoFrame generator test passed")
