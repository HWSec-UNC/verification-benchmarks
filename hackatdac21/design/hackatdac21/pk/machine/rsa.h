// See LICENSE for license details.

#ifndef _RISCV_RSA_H
#define _RISCV_RSA_H

#include <stdint.h>

extern volatile uint64_t* rsa;

#define RSA_VALID_DELAY 1
#define RSA_LOAD_DELAY 1
// peripheral registers
#define RSA_MSG_IN_WORDS 64
#define RSA_CTL_SIG_WORDS 1
#define RSA_PNUM_WORDS 64
#define RSA_MSG_OUT_BITS 2048
#define RSA_MSG_OUT_WORDS 64

#define RSA_RST_KEY_BASE 0
#define RSA_RST_MSG_BASE 1 
#define RSA_ENCRY_DECRY_BASE 2
#define RSA_PRIME_BASE 3
#define RSA_PRIME1_BASE 35
#define RSA_MSG_IN_BASE 67
#define RSA_MSG_OUT_BASE 131
#define RSA_VALID 195

int rsa_wait(); 
int rsa_write_prime_num(uint32_t *p_num);
int rsa_write_msg_in(uint32_t *msg_in, uint32_t encry_decry);
int rsa_read_msg_out(uint32_t *msg_out);

void query_rsa(uintptr_t dtb);

#endif
