/* startup.c */
#include <stdint.h>

extern uint32_t _estack;
extern uint32_t _etext;
extern uint32_t _sdata;
extern uint32_t _edata;
extern uint32_t _sbss;
extern uint32_t _ebss;

void main(void);

void Reset_Handler(void) __attribute__((naked, section(".boot")));
void Reset_Handler(void) {
    // Set stack pointer
    __asm volatile ("ldr sp, =_estack");

    // Copy .data section from flash to RAM
    for (uint32_t *src = &_etext, *dest = &_sdata; dest < &_edata;) {
        *dest++ = *src++;
    }

    // Zero out .bss section
    for (uint32_t *dest = &_sbss; dest < &_ebss;) {
        *dest++ = 0;
    }

    // Jump to main
    main();
    for (;;);
}

void Default_Handler(void) {
    while (1);
}

// Minimal ISR Vector Table
const uint32_t isr_vector[] __attribute__((section(".isr_vector"), aligned(256))) = {
    (uint32_t)&_estack,
    (uint32_t)&Reset_Handler,
    (uint32_t)&Default_Handler, // NMI
    (uint32_t)&Default_Handler, // HardFault
    (uint32_t)&Default_Handler, // MemManage
    (uint32_t)&Default_Handler, // BusFault
    (uint32_t)&Default_Handler, // UsageFault
    0, 0, 0, 0,                 // Reserved
    (uint32_t)&Default_Handler, // SVCall
    (uint32_t)&Default_Handler, // DebugMonitor
    0,                          // Reserved
    (uint32_t)&Default_Handler, // PendSV
    (uint32_t)&Default_Handler, // SysTick
};
