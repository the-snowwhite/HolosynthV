module midi_decoder(
	input							reset_reg_N,
	input							CLOCK_25,
// from uart
	input							byteready,
	input [7:0]						cur_status,
	input [7:0]						midibyte_nr,
	input [7:0]						midibyte,
	input							midi_out_ready,
	output							midi_send_byte,
	output reg [7:0]				midi_out_data,
// inputs from synth engine	
	input [VOICES-1:0]			voice_free,
	input [3:0]						midi_ch,
// outputs to synth_engine	
	output [VOICES-1:0]			keys_on,
// note events
	output reg						note_on,
	output reg [V_WIDTH-1:0]	cur_key_adr,
	output reg [7:0]				cur_key_val,
	output reg [7:0]				cur_vel_on,
	output reg [7:0]				cur_vel_off,
// controller data
//    output reg               	octrl_cmd,
	output reg						prg_ch_cmd,
	output reg						pitch_cmd,
	output reg [7:0]				octrl,
	output reg [7:0]				octrl_data,
	output reg [7:0]				prg_ch_data,
// memory controller
	output reg						data_ready,
	output							read_write,
	output reg						sysex_data_patch_send,
	output [6:0]					adr,
	inout  [7:0]					data,
	output [6:0]				dec_sel_bus,
// status data
	output reg [V_WIDTH:0]		active_keys

);

parameter VOICES = 8;
parameter V_WIDTH = 3; 

// ----- Pack / Unpack macros   ---- //

`define PACK_BIT_ARRAY(PK_LEN,PK_SRC,PK_DEST) generate genvar pk_idx; for(pk_idx=0;pk_idx<(PK_LEN);pk_idx = pk_idx+1)begin : pack_bit_array assign keys_on[pk_idx] = key_on[pk_idx]; end endgenerate
 // -----        End Macros Def     ---- //
 `PACK_BIT_ARRAY(VOICES,key_on,keys_on)

// -----        End Macros     ---- //

reg   key_on[VOICES-1:0];

reg   [7:0]key_val[VOICES-1:0];

//////////////key1 & key2 Assign///////////
reg [3:0] cur_midi_ch;
reg byteready_r, byteready_r_dly[2:0],is_data_byte_r, syx_cmd, syx_cmd_r[1:0];
reg [7:0]cur_status_r;
reg [7:0]midi_bytes,addr_cnt;
reg signed[7:0]databyte;
reg voice_free_r[VOICES-1:0];
reg reg_voice_free [VOICES-1:0];
reg [V_WIDTH:0]cur_slot;

    reg [V_WIDTH-1:0]first_free_voice;
    reg [V_WIDTH-1:0]first_on;
    reg [V_WIDTH-1:0] on_slot[VOICES-1:0];
    reg [V_WIDTH-1:0] off_slot[VOICES-1:0];
    reg free_voice_found;
    reg [7:0]vel_off;
    reg [7:0]cur_note;
    reg [V_WIDTH-1:0]slot_off;
    reg [2:0]	bank_adr_s, bank_adr_l;
	
	wire [2:0] bank_adr;
    
    wire [5:0] dec_sel;
    
    assign dec_sel_bus = {write,read,dec_sel[5],dec_sel[3:0]};
	
	reg Educational_Use,sysex_data_bank_load,sysex_data_patch_load,sysex_ctrl_data,sysex_data_patch_send_end,auto_syx_cmd;

	assign bank_adr = (sysex_data_patch_send) ? bank_adr_s : bank_adr_l;
	
	reg [7:0 ] 	data_out, adr_s;
	
	reg [6:0] 	adr_l;
	
	reg midi_send_byte_req[3];
	
	reg [3:0]	midi_cha_num, sysex_type;
	
	assign adr = (sysex_data_patch_send) ? adr_s : adr_l;
	
	assign midi_send_byte = (midi_send_byte_req[1] && ~midi_send_byte_req[2]) ? 1'b1 : 1'b0;
	
	assign data = write_dataenable ? data_out : 8'bz;
	
	wire write_dataenable;
	
	assign write = (read_write && ~sysex_data_patch_send) ? 1'b1 : 1'b0;
	assign read = (read_write && sysex_data_patch_send) ? 1'b1 : 1'b0;

    integer free_voices_found;
 //   integer note_found;
    integer i0;
    integer i1;
    integer i2;
    integer i3;
    integer i4;
    integer i5;
    integer i6;
    integer i7;
    integer i8;

wire is_cur_midi_ch=(
    (cur_status_r[3:0]==cur_midi_ch)?1'b1:1'b0);

wire is_st_note_on=(
    (cur_status_r[7:4]==4'h9)?1'b1:1'b0);

    wire is_st_note_off=(
        (cur_status_r[7:4]==4'h8)?1'b1:1'b0);

    wire is_st_ctrl=(
        (cur_status_r[7:4]==4'hb)?1'b1:1'b0);

    wire is_st_prg_change=(
        (cur_status_r[7:4]==4'hc)?1'b1:1'b0);

    wire is_st_pitch=(
        (cur_status_r[7:4]==4'he)?1'b1:1'b0);

    wire is_st_sysex=(
        (cur_status_r[7:4]==4'hf)?1'b1:1'b0);

    wire is_data_byte=(
     (midi_bytes[0]==1'b1)?1'b1:1'b0);

    wire is_velocity=(
     (midi_bytes[0]==1'b0 && midi_bytes != 8'h0)?1'b1:1'b0);

     wire is_allnotesoff=(
     (databyte==8'h7b)?1'b1:1'b0);

     address_decoder adr_dec_inst (
        .CLOCK_25 ( CLOCK_25 ),
        .reset_reg_N ( reset_reg_N ),
        .data_ready ( data_ready ),
        .dec_addr ( bank_adr ),
        .read_write  ( read_write  ),
		.write_dataenable ( write_dataenable ),
        .dec_sel ( dec_sel )
     );


    always @(posedge CLOCK_25)begin
       for(i0=0; i0 < VOICES ; i0=i0+1) begin
				reg_voice_free[i0] <= voice_free[i0];
           voice_free_r[i0] <= reg_voice_free[i0]; 
        end
    end

    always @(posedge CLOCK_25)begin
        syx_cmd_r[0] <= syx_cmd;
        syx_cmd_r[1] <= syx_cmd_r[0];
        data_ready   <= (syx_cmd_r[0] & ~syx_cmd_r[1]) | ((sysex_data_patch_send | auto_syx_cmd) & (byteready_r_dly[1] & ~byteready_r_dly[2]));
    end

    always @(negedge reset_reg_N or posedge CLOCK_25)begin
        if (!reset_reg_N) begin
        end
        else begin
            is_data_byte_r <= is_data_byte;
            cur_midi_ch <= midi_ch;
            byteready_r <= (is_cur_midi_ch | is_st_sysex) ? (byteready | midi_send_byte) : 1'b0 ;
			byteready_r_dly[0] <= byteready_r;
			byteready_r_dly[1] <= byteready_r_dly[0];
			byteready_r_dly[2] <= byteready_r_dly[1];
            cur_status_r <= cur_status;
            midi_bytes <= (is_cur_midi_ch | is_st_sysex) ? midibyte_nr : 8'h00;
            databyte <= (is_cur_midi_ch | is_st_sysex) ? midibyte : 8'h00;
			midi_send_byte_req[0] <= ( sysex_data_patch_send && byteready_r ) ? 1'b1 : 1'b0;
			midi_send_byte_req[1] <= midi_send_byte_req[0];
			midi_send_byte_req[2] <= midi_send_byte_req[1];
       end
    end

    always @(negedge reset_reg_N or posedge is_data_byte_r)begin
        if (!reset_reg_N) begin
            free_voice_found = 1'b1;
            first_free_voice = 0;
        end
        else begin
            for(i3=VOICES-1,free_voices_found=0; i3 >= 0 ; i3=i3-1) begin
                free_voice_found = 1'b0;
                if(voice_free_r[i3])begin
                    free_voices_found = free_voices_found +1;
                    first_free_voice = i3;
                end
                if (free_voices_found > 0) free_voice_found = 1'b1;
            end
        end
    end
    
    always @(negedge reset_reg_N or negedge byteready_r) begin
        if (!reset_reg_N) begin // init values 
            active_keys <= 0;
            cur_key_val <= 8'hff;
            cur_vel_on <= 0;
            cur_vel_off <= 0;
           for(i5=0;i5<VOICES-1;i5=i5+1)begin
                key_on[i5] <= 1'b0;
                cur_key_adr <= i5;
                key_val[i5] <= 8'hff;
                on_slot[i5] <= 0;
                off_slot[i5] <= 0;
            end
            slot_off<=0;
            cur_note<=0;
            cur_slot<=0;
            active_keys<=0;
        end
        else begin
            note_on <= 1'b0;
            if(is_st_note_on)begin // Note on omni
                if(is_data_byte)begin
                    if(active_keys >= VOICES) begin
                        active_keys <= active_keys-1'b1;
                        key_on[on_slot[0]]<=1'b0;
                        cur_key_adr <= on_slot[0];
                        cur_key_val <=8'hff;
                        key_val[on_slot[0]]<=8'hff;
                        slot_off<=on_slot[0];
                        cur_slot<=on_slot[0];
                    end 
					else if(free_voice_found  == 1'b0)begin
                        cur_slot <= off_slot[active_keys];
                    end
                    else begin
                        cur_slot<=first_free_voice;
                    end
                    for(i6=VOICES-1;i6>0;i6=i6-1)begin
                        on_slot[i6-1]<=on_slot[i6];
                    end
                    cur_note<=databyte;
                end 
				else if(is_velocity)begin
                    active_keys <= active_keys+1'b1;
                    key_on[cur_slot]<=1'b1;
                    cur_key_adr <= cur_slot;
                    cur_key_val <= cur_note;
                    cur_vel_on <= databyte;
                    note_on <= 1'b1;
                    key_val[cur_slot]<=cur_note;
                    on_slot[VOICES-1] <= cur_slot;
                end
			end 
 			else if(is_st_ctrl)begin // Control Change omni
                if(is_data_byte)begin
                    if(is_allnotesoff)begin
                        for(i4=0;i4<VOICES;i4=i4+1)begin
                            key_on[i4]<=1'b0;
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
                        if(databyte==key_val[i2])begin
                            active_keys <= active_keys-1'b1;
                            slot_off<=i2;
                            key_on[i2]<=1'b0;
                            cur_key_adr <= i2;
                            cur_key_val <= 8'hff;
                            key_val[i2] <= 8'hff;
                        end
                    end
                end 
				else if(is_velocity )begin
					if(key_val[slot_off] == 8'hff)begin
						cur_vel_off<=databyte;
						off_slot[VOICES-1]<=slot_off;
						for(i7=VOICES-1;i7>0;i7=i7-1)begin
							if(i7>active_keys)begin
                                off_slot[i7-1] <= off_slot[i7];
                            end
						end
                    end
                    if(active_keys == 0)begin
                        for(i8=0;i8<VOICES;i8=i8+1)begin
                            key_on[i8]<=1'b0;
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

    
    always @(negedge reset_reg_N or negedge byteready_r) begin
        if (!reset_reg_N) begin // init values 
            prg_ch_cmd <=1'b0;
        end
        else begin
            prg_ch_cmd <=1'b0;
            if(is_st_prg_change)begin // Control Change omni
                    prg_ch_cmd <= 1'b1;
                if(is_data_byte)begin
                    prg_ch_data<=databyte;
                    prg_ch_cmd <= 1'b0;
                end
            end 
        end
    end

    
    always @(negedge reset_reg_N or negedge byteready_r) begin
        if (!reset_reg_N) begin // init values 
            syx_cmd <= 1'b0; sysex_data_patch_send <= 1'b0; sysex_data_bank_load <= 1'b0;
			sysex_data_patch_load <= 1'b0; sysex_ctrl_data <= 1'b0; auto_syx_cmd <= 1'b0; 
        end
		else if (!byteready_r)begin
			if (sysex_data_patch_send_end && addr_cnt == (16*14+4)) begin  sysex_data_patch_send <= 1'b0; end
            syx_cmd <= 1'b0;
            if(is_st_sysex)begin // Sysex
				if (midi_bytes == 8'd1) begin
					Educational_Use <= (databyte == 8'h7D) ? 1'b1 : 1'b0; 
				end
				else if (Educational_Use) begin
					if (midi_bytes == 8'd2)begin // sysex_type <= databyte[7:4]; midi_cha_num <= databyte[3:0]; end
						if (databyte[3:0] == midi_ch) begin
							case (databyte[7:4])
								4'h1 : sysex_ctrl_data <= 1'b1;
								4'h2 : sysex_data_bank_load <= 1'b1; 
								4'h3 : sysex_data_patch_send <= 1'b1;
								4'h7 : begin sysex_data_patch_load <= 1'b1; bank_adr_l <= 3'b0; adr_l <= 7'b0; auto_syx_cmd <= 1'b1; end // data_out <= databyte; end
							endcase
						end
					end
					if(sysex_data_patch_load) begin
						if(databyte != 8'hf7)begin
							data_out  <= databyte;
							if (midi_bytes >= 8'd4 && midi_bytes < 16*4+8'd3) begin adr_l <= adr_l + 7'b1; end // data_out <= databyte; end
							if (midi_bytes == (16*4 + 8'd3))begin bank_adr_l <= 1; adr_l <= 7'b0; end //  data_out <= databyte; end
							else if (midi_bytes >= (16*4 + 8'd3) && midi_bytes < (16*8 + 8'd3)) begin adr_l <= adr_l + 7'b1; end // data_out <= databyte; end
							if (midi_bytes == (16*8 + 8'd3))begin bank_adr_l <= 2; adr_l <= 7'b0; end // data_out <= databyte; end
							else if (midi_bytes >= (16*8 + 8'd3) && midi_bytes < (16*12 + 8'd3)) begin adr_l <= adr_l + 7'b1; end // data_out <= databyte; end
							if (midi_bytes == (16*12 + 8'd3))begin bank_adr_l <= 5; adr_l <= 7'b0; end // data_out <= databyte; end
							else if (midi_bytes >= (16*12 + 8'd3) && midi_bytes < (16*14 + 8'd3)) begin adr_l <= adr_l + 7'b1; end // data_out <= databyte; end
						end
						else begin sysex_data_patch_load <= 1'b0; auto_syx_cmd <= 1'b0; end
					end
					if(sysex_data_bank_load) begin
						if(databyte != 8'hf7)begin
							data_out <= databyte;
							if (midi_bytes == 8'd3)begin adr_l <= 7'b0; bank_adr_l  <= databyte[2:0]; auto_syx_cmd <= 1'b1; end
							if (midi_bytes >= 8'd5 )begin adr_l <= adr_l + 7'b1; end
						end
						else begin sysex_data_bank_load <= 1'b0; auto_syx_cmd <= 1'b0; end
					end
					if(sysex_ctrl_data) begin
						case (midi_bytes)
							8'd3:bank_adr_l  <= databyte[2:0];
							8'd4:adr_l  <= databyte[6:0];
							8'd5:data_out  <= databyte;
							8'd6:if (midi_bytes == 6 && databyte == 8'hf7)begin syx_cmd <= 1'b1; sysex_ctrl_data <= 1'b0; end
							default:;
						endcase
					end
				end
			end
		end
	end

	always @(negedge reset_reg_N or negedge midi_out_ready ) begin
		if (!reset_reg_N) begin
			addr_cnt <= 8'b0; sysex_data_patch_send_end <= 1'b0;
		end
		else if (!midi_out_ready) begin
			if (sysex_data_patch_send) begin
				addr_cnt <= addr_cnt+8'h01; sysex_data_patch_send_end <= 1'b0;
				if (addr_cnt == 8'b0) begin	midi_out_data <= 8'hF0;	adr_s <= 8'b0; end
				else if(addr_cnt == 8'd1) midi_out_data <= 8'h7D;
				else if(addr_cnt == 8'd2)begin midi_out_data <= {4'h7,midi_ch}; adr_s <= 8'h0; bank_adr_s <= 3'h0; end
				else if(addr_cnt >= 8'd3 && addr_cnt < (16*14+3))begin 
					adr_s <= adr_s + 1'b1;	midi_out_data <= data; 
					if (addr_cnt == (16*4+2))begin adr_s <= 8'h0; bank_adr_s <= 3'h1; end
					if (addr_cnt == (16*8+2))begin adr_s <= 8'h0; bank_adr_s <= 3'h2; end
					if (addr_cnt == (16*12+2))begin adr_s <= 8'h0; bank_adr_s <= 3'h5; end
				end
				else if (addr_cnt == (16*14+3)) begin midi_out_data <= 8'hF7; sysex_data_patch_send_end <= 1'b1; end			
			end
			else if (addr_cnt == (16*14+4)) begin midi_out_data <= 8'hFF; sysex_data_patch_send_end <= 1'b0; addr_cnt <= 8'b0; end
		end
	end

	    
    always @(negedge reset_reg_N or negedge byteready_r) begin
        if (!reset_reg_N) begin // init values 
            pitch_cmd <= 1'b0;
        end
        else begin
            pitch_cmd <= 1'b0;
            if(is_st_pitch)begin // Control Change omni
                if(is_data_byte)begin
                    octrl<=databyte;
                    pitch_cmd<=1'b1;
                end 
				else if(is_velocity)begin
                    octrl_data<=databyte;
                    pitch_cmd<=1'b0;
                end
            end 
        end
    end
		
endmodule
