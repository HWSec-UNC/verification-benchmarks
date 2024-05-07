/////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  - This file is only to help the participants with basic API's to interact with the SoC
//  - You can also, write your own functions / modify the code here, to interact with the 
//    peripherals since all of this is considered as user space code.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef ARIANE_API
#define ARIANE_API

#include <stdio.h>
#include <string.h>

#define BITS_PER_BYTE   8
#define BYTES_PER_WORD   4
#define BITS_PER_WORD (BITS_PER_BYTE * BYTES_PER_WORD)

// SysCall IDs
#define SYS_RNG_WAIT 1050
#define SYS_RNG_READ_DATA 1051
#define SYS_RNG_READ_POLY 1052
#define SYS_RNG_WRITE_POLY 1053
#define SYS_RNG_READ_SEED 1054
#define SYS_RNG_WRITE_SEED 1055
#define SYS_RNG_READ_RAND_SEG 1056
#define SYS_RNG_READ_STATE_COUNTER 1057
#define SYS_AES0_START_ENCRY 1022
#define SYS_AES0_START_DECRY 1021
#define SYS_AES0_WAIT 1020
#define SYS_AES0_DATA_OUT 1019
#define SYS_SHA256_HASH 1018
#define SYS_HMAC_HASH 1017
#define SYS_DMA_COPY 1016
#define SYS_DMA_COPY1 1015
#define SYS_DMA_COPY2 1014
#define SYS_CMP 1013
#define SYS_AES1_READ_DATA 1012
#define SYS_AES1_WRITE_DATA 1011
#define SYS_AES1_READ_CONFIG 1010
#define SYS_AES1_WRITE_CONFIG 1009
#define SYS_DMA_END 1007

#define SYS_AES2_START_ENCRY 1058
#define SYS_AES2_START_DECRY 1059
#define SYS_AES2_WAIT 1060
#define SYS_AES2_DATA_OUT 1061

#define SYS_RST 1067

#define SYS_RSA_WRITE_PNUM 1063
#define SYS_RSA_WRITE_MSG_IN 1064
#define SYS_RSA_READ_MSG_OUT 1065
#define SYS_RSA_WAIT 1066
// declare the functions
void my_delay(int wait_cycles);

void dma_transfer_to_perif(uint32_t *sAddress, uint64_t dAddress, uint32_t length, int wait); 
void dma_transfer_from_perif(uint64_t sAddress, uint32_t *dAddress, uint32_t length, int wait); 
void dma_transfer_from_perif_to_perif(uint64_t sAddress, uint64_t dAddress, uint32_t length, int wait); 
void dma_end();
void aes0_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel); 
void aes0_decrypt(uint32_t *ct, uint32_t *st, uint32_t *pt, uint32_t key_sel); 
void aes2_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel); 
void aes2_decrypt(uint32_t *ct, uint32_t *st, uint32_t *pt, uint32_t key_sel); 
void sha256_hashString(char *pString, uint32_t *hash);
void hmac_hashString(char *pString, uint32_t *hash, uint32_t use_key_hash); 
int compareMulti(uint32_t *expectedData, uint32_t receivedData, uint32_t block_size);
void do_delay(int n);


void aes1_read_data(uint32_t *result); 
void aes1_write_data(uint32_t *block, uint32_t key_sel); 
void aes1_read_config(uint32_t *config_o);
void aes1_write_config(uint32_t config_i);
void rst_id(uint32_t id);

void rng(uint32_t *randnum);
//debug mode function
void rng_read_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16);
void rng_write_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16);
void rng_read_seed(uint32_t *seed128, uint32_t *seed64, uint32_t *seed32, uint32_t *seed16);
void rng_write_seed(uint32_t *seed128);
void rng_read_rand_seg(uint32_t *rand_seg);
void rng_read_state_counter(uint32_t *st_cnt);

void rsa_write_prime_num(uint32_t *p_num);
void rsa_write_msg_in(uint32_t *msg_in, uint32_t encry_decry);
void rsa_read_msg_out(uint32_t *msg_out);

uintptr_t mmap(uint32_t *addr, size_t length, int prot, int flags, int fd, int offset); 

#define AES0_NO_KEYS 3
#define AES0_PT_BITS   128
#define AES0_ST_BITS   128
#define AES0_KEY_BITS   192
#define AES0_CT_BITS   128
#define AES0_START_WORDS  1
#define AES0_DONE_WORDS   1
#define AES0_PT_WORDS (AES0_PT_BITS / BITS_PER_WORD)
#define AES0_KEY_WORDS (AES0_KEY_BITS / BITS_PER_WORD)
#define AES0_CT_WORDS (AES0_CT_BITS / BITS_PER_WORD)
#define AES0_BASE   0xfff5200000
#define AES0_PT_BASE   0xfff5200008
#define AES0_ST_BASE   0xfff5200060

#define AES2_NO_KEYS 3
#define AES2_PT_BITS   128
#define AES2_KEY_BITS   128
#define AES2_CT_BITS   128
#define AES2_START_WORDS  1
#define AES2_DONE_WORDS   1
#define AES2_PT_WORDS (AES2_PT_BITS / BITS_PER_WORD)
#define AES2_KEY_WORDS (AES2_KEY_BITS / BITS_PER_WORD)
#define AES2_CT_WORDS (AES2_CT_BITS / BITS_PER_WORD)
#define AES2_BASE 0xfff5209000
#define AES2_PT_BASE   0xfff5200008
#define AES2_ST_BASE   0xfff5200050

#define SHA256_BASE   0xfff5202000

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

#define HMAC_HASH_WORDS SHA256_HASH_WORDS

#endif

