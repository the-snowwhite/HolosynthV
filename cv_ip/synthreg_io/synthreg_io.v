module synthreg_io (
	input clk,
	input reset,
	input read,
	input write,
	input chipselect,
	input waitreq,
	input [9:0] address,
	input [7:0] writedata,
	output reg [7:0] readdata,
//	output waitrequest,
	inout [7:0] data,
	output [6:0] out_adr,
	output reg env_sel,
	output reg  osc_sel,
	output reg  m1_sel,
	output reg  m2_sel,
	output reg  com_sel,
	output write_out,
	output read_out,
	output chip_sel
);

reg [7:0] indata;
reg [7:0] outdata;
reg write_delay;
reg reg_w_act;

wire w_act = (write | write_delay);
wire write_active = (write | reg_w_act); 

assign chip_sel = chipselect;
assign data = (!read && write_active && !waitreq) ? outdata : 8'bz;
assign out_adr[6:0] = address[6:0]; 
assign read_out = read;
assign write_out = write;

always @(posedge clk) begin
	write_delay <= write;
	reg_w_act <= w_act;
end


always @(posedge clk) begin
	if (reset)
		readdata[7:0] <= 8'b0;
	else if (read)
		readdata[7:0] <= data[7:0];
	else if	(write)
		outdata <= writedata;
end

always @(address or reset) begin
	if (reset)begin
		env_sel <= 1'b0;
		osc_sel <= 1'b0;
		m1_sel <= 1'b0;
		m2_sel <= 1'b0;
		com_sel <= 1'b0;
	end
	else begin
		case (address[9:7])
			3'd0: begin env_sel <= 1'b1;osc_sel <= 1'b0;m1_sel <= 1'b0;m2_sel <= 1'b0;com_sel <= 1'b0;end
			3'd1: begin env_sel <= 1'b0;osc_sel <= 1'b1;m1_sel <= 1'b0;m2_sel <= 1'b0;com_sel <= 1'b0;end
			3'd2: begin env_sel <= 1'b0;osc_sel <= 1'b0;m1_sel <= 1'b1;m2_sel <= 1'b0;com_sel <= 1'b0;end
			3'd3: begin env_sel <= 1'b0;osc_sel <= 1'b0;m1_sel <= 1'b0;m2_sel <= 1'b1;com_sel <= 1'b0;end
			3'd5: begin env_sel <= 1'b0;osc_sel <= 1'b0;m1_sel <= 1'b0;m2_sel <= 1'b0;com_sel <= 1'b1;end
			default: begin env_sel = 0; osc_sel = 0; m1_sel <= 0; m2_sel <= 0; com_sel <= 0; end
		endcase
	end
end


endmodule
