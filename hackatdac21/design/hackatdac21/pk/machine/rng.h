// See LICENSE for license details.

#ifndef _RISCV_RNG_H
#define _RISCV_RNG_H

#include <stdint.h>

extern volatile uint64_t* rng;

#define RNG_LOAD_DELAY 1
#define RNG_VALID_DELAY 1

// peripheral registers
#define RNG_SEED_BITS   128
#define RNG_POLY128_BITS 128
#define RNG_POLY64_BITS 64
#define RNG_POLY32_BITS 32
#define RNG_RNUM_BITS   64
#define RNG_SEED_OUT128_BITS 128
#define RNG_SEED_OUT64_BITS 64
#define RNG_SEED_OUT32_BITS 32


#define RNG_SEED_WORDS 4 //(RNG_SEED_BITS / BITS_PER_WORD)
#define RNG_POLY128_WORDS 4 //(RNG_POLY128_BITS / BITS_PER_WORD)
#define RNG_POLY64_WORDS 2 //(RNG_POLY64_BITS / BITS_PER_WORD)
#define RNG_POLY32_WORDS 1
#define RNG_POLY16_WORDS 1
#define RNG_RNUM_WORDS 2 //(RNG_RNUM_BITS / BITS_PER_WORD)
#define RNG_VALID_WORDS   1
#define RNG_SEED_OUT128_WORDS 4 //(RNG_SEED_OUT128_BITS / BITS_PER_WORD)
#define RNG_SEED_OUT64_WORDS 2 //(RNG_SEED_OUT64_BITS / BITS_PER_WORD)
#define RNG_SEED_OUT32_WORDS 1
#define RNG_SEED_OUT16_WORDS 1
#define RNG_SEG_OUT_WORDS 2
#define RNG_STATE_WORDS 1



#define RNG_SEED_BASE 0
#define RNG_POLY128_BASE 4 //(RNG_SEED_BASE + RNG_SEED_WORDS)
#define RNG_POLY64_BASE 8 // (RNG_POLY128_BASE + RNG_POLY128_WORDS)
#define RNG_POLY32_BASE 10 // (RNG_POLY64_BASE + RNG_POLY64_WORDS)
#define RNG_POLY16_BASE 11 // (RNG_POLY32_BASE + RNG_POLY32_WORDS)
#define RNG_RNUM_BASE 12 // ( RNG_POLY16_BASE + RNG_POLY16_WORDS)
#define RNG_VALID 14    //( RNG_RNUM_BASE + RNG_RNUM_WORDS )
#define RNG_SEED_OUT128_BASE 15 // (RNG_VALID + RNG_VALID_WORDS)
#define RNG_SEED_OUT64_BASE 19 //(RNG_SEED_OUT128_BASE + RNG_SEED_OUT128_WORDS)
#define RNG_SEED_OUT32_BASE 21 //(RNG_SEED_OUT64_BASE + RNG_SEED_OUT64_WORDS)
#define RNG_SEED_OUT16_BASE 22 //(RNG_SEED_OUT32_BASE + RNG_SEED_OUT32_WORDS)
#define RNG_SEG_OUT_BASE 23
#define RNG_STATE 25


int rng_wait(); 
int rng_read_data(uint32_t *randnum);

//debug functions
int rng_read_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16);
int rng_write_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16);
int rng_read_seed(uint32_t *seed128, uint32_t *seed64, uint32_t *seed32, uint32_t *seed16);
int rng_write_seed(uint32_t *seed128);
int rng_read_rand_seg(uint32_t *rand_seg);
int rng_read_state_counter(uint32_t *st_cnt); 

void query_rng(uintptr_t dtb);

#endif
