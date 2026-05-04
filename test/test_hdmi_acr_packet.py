import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_hdmi_acr_packet(dut):
    """Test HDMI ACR Packet generator"""

    # Example values for 48kHz audio with 25.2MHz pixel clock
    # Reference: HDMI 1.3a Table 7-1
    # For 25.2MHz pixel clock: N=6144, CTS=25200
    n_val = 6144
    cts_val = 25200

    dut.n.value = n_val
    dut.cts.value = cts_val

    await Timer(1, unit="ns")

    # Header: Type=0x01, HB1=0x00, HB2=0x00 -> 0x000001
    header = int(dut.header.value)
    assert header == 0x000001, f"Expected header 0x000001, got {hex(header)}"

    # Subpacket 0-3 should be identical
    expected_sub = (n_val & 0xFF) << 48 | \
                   ((n_val >> 8) & 0xFF) << 40 | \
                   ((n_val >> 16) & 0x0F) << 32 | \
                   (cts_val & 0xFF) << 24 | \
                   ((cts_val >> 8) & 0xFF) << 16 | \
                   ((cts_val >> 16) & 0x0F) << 8 | \
                   0x00

    # manual calculation for 6144 (0x1800), 25200 (0x6270):
    # n[7:0] = 0x00
    # n[15:8] = 0x18
    # n[19:16] = 0x0
    # cts[7:0] = 0x70
    # cts[15:8] = 0x62
    # cts[19:16] = 0x0
    # sub = {0x00, 0x18, 0x00, 0x70, 0x62, 0x00, 0x00}
    # sub = 0x00180070620000

    assert int(dut.sub0.value) == expected_sub, f"Expected sub0 {hex(expected_sub)}, got {hex(int(dut.sub0.value))}"
    assert int(dut.sub1.value) == expected_sub, f"Expected sub1 {hex(expected_sub)}, got {hex(int(dut.sub1.value))}"
    assert int(dut.sub2.value) == expected_sub, f"Expected sub2 {hex(expected_sub)}, got {hex(int(dut.sub2.value))}"
    assert int(dut.sub3.value) == expected_sub, f"Expected sub3 {hex(expected_sub)}, got {hex(int(dut.sub3.value))}"

    dut._log.info("HDMI ACR packet generator test passed")
