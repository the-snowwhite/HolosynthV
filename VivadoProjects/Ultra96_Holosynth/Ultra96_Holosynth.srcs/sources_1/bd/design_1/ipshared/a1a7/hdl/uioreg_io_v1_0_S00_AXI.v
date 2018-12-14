
`timescale 1 ns / 1 ps

	module uioreg_io_v1_0_S00_AXI #
	(
		// Users to add parameters here

        parameter integer ADDRESS_WIDTH     = 10,
        parameter integer DATA_WIDTH        = 8,

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 16
	)
	(
		// Users to add ports here
	
        output reg [DATA_WIDTH-1:0]     con_dataout,
        input  wire [DATA_WIDTH-1:0]    con_datain,
        output reg  [ADDRESS_WIDTH+1:2] con_adrout,
        output reg                      con_write_out,
        output reg                      con_read_out,

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// I/O Connections assignments

	assign S_AXI_AWREADY   = axi_awready;
	assign S_AXI_WREADY    = axi_wready;
	assign S_AXI_BRESP     = axi_bresp;
	assign S_AXI_BVALID    = axi_bvalid;
	assign S_AXI_ARREADY   = axi_arready;
	assign S_AXI_RDATA     = axi_rdata;
	assign S_AXI_RRESP     = axi_rresp;
	assign S_AXI_RVALID    = axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	reg [2:0] aw_en_dly;
	reg [2:0] awready_dly;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      awready_dly <= 3'b0;
//	      aw_en <= 1'b1;
	      aw_en <= 1'b0;
	      aw_en_dly <= 3'b1;
	    end 
	  else
	    begin
          aw_en_dly[1] <= aw_en_dly[0];
          aw_en_dly[2] <= aw_en_dly[1];
          aw_en <= aw_en_dly[2];
          awready_dly[1] <= awready_dly[0];
          awready_dly[2] <= awready_dly[1];
          axi_awready <= awready_dly[2];
//	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	      if (~awready_dly[0] && S_AXI_AWVALID && S_AXI_WVALID && aw_en_dly[0])
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
//	          axi_awready <= 1'b1;
	          awready_dly[0] <= 1'b1;
//	          aw_en <= 1'b0;
              aw_en_dly[0] <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
//	              aw_en <= 1'b1;
	              aw_en_dly[0] <= 1'b1;
//	              axi_awready <= 1'b0;
	              awready_dly[0] <= 1'b0;
	            end
	      else           
	        begin
//	          axi_awready <= 1'b0;
	          awready_dly[0] <= 1'b0;
	        end
	    end 
	end     
	
//	reg write_dly;
	
	always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
//          write_dly <= 4'b0;
          con_write_out <= 1'b0;
        end 
      else
        begin
//          write_dly[1] <= write_dly[0];
//          write_dly[2] <= write_dly[1];
//          write_dly[3] <= write_dly[2];
//          write_dly[4] <= write_dly[3];
//          con_write_out <= write_dly ;
            if(S_AXI_AWVALID && axi_awready)
            begin
//              write_dly <= 1'b1;
              con_write_out <= 1'b1;
            end    
            else           
            begin
//              write_dly <= 1'b0;
              con_write_out <= 1'b0;
            end
	    end 
    end     

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 
	
	reg [3:0] wready_dly;
	
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      wready_dly <= 3'b0;
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin
	      wready_dly[1] <= wready_dly[0];
	      wready_dly[2] <= wready_dly[1];
	      axi_wready <= wready_dly[2];
//	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	      if (~wready_dly[0] && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
//	          axi_wready <= 1'b1;
	          wready_dly[0] <= 1'b1;
	        end
	      else
	        begin
//	          axi_wready <= 1'b0;
	          wready_dly[0] <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.

	//	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
	assign slv_reg_wren = wready_dly[0] && S_AXI_WVALID && awready_dly[0] && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	       con_dataout <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        if ( S_AXI_WSTRB[1] == 1 ) begin
	           con_dataout <= S_AXI_WDATA[DATA_WIDTH-1:0];
	        end
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

   
/*    
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       
    */
    reg [3:0] arready_dly;
	
	always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          arready_dly <= 3'b0;
          axi_arready <= 1'b0;
          con_adrout <= 0;
        end
        else begin
            arready_dly[1]  <= arready_dly[0];
            arready_dly[2]  <= arready_dly[1];
            arready_dly[3]  <= arready_dly[2];
            axi_arready     <= arready_dly[3];
            if (~arready_dly[0] && S_AXI_ARVALID) begin
                arready_dly[0] <= 1'b1;
                con_adrout  <= S_AXI_ARADDR[ADDRESS_WIDTH+1:2];
            end
//            else if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
//            else if (~awready_dly[0] && S_AXI_AWVALID && S_AXI_WVALID && aw_en_dly[0]) begin
            else if (~awready_dly[0] && S_AXI_AWVALID) begin
                con_adrout  <= S_AXI_AWADDR[ADDRESS_WIDTH+1:2];
            end
            else begin
                arready_dly[0]  <= 1'b0;
            end
        end
      end 

//    reg read_dly;
	
	always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 4'b0 )
        begin
//          read_dly <= 1'b0;
          con_read_out <= 1'b0;
        end 
      else
        begin
//          read_dly[1] <= read_dly[0];
//          read_dly[2] <= read_dly[1];
//          con_read_out <= read_dly;
          if(S_AXI_ARVALID && axi_arready)
            begin
//              read_dly <= 1'b1;
              con_read_out <= 1'b1;
            end    
	      else           
            begin
//              read_dly  <= 1'b0;
              con_read_out  <= 1'b0;
            end
	    end 
    end     

//    reg [4:0] rvalid_dly;
    reg [2:0] rvalid_dly;

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	      rvalid_dly  <= 3'b0;
	    end 
	  else
	    begin
	      rvalid_dly[1]    <=  rvalid_dly[0];  
	      rvalid_dly[2]    <=  rvalid_dly[1];  
//	      rvalid_dly[3]    <=  rvalid_dly[2];  
//	      rvalid_dly[4]    <=  rvalid_dly[3];  
//	      rvalid_dly[5]    <=  rvalid_dly[4];  
	      axi_rvalid       <=  rvalid_dly[1];  
//	      if (axi_rvalid) begin axi_rresp  <= 2'b0; end // 'OKAY' response
	      if (rvalid_dly[2]) begin axi_rresp  <= 2'b0; end // 'OKAY' response
//	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	      if (axi_arready && S_AXI_ARVALID && ~rvalid_dly[0])
	        begin
	          // Valid read data is available at the read data bus
//	          axi_rvalid <= 1'b1;
	          rvalid_dly[0] <= 1'b1;
	        end   
//	      else if (axi_rvalid && S_AXI_RREADY)
	      else if (rvalid_dly[0] && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
//	          axi_rvalid <= 1'b0;
	          rvalid_dly[0] <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = S_AXI_RREADY & rvalid_dly[1] & ~axi_rvalid;
/*	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= slv_reg0;
	        2'h1   : reg_data_out <= slv_reg1;
	        2'h2   : reg_data_out <= slv_reg2;
	        2'h3   : reg_data_out <= slv_reg3;
	        default : reg_data_out <= 0;
	      endcase
	end
*/
	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
//	          axi_rdata <= reg_data_out;     // register read data
	          axi_rdata[DATA_WIDTH-1:0] <= con_datain;     // register read data
	        end   
	    end
	end    

	// Add user logic here/
//	assign con_adrout = axi_araddr;
	// User logic ends

	endmodule