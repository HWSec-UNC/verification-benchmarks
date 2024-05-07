// See LICENSE for license details.

#include <string.h>
#include "aes0.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* aes0;


struct aes0_scan
{
  int compat;
  uint64_t reg;
};

int aes0_start_encrypt(uint32_t *pt, uint32_t *st, uint32_t key_sel)
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
    writeToAddress((uint64_t *)aes0, AES0_START, 0x0);
    return 0; 

}

int aes0_wait()
{
     // Wait for valid output
    while (readFromAddress(aes0, AES0_DONE) == 0) {
        do_delay(AES0_DONE_DELAY); 
    }

    return 0; 

}

int aes0_data_out(uint32_t *ct)
{
    // Read the Encrypted data
    readMultiFromAddress(aes0, AES0_CT_BASE, ct, AES0_CT_WORDS);

    return 0; 
}


int aes0_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel)
{
    aes0_start_encrypt(pt, st,key_sel); 
    aes0_wait();
    aes0_data_out(ct); 
    return 0; 
}

static void aes0_open(const struct fdt_scan_node *node, void *extra)
{
  struct aes0_scan *scan = (struct aes0_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void aes0_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct aes0_scan *scan = (struct aes0_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,aes0")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void aes0_done(const struct fdt_scan_node *node, void *extra)
{
  struct aes0_scan *scan = (struct aes0_scan *)extra;
  if (!scan->compat || !scan->reg || aes0) return;

  // Enable Rx/Tx channels
  aes0 = (void*)(uintptr_t)scan->reg;

}

void query_aes0(uintptr_t fdt)
{
  struct aes0_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5200000; 
  aes0_done(NULL, &scan); 
}
