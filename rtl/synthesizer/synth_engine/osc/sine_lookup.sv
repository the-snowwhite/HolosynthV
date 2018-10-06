module sine_lookup(
    input wire                  clk,
    input wire [10:0]           addr,
    output reg signed [16:0]    sine_value
);

// sine lookup value module using two symmetries
// appears like a 2048x10bits LUT even if it uses a 512x10bits internally
// 3 clock latency

wire  [15:0] LUT_output;

//blockram512x16bits_2clklatency my_DDS_sine_LUT(        // the LUT must contain only the first quarter of the sine wave
//    .clock(clk),
//    .address(addr[9] ? ~addr[8:0] : addr[8:0]),   // first symmetry
//    .q(LUT_output)
//);


blockrom512x16bits blockrom512x16bits_inst
(
	.addr(addr[9] ? ~addr[8:0] : addr[8:0]) ,	// input [ADDR_WIDTH-1:0] addr_sig
	.clk(clk) ,	// input  clk_sig
	.q(LUT_output) 	// output [DATA_WIDTH-1:0] q_sig
);

defparam blockrom512x16bits_inst.DATA_WIDTH = 16;
defparam blockrom512x16bits_inst.ADDR_WIDTH = 9;


// for the second symmetry, we need to use addr[10]
// but since we use a blockram that has 2 clock latencies on reads
// we need a two-clock delayed version of addr[10] here
reg addr10_delay1; always @(posedge clk) addr10_delay1 <= addr[10];
reg addr10_delay2; always @(posedge clk) addr10_delay2 <= addr10_delay1;

// now we can apply the second symmetry (and add a third latency to the module output for best performance)

    always @(posedge clk)begin
        sine_value <= signed '(!LUT_output ? {1'b0,LUT_output} : addr10_delay2 ? {1'b1,-LUT_output} : {1'b0,LUT_output});
    end

endmodule
