// See LICENSE for license details.

#include <string.h>
#include "sha256.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "common_driver_fn.h"

volatile uint64_t* sha256;

struct sha256_scan
{
  int compat;
  uint64_t reg;
};

int sha256_hashString(char *pString, uint32_t *hash)
{
  char *ptr = pString;

    int done = 0;
    int firstTime = 1;
    int totalBytes = 0;
    
    while(!done) {
        char message[2 * SHA256_TEXT_BITS];
        for (int i=0; i<2*SHA256_TEXT_BYTES; i++)
            message[i] = 0; 
        
        // Copy next portion of string to message buffer
        char *msg_ptr = message;
        int length = 0;
        while(length < SHA256_TEXT_BYTES) {
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
            addedBytes = sha256_addPadding(totalBytes * BITS_PER_BYTE, message);
        }
        
        // Send the message
        while (readFromAddress(sha256, SHA256_READY) == 0) {
            do_delay(SHA256_READY_DELAY); 
        }

        writeMulticharToAddress(sha256, SHA256_TEXT_BASE, message, SHA256_TEXT_BYTES); 

        // start the hashing
        if(firstTime) {
            //strobeInit();
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x1); 
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x0); 
            firstTime = 0;
        } else {
            //strobeNext();
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x2); 
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x0); 
        }

        // wait for SHA256 to start
        do_delay(20); 

        // wait for valid output
        while (readFromAddress(sha256, SHA256_VALID) == 0) {
            do_delay(SHA256_VALID_DELAY); 
        }

        //waitForReady ?

        // if data to send > 512 bits send again
        if (addedBytes > SHA256_TEXT_BYTES) {
            while (readFromAddress(sha256, SHA256_READY) == 0) {
                do_delay(SHA256_READY_DELAY); 
            }

            writeMultiToAddress(sha256, SHA256_TEXT_BASE, (uint32_t *)(message + SHA256_TEXT_BYTES), SHA256_TEXT_WORDS); 

            // start the hashing
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x2); 
            writeToAddress(sha256, SHA256_NEXT_INIT, 0x0); 

            // wait for SHA256 to start
            do_delay(20); 

            // wait for valid output
            while (readFromAddress(sha256, SHA256_VALID) == 0) {
                do_delay(SHA256_VALID_DELAY); 
            }
        }
    }

    // Read the Hash
    readMultiFromAddress(sha256, SHA256_HASH_BASE, hash, SHA256_HASH_WORDS); 

    return 0; 

}


int sha256_addPadding(uint64_t pMessageBits64Bit, char* buffer) {
    int extraBits = pMessageBits64Bit % SHA256_TEXT_BITS;
    int paddingBits = extraBits > 448 ? (2 * SHA256_TEXT_BITS) - extraBits : SHA256_TEXT_BITS - extraBits;
    
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


int check_sha256()
{
    //// Give a test input and verify AES enryption
    printm("    Verifying SHA256 crypto engine ...\n") ;
   
    // Input for SHA256 encyption
    char inputText[500] = "Lincoln LaboratoLincoln LaboratoLincoln LaboratoLincoln Laborato";
    uint32_t hash[SHA256_HASH_WORDS];
    uint32_t expectedHash[SHA256_HASH_WORDS] = {0xf88c49e2, 0xb696d45a, 0x699eb10e, 0xffafb3c9, 0x522df6f7, 0xfa68c250, 0x9d105e84, 0x9be605ba};

    int sha256_working; 

    // call the sha256 hashing function
    sha256_hashString(inputText, hash);

    // Verify the Hash 
    sha256_working = verifyMulti(expectedHash, hash, SHA256_HASH_WORDS); 
    
    if (sha256_working)
        printm("    SHA256 engine hashing successfully verified\n"); 
    else
        printm("    SHA256 engine failed, disabling the crypto engine !\n");

    return sha256_working ;  
}


static void sha256_open(const struct fdt_scan_node *node, void *extra)
{
  struct sha256_scan *scan = (struct sha256_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void sha256_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct sha256_scan *scan = (struct sha256_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,sha2560")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void sha256_done(const struct fdt_scan_node *node, void *extra)
{
  struct sha256_scan *scan = (struct sha256_scan *)extra;
  if (!scan->compat || !scan->reg || sha256) return;

  // Enable Rx/Tx channels
  sha256 = (void*)(uintptr_t)scan->reg;

  //printm("got sha256 %x\n", sha256); 

}

void query_sha256(uintptr_t fdt)
{
  //fdt_scan(fdt, &cb);
  struct sha256_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5202000; 
  sha256_done(NULL, &scan); 
}
