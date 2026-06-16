// Curated RTL benchmark case.
// case_id: bench_0016_memory_core_ram_wb
// source_project: memory_core_ram_wb
// top_module: ram_wb


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/ram_wb_defines.v
// -----------------------------------------------------------------------------
`define RAM_WB_ADR_WIDTH 12
`define RAM_WB_MEM_SIZE 4096
`define RAM_WB_DAT_SIZE 32

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/ram_wb.v
// -----------------------------------------------------------------------------
module ram_wb ( dat_i, dat_o, adr_i, we_i, sel_i, cyc_i, stb_i, ack_o, cti_i, clk_i, rst_i);

   parameter dat_width = `RAM_WB_DAT_WIDTH;
   parameter adr_width = `RAM_WB_ADR_WIDTH;
   parameter mem_size  = `RAM_WB_MEM_SIZE;
   
   // wishbone signals
   input [31:0]          dat_i;   
   output [31:0]         dat_o;
   input [adr_width-1:2] adr_i;
   input 		 we_i;
   input [3:0] 		 sel_i;
   input 		 cyc_i;
   input 		 stb_i;
   output reg 		 ack_o;
   input [2:0] 		 cti_i;
   
   // clock
   input 		 clk_i;
   // async reset
   input 		 rst_i;
   
   wire [31:0] 		 wr_data;
   
   // mux for data to ram
   assign wr_data[31:24] = sel_i[3] ? dat_i[31:24] : dat_o[31:24];
   assign wr_data[23:16] = sel_i[2] ? dat_i[23:16] : dat_o[23:16];
   assign wr_data[15: 8] = sel_i[1] ? dat_i[15: 8] : dat_o[15: 8];
   assign wr_data[ 7: 0] = sel_i[0] ? dat_i[ 7: 0] : dat_o[ 7: 0];
   
   ram
     #
     (
      .dat_width(dat_width),
      .adr_width(adr_width),
      .mem_size(mem_size)
      )
     ram0
     (
      .dat_i(wr_data),
      .dat_o(dat_o),
      .adr_i(adr_i), 
      .we_i(we_i & ack_o),
      .clk(clk_i)
      );
 
   // ack_o
   always @ (posedge clk_i or posedge rst_i)
     if (rst_i)
       ack_o <= 1'b0;
     else
       if (!ack_o) begin
	 if (cyc_i & stb_i)
	   ack_o <= 1'b1; end  
       else
	 if ((sel_i != 4'b1111) | (cti_i == 3'b000) | (cti_i == 3'b111))
	   ack_o <= 1'b0;
         
endmodule
 
	      

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/ram_wb_sc_dw.v
// -----------------------------------------------------------------------------
// True dual port RAM as found in ACTEL proasic3 devices
module ram_sc_dw (d_a, q_a, adr_a, we_a, q_b, adr_b, d_b, we_b, clk);
   
   parameter dat_width = `RAM_WB_DAT_WIDTH;
   parameter adr_width = `RAM_WB_ADR_WIDTH;
   parameter mem_size  = `RAM_WB_MEM_SIZE;
   
   input [dat_width-1:0]      d_a;
   input [adr_width-1:0]      adr_a;
   input [adr_width-1:0]      adr_b;
   input 		      we_a;
   output reg [dat_width-1:0] q_b;
   input [dat_width-1:0]      d_b;
   output reg [dat_width-1:0] q_a;
   input 		      we_b;
   input 		      clk;   

   reg [dat_width-1:0] ram [0:mem_size - 1] /*synthesis syn_ramstyle = "no_rw_check"*/;
   
   always @ (posedge clk)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	  ram[adr_a] <= d_a;
     end
   
   always @ (posedge clk)
     begin 
	q_b <= ram[adr_b];
	if (we_b)
	  ram[adr_b] <= d_b;
     end
   
endmodule 

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/ram_wb_sc_dw_wrapper.v
// -----------------------------------------------------------------------------
// wrapper for the above dual port RAM
module ram (dat_i, dat_o, adr_i, we_i, clk );

   parameter dat_width = 32;
   parameter adr_width = 11;
   parameter mem_size  = 2048;
   
   input [dat_width-1:0]      dat_i;
   input [adr_width-1:0]      adr_i;
   input 		      we_i;
   output [dat_width-1:0]     dat_o;
   input 		      clk;   

   wire [dat_width-1:0]       q_b;
   
   ram_sc_dw
     /*
     #
     (
      .dat_width(dat_width),
      .adr_width(adr_width),
      .mem_size(mem_size)
      )
      */
     ram0
     (
      .d_a(dat_i),
      .q_a(dat_o),
      .adr_a(adr_i),
      .we_a(we_i),
      .q_b(q_b),
      .adr_b({adr_width{1'b0}}),
      .d_b({dat_width{1'b0}}),
      .we_b(1'b0),
      .clk(clk)
      );

endmodule // ram

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/ram_wb_sc_sw.v
// -----------------------------------------------------------------------------
module ram (dat_i, dat_o, adr_i, we_i, clk );

   parameter dat_width = 32;
   parameter adr_width = 11;
   parameter mem_size  = 2048;
   
   input [dat_width-1:0]      dat_i;
   input [adr_width-1:0]      adr_i;
   input 		      we_i;
   output reg [dat_width-1:0] dat_o;
   input 		      clk;   

   reg [dat_width-1:0] ram [0:mem_size - 1] /* synthesis ram_style = no_rw_check */;
   
   always @ (posedge clk)
     begin 
	dat_o <= ram[adr_i];
	if (we_i)
	  ram[adr_i] <= dat_i;
     end 

endmodule // ram

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/wb_ram_sc_sw.v
// -----------------------------------------------------------------------------
module ram (dat_i, dat_o, adr_i, we_i, clk );

   parameter dat_width = 32;
   parameter adr_width = 11;
   parameter mem_size  = 2048;
   
   input [dat_width-1:0]      dat_i;
   input [adr_width-1:0]      adr_i;
   input 		      we_i;
   output reg [dat_width-1:0] dat_o;
   input 		      clk;   

   reg [dat_width-1:0] ram [0:mem_size - 1] /* synthesis ram_style = no_rw_check */;
   
   always @ (posedge clk)
     begin 
	dat_o <= ram[adr_i];
	if (we_i)
	  ram[adr_i] <= dat_i;
     end 

endmodule // ram
