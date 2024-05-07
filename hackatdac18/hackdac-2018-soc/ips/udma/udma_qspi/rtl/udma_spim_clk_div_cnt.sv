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
// Design Name:    SPI Master counter used by clock divider                   //
// Project Name:   SPI Master                                                 //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    SPI Master with full QPI support                           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module udma_spim_clk_div_cnt
(
    input  logic       clk_i,
    input  logic       rstn_i,
    input  logic       en_i,
    input  logic [7:0] clk_div_i,
    input  logic       clk_div_valid_i,
    output logic       clk_o
);

    logic [7:0]         r_counter;
    logic [7:0]         r_target;    

    always_ff @(posedge clk_i, negedge rstn_i)
    begin
        if (~rstn_i)
        begin
            r_counter  <=  'h0;
            r_target   <=  'h0;
            clk_o      <= 1'b0;
        end
        else
        begin
            if (clk_div_valid_i)
            begin
                r_target  <= clk_div_i;
                r_counter <=  'h0;
                clk_o     <= 1'b0;
            end
            else
            begin
                if(en_i)
                    if (r_counter == (r_target - 1))
                    begin
                        clk_o <= ~clk_o;
                        r_counter <= 'h0;
                    end
            end
        end
    end

endmodule
