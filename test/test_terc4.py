import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_terc4_encoding(dut):
    """Test TERC4 encoding mapping"""

    # HDMI 1.3a Table 5-11
    expected_mappings = {
        0x0: 0b1010011100,
        0x1: 0b1001100111,
        0x2: 0b1010010110,
        0x3: 0b1010101011,
        0x4: 0b1011100100,
        0x5: 0b1011100110,
        0x6: 0b1011100101,
        0x7: 0b1011100111,
        0x8: 0b1011011100,
        0x9: 0b1011001111,
        0xA: 0b1011010110,
        0xB: 0b1011010111,
        0xC: 0b1011101100,
        0xD: 0b1011101110,
        0xE: 0b1011101101,
        0xF: 0b1011101111,
    }

    for data_in, tmds_out in expected_mappings.items():
        dut.data.value = data_in
        await Timer(1, unit="ns")
        assert dut.tmds.value == tmds_out, f"Error: Input {data_in:X} expected {tmds_out:010b} but got {dut.tmds.value}"
        dut._log.info(f"Input {data_in:X} -> Output {dut.tmds.value}")
