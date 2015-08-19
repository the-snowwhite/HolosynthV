module address_decoder (
    input         CLOCK_25,
    input         reset_reg_N,
    input         data_ready,
    input   [2:0] bank_adr,

    output 	reg   read_write ,
	 output 	reg	write_dataenable, 
    output  reg   env_sel,
    output  reg   osc_sel,
    output  reg   m1_sel,
    output  reg   m2_sel,
    output  reg   com_sel
);

    reg syx_data_rdy_r[3:0];
    reg [2:0] syx_bank_adr_r;


    always @(posedge CLOCK_25)begin
        syx_bank_adr_r <= bank_adr;
        syx_data_rdy_r[0] <= data_ready;
        syx_data_rdy_r[1] <= syx_data_rdy_r[0];
        syx_data_rdy_r[2] <= syx_data_rdy_r[1];
        syx_data_rdy_r[3] <= syx_data_rdy_r[2];
        read_write  <= syx_data_rdy_r[2];
        write_dataenable  <= syx_data_rdy_r[3] || syx_data_rdy_r[2];
    end
    always @(negedge reset_reg_N or posedge syx_data_rdy_r[1]) begin
        if (!reset_reg_N)begin
            env_sel <= 0;
            osc_sel <= 0;
            m1_sel <= 0;
            m2_sel <= 0;
            com_sel <= 0;
        end
        else begin
            case (syx_bank_adr_r)
                3'd0: begin env_sel<=1'b1;osc_sel<=1'b0;m1_sel<=1'b0;m2_sel<=1'b0;com_sel<=1'b0;end
                3'd1: begin env_sel<=1'b0;osc_sel<=1'b1;m1_sel<=1'b0;m2_sel<=1'b0;com_sel<=1'b0;end
                3'd2: begin env_sel<=1'b0;osc_sel<=1'b0;m1_sel<=1'b1;m2_sel<=1'b0;com_sel<=1'b0;end
                3'd3: begin env_sel<=1'b0;osc_sel<=1'b0;m1_sel<=1'b0;m2_sel<=1'b1;com_sel<=1'b0;end
                3'd5: begin env_sel<=1'b0;osc_sel<=1'b0;m1_sel<=1'b0;m2_sel<=1'b0;com_sel<=1'b1;end
                default: begin env_sel <= 0; osc_sel <= 0; m1_sel <= 0; m2_sel <= 0; com_sel <= 0; end
            endcase
        end
    end

endmodule
