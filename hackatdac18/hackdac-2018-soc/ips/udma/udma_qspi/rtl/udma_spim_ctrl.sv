// Copyright 2016 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Pullini Antonio - pullinia@iis.ee.ethz.ch                  //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
// Design Name:    SPI Master Control State Machine                           //
// Project Name:   SPI Master                                                 //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    SPI Master with full QPI support                           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
`define SPI_STD     2'b00
`define SPI_QUAD_TX 2'b01
`define SPI_QUAD_RX 2'b10

`define SPI_CMD_CFG       4'b0000
`define SPI_CMD_SOT       4'b0001
`define SPI_CMD_SEND_CMD  4'b0010
`define SPI_CMD_SEND_ADDR 4'b0011
`define SPI_CMD_DUMMY     4'b0100
`define SPI_CMD_WAIT      4'b0101
`define SPI_CMD_TX_DATA   4'b0110
`define SPI_CMD_RX_DATA   4'b0111
`define SPI_CMD_RPT       4'b1000
`define SPI_CMD_EOT       4'b1001
`define SPI_CMD_RPT_END   4'b1010
`define SPI_CMD_RX_CHECK  4'b1011
`define SPI_CMD_FULL_DUPL 4'b1100
`define SPI_CMD_WAIT_CYC  4'b1101


module udma_spim_ctrl
(
    input  logic                          clk_i,
    input  logic                          rstn_i,
    output logic                          eot_o,

    input  logic   [3:0]                  event_i,

    output logic                          cfg_cpol_o,
    output logic                          cfg_cpha_o,

    output logic   [7:0]                  cfg_clkdiv_data_o,
    output logic                          cfg_clkdiv_valid_o,
    input  logic                          cfg_clkdiv_ack_i,

    output logic                          tx_start_o,
    output logic  [15:0]                  tx_size_o,
    output logic                          tx_customsize_o,
    output logic                          tx_qpi_o,
    input  logic                          tx_done_i,
    output logic  [31:0]                  tx_data_o,
    output logic                          tx_data_valid_o,
    input  logic                          tx_data_ready_i,

    output logic                          rx_start_o,
    output logic  [15:0]                  rx_size_o,
    output logic                          rx_customsize_o,
    output logic                          rx_qpi_o,
    input  logic                          rx_done_i,
    input  logic  [31:0]                  rx_data_i,
    input  logic                          rx_data_valid_i,
    output logic                          rx_data_ready_o,

    input  logic  [31:0]                  udma_tx_data_i,
    input  logic                          udma_tx_data_valid_i,
    output logic                          udma_tx_data_ready_o,
    output logic  [31:0]                  udma_rx_data_o,
    output logic                          udma_rx_data_valid_o,
    input  logic                          udma_rx_data_ready_i,

    output logic                          spi_csn0_o,
    output logic                          spi_csn1_o,
    output logic                          spi_csn2_o,
    output logic                          spi_csn3_o
);

    enum logic [2:0] {IDLE,WAIT_DONE,WAIT_CHECK,WAIT_EVENT,WAIT_ADDR,DO_REPEAT,WAIT_CYCLE,CLEAR_CS} state,state_next;
    enum logic [3:0] {RPT_CS,RPT_CMD,RPT_ADDR,RPT_DUMMY,RPT_TX,RPT_RX,RPT_RX_CHK,RPT_CLEAR_CS,RPT_WAIT} r_rptstate,s_rptstate_next;

    logic s_cfg_cpol;
    logic s_cfg_cpha;
    logic r_cfg_cpol;
    logic r_cfg_cpha;
    logic [7:0] s_cfg_clkdiv;
    logic [7:0] r_cfg_clkdiv;
    logic s_update_cfg;
    logic r_update_cfg;
    logic s_update_qpi;
    logic s_update_cs;
    logic s_update_evt;
    logic s_update_chk;
    logic s_clear_cs;

    logic s_event;

    logic [1:0] s_evt_sel;
    logic [1:0] r_evt_sel;

    logic is_cmd_cfg;
    logic is_cmd_sot;
    logic is_cmd_snc;
    logic is_cmd_sna;
    logic is_cmd_dum;
    logic is_cmd_wai;
    logic is_cmd_txd;
    logic is_cmd_rxd;
    logic is_cmd_rxc;
    logic is_cmd_rpt;
    logic is_cmd_rpe;
    logic is_cmd_eot;
    logic is_cmd_ful;
    logic is_cmd_wcy;

    logic  [3:0] s_cmd;
    logic  [1:0] s_cs;
    logic        s_cfg_custom;
    logic        s_cfg_qpi;
    logic  [1:0] s_cfg_cs;
    logic [15:0] s_cfg_check;
    logic [15:0] s_size_long;
    logic [15:0] s_cmd_data;
    logic  [4:0] s_size;
    logic        s_gen_eot;
    logic        s_qpi;
    logic        r_qpi;
    logic [15:0] r_chk;
    logic  [1:0] r_chk_type;
    logic  [1:0] s_cfg_chk_type;
    logic        s_is_dummy;
    logic        r_is_dummy;

    logic        s_update_rpt;
    logic        r_rpt_cfg;
    logic [15:0] r_rpt_num;
    logic [15:0] s_rpt_num;

    logic        s_rpt_update_cs;
    logic  [1:0] r_rpt_cs;
    logic  [1:0] s_rpt_cs;

    logic        s_rpt_update_cmd;
    logic        r_rpt_do_cmd;
    logic        s_rpt_do_cmd;
    logic [20:0] r_rpt_cmd;
    logic [20:0] s_rpt_cmd;

    logic        s_rpt_update_rx_chk;
    logic        r_rpt_do_rx_chk;
    logic        s_rpt_do_rx_chk;
    logic [20:0] r_rpt_rx_chk;
    logic [20:0] s_rpt_rx_chk;

    logic        s_rpt_update_addr;
    logic        r_rpt_do_addr;
    logic        s_rpt_do_addr;
    logic [37:0] r_rpt_addr;
    logic [37:0] s_rpt_addr;

    logic        s_rpt_update_dummy;
    logic        r_rpt_do_dummy;
    logic        s_rpt_do_dummy;
    logic  [4:0] r_rpt_dummy;
    logic  [4:0] s_rpt_dummy;

    logic        r_rpt_do_wait;
    logic        s_rpt_do_wait;

    logic        s_rpt_update_read;
    logic        r_rpt_do_read;
    logic        s_rpt_do_read;
    logic [17:0] r_rpt_read;
    logic [17:0] s_rpt_read;

    logic        s_rpt_update_write;
    logic        r_rpt_do_write;
    logic        s_rpt_do_write;
    logic [17:0] r_rpt_write;
    logic [17:0] s_rpt_write;

    logic        s_rpt_do_ful;
    logic        r_rpt_do_ful;
    logic        s_rpt_update_ful;
    logic [15:0] s_rpt_ful;
    logic [15:0] r_rpt_ful;

    logic        s_is_ful;
    logic        r_is_ful;

    logic        s_done;
    logic        r_tx_done;
    logic        r_rx_done;

    logic        s_is_repeating;
    logic        r_is_repeating;

    logic        s_update_chk_result;
    logic        s_chk_result;
    logic        r_chk_result;

    logic  [7:0] s_wait_cycle;

    assign s_cmd        = udma_tx_data_i[31:28];
    assign s_cfg_cpol   = udma_tx_data_i[9];
    assign s_cfg_cpha   = udma_tx_data_i[8];
    assign s_cfg_clkdiv = udma_tx_data_i[7:0];
    assign s_cfg_cs     = udma_tx_data_i[1:0];
    assign s_size       = udma_tx_data_i[20:16];
    assign s_size_long  = udma_tx_data_i[15:0];
    assign s_cfg_qpi    = udma_tx_data_i[27];
    assign s_cfg_custom = udma_tx_data_i[26];
    assign s_cmd_data   = udma_tx_data_i[15:0];
    assign s_gen_eot    = udma_tx_data_i[0];
    assign s_cfg_check  = udma_tx_data_i[15:0];
    assign s_cfg_chk_type = udma_tx_data_i[25:24];

    assign s_evt_sel    = udma_tx_data_i[1:0];
    assign s_wait_cycle = udma_tx_data_i[7:0];

    assign cfg_cpol_o = r_cfg_cpol;
    assign cfg_cpha_o = r_cfg_cpha;

    assign cfg_clkdiv_data_o = r_cfg_clkdiv;

    assign s_done = r_is_ful ? ((tx_done_i | r_tx_done) & (rx_done_i | r_rx_done)) : (tx_done_i | rx_done_i);

    edge_propagator_tx i_edgeprop
    (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .valid_i(r_update_cfg),
      .ack_i(cfg_clkdiv_ack_i),
      .valid_o(cfg_clkdiv_valid_o)
    );

  enum logic [1:0] { S_CNT_IDLE, S_CNT_RUNNING} r_cnt_state,s_cnt_state_next;

  logic            s_cnt_done;
  logic            s_cnt_start;
  logic            s_cnt_update;
  logic            s_cnt_clr;
  logic      [7:0] s_cnt_target; 
  logic      [7:0] r_cnt_target; 
  logic      [7:0] r_cnt; 
  logic      [7:0] s_cnt_next; 

  always_ff @(posedge clk_i, negedge rstn_i)
  begin
    if(~rstn_i) 
    begin
      r_cnt_state <= S_CNT_IDLE;
      r_cnt <= 'h0;
      r_cnt_target <= 'h0;
    end
    else
    begin
      if (s_cnt_start)
        r_cnt_target <= s_cnt_target;
      if (s_cnt_start || s_cnt_done)
        r_cnt_state <= s_cnt_state_next;
      if (s_cnt_update)
        r_cnt <= s_cnt_next;
    end
  end

  always_comb begin
    s_cnt_update = 1'b0;
    s_cnt_state_next = r_cnt_state;
    s_cnt_done   = 1'b0;
    s_cnt_next   = r_cnt;
    case (r_cnt_state)
      S_CNT_IDLE:
      begin
        if(s_cnt_start)
          s_cnt_state_next = S_CNT_RUNNING;
      end
      S_CNT_RUNNING:
      begin
        s_cnt_update = 1'b1;
        if (r_cnt_target == r_cnt)
        begin
          s_cnt_next =  'h0;
          s_cnt_done = 1'b1;
          if (~s_cnt_start)
            s_cnt_state_next = S_CNT_IDLE;
        end
        else
        begin
          s_cnt_next = r_cnt + 1;
        end
      end
    endcase // r_cnt_state
  end

    // Command decoding logic
    always_comb
    begin
        is_cmd_cfg  = 1'b0;
        is_cmd_sot  = 1'b0;
        is_cmd_snc  = 1'b0;
        is_cmd_sna  = 1'b0;
        is_cmd_dum  = 1'b0;
        is_cmd_wai  = 1'b0;
        is_cmd_txd  = 1'b0;
        is_cmd_rxd  = 1'b0;
        is_cmd_rxc  = 1'b0;
        is_cmd_rpt  = 1'b0;
        is_cmd_eot  = 1'b0;
        is_cmd_rpe  = 1'b0;
        is_cmd_ful  = 1'b0;
        is_cmd_wcy  = 1'b0;

        case(s_cmd)
            `SPI_CMD_CFG:
                is_cmd_cfg = 1'b1;
            `SPI_CMD_SOT:
                is_cmd_sot  = 1'b1;
            `SPI_CMD_SEND_CMD:
                is_cmd_snc  = 1'b1;
            `SPI_CMD_SEND_ADDR:
                is_cmd_sna  = 1'b1;
            `SPI_CMD_DUMMY:
                is_cmd_dum  = 1'b1;
            `SPI_CMD_WAIT:
                is_cmd_wai  = 1'b1;
            `SPI_CMD_TX_DATA:
                is_cmd_txd  = 1'b1;
            `SPI_CMD_RX_DATA:
                is_cmd_rxd  = 1'b1;
            `SPI_CMD_RX_CHECK:
                is_cmd_rxc  = 1'b1;
            `SPI_CMD_RPT:
                is_cmd_rpt  = 1'b1;
            `SPI_CMD_RPT_END:
                is_cmd_rpe  = 1'b1;
            `SPI_CMD_EOT:
                is_cmd_eot  = 1'b1;
            `SPI_CMD_FULL_DUPL:
                is_cmd_ful  = 1'b1;
            `SPI_CMD_WAIT_CYC:
                is_cmd_wcy  = 1'b1;
        endcase
    end

    always_comb begin : proc_s_event
        s_event = 1'b0;
        for(int i=0;i<4;i++)
            if(r_evt_sel == i)
                s_event = event_i[i];
    end

    always_comb
    begin
        state_next           = state;
        s_rptstate_next      = r_rptstate;
        udma_tx_data_ready_o = 1'b0;
        udma_rx_data_o       =  'h0;
        udma_rx_data_valid_o = 1'b0;
        rx_data_ready_o      = 1'b0;
        s_update_chk         = 1'b0;
        s_update_cfg         = 1'b0;
        s_update_cs          = 1'b0;
        s_update_qpi         = 1'b0;
        s_update_evt         = 1'b0;
        s_clear_cs           = 1'b0;
        tx_size_o            =  'h0;
        rx_size_o            =  'h0;
        tx_customsize_o      = 1'b0;
        rx_customsize_o      = 1'b0;
        tx_qpi_o             = r_qpi;
        rx_qpi_o             = r_qpi;
        tx_start_o           = 1'b0;
        rx_start_o           = 1'b0;
        tx_data_o            =  'h0;
        tx_data_valid_o      = 1'b0;
        eot_o                = 1'b0;
        s_is_dummy           = r_is_dummy;
        s_qpi                = r_qpi;

        s_rpt_num            = r_rpt_num;
        s_update_rpt         = 1'b0;
        s_is_repeating       = r_is_repeating;
        s_is_ful             = r_is_ful;
        s_update_chk_result  = 1'b0;
        s_chk_result         = 1'b0;
        s_rpt_update_cs      = 1'b0;
        s_rpt_update_cmd     = 1'b0;
        s_rpt_update_addr    = 1'b0;
        s_rpt_update_dummy   = 1'b0;
        s_rpt_update_write   = 1'b0;
        s_rpt_update_read    = 1'b0;
        s_rpt_update_rx_chk  = 1'b0;
        s_rpt_update_ful     = 1'b0; // FORGOTTEN DEFAULT --> LATCH

        s_cnt_start          = 1'b0;
        s_cnt_target         =  'h0;

        s_rpt_cs             = r_rpt_cs;
        s_rpt_cmd            = r_rpt_cmd;
        s_rpt_addr           = r_rpt_addr;
        s_rpt_read           = r_rpt_read;
        s_rpt_write          = r_rpt_write;
        s_rpt_ful            = r_rpt_ful;
        s_rpt_dummy          = r_rpt_dummy;
        s_rpt_rx_chk         = r_rpt_rx_chk;

   
        s_rpt_do_cmd         = r_rpt_do_cmd  ;
        s_rpt_do_addr        = r_rpt_do_addr ;
        s_rpt_do_dummy       = r_rpt_do_dummy;
        s_rpt_do_write       = r_rpt_do_write;
        s_rpt_do_read        = r_rpt_do_read ;
        s_rpt_do_rx_chk      = r_rpt_do_rx_chk ;
        s_rpt_do_wait        = r_rpt_do_wait ;
        s_rpt_do_ful         = r_rpt_do_ful;

        case(state)
            IDLE:
            begin
                s_is_ful = 1'b0;
                s_is_repeating = 1'b0;
                if(udma_tx_data_valid_i)
                begin
                    udma_tx_data_ready_o = 1'b1;
                    if(is_cmd_cfg)
                        s_update_cfg = 1'b1;
                    else if (is_cmd_sot)
                    begin
                        if (r_rpt_cfg)
                        begin
                            s_rpt_update_cs = 1'b1;
                            s_rpt_cs = s_cs;
                        end
                        else
                            s_update_cs = 1'b1;
                    end
                    else if(is_cmd_snc)
                    begin
                        if (r_rpt_cfg)
                        begin
                            s_rpt_do_cmd     = 1'b1;
                            s_rpt_update_cmd = 1'b1;
                            s_rpt_cmd        = {s_cfg_qpi,s_size[3:0],s_cmd_data};
                            state_next       = IDLE;
                        end
                        else
                        begin
                            s_update_qpi    = 1'b1;
                            tx_start_o      = 1'b1;
                            tx_customsize_o = 1'b1;
                            tx_qpi_o        = s_cfg_qpi;
                            s_qpi           = s_cfg_qpi;
                            tx_size_o       = {11'h0,s_size};
                            state_next      = WAIT_DONE;
                            tx_data_valid_o = 1'b1;
                            tx_data_o       = {s_cmd_data,16'h0};
                        end
                    end
                    else if(is_cmd_wai)
                    begin
                        s_update_evt      = 1'b1;
                        if (r_rpt_cfg)
                        begin
                            state_next    = IDLE;
                            s_rpt_do_wait = 1'b1;
                        end
                        else
                            state_next   = WAIT_EVENT;
                    end
                    else if(is_cmd_wcy)
                    begin
                        s_cnt_start  = 1'b1;
                        s_cnt_target = s_wait_cycle;
                        state_next   = WAIT_CYCLE;
                    end
                    else if(is_cmd_sna)
                    begin
                        if (r_rpt_cfg)
                        begin
                            s_rpt_do_addr     = 1'b1;
                            s_rpt_update_addr = 1'b1;
                            s_rpt_addr        = {s_cfg_qpi,s_size[4:0],32'h0};
                            state_next        = WAIT_ADDR;
                        end
                        else
                        begin
                            s_update_qpi = 1'b1;
                            tx_start_o   = 1'b1;
                            tx_customsize_o = 1'b1;
                            tx_qpi_o     = s_cfg_qpi;
                            s_qpi        = s_cfg_qpi;
                            tx_size_o    = {11'h0,s_size};
                            state_next   = WAIT_DONE;
                        end
                    end
                    else if(is_cmd_dum)
                    begin
                        if (r_rpt_cfg)
                        begin
                            s_rpt_do_dummy     = 1'b1;
                            s_rpt_update_dummy = 1'b1;
                            s_rpt_dummy        = s_size;
                            state_next         = IDLE;
                        end
                        else
                        begin
                            s_update_qpi = 1'b1;
                            rx_start_o   = 1'b1;
                            rx_customsize_o = 1'b0;
                            rx_qpi_o     = s_cfg_qpi;
                            s_qpi        = s_cfg_qpi;
                            rx_size_o    = {11'h0,s_size};
                            state_next   = WAIT_DONE;
                            s_is_dummy   = 1'b1;
                        end
                    end
                    else if(is_cmd_txd)
                    begin
                        if (r_rpt_cfg)
                        begin
                            s_rpt_do_write     = 1'b1;
                            s_rpt_update_write = 1'b1;
                            s_rpt_write        = {s_cfg_custom,s_cfg_qpi,s_size_long};
                            state_next         = IDLE;
                        end
                        else
                        begin
                            s_update_qpi = 1'b1;
                            tx_start_o   = 1'b1;
                            tx_customsize_o = s_cfg_custom;
                            tx_qpi_o     = s_cfg_qpi;
                            s_qpi        = s_cfg_qpi;
                            tx_size_o    = s_size_long;
                            state_next   = WAIT_DONE;
                        end
                    end
                    else if(is_cmd_rxd)
                    begin
                        if (r_rpt_cfg)
                        begin
                            s_rpt_do_read     = 1'b1;
                            s_rpt_update_read = 1'b1;
                            s_rpt_read        = {s_cfg_custom,s_cfg_qpi,s_size_long};
                            state_next        = IDLE;
                        end
                        else
                        begin
                            s_update_qpi = 1'b1;
                            rx_start_o   = 1'b1;
                            rx_customsize_o = s_cfg_custom;
                            rx_qpi_o     = s_cfg_qpi;
                            s_qpi        = s_cfg_qpi;
                            rx_size_o    = s_size_long;
                            state_next   = WAIT_DONE;
                        end
                    end
                    else if(is_cmd_ful)
                    begin
                        if (r_rpt_cfg)
                        begin
                            s_rpt_do_ful      = 1'b1;
                            s_rpt_update_ful  = 1'b1;
                            s_rpt_ful         = s_size_long;
                            state_next        = IDLE;
                        end
                        else
                        begin
                            s_is_ful     = 1'b1;
                            s_update_qpi = 1'b1;
                            rx_start_o   = 1'b1;
                            s_qpi        = 1'b0;
                            rx_qpi_o     = 1'b0;
                            rx_size_o    = s_size_long;
                            tx_start_o   = 1'b1;
                            tx_customsize_o = s_cfg_custom;
                            tx_qpi_o     = 1'b0;
                            tx_size_o    = s_size_long;
                            state_next   = WAIT_DONE;
                        end
                    end
                    else if(is_cmd_rxc)
                    begin
                        if (r_rpt_cfg)
                        begin
                            s_rpt_do_rx_chk     = 1'b1;
                            s_rpt_update_rx_chk = 1'b1;
                            s_rpt_rx_chk        = {s_cfg_custom,s_cfg_qpi,s_size[3:0]};
                            s_update_chk        = 1'b1;
                            state_next          = IDLE;
                        end
                        else
                        begin
                            state_next   = IDLE;
                        end
                    end
                    else if(is_cmd_rpt || is_cmd_rpe)
                    begin
                        s_update_rpt = 1'b1;
                        if (is_cmd_rpt)
                        begin
                            state_next   = IDLE;
                            s_rpt_num    = s_size_long;
                        end
                        else
                            state_next   = DO_REPEAT;
                    end
                    else if(is_cmd_eot)
                    begin
                        eot_o      = s_gen_eot;
                        state_next = CLEAR_CS;
                    end
                end
            end 
            WAIT_ADDR:
            begin
                if(udma_tx_data_valid_i)
                begin
                    udma_tx_data_ready_o = 1'b1;
                    s_rpt_update_addr    = 1'b1;
                    s_rpt_addr = {r_rpt_addr[37:32],udma_tx_data_i};
                    state_next = IDLE;
                end
            end
            DO_REPEAT:
            begin
                s_is_repeating  = 1'b1;
                s_rptstate_next = r_rptstate;
                state_next = DO_REPEAT;
                if (r_rpt_num == 0)
                begin
                    s_is_repeating = 1'b0;
                    state_next     = IDLE;
                end
                else
                begin
                    case(r_rptstate)
                        RPT_CS:
                        begin
                            s_update_cs = 1'b1;
                            s_rptstate_next = RPT_CMD;
                        end
                        RPT_CMD:
                        begin
                            if (r_rpt_do_cmd)
                            begin
                                s_update_qpi    = 1'b1;
                                tx_start_o      = 1'b1;
                                tx_customsize_o = 1'b1;
                                tx_qpi_o        = r_rpt_cmd[20];
                                tx_size_o       = {12'h0,r_rpt_cmd[19:16]};
                                state_next      = WAIT_DONE;
                                tx_data_valid_o = 1'b1;
                                tx_data_o       = {r_rpt_cmd[15:0],16'h0};
                            end
                            s_rptstate_next = RPT_ADDR;
                        end
                        RPT_ADDR:
                        begin
                            if (r_rpt_do_addr)
                            begin
                                s_update_qpi    = 1'b1;
                                tx_start_o      = 1'b1;
                                tx_customsize_o = 1'b1;
                                tx_qpi_o        = r_rpt_addr[37];
                                tx_size_o       = {11'h0,r_rpt_addr[36:32]};
                                state_next      = WAIT_DONE;
                                tx_data_valid_o = 1'b1;
                                tx_data_o       = {r_rpt_addr[31:0]};
                            end
                            s_rptstate_next = RPT_DUMMY;
                        end
                        RPT_DUMMY:
                        begin
                            if(r_rpt_do_dummy)
                            begin
                                s_update_qpi = 1'b1;
                                rx_start_o   = 1'b1;
                                rx_customsize_o = 1'b0;
                                rx_qpi_o     = 1'b0;
                                rx_size_o    = {11'h0,r_rpt_dummy};
                                state_next   = WAIT_DONE;
                                s_is_dummy   = 1'b1;
                            end
                            s_rptstate_next = RPT_TX;
                        end
                        RPT_TX:
                        begin
                            if (r_rpt_do_write)
                            begin
                                s_update_qpi    = 1'b1;
                                tx_start_o      = 1'b1;
                                tx_customsize_o = r_rpt_write[17];
                                tx_qpi_o        = r_rpt_write[16];
                                tx_size_o       = r_rpt_write[15:0];
                                state_next      = WAIT_DONE;
                            end
                            s_rptstate_next = r_rpt_do_rx_chk ? RPT_RX_CHK : RPT_RX;
                        end
                        RPT_RX:
                        begin
                            if (r_rpt_do_read)
                            begin
                                s_update_qpi    = 1'b1;
                                rx_start_o      = 1'b1;
                                rx_customsize_o = r_rpt_read[17];
                                rx_qpi_o        = r_rpt_read[16];
                                rx_size_o       = r_rpt_read[15:0];
                                state_next      = WAIT_DONE;
                            end
                            s_rptstate_next = RPT_CLEAR_CS;
                        end
                        RPT_RX_CHK:
                        begin
                            if (r_rpt_do_rx_chk)
                            begin
                                s_update_qpi    = 1'b1;
                                rx_start_o      = 1'b1;
                                rx_customsize_o = r_rpt_rx_chk[5];
                                rx_qpi_o        = r_rpt_rx_chk[4];
                                rx_size_o       = {12'h0,r_rpt_rx_chk[3:0]};
                                state_next      = WAIT_CHECK;
                            end
                            s_rptstate_next = RPT_CLEAR_CS;
                        end
                        RPT_CLEAR_CS:
                        begin
                                s_rptstate_next = RPT_WAIT;
                        end
                        RPT_WAIT:
                        begin
                            s_clear_cs = 1'b1;
                            s_rptstate_next = RPT_CS;
                            s_rpt_num = r_rpt_num - 1;
                            if (r_chk_result)
                                state_next = IDLE;
                            else if (r_rpt_do_wait)
                                state_next   = WAIT_EVENT;
                        end
                        default:
                            s_rptstate_next = RPT_CS;
                    endcase
                end
            end
            WAIT_DONE:
            begin
                if(s_done)
                begin
                    if (r_is_repeating)
                        state_next = DO_REPEAT;
                    else
                        state_next = IDLE;
                    s_is_dummy = 1'b0;
                end
                tx_data_o            = udma_tx_data_i;
                tx_data_valid_o      = udma_tx_data_valid_i;
                udma_tx_data_ready_o = tx_data_ready_i;

                udma_rx_data_o       = rx_data_i;
                udma_rx_data_valid_o = r_is_dummy ? 1'b0 : rx_data_valid_i;
                rx_data_ready_o      = udma_rx_data_ready_i;
            end            
            WAIT_CHECK:
            begin
                if(rx_done_i)
                begin
                    if (r_is_repeating)
                        state_next = DO_REPEAT;
                    else
                        state_next = IDLE;
                    s_is_dummy = 1'b0;
                end

                if (rx_data_valid_i)
                begin
                    s_update_chk_result = 1'b1;
                    case(r_chk_type)
                        2'b00:  //check the whole word
                        begin
                            if (rx_data_i[15:0] == r_chk)
                                s_chk_result = 1'b1;
                        end
                        2'b01:  //check only ones
                        begin
                            if ( (rx_data_i[15:0] & r_chk) == r_chk )
                                s_chk_result = 1'b1;
                        end
                        2'b10:  //check only zeros
                        begin
                            if ( (~rx_data_i[15:0] & ~r_chk) == ~r_chk )
                                s_chk_result = 1'b1;
                        end
                        default:
                            s_chk_result = 1'b0;
                    endcase // r_chk_type
                end
                rx_data_ready_o      = 1'b1;
            end
            WAIT_EVENT:
            begin
                if(s_event)
                begin
                    if (r_is_repeating)
                        state_next = DO_REPEAT;
                    else
                        state_next = IDLE;
                end
            end
            WAIT_CYCLE:
            begin
                if(s_cnt_done)
                begin
                    state_next = IDLE;
                end
            end
            CLEAR_CS:
            begin
                s_clear_cs = 1'b1;
                state_next = IDLE;
            end
            default:
                state_next = IDLE;
        endcase
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin : proc_r_chk_result
        if(~rstn_i) begin
            r_chk_result <= 0;
        end else begin
            if(s_update_chk_result)
                r_chk_result <= s_chk_result;
        end
    end

    always_ff @(posedge clk_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            state      <= IDLE;
            r_rptstate <= RPT_CS;
        end
        else
        begin
            state      <= state_next;
            r_rptstate <= s_rptstate_next;
        end

    end

    always_ff @(posedge clk_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            r_cfg_cpol <= 1'b0;
            r_cfg_cpha <= 1'b0;
            r_cfg_clkdiv <= 'h0;
        end
        else
        begin
            if(s_update_cfg) begin
                r_cfg_cpol   <= s_cfg_cpol;
                r_cfg_cpha   <= s_cfg_cpha;
                r_cfg_clkdiv <= s_cfg_clkdiv;
            end
        end

    end

    always_ff @(posedge clk_i or negedge rstn_i) begin : proc_r_update_cfg
        if(~rstn_i) begin
            r_update_cfg <= 0;
        end else begin
            r_update_cfg <= s_update_cfg;
        end
    end

    always_ff @(posedge clk_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            r_qpi       <= 1'b0;
            r_is_dummy  <= 1'b0;
            r_evt_sel   <=  'h0;
            r_is_ful    <= 1'b0;
            r_tx_done   <= 1'b0;
            r_rx_done   <= 1'b0;
            r_chk_type  <= 0;
            r_chk       <= 0;
        end
        else
        begin

            r_is_ful  <= s_is_ful;
            r_tx_done <= tx_done_i;
            r_rx_done <= rx_done_i;

            if(s_update_chk)
            begin
                r_chk_type   <= s_cfg_chk_type;
                r_chk        <= s_cfg_check;
            end

            if(s_update_qpi) 
                r_qpi <= s_qpi;

            if(s_update_evt)
                r_evt_sel <= s_evt_sel;

            r_is_dummy <= s_is_dummy;
        end
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin : proc_rpt
        if(~rstn_i) begin
            r_rpt_cmd       <= 0;
            r_rpt_addr      <= 0;
            r_rpt_dummy     <= 0;
            r_rpt_write     <= 0;
            r_rpt_read      <= 0;
            r_rpt_ful       <= 0;
            r_rpt_do_cmd    <= 0;
            r_rpt_do_addr   <= 0;
            r_rpt_do_dummy  <= 0;
            r_rpt_do_write  <= 0;
            r_rpt_do_read   <= 0;
            r_rpt_do_wait   <= 0;
            r_rpt_do_rx_chk <= 0;
            r_rpt_do_ful    <= 0;
            r_rpt_num       <= 0;
            r_rpt_cfg       <= 0;
            r_is_repeating  <= 0;
            r_rpt_rx_chk    <= 0;
            r_rpt_cs        <= 0;
        end else begin
            r_rpt_num      <= s_rpt_num;
            r_is_repeating <= s_is_repeating;

            if (s_update_rpt)
                if (is_cmd_rpt)
                    r_rpt_cfg <= 1'b1;
                else
                    r_rpt_cfg <= 1'b0;

            if (s_rpt_update_cs)
                r_rpt_cs <= s_rpt_cs;
            if (s_rpt_update_cmd)
                r_rpt_cmd <= s_rpt_cmd;
            if (s_rpt_update_addr)
                r_rpt_addr <= s_rpt_addr;
            if (s_rpt_update_dummy)
                r_rpt_dummy <= s_rpt_dummy;
            if (s_rpt_update_write)
                r_rpt_write <= s_rpt_write;
            if (s_rpt_update_read)
                r_rpt_read <= s_rpt_read;
            if (s_rpt_update_ful)
                r_rpt_ful  <= s_rpt_ful;
            if (s_rpt_update_rx_chk)
            begin
                r_rpt_rx_chk <= s_rpt_rx_chk;
            end

            r_rpt_do_cmd    <= s_rpt_do_cmd  ;
            r_rpt_do_addr   <= s_rpt_do_addr ;
            r_rpt_do_dummy  <= s_rpt_do_dummy;
            r_rpt_do_write  <= s_rpt_do_write;
            r_rpt_do_read   <= s_rpt_do_read ;
            r_rpt_do_wait   <= s_rpt_do_wait ;
            r_rpt_do_rx_chk <= s_rpt_do_rx_chk ;
            r_rpt_do_ful    <= s_rpt_do_ful;
        end
    end

    assign s_cs = (s_is_repeating | r_is_repeating) ? r_rpt_cs : s_cfg_cs;

    always_ff @(posedge clk_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            spi_csn0_o <= 1'b1;
            spi_csn1_o <= 1'b1;
            spi_csn2_o <= 1'b1;
            spi_csn3_o <= 1'b1;
        end
        else
        begin
            if(s_update_cs) begin
                case(s_cs)
                    2'b00:
                        spi_csn0_o <= 1'b0;
                    2'b01:
                        spi_csn1_o <= 1'b0;
                    2'b10:
                        spi_csn2_o <= 1'b0;
                    2'b11:
                        spi_csn3_o <= 1'b0;
                endcase
            end
            else if(s_clear_cs) begin
                spi_csn0_o <= 1'b1;
                spi_csn1_o <= 1'b1;
                spi_csn2_o <= 1'b1;
                spi_csn3_o <= 1'b1;
            end
        end

    end


endmodule
