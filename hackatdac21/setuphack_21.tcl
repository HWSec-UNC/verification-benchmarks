clear -all

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/axi/src/axi_pkg.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/axi/src/axi_pkg.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dm_pkg.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/include/riscv_pkg.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_pkg.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/include/ariane_pkg.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/tb/ariane_soc_pkg.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/include/ariane_axi_pkg.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/include/std_cache_pkg.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/ariane.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/frontend/frontend.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/frontend/instr_scan.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/instr_realign.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/frontend/ras.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/unread.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/frontend/btb.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/frontend/bht.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/frontend/instr_queue.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/popcount.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/fifo_v3.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/id_stage.sv 
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/compressed_decoder.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/decoder.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/issue_stage.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/re_name.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/ariane_regfile.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/scoreboard.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/ariane_regfile_ff.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/issue_read_operands.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/rr_arb_tree.sv 

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu_wrap.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_top.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_opgroup_block.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_opgroup_fmt_slice.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_fma.sv -incdir design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/common_cells/include
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_classifier.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_rounding.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_noncomp.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_opgroup_multifmt_slice.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_fma_multi.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_divsqrt_multi.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/div_sqrt_top_mvp.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/preprocess_mvp.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/nrbd_nrsc_mvp.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/norm_div_sqrt_mvp.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpnew_cast_multi.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/iteration_div_sqrt_mvp.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/ex_stage.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/alu.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/branch_unit.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/csr_buffer.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/serdiv.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/mult.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/multiplier.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/shift_reg.sv


analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/load_store_unit.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/store_unit.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/amo_buffer.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/store_buffer.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/load_unit.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/mmu.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/tlb.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/ptw.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/commit_stage.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/perf_counters.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/controller.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/cache_subsystem/std_cache_subsystem.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/stream_mux.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/stream_demux.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/cache_subsystem/std_icache.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/stream_arbiter.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/stream_arbiter_flushable.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/cache_subsystem/std_nbdcache.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/cache_subsystem/cache_ctrl.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/cache_subsystem/tag_cmp.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/cache_subsystem/miss_handler.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/axi_adapter.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/cache_subsystem/amo_alu.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fpga-support/rtl/SyncSpRamBeNx64.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/util/sram.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/deprecated/fifo_v2.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/lzc.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/fifo_v3.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/lfsr_8bit.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/deprecated/rrarbiter.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/csr_regfile.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dmi_jtag.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dmi_jtag_tap.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/tech_cells_generic/src/cluster_clock_inverter.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/tech_cells_generic/src/pulp_clock_mux2.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dmi_cdc.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dmi_cdc.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/common_cells/src/cdc_2phase.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/hmac/hmac.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/sha256/sha256.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/sha256/sha256_k_constants.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/sha256/sha256_w_mem.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/reglk/reglk_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/clint/axi_lite_interface.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/sha256/sha256_wrapper.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/sha256/sha256_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes0/aes0_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes0/aes_192_sed.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes0/aes_192.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes0/table.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes0/round.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/acct/acct_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/dma/dma.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/pmp/pmp.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/pmp/pmp_entry.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rsa/rsa_top.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/tech_cells_generic/src/pulp_clock_inverter.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rsa/mod_exp.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rsa/mod.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/register_interface/src/reg_intf.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/register_interface/src/reg_intf_pkg.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/openpiton/riscv_peripherals.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/tb/common/SimDTM.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/tb/common/SimJTAG.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dm_top.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dm_csrs.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dm_sba.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/src/dm_mem.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/riscv-dbg/debug_rom/debug_rom.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/axi_mem_if/src/axi2mem.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/bootrom/bootrom.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/openpiton/linux_save/bootrom_linux.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/clint/clint.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rv_plic/rtl/plic_top.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rv_plic/rtl/rv_plic_gateway.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rv_plic/rtl/rv_plic_target.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rv_plic/rtl/plic_regmap.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rst_ctrl/rst_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rsa/rsa_wrapper.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rand_num/rng_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rand_num/rng_top.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes1/aes1_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes1/aes1_core.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes2/aes2_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes2/aes2_interface.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/hmac/hmac_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/hmac/hmac.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/pkt/pkt_wrapper.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/pkt/pkt.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/fuse_mem/fuse_mem.sv
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/dma/dma_wrapper.sv

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rand_num/rng_cs.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rand_num/rng_128.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rand_num/rng_64.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rand_num/rng_32.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rand_num/rng_16.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes1/aes1_encipher_block.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes1/aes1_decipher_block.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes1/aes1_key_mem.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes1/aes1_sbox.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes1/aes1_inv_sbox.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes2/gcm_aes_v0.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes2/gfm128_16.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes2/aes_cipher_top.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes2/aes_key_expand_128.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes2/aes_sbox.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/aes2/aes_rcon.v

analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rsa/inverter.v
analyze -sv design/hackatdac21/piton/design/chip/tile/ariane/src/rsa/mod.v

analyze -sv top_wrapper_dac21.sv
elaborate -top top_wrapper_dac21 -bbox_m {scoreboard noc_axilite_bridge AXI_BUS}
clock clk_i -factor 1 -phase 1
reset -expression ~rst_ni

assert -name HACK@DAC21_p1 {(~dmi_jtag_i.trst_ni |-> dmi_jtag_i.pass_check == 1'b0)}
assert -name HACK@DAC21_p2 {(dmi_jtag_i.state_q == dmi_jtag_i.Idle && dmi_jtag_i.state_d == dmi_jtag_i.Write |-> dmi_jtag_i.pass_check == 1'b1)}
assert -name HACK@DAC21_p7 {(~(ariane_i.csr_regfile_i.debug_mode_q) || (riscv::PRIV_LVL_M))}
assert -name HACK@DAC21_p14 {( (aes0_wrapper_i.aes.uut.validCounter - 1) == $next(aes0_wrapper_i.aes.uut.validCounter))}
assert -name HACK@DAC21_p18 {(ariane_i.csr_regfile_i.csr_we && ariane_i.csr_regfile_i.csr_addr.address == riscv::CSR_SIE) -> ariane_i.csr_regfile_i.mie_d == (ariane_i.csr_regfile_i.mie_q & ~ariane_i.csr_regfile_i.mideleg_q) | (ariane_i.csr_regfile_i.csr_wdata & ariane_i.csr_regfile_i.mideleg_q)}
assert -name HACK@DAC21_p23 {((ariane_i.irq_i == ariane_i.csr_regfile_i.irq_i) && (ariane_i.time_irq_i  == ariane_i.csr_regfile_i.time_irq_i))}
assert -name HACK@DAC21_p28 {( (aes0_wrapper_i.aes.uut.out_valid) |-> (aes0_wrapper_i.aes.uut.key==0))}

assert -name HACK@DAC21_p30 {((dmi_jtag_i.pass_mode) |-> (dmi_jtag_i.pass_data == dmi_jtag_i.data_d))}
assert -name HACK@DAC21_p35 {~(reglk_wrapper_i.rst_ni && ~reglk_wrapper_i.jtag_unlock && ~reglk_wrapper_i.rst_9) |-> (reglk_wrapper_i.reglk_mem == 'h0)}
assert -name HACK@DAC21_p36 {((sha256_wrapper_i.sha256.sha256_ctrl_reg == sha256_wrapper_i.sha256.CTRL_IGNORE && sha256_wrapper_i.sha256.ignore_input_reg) |-> (sha256_wrapper_i.data == 0))}
assert -name HACK@DAC21_p39 {(aes0_wrapper_i.ct_valid |-> ((aes0_wrapper_i.p_c[0] == 0) && (aes0_wrapper_i.p_c[1] == 0) && (aes0_wrapper_i.p_c[2] == 0) && (aes0_wrapper_i.p_c[3] == 0)))}
assert -name HACK@DAC21_p42 {((acct_wrapper_i.rst_ni && rst_6) || (acct_wrapper_i.acct_mem.read_data_0[0]==32'h0000_0000))}
assert -name HACK@DAC21_p46 {((aes0_wrapper_i.debug_mode_i) |-> ((aes0_wrapper_i.key_big == 192'b0) && (aes0_wrapper_i.key_big2 == 192'b0)))}

assert -name HACK@DAC21_p47 {((aes0_wrapper_i.debug_mode_i) |-> ((aes0_wrapper_i.key_big == 192'b0) && (aes0_wrapper_i.key_big2 == 192'b0)))}
assert -name HACK@DAC21_p48 {(~(reglk_wrapper_i.rst_ni && ~rst_9) |-> ~reglk_wrapper_i.jtag_unlock)}
assert -name HACK@DAC21_p57 {(dma_i.dma_ctrl_reg == dma_i.CTRL_ABORT && !dma_i.done_i |=> dma_i.dma_ctrl_reg != dma_i.CTRL_ABORT)}
assert -name HACK@DAC21_p71 {((rsa_top_i.encrypt_decrypt_i == 1) |-> rsa_top_i.msg_in != rsa_top_i.msg_out)}

assert -name HACK@DAC21_p76 {(reglk_wrapper_i.en && reglk_wrapper_i.we && reglk_wrapper_i.address[7:3] == 2) |-> (reglk_wrapper_i.reglk_mem[2] != 0)}
assert -name HACK@DAC21_p77 {(acct_wrapper_i.en && acct_wrapper_i.we && acct_wrapper_i.address[7:3] == 10) |-> (acct_wrapper_i.acct_mem.read_data_0[10] != 0)}
assert -name HACK@DAC21_p78 {(riscv_peripherals_i.i_pkt_wrapper.en && riscv_peripherals_i.i_pkt_wrapper.we && riscv_peripherals_i.i_pkt_wrapper.address[7:3] == 1 && riscv_peripherals_i.i_pkt_wrapper.reglk_ctrl_i[5] ) |-> (riscv_peripherals_i.i_pkt_wrapper.fuse_req_o != riscv_peripherals_i.i_pkt_wrapper.wdata)}

assert -name HACK@DAC21_p83 {(riscv_peripherals_i.i_fuse_mem.test_MEM_SIZE == riscv_peripherals_i.i_fuse_mem.test_JTAG_OFFSET)}

assert -name HACK@DAC21_p84 {((dmi_jtag_i.dmi_req_ready && dmi_jtag_i.state_q == dmi_jtag_i.Write) |=> (dmi_jtag_i.state_q == dmi_jtag_i.WaitWriteValid))}

assert -name HACK@DAC21_p89 {((rsa_top_i.m.exponent_reg != 'd0) |=> (rsa_top_i.m.result_reg != $past(rsa_top_i.m.result_reg)))}
assert -name HACK@DAC21_p90 {((rsa_wrapper_i.rsa0.m.exponent_reg != 'd0) |=> (rsa_wrapper_i.rsa0.m.result_reg != $past(rsa_wrapper_i.rsa0.m.result_reg)))}

assert -name HACK@DAC21_p95 {(~(rsa_wrapper_i.rst_ni && ~rsa_wrapper_i.rst_13) |-> (rsa_wrapper_i.msg_out == 0))}
assert -name HACK@DAC21_p96 {(riscv_peripherals_i.ariane_boot_sel_i |-> riscv_peripherals_i.rom_rdata_linux)}
assert -name HACK@DAC21_p97_one {(~riscv_peripherals_i.i_hmac_wrapper.rst_ni |-> ~riscv_peripherals_i.i_hmac_wrapper.newMessage_r ==0)}
assert -name HACK@DAC21_p97_two {(~riscv_peripherals_i.i_hmac_wrapper.rst_ni |-> ~riscv_peripherals_i.i_hmac_wrapper.startHash_r ==0)}
assert -name HACK@DAC21_p99 {( ~(riscv_peripherals_i.i_aes0_wrapper.en_acct && riscv_peripherals_i.i_aes0_wrapper.acct_ctrl_i) || (riscv_peripherals_i.i_aes0_wrapper.en))}