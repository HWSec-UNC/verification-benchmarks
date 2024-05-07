// See LICENSE for license details.

#include <string.h>
#include "dma.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* dma;


struct dma_scan
{
  int compat;
  uint64_t reg;
};

int dma_transfer(uint64_t sAddress, uint64_t dAddress, uint32_t length, uint32_t wait) {
    
    uint32_t rdata; 
    uint32_t sAddress_lsb = sAddress; 
    uint32_t sAddress_msb = sAddress >> 32; 
    uint32_t dAddress_lsb = dAddress; 
    uint32_t dAddress_msb = dAddress >> 32; 

    // check for overflow of source and destination address
    if (sAddress + length < sAddress) // true only on overflow
        return 0;  // abort if overflow
    if (dAddress + length < dAddress) // true only on overflow
        return 0;   // abort if overflow

    // get the lock
    writeToAddress(dma, DMA_LOCK, 2); 
    while (readFromAddress(dma, DMA_LOCK) != 2) {
        do_delay(DMA_WAIT_DELAY); 
        writeToAddress(dma, DMA_LOCK, 2); 
    }

    // Configure the DMA
    writeToAddress(dma, DMA_DONE, 0); 
    writeToAddress(dma, DMA_SRC_ADDR_LSB, sAddress_lsb);  
    writeToAddress(dma, DMA_SRC_ADDR_MSB, sAddress_msb);  
    writeToAddress(dma, DMA_DST_ADDR_LSB, dAddress_lsb);  
    writeToAddress(dma, DMA_DST_ADDR_MSB, dAddress_msb);  
    writeToAddress(dma, DMA_LENGTH, length); 


    // State the DMA
    writeToAddress(dma, DMA_START, 0x01); 
    writeToAddress(dma, DMA_LOCK, 0); 

    // If wait == 1, wait till transfer is done
    if (wait) {
        while (readFromAddress(dma, DMA_DONE) != 1) {
            do_delay(DMA_WAIT_DELAY); 
        }
    }

    return 0; 
}

void dma_end() {
    
    writeToAddress(dma, DMA_END, 1); 

    return; 
}

static void dma_open(const struct fdt_scan_node *node, void *extra)
{
  struct dma_scan *scan = (struct dma_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void dma_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct dma_scan *scan = (struct dma_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,dma")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void dma_done(const struct fdt_scan_node *node, void *extra)
{
  struct dma_scan *scan = (struct dma_scan *)extra;
  if (!scan->compat || !scan->reg || dma) return;

  // Enable Rx/Tx channels
  dma = (void*)(uintptr_t)scan->reg;
}

void query_dma(uintptr_t fdt)
{

  //fdt_scan(fdt, &cb);
  struct dma_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5207000; 
  dma_done(NULL, &scan); 
}
