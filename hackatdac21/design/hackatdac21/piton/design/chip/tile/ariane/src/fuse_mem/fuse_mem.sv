 /*
 * FUSE mem: Which have all the secure data
 */

module fuse_mem 
(
   input  logic         clk_i,
   output  logic [255:0]  jtag_hash_o, ikey_hash_o, okey_hash_o,

   input  logic         req_i,
   input  logic [31:0]  addr_i,
   output logic [31:0]  rdata_o
);
    parameter  MEM_SIZE = 100;
    localparam JTAG_OFFSET = 81; 

// Store key values here. // Replication of fuse. 
    const logic [MEM_SIZE-1:0][31:0] mem = {
        // JTAG expected hamc hash
        32'h49ac13af, 32'h1276f1b8, 32'h6703193a, 32'h65eb531b,
        32'h3025ccca, 32'h3e8861f4, 32'h329edfe5, 32'h98f763b4,
        //RNG POLY 
        // poly 128
        32'ha0000014, 32'h00000000, 32'h00000000, 32'h00000000, 
        // poly 64
        32'hd8000000, 32'h00000000, 
        //poly 32
        32'h00000000,
        // poly 16
        32'h0000d008, 
        //RNG POLY END
        //HMAC okey hash
        32'hd5de2a45, 32'ha2a90626, 32'h595bee9e, 32'h537f47da, 
        32'h747616fd, 32'hb878b776, 32'hf787e54b, 32'hb9418290,
        //HMAC ikey hash
        32'h1c9d0b34, 32'h8683fd98, 32'h736ab688, 32'h81c2c0da, 
        32'h99b1d298, 32'h33d2b38d, 32'h07e12a57, 32'hfbc8cd46,
        //HMAC key
        "$$|-", "|/-\\", "[|<@", "|]/_", 
        "\\{<=", "=>H@", "ckAd", "aC$$",
        // Access control for master 2. First 4 bits for peripheral 0, next 4 for p1 and so on.
        32'hff8f8f8f,
        32'hfffccff8,
        32'hfff0f888, 
        // Access control for master 1. First 4 bits for peripheral 0, next 4 for p1 and so on.
        32'hf8ff8fff,
        32'hf8fc88c8,
        32'hfc8f8ff8,
        // Access control for master 0. First 4 bits for peripheral 0, next 4 for p1 and so on.
        32'hffffffff,
        32'hfffff888,
        32'h888f888f,
        // SHA Key
        32'h28aed2a6,
        32'h28aed2a6,
        32'habf71588,
        32'h09cf4f3c,
        32'h2b7e1516,
        32'h28aed2a6,
        // AES2 Key 2
        32'h23304b7a,
        32'h39f9f3ff,
        32'h067d8d9f,
        32'h9e24ecc7,
        // AES2 Key 1
        32'hf3eed1bd,
        32'hb5d2a03c,
        32'h064b5a7e,
        32'h3db181f8,
        // AES2 Key 0
        32'h00000001,
        32'h00000010,
        32'h00010000,
        32'h04200000,
        // AES1 Key 2
        32'h23304b7a,
        32'h39f9f3ff,
        32'h067d8d8f,
        32'h9e24ecc7,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,    // LSB 32 bits
        // AES1 Key 1
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,    // LSB 32 bits
        // AES1 Key 0
        32'h2b7e1516,
        32'h28aed2a6,
        32'habf71588,
        32'h09cf4f3c,
        32'h00000000,
        32'h00000000,
        32'h00000000,
        32'h00000000,  // LSB 32 bits
        // AES0 Key 2
        32'h28aed9a6,
        32'h207e1516,
        32'h09c94f3c,
        32'ha6f71558,
        32'h2b7e1516,    
        32'h28aed2a6, // LSB 32 bits
        // AES0 Key 1
        32'hf3eed1bd,
        32'hb5d2a03c,
        32'h064b5a7e,
        32'h3db181f8,
        32'hf3eed1bd,
        32'hb5d2a03c,
        32'h064b5a7e,
        32'h3db181f8,   // LSB 32 bits
        // AES0 Key 0
        32'h28aef2a6,
        32'h2b3e1216,    
        32'habf71588,
        32'h09cf4f3c,
        32'h2b7e1516,
        32'h28aed2a6    // LSB 32 bits
    };

    logic [$clog2(MEM_SIZE)-1:0] addr_q;
    
    always_ff @(posedge clk_i) begin
        if (req_i) begin
            addr_q <= addr_i[$clog2(MEM_SIZE)-1:0];
        end
    end

    // this prevents spurious Xes from propagating into
    // the speculative fetch stage of the core
    assign rdata_o = (addr_q < MEM_SIZE) ? mem[addr_q] : '0;

    assign jtag_hash_o = {mem[JTAG_OFFSET-1],mem[JTAG_OFFSET-2],mem[JTAG_OFFSET-3],mem[JTAG_OFFSET-4],mem[JTAG_OFFSET-5],mem[JTAG_OFFSET-6],mem[JTAG_OFFSET-7],mem[JTAG_OFFSET-8]};  // jtag key is not a AXI mapped address space, so passing the value directly
    assign okey_hash_o = {mem[JTAG_OFFSET-9],mem[JTAG_OFFSET-10],mem[JTAG_OFFSET-11],mem[JTAG_OFFSET-12],mem[JTAG_OFFSET-13],mem[JTAG_OFFSET-14],mem[JTAG_OFFSET-15],mem[JTAG_OFFSET-16]};  
    assign ikey_hash_o = {mem[JTAG_OFFSET-17],mem[JTAG_OFFSET-18],mem[JTAG_OFFSET-19],mem[JTAG_OFFSET-20],mem[JTAG_OFFSET-21],mem[JTAG_OFFSET-22],mem[JTAG_OFFSET-23],mem[JTAG_OFFSET-24]};
// jtag key is not a AXI mapped address space, so passing the value directly


endmodule
