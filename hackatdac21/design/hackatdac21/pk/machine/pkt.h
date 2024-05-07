// See LICENSE for license details.

#ifndef _RISCV_PKT_H
#define _RISCV_PKT_H

#include <stdint.h>
#include "aes0.h"
#include "aes1.h"
#include "aes2.h"
#include "sha256.h"
#include "hmac.h"
#include "rng.h"
#include "rst.h"

extern volatile uint64_t* pkt;

// PKT peripheral
#define PKT_FUSE_REQ 0
#define PKT_FUSE_RADDR (PKT_FUSE_REQ + 1)
#define PKT_WADDR_MSB (PKT_FUSE_RADDR + 1)
#define PKT_WADDR_LSB (PKT_WADDR_MSB + 1)
#define PKT_FUSE_RDATA (PKT_WADDR_LSB + 1)

#define PKT_AES0_WORDS AES0_KEY_WORDS
#define PKT_AES1_WORDS AES1_KEY_WORDS
#define PKT_AES2_WORDS AES2_KEY_WORDS
#define PKT_RST_WORDS RST_ID_WORDS
#define PKT_SHA256_WORDS SHA256_KEY_WORDS
#define PKT_ACCT_WORDS ACCT_WORDS
#define PKT_HMAC_KEY_WORDS HMAC_KEY_WORDS
#define PKT_AES0_BASE_INDX 0
#define PKT_AES1_BASE_INDX (PKT_AES0_BASE_INDX + (AES0_NO_KEYS*PKT_AES0_WORDS))
#define PKT_AES2_BASE_INDX (PKT_AES1_BASE_INDX + (AES1_NO_KEYS*PKT_AES1_WORDS))
#define PKT_SHA256_BASE_INDX (PKT_AES2_BASE_INDX + (AES2_NO_KEYS*PKT_AES2_WORDS))
#define PKT_ACCT_BASE_INDX (PKT_SHA256_BASE_INDX + PKT_SHA256_WORDS)
#define PKT_HMAC_KEY_BASE_INDX (PKT_ACCT_BASE_INDX + PKT_ACCT_WORDS)
#define PKT_HMAC_iKEY_BASE_INDX (PKT_HMAC_KEY_BASE_INDX + PKT_HMAC_KEY_WORDS)
#define PKT_HMAC_oKEY_BASE_INDX (PKT_HMAC_iKEY_BASE_INDX + PKT_HMAC_KEY_WORDS)
#define PKT_RNG_WORDS RNG_POLY128_WORDS + RNG_POLY64_WORDS + RNG_POLY32_WORDS + RNG_POLY16_WORDS
#define PKT_RNG_BASE_INDX (PKT_HMAC_oKEY_BASE_INDX + PKT_HMAC_KEY_WORDS)

int pkt_copy_fuse_data(int aes0_working, int aes1_working, int aes2_working, int sha256_working, int hmac_working, int rng_working, int rst_working);

void query_pkt(uintptr_t dtb);

#endif
