`define audio true
// Synthesizer
`define _CycloneV
`define _Synth
`define _32BitAudio


module DE1_SOC_Linux_Audio(
	//////////// ADC //////////
	inout						ADC_CS_N,
	output						ADC_DIN,
	input						ADC_DOUT,
	output						ADC_SCLK,

	//////////// Audio //////////
	input						AUD_ADCDAT,
	inout						AUD_ADCLRCK,
	inout						AUD_BCLK,
	output						AUD_DACDAT,
	inout						AUD_DACLRCK,
	output						AUD_XCK,

	//////////// CLOCK //////////
	input						CLOCK_50,
	input						CLOCK2_50,
	input						CLOCK3_50,
	input						CLOCK4_50,

	//////////// SDRAM //////////
	output			[12:0]		DRAM_ADDR,
	output			 [1:0]		DRAM_BA,
	output						DRAM_CAS_N,
	output						DRAM_CKE,
	output						DRAM_CLK,
	output						DRAM_CS_N,
	inout			[15:0]		DRAM_DQ,
	output						DRAM_LDQM,
	output						DRAM_RAS_N,
	output						DRAM_UDQM,
	output						DRAM_WE_N,

	///////// FAN /////////
	output						FAN_CTRL,

	//////////// I2C for Audio and Video-In //////////
	output						FPGA_I2C_SCLK,
	inout						FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output			 [6:0]		HEX0,
	output			 [6:0]		HEX1,
	output			 [6:0]		HEX2,
	output			 [6:0]		HEX3,
	output			 [6:0]		HEX4,
	output			 [6:0]		HEX5,

	//////////// IR //////////
	input						IRDA_RXD,
	output						IRDA_TXD,

	//////////// KEY //////////
	input			 [3:0]		KEY,

	//////////// LED //////////
	output			 [9:0]		LEDR,

	//////////// PS2 //////////
	inout						PS2_CLK,
	inout						PS2_CLK2,
	inout						PS2_DAT,
	inout						PS2_DAT2,

	//////////// SW //////////
	input			 [9:0]		SW,

	//////////// Video-In //////////
	input						TD_CLK27,
	input			 [7:0]		TD_DATA,
	input						TD_HS,
	output						TD_RESET_N,
	input						TD_VS,

	//////////// VGA //////////
	output			 [7:0]		VGA_B,
	output						VGA_BLANK_N,
	output						VGA_CLK,
	output			 [7:0]		VGA_G,
	output						VGA_HS,
	output			 [7:0]		VGA_R,
	output						VGA_SYNC_N,
	output						VGA_VS,

	//////////// HPS //////////
	inout						HPS_CONV_USB_N,
	output			[14:0]		HPS_DDR3_ADDR,
	output			 [2:0]		HPS_DDR3_BA,
	output						HPS_DDR3_CAS_N,
	output						HPS_DDR3_CK_N,
	output						HPS_DDR3_CK_P,
	output						HPS_DDR3_CKE,
	output						HPS_DDR3_CS_N,
	output			 [3:0]		HPS_DDR3_DM,
	inout			[31:0]		HPS_DDR3_DQ,
	inout			 [3:0]		HPS_DDR3_DQS_N,
	inout			 [3:0]		HPS_DDR3_DQS_P,
	output						HPS_DDR3_ODT,
	output						HPS_DDR3_RAS_N,
	output						HPS_DDR3_RESET_N,
	input						HPS_DDR3_RZQ,
	output						HPS_DDR3_WE_N,
	output						HPS_ENET_GTX_CLK,
	inout						HPS_ENET_INT_N,
	output						HPS_ENET_MDC,
	inout						HPS_ENET_MDIO,
	input						HPS_ENET_RX_CLK,
	input			 [3:0]		HPS_ENET_RX_DATA,
	input						HPS_ENET_RX_DV,
	output			 [3:0]		HPS_ENET_TX_DATA,
	output						HPS_ENET_TX_EN,
	inout			 [3:0]		HPS_FLASH_DATA,
	output						HPS_FLASH_DCLK,
	output						HPS_FLASH_NCSO,
	inout			 [1:0]		HPS_GPIO,
	inout						HPS_GSENSOR_INT,
	inout						HPS_I2C_CONTROL,
	inout						HPS_I2C1_SCLK,
	inout						HPS_I2C1_SDAT,
	inout						HPS_I2C2_SCLK,
	inout						HPS_I2C2_SDAT,
	inout						HPS_KEY,
	inout						HPS_LED,
	inout						HPS_LTC_GPIO,
	output						HPS_SD_CLK,
	inout						HPS_SD_CMD,
	inout			 [3:0]		HPS_SD_DATA,
	output						HPS_SPIM_CLK,
	input						HPS_SPIM_MISO,
	output						HPS_SPIM_MOSI,
	inout						HPS_SPIM_SS,
	input						HPS_UART_RX,
	output						HPS_UART_TX,
	input						HPS_USB_CLKOUT,
	inout			 [7:0]		HPS_USB_DATA,
	input						HPS_USB_DIR,
	input						HPS_USB_NXT,
	output						HPS_USB_STP,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	inout			[35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	inout			[35:0]		GPIO_1
);

//////////// GPIO - 15" LCD  //////////

wire	[7:0]	LCD_B;
wire			LCD_DCLK;
wire	[7:0]	LCD_G;
wire			LCD_HSD;
wire	[7:0]	LCD_R;
wire			LCD_DE;
wire			LCD_VSD;

assign GPIO_0[28:22]    = LCD_B[7:1];
assign GPIO_0[20]       = LCD_B[0];
assign GPIO_0[21]       = LCD_G[7];
assign GPIO_0[19:18]    = LCD_G[6:5];
assign GPIO_0[15:11]    = LCD_G[4:0];
assign GPIO_0[10:3]     = LCD_R;
assign GPIO_0[1]        = LCD_DCLK;
assign GPIO_0[30]       = ~LCD_HSD;
assign GPIO_0[35]       = LCD_DE;
assign GPIO_0[31]       = ~LCD_VSD;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	wire				hps_0_h2f_reset_reset_n;
	wire	[63:0]		i2s_output_apb_0_playback_fifo_data;
	wire				i2s_playback_fifo_ack;
	wire				i2s_output_apb_0_playback_fifo_empty;
	wire				i2s_playback_enable;
	wire	[63:0]		i2s_output_apb_0_capture_fifo_data;
	wire				i2s_output_apb_0_capture_fifo_full;
	wire				i2s_capture_enable;
	wire				i2s_clkctrl_apb_0_conduit_bclk;
	wire				i2s_clk;

// Synth
    wire  [3:0] fpga_debounced_buttons;
    wire		midi_rxd;   
    wire		midi_txd;

    wire [9:0]	cpu_adr;
    wire 		cpu_write;
    wire		cpu_read;
    wire		cpu_chip_sel;
    wire [31:0]	cpu_data_out;
    wire [31:0]	cpu_data_in;
    wire 		synth_irq_n;
	wire [2:0]	socmidi_addr;
	wire 		socmidi_write;
	wire		socmidi_read;
	wire		socmidi_chip_sel;
	wire [7:0]	socmidi_data_out;
	wire [7:0]	socmidi_data_in;
	wire 		socmidi_irq_n;

    wire            AUDIO_CLK;
    wire            OSC_CLK;
    wire    [31:0]  lsound_out;
    wire    [31:0]  rsound_out;
    wire            n_xxxx_zero;
    assign synth_irq_n = 1'b1;
    assign socmidi_irq_n = 1'b1;

    assign 	midi_rxd = SW[0] ? GPIO_1[27] : ~GPIO_1[27];
    assign	GPIO_1[29] = SW[0] ? midi_txd : ~midi_txd;
  
    
//=======================================================
//  Structural coding
//=======================================================

// Debounce logic to clean out glitches within 1ms
debounce debounce_inst (
  .clk                                  (CLOCK3_50),
  .reset_n                              (hps_0_h2f_reset_reset_n),
  .data_in                              (KEY),
  .data_out                             (fpga_debounced_buttons)
);
 defparam debounce_inst.WIDTH = 4;
 defparam debounce_inst.POLARITY = "LOW";
 defparam debounce_inst.TIMEOUT = 50000;        // at 50Mhz this is a debounce time of 1ms
 defparam debounce_inst.TIMEOUT_WIDTH = 16;     // ceil(log2(TIMEOUT))

assign HEX0 = 7'b1000000;
assign HEX1 = 7'b1111001;

    soc_system u0 (
		.clk_clk							(CLOCK_50),
		.reset_reset_n						(hps_0_h2f_reset_reset_n),

		.memory_mem_a						(HPS_DDR3_ADDR),
		.memory_mem_ba						(HPS_DDR3_BA),
		.memory_mem_ck						(HPS_DDR3_CK_P),
		.memory_mem_ck_n					(HPS_DDR3_CK_N),
		.memory_mem_cke						(HPS_DDR3_CKE),
		.memory_mem_cs_n					(HPS_DDR3_CS_N),
		.memory_mem_ras_n					(HPS_DDR3_RAS_N),
		.memory_mem_cas_n					(HPS_DDR3_CAS_N),
		.memory_mem_we_n					(HPS_DDR3_WE_N),
		.memory_mem_reset_n					(HPS_DDR3_RESET_N),
		.memory_mem_dq						(HPS_DDR3_DQ),
		.memory_mem_dqs						(HPS_DDR3_DQS_P),
		.memory_mem_dqs_n					(HPS_DDR3_DQS_N),
		.memory_mem_odt						(HPS_DDR3_ODT),
		.memory_mem_dm						(HPS_DDR3_DM),
		.memory_oct_rzqin					(HPS_DDR3_RZQ),
		.lcd_clk_clk                        (LCD_DCLK),
		.alt_vip_itc_vid_clk                (LCD_DCLK),
		.alt_vip_itc_vid_data               ({LCD_R,LCD_G,LCD_B}),
		.alt_vip_itc_underflow              (),
		.alt_vip_itc_vid_datavalid          (LCD_DE),
		.alt_vip_itc_vid_v_sync             (LCD_VSD),
		.alt_vip_itc_vid_h_sync             (LCD_HSD),
		.alt_vip_itc_vid_f                  (),
		.alt_vip_itc_vid_h                  (),
		.alt_vip_itc_vid_v                  (),
		.hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
		.hps_io_hps_io_emac1_inst_TXD0		(HPS_ENET_TX_DATA[0]),
		.hps_io_hps_io_emac1_inst_TXD1		(HPS_ENET_TX_DATA[1]),
		.hps_io_hps_io_emac1_inst_TXD2		(HPS_ENET_TX_DATA[2]),
		.hps_io_hps_io_emac1_inst_TXD3		(HPS_ENET_TX_DATA[3]),
		.hps_io_hps_io_emac1_inst_MDIO		(HPS_ENET_MDIO),
		.hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
		.hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
		.hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
		.hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
		.hps_io_hps_io_emac1_inst_RXD0		(HPS_ENET_RX_DATA[0]),
		.hps_io_hps_io_emac1_inst_RXD1		(HPS_ENET_RX_DATA[1]),
		.hps_io_hps_io_emac1_inst_RXD2		(HPS_ENET_RX_DATA[2]),
		.hps_io_hps_io_emac1_inst_RXD3		(HPS_ENET_RX_DATA[3]),

		.hps_io_hps_io_qspi_inst_IO0		(HPS_FLASH_DATA[0]),
		.hps_io_hps_io_qspi_inst_IO1		(HPS_FLASH_DATA[1]),
		.hps_io_hps_io_qspi_inst_IO2		(HPS_FLASH_DATA[2]),
		.hps_io_hps_io_qspi_inst_IO3		(HPS_FLASH_DATA[3]),
		.hps_io_hps_io_qspi_inst_SS0		(HPS_FLASH_NCSO),
		.hps_io_hps_io_qspi_inst_CLK		(HPS_FLASH_DCLK),


		.hps_io_hps_io_sdio_inst_CMD		(HPS_SD_CMD),
		.hps_io_hps_io_sdio_inst_D0			(HPS_SD_DATA[0]),
		.hps_io_hps_io_sdio_inst_D1			(HPS_SD_DATA[1]),
		.hps_io_hps_io_sdio_inst_D2			(HPS_SD_DATA[2]),
		.hps_io_hps_io_sdio_inst_D3			(HPS_SD_DATA[3]),
		.hps_io_hps_io_sdio_inst_CLK		(HPS_SD_CLK),

		.hps_io_hps_io_usb1_inst_D0			(HPS_USB_DATA[0]),
		.hps_io_hps_io_usb1_inst_D1			(HPS_USB_DATA[1]),
		.hps_io_hps_io_usb1_inst_D2			(HPS_USB_DATA[2]),
		.hps_io_hps_io_usb1_inst_D3			(HPS_USB_DATA[3]),
		.hps_io_hps_io_usb1_inst_D4			(HPS_USB_DATA[4]),
		.hps_io_hps_io_usb1_inst_D5			(HPS_USB_DATA[5]),
		.hps_io_hps_io_usb1_inst_D6			(HPS_USB_DATA[6]),
		.hps_io_hps_io_usb1_inst_D7			(HPS_USB_DATA[7]),
		.hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
		.hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
		.hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
		.hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT),

		.hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
		.hps_io_hps_io_spim1_inst_MOSI		(HPS_SPIM_MOSI),
		.hps_io_hps_io_spim1_inst_MISO		(HPS_SPIM_MISO),
		.hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),

		.hps_io_hps_io_uart0_inst_RX		(HPS_UART_RX),
		.hps_io_hps_io_uart0_inst_TX		(HPS_UART_TX),

		.hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
		.hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),

		.hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
		.hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),

		.hps_io_hps_io_gpio_inst_GPIO09		(HPS_CONV_USB_N),
		.hps_io_hps_io_gpio_inst_GPIO35		(HPS_ENET_INT_N),
		.hps_io_hps_io_gpio_inst_GPIO40		(HPS_LTC_GPIO),
		.hps_io_hps_io_gpio_inst_GPIO48		(HPS_I2C_CONTROL),
		.hps_io_hps_io_gpio_inst_GPIO53		(HPS_LED),
		.hps_io_hps_io_gpio_inst_GPIO54		(HPS_KEY),
		.hps_io_hps_io_gpio_inst_GPIO61		(HPS_GSENSOR_INT),

		.hps_0_h2f_reset_reset_n			(hps_0_h2f_reset_reset_n),

		.i2s_output_apb_0_playback_fifo_data				(i2s_output_apb_0_playback_fifo_data), 	// out
		.i2s_output_apb_0_playback_fifo_ack					(i2s_playback_fifo_ack),				//in
		.i2s_output_apb_0_playback_fifo_empty				(i2s_output_apb_0_playback_fifo_empty),	// out
		.i2s_output_apb_0_playback_fifo_full				(),										// out
		.i2s_output_apb_0_playback_fifo_i2s_playback_enable	(i2s_playback_enable),					// out
		.i2s_output_apb_0_playback_fifo_full				(),
		.i2s_output_apb_0_capture_fifo_data					(i2s_output_apb_0_capture_fifo_data), 	// in
		.i2s_output_apb_0_capture_fifo_write				(i2s_capture_fifo_write),				// in
		.i2s_output_apb_0_capture_fifo_empty				(),										// out
		.i2s_output_apb_0_capture_fifo_full					(i2s_output_apb_0_capture_fifo_full),	// out
		.i2s_output_apb_0_capture_fifo_i2s_capture_enable	(i2s_capture_enable),					// out

		.i2s_clkctrl_apb_0_conduit_bclk						(i2s_clkctrl_apb_0_conduit_bclk),		// out
		.i2s_clkctrl_apb_0_mclk_clk							(AUD_XCK),								// out
		.i2s_clkctrl_apb_0_conduit_aud_daclrclk				(AUD_DACLRCK),							// inout
		.i2s_clkctrl_apb_0_conduit_aud_adclrclk				(AUD_ADCLRCK),							// inout
		.i2s_clkctrl_apb_0_conduit_aud_bclk					(AUD_BCLK),								// inout
		.i2s_clkctrl_apb_0_mclk_i2s_clk						(i2s_clk),								// out
    .synthreg_io_uio_dataout                   (cpu_data_out),                   //                    synthreg_io.uio_dataout
    .synthreg_io_uio_address                   (cpu_adr),                   //                               .uio_address
    .synthreg_io_uio_read                      (cpu_read),                      //                               .uio_read
    .synthreg_io_uio_chipsel                   (cpu_chip_sel),                   //                               .uio_chipsel
    .synthreg_io_uio_datain                    (cpu_data_in),                    //                               .uio_datain
    .synthreg_io_uio_write                     (cpu_write),                     //                               .uio_write
    .synthreg_io_uio_int_in_n                  (synth_irq_n),                     //                               .uio_int_in
    .socmidi_io_socmidi_dataout                (socmidi_data_out),                //                     socmidi_io.socmidi_dataout
    .socmidi_io_socmidi_address                (socmidi_addr),                //                               .socmidi_address
    .socmidi_io_socmidi_read                   (socmidi_read),                   //                               .socmidi_read
    .socmidi_io_socmidi_chipsel                (socmidi_chip_sel),                //                               .socmidi_chipsel
    .socmidi_io_socmidi_datain                 (socmidi_data_in),                 //                               .socmidi_datain
    .socmidi_io_socmidi_write                  (socmidi_write),                  //                               .socmidi_write
    .socmidi_io_socmidi_int_in                 (socmidi_irq_n),                 //                               .socmidi_int_in
	.pll_stream_locked_export                  (),
	.pll_audio_locked_export                   (),
//	.audio_clk_clk                                       (AUDIO_CLK),
	.osc_clk                                  (OSC_CLK),
	.hsynth_clkctrl_api_0_conduit_aud_daclrclk           (),// inout
	.hsynth_clkctrl_api_0_conduit_aud_bclk               (),// inout
	.hsynth_clkctrl_api_0_conduit_bclk                   (),// out
	.hsynth_clkctrl_api_0_conduit_aud_adclrclk           (),// inout
	.hsynth_clkctrl_api_0_mclk_clk                       (),// out
	.hsynth_clkctrl_api_0_mclk_i2s_clk                   (),// out
	.hsynth_output_apb_0_capture_fifo_data               ({rsound_out[31:0],lsound_out[31:0]}),// in
	.hsynth_output_apb_0_capture_fifo_write              (n_xxxx_zero),// in
	.hsynth_output_apb_0_capture_fifo_full               (),// out
	.hsynth_output_apb_0_capture_fifo_i2s_capture_enable (),// out
	.hsynth_output_apb_0_capture_fifo_empty              ()// out
	);

	i2s_shift_out i2s_shift_out(
		.reset_n							(hps_0_h2f_reset_reset_n),
		.clk								(i2s_clk),

		.fifo_right_data					(i2s_output_apb_0_playback_fifo_data[63:32]),
		.fifo_left_data						(i2s_output_apb_0_playback_fifo_data[31:0]),
		.fifo_ready							(~i2s_output_apb_0_playback_fifo_empty),
		.fifo_ack							(i2s_playback_fifo_ack),

		.enable								(i2s_playback_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(AUD_DACLRCK),
		.data_out							(AUD_DACDAT)
	);

	i2s_shift_in i2s_shift_in(
		.reset_n							(hps_0_h2f_reset_reset_n),
		.clk								(i2s_clk),

		.fifo_right_data					(i2s_output_apb_0_capture_fifo_data[63:32]),
		.fifo_left_data						(i2s_output_apb_0_capture_fifo_data[31:0]),
		.fifo_ready							(~i2s_output_apb_0_capture_fifo_full),
		.fifo_write							(i2s_capture_fifo_write),

		.enable								(i2s_capture_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(AUD_ADCLRCK),
		.data_in							(AUD_ADCDAT)
	);
parameter VOICES = 32;
//parameter VOICES = 64;
parameter V_OSC = 8;	// number of oscilators pr. voice.

parameter O_ENVS = 2;	// number of envelope generators pr. oscilator.
parameter V_ENVS = V_OSC * O_ENVS;	// number of envelope generators  pr. voice.

	assign LEDR = voice_free[9:0];
	wire  [VOICES-1:0]	keys_on;
	wire  [VOICES-1:0]	voice_free;

	wire ad_xck = AUD_XCK;  			// violet
	wire ad_bclk = AUD_BCLK;			// orange
	wire ad_daclrck = AUD_DACLRCK;	// green
	wire ad_dacdat = AUD_DACDAT;	// white

	assign GPIO_1[9] = ad_xck;
	assign GPIO_1[7] = ad_bclk;
	assign GPIO_1[5] = ad_daclrck;
	assign GPIO_1[3] = ad_dacdat;

	reg [7:0]   delay_1;
	wire 			iRST_n;

synthesizer #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS))  synthesizer_inst(
	.EXT_CLOCK_IN			(CLOCK_50) ,   // input  CLOCK_50_sig
	.reset_n				(hps_0_h2f_reset_reset_n),
	.MIDI_Rx_DAT			( midi_rxd ) ,    // input  MIDI_DAT_sig (inverted due to inverter in rs232 chip)
	.midi_txd				( midi_txd ),		// output midi transmit signal (inverted due to inverter in rs232 chip)
//	.button( fpga_debounced_buttons[3:0] ),            //  Button[3:0]
	.button					( KEY ),            //  Button[3:0]
//    .SW ( SW[17:0]),
`ifdef _Synth
	.OSC_CLK				(OSC_CLK  ),      //  Audio CODEC Chip Clock
	.lsound_out				(lsound_out),      //  Audio Raw Data Low
	.rsound_out				(rsound_out),      //  Audio Raw Data high
`endif
	.n_xxxx_zero            (n_xxxx_zero),		// output  cycle complete signag
	.keys_on				(keys_on),				//  LED [7:0]
	.voice_free				(voice_free) , 			//  Red LED [4:1]
	.io_clk					(CLOCK3_50) ,	// input  io_clk_sig
	.io_reset_n				(hps_0_h2f_reset_reset_n) ,	// input  io_reset_sig
	.cpu_read				(cpu_read) ,	// input  cpu_read_sig
	.cpu_write				(cpu_write) ,	// input  cpu_write_sig
	.chipselect				(cpu_chip_sel) ,	// input  chipselect_sig
	.address				(cpu_adr) ,	// input [9:0] address_sig
	.writedata				(cpu_data_out) ,	// input [31:0] writedata_sig
	.readdata				(cpu_data_in), 	// output [31:0] readdata_sig
	.socmidi_read			(socmidi_read) ,	// input  cpu_read_sig
	.socmidi_write			(socmidi_write) ,	// input  cpu_write_sig
	.socmidi_cs				(socmidi_chip_sel) ,	// input  chipselect_sig
	.socmidi_addr			(socmidi_addr) ,	// input [9:0] address_sig
	.socmidi_data_out		(socmidi_data_out) ,	// input [31:0] writedata_sig
	.socmidi_data_in		(socmidi_data_in), 	// output [31:0] readdata_sig
    .switch4                (SW[3])
);

always @(negedge KEY[3] or posedge CLOCK3_50)
    begin
        if ( !KEY[3])
            delay_1 <=0 ;
        else if ( !delay_1 [7] )
            delay_1 <= delay_1 + 1'b1;
    end

endmodule
