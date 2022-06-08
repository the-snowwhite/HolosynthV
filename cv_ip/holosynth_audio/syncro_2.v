/* instansiate
    
    syncro_2 sync_inst (
        .clk(),
        .sig_in(),
        .sig_out()
    );
*/

module syncro_2 (
    input  wire  clk,
    input  wire  sig_in,
    output wire  sig_out
);
    (* ASYNC_REG = "TRUE" *) reg is_metastable_sig1,is_metastable_sig0;
    always @(posedge clk) begin
        is_metastable_sig0 <= sig_in;
        is_metastable_sig1 <= is_metastable_sig0;
    end
    assign sig_out = is_metastable_sig1;
endmodule
