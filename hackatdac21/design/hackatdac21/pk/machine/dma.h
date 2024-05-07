// See LICENSE for license details.

#ifndef _RISCV_DMA_H
#define _RISCV_DMA_H

#include <stdint.h>

extern volatile uint64_t* dma;

#define DMA_WAIT_DELAY 100
#define DMA_START_DELAY 2


// peripheral registers
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


int dma_transfer(uint64_t sAddress, uint64_t dAddress, uint32_t length, uint32_t wait);
void dma_end();

void query_dma(uintptr_t dtb);

#endif
