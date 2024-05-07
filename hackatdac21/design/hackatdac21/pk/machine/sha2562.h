// See LICENSE for license details.

#ifndef _RISCV_SHA2562_H
#define _RISCV_SHA2562_H

#include <stdint.h>
#include "common_driver_fn.h"

extern volatile uint32_t* sha2562;


#define SHA2562_READY_DELAY 1 
#define SHA2562_VALID_DELAY 4 

// SHA2562 peripheral
// SHA2562 has no key, SHA2562 key is only a place holder
#define SHA2562_KEY_BITS   192
#define SHA2562_KEY_WORDS (SHA2562_KEY_BITS / BITS_PER_WORD)

#define SHA2562_TEXT_BITS 512
#define SHA2562_HASH_BITS 256
#define SHA2562_TEXT_BYTES (SHA2562_TEXT_BITS / BITS_PER_BYTE )
#define SHA2562_READY_WORDS 1
#define SHA2562_NEXT_INIT_WORDS 1
#define SHA2562_VALID_WORDS 1
#define SHA2562_TEXT_WORDS (SHA2562_TEXT_BITS / BITS_PER_WORD)
#define SHA2562_HASH_WORDS (SHA2562_HASH_BITS / BITS_PER_WORD)

#define SHA2562_NEXT_INIT 0
#define SHA2562_READY 0
#define SHA2562_TEXT_BASE  ( SHA2562_NEXT_INIT + SHA2562_NEXT_INIT_WORDS )
#define SHA2562_VALID      ( SHA2562_TEXT_BASE + SHA2562_TEXT_WORDS )
#define SHA2562_HASH_BASE  ( SHA2562_VALID     + SHA2562_VALID_WORDS )


int sha2562_hashString(char *pString, uint32_t *hash);
int sha2562_addPadding(uint64_t pMessageBits64Bit, char* buffer);


void query_sha2562(uintptr_t dtb);

#endif
