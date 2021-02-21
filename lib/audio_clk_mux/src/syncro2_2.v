module syncro2_2 (
    input  wire  clk,
    input  wire  sig1_in,
    input  wire  sig2_in,
    output wire  sig1_out,
    output wire  sig2_out
);
    (* ASYNC_REG = "TRUE" *) reg is_metastable_sig0_0,is_metastable_sig1_0;
    (* ASYNC_REG = "TRUE" *) reg is_metastable_sig0_1,is_metastable_sig1_1;
    always @(posedge clk) begin
        is_metastable_sig0_0 <= sig1_in;
        is_metastable_sig1_0 <= is_metastable_sig0_0;
        is_metastable_sig0_1 <= sig2_in;
        is_metastable_sig1_1 <= is_metastable_sig0_1;
    end
    assign sig1_out = is_metastable_sig1_0;
    assign sig2_out = is_metastable_sig1_1;
endmodule
