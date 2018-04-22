module modulation_matrix (
// Inputs -- //
    input                		sCLK_XVXENVS,  // clk
    input                		sCLK_XVXOSC,  // clk
    input   [O_WIDTH-1:0]       ox_dly      [x_offset:0],
    input   [V_WIDTH-1:0]       vx_dly      [x_offset:0],
    input   [V_OSC+2:0]         sh_voice_reg,
    input   [V_ENVS:0]          sh_osc_reg,
    input signed [7:0]          level_mul_vel,    // envgen output
    input signed [16:0]         sine_lut_out, // sine

    input   signed      [7:0]   osc_mod     [V_OSC-1:0],
    input   signed      [7:0]   osc_feedb   [V_OSC-1:0],
    input   signed      [7:0]   osc_mod_in  [V_OSC-1:0],
    input   signed      [7:0]   osc_feedb_in[V_OSC-1:0],
    input   signed      [7:0]   mat_buf1    [15:0][V_OSC-1:0],
    input   signed      [7:0]   mat_buf2    [15:0][V_OSC-1:0],
// Output -- //
    output reg signed [10:0]	modulation
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

    reg signed [47:0] reg_sine_mod_data[V_OSC-1:0];
    reg signed [47:0] reg_sine_fb_data[V_OSC-1:0];

    wire signed [47:0] mod_matrix_mul[V_OSC-1:0];
    wire signed [47:0] fb_matrix_mul[V_OSC-1:0];

    reg signed [47:0] reg_mod_matrix_mul[V_OSC-1:0];
    reg signed [47:0] reg_fb_matrix_mul[V_OSC-1:0];

    reg signed [47:0] reg_mod_matrix_mul_sum[V_OSC-1:0];
    reg signed [47:0] reg_fb_matrix_mul_sum[V_OSC-1:0];

    wire signed [47:0] mod_matrix_out_sum;
    wire signed [47:0] fb_matrix_out_sum;

    reg signed [10:0] reg_matrix_data[VOICES-1:0][V_OSC-1:0];

/**	@brief sum modulation data and multiply with martix in for pr osc.
*/

    genvar matloop;
    generate
        for (matloop=0;matloop<V_OSC;matloop=matloop+1) begin : cal_mod_mat_mul
            assign mod_matrix_mul[matloop] = reg_sine_mod_data[ox_dly[1]] * mat_buf1[matloop][ox_dly[1]];
            assign fb_matrix_mul[matloop] = reg_sine_fb_data[ox_dly[1]] * mat_buf1[matloop+8][ox_dly[1]];
        end
    endgenerate

    assign mod_matrix_out_sum = (reg_mod_matrix_mul[ox_dly[V_OSC]] * osc_mod_in[ox_dly[V_OSC]]);// >>> ( O_WIDTH + V_WIDTH);
    assign fb_matrix_out_sum = (reg_fb_matrix_mul[ox_dly[V_OSC]] * osc_feedb_in[ox_dly[V_OSC]]);// >>> (O_WIDTH + V_WIDTH);

    wire signed [10:0] modulation_sum;
    assign modulation_sum = (( mod_matrix_out_sum + fb_matrix_out_sum ) >>> (26 ));


/**	@brief main mix summing machine
*		multiply sine level mul data with main vol env (1), left/right pan value, osc vol level and main volume
*
*/
    byte unsigned mmmloop, mmcloop;

    always @(posedge sCLK_XVXENVS )begin : main_mix_summing
        for(mmmloop=0;mmmloop<V_OSC;mmmloop=mmmloop+1) begin
            if(sh_osc_reg[0])begin
                reg_mod_matrix_mul_sum[mmmloop] <= reg_mod_matrix_mul_sum[mmmloop] + (mod_matrix_mul[mmmloop] >>> 7);
                reg_fb_matrix_mul_sum[mmmloop] <= reg_fb_matrix_mul_sum[mmmloop] + fb_matrix_mul[mmmloop];
            end
        end
        if (sh_osc_reg[1])begin
            reg_sine_mod_data[ox_dly[0]] <= (level_mul_vel * sine_lut_out * osc_mod[ox_dly[0]]);
            reg_sine_fb_data[ox_dly[0]] <= (sine_lut_out * osc_feedb[ox_dly[0]]);
        end

        if (sh_voice_reg[1])begin
            for(mmcloop=0;mmcloop<V_OSC;mmcloop=mmcloop+1) begin
                reg_mod_matrix_mul[mmcloop] <= reg_mod_matrix_mul_sum[mmcloop];
                reg_fb_matrix_mul[mmcloop]	<= reg_fb_matrix_mul_sum[mmcloop];
                reg_mod_matrix_mul_sum[mmcloop] <= signed'(0);
                reg_fb_matrix_mul_sum[mmcloop] <= signed'(0);
            end
        end

    end

    always @(posedge sCLK_XVXOSC)begin : out_gen
        reg_matrix_data[vx_dly[V_OSC]][ox_dly[V_OSC]] <= modulation_sum;
        modulation <= reg_matrix_data[vx_dly[vo_x_offset]][ox_dly[vo_x_offset]];
    end

endmodule
