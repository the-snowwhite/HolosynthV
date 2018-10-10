module clk_divider #(parameter N = 8) (
    input            clk_clkin,
    input            reset_n,
    input    [N-1:0]    max_count,
    output reg        q
);
    reg [N-1:0] counter;
    always @(posedge clk_clkin or negedge reset_n)
    begin
        if (~reset_n)
        begin
            q <= 0;
            counter <= 0;
        end
        else
        begin
            if (counter == max_count)
            begin
                counter <= 0;
                q <= ~q;
            end
            else
                counter <= counter + 1;
        end
    end
endmodule
