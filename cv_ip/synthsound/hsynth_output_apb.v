module hsynth_output_apb (
	input wire			clk, // Interface clock
	input wire			reset_n, // asynchronous, active low
	// APB
	input wire	[4:0]	paddr, // apb address
	input wire			penable, // apb enable
	input wire			pwrite,	// apb write strobe
	input wire 	[31:0]	pwdata, // apb data in
	input wire			psel, // apb select
	output reg	[31:0]	prdata, // apb data out
	output wire			pready, // apb ready
	// FIFO interface to capture shift register
	input wire	[63:0]	capture_fifo_data,
	input wire			i2s_capture_fifo_write,
	output wire			capture_fifo_empty,
//	output wire			i2s_playback_enable,
	output wire			i2s_capture_enable,
 	output wire			capture_fifo_full,
	// DMA interface, SOCFPGA
	output reg			capture_dma_req,
	output reg			capture_dma_single,
	input wire			capture_dma_ack
);
	wire			capture_dma_enable;
	assign i2s_capture_enable = capture_dma_enable & ~capture_fifo_full;

	wire			rd_fifo_read;
	wire			rd_fifo_clear;
	wire	[31:0]	rd_fifo_data;
	wire			rd_fifo_empty;
	wire			rd_fifo_full;
	wire	[3:0]	rd_fifo_used;

	reg		[31:0]	cmd_reg;
	reg		[31:0]	sts_reg;

	wire			data_sel = psel && (paddr == 0);
	wire			sts_sel = psel && (paddr == 4); // RO
	wire			cmd_sel = psel && (paddr == 8);

	wire			capture_fifo_write;
	reg [2:0] i2s_capture_fifo_write_synchro;

	always @(posedge clk or negedge reset_n)
		if (~reset_n)
			i2s_capture_fifo_write_synchro <= 0;
		else
			i2s_capture_fifo_write_synchro <= {i2s_capture_fifo_write_synchro[1:0], i2s_capture_fifo_write};
	assign capture_fifo_write = i2s_capture_fifo_write_synchro[2] & ~i2s_capture_fifo_write_synchro[1];

	// Register access
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			cmd_reg <= 0;
		end
		else
		begin
			if (data_sel & ~pwrite & ~penable) // data input register
				prdata <= rd_fifo_data;
			else if (sts_sel & ~pwrite & ~penable) // read status
				prdata <= sts_reg;
			else if (cmd_sel & pwrite & penable) // write cmd
				cmd_reg <= pwdata;
			else if (cmd_sel & ~pwrite & ~penable) // cmd readback
				prdata <= cmd_reg;
			else
			begin
				cmd_reg[0] <= 0; // FIFO clear is just a pulse
				cmd_reg[2] <= 0; // FIFO clear is just a pulse
			end
		end
	end

	// Update status register
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			sts_reg <= 0;
		end
		else
		begin
			sts_reg[7:5] <= 3'b0;
			sts_reg[15:13] <= 3'b0;
			sts_reg[16] <= rd_fifo_empty;
			sts_reg[17] <= rd_fifo_full;
			sts_reg[18] <= capture_dma_enable;
			sts_reg[19] <= capture_dma_single;
			sts_reg[20] <= capture_dma_ack;
			sts_reg[23:21] <= 3'b0;
			sts_reg[28:24] <= rd_fifo_used;
			sts_reg[31:29] <= 3'b0;
		end
	end

	// Capture DMA request
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			capture_dma_single <= 0;
		end
		else
		begin
			if (capture_dma_ack)
				capture_dma_single <= 0;
			else
				capture_dma_single <= capture_dma_enable & ~rd_fifo_empty;
		end
	end

	// Combinatorics
	assign rd_fifo_read = data_sel & ~pwrite & penable; // data read, phase 2
	assign rd_fifo_clear = cmd_reg[2];
	assign capture_dma_enable = cmd_reg[3];

	// APB
	assign pready = penable; // always ready (no wait states)

`ifdef ALTERA_FIFO
	capture_fifo	capture_fifo_inst (
		.wrclk			(clk),
		.wrreq			(capture_fifo_write),
		.data			(capture_fifo_data),
		.aclr			(rd_fifo_clear),
		.wrempty		(capture_fifo_empty),
		.wrfull			(capture_fifo_full),
		.rdclk			(clk),
		.rdreq			(rd_fifo_read),
		.q				(rd_fifo_data),
		.rdempty		(rd_fifo_empty),
		.rdfull			(rd_fifo_full),
		.rdusedw		(rd_fifo_used)
	);
`endif

endmodule
