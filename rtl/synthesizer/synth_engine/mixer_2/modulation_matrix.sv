module modulation_matrix #(
parameter VOICES	= 32,
parameter V_OSC		= 8, // oscs per Voice
parameter O_ENVS	= 2, // envs per Oscilator
parameter V_ENVS	= V_OSC * O_ENVS, // envs per Voice
parameter V_WIDTH	= 3,
parameter O_WIDTH	= 2,
parameter OE_WIDTH	= 1,
parameter E_WIDTH	= O_WIDTH + OE_WIDTH,
parameter x_offset = (V_OSC * VOICES ) - 2
) (
// Inputs -- //
    input wire                  sCLK_XVXENVS,    // clk
    input wire                  sCLK_XVXOSC,     // clk
    input wire  [O_WIDTH-1:0]   ox_dly          [x_offset:0],
    input wire  [V_WIDTH-1:0]   vx_dly          [x_offset:0],
    input wire  [V_OSC+2:0]     sh_voice_reg,
    input wire  [V_ENVS:0]      sh_osc_reg,
    input wire signed   [7:0]   level_mul_vel,  // envgen output
    input wire signed   [16:0]  sine_lut_out,   // sine

    input wire  signed  [7:0]   osc_mod_out     [V_OSC-1:0],
    input wire  signed  [7:0]   osc_feedb_out   [V_OSC-1:0],
    input wire  signed  [7:0]   osc_mod_in      [V_OSC-1:0],
    input wire  signed  [7:0]   osc_feedb_in    [V_OSC-1:0],
    input wire  signed  [7:0]   mat_buf1 [15:0] [V_OSC-1:0],
    input wire  signed  [7:0]   mat_buf2 [15:0] [V_OSC-1:0],
// Output -- //
    output reg signed [10:0]	modulation
);

    localparam DATA_WIDTH = 44;

    reg signed [DATA_WIDTH-1:0] sine_mod_data_in[V_OSC-1:0];
    reg signed [DATA_WIDTH-1:0] sine_fb_data_in[V_OSC-1:0];

    reg signed [DATA_WIDTH-1:0] mod_matrix_mul_mat[V_OSC-1:0];
    reg signed [DATA_WIDTH-1:0] fb_matrix_mul_mat[V_OSC-1:0];

    reg signed [DATA_WIDTH-1:0] reg_mod_matrix_mul_mat_sum[V_OSC-1:0];
    reg signed [DATA_WIDTH-1:0] reg_fb_matrix_mul_mat_sum[V_OSC-1:0];

    reg signed [DATA_WIDTH-1:0] reg_mod_matrix_summed[V_OSC-1:0];
    reg signed [DATA_WIDTH-1:0] reg_fb_matrixl_summed[V_OSC-1:0];

    wire signed [DATA_WIDTH-1:0] mod_matrix_out_sum;
    wire signed [DATA_WIDTH-1:0] fb_matrix_out_sum;

    reg signed [10:0] reg_matrix_data[VOICES-1:0][V_OSC-1:0];

    wire signed [10:0] modulation_sum;

/**	@brief sum modulation data and multiply with martix in for pr osc.
*/

    genvar matloop;
    generate
    for (matloop=0;matloop<V_OSC;matloop=matloop+1) begin : cal_mod_mat_mul
        always @(posedge sCLK_XVXENVS) begin
            if (sh_osc_reg[1])begin
                mod_matrix_mul_mat[matloop] <= (level_mul_vel * sine_lut_out * osc_mod_out[ox_dly[0]]) * mat_buf1[matloop][ox_dly[0]];
                fb_matrix_mul_mat[matloop]  <= ((sine_lut_out * osc_feedb_out[ox_dly[0]]  * mat_buf1[matloop+8][ox_dly[0]]) <<< 7);
            end
        end
    end
    endgenerate


/**	@brief main mix summing machine
*		multiply sine level mul data with main vol env (1), left/right pan value, osc vol level and main volume
*
*/
    byte unsigned mmmloop, mmcloop;

    always @(posedge sCLK_XVXENVS )begin : main_mix_summing
        for(mmmloop=0;mmmloop<V_OSC;mmmloop=mmmloop+1) begin
            if(sh_osc_reg[0])begin
                reg_mod_matrix_mul_mat_sum[mmmloop] <= reg_mod_matrix_mul_mat_sum[mmmloop] + mod_matrix_mul_mat[mmmloop];
                reg_fb_matrix_mul_mat_sum[mmmloop] <= reg_fb_matrix_mul_mat_sum[mmmloop] + fb_matrix_mul_mat[mmmloop];
            end
        end

        if (sh_voice_reg[1])begin
            for(mmcloop=0;mmcloop<V_OSC;mmcloop=mmcloop+1) begin
                reg_mod_matrix_summed[mmcloop] <= reg_mod_matrix_mul_mat_sum[mmcloop];
                reg_fb_matrixl_summed[mmcloop]	<= reg_fb_matrix_mul_mat_sum[mmcloop];
                reg_mod_matrix_mul_mat_sum[mmcloop] <= 0;
                reg_fb_matrix_mul_mat_sum[mmcloop] <= 0;
            end
        end

    end

    assign mod_matrix_out_sum = (reg_mod_matrix_summed[ox_dly[V_OSC]] * osc_mod_in[ox_dly[V_OSC]]);// >>> ( O_WIDTH + V_WIDTH);
    assign fb_matrix_out_sum = (reg_fb_matrixl_summed[ox_dly[V_OSC]] * osc_feedb_in[ox_dly[V_OSC]]);// >>> (O_WIDTH + V_WIDTH);
    assign modulation_sum = (( mod_matrix_out_sum + fb_matrix_out_sum ) >>> 33 );

    always @(posedge sCLK_XVXOSC)begin : out_gen
        reg_matrix_data[vx_dly[V_OSC]][ox_dly[V_OSC]] <= modulation_sum;
        modulation <= reg_matrix_data[vx_dly[x_offset]][ox_dly[x_offset]];
    end

endmodule