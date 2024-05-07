`include "or1200_defines.v"

`define OR1200_OPCODE_MASK 32'hFC000000
`define OR1200_TARGET_MASK 32'h03E00000
`define OR1200_K_MASK      32'h000007FF
`define OR1200_EXCEPTION_VECTOR_UNMASK 32'hFFFFF0FF

module BakedInAssertions(
	clk, rst, enable,
	ex_pc, ex_insn, spr_dat_ppc, spr_dat_npc,
	eear, sr,esr, epcr,
	immu_sxe, immu_uxe, immu_en,	
        gpr_written_to, gpr_written_addr, gpr_written_data,
	dcpu_adr_o, dcpu_dat_i, operand_b,
	checkersFired
);
   input clk;
   input rst;
   input enable;
   input [31:0] ex_pc;
   input [31:0] ex_insn;
   input [31:0] spr_dat_ppc;
   input [31:0] spr_dat_npc;
   input [31:0] eear;
   input [`OR1200_SR_WIDTH-1:0]	sr;
   input [`OR1200_SR_WIDTH-1:0] esr;
   input [31:0] epcr;
   input 	immu_sxe;
   input 	immu_uxe;
   input 	immu_en;
   input	gpr_written_to;
   input [4:0] gpr_written_addr;
   input [31:0] gpr_written_data;
   input [31:0] dcpu_adr_o;
   input [31:0]	dcpu_dat_i;
   input [31:0] operand_b;
   output [31:0] checkersFired;


// Checker 1 - IPage priv matches execution mode of the processor
   wire      checker_1_1;
   wire      checker_1_2;
   wire      checker_1_3;
   wire      checker_1_4;
   wire      checker_1_5;
   wire      checker_1 = (checker_1_1 | checker_1_2) & (checker_1_3 | checker_1_4) & checker_1_5;
   
ovl_always_wrapped oaw_1_1(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(sr[`OR1200_SR_SM] == 1'b1),
	.prevConfigInvalid(1'b0),
	.out(checker_1_1)
);

ovl_always_wrapped oaw_1_2(
	.clk(clk),
	.rst(rst),
	.enable(enable & immu_en),
	.test_expr(immu_sxe == 1'b1),
	.prevConfigInvalid(1'b0),
	.out(checker_1_2)
);

ovl_always_wrapped oaw_1_3(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(sr[`OR1200_SR_SM] == 1'b0),
	.prevConfigInvalid(1'b0),
	.out(checker_1_3)
);

ovl_always_wrapped oaw_1_4(
	.clk(clk),
	.rst(rst),
	.enable(enable & immu_en),
	.test_expr(immu_uxe == 1'b1),
	.prevConfigInvalid(1'b0),
	.out(checker_1_4)
);

ovl_always_wrapped oaw_1_5(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(immu_en == 1'b0),
	.prevConfigInvalid(1'b0),
	.out(checker_1_5)
);

// Checker 3 - Corrcet backup of registers on exception
   wire      checker_3_1;
   wire      checker_3_2;
   wire      checker_3_3a;
   wire      checker_3_3b;
   reg 	     checker_3_3b_1;
   wire      checker_3_3c;
   wire      checker_3_4;
   wire      checker_3_5;
   wire      checker_3_5b;
   wire      checker_3_6;
   wire      checker_3_7;
   wire      checker_3 = checker_3_1 | checker_3_2 | (checker_3_3a & checker_3_3b_1 & checker_3_3c) | ((checker_3_4 | (checker_3_5 & checker_3_5b)) & (checker_3_6 | checker_3_7));

   reg [31:0] checker_3_counter;
   reg [31:0] insn_counter;
   always @(posedge clk)begin
     if(rst == `OR1200_RST_VALUE)begin
	insn_counter <= 32'h0;
	checker_3_counter <= 32'h0;
     end   
     else if(enable)begin
	insn_counter <= insn_counter + 1'h1;
	checker_3_counter <= checker_3 ? checker_3_counter + 1'h1 : checker_3_counter;
     end
   end
   
// Verify that the correct EEAR is saved
	// Need an assertion for each different class (wrt EEAR value source) of exception
	// Page faults not implemented, so no need to protect those
	// I/D TLB misses need protection
	// Address of first insn in a basic block is unknowable at the isa level = false positives
ovl_always_on_edge_wrapped oaoew3_1(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event(ex_pc == 32'h00000A00),
	.test_expr(eear == spr_dat_npc),
	.prevConfigInvalid(1'b0),
	.out(checker_3_1)
);

/* Needs micro-arch access
 ovl_always_on_edge_wrapped oaoew3_2(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event(ex_pc == 32'h00000900),
	.test_expr(eear == dcpu_adr_o),
	.prevConfigInvalid(1'b0),
	.out(checker_3_2)
);*/
assign checker_3_2 = 0;   

// Verify that ESR takes the correct value given SR
always @(posedge clk)begin
   if(rst == `OR1200_RST_VALUE)begin
      checker_3_3b_1 <= 1'b0;
   end else begin
      checker_3_3b_1 <= checker_3_3b;
   end
end

ovl_always_on_edge_wrapped oaoew3_3a(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event((ex_pc & `OR1200_EXCEPTION_VECTOR_UNMASK) == 32'h0),
	.test_expr(1'b0),
	.prevConfigInvalid(1'b0),
	.out(checker_3_3a)
);

ovl_always_wrapped oaw3_3b(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(sr[0] == 1'b1),
	.prevConfigInvalid(1'b0),
	.out(checker_3_3b)
);

ovl_always_wrapped oaw3_3c(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(esr[0] == 1'b0),
	.prevConfigInvalid(1'b0),
	.out(checker_3_3c)
);

// Verify that EPCR gets the correct (delay slot dependant) PC
ovl_always_wrapped oaw_3_4(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(sr[`OR1200_SR_DSX] == 1'b0),
	.prevConfigInvalid(1'b0),
        .out(checker_3_4)
);

   // Fires when EPCR != next PC
ovl_always_on_edge_wrapped oaoew3_5(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event((ex_pc & `OR1200_EXCEPTION_VECTOR_UNMASK) == 32'h0),
	.test_expr(epcr == spr_dat_ppc+32'h4),
	.prevConfigInvalid(1'b0),
	.out(checker_3_5)
);

ovl_always_on_edge_wrapped oaoew3_5b(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event(ex_pc == 32'h00000A00),
	.test_expr(epcr == spr_dat_npc),
	.prevConfigInvalid(1'b0),
	.out(checker_3_5b)
);

ovl_always_wrapped oaw_3_6(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(sr[`OR1200_SR_DSX] == 1'b1),
	.prevConfigInvalid(1'b0),
	.out(checker_3_6)
);

   // Fires when EPCR != previous PC
ovl_always_on_edge_wrapped oaoew3_7(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event((ex_pc & `OR1200_EXCEPTION_VECTOR_UNMASK) == 32'h0),
	.test_expr(epcr == spr_dat_ppc),
	.prevConfigInvalid(1'b0),
	.out(checker_3_7)
);

// Checker 5 - Data from bus is stored in reg
wire checker_5_1;
wire checker_5_2;
reg [31:0] spec_xor_reg;
wire [31:0] spec_xor_comb = gpr_written_data ^ dcpu_dat_i;
wire spec_xor_comb_one = |spec_xor_comb;
wire spec_xor_reg_one = |spec_xor_reg;
wire spec_xor_small = spec_xor_reg_one & spec_xor_comb_one;
wire checker_5 = checker_5_1 & checker_5_2;

always @(posedge clk)begin
   spec_xor_reg <= gpr_written_data ^ dcpu_dat_i;
end

  // load
ovl_always_on_edge_wrapped oaoew5_1(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event((ex_insn & 32'hF0000000) == 32'h80000000),
	.test_expr(~spec_xor_small),
	.prevConfigInvalid(1'b0),
	.out(checker_5_1)
);

  // kick out add immediate signed
ovl_always_wrapped oaw5_2(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr((ex_insn & `OR1200_OPCODE_MASK) == 32'h8C000000),
	.prevConfigInvalid(1'b0),
	.out(checker_5_2)
);

// Checker 8
   wire      checker_8_1;
   wire      checker_8_2;
   wire      checker_8 = checker_8_1 & checker_8_2;

ovl_always_on_edge_wrapped oaoew8_1(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event(sr[`OR1200_SR_SM]),
	.test_expr(rst != 0),
	.prevConfigInvalid(1'b0),
	.out(checker_8_1)
);

ovl_always_on_edge_wrapped oaoew8_2(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.sampling_event(sr[`OR1200_SR_SM]),
	.test_expr((ex_pc & `OR1200_EXCEPTION_VECTOR_UNMASK) == 32'h0),
	.prevConfigInvalid(1'b0),
	.out(checker_8_2)
);

// Checker 9
   wire      checker_9_1;
   wire      checker_9_2;
   wire      checker_9 = checker_9_1 | checker_9_2;      

ovl_always_on_edge_wrapped oaoew9_1(
        .clk(clk),
        .rst(rst),
	.enable(enable),
        .sampling_event((ex_insn & `OR1200_OPCODE_MASK) == {`OR1200_OR32_RFE, 26'h0}),
        .test_expr(sr[`OR1200_SR_SM] == esr[`OR1200_SR_SM]),
        .prevConfigInvalid(1'b0),
        .out(checker_9_1)
);
   
ovl_always_on_edge_wrapped oaoew9_2(
        .clk(clk),
        .rst(rst),
	.enable(enable),
        .sampling_event((ex_insn & (`OR1200_OPCODE_MASK | `OR1200_K_MASK)) == {`OR1200_OR32_MTSPR, 15'h0, `OR1200_SPR_SR}),
        .test_expr(sr[`OR1200_SR_SM] == operand_b[`OR1200_SR_SM]),
        .prevConfigInvalid(1'b0),
        .out(checker_9_2)
);

// Checker 13 - Verify control flow
  wire checker_13_1;
  wire checker_13_2;
  reg checker_13_2_1;
  reg checker_13_2_2;
  wire checker_13_3;
  reg checker_13_3_1;
  reg checker_13_3_2;
  wire checker_13_4;
  reg checker_13_4_1;
  reg checker_13_4_2;
  wire checker_13_5;
  reg checker_13_5_1;
  wire checker_13_6;
  wire checker_13 = checker_13_1 & checker_13_2_1 & checker_13_3_1 & checker_13_4_1 & checker_13_5 & checker_13_6;
   
  // continuous control flow
ovl_delta_wrapped #(
  .width(32),
  .limit_width(4)
) odw_13_1(
        .clk(clk & enable),
        .rst(rst),
        .min(4'd0),
        .max(4'd4),
        .test_expr(ex_pc),
        .prevConfigInvalid(1'b0),
        .out(checker_13_1)
);

   // Need to save last two micro assertion results
   // One due to to transition, one extra for delay slot
always @(posedge clk)begin
   if(rst == `OR1200_RST_VALUE)begin
      checker_13_2_1 <= 1'b0;
      checker_13_2_2 <= 1'b0;
      checker_13_3_1 <= 1'b0;
      checker_13_3_2 <= 1'b0;
      checker_13_4_1 <= 1'b0;
      checker_13_4_2 <= 1'b0;
      checker_13_5_1 <= 1'b0;
   end else if(enable) begin
      checker_13_2_1 <= checker_13_2;
      checker_13_2_2 <= checker_13_2_1;
      checker_13_3_1 <= checker_13_3;
      checker_13_3_2 <= checker_13_3_1;
      checker_13_4_1 <= checker_13_4;
      checker_13_4_2 <= checker_13_4_1;
      checker_13_5_1 <= checker_13_5;
   end
end
   
   
  // jump
ovl_always_wrapped oaw_13_2(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(ex_insn[31:28] == 4'h0),
	.prevConfigInvalid(1'b0),
	.out(checker_13_2)
);

  // jump register
ovl_always_wrapped oaw_13_3(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(ex_insn[31:28] == 4'h4),
	.prevConfigInvalid(1'b0),
	.out(checker_13_3)
);

  // branch
ovl_always_wrapped oaw_13_4(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(ex_insn[31:26] == 6'h04),
	.prevConfigInvalid(1'b0),
	.out(checker_13_4)
);

  // rfe 
ovl_always_wrapped oaw_13_5(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr(ex_insn[31:26] == 6'h09),
	.prevConfigInvalid(1'b0),
	.out(checker_13_5)
);

  // exception
  // syscall, trap
ovl_proposition_wrapped opw_13_6(
	.rst(rst),
	.enable(enable),
	.test_expr((ex_pc & `OR1200_EXCEPTION_VECTOR_UNMASK) == 32'h0),
	.prevConfigInvalid(1'b0),
	.out(checker_13_6)
);

// Checker 15 - RFE updates SPRs correctly
wire checker_15_1;
wire checker_15_2;
wire checker_15_3;
wire checker_15 = checker_15_1 | (checker_15_2 & checker_15_3);

ovl_always_on_edge_wrapped oaoew15_1(
        .clk(clk),
        .rst(rst),
	.enable(enable),
        .sampling_event((ex_insn & `OR1200_OPCODE_MASK) == 32'h24000000),
        .test_expr(sr == esr),
        .prevConfigInvalid(1'b0),
        .out(checker_15_1)
);

   // TLB miss on address or data at address in EPCR breaks this
ovl_next_wrapped onw15_2(
        .clk(clk),
        .rst(rst),
	.enable(enable),
	.num_cks(3'd1),
        .start_event((ex_insn & `OR1200_OPCODE_MASK) == 32'h24000000),
        .test_expr(ex_pc == epcr),
        .prevConfigInvalid(1'b0),
        .out(checker_15_2)
);
   // Check for exception, note that EPCR will not be updated as we expect
ovl_always_wrapped oaw15_3(
        .clk(clk),
	.rst(rst),
	.enable(enable),
	.test_expr((ex_pc & `OR1200_EXCEPTION_VECTOR_UNMASK) == 32'h0),
	.prevConfigInvalid(1'b0),
	.out(checker_15_3)
);

// Checker 16 all use clk
wire checker_16_1;
wire checker_16_2;
wire checker_16_3;
wire checker_16_4;
wire checker_16_5;
wire checker_16_6;
wire checker_16_7;
wire checker_16 = ((checker_16_1 & checker_16_2 & checker_16_3) | checker_16_4) & (checker_16_5 | (checker_16_6 & checker_16_7));
   
  // Look for GPR writes when the insn does not have a target
ovl_always_on_edge_wrapped oaoew16_1(
        .clk(clk),
        .rst(rst),
	.enable(1'b1),
        .sampling_event(gpr_written_to),
        .test_expr((ex_insn & 32'hC0000000) == 32'h80000000),
        .prevConfigInvalid(1'b0),
        .out(checker_16_1)
);

ovl_always_on_edge_wrapped oaoew16_2(
        .clk(clk),
        .rst(rst),
	.enable(1'b1),
        .sampling_event(gpr_written_to),
        .test_expr((ex_insn & `OR1200_OPCODE_MASK) == 32'h18000000),
        .prevConfigInvalid(1'b0),
        .out(checker_16_2)
);

ovl_always_on_edge_wrapped oaoew16_3(
        .clk(clk),
        .rst(rst),
	.enable(1'b1),
        .sampling_event(gpr_written_to),
        .test_expr((ex_insn & `OR1200_OPCODE_MASK) == 32'hE0000000),
        .prevConfigInvalid(1'b0),
        .out(checker_16_3)
);
   

   // Look for when the instruction updated is not the target of the instruction
ovl_always_on_edge_wrapped oaoew16_4(
        .clk(clk),
        .rst(rst),
	.enable(1'b1),
        .sampling_event(gpr_written_to),
        .test_expr((ex_insn & `OR1200_TARGET_MASK) == {6'h0, gpr_written_addr, 21'h0}),
        .prevConfigInvalid(1'b0),
        .out(checker_16_4)
);

   // Jump and link writes to LR which is GPR9
ovl_always_on_edge_wrapped oaoew16_5(
        .clk(clk),
        .rst(rst),
	.enable(1'b1),
        .sampling_event(gpr_written_to),
        .test_expr(gpr_written_addr == 5'h9),
        .prevConfigInvalid(1'b0),
        .out(checker_16_5)
);

ovl_always_wrapped oaw16_6(
        .clk(clk),
        .rst(rst),
	.enable(1'b1),
        .test_expr((ex_insn & `OR1200_OPCODE_MASK) == 32'h04000000),
        .prevConfigInvalid(1'b0),
        .out(checker_16_6)
);

ovl_always_wrapped oaw16_7(
        .clk(clk),
        .rst(rst),
	.enable(1'b1),
        .test_expr((ex_insn & `OR1200_OPCODE_MASK) == 32'h48000000),
        .prevConfigInvalid(1'b0),
        .out(checker_16_7)
);

// Checker 18 - Unmasked maskable exception implies exception vector, at least 14
   wire checker_18_1;
   wire checker_18_2;
   wire checker_18 = checker_18_1 | checker_18_2;

   ovl_next_wrapped onw18_1(
        .clk(clk),
        .rst(rst),
	.enable(enable),
	.num_cks(3'd1),
        .start_event((ex_insn & 32'hFFFF0000) == 32'h20000000),
        .test_expr(ex_pc == 32'h00000C00),
        .prevConfigInvalid(1'b0),
        .out(checker_18_1)
   );

   ovl_next_wrapped onw18_2(
        .clk(clk),
        .rst(rst),
	.enable(enable),
	.num_cks(3'd1),
        .start_event((ex_insn & 32'hFFFF0000) == 32'h21000000),
        .test_expr(ex_pc == 32'h00000E00),
        .prevConfigInvalid(1'b0),
        .out(checker_18_2)
   );

   // Exception reg checker gated by continuous control flow checker
   wire checker_19 = checker_3 & checker_13_1;

   assign checkersFired = {12'b0, checker_19, checker_18, 1'b0, checker_16, checker_15, 1'b0, checker_13, 3'b0, checker_9, checker_8, 2'b0, checker_5, 1'b0, checker_3, 1'b0, checker_1, 1'b0};

   reg [31:0] checkersFired_reg;
   always @(posedge clk)
     checkersFired_reg <= checkersFired;

endmodule // BakedInAssertions
