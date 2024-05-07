// See LICENSE for license details.

#include "syscall.h"
#include "pk.h"
#include "file.h"
#include "frontend.h"
#include "mmap.h"
#include "boot.h"
#include "aes0.h"
#include "aes1.h"
#include "aes2.h"
#include "sha256.h"
#include "hmac.h"
#include "common_driver_fn.h"
#include "mcall.h"
#include <string.h>
#include <errno.h>

typedef long (*syscall_t)(long, long, long, long, long, long, long);

#define CLOCK_FREQ 1000000000

void sys_exit(int code)
{
  if (current.cycle0) {
    uint64_t dt = rdtime64() - current.time0;
    uint64_t dc = rdcycle64() - current.cycle0;
    uint64_t di = rdinstret64() - current.instret0;

    printk("%lld ticks\n", dt);
    printk("%lld cycles\n", dc);
    printk("%lld instructions\n", di);
    printk("%d.%d%d CPI\n", (int)(dc/di), (int)(10ULL*dc/di % 10),
        (int)((100ULL*dc + di/2)/di % 10));
  }
  shutdown(code);
}

ssize_t sys_read(int fd, char* buf, size_t n)
{
  ssize_t r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = file_read(f, buf, n);
    file_decref(f);
  }

  return r;
}

ssize_t sys_pread(int fd, char* buf, size_t n, off_t offset)
{
  ssize_t r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = file_pread(f, buf, n, offset);
    file_decref(f);
  }

  return r;
}

ssize_t sys_write(int fd, const char* buf, size_t n)
{
  ssize_t r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = file_write(f, buf, n);
    file_decref(f);
  }

  return r;
}

static int at_kfd(int dirfd)
{
  if (dirfd == AT_FDCWD)
    return AT_FDCWD;
  file_t* dir = file_get(dirfd);
  if (dir == NULL)
    return -1;
  return dir->kfd;
}

int sys_openat(int dirfd, const char* name, int flags, int mode)
{
  int kfd = at_kfd(dirfd);
  if (kfd != -1) {
    file_t* file = file_openat(kfd, name, flags, mode);
    if (IS_ERR_VALUE(file))
      return PTR_ERR(file);

    int fd = file_dup(file);
    if (fd < 0) {
      file_decref(file);
      return -ENOMEM;
    }

    return fd;
  }
  return -EBADF;
}

int sys_open(const char* name, int flags, int mode)
{
  return sys_openat(AT_FDCWD, name, flags, mode);
}

int sys_close(int fd)
{
  int ret = fd_close(fd);
  if (ret < 0)
    return -EBADF;
  return ret;
}

int sys_renameat(int old_fd, const char *old_path, int new_fd, const char *new_path) {
  int old_kfd = at_kfd(old_fd);
  int new_kfd = at_kfd(new_fd);
  if(old_kfd != -1 && new_kfd != -1) {
    size_t old_size = strlen(old_path)+1;
    size_t new_size = strlen(new_path)+1;
    return frontend_syscall(SYS_renameat, old_kfd, va2pa(old_path), old_size,
                                           new_kfd, va2pa(new_path), new_size, 0);
  }
  return -EBADF;
}

int sys_fstat(int fd, void* st)
{
  int r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = file_stat(f, st);
    file_decref(f);
  }

  return r;
}

int sys_fcntl(int fd, int cmd, int arg)
{
  int r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = frontend_syscall(SYS_fcntl, f->kfd, cmd, arg, 0, 0, 0, 0);
    file_decref(f);
  }

  return r;
}

int sys_ftruncate(int fd, off_t len)
{
  int r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = file_truncate(f, len);
    file_decref(f);
  }

  return r;
}

int sys_dup(int fd)
{
  int r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = file_dup(f);
    file_decref(f);
  }

  return r;
}

int sys_dup3(int fd, int newfd, int flags)
{
  kassert(flags == 0);
  int r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = file_dup3(f, newfd);
    file_decref(f);
  }

  return r;
}

ssize_t sys_lseek(int fd, size_t ptr, int dir)
{
  ssize_t r = -EBADF;
  file_t* f = file_get(fd);

  if (f)
  {
    r = file_lseek(f, ptr, dir);
    file_decref(f);
  }

  return r;
}

long sys_lstat(const char* name, void* st)
{
  struct frontend_stat buf;
  size_t name_size = strlen(name)+1;
  long ret = frontend_syscall(SYS_lstat, va2pa(name), name_size, va2pa(&buf), 0, 0, 0, 0);
  copy_stat(st, &buf);
  return ret;
}

long sys_fstatat(int dirfd, const char* name, void* st, int flags)
{
  int kfd = at_kfd(dirfd);
  if (kfd != -1) {
    struct frontend_stat buf;
    size_t name_size = strlen(name)+1;
    long ret = frontend_syscall(SYS_fstatat, kfd, va2pa(name), name_size, va2pa(&buf), flags, 0, 0);
    copy_stat(st, &buf);
    return ret;
  }
  return -EBADF;
}

long sys_stat(const char* name, void* st)
{
  return sys_fstatat(AT_FDCWD, name, st, 0);
}

long sys_faccessat(int dirfd, const char *name, int mode)
{
  int kfd = at_kfd(dirfd);
  if (kfd != -1) {
    size_t name_size = strlen(name)+1;
    return frontend_syscall(SYS_faccessat, kfd, va2pa(name), name_size, mode, 0, 0, 0);
  }
  return -EBADF;
}

long sys_access(const char *name, int mode)
{
  return sys_faccessat(AT_FDCWD, name, mode);
}

long sys_linkat(int old_dirfd, const char* old_name, int new_dirfd, const char* new_name, int flags)
{
  int old_kfd = at_kfd(old_dirfd);
  int new_kfd = at_kfd(new_dirfd);
  if (old_kfd != -1 && new_kfd != -1) {
    size_t old_size = strlen(old_name)+1;
    size_t new_size = strlen(new_name)+1;
    return frontend_syscall(SYS_linkat, old_kfd, va2pa(old_name), old_size,
                                        new_kfd, va2pa(new_name), new_size,
                                        flags);
  }
  return -EBADF;
}

long sys_link(const char* old_name, const char* new_name)
{
  return sys_linkat(AT_FDCWD, old_name, AT_FDCWD, new_name, 0);
}

long sys_unlinkat(int dirfd, const char* name, int flags)
{
  int kfd = at_kfd(dirfd);
  if (kfd != -1) {
    size_t name_size = strlen(name)+1;
    return frontend_syscall(SYS_unlinkat, kfd, va2pa(name), name_size, flags, 0, 0, 0);
  }
  return -EBADF;
}

long sys_unlink(const char* name)
{
  return sys_unlinkat(AT_FDCWD, name, 0);
}

long sys_mkdirat(int dirfd, const char* name, int mode)
{
  int kfd = at_kfd(dirfd);
  if (kfd != -1) {
    size_t name_size = strlen(name)+1;
    return frontend_syscall(SYS_mkdirat, kfd, va2pa(name), name_size, mode, 0, 0, 0);
  }
  return -EBADF;
}

long sys_mkdir(const char* name, int mode)
{
  return sys_mkdirat(AT_FDCWD, name, mode);
}

long sys_getcwd(const char* buf, size_t size)
{
  populate_mapping(buf, size, PROT_WRITE);
  return frontend_syscall(SYS_getcwd, va2pa(buf), size, 0, 0, 0, 0, 0);
}

size_t sys_brk(size_t pos)
{
  return do_brk(pos);
}

int sys_uname(void* buf)
{
    if (!(__valid_user_range((uintptr_t)buf, 65*5)))
        return 0; 
  const int sz = 65;
  strcpy(buf + 0*sz, "Proxy Kernel");
  strcpy(buf + 1*sz, "");
  strcpy(buf + 2*sz, "4.15.0");
  strcpy(buf + 3*sz, "");
  strcpy(buf + 4*sz, "");
  strcpy(buf + 5*sz, "");
  return 0;
}

pid_t sys_getpid()
{
  return 0;
}

int sys_getuid()
{
  return 0;
}

uintptr_t sys_mmap(uintptr_t addr, size_t length, int prot, int flags, int fd, off_t offset)
{
#if __riscv_xlen == 32
  if (offset != (offset << 12 >> 12))
    return -ENXIO;
  offset <<= 12;
#endif
  return do_mmap(addr, length, prot, flags, fd, offset);
}

int sys_munmap(uintptr_t addr, size_t length)
{
  return do_munmap(addr, length);
}

uintptr_t sys_mremap(uintptr_t addr, size_t old_size, size_t new_size, int flags)
{
  return do_mremap(addr, old_size, new_size, flags);
}

uintptr_t sys_mprotect(uintptr_t addr, size_t length, int prot)
{
  return do_mprotect(addr, length, prot);
}

int sys_rt_sigaction(int sig, const void* act, void* oact, size_t sssz)
{
  if (oact)
    memset(oact, 0, sizeof(long) * 3);

  return 0;
}

long sys_time(long* loc)
{
    if (!(__valid_user_range((uintptr_t)loc, 8)))
        return 0; 
  uint64_t t = rdcycle64() / CLOCK_FREQ;
  if (loc)
    *loc = t;
  return t;
}

int sys_times(long* loc)
{
    if (!(__valid_user_range((uintptr_t)loc, 2*8)))
        return 0; 
  uint64_t t = rdcycle64();
  kassert(CLOCK_FREQ % 1000000 == 0);
  loc[0] = t / (CLOCK_FREQ / 1000000);
  loc[1] = 0;
  loc[2] = 0;
  loc[3] = 0;
  
  return 0;
}

int sys_gettimeofday(long* loc)
{
    if (!(__valid_user_range((uintptr_t)loc, 2*8)))
        return 0; 
  uint64_t t = rdcycle64();
  loc[0] = t / CLOCK_FREQ;
  loc[1] = (t % CLOCK_FREQ) / (CLOCK_FREQ / 1000000);
  
  return 0;
}

long sys_clock_gettime(int clk_id, long *loc)
{
    if (!(__valid_user_range((uintptr_t)loc, 2*8)))
        return 0; 
  uint64_t t = rdcycle64();
  loc[0] = t / CLOCK_FREQ;
  loc[1] = (t % CLOCK_FREQ) / (CLOCK_FREQ / 1000000000);

  return 0;
}

ssize_t sys_writev(int fd, const long* iov, int cnt)
{
  ssize_t ret = 0;
  for (int i = 0; i < cnt; i++)
  {
    ssize_t r = sys_write(fd, (void*)iov[2*i], iov[2*i+1]);
    if (r < 0)
      return r;
    ret += r;
  }
  return ret;
}

int sys_chdir(const char *path)
{
  return frontend_syscall(SYS_chdir, va2pa(path), 0, 0, 0, 0, 0, 0);
}

int sys_getdents(int fd, void* dirbuf, int count)
{
  return 0; //stub
}

static int sys_stub_success()
{
  return 0;
}

static int sys_stub_nosys()
{
  return -ENOSYS;
}

static int sys_hello_world()
{
    printk("system call hello\n"); 
    return 0;
}

static int sys_rsa_wait()
{

  register uint32_t a7 asm ("a7") = (uint32_t)(SBI_RSA_WAIT);

  return 0;
}

static int sys_rsa_write_prime_num(uint32_t *p_num)
{

  if (!__valid_user_range((uintptr_t)p_num, 256))
    return 0;

  uint32_t volatile sp_num[64] = {p_num[0], p_num[1], p_num[2], p_num[3], p_num[4], p_num[5], p_num[6], p_num[7],
                                  p_num[8], p_num[9], p_num[10], p_num[11], p_num[12], p_num[13], p_num[14], p_num[15],
                                  p_num[16], p_num[17], p_num[18], p_num[19], p_num[20], p_num[21], p_num[22], p_num[23],
                                  p_num[24], p_num[25], p_num[26], p_num[27], p_num[28], p_num[29], p_num[30], p_num[31],
                                  p_num[32], p_num[33], p_num[34], p_num[35], p_num[36], p_num[37], p_num[38], p_num[39],
                                  p_num[40], p_num[41], p_num[42], p_num[43], p_num[44], p_num[45], p_num[46], p_num[47],
                                  p_num[48], p_num[49], p_num[50], p_num[51], p_num[52], p_num[53], p_num[54], p_num[55],
                                  p_num[56], p_num[57], p_num[58], p_num[59], p_num[60], p_num[61], p_num[62], p_num[63]};

  register uintptr_t a0 asm ("a0") = (uintptr_t)(sp_num);
  register uint32_t a7 asm ("a7") = (uint32_t)(SBI_RSA_WRITE_PNUM);

  asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

  memset((uint32_t *)sp_num, 0, sizeof(sp_num)); 
  return 0;
}

static int sys_rsa_write_msg_in(uint32_t *msg_in, uint32_t encry_decry)
{
  if (!__valid_user_range((uintptr_t)msg_in, 256))
    return 0;

  uint32_t volatile smsg_in[64] = {msg_in[0], msg_in[1], msg_in[2], msg_in[3], msg_in[4], msg_in[5], msg_in[6], msg_in[7],
                                   msg_in[8], msg_in[9], msg_in[10], msg_in[11], msg_in[12], msg_in[13], msg_in[14], msg_in[15],
                                   msg_in[16], msg_in[17], msg_in[18], msg_in[19], msg_in[20], msg_in[21], msg_in[22], msg_in[23],
                                   msg_in[24], msg_in[25], msg_in[26], msg_in[27], msg_in[28], msg_in[29], msg_in[30], msg_in[31],
                                   msg_in[32], msg_in[33], msg_in[34], msg_in[35], msg_in[36], msg_in[37], msg_in[38], msg_in[39],
                                   msg_in[40], msg_in[41], msg_in[42], msg_in[43], msg_in[44], msg_in[45], msg_in[46], msg_in[47],
                                   msg_in[48], msg_in[49], msg_in[50], msg_in[51], msg_in[52], msg_in[53], msg_in[54], msg_in[55],
                                   msg_in[56], msg_in[57], msg_in[58], msg_in[59], msg_in[60], msg_in[61], msg_in[62], msg_in[63]};

  register uintptr_t a0 asm ("a0") = (uintptr_t)(smsg_in);
  register uint32_t a1 asm ("a1") = (uint32_t)(encry_decry);
  register uint32_t a7 asm ("a7") = (uint32_t)(SBI_RSA_WRITE_MSG_IN);

  asm volatile ( "ecall"
                :
                : "r" (a0), "r" (a1), "r" (a7));

  memset((uint32_t *)smsg_in, 0, sizeof(smsg_in));

  return 0;
}

static int sys_rsa_read_msg_out(uint32_t *msg_out)
{
  if (!__valid_user_range((uintptr_t)msg_out, 256))
    return 0;

  uint32_t volatile smsg_out[64] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

  register uintptr_t a0 asm ("a0") = (uintptr_t)(smsg_out);
  register uint32_t a7 asm ("a7") = (uint32_t)(SBI_RSA_READ_MSG_OUT);

  asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

  msg_out[0]  = smsg_out[0]; msg_out[1]  = smsg_out[1]; msg_out[2]  = smsg_out[2]; msg_out[3]  = smsg_out[3];
  msg_out[4]  = smsg_out[4]; msg_out[5]  = smsg_out[5]; msg_out[6]  = smsg_out[6]; msg_out[7]  = smsg_out[7]; 
  msg_out[8]  = smsg_out[8]; msg_out[9]  = smsg_out[9]; msg_out[10]  = smsg_out[10]; msg_out[11]  = smsg_out[11];
  msg_out[12]  = smsg_out[12]; msg_out[13]  = smsg_out[13]; msg_out[14]  = smsg_out[14]; msg_out[15]  = smsg_out[15]; 
  msg_out[16]  = smsg_out[16]; msg_out[17]  = smsg_out[17]; msg_out[18]  = smsg_out[18]; msg_out[19]  = smsg_out[19];
  msg_out[20]  = smsg_out[20]; msg_out[21]  = smsg_out[21]; msg_out[22]  = smsg_out[22]; msg_out[23]  = smsg_out[23]; 
  msg_out[24]  = smsg_out[24]; msg_out[25]  = smsg_out[25]; msg_out[26]  = smsg_out[26]; msg_out[27]  = smsg_out[27];
  msg_out[28]  = smsg_out[28]; msg_out[29]  = smsg_out[29]; msg_out[30]  = smsg_out[30]; msg_out[31]  = smsg_out[31]; 
  msg_out[32]  = smsg_out[32]; msg_out[33]  = smsg_out[33]; msg_out[34]  = smsg_out[34]; msg_out[35]  = smsg_out[35];
  msg_out[36]  = smsg_out[36]; msg_out[37]  = smsg_out[37]; msg_out[38]  = smsg_out[38]; msg_out[39]  = smsg_out[39]; 
  msg_out[40]  = smsg_out[40]; msg_out[41]  = smsg_out[41]; msg_out[42]  = smsg_out[42]; msg_out[43]  = smsg_out[43];
  msg_out[44]  = smsg_out[44]; msg_out[45]  = smsg_out[45]; msg_out[46]  = smsg_out[46]; msg_out[47]  = smsg_out[47]; 
  msg_out[48]  = smsg_out[48]; msg_out[49]  = smsg_out[49]; msg_out[50]  = smsg_out[50]; msg_out[51]  = smsg_out[51];
  msg_out[52]  = smsg_out[52]; msg_out[53]  = smsg_out[53]; msg_out[54]  = smsg_out[54]; msg_out[55]  = smsg_out[55]; 
  msg_out[56]  = smsg_out[56]; msg_out[57]  = smsg_out[57]; msg_out[58]  = smsg_out[58]; msg_out[59]  = smsg_out[59];
  msg_out[60]  = smsg_out[60]; msg_out[61]  = smsg_out[61]; msg_out[62]  = smsg_out[62]; msg_out[63]  = smsg_out[63]; 
  
  memset((uint32_t *)smsg_out, 0, sizeof(smsg_out)); 
  
  return 0;
}

static int sys_rng_wait()
{


    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_RNG_WAIT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a7) ); 

    return 0;
}


static int sys_rng_read_data(uint32_t *randnum)
{
    if (!__valid_user_range((uintptr_t)randnum, 8)) 
        return 0; 

    uint32_t volatile srandnum[2] = {0,0};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(srandnum);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_RNG_READ_DATA);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

    randnum[0]  = srandnum[0]; 
    randnum[1]  = srandnum[1];  
    memset((uint32_t *)srandnum, 0, sizeof(srandnum)); 
    return 0;
}

static int sys_rng_read_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16)
{
    if (!(__valid_user_range((uintptr_t)poly128, 16) && __valid_user_range((uintptr_t)poly64, 8) && __valid_user_range((uintptr_t)poly32, 4)) && __valid_user_range((uintptr_t)poly16, 4)) 
        return 0; 

    uint32_t volatile spoly128[4] = {0,0,0,0};
    uint32_t volatile spoly64[2] = {0,0};
    uint32_t volatile spoly32[1] = {0};
    uint32_t volatile spoly16[1] = {0};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(spoly128);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(spoly64);
    register uintptr_t a2 asm ("a2") = (uintptr_t)(spoly32);
    register uintptr_t a3 asm ("a3") = (uintptr_t)(spoly16);

    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_RNG_READ_POLY);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (a7) ); 

    poly128[0] = spoly128[0];
    poly128[1] = spoly128[1];
    poly128[2] = spoly128[2];
    poly128[3] = spoly128[3];

    poly64[0] = spoly64[0];
    poly64[1] = spoly64[1];

    poly32[0] = spoly32[0];
    poly16[0] = spoly16[0];

    memset((uint32_t *)spoly128, 0, sizeof(spoly128));
    memset((uint32_t *)spoly64, 0, sizeof(spoly64));
    memset((uint32_t *)spoly32, 0, sizeof(spoly32));
    memset((uint32_t *)spoly16, 0, sizeof(spoly16));

  return 0;
}

static int sys_rng_write_poly(uint32_t *poly128, uint32_t *poly64, uint32_t *poly32, uint32_t *poly16)
{
    if (!(__valid_user_range((uintptr_t)poly128, 16) && __valid_user_range((uintptr_t)poly64, 8) && __valid_user_range((uintptr_t)poly32, 4)) && __valid_user_range((uintptr_t)poly16, 4)) 
        return 0; 

    uint32_t volatile spoly128[4] = {poly128[0],poly128[1],poly128[2],poly128[3]};
    uint32_t volatile spoly64[2] = {poly64[0],poly64[1]};
    uint32_t volatile spoly32[1] = {poly32[0]};
    uint32_t volatile spoly16[1] = {poly16[0]};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(spoly128);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(spoly64);
    register uintptr_t a2 asm ("a2") = (uintptr_t)(spoly32);
    register uintptr_t a3 asm ("a3") = (uintptr_t)(spoly16);

    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_RNG_WRITE_POLY);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (a7) ); 

    memset((uint32_t *)spoly128, 0, sizeof(spoly128));
    memset((uint32_t *)spoly64, 0, sizeof(spoly64));
    memset((uint32_t *)spoly32, 0, sizeof(spoly32));
    memset((uint32_t *)spoly16, 0, sizeof(spoly16));
  return 0;
}

static int sys_rng_read_seed(uint32_t *seed128, uint32_t *seed64, uint32_t *seed32, uint32_t *seed16)
{
    if (!(__valid_user_range((uintptr_t)seed128, 16) && __valid_user_range((uintptr_t)seed64, 8) && __valid_user_range((uintptr_t)seed32, 4)) && __valid_user_range((uintptr_t)seed16, 4)) 
        return 0; 

    uint32_t volatile sseed128[4] = {0,0,0,0};
    uint32_t volatile sseed64[2] = {0,0};
    uint32_t volatile sseed32[1] = {0};
    uint32_t volatile sseed16[1] = {0};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sseed128);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(sseed64);
    register uintptr_t a2 asm ("a2") = (uintptr_t)(sseed32);
    register uintptr_t a3 asm ("a3") = (uintptr_t)(sseed16);

    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_RNG_READ_SEED);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (a7) ); 

    seed128[0] = sseed128[0];
    seed128[1] = sseed128[1];
    seed128[2] = sseed128[2];
    seed128[3] = sseed128[3];

    seed64[0] = sseed64[0];
    seed64[1] = sseed64[1];

    seed32[0] = sseed32[0];
    seed16[0] = sseed16[0];

    memset((uint32_t *)sseed128, 0, sizeof(sseed128));
    memset((uint32_t *)sseed64, 0, sizeof(sseed64));
    memset((uint32_t *)sseed32, 0, sizeof(sseed32));
    memset((uint32_t *)sseed16, 0, sizeof(sseed16));

  return 0;
}

static int sys_rng_write_seed(uint32_t *seed)
{
    if (!__valid_user_range((uintptr_t)seed, 16))
      return 0;

    uint32_t volatile sseed[4] = {seed[0], seed[1], seed[2], seed[4]} ; 

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sseed);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_RNG_WRITE_SEED);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 
    memset((uint32_t *)sseed, 0, sizeof(sseed)); 

    return 0;
}

static int sys_rng_read_rand_seg(uint32_t *rand_seg)
{
    if (!__valid_user_range((uintptr_t)rand_seg, 8)) 
        return 0; 

    uint32_t volatile srand_seg[2] = {0,0};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(srand_seg);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_RNG_READ_RAND_SEG);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

    rand_seg[0]  = srand_seg[0]; 
    rand_seg[1]  = srand_seg[1];  
    memset((uint32_t *)srand_seg, 0, sizeof(srand_seg));  
  return 0;
}

static int sys_rng_read_state_counter(uint32_t *st_cnt)
{
    if (!__valid_user_range((uintptr_t)st_cnt, 4)) 
        return 0; 

    uint32_t volatile sst_cnt[1] = {0};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sst_cnt);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_RNG_READ_STATE_COUNTER);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

    st_cnt[0] = sst_cnt[0];   
    memset((uint32_t *)sst_cnt, 0, sizeof(sst_cnt));
  return 0;
}



static int sys_aes0_start_decry(uint32_t *ct, uint32_t *st, uint32_t key_sel)
{
    if (!(__valid_user_range((uintptr_t)ct, 16) && __valid_user_range((uintptr_t)st, 16)))
        return 0; 

    uint32_t volatile spt[4] = {ct[0], ct[1], ct[2], ct[3]} ; 

    uint32_t volatile sst[4]  = {st[0], st[1], st[2], st[3]};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(spt);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(sst);
    register uint32_t  a2 asm ("a2") = (uint32_t)(key_sel);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES0_START_ENCRYPT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a7) ); 

    memset((uint32_t *)spt, 0, sizeof(spt)); 
    memset((uint32_t *)sst, 0, sizeof(sst)); 

    return 0;
}


static int sys_aes0_start_encry(uint32_t *pt, uint32_t *st, uint32_t key_sel)
{
    if (!__valid_user_range((uintptr_t)st, 16))
        return 0; 

    uint32_t volatile spt[4] = {pt[0], pt[1], pt[2], pt[3]} ; 

    uint32_t volatile sst[4]  = {st[0], st[1], st[2], st[3]};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(spt);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(sst);
    register uint32_t  a2 asm ("a2") = (uint32_t)(key_sel);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES0_START_ENCRYPT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a7) ); 
    memset((uint32_t *)spt, 0, sizeof(spt)); 
    memset((uint32_t *)sst, 0, sizeof(sst)); 

    return 0;
}


static int sys_aes0_wait()
{


    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES0_WAIT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a7) ); 

    return 0;
}


static int sys_aes0_data_out(uint32_t *t, uint32_t key_sel)
{
    if (!__valid_user_range((uintptr_t)t, 16)) 
        return 0; 

    uint32_t volatile sct[4] = {0,0,0,0};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sct);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES0_DATA_OUT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

    t[0]  = sct[0]; 
    t[1]  = sct[1]; 
    t[2]  = sct[2]; 
    t[3]  = sct[3]; 
    memset((uint32_t *)sct, 0, sizeof(sct)); 
    return 0;
}

static int sys_aes2_start_decry(uint32_t *ct, uint32_t *st, uint32_t key_sel)
{
    if (!(__valid_user_range((uintptr_t)ct, 16) && __valid_user_range((uintptr_t)st, 16)))
        return 0; 

    uint32_t volatile spt[4] = {ct[0], ct[1], ct[2], ct[3]} ; 

    uint32_t volatile sst[4]  = {st[0], st[1], st[2], st[3]};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(spt);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(sst);
    register uint32_t  a2 asm ("a2") = (uint32_t)(key_sel);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES2_START_ENCRYPT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a7) ); 

    memset((uint32_t *)spt, 0, sizeof(spt)); 
    memset((uint32_t *)sst, 0, sizeof(sst)); 

    return 0;
}


static int sys_aes2_start_encry(uint32_t *pt, uint32_t *st, uint32_t key_sel)
{
    if (!__valid_user_range((uintptr_t)st, 16))
        return 0; 

    uint32_t volatile spt[4] = {pt[0], pt[1], pt[2], pt[3]} ; 

    uint32_t volatile sst[4]  = {st[0], st[1], st[2], st[3]};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(spt);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(sst);
    register uint32_t  a2 asm ("a2") = (uint32_t)(key_sel);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES2_START_ENCRYPT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a7) ); 
    memset((uint32_t *)spt, 0, sizeof(spt)); 
    memset((uint32_t *)sst, 0, sizeof(sst)); 

    return 0;
}

static int sys_rst(uint32_t id)
{
    register uint32_t a0 asm ("a0") = (uint32_t)(id);
  register uint32_t  a1 asm ("a7") = (uint32_t)(SBI_RST);
  
    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1)); 
    return 0;
}

static int sys_aes2_wait()
{


    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES2_WAIT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a7) ); 

    return 0;
}


static int sys_aes2_data_out(uint32_t *t, uint32_t key_sel)
{
    if (!__valid_user_range((uintptr_t)t, 16)) 
        return 0; 

    uint32_t volatile sct[4] = {0,0,0,0};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sct);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES2_DATA_OUT);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

    t[0]  = sct[0]; 
    t[1]  = sct[1]; 
    t[2]  = sct[2]; 
    t[3]  = sct[3]; 
    memset((uint32_t *)sct, 0, sizeof(sct)); 
    return 0;
}

static int sys_aes1_read_data(uint32_t *res)
{
    if (!__valid_user_range((uintptr_t)res, 12)) 
        return 0; 

    uint32_t volatile sres[4] = {0,0,0,0};

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sres);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES1_READ_DATA);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

    res[0]  = sres[0]; 
    res[1]  = sres[1]; 
    res[2]  = sres[2]; 
    res[3]  = sres[3]; 
    memset((uint32_t *)sres, 0, sizeof(sres)); 
    return 0;
}
static int sys_aes1_read_config(uint32_t *conf)
{
    if (!__valid_user_range((uintptr_t)conf, 4)) 
        return 0; 

    uint32_t volatile sconf = 0;

    register uintptr_t a0 asm ("a0") = (uintptr_t)(&sconf);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES1_READ_CONFIG);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

    *conf = sconf; 
    return 0;
}
static int sys_aes1_write_data(uint32_t *bk, uint32_t key_sel)
{
    if (!__valid_user_range((uintptr_t)bk, 16)) 
        return 0; 

    uint32_t volatile sbk[4] = {bk[0], bk[1], bk[2], bk[3]} ; 

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sbk);
    register uint32_t a1 asm ("a1") = (uint32_t)(key_sel);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES1_WRITE_DATA);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a7) ); 

    memset((uint32_t *)sbk, 0, sizeof(sbk)); 
    return 0;
}
static int sys_aes1_write_config(uint32_t config)
{

    register uint32_t a0 asm ("a0") = (uint32_t)(config);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_AES1_WRITE_CONFIG);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a7) ); 

    return 0;
}


static int sys_sha256_hash(char *pString, uint32_t *hash)
{
    if (!(__valid_user_range((uintptr_t)pString, strlen(pString)+1) && __valid_user_range((uintptr_t)hash, SHA256_HASH_WORDS*4)))
        return 0; 

    char volatile spString[500];
    uint32_t volatile shash[SHA256_HASH_WORDS]; 


    memcpy((char *)spString, pString, strlen(pString)+1);


    register uintptr_t a0 asm ("a0") = (uintptr_t)(spString);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(shash);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_SHA256_HASH);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a7) ); 

    for (int i=0; i<SHA256_HASH_WORDS; i++)
        hash[i]  = shash[i]; 
    memset((uint32_t *)spString, 0, sizeof(spString)); 
    memset((uint32_t *)shash, 0, sizeof(shash)); 

    return 0;
}


static int sys_dma_copy(uint64_t sAddr, uint64_t dAddr, uint32_t length, uint32_t wait)
{

    uint64_t volatile ssAddr = sAddr ; 
    uint64_t volatile sdAddr = dAddr ; 
    uint32_t volatile slength = length ; 
    uint32_t volatile swait = wait ; 

    register uint64_t a0 asm ("a0") = (uint64_t)(ssAddr);
    register uint64_t a1 asm ("a1") = (uint64_t)(sdAddr);
    register uint32_t a2 asm ("a2") = (uint32_t)(slength);
    register uint32_t  a3 asm ("a3") = (uint32_t)(swait);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_DMA_COPY);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (a7) ); 

    return 0;
}

static int sys_dma_copy_to_perif(uint32_t *sAddr, uint64_t dAddr, uint32_t length, uint32_t wait)
{

    if (!__valid_user_range((uintptr_t)sAddr, length+1)) 
        return 0; 

    uint32_t volatile ssAddr[64];  
    uint64_t volatile sdAddr = dAddr ; 
    uint32_t volatile slength = length ; 
    uint32_t volatile swait = wait ; 


    if (length > 32)
        return 0; 

    for (int i=0; i<2*length; i++)
    {
        ssAddr[i] = sAddr[i]; 
    }

    register uintptr_t a0 asm ("a0") = (uintptr_t)(ssAddr);
    register uint64_t a1 asm ("a1") = (uint64_t)(sdAddr);
    register uint32_t a2 asm ("a2") = (uint32_t)(slength);
    register uint32_t  a3 asm ("a3") = (uint32_t)(wait);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_DMA_COPY);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (a7) ); 

    memset((uint32_t *)ssAddr, 0, sizeof(ssAddr)); 
    return 0;
}

static int sys_dma_copy_from_perif(uint64_t sAddr, uint32_t *dAddr, uint32_t length, uint32_t wait)
{

    if (!__valid_user_range((uintptr_t)dAddr, length+1)) 
        return 0; 

    uint64_t volatile ssAddr = sAddr;  
    uint32_t volatile sdAddr[64] ; 
    uint32_t volatile slength = length ; 
    uint32_t volatile swait = wait ; 


    if (length > 32)
        return 0; 

    for (int i=0; i<64; i++)
    {
        sdAddr[i] = 0; 
    }

    register uint64_t a0 asm ("a0") = (uint64_t)(ssAddr);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(sdAddr);
    register uint32_t a2 asm ("a2") = (uint32_t)(slength);
    register uint32_t  a3 asm ("a3") = (uint32_t)(wait);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_DMA_COPY);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (a7) ); 

    for (int i=0; i<2*length; i++)
    {
        dAddr[i] = sdAddr[i]; 
    }
    memset((uint32_t *)sdAddr, 0, sizeof(sdAddr)); 
    return 0;
}


static int sys_dma_end()
{

    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_DMA_END);

    asm volatile ( "ecall"
                  : 
                  : "r" (a7) ); 

    return 0;
}






static int sys_hmac_hash(char *pString, uint32_t *hash, uint32_t use_key_hash)
{

    if (!(__valid_user_range((uintptr_t)pString, strlen(pString)+1) && __valid_user_range((uintptr_t)hash, HMAC_HASH_WORDS*4)))
        return 0; 

    char volatile spString[65];
    uint32_t volatile shash[SHA256_HASH_WORDS]; 


    memcpy((char *)spString, pString, 64);
    spString[64] = '\0'; 


    register uintptr_t a0 asm ("a0") = (uintptr_t)(spString);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(shash);
    register uint32_t  a2 asm ("a2") = (uint32_t)(use_key_hash);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_HMAC_HASH);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a7) ); 

    for (int i=0; i<HMAC_HASH_WORDS; i++)
        hash[i]  = shash[i]; 
    memset((uint32_t *)spString, 0, sizeof(spString)); 

    return 0;
}

static int sys_cmp(uint32_t *expectedData, uint32_t *receivedData, uint32_t block_size, uint32_t *equality)
{

    if (!(__valid_user_range_u((uintptr_t)expectedData, block_size) && __valid_user_range_u((uintptr_t)receivedData, block_size)  && __valid_user_range_u((uintptr_t)equality, 4)))
        return 0; 

    uint32_t volatile spt[1024] ; 

    uint32_t volatile sst[1024]; // = receivedData; 

    uint32_t volatile sblock_size = block_size;

    uint32_t volatile sequality;

    if (block_size > 1024)
        return 0; 

    for (int i=0; i<block_size; i++)
    {
        spt[i] = expectedData[i]; 
        sst[i] = receivedData[i]; 
    }

    register uintptr_t a0 asm ("a0") = (uintptr_t)(spt);
    register uintptr_t a1 asm ("a1") = (uintptr_t)(sst);
    register uint32_t  a2 asm ("a2") = (uint32_t)(sblock_size);
    register uintptr_t a3 asm ("a3") = (uintptr_t)(&sequality);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_CMP);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (a7) ); 

    *equality = sequality;
    memset((uint32_t *)spt, 0, sizeof(spt)); 
    memset((uint32_t *)sst, 0, sizeof(sst)); 

    return 0;
}

static int sys_puts(uint32_t *buf, uint32_t buf_len)
{
    if (!(__valid_user_range((uintptr_t)buf, buf_len)))
        return 0; 

    //printk("entered puts s_sys_call \n %d: %s\n", buf_len, buf); 
    char volatile sbuf[64] ; 

    uint32_t volatile sbuf_len = buf_len; 

    for (int i=0; i<buf_len; i++)
    {
        sbuf[i] = ((char *)buf)[i]; 
    }

    register uintptr_t a0 asm ("a0") = (uintptr_t)(sbuf);
    register uint32_t a1 asm ("a1") = (uint32_t)(sbuf_len);
    register uint32_t  a7 asm ("a7") = (uint32_t)(SBI_PUTS);

    asm volatile ( "ecall"
                  : 
                  : "r" (a0), "r" (a1), "r" (a7) ); 

    return 0;
}



long do_syscall(long a0, long a1, long a2, long a3, long a4, long a5, unsigned long n)
{
  const static void* syscall_table[] = {
    [SYS_exit] = sys_exit,
    [SYS_exit_group] = sys_exit,
    [SYS_read] = sys_stub_nosys,
    [SYS_pread] = sys_stub_nosys,
    [SYS_write] = sys_stub_nosys,
    [SYS_openat] = sys_stub_nosys,
    [SYS_close] = sys_stub_nosys,
    [SYS_fstat] = sys_stub_nosys,
    [SYS_lseek] = sys_stub_nosys,
    [SYS_fstatat] = sys_stub_nosys,
    [SYS_linkat] = sys_stub_nosys,
    [SYS_unlinkat] = sys_stub_nosys,
    [SYS_mkdirat] = sys_stub_nosys,
    [SYS_renameat] = sys_stub_nosys,
    [SYS_getcwd] = sys_stub_nosys,
    [SYS_brk] = sys_brk,
    [SYS_uname] = sys_uname,
    [SYS_getpid] = sys_stub_nosys,
    [SYS_getuid] = sys_stub_nosys,
    [SYS_geteuid] = sys_stub_nosys,
    [SYS_getgid] = sys_stub_nosys,
    [SYS_getegid] = sys_stub_nosys,
    [SYS_mmap] = sys_mmap,
    [SYS_munmap] = sys_munmap,
    [SYS_mremap] = sys_mremap,
    [SYS_mprotect] = sys_mprotect,
    [SYS_prlimit64] = sys_stub_nosys,
    [SYS_rt_sigaction] = sys_stub_nosys,
    [SYS_gettimeofday] = sys_gettimeofday,
    [SYS_times] = sys_times,
    [SYS_writev] = sys_stub_nosys,
    [SYS_faccessat] = sys_stub_nosys,
    [SYS_fcntl] = sys_stub_nosys,
    [SYS_ftruncate] = sys_stub_nosys,
    [SYS_getdents] = sys_stub_nosys,
    [SYS_dup] = sys_stub_nosys,
    [SYS_dup3] = sys_stub_nosys,
    [SYS_readlinkat] = sys_stub_nosys,
    [SYS_rt_sigprocmask] = sys_stub_success,
    [SYS_ioctl] = sys_stub_nosys,
    [SYS_clock_gettime] = sys_clock_gettime,
    [SYS_getrusage] = sys_stub_nosys,
    [SYS_getrlimit] = sys_stub_nosys,
    [SYS_setrlimit] = sys_stub_nosys,
    [SYS_chdir] = sys_stub_nosys,
    [SYS_set_tid_address] = sys_stub_nosys,
    [SYS_set_robust_list] = sys_stub_nosys,
    [SYS_madvise] = sys_stub_nosys,
    [SYS_hello] = sys_hello_world,
    [SYS_AES0_START_ENCRY] = sys_aes0_start_encry,    
    [SYS_AES0_START_DECRY] = sys_aes0_start_decry,    
    [SYS_AES0_WAIT] = sys_aes0_wait,    
    [SYS_AES0_DATA_OUT] = sys_aes0_data_out,
    [SYS_AES2_START_ENCRY] = sys_aes2_start_encry,    
    [SYS_AES2_START_DECRY] = sys_aes2_start_decry,    
    [SYS_AES2_WAIT] = sys_aes2_wait,    
    [SYS_AES2_DATA_OUT] = sys_aes2_data_out,    
    [SYS_AES1_READ_DATA] = sys_aes1_read_data, 
    [SYS_AES1_WRITE_DATA] = sys_aes1_write_data,
    [SYS_AES1_READ_CONFIG] = sys_aes1_read_config, 
    [SYS_AES1_WRITE_CONFIG] = sys_aes1_write_config,
    [SYS_SHA256_HASH] = sys_sha256_hash,    
    [SYS_HMAC_HASH] = sys_hmac_hash,    
    [SYS_DMA_COPY] = sys_dma_copy,       
    [SYS_DMA_COPY1] = sys_dma_copy_to_perif,       
    [SYS_DMA_COPY2] = sys_dma_copy_from_perif,       
    [SYS_CMP] = sys_cmp,    
    [SYS_PUTS] = sys_puts,    
    [SYS_DMA_END] = sys_dma_end,
    [SYS_RNG_WAIT] = sys_rng_wait,
    [SYS_RNG_READ_DATA] = sys_rng_read_data,
    [SYS_RNG_READ_POLY] = sys_rng_read_poly,
    [SYS_RNG_WRITE_POLY] = sys_rng_write_poly,
    [SYS_RNG_READ_SEED] = sys_rng_read_seed,
    [SYS_RNG_WRITE_SEED] = sys_rng_write_seed,
    [SYS_RNG_READ_RAND_SEG] = sys_rng_read_rand_seg,
    [SYS_RNG_READ_STATE_COUNTER] = sys_rng_read_state_counter,
    [SYS_RST] = sys_rst,
    [SYS_RSA_WAIT] = sys_rsa_wait, 
    [SYS_RSA_WRITE_PNUM] = sys_rsa_write_prime_num,
    [SYS_RSA_WRITE_MSG_IN] = sys_rsa_write_msg_in,
    [SYS_RSA_READ_MSG_OUT] = sys_rsa_read_msg_out,    
  };

  const static void* old_syscall_table[] = {
    [-OLD_SYSCALL_THRESHOLD + SYS_open] = sys_open,
    [-OLD_SYSCALL_THRESHOLD + SYS_link] = sys_link,
    [-OLD_SYSCALL_THRESHOLD + SYS_unlink] = sys_unlink,
    [-OLD_SYSCALL_THRESHOLD + SYS_mkdir] = sys_mkdir,
    [-OLD_SYSCALL_THRESHOLD + SYS_access] = sys_access,
    [-OLD_SYSCALL_THRESHOLD + SYS_stat] = sys_stat,
    [-OLD_SYSCALL_THRESHOLD + SYS_lstat] = sys_lstat,
    [-OLD_SYSCALL_THRESHOLD + SYS_time] = sys_time,
  };

  syscall_t f = 0;

  if (n < ARRAY_SIZE(syscall_table))
    f = syscall_table[n];
  else if (n - OLD_SYSCALL_THRESHOLD < ARRAY_SIZE(old_syscall_table))
    f = old_syscall_table[n - OLD_SYSCALL_THRESHOLD];

  if (!f)
    panic("bad syscall #%ld!",n);

  return f(a0, a1, a2, a3, a4, a5, n);
}
