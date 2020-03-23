module pitchdiv
(
input  wire [7:0]denom ,
input  wire [24:0]numer ,
output wire signed [24:0] quotient
);

wire signed [7:0]d = denom;
wire signed [24:0]n = numer;
wire signed [24:0]q;
assign q = n / d;
assign quotient = q;

endmodule
