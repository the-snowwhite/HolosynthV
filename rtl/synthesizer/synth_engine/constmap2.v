module constmap2
(
    // Input Ports
    input [8:0]sound,
	input clk,
    // Output Ports
    output [23:0]constant
);

constmaprom2	constmaprom_inst (
	.address ( sound[7:0] ),
	.clock ( clk ),
	.q ( constant )
	);

endmodule
