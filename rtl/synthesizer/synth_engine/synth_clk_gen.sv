module synth_clk_gen #(
parameter VOICES            = 32,
parameter V_OSC             = 4, // oscs per Voice
parameter V_ENVS            = 2*V_OSC,
parameter V_WIDTH           = 3,
parameter E_WIDTH           = 3,
parameter SYNTH_CHANNELS    = 1,
parameter OVERSAMPLING      = 384,
parameter   AUDIO_CLK_RATE       =   90416666,  //  90.416666 MHz <<-- use for fast
parameter   AUDIO_REF_CLK         =   16953125,   //  16.953125   MHz <<<--- use for slow
parameter   SAMPLE_RATE     =   AUDIO_REF_CLK / OVERSAMPLING, //44100;      //  44.1      KHz
//parameter XVOSC_DIV = AUDIO_CLK_RATE/((SAMPLE_RATE*SYNTH_CHANNELS*VOICES*V_OSC*2)-1),
//parameter XVXENVS_DIV = AUDIO_CLK_RATE/((SAMPLE_RATE*SYNTH_CHANNELS*VOICES*V_ENVS*2)-1),
parameter XVOSC_DIV = 2,
parameter XVXENVS_DIV = 1,
parameter XVXOSC_WIDTH = utils::clogb2(XVOSC_DIV),
parameter XVXENVS_WIDTH = utils::clogb2(XVXENVS_DIV)
) (
    input wire  reset_reg_N,
    input wire  AUDIO_CLK,                  //  180.555556 MHz
    input wire  trig,
    output reg  sCLK_XVXOSC,
    output reg  sCLK_XVXENVS,
    output reg  [V_WIDTH+E_WIDTH-1:0]xxxx,  // index counter
    output reg  run,
    output reg  xxxx_zero,
    output wire xxxx_top
);

//  Internal Registers and Wires
reg     [XVXOSC_WIDTH:0]	sCLK_XVXOSC_DIV;
reg     [XVXENVS_WIDTH:0]	sCLK_XVXENVS_DIV;

reg [1:0]trig_dly;
reg xxxx_top_dly;

wire xxxx_top_synced;
wire trig_rising = (~trig_dly[1] & trig_dly[0]);
wire xxxx_top_rising = (~xxxx_top_dly && xxxx_top_synced) ? 1'b1 : 1'b0;

//wire trig_rising = (trig_dly == 1'b0 && trig == 1'b1) ? 1'b1 : 1'b0;
//wire xxxx_top_rising = (xxxx_top_dly == 1'b0 && xxxx_top == 1'b1) ? 1'b1 : 1'b0;

    syncro_2 sync_inst (
        .clk(AUDIO_CLK),
        .sig_in(trig),
        .sig_out(trig_synced)
    );

    syncro_2 sync2_inst (
        .clk(AUDIO_CLK),
        .sig_in(xxxx_top),
        .sig_out(xxxx_top_synced)
    );

always_ff @(posedge AUDIO_CLK) begin
    trig_dly[0] <= trig_synced;
    trig_dly[1] <= trig_dly[0];
    xxxx_top_dly <= xxxx_top_synced;
    if (xxxx_top_rising) begin
        run <= 1'b0;
    end
    else if (trig_rising) begin
        run <= 1'b1;
    end
end

/*
always_ff @(negedge AUDIO_CLK) begin
    trig_dly <= trig;
    xxxx_top_dly <= xxxx_top;
    if (xxxx_top_rising) begin
        run <= 1'b0;
    end
    else if (trig_rising) begin
        run <= 1'b1;
    end
end
*/
//assign DE1_SOC_Linux_FB.GPIO_1[0] = run;

////////////////////////////////////
always@(negedge AUDIO_CLK or negedge reset_reg_N)
begin
    if(!reset_reg_N)
    begin
        sCLK_XVXOSC_DIV     <=  0;
        sCLK_XVXENVS_DIV    <=  0;
        sCLK_XVXOSC <=  0;
        sCLK_XVXENVS    <=  0;
    end
    else
    begin
        if (run == 1'b1)
        begin
            if(sCLK_XVXOSC_DIV >= XVOSC_DIV)
            begin
                sCLK_XVXOSC_DIV <=  1;
                sCLK_XVXOSC <=  ~sCLK_XVXOSC;
            end
            else
                sCLK_XVXOSC_DIV     <=  sCLK_XVXOSC_DIV+1'b1;

            if(sCLK_XVXENVS_DIV >= XVXENVS_DIV)
            begin
                sCLK_XVXENVS_DIV    <=  1;
                sCLK_XVXENVS    <=  ~sCLK_XVXENVS;
            end
            else
                sCLK_XVXENVS_DIV        <=  sCLK_XVXENVS_DIV+1'b1;
        end
    end
end

timing_gen #(.VOICES(VOICES),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH))timing_gen_inst  // ObjectKind=Sheet Symbol|PrimaryId=U_timing_gen
(
    .sCLK_XVXENVS( sCLK_XVXENVS ),  // input
    .reset_reg_N(reset_reg_N),      // input
    .xxxx( xxxx ),                  // output
    .xxxx_top( xxxx_top ),         // output
    .xxxx_zero( xxxx_zero )         // output
);

endmodule
