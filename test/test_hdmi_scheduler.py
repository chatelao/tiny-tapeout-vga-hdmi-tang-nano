import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, FallingEdge

@cocotb.test()
async def test_hdmi_scheduler_triggers(dut):
    """Test that the scheduler triggers AVI and ACR packets at correct times"""
    clock = Clock(dut.clk, 40, unit="ns")  # 25MHz approx
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    dut.vde.value = 0
    dut.hsync.value = 1
    dut.vsync.value = 1
    dut.di_active.value = 0
    await Timer(100, unit="ns")
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    # Test AVI trigger on VSync falling edge
    dut.vsync.value = 0
    await RisingEdge(dut.clk) # avi_pending becomes 1
    await RisingEdge(dut.clk) # di_start becomes 1
    await Timer(1, unit="ns")
    assert dut.di_start.value == 1, "AVI should trigger after VSync falling edge"
    assert int(dut.di_header.value) == 0x0D0282, "Header should be AVI InfoFrame"

    # Simulate di_active from framer
    dut.di_active.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.di_start.value == 0, "di_start should drop once active"

    # Finish packet
    dut.di_active.value = 0
    await RisingEdge(dut.clk)

    # Test ACR trigger on HSync falling edge
    dut.hsync.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.di_start.value == 1, "ACR should trigger on HSync falling edge during blanking"
    assert int(dut.di_header.value) == 0x000001, "Header should be ACR packet"

    dut.di_active.value = 1
    await RisingEdge(dut.clk)
    dut.di_active.value = 0
    await RisingEdge(dut.clk)

    # Test that triggers don't happen during VDE
    dut.vde.value = 1
    dut.hsync.value = 1
    await RisingEdge(dut.clk)
    dut.hsync.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.di_start.value == 0, "Triggers should be suppressed during VDE"

@cocotb.test()
async def test_hdmi_scheduler_prioritization(dut):
    """Test that AVI has priority over ACR if both pending"""
    clock = Clock(dut.clk, 40, unit="ns")
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    dut.vde.value = 0
    dut.hsync.value = 1
    dut.vsync.value = 1
    dut.di_active.value = 0
    await Timer(100, unit="ns")
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    # Trigger AVI pending
    dut.vsync.value = 0
    # But keep HSync high for now
    await RisingEdge(dut.clk)

    # Now trigger HSync low (both AVI pending and HSync trigger active)
    dut.hsync.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    assert dut.di_start.value == 1
    assert int(dut.di_header.value) == 0x0D0282, "AVI should have priority over ACR"
