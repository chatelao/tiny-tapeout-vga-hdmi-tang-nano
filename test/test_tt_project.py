import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles

@cocotb.test()
async def test_tt_um_vga_example(dut):
    """Test the VGA example module"""

    dut._log.info("Starting test_tt_um_vga_example")

    # Initial values
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 0

    # Pulse clock while reset is active to initialize registers
    for _ in range(10):
        await Timer(5, unit="ns")
        dut.clk.value = 1
        await Timer(5, unit="ns")
        dut.clk.value = 0

    # Release reset
    dut.rst_n.value = 1
    await Timer(10, unit="ns")

    # Run for some cycles and check for activity on hsync (uo_out[7])
    # HSYNC is active low in hvsync_generator.v

    hsync_found_low = False
    hsync_found_high = False

    for i in range(2000):
        dut.clk.value = 1
        await Timer(5, unit="ns")
        dut.clk.value = 0
        await Timer(5, unit="ns")

        try:
            uo_out = int(dut.uo_out.value)
            hsync = (uo_out >> 7) & 1

            if hsync == 0:
                hsync_found_low = True
            if hsync == 1:
                hsync_found_high = True
        except ValueError:
            if i % 100 == 0:
                dut._log.info(f"Cycle {i}: uo_out is still {dut.uo_out.value}")

    assert hsync_found_high, "hsync never went high"
    assert hsync_found_low, "hsync never went low"

    dut._log.info("Test passed!")
