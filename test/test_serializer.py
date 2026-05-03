import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import os

@cocotb.test()
async def test_serializer_basic(dut):
    """Test basic serialization functionality"""

    # Initialize clocks
    # Pixel clock (25.2 MHz) -> period ~39.68 ns
    # Serial clock (252 MHz) -> period ~3.968 ns
    pixel_clk = Clock(dut.clk_pixel, 39.68, unit="ns")
    serial_clk = Clock(dut.clk_x10, 3.968, unit="ns")

    cocotb.start_soon(pixel_clk.start())
    cocotb.start_soon(serial_clk.start())

    # Reset
    dut.reset.value = 1
    dut.tmds_d0.value = 0
    dut.tmds_d1.value = 0
    dut.tmds_d2.value = 0
    dut.tmds_clk.value = 0

    await Timer(100, unit="ns")
    await RisingEdge(dut.clk_pixel)
    dut.reset.value = 0

    # Wait for internal counter to reset and align
    await RisingEdge(dut.clk_pixel)
    await RisingEdge(dut.clk_x10)

    # Test patterns
    patterns = [
        0b1010101010,
        0b1111100000,
        0b0000011111,
        0x3FF,
        0x000
    ]

    for p in patterns:
        dut.tmds_d0.value = p
        await RisingEdge(dut.clk_pixel)
        # Wait a bit after pixel clock for the data to be latched in OSER10 model
        await Timer(1, unit="ns")

        # Check serialization (LSB first based on simulation model)
        for i in range(10):
            actual = dut.ser_d0.value
            expected = (p >> i) & 1
            assert actual == expected, f"Pattern {bin(p)} Bit {i} failed: expected {expected}, got {actual}"
            await RisingEdge(dut.clk_x10)
            await Timer(1, unit="ns")

    await Timer(100, unit="ns")
