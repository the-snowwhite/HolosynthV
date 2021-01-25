module syncro (
    input  wire  clka_clkin,
    input  wire  clkb_clkin,
    input  wire  sig1_in,
    input  wire  sig2_in,
    output wire  sig1_out,
    output wire  sig2_out
);
//     reg [1:0] sig_buffer [2:0];
//     always @(posedge clkb_clkin) begin
//         sig_buffer[0] <= {sig2_in,sig1_in};
//         sig_buffer[1] <= sig_buffer[0];
//         sig_buffer[2] <= sig_buffer[1];
//     end
//     assign sig1_out = sig_buffer[2][0];
//     assign sig2_out = sig_buffer[2][1];
    (* ASYNC_REG = "TRUE" *) reg sig_buffer0_0;
    (* ASYNC_REG = "TRUE" *) reg sig_buffer1_0;
    (* ASYNC_REG = "TRUE" *) reg sig_buffer2_0;
    (* ASYNC_REG = "TRUE" *) reg sig_buffer0_1;
    (* ASYNC_REG = "TRUE" *) reg sig_buffer1_1;
    (* ASYNC_REG = "TRUE" *) reg sig_buffer2_1;
    always @(posedge clkb_clkin) begin
        sig_buffer0_0 <= sig1_in;
        sig_buffer1_0 <= sig_buffer0_0;
        sig_buffer2_0 <= sig_buffer1_0;
        sig_buffer0_1 <= sig2_in;
        sig_buffer1_1 <= sig_buffer0_1;
        sig_buffer2_1 <= sig_buffer1_1;
    end
    assign sig1_out = sig_buffer2_0;
    assign sig2_out = sig_buffer2_1;
endmodule
