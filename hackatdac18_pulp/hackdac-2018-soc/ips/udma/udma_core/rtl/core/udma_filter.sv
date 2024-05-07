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
// Description: Top level of uDMA filtering block
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////

`define CONN_MODE_0   0
`define CONN_MODE_1   1
`define CONN_MODE_2   2
`define CONN_MODE_3   3
`define CONN_MODE_4   4
`define CONN_MODE_5   5
`define CONN_MODE_6   6
`define CONN_MODE_7   7
`define CONN_MODE_8   8
`define CONN_MODE_9   9
`define CONN_MODE_10 10
`define CONN_MODE_11 11
`define CONN_MODE_12 12
`define CONN_MODE_13 13
`define CONN_MODE_14 14
`define CONN_MODE_15 15

module udma_filter
  #(
    parameter DATA_WIDTH     = 32,
    parameter FILTID_WIDTH   = 8,
    parameter L2_AWIDTH_NOAL = 15,
    parameter TRANS_SIZE     = 16
    )
   (
    input  logic                             clk_i,
    input  logic                             resetn_i,

    input  logic                       [2:0] cfg_filter_mode_i,
    input  logic                             cfg_filter_start_i,

    input  logic [1:0]  [L2_AWIDTH_NOAL-1:0] cfg_filter_tx_start_addr_i,
    input  logic [1:0]                 [1:0] cfg_filter_tx_datasize_i,
    input  logic [1:0]                 [1:0] cfg_filter_tx_mode_i,
    input  logic [1:0]      [TRANS_SIZE-1:0] cfg_filter_tx_len0_i,
    input  logic [1:0]      [TRANS_SIZE-1:0] cfg_filter_tx_len1_i,
    input  logic [1:0]      [TRANS_SIZE-1:0] cfg_filter_tx_len2_i,

    input  logic        [L2_AWIDTH_NOAL-1:0] cfg_filter_rx_start_addr_i,
    input  logic                       [1:0] cfg_filter_rx_datasize_i,
    input  logic                       [1:0] cfg_filter_rx_mode_i,
    input  logic            [TRANS_SIZE-1:0] cfg_filter_rx_len0_i,
    input  logic            [TRANS_SIZE-1:0] cfg_filter_rx_len1_i,
    input  logic            [TRANS_SIZE-1:0] cfg_filter_rx_len2_i,

    input  logic                             cfg_au_use_signed_i,
    input  logic                             cfg_au_bypass_i    ,
    input  logic                       [3:0] cfg_au_mode_i      ,
    input  logic                       [4:0] cfg_au_shift_i     ,
    input  logic                      [31:0] cfg_au_reg0_i      ,
    input  logic                      [31:0] cfg_au_reg1_i      ,

    input  logic                      [31:0] cfg_bincu_threshold_i,
    input  logic            [TRANS_SIZE-1:0] cfg_bincu_counter_i,

    output logic                             eot_event_o,
    output logic                             act_event_o,

    output logic [1:0]                       filter_tx_ch_req_o,
    output logic [1:0]  [L2_AWIDTH_NOAL-1:0] filter_tx_ch_addr_o,
    output logic [1:0]                 [1:0] filter_tx_ch_datasize_o,
    input  logic [1:0]                       filter_tx_ch_gnt_o,
    input  logic [1:0]                       filter_tx_ch_valid_i,
    input  logic [1:0]      [DATA_WIDTH-1:0] filter_tx_ch_data_i,
    output logic [1:0]                       filter_tx_ch_ready_o,

    output logic                             filter_rx_ch_valid_o,
    output logic        [L2_AWIDTH_NOAL-1:0] filter_rx_ch_addr_o,
    output logic            [DATA_WIDTH-1:0] filter_rx_ch_data_o,
    output logic                       [1:0] filter_rx_ch_datasize_o,
    input  logic                             filter_rx_ch_ready_i,

    input  logic          [FILTID_WIDTH-1:0] filter_id_i,
    input  logic            [DATA_WIDTH-1:0] filter_data_i,
    input  logic                       [1:0] filter_datasize_i,
    input  logic                             filter_valid_i,
    input  logic                             filter_sof_i,
    input  logic                             filter_eof_i,
    output logic                             filter_ready_o

    );
   logic [DATA_WIDTH-1:0] s_porta_data;
   logic            [1:0] s_porta_datasize;
   logic                  s_porta_valid;
   logic                  s_porta_sof;
   logic                  s_porta_eof;
   logic                  s_porta_ready;

   logic [DATA_WIDTH-1:0] s_portb_data;
   logic            [1:0] s_portb_datasize;
   logic                  s_portb_valid;
   logic                  s_portb_sof;
   logic                  s_portb_eof;
   logic                  s_portb_ready;

   logic [DATA_WIDTH-1:0] s_operanda_data;
   logic            [1:0] s_operanda_datasize;
   logic                  s_operanda_valid;
   logic                  s_operanda_sof;
   logic                  s_operanda_eof;
   logic                  s_operanda_ready;

   logic [DATA_WIDTH-1:0] s_operandb_data;
   logic            [1:0] s_operandb_datasize;
   logic                  s_operandb_valid;
   logic                  s_operandb_ready;

   logic [DATA_WIDTH-1:0] s_au_out_data;
   logic            [1:0] s_au_out_datasize;
   logic                  s_au_out_valid;
   logic                  s_au_out_ready;

   logic [DATA_WIDTH-1:0] s_bincu_in_data;
   logic            [1:0] s_bincu_in_datasize;
   logic                  s_bincu_in_valid;
   logic                  s_bincu_in_ready;

   logic [DATA_WIDTH-1:0] s_bincu_out_data;
   logic                  s_bincu_out_valid;
   logic                  s_bincu_out_ready;

   logic [DATA_WIDTH-1:0] s_udma_out_data;
   logic                  s_udma_out_valid;
   logic                  s_udma_out_ready;

   logic s_sel_out;       //1 output is from AU, 0 output is from BINCU
   logic s_sel_out_valid; //1 enables output

   logic s_sel_opa;       //1 input is from OPAPORT, 0 input is from BINCU
   logic s_sel_opa_valid; //1 enables output
   logic s_sel_opb_valid; //1 enables output

   logic s_sel_bincu;       //1 input  is from AU, 0 input  is from STREAM
   logic s_sel_bincu_valid; //1 enables output

   logic s_start_cha;
   logic s_start_chb;
   logic s_start_out;

  logic [2:0] s_status;
  logic [2:0] r_status;

  logic       s_done_cha;
  logic       s_done_chb;
  logic       s_done_out;
  logic       s_done;
  logic       r_done;

  logic       s_event;
  
   assign s_start_out = cfg_filter_start_i & s_sel_out_valid;
   assign s_start_cha = cfg_filter_start_i & s_sel_opa_valid;
   assign s_start_chb = cfg_filter_start_i & s_sel_opb_valid;
   assign s_start_bcu = cfg_filter_start_i & s_sel_bincu_valid;

   assign s_udma_out_data  =                    s_sel_out ? s_au_out_data  : s_bincu_out_data;
   assign s_udma_out_valid = s_sel_out_valid & (s_sel_out ? s_au_out_valid : s_bincu_out_valid);

   assign s_bincu_in_data  =                      s_sel_bincu ? s_au_out_data  : filter_data_i;
   assign s_bincu_in_valid = s_sel_bincu_valid & (s_sel_bincu ? s_au_out_valid : filter_valid_i);
   assign s_bincu_in_datasize =                   s_sel_bincu ? s_au_out_datasize : filter_datasize_i;

   assign s_operanda_data  =                    s_sel_opa ? s_porta_data  : filter_data_i;
   assign s_operanda_datasize  =                s_sel_opa ? s_porta_datasize  : filter_datasize_i;
   assign s_operanda_sof  =                     s_sel_opa ? s_porta_sof   : filter_sof_i;
   assign s_operanda_eof  =                     s_sel_opa ? s_porta_eof   : filter_eof_i;
   assign s_operanda_valid = s_sel_opa_valid & (s_sel_opa ? s_porta_valid : filter_valid_i);

   assign s_operandb_data = s_portb_data;
   assign s_operandb_valid = s_portb_valid;
   assign s_operandb_datasize = s_portb_datasize;

   assign s_au_out_ready   = (s_sel_out_valid   & s_sel_out   & s_udma_out_ready) | 
                             (s_sel_bincu_valid & s_sel_bincu & s_bincu_in_ready);

   assign s_porta_ready = (s_sel_opa_valid & s_sel_opa & s_operanda_ready);
   assign s_portb_ready = s_operandb_ready;

   assign s_filter_ready = (s_sel_opa_valid   & !s_sel_opa   & s_operanda_ready) |
                           (s_sel_bincu_valid & !s_sel_bincu & s_bincu_in_ready);

   assign s_bincu_out_ready = (s_sel_out_valid & !s_sel_out & s_udma_out_ready);

   assign filter_ready_o = s_filter_ready;

  assign s_status = r_status | {s_sel_out_valid,s_sel_opb_valid,s_sel_opa_valid}; //mask status of all the channels with their on/off status
  assign s_done   = &s_status;
  assign s_event  = s_done & ~r_done; //when all of them are done then rise the int
  assign eot_event_o = s_event;

  assign s_bincu_outenable = s_sel_out_valid & ~s_sel_out;

  always_comb 
  begin
    s_sel_out         = 1'b0;
    s_sel_out_valid   = 1'b0;
    s_sel_bincu       = 1'b0;
    s_sel_bincu_valid = 1'b0;
    s_sel_opa         = 1'b0;
    s_sel_opa_valid   = 1'b0;
    s_sel_opb_valid   = 1'b0;
    case(cfg_filter_mode_i)         //OperandA OperandB Output TBUnit 
      `CONN_MODE_0:                 //  L2       L2      ON     OFF
      begin
        s_sel_opa       = 1'b1;
        s_sel_opa_valid = 1'b1;
        s_sel_opb_valid = 1'b1;
        s_sel_out       = 1'b1;
        s_sel_out_valid = 1'b1;
      end
      `CONN_MODE_1:                 // STREAM    L2      ON     OFF
      begin
        s_sel_opa       = 1'b0;
        s_sel_opa_valid = 1'b1;
        s_sel_opb_valid = 1'b1;
        s_sel_out       = 1'b1;
        s_sel_out_valid = 1'b1;
      end
      `CONN_MODE_2:                 //  L2       OFF     ON     OFF
      begin
        s_sel_opa       = 1'b1;
        s_sel_opa_valid = 1'b1;
        s_sel_out       = 1'b1;
        s_sel_out_valid = 1'b1;
      end
      `CONN_MODE_3:                 // STREAM    OFF     ON     OFF
      begin
        s_sel_opa       = 1'b0;
        s_sel_opa_valid = 1'b1;
        s_sel_out       = 1'b1;
        s_sel_out_valid = 1'b1;
      end
      `CONN_MODE_4:                 //  L2       L2      OFF    ON
      begin
        s_sel_opa       = 1'b1;
        s_sel_opa_valid = 1'b1;
        s_sel_opb_valid = 1'b1;
        s_sel_bincu       = 1'b1;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_5:                 // STREAM    L2      OFF    ON
      begin
        s_sel_opa       = 1'b0;
        s_sel_opa_valid = 1'b1;
        s_sel_opb_valid = 1'b1;
        s_sel_bincu       = 1'b1;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_6:                 //  L2       OFF     OFF    ON
      begin
        s_sel_opa       = 1'b1;
        s_sel_opa_valid = 1'b1;
        s_sel_bincu       = 1'b1;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_7:                 // STREAM    OFF     OFF    ON
      begin
        s_sel_opa       = 1'b0;
        s_sel_opa_valid = 1'b1;
        s_sel_bincu       = 1'b1;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_8:                 //  L2       L2      ON     ON
      begin
        s_sel_opa       = 1'b1;
        s_sel_opa_valid = 1'b1;
        s_sel_opb_valid = 1'b1;
        s_sel_out       = 1'b0;
        s_sel_out_valid = 1'b1;
        s_sel_bincu       = 1'b1;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_9:                 // STREAM    L2      ON     ON
      begin
        s_sel_opa       = 1'b0;
        s_sel_opa_valid = 1'b1;
        s_sel_opb_valid = 1'b1;
        s_sel_out       = 1'b0;
        s_sel_out_valid = 1'b1;
        s_sel_bincu       = 1'b1;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_10:                //  L2       OFF     ON    ON
      begin
        s_sel_opa       = 1'b1;     
        s_sel_opa_valid = 1'b1;
        s_sel_out       = 1'b0;
        s_sel_out_valid = 1'b1;
        s_sel_bincu       = 1'b1;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_11:                // STREAM    OFF     ON     ON
      begin
        s_sel_opa       = 1'b0;
        s_sel_opa_valid = 1'b1;
        s_sel_out       = 1'b0;
        s_sel_out_valid = 1'b1;
        s_sel_bincu       = 1'b1;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_12:               //    OFF     OFF     OFF    ON
      begin
        s_sel_bincu       = 1'b0;
        s_sel_bincu_valid = 1'b1;
      end
      `CONN_MODE_13:               //    OFF     OFF     ON     ON
      begin
        s_sel_out       = 1'b0;
        s_sel_out_valid = 1'b1;
        s_sel_bincu       = 1'b0;
        s_sel_bincu_valid = 1'b1;
      end
    endcase // cfg_filter_mode_i
  end

  always_ff @(posedge clk_i or negedge resetn_i) begin : proc_status
    if(~resetn_i) begin
      r_status <= 0;
      r_done   <= 0;
    end else begin
      r_done <= s_done;
      if(cfg_filter_start_i)
        r_status <= 0;
      else
      begin
        if(s_done_cha)
          r_status[0] <= 1'b1;
        if(s_done_chb)
          r_status[1] <= 1'b1;
        if(s_done_out)
          r_status[2] <= 1'b1;
      end
    end
  end

  udma_filter_tx_datafetch #(
      .DATA_WIDTH    (DATA_WIDTH    ),
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .TRANS_SIZE    (TRANS_SIZE    )
  ) u_tx_ch_opa (
      .clk_i            ( clk_i                   ),
      .resetn_i         ( resetn_i                ),

      .tx_ch_req_o      ( filter_tx_ch_req_o[0]      ),
      .tx_ch_addr_o     ( filter_tx_ch_addr_o[0]     ),
      .tx_ch_datasize_o ( filter_tx_ch_datasize_o[0] ),
      .tx_ch_gnt_i      ( filter_tx_ch_gnt_o[0]      ),
      .tx_ch_valid_i    ( filter_tx_ch_valid_i[0]    ),
      .tx_ch_data_i     ( filter_tx_ch_data_i[0]     ),
      .tx_ch_ready_o    ( filter_tx_ch_ready_o[0]    ),

      .cmd_start_i      ( s_start_cha ),
      .cmd_done_o       ( s_done_cha  ),

      .cfg_start_addr_i ( cfg_filter_tx_start_addr_i[0] ),
      .cfg_datasize_i   ( cfg_filter_tx_datasize_i[0]   ),
      .cfg_mode_i       ( cfg_filter_tx_mode_i[0]       ),
      .cfg_len0_i       ( cfg_filter_tx_len0_i[0]       ),
      .cfg_len1_i       ( cfg_filter_tx_len1_i[0]       ),
      .cfg_len2_i       ( cfg_filter_tx_len2_i[0]       ),

      .stream_data_o    ( s_porta_data      ),
      .stream_datasize_o( s_porta_datasize  ),
      .stream_sof_o     ( s_porta_sof       ),
      .stream_eof_o     ( s_porta_eof       ),
      .stream_valid_o   ( s_porta_valid     ),
      .stream_ready_i   ( s_porta_ready     )

    );

  udma_filter_tx_datafetch #(
      .DATA_WIDTH    (DATA_WIDTH    ),
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .TRANS_SIZE    (TRANS_SIZE    )
  ) u_tx_ch_opb (
      .clk_i            ( clk_i                   ),
      .resetn_i         ( resetn_i                ),
      .tx_ch_req_o      ( filter_tx_ch_req_o[1]      ),
      .tx_ch_addr_o     ( filter_tx_ch_addr_o[1]     ),
      .tx_ch_datasize_o ( filter_tx_ch_datasize_o[1] ),
      .tx_ch_gnt_i      ( filter_tx_ch_gnt_o[1]      ),
      .tx_ch_valid_i    ( filter_tx_ch_valid_i[1]    ),
      .tx_ch_data_i     ( filter_tx_ch_data_i[1]     ),
      .tx_ch_ready_o    ( filter_tx_ch_ready_o[1]    ),
      .cmd_start_i      ( s_start_chb ),
      .cmd_done_o       ( s_done_chb  ),
      .cfg_start_addr_i ( cfg_filter_tx_start_addr_i[1] ),
      .cfg_datasize_i   ( cfg_filter_tx_datasize_i[1]   ),
      .cfg_mode_i       ( cfg_filter_tx_mode_i[1]       ),
      .cfg_len0_i       ( cfg_filter_tx_len0_i[1]       ),
      .cfg_len1_i       ( cfg_filter_tx_len1_i[1]       ),
      .cfg_len2_i       ( cfg_filter_tx_len2_i[1]       ),
      .stream_data_o    ( s_portb_data      ),
      .stream_datasize_o( s_portb_datasize  ),
      .stream_sof_o     ( s_portb_sof       ),
      .stream_eof_o     ( s_portb_eof       ),
      .stream_valid_o   ( s_portb_valid     ),
      .stream_ready_i   ( s_portb_ready     )

    );

    udma_filter_au
    #(
      .DATA_WIDTH(DATA_WIDTH)
    ) u_filter_au (
        .clk_i            ( clk_i            ),
        .resetn_i         ( resetn_i         ),
        .cfg_use_signed_i ( cfg_au_use_signed_i ),
        .cfg_bypass_i     ( cfg_au_bypass_i     ),
        .cfg_mode_i       ( cfg_au_mode_i       ),
        .cfg_shift_i      ( cfg_au_shift_i      ),
        .cfg_reg0_i       ( cfg_au_reg0_i       ),
        .cfg_reg1_i       ( cfg_au_reg1_i       ),
        .cmd_start_i      ( cfg_filter_start_i  ),
        .operanda_data_i  ( s_operanda_data  ),
        .operanda_datasize_i  ( s_operanda_datasize  ),
        .operanda_valid_i ( s_operanda_valid ),
        .operanda_sof_i  ( s_operanda_sof  ),
        .operanda_eof_i  ( s_operanda_eof  ),
        .operanda_ready_o ( s_operanda_ready ),
        .operandb_data_i  ( s_operandb_data  ),
        .operandb_datasize_i  ( s_operandb_datasize  ),
        .operandb_valid_i ( s_operandb_valid ),
        .operandb_ready_o ( s_operandb_ready ),
        .output_data_o    ( s_au_out_data    ),
        .output_datasize_o( s_au_out_datasize),
        .output_valid_o   ( s_au_out_valid   ),
        .output_ready_i   ( s_au_out_ready   )
    );

    udma_filter_bincu
    #(
      .DATA_WIDTH(DATA_WIDTH),
      .TRANS_SIZE(TRANS_SIZE)
    ) u_filter_bincu (
        .clk_i            ( clk_i                 ),
        .resetn_i         ( resetn_i              ),
        .cfg_use_signed_i ( cfg_au_use_signed_i   ),
        .cfg_out_enable_i ( s_bincu_outenable     ),
        .cfg_threshold_i  ( cfg_bincu_threshold_i ),
        .cfg_counter_i    ( cfg_bincu_counter_i   ),
        .cmd_start_i      ( s_start_bcu           ),
        .act_event_o      ( act_event_o           ),
        .input_data_i     ( s_bincu_in_data       ),
        .input_datasize_i ( s_bincu_in_datasize   ),
        .input_valid_i    ( s_bincu_in_valid      ),
        .input_sof_i      ( 1'b0                  ),
        .input_eof_i      ( 1'b0                  ),
        .input_ready_o    ( s_bincu_in_ready      ),
        .output_data_o    ( s_bincu_out_data      ),
        .output_datasize_o( ),
        .output_valid_o   ( s_bincu_out_valid     ),
        .output_sof_o     ( ),
        .output_eof_o     ( ),
        .output_ready_i   ( s_bincu_out_ready     )
  );

    udma_filter_rx_dataout #(
      .DATA_WIDTH    ( DATA_WIDTH    ),
      .FILTID_WIDTH  ( FILTID_WIDTH  ),
      .L2_AWIDTH_NOAL( L2_AWIDTH_NOAL),
      .TRANS_SIZE    ( TRANS_SIZE    )
    ) u_rx_ch (
      .clk_i           ( clk_i    ),
      .resetn_i        ( resetn_i ),
      .rx_ch_addr_o    ( filter_rx_ch_addr_o    ),
      .rx_ch_datasize_o( filter_rx_ch_datasize_o     ),
      .rx_ch_valid_o   ( filter_rx_ch_valid_o     ),
      .rx_ch_data_o    ( filter_rx_ch_data_o ),
      .rx_ch_ready_i   ( filter_rx_ch_ready_i    ),
      .cmd_start_i     ( s_start_out ),
      .cmd_done_i      ( s_done_out ),
      .cfg_start_addr_i( cfg_filter_rx_start_addr_i ),
      .cfg_datasize_i  ( cfg_filter_rx_datasize_i ),
      .cfg_mode_i      ( cfg_filter_rx_mode_i ),
      .cfg_len0_i      ( cfg_filter_rx_len0_i ),
      .cfg_len1_i      ( cfg_filter_rx_len1_i ),
      .cfg_len2_i      ( cfg_filter_rx_len2_i ),
      .stream_data_i   ( s_udma_out_data  ),
      .stream_valid_i  ( s_udma_out_valid ),
      .stream_ready_o  ( s_udma_out_ready )

    );

endmodule

