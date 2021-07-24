module osc #(
parameter VOICES = 8,
parameter V_OSC = 8,
parameter O_ENVS = 2,
parameter V_ENVS = O_ENVS*V_OSC,
parameter V_WIDTH = 3,
parameter O_WIDTH = 2,
parameter OE_WIDTH = 1,
parameter E_WIDTH = O_WIDTH + OE_WIDTH,
parameter ox_offset = (V_OSC * VOICES ) - 1
) (
    input wire                          reg_clk,
    input wire                          sCLK_XVXENVS,
    input wire                          sCLK_XVXOSC,
    output reg [7:0]                    osc_regdata_out,
    input wire                          [7:0] synth_data_in,
    input wire                          [6:0] adr,
    input wire                          write,
    input wire                          read,
//    input wire                          read_select,
    input wire [V_WIDTH+E_WIDTH-1:0]    xxxx,
    input wire                          osc_sel,
    input wire [23:0]                   osc_pitch_val,
    input wire signed [10:0]            modulation,
    input wire [VOICES-1:0]             voice_free,
    input wire [V_ENVS-1:0]             osc_accum_zero,
    output wire [16:0]                  sine_lut_out
);

    wire [10:0]tablelookup;
    wire signed [10:0]phase_acc;
    wire signed [10:0] mod;

    wire [O_WIDTH-1:0] ox;
    wire [V_WIDTH-1:0] vx;
    assign ox = xxxx[E_WIDTH-1:OE_WIDTH];
    assign vx = xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH];

    reg signed [7:0] o_offs [V_OSC-1:0];
    reg [O_WIDTH-1:0] ox_dly[ox_offset:0]; // All Voices 2 osc's

    assign mod = modulation;

    integer loop,o1,o2,d1;

    initial begin
        for (loop=0;loop<V_OSC;loop=loop+1)begin
            o_offs[loop] = 8'h00;
        end
    end

    always@(posedge sCLK_XVXOSC)begin
        ox_dly[0] <= ox;
        for(d1=0;d1<ox_offset;d1=d1+1)
        ox_dly[d1+1] <= ox_dly[d1];
    end

    always@(posedge reg_clk )begin
        if(osc_sel && write)begin
            for (o1=0;o1<V_OSC;o1=o1+1)begin
                if (adr == (7'd6+(o1<<4))) o_offs[o1] <= synth_data_in;
            end
        end
    end

/** @brief read data
*/

    always @(negedge reg_clk) begin
        if(osc_sel && read)begin
            for (o2=0;o2<V_OSC;o2=o2+1)begin
                if (adr == (7'd6+(o2<<4))) osc_regdata_out <= o_offs[o2];
            end
        end
    end

    nco2 #(.VOICES(VOICES),.V_OSC(V_OSC),.V_WIDTH(V_WIDTH),.O_ENVS(O_ENVS),.O_WIDTH(O_WIDTH))  nco_inst (
        .sCLK_XVXOSC (sCLK_XVXOSC ),
        .sCLK_XVXENVS (sCLK_XVXENVS ),
        .osc_pitch_val ( osc_pitch_val ),
        .osc_accum_zero ( osc_accum_zero ),
        .ox    ( ox ),
        .vx    ( vx ),
        .phase_acc ( phase_acc )
    );

    assign tablelookup = phase_acc + mod + (o_offs[ox_dly[ox_offset]] << 3);

    sine_lookup osc_sine(.clk( sCLK_XVXENVS ), .addr( tablelookup ), .sine_value( sine_lut_out ));

endmodule
