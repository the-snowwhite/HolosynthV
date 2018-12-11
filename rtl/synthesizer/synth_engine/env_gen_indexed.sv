/** 	@file 	env_gen_indexed.v
*		@brief	Memory mapped DX-7 style envelope generator
*					(4 Rates + 4 Levels, Level 3 = Sustain)
*
*		@author	Michael Brown (Holotronic)
*/
module env_gen_indexed #(
parameter VOICES = 8,
parameter V_ENVS = 8,
parameter V_WIDTH = 3,
parameter E_WIDTH = 3
) (
    input wire                      reset_reg_N,
    input wire                      reset_data_N,
    input wire                      sCLK_XVXENVS,
    inout wire      [7:0]           data,
    input wire      [6:0]           adr,
    input wire                      write,
    input wire                      read,
    input wire                      sysex_data_patch_send,
    input wire                      env_sel,
    input wire      [VOICES-1:0]    keys_on,
    input wire [V_WIDTH+E_WIDTH-1:0] xxxx,
    output wire [7:0]               level_mul,
    output reg  [V_ENVS-1:0]        osc_accum_zero,
    output reg  [VOICES-1:0]        voice_free
);

/**	@brief keys_on -> high triggers for a certain voice bit.
*		@return (level_mul) The value for a certain envelope with 1 clk delay (in middle on rising edge).
*
'		@return voice_free bit goes low until keys_on deasserted and eventual release (Rate 4)
*/

localparam rate_mul = 7;
localparam num_mul = 22;

    localparam RES    = 9'h000;  // Reset state <----
    localparam IDLE   = 9'h1FE;  //9'b1 1111 1110;
    localparam RATE1  = 9'h002;  //9'b0 0000 0010;
    localparam LEVEL1 = 9'h004;  //9'b0 0000 0100;
    localparam RATE2  = 9'h008;  //9'b0 0000 1000;
    localparam LEVEL2 = 9'h010;  //9'b0 0001 0000;
    localparam RATE3  = 9'h020;  //9'b0 0010 0000;
    localparam LEVEL3 = 9'h040;  //9'b0 0100 0000;
    localparam RATE4  = 9'h080;  //9'b0 1000 0000;
    localparam LEVEL4 = 9'h100;  //9'b1 0000 0000;

    localparam mainvol_env_nr = 1;

// ------ Internal regs -------//
    reg           [7:0]   r_r[V_ENVS-1:0][3:0];
    reg signed    [7:0]   l_r[V_ENVS-1:0][3:0];

    wire [8:0]st_m;
    reg [8:0]st;
    reg [V_WIDTH-1:0]cur_voice;
    reg [E_WIDTH-1:0]cur_env;
    reg [V_WIDTH-1:0]save_voice;
    reg [E_WIDTH-1:0]save_env;
    reg signed [7:0]r[3:0];
    reg signed [7:0]l[3:0];
    wire signed[36:0]level_m;
    reg signed[36:0]level;
    wire signed[36:0]cur_level = level_m + quotient;
    wire signed[7:0]oldlevel_m;
    reg signed[7:0]oldlevel;
    wire [15:0]cur_denom_m;
    reg [15:0]next_denom;
    wire signed [36:0]cur_numer_m;
    reg signed [36:0]next_numer;
    wire signed[36:0]quotient;

    reg [E_WIDTH-1:0] oi;
    reg [V_WIDTH-1:0] vi;
    reg init = 1;

    reg [VOICES-1:0] go_rate1;

    reg [7:0] data_out;

    assign data = (sysex_data_patch_send && env_sel) ? data_out : 8'bz;

    wire       [E_WIDTH-1:0]   e_env_sel;
    wire       [V_WIDTH-1:0]   e_voice_sel;
    assign e_voice_sel = xxxx[V_WIDTH+E_WIDTH-1:E_WIDTH];
    assign e_env_sel = xxxx[E_WIDTH-1:0]; // 2 env's pr osc

    assign level_mul = level[36:29];

    integer oloop, iloop,v1,e1,d1,r1;

    always@(negedge reset_data_N or negedge write )begin
    if(!reset_data_N) begin
        for (oloop=0;oloop<V_ENVS;oloop=oloop+1)begin
            for(iloop=0;iloop<=3;iloop=iloop+1)begin
                r_r[oloop][iloop] <= 0;
                if (iloop == 2 && oloop <= 2) l_r[oloop][2] <= 8'h7f;
                else l_r[oloop][iloop] <= 0;
            end
            end
    end else begin
        if(env_sel)begin
            for(v1=0;v1<V_ENVS;v1=v1+1) begin
                if(adr == 0+(v1<<3)) r_r[v1][0] <= data  ;
                else if(adr == 1+(v1<<3)) r_r[v1][1] <= data  ;
                else if(adr == 2+(v1<<3)) r_r[v1][2] <= data  ;
                else if(adr == 3+(v1<<3)) r_r[v1][3] <= data  ;
                else if(adr == 4+(v1<<3)) l_r[v1][0] <= data  ;
                else if(adr == 5+(v1<<3)) l_r[v1][1] <= data  ;
                else if(adr == 6+(v1<<3)) l_r[v1][2] <= data  ;
                else if(adr == 7+(v1<<3)) l_r[v1][3] <= data  ;
            end
        end
    end
    end

    always @(posedge read)begin
        if(env_sel)begin
            for(r1=0;r1<V_ENVS;r1=r1+1) begin
                if(adr == 0+(r1<<3)) data_out <= r_r[r1][0];
                else if(adr == 1+(r1<<3)) data_out <= r_r[r1][1];
                else if(adr == 2+(r1<<3)) data_out <= r_r[r1][2];
                else if(adr == 3+(r1<<3)) data_out <= r_r[r1][3];
                else if(adr == 4+(r1<<3)) data_out <= l_r[r1][0];
                else if(adr == 5+(r1<<3)) data_out <= l_r[r1][1];
                else if(adr == 6+(r1<<3)) data_out <= l_r[r1][2];
                else if(adr == 7+(r1<<3)) data_out <= l_r[r1][3];
            end
        end
    end

    st_reg_ram #(.VOICES(VOICES),.V_ENVS(V_ENVS),.V_WIDTH(V_WIDTH),.E_WIDTH(E_WIDTH))st_reg_ram_inst
(
    .q({cur_denom_m,cur_numer_m,level_m,oldlevel_m,st_m}) ,  // output [16+37+37+8+9-1:0] q_sig
    .d({next_denom,  next_numer,  level,  oldlevel,  st}) ,    // input 16+37+37+8+9-1:0] d_sig
    .write_address({save_voice,save_env}) ,   // input  write_address_sig
    .read_address({e_voice_sel,e_env_sel}) ,    // input  read_address_sig
    .we(1'b1) , // input  we_sig
    .wclk(sCLK_XVXENVS  ),     // input  clk_sig
    .rclk(sCLK_XVXENVS  )     // input  clk_sig
);

    div_module div_module_inst (
    .denom ( cur_denom_m ),
    .numer ( cur_numer_m ),
    .quotient ( quotient )
    );

    always @(posedge sCLK_XVXENVS   or negedge reset_reg_N)begin
        if(!reset_reg_N )begin
            cur_voice <= 0;
            cur_env <= 0;
                save_voice <= VOICES-1;
                save_env <= V_ENVS -1;
            oi <= 0;
            vi <= 0;
            init <= 1'b1;
            st <= IDLE;
            level <= 0;
            oldlevel <= 0;
        end
        else if (!init) begin
            cur_voice <= e_voice_sel;
            cur_env <= e_env_sel;
                save_voice <= cur_voice;
                save_env <= cur_env;
            case(st_m)
            RES:
                begin
                    oi <= 0;
                    vi <= 0;
                    init <= 1;
                end
            IDLE:
                begin
                    if (keys_on[cur_voice] == 1'b1)begin
                        level <= 36'h0000000;
                        oldlevel <= level[36:29];
                        next_numer <= (l[0]-oldlevel_m)<<<num_mul;
                        next_denom <= r[0]*r[0];
                        if(cur_env == mainvol_env_nr) begin
                            voice_free[cur_voice] <= 1'b0;
                            go_rate1[cur_voice] <= 1'b1;
                        end
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE1;
                    end
                    else begin
                        level <= 36'h0000000;
                        oldlevel <= level_m[36:29];
                        osc_accum_zero[cur_env] <= 1'b0;
                        if(cur_env == mainvol_env_nr) begin
                            voice_free[cur_voice] <= 1'b1;
                            go_rate1[cur_voice] <= 1'b0;
                        end
                                osc_accum_zero[cur_env] <= 1'b1;
                                st <= IDLE;
                    end
                end
            RATE1:
                begin
                    if(cur_env == mainvol_env_nr) go_rate1[cur_voice] <= 1'b0;
                    if (keys_on[cur_voice]==1'b0)begin // Rate 1
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE4;
                    end
                    else begin
                                if(r[0] > 0 && cur_level[36:29] != l[0])begin // rate1
                        //level <= level_m;
                        next_numer <= (l[0]-oldlevel_m)<<<num_mul;
                        next_denom <= r[0]*r[0];
                        level <= level_m + quotient;
                        oldlevel <= oldlevel_m;
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                    osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE1;
                        end
                        else begin
                        level <= (l[0]<<<29);
                        oldlevel <= level_m[36:29];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                    osc_accum_zero[cur_env] <= 1'b0;
                        st <= LEVEL1;
                        end
                    end
                end
            LEVEL1:
                begin
                    if(cur_env == mainvol_env_nr) go_rate1[cur_voice] <= 1'b0;
                    if (keys_on[cur_voice] == 1'b0)begin // level 1
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        next_numer <= (l[3]-oldlevel_m)<<<num_mul;
                        next_denom <= r[3]*r[3];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE4;
                    end
                    else begin
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        next_numer <= (l[1]-oldlevel_m)<<<num_mul;
                        next_denom <= r[1]*r[1];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE2;
                    end
                end
            RATE2:
                begin
                    if(cur_env == mainvol_env_nr) go_rate1[cur_voice] <= 1'b0;
                    if (keys_on[cur_voice] == 1'b0)begin // rate 2
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        next_numer <= (l[3]-oldlevel_m)<<<num_mul;
                        next_denom <= r[3]*r[3];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE4;
                    end
                    else begin
                            if(r[1] > 0 && cur_level[36:29] != l[1])begin // rate2
                            //level <= level_m;
                            next_numer <= (l[1]-oldlevel_m)<<<num_mul;
                            next_denom <= r[1]*r[1];
                            level <= level_m + quotient;
                            oldlevel <= oldlevel_m;
                            if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                    osc_accum_zero[cur_env] <= 1'b0;
                            st <= RATE2;
                        end
                        else begin
                            level <= l[1]<<<29;
                            oldlevel <= level_m[36:29];
                            if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                    osc_accum_zero[cur_env] <= 1'b0;
                            st <= LEVEL2;
                        end
                    end
                end
            LEVEL2:
                begin
                    if(cur_env == mainvol_env_nr) go_rate1[cur_voice] <= 1'b0;
                    if (keys_on[cur_voice] == 1'b0)begin // level 2
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        next_numer <= (l[3]-oldlevel_m)<<<num_mul;
                        next_denom <= r[3]*r[3];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE4;
                    end
                    else begin
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        next_numer <= (l[2]-oldlevel_m)<<<num_mul;
                        next_denom <= r[2]*r[2];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE3;
                    end
                end
            RATE3:
                begin
                    if(cur_env == mainvol_env_nr) go_rate1[cur_voice] <= 1'b0;
                    if (keys_on[cur_voice] == 1'b0)begin // rate 3
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        next_numer <= (l[3]-oldlevel_m)<<<num_mul;
                        next_denom <= r[3]*r[3];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <=RATE4;
                    end
                    else begin
                            if(r[2] > 0 && cur_level[36:29] != l[2])begin // rate3
                            //level <= level_m;
                            oldlevel <= oldlevel_m;
                            next_numer <= (l[2]-oldlevel_m)<<<num_mul;
                            next_denom <= r[2]*r[2];
                            level <= level_m + quotient;
                            if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                    osc_accum_zero[cur_env] <= 1'b0;
                            st <= RATE3;
                        end
                        else begin
                            level <= l[2]<<<29;
                            oldlevel <= level_m[36:29];
                            if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                    osc_accum_zero[cur_env] <= 1'b0;
                            st <= LEVEL3;
                        end
                    end
                end
            LEVEL3:
                begin
                    if(cur_env == mainvol_env_nr) go_rate1[cur_voice] <= 1'b0;
                    if (keys_on[cur_voice] == 1'b0)begin // level 3
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        next_numer <= (l[3]-oldlevel_m)<<<num_mul;
                        next_denom <= r[3]*r[3];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= RATE4;
                    end
                    else begin
                        level <= l[2]<<<29;
                        oldlevel <= level_m[36:29];
                        if(cur_env == mainvol_env_nr) voice_free[cur_voice] <= 1'b0;
                                osc_accum_zero[cur_env] <= 1'b0;
                        st <= LEVEL3;
                    end
                end
            RATE4:
                begin
                    if (keys_on[cur_voice] ==  1'b1)begin
                        level <= level_m;
                        oldlevel <= level_m[36:29];
                        next_numer <= (l[0]-oldlevel_m)<<<num_mul;
                        next_denom <= r[0]*r[0];
                        if(cur_env == mainvol_env_nr) begin
                                    voice_free[cur_voice] <= 1'b0;
                                    go_rate1[cur_voice] <= 1'b1;
                                end
                                osc_accum_zero[cur_env] <= 1'b1;
                        st <= RATE1;
                    end
                    else begin
                        if(r[3] > 0 && cur_level[36:29] != l[3])begin // rate4
                            next_numer <= (l[3]-oldlevel_m)<<<num_mul;
                            next_denom <= r[3]*r[3];
                            level <= level_m + quotient;
                            oldlevel <= oldlevel_m;
                            if(cur_env == mainvol_env_nr) begin
                                        voice_free[cur_voice] <= 1'b0;
                                        go_rate1[cur_voice] <= 1'b0;
                                    end
                                    osc_accum_zero[cur_env] <= 1'b0;
                            st <= RATE4;
                        end
                        else begin
                            level <= l[3]<<<29;
                            oldlevel <= level_m[36:29];
                            if(cur_env == mainvol_env_nr) begin
                                        voice_free[cur_voice] <= 1'b1;
                                        go_rate1[cur_voice] <= 1'b0;
                                    end
                                    osc_accum_zero[cur_env] <= 1'b0;
                            st <= LEVEL4;
                        end
                    end
                end
            LEVEL4:
                begin
                    if(l[3] == 8'h00)begin
                        level <= 36'h0000000;
                        oldlevel <= 8'h0;
                        next_numer <= 36'h0000000;
                        next_denom <= 8'h01;
                        if(cur_env == mainvol_env_nr) begin
                                    voice_free[cur_voice] <= 1'b1;
                                    osc_accum_zero[cur_env] <= 1'b1;
                                end
                        st <= IDLE;
                    end
                    else begin
                        if (keys_on[cur_voice] ==  1'b1 && cur_env == mainvol_env_nr)begin
                            voice_free[cur_voice] <= 1'b0;
                            go_rate1[cur_voice] <= 1'b1;
                            level <= level_m;
                            oldlevel <= level_m[36:29];
                            next_numer <= (l[0]-oldlevel_m)<<<num_mul;
                            next_denom <= r[0]*r[0];
                                    osc_accum_zero[cur_env] <= 1'b1;
                            st <= RATE1;
                        end
                        else if (go_rate1[cur_voice])begin
                            level <= level_m;
                            oldlevel <= level_m[36:29];
                            next_numer <= (l[0]-oldlevel_m)<<<num_mul;
                            next_denom <= r[0]*r[0];
                                    osc_accum_zero[cur_env] <= 1'b1;
                            st <= RATE1;
                        end
                        else begin
                            level <= l[3]<<<29;
                            oldlevel <= level_m[36:29];
                            next_numer <= 36'h0000000;
                            next_denom <= 8'h01;
                            if(cur_env == mainvol_env_nr)begin
                                voice_free[cur_voice] <= 1'b1;
                                go_rate1[cur_voice] <= 1'b0;
                            end
                                    osc_accum_zero[cur_env] <= 1'b0;
                            st <= LEVEL4;
                        end
                    end
                end
            default: st <= IDLE;
            endcase
        r[0] <= r_r[e_env_sel][0];
        r[1] <= r_r[e_env_sel][1];
        r[2] <= r_r[e_env_sel][2];
        r[3] <= r_r[e_env_sel][3];
        l[0] <= l_r[e_env_sel][0];
        l[1] <= l_r[e_env_sel][1];
        l[2] <= l_r[e_env_sel][2];
        l[3] <= l_r[e_env_sel][3];
        end
        else begin
            oi <= oi + 1;
            cur_voice <= vi;
            cur_env <= oi;
                save_voice <= cur_voice;
                save_env <= cur_env;
                level <= 0;
            oldlevel <= 0;
            st <= IDLE;
            next_numer <= 0;
            next_denom <= 1;
            if(oi == V_ENVS-1) begin
                if(vi<VOICES-1) begin
                    vi <= vi +1;
                end
                else begin init <= 0;
                end
            end
        end
    end

endmodule
