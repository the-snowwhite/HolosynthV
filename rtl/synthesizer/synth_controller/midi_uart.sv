module MIDI_UART #(
parameter invert_rxd = 0
) (
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

    
    `define c_width 7
    reg midi_dat;
    reg [4:0]md;
    wire md_ok;

// comment out for debug
    reg startbit_d;
    reg [3:0]revcnt;
    reg [`c_width-1:0] counter;
    reg midi_clk, midi_clk_tick;
    
    reg         byteready;
    reg [7:0]   cur_status;
    reg [7:0]   midibyte_nr;
    reg [7:0]   midi_in_data;
    reg neg_edge_detected;

//// Clock gen ////

    reg carry;
    reg [7:0]samplebyte, out_buff;
    reg [2:0] clk_div_dly;
    reg [2:0] clk_div_8;
    reg [4:0] out_cnt;
    reg sampling, sampling_dly;
    reg take_sample, sample_rxd;
    reg transmit;
    
    always @(posedge reg_clk) begin
        byteready_u <= byteready;
        cur_status_u <= cur_status;
        midibyte_nr_u <= midibyte_nr;
        midi_in_data_u <= midi_in_data;
        neg_edge_detected <= (!md_ok && midi_dat) ? 1'b1 : 1'b0;
    end
    
      generate
       if (invert_rxd) begin: rxd_inverted
            assign md_ok = (midi_rxd && md[0] && md[1] && md[2] && md[3] && md[4]) ? 1'b0 : 1'b1;
       end else begin: rxd_noninverted
            assign md_ok = (~midi_rxd && ~md[0] && ~md[1] && ~md[2] && ~md[3] && ~md[4]) ? 1'b0 : 1'b1;
       end
    endgenerate
 


// -------------- Midi receiver  ------------- //
    always @(posedge reg_clk)begin
        md[0] <= midi_rxd;
        md[1] <= md[0];
        md[2] <= md[1];
        md[3] <= md[2];
        md[4] <= md[3];
        midi_dat <= md_ok;
    end

// -------------- Midi CLOCK  ------------- //
    always @(posedge reg_clk or negedge reset_reg_N)begin //! divide clock by 200
        if(!reset_reg_N)begin counter <= 'h00; carry <=1'b0; end
        else if (reg_clk)
            if(counter == `c_width'd100)begin carry <= 1'b1; counter <= `c_width'h00;end
            else begin counter <= counter + `c_width'h01 ;carry <= 1'b0;end
    end
    always @(posedge reg_clk or negedge reset_reg_N)begin//! divide by 2 more so we get 62500 hz midi clock
        if(!reset_reg_N) midi_clk <= 1'b0;
        else if(carry)midi_clk <= ~(midi_clk);
        midi_clk_tick <= (carry && ~midi_clk) ? 1'b1 : 1'b0;
    end


    always @(posedge reg_clk or negedge reset_reg_N)begin
        if (!reset_reg_N) begin startbit_d <= 1'b0; clk_div_dly <= 3'h0; end
        else begin 
            if(neg_edge_detected && !sampling) begin
                sample_rxd <= 1'b1;
                clk_div_dly <= clk_div_dly + 3'h1;
                startbit_d <= 1'b0;
            end
            if (midi_clk_tick) begin
                if (sample_rxd == 1'b1) begin
                    if (midi_dat == 1'b0) begin
                        if (clk_div_dly == 3'h5) begin
                            sample_rxd <= 1'b0;
                            clk_div_dly <= 3'h0;
                            startbit_d <= 1'b1;
                        end
                        else begin
                            sample_rxd <= 1'b1;
                            clk_div_dly <= clk_div_dly + 3'h1;
                            startbit_d <= 1'b0;                        
                        end
                    end
                    else begin
                        sample_rxd <= 1'b0;
                        clk_div_dly <= 3'h0;
                        startbit_d <= 1'b1;
                    end
                end
                else begin 
                    clk_div_dly <= 3'h0;
                    startbit_d <= 1'b0;
                end
            end    
        end    
    end
    

    always @(posedge reg_clk or negedge reset_reg_N)begin
        if (!reset_reg_N)begin sampling <= 1'b0; end
        else begin 
            if (midi_clk_tick) begin
                if(startbit_d) sampling <= 1'b1;
            end
            if (byteready) sampling <= 1'b0;
        end
    end

///// sequence generator /////

    always @(posedge reg_clk or negedge reset_reg_N)begin
        if(!reset_reg_N) clk_div_8 <= 3'h0;
        else if (midi_clk_tick) begin
            if (sampling) begin
                if (clk_div_8 == 3'h7) begin take_sample <= 1'b1;clk_div_8 <= 3'h0; end
                else begin take_sample <= 1'b0; clk_div_8 <= clk_div_8 + 3'h1; end
            end
        end
    end

// Serial data in

    always @(posedge reg_clk or negedge reset_reg_N)begin
        if(!reset_reg_N) begin samplebyte <= 8'h00; revcnt <= 0; byteready <= 1'b0; midi_in_data <= 8'h00; end
        else if (midi_clk_tick) begin
            if (sampling) begin
                if (take_sample) begin 
                    if (revcnt == 3'd7) begin samplebyte <= 8'h00; revcnt <= 3'h0; byteready <= 1'b1; midi_in_data <= {midi_dat,samplebyte[6:0]}; end
                    else begin samplebyte[revcnt] <= midi_dat; revcnt <= revcnt+1'b1; byteready <= 1'b0; midi_in_data <= midi_in_data; end
                end
                else begin samplebyte <= samplebyte; revcnt <= revcnt; byteready <= 1'b0; midi_in_data <= midi_in_data; end
            end
            else begin samplebyte <= samplebyte; revcnt <= 3'h0; byteready <= 1'b0;  midi_in_data <= midi_in_data; end
        end
    end

// DataByte counter -- Status byte logger //
    always @(posedge reg_clk or negedge reset_reg_N)begin
        sampling_dly <= sampling;
        if(!reset_reg_N)begin midibyte_nr <= 0; cur_status <= 0;end
        else if (sampling_dly && !sampling)begin
            if(byteready && (midi_in_data & 8'h80) && (midi_in_data != 8'hf7))begin
                midibyte_nr <= 0;
                cur_status <= midi_in_data;
            end
            else begin midibyte_nr <= midibyte_nr+1'b1; cur_status <= cur_status; end
        end
    end

// -------------- Midi transmitter ----------- //
    always @(posedge reg_clk or negedge reset_reg_N)begin
        if(!reset_reg_N) begin out_cnt <= 0; midi_out_ready <= 1'b1; midi_txd <=1'b0; out_buff <= 8'h00; end
        else if (midi_clk_tick) begin
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
