module timing_gen #(
parameter VOICES = 32,
parameter V_ENVS = 8,
parameter V_WIDTH = 3,
parameter E_WIDTH = 3
) (
    input wire  sCLK_XVXENVS, // clk
    input wire  reset_reg_N,    // reset
    output reg  [V_WIDTH+E_WIDTH-1:0]xxxx,  // index counter
    output reg  xxxx_top,
    output reg  xxxx_zero
);

    wire xxxx_pre_max = (xxxx == (VOICES*V_ENVS)-2) ? 1'b1:1'b0;
    wire xxxx_max = (xxxx == (VOICES*V_ENVS)-1) ? 1'b1:1'b0;
    always_ff @(negedge sCLK_XVXENVS)begin xxxx_top <= xxxx_pre_max; end
    always_ff @(negedge sCLK_XVXENVS)begin xxxx_zero <= xxxx_max; end

    always_ff @(posedge sCLK_XVXENVS or negedge reset_reg_N)begin
        if(!reset_reg_N) begin xxxx <= {(V_WIDTH+E_WIDTH){1'b0}}; end
        else begin
            if(xxxx_zero ) begin xxxx <= {(V_WIDTH+E_WIDTH){1'b0}}; end
            else begin xxxx <= xxxx + 1; end
        end
    end

endmodule
