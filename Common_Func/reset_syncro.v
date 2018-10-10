module reset_syncro (
    input  wire  clkin,
    input  wire  reset_in,
    output wire  synced_reset_out
);
     (* ASYNC_REG = "TRUE" *) reg sig_buffer [2:0];
     always @(posedge clkin) begin
         sig_buffer[0] <= reset_in;
         sig_buffer[1] <= sig_buffer[0];
         sig_buffer[2] <= sig_buffer[1];
     end
     assign synced_reset_out = sig_buffer[2];
endmodule
