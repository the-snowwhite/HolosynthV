module addr_mux #(
parameter addr_width = 7,
parameter num_lines = 7
) (
input bit                   clk,
input                       syx_data_ready,
input                       dec_syx,
input   [1:0]               cpu_and,
input   [addr_width-1:0]    dec_addr,
input   [addr_width-1:0]    cpu_addr,
input   [num_lines-1:0]     cpu_sel_bus,
input   [num_lines-1:0]     dec_sel_bus,
output                      syx_read_select,
output  [addr_width-1:0]    addr_out,
output  [num_lines-1:0]     sel_out_bus
);

    logic read_write_act;
    reg reg_dataready[4:0];
    reg in_select;

    assign read_write_act = (syx_data_ready || reg_dataready[0] || reg_dataready[1] || reg_dataready[2]
            || reg_dataready[3] || reg_dataready[4]);
//    assign read_write_act = (reg_dataready[3] || reg_dataready[4]);

    always @(posedge clk) begin
        in_select <= read_write_act;
        reg_dataready[0] <= syx_data_ready;
        reg_dataready[1] <= reg_dataready[0];
        reg_dataready[2] <= reg_dataready[1];
        reg_dataready[3] <= reg_dataready[2];
        reg_dataready[4] <= reg_dataready[3];
    end
    
//    always @(posedge clk) begin
    assign addr_out[addr_width-1:0]    = in_select ? dec_addr[addr_width-1:0] : cpu_addr[addr_width-1:0];
    assign sel_out_bus[num_lines-1:0]  = in_select ? dec_sel_bus[num_lines-1:0] : cpu_sel_bus[num_lines-1:0];
    assign syx_read_select             = in_select ? dec_syx : (cpu_and[1] & cpu_and[0]);
//	 end
endmodule
