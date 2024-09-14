/*
 * GNU linker script for Espressif ESP32
 */

/* Default entry point */
ENTRY(call_start_cpu0);

/* Specify main memory areas */
MEMORY
{
    iram_seg (RX)  : ORIGIN = 0x40080000, LENGTH = 512K
    dram_seg (RW)  : ORIGIN = 0x3FFB0000, LENGTH = 320K
}

/* Define output sections */
SECTIONS
{
    /* The program code and other data goes into Instruction RAM */
    .iram0.text :
    {
        _iram_start = ABSOLUTE(.);
        . = ALIGN(16);
        KEEP(*(.entry.text))
        *(.iram1 .iram1.*)
        *(.iram0.literal .iram.literal .iram.text.literal .iram0.text .iram.text)
        *(.literal .text .literal.* .text.*)
        _iram_end = ABSOLUTE(.);
    } > iram_seg

    /* Initialized data goes into Data RAM */
    .data :
    {
        _data_start = ABSOLUTE(.);
        *(.data)
        *(.data*)
        _data_end = ABSOLUTE(.);
    } > dram_seg AT > iram_seg

    _sidata = LOADADDR(.data);

    /* Uninitialized data also goes into Data RAM */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _bss_start = ABSOLUTE(.);
        *(.bss)
        *(.bss*)
        *(COMMON)
        _bss_end = ABSOLUTE(.);
    } > dram_seg

    /* Read-only data goes into Instruction RAM */
    .rodata :
    {
        _rodata_start = ABSOLUTE(.);
        *(.rodata)
        *(.rodata*)
        _rodata_end = ABSOLUTE(.);
    } > iram_seg

    /* Stack definition */
    .stack (NOLOAD) :
    {
        _stack_start = ABSOLUTE(.);
        . = . + 4K;  /* Stack size */
        _stack_end = ABSOLUTE(.);
    } > dram_seg

    . = ALIGN(4);
    _end = ABSOLUTE(.);
}

/* Define some symbols for use in startup code */
PROVIDE(_sdata = ADDR(.data));
PROVIDE(_edata = ADDR(.data) + SIZEOF(.data));
PROVIDE(_sbss = ADDR(.bss));
PROVIDE(_ebss = ADDR(.bss) + SIZEOF(.bss));