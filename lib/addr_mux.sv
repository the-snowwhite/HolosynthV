module addr_mux #(
parameter addr_width = 7,
parameter num_lines = 7
) (
input bit                   clk,
input                       dataready,
input                       dec_syx,
input   [1:0]               cpu_and,
input   [addr_width-1:0]    dec_addr,
input   [addr_width-1:0]    cpu_addr,
input   [num_lines-1:0]     cpu_sel,
input   [num_lines-1:0]     dec_sel,
output                      syx_out,
output  [addr_width-1:0]    addr_out,
output  [num_lines-1:0]     sel_out
);

    logic read_write_act;
    reg reg_dataready[4:0];
    reg in_select;

    assign read_write_act = (dataready || reg_dataready[0] || reg_dataready[1] || reg_dataready[2]
            || reg_dataready[3] || reg_dataready[4]);


    always @(posedge clk) begin
        in_select <= read_write_act;
        reg_dataready[0] <= dataready;
        reg_dataready[1] <= reg_dataready[0];
        reg_dataready[2] <= reg_dataready[1];
        reg_dataready[3] <= reg_dataready[2];
        reg_dataready[4] <= reg_dataready[3];
    end

    assign  addr_out[addr_width-1:0]    = in_select ? dec_addr[addr_width-1:0] : cpu_addr[addr_width-1:0];

    assign  sel_out[num_lines-1:0]      = in_select ? dec_sel[num_lines-1:0] : cpu_sel[num_lines-1:0];

    assign  syx_out                     = in_select ? dec_syx : (cpu_and[1] & cpu_and[0]);

endmodule
