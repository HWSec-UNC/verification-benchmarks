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
// Description: Top level of udma core block
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////

`define log2(VALUE) ((VALUE) < ( 2 ) ? 0 : (VALUE) < ( 3 ) ? 1 : (VALUE) < ( 5 ) ? 2 : (VALUE) < ( 9 ) ? 3 : (VALUE) < ( 17 )  ? 4 : (VALUE) < ( 33 )  ? 5 : (VALUE) < ( 65 )  ? 6 : (VALUE) < ( 129 ) ? 7 : (VALUE) < ( 257 ) ? 8 : (VALUE) < ( 513 ) ? 9 : (VALUE) < ( 1025 ) ? 10 : (VALUE) < ( 2049 ) ? 11 : (VALUE) < ( 4097 ) ? 12 : (VALUE) < ( 8193 ) ? 13 : (VALUE) < ( 16385 ) ? 14 : (VALUE) < ( 32769 ) ? 15 : (VALUE) < ( 65537 ) ? 16 : (VALUE) < ( 131073 ) ? 17 : (VALUE) < ( 262145 ) ? 18 : (VALUE) < ( 524289 ) ? 19 : (VALUE) < ( 1048576 ) ? 20 : (VALUE) < ( 1048576 * 2 ) ? 21 : (VALUE) < ( 1048576 * 4 ) ? 22 : (VALUE) < ( 1048576 * 8 ) ? 23 : (VALUE) < ( 1048576 * 16 ) ? 24 : 25)

module udma_core
  #(
    parameter L2_DATA_WIDTH  = 64,
    parameter DATA_WIDTH     = 32,
    parameter L2_ADDR_WIDTH  = 15,
    parameter L2_AWIDTH_NOAL = L2_ADDR_WIDTH+`log2(L2_DATA_WIDTH/8),
    parameter APB_ADDR_WIDTH = 12,  //APB slaves are 4KB by default
    parameter N_RX_CHANNELS  = 8,
    parameter N_TX_CHANNELS  = 8,
    parameter N_PERIPHS      = 8,
    parameter TRANS_SIZE     = 16
    )
   (
    input  logic                        sys_clk_i,
    input  logic                        per_clk_i,

    input  logic                        dft_cg_enable_i,

    input  logic                        HRESETn,
    input  logic   [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic                 [31:0] PWDATA,
    input  logic                        PWRITE,
    input  logic                        PSEL,
    input  logic                        PENABLE,
    output logic                 [31:0] PRDATA,
    output logic                        PREADY,
    output logic                        PSLVERR,

    input  logic                        event_valid_i,
    input  logic                  [7:0] event_data_i,
    output logic                        event_ready_o,
    output logic                  [3:0] event_o,

    output logic                        filter_eot_o,
    output logic                        filter_act_o,

    output logic        [N_PERIPHS-1:0] periph_per_clk_o,
    output logic        [N_PERIPHS-1:0] periph_sys_clk_o,

    output logic                 [31:0] periph_data_to_o,
    output logic                  [4:0] periph_addr_o,
    output logic                        periph_rwn_o,
    input  logic [N_PERIPHS-1:0] [31:0] periph_data_from_i,
    output logic [N_PERIPHS-1:0]        periph_valid_o,
    input  logic [N_PERIPHS-1:0]        periph_ready_i,

    output logic                        rx_l2_req_o,
    input  logic                        rx_l2_gnt_i,
    output logic    [L2_ADDR_WIDTH-1:0] rx_l2_addr_o,
    output logic  [L2_DATA_WIDTH/8-1:0] rx_l2_be_o,
    output logic    [L2_DATA_WIDTH-1:0] rx_l2_wdata_o,

    output logic                        tx_l2_req_o,
    input  logic                        tx_l2_gnt_i,
    output logic    [L2_ADDR_WIDTH-1:0] tx_l2_addr_o,
    input  logic    [L2_DATA_WIDTH-1:0] tx_l2_rdata_i,
    input  logic                        tx_l2_rvalid_i,

    input  logic [N_TX_CHANNELS-1:0]                        tx_ch_req_i,
    output logic [N_TX_CHANNELS-1:0]                        tx_ch_gnt_o,
    output logic [N_TX_CHANNELS-1:0]                        tx_ch_valid_o,
    output logic [N_TX_CHANNELS-1:0]     [DATA_WIDTH-1 : 0] tx_ch_data_o,
    input  logic [N_TX_CHANNELS-1:0]                        tx_ch_ready_i,
    input  logic [N_TX_CHANNELS-1:0]                [1 : 0] tx_ch_datasize_i,
    output logic [N_TX_CHANNELS-1:0]                        tx_ch_events_o,
    output logic [N_TX_CHANNELS-1:0]                        tx_ch_en_o,
    output logic [N_TX_CHANNELS-1:0]                        tx_ch_pending_o,
    output logic [N_TX_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] tx_ch_curr_addr_o,
    output logic [N_TX_CHANNELS-1:0]     [TRANS_SIZE-1 : 0] tx_ch_bytes_left_o,

    input  logic [N_TX_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] tx_cfg_startaddr_i,
    input  logic [N_TX_CHANNELS-1:0]     [TRANS_SIZE-1 : 0] tx_cfg_size_i,
    input  logic [N_TX_CHANNELS-1:0]                        tx_cfg_continuous_i,
    input  logic [N_TX_CHANNELS-1:0]                        tx_cfg_en_i,
    input  logic [N_TX_CHANNELS-1:0]                        tx_cfg_clr_i,
    
    input  logic [N_RX_CHANNELS-1:0]                [1 : 0] rx_ch_datasize_i,
    input  logic [N_RX_CHANNELS-1:0]                        rx_ch_valid_i,
    input  logic [N_RX_CHANNELS-1:0]     [DATA_WIDTH-1 : 0] rx_ch_data_i,
    output logic [N_RX_CHANNELS-1:0]                        rx_ch_ready_o,
    output logic [N_RX_CHANNELS-1:0]                        rx_ch_events_o,
    output logic [N_RX_CHANNELS-1:0]                        rx_ch_en_o,
    output logic [N_RX_CHANNELS-1:0]                        rx_ch_pending_o,
    output logic [N_RX_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] rx_ch_curr_addr_o,
    output logic [N_RX_CHANNELS-1:0]     [TRANS_SIZE-1 : 0] rx_ch_bytes_left_o,

    input  logic [N_RX_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] rx_cfg_startaddr_i,
    input  logic [N_RX_CHANNELS-1:0]     [TRANS_SIZE-1 : 0] rx_cfg_size_i,
    input  logic [N_RX_CHANNELS-1:0]                        rx_cfg_continuous_i,
    input  logic [N_RX_CHANNELS-1:0]                        rx_cfg_en_i,
    input  logic [N_RX_CHANNELS-1:0]                        rx_cfg_filter_i,
    input  logic [N_RX_CHANNELS-1:0]                        rx_cfg_clr_i

    );

    localparam FILTID_WIDTH = $clog2(N_RX_CHANNELS+1);

    logic [1:0]                        s_filter_tx_ch_req     ;
    logic [1:0] [L2_AWIDTH_NOAL-1 : 0] s_filter_tx_ch_addr    ;
    logic [1:0]                [1 : 0] s_filter_tx_ch_datasize;
    logic [1:0]                        s_filter_tx_ch_gnt     ;
    logic [1:0]                        s_filter_tx_ch_valid   ;
    logic [1:0]     [DATA_WIDTH-1 : 0] s_filter_tx_ch_data    ;
    logic [1:0]                        s_filter_tx_ch_ready   ;

    logic [1:0] [L2_AWIDTH_NOAL-1 : 0] s_filter_tx_ch_cfg_start_addr;
    logic [1:0]                [1 : 0] s_filter_tx_ch_cfg_datasize;  
    logic [1:0]                [1 : 0] s_filter_tx_ch_cfg_mode;      
    logic [1:0]     [TRANS_SIZE-1 : 0] s_filter_tx_ch_cfg_len0;      
    logic [1:0]     [TRANS_SIZE-1 : 0] s_filter_tx_ch_cfg_len1;      
    logic [1:0]     [TRANS_SIZE-1 : 0] s_filter_tx_ch_cfg_len2;      

    logic                              s_filter_rx_ch_valid;
    logic       [L2_AWIDTH_NOAL-1 : 0] s_filter_rx_ch_addr;
    logic           [DATA_WIDTH-1 : 0] s_filter_rx_ch_data;
    logic                      [1 : 0] s_filter_rx_ch_datasize;
    logic                              s_filter_rx_ch_ready;

    logic       [L2_AWIDTH_NOAL-1 : 0] s_filter_rx_ch_cfg_start_addr;
    logic                      [1 : 0] s_filter_rx_ch_cfg_datasize;  
    logic                      [1 : 0] s_filter_rx_ch_cfg_mode;      
    logic           [TRANS_SIZE-1 : 0] s_filter_rx_ch_cfg_len0;      
    logic           [TRANS_SIZE-1 : 0] s_filter_rx_ch_cfg_len1;      
    logic           [TRANS_SIZE-1 : 0] s_filter_rx_ch_cfg_len2; 

    logic                        [2:0] s_filter_cfg_mode;
    logic                              s_filter_cfg_start;

    logic                              s_au_cfg_use_signed;
    logic                              s_au_cfg_bypass;
    logic                        [3:0] s_au_cfg_mode;
    logic                        [4:0] s_au_cfg_shift;
    logic                       [31:0] s_au_cfg_reg0;
    logic                       [31:0] s_au_cfg_reg1;

    logic                       [31:0] s_bincu_cfg_threshold;
    logic             [TRANS_SIZE-1:0] s_bincu_cfg_counter  ;

    logic         [FILTID_WIDTH-1 : 0] s_filter_stream_id;
    logic           [DATA_WIDTH-1 : 0] s_filter_stream_data;
    logic                              s_filter_stream_valid;
    logic                              s_filter_stream_evnt;
    logic                              s_filter_stream_ready;

    logic        [31:0] s_periph_data_to;
    logic         [4:0] s_periph_addr;
    logic               s_periph_rwn;
    logic [15:0] [31:0] s_periph_data_from;
    logic [15:0]        s_periph_valid;
    logic [15:0]        s_periph_ready;

    logic               s_periph_ready_from_cgunit;
    logic        [31:0] s_periph_data_from_cgunit;
    logic        [15:0] s_cg_value;

    assign periph_data_to_o = s_periph_data_to;
    assign periph_addr_o    = s_periph_addr;
    assign periph_rwn_o     = s_periph_rwn;
    assign periph_valid_o   = s_periph_valid[N_PERIPHS-1:0];

  udma_tx_channels
  #(
      .L2_DATA_WIDTH(L2_DATA_WIDTH),
      .L2_ADDR_WIDTH(L2_ADDR_WIDTH),
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .DATA_WIDTH(32),
      .N_CHANNELS(N_TX_CHANNELS),
      .TRANS_SIZE(TRANS_SIZE)
    ) u_tx_channels (
      .clk_i(s_clk_core),
      .rstn_i(HRESETn),
    
      .l2_req_o(tx_l2_req_o),
      .l2_gnt_i(tx_l2_gnt_i),
      .l2_addr_o(tx_l2_addr_o),
      .l2_rdata_i(tx_l2_rdata_i),
      .l2_rvalid_i(tx_l2_rvalid_i),
      
      .ch_req_i(tx_ch_req_i),
      .ch_gnt_o(tx_ch_gnt_o),
      .ch_valid_o(tx_ch_valid_o),
      .ch_data_o(tx_ch_data_o),
      .ch_ready_i(tx_ch_ready_i),
      .ch_datasize_i(tx_ch_datasize_i),
      .ch_events_o(tx_ch_events_o),
      .ch_en_o(tx_ch_en_o),
      .ch_pending_o(tx_ch_pending_o),
      .ch_curr_addr_o(tx_ch_curr_addr_o),
      .ch_bytes_left_o(tx_ch_bytes_left_o),
      
      .filter_ch_req_i     ( s_filter_tx_ch_req     ),
      .filter_ch_addr_i    ( s_filter_tx_ch_addr    ),
      .filter_ch_datasize_i( s_filter_tx_ch_datasize),
      .filter_ch_gnt_o     ( s_filter_tx_ch_gnt     ),
      .filter_ch_valid_o   ( s_filter_tx_ch_valid   ),
      .filter_ch_data_o    ( s_filter_tx_ch_data    ),
      .filter_ch_ready_i   ( s_filter_tx_ch_ready   ),
      
      .cfg_startaddr_i(tx_cfg_startaddr_i),
      .cfg_size_i(tx_cfg_size_i),
      .cfg_continuous_i(tx_cfg_continuous_i),
      .cfg_en_i(tx_cfg_en_i),
      .cfg_clr_i(tx_cfg_clr_i)
    );

  udma_rx_channels
  #(
      .L2_DATA_WIDTH(L2_DATA_WIDTH),
      .L2_ADDR_WIDTH(L2_ADDR_WIDTH),
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .DATA_WIDTH(32),
      .N_CHANNELS(N_RX_CHANNELS),
      .TRANS_SIZE(TRANS_SIZE)
    ) u_rx_channels (
      .clk_i(s_clk_core),
      .rstn_i(HRESETn),
    
      .l2_req_o(rx_l2_req_o),
      .l2_addr_o(rx_l2_addr_o),
      .l2_be_o(rx_l2_be_o),
      .l2_wdata_o(rx_l2_wdata_o),
      .l2_gnt_i(rx_l2_gnt_i), 

      .ch_valid_i(rx_ch_valid_i),
      .ch_data_i(rx_ch_data_i),
      .ch_ready_o(rx_ch_ready_o),
      .ch_datasize_i(rx_ch_datasize_i),
      .ch_events_o(rx_ch_events_o),
      .ch_en_o(rx_ch_en_o),
      .ch_pending_o(rx_ch_pending_o),
      .ch_curr_addr_o(rx_ch_curr_addr_o),
      .ch_bytes_left_o(rx_ch_bytes_left_o),
      
      .filter_ch_valid_i   ( s_filter_rx_ch_valid    ),
      .filter_ch_addr_i    ( s_filter_rx_ch_addr     ),
      .filter_ch_data_i    ( s_filter_rx_ch_data     ),
      .filter_ch_datasize_i( s_filter_rx_ch_datasize ),
      .filter_ch_ready_o   ( s_filter_rx_ch_ready    ),

      .filter_id_o         ( s_filter_stream_id     ),
      .filter_data_o       ( s_filter_stream_data   ),
      .filter_valid_o      ( s_filter_stream_valid  ),
      .filter_sot_o        ( s_filter_stream_sof    ),
      .filter_eot_o        ( s_filter_stream_eof    ),
      .filter_ready_i      ( s_filter_stream_ready  ),
      
      .cfg_startaddr_i(rx_cfg_startaddr_i),
      .cfg_size_i(rx_cfg_size_i),
      .cfg_continuous_i(rx_cfg_continuous_i),
      .cfg_en_i(rx_cfg_en_i),
      .cfg_filter_i(rx_cfg_filter_i),
      .cfg_clr_i(rx_cfg_clr_i)

    );

    udma_filter #(
      .DATA_WIDTH    (DATA_WIDTH    ),
      .FILTID_WIDTH  (FILTID_WIDTH  ),
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .TRANS_SIZE    (TRANS_SIZE    )
    ) u_udma_filter (
        .clk_i                  ( s_clk_filter            ),
        .resetn_i               ( HRESETn                 ),

        .eot_event_o            ( filter_eot_o            ),
        .act_event_o            ( filter_act_o            ),
        
        .cfg_filter_mode_i      ( s_filter_cfg_mode       ),
        .cfg_filter_start_i     ( s_filter_cfg_start      ),

        .cfg_filter_tx_start_addr_i( s_filter_tx_ch_cfg_start_addr ),
        .cfg_filter_tx_datasize_i  ( s_filter_tx_ch_cfg_datasize   ),
        .cfg_filter_tx_mode_i      ( s_filter_tx_ch_cfg_mode       ),
        .cfg_filter_tx_len0_i      ( s_filter_tx_ch_cfg_len0       ),
        .cfg_filter_tx_len1_i      ( s_filter_tx_ch_cfg_len1       ),
        .cfg_filter_tx_len2_i      ( s_filter_tx_ch_cfg_len2       ),

        .cfg_filter_rx_start_addr_i( s_filter_rx_ch_cfg_start_addr ),
        .cfg_filter_rx_datasize_i  ( s_filter_rx_ch_cfg_datasize   ),
        .cfg_filter_rx_mode_i      ( s_filter_rx_ch_cfg_mode       ),
        .cfg_filter_rx_len0_i      ( s_filter_rx_ch_cfg_len0       ),
        .cfg_filter_rx_len1_i      ( s_filter_rx_ch_cfg_len1       ),
        .cfg_filter_rx_len2_i      ( s_filter_rx_ch_cfg_len2       ),

        .cfg_au_use_signed_i       ( s_au_cfg_use_signed ),
        .cfg_au_bypass_i           ( s_au_cfg_bypass     ),
        .cfg_au_mode_i             ( s_au_cfg_mode       ),
        .cfg_au_shift_i            ( s_au_cfg_shift      ),
        .cfg_au_reg0_i             ( s_au_cfg_reg0       ),
        .cfg_au_reg1_i             ( s_au_cfg_reg1       ),

        .cfg_bincu_threshold_i     ( s_bincu_cfg_threshold ),
        .cfg_bincu_counter_i       ( s_bincu_cfg_counter   ),
 
        .filter_tx_ch_req_o     ( s_filter_tx_ch_req      ),
        .filter_tx_ch_addr_o    ( s_filter_tx_ch_addr     ),
        .filter_tx_ch_datasize_o( s_filter_tx_ch_datasize ),
        .filter_tx_ch_gnt_o     ( s_filter_tx_ch_gnt      ),
        .filter_tx_ch_valid_i   ( s_filter_tx_ch_valid    ),
        .filter_tx_ch_data_i    ( s_filter_tx_ch_data     ),
        .filter_tx_ch_ready_o   ( s_filter_tx_ch_ready    ),

        .filter_rx_ch_valid_o   ( s_filter_rx_ch_valid    ),
        .filter_rx_ch_addr_o    ( s_filter_rx_ch_addr     ),
        .filter_rx_ch_data_o    ( s_filter_rx_ch_data     ),
        .filter_rx_ch_datasize_o( s_filter_rx_ch_datasize ),
        .filter_rx_ch_ready_i   ( s_filter_rx_ch_ready    ),

        .filter_id_i            ( s_filter_stream_id      ),
        .filter_data_i          ( s_filter_stream_data    ),
        .filter_datasize_i      ( 2'b00 ),
        .filter_sof_i           ( s_filter_stream_sof     ),
        .filter_eof_i           ( s_filter_stream_eof     ),
        .filter_valid_i         ( s_filter_stream_valid   ),
        .filter_ready_o         ( s_filter_stream_ready   )

    );

    always_comb
    begin
      for(int i=0;i<15;i++)
      begin
        if(i<N_PERIPHS)
        begin
          s_periph_ready[i]  = periph_ready_i[i];
          s_periph_data_from = periph_data_from_i[i];
        end
        else
        begin
          s_periph_ready[i]  = 1'b1;
          s_periph_data_from = 32'h0;
        end
      end
      s_periph_ready[15]     = s_periph_ready_from_cgunit;
      s_periph_data_from[15] = s_periph_data_from_cgunit;
    end

   
    udma_apb_if #(
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH)
    ) u_apb_if (
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),

        .periph_data_o(s_periph_data_to),
        .periph_addr_o(s_periph_addr),
        .periph_data_i(s_periph_data_from),
        .periph_ready_i(s_periph_ready),
        .periph_valid_o(s_periph_valid),
        .periph_rwn_o(s_periph_rwn)
    );

    udma_ctrl #(
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .TRANS_SIZE    (TRANS_SIZE    )
    )  u_udma_ctrl (
        .clk_i(sys_clk_i),
        .rstn_i(HRESETn),

        .cfg_data_i(s_periph_data_to),
        .cfg_addr_i(s_periph_addr),
        .cfg_valid_i(s_periph_valid[15]),
        .cfg_rwn_i(s_periph_rwn),
        .cfg_data_o(s_periph_data_from_cgunit),
        .cfg_ready_o(s_periph_ready_from_cgunit),

        .cfg_filter_tx_start_addr_o( s_filter_tx_ch_cfg_start_addr ),
        .cfg_filter_tx_datasize_o  ( s_filter_tx_ch_cfg_datasize   ),
        .cfg_filter_tx_mode_o      ( s_filter_tx_ch_cfg_mode       ),
        .cfg_filter_tx_len0_o      ( s_filter_tx_ch_cfg_len0       ),
        .cfg_filter_tx_len1_o      ( s_filter_tx_ch_cfg_len1       ),
        .cfg_filter_tx_len2_o      ( s_filter_tx_ch_cfg_len2       ),

        .cfg_filter_rx_start_addr_o( s_filter_rx_ch_cfg_start_addr ),
        .cfg_filter_rx_datasize_o  ( s_filter_rx_ch_cfg_datasize   ),
        .cfg_filter_rx_mode_o      ( s_filter_rx_ch_cfg_mode       ),
        .cfg_filter_rx_len0_o      ( s_filter_rx_ch_cfg_len0       ),
        .cfg_filter_rx_len1_o      ( s_filter_rx_ch_cfg_len1       ),
        .cfg_filter_rx_len2_o      ( s_filter_rx_ch_cfg_len2       ),

        .cfg_filter_mode_o         ( s_filter_cfg_mode   ),
        .cfg_filter_start_o        ( s_filter_cfg_start  ),

        .cfg_au_use_signed_o       ( s_au_cfg_use_signed ),
        .cfg_au_bypass_o           ( s_au_cfg_bypass     ),
        .cfg_au_mode_o             ( s_au_cfg_mode       ),
        .cfg_au_shift_o            ( s_au_cfg_shift      ),
        .cfg_au_reg0_o             ( s_au_cfg_reg0       ),
        .cfg_au_reg1_o             ( s_au_cfg_reg1       ),

        .cfg_bincu_threshold_o     ( s_bincu_cfg_threshold ),
        .cfg_bincu_counter_o       ( s_bincu_cfg_counter   ),

        .cg_value_o(s_cg_value),
        .cg_core_o(s_clk_core_en),

        .rst_value_o(), //TODO 

        .event_valid_i(event_valid_i),
        .event_data_i (event_data_i),
        .event_ready_o(event_ready_o),

        .event_o(event_o)
    );

    pulp_clock_gating i_clk_gate_sys_udma
    (
        .clk_i(sys_clk_i),
        .en_i(s_clk_core_en),
        .test_en_i(dft_cg_enable_i),
        .clk_o(s_clk_core)
    );

    pulp_clock_gating i_clk_gate_filter
    (
        .clk_i(s_clk_core),
        .en_i(s_cg_value[15]),
        .test_en_i(dft_cg_enable_i),
        .clk_o(s_clk_filter)
    );

    genvar i;
    generate
      for (i=0;i<N_PERIPHS;i++)
      begin
        pulp_clock_gating_async i_clk_gate_per
        (
            .clk_i(per_clk_i),
            .rstn_i(HRESETn),
            .en_async_i(s_cg_value[i]),
            .en_ack_o(),
            .test_en_i(dft_cg_enable_i),
            .clk_o(periph_per_clk_o[i])
        );
    
        pulp_clock_gating i_clk_gate_sys
        (
            .clk_i(s_clk_core),
            .en_i(s_cg_value[i]),
            .test_en_i(dft_cg_enable_i),
            .clk_o(periph_sys_clk_o[i])
        );
      end
    endgenerate

endmodule
