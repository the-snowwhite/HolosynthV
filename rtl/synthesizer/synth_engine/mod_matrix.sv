module mod_matrix (
// Inputs -- //
    input                       sCLK_XVXENVS,  // clk
    input                       sCLK_XVXOSC,  // clk

    input   [O_WIDTH-1:0]       ox_dly      [x_offset:0],
    input   [V_WIDTH-1:0]       vx_dly      [x_offset:0],
    input   [V_OSC+2:0]         sh_voice_reg,
    input   [V_ENVS:0]          sh_osc_reg,

    input   signed      [7:0]   osc_mod     [V_OSC-1:0],
    input   signed      [7:0]   osc_feedb   [V_OSC-1:0],
    input   signed      [7:0]   osc_mod_in  [V_OSC-1:0],
    input   signed      [7:0]   osc_feedb_in[V_OSC-1:0],
    input   signed      [7:0]   mat_buf1    [15:0][V_OSC-1:0],
    input   signed      [7:0]   mat_buf2    [15:0][V_OSC-1:0],

    input   signed      [7:0]   level_mul,
    input   signed      [16:0]  sine_lut_out,
// Outputs -- //
    output reg signed   [10:0]  modulation
);

parameter VOICES	= 8;
parameter V_OSC		= 4; // oscs per Voice
parameter V_WIDTH	= 3;
parameter O_WIDTH	= 2;
parameter O_ENVS	= 2; // envs per Oscilator
parameter V_ENVS	= V_OSC * O_ENVS; // envs per Voice
parameter x_offset = (V_OSC * VOICES ) - 2;

`ifdef	_32BitAudio
    parameter output_volume_scaling = 21; // 32-bits
`elsif	_24BitAudio
    parameter output_volume_scaling = 29; // 24-bits
`else
    parameter output_volume_scaling = 37; // 16-bits
`endif


    logic signed [47:0] mod_matrix_mul[V_OSC-1:0];
    logic signed [47:0] fb_matrix_mul[V_OSC-1:0];
    logic signed [47:0] mod_matrix_out_sum;
    logic signed [47:0] fb_matrix_out_sum;

    reg signed [47:0] reg_sine_mod_data[V_OSC-1:0];
    reg signed [47:0] reg_sine_fb_data[V_OSC-1:0];
    reg signed [47:0] reg_mod_matrix_mul[V_OSC-1:0];
    reg signed [47:0] reg_fb_matrix_mul[V_OSC-1:0];
    reg signed [47:0] reg_mod_matrix_mul_sum[V_OSC-1:0];
    reg signed [47:0] reg_fb_matrix_mul_sum[V_OSC-1:0];
    reg signed [10:0] reg_matrix_data[VOICES-1:0][V_OSC-1:0];

    logic signed [10:0] modulation_sum;

/**	@brief sum modulation data and multiply with martix in for pr osc.
*/

    genvar modmatloop;
    generate
        for (modmatloop=0;modmatloop<V_OSC;modmatloop=modmatloop+1) begin : cal_mod_mat_mul
            assign mod_matrix_mul[modmatloop] = signed '(reg_sine_mod_data[ox_dly[1]] * mat_buf1[modmatloop][ox_dly[1]]);
        end
    endgenerate

    genvar fbmatloop;
    generate
        for (fbmatloop=0;fbmatloop<V_OSC;fbmatloop=fbmatloop+1) begin : cal_fb_mat_mul
            assign fb_matrix_mul[fbmatloop] = signed '(reg_sine_fb_data[ox_dly[1]] * mat_buf1[fbmatloop+8][ox_dly[1]]);
        end
    endgenerate

    assign mod_matrix_out_sum = (reg_mod_matrix_mul[ox_dly[V_OSC]] * osc_mod_in[ox_dly[V_OSC]]);// >>> ( O_WIDTH + V_WIDTH);
    assign fb_matrix_out_sum = (reg_fb_matrix_mul[ox_dly[V_OSC]] * osc_feedb_in[ox_dly[V_OSC]]);// >>> (O_WIDTH + V_WIDTH);

    assign modulation_sum = (( mod_matrix_out_sum + fb_matrix_out_sum ) >>> (26 ));

    always @(posedge sCLK_XVXOSC)begin : modulation_sum_gen
        reg_matrix_data[vx_dly[V_OSC]][ox_dly[V_OSC]] <= modulation_sum;
        modulation <= reg_matrix_data[vx_dly[x_offset]][ox_dly[x_offset]];
    end

    /**	@brief matrix summing machine
*		multiply sine level mul data with main vol env (1), left/right pan value, osc vol level and main volume
*
*/
    byte unsigned mmoloop, mmmloop, mmcloop;

    always @(posedge sCLK_XVXENVS )begin : main_mix_summing
        if(sh_voice_reg[1]) begin
            for(mmoloop=0;mmoloop<V_OSC;mmoloop=mmoloop+1) begin
                reg_mod_matrix_mul[mmoloop] <= reg_mod_matrix_mul_sum[mmoloop];
                reg_fb_matrix_mul[mmoloop]	<= reg_fb_matrix_mul_sum[mmoloop];
            end
        end
        if (sh_osc_reg[1])begin
            reg_sine_mod_data[ox_dly[0]] <= (level_mul * sine_lut_out * osc_mod[ox_dly[0]]);
            reg_sine_fb_data[ox_dly[0]] <= sine_lut_out * osc_feedb[ox_dly[0]];
        end
        for(mmmloop=0;mmmloop<V_OSC;mmmloop=mmmloop+1) begin
            if(sh_osc_reg[0])begin
                reg_mod_matrix_mul_sum[mmmloop] <= reg_mod_matrix_mul_sum[mmmloop] + (mod_matrix_mul[mmmloop] >>> 7);
                reg_fb_matrix_mul_sum[mmmloop] <= reg_fb_matrix_mul_sum[mmmloop] + fb_matrix_mul[mmmloop];
            end
        end

        if (sh_voice_reg[1])begin
            for(mmcloop=0;mmcloop<V_OSC;mmcloop=mmcloop+1) begin
                reg_mod_matrix_mul_sum[mmcloop] <= 48'h0;
                reg_fb_matrix_mul_sum[mmcloop] <= 48'h0;
            end
        end
    end

endmodule
