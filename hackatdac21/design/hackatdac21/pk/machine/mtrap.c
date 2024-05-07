// See LICENSE for license details.

#include "mtrap.h"
#include "mcall.h"
#include "htif.h"
#include "atomic.h"
#include "bits.h"
#include "vm.h"
#include "uart.h"
#include "uart16550.h"
#include "aes0.h"
#include "aes1.h"
#include "aes2.h"
#include "sha256.h"
#include "dma.h"
#include "hmac.h"
#include "finisher.h"
#include "fdt.h"
#include "unprivileged_memory.h"
#include "disabled_hart_mask.h"
#include "rng.h"
#include "rst.h"
#include "rsa.h"
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>

void __attribute__((noreturn)) bad_trap(uintptr_t* regs, uintptr_t dummy, uintptr_t mepc)
{
  die("machine mode: unhandlable trap %d @ %p", read_csr(mcause), mepc);
}

static uintptr_t mcall_console_putchar(uint8_t ch)
{
  if (uart) {
    uart_putchar(ch);
  } else if (uart16550) {
    uart16550_putchar(ch);
  } else if (htif) {
    htif_console_putchar(ch);
  }
  return 0;
}

void putstring(const char* s)
{
  while (*s)
    mcall_console_putchar(*s++);
}

void vprintm(const char* s, va_list vl)
{
  char buf[256];
  vsnprintf(buf, sizeof buf, s, vl);
  putstring(buf);
}

void printm(const char* s, ...)
{
  va_list vl;

  va_start(vl, s);
  vprintm(s, vl);
  va_end(vl);
}

static void send_ipi(uintptr_t recipient, int event)
{
  if (((disabled_hart_mask >> recipient) & 1)) return;
  atomic_or(&OTHER_HLS(recipient)->mipi_pending, event);
  mb();
  *OTHER_HLS(recipient)->ipi = 1;
}

static uintptr_t mcall_console_getchar()
{
  if (uart) {
    return uart_getchar();
  } else if (uart16550) {
    return uart16550_getchar();
  } else if (htif) {
    return htif_console_getchar();
  } else {
    return '\0';
  }
}

static uintptr_t mcall_clear_ipi()
{
  return clear_csr(mip, MIP_SSIP) & MIP_SSIP;
}

static uintptr_t mcall_shutdown()
{
  poweroff(0);
}

static uintptr_t mcall_set_timer(uint64_t when)
{
  *HLS()->timecmp = when;
  clear_csr(mip, MIP_STIP);
  set_csr(mie, MIP_MTIP);
  return 0;
}

static uintptr_t mcall_rsa_wait()
{
  rsa_wait();

  return 0;
}

static uintptr_t mcall_rsa_write_prime_num(uintptr_t arg0)
{

  uint32_t *p_num = (uint32_t *)arg0;

  rsa_write_prime_num(p_num);

  return 0;
}

static uintptr_t mcall_rsa_write_msg_in(uintptr_t arg0, uintptr_t arg1)
{

  uint32_t *msg_in = (uint32_t *)arg0;
  uint32_t encry_decry = (uint32_t )arg1;

  rsa_write_msg_in(msg_in, encry_decry);

  return 0;
}

static uintptr_t mcall_rsa_read_msg_out(uintptr_t arg0)
{
  uint32_t *msg_out = (uint32_t *)arg0;

  rsa_read_msg_out(msg_out);

  return 0;
}

static uintptr_t mcall_rng_wait()
{

  rng_wait();

  return 0;
}

static uintptr_t mcall_rng_read_data(uintptr_t arg0)
{
  
  uint32_t *randnum = (uint32_t *)arg0;

  rng_read_data(randnum);

  return 0; 
}

static uintptr_t mcall_rng_read_poly(uintptr_t arg0, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3)
{
  uint32_t *poly128 = (uint32_t *) arg0;
  uint32_t *poly64 = (uint32_t *) arg1;
  uint32_t *poly32 = (uint32_t *) arg2;
  uint32_t *poly16 = (uint32_t *) arg3;

  rng_read_poly(poly128, poly64, poly32, poly16);

  return 0;
}
static uintptr_t mcall_rng_write_poly(uintptr_t arg0, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3)
{
  uint32_t *poly128 = (uint32_t *) arg0;
  uint32_t *poly64 = (uint32_t *) arg1;
  uint32_t *poly32 = (uint32_t *) arg2;
  uint32_t *poly16 = (uint32_t *) arg3;

  rng_write_poly(poly128, poly64, poly32, poly16);
  
  return 0;
}

static uintptr_t mcall_rng_read_seed(uintptr_t arg0, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3)
{
  uint32_t *seed128 = (uint32_t *) arg0;
  uint32_t *seed64 = (uint32_t *) arg1;
  uint32_t *seed32 = (uint32_t *) arg2;
  uint32_t *seed16 = (uint32_t *) arg3;

  rng_read_seed(seed128, seed64, seed32, seed16);

  return 0;
}

static uintptr_t mcall_rng_write_seed(uintptr_t arg0)
{
  uint32_t *seed128 = (uint32_t *) arg0;

  rng_write_seed(seed128);

  return 0;
}

static uintptr_t mcall_rng_read_rand_seg(uintptr_t arg0)
{
  uint32_t *rand_seg = (uint32_t *) arg0;

  rng_read_rand_seg(rand_seg);

  return 0;
}

static uintptr_t mcall_rng_read_state_counter(uintptr_t arg0)
{
  uint32_t *st_cnt = (uint32_t *) arg0;

  rng_read_state_counter(st_cnt);
  
  return 0;
}

static uintptr_t mcall_aes0_start_encrypt(uintptr_t arg0, uintptr_t arg1, uintptr_t arg2)
{
  uint32_t *pt = (uint32_t *)arg0;
  uint32_t *st = (uint32_t *)arg1;
  uint32_t key_sel = (uint32_t )arg2;

  aes0_start_encrypt(pt, st, key_sel); 


  return 0;
}

static uintptr_t mcall_rst(uintptr_t arg0)
{
  uint32_t id = (uint32_t )arg0;

  rst_id(id);

  return 0;
}

static uintptr_t mcall_aes2_start_encrypt(uintptr_t arg0, uintptr_t arg1, uintptr_t arg2)
{
  
  uint32_t *pt = (uint32_t *)arg0;
  uint32_t *st = (uint32_t *)arg1;
  uint32_t key_sel = (uint32_t )arg2;

  aes2_start_encrypt(pt, st, key_sel); 


  return 0;
}


static uintptr_t mcall_aes0_wait()
{
 
  aes0_wait(); 

  return 0;
}


static uintptr_t mcall_aes0_data_out(uintptr_t arg0)
{
  uint32_t *ct = (uint32_t *)arg0;

  aes0_data_out(ct); 

  return 0;
}



static uintptr_t mcall_aes2_wait()
{
 
  aes2_wait(); 

  return 0;
}


static uintptr_t mcall_aes2_data_out(uintptr_t arg0)
{
  uint32_t *ct = (uint32_t *)arg0;

  aes2_data_out(ct); 

  return 0;
}

static uintptr_t mcall_aes1_read_data(uintptr_t arg0)
{
  uint32_t *res = (uint32_t *)arg0;

  aes1_read_data(res); 

  return 0;
}

static uintptr_t mcall_aes1_read_config(uintptr_t arg0)
{
  uint32_t *conf = (uint32_t *)arg0;

  aes1_read_config(conf); 

  return 0;
}

static uintptr_t mcall_aes1_write_data(uintptr_t arg0, uintptr_t arg1)
{
  uint32_t *bk = (uint32_t *)arg0;
  uint32_t key_sel = (uint32_t )arg1;

  aes1_write_data(bk, key_sel); 

  return 0;
}

static uintptr_t mcall_aes1_write_config(uintptr_t arg0)
{
  uint32_t conf = (uint32_t )arg0;

  aes1_write_config(conf); 

  return 0;
}

static uintptr_t mcall_dma_copy(uintptr_t arg0, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3)
{
  uint64_t sAddr  = (uint64_t )arg0;
  uint64_t dAddr  = (uint64_t )arg1;
  uint32_t length = (uint32_t )arg2;
  uint32_t wait   = (uint32_t )arg3;

  dma_transfer(sAddr, dAddr, length, wait); 

  return 0;
}

static uintptr_t mcall_sha256_hash(uintptr_t arg0, uintptr_t arg1)
{
  char *pString = (char *)arg0;
  uint32_t *hash = (uint32_t *)arg1;
  char *ptr = pString;


  sha256_hashString(pString, hash); 

  return 0;
}

static uintptr_t mcall_hmac_hash(uintptr_t arg0, uintptr_t arg1, uintptr_t arg2)
{
  char *pString = (char *)arg0;
  uint32_t *hash = (uint32_t *)arg1;
  uint32_t use_key_hash = (uint32_t )arg2;
  char *ptr = pString;

  hmac_hashString(pString, hash, use_key_hash); 

  return 0;
}

static uintptr_t mcall_cmp(uintptr_t arg0, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t arg4)
{
  uint32_t *t1 = (uint32_t *)arg0;
  uint32_t *t2 = (uint32_t *)arg1;
  uint32_t length = (uint32_t )arg3;
  uint32_t *equality = (uint32_t *)arg4;

  *equality = verifyMulti(t1, t2, length); 


  return 0;
}

static uintptr_t mcall_puts(uintptr_t arg0, uintptr_t arg1)
{
  char *buf = (char *)arg0;
  uint32_t buf_len = (uint32_t )arg1;
  
  //printm("entered puts m_sys_call \n %d: %s\n", buf_len, buf); 
  
  int i; 
  for (i=0; i<buf_len; i++)
   {
     mcall_console_putchar(buf[i]); 
   }

    return 0;
}

static uintptr_t mcall_dma_end()
{
    dma_end(); 

    return 0;
}




static void send_ipi_many(uintptr_t* pmask, int event)
{
  _Static_assert(MAX_HARTS <= 8 * sizeof(*pmask), "# harts > uintptr_t bits");
  uintptr_t mask = hart_mask;
  if (pmask)
    mask &= load_uintptr_t(pmask, read_csr(mepc));

  // send IPIs to everyone
  for (uintptr_t i = 0, m = mask; m; i++, m >>= 1)
    if (m & 1)
      send_ipi(i, event);

  if (event == IPI_SOFT)
    return;

  // wait until all events have been handled.
  // prevent deadlock by consuming incoming IPIs.
  uint32_t incoming_ipi = 0;
  for (uintptr_t i = 0, m = mask; m; i++, m >>= 1)
    if (m & 1)
      while (*OTHER_HLS(i)->ipi)
        incoming_ipi |= atomic_swap(HLS()->ipi, 0);

  // if we got an IPI, restore it; it will be taken after returning
  if (incoming_ipi) {
    *HLS()->ipi = incoming_ipi;
    mb();
  }
}

void mcall_trap(uintptr_t* regs, uintptr_t mcause, uintptr_t mepc)
{
  write_csr(mepc, mepc + 4);

  uintptr_t n = regs[17], arg0 = regs[10], arg1 = regs[11], retval, ipi_type;
  uintptr_t arg2 = regs[12], arg3 = regs[13], arg4 = regs[14], arg5 = regs[15];

  switch (n)
  {
    case SBI_CONSOLE_PUTCHAR:
      retval = mcall_console_putchar(arg0);
      break;
    case SBI_CONSOLE_GETCHAR:
      retval = mcall_console_getchar();
      break;
    case SBI_SEND_IPI:
      ipi_type = IPI_SOFT;
      goto send_ipi;
    case SBI_REMOTE_SFENCE_VMA:
    case SBI_REMOTE_SFENCE_VMA_ASID:
      ipi_type = IPI_SFENCE_VMA;
      goto send_ipi;
    case SBI_REMOTE_FENCE_I:
      ipi_type = IPI_FENCE_I;
send_ipi:
      send_ipi_many((uintptr_t*)arg0, ipi_type);
      retval = 0;
      break;
    case SBI_CLEAR_IPI:
      retval = mcall_clear_ipi();
      break;
    case SBI_SHUTDOWN:
      retval = mcall_shutdown();
      break;
    case SBI_SET_TIMER:
#if __riscv_xlen == 32
      retval = mcall_set_timer(arg0 + ((uint64_t)arg1 << 32));
#else
      retval = mcall_set_timer(arg0);
#endif
      break;
    case SBI_RSA_WAIT:
      retval = mcall_rsa_wait();
      break;
    case SBI_RSA_WRITE_PNUM:
      retval = mcall_rsa_write_prime_num(arg0);
      break;
    case SBI_RSA_WRITE_MSG_IN:
      retval = mcall_rsa_write_msg_in(arg0, arg1);
      break;
    case SBI_RSA_READ_MSG_OUT:
      retval = mcall_rsa_read_msg_out(arg0);
      break;      
    case SBI_RNG_WAIT:
      retval = mcall_rng_wait();
      break;
    case SBI_RNG_READ_DATA:
      retval = mcall_rng_read_data(arg0);
      break;
    case SBI_RNG_READ_POLY:
      retval = mcall_rng_read_poly(arg0, arg1, arg2, arg3);
      break;
    case SBI_RNG_WRITE_POLY:
      retval = mcall_rng_write_poly(arg0, arg1, arg2, arg3);
      break;
    case SBI_RNG_READ_SEED:
      retval = mcall_rng_read_seed(arg0, arg1, arg2, arg3);
      break;
    case SBI_RNG_WRITE_SEED:
      retval = mcall_rng_write_seed(arg0);
      break;
    case SBI_RNG_READ_RAND_SEG:
      retval = mcall_rng_read_rand_seg(arg0);
      break;
    case SBI_RNG_READ_STATE_COUNTER:
      retval = mcall_rng_read_state_counter(arg0);
      break;
    case SBI_AES0_START_ENCRYPT:
      retval = mcall_aes0_start_encrypt(arg0, arg1, arg2);
      break; 
    case SBI_AES0_WAIT:
      retval = mcall_aes0_wait();
      break; 
    case SBI_AES0_DATA_OUT:
      retval = mcall_aes0_data_out(arg0);
      break; 
    case SBI_AES2_START_ENCRYPT:
      retval = mcall_aes2_start_encrypt(arg0, arg1, arg2);
      break; 
    case SBI_AES2_WAIT:
      retval = mcall_aes2_wait();
      break; 
    case SBI_AES2_DATA_OUT:
      retval = mcall_aes2_data_out(arg0);
      break; 
    case SBI_AES1_READ_DATA:
      retval = mcall_aes1_read_data(arg0);
      break; 
    case SBI_AES1_WRITE_DATA:
      retval = mcall_aes1_write_data(arg0, arg1);
      break; 
    case SBI_AES1_READ_CONFIG:
      retval = mcall_aes1_read_config(arg0);
      break; 
    case SBI_AES1_WRITE_CONFIG:
      retval = mcall_aes1_write_config(arg0);
      break; 
    case SBI_SHA256_HASH:
      retval = mcall_sha256_hash(arg0, arg1);
      break;
    case SBI_RST:
      retval = mcall_rst(arg0);
      break;
    case SBI_DMA_COPY:
      retval = mcall_dma_copy(arg0, arg1, arg2, arg3);
      break;  
    case SBI_HMAC_HASH:
      retval = mcall_hmac_hash(arg0, arg1, arg2);
      break; 
    case SBI_CMP:
      retval = mcall_cmp(arg0, arg1, arg2, arg3, arg4);
      break; 
    case SBI_PUTS:
      retval = mcall_puts(arg0, arg1);
      break; 
    case SBI_DMA_END:
      retval = mcall_dma_end(arg0, arg1);
      break;      
    default:
      retval = -ENOSYS;
      break;
  }
  regs[10] = retval;
}

void redirect_trap(uintptr_t epc, uintptr_t mstatus, uintptr_t badaddr)
{
  write_csr(sbadaddr, badaddr);
  write_csr(sepc, epc);
  write_csr(scause, read_csr(mcause));
  write_csr(mepc, read_csr(stvec));

  uintptr_t new_mstatus = mstatus & ~(MSTATUS_SPP | MSTATUS_SPIE | MSTATUS_SIE);
  uintptr_t mpp_s = MSTATUS_MPP & (MSTATUS_MPP >> 1);
  new_mstatus |= (mstatus * (MSTATUS_SPIE / MSTATUS_SIE)) & MSTATUS_SPIE;
  new_mstatus |= (mstatus / (mpp_s / MSTATUS_SPP)) & MSTATUS_SPP;
  new_mstatus |= mpp_s;
  write_csr(mstatus, new_mstatus);

  extern void __redirect_trap();
  return __redirect_trap();
}

void pmp_trap(uintptr_t* regs, uintptr_t mcause, uintptr_t mepc)
{
  redirect_trap(mepc, read_csr(mstatus), read_csr(mbadaddr));
}

static void machine_page_fault(uintptr_t* regs, uintptr_t mcause, uintptr_t mepc)
{
  // MPRV=1 iff this trap occurred while emulating an instruction on behalf
  // of a lower privilege level. In that case, a2=epc and a3=mstatus.
  // a1 holds MPRV if emulating a load or store, or MPRV | MXR if loading
  // an instruction from memory.  In the latter case, we should report an
  // instruction fault instead of a load fault.
  if (read_csr(mstatus) & MSTATUS_MPRV) {
    if (regs[11] == (MSTATUS_MPRV | MSTATUS_MXR)) {
      if (mcause == CAUSE_LOAD_PAGE_FAULT)
        write_csr(mcause, CAUSE_FETCH_PAGE_FAULT);
      else if (mcause == CAUSE_LOAD_ACCESS)
        write_csr(mcause, CAUSE_FETCH_ACCESS);
      else
        goto fail;
    } else if (regs[11] != MSTATUS_MPRV) {
      goto fail;
    }

    return redirect_trap(regs[12], regs[13], read_csr(mbadaddr));
  }

fail:
  bad_trap(regs, mcause, mepc);
}

void trap_from_machine_mode(uintptr_t* regs, uintptr_t dummy, uintptr_t mepc)
{
  uintptr_t mcause = read_csr(mcause);

  switch (mcause)
  {
    case CAUSE_LOAD_PAGE_FAULT:
    case CAUSE_STORE_PAGE_FAULT:
    case CAUSE_FETCH_ACCESS:
    case CAUSE_LOAD_ACCESS:
    case CAUSE_STORE_ACCESS:
      return machine_page_fault(regs, mcause, mepc);
    default:
      bad_trap(regs, dummy, mepc);
  }
}

void poweroff(uint16_t code)
{
  printm("Power off\r\n");
  finisher_exit(code);
  if (htif) {
    htif_poweroff();
  } else {
    send_ipi_many(0, IPI_HALT);
    while (1) { asm volatile ("wfi\n"); }
  }
}
