// See LICENSE for license details.

#include <string.h>
#include "pkt.h"
#include "fdt.h"
#include "mtrap.h"
#include "pk.h"
#include "reglk.h"
#include "rst.h"
#include "aes1.h"
#include "common_driver_fn.h"

//volatile uint64_t* aes1;
//volatile uint64_t* reglk;
volatile uint64_t* pkt;

struct pkt_scan
{
  int compat;
  uint64_t reg;
};

int pkt_copy_fuse_data(int aes0_working, int aes1_working, int aes2_working, int sha256_working, int hmac_working, int rng_working, int rst_working)
{
    int i, j;
    volatile uint32_t rdata, wdata, data; 
    volatile uint64_t waddr; 
    char reglk_bytes[REGLK_BYTES]; 
    reglk_blk reglk_blk_data; 


    //---------------------------------------------------
    // Check if the crypto engines are working properly
    //---------------------------------------------------
      if (!aes0_working) {
          reglk_bytes[AES0_ID]  =  0xff; // lock all registers 
      }
      if (!aes1_working) 
          reglk_bytes[AES1_ID]  =  0xff; // lock all registers 

      if (!aes2_working)
          reglk_bytes[AES2_ID] = 0xff; // lock all registers

      if (!sha256_working) {
          reglk_bytes[SHA256_ID]  =  0xff; // lock all registers 
      }
      if (!hmac_working) 
          reglk_bytes[HMAC_ID]  =  0xff; // lock all registers 

      if (!rng_working){
          reglk_bytes[RNG_ID]  =  0xff; // lock all registers
      }
      if (!rst_working){
          reglk_bytes[RST_ID]  =  0xff; // lock all registers
      }

    printm("    Setting the FUSE data\r\n");  

    // Enable the fuse request
    wdata = 0x1; 
    writeToAddress(pkt, PKT_FUSE_REQ, wdata);   

    // Set the Access Control Registers
    for (int acct_word=PKT_ACCT_BASE_INDX; acct_word<(PKT_ACCT_BASE_INDX+PKT_ACCT_WORDS); acct_word++)
    {
        wdata = acct_word ; 
        writeToAddress(pkt, PKT_FUSE_RADDR, wdata);   
        asm volatile ("nop \n\t") ;  // 1 cycle gap to allow data to be loaded
        waddr = readFromAddress(pkt, PKT_WADDR_MSB);
        waddr = (waddr << 32) | readFromAddress(pkt, PKT_WADDR_LSB);
        wdata = readFromAddress(pkt, PKT_FUSE_RDATA);  
        writeToAddress((uint64_t *)waddr, 0,  wdata); 
    } 

    // Set the AES keys only if it is working
    if (aes0_working)
    {
      for (int aes0_word=PKT_AES0_BASE_INDX; aes0_word<(PKT_AES0_BASE_INDX+(AES0_NO_KEYS*PKT_AES0_WORDS)); aes0_word++)
      {
          wdata = aes0_word ; 
          writeToAddress(pkt, PKT_FUSE_RADDR, wdata);   
          asm volatile ("nop \n\t") ;  // 1 cycle gap to allow data to be loaded
          waddr = readFromAddress(pkt, PKT_WADDR_MSB);
          waddr = (waddr << 32) | readFromAddress(pkt, PKT_WADDR_LSB);
          wdata = readFromAddress(pkt, PKT_FUSE_RDATA);  
          writeToAddress((uint64_t *)waddr, 0,  wdata); 
      }
    }  
    if (aes1_working)
    {
      for (int aes1_word=PKT_AES1_BASE_INDX; aes1_word<(PKT_AES1_BASE_INDX+(AES1_NO_KEYS*PKT_AES1_WORDS)); aes1_word++)
      {
          wdata = aes1_word ; 
          writeToAddress(pkt, PKT_FUSE_RADDR, wdata);   
          asm volatile ("nop \n\t") ;  // 1 cycle gap to allow data to be loaded
          waddr = readFromAddress(pkt, PKT_WADDR_MSB);
          waddr = (waddr << 32) | readFromAddress(pkt, PKT_WADDR_LSB);
          wdata = readFromAddress(pkt, PKT_FUSE_RDATA);  
          writeToAddress((uint64_t *)waddr, 0,  wdata); 
      }
      writeToAddress(aes1, AES1_KEY0_LEN, 0);
      writeToAddress(aes1, AES1_KEY1_LEN, 1);
      writeToAddress(aes1, AES1_KEY2_LEN, 1);
    }
    if (aes2_working) {
      for (int aes2_word=PKT_AES2_BASE_INDX; aes2_word<(PKT_AES2_BASE_INDX+(AES2_NO_KEYS*PKT_AES2_WORDS)); aes2_word++)
      {
          wdata = aes2_word ; 
          writeToAddress(pkt, PKT_FUSE_RADDR, wdata);   
          asm volatile ("nop \n\t") ;  // 1 cycle gap to allow data to be loaded
          waddr = readFromAddress(pkt, PKT_WADDR_MSB);
          waddr = (waddr << 32) | readFromAddress(pkt, PKT_WADDR_LSB);
          wdata = readFromAddress(pkt, PKT_FUSE_RDATA);  
          writeToAddress((uint64_t *)waddr, 0,  wdata); 
      }
    }
    if (hmac_working)
    {
      for (int hmac_word=PKT_HMAC_KEY_BASE_INDX; hmac_word<(PKT_HMAC_KEY_BASE_INDX+PKT_HMAC_KEY_WORDS); hmac_word++)
      {
          wdata = hmac_word ; 
          writeToAddress(pkt, PKT_FUSE_RADDR, wdata);   
          asm volatile ("nop \n\t") ;  // 1 cycle gap to allow data to be loaded
          waddr = readFromAddress(pkt, PKT_WADDR_MSB);
          waddr = (waddr << 32) | readFromAddress(pkt, PKT_WADDR_LSB);
          wdata = readFromAddress(pkt, PKT_FUSE_RDATA);  
          writeToAddress((uint64_t *)waddr, 0,  wdata); 
      }
      for (int hmac_word=PKT_HMAC_iKEY_BASE_INDX; hmac_word<(PKT_HMAC_iKEY_BASE_INDX+PKT_HMAC_KEY_WORDS); hmac_word++)
      {
          wdata = hmac_word ; 
          writeToAddress(pkt, PKT_FUSE_RADDR, wdata);   
          asm volatile ("nop \n\t") ;  // 1 cycle gap to allow data to be loaded
          waddr = readFromAddress(pkt, PKT_WADDR_MSB);
          waddr = (waddr << 32) | readFromAddress(pkt, PKT_WADDR_LSB);
          wdata = readFromAddress(pkt, PKT_FUSE_RDATA);  
          writeToAddress((uint64_t *)waddr, 0,  wdata); 
      }
      for (int hmac_word=PKT_HMAC_oKEY_BASE_INDX; hmac_word<(PKT_HMAC_oKEY_BASE_INDX+PKT_HMAC_KEY_WORDS); hmac_word++)
      {
          wdata = hmac_word ; 
          writeToAddress(pkt, PKT_FUSE_RADDR, wdata);   
          asm volatile ("nop \n\t") ;  // 1 cycle gap to allow data to be loaded
          waddr = readFromAddress(pkt, PKT_WADDR_MSB);
          waddr = (waddr << 32) | readFromAddress(pkt, PKT_WADDR_LSB);
          wdata = readFromAddress(pkt, PKT_FUSE_RDATA);  
          writeToAddress((uint64_t *)waddr, 0,  wdata); 
      }
    }  
    if (rng_working)
    {
      for (int rng_word=PKT_RNG_BASE_INDX; rng_word<(PKT_RNG_BASE_INDX+PKT_RNG_WORDS); rng_word++)
      {
          wdata = rng_word ; 
          writeToAddress(pkt, PKT_FUSE_RADDR, wdata);   
          asm volatile ("nop \n\t") ;  // 1 cycle gap to allow data to be loaded
          waddr = readFromAddress(pkt, PKT_WADDR_MSB);
          waddr = (waddr << 32) | readFromAddress(pkt, PKT_WADDR_LSB);
          wdata = readFromAddress(pkt, PKT_FUSE_RDATA);  
          writeToAddress((uint64_t *)waddr, 0,  wdata); 
      }
    }
    // Disable the fuse request
    wdata = 0x0; 
    writeToAddress(pkt, PKT_FUSE_REQ, wdata);   


  //---------------------------------------------------
  // Set the Register locks
  //---------------------------------------------------
    printm("    Setting the register locks\r\n");

    for (int reglk_word=0; reglk_word<REGLK_BYTES; reglk_word++)
    {
        reglk_bytes[reglk_word] = 0; // by default no locks are set
    }
    reglk_bytes[RNG_ID] = rng_working ? REGLK_RNG : 0xff;
    reglk_bytes[HMAC_ID]  =  hmac_working ? REGLK_HMAC : 0xff; 
    reglk_bytes[REGLK_ID] =  REGLK_REGLK; 
    reglk_bytes[ACCT_ID] =  REGLK_ACCT; 
    reglk_bytes[PKT_ID] =  REGLK_PKT; 
    reglk_bytes[SHA256_ID]  =  sha256_working ? REGLK_SHA256 : 0xff; 
    reglk_bytes[AES1_ID]  =  aes1_working ? REGLK_AES1 : 0xff; 
    reglk_bytes[AES0_ID]  =  aes0_working ? REGLK_AES0 : 0xff; 
    reglk_bytes[AES2_ID] = aes2_working ? REGLK_AES2 : 0xff;
    reglk_bytes[DMA_ID] =  REGLK_DMA; 
    reglk_bytes[RST_ID] = rst_working ? REGLK_RST : 0xff;
    
    for (int reglk_word=0; reglk_word<REGLK_WORDS; reglk_word++)
    {
        reglk_blk_data.slave_byte.s0 = reglk_bytes[reglk_word*4+0]; 
        reglk_blk_data.slave_byte.s1 = reglk_bytes[reglk_word*4+1]; 
        reglk_blk_data.slave_byte.s2 = reglk_bytes[reglk_word*4+2]; 
        reglk_blk_data.slave_byte.s3 = reglk_bytes[reglk_word*4+3]; 
        writeToAddress(reglk,  reglk_word, reglk_blk_data.word);   
    } 
   
    return 0; 
}
 
static void pkt_open(const struct fdt_scan_node *node, void *extra)
{
  struct pkt_scan *scan = (struct pkt_scan *)extra;
  memset(scan, 0, sizeof(*scan));
}

static void pkt_prop(const struct fdt_scan_prop *prop, void *extra)
{
  struct pkt_scan *scan = (struct pkt_scan *)extra;
  if (!strcmp(prop->name, "compatible")) {
          if( !strcmp((const char*)prop->value, "hd20,pkt")) {
    scan->compat = 1;
  }
  } else if (!strcmp(prop->name, "reg")) {
    fdt_get_address(prop->node->parent, prop->value, &scan->reg);
  }
}

static void pkt_done(const struct fdt_scan_node *node, void *extra)
{
  struct pkt_scan *scan = (struct pkt_scan *)extra;
  if (!scan->compat || !scan->reg || pkt) return;

  // Enable Rx/Tx channels
  pkt = (void*)(uintptr_t)scan->reg;
}

void query_pkt(uintptr_t fdt)
{
  //fdt_scan(fdt, &cb);
  struct pkt_scan scan;

  scan.compat = 1; 
  scan.reg = 0xfff5204000; 
  pkt_done(NULL, &scan); 
}
