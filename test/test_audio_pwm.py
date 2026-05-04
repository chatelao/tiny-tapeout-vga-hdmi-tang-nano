import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_audio_pwm(dut):
    """Test PWM duty cycle for various input samples"""
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.reset.value = 1
    dut.sample_in.value = 0
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    async def check_duty_cycle(sample_value, num_cycles=256):
        dut.sample_in.value = sample_value
        high_count = 0

        # Wait for counter to wrap to 0 to align with our measurement
        # We use a timeout to avoid infinite loop if it never hits 0
        for _ in range(300):
            await RisingEdge(dut.clk)
            if int(dut.counter.value) == 0:
                break

        for _ in range(num_cycles):
            # Sample PWM output on the rising edge.
            # Since pwm_out is registered, it reflects the comparison
            # made at the PREVIOUS clock edge (counter_prev < sample_in).
            # The counter just incremented to 'counter_curr' at this edge.
            if int(dut.pwm_out.value) == 1:
                high_count += 1
            await RisingEdge(dut.clk)

        # Duty cycle should be (sample_value / 256)
        # Since we check 'counter < sample_in' and it's registered:
        # If sample_in is 64, it will be 1 for counter = 0, 1, ..., 63.
        # That is exactly 64 cycles.
        assert high_count == sample_value, f"Sample {sample_value}: Expected high count {sample_value}, got {high_count}"
        dut._log.info(f"Sample {sample_value}: OK (high_count={high_count})")

    # Test several sample values
    await check_duty_cycle(0)
    await check_duty_cycle(64)
    await check_duty_cycle(128)
    await check_duty_cycle(192)
    await check_duty_cycle(255)
