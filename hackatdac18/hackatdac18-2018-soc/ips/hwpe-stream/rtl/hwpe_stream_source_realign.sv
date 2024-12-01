/*
 * hwpe_stream_source_realign.sv
 * Francesco Conti <f.conti@unibo.it>
 *
 * Copyright (C) 2014-2018 ETH Zurich, University of Bologna
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

import hwpe_stream_package::*;

module hwpe_stream_source_realign #(
  parameter int unsigned DATA_WIDTH = 32
)
(
  input  logic                    clk_i,
  input  logic                    rst_ni,
  input  logic                    test_mode_i,
  input  logic                    clear_i,

  input  ctrl_realign_t           ctrl_i,
  
  input  logic [DATA_WIDTH/8-1:0] strb_i, 
  hwpe_stream_intf_stream.sink    stream_i,
  hwpe_stream_intf_stream.source  stream_o
);

  logic unsigned [$clog2(DATA_WIDTH/8):0] strb_rotate_d;
  logic unsigned [$clog2(DATA_WIDTH/8):0] strb_rotate_inv_d;
  logic [DATA_WIDTH-1:0]   stream_data_q;
  logic unsigned [$clog2(DATA_WIDTH/8):0] strb_rotate_q;
  logic unsigned [$clog2(DATA_WIDTH/8):0] strb_rotate_inv_q;

  logic unsigned [$clog2(DATA_WIDTH/8)+3:0] strb_rotate_q_shifted;
  logic unsigned [$clog2(DATA_WIDTH/8)+3:0] strb_rotate_inv_q_shifted;

  logic clk_gated;

  /* clock gating */
  cluster_clock_gating i_realign_gating (
    .clk_i     ( clk_i         ),
    .test_en_i ( test_mode_i   ),
    .en_i      ( ctrl_i.enable ),
    .clk_o     ( clk_gated     )
  );

  /* management of misaligned access */

  // save the strobes of the first misaligned transfer as a reference!
  // this implicitly assumes that all strobes result in a rotation - it
  // must be thus!!
  always_comb
  begin
    strb_rotate_d = '0;
    for (int i=0; i<DATA_WIDTH/8; i++)
      strb_rotate_d += ($clog2(DATA_WIDTH/8))'(strb_i[i]);
  end
  assign strb_rotate_inv_d = {($clog2(DATA_WIDTH/8)){1'b1}} - strb_rotate_d + 1;;

  always_ff @(posedge clk_gated or negedge rst_ni)
  begin
    if(~rst_ni) begin
      strb_rotate_q <= '0;
      strb_rotate_inv_q <= '0;
    end
    else if (clear_i) begin
      strb_rotate_q <= '0;
      strb_rotate_inv_q <= '0;
    end
    else if (~ctrl_i.last_packet & ctrl_i.first) begin
      strb_rotate_q <= strb_rotate_d;
      strb_rotate_inv_q <= strb_rotate_inv_d;
    end
  end
  assign strb_rotate_q_shifted = strb_rotate_q << 3;
  assign strb_rotate_inv_q_shifted = strb_rotate_inv_q << 3;

  always_ff @(posedge clk_gated or negedge rst_ni)
  begin
    if(~rst_ni)
      stream_data_q <= '0;
    else if (clear_i)
      stream_data_q <= '0;
    // last packet is kept "forever"
    else if (~ctrl_i.last_packet & stream_i.valid & stream_i.ready)
      stream_data_q <= stream_i.data;
  end
  always_comb
  begin
    stream_o.data = stream_i.data;
    if(ctrl_i.realign) begin
      if ((strb_rotate_q != '1) && (strb_rotate_q != '0))
        stream_o.data = stream_i.data << strb_rotate_q_shifted | stream_data_q >> strb_rotate_inv_q_shifted;
    end
  end
  assign stream_o.valid = (~ctrl_i.realign)    ? stream_i.valid :
                          (ctrl_i.last_packet) ? stream_i.valid :
                                                 stream_i.valid & ~ctrl_i.first & (ctrl_i.last | (|strb_i));
  assign stream_i.ready = (~ctrl_i.realign)    ? stream_o.ready :
                          (ctrl_i.last_packet) ? stream_o.valid & stream_o.ready :
                                                 stream_o.ready | ctrl_i.first;

  assign stream_o.strb = '1;

endmodule // hwpe_stream_source_realign
