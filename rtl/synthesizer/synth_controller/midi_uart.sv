module MIDI_UART(
    input wire          reset_reg_N,
    input wire          reg_clk,
// receiver
    input wire          midi_rxd,
// data out
    output	reg         byteready_u,
    output	reg [7:0]   cur_status_u,
    output	reg [7:0]   midibyte_nr_u,
    output	reg [7:0]   midi_in_data_u,
// Transmitter
    input wire          midi_send_byte,
    input wire  [7:0]   midi_out_data,
    output	reg         midi_txd,
    output	reg         midi_out_ready
);
    reg midi_dat;
    reg [1:0]md;
    wire md_ok;
    assign md_ok = (~midi_rxd && ~md[0] && ~md[1]) ? 1'b0 : 1'b1;

// -------------- Midi receiver  ------------- //
    always @(posedge reg_clk)begin
        md[0] <= midi_rxd;
        md[1] <= md[0];
        midi_dat <= md_ok;
end

// comment out for debug
    reg startbit_d;
    reg [4:0]revcnt;
    reg [10:0] counter;
//    reg midi_clk;
    reg reset_mod_cnt;

//// Clock gen ////

    reg carry;
    reg [2:0]reset_cnt;
    reg [7:0]samplebyte, out_buff;

    reg [4:0] out_cnt;

    reg transmit;
    wire byte_end;
    assign byte_end = (revcnt[4:0]==18)? 1'b1 : 1'b0;

    reg[7:0]	cur_status_r;
    reg clk_enable;
/*
    always @(negedge reset_reg_N or posedge reg_clk)begin //! divide clock by 200
        if(!reset_reg_N)begin counter <= 10'h00; carry <=1'b0; end
        else if (reg_clk)
            if(reset_mod_cnt)begin carry <= 1'b0; counter <= 10'h00;end
            else if(counter == 10'd800)begin carry <= 1'b1; counter <= 10'h00;end
            else begin counter <= counter + 10'h1;carry <= 1'b0;end
    end
    always @(negedge reset_reg_N or posedge reg_clk)begin//! divide by 2 more so we get 62500 hz midi clock
        if(!reset_reg_N) midi_clk <= 1'b0;
        else if (reset_mod_cnt) midi_clk <= 1'b0;
        else if(carry)midi_clk <= ~(midi_clk);
    end
*/
    always@(posedge reg_clk or negedge reset_reg_N) begin
        if (!reset_reg_N)begin 
            counter <=11'h0; 
        end else begin
            if (counter == 11'd1600) begin
                clk_enable <= 1'b1; counter <=11'h0;
            end
            else begin
                clk_enable <= 1'b0;counter <= counter +11'h1;
            end
        end
    end
        
    always @(posedge reg_clk or negedge reset_reg_N)begin
        if (!reset_reg_N)begin startbit_d <= 0; cur_status_u <= 0; end
        else begin
            cur_status_u <= cur_status_r;
            if(revcnt>=18) startbit_d <= 0;
            else if (!startbit_d)begin
                if(midi_dat) startbit_d <= 0;
                else startbit_d <= 1;
            end
        end
    end
    
// Clk gen reset circuit /////
    always @(posedge reg_clk or negedge reset_reg_N)begin
        if(!reset_reg_N)begin reset_cnt <= 0;reset_mod_cnt <= 0;end
        else begin
            if (!startbit_d)
                reset_cnt <= 0;
            else if(reset_cnt <= 1 && startbit_d)begin
                reset_cnt <= reset_cnt+1'b1;
                reset_mod_cnt <= 1;
            end
            else reset_mod_cnt <= 0;
        end
    end
    
///// sequence generator /////

    always @(posedge reg_clk or negedge reset_reg_N)begin
        if(!reset_reg_N) revcnt <= 0;
        else if (clk_enable) begin
            if (!startbit_d) revcnt <= 0;
            else if (revcnt >= 18) revcnt <= 0;
            else revcnt <= revcnt+1'b1;
        end
    end

// Serial data in

    always @(negedge reg_clk or negedge reset_reg_N) begin
        if(!reset_reg_N)begin samplebyte <= 0; midi_in_data_u <= 0;end
        else if (clk_enable) begin
            case (revcnt[4:0])
            5'd3:samplebyte[0] <= midi_dat;
            5'd5:samplebyte[1] <= midi_dat;
            5'd7:samplebyte[2] <= midi_dat;
            5'd9:samplebyte[3] <= midi_dat;
            5'd11:samplebyte[4] <= midi_dat;
            5'd13:samplebyte[5] <= midi_dat;
            5'd15:samplebyte[6] <= midi_dat;
            5'd17:samplebyte[7] <= midi_dat;
            5'd18:midi_in_data_u <= samplebyte;
            default:;
            endcase
        end
    end

    always @(negedge reg_clk or negedge reset_reg_N) begin
        if(!reset_reg_N) byteready_u <= 0;
        else if (clk_enable) begin
            byteready_u <= (byte_end || out_cnt == 19) ?  1'b1 : 1'b0;
        end
    end

// DataByte counter -- Status byte logger //
    always @(negedge startbit_d or negedge reset_reg_N)begin
        if(!reset_reg_N)begin midibyte_nr_u <= 0; cur_status_r <= 0;end
        else begin
            if((samplebyte & 8'h80) && (samplebyte != 8'hf7))begin
//            if(samplebyte & 8'h80)begin
                midibyte_nr_u <= 0;
                cur_status_r <= samplebyte;
            end
            else midibyte_nr_u <= midibyte_nr_u+1'b1;
        end
    end

// -------------- Midi transmitter ----------- //
    always @(posedge reg_clk or negedge reset_reg_N)begin
        if(!reset_reg_N) begin out_cnt <= 0; midi_out_ready <= 1'b1; midi_txd <=1'b0; out_buff <= 8'h00; end
        else if (clk_enable) begin
            if (!transmit) begin out_cnt <= 0; midi_out_ready <= 1'b1;  midi_txd <= 1'b1; end
            else if (out_cnt == 18)begin out_cnt <= out_cnt + 1'b1; midi_out_ready <= 1'b1; midi_txd <= 1'b1; end
            else if (out_cnt >= 19)begin out_cnt <= 0; midi_out_ready <= 1'b1; end
            else begin
                midi_out_ready <= 1'b0;
                out_cnt <=out_cnt+1'b1;
                if (out_cnt == 1)begin out_buff <= midi_out_data; end
                if (out_cnt >= 2) midi_txd <= out_buff[((out_cnt - 2) >> 1)];
                else midi_txd <= 1'b0;
            end
        end
    end

    always @(posedge midi_send_byte or posedge midi_out_ready) begin
        if(midi_send_byte)begin
            transmit <= 1'b1;
        end
        else if (midi_out_ready) transmit <= 1'b0;
    end

endmodule
