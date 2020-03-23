module pitch_control #(
parameter VOICES = 8,
parameter V_OSC = 4,
parameter V_WIDTH = 3,
parameter O_WIDTH = 2,
parameter OE_WIDTH = 1,
parameter E_WIDTH = O_WIDTH + OE_WIDTH
) (
    input wire                          reset_reg_N,
    input wire                          reset_data_N,
    input wire                          sCLK_XVXOSC,
    input wire [V_WIDTH+E_WIDTH-1:0]    xxxx,
    input wire [V_WIDTH-1:0]            cur_key_adr,
    input wire [7:0]                    cur_key_val,
    input wire [13:0]                   pitch_val,
    input wire                          note_on,
    inout wire [7:0]                    data,
    input wire [6:0]                    adr,
    input wire                          write,
    input wire                          read,
    input wire                          sysex_data_patch_send,
    input wire                          osc_sel,
    input wire                          com_sel,
    output wire [23:0]                  osc_pitch_val
);

    reg           [7:0]rkey_val[VOICES-1:0];

    reg  signed   [7:0]osc_ct[V_OSC-1:0];
    reg  signed   [7:0]osc_ft[V_OSC-1:0];
    reg  signed   [7:0]b_ct[V_OSC-1:0];   // base pitch
    reg  signed   [7:0]b_ft[V_OSC-1:0];  // base tune
    reg  signed   [7:0]k_scale[V_OSC-1:0];

    reg  signed   [7:0]pb_range;

    reg [7:0] data_out;

    wire [O_WIDTH-1:0] ox;
    wire [V_WIDTH-1:0] vx;

    wire [V_OSC-1:0] osc_adr_data;

    assign ox = xxxx[E_WIDTH-1:OE_WIDTH];
assign vx = xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH];

    reg [O_WIDTH-1:0] ox_dly[3:0];

    always @(posedge sCLK_XVXOSC)begin
        ox_dly[0] <= ox;
        ox_dly[1] <= ox_dly[0];
        ox_dly[2] <= ox_dly[1];
        ox_dly[3] <= ox_dly[2];
    end

    generate
        genvar osc3;
        for (osc3=0;osc3<V_OSC;osc3=osc3+1)begin : oscdataloop
            assign osc_adr_data[osc3] = (adr == (7'd0 +(osc3<<4)) || (adr == 7'd1 +(osc3<<4)) || (adr == 7'd5 +(osc3<<4)) ||
            (adr == 7'd8 +(osc3<<4)) || (adr == 7'd9 +(osc3<<4))) ? 1'b1 : 1'b0;
        end
    endgenerate

    assign data = (sysex_data_patch_send && (((osc_adr_data != 0) && osc_sel) || (com_sel && adr == 0))) ? data_out : 8'bz;

    integer v1,loop,o1,o2,kloop;

    always @(negedge reset_reg_N or posedge note_on)begin
        if(!reset_reg_N)begin
            for (kloop=0;kloop<VOICES;kloop=kloop+1)begin
                rkey_val[kloop] <= 8'hff;
            end
        end
        else
            rkey_val[cur_key_adr] <= cur_key_val;
    end

    always@(negedge reset_data_N or negedge write)begin
        if(!reset_data_N) begin
            for (loop=0;loop<V_OSC;loop=loop+1)begin
                osc_ct[loop] <= 8'h40;
                osc_ft[loop] <= 8'h40;
                b_ct[loop] <= 8'h40;
                b_ft[loop] <= 8'h40;
                k_scale[loop] <= 8'h0;
            end
            pb_range <= 8'h03;
        end else begin
            if(osc_sel)begin
                for (o1=0;o1<V_OSC;o1=o1+1)begin
                    case (adr)
                        7'd0 +(o1<<4): osc_ct[o1] <= data;
                        7'd1 +(o1<<4): osc_ft[o1] <= data;
                        7'd5 +(o1<<4): k_scale[o1] <= data;
                        7'd8 +(o1<<4): b_ct[o1] <= data;
                        7'd9 +(o1<<4): b_ft[o1] <= data;
                        default:;
                    endcase
                end
            end
            else if(com_sel) begin
                if(adr == 0) pb_range <= data;
            end
        end
    end

/** @brief read data
*/
    always @(posedge read) begin
        if(osc_sel)begin
            for (o2=0;o2<V_OSC;o2=o2+1)begin
                case (adr)
                    7'd0 +(o2<<4): data_out <= osc_ct[o2];
                    7'd1 +(o2<<4): data_out <= osc_ft[o2];
                    7'd5 +(o2<<4): data_out <= k_scale[o2];
                    7'd8 +(o2<<4): data_out <= b_ct[o2];
                    7'd9 +(o2<<4): data_out <= b_ft[o2];
                    default:;
                endcase
            end
        end
        else if(com_sel) begin
            if(adr == 0) data_out <= pb_range;
        end
    end



////////        Internals       ////////
    wire [8:0] key;
    wire [8:0] ft_ct_key;

    assign key = (b_ct[ox] <= 63) ?
        ((rkey_val[vx])-( 64 - b_ct[ox])+128) : ((rkey_val[vx])+(b_ct[ox][5:0])+128);

    assign ft_ct_key = (b_ft[ox] <= 63) ? (key-1) : (key+1);

    wire [23:0]ct_res;
    wire [23:0]ft_ct_res;

    constmap2 constmap(.sound(key), .clk(sCLK_XVXOSC), .constant(ct_res));
    constmap2 ct_pb_pitchmap(.sound(ft_ct_key), .clk(sCLK_XVXOSC), .constant(ft_ct_res));

    wire [23:0]pb_res;
    wire [23:0]ft_pb_res;
    wire [23:0]key_scale;

    wire [29:0]ft_range_l;
    wire [29:0]ft_range_h;
    wire [23:0]ft_pitch;
    wire [8:0] pitch_key;
    wire [8:0] pb_pitch_key;
    wire [36:0]pb_range_l;
    wire [36:0]pb_range_h;
    wire [42:0]pb_ft_range_l;
    wire [42:0]pb_ft_range_h;
    wire [23:0]full_pitch;
    wire [23:0]base_pitch_val;
// Fine tune  //
    assign ft_range_l = (ct_res-ft_ct_res)*(64 - b_ft[ox_dly[0]]);//b_ft(down)
    assign ft_range_h = ((ft_ct_res - ct_res)*b_ft[ox_dly[0]][5:0]);// b_ft(up)

    assign ft_pitch = (b_ft[ox_dly[0]] <= 63) ? (ct_res- (ft_range_l>>6)) //b_ft(down)
    : ((ct_res + (ft_range_h>>6)));//b_ft(up)

// Pitch bend  //
    assign pitch_key = (pitch_val <= 14'h1fff) ? (key-pb_range) : (key+pb_range);
    assign pb_pitch_key = (pitch_val <= 14'h1fff) ? (key-(pb_range+1)) : (key+(pb_range+1));

    constmap2 pitchmap_pb(.sound(pitch_key), .clk(sCLK_XVXOSC), .constant(pb_res));
    constmap2 ft_pb_pitchmap(.sound(pb_pitch_key), .clk(sCLK_XVXOSC), .constant(ft_pb_res));

    assign pb_range_l = (ft_pitch-pb_res)*(14'h2000-pitch_val);//pb(down)
    assign pb_range_h = ((pb_res - ft_pitch)*pitch_val[12:0]);//pb(up)

    assign pb_ft_range_l = (b_ft[ox_dly[0]] <= 63) ? (pb_res - ft_pb_res)*(14'h2000-pitch_val)*(64-b_ft[ox_dly[0]])
    : (pb_res - ft_pb_res)*(14'h2000-pitch_val)*b_ft[ox_dly[0]][5:0];

    assign pb_ft_range_h = (b_ft[ox_dly[0]] <= 63) ? ((ft_pb_res - pb_res)*pitch_val[12:0]*(64-b_ft[ox_dly[0]]))//pb_up b_ft(down)
    : ((ft_pb_res - pb_res)*pitch_val[12:0]*b_ft[ox_dly[0]][5:0]);// pb(up) b_ft(up)

    assign full_pitch = (pitch_val <= 14'h1fff) ? (b_ft[ox_dly[0]] <= 63) ? (ft_pitch-(pb_range_l>>13)-(pb_ft_range_l>>19))//pb(down) b_ft(down)
    : (ft_pitch-(pb_range_l>>13)+(pb_ft_range_l>>19)) //pb(down) b_ft_(up)
    : (b_ft[ox_dly[0]] <= 63) ? (ft_pitch+(pb_range_h>>13)-(pb_ft_range_h>>19))//pb(up) b_ft(down)
    : (ft_pitch+(pb_range_h>>13)+(pb_ft_range_h>>19));// pb(up)

// keyboard rate scaling //
    assign base_pitch_val = full_pitch + (k_scale[ox_dly[0]] << 4);

    wire [30:0]osc_res;
    wire [30:0]osc_res_l;
    wire [30:0]osc_res_h;
//    wire [23:0]osc_transp_range_l;
//    wire [23:0]osc_transp_range_h;
    wire [30:0]osc_transp_range_l;
    wire [30:0]osc_transp_range_h;
    wire [30:0]osc_transp_val_l;
    wire [30:0]osc_transp_val_h;
    wire [7:0]osc_ct_64;

    assign osc_ct_64 = (osc_ct[ox_dly[0]] <= 8'd64) ?
            (64-osc_ct[ox_dly[0]]+1):(osc_ct[ox_dly[0]][5:0]+1);

    wire signed [24:0] osc_res_div, osc_res_l_div, osc_res_h_div;

    pitchdiv	pitchdiv_inst (
        .denom ( osc_ct_64 ),
        .numer ( base_pitch_val ),
        .quotient ( osc_res_div )
    );
    pitchdiv	pitchdiv_l_inst (
        .denom ( osc_ct_64+8'd1 ),
        .numer ( base_pitch_val ),
        .quotient ( osc_res_l_div )
    );
    pitchdiv	pitchdiv_h_inst (
        .denom ( osc_ct_64-8'd1 ),
        .numer ( base_pitch_val ),
        .quotient ( osc_res_h_div )
    );

    reg [7:0]	osc_ct_64_r;
    reg signed [24:0] 	osc_res_div_r, osc_res_l_div_r, osc_res_h_div_r, base_pitch_val_r;

    always @(posedge sCLK_XVXOSC)begin
        osc_ct_64_r <= osc_ct_64;
        osc_res_div_r <= osc_res_div;
        osc_res_l_div_r <= osc_res_l_div;
        osc_res_h_div_r <= osc_res_h_div;
        base_pitch_val_r <= base_pitch_val;
    end

    assign osc_res =  (osc_ct[ox_dly[1]] <= 8'd64) ?// M:C Ratio
        (osc_res_div_r):
        (base_pitch_val_r * (osc_ct_64_r));

    assign osc_res_l =  (osc_ct[ox_dly[1]] <= 8'd64) ?// M:C Ratio
        (osc_res_l_div_r):
        (base_pitch_val_r * (osc_ct_64_r-1));

    assign osc_res_h =  (osc_ct[ox_dly[1]] <= 8'd63) ?// M:C Ratio
        (osc_res_h_div_r):
        (base_pitch_val_r * (osc_ct_64_r+1));

    reg [30:0]	osc_res_r, osc_res_l_r, osc_res_h_r;

    always @(posedge sCLK_XVXOSC)begin
        osc_res_r <= osc_res;
        osc_res_l_r <= osc_res_l;
        osc_res_h_r <= osc_res_h;
    end
    assign osc_transp_range_l = osc_res_r - osc_res_l_r;
    assign osc_transp_range_h = osc_res_h_r - osc_res_r;
    assign osc_transp_val_l = (64 - osc_ft[ox_dly[2]]) * osc_transp_range_l;  //
    assign osc_transp_val_h = (osc_ft[ox_dly[2]][5:0]) * osc_transp_range_h;    //

    assign osc_pitch_val =  (osc_ft[ox_dly[2]] <= 8'h40) ?
                    (osc_res_r - (osc_transp_val_l>>6)) :
                    (osc_res_r + (osc_transp_val_h>>6));

endmodule
