module osc (
    input                       reset_reg_N,
    input                       reset_data_N,
    input                       sCLK_XVXENVS,
    input                       sCLK_XVXOSC,
    inout                       [7:0] data,
    input                       [6:0] adr,
    input                       write,
    input                       read,
    input                       sysex_data_patch_send,
    input [V_WIDTH+E_WIDTH-1:0] xxxx,
    input                       osc_sel,
    input [23:0]                osc_pitch_val,
    input signed [10:0]         modulation,
    input [VOICES-1:0]          voice_free,
    input [V_ENVS-1:0]          osc_accum_zero,
    output signed [16:0]        sine_lut_out
);

parameter VOICES = 8;
parameter V_OSC = 4;
parameter V_ENVS = 8;
parameter V_WIDTH = 3;
parameter O_WIDTH = 2;
parameter OE_WIDTH = 1;
parameter E_WIDTH = O_WIDTH + OE_WIDTH;
parameter ox_offset = (V_OSC * VOICES ) - 1;

    logic [10:0]tablelookup;
    logic signed [10:0]phase_acc;
    logic signed [10:0] mod;

    logic [O_WIDTH-1:0] ox;
    logic [V_WIDTH-1:0] vx;
    assign ox = xxxx[E_WIDTH-1:OE_WIDTH];
    assign vx = xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH];

    reg signed [7:0] o_offs [V_OSC-1:0];
    reg [O_WIDTH-1:0] ox_dly[ox_offset:0]; // All Voices 2 osc's

    reg [7:0] data_out;

    logic [V_OSC-1:0] osc_adr_data;

    generate
        genvar osc3;
        for (osc3=0;osc3<V_OSC;osc3=osc3+1)begin : oscdataloop
            assign osc_adr_data[osc3] = (adr == (7'd6 +(osc3<<4))) ? 1'b1 : 1'b0;
        end
    endgenerate

    assign data = (sysex_data_patch_send && (((osc_adr_data != 0) && osc_sel))) ? data_out : 8'bz;

    assign mod = modulation;

    integer loop,o1,o2,d1;

    always@(posedge sCLK_XVXOSC)begin
        ox_dly[0] <= ox;
        for(d1=0;d1<ox_offset;d1=d1+1)
        ox_dly[d1+1] <= ox_dly[d1];
    end

    always@(negedge reset_data_N or negedge write)begin
        if(!reset_data_N) begin
            for (loop=0;loop<V_OSC;loop=loop+1)begin
                o_offs[loop] <= 8'h00;
            end
        end else begin
            if(osc_sel)begin
                for (o1=0;o1<V_OSC;o1=o1+1)begin
                    if (adr == (7'd6+(o1<<4))) o_offs[o1] <= data;
                end
            end
        end
    end

/** @brief read data
*/

    always @(posedge read) begin
        if(osc_sel)begin
            for (o2=0;o2<V_OSC;o2=o2+1)begin
                if (adr == (7'd6+(o2<<4))) data_out <= o_offs[o2];
            end
        end
    end

    nco2 #(.VOICES(VOICES),.V_OSC(V_OSC),.V_WIDTH(V_WIDTH),.V_ENVS(V_ENVS),.O_WIDTH(O_WIDTH))  nco_inst (
        .reset_reg_N(reset_reg_N) ,   // input  reset_reg_N_sig
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
