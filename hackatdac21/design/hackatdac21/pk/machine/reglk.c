// See LICENSE for license details.

#include <string.h>
#include "reglk.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* reglk;


struct reglk_scan
{
  int compat;
  uint64_t reg;
};

static void reglk_open(const struct fdt_scan_node *node, void *extra)
{
  struct reglk_scan *scan = (struct reglk_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void reglk_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct reglk_scan *scan = (struct reglk_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,reglk")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void reglk_done(const struct fdt_scan_node *node, void *extra)
{
  struct reglk_scan *scan = (struct reglk_scan *)extra;
  if (!scan->compat || !scan->reg || reglk) return;

  // Enable Rx/Tx channels
  reglk = (void*)(uintptr_t)scan->reg;

}

void query_reglk(uintptr_t fdt)
{
  //fdt_scan(fdt, &cb);
  struct reglk_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5206000; 
  reglk_done(NULL, &scan); 
}
