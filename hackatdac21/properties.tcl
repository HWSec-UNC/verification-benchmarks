assert -name HACK@DAC21_p1 {(~dmi_jtag_i.trst_ni |-> dmi_jtag_i.pass_check == 1'b0)}
assert -name HACK@DAC21_p2 {(dmi_jtag_i.state_q == dmi_jtag_i.Idle && dmi_jtag_i.state_d == dmi_jtag_i.Write |-> dmi_jtag_i.pass_check == 1'b1)}
assert -name HACK@DAC21_p7 {(~(ariane_i.csr_regfile_i.debug_mode_q) || (riscv::PRIV_LVL_M))}
assert -name HACK@DAC21_p14 {( (aes0_wrapper_i.aes.uut.validCounter - 1) == $next(aes0_wrapper_i.aes.uut.validCounter))}
assert -name HACK@DAC21_p18 {(ariane_i.csr_regfile_i.csr_we && ariane_i.csr_regfile_i.csr_addr.address == riscv::CSR_SIE) -> ariane_i.csr_regfile_i.mie_d == (ariane_i.csr_regfile_i.mie_q & ~ariane_i.csr_regfile_i.mideleg_q) | (ariane_i.csr_regfile_i.csr_wdata & ariane_i.csr_regfile_i.mideleg_q)}
assert -name HACK@DAC21_p30 {((dmi_jtag_i.pass_mode) |-> (dmi_jtag_i.pass_data == dmi_jtag_i.data_d))}
assert -name HACK@DAC21_p35 {~(reglk_wrapper_i.rst_ni && ~reglk_wrapper_i.jtag_unlock && ~reglk_wrapper_i.rst_9) |-> (reglk_wrapper_i.reglk_mem == 'h0)}
assert -name HACK@DAC21_p36 {((sha256_wrapper_i.sha256.sha256_ctrl_reg == sha256_wrapper_i.sha256.CTRL_IGNORE && sha256_wrapper_i.sha256.ignore_input_reg) |-> (sha256_wrapper_i.data == 0))}
assert -name HACK@DAC21_p39 {(aes0_wrapper_i.ct_valid |-> ((aes0_wrapper_i.p_c[0] == 0) && (aes0_wrapper_i.p_c[1] == 0) && (aes0_wrapper_i.p_c[2] == 0) && (aes0_wrapper_i.p_c[3] == 0)))}
assert -name HACK@DAC21_p42 {((acct_wrapper_i.rst_ni && rst_6) || (acct_wrapper_i.acct_mem.read_data_0[0]==32'h0000_0000))}
assert -name HACK@DAC21_p46 {((aes0_wrapper_i.debug_mode_i) |-> ((aes0_wrapper_i.key_big == 192'b0) && (aes0_wrapper_i.key_big2 == 192'b0)))}
assert -name HACK@DAC21_p47 {((aes0_wrapper_i.debug_mode_i) |-> ((aes0_wrapper_i.key_big == 192'b0) && (aes0_wrapper_i.key_big2 == 192'b0)))}
assert -name HACK@DAC21_p48 {(~(reglk_wrapper_i.rst_ni && ~rst_9) |-> ~reglk_wrapper_i.jtag_unlock)}
assert -name HACK@DAC21_p57 {(dma_i.dma_ctrl_reg == dma_i.CTRL_ABORT && !dma_i.done_i |=> dma_i.dma_ctrl_reg != dma_i.CTRL_ABORT)}
assert -name HACK@DAC21_p84 {((dmi_jtag_i.dmi_req_ready && dmi_jtag_i.state_q == dmi_jtag_i.Write) |=> (dmi_jtag_i.state_q == dmi_jtag_i.WaitWriteValid))}
assert -name HACK@DAC21_p95 {(~(rsa_wrapper_i.rst_ni && ~rsa_wrapper_i.rst_13) |-> (rsa_wrapper_i.msg_out == 0))}
assert -name HACK@DAC21_p96_modified {(riscv_peripherals_i.ariane_boot_sel_i |-> riscv_peripherals_i.rom_rdata_linux)}
