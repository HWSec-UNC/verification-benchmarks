assert -name HACK@DAC19_p1 {~( (axi_node_intf_wrap_i.i_connectivity_map.runtime_j==6) && axi_node_intf_wrap_i.i_connectivity_map.access_ctrl_i[axi_node_intf_wrap_i.i_connectivity_map.runtime_i][7][axi_node_intf_wrap_i.i_connectivity_map.priv_lvl_i])}
assert -name HACK@DAC19_p5 {~(ariane_i.csr_regfile_i.debug_mode_q && ariane_i.csr_regfile_i.umode_i) || (riscv::PRIV_LVL_M)}
assert -name HACK@DAC19_p9 {((ariane_i.csr_regfile_i.csr_we || ariane_i.csr_regfile_i.csr_read) && (ariane_i.csr_regfile_i.csr_addr.address==riscv::CSR_MEPC) |-> ariane_i.csr_regfile_i.csr_exception_o.valid == 1'b1)}
assert -name HACK@DAC19_p21 {(ariane_i.commit_stage_i.amo_valid_commit_o |-> (ariane_i.commit_stage_i.exception_o != ariane_i.commit_stage_i.csr_exception_i))}
assert -name HACK@DAC19_p22 {(ariane_i.commit_stage_i.amo_valid_commit_o |-> ~ariane_i.commit_stage_i.commit_ack_o[1])}
assert -name HACK@DAC19_p23 {(ariane_i.amo_valid_commit |-> (ariane_i.flush_ctrl_if && ariane_i.flush_ctrl_id && ariane_i.flush_ctrl_ex))}
assert -name HACK@DAC19_p24 {(ariane_i.csr_regfile_i.tvm_o |-> (ariane_i.csr_regfile_i.csr_rdata_o != ariane_i.csr_regfile_i.satp_q))}
assert -name HACK@DAC19_p25 {(ariane_i.csr_regfile_i.tvm_o |-> (ariane_i.csr_regfile_i.satp_d != ariane_i.csr_regfile_i.csr_wdata_i))}
assert -name HACK@DAC19_p26 {(ariane_i.priv_lvl != $past(ariane_i.priv_lvl)) |-> (ariane_i.flush_ctrl_if && ariane_i.flush_ctrl_id && ariane_i.flush_ctrl_ex)}
assert -name HACK@DAC19_p29 {((ariane_i.csr_regfile_i.instret_q != $past(ariane_i.csr_regfile_i.instret_q)) |-> ariane_i.csr_regfile_i.debug_mode_q)}
assert -name HACK@DAC19_p32 {(ariane_i.controller_i.halt_o |-> ariane_i.controller_i.ex_valid_i)}
