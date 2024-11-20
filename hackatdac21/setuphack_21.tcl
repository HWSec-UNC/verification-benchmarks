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
