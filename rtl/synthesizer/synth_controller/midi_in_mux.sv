module midi_in_mux (
//	input wire          reset_reg_N,
	input wire          reg_clk,
    input wire  [4:0]   cur_midi_ch,
    input wire          byteready_u,
    input wire  [7:0]   cur_status_u,
    input wire  [7:0]   midibyte_nr_u,
    input wire  [7:0]   midi_in_data_u,
    input wire          byteready_c,
    input wire  [7:0]   cur_status_c,
    input wire  [7:0]   midibyte_nr_c,
    input wire  [7:0]   midi_in_data_c,
	output reg          byteready,
	output reg  [7:0]   cur_status,
	output reg  [7:0]   midibyte_nr,
	output reg  [7:0]   midi_in_data
);
    
    wire uart_usb_sel;
    
    assign uart_usb_sel = cur_midi_ch[4];
    
    initial begin
        byteready    = 1'b0;
        cur_status   = 8'h00;
        midibyte_nr  = 8'h00;
        midi_in_data = 8'h00;
    end

    always @(posedge reg_clk) begin
        if (uart_usb_sel) begin
            byteready    <= byteready_c;
            cur_status   <= cur_status_c;
            midibyte_nr  <= midibyte_nr_c;
            midi_in_data <= midi_in_data_c;
        end
        else begin
            byteready    <= byteready_u;
            cur_status   <= cur_status_u;
            midibyte_nr  <= midibyte_nr_u;
            midi_in_data <= midi_in_data_u;
        end
    end

endmodule
