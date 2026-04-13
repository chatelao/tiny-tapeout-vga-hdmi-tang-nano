import cocotb
from cocotb.triggers import Timer, RisingEdge

@cocotb.test()
async def test_tt_um_minimal_echo(dut):
    """Test the minimal echo module"""

    dut._log.info("Starting test_tt_um_minimal_echo")

    # Initial values
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 0

    # Wait for a bit
    await Timer(10, unit="ns")
    dut.rst_n.value = 1
    await Timer(10, unit="ns")

    # Test echoing ui_in to uo_out
    for i in range(256):
        dut.ui_in.value = i
        await Timer(1, unit="ns")
        assert dut.uo_out.value == i, f"Expected {i}, got {dut.uo_out.value}"

    # Test UIO outputs
    # assign uio_out = 8'b10101100;
    # assign uio_oe  = 8'b11111111;
    assert dut.uio_out.value == 0b10101100, f"Expected 0b10101100, got {dut.uio_out.value}"
    assert dut.uio_oe.value == 0b11111111, f"Expected 0b11111111, got {dut.uio_oe.value}"

    dut._log.info("Test passed!")
