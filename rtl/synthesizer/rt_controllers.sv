module rt_controllers #(
parameter VOICES = 8,// Set in toplevel
parameter V_OSC = 4, // oscs per Voice  // Set in toplevel
parameter V_WIDTH = 3,
parameter O_WIDTH = 2,
parameter B_WIDTH = O_WIDTH+3
) (
    input wire          reset_data_N,
    input wire          data_clk,
//@name from synth_controller
    input wire  [7:0]   ictrl,
    input wire  [7:0]   ictrl_data,
    input wire          pitch_cmd,
    output reg  [13:0]  pitch_val
);

/////////////   Fetch Controllers           /////////////
//      Internal             //
    reg  pitch_cmd_r;
    reg [6:0]pitch_lsb;


    always @(posedge data_clk)begin
        pitch_cmd_r <= pitch_cmd;
    end

    always @(posedge pitch_cmd_r)   pitch_lsb <= ictrl[6:0];

    always @(negedge reset_data_N or negedge pitch_cmd_r)begin
        if (!reset_data_N)
            pitch_val <= 8191;
        else if(!pitch_cmd_r)
            pitch_val <= {ictrl_data[6:0],pitch_lsb};
    end

endmodule
