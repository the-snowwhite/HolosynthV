module sig_syncro #(parameter N = 24) (
    input  wire clkin,
    input  wire [N-1:0] sig_in,
    output wire [N-1:0] synced_sig_out
);
     (* ASYNC_REG = "TRUE" *) reg [N-1:0] sig_buffer [2:0];
     always @(posedge clkin) begin
         sig_buffer[0] <= sig_in;
         sig_buffer[1] <= sig_buffer[0];
         sig_buffer[2] <= sig_buffer[1];
     end
     assign synced_sig_out = sig_buffer[2];
endmodule
