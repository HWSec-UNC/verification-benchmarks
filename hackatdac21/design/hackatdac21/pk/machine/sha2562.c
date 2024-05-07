// See LICENSE for license details.

#include <string.h>
#include "sha2562.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint32_t* sha2562;

struct sha2562_scan
{
  int compat;
  uint64_t reg;
};

int sha2562_hashString(char *pString, uint32_t *hash)
{
  char *ptr = pString;

    int done = 0;
    int firstTime = 1;
    int totalBytes = 0;
    
    while(!done) {
        char message[2 * SHA2562_TEXT_BITS];
        for (int i=0; i<2*SHA2562_TEXT_BYTES; i++)
            message[i] = 0; 
        
        // Copy next portion of string to message buffer
        char *msg_ptr = message;
        int length = 0;
        while(length < SHA2562_TEXT_BYTES) {
            // Check for end of input
            if(*pString == '\0') {
                done = 1;
                break;
            }
            *msg_ptr++ = *pString++;
            ++length;
            ++totalBytes;
        }
        
        // Need to add padding if done
        int addedBytes = 0;
        if(done) {
            addedBytes = sha2562_addPadding(totalBytes * BITS_PER_BYTE, message);
        }
        
        // Send the message
        while (readFromAddress((uint32_t *)sha2562, SHA2562_READY) == 0) {
            do_delay(SHA2562_READY_DELAY); 
        }

        writeMulticharToAddress((uint32_t *)sha2562, SHA2562_TEXT_BASE, message, SHA2562_TEXT_BYTES); 

        // start the hashing
        if(firstTime) {
            //strobeInit();
            writeToAddress((uint32_t *)sha2562, SHA2562_NEXT_INIT, 0x1); 
            writeToAddress((uint32_t *)sha2562, SHA2562_NEXT_INIT, 0x0); 
            firstTime = 0;
        } else {
            //strobeNext();
            writeToAddress((uint32_t *)sha2562, SHA2562_NEXT_INIT, 0x2); 
            writeToAddress((uint32_t *)sha2562, SHA2562_NEXT_INIT, 0x0); 
        }

        // wait for SHA2562 to start
        do_delay(20); 

        // wait for valid output
        while (readFromAddress((uint32_t *)sha2562, SHA2562_VALID) == 0) {
            do_delay(SHA2562_VALID_DELAY); 
        }

        //waitForReady ?

        // if data to send > 512 bits send again
        if (addedBytes > SHA2562_TEXT_BYTES) {
            while (readFromAddress((uint32_t *)sha2562, SHA2562_READY) == 0) {
                do_delay(SHA2562_READY_DELAY); 
            }

            writeMultiToAddress((uint32_t *)sha2562, SHA2562_TEXT_BASE, (uint32_t *)(message + SHA2562_TEXT_BYTES), SHA2562_TEXT_WORDS); 

            // start the hashing
            //strobeNext();
            writeToAddress((uint32_t *)sha2562, SHA2562_NEXT_INIT, 0x2); 
            writeToAddress((uint32_t *)sha2562, SHA2562_NEXT_INIT, 0x0); 

            // wait for SHA2562 to start
            do_delay(20); 

            // wait for valid output
            while (readFromAddress((uint32_t *)sha2562, SHA2562_VALID) == 0) {
                do_delay(SHA2562_VALID_DELAY); 
            }
        }
    }

    // Read the Hash
    readMultiFromAddress((uint32_t *)sha2562, SHA2562_HASH_BASE, hash, SHA2562_HASH_WORDS); 

    return 0; 

}


int sha2562_addPadding(uint64_t pMessageBits64Bit, char* buffer) {
    int extraBits = pMessageBits64Bit % SHA2562_TEXT_BITS;
    int paddingBits = extraBits > 448 ? (2 * SHA2562_TEXT_BITS) - extraBits : SHA2562_TEXT_BITS - extraBits;
    
    // Add size to end of string
    const int startByte = extraBits / BITS_PER_BYTE;
    const int sizeStartByte =  startByte + ((paddingBits / BITS_PER_BYTE) - 8);

    for(int i = startByte; i < (sizeStartByte + 8); ++i) {
        if(i == startByte) {
            buffer[i] = 0x80; // 1 followed by many 0's
        } else if( i >= sizeStartByte) {
            int offset = i - sizeStartByte;
            int shftAmnt = 56 - (8 * offset);
            buffer[i] = (pMessageBits64Bit >> shftAmnt) & 0xFF;
        } else {
            buffer[i] = 0x0;
        }
    }
    
    return (paddingBits / BITS_PER_BYTE);
}


static void sha2562_open(const struct fdt_scan_node *node, void *extra)
{
  struct sha2562_scan *scan = (struct sha2562_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void sha2562_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct sha2562_scan *scan = (struct sha2562_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,sha2562")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void sha2562_done(const struct fdt_scan_node *node, void *extra)
{
  struct sha2562_scan *scan = (struct sha2562_scan *)extra;
  if (!scan->compat || !scan->reg || sha2562) return;

  // Enable Rx/Tx channels
  sha2562 = (void*)(uintptr_t)scan->reg;

  //printm("got sha2562 %x\n", sha2562); 

}

void query_sha2562(uintptr_t fdt)
{
  struct fdt_cb cb;
  struct sha2562_scan scan;

  memset(&cb, 0, sizeof(cb));
  cb.open = sha2562_open;
  cb.prop = sha2562_prop;
  cb.done = sha2562_done;
  cb.extra = &scan;

  fdt_scan(fdt, &cb);
}
