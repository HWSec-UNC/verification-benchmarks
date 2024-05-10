| ID | Assertion | Bug Number | Bug Description | CWE-ID |
|----| ---- | ---- | ---- | ---- |
|p1|assert(\~(((j==6) && access\_ctrl\_i[i][7][priv\_lvl\_i])) draft|1|Processor access to CLINT grants it access to PLIC regardless of PLIC access configuration|CWE-1220|
|p2|assert(\~(debug\_mode\_q && umode\_i) \|\| (riscv::PRIV\_LVL\_M))|5|Incorrect access control setting leaving debug enabled|CWE-1244|
|p3|assert( ((csr\_we \|\| csr\_read) && (csr\_addr.address==riscv::CSR\_MEPC)) \|-> csr\_exception\_o.valid == 1'b1)|9|Execute machine level instructions from user mode|CWE-1262|
|p4|assert {amo\_valid\_commit\_o \|-> \~commit\_ack\_o[1]}|22|Commit the second instruction even if the first is atomic instruction||
|p5|assert {amo\_valid\_commit \|-> (flush\_ctrl\_if && flush\_ctrl\_id && flush\_ctrl\_ex)}|23|Pipeline not flushed after committing an atomic instruction||
|p6|assert {tvm\_o \|-> (csr\_rdata\_o != satp\_q)}|24|SATP register (read) accessible in Supervisor mode even if TVM is enabled||
|p7|assert {tvm\_o \|-> (satp\_d != csr\_wdata\_i)|25|SATP register (write) accessible in Supervisor mode even if TVM is enabled||
|p8|assert {(priv\_lvl != $past(priv\_lvl)) \|-> (flush\_ctrl\_if && flush\_ctrl\_id && flush\_ctrl\_ex)}|26|Pipeline not flushed after change in virtual address translation mode||
|p9|assert {(instret\_q != $past(instret\_q)) \|-> debug\_mode\_q}|29|Instruction retired counters are updated in non-debug mode||
|p10|assert {halt\_o \|-> ex\_valid\_i}|32|Exception signal is not set at halt||
|p11|assert(pass\_mode \|-> pass\_data == data\_d)|53|JTAG key is hardcoded|CWE-1329|
