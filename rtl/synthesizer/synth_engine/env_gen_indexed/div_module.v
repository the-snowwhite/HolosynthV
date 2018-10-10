
module div_module
(
input wire [15:0]   denom ,
input wire [36:0]   numer ,
output wire [36:0]  quotient
);

wire signed [15:0]d = denom;
wire signed [36:0]n = numer;
wire signed [36:0]q;
assign q = n / d;
assign quotient = q;

endmodule
