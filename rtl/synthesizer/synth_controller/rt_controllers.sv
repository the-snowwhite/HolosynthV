module rt_controllers #(
parameter VOICES = 8,// Set in toplevel
parameter V_OSC = 4, // oscs per Voice  // Set in toplevel
parameter V_WIDTH = 3,
parameter O_WIDTH = 2,
parameter B_WIDTH = O_WIDTH+3
) (
    input wire          reg_clk,
//@name from synth_controller
    input wire  [7:0]   octrl,
    input wire  [7:0]   octrl_data,
    input wire          pitch_cmd,
    output reg  [13:0]  pitch_val
);

/////////////   Fetch Controllers           /////////////
//      Internal             //
    reg  pitch_cmd_dly;
    reg [6:0]pitch_lsb;
    wire pitch_cmd_r;
    wire pitch_cmd_f;

    initial begin
        pitch_val <= 8191;
    end

    assign pitch_cmd_r = (pitch_cmd && !pitch_cmd_dly) ? 1'b1 : 1'b0;
    assign pitch_cmd_f = (!pitch_cmd && pitch_cmd_dly) ? 1'b1 : 1'b0;

    always @(posedge reg_clk)begin
        pitch_cmd_dly <= pitch_cmd;
        if (pitch_cmd_r) begin pitch_lsb <= octrl[6:0]; end
        if (pitch_cmd_f) begin pitch_val <= {octrl_data[6:0],pitch_lsb}; end
    end


endmodule
