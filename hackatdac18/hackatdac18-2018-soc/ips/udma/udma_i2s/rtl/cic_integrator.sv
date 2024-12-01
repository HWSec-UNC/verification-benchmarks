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
// Description: Integrator block of CIC filter
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////
module cic_integrator #(
	parameter WIDTH = 64
) (	
	input logic clk_i,
	input logic rstn_i,

	input  logic en_i,
	input  logic clr_i,

	input  logic [WIDTH-1:0] data_i,
	output logic [WIDTH-1:0] data_o
);

	logic [WIDTH-1:0] r_accumulator;

	assign data_o = r_accumulator;

	always_ff @(posedge clk_i or negedge rstn_i)
	begin
		if (~rstn_i)
			r_accumulator <= 'h0;
		else
			if (clr_i)
				r_accumulator <= 'h0;
  			else if (en_i) 
  				r_accumulator <= r_accumulator + data_i;
	end

endmodule

