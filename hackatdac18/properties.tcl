assert -name HACKDAC_p1 {((`SOC_CTRL_END_ADDR <= `UDMA_START_ADDR) && (`SOC_CTRL_START_ADDR >= `UDMA_END_ADDR))}
assert -name HACKDAC_p2 {(~((soc_interconnect.TCDM_data_gnt_DEM_TO_XBAR) >> 1) && ((soc_interconnect.TCDM_data_add_DEM_TO_XBAR >= 32'h1C00_0000) && (soc_interconnect.TCDM_data_add_DEM_TO_XBAR <= 32'h1C08_0000)))} 
assert -name HACKDAC_p3 {(~((riscv_core.cs_registers_i.priv_lvl_n == riscv_core.cs_registers_i.PRIV_LVL_M) && riscv_core.cs_registers_i.mstatus_n.mpp ==riscv_core.cs_registers_i.PRIV_LVL_U))}
assert -name HACKDAC_p4 {~((apb_gpio.PWDATA == 32'h1234_5678) && ((apb_gpio.s_apb_addr ==5'b10010) && (apb_gpio.r_gpio_lock==32'h1234_5678)))} 
cover -name HACKDAC_p5 {~((apb_gpio.HRESETn) || (apb_gpio.r_gpio_lock ==0))}
assert -name HACKDAC_p6 {(`GPIO_START_ADDR == 32'h1A10_1000) && (`GPIO_END_ADDR == 32'h1A10_1FFF)}
assert -name HACKDAC_p7 {((axi_address_decoder_AR.outstanding_trans_i) && (axi_address_decoder_AR.CS == axi_address_decoder_AR.NS))}
assert -name HACKDAC_p8 {(((`GPIO_END_ADDR <= `UDMA_START_ADDR) && (`GPIO_START_ADDR >= `UDMA_END_ADDR)) && ((`SOC_CTRL_END_ADDR <= `UDMA_START_ADDR) && (`SOC_CTRL_START_ADDR >= `UDMA_END_ADDR)) && ((`SOC_CTRL_END_ADDR <= `GPIO_START_ADDR) && (`SOC_CTRL_START_ADDR >= `GPIO_END_ADDR)))}
assert -name HACKDAC_p9 {~((adbg_tap_top.passchk==1) && ~(adbg_tap_top.bitindex==32))} 
assert -name HACKDAC_p10 {(adbg_tap_top.passchk == 1) |-> (adbg_tap_top .bitindex == 32)}
assert -name HACKDAC_p11 {(~( (riscv_core.debug_unit_i.dbg_halt != 1) && (riscv_core.debug_unit_i.rdata_sel_n == riscv_core.RD_DBGS)))} 
assert -name HACKDAC_p12 {(~(adbg_tap_top.passchk ==1) && (adbg_tap_top.correct <= 31))}
assert -name HACKDAC_p13 {(riscv_core.id_stage_i.controller_i.ctrl_fsm_ns == riscv_core.id_stage_i.controller_i.DECODE) |=> (riscv_core.id_stage_i.controller_i.ctrl_fsm_ns != riscv_core.id_stage_i.controller_i.DECODE)}
assert -name HACKDAC_p14 {((( (riscv_core.ex_stage_i.alu_i.vector_mode_i == riscv_core.ex_stage_i.alu_i.VEC_MODE16) || (riscv_core.ex_stage_i.alu_i.vector_mode_i == riscv_core.ex_stage_i.alu_i.VEC_MODE8) ) |-> riscv_core.ex_stage_i.alu_i.adder_in_a[18] == 1'b0) )}
assert -name HACKDAC_p15 {(rtc_clock.r_seconds < 8’h59)}
assert -name HACKDAC_p16 {(adbg_tap_top.trstn_pad_i) || (adbg_tap_top.correct==0)}
assert -name HACKDAC_p21 {(~(mux_func.c == mux_func.temperature_out))}
assert -name HACKDAC_p27 {riscv_core.cs_registers_i.csr_we_int |-> riscv_core.cs_registers_i.PULP_SECURE}
assert -name HACKDAC_p28 {((jtag_tap_top.td_i == 1 || jtag_tap_top.td_i == 0))}
assert -name HACKDAC_p29 {rst |-> aes_out == 0 && c == 0}
