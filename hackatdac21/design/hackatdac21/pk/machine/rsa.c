#include <string.h>
#include "rsa.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* rsa;

struct rsa_scan
{
  int compat;
  uint64_t reg;
};

int rsa_wait()
{
	while(readFromAddress(rsa, RSA_VALID) == 0){
		do_delay(RSA_VALID_DELAY);
	}

	return 0;
} 

int rsa_write_prime_num(uint32_t *p_num)
{
  writeMultiToAddress(rsa, RSA_PRIME_BASE, p_num, RSA_PNUM_WORDS);
  do_delay(RSA_LOAD_DELAY);
  writeToAddress(rsa, RSA_RST_KEY_BASE, 0x0);
  writeToAddress(rsa, RSA_RST_KEY_BASE, 0x1);

  return 0;
}


int rsa_write_msg_in(uint32_t *msg_in, uint32_t encry_decry)
{
  writeMultiToAddress(rsa, RSA_MSG_IN_BASE, msg_in, RSA_MSG_IN_WORDS);
  writeToAddress(rsa, RSA_ENCRY_DECRY_BASE, encry_decry);
  do_delay(RSA_LOAD_DELAY);
  writeToAddress(rsa, RSA_RST_MSG_BASE, 0x0);
  writeToAddress(rsa, RSA_RST_MSG_BASE, 0x1);

  return 0;
}

int rsa_read_msg_out(uint32_t *msg_out)
{
  readMultiFromAddress(rsa, RSA_MSG_OUT_BASE, msg_out, RSA_MSG_OUT_WORDS);

  return 0;
}


static void rsa_open(const struct fdt_scan_node *node, void *extra)
{
  struct rsa_scan *scan = (struct rsa_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void rsa_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct rsa_scan *scan = (struct rsa_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,rsa")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void rsa_done(const struct fdt_scan_node *node, void *extra)
{
  struct rsa_scan *scan = (struct rsa_scan *)extra;
  if (!scan->compat || !scan->reg || rsa) return;

  // Enable Rx/Tx channels
  rsa = (void*)(uintptr_t)scan->reg;

}

void query_rsa(uintptr_t fdt)
{
  struct rsa_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5211000; 
  rsa_done(NULL, &scan); 
}
