module nco_ram(
    output reg [50:0] qa, qb, //phase_accum_a,reset_a,osc_pitch_val_a --//
    input [50:0] d,
    input [V_WIDTH+O_WIDTH-1:0] write_address, reada_address, readb_address,
    input we, wclk, raclk, rbclk
    );
//`include "utils.v"
parameter VOICES = 8;
parameter V_OSC = 8;
parameter V_WIDTH = 3;
parameter O_WIDTH = 2;


    reg [V_WIDTH+O_WIDTH-1:0] reada_address_reg,readb_address_reg,write_address_reg;
    reg [50:0] mem [(VOICES*V_OSC)-1:0];
    always @ (posedge wclk) begin
        if (we)
        mem[write_address_reg] <= d;
        write_address_reg <= write_address;
    end
    always @ (posedge raclk) begin
        qa <= mem[reada_address_reg];
        reada_address_reg <= reada_address;
    end
    always @ (posedge rbclk) begin
        qb <= mem[readb_address_reg];
        readb_address_reg <= readb_address;
    end
endmodule
