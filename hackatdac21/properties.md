| ID | Assertion | Bug Number | Bug Description | CWE-ID |
|----| ---- | ---- | ---- | ---- |
|p1|assert(\~trst\_ni \|-> pass\_check == 1'b0) |1|JTAG password flag not reset properly|CWE-1239|
|p2|assert (state\_q == IDLE && state\_d == WRITE \|-> pass\_check == 1'b1)|2|Able to write using JTAG without password|CWE-1245|
|p3|assert(\~(debug\_mode\_q && umode\_i) \|\| (riscv::PRIV\_LVL\_M))|7|Incorrect access control setting leaving debug enabled|CWE-1220|
|p4|assert(count - 1 == $next(count)) or something ** draft|14|Counter register in AES CTR mode does not increase|CWE-1240|
|p5|assert((csr\_we && csr.addr.address == riscv::CSR\_SIE) -> mie\_d == (mie\_q & \~mideleg\_q) \| (csr\_wdata & mideleg\_q))|18|Access to CSRs from lower privilege level|CWE-1262|
|p6|assert(pass\_mode \|-> pass\_data == data\_d)|30|JTAG key is hardcoded|CWE-1329|
|p7|assert\~(\~(rst\_ni && \~jtag\_unlock && \~rst\_9) \|-> (reglk\_mem == 'h0))|35|Reg locks are disabled by default when reset|CWE-1232|
|p8|assert (sha256\_ctrl\_reg == IGNORE && ignore\_input\_reg \|-> data == 0)|36|SHA input data not cleared after HASH computation|CWE-1239|
|p9|assert(ct\_valid \|-> ((p\_c[0] == 0) && (p\_c[1] == 0) && (p\_c[2] == 0) && (p\_c[3] == 0)) |39|AES plain text is left uncleared after the encryption is over in the peripheral registers|CWE-226|
|p10|assert ( (rst\_ni && rst\_6) \|\| (acct\_mem[0]==32'h0000\_0000))|42|At reset, the access control values are set to full access|CWE-276|
|p11|assert(debug\_mode\_i \|-> ((key\_big == 192'b0) && (key\_big2 == 192'b0)))|46|Not disconnecting sensitive data from fuse when in debug mode|CWE-1243|
|p12|assert(debug\_mode\_i \|-> ((key\_big == 192'b0) && (key\_big2 == 192'b0)))|47|not clearing one of the aes keys when entering debug mode|CWE-1258|
|p13|assert(\~(rst\_ni&& \~rst\_9) \|-> \~jtag\_unlock)|48|JTAG unlock disables the reglocks|CWE-1234|
|p14|assert(dma\_ctrl\_reg == CTRL\_ABORT && !done \|=> dma\_ctrl\_reg != CTRL\_ABORT)|57|if abort is issued when there is no active command running in dma, the dma gets stuck in a unknown state|CWE-1245|
|p15|assert ((dmi\_req\_ready && state\_q == Write) \|=> (state\_q == WatiWriteValid)).|84|Unreachable state WaitWriteValid in JTAG|CWE-1245|
|p16|assert(\~(rst\_ni && \~rst\_13) \|-> (msg\_out == 0))|95|Output message on RSA is not cleared after a soft reset. This can leave decrypted data available in a memory mapped area.|CWE-226|
|p17|assert (ariane\_boot\_sel\_i \|-> rom\_rdata\_patch)|96|ROM module is hardcoded|CWE-1310|
