clear -all

analyze -sv src/axi/src/axi_pkg.sv
analyze -sv src/debug/dm_pkg.sv
analyze -sv include/riscv_pkg.sv
analyze -sv include/ariane_pkg.sv
analyze -sv include/ariane_axi_pkg.sv
analyze -sv include/serpent_cache_pkg.sv
analyze -sv include/std_cache_pkg.sv
analyze -sv include/axi_intf.sv
analyze -sv src/util/instruction_tracer_pkg.sv
analyze -sv src/util/instruction_tracer_if.sv
analyze -sv src/util/sram.sv
analyze -sv src/util/axi_master_connect.sv
analyze -sv src/util/axi_master_connect_rev.sv
analyze -sv src/util/axi_slave_connect.sv
analyze -sv src/util/axi_slave_connect_rev.sv
analyze -sv src/common_cells/src/fifo_v1.sv
analyze -sv src/common_cells/src/fifo_v2.sv
analyze -sv src/common_cells/src/fifo_v3.sv
analyze -sv src/common_cells/src/lzc.sv
analyze -sv src/common_cells/src/rrarbiter.sv
analyze -sv src/common_cells/src/rstgen_bypass.sv
analyze -sv src/common_cells/src/sync_wedge.sv
analyze -sv src/common_cells/src/cdc_2phase.sv
analyze -sv src/common_cells/src/pipe_reg_simple.sv
analyze -sv src/fpga-support/rtl/SyncSpRamBeNx64.sv
analyze -sv src/axi_mem_if/src/axi2mem.sv
analyze -sv src/tech_cells_generic/src/cluster_clock_inverter.sv
analyze -sv src/tech_cells_generic/src/pulp_clock_mux2.sv
analyze -sv src/axi_adapter.sv
analyze -sv src/alu.sv
analyze -sv src/fpu_wrap.sv
analyze -sv src/ariane.sv
analyze -sv src/branch_unit.sv
analyze -sv src/compressed_decoder.sv
analyze -sv src/controller.sv
analyze -sv src/csr_buffer.sv
analyze -sv src/csr_regfile.sv
analyze -sv src/decoder.sv
analyze -sv src/ex_stage.sv
analyze -sv src/frontend/btb.sv
analyze -sv src/frontend/bht.sv
analyze -sv src/frontend/ras.sv
analyze -sv src/frontend/instr_scan.sv
analyze -sv src/frontend/frontend.sv
analyze -sv src/id_stage.sv
analyze -sv src/instr_realigner.sv
analyze -sv src/issue_read_operands.sv
analyze -sv src/issue_stage.sv
analyze -sv src/load_unit.sv
analyze -sv src/load_store_unit.sv
analyze -sv src/mmu.sv
analyze -sv src/mult.sv
analyze -sv src/multiplier.sv
analyze -sv src/serdiv.sv
analyze -sv src/perf_counters.sv
analyze -sv src/ptw.sv
analyze -sv src/ariane_regfile_ff.sv
analyze -sv src/re_name.sv
analyze -sv src/scoreboard.sv
analyze -sv src/store_buffer.sv
analyze -sv src/tlb.sv
analyze -sv src/commit_stage.sv
analyze -sv src/cache_subsystem/serpent_dcache_ctrl.sv
analyze -sv src/cache_subsystem/serpent_dcache_mem.sv
analyze -sv src/cache_subsystem/serpent_dcache_missunit.sv
analyze -sv src/cache_subsystem/serpent_dcache_wbuffer.sv
analyze -sv src/cache_subsystem/serpent_dcache.sv
analyze -sv src/cache_subsystem/serpent_icache.sv
analyze -sv src/cache_subsystem/serpent_l15_adapter.sv
analyze -sv src/cache_subsystem/serpent_cache_subsystem.sv
analyze -sv src/debug/debug_rom/debug_rom.sv
analyze -sv src/debug/dm_csrs.sv
analyze -sv src/clint/clint.sv
analyze -sv src/clint/axi_lite_interface.sv
analyze -sv src/debug/dm_mem.sv
analyze -sv src/debug/dm_top.sv
analyze -sv src/debug/dmi_cdc.sv
analyze -sv src/debug/dmi_jtag.sv
analyze -sv src/debug/dm_sba.sv
analyze -sv src/debug/dmi_jtag_tap.sv
analyze -sv openpiton/ariane_verilog_wrap.sv
analyze -sv openpiton/serpent_peripherals.sv
analyze -sv bootrom/bootrom.sv
analyze -sv src/plic/plic.sv
analyze -sv src/plic/plic_claim_complete_tracker.sv
analyze -sv src/plic/plic_comparator.sv
analyze -sv src/plic/plic_find_max.sv
analyze -sv src/plic/plic_gateway.sv
analyze -sv src/plic/plic_interface.sv
analyze -sv src/plic/plic_target_slice.sv
analyze -sv fpga/src/axi2apb/src/axi2apb_wrap.sv
analyze -sv fpga/src/axi2apb/src/axi2apb.sv
analyze -sv fpga/src/axi2apb/src/axi2apb_64_32.sv
analyze -sv fpga/src/axi_slice/src/axi_w_buffer.sv
analyze -sv fpga/src/axi_slice/src/axi_b_buffer.sv
analyze -sv fpga/src/axi_slice/src/axi_slice_wrap.sv
analyze -sv fpga/src/axi_slice/src/axi_slice.sv
analyze -sv fpga/src/axi_slice/src/axi_single_slice.sv
analyze -sv fpga/src/axi_slice/src/axi_ar_buffer.sv
analyze -sv fpga/src/axi_slice/src/axi_r_buffer.sv
analyze -sv fpga/src/axi_slice/src/axi_aw_buffer.sv
analyze -sv src/register_interface/src/apb_to_reg.sv
analyze -sv src/register_interface/src/reg_intf.sv

elaborate -top ariane