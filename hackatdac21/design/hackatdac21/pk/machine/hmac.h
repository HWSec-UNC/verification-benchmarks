// See LICENSE for license details.

#ifndef _RISCV_HMAC_H
#define _RISCV_HMAC_H

#include <stdint.h>
#include "common_driver_fn.h"

extern volatile uint64_t* hmac;


#define HMAC_READY_DELAY 1 
#define HMAC_VALID_DELAY 4 

// HMAC peripheral
#define HMAC_KEY_BITS   256
#define HMAC_KEY_WORDS (HMAC_KEY_BITS / BITS_PER_WORD)

#define HMAC_TEXT_BITS 512
#define HMAC_HASH_BITS 256
#define HMAC_TEXT_BYTES (HMAC_TEXT_BITS / BITS_PER_BYTE )
#define HMAC_READY_WORDS 1
#define HMAC_NEXT_INIT_WORDS 1
#define HMAC_VALID_WORDS 1
#define HMAC_TEXT_WORDS (HMAC_TEXT_BITS / BITS_PER_WORD)
#define HMAC_HASH_WORDS (HMAC_HASH_BITS / BITS_PER_WORD)

#define HMAC_NEXT_INIT 0
#define HMAC_READY 0
#define HMAC_TEXT_BASE  ( HMAC_NEXT_INIT + HMAC_NEXT_INIT_WORDS )
#define HMAC_VALID      ( HMAC_TEXT_BASE + HMAC_TEXT_WORDS )
#define HMAC_HASH_BASE  ( HMAC_VALID     + HMAC_VALID_WORDS )
#define HMAC_KEY_BASE   ( HMAC_HASH_BASE + HMAC_KEY_WORDS )


int hmac_hashString(char *pString, uint32_t *hash, uint32_t use_key_hash);
int check_hmac(); 


void query_hmac(uintptr_t dtb);

#endif
