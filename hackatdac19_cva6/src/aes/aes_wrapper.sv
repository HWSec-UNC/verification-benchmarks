// Usage:
// All signals used in the description are apb_register signals
// 1) writing: First enable write signal
//      1st clock cycle: give start in 0th bit of wdata
//
//      2nd clock cycle: give msb 32 bits of plain text to wdata
//      3rd clock cycle: give next 32 bits of plain text to wdata
//      4th clock cycle: give next 32 bits of plain text to wdata
//      5th clock cycle: give last 32 bits of plain text to wdata i.e., 31:0
//
//      12nd clock cycle: give msb 32 bits of state to wdata
//      13rd clock cycle: give next 32 bits of state to wdata
//      14th clock cycle: give next 32 bits of state to wdata
//      15th clock cycle: give last 32 bits of state to wdata i.e., 31:0
//
// Author: Bhagyaraja 
//


module aes_wrapper #(
    parameter int ADDR_WIDTH         = 32,   // width of external address bus
    parameter int DATA_WIDTH         = 32   // width of external data bus
)(
           clk_i,
           rst_ni,
           key_in,
           external_bus_io
       );

    input  logic                   clk_i;
    input  logic                   rst_ni;
    input  logic    [191:0]        key_in;
    REG_BUS.in                     external_bus_io;

// internal signals

logic start;
logic [31:0] p_c [0:3];
logic [31:0] state [0:3];
//logic [31:0] key [0:5];

logic   [127:0] p_c_big   ;   // = {p_c[0], p_c[1], p_c[2], p_c[3]};
logic   [127:0] state_big ;  // = {state[0], state[1], state[2], state[3]};
logic   [191:0] key_big ;  // = {key[0], key[1], key[2], key[3], key[4], key[5]};
logic   [127:0] inter_state; 
logic   [127:0] ct;
logic           ct_valid;
const logic   [127:0] state_iv = 127'h3243f6a8_885a308d_00000000_00000001; 


assign external_bus_io.ready = 1'b1;
assign external_bus_io.error = 1'b0;

assign p_c_big    = {p_c[0], p_c[1], p_c[2], p_c[3]};
assign state_big  = {state[0], state[1], state[2], state[3]};
//assign key_big    = {key[0], key[1], key[2], key[3], key[4], key[5]};
assign key_big    = key_in;
///////////////////////////////////////////////////////////////////////////
// Implement APB I/O map to AES interface
// Write side
always @(posedge clk_i)
    begin
        if(~rst_ni)
            begin
                start <= 0;
                p_c[0] <= 0;
                p_c[1] <= 0;
                p_c[2] <= 0;
                p_c[3] <= 0;
                state[0] <= 0;
                state[1] <= 0;
                state[2] <= 0;
                state[3] <= 0;
            end
        else if(external_bus_io.write)
            case(external_bus_io.addr[6:2])
                0:
                    start <= external_bus_io.wdata[0];
                1:
                    p_c[3] <= external_bus_io.wdata;
                2:
                    p_c[2] <= external_bus_io.wdata;
                3:
                    p_c[1] <= external_bus_io.wdata;
                4:
                    p_c[0] <= external_bus_io.wdata;
		// no write access to ct registers !!

                16:
                    state[3] <= external_bus_io.wdata;
                17:
                    state[2] <= external_bus_io.wdata;
                18:
                    state[1] <= external_bus_io.wdata;
                19:
                    state[0] <= external_bus_io.wdata;
                default:
                    ;
            endcase
    end // always @ (posedge wb_clk_i)

// Implement MD5 I/O memory map interface
// Read side
//always @(~external_bus_io.write)
always @(*)
    begin
        case(external_bus_io.addr[6:2])
            0:
                external_bus_io.rdata = {31'b0, start};
            1:
                external_bus_io.rdata = p_c[3];
            2:
                external_bus_io.rdata = p_c[2];
            3:
                external_bus_io.rdata = p_c[1];
            4:
                external_bus_io.rdata = p_c[0];
            11:
                external_bus_io.rdata = {31'b0, ct_valid};
            12:
                external_bus_io.rdata = ct[127:96];
            13:
                external_bus_io.rdata = ct[95:64];
            14:
                external_bus_io.rdata = ct[63:32];
            15:
                external_bus_io.rdata = ct[31:0];
            16:
                external_bus_io.rdata = key_big[191:160];
            17:
                external_bus_io.rdata = key_big[159:128];
            18:
                external_bus_io.rdata = key_big[127:96];
            19:
                external_bus_io.rdata = key_big[95:64];
            20:
                external_bus_io.rdata = key_big[63:32];
            21:
                external_bus_io.rdata = key_big[31:0];
            22:
                external_bus_io.rdata = inter_state[127:96];
            23:
                external_bus_io.rdata = inter_state[95:64];
            24:
                external_bus_io.rdata = inter_state[63:32];
            25:
                external_bus_io.rdata = inter_state[31:0];
            default:
                external_bus_io.rdata = 32'b0;
        endcase
    end // always @ (*)

aes_192_sed aes(
            .clk(clk_i),
            .state(state_iv),
            .p_c_text(p_c_big),
            .key(key_big),
            .start(start),
            .inter_state(inter_state),
            .out(ct),
            .out_valid(ct_valid)
        );

endmodule
