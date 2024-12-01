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
// Description: I2S top level implementation
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////

`define CFG_USE_CLK0         2'b00
`define CFG_USE_CLK1         2'b01
`define CFG_USE_EXTCLK_INTWS 2'b10
`define CFG_USE_EXTCLK_EXTWS 2'b11

module udma_i2s_top 
#(
    parameter NUM_CHANNELS = 4,  //number of i2s channels
    parameter BUFFER_WIDTH = 4
)
(
    input  logic                             clk_i,
    input  logic                             rstn_i,

    input  logic   [NUM_CHANNELS-1:0]        ext_sd_i,
    input  logic                             ext_sck_i,
    input  logic                             ext_ws_i,
    output logic                             ext_ws_o,
    output logic                             ext_sck0_o,
    output logic                             ext_ws0_o,
    output logic                             ext_sck1_o,
    output logic                             ext_ws1_o,

    output logic   [NUM_CHANNELS-1:0] [31:0] fifo_data_o,
    output logic   [NUM_CHANNELS-1:0]        fifo_data_valid_o,
    input  logic   [NUM_CHANNELS-1:0]        fifo_data_ready_i,

    output logic   [NUM_CHANNELS-1:0]        fifo_err_o,
    input  logic   [NUM_CHANNELS-1:0]        fifo_err_clr_i,

    input  logic [NUM_CHANNELS*2-1:0]        cfg_ch_mode_i,
    input  logic   [NUM_CHANNELS-1:0]        cfg_pdm_en_i,
    input  logic   [NUM_CHANNELS-1:0]        cfg_pdm_usefilter_i,
    input  logic   [NUM_CHANNELS-1:0]  [9:0] cfg_pdm_decimation_i,
    input  logic   [NUM_CHANNELS-1:0]  [2:0] cfg_pdm_shift_i,
    input  logic   [NUM_CHANNELS-1:0]        cfg_useddr_i,
    input  logic   [NUM_CHANNELS-1:0]        cfg_snap_cam_i,
    input  logic   [NUM_CHANNELS-1:0]        cfg_lsb_first_i,

    input  logic                [4:0]        cfg_ext_bits_word_i,

    input  logic                             cfg0_gen_clk_en_i,
    input  logic               [15:0]        cfg0_gen_clk_div_i,
    input  logic                [4:0]        cfg0_bits_word_i,

    input  logic                             cfg1_gen_clk_en_i,
    input  logic               [15:0]        cfg1_gen_clk_div_i,
    input  logic                [4:0]        cfg1_bits_word_i

);

    genvar i;
    integer j;

    logic                                       s_ws_gen_ext_en;
    logic                                       s_ws_gen_ext;
    logic                                       s_int_sck0;
    logic                                       s_ws_gen_cfg0;
    logic                                       s_int_sck1;
    logic                                       s_ws_gen_cfg1;
    logic [NUM_CHANNELS-1:0]              [1:0] s_channel_sel;
    logic [NUM_CHANNELS-1:0]                    s_clkintsel;
    logic [NUM_CHANNELS-1:0]                    s_clkint;
    logic [NUM_CHANNELS-1:0]                    s_sck;
    logic [NUM_CHANNELS-1:0]                    s_clksel;
    logic [NUM_CHANNELS-1:0]                    s_ws;

    logic [NUM_CHANNELS-1:0]             [31:0] s_fifo_data;
    logic [NUM_CHANNELS-1:0]                    s_fifo_data_valid;
    logic [NUM_CHANNELS-1:0]                    s_fifo_data_ready;

    logic [NUM_CHANNELS-1:0]             [31:0] s_dc_data_async;
    logic [NUM_CHANNELS-1:0] [BUFFER_WIDTH-1:0] s_dc_writetoken;
    logic [NUM_CHANNELS-1:0] [BUFFER_WIDTH-1:0] s_dc_readpointer;

    i2s_ws_gen u_ws_gen_ext (
        .sck_i(ext_sck_i),
        .rstn_i(rstn_i),
        .ws_o(s_ws_gen_ext),
        .cfg_ws_en_i(1'b1),
        .cfg_data_size_i(cfg_ext_bits_word_i)
    );
    assign ext_ws_o = s_ws_gen_ext;

    i2s_clk_gen u_clkgen_cfg0 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .sck_o(s_int_sck0),
        .cfg_clk_en_i(cfg0_gen_clk_en_i),
        .cfg_semiperiod_cycles_i(cfg0_gen_clk_div_i)
    );
    assign ext_sck0_o = s_int_sck0;

    i2s_ws_gen u_ws_gen_cfg0 (
        .sck_i(s_int_sck0),
        .rstn_i(rstn_i),
        .ws_o(s_ws_gen_cfg0),
        .cfg_ws_en_i(cfg0_gen_clk_en_i),
        .cfg_data_size_i(cfg0_bits_word_i)
    );
    assign ext_ws0_o = s_ws_gen_cfg0;

    i2s_clk_gen u_clkgen_cfg1 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .sck_o(s_int_sck1),
        .cfg_clk_en_i(cfg1_gen_clk_en_i),
        .cfg_semiperiod_cycles_i(cfg1_gen_clk_div_i)
    );
    assign ext_sck1_o = s_int_sck1;

    i2s_ws_gen u_ws_gen_cfg1 (
        .sck_i(s_int_sck1),
        .rstn_i(rstn_i),
        .ws_o(s_ws_gen_cfg1),
        .cfg_ws_en_i(cfg1_gen_clk_en_i),
        .cfg_data_size_i(cfg1_bits_word_i)
    );
    assign ext_ws1_o = s_ws_gen_cfg1;

    always_comb
    begin
        for ( j = 0; j < NUM_CHANNELS; j++ ) 
        begin
            s_channel_sel[j] = cfg_ch_mode_i[j*2+:2];
            case (s_channel_sel[j])
                `CFG_USE_CLK0:
                begin
                    s_clkintsel[j] = 1'b0;
                    s_clksel[j]    = 1'b1;
                    s_ws[j]        = s_ws_gen_cfg0;
                end
                `CFG_USE_CLK1:
                begin
                    s_clkintsel[j] = 1'b1;
                    s_clksel[j]    = 1'b1;
                    s_ws[j]        = s_ws_gen_cfg1;
                end
                `CFG_USE_EXTCLK_INTWS:
                begin
                    s_clkintsel[j] = 1'b0;
                    s_clksel[j]    = 1'b0;
                    s_ws[j]        = s_ws_gen_ext;
                end
                `CFG_USE_EXTCLK_EXTWS:
                begin
                    s_clkintsel[j] = 1'b0;
                    s_clksel[j]    = 1'b0;
                    s_ws[j]        = ext_ws_i;
                end
            endcase
        end
    end

    generate
        for ( i = 0; i < NUM_CHANNELS; i++ ) 
        begin
            pulp_clock_mux2 u_clkselint (
                    .clk0_i(s_int_sck0),
                    .clk1_i(s_int_sck1),
                    .clk_sel_i(s_clkintsel[i]),
                    .clk_o(s_clkint[i])
            );
            pulp_clock_mux2 u_clksel (
                    .clk0_i(ext_sck_i),
                    .clk1_i(s_clkint[i]),
                    .clk_sel_i(s_clksel[i]),
                    .clk_o(s_sck[i])
            );
        end
    endgenerate

    generate
        for ( i = 0; i < NUM_CHANNELS; i++ ) 
        begin
            i2s_rx_channel u_channel 
            (
                .sck_i(s_sck[i]),
                .rstn_i(rstn_i),

                .sd_i(ext_sd_i[i]),
                .ws_i(s_ws[i]),

                .fifo_data_o(s_fifo_data[i]),
                .fifo_data_valid_o(s_fifo_data_valid[i]),
                .fifo_data_ready_i(s_fifo_data_ready[i]),

                .fifo_err_o(),
                .fifo_err_clr_i(),
                .cfg_pdm_en_i(cfg_pdm_en_i[i]),
                .cfg_pdm_usefilter_i(cfg_pdm_usefilter_i[i]),
                .cfg_decimation_i(cfg_pdm_decimation_i[i]),
                .cfg_shift_i(cfg_pdm_shift_i[i]),
                .cfg_snap_cam_i(cfg_snap_cam_i[i]),
                .cfg_lsb_first_i(cfg_lsb_first_i[i]), 
                .cfg_pdm_ddr_i(cfg_useddr_i[i])

            );
        end
    endgenerate

    generate
        for ( i = 0; i < NUM_CHANNELS; i++ ) 
        begin
            dc_token_ring_fifo_dout #(32,BUFFER_WIDTH) u_dc_out
            (
                .clk          ( clk_i                ),
                .rstn         ( rstn_i               ),
                .data         ( fifo_data_o[i]       ),
                .valid        ( fifo_data_valid_o[i] ),
                .ready        ( fifo_data_ready_i[i] ),
                .write_token  ( s_dc_writetoken[i]   ),
                .read_pointer ( s_dc_readpointer[i]  ),
                .data_async   ( s_dc_data_async[i]   )
            );
        end
    endgenerate

    generate
        for ( i = 0; i < NUM_CHANNELS; i++ ) 
        begin
            dc_token_ring_fifo_din #(32,BUFFER_WIDTH) u_dc_in
            (
                .clk          ( s_sck[i]             ),
                .rstn         ( rstn_i               ),
                .data         ( s_fifo_data[i]       ),
                .valid        ( s_fifo_data_valid[i] ),
                .ready        ( s_fifo_data_ready[i] ),
                .write_token  ( s_dc_writetoken[i]   ),
                .read_pointer ( s_dc_readpointer[i]  ),
                .data_async   ( s_dc_data_async[i]   )
            );
        end
    endgenerate


endmodule

