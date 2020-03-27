module audio_i2s_driver #(
parameter AUD_BIT_DEPTH = 24
) (
    input wire              reset_reg_N,
    input wire              iAUD_DACLRCK,
    input wire              iAUDB_CLK,
    input wire [AUD_BIT_DEPTH-1:0]  i_lsound_out,
    input wire [AUD_BIT_DEPTH-1:0]  i_rsound_out,
    output wire             oAUD_DACDAT
);

    reg [4:0]         SEL_Cont;
    reg signed [AUD_BIT_DEPTH-1:0] sound_out; // 
    reg reg_edge_detected;
    reg reg_lrck_dly;

    wire edge_detected = reg_lrck_dly ^ iAUD_DACLRCK;

////////////        SoundOut        ///////////////
    always@(posedge iAUDB_CLK)begin
        reg_edge_detected <= edge_detected;
    end

    always@(negedge iAUDB_CLK or negedge reset_reg_N)begin
        if(!reset_reg_N)begin
            SEL_Cont    <=  5'h0;
            reg_lrck_dly <= 1'b0;
            sound_out <= 'b0;
        end
        else begin
            reg_lrck_dly <= iAUD_DACLRCK;

            if (reg_edge_detected) begin 	SEL_Cont <= 5'h0; 				end // i2s mode 1 bclk delay
            else begin 						SEL_Cont <= SEL_Cont + 1'b1;	end

            if (SEL_Cont == 5'h1f) begin
                if (iAUD_DACLRCK) begin 	sound_out <= i_rsound_out; end
                else begin 				    sound_out <= i_lsound_out; end
            end
        end
    end

// // `ifdef _32BitAudio
// //     assign  oAUD_DACDAT   =  (SEL_Cont <= AUD_BIT_DEPTH-1) ? sound_out[(~SEL_Cont)] : 1'b0; // 32-bits
// `elsif _24BitAudio
    assign  oAUD_DACDAT   =  (SEL_Cont <= AUD_BIT_DEPTH-1) ? sound_out[(~SEL_Cont)-(32-AUD_BIT_DEPTH)] : 1'b0; // 24-bits
// `else
//     assign  oAUD_DACDAT   =  (SEL_Cont <= AUD_BIT_DEPTH-1 ) ? sound_out[~SEL_Cont[4:0]] : 1'b0; // 16-bits
// `endif

endmodule
