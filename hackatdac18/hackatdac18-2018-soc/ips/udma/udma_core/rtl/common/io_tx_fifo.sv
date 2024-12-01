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
// Description: TX FIFO with outstanding request support
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////
`define log2(VALUE) ((VALUE) < ( 1 ) ? 0 : (VALUE) < ( 2 ) ? 1 : (VALUE) < ( 4 ) ? 2 : (VALUE) < ( 8 ) ? 3 : (VALUE) < ( 16 )  ? 4 : (VALUE) < ( 32 )  ? 5 : (VALUE) < ( 64 )  ? 6 : (VALUE) < ( 128 ) ? 7 : (VALUE) < ( 256 ) ? 8 : (VALUE) < ( 512 ) ? 9 : (VALUE) < ( 1024 ) ? 10 : (VALUE) < ( 2048 ) ? 11 : (VALUE) < ( 4096 ) ? 12 : (VALUE) < ( 8192 ) ? 13 : (VALUE) < ( 16384 ) ? 14 : (VALUE) < ( 32768 ) ? 15 : (VALUE) < ( 65536 ) ? 16 : (VALUE) < ( 131072 ) ? 17 : (VALUE) < ( 262144 ) ? 18 : (VALUE) < ( 524288 ) ? 19 : (VALUE) < ( 1048576 ) ? 20 : (VALUE) < ( 1048576 * 2 ) ? 21 : (VALUE) < ( 1048576 * 4 ) ? 22 : (VALUE) < ( 1048576 * 8 ) ? 23 : (VALUE) < ( 1048576 * 16 ) ? 24 : 25)

module io_tx_fifo
#(
    parameter DATA_WIDTH = 32,
    parameter BUFFER_DEPTH = 2,
    parameter LOG_BUFFER_DEPTH = `log2(BUFFER_DEPTH)
)
(
    input  logic                    clk_i,
    input  logic                    rstn_i,

    input  logic                    clr_i,

    output logic                    req_o,
    input  logic                    gnt_i,

    output logic [DATA_WIDTH-1 : 0] data_o,
    output logic                    valid_o,
    input  logic                    ready_i,

    input  logic                    valid_i,
    input  logic [DATA_WIDTH-1 : 0] data_i,
    output logic                    ready_o
);
    logic [LOG_BUFFER_DEPTH:0]      s_elements;    // number of elements in the buffer
    logic [LOG_BUFFER_DEPTH:0]      s_free_ele;    // number of free elements in the buffer
    logic [LOG_BUFFER_DEPTH:0]      r_inflight; 
    logic                           s_stop_req;   

    io_generic_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .BUFFER_DEPTH(BUFFER_DEPTH),    
        .LOG_BUFFER_DEPTH(LOG_BUFFER_DEPTH)
    ) i_fifo (
        .clk_i(clk_i),
        .rstn_i(rstn_i),

        .clr_i(clr_i),

        .elements_o(s_elements),

        .data_o(data_o),
        .valid_o(valid_o),
        .ready_i(ready_i),

        .valid_i(valid_i),
        .data_i(data_i),
        .ready_o(ready_o)
    );

    assign s_free_ele = BUFFER_DEPTH - s_elements;
    assign s_stop_req = (s_free_ele == r_inflight);

    assign req_o = ready_o & ~s_stop_req;

    always_ff @(posedge clk_i, negedge rstn_i)
    begin: elements_sequential
        if (rstn_i == 1'b0)
            r_inflight <= 0;
        else
        begin
            if(req_o && gnt_i)
            begin
                if (~valid_i || ~ready_o)
                    r_inflight <= r_inflight + 1;
            end
            else if (valid_i && ready_o)
                r_inflight <= r_inflight - 1;
        end
    end


endmodule
