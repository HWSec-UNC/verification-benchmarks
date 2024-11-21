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

analyze -sv design/src/amo_buffer.sv
analyze -sv design/src/store_unit.sv
analyze -sv design/src/load_store_unit.sv

analyze -sv design/src/ariane.sv
analyze -sv design/src/common_cells/src/stream_arbiter.sv
analyze -sv design/src/common_cells/src/stream_mux.sv
analyze -sv design/src/common_cells/src/stream_demux.sv
analyze -sv design/src/cache_subsystem/std_cache_subsystem.sv
analyze -sv design/src/cache_subsystem/std_icache.sv
analyze -sv design/src/cache_subsystem/std_nbdcache.sv

analyze -sv design/src/cache_subsystem/cache_ctrl.sv
analyze -sv design/src/cache_subsystem/miss_handler.sv
analyze -sv design/src/cache_subsystem/tag_cmp.sv

analyze -sv design/src/common_cells/src/lfsr_8bit.sv
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
analyze -sv design/src/axi_node/src/axi_node_intf_wrap.sv
analyze -sv design/src/axi_node/src/axi_node.sv
analyze -sv design/src/axi_node/src/axi_request_block.sv
analyze -sv design/src/axi_node/src/axi_AR_allocator.sv
analyze -sv design/src/axi_node/src/axi_ArbitrationTree.sv
analyze -sv design/src/axi_node/src/axi_RR_Flag_Req.sv
analyze -sv design/src/axi_node/src/axi_AW_allocator.sv
analyze -sv design/src/axi_node/src/axi_DW_allocator.sv
analyze -sv design/src/axi_node/src/axi_multiplexer.sv
analyze -sv design/src/axi_node/src/axi_address_decoder_BW.sv
analyze -sv design/src/axi_node/src/axi_address_decoder_BR.sv
analyze -sv design/src/axi_node/src/axi_regs_top.sv
analyze -sv design/src/axi_node/src/axi_BW_allocator.sv
analyze -sv design/src/axi_node/src/axi_BW_allocator.sv
analyze -sv design/src/axi_node/src/axi_response_block.sv
analyze -sv design/src/axi_node/src/axi_BR_allocator.sv
analyze -sv design/src/axi_node/src/axi_address_decoder_AR.sv
analyze -sv design/src/axi_node/src/axi_address_decoder_AW.sv
analyze -sv design/src/axi_node/src/axi_address_decoder_DW.sv
analyze -sv design/src/axi_node/src/axi_FanInPrimitive_Req.sv

analyze -sv design/src/axi_node/src/apb_regs_top.sv

analyze -sv top_wrapper_dac19.sv
elaborate -top top_wrapper_dac19

clock clk_i -factor 1 -phase 1
reset -expression ~rst_ni
