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

    input   signed      [7:0]   level_mul_vel,
    input   signed      [16:0]  sine_lut_out,
// Outputs -- //
    output reg signed   [10:0]  modulation
);

parameter VOICES	= 32;
parameter V_OSC		= 8; // oscs per Voice
parameter V_WIDTH	= 5;
parameter O_WIDTH	= 3;
parameter O_ENVS	= 2; // envs per Oscilator
parameter V_ENVS	= V_OSC * O_ENVS; // envs per Voice
parameter x_offset = (V_OSC * VOICES ) - 2;


    wire signed [32:0] sine_mod_in_data[V_OSC-1:0];
    wire signed [24:0] sine_fb_in_data[V_OSC-1:0];

    wire signed [40:0] mod_matrix_mul[V_OSC-1:0];
    wire signed [32:0] fb_matrix_mul[V_OSC-1:0];

    reg signed [43:0] reg_mod_matrix_mul_sum[V_OSC-1:0];
    reg signed [35:0] reg_fb_matrix_mul_sum[V_OSC-1:0];

    reg signed [43:0] reg_mod_matrix_mul[V_OSC-1:0];
    reg signed [35:0] reg_fb_matrix_mul[V_OSC-1:0];

    wire signed [51:0] mod_matrix_out_sum;
    wire signed [43:0] fb_matrix_out_sum;
    reg signed [10:0] reg_matrix_data[VOICES-1:0][V_OSC-1:0];

    wire signed [10:0] modulation_sum;



    genvar matrixloop;
    generate
        for (matrixloop=0;matrixloop<V_OSC;matrixloop++) begin : cal_fb_mat_mul
            assign sine_mod_in_data[matrixloop] = level_mul_vel * sine_lut_out * osc_mod[matrixloop];
            assign sine_fb_in_data[matrixloop] = sine_lut_out * osc_feedb[matrixloop];
        end
    endgenerate


    genvar matloop;
    generate
        for (matloop=0;matloop<V_OSC;matloop=matloop+1) begin : cal_mat_mul
            assign mod_matrix_mul[matloop] = sine_mod_in_data[ox_dly[1]] * mat_buf1[matloop][ox_dly[1]];
            assign fb_matrix_mul[matloop] = sine_fb_in_data[ox_dly[1]] * mat_buf1[matloop+8][ox_dly[1]];
        end
    endgenerate

    /**	@brief matrix summing machine
*		multiply sine level mul data with main vol env (1), left/right pan value, osc vol level and main volume
*
*/
    byte unsigned mmmloop;

    always_ff @(posedge sCLK_XVXENVS )begin : main_mix_summing
        for(mmmloop=0;mmmloop<V_OSC;mmmloop++) begin
            if(sh_voice_reg[1]) begin
                reg_mod_matrix_mul[mmmloop] <= reg_mod_matrix_mul_sum[mmmloop];
                reg_fb_matrix_mul[mmmloop]	<= reg_fb_matrix_mul_sum[mmmloop];
                reg_mod_matrix_mul_sum[mmmloop] <= 0;
                reg_fb_matrix_mul_sum[mmmloop] <= 0;
            end
            else if(sh_osc_reg[0])begin
                reg_mod_matrix_mul_sum[mmmloop] <= reg_mod_matrix_mul_sum[mmmloop] + mod_matrix_mul[mmmloop];
                reg_fb_matrix_mul_sum[mmmloop] <= reg_fb_matrix_mul_sum[mmmloop] + fb_matrix_mul[mmmloop];
            end
        end
    end


/**	@brief sum modulation data and multiply with martix in for pr osc.
*/

    assign mod_matrix_out_sum = (reg_mod_matrix_mul[ox_dly[V_OSC-1]] * osc_mod_in[ox_dly[V_OSC-1]]);// >>> ( O_WIDTH + V_WIDTH);
    assign fb_matrix_out_sum = (reg_fb_matrix_mul[ox_dly[V_OSC-1]] * osc_feedb_in[ox_dly[V_OSC-1]]);// >>> (O_WIDTH + V_WIDTH);

    assign modulation_sum = (( mod_matrix_out_sum[51:8] + fb_matrix_out_sum ) >>> (33 ));

    always @(posedge sCLK_XVXOSC)begin : modulation_sum_gen
        reg_matrix_data[vx_dly[V_OSC]][ox_dly[V_OSC]] <= modulation_sum;
        modulation <= reg_matrix_data[vx_dly[x_offset]][ox_dly[x_offset]];
    end

endmodule
