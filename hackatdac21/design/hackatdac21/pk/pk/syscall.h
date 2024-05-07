// See LICENSE for license details.

#ifndef _PK_SYSCALL_H
#define _PK_SYSCALL_H

#define SYS_exit 93
#define SYS_exit_group 94
#define SYS_getpid 172
#define SYS_kill 129
#define SYS_read 63
#define SYS_write 64
#define SYS_openat 56
#define SYS_close 57
#define SYS_lseek 62
#define SYS_brk 214
#define SYS_linkat 37
#define SYS_unlinkat 35
#define SYS_mkdirat 34
#define SYS_renameat 38
#define SYS_chdir 49
#define SYS_getcwd 17
#define SYS_fstat 80
#define SYS_fstatat 79
#define SYS_faccessat 48
#define SYS_pread 67
#define SYS_pwrite 68
#define SYS_uname 160
#define SYS_getuid 174
#define SYS_geteuid 175
#define SYS_getgid 176
#define SYS_getegid 177
#define SYS_mmap 222
#define SYS_munmap 215
#define SYS_mremap 216
#define SYS_mprotect 226
#define SYS_prlimit64 261
#define SYS_getmainvars 2011
#define SYS_rt_sigaction 134
#define SYS_writev 66
#define SYS_gettimeofday 169
#define SYS_times 153
#define SYS_fcntl 25
#define SYS_ftruncate 46
#define SYS_getdents 61
#define SYS_dup 23
#define SYS_dup3 24
#define SYS_readlinkat 78
#define SYS_rt_sigprocmask 135
#define SYS_ioctl 29
#define SYS_getrlimit 163
#define SYS_setrlimit 164
#define SYS_getrusage 165
#define SYS_clock_gettime 113
#define SYS_set_tid_address 96
#define SYS_set_robust_list 99
#define SYS_madvise 233

#define SYS_hello 1023

#define SYS_RNG_WAIT 1050
#define SYS_RNG_READ_DATA 1051
#define SYS_RNG_READ_POLY 1052
#define SYS_RNG_WRITE_POLY 1053
#define SYS_RNG_READ_SEED 1054
#define SYS_RNG_WRITE_SEED 1055
#define SYS_RNG_READ_RAND_SEG 1056
#define SYS_RNG_READ_STATE_COUNTER 1057
#define SYS_AES0_START_ENCRY 1022
#define SYS_AES0_START_DECRY 1021
#define SYS_AES0_WAIT 1020
#define SYS_AES0_DATA_OUT 1019

#define SYS_AES2_START_ENCRY 1058
#define SYS_AES2_START_DECRY 1059
#define SYS_AES2_WAIT 1060
#define SYS_AES2_DATA_OUT 1061

#define SYS_RST 1067
#define SYS_RSA_WRITE_PNUM 1063
#define SYS_RSA_WRITE_MSG_IN 1064
#define SYS_RSA_READ_MSG_OUT 1065
#define SYS_RSA_WAIT 1066

#define SYS_SHA256_HASH 1018
#define SYS_HMAC_HASH 1017
#define SYS_DMA_COPY 1016
#define SYS_DMA_COPY1 1015
#define SYS_DMA_COPY2 1014
#define SYS_CMP 1013
#define SYS_AES1_READ_DATA 1012
#define SYS_AES1_WRITE_DATA 1011
#define SYS_AES1_READ_CONFIG 1010
#define SYS_AES1_WRITE_CONFIG 1009
#define SYS_PUTS 1008
#define SYS_DMA_END 1007

#define OLD_SYSCALL_THRESHOLD 1024
#define SYS_open 1024
#define SYS_link 1025
#define SYS_unlink 1026
#define SYS_mkdir 1030
#define SYS_access 1033
#define SYS_stat 1038
#define SYS_lstat 1039
#define SYS_time 1062

#define IS_ERR_VALUE(x) ((unsigned long)(x) >= (unsigned long)-4096)
#define ERR_PTR(x) ((void*)(long)(x))
#define PTR_ERR(x) ((long)(x))

#undef AT_FDCWD
#define AT_FDCWD -100

long do_syscall(long a0, long a1, long a2, long a3, long a4, long a5, unsigned long n);

#endif
