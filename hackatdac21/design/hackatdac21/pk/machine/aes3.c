// See LICENSE for license details.

#include <string.h>
#include "aes3.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint32_t* aes3;


struct aes3_scan
{
  int compat;
  uint64_t reg;
};

int aes3_start_encrypt(uint32_t *pt, uint32_t *st, uint32_t key_sel)
{

    // Write the inputs
    writeToAddress((uint32_t *)aes3, AES3_KEY_SEL, key_sel); 
    writeMultiToAddress((uint32_t *)aes3, AES3_PT_BASE, pt, AES3_PT_WORDS); 
    writeMultiToAddress((uint32_t *)aes3, AES3_ST_BASE, st, AES3_ST_WORDS); 

    // Start the AES3 encryption
    writeToAddress((uint32_t *)aes3, AES3_START, 0x0);
    writeToAddress((uint32_t *)aes3, AES3_START, 0x1);

    // Wait to see that START has been asserted to make sure DONE has a valid value
    while (readFromAddress((uint32_t *)aes3, AES3_START) == 0) {
        do_delay(AES3_START_DELAY); 
    }
    writeToAddress((uint32_t *)aes3, AES3_START, 0x0);
    return 0; 

}

int aes3_wait()
{
     // Wait for valid output
    while (readFromAddress((uint32_t *)aes3, AES3_DONE) == 0) {
        do_delay(AES3_DONE_DELAY); 
    }

    return 0; 

}

int aes3_data_out(uint32_t *ct)
{
    // Read the Encrypted data
    readMultiFromAddress((uint32_t *)aes3, AES3_CT_BASE, ct, AES3_CT_WORDS);

    return 0; 
}


int aes3_encrypt(uint32_t *pt, uint32_t *st, uint32_t *ct, uint32_t key_sel)
{
    aes3_start_encrypt(pt, st,key_sel); 
    aes3_wait();
    aes3_data_out(ct); 
    return 0; 
}


static void aes3_open(const struct fdt_scan_node *node, void *extra)
{
  struct aes3_scan *scan = (struct aes3_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void aes3_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct aes3_scan *scan = (struct aes3_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,aes3")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void aes3_done(const struct fdt_scan_node *node, void *extra)
{
  struct aes3_scan *scan = (struct aes3_scan *)extra;
  if (!scan->compat || !scan->reg || aes3) return;

  // Enable Rx/Tx channels
  aes3 = (void*)(uintptr_t)scan->reg;

}

void query_aes3(uintptr_t fdt)
{
  struct fdt_cb cb;
  struct aes3_scan scan;

  memset(&cb, 0, sizeof(cb));
  cb.open = aes3_open;
  cb.prop = aes3_prop;
  cb.done = aes3_done;
  cb.extra = &scan;

  fdt_scan(fdt, &cb);
}
