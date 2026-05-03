import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

async def apb_write(dut, addr, data):
    dut.PADDR.value = addr
    dut.PWDATA.value = data
    dut.PWRITE.value = 1
    dut.PSEL.value = 1
    await RisingEdge(dut.PCLK)
    dut.PENABLE.value = 1
    await RisingEdge(dut.PCLK)
    dut.PSEL.value = 0
    dut.PENABLE.value = 0
    dut.PWRITE.value = 0

async def apb_read(dut, addr):
    dut.PADDR.value = addr
    dut.PWRITE.value = 0
    dut.PSEL.value = 1
    await RisingEdge(dut.PCLK)
    dut.PENABLE.value = 1
    await RisingEdge(dut.PCLK)
    data = int(dut.PRDATA.value)
    dut.PSEL.value = 0
    dut.PENABLE.value = 0
    return data

@cocotb.test()
async def test_tt_wrapper_registers(dut):
    """Test APB register access in tt_m3_wrapper"""

    # Initialize signals
    dut.PCLK.value = 0
    dut.PRESETn.value = 0
    dut.PSEL.value = 0
    dut.PENABLE.value = 0
    dut.PWRITE.value = 0
    dut.PADDR.value = 0
    dut.PWDATA.value = 0

    # Start clock
    cocotb.start_soon(Clock(dut.PCLK, 10, unit="ns").start())

    # Reset
    await Timer(20, unit="ns")
    dut.PRESETn.value = 1
    await RisingEdge(dut.PCLK)

    # After PRESETn, ctrl=0, which means rst_n=0 (reset active)
    # Pulse TT clock while reset is active to initialize registers
    dut._log.info("Pulsing TT clock while reset is active...")
    for _ in range(10):
        await apb_write(dut, 0x0C, 0x1) # clk=1, rst_n=0, ena=0
        await apb_write(dut, 0x0C, 0x0) # clk=0, rst_n=0, ena=0

    # Test CTRL register (Offset 0x0C)
    # [0]=clk, [1]=rst_n, [2]=ena
    dut._log.info("Testing CTRL register (releasing reset)...")
    await apb_write(dut, 0x0C, 0x7) # ena=1, rst_n=1, clk=1
    await Timer(1, unit="ns")
    assert dut.debug_ena.value == 1
    assert dut.debug_rst_n.value == 1
    assert dut.debug_clk.value == 1

    val = await apb_read(dut, 0x0C)
    assert val == 0x7

    # Test DATA register (Offset 0x00) - Write ui_in
    dut._log.info("Testing DATA register (write ui_in)...")
    await apb_write(dut, 0x00, 0xAA)
    await Timer(1, unit="ns")
    assert dut.debug_ui_in.value == 0xAA

    # Test UIO_DATA register (Offset 0x04) - Write uio_in
    dut._log.info("Testing UIO_DATA register (write uio_in)...")
    await apb_write(dut, 0x04, 0x55)
    await Timer(1, unit="ns")
    assert dut.debug_uio_in.value == 0x55

    # Test UIO_OE register (Offset 0x08) - Read only
    # tt_um_vga_example has uio_oe = 8'h01
    dut._log.info("Testing UIO_OE register (read only)...")
    val = await apb_read(dut, 0x08)
    assert val == 0x01

    # Test Reading back uo_out via DATA register
    # The VGA example outputs something to uo_out.
    # We pulse the TT clock via CTRL register to stabilize it.
    dut._log.info("Pulsing TT clock via CTRL register...")
    for _ in range(20):
        await apb_write(dut, 0x0C, 0x6) # clk=0, rst_n=1, ena=1
        await apb_write(dut, 0x0C, 0x7) # clk=1, rst_n=1, ena=1

    dut._log.info("Testing DATA register (read uo_out)...")
    # PRDATA might still contain some 'X' if the module hasn't fully initialized
    # but at least we can check if it's un-Xed now.
    prdata_str = dut.PRDATA.value.binstr
    dut._log.info(f"PRDATA binstr: {prdata_str}")

    # We expect the constant part (high bits) to be 0
    # and the lower bits to be something potentially non-X now
    val = await apb_read(dut, 0x00)
    dut._log.info(f"Read uo_out: {val:02x}")

    dut._log.info("TT Wrapper APB register tests passed!")
