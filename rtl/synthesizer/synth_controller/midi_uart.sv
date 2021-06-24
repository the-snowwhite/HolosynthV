module MIDI_UART #(
parameter Invert_rxd = 0,
parameter REG_CLK_FREQUENCY = 50_000_000
) (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 reg_clk CLK" *)
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

    localparam div_factor = (REG_CLK_FREQUENCY / 500000);
    localparam c_width = $clog2(div_factor);
    reg midi_dat;
    reg [11:0]md;
    wire md_ok;

// comment out for debug
    reg startbit_d;
    reg [3:0]revcnt;
    reg [c_width-1:0] counter;
    reg midi_clk, midi_clk_tick;
    
    reg         byteready, byteready_dly;
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
    reg midi_send_byte_dly, midi_out_ready_dly;
    
    always @(posedge reg_clk) begin
        byteready_u <= byteready_dly;
        cur_status_u <= cur_status;
        midibyte_nr_u <= midibyte_nr;
        midi_in_data_u <= midi_in_data;
        neg_edge_detected <= (!md_ok && midi_dat) ? 1'b1 : 1'b0;
    end
    
      generate
       if (Invert_rxd) begin: rxd_inverted
            assign md_ok = (midi_rxd && (md == 12'hFFF)) ? 1'b0 : 1'b1;
       end else begin: rxd_noninverted
            assign md_ok = (~midi_rxd && (md == 12'h000)) ? 1'b0 : 1'b1;
       end
    endgenerate
 


// -------------- Midi receiver  ------------- //
    always @(posedge reg_clk)begin
        md[0] <= midi_rxd; 
        md[2] <= md[1]; md[1] <= md[0];
        md[4] <= md[3]; md[3] <= md[2];
        md[6] <= md[5]; md[5] <= md[4];
        md[8] <= md[7]; md[7] <= md[5];
        md[10] <= md[9]; md[9] <= md[8];
        midi_dat <= md_ok; md[11] <= md[10];
    end

// -------------- Midi CLOCK  ------------- //

    initial begin
        counter = 'h00;
        carry =1'b0;
        midi_clk = 1'b0;
        startbit_d = 1'b0;
        clk_div_dly = 3'h0;    
        sampling = 1'b0;
        clk_div_8 = 3'h0;
        samplebyte = 8'h00;
        revcnt = 4'h0;
        byteready = 1'b0;
        byteready_dly = 1'b0;
        midi_in_data = 8'h00;
        midibyte_nr = 8'h00;
        cur_status = 8'h00;
        out_cnt = 0;
        midi_out_ready = 1'b1;
        midi_txd =1'b0;
        out_buff = 8'h00;
        
    end


    always @(posedge reg_clk)begin //! divide clock by 200
        if(counter == div_factor)begin carry <= 1'b1; counter <= 'h00;end
        else begin counter <= counter + 'h01 ;carry <= 1'b0;end
    end
    always @(posedge reg_clk)begin//! divide by 2 more so we get 62500 hz midi clock
        if(carry)midi_clk <= ~(midi_clk);
        midi_clk_tick <= (carry && ~midi_clk) ? 1'b1 : 1'b0;
    end


    always @(posedge reg_clk)begin
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
    

    always @(posedge reg_clk)begin
        if (midi_clk_tick) begin
            if(startbit_d) sampling <= 1'b1;
        end
        if (byteready) sampling <= 1'b0;
    end

///// sequence generator /////

    always @(posedge reg_clk)begin
        if (midi_clk_tick) begin
            if (sampling) begin
                if (clk_div_8 == 3'h7) begin take_sample <= 1'b1;clk_div_8 <= 3'h0; end
                else begin take_sample <= 1'b0; clk_div_8 <= clk_div_8 + 3'h1; end
            end
        end
    end

// Serial data in

    always @(posedge reg_clk)begin
        if (midi_clk_tick) begin
            byteready_dly <= byteready;
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
    always @(posedge reg_clk)begin
        sampling_dly <= sampling;
        if (sampling_dly && !sampling)begin
            if(byteready && (midi_in_data & 8'h80) && midi_in_data < 8'hf7)begin
                midibyte_nr <= 0;
                cur_status <= midi_in_data;
            end
            else begin midibyte_nr <= midibyte_nr+1; cur_status <= cur_status; end
        end
    end

// -------------- Midi transmitter ----------- //
    always @(posedge reg_clk)begin
        if (midi_clk_tick) begin
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

    always @(posedge reg_clk) begin
        midi_send_byte_dly <= midi_send_byte;
        midi_out_ready_dly <= midi_out_ready;
        if(midi_send_byte & ~midi_send_byte_dly)begin
            transmit <= 1'b1;
        end
        else if (midi_out_ready & ~midi_out_ready_dly) transmit <= 1'b0;
    end

endmodule
