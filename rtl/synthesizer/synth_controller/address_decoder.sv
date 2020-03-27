module address_decoder (
    input wire              reg_clk,
    input wire              reset_reg_N,
    input wire              data_ready,
    input wire  [2:0]       bank_adr,
    input wire  [7:0]       out_data,
    output  reg             read_write ,
	inout wire  [7:0]       data_out,
    output wire [5:0]       dec_sel,
    output reg          write_dataenable
);

    reg syx_data_rdy_r[3:0];
    reg [2:0] syx_bank_adr_r;

    assign data_out = write_dataenable ? out_data : 8'bz;

    always @(posedge reg_clk)begin
        syx_bank_adr_r <= bank_adr;
        syx_data_rdy_r[0] <= data_ready;
        syx_data_rdy_r[1] <= syx_data_rdy_r[0];
        syx_data_rdy_r[2] <= syx_data_rdy_r[1];
        syx_data_rdy_r[3] <= syx_data_rdy_r[2];
        read_write  <= syx_data_rdy_r[2];
        write_dataenable  <= syx_data_rdy_r[3] || syx_data_rdy_r[2];
    end

    addr_decoder #(.addr_width(3),.num_lines(6)) addr_decoder2_inst
    (
        .clk(syx_data_rdy_r[1]) ,	// input  clk_sig
        .reset_n(!reset_reg_N) ,	// input  reset_sig
        .address(bank_adr) ,	// input [addr_width-1:0] address_sig
        .sel(dec_sel[5:0]) 	// output [num_lines:0] sel_sig
    );

endmodule
