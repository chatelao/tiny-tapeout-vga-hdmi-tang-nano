import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_hdmi_data_island_fsm(dut):
    """Test HDMI Data Island FSM timing"""
    clock = Clock(dut.clk, 40, unit="ns") # 25 MHz
    cocotb.start_soon(clock.start())

    # States from Verilog
    STATE_IDLE = 0
    STATE_PREAMBLE = 1
    STATE_LEAD_GUARD = 2
    STATE_DATA = 3
    STATE_TRAIL_GUARD = 4

    # Initial Reset
    dut.reset.value = 1
    dut.start.value = 0
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    assert int(dut.state.value) == STATE_IDLE
    assert int(dut.active.value) == 0

    # Start sequence
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    # Verify Preamble (8 pixels)
    for i in range(8):
        await Timer(1, unit="ns") # Allow combinational logic to settle
        assert int(dut.state.value) == STATE_PREAMBLE
        assert int(dut.cnt.value) == i
        assert int(dut.active.value) == 1
        await RisingEdge(dut.clk)

    # Verify Leading Guard Band (2 pixels)
    for i in range(2):
        await Timer(1, unit="ns")
        assert int(dut.state.value) == STATE_LEAD_GUARD
        assert int(dut.cnt.value) == i
        await RisingEdge(dut.clk)

    # Verify Data (32 pixels)
    for i in range(32):
        await Timer(1, unit="ns")
        assert int(dut.state.value) == STATE_DATA
        assert int(dut.cnt.value) == i
        assert int(dut.packet_pixel_index.value) == i
        await RisingEdge(dut.clk)

    # Verify Trailing Guard Band (2 pixels)
    for i in range(2):
        await Timer(1, unit="ns")
        assert int(dut.state.value) == STATE_TRAIL_GUARD
        assert int(dut.cnt.value) == i
        await RisingEdge(dut.clk)

    # Back to IDLE
    await Timer(1, unit="ns")
    assert int(dut.state.value) == STATE_IDLE
    assert int(dut.active.value) == 0
