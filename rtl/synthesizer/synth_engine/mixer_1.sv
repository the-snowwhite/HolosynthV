module mixer_2 (
// Inputs -- //
	input                		sCLK_XVXENVS,  // clk
	input                		sCLK_XVXOSC,  // clk
	input                		reset_reg_N,        // reset
	input                		reset_data_N,        // reset
	input [V_WIDTH+E_WIDTH-1:0] xxxx,
	input                     	n_xxxx_zero,
//  env gen
	input signed [7:0]          level_mul,    // envgen output
	input signed [16:0]         sine_lut_out, // sine

	inout signed [7:0]				data,
	input [6:0]							adr,
	input									write,
	input									read,
	input									sysex_data_patch_send,
	input									osc_sel,
	input									com_sel,
	input									m1_sel,
	input									m2_sel,
// Outputs -- //
// osc
	output reg signed [10:0]		modulation,
// sound data out
`ifdef	_32BitAudio
    output signed [31:0]        lsound_out, // 32-bits
    output signed [31:0]        rsound_out  // 32-bits
`elsif	_24BitAudio
    output signed [23:0]        lsound_out, // 24-bits
    output signed [23:0]        rsound_out  // 24-bits
`else
    output signed [15:0]        lsound_out, // 16-bits
    output signed [15:0]        rsound_out  // 16-bits
`endif
);

parameter VOICES	= 8;
parameter V_OSC		= 4; // oscs per Voice
parameter O_ENVS	= 2; // envs per Oscilator
parameter V_ENVS	= V_OSC * O_ENVS; // envs per Voice
parameter V_WIDTH	= 3;
parameter O_WIDTH	= 2;
parameter OE_WIDTH	= 1;
parameter E_WIDTH	= O_WIDTH + OE_WIDTH;

parameter x_offset = (V_OSC * VOICES ) - 2;
parameter vo_x_offset = x_offset;
`ifdef	_32BitAudio
    parameter output_volume_scaling = 21; // 32-bits
`elsif	_24BitAudio
    parameter output_volume_scaling = 29; // 24-bits
`else
    parameter output_volume_scaling = 37; // 16-bits
`endif

   reg  signed [7:0]osc_lvl[V_OSC-1:0];      // osc_lvl  osc_buf[2]
   reg  signed [7:0]osc_mod[V_OSC-1:0];      // osc_mod    osc_buf[3]
   reg  signed [7:0]osc_feedb[V_OSC-1:0];        // osc_feedb  osc_buf[4]
   reg  signed [7:0]osc_pan[V_OSC-1:0];        // osc_feedb  osc_buf[4]
   reg  signed [7:0]osc_mod_in[V_OSC-1:0];       // osc_mod    osc_buf[10]
   reg  signed [7:0]osc_feedb_in[V_OSC-1:0];     // osc_feedb  osc_buf[11]
   reg  signed [7:0]m_vol;               // m_vol        com_buf[1]
   reg  signed [7:0]mat_buf1[15:0][V_OSC-1:0];
   reg  signed [7:0]mat_buf2[15:0][V_OSC-1:0];
	reg			[7:0]patch_name[15:0];

   reg [O_WIDTH-1:0]  ox_dly[x_offset:0];
   reg [V_WIDTH-1:0]  vx_dly[x_offset:0];

	reg signed [63:0] reg_sine_level_mul_data;
	reg signed [63:0] reg_sine_level_mul_osc_lvl_m_vol_data;

	reg signed [63:0] reg_osc_data_sum_l;
	reg signed [63:0] reg_osc_data_sum_r;

	reg signed [63:0] reg_voice_sound_sum_l;
	reg signed [63:0] reg_voice_sound_sum_r;

	reg signed [7:0] reg_voice_vol_env_lvl;

	reg signed [47:0] reg_sine_mod_data[V_OSC-1:0];
	reg signed [47:0] reg_sine_fb_data[V_OSC-1:0];

	reg signed [47:0] reg_mod_matrix_mul_sum[V_OSC-1:0];
	reg signed [47:0] reg_fb_matrix_mul_sum[V_OSC-1:0];

	reg signed [47:0] reg_mod_matrix_mul[V_OSC-1:0];
	reg signed [47:0] reg_fb_matrix_mul[V_OSC-1:0];

	wire signed [47:0] mod_matrix_mul[V_OSC-1:0];
	wire signed [47:0] fb_matrix_mul[V_OSC-1:0];

	wire signed [47:0] mod_matrix_out_sum;
	wire signed [47:0] fb_matrix_out_sum;

	reg signed [10:0] reg_matrix_data[VOICES-1:0][V_OSC-1:0];


	reg[V_OSC+2:0] sh_voice_reg;
	reg[V_ENVS:0] sh_osc_reg;

	reg [7:0] data_out;

	wire [V_OSC-1:0] osc_adr_data;

	generate
		genvar osc3;
		for (osc3=0;osc3<V_OSC;osc3=osc3+1)begin : oscdataloop
			assign osc_adr_data[osc3] = (adr == (7'd2 +(osc3<<4)) || (adr == 7'd3 +(osc3<<4)) || (adr == 7'd4 +(osc3<<4)) ||
			(adr == 7'd7 +(osc3<<4)) || (adr == 7'd10 +(osc3<<4)) || (adr == 7'd11 +(osc3<<4)) || (adr == 7'd12 +(osc3<<4))
			 || (adr == 7'd13 +(osc3<<4)) || (adr == 7'd14 +(osc3<<4)) || (adr == 7'd15 +(osc3<<4))) ? 1'b1 : 1'b0;
		end
	endgenerate


	assign data = (sysex_data_patch_send && (((osc_adr_data != 0) && osc_sel) || (com_sel && adr >= 1) || m1_sel || m2_sel)) ? data_out : 8'bz;

	wire signed [63:0] sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_l;
	wire signed [63:0] sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_r;

	assign sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_l = reg_sine_level_mul_osc_lvl_m_vol_data * reg_voice_vol_env_lvl * (127 - osc_pan[ox_dly[1]]);
	assign sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_r = reg_sine_level_mul_osc_lvl_m_vol_data * reg_voice_vol_env_lvl * osc_pan[ox_dly[1]];

	wire signed [63:0] lsound_out_full = reg_voice_sound_sum_l * m_vol;
	wire signed [63:0] rsound_out_full = reg_voice_sound_sum_r * m_vol;

	wire [O_WIDTH-1:0]  ox;
	wire [V_WIDTH-1:0]  vx;
	assign ox = xxxx[E_WIDTH-1:OE_WIDTH];
	assign vx = xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH];

//   integer loop,oloop,iloop,inloop,osc1,osc2,ol1,il1,ol2,il2,o21,i21,o22,i22,innam,outnam;
//	integer slmloop,shloop,dloop;
   byte unsigned loop,oloop,iloop,inloop,osc1,osc2,ol1,il1,ol2,il2,o21,i21,o22,i22,innam,outnam;
//	byte unsigned slmloop,shloop;
	shortint unsigned dloop;
/**		@brief get midi controller data from midi decoder
*/
    always@(negedge reset_data_N or negedge write)begin : receive_midi_controller_data
        if(!reset_data_N) begin
            for (loop=0;loop<V_OSC;loop=loop+1)begin
                if(loop <= 1)osc_lvl[loop] <= 8'h40;
                else osc_lvl[loop] <= 8'h00;
                osc_mod[loop] <= 8'h00;
                osc_feedb[loop] <= 8'h00;
                osc_pan[loop] <= 8'h40;
                osc_mod_in[loop] <= 8'h00;
                osc_feedb_in[loop] <= 8'h00;
            end
            for (oloop=0;oloop<16;oloop=oloop+1)begin
                for(iloop=0;iloop<V_OSC;iloop=iloop+1)begin
                    mat_buf1[oloop][iloop] <= 8'h00;
                    mat_buf2[oloop][iloop] <= 8'h00;
                end
            end
            m_vol <= 8'h40;
				for(inloop=0;inloop<16;inloop=inloop+1)begin
					 patch_name[inloop] <= 8'd32;
				end
        end else if(!write) begin
            if(osc_sel)begin
                for (osc1=0;osc1<V_OSC;osc1=osc1+1)begin
                    case (adr)
                        7'd2 +(osc1<<4): osc_lvl[osc1] <= data;
                        7'd3 +(osc1<<4): osc_mod[osc1] <= data;
                        7'd4 +(osc1<<4): osc_feedb[osc1] <= data;
                        7'd7 +(osc1<<4): osc_pan[osc1] <= data;
                        7'd10 +(osc1<<4): osc_mod_in[osc1] <= data;
                        7'd11 +(osc1<<4): osc_feedb_in[osc1] <= data;
                        default:;
                    endcase
                end
            end
            else if(com_sel) begin
                if(adr == 1) m_vol <= data;
					 else if(adr >= 16 && adr < 32)begin
					    for(innam=0;innam<16;innam=innam+1)begin
							 if(adr == (innam + 16)) patch_name[innam] <= data;
						 end
					 end
            end
            else if (m1_sel) begin
               for (ol1=0;ol1<16;ol1=ol1+1)begin
                   for(il1=0;il1<V_OSC;il1=il1+1)begin
                       if (adr == (il1 << 4)+ol1) mat_buf1[ol1][il1] <= data;
                   end
                end
            end
            else if (m2_sel) begin
               for (ol2=0;ol2<16;ol2=ol2+1)begin
                   for(il2=0;il2<V_OSC;il2=il2+1)begin
                       if (adr == (il2 << 4)+ol2)mat_buf2[ol2][il2] <= data;
                   end
                end
            end
        end
    end

/** @brief read data
*/

	always @(posedge read) begin
		if(osc_sel)begin
			for (osc2=0;osc2<V_OSC;osc2=osc2+1)begin
				case (adr)
					7'd2 +(osc2<<4): data_out <= osc_lvl[osc2];
                    7'd3 +(osc2<<4): data_out <= osc_mod[osc2];
                    7'd4 +(osc2<<4): data_out <= osc_feedb[osc2];
                    7'd7 +(osc2<<4): data_out <= osc_pan[osc2];
                    7'd10 +(osc2<<4): data_out <= osc_mod_in[osc2];
                    7'd11 +(osc2<<4): data_out <= osc_feedb_in[osc2];
                    7'd12 +(osc2<<4): data_out <= 8'h00;
                    7'd13 +(osc2<<4): data_out <= 8'h00;
                    7'd14 +(osc2<<4): data_out <= 8'h00;
                    7'd15 +(osc2<<4): data_out <= 8'h00;
                    default:;
                endcase
            end
        end
        else if(com_sel) begin
            if(adr == 1) data_out <= m_vol;
				else if(adr > 2 && adr <= 15)data_out <= 0;
				else if (adr >= 16 && adr < 32) begin
	             for(outnam=0;outnam<16;outnam=outnam+1)begin
				        if(adr == (outnam + 16)) data_out <= patch_name[outnam];
			       end
			   end
        end
        else if (m1_sel) begin
           for (o21=0;o21<16;o21=o21+1)begin
               for(i21=0;i21<V_OSC;i21=i21+1)begin
                   if (adr == (i21 << 4)+o21) data_out <= mat_buf1[o21][i21];
               end
            end
        end
        else if (m2_sel) begin
           for (o22=0;o22<16;o22=o22+1)begin
               for(i22=0;i22<V_OSC;i22=i22+1)begin
                   if (adr == (i22 << 4)+o22) data_out <= mat_buf2[o22][i22];
               end
            end
        end
    end


/**	@brief sum modulation data and multiply with martix in for pr osc.
*/

	genvar modmatloop;
	generate
		for (modmatloop=0;modmatloop<V_OSC;modmatloop=modmatloop+1) begin : cal_mod_mat_mul
			assign mod_matrix_mul[modmatloop] = reg_sine_mod_data[ox_dly[1]] * mat_buf1[modmatloop][ox_dly[1]];
		end
	endgenerate

	genvar fbmatloop;
	generate
		for (fbmatloop=0;fbmatloop<V_OSC;fbmatloop=fbmatloop+1) begin : cal_fb_mat_mul
			assign fb_matrix_mul[fbmatloop] = reg_sine_fb_data[ox_dly[1]] * mat_buf1[fbmatloop+8][ox_dly[1]];
		end
	endgenerate

	assign mod_matrix_out_sum = (reg_mod_matrix_mul[ox_dly[V_OSC]] * osc_mod_in[ox_dly[V_OSC]]);// >>> ( O_WIDTH + V_WIDTH);
	assign fb_matrix_out_sum = (reg_fb_matrix_mul[ox_dly[V_OSC]] * osc_feedb_in[ox_dly[V_OSC]]);// >>> (O_WIDTH + V_WIDTH);

	wire signed [10:0] modulation_sum;
//	wire signed [47:0] modulation_sum;

	assign modulation_sum = (( mod_matrix_out_sum + fb_matrix_out_sum ) >>> (26 ));
//	assign modulation_sum = mod_matrix_out_sum + fb_matrix_out_sum;

/**	@brief output mixed sounddata to out register
*/
//	integer mmoloop;
	byte unsigned mmoloop;

//	always @(negedge sCLK_XVXENVS)begin : sound_out
	always @(posedge sCLK_XVXENVS)begin : sound_out
		if(sh_voice_reg[1]) begin
			for(mmoloop=0;mmoloop<V_OSC;mmoloop=mmoloop+1) begin
				reg_mod_matrix_mul[mmoloop] <= reg_mod_matrix_mul_sum[mmoloop];
				reg_fb_matrix_mul[mmoloop]	<= reg_fb_matrix_mul_sum[mmoloop];
			end
		end
		if (sh_voice_reg[2])begin
			reg_voice_sound_sum_l <= reg_voice_sound_sum_l + reg_osc_data_sum_l;
			reg_voice_sound_sum_r <= reg_voice_sound_sum_r + reg_osc_data_sum_r;
		end
		if ( xxxx == ((VOICES - 1) * V_ENVS) )begin
			lsound_out <= lsound_out_full >>> output_volume_scaling;// - + 1
			rsound_out <= rsound_out_full >>> output_volume_scaling;// - + 1
		end
		if (xxxx == ((VOICES - 1) * V_ENVS) + 1)begin reg_voice_sound_sum_l <= 0; reg_voice_sound_sum_r <= 0; end
	end

	always @(posedge sCLK_XVXENVS) begin
		if(sh_voice_reg[2]) begin reg_voice_vol_env_lvl <= level_mul; end
	end


/**	@brief main mix summing machine
*		multiply sine level mul data with main vol env (1), left/right pan value, osc vol level and main volume
*
*/
//	integer mmmloop, mmcloop;
	byte unsigned mmmloop, mmcloop;

	always @(posedge sCLK_XVXENVS )begin : main_mix_summing
		for(mmmloop=0;mmmloop<V_OSC;mmmloop=mmmloop+1) begin
			if(sh_osc_reg[0])begin
				reg_mod_matrix_mul_sum[mmmloop] <= reg_mod_matrix_mul_sum[mmmloop] + (mod_matrix_mul[mmmloop] >>> 7);
				reg_fb_matrix_mul_sum[mmmloop] <= reg_fb_matrix_mul_sum[mmmloop] + fb_matrix_mul[mmmloop];
			end
		end
		if (sh_osc_reg[1])begin
			reg_sine_level_mul_data <= (level_mul * sine_lut_out);
			reg_sine_mod_data[ox_dly[0]] <= (level_mul * sine_lut_out * osc_mod[ox_dly[0]]);
			reg_sine_fb_data[ox_dly[0]] <= sine_lut_out * osc_feedb[ox_dly[0]];
		end
		if (sh_osc_reg[2])begin
			reg_sine_level_mul_osc_lvl_m_vol_data <= reg_sine_level_mul_data * osc_lvl[ox_dly[1]];
		end
		if(sh_osc_reg[3])begin
			reg_osc_data_sum_l <= reg_osc_data_sum_l + sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_l;
			reg_osc_data_sum_r <= reg_osc_data_sum_r + sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_r;

		end

		if (sh_voice_reg[1])begin
			for(mmcloop=0;mmcloop<V_OSC;mmcloop=mmcloop+1) begin
				reg_mod_matrix_mul_sum[mmcloop] <= 48'h0;
				reg_fb_matrix_mul_sum[mmcloop] <= 48'h0;
			end
		end

		if(sh_voice_reg[2])begin
			reg_osc_data_sum_l <= 63'h0; reg_osc_data_sum_r <= 63'h0;
		end
	end

	always @(posedge sCLK_XVXOSC)begin : ox_vx_delay_gen
		vx_dly[0] <= vx; ox_dly[0] <= ox;
		for(dloop=0;dloop<x_offset;dloop=dloop+1) begin // all Voices 2 osc's
			vx_dly[dloop+1] <= vx_dly[dloop]; ox_dly[dloop+1] <= ox_dly[dloop];
		end
		reg_matrix_data[vx_dly[V_OSC]][ox_dly[V_OSC]] <= modulation_sum;
		modulation <= reg_matrix_data[vx_dly[vo_x_offset]][ox_dly[vo_x_offset]];
	end

/**	@brief main shiftreg state driver
*/
	reg [E_WIDTH-1:0] sh_v_counter;
	reg [OE_WIDTH-1:0] sh_o_counter;

	always @(posedge sCLK_XVXENVS )begin : main_sh_regs_state_driver
		if (n_xxxx_zero) begin sh_v_counter <= 0;sh_o_counter <= 0; end
		else begin sh_v_counter <= sh_v_counter + 1; sh_o_counter <= sh_o_counter + 1; end

		if(sh_v_counter == 0 ) begin sh_voice_reg <= (sh_voice_reg << 1)+ 1; end
		else begin sh_voice_reg <= sh_voice_reg << 1; end

		if(sh_o_counter == 0 ) begin sh_osc_reg <= (sh_osc_reg << 1)+ 1; end
		else begin sh_osc_reg <= sh_osc_reg << 1; end
	end

endmodule
