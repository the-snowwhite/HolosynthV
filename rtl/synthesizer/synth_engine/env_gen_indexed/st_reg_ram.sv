module st_reg_ram #(
parameter VOICES = 8,
parameter V_ENVS = 8,
parameter V_WIDTH = 3,
parameter E_WIDTH = 3
) (
    output reg [105:0] q, //level, oldlevel, distance, st --//
    input wire [105:0] d,
    input wire [V_WIDTH+E_WIDTH-1:0] write_address, read_address,
    input wire we, wclk, rclk
);

    reg [105:0] mem [(VOICES*V_ENVS)-1:0];
    always @ (posedge wclk) begin
        if (we)
        mem[write_address] <= d;
    end
    always @ (posedge rclk) begin
        q <= mem[read_address];
    end
endmodule
