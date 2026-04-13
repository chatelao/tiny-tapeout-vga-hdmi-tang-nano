#ifndef M3_REGS_H
#define M3_REGS_H

#include <stdint.h>

// --- UART0 ---
#define UART0_BASE          (0x40004000)
#define REG_UART0_DATA      (*(volatile uint32_t *)(UART0_BASE + 0x00))
#define REG_UART0_STATE     (*(volatile uint32_t *)(UART0_BASE + 0x04))
#define REG_UART0_CTRL      (*(volatile uint32_t *)(UART0_BASE + 0x08))
#define REG_UART0_BAUDDIV   (*(volatile uint32_t *)(UART0_BASE + 0x10))

// --- GPIO (CMSDK) ---
#define GPIO_BASE           (0x40010000)
#define REG_GPIO_DATA       (*(volatile uint32_t *)(GPIO_BASE + 0x00))
#define REG_GPIO_DATAOUT    (*(volatile uint32_t *)(GPIO_BASE + 0x04))
#define REG_GPIO_OUTENSET   (*(volatile uint32_t *)(GPIO_BASE + 0x10))
#define REG_GPIO_OUTENCLR   (*(volatile uint32_t *)(GPIO_BASE + 0x14))

// --- NVIC ---
#define NVIC_ISER0          (*(volatile uint32_t *)(0xE000E100))
#define NVIC_ICER0          (*(volatile uint32_t *)(0xE000E180))

// --- Memory Regions ---
#define SRAM_BASE           (0x20000000)
#define SRAM_SIZE           (22 * 1024)

// --- Tiny Tapeout (APB2 Slot 1) ---
#define TT_BASE             (0x40002400)
#define REG_TT_DATA         (*(volatile uint32_t *)(TT_BASE + 0x00))
#define REG_TT_UIO_DATA     (*(volatile uint32_t *)(TT_BASE + 0x04))
#define REG_TT_UIO_OE       (*(volatile uint32_t *)(TT_BASE + 0x08))
#define REG_TT_CTRL         (*(volatile uint32_t *)(TT_BASE + 0x0C))

#endif // M3_REGS_H
