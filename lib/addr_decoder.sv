module addr_decoder #(
parameter addr_width = 3,
parameter num_lines = 6
) (
input		clk,
input		reset_n,
input 		[addr_width-1:0]	address,
output reg	[num_lines-1:0]	sel
);

genvar i;
generate
    for (i=0;i<num_lines;i++)  begin: mux_loop
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n)begin
                sel[i] <= 1'b0;
            end
            else begin	
                sel[i] <= (address == i) ? 1'b1 : 1'b0; 
            end
        end
    end
endgenerate
endmodule
