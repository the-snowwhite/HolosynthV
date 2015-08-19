module synth_clk_gen (
input 		reset_reg_N,
input 		OSC_CLK,  		//  180.555556 MHz
input 		AUDIO_CLK,		//  16.964286  MHz
//output reg 	AUDIO_CLK,		//  16.964286  MHz
output reg  AUD_DACLRCK,
output reg  sCLK_XVXOSC,
output reg  sCLK_XVXENVS,
output reg  oAUD_BCLK
);
parameter   VOICES 			= 8;
parameter   V_OSC 			= 4; // oscs per Voice
parameter   V_ENVS 			= 2*V_OSC;
parameter 	SYNTH_CHANNELS = 1;
parameter 	OVERSAMPLING	= 384;
`ifdef _271MhzOscs
parameter   OSC_CLK_RATE       =   271250000;  //  271.250000 MHz
parameter   AUDIO_REF_CLK         =   16953125;   //  16.953125   MHz <<<--- use for 271 
`else

//parameter   OSC_CLK_RATE       =   135625000;  //  135.625000 MHz <<-- use for slow
//parameter   OSC_CLK_RATE       =   180833333;  //  180.833333 MHz <<-- use for fast 
parameter   OSC_CLK_RATE       =   90416666;  //  90.4166665 MHz <<-- use for fast 
//parameter   OSC_CLK_RATE       =   45208333;  //  45.208333 MHz <<-- use for fast 
parameter   AUDIO_REF_CLK         =   16953125;   //  16.953125   MHz <<<--- use for slow
`endif
parameter   SAMPLE_RATE     =   AUDIO_REF_CLK / OVERSAMPLING; //44100;      //  44.1      KHz
`ifdef _24BitAudio
	parameter DATA_WIDTH 	= 24;
`else
	parameter   DATA_WIDTH	= 16;         //  16      Bits
`endif
parameter   CHANNEL_NUM     =   2;          //  Dual Channel

parameter XVOSC_DIV = OSC_CLK_RATE/((SAMPLE_RATE*SYNTH_CHANNELS*VOICES*V_OSC*2)-1);
parameter XVXENVS_DIV = OSC_CLK_RATE/((SAMPLE_RATE*SYNTH_CHANNELS*VOICES*V_ENVS*2)-1);
parameter LRCK_DIV = AUDIO_REF_CLK/((SAMPLE_RATE*2)-1);
parameter BCK_DIV_FAC = AUDIO_REF_CLK/((SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*4)-1);
//parameter AUCK_DIV_FAC = OSC_CLK_RATE/((AUDIO_REF_CLK*2)-1);
parameter XVXOSC_WIDTH = utils::clogb2(XVOSC_DIV);
parameter XVXENVS_WIDTH = utils::clogb2(XVXENVS_DIV);
parameter LRCK_WIDTH = utils::clogb2(LRCK_DIV);
parameter BCK_DIV_WIDTH = utils::clogb2(BCK_DIV_FAC);

//  Internal Registers and Wires
reg     [XVXOSC_WIDTH:0]	sCLK_XVXOSC_DIV;
reg     [XVXENVS_WIDTH:0]	sCLK_XVXENVS_DIV;
//reg     [8:0]	AUCK_DIV;
reg     [LRCK_WIDTH:0]	AUD_DACLRCK_DIV;
reg     [BCK_DIV_WIDTH:0]	BCK_DIV;


////////////////////////////////////
always@(negedge OSC_CLK or negedge reset_reg_N)
begin
    if(!reset_reg_N)
    begin
        sCLK_XVXOSC_DIV     <=  0;
        sCLK_XVXENVS_DIV    <=  0;
        sCLK_XVXOSC <=  0;
        sCLK_XVXENVS    <=  0;
//        AUCK_DIV    <=  0;
//        AUDIO_CLK    <=  0;
    end
    else
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
	/////////// AUD_REF_BCK Generator   //////////////
/*       //  AUD_REF_BCK
        if(AUCK_DIV >= AUCK_DIV_FAC )
        begin
            AUCK_DIV     <=  1;
            AUDIO_CLK    <=  ~AUDIO_CLK;
        end
        else
			AUCK_DIV     <=  AUCK_DIV+1'b1;
*/	end 
end 
//////////////////////////////////////////////////
always@(posedge AUDIO_CLK or negedge reset_reg_N)
begin
    if(!reset_reg_N)
    begin
        AUD_DACLRCK_DIV	<=  0;
        AUD_DACLRCK     <=  0;
        BCK_DIV     <=  0;
        oAUD_BCLK    <=  0;
    end
    else
    begin
////////////    AUD_LRCK Generator  //////////////
        //  LRCK 1X
        if(AUD_DACLRCK_DIV >= LRCK_DIV )
        begin
            AUD_DACLRCK_DIV <=  1;
            AUD_DACLRCK <=  ~AUD_DACLRCK;
        end
        else
        AUD_DACLRCK_DIV     <=  AUD_DACLRCK_DIV+1'b1;
 /////////// AUD_BCLK Generator   //////////////
       //  AUD_BCLK
        if(BCK_DIV >= BCK_DIV_FAC )
        begin
            BCK_DIV     <=  1;
            oAUD_BCLK    <=  ~oAUD_BCLK;
        end
        else
        BCK_DIV     <=  BCK_DIV+1'b1;
    end
end

endmodule
