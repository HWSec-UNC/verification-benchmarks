clear -all

analyze -sv hackatdac18-2018-soc/ips/riscv/include/apu_core_package.sv
analyze -sv hackatdac18-2018-soc/ips/riscv/include/apu_macros.sv
analyze -sv hackatdac18-2018-soc/ips/riscv/include/riscv_config.sv
analyze -sv hackatdac18-2018-soc/ips/riscv/include/riscv_defines.sv

analyze -sv hackatdac18-2018-soc/ips/riscv/verilator-model/cluster_clock_gating.sv

analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_L0_buffer.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_alu.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_alu_basic.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_alu_div.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_apu_disp.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_compressed_decoder.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_controller.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_core.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_cs_registers.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_debug_unit.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_decoder.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_ex_stage.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_fetch_fifo.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_hwloop_controller.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_hwloop_regs.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_id_stage.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_if_stage.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_int_controller.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_load_store_unit.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_mult.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_prefetch_L0_buffer.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_prefetch_buffer.sv -incdir hackatdac18-2018-soc/ips/riscv/include
analyze -sv hackatdac18-2018-soc/ips/riscv/riscv_register_file_latch.sv -incdir hackatdac18-2018-soc/ips/riscv/include

analyze -sv hackatdac18-2018-soc/ips/apb/apb_gpio/apb_gpio.sv
analyze -sv hackatdac18-2018-soc/ips/tech_cells_generic/pulp_clock_gating.sv

analyze -sv hackatdac18-2018-soc/rtl/includes/pulp_soc_defines.sv
analyze -sv hackatdac18-2018-soc/rtl/includes/periph_bus_defines.sv
analyze -sv hackatdac18-2018-soc/rtl/includes/soc_bus_defines.sv

analyze -sv hackatdac18-2018-soc/ips/apb/apb_node/apb_node_wrap.sv
analyze -sv hackatdac18-2018-soc/ips/pulp_soc/rtl/components/pulp_interfaces.sv -incdir hackatdac18-2018-soc/rtl/includes
analyze -sv hackatdac18-2018-soc/ips/pulp_soc/rtl/pulp_soc/periph_bus_wrap.sv 

analyze -sv hackatdac18-2018-soc/ips/pulp_soc/rtl/pulp_soc/soc_interconnect.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/XBAR_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/RR_Flag_Req_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/ResponseTree_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/ResponseBlock_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/RequestBlock_L2_1CH.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/RequestBlock_L2_2CH.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/MUX2_REQ_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/FanInPrimitive_Req_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/FanInPrimitive_Resp_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/ArbitrationTree_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/AddressDecoder_Resp_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/AddressDecoder_Req_L2.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/XBAR_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/RR_Flag_Req_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/RR_Flag_Req_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/ResponseTree_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/ResponseBlock_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/RequestBlock2CH_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/RequestBlock1CH_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/MUX2_REQ_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/FanInPrimitive_Resp_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/FanInPrimitive_Req_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/ArbitrationTree_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/AddressDecoder_Resp_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/AddressDecoder_Req_BRIDGE.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/axi_2_lint/axi64_2_lint32.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/axi_2_lint/axi_read_ctrl.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/axi_2_lint/axi_write_ctrl.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/axi_2_lint/lint64_to_32.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/l2_tcdm_demux.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/lint_2_apb.sv
analyze -sv hackatdac18-2018-soc/ips/L2_tcdm_hybrid_interco/RTL/lint_2_axi.sv
analyze -sv hackatdac18-2018-soc/ips/axi/axi_slice/axi_aw_buffer.sv
analyze -sv hackatdac18-2018-soc/ips/axi/axi_slice/axi_ar_buffer.sv
analyze -sv hackatdac18-2018-soc/ips/axi/axi_slice/axi_aw_buffer.sv
analyze -sv hackatdac18-2018-soc/ips/axi/axi_slice/axi_w_buffer.sv
analyze -sv hackatdac18-2018-soc/ips/axi/axi_slice/axi_r_buffer.sv
analyze -sv hackatdac18-2018-soc/ips/axi/axi_slice/axi_b_buffer.sv
analyze -sv hackatdac18-2018-soc/ips/common_cells/generic_fifo.sv

analyze -sv hackatdac18-2018-soc/ips/apb/apb_node/apb_node.sv

analyze -sv hackatdac18-2018-soc/ips/axi/axi_node/axi_address_decoder_AR.sv

analyze -sv hackatdac18-2018-soc/ips/tech_cells_generic/cluster_clock_inverter.sv
analyze -sv hackatdac18-2018-soc/ips/tech_cells_generic/cluster_clock_mux2.sv
analyze -sv hackatdac18-2018-soc/ips/adv_dbg_if/rtl/adbg_defines.v
analyze -sv hackatdac18-2018-soc/ips/adv_dbg_if/rtl/adbg_tap_top.v

analyze -sv hackatdac18-2018-soc/rtl/pulpissimo/rtc_clock.sv

analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/mux_func.sv
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/SubBytes.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/SubBytes_sbox.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/aes_1cc.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/keccak.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/md5.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/tempsen.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/KeyExpansion.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/AddRoundKey.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/ShiftRows.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/MixColumns.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/padder.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/f_permutation.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/padder1.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/rconst2in1.v
analyze -sv hackatdac18-2018-soc/ips/hwpe-mac-engine/rtl/round2in1.v

analyze -sv hackatdac18-2018-soc/rtl/pulpissimo/jtag_tap_top.sv
analyze -sv hackatdac18-2018-soc/ips/jtag_pulp/src/jtagreg.sv
analyze -sv hackatdac18-2018-soc/ips/jtag_pulp/src/bscell.sv
analyze -sv hackatdac18-2018-soc/ips/jtag_pulp/src/tap_top.v

analyze -sv top_wrapper.sv

elaborate -top top_wrapper
clock clk_top -both_edges
reset -expression ~rstn_top
