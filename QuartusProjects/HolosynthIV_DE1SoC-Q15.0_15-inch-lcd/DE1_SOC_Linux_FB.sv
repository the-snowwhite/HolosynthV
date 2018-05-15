// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ============================================================================
//
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Mon Jun 17 20:35:29 2013
// ============================================================================

`define ENABLE_HPS
`define user_peripheral true
`define audio true
// Synthesizer
`define _CycloneV
`define _Synth
`define _32BitAudio
//`define _180MhzOscs

module DE1_SOC_Linux_FB(

    inout              ADC_CS_N,
    output             ADC_DIN,
    input              ADC_DOUT,
    output             ADC_SCLK,

    ///////// AUD /////////
    input              AUD_ADCDAT,
    inout              AUD_ADCLRCK,
    inout              AUD_BCLK,
    output             AUD_DACDAT,
    inout              AUD_DACLRCK,
    output             AUD_XCK,

    ///////// CLOCK2 /////////
    input              CLOCK_50,

    ///////// CLOCK3 /////////
    input              CLOCK2_50,

    ///////// CLOCK4 /////////
    input              CLOCK3_50,

    ///////// CLOCK /////////
    input              CLOCK4_50,

    ///////// DRAM /////////
    output      [12:0] DRAM_ADDR,
    output      [1:0]  DRAM_BA,
    output             DRAM_CAS_N,
    output             DRAM_CKE,
    output             DRAM_CLK,
    output             DRAM_CS_N,
    inout       [15:0] DRAM_DQ,
    output             DRAM_LDQM,
    output             DRAM_RAS_N,
    output             DRAM_UDQM,
    output             DRAM_WE_N,

    ///////// FAN /////////
    output             FAN_CTRL,

    ///////// FPGA /////////
    output             FPGA_I2C_SCLK,
    inout              FPGA_I2C_SDAT,

    ///////// GPIO /////////
//      inout     [35:0]         GPIO_0,

    output  [7:0]   LCD_B,
    output          LCD_DCLK,
    output  [7:0]   LCD_G,
    output          LCD_HSD,
    output  [7:0]   LCD_R,
    output          LCD_DE,
    output          LCD_VSD,

    inout   [35:0]  GPIO_1,


    ///////// HEX0 /////////
    output  [6:0]  HEX[5:0],

//     ///////// HEX1 /////////
//     output  [6:0]  HEX1,
//
//     ///////// HEX2 /////////
//     output  [6:0]  HEX2,
//
//     ///////// HEX3 /////////
//     output  [6:0]  HEX3,
//
//     ///////// HEX4 /////////
//     output  [6:0]  HEX4,
//
//     ///////// HEX5 /////////
//     output  [6:0]  HEX5,

`ifdef ENABLE_HPS
    ///////// HPS /////////
    inout              HPS_CONV_USB_N,
    output      [14:0] HPS_DDR3_ADDR,
    output      [2:0]  HPS_DDR3_BA,
    output             HPS_DDR3_CAS_N,
    output             HPS_DDR3_CKE,
    output             HPS_DDR3_CK_N,
    output             HPS_DDR3_CK_P,
    output             HPS_DDR3_CS_N,
    output      [3:0]  HPS_DDR3_DM,
    inout       [31:0] HPS_DDR3_DQ,
    inout       [3:0]  HPS_DDR3_DQS_N,
    inout       [3:0]  HPS_DDR3_DQS_P,
    output             HPS_DDR3_ODT,
    output             HPS_DDR3_RAS_N,
    output             HPS_DDR3_RESET_N,
    input              HPS_DDR3_RZQ,
    output             HPS_DDR3_WE_N,
    output             HPS_ENET_GTX_CLK,
    inout              HPS_ENET_INT_N,
    output             HPS_ENET_MDC,
    inout              HPS_ENET_MDIO,
    input              HPS_ENET_RX_CLK,
    input       [3:0]  HPS_ENET_RX_DATA,
    input              HPS_ENET_RX_DV,
    output      [3:0]  HPS_ENET_TX_DATA,
    output             HPS_ENET_TX_EN,
    inout       [3:0]  HPS_FLASH_DATA,
    output             HPS_FLASH_DCLK,
    output             HPS_FLASH_NCSO,
    inout              HPS_GSENSOR_INT,
    inout              HPS_I2C1_SCLK,
    inout              HPS_I2C1_SDAT,
    inout              HPS_I2C2_SCLK,
    inout              HPS_I2C2_SDAT,
    inout              HPS_I2C_CONTROL,
    inout              HPS_KEY,
    inout              HPS_LED,
    inout              HPS_LTC_GPIO,
    output             HPS_SD_CLK,
    inout              HPS_SD_CMD,
    inout       [3:0]  HPS_SD_DATA,
    output             HPS_SPIM_CLK,
    input              HPS_SPIM_MISO,
    output             HPS_SPIM_MOSI,
    inout              HPS_SPIM_SS,
    input              HPS_UART_RX,
    output             HPS_UART_TX,
    input              HPS_USB_CLKOUT,
    inout       [7:0]  HPS_USB_DATA,
    input              HPS_USB_DIR,
    input              HPS_USB_NXT,
    output             HPS_USB_STP,
`endif /*ENABLE_HPS*/

    ///////// IRDA /////////
    input              IRDA_RXD,
    output             IRDA_TXD,

    ///////// KEY /////////
    input       [3:0]  KEY,

    ///////// LEDR /////////
    output      [9:0]  LEDR,

    ///////// PS2 /////////
    inout              PS2_CLK,
    inout              PS2_CLK2,
    inout              PS2_DAT,
    inout              PS2_DAT2,

    ///////// SW /////////
    input       [9:0]  SW,

    ///////// TD /////////
    input              TD_CLK27,
    input      [7:0]  TD_DATA,
    input             TD_HS,
    output             TD_RESET_N,
    input             TD_VS,

    ///////// VGA /////////
    output      [7:0]  VGA_B,
    output             VGA_BLANK_N,
    output             VGA_CLK,
    output      [7:0]  VGA_G,
    output             VGA_HS,
    output      [7:0]  VGA_R,
    output             VGA_SYNC_N,
    output             VGA_VS
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
// internal logics and registers declaration
bit  [3:0]  fpga_debounced_buttons;
bit         hps_0_h2f_reset_reset_n;

wire [7:0]  vid_r,vid_g,vid_b;
wire        vid_v_sync ;
wire        vid_h_sync ;
wire        vid_datavalid;
//////////// GPIO - 10" LCD  //////////
logic        midi_rxd;
logic        midi_txd;

assign  midi_rxd    = SW[0] ? GPIO_1[27]    : ~GPIO_1[27];
assign  GPIO_1[29]  = SW[0] ? midi_txd      : ~midi_txd;

// Display
assign   VGA_BLANK_N        =     1'b1;
assign   VGA_SYNC_N         =     1'b0;
assign   VGA_CLK            =     lcd_clk_75;
assign  {VGA_B,VGA_G,VGA_R} =     {vid_b,vid_g,vid_r};
assign   VGA_VS             =     vid_v_sync;
assign   VGA_HS             =     vid_h_sync;

assign {LCD_R,LCD_G,LCD_B}  = {vid_r,vid_g,vid_b};
assign LCD_DCLK             = lcd_clk_75;
assign LCD_HSD              = ~vid_h_sync;
assign LCD_VSD              = ~vid_v_sync;
assign LCD_DE               = vid_datavalid;

    logic [9:0]      cpu_adr;
    logic            cpu_write;
    logic            cpu_read;
    logic            cpu_chip_sel;
    logic [31:0]     cpu_data_out;
    logic [31:0]     cpu_data_in;
    logic            synth_irq_n;
    logic [2:0]      socmidi_addr;
    logic            socmidi_write;
    logic            socmidi_read;
    logic            socmidi_chip_sel;
    logic [7:0]      socmidi_data_out;
    logic [7:0]      socmidi_data_in;
    logic            socmidi_irq_n;
    assign socmidi_irq_n = 1'b1;
    assign synth_irq_n = 1'b1;
// sound dma
//    logic            OSC_CLK;
    logic [31:0] lsound_out;
    logic [31:0] rsound_out;
    logic [31:0] lsound_mixed_out;
    logic [31:0] rsound_mixed_out;
    logic        xxxx_zero;
    logic [31:0] i2s_output_apb_0_playback_fifo_data_R;
    logic [31:0] i2s_output_apb_0_playback_fifo_data_L;
    logic        i2s_playback_fifo_ack;
    logic        i2s_output_apb_0_playback_fifo_empty;
    logic        i2s_playback_enable;
    logic [31:0] i2s_output_apb_0_capture_fifo_data_R;
    logic [31:0] i2s_output_apb_0_capture_fifo_data_L;
    logic        i2s_output_apb_0_capture_fifo_full;
    logic        i2s_capture_enable;
    bit          i2s_clkctrl_apb_0_conduit_bclk;
    bit          i2s_clk;
    logic        AUDIO_CLK;
//=======================================================
//  Structural coding
//=======================================================

// Debounce logic to clean out glitches within 1ms
debounce debounce_inst (
.clk        (CLOCK_50),
.reset_n    (hps_0_h2f_reset_reset_n),
.data_in    (KEY),
.data_out   (fpga_debounced_buttons)
);
defparam debounce_inst.WIDTH            = 4;
defparam debounce_inst.POLARITY         = "LOW";
defparam debounce_inst.TIMEOUT          = 50000;        // at 50Mhz this is a debounce time of 1ms
defparam debounce_inst.TIMEOUT_WIDTH    = 16;     // ceil(log2(TIMEOUT))

assign HEX[0] = 7'b1000000;
assign HEX[1] = 7'b1111001;

logic lcd_clk_75;

soc_system u0 (
    .clk_clk                                                ( CLOCK_50),
    .reset_reset_n                                          ( hps_0_h2f_reset_reset_n),
    .memory_mem_a                                           ( HPS_DDR3_ADDR),
    .memory_mem_ba                                          ( HPS_DDR3_BA),
    .memory_mem_ck                                          ( HPS_DDR3_CK_P),
    .memory_mem_ck_n                                        ( HPS_DDR3_CK_N),
    .memory_mem_cke                                         ( HPS_DDR3_CKE),
    .memory_mem_cs_n                                        ( HPS_DDR3_CS_N),
    .memory_mem_ras_n                                       ( HPS_DDR3_RAS_N),
    .memory_mem_cas_n                                       ( HPS_DDR3_CAS_N),
    .memory_mem_we_n                                        ( HPS_DDR3_WE_N),
    .memory_mem_reset_n                                     ( HPS_DDR3_RESET_N),
    .memory_mem_dq                                          ( HPS_DDR3_DQ),
    .memory_mem_dqs                                         ( HPS_DDR3_DQS_P),
    .memory_mem_dqs_n                                       ( HPS_DDR3_DQS_N),
    .memory_mem_odt                                         ( HPS_DDR3_ODT),
    .memory_mem_dm                                          ( HPS_DDR3_DM),
    .memory_oct_rzqin                                       ( HPS_DDR3_RZQ),

    .hps_0_hps_io_hps_io_emac1_inst_TX_CLK                  ( HPS_ENET_GTX_CLK),
    .hps_0_hps_io_hps_io_emac1_inst_TXD0                    ( HPS_ENET_TX_DATA[0] ),
    .hps_0_hps_io_hps_io_emac1_inst_TXD1                    ( HPS_ENET_TX_DATA[1] ),
    .hps_0_hps_io_hps_io_emac1_inst_TXD2                    ( HPS_ENET_TX_DATA[2] ),
    .hps_0_hps_io_hps_io_emac1_inst_TXD3                    ( HPS_ENET_TX_DATA[3] ),
    .hps_0_hps_io_hps_io_emac1_inst_RXD0                    ( HPS_ENET_RX_DATA[0] ),
    .hps_0_hps_io_hps_io_emac1_inst_MDIO                    ( HPS_ENET_MDIO ),
    .hps_0_hps_io_hps_io_emac1_inst_MDC                     ( HPS_ENET_MDC  ),
    .hps_0_hps_io_hps_io_emac1_inst_RX_CTL                  ( HPS_ENET_RX_DV),
    .hps_0_hps_io_hps_io_emac1_inst_TX_CTL                  ( HPS_ENET_TX_EN),
    .hps_0_hps_io_hps_io_emac1_inst_RX_CLK                  ( HPS_ENET_RX_CLK),
    .hps_0_hps_io_hps_io_emac1_inst_RXD1                    ( HPS_ENET_RX_DATA[1] ),
    .hps_0_hps_io_hps_io_emac1_inst_RXD2                    ( HPS_ENET_RX_DATA[2] ),
    .hps_0_hps_io_hps_io_emac1_inst_RXD3                    ( HPS_ENET_RX_DATA[3] ),


    .hps_0_hps_io_hps_io_qspi_inst_IO0                      ( HPS_FLASH_DATA[0] ),
    .hps_0_hps_io_hps_io_qspi_inst_IO1                      ( HPS_FLASH_DATA[1] ),
    .hps_0_hps_io_hps_io_qspi_inst_IO2                      ( HPS_FLASH_DATA[2] ),
    .hps_0_hps_io_hps_io_qspi_inst_IO3                      ( HPS_FLASH_DATA[3] ),
    .hps_0_hps_io_hps_io_qspi_inst_SS0                      ( HPS_FLASH_NCSO ),
    .hps_0_hps_io_hps_io_qspi_inst_CLK                      ( HPS_FLASH_DCLK ),

    .hps_0_hps_io_hps_io_sdio_inst_CMD                      ( HPS_SD_CMD ),
    .hps_0_hps_io_hps_io_sdio_inst_D0                       ( HPS_SD_DATA[0] ),
    .hps_0_hps_io_hps_io_sdio_inst_D1                       ( HPS_SD_DATA[1] ),
    .hps_0_hps_io_hps_io_sdio_inst_CLK                      ( HPS_SD_CLK ),
    .hps_0_hps_io_hps_io_sdio_inst_D2                       ( HPS_SD_DATA[2] ),
    .hps_0_hps_io_hps_io_sdio_inst_D3                       ( HPS_SD_DATA[3] ),

    .hps_0_hps_io_hps_io_usb1_inst_D0                       ( HPS_USB_DATA[0] ),
    .hps_0_hps_io_hps_io_usb1_inst_D1                       ( HPS_USB_DATA[1] ),
    .hps_0_hps_io_hps_io_usb1_inst_D2                       ( HPS_USB_DATA[2] ),
    .hps_0_hps_io_hps_io_usb1_inst_D3                       ( HPS_USB_DATA[3] ),
    .hps_0_hps_io_hps_io_usb1_inst_D4                       ( HPS_USB_DATA[4] ),
    .hps_0_hps_io_hps_io_usb1_inst_D5                       ( HPS_USB_DATA[5] ),
    .hps_0_hps_io_hps_io_usb1_inst_D6                       ( HPS_USB_DATA[6] ),
    .hps_0_hps_io_hps_io_usb1_inst_D7                       ( HPS_USB_DATA[7] ),
    .hps_0_hps_io_hps_io_usb1_inst_CLK                      ( HPS_USB_CLKOUT ),
    .hps_0_hps_io_hps_io_usb1_inst_STP                      ( HPS_USB_STP ),
    .hps_0_hps_io_hps_io_usb1_inst_DIR                      ( HPS_USB_DIR ),
    .hps_0_hps_io_hps_io_usb1_inst_NXT                      ( HPS_USB_NXT ),

    .hps_0_hps_io_hps_io_spim1_inst_CLK                     ( HPS_SPIM_CLK ),
    .hps_0_hps_io_hps_io_spim1_inst_MOSI                    ( HPS_SPIM_MOSI ),
    .hps_0_hps_io_hps_io_spim1_inst_MISO                    ( HPS_SPIM_MISO ),
    .hps_0_hps_io_hps_io_spim1_inst_SS0                     ( HPS_SPIM_SS ),

    .hps_0_hps_io_hps_io_uart0_inst_RX                      ( HPS_UART_RX ),
    .hps_0_hps_io_hps_io_uart0_inst_TX                      ( HPS_UART_TX ),

    .hps_0_hps_io_hps_io_i2c0_inst_SDA                      ( HPS_I2C1_SDAT ),
    .hps_0_hps_io_hps_io_i2c0_inst_SCL                      ( HPS_I2C1_SCLK ),

    .hps_0_hps_io_hps_io_i2c1_inst_SDA                      ( HPS_I2C2_SDAT ),
    .hps_0_hps_io_hps_io_i2c1_inst_SCL                      ( HPS_I2C2_SCLK ),

    .hps_0_hps_io_hps_io_gpio_inst_GPIO09                   ( HPS_CONV_USB_N),
    .hps_0_hps_io_hps_io_gpio_inst_GPIO35                   ( HPS_ENET_INT_N),
    .hps_0_hps_io_hps_io_gpio_inst_GPIO40                   ( HPS_LTC_GPIO),
    .hps_0_hps_io_hps_io_gpio_inst_GPIO48                   ( HPS_I2C_CONTROL),
    .hps_0_hps_io_hps_io_gpio_inst_GPIO53                   ( HPS_LED),
    .hps_0_hps_io_hps_io_gpio_inst_GPIO54                   ( HPS_KEY),
    .hps_0_hps_io_hps_io_gpio_inst_GPIO61                   ( HPS_GSENSOR_INT),

    .led_pio_external_connection_export                     (),
    .dipsw_pio_external_connection_export                   ( SW ),
    .button_pio_external_connection_export                  ( fpga_debounced_buttons ),
    .hps_0_h2f_reset_reset_n                                (hps_0_h2f_reset_reset_n ),

    .lcd_clk_clk                                            (lcd_clk_75),

    //itc
    .alt_vip_cl_cvo_0_clocked_video_vid_clk                 (lcd_clk_75),
    .alt_vip_cl_cvo_0_clocked_video_vid_data                ({vid_r,vid_g,vid_b}),
    .alt_vip_cl_cvo_0_clocked_video_underflow               (),
    .alt_vip_cl_cvo_0_clocked_video_vid_datavalid           (vid_datavalid),
    .alt_vip_cl_cvo_0_clocked_video_vid_v_sync              (vid_v_sync),
    .alt_vip_cl_cvo_0_clocked_video_vid_h_sync              (vid_h_sync),
    .alt_vip_cl_cvo_0_clocked_video_vid_f                   (),
    .alt_vip_cl_cvo_0_clocked_video_vid_h                   (),
    .alt_vip_cl_cvo_0_clocked_video_vid_v                   (),
    .synthreg_io_uio_dataout                                (cpu_data_out),
    .synthreg_io_uio_address                                (cpu_adr),
    .synthreg_io_uio_read                                   (cpu_read),
    .synthreg_io_uio_chipsel                                (cpu_chip_sel),
    .synthreg_io_uio_datain                                 (cpu_data_in),
    .synthreg_io_uio_write                                  (cpu_write),
    .synthreg_io_uio_int_in_n                               (synth_irq_n),
    .socmidi_io_socmidi_dataout                             (socmidi_data_out),
    .socmidi_io_socmidi_address                             (socmidi_addr),
    .socmidi_io_socmidi_read                                (socmidi_read),
    .socmidi_io_socmidi_chipsel                             (socmidi_chip_sel),
    .socmidi_io_socmidi_datain                              (socmidi_data_in),
    .socmidi_io_socmidi_write                               (socmidi_write),
    .socmidi_io_socmidi_int_in                              (socmidi_irq_n),
    .pll_stream_locked_export                               (),
    .pll_audio_locked_export                                (),
    .hsynth_output_apb_0_capture_fifo_data                  ({rsound_out[31:0],lsound_out[31:0]}),
    .hsynth_output_apb_0_capture_fifo_write                 (xxxx_zero),
    .hsynth_output_apb_0_capture_fifo_full                  (),
    .hsynth_output_apb_0_capture_fifo_i2s_capture_enable    (),
    .hsynth_output_apb_0_capture_fifo_empty                 (),
    .i2s_clkctrl_api_0_conduit_aud_daclrclk                 (AUD_DACLRCK),
    .i2s_clkctrl_api_0_conduit_aud_bclk                     (AUD_BCLK),
    .i2s_clkctrl_api_0_conduit_bclk                         (i2s_clkctrl_apb_0_conduit_bclk),
    .i2s_clkctrl_api_0_conduit_aud_adclrclk                 (AUD_ADCLRCK),
    .i2s_clkctrl_api_0_mclk_clk                             (AUD_XCK),
    .i2s_clkctrl_api_0_i2s_clk_clk                          (i2s_clk),
    .i2s_output_apb_0_capture_fifo_data                     ({i2s_output_apb_0_capture_fifo_data_R,i2s_output_apb_0_capture_fifo_data_L}),
    .i2s_output_apb_0_capture_fifo_write                    (i2s_capture_fifo_write),
    .i2s_output_apb_0_capture_fifo_full                     (i2s_output_apb_0_capture_fifo_full),
    .i2s_output_apb_0_capture_fifo_i2s_capture_enable       (i2s_capture_enable),
    .i2s_output_apb_0_capture_fifo_empty                    (),
    .i2s_output_apb_0_playback_fifo_ack                     (i2s_playback_fifo_ack),
    .i2s_output_apb_0_playback_fifo_i2s_playback_enable     (i2s_playback_enable),
    .i2s_output_apb_0_playback_fifo_empty                   (i2s_output_apb_0_playback_fifo_empty),
    .i2s_output_apb_0_playback_fifo_full                    (),
    .i2s_output_apb_0_playback_fifo_data                    ({i2s_output_apb_0_playback_fifo_data_R,i2s_output_apb_0_playback_fifo_data_L}),
    .audio_clk                                              (AUDIO_CLK)
    );
// sound dma

    assign rsound_mixed_out = SW[9] ? rsound_out : i2s_output_apb_0_playback_fifo_data_R;
    assign lsound_mixed_out = SW[9] ? lsound_out : i2s_output_apb_0_playback_fifo_data_L;

    i2s_shift_out i2s_shift_out(
        .reset_n            (hps_0_h2f_reset_reset_n),
        .clk                (i2s_clk),

        .fifo_right_data    (rsound_mixed_out),
        .fifo_left_data     (lsound_mixed_out),
        .fifo_ready         (~i2s_output_apb_0_playback_fifo_empty),
        .fifo_ack           (i2s_playback_fifo_ack),

        .enable             (i2s_playback_enable),
        .bclk               (i2s_clkctrl_apb_0_conduit_bclk),
        .lrclk              (AUD_DACLRCK),
        .data_out           (AUD_DACDAT)
    );

    i2s_shift_in i2s_shift_in(
        .reset_n            (hps_0_h2f_reset_reset_n),
        .clk                (i2s_clk),

        .fifo_right_data    (i2s_output_apb_0_capture_fifo_data_R),
        .fifo_left_data     (i2s_output_apb_0_capture_fifo_data_L),
        .fifo_ready         (~i2s_output_apb_0_capture_fifo_full),
        .fifo_write         (i2s_capture_fifo_write),

        .enable             (i2s_capture_enable),
        .bclk               (i2s_clkctrl_apb_0_conduit_bclk),
        .lrclk              (AUD_ADCLRCK),
        .data_in            (AUD_ADCDAT)
    );

parameter VOICES = 32;
//parameter VOICES = 64;
//parameter VOICES = 4;
parameter V_OSC = 8;	// number of oscilators pr. voice.
//parameter V_OSC = 4;	// number of oscilators pr. voice.

parameter O_ENVS = 2;	// number of envelope generators pr. oscilator.
parameter V_ENVS = V_OSC * O_ENVS;	// number of envelope generators  pr. voice.

/////// LED Display ////////
    assign LEDR = voice_free[9:0];
    logic  [VOICES-1:0]	keys_on;
    logic  [VOICES-1:0]	voice_free;

    wire ad_xck = AUD_XCK;  			// violet
    wire ad_bclk = AUD_BCLK;			// orange
    wire ad_daclrck = AUD_DACLRCK;	// green
    wire ad_dacdat = AUD_DACDAT;	// white

    assign GPIO_1[9] = ad_xck;
    assign GPIO_1[7] = ad_bclk;
    assign GPIO_1[5] = ad_daclrck;
    assign GPIO_1[3] = ad_dacdat;

    reg [7:0]  delay_1;
    logic       iRST_n;
    wire run;
    assign GPIO_1[0] = run;

synthesizer #(.VOICES(VOICES),.V_OSC(V_OSC),.V_ENVS(V_ENVS))  synthesizer_inst(
    .CLOCK_50           (CLOCK2_50) ,
    .AUDIO_CLK          ( AUDIO_CLK ),             // input
    .reset_n            (hps_0_h2f_reset_reset_n),
    .trig               (AUD_DACLRCK),
    .MIDI_Rx_DAT        ( midi_rxd ) ,              // input  MIDI_DAT_sig (inverted due to inverter in rs232 chip)
    .midi_txd           ( midi_txd ),               // output midi transmit signal (inverted due to inverter in rs232 chip)
    .button             ( KEY ),                    //  Button[3:0]
`ifdef _Synth
    .lsound_out         (lsound_out),               //  Audio Raw Data Low
    .rsound_out         (rsound_out),               //  Audio Raw Data high
    .xxxx_zero          (xxxx_zero),                // output  cycle complete signag
`endif
    .keys_on            (keys_on),                  //  LED [7:0]
    .voice_free         (voice_free) ,              //  Red LED [4:1]
    .io_reset_n         (hps_0_h2f_reset_reset_n) , // input  io_reset_sig
    .cpu_read           (cpu_read) ,                // input  cpu_read_sig
    .cpu_write          (cpu_write) ,               // input  cpu_write_sig
    .chipselect         (cpu_chip_sel) ,            // input  chipselect_sig
    .address            (cpu_adr) ,                 // input [9:0] address_sig
    .writedata          (cpu_data_out) ,            // input [31:0] writedata_sig
    .readdata           (cpu_data_in),              // output [31:0] readdata_sig
    .socmidi_read       (socmidi_read) ,            // input  cpu_read_sig
    .socmidi_write      (socmidi_write) ,           // input  cpu_write_sig
    .socmidi_cs         (socmidi_chip_sel) ,        // input  chipselect_sig
    .socmidi_addr       (socmidi_addr) ,            // input [9:0] address_sig
    .socmidi_data_out   (socmidi_data_out) ,        // input [31:0] writedata_sig
    .socmidi_data_in    (socmidi_data_in),          // output [31:0] readdata_sig
    .run                (run),
    .switch3            (SW[2])                     // input
);

always @(negedge KEY[3] or posedge CLOCK_50)
    begin
        if ( !KEY[3])
            delay_1 <=0 ;
        else if ( !delay_1 [7] )
            delay_1 <= delay_1 + 1'b1;
    end

I2C_AV_Config u3  (   //  Host Side
    .iCLK  ( CLOCK_50 ),
    .iRST_N( delay_1[7] ),
//  I2C Side
    .I2C_SCLK(FPGA_I2C_SCLK),
    .I2C_SDAT(FPGA_I2C_SDAT)
);





endmodule
