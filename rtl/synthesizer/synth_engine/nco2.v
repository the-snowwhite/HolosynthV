module nco2 (
    input	reset_reg_N,
    input	sCLK_XVXOSC,
    input	sCLK_XVXENVS,
    input	[23:0]osc_pitch_val,
    input	[V_ENVS-1:0]osc_accum_zero,
    input	[O_WIDTH-1:0] ox,
    input	[V_WIDTH-1:0] vx,
    output	[10:0]phase_acc
);

parameter VOICES = 8;
parameter V_OSC = 4;
parameter V_ENVS = 8;
parameter V_WIDTH = 3;
parameter O_WIDTH = 2;
//parameter x_offset = (V_OSC * VOICES ) - 2;
parameter x_offset = 6;

//parameter x_offset = (V_OSC * VOICES ) - 5;// osc 2,3
//parameter x_offset = (V_OSC * VOICES ) - 8;

	assign phase_acc = phase_accum_b[24:14];
	assign reset = osc_accum_zero[{ox_dly[0],1'b0}];
	
	reg [V_WIDTH-1:0] vx_dly[x_offset:0];
	reg [O_WIDTH-1:0] ox_dly[x_offset:0];
	reg 				reset_dly[2:0];
	wire				reset;
	wire				reset_a;
	wire				reset_b;
	reg signed [10:0] 	reg_phase_acc;   
	reg [23:0] 			reg_osc_pitch_val;
	wire [23:0] 		osc_pitch_val_a;
	wire [23:0] 		osc_pitch_val_b;
	wire [25:0]			phase_accum_a; // 36 bits phase accumulator
	wire [25:0]			phase_accum_b; // 36 bits phase accumulator
	reg [25:0]			reg_phase_accum; // 36 bits phase accumulator
	integer o1,d1;
    nco_ram #(.VOICES(VOICES),.V_OSC(V_OSC),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH))nco_ram_inst
	(
		.qa({reset_a,phase_accum_a,osc_pitch_val_a}) ,  // output [16+37+37+8+21+9-1:0] q_sig
		.qb({reset_b,phase_accum_b,osc_pitch_val_b}) ,  // output [16+37+37+8+21+9-1:0] q_sig
		.d({reset_dly[2],reg_phase_accum,reg_osc_pitch_val}) ,    // input [15+36+36+7+20+8:0] d_sig
		.write_address({vx_dly[5],ox_dly[5]}) ,   // input  write_address_sig
		.reada_address({vx_dly[4],ox_dly[4]}) ,    // input  read_address_sig
//		.readb_address({vx_dly[x_offset],ox_dly[x_offset]}) ,    // input  read_address_sig
		.readb_address({vx_dly[0],ox_dly[0]}) ,    // input  read_address_sig
		.we(1'b1) , // input  we_sig
		.wclk(~sCLK_XVXENVS  ),     // input  clk_sig
		.raclk(~sCLK_XVXOSC  ),     // input  clk_sig
		.rbclk(sCLK_XVXOSC )     // input  clk_sig
	);

	always @(posedge sCLK_XVXENVS or negedge reset_reg_N)begin
		if ( !reset_reg_N)  reg_phase_accum <= 25'b0;
		else  begin reg_phase_accum <= reset_a ? 25'b0 : (phase_accum_a + osc_pitch_val_a); end
	end
	
	always @(posedge sCLK_XVXOSC)begin
		vx_dly[0] <= vx; ox_dly[0] <= ox;
		for(d1=0;d1<x_offset;d1=d1+1) begin 
			vx_dly[d1+1] <= vx_dly[d1]; ox_dly[d1+1] <= ox_dly[d1];
		end
		reset_dly[0] <= reset;
		reset_dly[1] <= reset_dly[0];
		reset_dly[2] <= reset_dly[1];
//		reset_dly[3] <= reset_dly[2];
//		reset_dly[4] <= reset_dly[3];
//		reset_dly[5] <= reset_dly[4];
		reg_osc_pitch_val <= osc_pitch_val;
	end
	 
endmodule
