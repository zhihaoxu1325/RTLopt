// Curated RTL benchmark case.
// case_id: bench_0051_memory_core_directmappedcachecontroller
// source_project: memory_core_directmappedcachecontroller
// top_module: memory_bank


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/memory_bank.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "C:/cachedesign/v1/ise/src/global_params.vh"
`include "C:/cachedesign/v1/ise/src/memory_params.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    06:41:43 12/08/2009 
// Design Name: 
// Module Name:    memory_bank 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module memory_bank(CLK,EN,WE,SELECT,ADDR,DI,DO_BUF);
	input CLK,EN,WE;
	input [`OFFSET-1:0]SELECT;
	input [`ADDR_PORT_SIZE-1:0]ADDR;
	input [`DATA_PORT_SIZE-1:0] DI;
	output [`DATA_PORT_SIZE-1:0]DO_BUF;
		
	wire [`DATA_PORT_SIZE-1:0] DO;
	wire [`DATA_PORT_SIZE-1:0]DO0,DO1,DO2,DO3,DO4,DO5,DO6,DO7;
	wire [`DATA_PORT_SIZE-1:0]DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7;
	
	reg [`DATA_PORT_SIZE-1:0]REG_EN;
	
	bufif0_8bit bufout(DO_BUF,DO,WE);	// output buffer
	
	eight_to_one_mux_8bit mux(DO,{DO7,DO6,DO5,DO4,DO3,DO2,DO1,DO0},SELECT); // output mux
	
	initial REG_EN = 8'h00; // disable all banks for safe operation
	
	// Read burst and write normal
	always @(posedge CLK)
	begin
		REG_EN = 8'h00; // disable all banks
		if (EN) 
			begin
				if (WE) 
					begin
						REG_EN = 8'h00; // disable all banks
						
						case (ADDR[2:0])	// enable required single bank for normal write
							3'h0 : REG_EN = 8'h01;
							3'h1 : REG_EN = 8'h02;
							3'h2 : REG_EN = 8'h04;
							3'h3 : REG_EN = 8'h08;
							3'h4 : REG_EN = 8'h10;
							3'h5 : REG_EN = 8'h20;
							3'h6 : REG_EN = 8'h40;
							3'h7 : REG_EN = 8'h80; 
						endcase
						
					end 
				else 
					begin
						REG_EN = 8'hFF;	// enable all banks for burst read
						
					end
			end
		end
		
	// memory banks
	RAMB16_S8 bank0(CLK,REG_EN[0],WE,ADDR[13:3],DI0,DO0);
	RAMB16_S8 bank1(CLK,REG_EN[1],WE,ADDR[13:3],DI1,DO1);
	RAMB16_S8 bank2(CLK,REG_EN[2],WE,ADDR[13:3],DI2,DO2);
	RAMB16_S8 bank3(CLK,REG_EN[3],WE,ADDR[13:3],DI3,DO3);
	RAMB16_S8 bank4(CLK,REG_EN[4],WE,ADDR[13:3],DI4,DO4);
	RAMB16_S8 bank5(CLK,REG_EN[5],WE,ADDR[13:3],DI5,DO5);
	RAMB16_S8 bank6(CLK,REG_EN[6],WE,ADDR[13:3],DI6,DO6);
	RAMB16_S8 bank7(CLK,REG_EN[7],WE,ADDR[13:3],DI7,DO7);
	
	one_to_eight_demux_8bit demux({DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7},DI,ADDR[2:0]); // input mux
endmodule

// -----------------------------------------------------------------------------
// Source file: RAMB16_S8.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    06:35:12 12/08/2009 
// Design Name: 
// Module Name:    RAMB16_S8 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RAMB16_S8(CLK,EN,WE,ADDR,DI,DO);
	input CLK;
	input EN;
	input WE;
	input [10:0] ADDR;
	input [7:0] DI;
	output [7:0] DO;

	reg [7:0] RAM [2047:0];
	reg [10:0] REG_ADDR;
	
	// initialize memory
	reg [11:0]count;
	
	initial begin
		for (count=0;count<2048;count=count+1) RAM[count]=0;
	end

	always @(negedge CLK) 
		begin
			if (EN)
				begin
					if (WE) RAM[ADDR] <= DI;
					
					REG_ADDR <= ADDR;
				end
		end	
	assign DO = RAM[REG_ADDR];

endmodule

// -----------------------------------------------------------------------------
// Source file: bufif0_8bit.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    10:52:01 12/08/2009 
// Design Name: 
// Module Name:    bufif0_8bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module bufif0_8bit(buf_out, buf_in,ENB);
	output [7:0]buf_out;
	input [7:0]buf_in;
	input ENB;
	
   bufif0(buf_out[0],buf_in[0],ENB);
   bufif0(buf_out[1],buf_in[1],ENB);
   bufif0(buf_out[2],buf_in[2],ENB);
   bufif0(buf_out[3],buf_in[3],ENB);
   bufif0(buf_out[4],buf_in[4],ENB);
   bufif0(buf_out[5],buf_in[5],ENB);
   bufif0(buf_out[6],buf_in[6],ENB);
   bufif0(buf_out[7],buf_in[7],ENB);

endmodule

// -----------------------------------------------------------------------------
// Source file: eight_to_one_mux_8bit.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K
// 
// Create Date:    10:30:11 12/07/2009 
// Design Name: 
// Module Name:    eight_to_one_mux_8bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module eight_to_one_mux_8bit(mux_out,mux_in,select);
	output reg[7:0] mux_out;
	input [63:0]mux_in;
	input [2:0]select;
	
	always @(select, mux_in)
			case(select)
				3'b000:mux_out <= mux_in[7:0];
				3'b001:mux_out <= mux_in[15:8];
				3'b010:mux_out <= mux_in[23:16];
				3'b011:mux_out <= mux_in[31:24];
				3'b100:mux_out <= mux_in[39:32];
				3'b101:mux_out <= mux_in[47:40];
				3'b110:mux_out <= mux_in[55:48];
				3'b111:mux_out <= mux_in[63:56];
			endcase
endmodule


// -----------------------------------------------------------------------------
// Source file: memory_bank.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "C:/cachedesign/v1/ise/src/global_params.vh"
`include "C:/cachedesign/v1/ise/src/memory_params.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    06:41:43 12/08/2009 
// Design Name: 
// Module Name:    memory_bank 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module memory_bank(CLK,EN,WE,SELECT,ADDR,DI,DO_BUF);
	input CLK,EN,WE;
	input [`OFFSET-1:0]SELECT;
	input [`ADDR_PORT_SIZE-1:0]ADDR;
	input [`DATA_PORT_SIZE-1:0] DI;
	output [`DATA_PORT_SIZE-1:0]DO_BUF;
		
	wire [`DATA_PORT_SIZE-1:0] DO;
	wire [`DATA_PORT_SIZE-1:0]DO0,DO1,DO2,DO3,DO4,DO5,DO6,DO7;
	wire [`DATA_PORT_SIZE-1:0]DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7;
	
	reg [`DATA_PORT_SIZE-1:0]REG_EN;
	
	bufif0_8bit bufout(DO_BUF,DO,WE);	// output buffer
	
	eight_to_one_mux_8bit mux(DO,{DO7,DO6,DO5,DO4,DO3,DO2,DO1,DO0},SELECT); // output mux
	
	initial REG_EN = 8'h00; // disable all banks for safe operation
	
	// Read burst and write normal
	always @(posedge CLK)
	begin
		REG_EN = 8'h00; // disable all banks
		if (EN) 
			begin
				if (WE) 
					begin
						REG_EN = 8'h00; // disable all banks
						
						case (ADDR[2:0])	// enable required single bank for normal write
							3'h0 : REG_EN = 8'h01;
							3'h1 : REG_EN = 8'h02;
							3'h2 : REG_EN = 8'h04;
							3'h3 : REG_EN = 8'h08;
							3'h4 : REG_EN = 8'h10;
							3'h5 : REG_EN = 8'h20;
							3'h6 : REG_EN = 8'h40;
							3'h7 : REG_EN = 8'h80; 
						endcase
						
					end 
				else 
					begin
						REG_EN = 8'hFF;	// enable all banks for burst read
						
					end
			end
		end
		
	// memory banks
	RAMB16_S8 bank0(CLK,REG_EN[0],WE,ADDR[13:3],DI0,DO0);
	RAMB16_S8 bank1(CLK,REG_EN[1],WE,ADDR[13:3],DI1,DO1);
	RAMB16_S8 bank2(CLK,REG_EN[2],WE,ADDR[13:3],DI2,DO2);
	RAMB16_S8 bank3(CLK,REG_EN[3],WE,ADDR[13:3],DI3,DO3);
	RAMB16_S8 bank4(CLK,REG_EN[4],WE,ADDR[13:3],DI4,DO4);
	RAMB16_S8 bank5(CLK,REG_EN[5],WE,ADDR[13:3],DI5,DO5);
	RAMB16_S8 bank6(CLK,REG_EN[6],WE,ADDR[13:3],DI6,DO6);
	RAMB16_S8 bank7(CLK,REG_EN[7],WE,ADDR[13:3],DI7,DO7);
	
	one_to_eight_demux_8bit demux({DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7},DI,ADDR[2:0]); // input mux
endmodule

// -----------------------------------------------------------------------------
// Source file: one_to_eight_demux_8bit.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    10:14:47 12/08/2009 
// Design Name: 
// Module Name:    one_to_eight_demux_8bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module one_to_eight_demux_8bit(d,demux_in,select);
	output [63:0]d;
	input [7:0]demux_in;
	input [2:0]select;
	
	three_to_eight_decoder DEC0({d[0],d[8],d[16],d[24],d[32],d[40],d[48],d[56]},select,demux_in[0]);
	three_to_eight_decoder DEC1({d[1],d[9],d[17],d[25],d[33],d[41],d[49],d[57]},select,demux_in[1]);
	three_to_eight_decoder DEC2({d[2],d[10],d[18],d[26],d[34],d[42],d[50],d[58]},select,demux_in[2]);
	three_to_eight_decoder DEC3({d[3],d[11],d[19],d[27],d[35],d[43],d[51],d[59]},select,demux_in[3]);
	three_to_eight_decoder DEC4({d[4],d[12],d[20],d[28],d[36],d[44],d[52],d[60]},select,demux_in[4]);
	three_to_eight_decoder DEC5({d[5],d[13],d[21],d[29],d[37],d[45],d[53],d[61]},select,demux_in[5]);
	three_to_eight_decoder DEC6({d[6],d[14],d[22],d[30],d[38],d[46],d[54],d[62]},select,demux_in[6]);
	three_to_eight_decoder DEC7({d[7],d[15],d[23],d[31],d[39],d[47],d[55],d[63]},select,demux_in[7]);
	
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/RAMB16_S8.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    06:35:12 12/08/2009 
// Design Name: 
// Module Name:    RAMB16_S8 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RAMB16_S8(CLK,EN,WE,ADDR,DI,DO);
	input CLK;
	input EN;
	input WE;
	input [10:0] ADDR;
	input [7:0] DI;
	output [7:0] DO;

	reg [7:0] RAM [2047:0];
	reg [10:0] REG_ADDR;
	
	// initialize memory
	reg [11:0]count;
	
	initial begin
		for (count=0;count<2048;count=count+1) RAM[count]=0;
	end

	always @(negedge CLK) 
		begin
			if (EN)
				begin
					if (WE) RAM[ADDR] <= DI;
					
					REG_ADDR <= ADDR;
				end
		end	
	assign DO = RAM[REG_ADDR];

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/bufif0_8bit.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    10:52:01 12/08/2009 
// Design Name: 
// Module Name:    bufif0_8bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module bufif0_8bit(buf_out, buf_in,ENB);
	output [7:0]buf_out;
	input [7:0]buf_in;
	input ENB;
	
   bufif0(buf_out[0],buf_in[0],ENB);
   bufif0(buf_out[1],buf_in[1],ENB);
   bufif0(buf_out[2],buf_in[2],ENB);
   bufif0(buf_out[3],buf_in[3],ENB);
   bufif0(buf_out[4],buf_in[4],ENB);
   bufif0(buf_out[5],buf_in[5],ENB);
   bufif0(buf_out[6],buf_in[6],ENB);
   bufif0(buf_out[7],buf_in[7],ENB);

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/eight_to_one_mux_8bit.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K
// 
// Create Date:    10:30:11 12/07/2009 
// Design Name: 
// Module Name:    eight_to_one_mux_8bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module eight_to_one_mux_8bit(mux_out,mux_in,select);
	output reg[7:0] mux_out;
	input [63:0]mux_in;
	input [2:0]select;
	
	always @(select, mux_in)
			case(select)
				3'b000:mux_out <= mux_in[7:0];
				3'b001:mux_out <= mux_in[15:8];
				3'b010:mux_out <= mux_in[23:16];
				3'b011:mux_out <= mux_in[31:24];
				3'b100:mux_out <= mux_in[39:32];
				3'b101:mux_out <= mux_in[47:40];
				3'b110:mux_out <= mux_in[55:48];
				3'b111:mux_out <= mux_in[63:56];
			endcase
endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/one_to_eight_demux_8bit.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    10:14:47 12/08/2009 
// Design Name: 
// Module Name:    one_to_eight_demux_8bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module one_to_eight_demux_8bit(d,demux_in,select);
	output [63:0]d;
	input [7:0]demux_in;
	input [2:0]select;
	
	three_to_eight_decoder DEC0({d[0],d[8],d[16],d[24],d[32],d[40],d[48],d[56]},select,demux_in[0]);
	three_to_eight_decoder DEC1({d[1],d[9],d[17],d[25],d[33],d[41],d[49],d[57]},select,demux_in[1]);
	three_to_eight_decoder DEC2({d[2],d[10],d[18],d[26],d[34],d[42],d[50],d[58]},select,demux_in[2]);
	three_to_eight_decoder DEC3({d[3],d[11],d[19],d[27],d[35],d[43],d[51],d[59]},select,demux_in[3]);
	three_to_eight_decoder DEC4({d[4],d[12],d[20],d[28],d[36],d[44],d[52],d[60]},select,demux_in[4]);
	three_to_eight_decoder DEC5({d[5],d[13],d[21],d[29],d[37],d[45],d[53],d[61]},select,demux_in[5]);
	three_to_eight_decoder DEC6({d[6],d[14],d[22],d[30],d[38],d[46],d[54],d[62]},select,demux_in[6]);
	three_to_eight_decoder DEC7({d[7],d[15],d[23],d[31],d[39],d[47],d[55],d[63]},select,demux_in[7]);
	
endmodule
