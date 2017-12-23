module vol_mixer (
    input                           sCLK_XVXENVS,  // clk
    input   [V_WIDTH+E_WIDTH-1:0]   xxxx,
    input   [O_WIDTH-1:0]           ox_dly      [x_offset:0],
    input   [V_OSC+2:0]             sh_voice_reg,
    input   [V_ENVS:0]              sh_osc_reg,
    input   signed  [7:0]           m_vol,
    input   signed  [7:0]           osc_lvl     [V_OSC-1:0],
    input   signed  [7:0]           level_mul,
    input   signed  [7:0]           osc_pan     [V_OSC-1:0],
    input   signed  [16:0]          sine_lut_out,
// sound data out
`ifdef	_32BitAudio
    output signed [31:0]            lsound_out, // 32-bits
    output signed [31:0]            rsound_out  // 32-bits
`elsif	_24BitAudio
    output signed [23:0]            lsound_out, // 24-bits
    output signed [23:0]            rsound_out  // 24-bits
`else
    output signed [15:0]            lsound_out, // 16-bits
    output signed [15:0]            rsound_out  // 16-bits
`endif
);

parameter VOICES	= 8;
parameter V_OSC		= 4; // oscs per Voice
parameter O_ENVS	= 2; // envs per Oscilator
parameter V_WIDTH = utils::clogb2(VOICES);
parameter O_WIDTH = utils::clogb2(V_OSC);
parameter OE_WIDTH	= utils::clogb2(O_ENVS);
parameter E_WIDTH	= O_WIDTH + OE_WIDTH;
parameter V_ENVS	= V_OSC * O_ENVS; // envs per Voice
parameter x_offset = (V_OSC * VOICES ) - 2;

`ifdef	_32BitAudio
    parameter output_volume_scaling = 21; // 32-bits
`elsif	_24BitAudio
    parameter output_volume_scaling = 29; // 24-bits
`else
    parameter output_volume_scaling = 37; // 16-bits
`endif

/**	@brief output mixed sounddata to out register
*/
    reg signed [7:0] reg_voice_vol_env_lvl;
    reg signed [63:0] reg_osc_data_sum_l;
    reg signed [63:0] reg_osc_data_sum_r;
    reg signed [63:0] reg_sine_level_mul_data;
    reg signed [63:0] reg_sine_level_mul_osc_lvl_m_vol_data;
    reg signed [63:0] reg_voice_sound_sum_l;
    reg signed [63:0] reg_voice_sound_sum_r;

    wire signed [63:0] lsound_out_full, rsound_out_full;
    assign lsound_out_full = reg_voice_sound_sum_l * m_vol;
    assign rsound_out_full = reg_voice_sound_sum_r * m_vol;

    always @(posedge sCLK_XVXENVS)begin : sound_out
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

    wire signed [63:0] sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_l;
    wire signed [63:0] sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_r;

    assign sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_l = reg_sine_level_mul_osc_lvl_m_vol_data * reg_voice_vol_env_lvl * (127 - osc_pan[ox_dly[1]]);
    assign sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_r = reg_sine_level_mul_osc_lvl_m_vol_data * reg_voice_vol_env_lvl * osc_pan[ox_dly[1]];

    always @(posedge sCLK_XVXENVS )begin : main_mix_summing
        if (sh_osc_reg[1])begin
            reg_sine_level_mul_data <= (level_mul * sine_lut_out);
        end

        if (sh_osc_reg[2])begin
            reg_sine_level_mul_osc_lvl_m_vol_data <= reg_sine_level_mul_data * osc_lvl[ox_dly[1]];
        end

        if(sh_osc_reg[3])begin
            reg_osc_data_sum_l <= reg_osc_data_sum_l + sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_l;
            reg_osc_data_sum_r <= reg_osc_data_sum_r + sine_level_mul_osc_lvl_m_vol_osc_pan_main_vol_env_r;
        end

        if(sh_voice_reg[2])begin
            reg_osc_data_sum_l <= 63'h0; reg_osc_data_sum_r <= 63'h0;
        end
    end

endmodule
