module synth_clk_gen (
    input       reset_reg_N,
    input       AUDIO_CLK,  		//  90.4166666 MHz  //90.625000 MHz
    input       trig,
    output      sCLK_XVXOSC,
    output      sCLK_XVXENVS,
    output reg  [V_WIDTH+E_WIDTH-1:0]xxxx,  // index counter
    output reg  xxxx_zero
);
parameter   VOICES 			= 8;
parameter   V_OSC           = 4; // oscs per Voice
parameter   V_WIDTH         = 3;
parameter   E_WIDTH         = 3;
// internal parameters
parameter   V_ENVS          = 2*V_OSC;
parameter   SYNTH_CHANNELS  = 1;
parameter   OVERSAMPLING    = 384;
`ifdef _180MhzOscs
parameter   AUDIO_CLK_RATE    = 180714285;  //  180.714285 MHz
parameter   AUDIO_REF_CLK   =  16941964;   //  16.953125   MHz <<<--- use for 271
`else

parameter   AUDIO_CLK_RATE    =   90416666;  //  90.4166665 MHz <<-- use for fast
parameter   AUDIO_REF_CLK   =   16934400;   //  16.953125   MHz <<<--- use for slow
`endif
parameter   SAMPLE_RATE     =   AUDIO_REF_CLK / OVERSAMPLING; //44100;      //  44.1      KHz
`ifdef _32BitAudio
    parameter DATA_WIDTH 	= 32;
`elsif _24BitAudio
    parameter DATA_WIDTH 	= 24;
`else
    parameter DATA_WIDTH	= 16;         //  16      Bits
`endif
parameter   CHANNEL_NUM     =   2;          //  Dual Channel

parameter XVOSC_DIV = AUDIO_CLK_RATE/((SAMPLE_RATE*SYNTH_CHANNELS*VOICES*V_OSC*4)-1);
parameter XVXENVS_DIV = AUDIO_CLK_RATE/((SAMPLE_RATE*SYNTH_CHANNELS*VOICES*V_ENVS*4)-1);
parameter XVXOSC_WIDTH = utils::clogb2(XVOSC_DIV);
parameter XVXENVS_WIDTH = utils::clogb2(XVXENVS_DIV);

//  Internal Registers and Wires
reg     [XVXOSC_WIDTH:0]	sCLK_XVXOSC_DIV;
reg     [XVXENVS_WIDTH:0]	sCLK_XVXENVS_DIV;
wire     trig_dly;
wire     trig_rising;
wire     run;
reg     [1:0] xxxx_zero_dly;
////////////////////////////////////

//wire stop_n = ((run == 1'b0) || (reset_reg_N == 1'b0)) ? 1'b0 : 1'b1;

always @(posedge AUDIO_CLK or negedge reset_reg_N) begin
    if (!reset_reg_N) begin
        xxxx_zero_dly <= 2'b00;
    end
    else begin
        xxxx_zero_dly[0] <= xxxx_zero;
        xxxx_zero_dly[1] <= xxxx_zero_dly[0];
    end
end

always @(negedge AUDIO_CLK or negedge reset_reg_N) begin
    if (!reset_reg_N) begin
        trig_dly <= 1'b0;
        trig_rising <= 1'b0;
    end
    else begin
        trig_dly <= trig;
        trig_rising <= (trig && !trig_dly);
    end
end

always @( posedge trig_rising or posedge xxxx_zero_dly[1] or negedge reset_reg_N) begin
    if (!reset_reg_N) begin
        run <= 0;
    end
    else if(trig_rising) begin
        run <= 1'b1;
    end
    else if (xxxx_zero_dly[1]) begin
        run <= 1'b0;
    end
    else begin
        run <= run;
    end
end

always@(negedge AUDIO_CLK)
begin
    if (!AUDIO_CLK) begin
        if(!run) begin
            sCLK_XVXOSC_DIV     <=  0;
            sCLK_XVXENVS_DIV    <=  0;
            sCLK_XVXOSC         <=  1'b0;
            sCLK_XVXENVS        <=  1'b0;
        end
        else begin
            if(sCLK_XVXOSC_DIV >= XVOSC_DIV)
            begin
                sCLK_XVXOSC_DIV     <=  1;
                sCLK_XVXOSC         <=  ~sCLK_XVXOSC;
            end
            else
                sCLK_XVXOSC_DIV     <=  sCLK_XVXOSC_DIV+1'b1;

            if(sCLK_XVXENVS_DIV >= XVXENVS_DIV)
            begin
                sCLK_XVXENVS_DIV    <=  1;
                sCLK_XVXENVS        <=  ~sCLK_XVXENVS;
            end
            else
                sCLK_XVXENVS_DIV    <=  sCLK_XVXENVS_DIV+1'b1;
        end
    end
end
//////////////////////////////////////////////////

timing_gen #(.VOICES(VOICES),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH))timing_gen_inst
(
    .reset_reg_N(reset_reg_N),      // input
    .sCLK_XVXENVS( sCLK_XVXENVS ),  // input
    .xxxx( xxxx ),                  // output
    .xxxx_zero( xxxx_zero )     // output
);

endmodule
