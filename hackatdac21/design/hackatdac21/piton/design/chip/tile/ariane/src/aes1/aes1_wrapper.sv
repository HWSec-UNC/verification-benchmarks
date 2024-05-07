//======================================================================
//
// aes1.v
// --------
// Top level wrapper for the AES block cipher core.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2013, 2014 Secworks Sweden AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module aes1_wrapper #(
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 10
)(
          clk_i,
          rst_ni,
          reglk_ctrl_i,
          acct_ctrl_i,
          debug_mode_i,
          axi_req_i, 
          axi_resp_o,
          rst_2
          );
 
input logic                    clk_i;
input logic                    rst_ni;
input logic [7 :0]             reglk_ctrl_i; // register lock values
input logic                    acct_ctrl_i;
input logic                    debug_mode_i;
input  ariane_axi::req_t       axi_req_i;
output ariane_axi::resp_t      axi_resp_o;

input logic rst_2;

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam ADDR_NAME0       = 9'h00;
  localparam ADDR_NAME1       = 9'h01;
  localparam ADDR_VERSION     = 9'h02;

  localparam ADDR_CTRL        = 9'h08;
  localparam CTRL_INIT_BIT    = 0;
  localparam CTRL_NEXT_BIT    = 1;

  localparam ADDR_STATUS      = 9'h09;
  localparam STATUS_READY_BIT = 0;
  localparam STATUS_VALID_BIT = 1;

  localparam ADDR_CONFIG      = 9'h0a;
  localparam CTRL_ENCDEC   = 9'h0a;
  localparam CTRL_KEYLEN0  = 9'h0b;
  localparam CTRL_KEYLEN1  = 9'h0c;
  localparam CTRL_KEYLEN2  = 9'h0d;

  localparam KEY_SEL           = 9'h0e;
  localparam ADDR_KEY00        = 9'h10;
  localparam ADDR_KEY07        = 9'h17;
  localparam ADDR_KEY10        = 9'h20;
  localparam ADDR_KEY17        = 9'h27;
  localparam ADDR_KEY20        = 9'h30;
  localparam ADDR_KEY27        = 9'h37;

  localparam ADDR_BLOCK0      = 9'h40;
  localparam ADDR_BLOCK3      = 9'h43;

  localparam ADDR_RESULT0     = 9'h50;
  localparam ADDR_RESULT1     = 9'h51;
  localparam ADDR_RESULT2     = 9'h52;
  localparam ADDR_RESULT3     = 9'h53;

  localparam CORE_NAME0       = 32'h61657320; // "aes "
  localparam CORE_NAME1       = 32'h20202020; // "    "
  localparam CORE_VERSION     = 32'h302e3630; // "0.60"


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  logic  init_reg, init_reg_d;
  logic  next_reg, next_reg_d;

  logic  encdec_reg;
  logic  keylen_reg, keylen_reg0, keylen_reg1, keylen_reg2;

  logic  [31 : 0] block_reg [0 : 3];
  logic           block_we;

  logic  [31 : 0] key_reg0 [0 : 7];
  logic  [31 : 0] key_reg1 [0 : 7];
  logic  [31 : 0] key_reg2 [0 : 7];
  logic           key_we0, key_we1, key_we2;
  logic  [1:0]    key_sel; 


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  logic            core_encdec;
  logic            core_init;
  logic            core_next;
  logic            core_ready;
  logic  [255 : 0] core_key, core_key0, core_key1, core_key2;
  logic            core_keylen;
  logic  [127 : 0] core_block;
  logic  [127 : 0] core_result;
  logic            core_valid;

  // signals from AXI 4 Lite
  logic [AXI_ADDR_WIDTH-1:0] address;
logic                      en, en_acct;
  logic                      we;
  logic [63:0] wdata;
  logic [63:0] rdata;

  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------

  assign core_key0 = debug_mode_i ? 'b0 : {key_reg0[7], key_reg0[6],
                      key_reg0[5], key_reg0[4], key_reg0[3], key_reg0[2], key_reg0[1], key_reg0[0]};
  assign core_key1 = {key_reg1[7], key_reg1[6],
                      key_reg1[5], key_reg1[4], key_reg1[3], key_reg1[2], key_reg1[1], key_reg1[0]};
  assign core_key2 = debug_mode_i ? 'b0 : {key_reg2[7], key_reg2[6],
                      key_reg2[5], key_reg2[4], key_reg2[3], key_reg2[2], key_reg2[1], key_reg2[0]};

  assign core_key  = key_sel[1] ? core_key2 : (key_sel[0] ? core_key1 : core_key0) ;  
  assign core_keylen  = key_sel[1] ? keylen_reg2 : (key_sel[0] ? keylen_reg1 : keylen_reg0) ;  

  assign core_block  = {block_reg[3], block_reg[2],
                        block_reg[1], block_reg[0]};
  assign core_init   = init_reg & ~init_reg_d;
  assign core_next   = next_reg & ~next_reg_d;
  assign core_encdec = encdec_reg;


  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  // Implement APB I/O map to AES interface
  // Write side

  assign key_we0  = ((address[11:3] >= ADDR_KEY00) && (address[11:3] <= ADDR_KEY07));
  assign key_we1  = ((address[11:3] >= ADDR_KEY10) && (address[11:3] <= ADDR_KEY17));
  assign key_we2  = ((address[11:3] >= ADDR_KEY20) && (address[11:3] <= ADDR_KEY27));

  assign block_we  = ((address[11:3] >= ADDR_BLOCK0) && (address[11:3] <= ADDR_BLOCK3));

///////////////////////////////////////////////////////////////////////////
    // -----------------------------
    // AXI Interface Logic
    // -----------------------------
    axi_lite_interface #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH    )
    ) axi_lite_interface_i (
        .clk_i      ( clk_i      ),
        .rst_ni     ( rst_ni     ),
        .axi_req_i  ( axi_req_i  ),
        .axi_resp_o ( axi_resp_o ),
        .address_o  ( address    ),
        .en_o       ( en_acct    ),
        .we_o       ( we         ),
        .data_i     ( rdata      ),
        .data_o     ( wdata      )
    );

    assign en = en_acct && acct_ctrl_i; 

  always @(posedge clk_i)
    begin
      if(~(rst_ni && ~rst_2))
        begin
          init_reg_d <= 1'b0;
          next_reg_d <= 1'b0;
        end
      else
        begin
          init_reg_d <= init_reg;
          next_reg_d <= next_reg;
        end
    end

  always @(posedge clk_i)
    begin
      integer i;
      if(~(rst_ni && ~rst_2))
        begin
          encdec_reg <= 1'b0; 
          keylen_reg0 <= 1'b0;
          keylen_reg1 <= 1'b0;
          keylen_reg2 <= 1'b0;
          init_reg   <= 1'b0;
          next_reg   <= 1'b0;
          init_reg_d <= 1'b0;
          next_reg_d <= 1'b0;
          key_sel    <= 2'b0;

          for (i = 0 ; i < 4 ; i = i + 1)
            block_reg[i] <= 32'h0;

          for (i = 0 ; i < 8 ; i = i + 1) begin
            key_reg0[i] <= 32'h0;
            key_reg1[i] <= 32'h0;
            key_reg2[i] <= 32'h0;
          end
        end
      else if(en && we) begin
        case(address[11:3])
          CTRL_ENCDEC : encdec_reg <= reglk_ctrl_i[1] ? encdec_reg : wdata;
          CTRL_KEYLEN0: keylen_reg0 <= reglk_ctrl_i[3] ? keylen_reg0 : wdata;
          CTRL_KEYLEN1: keylen_reg1 <= reglk_ctrl_i[3] ? keylen_reg1 : wdata;
          CTRL_KEYLEN2: keylen_reg2 <= reglk_ctrl_i[3] ? keylen_reg2 : wdata;
          ADDR_CTRL :
            begin
              init_reg <= reglk_ctrl_i[1] ? init_reg : wdata[CTRL_INIT_BIT];
              next_reg <= reglk_ctrl_i[1] ? next_reg : wdata[CTRL_NEXT_BIT];
            end  
          KEY_SEL: key_sel <= reglk_ctrl_i[5] ? key_sel : wdata;
          
          default: 
            ; 
        endcase

        if (block_we)
            block_reg[address[4 : 3]] <= reglk_ctrl_i[5] ? block_reg[address[4 : 3]] : wdata;

        if (key_we0) 
            key_reg0[address[5 : 3]] <= reglk_ctrl_i[3] ? key_reg0[address[5 : 3]] : wdata;
        if (key_we1) 
            key_reg1[address[5 : 3]] <= reglk_ctrl_i[3] ? key_reg1[address[5 : 3]] : wdata;
        if (key_we2) 
            key_reg2[address[5 : 3]] <= reglk_ctrl_i[3] ? key_reg2[address[5 : 3]] : wdata;
        end // end else if
    end // always @ (posedge)


  // Read side
  //always @(~write)
  always @(*)
    begin
      if (~en) begin
        rdata = 64'b0; 
      end
      else begin
        case(address[11:3])
          ADDR_NAME0:   rdata = reglk_ctrl_i[0] ? 32'b0 : CORE_NAME0;
          ADDR_NAME1:   rdata = reglk_ctrl_i[0] ? 32'b0 : CORE_NAME1;
          ADDR_VERSION: rdata = reglk_ctrl_i[0] ? 32'b0 : CORE_VERSION;
          ADDR_CTRL:    rdata = reglk_ctrl_i[0] ? 32'b0 : {28'h0, core_keylen, encdec_reg, next_reg, init_reg};
          ADDR_STATUS:  rdata = reglk_ctrl_i[4] ? 32'b0 : {30'h0, core_valid, core_ready};
          ADDR_RESULT0: rdata = reglk_ctrl_i[4] ? 32'b0 : core_result[0*32 +: 32];
          ADDR_RESULT1: rdata = reglk_ctrl_i[4] ? 32'b0 : core_result[1*32 +: 32];
          ADDR_RESULT2: rdata = reglk_ctrl_i[4] ? 32'b0 : core_result[2*32 +: 32];
          ADDR_RESULT3: rdata = reglk_ctrl_i[4] ? 32'b0 : core_result[3*32 +: 32];
          default:
            rdata = 32'b0;
        endcase
        if (key_we0) rdata = reglk_ctrl_i[2] ? 32'b0 : key_reg0[address[5:3]]; 
        if (key_we1) rdata = reglk_ctrl_i[2] ? 32'b0 : key_reg1[address[5:3]]; 
        if (key_we2) rdata = reglk_ctrl_i[2] ? 32'b0 : key_reg2[address[5:3]];
      end 
  end // always @ (*)



  //----------------------------------------------------------------
  // core instantiation.
  //----------------------------------------------------------------
  aes1_core core1(
                .clk(clk_i),
                .reset_n(rst_ni && ~rst_2),

                .encdec(core_encdec),
                .init(core_init),
                .next(core_next),
                .ready(core_ready),

                .key(core_key),
                .keylen(core_keylen),

                .block(core_block),
                .result(core_result),
                .result_valid(core_valid)
               );

endmodule // aes


//======================================================================
// EOF aes.v
//======================================================================
