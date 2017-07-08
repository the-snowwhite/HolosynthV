module cpu_port (
	input               reset_reg_N,
	input               CLOCK_25,
    input [2:0]         socmidi_addr,
    inout [7:0]         socmidi_data_out,
//    input               cpu_com_sel,
    input               socmidi_write,
	output reg          byteready,
	output reg  [7:0]	cur_status,
	output reg  [7:0]	midibyte_nr,
	output reg  [7:0]	midi_in_data
);

    reg [7:0]	cpu_midi_in_data;
    reg [2:0]   data_tap;

    
    always @(posedge CLOCK_25)begin
        data_tap[0] <= socmidi_write;
        data_tap[1] <= data_tap[0];
        data_tap[2] <= data_tap[1];
        byteready <= (!socmidi_write && ((data_tap[2] || data_tap[1]))) ? 1'b1 : 1'b0;
    end
    
// DataByte counter -- Status byte logger //
    always @(negedge data_tap[0]  or negedge reset_reg_N)begin
        if(!reset_reg_N)begin midibyte_nr <= 0; cur_status <= 0; midi_in_data <= 0; end
        else begin
            midi_in_data <= cpu_midi_in_data;
            if((cpu_midi_in_data & 8'h80) && (cpu_midi_in_data != 8'hf7))begin
                midibyte_nr <= 0;
                cur_status <= cpu_midi_in_data;
            end
            else begin midibyte_nr <= midibyte_nr+1'b1; cur_status <= cur_status; end
        end
    end

    always@(negedge reset_reg_N or negedge socmidi_write)begin
        if(!reset_reg_N) begin
            cpu_midi_in_data <= 8'h00;
        end else begin
            if(socmidi_addr == 0) begin
                cpu_midi_in_data <= socmidi_data_out;
            end
            else begin
                cpu_midi_in_data <= cpu_midi_in_data;
            end
        end
    end
    
endmodule