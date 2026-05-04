import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_hdmi_data_island_framer(dut):
    """Test HDMI Data Island Framer sequence and encoding"""
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    dut.start.value = 0
    dut.header_data.value = 0
    dut.sub0_data.value = 0
    dut.sub1_data.value = 0
    dut.sub2_data.value = 0
    dut.sub3_data.value = 0
    dut.hsync.value = 0
    dut.vsync.value = 0

    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    # Start sequence
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    # Allow logic to settle after clock edge
    await Timer(1, unit="ns")

    # Verify Preamble (8 pixels)
    for i in range(8):
        assert int(dut.active.value) == 1, f"Expected active at preamble pixel {i}"
        # In Preamble, chan1 uses CTL 2'b01 -> 10'b0010101011
        assert int(dut.chan1_tmds.value) == 0b0010101011
        # In Preamble, chan2 uses CTL 2'b01 -> 10'b0010101011
        assert int(dut.chan2_tmds.value) == 0b0010101011
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

    # Verify Leading Guard Band (2 pixels)
    for i in range(2):
        assert int(dut.chan0_tmds.value) == 0b1011001100, f"Expected lead guard on chan0 at pixel {i}"
        assert int(dut.chan1_tmds.value) == 0b0100110011
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

    # Verify Data (32 pixels)
    for i in range(32):
        # Since data is all 0, TERC4(0) = 10'b1010011100
        assert int(dut.chan0_tmds.value) == 0b1010011100, f"Expected data TERC4 on chan0 at pixel {i}, got {int(dut.chan0_tmds.value):010b}"
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

    # Verify Trailing Guard Band (2 pixels)
    for i in range(2):
        assert int(dut.chan0_tmds.value) == 0b1011001100, f"Expected trail guard on chan0 at pixel {i}"
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

    assert int(dut.active.value) == 0
    print("HDMI Data Island Framer test passed!")
