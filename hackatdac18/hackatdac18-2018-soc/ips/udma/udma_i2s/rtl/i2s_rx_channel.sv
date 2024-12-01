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
// Description: RX channles of I2S module
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////


module i2s_rx_channel #(
    parameter CIC_N_STAGES = 5,
    parameter CIC_ACC_WIDTH = 51
) (
    input  logic                    sck_i,
    input  logic                    rstn_i,

    input  logic                    sd_i,
    input  logic                    ws_i,

    output logic             [31:0] fifo_data_o,
    output logic                    fifo_data_valid_o,
    input  logic                    fifo_data_ready_i,

    output logic                    fifo_err_o,
    input  logic                    fifo_err_clr_i,

    input  logic                    cfg_update_i, 
    input  logic              [9:0] cfg_decimation_i, 
    input  logic              [2:0] cfg_shift_i, 

    input  logic                    cfg_lsb_first_i,
    input  logic                    cfg_snap_cam_i,

    input  logic                    cfg_pdm_en_i,
    input  logic                    cfg_pdm_ddr_i,
    input  logic                    cfg_pdm_usefilter_i
);

    logic  [1:0] r_ws_sync;
    logic        s_ws_edge;
    logic        s_ws_redge;

    logic [31:0] r_shiftreg_pos;
    logic [32:0] r_shiftreg_neg;

    logic        r_send_neg;

    logic [4:0]  r_counter;

    logic        s_cic_data_valid_pos;
    logic        s_cic_data_valid_neg;
    logic        s_cic_result_valid_pos;
    logic        s_cic_result_valid_neg;
    logic [15:0] s_cic_result_pos;
    logic [15:0] s_cic_result_neg;

    logic        r_sel_pos;
    logic        r_fifo_data_filter_pos_valid;
    logic        r_fifo_data_filter_neg_valid;

    logic [31:0] s_fifo_data;
    logic [31:0] s_fifo_data_filter;

    logic        s_clk_inv;

    logic        s_fifo_data_filter_valid;
    logic        s_fifo_data_valid;

    pulp_clock_inverter i_clk_inv
    (
        .clk_i(sck_i),
        .clk_o(s_clk_inv)
    );

    varcic #( 
        .STAGES(CIC_N_STAGES),
        .ACC_WIDTH(CIC_ACC_WIDTH)
    ) i_cic_pos (

        .clk_i(sck_i),
        .rstn_i(rstn_i),

        .cfg_update_i(cfg_update_i),

        .cfg_decimation_i(cfg_decimation_i),
        .cfg_shift_i(cfg_shift_i),

        .data_i(sd_i),
        .data_valid_i(s_cic_data_valid_pos),

        .data_o(s_cic_result_pos),
        .data_valid_o(s_cic_result_valid_pos)
    );  

    varcic #( 
        .STAGES(CIC_N_STAGES),
        .ACC_WIDTH(CIC_ACC_WIDTH)
    ) i_cic_neg (

        .clk_i(s_clk_inv),
        .rstn_i(rstn_i),

        .cfg_update_i(cfg_update_i),

        .cfg_decimation_i(cfg_decimation_i),
        .cfg_shift_i(cfg_shift_i),

        .data_i(sd_i),
        .data_valid_i(s_cic_data_valid_neg),

        .data_o(s_cic_result_neg),
        .data_valid_o(s_cic_result_valid_neg)
    );  

    assign s_cic_data_valid_pos = cfg_pdm_en_i;
    assign s_cic_data_valid_neg = cfg_pdm_en_i & cfg_pdm_ddr_i;

    assign s_fifo_data_filter_valid = r_fifo_data_filter_pos_valid | r_fifo_data_filter_neg_valid;
    assign s_fifo_data_filter       = r_sel_pos ? s_cic_result_pos : s_cic_result_neg;

    always_ff @(posedge sck_i or negedge rstn_i) 
    begin : proc_valid_o
        if(~rstn_i) 
        begin
            r_fifo_data_filter_pos_valid <= 0;
            r_fifo_data_filter_neg_valid <= 0;
            r_sel_pos <= 1'b1;
        end 
        else 
        begin
            if(cfg_pdm_usefilter_i)
            begin
                if (!s_fifo_data_filter_valid && (s_cic_result_valid_neg || s_cic_result_valid_pos))
                begin
                    r_fifo_data_filter_pos_valid <= s_cic_result_valid_pos;
                    r_fifo_data_filter_neg_valid <= s_cic_result_valid_neg;
                    if (s_cic_result_valid_pos)
                        r_sel_pos <= 1'b1;
                    else
                        r_sel_pos <= 1'b0;
                end
                else if (s_fifo_data_filter_valid)
                begin
                    if (fifo_data_ready_i)
                    begin
                        if (r_sel_pos)
                        begin
                            r_fifo_data_filter_pos_valid <= s_cic_result_valid_pos;
                            if (r_fifo_data_filter_neg_valid || s_cic_result_valid_neg)
                                r_sel_pos <= 1'b0;
                            if (s_cic_result_valid_neg)
                                r_fifo_data_filter_neg_valid <= 1'b1;
                        end
                        else
                        begin
                            r_fifo_data_filter_neg_valid <= s_cic_result_valid_neg;                            
                            if (r_fifo_data_filter_pos_valid || s_cic_result_valid_pos)
                                r_sel_pos <= 1'b1;
                            if (s_cic_result_valid_pos)
                                r_fifo_data_filter_pos_valid <= 1'b1;
                        end
                    end
                    else
                    begin
                        if (s_cic_result_valid_neg)
                            r_fifo_data_filter_neg_valid <= 1'b1;
                        if (s_cic_result_valid_pos)
                            r_fifo_data_filter_pos_valid <= 1'b1;
                    end
                end
            end
            else
            begin
                r_fifo_data_filter_pos_valid <= 0;
                r_fifo_data_filter_neg_valid <= 0;
            end
        end
    end

    //Delay WS edge
    always_ff  @(posedge sck_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            r_send_neg  <= 1'b0;
        end
        else
        begin
            if (s_ws_edge & cfg_pdm_ddr_i)
                r_send_neg <= 1'b1;
            else
                r_send_neg <= 1'b0;
        end
    end


    //Posedge Shift Register
    always_ff  @(posedge sck_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            r_shiftreg_pos  <=  'h0;
        end
        else
        begin
            //sample data if in any mode or if in snap_mode and delayed WS is low
            if (!cfg_snap_cam_i || (cfg_snap_cam_i && !r_ws_sync[0]))
            begin
                if (cfg_lsb_first_i)
                    r_shiftreg_pos[r_counter] <= sd_i;
                else
                    r_shiftreg_pos  <= {r_shiftreg_pos[30:0],sd_i};
            end
        end
    end

    //Negedge Shift Register
    always_ff  @(negedge sck_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            r_counter <= 'h0;
            r_shiftreg_neg  <= 'h0;
        end
        else
        begin
            if (s_ws_edge)
                r_counter <= 'h0;
            else 
                r_counter <= r_counter + 1;
            if (cfg_pdm_ddr_i)
            begin
                if (cfg_lsb_first_i)
                begin
                    r_shiftreg_neg[r_counter] <= sd_i;
                    if (s_ws_edge) 
                        r_shiftreg_neg[32] <= r_shiftreg_neg[0];
                end
                else
                    r_shiftreg_neg  <= {r_shiftreg_neg[31:0],sd_i};
            end
        end
    end

    //WS Syncronizer
    always_ff  @(posedge sck_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            r_ws_sync  <= 'h0;
        end
        else
        begin
            r_ws_sync  <= {r_ws_sync[0],ws_i};
        end
    end

    //Sticky error
    always_ff  @(posedge sck_i, negedge rstn_i)
    begin
        if (rstn_i == 1'b0)
        begin
            fifo_err_o  <= 1'b0;
        end
        else
        begin
            if (fifo_err_clr_i)
                fifo_err_o  <= 1'b0;
            else if( fifo_data_valid_o && !fifo_data_ready_i )
                fifo_err_o  <= 1'b1;
        end
    end

    always_comb 
    begin
        if(r_send_neg)
            if(cfg_lsb_first_i)
                s_fifo_data = {r_shiftreg_neg[31:1],r_shiftreg_neg[32]};
            else
                s_fifo_data = r_shiftreg_neg[32:1];
        else
            s_fifo_data = r_shiftreg_pos;
    end

    assign s_ws_edge  = r_ws_sync[0] ^  r_ws_sync[1];
    assign s_ws_redge = r_ws_sync[0] & ~r_ws_sync[1];

    assign s_fifo_data_valid = cfg_snap_cam_i ? s_ws_redge : (s_ws_edge | r_send_neg);

    assign fifo_data_o       = cfg_pdm_usefilter_i ? s_fifo_data_filter       : s_fifo_data;
    assign fifo_data_valid_o = cfg_pdm_usefilter_i ? s_fifo_data_filter_valid : s_fifo_data_valid;

endmodule

