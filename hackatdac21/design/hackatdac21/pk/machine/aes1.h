// See LICENSE for license details.

#ifndef _RISCV_AES1_H
#define _RISCV_AES1_H

#include <stdint.h>

extern volatile uint64_t* aes1;


#define AES1_ENCRYPT_ID 0
#define AES1_DECRYPT_ID 1


#define AES1_REG_TXFIFO		2
#define AES1_REG_RXFIFO		1
#define AES1_REG_TXCTRL		2
#define AES1_REG_RXCTRL		3
#define AES1_REG_DIV		4

#define AES1_TXEN		 0x1
#define AES1_RXEN		 0x1


#define AES1_START_DELAY 1
#define AES1_DONE_DELAY 4

// peripheral registers
#define AES1_NO_KEYS 3
#define AES1_BLK_BITS   128
#define AES1_RES_BITS   128
#define AES1_KEY_BITS   256
#define AES1_ENC_DEC_WORDS 1
#define AES1_KEY_LEN_WORDS 1
#define AES1_BLK_WORDS (AES1_BLK_BITS / BITS_PER_WORD)
#define AES1_RES_WORDS (AES1_RES_BITS / BITS_PER_WORD)
#define AES1_KEY_WORDS (AES1_KEY_BITS / BITS_PER_WORD)

#define AES1_CTRL_BASE  8
#define AES1_STATUS_BASE  9
#define AES1_ENC_DEC   10
#define AES1_KEY0_LEN   ( AES1_ENC_DEC      + AES1_ENC_DEC_WORDS )
#define AES1_KEY1_LEN   ( AES1_KEY0_LEN     + AES1_KEY_LEN_WORDS )
#define AES1_KEY2_LEN   ( AES1_KEY1_LEN     + AES1_KEY_LEN_WORDS )
#define AES1_KEY_SEL    ( AES1_KEY2_LEN     + AES1_KEY_LEN_WORDS )

#define AES1_KEY0_BASE 16
#define AES1_KEY1_BASE 32
#define AES1_KEY2_BASE 48
#define AES1_BLK_BASE  64
#define AES1_RES_BASE  80


int aes1_read_data(uint32_t *result); 
int aes1_write_data(uint32_t *block, uint32_t key_sel); 
int aes1_read_config(uint32_t *config_o);
int aes1_write_config(uint32_t config_i);
int check_aes1();

void query_aes1(uintptr_t dtb);

#endif
