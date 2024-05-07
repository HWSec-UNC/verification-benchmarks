// See LICENSE for license details.

#include <string.h>
#include "aes2.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* aes2;


struct aes2_scan
{
  int compat;
  uint64_t reg;
};

int aes2_start_encrypt(uint32_t *pt, uint32_t *st, uint32_t key_sel)
{
    // Write the inputs
    writeToAddress(aes2, AES2_KEY_SEL, key_sel);
    writeMultiToAddress(aes2, AES2_PT_BASE, pt, AES2_PT_WORDS); 
    writeMultiToAddress(aes2, AES2_ST_BASE, st, AES2_ST_WORDS); 

    // Start the AES encryption
    writeToAddress(aes2, AES2_START, 0x0);
    writeToAddress(aes2, AES2_START, 0x1);

    // Wait to see that START has been asserted to make sure DONE has a valid value
    while (readFromAddress(aes2, AES2_START) == 0) {
        do_delay(AES2_START_DELAY); 
    }
    writeToAddress((uint64_t *)aes2, AES2_START, 0x0);
    return 0; 

}

int aes2_wait()
{
     // Wait for valid output
    while (readFromAddress(aes2, AES2_DONE) == 0) {
        do_delay(AES2_DONE_DELAY); 
    }

    return 0; 

}

int aes2_data_out(uint32_t *ct)
{
    // Read the Encrypted data
    readMultiFromAddress(aes2, AES2_CT_BASE, ct, AES2_CT_WORDS);

    return 0; 
}


int aes2_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel)
{
    aes2_start_encrypt(pt, st, key_sel); 
    aes2_wait();
    aes2_data_out(ct); 
    return 0; 
}

static void aes2_open(const struct fdt_scan_node *node, void *extra)
{
  struct aes2_scan *scan = (struct aes2_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void aes2_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct aes2_scan *scan = (struct aes2_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,aes2")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void aes2_done(const struct fdt_scan_node *node, void *extra)
{
  struct aes2_scan *scan = (struct aes2_scan *)extra;
  if (!scan->compat || !scan->reg || aes2) return;

  // Enable Rx/Tx channels
  aes2 = (void*)(uintptr_t)scan->reg;

}

void query_aes2(uintptr_t fdt)
{
  struct aes2_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5209000; 
  aes2_done(NULL, &scan); 
}
