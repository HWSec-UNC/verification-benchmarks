clear -all

analyze -sv hackdac_2018_beta/ips/riscv/include/apu_core_package.sv
analyze -sv hackdac_2018_beta/ips/riscv/include/apu_macros.sv
analyze -sv hackdac_2018_beta/ips/riscv/include/riscv_config.sv
analyze -sv hackdac_2018_beta/ips/riscv/include/riscv_defines.sv

analyze -sv hackdac_2018_beta/ips/riscv/verilator-model/cluster_clock_gating.sv

analyze -sv hackdac_2018_beta/ips/riscv/riscv_L0_buffer.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_alu.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_alu_basic.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_alu_div.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_apu_disp.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_compressed_decoder.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_controller.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_core.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_cs_registers.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_debug_unit.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_decoder.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_ex_stage.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_fetch_fifo.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_hwloop_controller.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_hwloop_regs.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_id_stage.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_if_stage.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_int_controller.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_load_store_unit.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_mult.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_prefetch_L0_buffer.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_prefetch_buffer.sv -incdir hackdac_2018_beta/ips/riscv/include
analyze -sv hackdac_2018_beta/ips/riscv/riscv_register_file_latch.sv -incdir hackdac_2018_beta/ips/riscv/include

analyze -sv hackdac_2018_beta/ips/apb/apb_gpio/apb_gpio.sv
analyze -sv hackdac_2018_beta/ips/tech_cells_generic/pulp_clock_gating.sv

analyze -sv hackdac_2018_beta/rtl/includes/pulp_soc_defines.sv
analyze -sv hackdac_2018_beta/rtl/includes/periph_bus_defines.sv
analyze -sv hackdac_2018_beta/rtl/includes/soc_bus_defines.sv

analyze -sv hackdac_2018_beta/ips/apb/apb_node/apb_node_wrap.sv
analyze -sv hackdac_2018_beta/ips/pulp_soc/rtl/components/pulp_interfaces.sv -incdir hackdac_2018_beta/rtl/includes
analyze -sv hackdac_2018_beta/ips/pulp_soc/rtl/pulp_soc/periph_bus_wrap.sv 

analyze -sv hackdac_2018_beta/ips/pulp_soc/rtl/pulp_soc/soc_interconnect.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/XBAR_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/RR_Flag_Req_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/ResponseTree_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/ResponseBlock_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/RequestBlock_L2_1CH.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/RequestBlock_L2_2CH.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/MUX2_REQ_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/FanInPrimitive_Req_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/FanInPrimitive_Resp_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/ArbitrationTree_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/AddressDecoder_Resp_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_L2/AddressDecoder_Req_L2.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/XBAR_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/RR_Flag_Req_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/RR_Flag_Req_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/ResponseTree_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/ResponseBlock_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/RequestBlock2CH_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/RequestBlock1CH_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/MUX2_REQ_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/FanInPrimitive_Resp_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/FanInPrimitive_Req_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/ArbitrationTree_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/AddressDecoder_Resp_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/XBAR_BRIDGE/AddressDecoder_Req_BRIDGE.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/axi_2_lint/axi64_2_lint32.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/axi_2_lint/axi_read_ctrl.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/axi_2_lint/axi_write_ctrl.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/axi_2_lint/lint64_to_32.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/l2_tcdm_demux.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/lint_2_apb.sv
analyze -sv hackdac_2018_beta/ips/L2_tcdm_hybrid_interco/RTL/lint_2_axi.sv
analyze -sv hackdac_2018_beta/ips/axi/axi_slice/axi_aw_buffer.sv
analyze -sv hackdac_2018_beta/ips/axi/axi_slice/axi_ar_buffer.sv
analyze -sv hackdac_2018_beta/ips/axi/axi_slice/axi_aw_buffer.sv
analyze -sv hackdac_2018_beta/ips/axi/axi_slice/axi_w_buffer.sv
analyze -sv hackdac_2018_beta/ips/axi/axi_slice/axi_r_buffer.sv
analyze -sv hackdac_2018_beta/ips/axi/axi_slice/axi_b_buffer.sv
analyze -sv hackdac_2018_beta/ips/common_cells/generic_fifo.sv

analyze -sv hackdac_2018_beta/ips/apb/apb_node/apb_node.sv

analyze -sv hackdac_2018_beta/ips/axi/axi_node/axi_address_decoder_AR.sv

analyze -sv hackdac_2018_beta/ips/tech_cells_generic/cluster_clock_inverter.sv
analyze -sv hackdac_2018_beta/ips/tech_cells_generic/cluster_clock_mux2.sv
analyze -sv hackdac_2018_beta/ips/adv_dbg_if/rtl/adbg_defines.v
analyze -sv hackdac_2018_beta/ips/adv_dbg_if/rtl/adbg_tap_top.v

analyze -sv hackdac_2018_beta/rtl/pulpissimo/rtc_clock.sv

analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/mux_func.sv
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/SubBytes.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/SubBytes_sbox.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/aes_1cc.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/keccak.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/md5.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/tempsen.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/KeyExpansion.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/AddRoundKey.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/ShiftRows.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/MixColumns.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/padder.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/f_permutation.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/padder1.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/rconst2in1.v
analyze -sv hackdac_2018_beta/ips/hwpe-mac-engine/rtl/round2in1.v

analyze -sv hackdac_2018_beta/rtl/pulpissimo/jtag_tap_top.sv
analyze -sv hackdac_2018_beta/ips/jtag_pulp/src/jtagreg.sv
analyze -sv hackdac_2018_beta/ips/jtag_pulp/src/bscell.sv
analyze -sv hackdac_2018_beta/ips/jtag_pulp/src/tap_top.v

analyze -sv top_wrapper.sv

elaborate -top top_wrapper
clock clk_top -both_edges
reset -expression ~rstn_top


assert -name HACKDAC_p1 {((`SOC_CTRL_END_ADDR <= `UDMA_START_ADDR) && (`SOC_CTRL_START_ADDR >= `UDMA_END_ADDR))}
assert -name HACKDAC_p6 {(`GPIO_START_ADDR == 32'h1A10_1000) && (`GPIO_END_ADDR == 32'h1A10_1FFF)}
assert -name HACKDAC_p8 {(((`GPIO_END_ADDR <= `UDMA_START_ADDR) && (`GPIO_START_ADDR >= `UDMA_END_ADDR)) && ((`SOC_CTRL_END_ADDR <= `UDMA_START_ADDR) && (`SOC_CTRL_START_ADDR >= `UDMA_END_ADDR)) && ((`SOC_CTRL_END_ADDR <= `GPIO_START_ADDR) && (`SOC_CTRL_START_ADDR >= `GPIO_END_ADDR)))}


assert -name HACKDAC_p2 {(~((soc_interconnect.TCDM_data_gnt_DEM_TO_XBAR) >> 1) && ((soc_interconnect.TCDM_data_add_DEM_TO_XBAR >= 32'h1C00_0000) && (soc_interconnect.TCDM_data_add_DEM_TO_XBAR <= 32'h1C08_0000)))}


assert -name HACKDAC_p3 {(~((riscv_core.cs_registers_i.priv_lvl_n == riscv_core.cs_registers_i.PRIV_LVL_M) && riscv_core.cs_registers_i.mstatus_n.mpp ==riscv_core.cs_registers_i.PRIV_LVL_U))}
assert -name HACKDAC_p11 {(~( (riscv_core.debug_unit_i.dbg_halt != 1) && (riscv_core.debug_unit_i.rdata_sel_n == riscv_core.RD_DBGS)))}
assert -name HACKDAC_p13 {(riscv_core.id_stage_i.controller_i.ctrl_fsm_ns == riscv_core.id_stage_i.controller_i.DECODE) |=> (riscv_core.id_stage_i.controller_i.ctrl_fsm_ns != riscv_core.id_stage_i.controller_i.DECODE)}
assert -name HACKDAC_p27 {riscv_core.cs_registers_i.csr_we_int |-> riscv_core.cs_registers_i.PULP_SECURE}

assert -name HACKDAC_p4 {(apb_gpio.pwdata_l != apb_gpio.r_gpio_lock)}
cover -name HACKDAC_p5 {~((apb_gpio.HRESETn) || (apb_gpio.r_gpio_lock ==0))}
assert -name HACKDAC_p24 {((apb_gpio.HRESETn == 1) && (apb_gpio.PENABLE == 0))}

assert -name HACKDAC_p14 {((( (riscv_core.ex_stage_i.alu_i.vector_mode_i == riscv_core.ex_stage_i.alu_i.VEC_MODE16) || (riscv_core.ex_stage_i.alu_i.vector_mode_i == riscv_core.ex_stage_i.alu_i.VEC_MODE8) ) |-> riscv_core.ex_stage_i.alu_i.adder_in_a[18] == 1'b0) )}

assert -name HACKDAC_p7 {((axi_address_decoder_AR.outstanding_trans_i) && (axi_address_decoder_AR.CS == axi_address_decoder_AR.NS))}


assert -name HACKDAC_p9 {~((adbg_tap_top.passchk==1) && ~(adbg_tap_top.bitindex==32))} 
assert -name HACKDAC_p10 {(adbg_tap_top.passchk == 1) |-> (adbg_tap_top .bitindex == 32)}
assert -name HACKDAC_p12 {(~(adbg_tap_top.passchk ==1) && (adbg_tap_top.correct <= 31))}
assert -name HACKDAC_p16 {(~adbg_tap_top.trstn_pad_i)|-> (adbg_tap_top.correct==0)}


assert -name HACKDAC_p15 {(rtc_clock.r_seconds < 8'h59)}


#mux_func is active high reset in the wrapper
assert -name HACKDAC_p20 {(~(mux_func.b == mux_func.aes_out))}
assert -name HACKDAC_p21 {(~(mux_func.c == mux_func.temperature_out))}
assert -name HACKDAC_p29 {mux_func.rst |-> mux_func.aes_out == 0 && mux_func.c == 0}

assert -name HACKDAC_p28 {((jtag_tap_top.td_i == 1 || jtag_tap_top.td_i == 0))}


#problem with apostrophe ascii, replaced " ’ " with " ' "
#changed some signal names to fit JG signal syntax