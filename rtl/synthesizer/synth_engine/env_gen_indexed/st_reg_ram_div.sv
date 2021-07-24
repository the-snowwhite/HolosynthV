module st_reg_ram_div #(
parameter VOICES = 32,
parameter V_OSC = 8;	// number of oscilators pr. voice.
parameter O_ENVS = 2,
parameter V_ENVS = O_ENVS*V_OSC,
parameter V_WIDTH = 5,
parameter E_WIDTH = 3,
parameter width_numerator = 37
) (
    input  wire [width_numerator+15:0] data_in,
    output reg  [width_numerator+15:0] memdata, //level, oldlevel, distance, st --//
    input  wire [V_WIDTH+E_WIDTH-1:0] write_address, read_address,
    input  wire we, re, clk
);

    reg [width_numerator+15:0] mem [(VOICES*V_ENVS)-1:0];

    always @ (posedge clk) begin
        if (we)
            mem[write_address] <= data_in;
        if (re)
            memdata <= mem[read_address];
    end
endmodule
