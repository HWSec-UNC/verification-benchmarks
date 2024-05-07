// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

///////////////////////////////////////////////////////////////////////////////
//
// Description: TX channels for uDMA IP
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////

`define log2(VALUE) ((VALUE) < ( 1 ) ? 0 : (VALUE) < ( 2 ) ? 1 : (VALUE) < ( 4 ) ? 2 : (VALUE) < ( 8 ) ? 3 : (VALUE) < ( 16 )  ? 4 : (VALUE) < ( 32 )  ? 5 : (VALUE) < ( 64 )  ? 6 : (VALUE) < ( 128 ) ? 7 : (VALUE) < ( 256 ) ? 8 : (VALUE) < ( 512 ) ? 9 : (VALUE) < ( 1024 ) ? 10 : (VALUE) < ( 2048 ) ? 11 : (VALUE) < ( 4096 ) ? 12 : (VALUE) < ( 8192 ) ? 13 : (VALUE) < ( 16384 ) ? 14 : (VALUE) < ( 32768 ) ? 15 : (VALUE) < ( 65536 ) ? 16 : (VALUE) < ( 131072 ) ? 17 : (VALUE) < ( 262144 ) ? 18 : (VALUE) < ( 524288 ) ? 19 : (VALUE) < ( 1048576 ) ? 20 : (VALUE) < ( 1048576 * 2 ) ? 21 : (VALUE) < ( 1048576 * 4 ) ? 22 : (VALUE) < ( 1048576 * 8 ) ? 23 : (VALUE) < ( 1048576 * 16 ) ? 24 : 25)

module udma_tx_channels
  #(
    parameter L2_ADDR_WIDTH  = 32,
    parameter L2_AWIDTH_NOAL = L2_ADDR_WIDTH+3,
    parameter L2_DATA_WIDTH  = 64,
    parameter DATA_WIDTH     = 32,
    parameter N_CHANNELS     = 8,
    parameter TRANS_SIZE     = 16
    )
   (
    input  logic	                        clk_i,
    input  logic                          rstn_i,
    
    output logic                           l2_req_o,
    input  logic                           l2_gnt_i,
    output logic    [L2_ADDR_WIDTH-1 : 0]  l2_addr_o,

    input  logic    [L2_DATA_WIDTH-1 : 0]  l2_rdata_i,
    input  logic                           l2_rvalid_i,

    input  logic [1:0]                         filter_ch_req_i     ,
    input  logic [1:0]  [L2_AWIDTH_NOAL-1 : 0] filter_ch_addr_i    ,
    input  logic [1:0]                 [1 : 0] filter_ch_datasize_i,
    output logic [1:0]                         filter_ch_gnt_o     ,
    output logic [1:0]                         filter_ch_valid_o   ,
    output logic [1:0]      [DATA_WIDTH-1 : 0] filter_ch_data_o    ,
    input  logic [1:0]                         filter_ch_ready_i   ,

    input  logic [N_CHANNELS-1:0]                [1 : 0] ch_datasize_i,
    input  logic [N_CHANNELS-1:0]                        ch_req_i,
    output logic [N_CHANNELS-1:0]                        ch_gnt_o,
    output logic [N_CHANNELS-1:0]                        ch_valid_o,
    output logic [N_CHANNELS-1:0]     [DATA_WIDTH-1 : 0] ch_data_o,
    input  logic [N_CHANNELS-1:0]                        ch_ready_i,
    output logic [N_CHANNELS-1:0]                        ch_events_o,
    output logic [N_CHANNELS-1:0]                        ch_en_o,
    output logic [N_CHANNELS-1:0]                        ch_pending_o,
    output logic [N_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] ch_curr_addr_o,
    output logic [N_CHANNELS-1:0]     [TRANS_SIZE-1 : 0] ch_bytes_left_o,

    input  logic [N_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] cfg_startaddr_i,
    input  logic [N_CHANNELS-1:0]     [TRANS_SIZE-1 : 0] cfg_size_i,
    input  logic [N_CHANNELS-1:0]                        cfg_continuous_i,
    input  logic [N_CHANNELS-1:0]                        cfg_en_i,
    input  logic [N_CHANNELS-1:0]                        cfg_clr_i

    );

    localparam ALIGN_BITS     = $clog2(L2_DATA_WIDTH/8);
    localparam L2_SIZE        = L2_ADDR_WIDTH + ALIGN_BITS;
    localparam N_CHANNELS_TX  = N_CHANNELS+2;
    localparam LOG_N_CHANNELS = $clog2(N_CHANNELS_TX);
    localparam INTFIFO_SIZE   = L2_SIZE + LOG_N_CHANNELS + 2;//store addr_data and size and request

    integer i;
   
   // Internal signals

    logic       [N_CHANNELS_TX-1:0] s_grant;
    logic       [N_CHANNELS_TX-1:0] r_grant;
    logic       [N_CHANNELS_TX-1:0] s_req;
    logic       [N_CHANNELS_TX-1:0] s_gnt;

    logic      [LOG_N_CHANNELS-1:0] s_grant_log;

    logic       [N_CHANNELS_TX-1:0] s_ch_ready;

    logic       [N_CHANNELS-1:0] s_ch_en;

    logic       [LOG_N_CHANNELS-1:0] s_resp;
    logic       [LOG_N_CHANNELS-1:0] r_resp;
    logic       [LOG_N_CHANNELS-1:0] r_resp_dly;

    logic                        r_valid;

    logic                        s_anygrant;
    logic                        r_anygrant;

    logic                        s_send_req;

    logic                      [L2_AWIDTH_NOAL-1:0] s_addr;
    logic [N_CHANNELS_TX-1:0]  [L2_AWIDTH_NOAL-1:0] s_curr_addr;
    logic                      [L2_AWIDTH_NOAL-1:0] r_in_addr;

    logic                  [1:0] s_size;
    logic                  [1:0] s_trans_size;
    logic       [DATA_WIDTH-1:0] s_data;
    logic                  [1:0] r_size;
    logic       [DATA_WIDTH-1:0] r_data;
    logic       [ALIGN_BITS-1:0] s_addr_lsb;
    logic       [ALIGN_BITS-1:0] r_addr;

    logic                  [1:0] s_in_size;
    logic                  [1:0] r_in_size;

    logic         [INTFIFO_SIZE-1:0] s_fifoin;
    logic         [INTFIFO_SIZE-1:0] s_fifoout;

    logic s_l2_req_o;
    logic s_stall;
    logic s_sample_indata;

    assign ch_curr_addr_o = s_curr_addr;
    assign ch_en_o = s_ch_en;
    assign s_fifoin = {s_grant_log,r_in_size,s_addr[L2_SIZE-1:0]};

    assign l2_addr_o    = s_fifoout[L2_SIZE-1:ALIGN_BITS];     //{3'b000,s_fifoout[L2_SIZE-1:3]};
    assign s_addr_lsb   = s_fifoout[ALIGN_BITS-1:0];
    assign s_trans_size = s_fifoout[L2_SIZE+2-1:L2_SIZE];
    assign s_resp       = s_fifoout[INTFIFO_SIZE-1:L2_SIZE+2];

    assign s_req[N_CHANNELS-1:0] = ch_req_i & s_ch_en;
    assign s_req[N_CHANNELS_TX-1:N_CHANNELS] = filter_ch_req_i;

    assign s_gnt = s_sample_indata ? s_grant : 'h0;

    assign s_send_req = r_anygrant;

    assign l2_req_o = s_l2_req_o & ~s_stall;
    assign ch_gnt_o = s_gnt[N_CHANNELS-1:0];
    assign filter_ch_gnt_o = s_gnt[N_CHANNELS_TX-1:N_CHANNELS];

    udma_arbiter #(
      .N(N_CHANNELS_TX),
      .S(LOG_N_CHANNELS)
      ) u_arbiter (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .req_i(s_req),
        .grant_o(s_grant),
        .grant_ack_i(s_sample_indata),
        .anyGrant_o(s_anygrant)
      );

    io_generic_fifo #(
      .DATA_WIDTH(INTFIFO_SIZE),
      .BUFFER_DEPTH(4)
      ) u_fifo (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .elements_o(),
        .clr_i(1'b0),
        .data_o(s_fifoout),
        .valid_o(s_l2_req_o),
        .ready_i(l2_gnt_i),
        .valid_i(s_send_req),
        .data_i(s_fifoin),
        .ready_o(s_sample_indata)
        );

    genvar j;
    generate
      for (j=0;j<N_CHANNELS;j++)
      begin
        udma_ch_addrgen #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE(TRANS_SIZE)
        ) u_tx_ch_ctrl (
          .clk_i(clk_i),
          .rstn_i(rstn_i),
          .cfg_startaddr_i(cfg_startaddr_i[j]),
          .cfg_size_i(cfg_size_i[j]),
          .cfg_continuous_i(cfg_continuous_i[j]),
          .cfg_filter_i(1'b0),
          .cfg_en_i(cfg_en_i[j]),
          .cfg_clr_i(cfg_clr_i[j]),
          .int_datasize_i(r_in_size),
          .int_not_stall_i(s_sample_indata),
          .int_ch_curr_addr_o(s_curr_addr[j]),
          .int_ch_bytes_left_o(ch_bytes_left_o[j]),
          .int_ch_grant_i(r_grant[j]),
          .int_ch_en_o(),
          .int_ch_sot_o(),
          .int_ch_en_prev_o(s_ch_en[j]),
          .int_ch_pending_o(ch_pending_o[j]),
          .int_ch_events_o(ch_events_o[j]),
          .int_filter_o()
        );
      end
    endgenerate

    always_comb 
    begin
      s_grant_log = 0;
      for(int i=0;i<N_CHANNELS_TX;i++)
        if(r_grant[i])
          s_grant_log = i;    
    end

    always_comb
    begin: gen_addr
      s_addr = 0;
      for(int i=0;i<N_CHANNELS;i++)
        if(r_grant[i])
          s_addr = s_curr_addr[i];
      if(r_grant[N_CHANNELS] | r_grant[N_CHANNELS+1])
        s_addr = r_in_addr;
    end

    always_comb
    begin: gen_size
      s_in_size = 0;
      for(int i=0;i<N_CHANNELS;i++)
        if(s_grant[i])
          s_in_size = ch_datasize_i[i];
      if(s_grant[N_CHANNELS])
        s_in_size = filter_ch_datasize_i[0];
      if(s_grant[N_CHANNELS+1])
        s_in_size = filter_ch_datasize_i[1];
    end

    always_comb
    begin: demux_data
      for(int i=0;i<N_CHANNELS;i++)
      begin
        ch_valid_o[i]        = 1'b0;
        ch_data_o[i]         = 'hDEADBEEF;
      end
      filter_ch_valid_o[0] = 1'b0;
      filter_ch_data_o[0]  = 'hDEADBEEF;
      filter_ch_valid_o[1] = 1'b0;
      filter_ch_data_o[1]  = 'hDEADBEEF;
      if(r_resp_dly == N_CHANNELS)
      begin
        filter_ch_valid_o[0] = r_valid;
        filter_ch_data_o[0]  = r_data;
      end
      else if(r_resp_dly == N_CHANNELS+1)
      begin
        filter_ch_valid_o[1] = r_valid;
        filter_ch_data_o[1]  = r_data;
      end
      else
      begin
        ch_valid_o[r_resp_dly] = r_valid;
        ch_data_o[r_resp_dly]  = r_data;
      end
    end
      
    assign s_ch_ready[N_CHANNELS-1:0] = ch_ready_i;
    assign s_ch_ready[N_CHANNELS_TX-1:N_CHANNELS] = filter_ch_ready_i;

    //this may happen only in burst mode when multiple reads are pipelined
    assign s_stall = |(~s_ch_ready & r_resp) & r_valid;    

    always_ff @(posedge clk_i or negedge rstn_i) 
    begin : ff_data
      if(~rstn_i) begin
        r_grant     <=  '0;
        r_anygrant  <=  '0;
        r_resp      <=  '0;
        r_resp_dly  <=  '0;
        r_valid     <=  '0;
        r_in_size   <=  '0;
        r_size      <=  '0;
        r_addr      <=  '0; 
        r_data      <=  '0;
        r_in_addr   <=  '0;
      end else begin
          r_valid     <= l2_rvalid_i;
          r_resp_dly  <= r_resp;

          if (l2_rvalid_i)
            r_data <= s_data;
          if (l2_req_o && l2_gnt_i)
          begin
            r_resp     <= s_resp;
            r_size     <= s_trans_size;
            r_addr     <= s_addr_lsb;
          end
          
         if (s_sample_indata)
         begin
              r_in_size  <= s_in_size;
              r_grant    <= s_grant;
              r_anygrant <= s_anygrant;
              if (s_grant[N_CHANNELS])
                r_in_addr <= filter_ch_addr_i[0];
              else if(s_grant[N_CHANNELS+1])
                r_in_addr <= filter_ch_addr_i[1];
         end
      end
    end
   
    generate
      if (L2_DATA_WIDTH == 64)
      begin
        always_comb
        begin
          case (r_size)
          2'h0:
                begin
                   if     (r_addr == 3'b000) s_data = {24'h0,l2_rdata_i[7:0]};
                   else if(r_addr == 3'b001) s_data = {24'h0,l2_rdata_i[15:8]};
                   else if(r_addr == 3'b010) s_data = {24'h0,l2_rdata_i[23:16]};
                   else if(r_addr == 3'b011) s_data = {24'h0,l2_rdata_i[31:24]};
                   else if(r_addr == 3'b100) s_data = {24'h0,l2_rdata_i[39:32]};
                   else if(r_addr == 3'b101) s_data = {24'h0,l2_rdata_i[47:40]};
                   else if(r_addr == 3'b110) s_data = {24'h0,l2_rdata_i[55:48]};
                   else                      s_data = {24'h0,l2_rdata_i[63:56]};
                end
          2'h1:
                begin
                   if(r_addr[2:1] == 2'b00)      s_data = {16'h0,l2_rdata_i[15:0]};
                   else if(r_addr[2:1] == 2'b01) s_data = {16'h0,l2_rdata_i[31:16]};
                   else if(r_addr[2:1] == 2'b10) s_data = {16'h0,l2_rdata_i[47:32]};
                   else                          s_data = {16'h0,l2_rdata_i[63:48]};
                end
          2'h2: 
                begin
                   if(r_addr[2] == 1'b0)         s_data = l2_rdata_i[31:0];
                   else                          s_data = l2_rdata_i[63:32];
                end
          default:                               s_data = 32'hDEADBEEF;  // default to 32-bit access
          endcase 
        end
      end
      else if (L2_DATA_WIDTH == 32)
      begin
        always_comb
        begin
          case (r_size)
          2'h0:
                begin
                   if     (r_addr[1:0] == 2'b00) s_data = {24'h0,l2_rdata_i[7:0]};
                   else if(r_addr[1:0] == 2'b01) s_data = {24'h0,l2_rdata_i[15:8]};
                   else if(r_addr[1:0] == 2'b10) s_data = {24'h0,l2_rdata_i[23:16]};
                   else                          s_data = {24'h0,l2_rdata_i[31:24]};
                end
          2'h1:
                begin
                   if(r_addr[1] == 1'b0)         s_data = {16'h0,l2_rdata_i[15:0]};
                   else                          s_data = {16'h0,l2_rdata_i[31:16]};
                end
          2'h2: 
                begin
                                                 s_data = l2_rdata_i[31:0];
                end
          default:                               s_data = 32'hDEADBEEF;  // default to 32-bit access
          endcase 
        end
      end
    endgenerate

endmodule
