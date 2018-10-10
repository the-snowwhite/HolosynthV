module syncro32 (
    input  wire clka_clkin,
    input  wire clkb_clkin,
    input  wire wr_en,
    input  wire [31:0] sig_in,
    output wire [31:0] sig_out
);
    (* ASYNC_REG = "TRUE" *) reg [31:0] sig_buffer0;
    (* ASYNC_REG = "TRUE" *) reg [31:0] sig_buffer1;
    (* ASYNC_REG = "TRUE" *) reg [31:0] sig_buffer2;
    always @(posedge clkb_clkin) begin
        if (~wr_en) begin
            sig_buffer0 <= sig_in;
            sig_buffer1 <= sig_buffer0;
            sig_buffer2 <= sig_buffer1;
        end
    end
    assign sig_out = sig_buffer2;
endmodule
