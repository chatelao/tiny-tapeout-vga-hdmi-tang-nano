import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

async def reset_dut(dut):
    dut.reset.value = 1
    dut.red.value = 0
    dut.green.value = 0
    dut.blue.value = 0
    dut.hsync.value = 0
    dut.vsync.value = 0
    dut.vde.value = 0
    await Timer(100, unit="ns")
    await RisingEdge(dut.clk_pixel)
    dut.reset.value = 0
    await RisingEdge(dut.clk_pixel)

@cocotb.test()
async def test_hdmi_tx_basic(dut):
    """Test basic HDMI TX functionality and data transitions"""
    pixel_clk = Clock(dut.clk_pixel, 39.68, unit="ns") # ~25.2 MHz
    serial_clk = Clock(dut.clk_x10, 3.968, unit="ns") # ~252 MHz

    cocotb.start_soon(pixel_clk.start())
    cocotb.start_soon(serial_clk.start())

    await reset_dut(dut)

    # Test some data
    dut.red.value = 0xFF
    dut.green.value = 0x55
    dut.blue.value = 0xAA
    dut.vde.value = 1
    dut.hsync.value = 0
    dut.vsync.value = 0

    await RisingEdge(dut.clk_pixel)
    await RisingEdge(dut.clk_pixel) # Wait for pipeline

    # Check for activity on serial lines
    d0_seen_high = False
    d0_seen_low = False
    for _ in range(20):
        await RisingEdge(dut.clk_x10)
        if dut.ser_d0.value == 1: d0_seen_high = True
        if dut.ser_d0.value == 0: d0_seen_low = True

    assert d0_seen_high and d0_seen_low, "No transitions seen on ser_d0 during data period"
    dut._log.info("HDMI TX basic data test passed")

@cocotb.test()
async def test_hdmi_tx_control(dut):
    """Test HDMI TX control period symbols"""
    pixel_clk = Clock(dut.clk_pixel, 39.68, unit="ns")
    serial_clk = Clock(dut.clk_x10, 3.968, unit="ns")

    cocotb.start_soon(pixel_clk.start())
    cocotb.start_soon(serial_clk.start())

    await reset_dut(dut)

    # Control period: VDE=0
    # Case: HSync=1, VSync=0 -> ctrl=2'b01
    dut.vde.value = 0
    dut.hsync.value = 1
    dut.vsync.value = 0

    # Wait for pipeline (encoder has 1 cycle delay)
    await RisingEdge(dut.clk_pixel)
    await RisingEdge(dut.clk_pixel)

    # Synchronize to pixel clock edge to start capturing
    await RisingEdge(dut.clk_pixel)
    await Timer(1, unit="ns") # Offset from edge

    pattern = ""
    for _ in range(10):
        pattern += str(dut.ser_d0.value)
        await RisingEdge(dut.clk_x10)
        await Timer(1, unit="ns")

    # ctrl=2'b01 -> tmds=10'b0010101011
    # LSB first: 1, 1, 0, 1, 0, 1, 0, 1, 0, 0 -> "1101010100"
    expected_pattern = "1101010100"

    dut._log.info(f"Captured pattern for ctrl=2'b01: {pattern}")
    assert pattern == expected_pattern, f"Expected {expected_pattern}, got {pattern}"

    # Case: HSync=0, VSync=0 -> ctrl=2'b00
    dut.hsync.value = 0
    await RisingEdge(dut.clk_pixel)
    await RisingEdge(dut.clk_pixel)
    await RisingEdge(dut.clk_pixel)
    await Timer(1, unit="ns")

    pattern = ""
    for _ in range(10):
        pattern += str(dut.ser_d0.value)
        await RisingEdge(dut.clk_x10)
        await Timer(1, unit="ns")

    # ctrl=2'b00 -> tmds=10'b1101010100
    # LSB first: 0, 0, 1, 0, 1, 0, 1, 0, 1, 1 -> "0010101011"
    expected_pattern = "0010101011"
    dut._log.info(f"Captured pattern for ctrl=2'b00: {pattern}")
    assert pattern == expected_pattern, f"Expected {expected_pattern}, got {pattern}"

    dut._log.info("HDMI TX control pattern test passed")
