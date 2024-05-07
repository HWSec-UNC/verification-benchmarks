// See LICENSE for license details.

#ifndef _RISCV_AES3_H
#define _RISCV_AES3_H

#include <stdint.h>

extern volatile uint32_t* aes3;


#define AES3_ENCRYPT_ID 0
#define AES3_DECRYPT_ID 1


#define AES3_REG_TXFIFO		2
#define AES3_REG_RXFIFO		1
#define AES3_REG_TXCTRL		2
#define AES3_REG_RXCTRL		3
#define AES3_REG_DIV		4

#define AES3_TXEN		 0x1
#define AES3_RXEN		 0x1


#define AES3_START_DELAY 1
#define AES3_DONE_DELAY 4

// peripheral registers
#define AES3_NO_KEYS 3
#define AES3_PT_BITS   128
#define AES3_ST_BITS   128
#define AES3_KEY_BITS   192
#define AES3_CT_BITS   128
#define AES3_START_WORDS  1
#define AES3_DONE_WORDS   1
#define AES3_PT_WORDS (AES3_PT_BITS / BITS_PER_WORD)
#define AES3_ST_WORDS (AES3_ST_BITS / BITS_PER_WORD)
#define AES3_KEY_WORDS (AES3_KEY_BITS / BITS_PER_WORD)
#define AES3_CT_WORDS (AES3_CT_BITS / BITS_PER_WORD)

#define AES3_START   0
#define AES3_PT_BASE   ( AES3_START     + AES3_START_WORDS )
#define AES3_KEY0_BASE ( AES3_PT_BASE   + AES3_PT_WORDS )
#define AES3_DONE      ( AES3_KEY0_BASE + AES3_KEY_WORDS )
#define AES3_CT_BASE   ( AES3_DONE      + AES3_DONE_WORDS )
#define AES3_ST_BASE   ( AES3_CT_BASE   + AES3_CT_WORDS )
#define AES3_KEY1_BASE ( AES3_ST_BASE   + AES3_ST_WORDS )
#define AES3_KEY2_BASE ( AES3_KEY1_BASE + AES3_KEY_WORDS )
#define AES3_KEY_SEL   ( AES3_KEY2_BASE + AES3_KEY_WORDS )


int aes3_start_encrypt(uint32_t *pt, uint32_t *st, uint32_t key_sel); 
int aes3_wait(); 
int aes3_data_out(uint32_t *ct); 
int aes3_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel);

void query_aes3(uintptr_t dtb);

#endif
