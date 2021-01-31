module syncro2_2 (
    input  wire  clk,
    input  wire  sig1_in,
    input  wire  sig2_in,
    output wire  sig1_out,
    output wire  sig2_out
);
    (* ASYNC_REG = "TRUE" *) reg sig_buffer0_0,sig_buffer1_0;
    (* ASYNC_REG = "TRUE" *) reg sig_buffer0_1,sig_buffer1_1;
    always @(posedge clk) begin
        sig_buffer0_0 <= sig1_in;
        sig_buffer1_0 <= sig_buffer0_0;
        sig_buffer0_1 <= sig2_in;
        sig_buffer1_1 <= sig_buffer0_1;
    end
    assign sig1_out = sig_buffer1_0;
    assign sig2_out = sig_buffer1_1;
endmodule
