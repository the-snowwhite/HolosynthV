module nco_ram #(
parameter VOICES = 32,
parameter V_OSC = 8,                // number of oscilators pr. voice.
parameter O_ENVS = 2,               // number of envelope generators pr. oscilator.
parameter V_ENVS = V_OSC * O_ENVS,  // number of envelope generators  pr. voice.
parameter V_WIDTH = utils::clogb2(VOICES),
parameter O_WIDTH = utils::clogb2(V_OSC)
) (
    output reg [50:0] qa, qb, //phase_accum_a,reset_a,osc_pitch_val_a --//
    input wire [50:0] d,
    input wire [V_WIDTH+O_WIDTH-1:0] write_address, reada_address, readb_address,
    input wire we, wclk, raclk, rbclk
    );
//`include "utils.v"

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
