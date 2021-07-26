module holosynth_audio #(
parameter ADDRESS_WIDTH = 3,
parameter DATA_WIDTH = 8,
parameter IRQ_EN = 0,
parameter FIFO_WIDTH = 10,
parameter AUD_BIT_DEPTH = 24
) (
// signals to connect to an Avalon clock source interface
    input clk,
    input reset_n,
    // signals to connect to an Avalon-MM slave interface
    input [ADDRESS_WIDTH-1:0] slave_address,
    input slave_read,
    input slave_write,
    output reg [DATA_WIDTH-1:0] slave_readdata,
    input [DATA_WIDTH-1:0] slave_writedata,
    input slave_chipselect,
//    interrupt siganls
    output reg slave_irq,
// signals to connect to custom con logic
    input con_int_in,
    input wire con_xxxx_zero,
    input wire con_xxxx_top,
    input wire con_lrck,
    input wire con_run,
    input wire [AUD_BIT_DEPTH-1:0] con_lsound_in,
    input wire [AUD_BIT_DEPTH-1:0] con_rsound_in,
    output wire con_trig,
    output wire con_i2s_enable
);

// signals to connect to custom con logic
reg [DATA_WIDTH-1:0] datain;
wire [DATA_WIDTH-1:0] dataout;
reg [ADDRESS_WIDTH-1:0] address;
reg read;
reg write;
reg chip_sel;

wire [AUD_BIT_DEPTH-1:0] lsound_fifo;
wire [AUD_BIT_DEPTH-1:0] rsound_fifo;
wire sample_ready;
wire l_read,r_read;

always @(posedge clk) begin
    if (!reset_n) begin
        slave_readdata[DATA_WIDTH-1:0] <= 0;
        slave_irq <= 0;
        datain[DATA_WIDTH-1:0] <= 0;
        address[ADDRESS_WIDTH-1:0] <= 0;
        chip_sel <= 0;
        read <= 0;
        write<= 0;
    end
    else begin
        chip_sel <= slave_chipselect;
        read <= slave_read;
        write <= slave_write;
        address[ADDRESS_WIDTH-1:0] <= slave_address[ADDRESS_WIDTH-1:0];
        if (slave_read) begin
            slave_readdata[DATA_WIDTH-1:0] <= dataout[DATA_WIDTH-1:0];
        end
        if    (slave_write) begin
            datain <= slave_writedata;
        end
        if (IRQ_EN == 1) begin
            if (!con_int_in)
                slave_irq <= 1'b1;
            else if (slave_read)
                slave_irq <= 1'b0;
        end
    end
end

audio_mux audio_mux_inst
(
	.clk(clk) ,	// input  clk_sig
	.address(address) ,	// input [2:0] address_sig
	.read(read) ,	// input  read_sig
	.write(write) ,	// input  write_sig
	.datain(datain) ,	// input [31:0] datain_sig
	.lsound_fifo(lsound_fifo) ,	// input [AUD_BIT_DEPTH-1:0] lsound_in_sig
	.rsound_fifo(rsound_fifo) ,	// input [AUD_BIT_DEPTH-1:0] rsound_in_sig
	.xxxx_top(con_xxxx_top) ,	// input  xxxx_top_sig
	.lrck(con_lrck) ,	// input  lrck_sig
	.run(con_run) ,	// input  run_sig
	.dataout(dataout) ,	// output [31:0] dataout_sig
	.l_read(l_read) ,	// output  l_read_sig
	.r_read(r_read) ,	// output  r_read_sig
	.sample_ready(sample_ready) ,	// output  sample_ready_sig
	.trig(con_trig) ,	// output  trig_sig
	.i2s_enable(con_i2s_enable) 	// output  i2s_enable_sig
);

defparam audio_mux_inst.FIFO_WIDTH = FIFO_WIDTH;
defparam audio_mux_inst.AUD_BIT_DEPTH = AUD_BIT_DEPTH;

audio_fifo	audio_fifo_left (
	.data ( con_lsound_in ),
	.rdclk ( clk ),
	.rdreq ( l_read ),
	.wrclk ( con_xxxx_zero ),
	.wrreq ( sample_ready ),
	.q ( lsound_fifo )
	);
	
audio_fifo	audio_fifo_right (
	.data ( con_rsound_in ),
	.rdclk ( clk ),
	.rdreq ( r_read ),
	.wrclk ( con_xxxx_zero ),
	.wrreq ( sample_ready ),
	.q ( rsound_fifo )
	);


endmodule
