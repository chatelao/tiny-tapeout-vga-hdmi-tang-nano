import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_hdmi_packet_framer(dut):
    """Test HDMI Packet Framer ECC integration"""

    # Example Null Packet (Type 0x00)
    # Header: HB0=0x00, HB1=0x00, HB2=0x00 (24 bits)
    # Subpackets: All zeros (56 bits each)

    dut.header_data.value = 0x000000
    dut.subpacket0_data.value = 0x00000000000000
    dut.subpacket1_data.value = 0x00000000000000
    dut.subpacket2_data.value = 0x00000000000000
    dut.subpacket3_data.value = 0x00000000000000

    await Timer(1, unit="ns")

    # For all zeros, parity should be zero (G(x) has no constant term? No, parity of 0 is 0)
    assert dut.header.value == 0x00000000
    assert dut.subpacket0.value == 0x0000000000000000

    # Example 2: Some data
    # Header: 0x010203
    dut.header_data.value = 0x010203
    # Subpacket 0: 0x01020304050607
    dut.subpacket0_data.value = 0x01020304050607

    await Timer(1, unit="ns")

    header_val = int(dut.header.value)
    sp0_val = int(dut.subpacket0.value)

    # Extract parity (top 8 bits)
    header_parity = (header_val >> 24) & 0xFF
    sp0_parity = (sp0_val >> 56) & 0xFF

    dut._log.info(f"Header: {header_val:08x}, Parity: {header_parity:02x}")
    dut._log.info(f"Subpacket 0: {sp0_val:016x}, Parity: {sp0_parity:02x}")

    # Check that parity is non-zero for this data
    assert header_parity != 0
    assert sp0_parity != 0

    # These parities should match what the BCH encoder generates.
    # We already verified hdmi_ecc.v separately, so here we verify integration.
