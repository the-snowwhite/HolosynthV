module audio_clock_generator (
    input            clk_clkin,
    input            reset_n,
    input    [31:0]  cmd_reg1,
    input    [31:0]  cmd_reg2,
    output           mclk,
    output           bclk,
    input            lrclk_clear,
    output           lrclk1,
    output           lrclk2
);

    wire [7:0]        mclk_divisor = cmd_reg1[31:24]; // divide by (n + 1)*2
    wire [7:0]        bclk_divisor = cmd_reg1[23:16]; // divide by (n + 1)*2
    wire [7:0]        lrclk1_divisor = cmd_reg2[15:8]; // divide by (n + 1)*2*16
    wire [7:0]        lrclk2_divisor = cmd_reg2[7:0]; // divide by (n + 1)*2*16

    clk_divider #(.N(8)) mclk_divider (
        .clk_clkin    (clk_clkin),
        .reset_n      (reset_n),
        .max_count    (mclk_divisor),
        .q            (mclk)
    );
    clk_divider #(.N(8)) bclk_divider (
        .clk_clkin    (clk_clkin),
        .reset_n      (reset_n),
        .max_count    (bclk_divisor),
        .q            (bclk)
    );
    clk_divider #(.N(12)) lrclk1_divider (
        .clk_clkin    (clk_clkin),
        .reset_n      (reset_n & ~lrclk_clear),
        .max_count    ({lrclk1_divisor, 4'b1111}),
        .q            (lrclk1)
    );
    clk_divider #(.N(12)) lrclk2_divider (
        .clk_clkin    (clk_clkin),
        .reset_n      (reset_n & ~lrclk_clear),
        .max_count    ({lrclk2_divisor, 4'b1111}),
        .q            (lrclk2)
    );
endmodule
