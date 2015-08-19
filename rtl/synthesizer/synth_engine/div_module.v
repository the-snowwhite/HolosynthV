
module div_module
(
input  [15:0]denom ,
input  [36:0]numer ,
output [36:0]quotient
);

wire signed [15:0]d = denom;
wire signed [36:0]n = numer;
wire signed [36:0]q;
assign q = n / d;
assign quotient = q;

endmodule
