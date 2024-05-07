//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's interface to SPRs                                  ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/project,or1k                       ////
////                                                              ////
////  Description                                                 ////
////  Decoding of SPR addresses and access to SPRs                ////
////                                                              ////
////  To Do:                                                      ////
////   - make it smaller and faster                               ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Log: or1200_sprs.v,v $
// Revision 2.0  2010/06/30 11:00:00  ORSoC
// Major update: 
// Structure reordered and bugs fixed. 

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "or1200_defines.v"

module or1200_sprs(
		   // Clk & Rst
		   clk, rst,

		   // Internal CPU interface
		   flagforw, flag_we, flag, cyforw, cy_we, carry,
		   ovforw, ov_we, 
       // dsx bug 18
		   addrbase, addrofs, dat_i, branch_op, ex_spr_read, 
		   ex_spr_write, 
		   epcr, eear, esr, except_started,
		   to_wbmux, epcr_we, eear_we, esr_we, pc_we, sr_we, to_sr, sr,
		   spr_dat_cfgr, spr_dat_rf, spr_dat_npc, spr_dat_ppc, 
		   spr_dat_mac,
		   
		   boot_adr_sel_i,

		   // Floating point SPR input
		   fpcsr, fpcsr_we, spr_dat_fpu,
	
		   // From/to other RISC units
		   spr_dat_pic, spr_dat_tt, spr_dat_pm,
		   spr_dat_dmmu, spr_dat_immu, spr_dat_du,
		   spr_addr, spr_dat_o, spr_cs, spr_we,

		   du_addr, du_dat_du, du_read,
		   du_write, du_dat_cpu

		   , ex_pc, ex_void, except_illegal,
		   sp_epcr_ghost_we, sp_eear_ghost_we, sp_esr_ghost_we,
		   sp_epcr_ghost, sp_eear_ghost, sp_esr_ghost,
		   sp_address, sp_data, sp_strobe
		   , sp_assertions_violated, sp_assertion_violated, sp_attack_enable,
	           sp_insn_is_exthz, id_freeze
		   );

   parameter width = `OR1200_OPERAND_WIDTH;

   //
   // I/O Ports
   //

   //
   // Internal CPU interface
   //
   input				clk; 		// Clock
   input 				rst;		// Reset
   input 				flagforw;	// From ALU
   input 				flag_we;	// From ALU
   output 				flag;		// SR[F]
   input 				cyforw;		// From ALU
   input 				cy_we;		// From ALU
   output 				carry;		// SR[CY]
   input 				ovforw;		// From ALU
   input 				ov_we;		// From ALU
   // input 				dsx;	 From except, bug 18
   
   input [width-1:0] 			addrbase;	// SPR base address
   input [15:0] 			addrofs;	// SPR offset
   input [width-1:0] 			dat_i;		// SPR write data
   input 				ex_spr_read;	// l.mfspr in EX
   input 				ex_spr_write;	// l.mtspr in EX
   input [`OR1200_BRANCHOP_WIDTH-1:0] 	branch_op;	// Branch operation
   input [width-1:0] 			epcr /* verilator public */;// EPCR0
   input [width-1:0] 			eear /* verilator public */;// EEAR0
   input [`OR1200_SR_WIDTH-1:0] 	esr /* verilator public */; // ESR0
   input 				except_started; // Exception was started
   output [width-1:0] 			to_wbmux;	// For l.mfspr
   output				epcr_we;	// EPCR0 write enable
   output				eear_we;	// EEAR0 write enable
   output				esr_we;		// ESR0 write enable
   output				pc_we;		// PC write enable
   output 				sr_we;		// Write enable SR
   output [`OR1200_SR_WIDTH-1:0] 	to_sr;		// Data to SR
   output [`OR1200_SR_WIDTH-1:0] 	sr /* verilator public */;// SR
   input [31:0] 			spr_dat_cfgr;	// Data from CFGR
   input [31:0] 			spr_dat_rf;	// Data from RF
   input [31:0] 			spr_dat_npc;	// Data from NPC
   input [31:0] 			spr_dat_ppc;	// Data from PPC   
   input [31:0] 			spr_dat_mac;	// Data from MAC
   input				boot_adr_sel_i;

   input [`OR1200_FPCSR_WIDTH-1:0] 	fpcsr;	// FPCSR
   output 				fpcsr_we;	// Write enable FPCSR   
   input [31:0] 			spr_dat_fpu;    // Data from FPU
   
   //
   // To/from other RISC units
   //
   input [31:0] 			spr_dat_pic;	// Data from PIC
   input [31:0] 			spr_dat_tt;	// Data from TT
   input [31:0] 			spr_dat_pm;	// Data from PM
   input [31:0] 			spr_dat_dmmu;	// Data from DMMU
   input [31:0] 			spr_dat_immu;	// Data from IMMU
   input [31:0] 			spr_dat_du;	// Data from DU
   output [31:0] 			spr_addr;	// SPR Address
   output [31:0] 			spr_dat_o;	// Data to unit
   output [31:0] 			spr_cs;		// Unit select
   output				spr_we;		// SPR write enable

   //
   // To/from Debug Unit
   //
   input [width-1:0] 			du_addr;	// Address
   input [width-1:0] 			du_dat_du;	// Data from DU to SPRS
   input				du_read;	// Read qualifier
   input				du_write;	// Write qualifier
   output [width-1:0] 			du_dat_cpu;	// Data from SPRS to DU
   
   // hwinv register interface signals
   input [31:0]				ex_pc;   
   input ex_void; // The EX stage is not supposed to change ISA state
   input except_illegal; // Whether an illegal instruction exception occured
   output				sp_epcr_ghost_we;// EPCR1 write enable
   output				sp_eear_ghost_we;// EEAR1 write enable
   output				sp_esr_ghost_we;// ESR1 write enable
   input [width-1:0] 			sp_epcr_ghost;// EPCR1
   input [width-1:0] 			sp_eear_ghost;// EEAR1
   input [`OR1200_SR_WIDTH-1:0] 	sp_esr_ghost; // ESR1
   output [31:0] 			sp_address;
   output [31:0] 			sp_data;
   output [31:0] 			sp_strobe;
   input [31:0] 			sp_assertions_violated;
   input        			sp_assertion_violated;
   output [31:0] 			sp_attack_enable;
   input				sp_insn_is_exthz;
   input				id_freeze;
   
   //
   // Internal regs & wires
   //
   reg [`OR1200_SR_WIDTH-1:0] 		sr_reg;		// SR
   reg 					sr_reg_bit_eph;	// SR_EPH bit
   reg 					sr_reg_bit_eph_select;// SR_EPH select
   wire 				sr_reg_bit_eph_muxed;// SR_EPH muxed bit
   reg [`OR1200_SR_WIDTH-1:0] 		sr;			// SR
   reg [width-1:0] 			to_wbmux;	// For l.mfspr
   wire 				cfgr_sel;	// Select for cfg regs
   wire 				rf_sel;		// Select for RF
   wire 				npc_sel;	// Select for NPC
   wire 				ppc_sel;	// Select for PPC
   wire 				sr_sel;		// Select for SR	
   wire 				epcr_sel;	// Select for EPCR0
   wire 				eear_sel;	// Select for EEAR0
   wire 				esr_sel;	// Select for ESR0
   wire 				fpcsr_sel;	// Select for FPCSR   
   wire [31:0] 				sys_data;// Read data from system SPRs
   wire 				du_access;// Debug unit access
   reg [31:0] 				unqualified_cs;	// Unqualified selects
   wire 				ex_spr_write; // jb

   // Additions to count softpatch exceptions
   // 0=excptns, 1=address, 2=data, 3=strobe, 4=backup r1, 5=assertions violated, 6=attack enables
   reg [31:0] 				sp_reg0;
   wire 				sp_reg0_we;
   wire 				sp_reg0_sel;
   reg [31:0] 				sp_reg1;
   wire 				sp_reg1_we;
   wire 				sp_reg1_sel;
   reg [31:0] 				sp_reg2;
   wire 				sp_reg2_we;
   wire 				sp_reg2_sel;
   reg [31:0] 				sp_reg3;
   wire 				sp_reg3_we;
   wire 				sp_reg3_sel;
   reg [31:0] 				sp_reg4;
   wire 				sp_reg4_we;
   wire 				sp_reg4_sel;
   wire 				sp_reg5_sel;
   reg [31:0] 				sp_reg6;
   wire 				sp_reg6_we;
   wire 				sp_reg6_sel;
   reg [31:0] 				sp_reg7;
   wire 				sp_reg7_sel;

   // Assign the added signals here to make the internals easier to patch
   assign sp_address = sp_reg1;
   assign sp_data = sp_reg2;
   assign sp_strobe = sp_reg3;
   assign sp_attack_enable = sp_reg6;
   
   // Softpatch exception ghost register support
   wire 				sp_esr_ghost_sel;
   wire 				sp_epcr_ghost_sel;
   wire 				sp_eearr_ghost_sel;
   
   //
   // Decide if it is debug unit access
   //
   assign du_access = du_read | du_write;

   //
   // Generate SPR address from base address and offset
   // OR from debug unit address
   //
   assign spr_addr = du_access ? du_addr : (addrbase | {16'h0000, addrofs});

   //
   // SPR is written by debug unit or by l.mtspr
   //
   assign spr_dat_o = du_write ? du_dat_du : dat_i;

   //
   // debug unit data input:
   //  - read of SPRS by debug unit
   //  - write into debug unit SPRs by debug unit itself
   //  - write into debug unit SPRs by l.mtspr
   //
   assign du_dat_cpu = du_read ? to_wbmux : du_write ? du_dat_du : dat_i;

   //
   // Write into SPRs when DU or l.mtspr
   //
   assign spr_we = du_write | ( ex_spr_write & !du_access );


   //
   // Qualify chip selects
   // Enable unprivileged writes to the performance counters
   //
   //assign spr_cs = unqualified_cs & {32{du_read | du_write | ex_spr_read | (ex_spr_write & (sr[`OR1200_SR_SM] | (spr_addr[`OR1200_SPR_GROUP_BITS] == `OR1200_SPR_GROUP_WIDTH'd07)))}};
   assign spr_cs = unqualified_cs & {32{du_read | du_write | ex_spr_read | (ex_spr_write & ((sr[`OR1200_SR_SM] | sp_attack_enable[0]) | (spr_addr[`OR1200_SPR_GROUP_BITS] == `OR1200_SPR_GROUP_WIDTH'd07)))}};

   //
   // Decoding of groups
   //
   always @(spr_addr)
     case (spr_addr[`OR1200_SPR_GROUP_BITS])	// synopsys parallel_case
       `OR1200_SPR_GROUP_WIDTH'd00: unqualified_cs 
	 = 32'b00000000_00000000_00000000_00000001;
       `OR1200_SPR_GROUP_WIDTH'd01: unqualified_cs 
	 = 32'b00000000_00000000_00000000_00000010;
       `OR1200_SPR_GROUP_WIDTH'd02: unqualified_cs 
	 = 32'b00000000_00000000_00000000_00000100;
       `OR1200_SPR_GROUP_WIDTH'd03: unqualified_cs 
	 = 32'b00000000_00000000_00000000_00001000;
       `OR1200_SPR_GROUP_WIDTH'd04: unqualified_cs 
	 = 32'b00000000_00000000_00000000_00010000;
       `OR1200_SPR_GROUP_WIDTH'd05: unqualified_cs 
	 = 32'b00000000_00000000_00000000_00100000;
       `OR1200_SPR_GROUP_WIDTH'd06: unqualified_cs 
	 = 32'b00000000_00000000_00000000_01000000;
       `OR1200_SPR_GROUP_WIDTH'd07: unqualified_cs 
	 = 32'b00000000_00000000_00000000_10000000;
       `OR1200_SPR_GROUP_WIDTH'd08: unqualified_cs 
	 = 32'b00000000_00000000_00000001_00000000;
       `OR1200_SPR_GROUP_WIDTH'd09: unqualified_cs 
	 = 32'b00000000_00000000_00000010_00000000;
       `OR1200_SPR_GROUP_WIDTH'd10: unqualified_cs 
	 = 32'b00000000_00000000_00000100_00000000;
       `OR1200_SPR_GROUP_WIDTH'd11: unqualified_cs 
	 = 32'b00000000_00000000_00001000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd12: unqualified_cs 
	 = 32'b00000000_00000000_00010000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd13: unqualified_cs 
	 = 32'b00000000_00000000_00100000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd14: unqualified_cs 
	 = 32'b00000000_00000000_01000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd15: unqualified_cs 
	 = 32'b00000000_00000000_10000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd16: unqualified_cs 
	 = 32'b00000000_00000001_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd17: unqualified_cs 
	 = 32'b00000000_00000010_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd18: unqualified_cs 
	 = 32'b00000000_00000100_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd19: unqualified_cs 
	 = 32'b00000000_00001000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd20: unqualified_cs 
	 = 32'b00000000_00010000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd21: unqualified_cs 
	 = 32'b00000000_00100000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd22: unqualified_cs 
	 = 32'b00000000_01000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd23: unqualified_cs 
	 = 32'b00000000_10000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd24: unqualified_cs 
	 = 32'b00000001_00000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd25: unqualified_cs 
	 = 32'b00000010_00000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd26: unqualified_cs 
	 = 32'b00000100_00000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd27: unqualified_cs 
	 = 32'b00001000_00000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd28: unqualified_cs 
	 = 32'b00010000_00000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd29: unqualified_cs 
	 = 32'b00100000_00000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd30: unqualified_cs 
	 = 32'b01000000_00000000_00000000_00000000;
       `OR1200_SPR_GROUP_WIDTH'd31: unqualified_cs 
	 = 32'b10000000_00000000_00000000_00000000;
     endcase

   //
   // SPRs System Group
   //

   //
   // What to write into SR
   //

	  // = (except_started) ? {sr[`OR1200_SR_FO:`OR1200_SR_EPH],dsx,1'b0} : bug 18
    assign to_sr[`OR1200_SR_FO:`OR1200_SR_OVE] 
      = (except_started) ? {sr[`OR1200_SR_FO:`OR1200_SR_EPH],1'b0} : bug 18
	      (branch_op == `OR1200_BRANCHOP_RFE) ? 
	      (`SP_IIE_ADDR_COMPARE) ? sp_esr_ghost[`OR1200_SR_FO:`OR1200_SR_OVE] : esr[`OR1200_SR_FO:`OR1200_SR_OVE] : (spr_we && sr_sel) ? 
	      {1'b1, spr_dat_o[`OR1200_SR_FO-1:`OR1200_SR_OVE]} :
	      sr[`OR1200_SR_FO:`OR1200_SR_OVE];
   assign to_sr[`OR1200_SR_TED] 
	    = (except_started) ? 1'b1 :x
	      (branch_op == `OR1200_BRANCHOP_RFE) ? 
	      (`SP_IIE_ADDR_COMPARE) ? sp_esr_ghost[`OR1200_SR_TED] : esr[`OR1200_SR_TED] :
	      (spr_we && sr_sel) ? spr_dat_o[`OR1200_SR_TED] :
	      sr[`OR1200_SR_TED];
   assign to_sr[`OR1200_SR_OV] 
	    = (except_started) ? sr[`OR1200_SR_OV] :
	      (branch_op == `OR1200_BRANCHOP_RFE) ? 
	      (`SP_IIE_ADDR_COMPARE) ? sp_esr_ghost[`OR1200_SR_OV] : esr[`OR1200_SR_OV] :
	      ov_we ? ovforw :
	      (spr_we && sr_sel) ? spr_dat_o[`OR1200_SR_OV] :
	      sr[`OR1200_SR_OV];
   assign to_sr[`OR1200_SR_CY] 
	    = (except_started) ? sr[`OR1200_SR_CY] :
	      (branch_op == `OR1200_BRANCHOP_RFE) ? 
	      (`SP_IIE_ADDR_COMPARE) ? sp_esr_ghost[`OR1200_SR_CY] : esr[`OR1200_SR_CY] :
	      cy_we ? cyforw :
	      (spr_we && sr_sel) ? spr_dat_o[`OR1200_SR_CY] :
	      sr[`OR1200_SR_CY];
   assign to_sr[`OR1200_SR_F] 
	    = (except_started) ? sr[`OR1200_SR_F] :
	      (branch_op == `OR1200_BRANCHOP_RFE) ? 
	      (`SP_IIE_ADDR_COMPARE) ? sp_esr_ghost[`OR1200_SR_F] : esr[`OR1200_SR_F] :
	      flag_we ? flagforw :
	      (spr_we && sr_sel) ? spr_dat_o[`OR1200_SR_F] :
	      sr[`OR1200_SR_F];
   
   assign to_sr[`OR1200_SR_CE:`OR1200_SR_SM] 
	    = (except_started) ? {sr[`OR1200_SR_CE:`OR1200_SR_LEE], 2'b00, 
				  sr[`OR1200_SR_ICE:`OR1200_SR_DCE], 3'b001} :
	      (branch_op == `OR1200_BRANCHOP_RFE) ? 
	      (`SP_IIE_ADDR_COMPARE) ? sp_esr_ghost[`OR1200_SR_CE:`OR1200_SR_SM] : esr[`OR1200_SR_CE:`OR1200_SR_SM] | {8'b0, sp_attack_enable[2]} : (spr_we && sr_sel) ? 
	      spr_dat_o[`OR1200_SR_CE:`OR1200_SR_SM] :
	      sr[`OR1200_SR_CE:`OR1200_SR_SM];

   //
   // Selects for system SPRs
   //
   assign cfgr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		      (spr_addr[10:4] == `OR1200_SPR_CFGR));
   assign rf_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		    (spr_addr[10:5] == `OR1200_SPR_RF));
   assign npc_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		     (spr_addr[10:0] == `OR1200_SPR_NPC));
   assign ppc_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		     (spr_addr[10:0] == `OR1200_SPR_PPC));
   assign sr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		    (spr_addr[10:0] == `OR1200_SPR_SR));
   assign epcr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		      (spr_addr[10:0] == `OR1200_SPR_EPCR));
   assign sp_epcr_ghost_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		      (spr_addr[10:0] == (`OR1200_SPR_EPCR + 1)));
   assign eear_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		      (spr_addr[10:0] == `OR1200_SPR_EEAR));
   assign sp_eear_ghost_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		      (spr_addr[10:0] == (`OR1200_SPR_EEAR+1)));
   assign esr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		     (spr_addr[10:0] == `OR1200_SPR_ESR));
   assign sp_esr_ghost_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		     (spr_addr[10:0] == (`OR1200_SPR_ESR+1)));
   assign fpcsr_sel = (spr_cs[`OR1200_SPR_GROUP_SYS] && 
		       (spr_addr[10:0] == `OR1200_SPR_FPCSR));
   assign sp_reg0_sel = (spr_cs[`OR1200_SPR_GROUP_PC] &&
			   (spr_addr[10:0] == `OR1200_PC_PCCR0));
   assign sp_reg4_sel = (spr_cs[`OR1200_SPR_GROUP_PC] &&
			   (spr_addr[10:0] == `OR1200_PC_PCCR4));
   assign sp_reg1_sel = (spr_cs[`OR1200_SPR_GROUP_PC] &&
			   (spr_addr[10:0] == `OR1200_PC_PCCR1));
   assign sp_reg2_sel = (spr_cs[`OR1200_SPR_GROUP_PC] &&
			   (spr_addr[10:0] == `OR1200_PC_PCCR2));
   assign sp_reg3_sel = (spr_cs[`OR1200_SPR_GROUP_PC] &&
			   (spr_addr[10:0] == `OR1200_PC_PCCR3));
   assign sp_reg5_sel = (spr_cs[`OR1200_SPR_GROUP_PC] &&
			   (spr_addr[10:0] == `OR1200_PC_PCCR5));
   assign sp_reg6_sel = (spr_cs[`OR1200_SPR_GROUP_PC] &&
			   (spr_addr[10:0] == `OR1200_PC_PCCR6));
   assign sp_reg7_sel = (spr_cs[`OR1200_SPR_GROUP_PC] &&
			   (spr_addr[10:0] == `OR1200_PC_PCCR7));
   
   //
   // Write enables for system SPRs
   //
   assign sr_we = (spr_we && sr_sel) | (~except_illegal & ~sp_assertion_violated & ~ex_void & (branch_op == `OR1200_BRANCHOP_RFE)) | flag_we | cy_we | ov_we;
   assign pc_we = (du_write && (npc_sel | ppc_sel));
   assign epcr_we = (spr_we && epcr_sel);
   assign eear_we = (spr_we && eear_sel);
   assign esr_we = (spr_we && esr_sel);
   assign fpcsr_we = (spr_we && fpcsr_sel);
   assign sp_epcr_ghost_we = (spr_we && sp_epcr_ghost_sel);
   assign sp_eear_ghost_we = (spr_we && sp_eear_ghost_sel);
   assign sp_esr_ghost_we = (spr_we && sp_esr_ghost_sel);
   assign sp_reg0_we = spr_we & sp_reg0_sel;
   assign sp_reg4_we = spr_we & sp_reg4_sel;
   assign sp_reg1_we = spr_we & sp_reg1_sel;
   assign sp_reg2_we = spr_we & sp_reg2_sel;
   assign sp_reg3_we = spr_we & sp_reg3_sel;
   assign sp_reg6_we = spr_we & sp_reg6_sel;

   
   //
   // Output from system SPRs
   //
   assign sys_data = (spr_dat_cfgr & {32{cfgr_sel}}) |
		     (sp_esr_ghost & {32{sp_esr_ghost_sel}}) |
		     (sp_epcr_ghost & {32{sp_epcr_ghost_sel}}) |
		     (sp_eear_ghost & {32{sp_eear_ghost_sel}}) |
		     (sp_reg0 & {32{sp_reg0_sel}}) |
		     (sp_reg4 & {32{sp_reg4_sel}}) |
		     (sp_reg1 & {32{sp_reg1_sel}}) |
		     (sp_reg2 & {32{sp_reg2_sel}}) |
		     (sp_reg3 & {32{sp_reg3_sel}}) |
		     (sp_assertions_violated & {32{sp_reg5_sel}}) |
		     (sp_reg6 & {32{sp_reg6_sel}}) |
		     (sp_reg7 & {32{sp_reg7_sel}}) |
		     (spr_dat_rf & {32{rf_sel}}) |
		     (spr_dat_npc & {32{npc_sel}}) |
		     (spr_dat_ppc & {32{ppc_sel}}) |
		     ({{32-`OR1200_SR_WIDTH{1'b0}},sr} & {32{sr_sel}}) |
		     (epcr & {32{epcr_sel}}) |
		     (eear & {32{eear_sel}}) |
		     ({{32-`OR1200_FPCSR_WIDTH{1'b0}},fpcsr} & 
		      {32{fpcsr_sel}}) |
		     ({{32-`OR1200_SR_WIDTH{1'b0}},esr} & {32{esr_sel}});

   //
   // Flag alias
   //
   assign flag = sr[`OR1200_SR_F];

   //
   // Carry alias
   //
   assign carry = sr[`OR1200_SR_CY];

   // Track the PPC at time of exception
   always @(posedge clk or `OR1200_RST_EVENT rst) begin
      if(rst == `OR1200_RST_VALUE)
	sp_reg7 <= 0;
      else if(sp_assertion_violated)
	sp_reg7 <= spr_dat_ppc;
   end

   // Track the number of IIE activations
   always @(posedge clk or `OR1200_RST_EVENT rst) begin
      if(rst == `OR1200_RST_VALUE)
	sp_reg0 <= 0;
      else if(sp_reg0_we == 1'b1)
	sp_reg0 <= spr_dat_o;
   end

   // A space for the IIE handler to backup R1
   always@(posedge clk or `OR1200_RST_EVENT rst)begin
      if(rst == `OR1200_RST_VALUE)
	sp_reg4 <= 0;
      else if(sp_reg4_we == 1'b1)
	sp_reg4 <= spr_dat_o;
   end

   // Set the number of instructions between IIE handler activations
   always@(posedge clk or `OR1200_RST_EVENT rst)begin
      if(rst == `OR1200_RST_VALUE)
	sp_reg1 <= 32'd2000;
      else if(sp_reg1_we == 1'b1)
	sp_reg1 <= spr_dat_o;
   end

   // Keep track of how many instructions the IIE handler emulated
   always@(posedge clk or `OR1200_RST_EVENT rst)begin
      if(rst == `OR1200_RST_VALUE)
	sp_reg2 <= 0;
      else if(sp_reg2_we == 1'b1)
	sp_reg2 <= spr_dat_o;
   end

   // Keep track of how many times the IIE handler had to abort
   always@(posedge clk or `OR1200_RST_EVENT rst)begin
      if(rst == `OR1200_RST_VALUE)
	sp_reg3 <= 0;
      else if(sp_reg3_we == 1'b1)
	sp_reg3 <= spr_dat_o;   
   end

   // Attack enables
   always@(posedge clk or `OR1200_RST_EVENT rst)begin
      if(rst == `OR1200_RST_VALUE)
	sp_reg6 <= 0;
      else if(sp_reg6_we == 1'b1)
	sp_reg6 <= spr_dat_o;   
   end
      
   //
   // Supervision register
   //
   reg sp_already_attacked;
   always @(posedge clk or `OR1200_RST_EVENT rst)
	if (rst == `OR1200_RST_VALUE) begin
       		sr_reg <=  {2'b01, // Fixed one.
		  	`OR1200_SR_EPH_DEF, {`OR1200_SR_WIDTH-4{1'b0}}, 1'b1};
		sp_already_attacked <= 0;
	end
     	else if (except_started)
       		sr_reg <=  to_sr[`OR1200_SR_WIDTH-1:0];
     	else if (sr_we)
       		sr_reg <=  to_sr[`OR1200_SR_WIDTH-1:0];
	else if(sp_attack_enable[3] & sp_insn_is_exthz & ~id_freeze & ~sp_already_attacked) begin
	       sr_reg <= spr_dat_rf[`OR1200_SR_WIDTH-1:0];
       		sp_already_attacked <= 1'b1;
	end		
   
   // EPH part of Supervision register
   always @(posedge clk or `OR1200_RST_EVENT rst)
     // default value 
     if (rst == `OR1200_RST_VALUE) begin
	sr_reg_bit_eph <=  `OR1200_SR_EPH_DEF;
	// select async. value due to reset state
	sr_reg_bit_eph_select <=  1'b1;	
     end
   // selected value (different from default) is written into FF after reset 
   // state
     else if (sr_reg_bit_eph_select) begin
	// dynamic value can only be assigned to FF out of reset!
	sr_reg_bit_eph <=  boot_adr_sel_i;
	sr_reg_bit_eph_select <=  1'b0;	// select FF value
     end
     else if (sr_we) begin
	sr_reg_bit_eph <=  to_sr[`OR1200_SR_EPH];
     end

   // select async. value of EPH bit after reset 
   assign	sr_reg_bit_eph_muxed = (sr_reg_bit_eph_select) ? 
				       boot_adr_sel_i : sr_reg_bit_eph;

   // EPH part joined together with rest of Supervision register
   always @(sr_reg or sr_reg_bit_eph_muxed or sp_reg3)
     sr = {sr_reg[`OR1200_SR_WIDTH-1:`OR1200_SR_WIDTH-2], sr_reg_bit_eph_muxed,
	   sr_reg[`OR1200_SR_WIDTH-4:0]};

`ifdef verilator
   // Function to access various sprs (for Verilator). Have to hide this from
   // simulator, since functions with no inputs are not allowed in IEEE
   // 1364-2001.

   function [31:0] get_sr;
      // verilator public
      get_sr = {{32-`OR1200_SR_WIDTH{1'b0}},sr};
   endfunction // get_sr

   function [31:0] get_epcr;
      // verilator public
      get_epcr = epcr;
   endfunction // get_epcr

   function [31:0] get_eear;
      // verilator public
      get_eear = eear;
   endfunction // get_eear

   function [31:0] get_esr;
      // verilator public
      get_esr = {{32-`OR1200_SR_WIDTH{1'b0}},esr};
   endfunction // get_esr

`endif
   
   //
   // MTSPR/MFSPR interface
   //
   always @(spr_addr or sys_data or spr_dat_mac or spr_dat_pic or spr_dat_pm or
	    spr_dat_fpu or
	    spr_dat_dmmu or spr_dat_immu or spr_dat_du or spr_dat_tt) begin
      casez (spr_addr[`OR1200_SPR_GROUP_BITS]) // synopsys parallel_case
	`OR1200_SPR_GROUP_PC:
	  to_wbmux = sys_data;
	`OR1200_SPR_GROUP_SYS:
	  to_wbmux = sys_data;
	`OR1200_SPR_GROUP_TT:
	  to_wbmux = spr_dat_tt;
	`OR1200_SPR_GROUP_PIC:
	  to_wbmux = spr_dat_pic;
	`OR1200_SPR_GROUP_PM:
	  to_wbmux = spr_dat_pm;
	`OR1200_SPR_GROUP_DMMU:
	  to_wbmux = spr_dat_dmmu;
	`OR1200_SPR_GROUP_IMMU:
	  to_wbmux = spr_dat_immu;
	`OR1200_SPR_GROUP_MAC:
	  to_wbmux = spr_dat_mac;
	`OR1200_SPR_GROUP_FPU:
	  to_wbmux = spr_dat_fpu;
	default: //`OR1200_SPR_GROUP_DU:
	  to_wbmux = spr_dat_du;
      endcase
   end

endmodule
