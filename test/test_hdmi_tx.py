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
    dut.di_start.value = 0
    dut.di_header.value = 0
    dut.di_sub0.value = 0
    dut.di_sub1.value = 0
    dut.di_sub2.value = 0
    dut.di_sub3.value = 0
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

@cocotb.test()
async def test_hdmi_tx_data_island(dut):
    """Test Data Island transmission through HDMI TX"""
    pixel_clk = Clock(dut.clk_pixel, 39.68, unit="ns")
    serial_clk = Clock(dut.clk_x10, 3.968, unit="ns")

    cocotb.start_soon(pixel_clk.start())
    cocotb.start_soon(serial_clk.start())

    await reset_dut(dut)

    # Prepare Data Island packet
    dut.di_header.value = 0x123456
    dut.di_sub0.value = 0x0123456789ABCD
    dut.di_sub1.value = 0x11223344556677
    dut.di_sub2.value = 0x8899AABBCCDDEE
    dut.di_sub3.value = 0x00112233445566

    # Start transmission (VDE must be low)
    dut.vde.value = 0
    dut.di_start.value = 1
    await RisingEdge(dut.clk_pixel)
    dut.di_start.value = 0

    # Wait for sequence to start (active should go high)
    while not dut.di_active.value:
        await RisingEdge(dut.clk_pixel)

    # Capture first symbol of Preamble on Channel 1
    # Preamble should have CTL=2'b01 on Channel 1 (tmds=10'b0010101011)
    await RisingEdge(dut.clk_pixel)
    await Timer(1, unit="ns")

    pattern = ""
    for _ in range(10):
        pattern += str(dut.ser_d1.value)
        await RisingEdge(dut.clk_x10)
        await Timer(1, unit="ns")

    # CTL=2'b01 -> 10'b0010101011, LSB first -> "1101010100"
    expected_preamble = "1101010100"
    dut._log.info(f"Captured preamble pattern: {pattern}")
    assert pattern == expected_preamble, f"Expected preamble {expected_preamble}, got {pattern}"

    # Wait for Leading Guard Band (Preamble: 8px, Leading Guard: 2px)
    # We already did 1 RisingEdge(clk_pixel) to capture preamble (at cnt=1).
    # Total preamble is 8 (cnt 0 to 7).
    # To reach first guard band (state=LEAD_GUARD, cnt=0), we need 7 more edges.
    # But wait, 1 (already done) + 6 = 7. So 6 more edges to reach start of cnt=7.
    # Then 1 more edge to reach start of LEAD_GUARD cnt=0.
    for _ in range(7):
        await RisingEdge(dut.clk_pixel)

    # Now at first pixel of Lead Guard (Pixel 8)
    # Guard Band on Channel 0: 10'b1011001100
    # LSB first: "0011001101"
    # We are already at the rising edge of the pixel clock for the first guard band pixel.
    await Timer(1, unit="ns")
    pattern = ""
    for _ in range(10):
        pattern += str(dut.ser_d0.value)
        await RisingEdge(dut.clk_x10)
        await Timer(1, unit="ns")

    # The simulation pattern might be shifted relative to what we expect
    # Expected guard: 10'b1011001100 -> LSB first "0011001101"
    # Actually seen: "1110011001" which is 10'b1001100111
    # Wait, looking at the log: Expected guard 0011001101, got 1110011001
    # 1110011001 is "1001100111" LSB-first.
    # Actually "0011001101" is 10'b1011001100 LSB first.
    # Let's re-examine the HDMI 1.3a spec for Guard Bands.
    # Section 5.4.1 says:
    # Ch0: 10'b1011001100
    # Ch1,2: 10'b0100110011
    # My code in hdmi_data_island_framer.v:
    # chan0_tmds = 10'b1011001100;
    # chan1_tmds = 10'b0100110011;
    # chan2_tmds = 10'b0100110011;
    # Correct.

    expected_guard = "0011001101"
    dut._log.info(f"Captured guard band pattern: {pattern}")
    assert pattern == expected_guard, f"Expected guard {expected_guard}, got {pattern}"

    # Verify we are in the data phase
    # Wait until di_active goes low again
    while dut.di_active.value:
        await RisingEdge(dut.clk_pixel)

    dut._log.info("HDMI TX Data Island test passed")
