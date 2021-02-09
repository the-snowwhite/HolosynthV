module cpu_port #(parameter address = 0)(
    input wire          reset_reg_N,
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

// DataByte counter -- Status byte logger //
    always @(negedge reset_reg_N or posedge reg_clk)begin
        if(!reset_reg_N)begin midibyte_nr_c <= 8'h00; cur_status_c <= 8'h00; midi_in_data_c <= 8'h00; byteready_c <= 1'b0; end
        else  if (socmidi_write && socmidi_addr == address) begin
            socmidi_write_dly <= socmidi_write;
            byteready_c <= (!socmidi_write && socmidi_write_dly) ? 1'b1 : 1'b0;
            midi_in_data_c <= socmidi_data_in;
            if((socmidi_data_in & 8'h80) && (socmidi_data_in != 8'hf7))begin
                midibyte_nr_c <= 0;
                cur_status_c <= socmidi_data_in;
            end
            else begin midibyte_nr_c <= midibyte_nr_c+8'h01; cur_status_c <= cur_status_c; end
        end
    end
endmodule
