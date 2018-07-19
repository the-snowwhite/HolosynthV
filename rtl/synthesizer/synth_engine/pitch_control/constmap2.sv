module constmap2
(
    // Input Ports
    input   [8:0]   sound,
    input           clk,
    // Output Ports
    output  [23:0]  constant
);

blockrom256x24bits blockrom256x24bits_inst
(
	.addr( sound[7:0] ) ,	// input [ADDR_WIDTH-1:0] addr_sig
	.clk( clk ) ,	// input  clk_sig
	.q( constant ) 	// output [DATA_WIDTH-1:0] q_sig
);

defparam blockrom256x24bits_inst.DATA_WIDTH = 24;
defparam blockrom256x24bits_inst.ADDR_WIDTH = 8;

// constmaprom2	constmaprom_inst (
//     .address ( sound[7:0] ),
//     .clock ( clk ),
//     .q ( constant )
//     );

endmodule
