#ifndef COMMON_DRIVER_FN
#define COMMON_DRIVER_FN

#include <stdint.h>
#include "aes0.h"
#include "aes2.h"

#define NO_MASTERS   3

#define BITS_PER_BYTE   8
#define BYTES_PER_WORD   4
#define BITS_PER_WORD (BITS_PER_BYTE * BYTES_PER_WORD)

#define   HMAC_ID       4
#define   REGLK_ID      9
#define   DMA_ID        8
#define   ACCT_ID       6
#define   PKT_ID        5
#define   SHA256_ID     3
#define   AES1_ID       2
#define   AES0_ID       1
#define   UART_ID       7
#define   ROM_ID        0
#define	  RNG_ID		10
#define   AES2_ID       11
#define   RST_ID        12
#define   RSA_ID        13

// AcCt peripheral 
#define ACCT_WORDS_PER_MASTER   3
#define ACCT_WORDS (NO_MASTERS*ACCT_WORDS_PER_MASTER)

typedef union REG_LOCK_BLOCK {
    uint32_t word; 

    struct packed_struct {
        char s0; 
        char s1; 
        char s2; 
        char s3; 
    } slave_byte; 

} reglk_blk;

// declare the functions
uint32_t readFromAddress(uint64_t volatile *base_addr, uint32_t offset);
void writeToAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t pData);
void readMultiFromAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t *pData, int block_size);
void writeMultiToAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t *pData, int block_size);
void writeMulticharToAddress(uint64_t volatile *base_addr, uint32_t offset, char *pData, int block_byte_size);

void do_delay(int wait_cycles); 

int verifyMulti(uint32_t *expectedData, uint32_t *receivedData, int block_size);

#endif
