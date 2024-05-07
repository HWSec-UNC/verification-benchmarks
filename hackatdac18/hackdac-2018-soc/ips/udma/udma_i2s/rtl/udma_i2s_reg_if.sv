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
// Description: I2S configuration interface
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////

// SPI Master Registers
`define REG_RX_CH0_SADDR     5'b00000 //BASEADDR+0x00 
`define REG_RX_CH0_SIZE      5'b00001 //BASEADDR+0x04
`define REG_RX_CH0_CFG       5'b00010 //BASEADDR+0x08  
`define REG_RX_CH0_INTCFG    5'b00011 //BASEADDR+0x0C  

`define REG_RX_CH1_SADDR     5'b00100 //BASEADDR+0x10
`define REG_RX_CH1_SIZE      5'b00101 //BASEADDR+0x14
`define REG_RX_CH1_CFG       5'b00110 //BASEADDR+0x18
`define REG_RX_CH1_INTCFG    5'b00111 //BASEADDR+0x1C

`define REG_I2S_EXT_SETUP    5'b01000 //BASEADDR+0x20   
`define REG_I2S_CFG0_SETUP   5'b01001 //BASEADDR+0x24    
`define REG_I2S_CFG1_SETUP   5'b01010 //BASEADDR+0x28    
`define REG_I2S_CHMODE       5'b01011 //BASEADDR+0x2C
`define REG_I2S_FILT_CH0     5'b01100 //BASEADDR+0x30
`define REG_I2S_FILT_CH1     5'b01101 //BASEADDR+0x34

module udma_i2s_reg_if #(
    parameter L2_AWIDTH_NOAL = 12,
    parameter TRANS_SIZE     = 16,
    parameter NUM_CHANNELS   = 4
)
(
	input  logic 	                  clk_i,
	input  logic   	                  rstn_i,

	input  logic               [31:0] cfg_data_i,
	input  logic                [4:0] cfg_addr_i,
	input  logic                      cfg_valid_i,
	input  logic                      cfg_rwn_i,
	output logic               [31:0] cfg_data_o,
	output logic                      cfg_ready_o,

    output logic [L2_AWIDTH_NOAL-1:0] cfg_rx_ch0_startaddr_o,
    output logic     [TRANS_SIZE-1:0] cfg_rx_ch0_size_o,
    output logic                [1:0] cfg_rx_ch0_datasize_o,
    output logic                      cfg_rx_ch0_continuous_o,
    output logic                      cfg_rx_ch0_en_o,
    output logic                      cfg_rx_ch0_clr_o,
    input  logic                      cfg_rx_ch0_en_i,
    input  logic                      cfg_rx_ch0_pending_i,
    input  logic [L2_AWIDTH_NOAL-1:0] cfg_rx_ch0_curr_addr_i,
    input  logic     [TRANS_SIZE-1:0] cfg_rx_ch0_bytes_left_i,

    output logic [L2_AWIDTH_NOAL-1:0] cfg_rx_ch1_startaddr_o,
    output logic     [TRANS_SIZE-1:0] cfg_rx_ch1_size_o,
    output logic                [1:0] cfg_rx_ch1_datasize_o,
    output logic                      cfg_rx_ch1_continuous_o,
    output logic                      cfg_rx_ch1_en_o,
    output logic                      cfg_rx_ch1_clr_o,
    input  logic                      cfg_rx_ch1_en_i,
    input  logic                      cfg_rx_ch1_pending_i,
    input  logic [L2_AWIDTH_NOAL-1:0] cfg_rx_ch1_curr_addr_i,
    input  logic     [TRANS_SIZE-1:0] cfg_rx_ch1_bytes_left_i,

    output logic [NUM_CHANNELS-1:0]  [1:0] cfg_i2s_ch_mode_o,
    output logic [NUM_CHANNELS-1:0]        cfg_i2s_snap_cam_o,
    output logic [NUM_CHANNELS-1:0]        cfg_i2s_useddr_o,
    output logic [NUM_CHANNELS-1:0]        cfg_i2s_update_o,
    output logic [NUM_CHANNELS-1:0]  [9:0] cfg_i2s_decimation_o,
    output logic [NUM_CHANNELS-1:0]  [2:0] cfg_i2s_shift_o,
    output logic [NUM_CHANNELS-1:0]        cfg_i2s_pdm_en_o,
    output logic [NUM_CHANNELS-1:0]        cfg_i2s_pdm_usefilter_o,
    output logic [NUM_CHANNELS-1:0]        cfg_i2s_lsb_first_o,

    output logic                [4:0] cfg_i2s_ext_bits_word_o,
    output logic                      cfg_i2s_0_gen_clk_en_o,
    input  logic                      cfg_i2s_0_gen_clk_en_i,
    output logic               [15:0] cfg_i2s_0_gen_clk_div_o,
    output logic                [4:0] cfg_i2s_0_bits_word_o,
    output logic                      cfg_i2s_1_gen_clk_en_o,
    input  logic                      cfg_i2s_1_gen_clk_en_i,
    output logic               [15:0] cfg_i2s_1_gen_clk_div_o,
    output logic                [4:0] cfg_i2s_1_bits_word_o

);

    localparam MAX_CHANNELS = 4;

    logic [L2_AWIDTH_NOAL-1:0] r_rx_ch0_startaddr;
    logic   [TRANS_SIZE-1 : 0] r_rx_ch0_size;
    logic                [1:0] r_rx_ch0_datasize;
    logic                      r_rx_ch0_continuous;
    logic                      r_rx_ch0_en;
    logic                      r_rx_ch0_clr;

    logic [L2_AWIDTH_NOAL-1:0] r_rx_ch1_startaddr;
    logic   [TRANS_SIZE-1 : 0] r_rx_ch1_size;
    logic                [1:0] r_rx_ch1_datasize;
    logic                      r_rx_ch1_continuous;
    logic                      r_rx_ch1_en;
    logic                      r_rx_ch1_clr;

    logic [MAX_CHANNELS-1:0]  [1:0] r_i2s_ch_mode;
    logic [MAX_CHANNELS-1:0]        r_i2s_snap_cam;
    logic [MAX_CHANNELS-1:0]        r_i2s_useddr;
    logic [MAX_CHANNELS-1:0]        r_i2s_update;
    logic [MAX_CHANNELS-1:0]  [9:0] r_i2s_decimation;
    logic [MAX_CHANNELS-1:0]  [2:0] r_i2s_shift;
    logic [MAX_CHANNELS-1:0]        r_i2s_pdm_en;
    logic [MAX_CHANNELS-1:0]        r_i2s_pdm_usefilter;
    logic [MAX_CHANNELS-1:0]        r_i2s_lsb_first;

    logic  [4:0] r_i2s_ext_bits_word;
    logic        r_i2s_cfg0_clk_en;
    logic [15:0] r_i2s_cfg0_clk_div;
    logic  [4:0] r_i2s_cfg0_bits_word;
    logic        r_i2s_cfg1_clk_en;
    logic [15:0] r_i2s_cfg1_clk_div;
    logic  [4:0] r_i2s_cfg1_bits_word;


    logic                [4:0] s_wr_addr;
    logic                [4:0] s_rd_addr;

    assign s_wr_addr = (cfg_valid_i & ~cfg_rwn_i) ? cfg_addr_i : 5'h0;
    assign s_rd_addr = (cfg_valid_i &  cfg_rwn_i) ? cfg_addr_i : 5'h0;

    assign cfg_rx_ch0_startaddr_o  = r_rx_ch0_startaddr;
    assign cfg_rx_ch0_size_o       = r_rx_ch0_size;
    assign cfg_rx_ch0_datasize_o   = r_rx_ch0_datasize;
    assign cfg_rx_ch0_continuous_o = r_rx_ch0_continuous;
    assign cfg_rx_ch0_en_o         = r_rx_ch0_en;
    assign cfg_rx_ch0_clr_o        = r_rx_ch0_clr;

    assign cfg_rx_ch1_startaddr_o  = r_rx_ch1_startaddr;
    assign cfg_rx_ch1_size_o       = r_rx_ch1_size;
    assign cfg_rx_ch1_datasize_o   = r_rx_ch1_datasize;
    assign cfg_rx_ch1_continuous_o = r_rx_ch1_continuous;
    assign cfg_rx_ch1_en_o         = r_rx_ch1_en;
    assign cfg_rx_ch1_clr_o        = r_rx_ch1_clr;

    always_comb begin : proc_outs
        for (int i=0;i<NUM_CHANNELS;i++)
        begin
            cfg_i2s_ch_mode_o[i]        = r_i2s_ch_mode[i];
            cfg_i2s_useddr_o[i]         = r_i2s_useddr[i];
            cfg_i2s_update_o[i]         = r_i2s_update[i];
            cfg_i2s_decimation_o[i]     = r_i2s_decimation[i];
            cfg_i2s_shift_o[i]          = r_i2s_shift[i];
            cfg_i2s_pdm_en_o[i]         = r_i2s_pdm_en[i];
            cfg_i2s_pdm_usefilter_o[i]  = r_i2s_pdm_usefilter[i];
            cfg_i2s_snap_cam_o[i]       = r_i2s_snap_cam[i];
            cfg_i2s_lsb_first_o[i]      = r_i2s_lsb_first[i];
        end
    end

    assign cfg_i2s_ext_bits_word_o  = r_i2s_ext_bits_word;
    assign cfg_i2s_0_gen_clk_en_o   = r_i2s_cfg0_clk_en;
    assign cfg_i2s_0_gen_clk_div_o  = r_i2s_cfg0_clk_div;
    assign cfg_i2s_0_bits_word_o    = r_i2s_cfg0_bits_word;
    assign cfg_i2s_1_gen_clk_en_o   = r_i2s_cfg1_clk_en;
    assign cfg_i2s_1_gen_clk_div_o  = r_i2s_cfg1_clk_div; 
    assign cfg_i2s_1_bits_word_o    = r_i2s_cfg1_bits_word;

    always_ff @(posedge clk_i, negedge rstn_i) 
    begin
        if(~rstn_i) 
        begin
            // SPI REGS
            r_rx_ch0_startaddr   <=  'h0;
            r_rx_ch0_size        <=  'h0;
            r_rx_ch0_datasize    <=  'h2;
            r_rx_ch0_continuous  <=  'h0;
            r_rx_ch0_en           =  'h0;
            r_rx_ch0_clr          =  'h0;
            r_rx_ch1_startaddr   <=  'h0;
            r_rx_ch1_size        <=  'h0;
            r_rx_ch1_datasize    <=  'h2;
            r_rx_ch1_continuous  <=  'h0;
            r_rx_ch1_en           =  'h0;
            r_rx_ch1_clr          =  'h0;
            r_i2s_ch_mode        <=  'h0;
            r_i2s_useddr         <=  'h0;
            r_i2s_update          =  'h0;
            r_i2s_decimation     <=  'h0;
            r_i2s_shift          <=  'h0;
            r_i2s_pdm_en         <=  'h0;
            r_i2s_pdm_usefilter  <=  'h0;
            r_i2s_snap_cam       <=  'h0;
            r_i2s_lsb_first      <=  'h0;
            r_i2s_ext_bits_word  <=  'h0;
            r_i2s_cfg0_clk_en    <=  'h0;
            r_i2s_cfg0_clk_div   <=  'h0;
            r_i2s_cfg0_bits_word <=  'h0;
            r_i2s_cfg1_clk_en    <=  'h0;
            r_i2s_cfg1_clk_div   <=  'h0;
            r_i2s_cfg1_bits_word <=  'h0;
        end
        else
        begin
            r_rx_ch0_en          =  'h0;
            r_rx_ch0_clr         =  'h0;
            r_rx_ch1_en          =  'h0;
            r_rx_ch1_clr         =  'h0;
            r_i2s_update[0]      = 1'b0;
            r_i2s_update[1]      = 1'b0;

            if (cfg_valid_i & ~cfg_rwn_i)
            begin
                case (s_wr_addr)
                `REG_RX_CH0_SADDR:
                    r_rx_ch0_startaddr   <= cfg_data_i[L2_AWIDTH_NOAL-1:0];
                `REG_RX_CH0_SIZE:
                    r_rx_ch0_size        <= cfg_data_i[TRANS_SIZE-1:0];
                `REG_RX_CH0_CFG:
                begin
                    r_rx_ch0_clr          = cfg_data_i[5];
                    r_rx_ch0_en           = cfg_data_i[4];
                    r_rx_ch0_datasize    <= cfg_data_i[2:1];
                    r_rx_ch0_continuous  <= cfg_data_i[0];
                end
                `REG_RX_CH1_SADDR:
                    r_rx_ch1_startaddr   <= cfg_data_i[L2_AWIDTH_NOAL-1:0];
                `REG_RX_CH1_SIZE:
                    r_rx_ch1_size        <= cfg_data_i[TRANS_SIZE-1:0];
                `REG_RX_CH1_CFG:
                begin
                    r_rx_ch1_clr          = cfg_data_i[5];
                    r_rx_ch1_en           = cfg_data_i[4];
                    r_rx_ch1_datasize    <= cfg_data_i[2:1];
                    r_rx_ch1_continuous  <= cfg_data_i[0];
                end
                `REG_I2S_CHMODE:
                begin
                    r_i2s_ch_mode[0]       <= cfg_data_i[25:24];
                    r_i2s_useddr[0]        <= cfg_data_i[16];
                    r_i2s_pdm_en[0]        <= cfg_data_i[12];
                    r_i2s_pdm_usefilter[0] <= cfg_data_i[8];
                    r_i2s_lsb_first[0]     <= cfg_data_i[4];
                    r_i2s_snap_cam[0]      <= cfg_data_i[0];
                    r_i2s_ch_mode[1]       <= cfg_data_i[27:26];
                    r_i2s_useddr[1]        <= cfg_data_i[17];
                    r_i2s_pdm_en[1]        <= cfg_data_i[13];
                    r_i2s_pdm_usefilter[1] <= cfg_data_i[9];
                    r_i2s_lsb_first[1]     <= cfg_data_i[5];
                    r_i2s_snap_cam[1]      <= cfg_data_i[1];
                    r_i2s_ch_mode[2]       <= cfg_data_i[29:28];
                    r_i2s_useddr[2]        <= cfg_data_i[18];
                    r_i2s_pdm_en[2]        <= cfg_data_i[14];
                    r_i2s_pdm_usefilter[2] <= cfg_data_i[10];
                    r_i2s_lsb_first[2]     <= cfg_data_i[6];
                    r_i2s_snap_cam[2]      <= cfg_data_i[2];
                    r_i2s_ch_mode[3]       <= cfg_data_i[31:30];
                    r_i2s_useddr[3]        <= cfg_data_i[19];
                    r_i2s_pdm_en[3]        <= cfg_data_i[15];
                    r_i2s_pdm_usefilter[3] <= cfg_data_i[11];
                    r_i2s_lsb_first[3]     <= cfg_data_i[7];
                    r_i2s_snap_cam[3]      <= cfg_data_i[3];
                end

                `REG_I2S_FILT_CH0:
                begin
                    r_i2s_update[0]       = 1'b1;
                    r_i2s_decimation[0]  <= cfg_data_i[9:0];
                    r_i2s_shift[0]       <= cfg_data_i[18:16];
                end

                `REG_I2S_FILT_CH1:
                begin
                    r_i2s_update[1]       = 1'b1;
                    r_i2s_decimation[1]  <= cfg_data_i[9:0];
                    r_i2s_shift[1]       <= cfg_data_i[18:16];
                end

                `REG_I2S_EXT_SETUP:
                begin
                    r_i2s_ext_bits_word     <= cfg_data_i[4:0];
                end
                `REG_I2S_CFG0_SETUP:
                begin
                    r_i2s_cfg0_clk_en    <= cfg_data_i[8];
                    r_i2s_cfg0_clk_div   <= cfg_data_i[31:16];
                    r_i2s_cfg0_bits_word <= cfg_data_i[4:0];
                end
                `REG_I2S_CFG1_SETUP:
                begin
                    r_i2s_cfg1_clk_en    <= cfg_data_i[8];
                    r_i2s_cfg1_clk_div   <= cfg_data_i[31:16];
                    r_i2s_cfg1_bits_word <= cfg_data_i[4:0];
                end
                endcase
            end
        end
    end //always

    always_comb
    begin
        cfg_data_o = 32'h0;
        case (s_rd_addr)
        `REG_RX_CH0_SADDR:
            cfg_data_o = cfg_rx_ch0_curr_addr_i;
        `REG_RX_CH0_SIZE:
            cfg_data_o[TRANS_SIZE-1:0] = cfg_rx_ch0_bytes_left_i;
        `REG_RX_CH0_CFG:
            cfg_data_o = {26'h0,cfg_rx_ch0_pending_i,cfg_rx_ch0_en_i,1'b0,r_rx_ch0_datasize,r_rx_ch0_continuous};
        `REG_RX_CH1_SADDR:
            cfg_data_o = cfg_rx_ch1_curr_addr_i;
        `REG_RX_CH1_SIZE:
            cfg_data_o[TRANS_SIZE-1:0] = cfg_rx_ch1_bytes_left_i;
        `REG_RX_CH1_CFG:
            cfg_data_o = {26'h0,cfg_rx_ch1_pending_i,cfg_rx_ch1_en_i,1'b0,r_rx_ch1_datasize,r_rx_ch1_continuous};
        `REG_I2S_CHMODE:
            cfg_data_o = {r_i2s_ch_mode,4'h0,r_i2s_useddr,r_i2s_pdm_en,r_i2s_pdm_usefilter,r_i2s_lsb_first,r_i2s_snap_cam};
        `REG_I2S_FILT_CH0:
            cfg_data_o = {13'h0, r_i2s_shift[0], 6'h0, r_i2s_decimation[0]};
        `REG_I2S_FILT_CH1:
            cfg_data_o = {13'h0, r_i2s_shift[1], 6'h0, r_i2s_decimation[1]};
        `REG_I2S_EXT_SETUP:
            cfg_data_o = {27'h0,r_i2s_ext_bits_word};
        `REG_I2S_CFG0_SETUP:
            cfg_data_o = {r_i2s_cfg0_clk_div, 7'h0, cfg_i2s_0_gen_clk_en_i, 3'h0, r_i2s_cfg0_bits_word};
        `REG_I2S_CFG1_SETUP:
            cfg_data_o = {r_i2s_cfg1_clk_div, 7'h0, cfg_i2s_1_gen_clk_en_i, 3'h0, r_i2s_cfg1_bits_word};
        default:
            cfg_data_o = 'h0;
        endcase
    end

    assign cfg_ready_o  = 1'b1;

endmodule 
