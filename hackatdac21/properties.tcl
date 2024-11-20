assert -name HACK@DAC21\_p1 {(\~dmi\_jtag\_i.trst\_ni \|-> dmi\_jtag\_i.pass\_check == 1'b0)}
assert -name HACK@DAC21\_p2 {(dmi\_jtag\_i.state\_q == dmi\_jtag\_i.Idle && dmi\_jtag\_i.state\_d == dmi\_jtag\_i.Write \|-> dmi\_jtag\_i.pass\_check == 1'b1)}
assert -name HACK@DAC21\_p7 {(\~(ariane\_i.csr\_regfile\_i.debug\_mode\_q) \|\| (riscv::PRIV\_LVL\_M))}
assert -name HACK@DAC21\_p14 {( (aes0\_wrapper\_i.aes.uut.validCounter - 1) == $next(aes0\_wrapper\_i.aes.uut.validCounter))}
assert -name HACK@DAC21\_p18 {(ariane\_i.csr\_regfile\_i.csr\_we && ariane\_i.csr\_regfile\_i.csr\_addr.address == riscv::CSR\_SIE) -> ariane\_i.csr\_regfile\_i.mie\_d == (ariane\_i.csr\_regfile\_i.mie\_q & \~ariane\_i.csr\_regfile\_i.mideleg\_q) \| (ariane\_i.csr\_regfile\_i.csr\_wdata & ariane\_i.csr\_regfile\_i.mideleg\_q)}
assert -name HACK@DAC21\_p30 {((dmi\_jtag\_i.pass\_mode) \|-> (dmi\_jtag\_i.pass\_data == dmi\_jtag\_i.data\_d))}
assert -name HACK@DAC21\_p35 {\~(reglk\_wrapper\_i.rst\_ni && \~reglk\_wrapper\_i.jtag\_unlock && \~reglk\_wrapper\_i.rst\_9) \|-> (reglk\_wrapper\_i.reglk\_mem == 'h0)}
assert -name HACK@DAC21\_p36 {((sha256\_wrapper\_i.sha256.sha256\_ctrl\_reg == sha256\_wrapper\_i.sha256.CTRL\_IGNORE && sha256\_wrapper\_i.sha256.ignore\_input\_reg) \|-> (sha256\_wrapper\_i.data == 0))}
assert -name HACK@DAC21\_p39 {(aes0\_wrapper\_i.ct\_valid \|-> ((aes0\_wrapper\_i.p\_c[0] == 0) && (aes0\_wrapper\_i.p\_c[1] == 0) && (aes0\_wrapper\_i.p\_c[2] == 0) && (aes0\_wrapper\_i.p\_c[3] == 0)))}
assert -name HACK@DAC21\_p42 {((acct\_wrapper\_i.rst\_ni && rst\_6) \|\| (acct\_wrapper\_i.acct\_mem.read\_data\_0[0]==32'h0000\_0000))}
assert -name HACK@DAC21\_p46 {((aes0\_wrapper\_i.debug\_mode\_i) \|-> ((aes0\_wrapper\_i.key\_big == 192'b0) && (aes0\_wrapper\_i.key\_big2 == 192'b0)))}
assert -name HACK@DAC21\_p47 {((aes0\_wrapper\_i.debug\_mode\_i) \|-> ((aes0\_wrapper\_i.key\_big == 192'b0) && (aes0\_wrapper\_i.key\_big2 == 192'b0)))}
assert -name HACK@DAC21\_p48 {(\~(reglk\_wrapper\_i.rst\_ni && \~rst\_9) \|-> \~reglk\_wrapper\_i.jtag\_unlock)}
assert -name HACK@DAC21\_p57 {(dma\_i.dma\_ctrl\_reg == dma\_i.CTRL\_ABORT && !dma\_i.done\_i \|=> dma\_i.dma\_ctrl\_reg != dma\_i.CTRL\_ABORT)}
assert -name HACK@DAC21\_p84 {((dmi\_jtag\_i.dmi\_req\_ready && dmi\_jtag\_i.state\_q == dmi\_jtag\_i.Write) \|=> (dmi\_jtag\_i.state\_q == dmi\_jtag\_i.WaitWriteValid))}
assert -name HACK@DAC21\_p95 {(\~(rsa\_wrapper\_i.rst\_ni && \~rsa\_wrapper\_i.rst\_13) \|-> (rsa\_wrapper\_i.msg\_out == 0))}
assert -name HACK@DAC21\_p96\_modified {(riscv\_peripherals\_i.ariane\_boot\_sel\_i \|-> riscv\_peripherals\_i.rom\_rdata\_linux)}
