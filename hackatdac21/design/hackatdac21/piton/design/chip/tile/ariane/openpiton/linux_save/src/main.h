#ifndef MAIN_H
#define MAIN_H

//#define TESTING

#include <stdint.h>
#include <stddef.h>

#define NO_MASTERS   1

#define BITS_PER_BYTE   8
#define BYTES_PER_WORD   4
#define BITS_PER_WORD (BITS_PER_BYTE * BYTES_PER_WORD)

//RNG
volatile uint64_t* rng = 0xfff5208000;
#define RNG_LOAD_DELAY 1
#define RNG_VALID_DELAY 1

// peripheral registers
#define RNG_SEED_BITS   64
#define RNG_RNUM_BITS   64
#define RNG_LOAD_WORDS  1
#define RNG_VALID_WORDS   1
#define RNG_SEED_WORDS (RNG_SEED_BITS / BITS_PER_WORD)
#define RNG_RNUM_WORDS (RNG_RNUM_BITS / BITS_PER_WORD)

//#define RNG_LOAD   0
//#define RNG_SEED_BASE ( RNG_LOAD      + RNG_LOAD_WORDS )
//#define RNG_RNUM_BASE ( RNG_SEED_BASE + RNG_SEED_WORDS )
#define RNG_VALID    14     //( RNG_RNUM_BASE + RNG_RNUM_WORDS )
int rng_num();
int check_rng();

//RNG


volatile uint64_t* aes0 = 0xfff5200000;

#define AES0_ENCRYPT_ID 0
#define AES0_DECRYPT_ID 1

#define AES0_START_DELAY 1
#define AES0_DONE_DELAY 4

// peripheral registers
#define AES0_NO_KEYS 3
#define AES0_PT_BITS   128
#define AES0_ST_BITS   128
#define AES0_KEY_BITS   192
#define AES0_CT_BITS   128
#define AES0_START_WORDS  1
#define AES0_DONE_WORDS   1
#define AES0_PT_WORDS (AES0_PT_BITS / BITS_PER_WORD)
#define AES0_ST_WORDS (AES0_ST_BITS / BITS_PER_WORD)
#define AES0_KEY_WORDS (AES0_KEY_BITS / BITS_PER_WORD)
#define AES0_CT_WORDS (AES0_CT_BITS / BITS_PER_WORD)

#define AES0_START   0
#define AES0_PT_BASE   ( AES0_START     + AES0_START_WORDS )
#define AES0_KEY0_BASE ( AES0_PT_BASE   + AES0_PT_WORDS )
#define AES0_DONE      ( AES0_KEY0_BASE + AES0_KEY_WORDS )
#define AES0_CT_BASE   ( AES0_DONE      + AES0_DONE_WORDS )
#define AES0_ST_BASE   ( AES0_CT_BASE   + AES0_CT_WORDS )
#define AES0_KEY1_BASE ( AES0_ST_BASE   + AES0_ST_WORDS )
#define AES0_KEY2_BASE ( AES0_KEY1_BASE + AES0_KEY_WORDS )
#define AES0_KEY_SEL   ( AES0_KEY2_BASE + AES0_KEY_WORDS )

int aes0_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel);
int check_aes0(); 

// AES2
volatile uint64_t* aes2 = 0xfff5209000;
#define AES2_ENCRYPT_ID 0
#define AES2_DECRYPT_ID 1

#define AES2_START_DELAY 1
#define AES2_DONE_DELAY 4

// peripheral registers
#define AES2_NO_KEYS 3
#define AES2_PT_BITS   128
#define AES2_ST_BITS   128
#define AES2_KEY_BITS  128
#define AES2_CT_BITS   128
#define AES2_START_WORDS  1
#define AES2_DONE_WORDS   1
#define AES2_PT_WORDS (AES2_PT_BITS / BITS_PER_WORD)
#define AES2_ST_WORDS (AES2_ST_BITS / BITS_PER_WORD)
#define AES2_KEY_WORDS (AES2_KEY_BITS / BITS_PER_WORD)
#define AES2_CT_WORDS (AES2_CT_BITS / BITS_PER_WORD)

#define AES2_START   0
#define AES2_PT_BASE   ( AES2_START     + AES2_START_WORDS )
#define AES2_KEY0_BASE ( AES2_PT_BASE   + AES2_PT_WORDS )
#define AES2_DONE      ( AES2_KEY0_BASE + AES2_KEY_WORDS )
#define AES2_CT_BASE   ( AES2_DONE      + AES2_DONE_WORDS )
#define AES2_ST_BASE   ( AES2_CT_BASE   + AES2_CT_WORDS )
#define AES2_KEY1_BASE ( AES2_ST_BASE   + AES2_ST_WORDS )
#define AES2_KEY2_BASE ( AES2_KEY1_BASE + AES2_KEY_WORDS )
#define AES2_KEY_SEL   ( AES2_KEY2_BASE + AES2_KEY_WORDS )

int aes2_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel);
int check_aes2(); 


volatile uint64_t* sha256 = 0xfff5202000;


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


volatile uint64_t* hmac = 0xfff5203000 ;
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



volatile uint64_t* dma = 0xfff5207000;

#define DMA_START 0
#define DMA_LENGTH 1
#define DMA_SRC_ADDR_LSB 2
#define DMA_SRC_ADDR_MSB 3
#define DMA_DST_ADDR_LSB 4
#define DMA_DST_ADDR_MSB 5
#define DMA_DONE 6
#define DMA_LOCK 7
#define DMA_END 8
#define DMA_VALID 9

#define DMA_DONE_MASK 0x8
#define DMA_READ_MASK 0x2
#define DMA_WRITE_MASK 0x4


void acquire_dma();

int sha256_hashString(char *pString, uint32_t *hash);
int sha256_addPadding(uint64_t pMessageBits64Bit, char* buffer);
int check_sha256(); 


// declare the functions
uint32_t readFromAddress(uint64_t volatile *base_addr, uint32_t offset);
void writeToAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t pData);
void readMultiFromAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t *pData, int block_size);
void writeMultiToAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t *pData, int block_size);
void writeMulticharToAddress(uint64_t volatile *base_addr, uint32_t offset, char *pData, int block_byte_size);

void do_delay(int wait_cycles); 

int verifyMulti(uint32_t *expectedData, uint32_t *receivedData, int block_size);

void * memcpy(void *to, const void *from, size_t numBytes);
void * memcpy_w(void *to, const void *from, size_t numWords); 
void *memset(void *ptr, int x, size_t n);

#endif
