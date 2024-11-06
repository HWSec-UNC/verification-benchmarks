clear -all

analyze -sv design/src/axi/src/axi_pkg.sv
analyze -sv design/src/debug/dm_pkg.sv
analyze -sv design/include/riscv_pkg.sv
analyze -sv design/include/ariane_pkg.sv
analyze -sv design/include/ariane_axi_pkg.sv
analyze -sv design/include/serpent_cache_pkg.sv
analyze -sv design/include/std_cache_pkg.sv
analyze -sv design/include/axi_intf.sv
analyze -sv design/src/util/instruction_tracer_pkg.sv
analyze -sv design/src/util/instruction_tracer_if.sv
analyze -sv design/src/util/sram.sv
analyze -sv design/src/util/axi_master_connect.sv
analyze -sv design/src/util/axi_master_connect_rev.sv
analyze -sv design/src/util/axi_slave_connect.sv
analyze -sv design/src/util/axi_slave_connect_rev.sv
analyze -sv design/src/common_cells/src/fifo_v1.sv
analyze -sv design/src/common_cells/src/fifo_v2.sv
analyze -sv design/src/common_cells/src/fifo_v3.sv
analyze -sv design/src/common_cells/src/lzc.sv
analyze -sv design/src/common_cells/src/rrarbiter.sv
analyze -sv design/src/common_cells/src/rstgen_bypass.sv
analyze -sv design/src/common_cells/src/sync_wedge.sv
analyze -sv design/src/common_cells/src/cdc_2phase.sv
analyze -sv design/src/common_cells/src/pipe_reg_simple.sv
analyze -sv design/src/fpga-support/rtl/SyncSpRamBeNx64.sv
analyze -sv design/src/axi_mem_if/src/axi2mem.sv
analyze -sv design/src/tech_cells_generic/src/cluster_clock_inverter.sv
analyze -sv design/src/tech_cells_generic/src/pulp_clock_mux2.sv
analyze -sv design/src/axi_adapter.sv
analyze -sv design/src/alu.sv
analyze -sv design/src/fpu_wrap.sv





analyze -sv design/src/branch_unit.sv
analyze -sv design/src/compressed_decoder.sv
analyze -sv design/src/controller.sv
analyze -sv design/src/csr_buffer.sv
analyze -sv design/src/csr_regfile.sv
analyze -sv design/src/decoder.sv
analyze -sv design/src/ex_stage.sv
analyze -sv design/src/frontend/btb.sv
analyze -sv design/src/frontend/bht.sv
analyze -sv design/src/frontend/ras.sv
analyze -sv design/src/frontend/instr_scan.sv
analyze -sv design/src/frontend/frontend.sv
analyze -sv design/src/id_stage.sv
analyze -sv design/src/instr_realigner.sv
analyze -sv design/src/issue_read_operands.sv
analyze -sv design/src/issue_stage.sv
analyze -sv design/src/load_unit.sv

#adding the store_unit module to be analyized because jasper is unable to locate it while analyzing load_store_unit. 
#store_unit uses the amo_buffer so I am also analyzing that in jasper
analyze -sv design/src/amo_buffer.sv
analyze -sv design/src/store_unit.sv
analyze -sv design/src/load_store_unit.sv

#analyzing std_cache_subsystem, screen_arbitor, stream_mux, stream_demux, std_nbdcache.sv, std_icache.sv for std_cache
analyze -sv design/src/ariane.sv
analyze -sv design/src/common_cells/src/stream_arbiter.sv
analyze -sv design/src/common_cells/src/stream_mux.sv
analyze -sv design/src/common_cells/src/stream_demux.sv
analyze -sv design/src/cache_subsystem/std_cache_subsystem.sv
analyze -sv design/src/cache_subsystem/std_icache.sv
analyze -sv design/src/cache_subsystem/std_nbdcache.sv

#now analyzing cache_ctrl.sv, miss_handler.sv, tag_cmp.sv
analyze -sv design/src/cache_subsystem/cache_ctrl.sv
analyze -sv design/src/cache_subsystem/miss_handler.sv
analyze -sv design/src/cache_subsystem/tag_cmp.sv

#icache and nbdcache: lfsr_8bit
analyze -sv design/src/common_cells/src/lfsr_8bit.sv
#miss_handler: amo_amu 
analyze -sv design/src/cache_subsystem/amo_alu.sv



analyze -sv design/src/mmu.sv
analyze -sv design/src/mult.sv
analyze -sv design/src/multiplier.sv
analyze -sv design/src/serdiv.sv
analyze -sv design/src/perf_counters.sv
analyze -sv design/src/ptw.sv
analyze -sv design/src/ariane_regfile_ff.sv
analyze -sv design/src/re_name.sv
analyze -sv design/src/scoreboard.sv
analyze -sv design/src/store_buffer.sv
analyze -sv design/src/tlb.sv
analyze -sv design/src/commit_stage.sv
analyze -sv design/src/cache_subsystem/serpent_dcache_ctrl.sv
analyze -sv design/src/cache_subsystem/serpent_dcache_mem.sv
analyze -sv design/src/cache_subsystem/serpent_dcache_missunit.sv
analyze -sv design/src/cache_subsystem/serpent_dcache_wbuffer.sv
analyze -sv design/src/cache_subsystem/serpent_dcache.sv
analyze -sv design/src/cache_subsystem/serpent_icache.sv
analyze -sv design/src/cache_subsystem/serpent_l15_adapter.sv
analyze -sv design/src/cache_subsystem/serpent_cache_subsystem.sv
analyze -sv design/src/debug/debug_rom/debug_rom.sv
analyze -sv design/src/debug/dm_csrs.sv
analyze -sv design/src/clint/clint.sv
analyze -sv design/src/clint/axi_lite_interface.sv
analyze -sv design/src/debug/dm_mem.sv
analyze -sv design/src/debug/dm_top.sv
analyze -sv design/src/debug/dmi_cdc.sv
analyze -sv design/src/debug/dmi_jtag.sv
analyze -sv design/src/debug/dm_sba.sv
analyze -sv design/src/debug/dmi_jtag_tap.sv
analyze -sv design/openpiton/ariane_verilog_wrap.sv
analyze -sv design/openpiton/serpent_peripherals.sv
analyze -sv design/bootrom/bootrom.sv
analyze -sv design/src/plic/plic.sv
analyze -sv design/src/plic/plic_claim_complete_tracker.sv
analyze -sv design/src/plic/plic_comparator.sv
analyze -sv design/src/plic/plic_find_max.sv
analyze -sv design/src/plic/plic_gateway.sv
analyze -sv design/src/plic/plic_interface.sv
analyze -sv design/src/plic/plic_target_slice.sv
analyze -sv design/fpga/src/axi2apb/src/axi2apb_wrap.sv
analyze -sv design/fpga/src/axi2apb/src/axi2apb.sv
analyze -sv design/fpga/src/axi2apb/src/axi2apb_64_32.sv
analyze -sv design/fpga/src/axi_slice/src/axi_w_buffer.sv
analyze -sv design/fpga/src/axi_slice/src/axi_b_buffer.sv
analyze -sv design/fpga/src/axi_slice/src/axi_slice_wrap.sv
analyze -sv design/fpga/src/axi_slice/src/axi_slice.sv
analyze -sv design/fpga/src/axi_slice/src/axi_single_slice.sv
analyze -sv design/fpga/src/axi_slice/src/axi_ar_buffer.sv
analyze -sv design/fpga/src/axi_slice/src/axi_r_buffer.sv
analyze -sv design/fpga/src/axi_slice/src/axi_aw_buffer.sv
analyze -sv design/src/register_interface/src/apb_to_reg.sv
analyze -sv design/src/register_interface/src/reg_intf.sv

elaborate -top ariane

clock clk_i -factor 1 -phase 1
reset -expression ~rst_ni

#No properties for bugs 1-2
assert -name HACK@DAC19_p5 {~(csr_regfile_i.debug_mode_q && csr_regfile_i.umode_i) || (riscv::PRIV_LVL_M)}
#No properties for bugs 6-8
assert -name HACK@DAC19_p9 {((csr_regfile_i.csr_we || csr_regfile_i.csr_read) && (csr_regfile_i.csr_addr.address==riscv::CSR_MEPC) |-> csr_regfile_i.csr_exception_o.valid == 1'b1)}
#No properties for bugs 10-16

#P17: WIP

#No properties for bugs 18-20

assert -name HACK@DAC19_p21_wrong {~((commit_stage_i.csr_exception_i.valid && commit_stage_i.csr_exception_i.cause[63] && commit_stage_i.commit_instr_i[0].fu != commit_stage_i.CSR) || (commit_stage_i.amo_valid_commit_o))}

assert -name HACK@DAC19_p21_another {(commit_stage_i.amo_valid_commit_o |-> (commit_stage_i.exception_o != commit_stage_i.csr_exception_i))}

assert -name HACK@DAC19_p22 {(commit_stage_i.amo_valid_commit_o |-> ~commit_stage_i.commit_ack_o[1])}
#p23 is on the top module-ariane
assert -name HACK@DAC19_p23 {(amo_valid_commit |-> (flush_ctrl_if && flush_ctrl_id && flush_ctrl_ex))}

assert -name HACK@DAC19_p24 {(csr_regfile_i.tvm_o |-> (csr_regfile_i.csr_rdata_o != csr_regfile_i.satp_q))}

assert -name HACK@DAC19_p25 {(csr_regfile_i.tvm_o |-> (csr_regfile_i.satp_d != csr_regfile_i.csr_wdata_i))}
#p26 is on the top module-ariane
assert -name HACK@DAC19_p26 {(priv_lvl != $past(priv_lvl)) |-> (flush_ctrl_if && flush_ctrl_id && flush_ctrl_ex)}
#No properties for bugs 27-28
assert -name HACK@DAC19_p29 {((csr_regfile_i.instret_q != $past(csr_regfile_i.instret_q)) |-> csr_regfile_i.debug_mode_q)}
#No properties for bugs 30-31
assert -name HACK@DAC19_p32 {(controller_i.halt_o |-> controller_i.ex_valid_i)}
#No properties for bugs 33-43
#P44: WIP
#No properties for bugs 45-48
#P49: WIP
#No properties for bug 50
#P51: WIP
#No properties for bug 52
