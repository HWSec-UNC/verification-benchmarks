// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// ============================================================================= //
// Engineer:       Davide Rossi - davide.rossi@unibo.it                          //
//                                                                               //
// Design Name:    APB BUS                                                       //
// Module Name:    APB_BUS                                                       //
// Project Name:   PULP                                                          //
// Language:       SystemVerilog                                                 //
//                                                                               //
// Description:    This component implements a configurable APB node             //
//                                                                               //
// ============================================================================= //

module apb_node
  #(
    parameter NB_MASTER = 8,
    parameter APB_DATA_WIDTH = 32,
    parameter APB_ADDR_WIDTH = 32
    )
   (

    // SLAVE PORT
    input  logic                                     penable_i,
    input  logic                                     pwrite_i,
    input  logic [31:0]                              paddr_i,
    input  logic [31:0]                              pwdata_i,
    output logic [31:0]                              prdata_o,
    output logic                                     pready_o,
    output logic                                     pslverr_o,

    // MASTER PORTS
    output logic [NB_MASTER-1:0]                     penable_o,
    output logic [NB_MASTER-1:0]                     pwrite_o,
    output logic [NB_MASTER-1:0][31:0]               paddr_o,
    output logic [NB_MASTER-1:0]                     psel_o,
    output logic [NB_MASTER-1:0][31:0]               pwdata_o,
    input  logic [NB_MASTER-1:0][31:0]               prdata_i,
    input  logic [NB_MASTER-1:0]                     pready_i,
    input  logic [NB_MASTER-1:0]                     pslverr_i,

    // CONFIGURATION PORT
    input  logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] START_ADDR_i,
    input  logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] END_ADDR_i

    );

   genvar                              i;
   integer                             s_loop1,s_loop2,s_loop3,s_loop4,s_loop5,s_loop6,s_loop7;

   // GENERATE SEL SIGNAL FOR MASTER MATCHING THE ADDRESS
   generate
      for(i=0;i<NB_MASTER;i++)
        begin
           assign psel_o[i]  =  (paddr_i >= START_ADDR_i[i]) && (paddr_i <= END_ADDR_i[i]);
        end
   endgenerate

   always_comb
     begin
        // PENABLE GENERATION
        for ( s_loop1 = 0; s_loop1 < NB_MASTER; s_loop1++ )
          begin
             if( psel_o[s_loop1] == 1'b1 )
               begin
                  penable_o[s_loop1] = penable_i;
               end
             else
               begin
                  penable_o[s_loop1] = '0;
               end
          end
     end

   // PWRITE GENERATION
   always_comb
     begin
        for ( s_loop2 = 0; s_loop2 < NB_MASTER; s_loop2++ )
          begin
             if( psel_o[s_loop2] == 1'b1 )
               begin
                  pwrite_o[s_loop2] = pwrite_i;
               end
             else
               begin
                  pwrite_o[s_loop2] = '0;
               end
          end
     end

   // PADDR GENERATION
   always_comb
     begin
        for ( s_loop3 = 0; s_loop3 < NB_MASTER; s_loop3++ )
          begin
             if( psel_o[s_loop3] == 1'b1 )
               begin
                  paddr_o[s_loop3] = paddr_i;
               end
             else
               begin
                  paddr_o[s_loop3] = '0;
               end
          end
     end

   // PWDATA GENERATION
   always_comb
     begin
        for ( s_loop4 = 0; s_loop4 < NB_MASTER; s_loop4++ )
          begin
             if(psel_o[s_loop4] == 1'b1)
               begin
                  pwdata_o[s_loop4] = pwdata_i;
               end
             else
               begin
                  pwdata_o[s_loop4] = '0;
               end
          end
     end

   // PRDATA MUXING
   always_comb
     begin
        prdata_o = '0;
        for ( s_loop5 = 0; s_loop5 < NB_MASTER; s_loop5++ )
          begin
             if(psel_o[s_loop5] == 1'b1)
               begin
                  prdata_o = prdata_i[s_loop5];
               end
          end
     end

   // PRREADY MUXING
   always_comb
     begin
        pready_o = '0;
        for ( s_loop6 = 0; s_loop6 < NB_MASTER; s_loop6++ )
          begin
             if(psel_o[s_loop6] == 1'b1)
               begin
                  pready_o = pready_i[s_loop6];
               end
          end
     end

   // PSLVERR MUXING
   always_comb
     begin
        pslverr_o = '0;
        for ( s_loop7 = 0; s_loop7 < NB_MASTER; s_loop7++ )
          begin
             if(psel_o[s_loop7] == 1'b1)
               begin
                  pslverr_o = pslverr_i[s_loop7];
               end
          end
     end

endmodule
