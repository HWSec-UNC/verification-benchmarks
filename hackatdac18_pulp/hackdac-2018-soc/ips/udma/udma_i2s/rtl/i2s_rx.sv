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
// Description: Single I2S RX channel
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////

`define log2(VALUE) ((VALUE) < ( 1 ) ? 0 : (VALUE) < ( 2 ) ? 1 : (VALUE) < ( 4 ) ? 2 : (VALUE) < ( 8 ) ? 3 : (VALUE) < ( 16 )  ? 4 : (VALUE) < ( 32 )  ? 5 : (VALUE) < ( 64 )  ? 6 : (VALUE) < ( 128 ) ? 7 : (VALUE) < ( 256 ) ? 8 : (VALUE) < ( 512 ) ? 9 : (VALUE) < ( 1024 ) ? 10 : (VALUE) < ( 2048 ) ? 11 : (VALUE) < ( 4096 ) ? 12 : (VALUE) < ( 8192 ) ? 13 : (VALUE) < ( 16384 ) ? 14 : (VALUE) < ( 32768 ) ? 15 : (VALUE) < ( 65536 ) ? 16 : (VALUE) < ( 131072 ) ? 17 : (VALUE) < ( 262144 ) ? 18 : (VALUE) < ( 524288 ) ? 19 : (VALUE) < ( 1048576 ) ? 20 : (VALUE) < ( 1048576 * 2 ) ? 21 : (VALUE) < ( 1048576 * 4 ) ? 22 : (VALUE) < ( 1048576 * 8 ) ? 23 : (VALUE) < ( 1048576 * 16 ) ? 24 : 25)

module i2s_rx 
#(
    parameter NUM_CHANNELS = 1  //number of i2s channels
)
(
    input  logic                    clk_i,
    input  logic                    rstn_i,

    input  logic [NUM_CHANNELS-1:0] ext_sd_i,
    output logic                    ext_sck0_o,
    output logic                    ext_ws0_o,
    output logic                    ext_sck1_o,
    output logic                    ext_ws1_o,

    output logic [NUM_CHANNELS-1:0] [31:0] fifo_data_o,
    output logic [NUM_CHANNELS-1:0]        fifo_data_valid_o,
    input  logic [NUM_CHANNELS-1:0]        fifo_data_ready_i,

    input  logic [NUM_CHANNELS-1:0]        fifo_err_o,
    output logic [NUM_CHANNELS-1:0]        fifo_err_clr_i,

    input  logic [NUM_CHANNELS-1:0] cfg_select_i,
    input  logic [NUM_CHANNELS-1:0] cfg_enable_i,

    input  logic                    cfg0_pdm_en_i,
    input  logic                    cfg0_pdm_ddr_i,
    input  logic                    cfg0_lsbfirst_i,
    input  logic                    cfg0_sample_word_i,
    input  logic                    cfg0_gen_clk_en_i,
    input  logic             [10:0] cfg0_gen_clk_div_i,
    input  logic              [5:0] cfg0_bits_word_i,
    input  logic              [5:0] cfg0_ws_time_i,
    input  logic                    cfg0_ws_value_i,
    input  logic                    cfg0_ws_fix_i,

    input  logic                    cfg1_pdm_en_i,
    input  logic                    cfg1_pdm_ddr_i,
    input  logic                    cfg1_lsbfirst_i,
    input  logic                    cfg1_sample_word_i,
    input  logic                    cfg1_gen_clk_en_i,
    input  logic             [10:0] cfg1_gen_clk_div_i,
    input  logic              [5:0] cfg1_bits_word_i,
    input  logic              [5:0] cfg1_ws_time_i,
    input  logic                    cfg1_ws_value_i,
    input  logic                    cfg1_ws_fix_i
);

    genvar i;

    logic s_en_clkgen;
    logic s_fall0;
    logic s_rise0;
    logic s_fall1;
    logic s_rise1;
    logic [NUM_CHANNELS-1:0] s_shift;
    logic [NUM_CHANNELS-1:0] s_cfg_enable;
    logic [NUM_CHANNELS-1:0] r_datavalid;
    logic [NUM_CHANNELS-1:0] r_error;
    logic s_shift_fifow0;
    logic s_shift_fifow1;
    logic s_dataready0;
    logic s_dataready1;
    logic s_32bitsready0;
    logic s_32bitsready1;
    logic s_wordready0;
    logic s_wordready1;

    logic [5:0] s_bitcount;
    logic [5:0] s_bitcountword;
    logic [5:0] s_bitcountreg;

    logic       s_shift0;
    logic       s_shift1;
    logic [NUM_CHANNELS-1:0] s_cfg_lsbfirst;
    logic       s_bitcount1;
    logic       s_bitcount0;
    logic       s_bitcountword1;
    logic       s_bitcountword0;
    logic       s_bitcountreg0;
    logic       s_bitcountreg1;

    //if 32bit at the time are written to fifo use the fifow_counter
    assign s_shift_fifow0 = (cfg0_pdm_en_i || !cfg0_sample_word_i) ? s_shift0 : 1'b0;
    assign s_dataready0   = (cfg0_pdm_en_i || !cfg0_sample_word_i) ? s_32bitsready0 : s_wordready0;
    assign s_bitcount0    = (cfg0_pdm_en_i || !cfg0_sample_word_i) ? s_bitcountword0 : s_bitcountreg0;

    assign s_shift_fifow1 = (cfg1_pdm_en_i || !cfg1_sample_word_i) ? s_shift1 : 1'b0;
    assign s_dataready1   = (cfg1_pdm_en_i || !cfg1_sample_word_i) ? s_32bitsready1 : s_wordready1;
    assign s_bitcount1    = (cfg1_pdm_en_i || !cfg1_sample_word_i) ? s_bitcountword1 : s_bitcountreg1;

    assign s_cfg0_enable = | (cfg_enable_i & ~cfg_select_i);
    assign s_cfg1_enable = | (cfg_enable_i &  cfg_select_i);

    io_clk_gen
        #(.COUNTER_WIDTH(11)
    ) 
    i_clk_gen0
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .en_i(s_cfg0_enable),
        .clk_div_i(cfg_gen0_clk_div_i),
        .clk_o(ext_sck0_o),
        .fall_o(s_fall0),
        .rise_o(s_rise0)
    );

    //counts how many bits in the current word are sampled
    io_event_counter 
        #(.COUNTER_WIDTH(6)
    ) 
    i_bit_counter0 
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .event_i(s_shift0),
        .counter_rst_i(~s_cfg0_enable),
        .counter_target_i(cfg0_bits_word_i),
        .counter_value_o(s_bitcountreg0),
        .counter_trig_o(s_wordready0)
    );

    //counts up to 32 bits rx when each word is not sent to fifo
    io_event_counter 
        #(.COUNTER_WIDTH(6)
    ) 
    i_fifow_counter0 
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .event_i(s_shift_fifow0),
        .counter_rst_i(~s_cfg0_enable),
        .counter_target_i(6'd32),
        .counter_value_o(s_bitcountword0),
        .counter_trig_o(s_32bitsready0)
    );

    io_clk_gen
        #(.COUNTER_WIDTH(11)
    ) 
    i_clk_gen1
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .en_i(s_cfg1_enable),
        .clk_div_i(cfg1_gen_clk_div_i),
        .clk_o(ext_sck1_o),
        .fall_o(s_fall1),
        .rise_o(s_rise1)
    );

    //counts how many bits in the current word are sampled
    io_event_counter 
        #(.COUNTER_WIDTH(6)
    ) 
    i_bit_counter1 
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .event_i(s_shift1),
        .counter_rst_i(~s_cfg1_enable),
        .counter_target_i(cfg1_bits_word_i),
        .counter_value_o(s_bitcountreg1),
        .counter_trig_o(s_wordready1)
    );

    //counts up to 32 bits rx when each word is not sent to fifo
    io_event_counter 
        #(.COUNTER_WIDTH(6)
    ) 
    i_fifow_counter1 
    (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .event_i(s_shift_fifow1),
        .counter_rst_i(~s_cfg1_enable),
        .counter_target_i(6'd32),
        .counter_value_o(s_bitcountword1),
        .counter_trig_o(s_32bitsready1)
    );

    generate
        for ( i = 0; i < NUM_CHANNELS; i++ ) 
        begin
            io_shiftreg 
                #(.DATA_WIDTH(32)
            ) 
            i_shiftreg 
            (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .data_i(32'h0),
                .data_o(fifo_data_o[i]),
                .serial_i(ext_sd_i[i]),
                .serial_o(),
                .load_i(~cfg_enable_i[i]),
                .shift_i(s_shift[i]),
                .lsbfirst_i(s_cfg_lsbfirst[i])
            );
        end
    endgenerate

    always_comb
    begin
        for (int i = 0; i < NUM_CHANNELS; i++)
        begin
            if(cfg_select_i[i])
            begin
                s_shift[i] = s_shift1 & cfg_enable_i[i];
                s_cfg_enable[i] = s_cfg1_enable; 
                s_cfg_lsbfirst[i] = cfg1_lsbfirst_i;
            end
            else
            begin
                s_shift[i] = s_shift0 & cfg_enable_i[i]; 
                s_cfg_enable[i] = s_cfg0_enable; 
                s_cfg_lsbfirst[i] = cfg0_lsbfirst_i;
            end
        end
    end

    always_comb
    begin
        if (cfg0_pdm_en_i && cfg0_pdm_ddr_i)
            s_shift0 = s_fall0 | s_rise0; //if pdm ddr enabled sample data at each edge
        else
            s_shift0 = s_rise0; 
        if (cfg1_pdm_en_i && cfg1_pdm_ddr_i)
            s_shift1 = s_fall1 | s_rise1; //if pdm ddr enabled sample data at each edge
        else
            s_shift1 = s_rise1; 
    end

    //Dump Shift Regs to FIFO
    always_ff  @(posedge clk_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            r_datavalid  <= 'h0;
            r_error      <= 'h0;
        end
        else
        begin
            for (int i=0; i<NUM_CHANNELS;i++)
            begin
                if (fifo_err_clr_i[i])
                    r_error[i] <= 1'b0;
                else if(cfg_enable_i[i] && r_datavalid[i] && ~fifo_data_ready_i[i] && s_shift[i] )
                    r_error[i] <= 1'b1;

                if (cfg_enable_i[i])
                begin
                    if(r_datavalid[i])
                    begin
                        if(fifo_data_ready_i[i])
                        begin
                            if((cfg_select_i[i] & ~s_dataready1) || (~cfg_select_i[i] & ~s_dataready0))
                                r_datavalid[i] <= 1'b0;
                        end
                    end
                    else
                    begin
                        if(cfg_select_i[i])
                            r_datavalid[i] <= s_dataready1;
                        else
                            r_datavalid[i] <= s_dataready0;
                    end
                end
                else
                begin
                    r_datavalid[i] <= 1'b0;
                end
            end
        end
    end

    //Generate WS0 signal
    always_ff  @(posedge clk_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
            ext_ws0_o   <= 1'b0;
        else
        begin
            if (s_cfg0_enable)
            begin
                if (cfg0_ws_fix_i) //if WS fix then assign proper value
                    ext_ws0_o   <= cfg0_ws_value_i;
                else
                    if ((s_bitcount0 == cfg0_ws_time_i) && s_fall0)
                        ext_ws0_o   <= ~ext_ws0_o;
            end
            else
                ext_ws0_o   <= 1'b0;
        end 
    end

    //Generate WS1 signal
    always_ff  @(posedge clk_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
            ext_ws1_o   <= 1'b0;
        else
        begin
            if (s_cfg1_enable)
            begin
                if (cfg1_ws_fix_i) //if WS fix then assign proper value
                    ext_ws1_o   <= cfg1_ws_value_i;
                else
                    if ((s_bitcount1 == cfg1_ws_time_i) && s_fall1)
                        ext_ws1_o   <= ~ext_ws1_o;
            end
            else
                ext_ws1_o   <= 1'b0;
        end 
    end

    assign fifo_data_valid_o = r_datavalid;

endmodule

