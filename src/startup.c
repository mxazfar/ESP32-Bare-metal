#include <stdint.h>
#include <string.h>
#include "main.h"

// These symbols are defined by the linker script
extern uint32_t _sidata, _sdata, _edata, _sbss, _ebss, _stack_end;

void __attribute__((noreturn)) call_start_cpu0() {
    // Set up stack ptr, bootloader may do this but I'm doing it again to be safe
    __asm__ volatile("movi a1, _stack_end");

    // Initialize data section
    uint32_t *pSrc = &_sidata;
    uint32_t *pDest = &_sdata;
    while (pDest < &_edata) {
        *pDest++ = *pSrc++;
    }

    // Clear BSS section
    for (uint32_t *pBss = &_sbss; pBss < &_ebss; pBss++) {
        *pBss = 0;
    }

    // Optional: Initialize hardware, clocks, etc.
    // init_hardware();

    // Enable interrupts
    __asm__ volatile ("rsil a2, 0");

    // Call main function
    main();

    // Should never reach here
    while(1) {}
}