module midi_ctrl_data (
    input                		reset_data_N,        // reset
    input               [6:0]   adr,
    input                       write,
    input                       read,
    input						sysex_data_patch_send,
    input						osc_sel,
    input						com_sel,
    input						m1_sel,
    input						m2_sel,
    inout signed        [7:0]   data,
    output reg  signed  [7:0]   osc_lvl     [V_OSC-1:0],
    output reg  signed  [7:0]   osc_mod     [V_OSC-1:0],
    output reg  signed  [7:0]   osc_feedb   [V_OSC-1:0],
    output reg  signed  [7:0]   osc_pan     [V_OSC-1:0],
    output reg  signed  [7:0]   osc_mod_in  [V_OSC-1:0],
    output reg  signed  [7:0]   osc_feedb_in[V_OSC-1:0],
    output reg  signed  [7:0]   m_vol,
    output reg  signed  [7:0]   mat_buf1    [15:0][V_OSC-1:0],
    output reg  signed  [7:0]   mat_buf2    [15:0][V_OSC-1:0],
    output reg          [7:0]   patch_name  [15:0]
);
parameter V_OSC		= 4; // oscs per Voice

    logic [V_OSC-1:0] osc_adr_data;
    reg signed [7:0] data_out;

    generate
        genvar osc3;
        for (osc3=0;osc3<V_OSC;osc3=osc3+1)begin : oscdataloop
            assign osc_adr_data[osc3] = (adr == (7'd2 +(osc3<<4)) || (adr == 7'd3 +(osc3<<4)) || (adr == 7'd4 +(osc3<<4)) ||
            (adr == 7'd7 +(osc3<<4)) || (adr == 7'd10 +(osc3<<4)) || (adr == 7'd11 +(osc3<<4)) || (adr == 7'd12 +(osc3<<4))
            || (adr == 7'd13 +(osc3<<4)) || (adr == 7'd14 +(osc3<<4)) || (adr == 7'd15 +(osc3<<4))) ? 1'b1 : 1'b0;
        end
    endgenerate


    assign data = (sysex_data_patch_send && (((osc_adr_data != 0) && osc_sel) || (com_sel && (adr == 1 || adr >=10)) || m1_sel || m2_sel)) ? data_out : 8'bz;

    byte unsigned loop,oloop,iloop,inloop,osc1,osc2,ol1,il1,ol2,il2,o21,i21,o22,i22,innam,outnam;

/**		@brief get midi controller data from midi decoder
*/
    always@(negedge reset_data_N or negedge write)begin : receive_midi_controller_data
        if(!reset_data_N) begin
            for (loop=0;loop<V_OSC;loop=loop+1)begin
                if(loop <= 1)osc_lvl[loop] <= 8'h40;
                else osc_lvl[loop] <= 8'h00;
                osc_mod[loop] <= 8'h00;
                osc_feedb[loop] <= 8'h00;
                osc_pan[loop] <= 8'h40;
                osc_mod_in[loop] <= 8'h00;
                osc_feedb_in[loop] <= 8'h00;
            end
            for (oloop=0;oloop<16;oloop=oloop+1)begin
                for(iloop=0;iloop<V_OSC;iloop=iloop+1)begin
                    mat_buf1[oloop][iloop] <= 8'h00;
                    mat_buf2[oloop][iloop] <= 8'h00;
                end
            end
            m_vol <= 8'h40;
                for(inloop=0;inloop<16;inloop=inloop+1)begin
                    patch_name[inloop] <= 8'd32;
                end
        end else if(!write) begin
            if(osc_sel)begin
                for (osc1=0;osc1<V_OSC;osc1=osc1+1)begin
                    case (adr)
                        7'd2 +(osc1<<4): osc_lvl[osc1] <= data;
                        7'd3 +(osc1<<4): osc_mod[osc1] <= data;
                        7'd4 +(osc1<<4): osc_feedb[osc1] <= data;
                        7'd7 +(osc1<<4): osc_pan[osc1] <= data;
                        7'd10 +(osc1<<4): osc_mod_in[osc1] <= data;
                        7'd11 +(osc1<<4): osc_feedb_in[osc1] <= data;
                        default:;
                    endcase
                end
            end
            else if(com_sel) begin
                if(adr == 1) m_vol <= data;
                    else if(adr >= 16 && adr < 32)begin
                        for(innam=0;innam<16;innam=innam+1)begin
                            if(adr == (innam + 16)) patch_name[innam] <= data;
                        end
                    end
            end
            else if (m1_sel) begin
            for (ol1=0;ol1<16;ol1=ol1+1)begin
                for(il1=0;il1<V_OSC;il1=il1+1)begin
                    if (adr == (il1 << 4)+ol1) mat_buf1[ol1][il1] <= data;
                end
                end
            end
            else if (m2_sel) begin
                for (ol2=0;ol2<16;ol2=ol2+1)begin
                    for(il2=0;il2<V_OSC;il2=il2+1)begin
                        if (adr == (il2 << 4)+ol2)mat_buf2[ol2][il2] <= data;
                    end
                end
            end
        end
    end

/** @brief read data
*/

    always @(posedge read) begin
        if(osc_sel)begin
            for (osc2=0;osc2<V_OSC;osc2=osc2+1)begin
                case (adr)
                    7'd2 +(osc2<<4): data_out <= osc_lvl[osc2];
                    7'd3 +(osc2<<4): data_out <= osc_mod[osc2];
                    7'd4 +(osc2<<4): data_out <= osc_feedb[osc2];
                    7'd7 +(osc2<<4): data_out <= osc_pan[osc2];
                    7'd10 +(osc2<<4): data_out <= osc_mod_in[osc2];
                    7'd11 +(osc2<<4): data_out <= osc_feedb_in[osc2];
                    7'd12 +(osc2<<4): data_out <= 8'h00;
                    7'd13 +(osc2<<4): data_out <= 8'h00;
                    7'd14 +(osc2<<4): data_out <= 8'h00;
                    7'd15 +(osc2<<4): data_out <= 8'h00;
                    default:;
                endcase
            end
        end
        else if(com_sel) begin
            if(adr == 1) data_out <= m_vol;
                else if(adr > 2 && adr <= 15)data_out <= 0;
                else if (adr >= 16 && adr < 32) begin
                for(outnam=0;outnam<16;outnam=outnam+1)begin
                    if(adr == (outnam + 16)) data_out <= patch_name[outnam];
                end
            end
        end
        else if (m1_sel) begin
        for (o21=0;o21<16;o21=o21+1)begin
            for(i21=0;i21<V_OSC;i21=i21+1)begin
                if (adr == (i21 << 4)+o21) data_out <= mat_buf1[o21][i21];
            end
            end
        end
        else if (m2_sel) begin
            for (o22=0;o22<16;o22=o22+1)begin
                for(i22=0;i22<V_OSC;i22=i22+1)begin
                    if (adr == (i22 << 4)+o22) data_out <= mat_buf2[o22][i22];
                end
            end
        end
    end

endmodule
