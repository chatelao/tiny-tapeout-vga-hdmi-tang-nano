/*
 * APB2 Wrapper for Tiny Tapeout (TT) on Tang Nano 4K
 *
 * This wrapper connects a standard TT module to the M3 APB2 expansion bus (Slot 1).
 *
 * Register Map (Base: 0x40002400):
 *   0x00: DATA    (W: ui_in, R: uo_out)
 *   0x04: UIO_DATA (W: uio_in, R: uio_out)
 *   0x08: UIO_OE   (R: uio_oe)
 *   0x0C: CTRL     (W/R: [0]=clk, [1]=rst_n, [2]=ena)
 */

`default_nettype none

module tt_m3_wrapper (
    input  wire        PCLK,    // APB Clock (from M3)
    input  wire        PRESETn, // APB Reset (Active Low)
    input  wire [7:0]  PADDR,   // APB Address (Offset within slot)
    input  wire        PSEL,    // APB Select
    input  wire        PENABLE, // APB Enable
    input  wire        PWRITE,  // APB Write
    input  wire [31:0] PWDATA,  // APB Write Data
    output reg  [31:0] PRDATA,  // APB Read Data
    output wire        PREADY,  // APB Ready

    // --- Debug Ports (Mirroring for observation) ---
    output wire [7:0]  debug_ui_in,
    output wire [7:0]  debug_uo_out,
    output wire [7:0]  debug_uio_in,
    output wire [7:0]  debug_uio_out,
    output wire [7:0]  debug_uio_oe,
    output wire        debug_ena,
    output wire        debug_clk,
    output wire        debug_rst_n
);

    assign PREADY = 1'b1;

    // Debug assignments
    assign debug_ui_in   = ui_in;
    assign debug_uo_out  = uo_out;
    assign debug_uio_in  = uio_in;
    assign debug_uio_out = uio_out;
    assign debug_uio_oe  = uio_oe;
    assign debug_ena     = ctrl[2];
    assign debug_clk     = ctrl[0];
    assign debug_rst_n   = ctrl[1];

    // Registers (W)
    reg  [7:0] ui_in;   // Input to TT module
    reg  [7:0] uio_in;  // Input (path) to TT module
    reg  [2:0] ctrl;    // [0]=clk, [1]=rst_n (Active Low), [2]=ena

    // Wires from TT module (R)
    wire [7:0] uo_out;  // Output from TT module
    wire [7:0] uio_out; // Output (path) from TT module
    wire [7:0] uio_oe;  // Output Enable from TT module

    // --- APB Write Logic ---
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            ui_in   <= 8'h0;
            uio_in  <= 8'h0;
            ctrl    <= 3'h0; // Reset active (rst_n=0), Ena=0, Clk=0
        end else if (PSEL && PENABLE && PWRITE) begin
            case (PADDR[3:0])
                4'h0: ui_in  <= PWDATA[7:0];
                4'h4: uio_in <= PWDATA[7:0];
                4'hC: ctrl   <= PWDATA[2:0];
            endcase
        end
    end

    // --- APB Read Logic ---
    always @(*) begin
        case (PADDR[3:0])
            4'h0:    PRDATA = {24'h0, uo_out};
            4'h4:    PRDATA = {24'h0, uio_out};
            4'h8:    PRDATA = {24'h0, uio_oe};
            4'hC:    PRDATA = {29'h0, ctrl};
            default: PRDATA = 32'h0;
        endcase
    end

    // --- Tiny Tapeout Module Instantiation ---
    // Note: Change 'tt_um_minimal_echo' to your actual TT module name
    tt_um_minimal_echo tt_inst (
        .ui_in  (ui_in),
        .uo_out (uo_out),
        .uio_in (uio_in),
        .uio_out(uio_out),
        .uio_oe (uio_oe),
        .ena    (ctrl[2]),
        .clk    (ctrl[0]),
        .rst_n  (ctrl[1])
    );

endmodule
