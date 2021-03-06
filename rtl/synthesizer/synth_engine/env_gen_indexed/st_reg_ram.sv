module st_reg_ram #(
parameter VOICES = 8,
parameter V_ENVS = 8,
parameter V_WIDTH = 3,
parameter E_WIDTH = 3,
parameter width_numerator = 37
) (
    input  wire [width_numerator+8+9-1:0] data_in,
    output reg  [width_numerator+8+9-1:0] memdata, //level, oldlevel, distance, st --//
    input  wire [V_WIDTH+E_WIDTH-1:0] write_address, read_address,
    input  wire we, re, clk
);

    reg [width_numerator+8+9-1:0] mem [(VOICES*V_ENVS)-1:0];

    always @ (posedge clk) begin
        if (we)
            mem[write_address] <= data_in;
        if (re)
            memdata <= mem[read_address];
    end
endmodule
