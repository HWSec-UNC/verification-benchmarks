/*
 * hwpe_stream_array_concat.sv
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

module hwpe_stream_array_concat #(
  parameter int unsigned NB_IN_STREAMS = 2,
  parameter int unsigned DATA_SIZE     = 128
)
(
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   clear_i,
  
  hwpe_stream_intf_stream.sink   stream_i [NB_IN_STREAMS-1:0],
  hwpe_stream_intf_stream.source stream_o
);

  parameter DATA_SIZE_OUT = DATA_SIZE_IN/NB_OUT_STREAMS;
  parameter STRB_SIZE_OUT = DATA_SIZE_OUT/8;

  logic [NB_OUT_STREAMS-1:0] stream_ready;

  generate

    for(genvar ii=0; ii<NB_OUT_STREAMS; ii++) begin : stream_binding

      // split data is bound in order
      assign stream_o[ii].data  = stream_i.data [(ii+1)*DATA_SIZE_OUT-1:ii*DATA_SIZE_OUT];
      assign stream_o[ii].strb  = stream_i.strb [(ii+1)*STRB_SIZE_OUT-1:ii*STRB_SIZE_OUT];

      // split valid is broadcast to all outgoing streams
      assign stream_o[ii].valid = stream_i.valid;

      // auxiliary for ready generation
      assign stream_ready[ii] = stream_o[ii].ready;

    end

  endgenerate

  // ready only when all diverging streams are ready
  assign stream_i.ready = & stream_ready;

endmodule // hwpe_stream_array_concat
