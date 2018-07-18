module mixer_2 (
// Inputs -- //
    input                       sCLK_XVXENVS,  // clk
    input                       sCLK_XVXOSC,  // clk
    input                       reset_data_N,        // reset
    input [V_WIDTH+E_WIDTH-1:0] xxxx,
    input                       xxxx_zero,
//  env gen
    input signed [7:0]          level_mul_vel,    // envgen output
    input signed [16:0]         sine_lut_out, // sine

    inout signed [7:0]          data,
    input [6:0]                 adr,
    input                       write,
    input                       read,
    input                       sysex_data_patch_send,
    input                       osc_sel,
    input                       com_sel,
    input                       m1_sel,
    input                       m2_sel,
// Outputs -- //
// osc
    output reg signed [10:0]    modulation,
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

parameter VOICES	= 32;
parameter V_OSC		= 8; // oscs per Voice
parameter O_ENVS	= 2; // envs per Oscilator
parameter V_ENVS	= V_OSC * O_ENVS; // = 16 number of envelope generators  pr. voice.
parameter V_WIDTH = utils::clogb2(VOICES);
parameter O_WIDTH = utils::clogb2(V_OSC);
parameter OE_WIDTH	= 1;
parameter E_WIDTH	= O_WIDTH + OE_WIDTH;

parameter x_offset = (V_OSC * VOICES ) - 2;

wire  signed   [7:0]   osc_lvl        [V_OSC-1:0];
wire  signed   [7:0]   osc_mod_out    [V_OSC-1:0];
wire  signed   [7:0]   osc_feedb_out  [V_OSC-1:0];
wire  signed   [7:0]   osc_pan        [V_OSC-1:0];
wire  signed   [7:0]   osc_mod_in     [V_OSC-1:0];
wire  signed   [7:0]   osc_feedb_in   [V_OSC-1:0];
wire  signed   [7:0]   m_vol;
wire  signed   [7:0]   mat_buf1       [15:0][V_OSC-1:0];
wire  signed   [7:0]   mat_buf2       [15:0][V_OSC-1:0];
wire           [7:0]   patch_name     [15:0];

 midi_ctrl_data #(.V_OSC(V_OSC))midi_ctrl_data_inst
(
    .reset_data_N(reset_data_N),                        // input
    .adr( adr ),                                        // input
    .write( write ),                                    // input
    .read( read ),                                      // input
    .sysex_data_patch_send( sysex_data_patch_send ),    // input
    .osc_sel( osc_sel ),                                // output
    .com_sel( com_sel ),                                // output
    .m1_sel( m1_sel ),                                  // output
    .m2_sel( m2_sel ),                                  // output
    .data( data ),                                      // inout
    .osc_lvl( osc_lvl ),                                // output
    .osc_mod_out( osc_mod_out ),                        // output
    .osc_feedb_out( osc_feedb_out ),                    // output
    .osc_pan( osc_pan ),                                // output
    .osc_mod_in( osc_mod_in ),                          // output
    .osc_feedb_in( osc_feedb_in ),                      // output
    .m_vol( m_vol ),                                    // output
    .mat_buf1( mat_buf1 ),                              // output
    .mat_buf2( mat_buf2 ),                              // output
    .patch_name( patch_name )                           // output
);

modulation_matrix #(.VOICES(VOICES),.V_OSC(V_OSC),.V_WIDTH(V_WIDTH),.O_WIDTH(O_WIDTH),.O_ENVS(O_ENVS))modulation_matrix_inst
(
    .sCLK_XVXENVS(sCLK_XVXENVS),    // input
    .sCLK_XVXOSC( sCLK_XVXOSC ),    // input
    .ox_dly( ox_dly ),              // input
    .vx_dly( vx_dly ),              // input
    .sh_voice_reg( sh_voice_reg ),  // input
    .sh_osc_reg( sh_osc_reg ),      // input
    .osc_mod_out( osc_mod_out ),    // input
    .osc_feedb_out( osc_feedb_out ),// input
    .osc_mod_in( osc_mod_in ),      // input
    .osc_feedb_in( osc_feedb_in ),  // input
    .mat_buf1( mat_buf1 ),          // input
    .mat_buf2( mat_buf2 ),          // input
    .level_mul_vel( level_mul_vel ),// input
    .sine_lut_out( sine_lut_out ),  // input
    .modulation( modulation )       // output
);

vol_mixer #(.VOICES(VOICES),.V_OSC(V_OSC),.O_ENVS(O_ENVS))vol_mixer_inst
(
    .sCLK_XVXENVS(sCLK_XVXENVS),    // input
    .xxxx( xxxx ),                  // input
    .ox_dly( ox_dly ),              // input
    .sh_voice_reg( sh_voice_reg ),  // input
    .sh_osc_reg( sh_osc_reg ),      // input
    .m_vol( m_vol ),                // input
    .osc_lvl( osc_lvl ),            // input
    .level_mul_vel( level_mul_vel ),        // input
    .osc_pan( osc_pan ),            // input
    .sine_lut_out( sine_lut_out ),  // output
    .lsound_out( lsound_out ),      // output
    .rsound_out( rsound_out )       // output
);

    shortint unsigned dloop;

/**	@brief main shiftreg state driver
*/

    reg [O_WIDTH-1:0]  ox_dly[x_offset:0];
    reg [V_WIDTH-1:0]  vx_dly[x_offset:0];

    reg[V_OSC+2:0] sh_voice_reg;
    reg[V_ENVS:0] sh_osc_reg;

    wire [O_WIDTH-1:0]  ox;
    wire [V_WIDTH-1:0]  vx;
    assign ox = xxxx[E_WIDTH-1:OE_WIDTH];
    assign vx = xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH];
    reg [E_WIDTH-1:0] sh_v_counter;
    reg [OE_WIDTH-1:0] sh_o_counter;

    always @(posedge sCLK_XVXENVS )begin : main_sh_regs_state_driver
        if (xxxx_zero) begin sh_v_counter <= 0;sh_o_counter <= 0; end
        else begin sh_v_counter <= sh_v_counter + 1; sh_o_counter <= sh_o_counter + 1; end

        if(sh_v_counter == 0 ) begin sh_voice_reg <= (sh_voice_reg << 1) | 1; end
        else begin sh_voice_reg <= sh_voice_reg << 1; end

        if(sh_o_counter == 0 ) begin sh_osc_reg <= (sh_osc_reg << 1) | 1; end
        else begin sh_osc_reg <= sh_osc_reg << 1; end
    end

    always @(posedge sCLK_XVXOSC)begin : ox_vx_delay_gen
        vx_dly[0] <= vx; ox_dly[0] <= ox;
        for(dloop=0;dloop<x_offset;dloop=dloop+1) begin // all Voices 2 osc's
            vx_dly[dloop+1] <= vx_dly[dloop]; ox_dly[dloop+1] <= ox_dly[dloop];
        end
    end

endmodule
