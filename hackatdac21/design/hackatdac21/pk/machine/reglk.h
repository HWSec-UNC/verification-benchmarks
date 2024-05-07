// See LICENSE for license details.

#ifndef _RISCV_REGLK_H
#define _RISCV_REGLK_H

#include <stdint.h>

extern volatile uint64_t* reglk;

// REGLK peripheral
#define REGLK_WORDS 10
#define REGLK_BYTES (REGLK_WORDS*BYTES_PER_WORD)

#define REGLK_HMAC 0x00
#define REGLK_REGLK 0xf7
#define REGLK_ACCT 0xec
#define REGLK_PKT 0xcf
#define REGLK_SHA256 0x00
#define REGLK_AES1 0x08
#define REGLK_AES0 0xa0
#define REGLK_AES2 0x20
#define REGLK_DMA 0x00
#define REGLK_ROM 0x00
#define REGLK_UART 0x00
#define REGLK_RNG 0xa8
#define REGLK_RSA 0x00
#define REGLK_RST 0x00

void query_reglk(uintptr_t dtb);

#endif
