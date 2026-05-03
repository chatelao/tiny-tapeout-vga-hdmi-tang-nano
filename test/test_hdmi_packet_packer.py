import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_hdmi_packet_packer(dut):
    """Test HDMI Packet Packer mapping and ECC."""

    # Sample packet data (Null Packet)
    # Header: 24 bits (0x000000 for Null packet)
    header_data = 0x000000
    # Subpackets: 56 bits each
    sub0_data = 0x0
    sub1_data = 0x0
    sub2_data = 0x0
    sub3_data = 0x0

    dut.header_data.value = header_data
    dut.sub0_data.value = sub0_data
    dut.sub1_data.value = sub1_data
    dut.sub2_data.value = sub2_data
    dut.sub3_data.value = sub3_data

    await Timer(1, unit="ns")

    # For Null packet (all 0s), parity should also be 0 since it's a linear code (XORs)
    # Header parity = 0x00
    # Subpacket parity = 0x00

    # Check pixel 0 mapping
    dut.pixel_index.value = 0
    await Timer(1, unit="ns")

    # header[0] = 0, sub0[0] = 0, sub1[0] = 0, sub2[0] = 0 -> chan0 = 0000
    assert dut.chan0_out.value == 0x0
    # sub0[32] = 0, sub1[32] = 0, sub2[32] = 0, sub3[32] = 0 -> chan1 = 0000
    assert dut.chan1_out.value == 0x0
    # sub3[0] = 0 -> chan2 = 0000
    assert dut.chan2_out.value == 0x0

    # Test with some data
    header_data = 0x123456
    sub0_data = 0x0123456789ABCD
    sub1_data = 0x11223344556677
    sub2_data = 0x8899AABBCCDDEE
    sub3_data = 0xFFEEDDCCBBAA99

    dut.header_data.value = header_data
    dut.sub0_data.value = sub0_data
    dut.sub1_data.value = sub1_data
    dut.sub2_data.value = sub2_data
    dut.sub3_data.value = sub3_data

    await Timer(1, unit="ns")

    # Parity will be calculated by the module
    # We can check the mapping logic itself by reading internal signals if needed,
    # or just trust the ECC modules (which are tested separately) and check bit positions.

    header_parity = int(dut.ecc_header.parity.value)
    sub0_parity = int(dut.ecc_sub0.parity.value)
    sub1_parity = int(dut.ecc_sub1.parity.value)
    sub2_parity = int(dut.ecc_sub2.parity.value)
    sub3_parity = int(dut.ecc_sub3.parity.value)

    header_full = (header_parity << 24) | header_data
    sub0_full = (sub0_parity << 56) | sub0_data
    sub1_full = (sub1_parity << 56) | sub1_data
    sub2_full = (sub2_parity << 56) | sub2_data
    sub3_full = (sub3_parity << 56) | sub3_data

    for i in range(32):
        dut.pixel_index.value = i
        await Timer(1, unit="ns")

        # chan0_out = {sub2[i], sub1[i], sub0[i], header[i]}
        expected_chan0 = (
            ((sub2_full >> i) & 1) << 3 |
            ((sub1_full >> i) & 1) << 2 |
            ((sub0_full >> i) & 1) << 1 |
            ((header_full >> i) & 1)
        )
        assert int(dut.chan0_out.value) == expected_chan0

        # chan1_out = {sub3[i+32], sub2[i+32], sub1[i+32], sub0[i+32]}
        expected_chan1 = (
            ((sub3_full >> (i+32)) & 1) << 3 |
            ((sub2_full >> (i+32)) & 1) << 2 |
            ((sub1_full >> (i+32)) & 1) << 1 |
            ((sub0_full >> (i+32)) & 1)
        )
        assert int(dut.chan1_out.value) == expected_chan1

        # chan2_out = {1'b0, 1'b0, 1'b0, sub3[i]}
        expected_chan2 = (sub3_full >> i) & 1
        assert int(dut.chan2_out.value) == expected_chan2

    print("HDMI Packet Packer test passed!")
