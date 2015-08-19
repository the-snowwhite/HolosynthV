module	reset_delay(
	input		iCLK,
	input		reset_reg_N,
	output reg	oRST_0,
	output reg	oRST_1,
	output reg	oRST_2
);
reg	[24:0]	Cont;

always@(posedge iCLK or negedge reset_reg_N)
begin
	if(!reset_reg_N)
	begin
		Cont	<=	24'h0;
		oRST_0	<=	1'b0;
		oRST_1	<=	1'b0;
		oRST_2	<=	1'b0;
	end
	else
	begin
		if(Cont!=24'h8FFFFF)
		Cont	<=	Cont+1'b1;
		if(Cont>=24'h1FFFFF)
		oRST_0	<=	1'b1;
		if(Cont>=24'h2FFFFF)
		oRST_1	<=	1'b1;
		if(Cont>=24'h8FFFFF)
		oRST_2	<=	1'b1;
	end
end

endmodule