/*
 * Behavioral model of Gowin rPLL for simulation with Icarus Verilog.
 *
 * This model approximates the frequency scaling of the rPLL primitive.
 * It is NOT a cycle-accurate representation of the hardware's analog behavior.
 */

`timescale 1ns/1ps

module rPLL #(
    parameter FCLKIN = "27",
    parameter DEVICE = "GW1NSR-4C",
    parameter IDIV_SEL = 0,
    parameter FBDIV_SEL = 0,
    parameter ODIV_SEL = 8,
    parameter DUTYDA_SEL = "1000",
    parameter PSDA_SEL = "0000",
    parameter CLKOUTD_SRC = "CLKOUT",
    parameter CLKOUTD_SEL = 2
)(
    input  wire CLKIN,
    input  wire RESET,
    input  wire RESET_P,
    input  wire CLKFB,
    input  wire [5:0] FBDSEL,
    input  wire [5:0] IDSEL,
    input  wire [5:0] ODSEL,
    input  wire [3:0] DUTYDA,
    input  wire [3:0] FDLY,
    output reg  CLKOUT,
    output reg  CLKOUTD,
    output reg  LOCK
);

    // Factors based on Gowin documentation (approximate)
    // IDIV = IDIV_SEL + 1
    // FBDIV = FBDIV_SEL + 1
    // ODIV = ODIV_SEL (Wait, usually ODIV is one of 2, 4, 8, 16...)
    // For our specific case:
    // IDIV = 3 (IDIV_SEL=2)
    // FBDIV = 28 (FBDIV_SEL=27)
    // Target Frequency = (27 * 28) / 3 = 252 MHz
    // Pixel Clock = 252 / 10 = 25.2 MHz (CLKOUTD_SEL=10)

    real input_period = 0;
    real last_edge = 0;
    real vco_period = 0;

    initial begin
        CLKOUT = 0;
        CLKOUTD = 0;
        LOCK = 0;
    end

    // Measure input period
    always @(posedge CLKIN) begin
        if (last_edge != 0) begin
            input_period = $realtime - last_edge;
            // Target output period: input_period * IDIV * ODIV / FBDIV
            // For 252 MHz: 37.037 * 3 * 2 / 56 = 3.968 ns
            vco_period = (input_period * (IDIV_SEL + 1.0) * ODIV_SEL) / (FBDIV_SEL + 1.0);
        end
        last_edge = $realtime;
    end

    // Generate LOCK signal
    always @(posedge CLKIN or posedge RESET) begin
        if (RESET) begin
            LOCK <= 0;
        end else begin
            // Simple delay to simulate locking
            #100 LOCK <= 1;
        end
    end

    // Generate CLKOUT (x10)
    always begin
        if (LOCK && vco_period > 0) begin
            #(vco_period / 2.0) CLKOUT = ~CLKOUT;
        end else begin
            #1 CLKOUT = 0;
        end
    end

    // Generate CLKOUTD (x1)
    integer d_count = 0;
    always @(posedge CLKOUT) begin
        if (!LOCK) begin
            d_count <= 0;
            CLKOUTD <= 0;
        end else begin
            if (d_count >= (CLKOUTD_SEL / 2) - 1) begin
                CLKOUTD <= ~CLKOUTD;
                d_count <= 0;
            end else begin
                d_count <= d_count + 1;
            end
        end
    end

endmodule
