module velocity #(
parameter VOICES	= 32,
parameter V_WIDTH	= 5
) (
input wire                  reset_reg_N,
input wire  [V_WIDTH-1:0]   vx,
input wire                  reg_note_on,
input wire  [7:0]           reg_cur_vel_on,
input wire  [V_WIDTH-1:0]   reg_cur_key_adr,
input wire  [7:0]           level_mul,
output wire [7:0]           level_mul_vel
);

    reg  [7:0]r_cur_vel_on[VOICES-1:0];
    wire [14:0]  level_mul_vel_w;

    integer kloop;

    always_ff @(negedge reset_reg_N or posedge reg_note_on)begin
        if(!reset_reg_N)begin
            for (kloop=0;kloop<VOICES;kloop=kloop+1)begin
                r_cur_vel_on[kloop] <= 8'hff;
            end
        end
        else
            r_cur_vel_on[reg_cur_key_adr] <= reg_cur_vel_on;
    end

assign level_mul_vel_w = r_cur_vel_on[vx] * level_mul;
assign level_mul_vel = level_mul_vel_w[14:7];


endmodule
