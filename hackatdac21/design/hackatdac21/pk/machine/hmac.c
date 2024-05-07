// See LICENSE for license details.

#include <string.h>
#include "hmac.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* hmac;

struct hmac_scan
{
  int compat;
  uint64_t reg;
};

int hmac_hashString(char *pString, uint32_t *hash, uint32_t use_key_hash)
{
    char *ptr = pString;
     

    // Send the message
    while (readFromAddress(hmac, HMAC_READY) == 0) {
        do_delay(HMAC_READY_DELAY); 
    }

    writeMulticharToAddress(hmac, HMAC_TEXT_BASE, pString, HMAC_TEXT_BYTES); 

    //strobeInit();
    if (use_key_hash) {
        writeToAddress(hmac, HMAC_NEXT_INIT, 0x5); 
        writeToAddress(hmac, HMAC_NEXT_INIT, 0x4); 
    } else {
        writeToAddress(hmac, HMAC_NEXT_INIT, 0x1); 
        writeToAddress(hmac, HMAC_NEXT_INIT, 0x0); 
    }

    // wait for HMAC to start
    do_delay(20); 

    // wait for valid output
    while (readFromAddress(hmac, HMAC_VALID) == 0) {
        do_delay(HMAC_VALID_DELAY); 
    }

    // Read the Hash
    readMultiFromAddress(hmac, HMAC_HASH_BASE, hash, HMAC_HASH_WORDS); 

    return 0; 

}


int check_hmac()
{
    //// Give a test input and verify AES enryption
    printm("    Verifying HMAC crypto engine ...\n") ;
   
    // Input for HMAC encyption
    char inputText[65] = "----> this is the message to test hmac mod for hackadac'20 <----";
    //char inputText[500] = "abc";
    uint32_t hash[HMAC_HASH_WORDS];
    uint32_t expectedHash[HMAC_HASH_WORDS] = {0xe2fcbb9f,0xe426e269,0xc1a1ade9,0xc9d53cb7,0xa086fbf3,0x75836f93,0xd5761d02,0x0ecd9fe8};
    uint32_t key[8] = {0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c, 0x2b7e1516, 0x28aed2a6, 0x2b7e1516, 0x28aed2a6};
    
    int hmac_working; 
    int use_key_hash = 0; 

    writeMultiToAddress(hmac, HMAC_KEY_BASE, key, HMAC_KEY_WORDS); 

    // call the hmac hashing function
    hmac_hashString(inputText, hash, use_key_hash);

    // Verify the Hash 
    hmac_working = verifyMulti(expectedHash, hash, HMAC_HASH_WORDS); 
    
    if (hmac_working)
        printm("    HMAC engine hashing successfully verified\n"); 
    else
        printm("    HMAC engine failed, disabling the crypto engine !\n");

    return hmac_working ;  
}


static void hmac_open(const struct fdt_scan_node *node, void *extra)
{
  struct hmac_scan *scan = (struct hmac_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void hmac_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct hmac_scan *scan = (struct hmac_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,hmac")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void hmac_done(const struct fdt_scan_node *node, void *extra)
{
  struct hmac_scan *scan = (struct hmac_scan *)extra;
  if (!scan->compat || !scan->reg || hmac) return;

  // Enable Rx/Tx channels
  hmac = (void*)(uintptr_t)scan->reg;


}

void query_hmac(uintptr_t fdt)
{
  //fdt_scan(fdt, &cb);
  struct hmac_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5203000; 
  hmac_done(NULL, &scan); 
}
