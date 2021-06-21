module syncro2_1 (
    input  wire  clk,
    input  wire  sig1_in,
    output wire  sig1_out
);
    (* ASYNC_REG = "TRUE" *) reg is_metastable_sig0_0,is_metastable_sig1_0;
    always @(posedge clk) begin
        is_metastable_sig0_0 <= sig1_in;
        is_metastable_sig1_0 <= is_metastable_sig0_0;
    end
    assign sig1_out = is_metastable_sig1_0;
endmodule
