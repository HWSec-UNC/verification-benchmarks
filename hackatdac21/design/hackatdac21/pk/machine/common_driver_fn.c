#include <string.h>
#include "common_driver_fn.h"


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
        pData[(block_size - 1) - i] = readFromAddress(pAddress, i);
}

void writeMultiToAddress(uint64_t volatile *base_addr, uint32_t offset, uint32_t *pData, int block_size) {
    uint64_t volatile *pAddress = base_addr + offset; 
    for(unsigned int i = 0; i < block_size; ++i) 
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
   
    for (int i=0; i<block_size; i++)
    {
        if (expectedData[i] != receivedData[i])
            return 0; 
    }

    return match; 
}

