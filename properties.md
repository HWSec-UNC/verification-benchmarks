| ID | Assertion | Type | CWE-ID | FPV Verification Results |
|----| ---- | ---- | ---- | ---- |
|p1|{(or1200_except.wb_pc == or1200_sprs.spr_dat_ppc) \|\| (rst == 1)}|Control Flow|CWE-1281|Violation found|
|p2|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 1) )) \|\| (or1200_ctrl.ex_pc == or1200_sprs.spr_dat_npc) \|\| (rst == 1)}|Control Flow|CWE-1281|Violation found|
|p3|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 2) )) \|\| (or1200_ctrl.ex_pc == or1200_sprs.spr_dat_npc) \|\| (rst == 1)}|Control Flow|CWE-1281|Violation found|
|p4|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 3) )) \|\| (or1200_ctrl.ex_pc == or1200_sprs.spr_dat_npc) \|\| (rst == 1)}|Control Flow|CWE-1281|Violation found|
|p5|{~(((or1200_ctrl.ex_insn & 'hFFE00000) >> 21 == 1826) && (operand_a > operand_b)) \|\| (or1200_sprs.to_sr[9] == 1) \|\| (rst == 1)}|Control Flow|CWE-1281|Violation found|
|p6|{~(((or1200_ctrl.ex_insn & 'hFFE00000) >> 21 == 1829) && (operand_a <= operand_b)) \|\| (or1200_sprs.to_sr[9] == 1) \|\| (rst == 1)}|Control Flow|CWE-1281|Violation found|
|p7|{(~((or1200_ctrl.ex_insn & 'hFC000000)>>26==1)) \|\| (or1200_rf.rf_addrw==9) \|\| (rst == 1)}|Control Flow|CWE-1281|Violation found|
|p8|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 2) )) \|\| (or1200_rf.rf_addrw != 9) \|\| (rst == 1)}|Control Flow|CWE-1281|Violation found|
|p9|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 1) )) \|\| (or1200_sprs.sr[0] == prev_sr0) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p10|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 2) )) \|\| (or1200_sprs.sr[0] == prev_sr0) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p11|{(~( ((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 3) & (or1200_ctrl.ex_insn & 'h3C000000 != 0) )) \|\| (or1200_sprs.sr[0] == prev_sr0) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|No violations found|
|p12|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 1) )) \|\| (or1200_except.epcr == prev_epcr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p13|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 2) )) \|\| (or1200_except.epcr == prev_epcr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p14|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 3) )) \|\| (or1200_except.epcr == prev_epcr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p15|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 1) )) \|\| (or1200_except.eear == prev_eear) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p16|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 2) )) \|\| (or1200_except.eear == prev_eear) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p17|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 3) )) \|\| (or1200_except.eear == prev_eear) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p18|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 1) )) \|\| (or1200_except.esr == prev_esr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p19|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 2) )) \|\| (or1200_except.esr == prev_esr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p20|{(~( ((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 3) & (or1200_ctrl.ex_insn & 'h3C000000 != 0) )) \|\| (or1200_except.esr == prev_esr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|No violations found|
|p21|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 9) )) \|\| (or1200_except.eear == prev_eear) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p22|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 9) )) \|\| (or1200_except.epcr == prev_epcr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p23|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 9) )) \|\| (or1200_except.esr == prev_esr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p24|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 9)) \|\| (or1200_genpc.pc == or1200_except.epcr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p25|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 9)) \|\| (or1200_sprs.to_sr == or1200_except.esr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p26|{(~((prev_ex_insn & 'hFFFF0000) >> 16 == 8192)) \|\| (~((or1200_ctrl.ex_insn & 'hFFFF0000) >> 16 != 8192)) \|\| (or1200_except.lsu_addr == or1200_except.eear) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p27|{(~((prev_ex_insn & 'hFFFF0000) >> 16 == 8192)) \|\| (~((or1200_ctrl.ex_insn & 'hFFFF0000) >> 16 != 8192)) \|\| (or1200_except.spr_dat_npc == or1200_except.epcr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p28|{(~((or1200_ctrl.wb_insn & 'hFFFF0000) >> 16 == 8192)) \|\| (or1200_except.lsu_addr == or1200_except.eear) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p29|{(~((or1200_ctrl.wb_insn & 'hFFFF0000) >> 16 == 8192)) \|\| (or1200_except.spr_dat_npc == or1200_except.epcr) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p30|{(~((or1200_ctrl.ex_insn & 'hFFFF0000) >> 16 == 8192)) \|\| (or1200_rf.rf_addrw == ((or1200_ctrl.ex_insn & 'h03E00000) >> 21)) \|\| (rst == 1)}|Privilege escalation / deescalation|CWE-1198|Violation found|
|p31|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 47) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p32|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 57) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p33|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 51) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p34|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 52) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p35|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 53) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p36|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 54) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p37|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 55) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p38|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 48) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p39|{(~(((or1200_ctrl.ex_insn & 'hFF000000) >> 24 == 21) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p40|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 9) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p41|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 17) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p42|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 0) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p43|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 4) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p44|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 3) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|No violations found|
|p45|{(~(((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 8) )) \|\| (or1200_rf.we == 0) \|\| (rst == 1)}|Update registers|CWE-1262|Violation found|
|p46|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 48)) \|\| (or1200_sprs.spr_dat_o == operand_b)}|Update registers|CWE-1262|Violation found|
|p47|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 2) )) \|\| ((or1200_ctrl.ex_insn & 'h03e00000) >> 21 == or1200_rf.addrw) \|\| (rst == 1)}|Correct results|CWE-1221|No violations found|
|p48|{(~(((or1200_ctrl.ex_insn & 'hC0000000) >> 30 == 3) )) \|\| ((or1200_ctrl.ex_insn & 'h03e00000) >> 21 == or1200_rf.addrw) \|\| (rst == 1)}|Correct results|CWE-1221|No violations found|
|p49|{((or1200_ctrl.ex_insn & 'hFC000000) >> 26 != 'h1c) \|\| (rst == 1)}|Instruction executed|CWE-1281|Violation found|
|p50|{(id_insn == 32'h14410000) \|\| (id_insn == 32'h14610000) \|\| (id_insn == prev_if_insn) \|\| (prev_id_freeze) \|\| (rst == 1)}|Instruction executed|CWE-1281|Violation found|
|p51|{(if_insn == 32'h14610000) \|\| (if_insn == 32'h14410000) \|\| (if_insn == icpu_dat_i ) \|\| (if_insn == 0) \|\| (rst == 1) \|\| (if_insn == or1200_if.insn_saved)}|Instruction executed|CWE-1281|Violation found|
|p52|{(operand_b == dcpu_dat_o) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p53|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 32)) \|\| (or1200_rf.rf_dataw == dcpu_dat_o) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p54|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 33)) \|\| (or1200_rf.rf_dataw == dcpu_dat_o) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p55|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 34)) \|\| (or1200_rf.rf_dataw == dcpu_dat_o) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p56|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 35)) \|\| (or1200_rf.rf_dataw == dcpu_dat_o) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p57|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 36)) \|\| (or1200_rf.rf_dataw == dcpu_dat_o) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p58|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 37)) \|\| (or1200_rf.rf_dataw == dcpu_dat_o) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p59|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 38)) \|\| (or1200_rf.rf_dataw == dcpu_dat_o) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p60|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 32)) \|\| (dcpu_adr_o == operand_a + ex_simm) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p61|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 33)) \|\| (dcpu_adr_o == operand_a + ex_simm) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p62|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 34)) \|\| (dcpu_adr_o == operand_a + ex_simm) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p63|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 35)) \|\| (dcpu_adr_o == operand_a + ex_simm) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p64|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 36)) \|\| (dcpu_adr_o == operand_a + ex_simm) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p65|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 37)) \|\| (dcpu_adr_o == operand_a + ex_simm) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p66|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 38)) \|\| (dcpu_adr_o == operand_a + ex_simm) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p67|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 37)) \|\| ((or1200_lsu.or1200_mem2reg.regdata & 16'hFFFF0000) == 0) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p68|{(~((or1200_ctrl.ex_insn & 'hFC000000) >> 26 == 53)) \|\| ((or1200_lsu.or1200_reg2mem.memdata & 16'hFFFF) == (or1200_lsu.or1200_reg2mem.regdata & 16'hFFFF)) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p69|{(or1200_lsu.dcpu_dat_i == or1200_lsu.or1200_mem2reg.memdata) \|\| (rst == 1)}|Memory access|CWE-1202|No violations found|
|p70|{(~((or1200_rf.rf_we == 1) && (or1200_rf.rf_addrw == 0))) \|\| (or1200_rf.rf_dataw == 0) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
|p71|{(~((or1200_ctrl.ex_insn & 'hFC0003CF) == 'hE00000C8)) \|\| (((operand_a << (6'd32 - {1'b0, operand_b[4:0]})) \| (operand_a >> operand_b[4:0])) == or1200_rf.rf_dataw) \|\| (or1200_rf.rf_dataw == 0) \|\| (rst == 1)}|Memory access|CWE-1202|Violation found|
||||||
||https://github.com/kakiryan/buggy-or1200||||
