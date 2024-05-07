#include <string.h>
#include "rst.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* rst;

struct rst_scan 
{
	int compat;
	uint64_t reg;
};

int rst_id(uint32_t id) {
	if(id > 13) {
		printm("error: cannot have ID larger than 13\n");
		return 0;
	}
	
	// write the input ID
	writeToAddress(rst, RST_ID_BASE, id);
	
	// send start signal
	writeToAddress(rst, RST_START, 0x0);
	writeToAddress(rst, RST_START, 0x1);
	
	// Wait to see that START has been asserted to make sure DONE has a valid value
    while (readFromAddress(rst, RST_START) == 0) {
        do_delay(RST_START_DELAY); 
    }
	
	writeToAddress((uint64_t *)rst, RST_START, 0x0);
    return 0; 
}

static void rst_open(const struct fdt_scan_node *node, void *extra)
{
  struct rst_scan *scan = (struct rst_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void rst_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct rst_scan *scan = (struct rst_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,rst")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void rst_done(const struct fdt_scan_node *node, void *extra)
{
  struct rst_scan *scan = (struct rst_scan *)extra;
  if (!scan->compat || !scan->reg || rst) return;

  // Enable Rx/Tx channels
  rst = (void*)(uintptr_t)scan->reg;

}

void query_rst(uintptr_t fdt)
{
  struct rst_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff520A000; 
  rst_done(NULL, &scan); 
}