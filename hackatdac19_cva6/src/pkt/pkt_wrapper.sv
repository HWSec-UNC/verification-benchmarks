// Description: Wrapper for the PKT.
//


module pkt_wrapper #(
    parameter int ADDR_WIDTH         = 32,   // width of external address bus
    parameter int DATA_WIDTH         = 32   // width of external data bus
)(
           clk_i,
           rst_ni,
           pkey_loc_o,
           external_bus_io
       );

    input  logic                   clk_i;
    input  logic                   rst_ni;
    output  logic    [31:0]        pkey_loc_o;
    REG_BUS.in                     external_bus_io;

// internal signals

logic req;
logic [31:0] key_index;

//logic   [127:0] ct;


assign external_bus_io.ready = 1'b1;
assign external_bus_io.error = 1'b0;

///////////////////////////////////////////////////////////////////////////
// Implement APB I/O map to PKT interface
// Write side
always @(posedge clk_i)
    begin
        if(~rst_ni)
            begin
                req <= 0;
                key_index <= 0;
            end
        else if(external_bus_io.write)
            case(external_bus_io.addr[6:2])
                0:
                    req <= external_bus_io.wdata[0];
                1:
                    key_index <= external_bus_io.wdata;
                default:
                    ;
            endcase
    end // always @ (posedge wb_clk_i)

//// Implement MD5 I/O memory map interface
//// Read side
////always @(~external_bus_io.write)
//always @(*)
//    begin
//        case(external_bus_io.addr[6:2])
//            0:
//                external_bus_io.rdata = {31'b0, req};
//            12:
//                external_bus_io.rdata = ct[127:96];
//            13:
//                external_bus_io.rdata = ct[95:64];
//            14:
//                external_bus_io.rdata = ct[63:32];
//            15:
//                external_bus_io.rdata = ct[31:0];
//            default:
//                external_bus_io.rdata = 32'b0;
//        endcase
//    end // always @ (*)
//
pkt i_pkt(
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .req_i(req),
            .key_index(key_index),
            .pkey_loc_o(pkey_loc_o)
        );

endmodule
