module rt_controllers #(
parameter VOICES = 8,// Set in toplevel
parameter V_OSC = 4, // oscs per Voice  // Set in toplevel
parameter V_WIDTH = 3,
parameter O_WIDTH = 2,
parameter B_WIDTH = O_WIDTH+3
) (
    input wire          reset_data_N,
    input wire          CLOCK_50,
//@name from synth_controller
    input wire  [7:0]   octrl,
    input wire  [7:0]   octrl_data,
    input wire          pitch_cmd,
    output reg  [13:0]  pitch_val
);

/////////////   Fetch Controllers           /////////////
//      Internal             //
    reg  pitch_cmd_rt;
    reg [6:0]pitch_lsb;


    always @(posedge CLOCK_50)begin
        pitch_cmd_rt <= pitch_cmd;
    end

    always @(posedge pitch_cmd_rt) begin   pitch_lsb <= octrl[6:0]; end

    always @(negedge reset_data_N or negedge pitch_cmd_rt)begin
        if (!reset_data_N)
            pitch_val <= 8191;
        else if(!pitch_cmd_rt) begin
            pitch_val <= {octrl_data[6:0],pitch_lsb};
        end
    end

endmodule
