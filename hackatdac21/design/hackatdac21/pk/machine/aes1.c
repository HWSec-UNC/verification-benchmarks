// See LICENSE for license details.

#include <string.h>
#include "aes1.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* aes1;


struct aes1_scan
{
  int compat;
  uint64_t reg;
};

int aes1_read_data(uint32_t *result)
{
    readMultiFromAddress(aes1, AES1_RES_BASE, result, AES1_RES_WORDS); 
    return 0; 
}

int aes1_write_data(uint32_t *block, uint32_t key_sel)
{

    // Write the inputs
    writeMultiToAddress(aes1, AES1_BLK_BASE, block, AES1_BLK_WORDS); 
    writeToAddress(aes1, AES1_KEY_SEL, key_sel);

    return 0; 

}

int aes1_read_config(uint32_t *config_o)
{
    *config_o = readFromAddress(aes1, AES1_STATUS_BASE); 
    return 0; 
}

int aes1_write_config(uint32_t config_i)
{
    writeToAddress(aes1, AES1_ENC_DEC, config_i % 2);
    writeToAddress(aes1, AES1_CTRL_BASE, (config_i/2) % 4);
    return 0; 

}

static void aes1_open(const struct fdt_scan_node *node, void *extra)
{
  struct aes1_scan *scan = (struct aes1_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void aes1_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct aes1_scan *scan = (struct aes1_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,aes1")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void aes1_done(const struct fdt_scan_node *node, void *extra)
{
  struct aes1_scan *scan = (struct aes1_scan *)extra;
  if (!scan->compat || !scan->reg || aes1) return;

  // Enable Rx/Tx channels
  aes1 = (void*)(uintptr_t)scan->reg;

}

void query_aes1(uintptr_t fdt)
{
  //fdt_scan(fdt, &cb);
  struct aes1_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5201000; 
  aes1_done(NULL, &scan); 
}
