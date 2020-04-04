module address_decoder (
    input wire              reg_clk,
    input wire              dec_sysex_data_patch_send,
    input wire              syx_data_ready,
    output reg              syx_read ,
    output reg              syx_write ,
    output reg              write_dataenable
);

    reg [3:0] syx_data_rdy_r;

    initial begin
        syx_data_rdy_r = 3'h0;
        syx_read = 1'b0;
        syx_write = 1'b0;
        write_dataenable = 1'b0;
    end

    always @(posedge reg_clk)begin
        syx_read <= (syx_data_rdy_r[2] && dec_sysex_data_patch_send) ? 1'b1 : 1'b0;
        syx_write <= (syx_data_rdy_r[2] && ~dec_sysex_data_patch_send) ? 1'b1 : 1'b0;
        syx_data_rdy_r[0] <= syx_data_ready;
        syx_data_rdy_r[1] <= syx_data_rdy_r[0];
        syx_data_rdy_r[2] <= syx_data_rdy_r[1];
        syx_data_rdy_r[3] <= syx_data_rdy_r[2];
        write_dataenable  <= syx_data_rdy_r[3] || syx_data_rdy_r[2] || syx_data_rdy_r[1];
    end

endmodule
