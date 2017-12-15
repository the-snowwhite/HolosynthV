module note_key_vel_sync(
input                       xxxx_zero,
input                       OSC_CLK,
input                       note_on,
input       [V_WIDTH-1:0]   cur_key_adr,
input       [7:0]           cur_key_val,
input       [7:0]           cur_vel_on,
input       [VOICES-1:0]    keys_on,
output reg                  reg_note_on,
output reg  [V_WIDTH-1:0]   reg_cur_key_adr,
output reg  [7:0]           reg_cur_key_val,
output reg  [7:0]           reg_cur_vel_on,
output reg  [VOICES-1:0]    reg_keys_on
);

parameter VOICES	= 8;
parameter V_WIDTH	= 3;

reg                 note_on_r[1:0];
reg [V_WIDTH-1:0]   cur_key_adr_r[1:0];
reg [7:0]           cur_key_val_r[1:0];
reg [7:0]           cur_vel_on_r[1:0];
reg [VOICES-1:0]    keys_on_r[1:0];
reg                 r_note_on;
    always @(posedge OSC_CLK)begin
            note_on_r[0]        <= note_on;
            note_on_r[1]        <= note_on_r[0];
            cur_key_adr_r[0]    <= cur_key_adr;
            cur_key_adr_r[1]	<= cur_key_adr_r[0];
            cur_key_val_r[0]	<= cur_key_val;
            cur_key_val_r[1]	<= cur_key_val_r[0];
            cur_vel_on_r[0]     <= cur_vel_on;
            cur_vel_on_r[1]     <= cur_vel_on_r[0];
            keys_on_r[0]        <= keys_on;
            keys_on_r[1]        <= keys_on_r[0];
            reg_note_on         <= r_note_on;
    end

    always @(negedge xxxx_zero)begin
        if(!xxxx_zero)begin
            r_note_on       <= (r_note_on == 1'b1) ? 1'b0 : note_on_r[1];
            reg_cur_key_adr <= cur_key_adr_r[1];
            reg_cur_key_val <= cur_key_val_r[1];
            reg_cur_vel_on  <= cur_vel_on_r[1];
            reg_keys_on     <= keys_on_r[1];
        end
    end

endmodule


