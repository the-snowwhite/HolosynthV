module sysex_func (
    input wire          reg_clk,
    input wire          reset_reg_N,
    input wire          write_dataenable,
    inout wire  [7:0]   sysex_data_out,
    input wire  [7:0]   synth_data_out,
    input wire  [3:0]   midi_ch,
    input wire          is_st_sysex,
    input wire          midi_out_ready,
    input wire  [7:0]   midi_bytes,
    input wire  [7:0]   databyte,
    input wire          trig_seq_f,
    output  reg         syx_cmd,
    output  reg         dec_sysex_data_patch_send,
    output  reg         auto_syx_cmd,
    output reg  [7:0]   midi_out_data,
    output wire [2:0]   bank_adr,
    output wire [6:0]   dec_addr
);

    reg [6:0]   adr_l;
    reg [2:0]   bank_adr_s, bank_adr_l;
    reg [7:0]   sysex_regdata_out,adr_s;

    reg [7:0]addr_cnt;

    reg Educational_Use,sysex_data_bank_load,sysex_data_patch_load,sysex_ctrl_data,sysex_data_patch_send_end;

    assign bank_adr = (dec_sysex_data_patch_send) ? bank_adr_s : bank_adr_l;
    assign dec_addr = (dec_sysex_data_patch_send) ? adr_s : adr_l;
	assign sysex_data_out = write_dataenable ? sysex_regdata_out : 8'bz;

    always @(negedge reset_reg_N or posedge reg_clk) begin
        if (!reset_reg_N) begin // init values
            syx_cmd <= 1'b0; dec_sysex_data_patch_send <= 1'b0; sysex_data_bank_load <= 1'b0;
            sysex_data_patch_load <= 1'b0; sysex_ctrl_data <= 1'b0; auto_syx_cmd <= 1'b0;
        end
        else if (trig_seq_f)begin
            if (sysex_data_patch_send_end && addr_cnt == (16*14+4)) begin  dec_sysex_data_patch_send <= 1'b0; end
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
                                4'h3 : dec_sysex_data_patch_send <= 1'b1;
                                4'h7 : begin sysex_data_patch_load <= 1'b1; bank_adr_l <= 3'b0; adr_l <= 7'b0; auto_syx_cmd <= 1'b1; end // sysex_regdata_out <= databyte; end
                            endcase
                        end
                    end
                    if(sysex_data_patch_load) begin
                        if(databyte != 8'hf7)begin
                            sysex_regdata_out  <= databyte;
                            if (midi_bytes >= 8'd4 && midi_bytes < 16*4+8'd3) begin adr_l <= adr_l + 7'b1; end // sysex_regdata_out <= databyte; end
                            if (midi_bytes == (16*4 + 8'd3))begin bank_adr_l <= 1; adr_l <= 7'b0; end //  sysex_regdata_out <= databyte; end
                            else if (midi_bytes >= (16*4 + 8'd3) && midi_bytes < (16*8 + 8'd3)) begin adr_l <= adr_l + 7'b1; end // sysex_regdata_out <= databyte; end
                            if (midi_bytes == (16*8 + 8'd3))begin bank_adr_l <= 2; adr_l <= 7'b0; end // sysex_regdata_out <= databyte; end
                            else if (midi_bytes >= (16*8 + 8'd3) && midi_bytes < (16*12 + 8'd3)) begin adr_l <= adr_l + 7'b1; end // sysex_regdata_out <= databyte; end
                            if (midi_bytes == (16*12 + 8'd3))begin bank_adr_l <= 5; adr_l <= 7'b0; end // sysex_regdata_out <= databyte; end
                            else if (midi_bytes >= (16*12 + 8'd3) && midi_bytes < (16*14 + 8'd3)) begin adr_l <= adr_l + 7'b1; end // sysex_regdata_out <= databyte; end
                        end
                        else begin sysex_data_patch_load <= 1'b0; auto_syx_cmd <= 1'b0; end
                    end
                    if(sysex_data_bank_load) begin
                        if(databyte != 8'hf7)begin
                            sysex_regdata_out <= databyte;
                            if (midi_bytes == 8'd3)begin adr_l <= 7'b0; bank_adr_l  <= databyte[2:0]; auto_syx_cmd <= 1'b1; end
                            if (midi_bytes >= 8'd5 )begin adr_l <= adr_l + 7'b1; end
                        end
                        else begin sysex_data_bank_load <= 1'b0; auto_syx_cmd <= 1'b0; end
                    end
                    if(sysex_ctrl_data) begin
                        case (midi_bytes)
                            8'd3:bank_adr_l  <= databyte[2:0];
                            8'd4:adr_l  <= databyte[6:0];
                            8'd5:sysex_regdata_out  <= databyte;
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
            if (dec_sysex_data_patch_send) begin
                addr_cnt <= addr_cnt+8'h01; sysex_data_patch_send_end <= 1'b0;
                if (addr_cnt == 8'b0) begin    midi_out_data <= 8'hF0;    adr_s <= 8'b0; end
                else if(addr_cnt == 8'd1) midi_out_data <= 8'h7D;
                else if(addr_cnt == 8'd2)begin midi_out_data <= {4'h7,midi_ch}; adr_s <= 8'h0; bank_adr_s <= 3'h0; end
                else if(addr_cnt >= 8'd3 && addr_cnt < (16*14+3))begin
                    adr_s <= adr_s + 1'b1;    midi_out_data <= synth_data_out;
                    if (addr_cnt == (16*4+2))begin adr_s <= 8'h0; bank_adr_s <= 3'h1; end
                    if (addr_cnt == (16*8+2))begin adr_s <= 8'h0; bank_adr_s <= 3'h2; end
                    if (addr_cnt == (16*12+2))begin adr_s <= 8'h0; bank_adr_s <= 3'h5; end
                end
                else if (addr_cnt == (16*14+3)) begin midi_out_data <= 8'hF7; sysex_data_patch_send_end <= 1'b1; end
            end
            else if (addr_cnt == (16*14+4)) begin midi_out_data <= 8'hFF; sysex_data_patch_send_end <= 1'b0; addr_cnt <= 8'b0; end
        end
    end

endmodule
