/* main.c - m3_uart_echo */
#include "m3_regs.h"

int main(void) {
    // Configure UART0: 115200 baud @ 27MHz
    REG_UART0_BAUDDIV = 234;

    // Enable UART0 TX and RX
    REG_UART0_CTRL = (1 << 1) | (1 << 0);

    // Configure GPIO0 (LED) as output
    REG_GPIO_OUTENSET = (1 << 0);

    /* FIXME: Tiny Tapeout module logic is disabled because the APB expansion
       is not yet available in the IP core.
    // Initialize TT Module: ena=1, rst_n=1, clk=0
    REG_TT_CTRL = (1 << 2) | (1 << 1) | (0 << 0);
    */

    while (1) {
        // Poll for RX buffer full (STATE[1])
        if (REG_UART0_STATE & (1 << 1)) {
            // Read received character
            uint8_t c = (uint8_t)REG_UART0_DATA;

            // Toggle LED
            REG_GPIO_DATAOUT ^= (1 << 0);

            /* FIXME: Re-enable TT processing when APB is functional.
            // Process through Tiny Tapeout Module
            // 1. Write data to TT ui_in
            REG_TT_DATA = c;

            // 2. Pulse TT clock (0 -> 1 -> 0)
            REG_TT_CTRL |= (1 << 0);
            REG_TT_CTRL &= ~(1 << 0);

            // 3. Read result from TT uo_out
            uint8_t result = (uint8_t)REG_TT_DATA;
            */

            // Wait for TX buffer not full (STATE[0] == 0)
            while (REG_UART0_STATE & (1 << 0));

            // Echo the character back directly for now.
            REG_UART0_DATA = c;
        }
    }

    return 0;
}
