// See LICENSE for license details.

#ifndef _RISCV_SHA256_H
#define _RISCV_SHA256_H

#include <stdint.h>
#include "common_driver_fn.h"

extern volatile uint64_t* sha256;


#define SHA256_READY_DELAY 1 
#define SHA256_VALID_DELAY 4 

// SHA256 peripheral
// SHA256 has no key, SHA256 key is only a place holder
#define SHA256_KEY_BITS   192
#define SHA256_KEY_WORDS (SHA256_KEY_BITS / BITS_PER_WORD)

#define SHA256_TEXT_BITS 512
#define SHA256_HASH_BITS 256
#define SHA256_TEXT_BYTES (SHA256_TEXT_BITS / BITS_PER_BYTE )
#define SHA256_READY_WORDS 1
#define SHA256_NEXT_INIT_WORDS 1
#define SHA256_VALID_WORDS 1
#define SHA256_TEXT_WORDS (SHA256_TEXT_BITS / BITS_PER_WORD)
#define SHA256_HASH_WORDS (SHA256_HASH_BITS / BITS_PER_WORD)

#define SHA256_NEXT_INIT 0
#define SHA256_READY 0
#define SHA256_TEXT_BASE  ( SHA256_NEXT_INIT + SHA256_NEXT_INIT_WORDS )
#define SHA256_VALID      ( SHA256_TEXT_BASE + SHA256_TEXT_WORDS )
#define SHA256_HASH_BASE  ( SHA256_VALID     + SHA256_VALID_WORDS )


int sha256_hashString(char *pString, uint32_t *hash);
int sha256_addPadding(uint64_t pMessageBits64Bit, char* buffer);
int check_sha256(); 


void query_sha256(uintptr_t dtb);

#endif
