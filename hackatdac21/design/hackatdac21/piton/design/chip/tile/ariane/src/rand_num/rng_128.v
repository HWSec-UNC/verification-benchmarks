module rng_128(
    input               clk,
    input             rst_n,
    input             load_i,
    input      [127:0]  seed_i,
    input      [127:0]  poly_i,
    output     [127:0]    entropy128_o,
    output              entropy128_valid_o
);

reg in_sr, entropy128_valid;
reg [127:0] entropy128;

assign entropy128_o = entropy128;
assign entropy128_valid_o = entropy128_valid;


always @ (*)
begin
    in_sr = ^ (poly_i [127:0] & entropy128 [127:0]);
end

always@(posedge clk or negedge rst_n)
begin
    
    if(!rst_n)
    begin
        entropy128    <= 128'b0;
        entropy128_valid <= 0;  
    end
    else if(load_i)
    begin
        entropy128 <=seed_i;
        entropy128_valid <= 0;   
    end
    else
        begin
            entropy128[126:0] <= entropy128[127:1];
            entropy128[127] <= in_sr;
            entropy128_valid <= 1;
        end

end
endmodule