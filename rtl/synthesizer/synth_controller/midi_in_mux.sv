module midi_in_mux (
	input wire          reset_reg_N,
	input wire          reg_clk,
    input wire          sel,
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

    always @(negedge reset_reg_N or posedge reg_clk) begin
        if(!reset_reg_N) begin
            byteready    <= 1'b0;
            cur_status   <= 8'h00;
            midibyte_nr  <= 8'h00;
            midi_in_data <= 8'h00;
        end
        else begin
            byteready    <= sel ? byteready_u : byteready_c;
            cur_status   <= sel ? cur_status_u : cur_status_c;
            midibyte_nr  <= sel ? midibyte_nr_u : midibyte_nr_c;
            midi_in_data <= sel ? midi_in_data_u : midi_in_data_c;
        end
    end

endmodule
