// See LICENSE for license details.

#ifndef _RISCV_AES2_H
#define _RISCV_AES2_H

#include <stdint.h>

extern volatile uint64_t* aes2;


#define AES2_ENCRYPT_ID 0
#define AES2_DECRYPT_ID 1


#define AES2_REG_TXFIFO		2
#define AES2_REG_RXFIFO		1
#define AES2_REG_TXCTRL		2
#define AES2_REG_RXCTRL		3
#define AES2_REG_DIV		4

#define AES2_TXEN		 0x1
#define AES2_RXEN		 0x1


#define AES2_START_DELAY 1
#define AES2_DONE_DELAY 4

// peripheral registers
#define AES2_NO_KEYS 3
#define AES2_PT_BITS   128
#define AES2_ST_BITS   128
#define AES2_KEY_BITS   128
#define AES2_CT_BITS   128
#define AES2_START_WORDS  1
#define AES2_DONE_WORDS   1
#define AES2_PT_WORDS (AES2_PT_BITS / BITS_PER_WORD)
#define AES2_ST_WORDS (AES2_ST_BITS / BITS_PER_WORD)
#define AES2_KEY_WORDS (AES2_KEY_BITS / BITS_PER_WORD)
#define AES2_CT_WORDS (AES2_CT_BITS / BITS_PER_WORD)

#define AES2_START     0
#define AES2_PT_BASE   1
#define AES2_KEY0_BASE 5
#define AES2_DONE      9
#define AES2_CT_BASE   10
#define AES2_ST_BASE   14
#define AES2_KEY1_BASE 18
#define AES2_KEY2_BASE 22
#define AES2_KEY_SEL   26


int aes2_start_encrypt(uint32_t *pt, uint32_t *st, uint32_t key_sel); 
int aes2_wait(); 
int aes2_data_out(uint32_t *ct); 
int aes2_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel);
int check_aes(); 

void query_aes2(uintptr_t dtb);

#endif
