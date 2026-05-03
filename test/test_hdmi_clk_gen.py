import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import logging

@cocotb.test()
async def test_hdmi_clk_gen(dut):
    """Test HDMI clock generation frequencies"""

    # 27 MHz input clock (Period approx 37.037 ns)
    # Using 37038 ps to be divisible by 2
    cocotb.start_soon(Clock(dut.clk_in, 37038, unit="ps").start())

    # Reset
    dut.reset.value = 1
    await Timer(100, unit="ns")
    dut.reset.value = 0

    # Wait for LOCK
    await RisingEdge(dut.lock)
    dut._log.info("PLL Locked")

    # Measure clk_x10 (Serial Clock)
    # Expected: 252 MHz (Period = 3.968 ns)
    await RisingEdge(dut.clk_x10)
    t1 = cocotb.utils.get_sim_time(unit="ns")
    await RisingEdge(dut.clk_x10)
    t2 = cocotb.utils.get_sim_time(unit="ns")
    period_x10 = t2 - t1
    freq_x10 = 1000 / period_x10

    dut._log.info(f"clk_x10 Period: {period_x10:.3f} ns ({freq_x10:.2f} MHz)")
    assert 3.9 < period_x10 < 4.1, f"clk_x10 period {period_x10} out of range"

    # Measure clk_pixel (Pixel Clock)
    # Expected: 25.2 MHz (Period = 39.68 ns)
    await RisingEdge(dut.clk_pixel)
    t1 = cocotb.utils.get_sim_time(unit="ns")
    await RisingEdge(dut.clk_pixel)
    t2 = cocotb.utils.get_sim_time(unit="ns")
    period_pixel = t2 - t1
    freq_pixel = 1000 / period_pixel

    dut._log.info(f"clk_pixel Period: {period_pixel:.3f} ns ({freq_pixel:.2f} MHz)")
    assert 39.0 < period_pixel < 40.5, f"clk_pixel period {period_pixel} out of range"

    # Verify 10:1 ratio
    ratio = period_pixel / period_x10
    dut._log.info(f"Clock Ratio: {ratio:.2f}")
    assert 9.9 < ratio < 10.1, f"Clock ratio {ratio} is not approx 10"
