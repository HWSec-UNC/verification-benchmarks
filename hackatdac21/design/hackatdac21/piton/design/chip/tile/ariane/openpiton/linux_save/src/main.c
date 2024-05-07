#include "main.h"
#include "uart.h"
#include "info.h"


#ifndef PITON_SD_BASE_ADDR
#define PITON_SD_BASE_ADDR  0xf000000000L
#endif

#ifndef PITON_SD_LENGTH
#define PITON_SD_LENGTH     0xff0300000L
#endif

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

int main()
{
    init_uart(UART_FREQ, 115200);
    //print_uart(info);

    print_uart("sd initialized!\r\n");


    char buf[100];
    uint64_t raw_addr = PITON_SD_BASE_ADDR;
    uint64_t raw_addr1 = PITON_SD_BASE_ADDR;
    raw_addr1 += ((uint64_t)1) << 9;
    uint32_t num_chars = 0;
    uint32_t size = 1;
    uint64_t * addr = (uint64_t *)raw_addr;
    uint64_t * addr1 = (uint64_t *)raw_addr1;
    volatile uint64_t * p = (uint64_t *)0x80000000UL;
   print_uart("1\r\n");
    for (uint32_t offset = 0; offset < 30000; offset++) {
        *(p++) = *(addr++);
        //print_uart_int(offset);
        //print_uart("\r\n");
    }
    //addr = (uint64_t *)raw_addr;
    //print_uart_addr(addr);
    //print_uart_addr(*(addr++));
    //print_uart("\n");
    //print_uart_addr(addr);
    //print_uart_addr(*(addr++));
    //print_uart("\n");
    //addr1 = (uint64_t *)0x80000000UL;
    //print_uart_addr(addr1);
    //print_uart_addr(*(addr1++));
    //print_uart("\n");
    //print_uart_addr(addr1);
    //print_uart_addr(*(addr1++));
    //print_uart("\n");
    //addr1 = (uint64_t *)0x80011290UL;
    //print_uart_addr(addr1);
    //print_uart_addr(*(addr1++));
    //print_uart("\n");
    //print_uart_addr(addr1);
    //print_uart_addr(*(addr1++));
    //print_uart("\n");
    print_uart("ram loading done fr aws\r\n");
     
    int aes0_working = 1; 
    int aes1_working = 1; 
    int aes2_working = 1; // TODO: Add rest of aes funcs
    int sha256_working = 1; 
    int hmac_working = 1; 
    int rng_working = 1;
    int test_working = 1; 

    //---------------------------------------------------
    // Check if the crypto engines are working properly
    //---------------------------------------------------

    test_working = check_aes0(); 
    aes0_working = test_working; 

    //test_working = check_sha256(); 
    sha256_working = test_working; 

    test_working = check_hmac(); 
    hmac_working = test_working; 

    test_working = check_rng();
    rng_working = test_working;

    if (!(aes0_working && aes1_working && sha256_working && hmac_working && rng_working))
        asm volatile ("call _hang"); 

    asm volatile ("addi x5, x0, 5"); 
    return 0; 
}

int rng_num()
{
    int ct = 0;
    //wait for valid rng
    while(readFromAddress(rng, RNG_VALID) == 0){
        do_delay(RNG_VALID_DELAY);
        ct++;
        if (ct > 10000000)
            return 0;
    }
 
    //read rng
    //readMultiFromAddress(rng, RNG_RNUM_BASE, randnum, RNG_RNUM_WORDS);

    return 1;
}

int check_rng()
{
    //uint32_t randnum[2];
  
  
    //printm("check rng %08x, %08x\n", randnum[0], randnum[1]);
  
    if (rng_num() == 1)
        return 1;
    else
        return 0;

    return 0;
}


int aes0_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel)
{
    // Write the inputs
    writeToAddress(aes0, AES0_KEY_SEL, key_sel); 
    writeMultiToAddress(aes0, AES0_PT_BASE, pt, AES0_PT_WORDS); 
    writeMultiToAddress(aes0, AES0_ST_BASE, st, AES0_ST_WORDS); 

    // Start the AES encryption
    writeToAddress(aes0, AES0_START, 0x0);
    writeToAddress(aes0, AES0_START, 0x1);

    // Wait to see that START has been asserted to make sure DONE has a valid value
    while (readFromAddress(aes0, AES0_START) == 0) {
        do_delay(AES0_START_DELAY); 
    }
    writeToAddress(aes0, AES0_START, 0x0);

     // Wait for valid output
    while (readFromAddress(aes0, AES0_DONE) == 0) {
        do_delay(AES0_DONE_DELAY); 
    }

    // Read the Encrypted data
    readMultiFromAddress(aes0, AES0_CT_BASE, ct, AES0_CT_WORDS);

    return 0; 
}

int check_aes0()
{
    //// Give a test input and verify AES enryption
    //printm("    Verifying AES crypto engine ...\n") ;
   
    // Input for AES encyption
    uint32_t pt[4]  = {0x0024113a, 0x2ff23783, 0x5f44b551, 0x2266a7a6};
    uint32_t st[4]  = {0x2245f678, 0xa8caf0fd, 0x413197af, 0xb03a0f32};
    uint32_t key[6] = {0xab7d152f, 0xc8ae6226, 0xcba76688, 0xabcf2236, 0x77731ecd, 0x35a2bdaa};
    uint32_t ct[AES0_CT_WORDS];
    uint32_t expectedCt[AES0_CT_WORDS] = {0x114f83c3, 0xc4029249, 0x1d52a753, 0x103cf58f};

    uint32_t key_sel = 0; 

    int aes0_working; 

    // Write the AES key 
    writeMultiToAddress(aes0, AES0_KEY0_BASE, key, AES0_KEY_WORDS); 

    // call the aes encryption function
    aes0_encrypt(pt, st, ct, key_sel); 

    // Verify the Encrypted data
    aes0_working = verifyMulti(expectedCt, ct, AES0_CT_WORDS); 

    //if (aes0_working)
    //    printm("    AES engine encryption successfully verified\n"); 
    //else
    //    printm("    AES engine failed, disabling the crypto engine !\n");

    return aes0_working ;  
    
}

int sha256_hashString(char *pString, uint32_t *hash)
{
  //char *ptr = pString;
    //printm("starting sha256 encryption, data received = \n");
    //printm("%s\n", ptr); 
     

    int done = 0;
    int firstTime = 1;
    int totalBytes = 0;
    
    while(!done) {
        char message[2 * SHA256_TEXT_BITS];
        for (int i=0; i<2*SHA256_TEXT_BYTES; i++)
            message[i] = 0; 
        
        // Copy next portion of string to message buffer
        char *msg_ptr = message;
        int length = 0;
        while(length < SHA256_TEXT_BYTES) {
            // Check for end of input
            if(*pString == '\0') {
                done = 1;
                break;
            }
            *msg_ptr++ = *pString++;
            ++length;
            ++totalBytes;
        }
        
        // Need to add padding if done
        int addedBytes = 0;
        if(done) {
            addedBytes = sha256_addPadding(totalBytes * BITS_PER_BYTE, message);
        }
        
        // Send the message
        while (readFromAddress(sha256, SHA256_READY) == 0) {
            do_delay(SHA256_READY_DELAY); 
        }

        writeMulticharToAddress(sha256, SHA256_TEXT_BASE, message, SHA256_TEXT_BYTES); 

        // start the hashing
        if(firstTime) {
            //strobeInit();
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x1); 
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x0); 
            firstTime = 0;
        } else {
            //strobeNext();
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x2); 
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x0); 
        }

        // wait for SHA256 to start
        do_delay(20); 

        // wait for valid output
        while (readFromAddress(sha256, SHA256_VALID) == 0) {
            do_delay(SHA256_VALID_DELAY); 
        }

        //waitForReady ?

        // if data to send > 512 bits send again
        if (addedBytes > SHA256_TEXT_BYTES) {
            while (readFromAddress(sha256, SHA256_READY) == 0) {
                do_delay(SHA256_READY_DELAY); 
            }

            writeMultiToAddress(sha256, SHA256_TEXT_BASE, (uint32_t *)(message + SHA256_TEXT_BYTES), SHA256_TEXT_WORDS); 

            // start the hashing
            //strobeNext();
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x2); 
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x0); 

            // wait for SHA256 to start
            do_delay(20); 

            // wait for valid output
            while (readFromAddress(sha256, SHA256_VALID) == 0) {
                do_delay(SHA256_VALID_DELAY); 
            }
        }
    }

    // Read the Hash
    readMultiFromAddress(sha256, SHA256_HASH_BASE, hash, SHA256_HASH_WORDS); 

    //printm("mcall hash = %08x %08x %08x %08x %08x %08x %08x %08x \n", hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], hash[6], hash[7]);

    return 0; 

}


int sha256_addPadding(uint64_t pMessageBits64Bit, char* buffer) {
    int extraBits = pMessageBits64Bit % SHA256_TEXT_BITS;
    int paddingBits = extraBits > 448 ? (2 * SHA256_TEXT_BITS) - extraBits : SHA256_TEXT_BITS - extraBits;
    
    // Add size to end of string
    const int startByte = extraBits / BITS_PER_BYTE;
    const int sizeStartByte =  startByte + ((paddingBits / BITS_PER_BYTE) - 8);

    for(int i = startByte; i < (sizeStartByte + 8); ++i) {
        if(i == startByte) {
            buffer[i] = 0x80; // 1 followed by many 0's
        } else if( i >= sizeStartByte) {
            int offset = i - sizeStartByte;
            int shftAmnt = 56 - (8 * offset);
            buffer[i] = (pMessageBits64Bit >> shftAmnt) & 0xFF;
        } else {
            buffer[i] = 0x0;
        }
    }
    
    return (paddingBits / BITS_PER_BYTE);
}


int check_sha256()
{
    //// Give a test input and verify AES enryption
    //printm("    Verifying SHA256 crypto engine ...\n") ;
   
    // Input for SHA256 encyption
    char inputText[50] = "tom meets jack in Partom meets jack in Pari";
    //char inputText[500] = "abc";
    uint32_t hash[SHA256_HASH_WORDS];
    uint32_t expectedHash[SHA256_HASH_WORDS] = {0x0f0fae19, 0xb7d3585b, 0x20ef2066, 0x02a0edca, 0x10aefc11, 0xfc3fe2b0, 0x1d24185b, 0x003afba2};

    int sha256_working; 

    // call the sha256 hashing function
    sha256_hashString(inputText, hash);

    // Verify the Hash 
    sha256_working = verifyMulti(expectedHash, hash, SHA256_HASH_WORDS); 
    
    //if (sha256_working)
    //    printm("    SHA256 engine hashing successfully verified\n"); 
    //else
    //    printm("    SHA256 engine failed, disabling the crypto engine !\n");

    return sha256_working ;  
}

int hmac_hashString(char *pString, uint32_t *hash, uint32_t use_key_hash)
{
    char *ptr = pString;
     

    // Send the message
    while (readFromAddress(hmac, HMAC_READY) == 0) {
        do_delay(HMAC_READY_DELAY); 
    }

    writeMulticharToAddress(hmac, HMAC_TEXT_BASE, pString, HMAC_TEXT_BYTES); 

    //strobeInit();
    if (use_key_hash) {
        writeToAddress(hmac, HMAC_NEXT_INIT, 0x5); 
        writeToAddress(hmac, HMAC_NEXT_INIT, 0x4); 
    } else {
        writeToAddress(hmac, HMAC_NEXT_INIT, 0x1); 
        writeToAddress(hmac, HMAC_NEXT_INIT, 0x0); 
    }

    // wait for HMAC to start
    do_delay(20); 

    // wait for valid output
    while (readFromAddress(hmac, HMAC_VALID) == 0) {
        do_delay(HMAC_VALID_DELAY); 
    }

    // Read the Hash
    readMultiFromAddress(hmac, HMAC_HASH_BASE, hash, HMAC_HASH_WORDS); 

    return 0; 
}


int check_hmac()
{
    //// Give a test input and verify AES enryption
    //printf("    Verifying HMAC crypto engine ...\n") ;
   
    // Input for HMAC encyption
    char inputText[65] = "----> this is the message to test hmac mod for hackadac'20 <----";
    //char inputText[500] = "abc";
    uint32_t hash[HMAC_HASH_WORDS];
    uint32_t expectedHash[HMAC_HASH_WORDS] = {0xe2fcbb9f,0xe426e269,0xc1a1ade9,0xc9d53cb7,0xa086fbf3,0x75836f93,0xd5761d02,0x0ecd9fe8};
    uint32_t key[8] = {0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c, 0x2b7e1516, 0x28aed2a6, 0x2b7e1516, 0x28aed2a6};
    
    int hmac_working; 
    int use_key_hash = 0; 

    writeMultiToAddress(hmac, HMAC_KEY_BASE, key, HMAC_KEY_WORDS); 

    // call the hmac hashing function
    hmac_hashString(inputText, hash, use_key_hash);
    //printf("encrypted data : %x %x %x %x\n", hash[0], hash[1], hash[2], hash[3]); 
    //printf("encrypted data : %x %x %x %x\n", hash[4], hash[5], hash[6], hash[7]); 

    // Verify the Hash 
    hmac_working = verifyMulti(expectedHash, hash, HMAC_HASH_WORDS); 
    
    //if (hmac_working)
    //    printf("    HMAC engine hashing successfully verified\n"); 
    //else
    //    printf("    HMAC engine failed, disabling the crypto engine !\n");

    return hmac_working ;  
}



uint32_t readFromAddress(uint64_t volatile *base_addr, uint32_t offset) {
    uint64_t volatile *pAddress = base_addr + offset; 
    
    #ifndef TESTING
    return *((volatile uint32_t *)pAddress);
    #else
    printm("reading from location %x \n",pAddress ); 
    return 1; 
    #endif

}

void writeToAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t pData) {
    uint64_t volatile *pAddress = base_addr + offset; 

    #ifndef TESTING
    *((volatile uint32_t *)pAddress) = pData;
    #else
    printm("writing to %x, data = %x\n",pAddress, pData );
    #endif
}


void readMultiFromAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t *pData, int block_size) {
    uint64_t volatile *pAddress = base_addr + offset; 
    for(unsigned int i = 0; i < block_size; ++i) 
        //pData[(block_size - 1) - i] = readFromAddress(pAddress + (i * BYTES_PER_WORD));
        //pData[(block_size - 1) - i] = readFromAddress(pAddress, (i * BYTES_PER_WORD));
        pData[(block_size - 1) - i] = readFromAddress(pAddress, i);
}

void writeMultiToAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t *pData, int block_size) {
    uint64_t volatile *pAddress = base_addr + offset; 
    for(unsigned int i = 0; i < block_size; ++i) 
        //writeToAddress(pAddress + (((block_size - 1) - i) * BYTES_PER_WORD), pData[i]);
        //writeToAddress(pAddress, (((block_size - 1) - i) * BYTES_PER_WORD), pData[i]);
        writeToAddress(pAddress, ((block_size - 1) - i), pData[i]);
}

void writeMulticharToAddress(uint64_t volatile *base_addr, uint32_t offset, char *pData, int block_byte_size) {
    
    uint64_t volatile *pAddress = base_addr + offset; 
    uint32_t wdata; 
    int block_ptr = 0; 
    int block_size = block_byte_size / BYTES_PER_WORD ; 

    wdata = 0; 
    for(int i = (block_byte_size-1); i >= 0; i--) {
        wdata = ( wdata << 8 ) | ((*pData++) & 0xFF);
        
        if (i % BYTES_PER_WORD == 0)  {
            //writeToAddress(pAddress + (((block_size - 1) - block_ptr) * BYTES_PER_WORD), wdata);
            //writeToAddress(pAddress, (((block_size - 1) - block_ptr) * BYTES_PER_WORD), wdata);
            writeToAddress(pAddress, ((block_size - 1) - block_ptr) , wdata);
            block_ptr++; 
        }
    }
}

void do_delay(int wait_cycles) {
    for (int i=0; i<wait_cycles; i++)
        asm volatile ("nop \n\t") ;   
}


int verifyMulti(uint32_t *expectedData, uint32_t *receivedData, int block_size) {


    // check for overflow of source and destination address
    if (expectedData + block_size < expectedData) // true only on overflow
        return 0;  // abort if overflow 
    if (receivedData + block_size < receivedData) // true only on overflow
        return 0;  // abort if overflow 

    int match = 1; 
   
    for (int i=0; i<2; i++)
    {
        if (expectedData[i] != receivedData[i])
            match = 0;
        else
            match = 1;  
    }

    return match; 
}


void * memcpy(void *to, const void *from, size_t numBytes)
{
    for (int i=0; i<numBytes; i++)
        *((char *)to+i) = *((char *)from+i);
    return to; 
} 

void * memcpy_w(void *to, const void *from, size_t numWords)
{
    for (int i=0; i<numWords; i++)
        *((uint32_t *)to+i) = *((uint32_t *)from+i);
    return to; 
} 

void *memset(void *ptr, int x, size_t n)
{
    for (int i=0; i<n; i++)
        *((char *)ptr+i) = x;
    return ptr;
}



void handle_trap(void)
{
    // print_uart("trap\r\n");
}
