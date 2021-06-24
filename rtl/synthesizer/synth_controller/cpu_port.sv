module cpu_port #(parameter addr = 0)(
    input wire          reg_clk,
    input wire [2:0]    socmidi_addr,
    input wire [7:0]    socmidi_data_in,
    input wire          socmidi_write,
    output reg          byteready_c,
    output reg [7:0]    cur_status_c,
    output reg [7:0]    midibyte_nr_c,
    output reg [7:0]    midi_in_data_c
);

    reg socmidi_write_dly;

       initial begin
          socmidi_write_dly = 1'b0;
          byteready_c = 1'b0;
          midibyte_nr_c = 8'h00;
          cur_status_c = 8'h00;
          midi_in_data_c = 8'h00;
       end

    
    always @(posedge reg_clk)begin
        socmidi_write_dly <= socmidi_write;
        if (socmidi_addr == addr) begin
            byteready_c <= (!socmidi_write && socmidi_write_dly) ? 1'b1 : 1'b0;            
        end
    end
    
// DataByte counter -- Status byte logger //
    always @(posedge reg_clk)begin
        if (socmidi_write && socmidi_addr == addr) begin
            midi_in_data_c <= socmidi_data_in;
            if((socmidi_data_in & 8'h80) && (socmidi_data_in != 8'hf7))begin
                midibyte_nr_c <= 0;
                cur_status_c <= socmidi_data_in;
            end
            else begin midibyte_nr_c <= midibyte_nr_c+8'h01; cur_status_c <= cur_status_c; end
        end
    end
endmodule
