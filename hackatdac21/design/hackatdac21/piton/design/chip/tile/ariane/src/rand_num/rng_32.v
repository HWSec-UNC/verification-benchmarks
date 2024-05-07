module rng_32(
    input               clk,
    input             rst_n,
    input             load_i,
    input      [31:0]   seed_i,
    input      [31:0]   poly_i,
    output     [31:0] entropy32_o,
    output              entropy32_valid_o
);


reg in_sr, entropy32_valid;
reg [31:0] entropy32;

assign entropy32_o = entropy32;
assign entropy32_valid_o = entropy32_valid;


always @ (*)
begin
    in_sr = ^ (poly_i [31:0] & entropy32 [31:0]);
end

always@(posedge clk or negedge rst_n)
begin
    
    if(!rst_n)
    begin
        entropy32    <= 32'b0;
        entropy32_valid <= 0;  
    end
    else if(load_i)
    begin
        entropy32 <=seed_i;
        entropy32_valid <= 0;   
    end
    else
        begin
            entropy32[30:0] <= entropy32[31:1];
            entropy32[31] <= in_sr;
            entropy32_valid <= 1;
        end

end
endmodule