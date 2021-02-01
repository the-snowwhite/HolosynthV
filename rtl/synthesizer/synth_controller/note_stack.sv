module note_stack #(
parameter VOICES = 8,
parameter V_WIDTH = 3
) (
    input wire                  reg_clk,
    input wire                  reset_reg_N,
    input wire  [VOICES-1:0]    voice_free,
    input wire                  is_data_byte,
    input wire                  is_velocity,
    input wire                  is_st_note_on,
    input wire                  is_st_note_off,
    input wire                  is_st_ctrl,
//    input wire                  auto_syx_cmd,
    input wire                  trig__note_stack,
    input wire  [7:0]           seq_databyte,
    output reg [V_WIDTH:0]      active_keys,
    output reg                  note_on,
    output reg [V_WIDTH-1:0]    cur_key_adr,
    output reg [7:0]            cur_key_val,
    output reg [7:0]            cur_vel_on,
    output reg [7:0]            cur_vel_off,
// outputs to synth_engine
    output reg  [VOICES-1:0]    keys_on

);

    integer free_voices_found;
 //   integer note_found;
    integer i0;
    integer i1;
    integer i22;
    integer i2;
    integer i3;
    integer i4;
    integer i5;
    integer i6;
    integer i7;
    integer i8;

// ----- Pack / Unpack macros   ---- //

// `define PACK_BIT_ARRAY(PK_LEN,PK_SRC,PK_DEST) generate genvar pk_idx; for(pk_idx=0;pk_idx<(PK_LEN);pk_idx = pk_idx+1)begin : pack_bit_array assign keys_on[pk_idx] = key_on[pk_idx]; end endgenerate
//  // -----        End Macros Def     ---- //
//  `PACK_BIT_ARRAY(VOICES,key_on,keys_on)

// -----        End Macros     ---- //

//    reg   key_on[VOICES-1:0];

    reg   [7:0]key_val[VOICES-1:0];

    reg voice_free_r[VOICES-1:0];
//    reg reg_voice_free [VOICES-1:0];
    reg [V_WIDTH:0]cur_slot;

    reg [V_WIDTH-1:0]first_free_voice;
    reg free_voice_found_r;
//    reg [V_WIDTH-1:0]first_on;
    reg [V_WIDTH-1:0] on_slot[VOICES-1:0];
    reg [V_WIDTH-1:0] off_slot[VOICES-1:0];
    reg free_voice_found;
    reg [7:0]vel_off;
    reg [7:0]cur_note;
    reg [V_WIDTH-1:0]slot_off;

    wire is_allnotesoff;
    
    initial begin
        free_voice_found = 1'b1;
        first_free_voice = 0;
        active_keys = 0;
        cur_key_val = 8'hff;
        cur_vel_on = 0;
        cur_vel_off = 0;
       for(i5=0;i5<VOICES-1;i5=i5+1)begin
            keys_on[i5] = 1'b0;
            cur_key_adr = i5;
            key_val[i5] = 8'hff;
            on_slot[i5] = 0;
            off_slot[i5] = 0;
        end
        slot_off = 0;
        cur_note = 0;
        cur_slot = 0;
        note_on = 1'b0;
    end
    
    assign is_allnotesoff    =   ((seq_databyte==8'h7b)?1'b1:1'b0);



    always @(posedge reg_clk)begin
        for(i0=0; i0 < VOICES ; i0=i0+1) begin
            voice_free_r[i0] <= voice_free[i0];
            free_voice_found_r <= free_voice_found;
        end
    end

//    assign free_voice_found = (free_voices_found > 0) ? 1'b1: 1'b0;

    always @(posedge is_data_byte)begin
        for(i3=VOICES-1,free_voices_found=0; i3 >= 0 ; i3=i3-1) begin
            free_voice_found = 1'b0;
            if(voice_free_r[i3])begin
                free_voices_found = free_voices_found +1;
                first_free_voice = i3;
            end
            if (free_voices_found > 0) free_voice_found = 1'b1;
        end
    end


    always @(posedge reg_clk) begin
        if (trig__note_stack)begin
            note_on <= 1'b0;
            if(is_st_note_on)begin // Note on omni
                if(is_data_byte)begin
                    if(active_keys >= VOICES) begin
                        active_keys <= active_keys-1'b1;
                        keys_on[on_slot[0]]<=1'b0;
                        cur_key_adr <= on_slot[0];
                        cur_key_val <=8'hff;
                        key_val[on_slot[0]]<=8'hff;
                        slot_off<=on_slot[0];
                        cur_slot<=on_slot[0];
                    end
                    else if(free_voice_found_r  == 1'b0)begin
                        cur_slot <= off_slot[active_keys];
                    end
                    else begin
                        cur_slot<=first_free_voice;
                    end
                    for(i6=VOICES-1;i6>0;i6=i6-1)begin
                        on_slot[i6-1]<=on_slot[i6];
                    end
                    cur_note<=seq_databyte;
                end
                else if(is_velocity)begin
                    if(seq_databyte == 0)begin
                        for(i22=0;i22<VOICES;i22=i22+1)begin
                            if(cur_note==key_val[i22])begin
                                active_keys <= active_keys-1'b1;
                                slot_off<=i22;
                                keys_on[i22]<=1'b0;
                                cur_key_adr <= i22;
                                cur_key_val <= 8'hff;
                                key_val[i22] <= 8'hff;
                            end
                        end
                    end
                    else begin
                        active_keys <= active_keys+1'b1;
                        keys_on[cur_slot]<=1'b1;
                        cur_key_adr <= cur_slot;
                        cur_key_val <= cur_note;
                        cur_vel_on <= seq_databyte;
                        note_on <= 1'b1;
                        key_val[cur_slot]<=cur_note;
                        on_slot[VOICES-1] <= cur_slot;
                    end
                end
            end
            else if(is_st_ctrl)begin // Control Change omni
                if(is_data_byte)begin
                    if(is_allnotesoff)begin
                        for(i4=0;i4<VOICES;i4=i4+1)begin
                            keys_on[i4]<=1'b0;
                            cur_key_adr <= i4;
                            key_val[i4]<=8'hff;
                            cur_key_val<=8'hff;
                        end
                        slot_off <= 0;
                        cur_note <= 0;
                        active_keys <= 0;
                    end
                end
            end
            else if (is_st_note_off) begin// Note off omni
                if(is_data_byte)begin
                    for(i2=0;i2<VOICES;i2=i2+1)begin
                        if(seq_databyte==key_val[i2])begin
                            active_keys <= active_keys-1'b1;
                            slot_off<=i2;
                            keys_on[i2]<=1'b0;
                            cur_key_adr <= i2;
                            cur_key_val <= 8'hff;
                            key_val[i2] <= 8'hff;
                        end
                    end
                end
                else if(is_velocity )begin
                    if(key_val[slot_off] == 8'hff)begin
                        cur_vel_off<=seq_databyte;
                        off_slot[VOICES-1]<=slot_off;
                        for(i7=VOICES-1;i7>0;i7=i7-1)begin
                            if(i7>active_keys)begin
                                off_slot[i7-1] <= off_slot[i7];
                            end
                        end
                    end
                    if(active_keys == 0)begin
                        for(i8=0;i8<VOICES;i8=i8+1)begin
                            keys_on[i8]<=1'b0;
                            cur_key_adr <= i8;
                            cur_key_val <= 8'hff;
                            cur_vel_on <= 8'd0;
                            cur_vel_off <= 8'd0;
                            key_val[i8] <= 8'hff;
                        end
                        cur_note <= 8'd0;
                        slot_off <= 0;
                        cur_slot <= 0;
                    end
                end
            end
        end
    end


endmodule
