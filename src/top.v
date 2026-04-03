/* top.v - m3_uart_echo */
module top (
    input  wire       clk_27m,      // Pin 45
    output wire       uart0_txd,    // Pin 18
    input  wire       uart0_rxd,    // Pin 19
    output wire       led_pin,             // LED
    input  wire       btn1_pin ,            // BTN-1
    input  wire       btn2_pin             // BTN-2
);

    wire [15:0] m3_gpio;

    // --- APB Expansion (Slot 1) Signals ---
    /* FIXME: The current Gowin_EMPU_Top IP core definition does not have APB extension ports.
       Commenting out for now to ensure synthesis.
    wire [11:0] mst1_paddr;
    wire        mst1_psel;
    wire        mst1_penable;
    wire        mst1_pwrite;
    wire [31:0] mst1_pwdata;
    wire [31:0] mst1_prdata;
    wire        mst1_pready;
    */

    Gowin_EMPU_Top m3_inst (
		.sys_clk(clk_27m),     //input sys_clk

		.gpio(m3_gpio),        //inout [15:0] gpio

		.uart0_rxd(uart0_rxd), //input uart0_rxd
		.uart0_txd(uart0_txd), //output uart0_txd

		.reset_n(btn2_pin)

        /* FIXME: Re-enable these ports when the IP core is updated with APB expansion enabled.
        ,
        .APBTARGEXP1PSEL(mst1_psel),
        .APBTARGEXP1PENABLE(mst1_penable),
        .APBTARGEXP1PWRITE(mst1_pwrite),
        .APBTARGEXP1PADDR(mst1_paddr),
        .APBTARGEXP1PWDATA(mst1_pwdata),
        .APBTARGEXP1PRDATA(mst1_prdata),
        .APBTARGEXP1PREADY(mst1_pready)
        */
    );

    /* FIXME: Re-enable the TT wrapper when APB expansion is available.
    tt_m3_wrapper tt_wrapper_inst (
        .PCLK(clk_27m),
        .PRESETn(btn2_pin),
        .PADDR(mst1_paddr[7:0]),
        .PSEL(mst1_psel),
        .PENABLE(mst1_penable),
        .PWRITE(mst1_pwrite),
        .PWDATA(mst1_pwdata),
        .PRDATA(mst1_prdata),
        .PREADY(mst1_pready)
    );
    */

    assign led_pin = btn1_pin ^ btn2_pin ^ uart0_txd;

endmodule
