/* 
 * mac_top.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 *
 * Copyright (C) 2018 ETH Zurich, University of Bologna
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

module mux_func
(
  // global signals
  input  logic [127:0] a,
  input  logic [127:0] b,
  output logic [127:0] c,
  input  logic [127:0] d,
  input  logic clk,
  input  logic rst
);

logic rdy_out_sha, rdy_out_md5;
logic [127:0] aes_out;
logic [127:0] sha_out;
logic [127:0] md5_out;
logic [127:0] temperature_out;

  aes_1cc aes(
  .clk(0),
  .rst(1),
  .g_input(b),
  .e_input(a),
  .o(aes_out)
  );

  keccak sha(
  .clk(clk),
  .reset(rst),
  .in(a),
  .in_ready(1),
  .out(sha_out),
  .out_ready(rdy_out)
  );

  md5 md5(
  .clk(clk),
  .reset(rst),
  .data_i(a[31:0]),
  .load_i(1),
  .ready_o(rdy_out_md5),
  .data_o(md5_out[31:0])
  );

  tempsen temperature_sensor(
  .clk(clk),
  .in(a),
  .out(temperature_out)
  );

  always @(posedge clk) begin
    if(d[0] == 1'b1) c = aes_out;
    if(d[1] == 1'b1) c = sha_out;
    if(d[2] == 1'b1) c = md5_out;
    if(d[3] == 1'b1) c = temperature_out;
    else c = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
  end
  
  
  //assign c = (a & ~b) | (~a & b);  

endmodule // cust_xor
