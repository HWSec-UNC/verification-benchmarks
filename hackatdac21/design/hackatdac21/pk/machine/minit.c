// See LICENSE for license details.

#include "mtrap.h"
#include "atomic.h"
#include "vm.h"
#include "fp_emulation.h"
#include "fdt.h"
#include "uart.h"
#include "uart16550.h"
#include "aes0.h"
#include "aes1.h"
#include "aes2.h"
#include "sha256.h"
#include "pkt.h"
#include "dma.h"
#include "reglk.h"
#include "hmac.h"
#include "finisher.h"
#include "disabled_hart_mask.h"
#include "htif.h"
#include "rng.h"
#include "rst.h"
#include "rsa.h"
#include <string.h>
#include <limits.h>

pte_t* root_page_table;
uintptr_t mem_size;
volatile uint64_t* mtime;
volatile uint32_t* plic_priorities;
size_t plic_ndevs;
void* kernel_start;
void* kernel_end;

static void mstatus_init()
{
  uintptr_t mstatus = 0;

  // Enable FPU
  if (supports_extension('F'))
    mstatus |= MSTATUS_FS;

  // Enable vector extension
  if (supports_extension('V'))
    mstatus |= MSTATUS_VS;

  write_csr(mstatus, mstatus);

  // Enable user/supervisor use of perf counters
  if (supports_extension('S'))
    write_csr(scounteren, -1);
  if (supports_extension('U'))
    write_csr(mcounteren, -1);

  // Enable software interrupts
  write_csr(mie, MIP_MSIP);

  // Disable paging
  if (supports_extension('S'))
    write_csr(sptbr, 0);
}

// send S-mode interrupts and most exceptions straight to S-mode
static void delegate_traps()
{
  if (!supports_extension('S'))
    return;

  uintptr_t interrupts = MIP_SSIP | MIP_STIP | MIP_SEIP;
  uintptr_t exceptions =
    (1U << CAUSE_MISALIGNED_FETCH) |
    (1U << CAUSE_FETCH_PAGE_FAULT) |
    (1U << CAUSE_BREAKPOINT) |
    (1U << CAUSE_LOAD_PAGE_FAULT) |
    (1U << CAUSE_STORE_PAGE_FAULT) |
    (1U << CAUSE_USER_ECALL);

  write_csr(mideleg, interrupts);
  write_csr(medeleg, exceptions);
  assert(read_csr(mideleg) == interrupts);
  assert(read_csr(medeleg) == exceptions);
}

static void fp_init()
{
  if (!supports_extension('F'))
    return;

  assert(read_csr(mstatus) & MSTATUS_FS);

#ifdef __riscv_flen
  for (int i = 0; i < 32; i++)
    init_fp_reg(i);
  write_csr(fcsr, 0);

# if __riscv_flen == 32
  uintptr_t d_mask = 1 << ('D' - 'A');
  clear_csr(misa, d_mask);
  assert(!(read_csr(misa) & d_mask));
# endif

#else
  uintptr_t fd_mask = (1 << ('F' - 'A')) | (1 << ('D' - 'A'));
  clear_csr(misa, fd_mask);
  assert(!(read_csr(misa) & fd_mask));
#endif
}

hls_t* hls_init(uintptr_t id)
{
  hls_t* hls = OTHER_HLS(id);
  memset(hls, 0, sizeof(*hls));
  return hls;
}

static void memory_init()
{
  mem_size = mem_size / MEGAPAGE_SIZE * MEGAPAGE_SIZE;
}

static void hart_init()
{
  mstatus_init();
  fp_init();
#ifndef BBL_BOOT_MACHINE
  delegate_traps();
#endif /* BBL_BOOT_MACHINE */
  //setup_pmp();
  setup_pk_pmp();
}

static void plic_init()
{
  for (size_t i = 1; i <= plic_ndevs; i++)
    plic_priorities[i] = 1;
}

static void prci_test()
{
  assert(!(read_csr(mip) & MIP_MSIP));
  *HLS()->ipi = 1;
  assert(read_csr(mip) & MIP_MSIP);
  *HLS()->ipi = 0;

  assert(!(read_csr(mip) & MIP_MTIP));
  *HLS()->timecmp = 0;
  assert(read_csr(mip) & MIP_MTIP);
  *HLS()->timecmp = -1ULL;
}

static void hart_plic_init()
{
  // clear pending interrupts
  *HLS()->ipi = 0;
  *HLS()->timecmp = -1ULL;
  write_csr(mip, 0);

  if (!plic_ndevs)
    return;

  size_t ie_words = (plic_ndevs + 8 * sizeof(uintptr_t) - 1) /
		(8 * sizeof(uintptr_t));
  for (size_t i = 0; i < ie_words; i++) {
     if (HLS()->plic_s_ie) {
        // Supervisor not always present
        HLS()->plic_s_ie[i] = ULONG_MAX;
     }
  }
  *HLS()->plic_m_thresh = 1;
  if (HLS()->plic_s_thresh) {
      // Supervisor not always present
      *HLS()->plic_s_thresh = 0;
  }
}

static void wake_harts()
{
  for (int hart = 0; hart < MAX_HARTS; ++hart)
    if ((((~disabled_hart_mask & hart_mask) >> hart) & 1))
      *OTHER_HLS(hart)->ipi = 1; // wakeup the hart
}

void init_first_hart(uintptr_t hartid, uintptr_t dtb)
{
  // Confirm console as early as possible
  query_uart16550(dtb);

  hart_init();
  hls_init(0); // this might get called again from parse_config_string

  query_mem(dtb);
  printm("reading dtb for hart\r\n");
  query_harts(dtb);
  query_clint(dtb);
  query_plic(dtb);
  //query_chosen(dtb);

  query_aes0(dtb);
  query_aes1(dtb);
  query_aes2(dtb);
  query_sha256(dtb);
  query_pkt(dtb);
  query_dma(dtb);
  query_reglk(dtb);
  query_hmac(dtb);
  query_rng(dtb);
  query_rst(dtb);
  query_rsa(dtb);
  wake_harts();

  plic_init();
  hart_plic_init();
  //prci_test();
  memory_init();

  pkt_copy_fuse_data(1,1,1,1,1,1,1); 

  boot_loader(dtb);
}

void init_other_hart(uintptr_t hartid, uintptr_t dtb)
{
  hart_init();
  hart_plic_init();
  boot_other_hart(dtb);
}

static uintptr_t pmp_make_napot(uintptr_t base, size_t len)
{
      size_t napot_len = ((len >> 1) - 1);
        return (base + napot_len) >> PMP_SHIFT;
}


void setup_pmp(void)
{
  // Set up a PMP to permit access to all of memory.
  // Ignore the illegal-instruction trap if PMPs aren't supported.
  uintptr_t pmpc0 = PMP_NAPOT | PMP_R | PMP_W | PMP_X;
  uintptr_t pmpc1 = PMP_NAPOT | PMP_W | PMP_X;
  asm volatile ("la t0, 1f\n\t"
                "csrrw t0, mtvec, t0\n\t"
                "csrw pmpaddr1, %2\n\t"
                "csrw pmpaddr0, %2\n\t"
                "csrw pmpcfg0, %0\n\t"
                "csrw pmpcfg2, %1\n\t"
                ".align 2\n\t"
                "1: csrw mtvec, t0"
                : : "r" (pmpc0), "r" (pmpc1), "r" (-1UL) : "t0");
}

void setup_pk_pmp(void)
{
  extern char _ftext, _fdata, _end;

  //printm("_ftext %x end %x\n", &_ftext, &_fdata);

  write_csr(pmpaddr0, pmp_make_napot((uintptr_t)&_ftext, (uintptr_t)&_fdata - (uintptr_t)&_ftext));
  write_csr(pmpaddr1, pmp_make_napot((uintptr_t)&_fdata, (uintptr_t)&_end - (uintptr_t)&_fdata));
  write_csr(pmpaddr2, -1);
  uintptr_t cfg0 = PMP_NAPOT | PMP_R | PMP_X | PMP_L; // text + rodata
  uintptr_t cfg1 = PMP_NAPOT | PMP_R | PMP_W | PMP_L; // data
  uintptr_t cfg2 = PMP_NAPOT | PMP_R | PMP_W | PMP_X; // everything else
  uintptr_t cfg = cfg0 | (cfg1 << 8) | (cfg2 << 16);
  write_csr(pmpcfg0, cfg);
}

void enter_supervisor_mode(void (*fn)(uintptr_t), uintptr_t arg0, uintptr_t arg1)
{
  uintptr_t mstatus = read_csr(mstatus);
  mstatus = INSERT_FIELD(mstatus, MSTATUS_MPP, PRV_S);
  mstatus = INSERT_FIELD(mstatus, MSTATUS_MPIE, 0);
  write_csr(mstatus, mstatus);
  write_csr(mscratch, MACHINE_STACK_TOP() - MENTRY_FRAME_SIZE);
#ifndef __riscv_flen
  uintptr_t *p_fcsr = MACHINE_STACK_TOP() - MENTRY_FRAME_SIZE; // the x0's save slot
  *p_fcsr = 0;
#endif
  write_csr(mepc, fn);

  printm("calling mret\r\n");

  register uintptr_t a0 asm ("a0") = arg0;
  register uintptr_t a1 asm ("a1") = arg1;
  asm volatile ("mret" : : "r" (a0), "r" (a1));
  __builtin_unreachable();
}

void enter_machine_mode(void (*fn)(uintptr_t, uintptr_t), uintptr_t arg0, uintptr_t arg1)
{
  uintptr_t mstatus = read_csr(mstatus);
  mstatus = INSERT_FIELD(mstatus, MSTATUS_MPIE, 0);
  write_csr(mstatus, mstatus);
  write_csr(mscratch, MACHINE_STACK_TOP() - MENTRY_FRAME_SIZE);

  /* Jump to the payload's entry point */
  fn(arg0, arg1);

  __builtin_unreachable();
}
