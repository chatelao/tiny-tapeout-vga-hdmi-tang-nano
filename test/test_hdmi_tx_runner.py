import os
import pytest
from cocotb_test.simulator import run

def test_hdmi_tx():
    run(
        verilog_sources=[
            os.path.abspath("src/hdmi_tx.v"),
            os.path.abspath("src/tmds_encoder.v"),
            os.path.abspath("src/hdmi_serializer.v"),
            os.path.abspath("test/oser10_sim_model.v"),
        ],
        toplevel="hdmi_tx",
        module="test_hdmi_tx",
        simulator="icarus",
    )
