#ifndef _RISCV_RST_H
#define _RISCV_RST_H

#include <stdint.h>

extern volatile uint64_t* rst;

#define RST_START_DELAY 1
#define RST_DONE_DELAY 4

#define RST_ID_BITS 5

#define RST_ID_WORDS (RST_ID_BITS / BITS_PER_WORD)

#define RST_START 0
#define RST_ID_BASE 1

int rst_id(uint32_t id);

void query_rst(uintptr_t dtb);

#endif