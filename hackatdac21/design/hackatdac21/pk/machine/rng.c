#include <string.h>
#include "rng.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* rng;

struct rng_scan
{
  int compat;
  uint64_t reg;
};
int rng_wait()
{
	while(readFromAddress(rng, RNG_VALID) == 0){
		do_delay(RNG_VALID_DELAY);
	}

	return 0;
} 

int rng_read_data(uint32_t *randnum)
{
    readMultiFromAddress(rng, RNG_RNUM_BASE, randnum, RNG_RNUM_WORDS);

    return 0;

}

//functions for debug mode
int rng_read_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16)
{
  readMultiFromAddress(rng, RNG_POLY128_BASE, poly128, RNG_POLY128_WORDS);
  readMultiFromAddress(rng, RNG_POLY64_BASE, poly64, RNG_POLY64_WORDS);
  readMultiFromAddress(rng, RNG_POLY32_BASE, poly32, RNG_POLY32_WORDS);
  readMultiFromAddress(rng, RNG_POLY16_BASE, poly16, RNG_POLY16_WORDS);

  return 0;
}

int rng_write_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16)
{
  writeMultiToAddress(rng, RNG_POLY128_BASE, poly128, RNG_POLY128_WORDS);
  writeMultiToAddress(rng, RNG_POLY64_BASE, poly64, RNG_POLY64_WORDS);
  writeMultiToAddress(rng, RNG_POLY32_BASE, poly32, RNG_POLY32_WORDS);
  writeMultiToAddress(rng, RNG_POLY16_BASE, poly16, RNG_POLY16_WORDS);

  return 0;
}

int rng_read_seed(uint32_t *seed128, uint32_t *seed64, uint32_t *seed32, uint32_t *seed16)
{
  readMultiFromAddress(rng, RNG_SEED_OUT128_BASE, seed128, RNG_SEED_OUT128_WORDS);
  readMultiFromAddress(rng, RNG_SEED_OUT64_BASE, seed64, RNG_SEED_OUT64_WORDS);
  readMultiFromAddress(rng, RNG_SEED_OUT32_BASE, seed32, RNG_SEED_OUT32_WORDS);
  readMultiFromAddress(rng, RNG_SEED_OUT16_BASE, seed16, RNG_SEED_OUT16_WORDS);

  return 0;
}

int rng_write_seed(uint32_t *seed128)
{
  writeMultiToAddress(rng, RNG_SEED_BASE, seed128, RNG_SEED_WORDS);

  return 0;
}


int rng_read_rand_seg(uint32_t *rand_seg)
{
  readMultiFromAddress(rng, RNG_SEG_OUT_BASE, rand_seg, RNG_SEG_OUT_WORDS);

  return 0;
}

int rng_read_state_counter(uint32_t *st_cnt)
{
  readMultiFromAddress(rng, RNG_STATE, st_cnt, RNG_STATE_WORDS);

  return 0;
}


static void rng_open(const struct fdt_scan_node *node, void *extra)
{
  struct rng_scan *scan = (struct rng_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void rng_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct rng_scan *scan = (struct rng_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,rng")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void rng_done(const struct fdt_scan_node *node, void *extra)
{
  struct rng_scan *scan = (struct rng_scan *)extra;
  if (!scan->compat || !scan->reg || rng) return;

  // Enable Rx/Tx channels
  rng = (void*)(uintptr_t)scan->reg;

}

void query_rng(uintptr_t fdt)
{
  struct rng_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5208000; 
  rng_done(NULL, &scan); 
}
