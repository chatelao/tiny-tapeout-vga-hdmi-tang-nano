import cocotb
from cocotb.triggers import Timer
import random

def generate_hdmi_ecc_expected(data_int, num_bits):
    # G(x) = x^8 + x^6 + x^5 + x + 1
    # Polynomial: 0x63 (without the implicit x^8)
    poly = 0x63
    state = 0

    for i in range(num_bits):
        bit = (data_int >> i) & 1
        feedback = bit ^ ((state >> 7) & 1)
        state = (state << 1) & 0xFF
        if feedback:
            state ^= poly

    return state

@cocotb.test()
async def test_hdmi_header_ecc(dut):
    """Test HDMI Header ECC (BCH 32,24)"""

    # Test cases: all zeros, all ones, and some random patterns
    test_cases = [0, (1 << 24) - 1]
    for _ in range(20):
        test_cases.append(random.getrandbits(24))

    for data in test_cases:
        dut.data.value = data
        await Timer(1, unit="ns")

        expected = generate_hdmi_ecc_expected(data, 24)
        actual = dut.parity.value.to_unsigned()

        assert actual == expected, f"Header ECC error: Data={data:06x}, Expected={expected:02x}, Actual={actual:02x}"

@cocotb.test()
async def test_hdmi_subpacket_ecc(dut):
    """Test HDMI Subpacket ECC (BCH 64,56)"""

    # Test cases: all zeros, all ones, and some random patterns
    test_cases = [0, (1 << 56) - 1]
    for _ in range(20):
        test_cases.append(random.getrandbits(56))

    for data in test_cases:
        dut.data.value = data
        await Timer(1, unit="ns")

        expected = generate_hdmi_ecc_expected(data, 56)
        actual = dut.parity.value.to_unsigned()

        assert actual == expected, f"Subpacket ECC error: Data={data:014x}, Expected={expected:02x}, Actual={actual:02x}"
