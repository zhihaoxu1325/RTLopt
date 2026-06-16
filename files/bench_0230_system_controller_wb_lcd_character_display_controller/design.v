// Curated RTL benchmark case.
// case_id: bench_0230_system_controller_wb_lcd_character_display_controller
// source_project: system_controller_wb_lcd_character_display_controller
// top_module: system


// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace/rtl/lcd_defines.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  lcd_defines.v                                               ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Set of core customization defines.                       ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


///
/// LCD Controller defines
///
`define ADDR_WIDTH 7			// Address bus width
`define ADDR_RNG `ADDR_WIDTH-1:0	// Address bus range
`define DAT_WIDTH 8			// data bus width
`define DAT_RNG `DAT_WIDTH-1:0		// Address bus range
`define MEM_LENGTH 67			// Number of LCD memory positions.
`define MEM_ADDR_WIDTH 7		// Memory address bus width
`define MEM_LOW1  `ADDR_WIDTH'h00 //0	// Memory address of the first character at the first line
`define MEM_HIGH1 `ADDR_WIDTH'h15 //21	// Memory address of the last character at the first line
`define MEM_LOW2  `ADDR_WIDTH'h40 //64	// Memory address of the first character at the second line
`define MEM_HIGH2 `ADDR_WIDTH'h55 //85	// Memory address of the last character at the second line

`define INIT_DELAY_COUNTER_WIDTH 20	// Delay cycle counter width for init & main FSM
`define TX_DELAY_COUNTER_WIDTH 11	// Delay cycle counter width for TX FSM
`define _1MS_DELAY_CYCLES 50		// Number of cycles for a 1ms delay

///
/// WB wrapper defines
///

// WB interface
`define WB_DAT_WIDTH 32			// WB data bus width
`define WB_DAT_RNG `WB_DAT_WIDTH-1:0	// WB data bus range
`define WB_ADDR_WIDTH 32		// WB address bus width
`define WB_ADDR_RNG `WB_ADDR_WIDTH-1:0	// WB address bus range
`define WB_BSEL_WIDTH 4			// WB byte sel bus width
`define WB_BSEL_RNG `WB_BSEL_WIDTH-1:0	// WB byte sel bus range
`define ADDRESS_BIT


// Command and status registers address mask
`define SPECIAL_REG_ADDR_MASK 32'h00000080

// LCD characters memory mapping
`define FIRST_LCD_ADDR 0			// Address at where first LCD character is mapped (0)

// Command register and command codes
`define COMMAND_REG_ADDR 32'h00000080		// Address at where command register is mapped (128)
`define COMMAND_NOP_CODE 32'h00000000		// Code for repaint command	
`define COMMAND_REPAINT_CODE 32'h00000001	// Code for repaint command

// Status register and status codes
`define STATUS_REG_ADDR 32'h00000080		// Address at where status register is mapped (129)
`define STATUS_IDDLE_CODE 32'h00000000		// Code for iddle status
`define STATUS_BUSY_CODE 32'h00000001		// Code for busy status


// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace_ramless/rtl/lcd_defines.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  lcd_defines.v                                               ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Set of core customization defines.                       ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


///
/// LCD Controller defines
///
`define ADDR_WIDTH 7			// Address bus width
`define ADDR_RNG `ADDR_WIDTH-1:0	// Address bus range
`define DAT_WIDTH 8			// data bus width
`define DAT_RNG `DAT_WIDTH-1:0		// Address bus range
`define MEM_LENGTH 67			// Number of LCD memory positions.
`define MEM_ADDR_WIDTH 7		// Memory address bus width
`define MEM_LOW1  `ADDR_WIDTH'h00 //0	// Memory address of the first character at the first line
`define MEM_HIGH1 `ADDR_WIDTH'h0F //21	// Memory address of the last character at the first line
`define MEM_LOW2  `ADDR_WIDTH'h40 //64	// Memory address of the first character at the second line
`define MEM_HIGH2 `ADDR_WIDTH'h4F //85	// Memory address of the last character at the second line

`define INIT_DELAY_COUNTER_WIDTH 20	// Delay cycle counter width for init & main FSM
`define TX_DELAY_COUNTER_WIDTH 11	// Delay cycle counter width for TX FSM
`define _1MS_DELAY_CYCLES 50		// Number of cycles for a 1ms delay

///
/// WB wrapper defines
///

// WB interface
`define WB_DAT_WIDTH 32			// WB data bus width
`define WB_DAT_RNG `WB_DAT_WIDTH-1:0	// WB data bus range
`define WB_ADDR_WIDTH 32		// WB address bus width
`define WB_ADDR_RNG `WB_ADDR_WIDTH-1:0	// WB address bus range
`define WB_BSEL_WIDTH 4			// WB byte sel bus width
`define WB_BSEL_RNG `WB_BSEL_WIDTH-1:0	// WB byte sel bus range
`define ADDRESS_BIT


// Command and status registers address mask
`define SPECIAL_REG_ADDR_MASK 32'h00000080

// LCD characters memory mapping
`define FIRST_LCD_ADDR 0			// Address at where first LCD character is mapped (0)

// Command register and command codes
`define COMMAND_REG_ADDR 32'h00000080		// Address at where command register is mapped (128)
`define COMMAND_NOP_CODE 32'h00000000		// Code for repaint command	
`define COMMAND_REPAINT_CODE 32'h00000001	// Code for repaint command

// Status register and status codes
`define STATUS_REG_ADDR 32'h00000080		// Address at where status register is mapped (129)
`define STATUS_IDDLE_CODE 32'h00000000		// Code for iddle status
`define STATUS_BUSY_CODE 32'h00000001		// Code for busy status


// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd_ramless/rtl/lcd_defines.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  lcd_defines.v                                               ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Set of core customization defines.                       ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


///
/// LCD Controller defines
///
`define ADDR_WIDTH 7			// Address bus width
`define ADDR_RNG `ADDR_WIDTH-1:0	// Address bus range
`define DAT_WIDTH 8			// data bus width
`define DAT_RNG `DAT_WIDTH-1:0		// Address bus range
`define MEM_LENGTH 67			// Number of LCD memory positions.
`define MEM_ADDR_WIDTH 7		// Memory address bus width
`define MEM_LOW1  `ADDR_WIDTH'h00 //0	// Memory address of the first character at the first line
`define MEM_HIGH1 `ADDR_WIDTH'h0F //21	// Memory address of the last character at the first line
`define MEM_LOW2  `ADDR_WIDTH'h40 //64	// Memory address of the first character at the second line
`define MEM_HIGH2 `ADDR_WIDTH'h4F //85	// Memory address of the last character at the second line

`define INIT_DELAY_COUNTER_WIDTH 20	// Delay cycle counter width for init & main FSM
`define TX_DELAY_COUNTER_WIDTH 11	// Delay cycle counter width for TX FSM
`define _1MS_DELAY_CYCLES 50		// Number of cycles for a 1ms delay

///
/// WB wrapper defines
///

// WB interface
`define WB_DAT_WIDTH 32			// WB data bus width
`define WB_DAT_RNG `WB_DAT_WIDTH-1:0	// WB data bus range
`define WB_ADDR_WIDTH 32		// WB address bus width
`define WB_ADDR_RNG `WB_ADDR_WIDTH-1:0	// WB address bus range
`define WB_BSEL_WIDTH 4			// WB byte sel bus width
`define WB_BSEL_RNG `WB_BSEL_WIDTH-1:0	// WB byte sel bus range
`define ADDRESS_BIT


// Command and status registers address mask
`define SPECIAL_REG_ADDR_MASK 32'h00000080

// LCD characters memory mapping
`define FIRST_LCD_ADDR 0			// Address at where first LCD character is mapped (0)

// Command register and command codes
`define COMMAND_REG_ADDR 32'h00000080		// Address at where command register is mapped (128)
`define COMMAND_NOP_CODE 32'h00000000		// Code for repaint command	
`define COMMAND_REPAINT_CODE 32'h00000001	// Code for repaint command

// Status register and status codes
`define STATUS_REG_ADDR 32'h00000080		// Address at where status register is mapped (129)
`define STATUS_IDDLE_CODE 32'h00000000		// Code for iddle status
`define STATUS_BUSY_CODE 32'h00000001		// Code for busy status


// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd/rtl/lcd_defines.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  lcd_defines.v                                               ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Set of core customization defines.                       ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


///
/// LCD Controller defines
///
`define ADDR_WIDTH 7			// Address bus width
`define ADDR_RNG `ADDR_WIDTH-1:0	// Address bus range
`define DAT_WIDTH 8			// data bus width
`define DAT_RNG `DAT_WIDTH-1:0		// Address bus range
`define MEM_LENGTH 67			// Number of LCD memory positions.
`define MEM_ADDR_WIDTH 7		// Memory address bus width
`define MEM_LOW1  `ADDR_WIDTH'h00 //0	// Memory address of the first character at the first line
`define MEM_HIGH1 `ADDR_WIDTH'h0F //21	// Memory address of the last character at the first line
`define MEM_LOW2  `ADDR_WIDTH'h40 //64	// Memory address of the first character at the second line
`define MEM_HIGH2 `ADDR_WIDTH'h4F //85	// Memory address of the last character at the second line

`define INIT_DELAY_COUNTER_WIDTH 20	// Delay cycle counter width for init & main FSM
`define TX_DELAY_COUNTER_WIDTH 11	// Delay cycle counter width for TX FSM
`define _1MS_DELAY_CYCLES 50		// Number of cycles for a 1ms delay

///
/// WB wrapper defines
///

// WB interface
`define WB_DAT_WIDTH 32			// WB data bus width
`define WB_DAT_RNG `WB_DAT_WIDTH-1:0	// WB data bus range
`define WB_ADDR_WIDTH 32		// WB address bus width
`define WB_ADDR_RNG `WB_ADDR_WIDTH-1:0	// WB address bus range
`define WB_BSEL_WIDTH 4			// WB byte sel bus width
`define WB_BSEL_RNG `WB_BSEL_WIDTH-1:0	// WB byte sel bus range
`define ADDRESS_BIT


// Command and status registers address mask
`define SPECIAL_REG_ADDR_MASK 32'h00000080

// LCD characters memory mapping
`define FIRST_LCD_ADDR 0			// Address at where first LCD character is mapped (0)

// Command register and command codes
`define COMMAND_REG_ADDR 32'h00000080		// Address at where command register is mapped (128)
`define COMMAND_NOP_CODE 32'h00000000		// Code for repaint command	
`define COMMAND_REPAINT_CODE 32'h00000001	// Code for repaint command

// Status register and status codes
`define STATUS_REG_ADDR 32'h00000080		// Address at where status register is mapped (129)
`define STATUS_IDDLE_CODE 32'h00000000		// Code for iddle status
`define STATUS_BUSY_CODE 32'h00000001		// Code for busy status


// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd/boards/s3esk-wb_lcd/rtl/system.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Wishbone controller testbench implementation for         ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------

reg	[`DAT_RNG]	dat = 8'b00100000;
wire	[`WB_DAT_RNG]	wb_dat = {24'b0, dat};
reg	[`ADDR_WIDTH:0] 	addr = 0;
wire	[`WB_ADDR_RNG]	wb_addr = {24'b0, addr};
wire	[`WB_DAT_RNG]	status;
wire 			busy = status[0];
reg cs = 0;
reg we = 0;
wire ack;
wb_lcd lcd  (
	//
	// I/O Ports
	//
	.wb_clk_i	( clk ),
	.wb_rst_i	( reset),
	
	//
	// WB slave interface
	//
	.wb_dat_i	( wb_dat ),
	.wb_dat_o	( status ),
	.wb_adr_i	( wb_addr ),
	.wb_sel_i	(  ),
	.wb_we_i	( we ),
	.wb_cyc_i	( cs  ),
	.wb_stb_i	( cs ),
	.wb_ack_o	( ack ),
	.wb_err_o	(  ),

	//
	// LCD interface
	//
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	
//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;

reg wait_for_ack = 0;
wire stall;
assign stall = (wait_for_ack & ~ack);

// Handles transfers to the display
integer i = 0;
always @(posedge clk) 
begin
	if(reset) begin
		i <= 0;
		cs <= 1;
		we <= 1;
		addr <= 0;
		dat <= start_dat;
		
		led <= 8'b00100000;
		start_dat <= 8'b00100000;
	end else if(~stall) begin
		if (i < 104) begin
			i <= i + 1;
			cs <= 1;
			we <= 1'b1;
			addr <= addr + 1;
			dat <= dat + 1;
			wait_for_ack <= 1;
		end else if (i == 104) begin
			if(!busy) begin
				i <= i + 1;
				cs <= 1;
				addr <= 8'b10000000; // Command register
				dat <=  8'b00000001; // Repaint command
				we <= 1'b1;
				wait_for_ack <= 1;
			end else begin
				cs <= 0;
				wait_for_ack <= 0;
			end

		end else if (i == 105) begin
			i <= i + 1;
			cs <= 0;
			we <= 1'b0;
			wait_for_ack <= 0;
		end else if (rot_event && rot_left && !busy) begin
			i <= 0;
			led <= led - 1;
			start_dat <= start_dat - 1;

			cs <= 1;		
			addr <= 0;
			we <= 1'b1;
			dat <= start_dat - 1;
			wait_for_ack <= 1;
		end else if (rot_event && !busy) begin
			i <= 0;
			led <= led + 1;
			start_dat <= start_dat + 1;	

			cs <= 1;		
			addr <= 0;
			we <= 1'b1;
			dat <= start_dat + 1;
			wait_for_ack <= 1;
		end
	end
end
 

//		  1'b1
//		  2'b01, 
//		  4'b0011,
//		  8'b00001111,
//		 16'b0000000011111111,
//		 32'b00000000000000001111111111111111

//	{reset, busy, cs, we, ack, wb_dat[7:0], status[7:0], i, {10,1'b0}}
endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace/boards/s3esk-mm_lcd/rtl/rotary.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace/boards/s3esk-mm_lcd/rtl/system.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Memory mapped controller testbench implementation for    ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////      - Grupo ID2 http://www.dte.us.es/id2/                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------


wire busy;
reg repaint = 0;
reg [`DAT_RNG]  dat = 8'b00100000;
reg [`ADDR_RNG] addr = 0;
reg we = 0;

lcd lcd(
	.clk		( clk ),
	.reset	( reset),
	
	.dat		( dat ),
	.addr		( addr ),
	.we		( we ),
	.repaint	( repaint ),
	
	.busy		( busy ),
	.SF_D		( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	
	);
	
//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;


// Handles transfers to the display
integer i = 0;
always @(posedge clk) 
begin
	if(reset) begin
		i <= 0;
		repaint <= 0;
		
		we <= 1;
		addr <= 0;
		dat <= start_dat;
		
		led <= 8'b00100000;
		start_dat <= 8'b00100000;
	end if (i < 104) begin
		i <= i + 1;
		repaint <= 0;
		
		we <= 1'b1;
		addr <= addr + 1;
		dat <= dat + 1;
	end if (i == 104 && !busy) begin
		i <= i + 1;
		repaint <= 1;
		we <= 1'b0;

	end if (i == 105) begin
		i <= i + 1;
		repaint <= 0;
		we <= 1'b0;
	end else if (rot_event && rot_left && !busy) begin
		i <= 0;
		led <= led - 1;
		start_dat <= start_dat - 1;
		
		addr <= 0;
		repaint <= 0;
		we <= 1'b1;
		dat <= start_dat - 1;
	end else if (rot_event && !busy) begin
		i <= 0;
		led <= led + 1;
		start_dat <= start_dat + 1;	
		
		addr <= 0;
		repaint <= 0;
		we <= 1'b1;
		dat <= start_dat + 1;
	end
end
 

endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace/boards/s3esk-wb_lcd/rtl/rotary.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace/boards/s3esk-wb_lcd/rtl/system.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Wishbone controller testbench implementation for         ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------

reg	[`DAT_RNG]	dat = 8'b00100000;
wire	[`WB_DAT_RNG]	wb_dat = {24'b0, dat};
reg	[`ADDR_WIDTH:0] 	addr = 0;
wire	[`WB_ADDR_RNG]	wb_addr = {24'b0, addr};
wire	[`WB_DAT_RNG]	status;
wire 			busy = status[0];
reg cs = 0;
reg we = 0;
wire ack;
wb_lcd lcd  (
	//
	// I/O Ports
	//
	.wb_clk_i	( clk ),
	.wb_rst_i	( reset),
	
	//
	// WB slave interface
	//
	.wb_dat_i	( wb_dat ),
	.wb_dat_o	( status ),
	.wb_adr_i	( wb_addr ),
	.wb_sel_i	(  ),
	.wb_we_i	( we ),
	.wb_cyc_i	( cs  ),
	.wb_stb_i	( cs ),
	.wb_ack_o	( ack ),
	.wb_err_o	(  ),

	//
	// LCD interface
	//
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	
//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;

reg wait_for_ack = 0;
wire stall;
assign stall = (wait_for_ack & ~ack);

// Handles transfers to the display
integer i = 0;
always @(posedge clk) 
begin
	if(reset) begin
		i <= 0;
		cs <= 1;
		we <= 1;
		addr <= 0;
		dat <= start_dat;
		
		led <= 8'b00100000;
		start_dat <= 8'b00100000;
	end else if(~stall) begin
		if (i < 104) begin
			i <= i + 1;
			cs <= 1;
			we <= 1'b1;
			addr <= addr + 1;
			dat <= dat + 1;
			wait_for_ack <= 1;
		end else if (i == 104) begin
			if(!busy) begin
				i <= i + 1;
				cs <= 1;
				addr <= 8'b10000000; // Command register
				dat <=  8'b00000001; // Repaint command
				we <= 1'b1;
				wait_for_ack <= 1;
			end else begin
				cs <= 0;
				wait_for_ack <= 0;
			end

		end else if (i == 105) begin
			i <= i + 1;
			cs <= 0;
			we <= 1'b0;
			wait_for_ack <= 0;
		end else if (rot_event && rot_left && !busy) begin
			i <= 0;
			led <= led - 1;
			start_dat <= start_dat - 1;

			cs <= 1;		
			addr <= 0;
			we <= 1'b1;
			dat <= start_dat - 1;
			wait_for_ack <= 1;
		end else if (rot_event && !busy) begin
			i <= 0;
			led <= led + 1;
			start_dat <= start_dat + 1;	

			cs <= 1;		
			addr <= 0;
			we <= 1'b1;
			dat <= start_dat + 1;
			wait_for_ack <= 1;
		end
	end
end
 

//		  1'b1
//		  2'b01, 
//		  4'b0011,
//		  8'b00001111,
//		 16'b0000000011111111,
//		 32'b00000000000000001111111111111111

//	{reset, busy, cs, we, ack, wb_dat[7:0], status[7:0], i, {10,1'b0}}
endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace/rtl/delay_counter.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  delay_counter.v                                             ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   -  Delay down counter.                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module delay_counter #(
	parameter counter_width = 32
) (
	input clk,
	input reset,

	input [counter_width-1:0] count,	
	input load,
	output done
	);



reg [counter_width-1:0] counter;

always @(posedge clk)
	if(load)
		counter <= count;
	else if (!done)
		counter <= counter - 1'b1;
	
	
assign done = (counter == 0);


endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace/rtl/lcd_display.v
// -----------------------------------------------------------------------------
// File: lcd.v
// Generated by MyHDL 0.6
// Date: Wed Apr 15 12:33:13 2009

`timescale 1ns/10ps

module lcd (
    clk,
    reset,
    dat,
    addr,
    we,
    repaint,
    busy,
    SF_D,
    LCD_E,
    LCD_RS,
    LCD_RW
);

input clk;
input reset;
input [31:0] dat;
input [6:0] addr;
input we;
input repaint;
output busy;
wire busy;
output [3:0] SF_D;
reg [3:0] SF_D;
output LCD_E;
reg LCD_E;
output LCD_RS;
wire LCD_RS;
output LCD_RW;
wire LCD_RW;

wire tx_init;
reg [8:0] pos;
wire delay_load;
reg tx_done;
reg [3:0] SF_D1;
reg [3:0] SF_D0;
reg LCD_E1;
reg LCD_E0;
wire delay_done;
reg [7:0] tx_byte;
wire output_selector;
reg [4:0] state;
reg [19:0] tx_delay_value;
reg [19:0] main_delay_value;
reg tx_delay_load;
reg [19:0] delay_value;
reg main_delay_load;
reg [2:0] tx_state;
reg [20:0] counter_counter;

reg [7:0] ram [0:80-1];



assign output_selector = ((state == 5'b00000) | (state == 5'b00001) | (state == 5'b00010) | (state == 5'b00011) | (state == 5'b00100) | (state == 5'b00101) | (state == 5'b00110) | (state == 5'b00111) | (state == 5'b01000) | (state == 5'b01001));

always @(main_delay_value, tx_delay_load, tx_delay_value) begin: LCD_CONUNTER_SHARING_VALUE
    if (tx_delay_load) begin
        delay_value <= tx_delay_value;
    end
    else begin
        delay_value <= main_delay_value;
    end
end

always @(posedge clk, posedge reset) begin: LCD_TXFSM
    if ((reset == 1)) begin
        tx_state <= 3'b110;
        SF_D0 <= 0;
        LCD_E0 <= 0;
    end
    else begin
        tx_delay_load <= 0;
        
        tx_delay_value <= 0;
        
        // synthesis parallel_case full_case
        casez (tx_state)
            3'b000: begin
                LCD_E0 <= 0;
                SF_D0 <= tx_byte[8-1:4];
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b001;
                    tx_delay_load <= 1;
                    tx_delay_value <= 12;
                end
            end
            3'b001: begin
                LCD_E0 <= 1;
                SF_D0 <= tx_byte[8-1:4];
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b010;
                    tx_delay_load <= 1;
                    tx_delay_value <= 50;
                end
            end
            3'b010: begin
                LCD_E0 <= 0;
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b011;
                    tx_delay_load <= 1;
                    tx_delay_value <= 2;
                end
            end
            3'b011: begin
                LCD_E0 <= 0;
                SF_D0 <= tx_byte[4-1:0];
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b100;
                    tx_delay_load <= 1;
                    tx_delay_value <= 12;
                end
            end
            3'b100: begin
                LCD_E0 <= 1;
                SF_D0 <= tx_byte[4-1:0];
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b101;
                    tx_delay_load <= 1;
                    tx_delay_value <= 2000;
                end
            end
            3'b101: begin
                LCD_E0 <= 0;
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b110;
                    tx_done <= 1;
                end
            end
            3'b110: begin
                LCD_E0 <= 0;
                tx_done <= 0;
                tx_delay_load <= 0;
                if (tx_init) begin
                    tx_state <= 3'b000;
                    tx_delay_load <= 1;
                    tx_delay_value <= 2;
                end
            end
        endcase
    end
end


assign delay_load = (tx_delay_load || main_delay_load);


assign busy = (state != 5'b10100);
assign LCD_RW = 0;

always @(SF_D1, SF_D0, LCD_E1, LCD_E0, output_selector) begin: LCD_OUTPUT_TX_OR_INIT_MUX
    if (output_selector) begin
        SF_D <= SF_D1;
        LCD_E <= LCD_E1;
    end
    else begin
        SF_D <= SF_D0;
        LCD_E <= LCD_E0;
    end
end

always @(posedge clk) begin: LCD_MEMWRITE
    if (we) begin
        ram[addr] <= dat;
    end
end

always @(posedge clk, posedge reset) begin: LCD_DISPLAYFSM
    if ((reset == 1)) begin
        state <= 5'b00000;
        main_delay_load <= 0;
        main_delay_value <= 0;
        SF_D1 <= 0;
        LCD_E1 <= 0;
        tx_byte <= 0;
        pos <= 0;
    end
    else begin
        main_delay_load <= 0;
        
        main_delay_value <= 0;
        
        // synthesis parallel_case full_case
        casez (state)
            5'b00000: begin
                tx_byte <= 0;
                state <= 5'b00001;
                main_delay_load <= 1;
                main_delay_value <= 750000;
            end
            5'b00001: begin
                main_delay_load <= 0;
                if (delay_done) begin
                    state <= 5'b00010;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 11;
                end
            end
            5'b00010: begin
                main_delay_load <= 0;
                SF_D1 <= 3;
                LCD_E1 <= 1;
                if (delay_done) begin
                    state <= 5'b00011;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 205000;
                end
            end
            5'b00011: begin
                main_delay_load <= 0;
                LCD_E1 <= 0;
                if (delay_done) begin
                    state <= 5'b00100;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 11;
                end
            end
            5'b00100: begin
                main_delay_load <= 0;
                SF_D1 <= 3;
                LCD_E1 <= 1;
                if (delay_done) begin
                    state <= 5'b00101;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 5000;
                end
            end
            5'b00101: begin
                main_delay_load <= 0;
                LCD_E1 <= 0;
                if (delay_done) begin
                    state <= 5'b00110;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 11;
                end
            end
            5'b00110: begin
                main_delay_load <= 0;
                SF_D1 <= 3;
                LCD_E1 <= 1;
                if (delay_done) begin
                    state <= 5'b00111;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 2000;
                end
            end
            5'b00111: begin
                main_delay_load <= 0;
                LCD_E1 <= 0;
                if (delay_done) begin
                    state <= 5'b01000;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 11;
                end
            end
            5'b01000: begin
                main_delay_load <= 0;
                SF_D1 <= 2;
                LCD_E1 <= 1;
                if (delay_done) begin
                    state <= 5'b01001;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 2000;
                end
            end
            5'b01001: begin
                main_delay_load <= 0;
                LCD_E1 <= 0;
                if (delay_done) begin
                    state <= 5'b01010;
                    
                end
            end
            5'b01010: begin
                tx_byte <= 40;
                if (tx_done) begin
                    state <= 5'b01011;
                end
            end
            5'b01011: begin
                tx_byte <= 6;
                if (tx_done) begin
                    state <= 5'b01100;
                end
            end
            5'b01100: begin
                tx_byte <= 12;
                if (tx_done) begin
                    state <= 5'b01101;
                end
            end
            5'b01101: begin
                tx_byte <= 1;
                if (tx_done) begin
                    state <= 5'b01110;
                    main_delay_load <= 1;
                    main_delay_value <= 82000;
                end
            end
            5'b01110: begin
                state <= 5'b01111;
            end
            5'b01111: begin
                tx_byte <= 0;
                if (delay_done) begin
                    state <= 5'b10000;
                    
                end
            end
            5'b10000: begin
                tx_byte <= 128;
                if (tx_done) begin
                    state <= 5'b10001;
                    pos <= 0;
                end
            end
            5'b10001: begin
                tx_byte <= ram[pos];
                if (tx_done) begin
                    if ((pos == 15)) begin
                        state <= 5'b10010;
                        
                    end
                    else begin
                        pos <= (pos + 1);
                    end
                end
            end
            5'b10010: begin
                tx_byte <= 192;
                if (tx_done) begin
                    state <= 5'b10011;
                    pos <= 64;
                end
            end
            5'b10011: begin
                tx_byte <= ram[pos];
                if (tx_done) begin
                    if ((pos == 79)) begin
                        state <= 5'b10100;
                        
                    end
                    else begin
                        pos <= (pos + 1);
                    end
                end
            end
            5'b10100: begin
                tx_byte <= 0;
                if (repaint) begin
                    state <= 5'b01010;
                end
                else begin
                    state <= 5'b10100;
                end
            end
        endcase
    end
end


assign delay_done = (counter_counter == 0);

always @(posedge clk) begin: LCD_COUNTER_COUNTDOWN_LOGIC
    if (delay_load) begin
        counter_counter <= delay_value;
    end
    else begin
        counter_counter <= (counter_counter - 1);
    end
end


assign tx_init = ((~tx_done) & ((state == 5'b01010) | (state == 5'b01011) | (state == 5'b01100) | (state == 5'b01101) | (state == 5'b10000) | (state == 5'b10001) | (state == 5'b10010) | (state == 5'b10011)));
assign LCD_RS = (~(((state == 5'b01010) != 0) | (state == 5'b01011) | (state == 5'b01100) | (state == 5'b01101) | (state == 5'b10000) | (state == 5'b10010)));

endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace/rtl/wb_lcd.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wb_lcd.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   -  Wishbone wrapper.                                       ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module wb_lcd (
	//
	// I/O Ports
	//
	input			wb_clk_i,
	input			wb_rst_i,

	//
	// WB slave interface
	//
	input	[`WB_DAT_RNG]	wb_dat_i,
	output	reg [`WB_DAT_RNG]	wb_dat_o,
	input	[`WB_ADDR_RNG]	wb_adr_i,
	input	[`WB_BSEL_RNG]	wb_sel_i,
	input			wb_we_i,
	input			wb_cyc_i,
	input			wb_stb_i,
	output	reg		wb_ack_o,
	output			wb_err_o,
	
	//
	// LCD interface
	//
	output	[3:0]		SF_D,
	output			LCD_E,
	output			LCD_RS,
	output			LCD_RW
	);
	

assign wb_err_o = 0;

wire cs = wb_cyc_i & wb_stb_i;
wire we = cs & wb_we_i;
wire re = cs & !wb_we_i;
wire special_address = (`SPECIAL_REG_ADDR_MASK == (`SPECIAL_REG_ADDR_MASK & wb_adr_i));

wire lcd_busy;
wire lcd_we = !special_address & we;
wire [`ADDR_WIDTH-1:0] lcd_addr = wb_adr_i[`ADDR_WIDTH-1:0];

wire repaint_req =  we & (wb_adr_i == `COMMAND_REG_ADDR) & (wb_dat_i == `COMMAND_REPAINT_CODE);
wire status = lcd_busy ? `STATUS_BUSY_CODE : `STATUS_IDDLE_CODE;


// wb_ack management: two clk cycles per WB access to avoid long combinational paths.
always @(posedge wb_clk_i) begin
	if(wb_rst_i)
		wb_ack_o <= 1'b0;
	else begin
		if(cs)
			wb_ack_o <= ~wb_ack_o;
		else
			wb_ack_o <= 1'b0;
	end
end

// Status register (only checks if lcd is busy)
always @(posedge wb_clk_i) // wb_dat_o always outputs the status register not depending on what address is being accessed
	wb_dat_o = status;

// Command register (only issues repaint commands)
reg lcd_repaint = 0;
always @(posedge wb_clk_i) begin
	if(repaint_req & !lcd_busy)
		lcd_repaint <= 1;
	else
		lcd_repaint <= 0;
end

//----------------------------------------------------------------------------
// Memory mapped LCD display controller
//----------------------------------------------------------------------------

lcd lcd(
	.clk	( wb_clk_i ),
	.reset	( wb_rst_i ),
	
	.dat	( wb_dat_i[`DAT_RNG] ),
	.addr	( lcd_addr ),
	.we	( lcd_we ),
	.repaint( lcd_repaint ),
	
	.busy	( lcd_busy ),	
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	


endmodule


// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace_ramless/boards/s3esk-mm_lcd/rtl/rotary.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace_ramless/boards/s3esk-mm_lcd/rtl/system.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Memory mapped controller testbench implementation for    ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////      - Grupo ID2 http://www.dte.us.es/id2/                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------


wire busy;
reg [`DAT_RNG]  dat = 8'b00100000;
reg [`ADDR_RNG] addr = 0;
wire we;



lcd lcd(
	.clk	( clk ),
	.reset	( reset),
	
	.dat	( dat ),
	.addr	( addr ),
	.we	( we ),
	.busy	( busy ),
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	
	);



//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash
integer i = 0;
assign we = (i < 104) & ~busy;

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;



// Handles transfers to the display

always @(posedge clk) 
begin
	if(reset) begin
		i <= 0;
		addr <= 0;
		dat <= start_dat;
		
		led <= 8'b00100000;
		start_dat <= 8'b00100000;
	end else begin
		if (i < 104 && !busy) begin
			i <= i + 1;
			addr <= addr + 1;
			dat <= dat + 1;
		end else if (rot_event && rot_left && !busy) begin
			i <= 0;
			led <= led - 1;
			start_dat <= start_dat - 1;
		
			addr <= 0;
			dat <= start_dat - 1;
		end else if (rot_event && !busy) begin
			i <= 0;
			led <= led + 1;
			start_dat <= start_dat + 1;	
		
			addr <= 0;
			dat <= start_dat + 1;
		end
	end 
end
 

endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace_ramless/boards/s3esk-wb_lcd/rtl/rotary.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace_ramless/boards/s3esk-wb_lcd/rtl/system.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Wishbone controller testbench implementation for         ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------

reg	[`DAT_RNG]	dat = 8'b00100000;
wire	[`WB_DAT_RNG]	wb_dat = {24'b0, dat};
reg	[`ADDR_WIDTH:0] addr = 0;
wire	[`WB_ADDR_RNG]	wb_addr = {24'b0, addr};
wire	[`WB_DAT_RNG]	status;
wire 			busy = status[0];
wire cs;
wire we;
wire ack;

wb_lcd lcd  (
	//
	// I/O Ports
	//
	.wb_clk_i	( clk ),
	.wb_rst_i	( reset),
	
	//
	// WB slave interface
	//
	.wb_dat_i	( wb_dat ),
	.wb_dat_o	( status ),
	.wb_adr_i	( wb_addr ),
	.wb_sel_i	(  ),
	.wb_we_i	( we ),
	.wb_cyc_i	( cs  ),
	.wb_stb_i	( cs ),
	.wb_ack_o	( ack ),

	//
	// LCD interface
	//
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	
//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;

integer i = 0;
assign we = (i < 104) & ~busy;
assign cs = (i < 104);
			
// Handles transfers to the display
always @(posedge clk) 
begin
	if(reset) begin
		led <= 8'b00100000;
		start_dat <= 8'b00100000;

		i <= 0;
		addr <= 0;
		dat <= start_dat;
	end else begin
		if (i < 104 && !busy) begin
			i <= i + 1;
			addr <= addr + 1;
			dat <= dat + 1;
		end else if (rot_event && rot_left && !busy) begin
			led <= led - 1;
			start_dat <= start_dat - 1;

			i <= 0;
			addr <= 0;
			dat <= start_dat - 1;
		end else if (rot_event && !busy) begin
			led <= led + 1;
			start_dat <= start_dat + 1;	

			i <= 0;
			addr <= 0;
			dat <= start_dat + 1;
		end
	end
end
 
endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace_ramless/rtl/lcd_display.v
// -----------------------------------------------------------------------------
// File: lcd.v
// Generated by MyHDL 0.6
// Date: Thu Apr 16 10:52:36 2009

`timescale 1ns/10ps

module lcd (
    clk,
    reset,
    dat,
    addr,
    we,
    busy,
    SF_D,
    LCD_E,
    LCD_RS,
    LCD_RW
);

input clk;
input reset;
input [31:0] dat;
input [6:0] addr;
input we;
output busy;
wire busy;
output [3:0] SF_D;
reg [3:0] SF_D;
output LCD_E;
reg LCD_E;
output LCD_RS;
wire LCD_RS;
output LCD_RW;
wire LCD_RW;

wire tx_init;
wire delay_load;
reg tx_done;
reg [3:0] SF_D1;
reg [3:0] SF_D0;
reg LCD_E1;
reg LCD_E0;
wire delay_done;
reg [7:0] tx_byte;
reg [6:0] wr_addr;
wire output_selector;
reg [4:0] state;
reg [19:0] tx_delay_value;
reg [19:0] main_delay_value;
reg tx_delay_load;
reg [19:0] delay_value;
reg [6:0] wr_dat;
reg main_delay_load;
reg [2:0] tx_state;
reg [20:0] counter_counter;




assign output_selector = ((state == 5'b00000) | (state == 5'b00001) | (state == 5'b00010) | (state == 5'b00011) | (state == 5'b00100) | (state == 5'b00101) | (state == 5'b00110) | (state == 5'b00111) | (state == 5'b01000) | (state == 5'b01001));

always @(main_delay_value, tx_delay_load, tx_delay_value) begin: LCD_CONUNTER_SHARING_VALUE
    if (tx_delay_load) begin
        delay_value <= tx_delay_value;
    end
    else begin
        delay_value <= main_delay_value;
    end
end

always @(posedge clk, posedge reset) begin: LCD_DISPLAYFSM
    if ((reset == 1)) begin
        state <= 5'b00000;
        main_delay_load <= 0;
        main_delay_value <= 0;
        SF_D1 <= 0;
        LCD_E1 <= 0;
        tx_byte <= 0;
    end
    else begin
        main_delay_load <= 0;
        
        main_delay_value <= 0;
        
        // synthesis parallel_case full_case
        casez (state)
            5'b00000: begin
                tx_byte <= 0;
                state <= 5'b00001;
                main_delay_load <= 1;
                main_delay_value <= 750000;
            end
            5'b00001: begin
                main_delay_load <= 0;
                if (delay_done) begin
                    state <= 5'b00010;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 11;
                end
            end
            5'b00010: begin
                main_delay_load <= 0;
                SF_D1 <= 3;
                LCD_E1 <= 1;
                if (delay_done) begin
                    state <= 5'b00011;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 205000;
                end
            end
            5'b00011: begin
                main_delay_load <= 0;
                LCD_E1 <= 0;
                if (delay_done) begin
                    state <= 5'b00100;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 11;
                end
            end
            5'b00100: begin
                main_delay_load <= 0;
                SF_D1 <= 3;
                LCD_E1 <= 1;
                if (delay_done) begin
                    state <= 5'b00101;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 5000;
                end
            end
            5'b00101: begin
                main_delay_load <= 0;
                LCD_E1 <= 0;
                if (delay_done) begin
                    state <= 5'b00110;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 11;
                end
            end
            5'b00110: begin
                main_delay_load <= 0;
                SF_D1 <= 3;
                LCD_E1 <= 1;
                if (delay_done) begin
                    state <= 5'b00111;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 2000;
                end
            end
            5'b00111: begin
                main_delay_load <= 0;
                LCD_E1 <= 0;
                if (delay_done) begin
                    state <= 5'b01000;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 11;
                end
            end
            5'b01000: begin
                main_delay_load <= 0;
                SF_D1 <= 2;
                LCD_E1 <= 1;
                if (delay_done) begin
                    state <= 5'b01001;
                    
                    main_delay_load <= 1;
                    main_delay_value <= 2000;
                end
            end
            5'b01001: begin
                main_delay_load <= 0;
                LCD_E1 <= 0;
                if (delay_done) begin
                    state <= 5'b01010;
                    
                end
            end
            5'b01010: begin
                tx_byte <= 40;
                if (tx_done) begin
                    state <= 5'b01011;
                end
            end
            5'b01011: begin
                tx_byte <= 6;
                if (tx_done) begin
                    state <= 5'b01100;
                end
            end
            5'b01100: begin
                tx_byte <= 12;
                if (tx_done) begin
                    state <= 5'b01101;
                end
            end
            5'b01101: begin
                tx_byte <= 1;
                if (tx_done) begin
                    state <= 5'b01111;
                    main_delay_load <= 1;
                    main_delay_value <= 82000;
                end
            end
            5'b01110: begin
                state <= 5'b01111;
            end
            5'b01111: begin
                tx_byte <= 0;
                if (delay_done) begin
                    state <= 5'b10000;
                    
                end
            end
            5'b10000: begin
                tx_byte <= 0;
                if (we) begin
                    state <= 5'b10001;
                    wr_addr <= addr;
                    wr_dat <= dat;
                end
                else begin
                    state <= 5'b10000;
                end
            end
            5'b10001: begin
                tx_byte <= (128 | wr_addr);
                if (tx_done) begin
                    state <= 5'b10010;
                end
            end
            5'b10010: begin
                tx_byte <= wr_dat;
                if (tx_done) begin
                    state <= 5'b10000;
                    
                end
            end
        endcase
    end
end

always @(posedge clk, posedge reset) begin: LCD_TXFSM
    if ((reset == 1)) begin
        tx_state <= 3'b110;
        SF_D0 <= 0;
        LCD_E0 <= 0;
    end
    else begin
        tx_delay_load <= 0;
        
        tx_delay_value <= 0;
        
        // synthesis parallel_case full_case
        casez (tx_state)
            3'b000: begin
                LCD_E0 <= 0;
                SF_D0 <= tx_byte[8-1:4];
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b001;
                    tx_delay_load <= 1;
                    tx_delay_value <= 12;
                end
            end
            3'b001: begin
                LCD_E0 <= 1;
                SF_D0 <= tx_byte[8-1:4];
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b010;
                    tx_delay_load <= 1;
                    tx_delay_value <= 50;
                end
            end
            3'b010: begin
                LCD_E0 <= 0;
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b011;
                    tx_delay_load <= 1;
                    tx_delay_value <= 2;
                end
            end
            3'b011: begin
                LCD_E0 <= 0;
                SF_D0 <= tx_byte[4-1:0];
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b100;
                    tx_delay_load <= 1;
                    tx_delay_value <= 12;
                end
            end
            3'b100: begin
                LCD_E0 <= 1;
                SF_D0 <= tx_byte[4-1:0];
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b101;
                    tx_delay_load <= 1;
                    tx_delay_value <= 2000;
                end
            end
            3'b101: begin
                LCD_E0 <= 0;
                tx_delay_load <= 0;
                if (delay_done) begin
                    tx_state <= 3'b110;
                    tx_done <= 1;
                end
            end
            3'b110: begin
                LCD_E0 <= 0;
                tx_done <= 0;
                tx_delay_load <= 0;
                if (tx_init) begin
                    tx_state <= 3'b000;
                    tx_delay_load <= 1;
                    tx_delay_value <= 2;
                end
            end
        endcase
    end
end


assign delay_load = (tx_delay_load || main_delay_load);


assign busy = (state != 5'b10000);
assign LCD_RW = 0;

always @(SF_D1, SF_D0, LCD_E1, LCD_E0, output_selector) begin: LCD_OUTPUT_TX_OR_INIT_MUX
    if (output_selector) begin
        SF_D <= SF_D1;
        LCD_E <= LCD_E1;
    end
    else begin
        SF_D <= SF_D0;
        LCD_E <= LCD_E0;
    end
end


assign tx_init = ((~tx_done) & ((state == 5'b01010) | (state == 5'b01011) | (state == 5'b01100) | (state == 5'b01101) | (state == 5'b10001) | (state == 5'b10010)));
assign LCD_RS = (~(((state == 5'b01010) != 0) | (state == 5'b01011) | (state == 5'b01100) | (state == 5'b01101) | (state == 5'b10001)));


assign delay_done = (counter_counter == 0);

always @(posedge clk) begin: LCD_COUNTER_COUNTDOWN_LOGIC
    if (delay_load) begin
        counter_counter <= delay_value;
    end
    else begin
        counter_counter <= (counter_counter - 1);
    end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: myhdl/wb_lcd_workspace_ramless/rtl/wb_lcd.v
// -----------------------------------------------------------------------------
// File: wb_lcd.v
// Generated by MyHDL 0.6
// Date: Mon Apr 20 03:13:34 2009

`timescale 1ns/10ps

module wb_lcd (
    wb_clk_i,
    wb_rst_i,
    wb_dat_i,
    wb_dat_o,
    wb_adr_i,
    wb_sel_i,
    wb_we_i,
    wb_cyc_i,
    wb_stb_i,
    wb_ack_o,
    SF_D,
    LCD_E,
    LCD_RS,
    LCD_RW
);

input wb_clk_i;
input wb_rst_i;
input [31:0] wb_dat_i;
output [31:0] wb_dat_o;
reg [31:0] wb_dat_o;
input [31:0] wb_adr_i;
input [3:0] wb_sel_i;
input wb_we_i;
input wb_cyc_i;
input wb_stb_i;
output wb_ack_o;
reg wb_ack_o;
output [3:0] SF_D;
reg [3:0] SF_D;
output LCD_E;
reg LCD_E;
output LCD_RS;
wire LCD_RS;
output LCD_RW;
wire LCD_RW;

wire busy;
reg lcd_we;
wire mylcd_tx_init;
wire mylcd_delay_load;
reg mylcd_tx_done;
reg [3:0] mylcd_SF_D1;
reg [3:0] mylcd_SF_D0;
reg mylcd_LCD_E1;
reg mylcd_LCD_E0;
wire mylcd_delay_done;
reg [7:0] mylcd_tx_byte;
reg [6:0] mylcd_wr_addr;
wire mylcd_output_selector;
reg [4:0] mylcd_state;
reg [19:0] mylcd_tx_delay_value;
reg [19:0] mylcd_main_delay_value;
reg mylcd_tx_delay_load;
reg [19:0] mylcd_delay_value;
reg [6:0] mylcd_wr_dat;
reg mylcd_main_delay_load;
reg [2:0] mylcd_tx_state;
reg [20:0] mylcd_counter_counter;



always @(busy, wb_we_i, wb_stb_i, wb_cyc_i, wb_adr_i) begin: WB_LCD_WISHBONE_LOGIC
    wb_ack_o <= (wb_cyc_i & wb_stb_i);
    
    lcd_we <= (wb_cyc_i & wb_stb_i & wb_we_i & (wb_adr_i != 128));
    if (busy) begin
        wb_dat_o <= 1;
    end
    else begin
        wb_dat_o <= 0;
    end
end


assign mylcd_output_selector = ((mylcd_state == 5'b00000) | (mylcd_state == 5'b00001) | (mylcd_state == 5'b00010) | (mylcd_state == 5'b00011) | (mylcd_state == 5'b00100) | (mylcd_state == 5'b00101) | (mylcd_state == 5'b00110) | (mylcd_state == 5'b00111) | (mylcd_state == 5'b01000) | (mylcd_state == 5'b01001));

always @(mylcd_main_delay_value, mylcd_tx_delay_load, mylcd_tx_delay_value) begin: WB_LCD_MYLCD_CONUNTER_SHARING_VALUE
    if (mylcd_tx_delay_load) begin
        mylcd_delay_value <= mylcd_tx_delay_value;
    end
    else begin
        mylcd_delay_value <= mylcd_main_delay_value;
    end
end

always @(posedge wb_clk_i, posedge wb_rst_i) begin: WB_LCD_MYLCD_DISPLAYFSM
    if ((wb_rst_i == 1)) begin
        mylcd_state <= 5'b00000;
        mylcd_main_delay_load <= 0;
        mylcd_main_delay_value <= 0;
        mylcd_SF_D1 <= 0;
        mylcd_LCD_E1 <= 0;
        mylcd_tx_byte <= 0;
    end
    else begin
        mylcd_main_delay_load <= 0;
        
        mylcd_main_delay_value <= 0;
        
        // synthesis parallel_case full_case
        casez (mylcd_state)
            5'b00000: begin
                mylcd_tx_byte <= 0;
                mylcd_state <= 5'b00001;
                mylcd_main_delay_load <= 1;
                mylcd_main_delay_value <= 750000;
            end
            5'b00001: begin
                mylcd_main_delay_load <= 0;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b00010;
                    
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 11;
                end
            end
            5'b00010: begin
                mylcd_main_delay_load <= 0;
                mylcd_SF_D1 <= 3;
                mylcd_LCD_E1 <= 1;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b00011;
                    
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 205000;
                end
            end
            5'b00011: begin
                mylcd_main_delay_load <= 0;
                mylcd_LCD_E1 <= 0;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b00100;
                    
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 11;
                end
            end
            5'b00100: begin
                mylcd_main_delay_load <= 0;
                mylcd_SF_D1 <= 3;
                mylcd_LCD_E1 <= 1;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b00101;
                    
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 5000;
                end
            end
            5'b00101: begin
                mylcd_main_delay_load <= 0;
                mylcd_LCD_E1 <= 0;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b00110;
                    
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 11;
                end
            end
            5'b00110: begin
                mylcd_main_delay_load <= 0;
                mylcd_SF_D1 <= 3;
                mylcd_LCD_E1 <= 1;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b00111;
                    
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 2000;
                end
            end
            5'b00111: begin
                mylcd_main_delay_load <= 0;
                mylcd_LCD_E1 <= 0;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b01000;
                    
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 11;
                end
            end
            5'b01000: begin
                mylcd_main_delay_load <= 0;
                mylcd_SF_D1 <= 2;
                mylcd_LCD_E1 <= 1;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b01001;
                    
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 2000;
                end
            end
            5'b01001: begin
                mylcd_main_delay_load <= 0;
                mylcd_LCD_E1 <= 0;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b01010;
                    
                end
            end
            5'b01010: begin
                mylcd_tx_byte <= 40;
                if (mylcd_tx_done) begin
                    mylcd_state <= 5'b01011;
                end
            end
            5'b01011: begin
                mylcd_tx_byte <= 6;
                if (mylcd_tx_done) begin
                    mylcd_state <= 5'b01100;
                end
            end
            5'b01100: begin
                mylcd_tx_byte <= 12;
                if (mylcd_tx_done) begin
                    mylcd_state <= 5'b01101;
                end
            end
            5'b01101: begin
                mylcd_tx_byte <= 1;
                if (mylcd_tx_done) begin
                    mylcd_state <= 5'b01111;
                    mylcd_main_delay_load <= 1;
                    mylcd_main_delay_value <= 82000;
                end
            end
            5'b01110: begin
                mylcd_state <= 5'b01111;
            end
            5'b01111: begin
                mylcd_tx_byte <= 0;
                if (mylcd_delay_done) begin
                    mylcd_state <= 5'b10000;
                    
                end
            end
            5'b10000: begin
                mylcd_tx_byte <= 0;
                if (lcd_we) begin
                    mylcd_state <= 5'b10001;
                    mylcd_wr_addr <= wb_adr_i;
                    mylcd_wr_dat <= wb_dat_i;
                end
                else begin
                    mylcd_state <= 5'b10000;
                end
            end
            5'b10001: begin
                mylcd_tx_byte <= (128 | mylcd_wr_addr);
                if (mylcd_tx_done) begin
                    mylcd_state <= 5'b10010;
                end
            end
            5'b10010: begin
                mylcd_tx_byte <= mylcd_wr_dat;
                if (mylcd_tx_done) begin
                    mylcd_state <= 5'b10000;
                    
                end
            end
        endcase
    end
end

always @(posedge wb_clk_i, posedge wb_rst_i) begin: WB_LCD_MYLCD_TXFSM
    if ((wb_rst_i == 1)) begin
        mylcd_tx_state <= 3'b110;
        mylcd_SF_D0 <= 0;
        mylcd_LCD_E0 <= 0;
    end
    else begin
        mylcd_tx_delay_load <= 0;
        
        mylcd_tx_delay_value <= 0;
        
        // synthesis parallel_case full_case
        casez (mylcd_tx_state)
            3'b000: begin
                mylcd_LCD_E0 <= 0;
                mylcd_SF_D0 <= mylcd_tx_byte[8-1:4];
                mylcd_tx_delay_load <= 0;
                if (mylcd_delay_done) begin
                    mylcd_tx_state <= 3'b001;
                    mylcd_tx_delay_load <= 1;
                    mylcd_tx_delay_value <= 12;
                end
            end
            3'b001: begin
                mylcd_LCD_E0 <= 1;
                mylcd_SF_D0 <= mylcd_tx_byte[8-1:4];
                mylcd_tx_delay_load <= 0;
                if (mylcd_delay_done) begin
                    mylcd_tx_state <= 3'b010;
                    mylcd_tx_delay_load <= 1;
                    mylcd_tx_delay_value <= 50;
                end
            end
            3'b010: begin
                mylcd_LCD_E0 <= 0;
                mylcd_tx_delay_load <= 0;
                if (mylcd_delay_done) begin
                    mylcd_tx_state <= 3'b011;
                    mylcd_tx_delay_load <= 1;
                    mylcd_tx_delay_value <= 2;
                end
            end
            3'b011: begin
                mylcd_LCD_E0 <= 0;
                mylcd_SF_D0 <= mylcd_tx_byte[4-1:0];
                mylcd_tx_delay_load <= 0;
                if (mylcd_delay_done) begin
                    mylcd_tx_state <= 3'b100;
                    mylcd_tx_delay_load <= 1;
                    mylcd_tx_delay_value <= 12;
                end
            end
            3'b100: begin
                mylcd_LCD_E0 <= 1;
                mylcd_SF_D0 <= mylcd_tx_byte[4-1:0];
                mylcd_tx_delay_load <= 0;
                if (mylcd_delay_done) begin
                    mylcd_tx_state <= 3'b101;
                    mylcd_tx_delay_load <= 1;
                    mylcd_tx_delay_value <= 2000;
                end
            end
            3'b101: begin
                mylcd_LCD_E0 <= 0;
                mylcd_tx_delay_load <= 0;
                if (mylcd_delay_done) begin
                    mylcd_tx_state <= 3'b110;
                    mylcd_tx_done <= 1;
                end
            end
            3'b110: begin
                mylcd_LCD_E0 <= 0;
                mylcd_tx_done <= 0;
                mylcd_tx_delay_load <= 0;
                if (mylcd_tx_init) begin
                    mylcd_tx_state <= 3'b000;
                    mylcd_tx_delay_load <= 1;
                    mylcd_tx_delay_value <= 2;
                end
            end
        endcase
    end
end


assign mylcd_delay_load = (mylcd_tx_delay_load || mylcd_main_delay_load);


assign busy = (mylcd_state != 5'b10000);
assign LCD_RW = 0;

always @(mylcd_SF_D1, mylcd_SF_D0, mylcd_LCD_E1, mylcd_LCD_E0, mylcd_output_selector) begin: WB_LCD_MYLCD_OUTPUT_TX_OR_INIT_MUX
    if (mylcd_output_selector) begin
        SF_D <= mylcd_SF_D1;
        LCD_E <= mylcd_LCD_E1;
    end
    else begin
        SF_D <= mylcd_SF_D0;
        LCD_E <= mylcd_LCD_E0;
    end
end


assign mylcd_tx_init = ((~mylcd_tx_done) & ((mylcd_state == 5'b01010) | (mylcd_state == 5'b01011) | (mylcd_state == 5'b01100) | (mylcd_state == 5'b01101) | (mylcd_state == 5'b10001) | (mylcd_state == 5'b10010)));
assign LCD_RS = (~(((mylcd_state == 5'b01010) != 0) | (mylcd_state == 5'b01011) | (mylcd_state == 5'b01100) | (mylcd_state == 5'b01101) | (mylcd_state == 5'b10001)));


assign mylcd_delay_done = (mylcd_counter_counter == 0);

always @(posedge wb_clk_i) begin: WB_LCD_MYLCD_COUNTER_COUNTDOWN_LOGIC
    if (mylcd_delay_load) begin
        mylcd_counter_counter <= mylcd_delay_value;
    end
    else begin
        mylcd_counter_counter <= (mylcd_counter_counter - 1);
    end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd/boards/s3esk-mm_lcd/rtl/rotary.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd/boards/s3esk-mm_lcd/rtl/system.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Memory mapped controller testbench implementation for    ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////      - Grupo ID2 http://www.dte.us.es/id2/                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------


wire busy;
reg repaint = 0;
reg [`DAT_RNG]  dat = 8'b00100000;
reg [`ADDR_RNG] addr = 0;
reg we = 0;

lcd lcd(
	.clk		( clk ),
	.reset	( reset),
	
	.dat		( dat ),
	.addr		( addr ),
	.we		( we ),
	.repaint	( repaint ),
	
	.busy		( busy ),
	.SF_D		( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	
	);
	
//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;


// Handles transfers to the display
integer i = 0;
always @(posedge clk) 
begin
	if(reset) begin
		i <= 0;
		repaint <= 0;
		
		we <= 1;
		addr <= 0;
		dat <= start_dat;
		
		led <= 8'b00100000;
		start_dat <= 8'b00100000;
	end if (i < 104) begin
		i <= i + 1;
		repaint <= 0;
		
		we <= 1'b1;
		addr <= addr + 1;
		dat <= dat + 1;
	end if (i == 104 && !busy) begin
		i <= i + 1;
		repaint <= 1;
		we <= 1'b0;

	end if (i == 105) begin
		i <= i + 1;
		repaint <= 0;
		we <= 1'b0;
	end else if (rot_event && rot_left && !busy) begin
		i <= 0;
		led <= led - 1;
		start_dat <= start_dat - 1;
		
		addr <= 0;
		repaint <= 0;
		we <= 1'b1;
		dat <= start_dat - 1;
	end else if (rot_event && !busy) begin
		i <= 0;
		led <= led + 1;
		start_dat <= start_dat + 1;	
		
		addr <= 0;
		repaint <= 0;
		we <= 1'b1;
		dat <= start_dat + 1;
	end
end
 

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd/boards/s3esk-wb_lcd/rtl/rotary.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd/rtl/delay_counter.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  delay_counter.v                                             ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   -  Delay down counter.                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module delay_counter #(
	parameter counter_width = 32
) (
	input clk,
	input reset,

	input [counter_width-1:0] count,	
	input load,
	output done
	);



reg [counter_width-1:0] counter;

always @(posedge clk)
	if(load)
		counter <= count;
	else //if (!done)
		counter <= counter - 1'b1;
	
	
assign done = (counter == 0);


endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd/rtl/lcd_display.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  lcd_display.v                                               ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Memory mapped main controller.                           ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module lcd (
	input clk,
	input reset,
	
	input [`DAT_WIDTH-1:0] dat,
	input [`ADDR_WIDTH-1:0] addr,
	input we,
	
	input  repaint,
	output busy,
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW
	);

//
// TX sub FSM
//
parameter tx_state_high_setup	= 3'b000;
parameter tx_state_high_hold	= 3'b001;
parameter tx_state_oneus	= 3'b010;
parameter tx_state_low_setup	= 3'b011;
parameter tx_state_low_hold	= 3'b100;
parameter tx_state_fortyus	= 3'b101;	
parameter tx_state_done		= 3'b110;

reg	[2:0]	tx_state = tx_state_done; // Current tx fsm state
reg	[7:0]	tx_byte; // transmitting byte
wire		tx_init; // init transmission
reg  tx_done = 0;


//
// MAIN FSM
//
parameter display_state_init		= 5'b00000;
parameter init_state_fifteenms		= 5'b00001;
parameter init_state_one		= 5'b00010;
parameter init_state_two		= 5'b00011;
parameter init_state_three		= 5'b00100;
parameter init_state_four		= 5'b00101;
parameter init_state_five		= 5'b00110;
parameter init_state_six		= 5'b00111;
parameter init_state_seven		= 5'b01000;
parameter init_state_eight		= 5'b01001;
parameter display_state_function_set	= 5'b11000;
parameter display_state_entry_set	= 5'b11001;
parameter display_state_set_display	= 5'b11010;
parameter display_state_clr_display	= 5'b11011;
parameter display_state_pause_setup	= 5'b10000;
parameter display_state_pause		= 5'b10001;
parameter display_state_set_addr1	= 5'b11100;
parameter display_state_char_write1	= 5'b11101;
parameter display_state_set_addr2	= 5'b11110;
parameter display_state_char_write2	= 5'b11111;
parameter display_state_done		= 5'b10010;

reg [4:0] display_state = display_state_init; // current main fsm state
integer pos = `MEM_LOW1; // current drawing position




//
// RAM Interface
//
reg     [`DAT_WIDTH-1:0] ram [0:`MEM_LENGTH-1];    // memory contents
assign busy = (display_state != display_state_done);
																			
always @(posedge clk) 
	if (we) 
		ram[addr] <= dat;

///
/// FSM and councurrent assignments definitions for LCD driving
/// 
reg [3:0] SF_D0 = 4'b0000;
reg [3:0] SF_D1 = 4'b0000;
reg       LCD_E0 = 1'b0;
reg       LCD_E1 = 1'b0;
wire      output_selector;

assign output_selector = display_state[4];

assign SF_D = (output_selector == 1'b1) ?	SF_D0 : //transmit
						SF_D1;  //initialize

assign LCD_E = (output_selector == 1'b1) ?	LCD_E0 ://transmit
						LCD_E1; //initialize

assign LCD_RW = 1'b0; // write only

//when to transmit a command/data and when not to
assign tx_init = !tx_done & display_state[4] & display_state[3];

// register select
assign LCD_RS =	(display_state == display_state_function_set) ? 1'b0 :
                (display_state == display_state_entry_set)    ? 1'b0 :
                (display_state == display_state_set_display)  ? 1'b0 :
                (display_state == display_state_clr_display)  ? 1'b0 :
                (display_state == display_state_set_addr1)    ? 1'b0 :
                (display_state == display_state_set_addr2)    ? 1'b0 :
                                                                1'b1;


reg  [`INIT_DELAY_COUNTER_WIDTH-1:0] main_delay_value = 0;
reg  [`INIT_DELAY_COUNTER_WIDTH-1:0] tx_delay_value = 0;

wire delay_done;

reg main_delay_load = 0;
reg tx_delay_load = 0;



delay_counter  #(
	.counter_width(`INIT_DELAY_COUNTER_WIDTH)
) delay_counter (
	.clk   ( clk ),
	.reset ( reset ),
	.count ( (main_delay_load) ? main_delay_value : tx_delay_value),
	.load  ( main_delay_load | tx_delay_load ),
	.done  ( delay_done )
);									  
																					  



// main (display) state machine
always @(posedge clk, posedge reset)
begin
	if(reset==1'b1) begin
		display_state <= display_state_init;
		main_delay_load <= 0;
		main_delay_value <= 0;
	end else begin
		main_delay_load <= 0;
		main_delay_value <= 0;

		case (display_state)
			//refer to intialize state machine below
			display_state_init:
			begin
				tx_byte <= 8'b00000000;
				display_state <= init_state_fifteenms;
				main_delay_load <= 1'b1;
				main_delay_value <= 750000;
			end

			init_state_fifteenms: 
			begin
				main_delay_load <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_one;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end	

			init_state_one: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_two;
					main_delay_load <= 1'b1;
					main_delay_value <= 205000;
				end 
			end

			init_state_two: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_three;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_three: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_four;
					main_delay_load <= 1'b1;
					main_delay_value <= 5000;
				end
			end

			init_state_four: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_five;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_five: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_six;
					main_delay_load <= 1'b1;
					main_delay_value <= 2000;
				end
			end

			init_state_six: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_seven;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_seven: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0010;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_eight;
					main_delay_load <= 1'b1;
					main_delay_value <= 2000;
				end
			end

			init_state_eight: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= display_state_function_set;
				end
			end

			//every other state but pause uses the transmit state machine
			display_state_function_set:
			begin
				tx_byte <= 8'b00101000;
				if(tx_done)
					display_state <= display_state_entry_set;
			end
				
			display_state_entry_set:
			begin
				tx_byte <= 8'b00000110;
				if(tx_done)
					display_state <= display_state_set_display;
			end
			
			display_state_set_display:
			begin
				tx_byte <= 8'b00001100;
				if(tx_done)
					display_state <= display_state_clr_display;
			end
				
			display_state_clr_display:
			begin
				tx_byte <= 8'b00000001;
				if(tx_done) begin
					display_state <= display_state_pause_setup;
					main_delay_load <= 1;
					main_delay_value <= 82000;
				end
			end

			display_state_pause_setup:
			begin
				display_state <= display_state_pause;
			end

			display_state_pause:
			begin
				tx_byte <= 8'b00000000;
				if(delay_done) 
					display_state <= display_state_set_addr1;
			end

			display_state_set_addr1:
			begin
				tx_byte <= 8'b10000000;
				if(tx_done) begin
					display_state <= display_state_char_write1;
					pos <= `MEM_LOW1;
				end
			end

			display_state_char_write1:
			begin
				tx_byte <= ram[pos] & 8'b11111111;
				if(tx_done)
					if(pos == `MEM_HIGH1)
						display_state <= display_state_set_addr2;
					else 
						pos <= pos + 1;
			end

			display_state_set_addr2:
			begin
				tx_byte <= 8'b11000000;
				if(tx_done) begin
					display_state <= display_state_char_write2;
					pos <= `MEM_LOW2;
				end
			end

			display_state_char_write2:
			begin
				tx_byte <= ram[pos] & 8'b11111111;
				if(tx_done)
					if(pos == `MEM_HIGH2) begin
						display_state <= display_state_done;
					end else 
						pos <= pos + 1;
			end
			
			display_state_done:
			begin
				tx_byte <= 8'b00000000;
				if(repaint)
					display_state <= display_state_function_set;
				else
					display_state <= display_state_done;
			end
		endcase
	end
end


// transmit (tx) state machine, specified by datasheet
always @(posedge clk, posedge reset)
begin
	if(reset==1'b1)
		tx_state <= tx_state_done;
	else
	begin
		case (tx_state)
			tx_state_high_setup: // 40 ns
			begin
				LCD_E0 <= 1'b0;
				SF_D0 <= tx_byte[7 : 4];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_high_hold;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 12;
				end
			end

			tx_state_high_hold: // 230 ns
			begin
				LCD_E0 <= 1'b1;
				SF_D0 <= tx_byte[7 : 4];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_oneus;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 50;
				end
			end

			tx_state_oneus: 
			begin
				LCD_E0 <= 1'b0;
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_low_setup;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2;
				end
			end

			tx_state_low_setup: // 40 ns
			begin
				LCD_E0 <= 1'b0;
				SF_D0 <= tx_byte[3 : 0];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_low_hold;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 12;
				end
			end

			tx_state_low_hold: // 230 ns
			begin
				LCD_E0 <= 1'b1;
				SF_D0 <= tx_byte[3 : 0];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_fortyus;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2000;
				end
			end

			tx_state_fortyus: 
			begin
				LCD_E0 <= 1'b0;
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_done;
					tx_done <= 1'b1;
				end
			end

			tx_state_done: 
			begin
				LCD_E0 <= 1'b0;
				tx_done <= 1'b0;
				tx_delay_load <= 1'b0;
				if(tx_init == 1'b1) begin
					tx_state <= tx_state_high_setup;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2;
				end
			end
		endcase
	end
end
endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd/rtl/wb_lcd.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wb_lcd.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   -  Wishbone wrapper.                                       ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module wb_lcd (
	//
	// I/O Ports
	//
	input			wb_clk_i,
	input			wb_rst_i,

	//
	// WB slave interface
	//
	input	[`WB_DAT_RNG]	wb_dat_i,
	output	reg [`WB_DAT_RNG]	wb_dat_o,
	input	[`WB_ADDR_RNG]	wb_adr_i,
	input	[`WB_BSEL_RNG]	wb_sel_i,
	input			wb_we_i,
	input			wb_cyc_i,
	input			wb_stb_i,
	output	reg		wb_ack_o,
	output			wb_err_o,
	
	//
	// LCD interface
	//
	output	[3:0]		SF_D,
	output			LCD_E,
	output			LCD_RS,
	output			LCD_RW
	);
	

assign wb_err_o = 0;

wire cs = wb_cyc_i & wb_stb_i;
wire we = cs & wb_we_i;
wire re = cs & !wb_we_i;
wire special_address = (`SPECIAL_REG_ADDR_MASK == (`SPECIAL_REG_ADDR_MASK & wb_adr_i));

wire lcd_busy;
wire lcd_we = !special_address & we;
wire [`ADDR_WIDTH-1:0] lcd_addr = wb_adr_i[`ADDR_WIDTH-1:0];

wire repaint_req =  we & (wb_adr_i == `COMMAND_REG_ADDR) & (wb_dat_i == `COMMAND_REPAINT_CODE);
wire status = lcd_busy ? `STATUS_BUSY_CODE : `STATUS_IDDLE_CODE;


// wb_ack management: two clk cycles per WB access to avoid long combinational paths.
always @(posedge wb_clk_i) begin
	if(wb_rst_i)
		wb_ack_o <= 1'b0;
	else begin
		if(cs)
			wb_ack_o <= ~wb_ack_o;
		else
			wb_ack_o <= 1'b0;
	end
end

// Status register (only checks if lcd is busy)
always @(posedge wb_clk_i) // wb_dat_o always outputs the status register not depending on what address is being accessed
	wb_dat_o = status;

// Command register (only issues repaint commands)
reg lcd_repaint = 0;
always @(posedge wb_clk_i) begin
	if(repaint_req & !lcd_busy)
		lcd_repaint <= 1;
	else
		lcd_repaint <= 0;
end

//----------------------------------------------------------------------------
// Memory mapped LCD display controller
//----------------------------------------------------------------------------

lcd lcd(
	.clk	( wb_clk_i ),
	.reset	( wb_rst_i ),
	
	.dat	( wb_dat_i[`DAT_RNG] ),
	.addr	( lcd_addr ),
	.we	( lcd_we ),
	.repaint( lcd_repaint ),
	
	.busy	( lcd_busy ),	
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	


endmodule


// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd_ramless/boards/s3esk-mm_lcd/rtl/rotary.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd_ramless/boards/s3esk-mm_lcd/rtl/system.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Memory mapped controller testbench implementation for    ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////      - Grupo ID2 http://www.dte.us.es/id2/                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------


wire busy;
reg repaint = 0;
reg [`DAT_RNG]  dat = 8'b00100000;
reg [`ADDR_RNG] addr = 0;
reg we = 0;

lcd lcd(
	.clk		( clk ),
	.reset	( reset),
	
	.dat		( dat ),
	.addr		( addr ),
	.we		( we ),
	.repaint	( repaint ),
	
	.busy		( busy ),
	.SF_D		( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	
	);
	
//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;


// Handles transfers to the display
integer i = 0;
always @(posedge clk) 
begin
	if(reset) begin
		i <= 0;
		repaint <= 0;
		
		we <= 1;
		addr <= 0;
		dat <= start_dat;
		
		led <= 8'b00100000;
		start_dat <= 8'b00100000;
	end if (i < 104) begin
		i <= i + 1;
		repaint <= 0;
		
		we <= 1'b1;
		addr <= addr + 1;
		dat <= dat + 1;
	end if (i == 104 && !busy) begin
		i <= i + 1;
		repaint <= 1;
		we <= 1'b0;

	end if (i == 105) begin
		i <= i + 1;
		repaint <= 0;
		we <= 1'b0;
	end else if (rot_event && rot_left && !busy) begin
		i <= 0;
		led <= led - 1;
		start_dat <= start_dat - 1;
		
		addr <= 0;
		repaint <= 0;
		we <= 1'b1;
		dat <= start_dat - 1;
	end else if (rot_event && !busy) begin
		i <= 0;
		led <= led + 1;
		start_dat <= start_dat + 1;	
		
		addr <= 0;
		repaint <= 0;
		we <= 1'b1;
		dat <= start_dat + 1;
	end
end
 

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd_ramless/boards/s3esk-wb_lcd/rtl/rotary.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Decode rotary encoder to clk-syncronous signals
//
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module rotary (
	input        clk,
	input        reset,
	input [2:0]  rot,
	//
	output reg   rot_btn,
	output reg   rot_event,
	output reg   rot_left
);

//----------------------------------------------------------------------------
// decode rotary encoder
//----------------------------------------------------------------------------
reg [1:0] rot_q;

always @(posedge clk)
begin
	case (rot[1:0])
		2'b00: rot_q <= { rot_q[1], 1'b0 };
		2'b01: rot_q <= { 1'b0, rot_q[0] };
		2'b10: rot_q <= { 1'b1, rot_q[0] };
		2'b11: rot_q <= { rot_q[1], 1'b1 };
	endcase
end

reg [1:0] rot_q_delayed;

always @(posedge clk)
begin
	rot_q_delayed <= rot_q;

	if (rot_q[0] && ~rot_q_delayed[0]) begin
		rot_event <= 1;
		rot_left  <= rot_q[1];
	end else
		rot_event <= 0;
end

//----------------------------------------------------------------------------
// debounce push button (rot[2])
//----------------------------------------------------------------------------
reg [2:0]  rot_d;
reg [15:0] dead_count;

always @(posedge clk)
begin
	if (reset) begin
		rot_btn    <= 0;
		dead_count <= 0;
	end else begin
		rot_btn <= 1'b0;
		rot_d   <= { rot_d[1:0], rot[2] };

		if (dead_count == 0) begin
			if ( rot_d[2:1] == 2'b01 ) begin
				rot_btn    <= 1'b1;
				dead_count <= dead_count - 1;
			end
		end else
			dead_count <= dead_count - 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd_ramless/boards/s3esk-wb_lcd/rtl/system.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Wishbone controller testbench implementation for         ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------

reg	[`DAT_RNG]	dat = 8'b00100000;
wire	[`WB_DAT_RNG]	wb_dat = {24'b0, dat};
reg	[`ADDR_WIDTH:0] addr = 0;
wire	[`WB_ADDR_RNG]	wb_addr = {24'b0, addr};
wire	[`WB_DAT_RNG]	status;
wire 			busy = status[0];
wire cs;
wire we;
wire ack;

wb_lcd lcd  (
	//
	// I/O Ports
	//
	.wb_clk_i	( clk ),
	.wb_rst_i	( reset),
	
	//
	// WB slave interface
	//
	.wb_dat_i	( wb_dat ),
	.wb_dat_o	( status ),
	.wb_adr_i	( wb_addr ),
	.wb_sel_i	(  ),
	.wb_we_i	( we ),
	.wb_cyc_i	( cs  ),
	.wb_stb_i	( cs ),
	.wb_ack_o	( ack ),

	//
	// LCD interface
	//
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	
//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;

integer i = 0;
assign we = (i < 104) & ~busy;
assign cs = (i < 104);
			
// Handles transfers to the display
always @(posedge clk) 
begin
	if(reset) begin
		led <= 8'b00100000;
		start_dat <= 8'b00100000;

		i <= 0;
		addr <= 0;
		dat <= start_dat;
	end else begin
		if (i < 105 && !busy) begin
			i <= i + 1;
			addr <= addr + 1;
			dat <= dat + 1;
		end else if (rot_event && rot_left && !busy) begin
			led <= led - 1;
			start_dat <= start_dat - 1;

			i <= 0;
			addr <= 0;
			dat <= start_dat - 1;
		end else if (rot_event && !busy) begin
			led <= led + 1;
			start_dat <= start_dat + 1;	

			i <= 0;
			addr <= 0;
			dat <= start_dat + 1;
		end
	end
end
 
endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd_ramless/rtl/delay_counter.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  delay_counter.v                                             ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   -  Delay down counter.                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module delay_counter #(
	parameter counter_width = 32
) (
	input clk,
	input reset,

	input [counter_width-1:0] count,	
	input load,
	output done
	);



reg [counter_width-1:0] counter;

always @(posedge clk)
	if(load)
		counter <= count;
	else //if (!done)
		counter <= counter - 1'b1;
	
	
assign done = (counter == 0);


endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd_ramless/rtl/lcd_display.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  lcd_display.v                                               ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Memory mapped main controller.                           ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module lcd (
	input clk,
	input reset,
	
	input [`DAT_WIDTH-1:0] dat,
	input [`ADDR_WIDTH-1:0] addr,
	input we,
	
	output busy,
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW
	);

//
// TX sub FSM
//
parameter tx_state_high_setup	= 3'b000;
parameter tx_state_high_hold	= 3'b001;
parameter tx_state_oneus	= 3'b010;
parameter tx_state_low_setup	= 3'b011;
parameter tx_state_low_hold	= 3'b100;
parameter tx_state_fortyus	= 3'b101;	
parameter tx_state_done		= 3'b110;

reg	[2:0]	tx_state = tx_state_done; // Current tx fsm state
reg	[7:0]	tx_byte; // transmitting byte
wire		tx_init; // init transmission
reg  		tx_done = 0;


//
// MAIN FSM
//
parameter display_state_init		= 5'b00000;
parameter init_state_fifteenms		= 5'b00001;
parameter init_state_one		= 5'b00010;
parameter init_state_two		= 5'b00011;
parameter init_state_three		= 5'b00100;
parameter init_state_four		= 5'b00101;
parameter init_state_five		= 5'b00110;
parameter init_state_six		= 5'b00111;
parameter init_state_seven		= 5'b01000;
parameter init_state_eight		= 5'b01001;
parameter display_state_function_set	= 5'b11000;
parameter display_state_entry_set	= 5'b11001;
parameter display_state_set_display	= 5'b11010;
parameter display_state_clr_display	= 5'b11011;
parameter display_state_pause_setup	= 5'b10000;
parameter display_state_pause		= 5'b10001;
parameter display_state_set_addr	= 5'b11100;
parameter display_state_char_write	= 5'b11101;
parameter display_state_done		= 5'b10010;

reg [4:0] display_state = display_state_init; // current main fsm state




//
// RAM Interface
//
assign busy = (display_state != display_state_done);

reg [`DAT_WIDTH-1:0] wr_dat;
reg [`ADDR_WIDTH-1:0] wr_addr;
																			
///
/// FSM and councurrent assignments definitions for LCD driving
/// 
reg [3:0] SF_D0 = 4'b0000;
reg [3:0] SF_D1 = 4'b0000;
reg       LCD_E0 = 1'b0;
reg       LCD_E1 = 1'b0;
wire      output_selector;

assign output_selector = display_state[4];

assign SF_D = (output_selector == 1'b1) ?	SF_D0 : //transmit
						SF_D1;  //initialize

assign LCD_E = (output_selector == 1'b1) ?	LCD_E0 ://transmit
						LCD_E1; //initialize

assign LCD_RW = 1'b0; // write only

//when to transmit a command/data and when not to
assign tx_init = !tx_done & display_state[4] & display_state[3];

// register select
assign LCD_RS =	(display_state == display_state_function_set) ? 1'b0 :
                (display_state == display_state_entry_set)    ? 1'b0 :
                (display_state == display_state_set_display)  ? 1'b0 :
                (display_state == display_state_clr_display)  ? 1'b0 :
                (display_state == display_state_set_addr)     ? 1'b0 :
                                                                1'b1;


reg  [`INIT_DELAY_COUNTER_WIDTH-1:0] main_delay_value = 0;
reg  [`INIT_DELAY_COUNTER_WIDTH-1:0] tx_delay_value = 0;

wire delay_done;

reg main_delay_load = 0;
reg tx_delay_load = 0;



delay_counter  #(
	.counter_width(`INIT_DELAY_COUNTER_WIDTH)
) delay_counter (
	.clk   ( clk ),
	.reset ( reset ),
	.count ( (main_delay_load) ? main_delay_value : tx_delay_value),
	.load  ( main_delay_load | tx_delay_load ),
	.done  ( delay_done )
);									  
																					  



// main (display) state machine
always @(posedge clk, posedge reset)
begin
	if(reset==1'b1) begin
		display_state <= display_state_init;
		main_delay_load <= 0;
		main_delay_value <= 0;
	end else begin
		main_delay_load <= 0;
		main_delay_value <= 0;

		case (display_state)
			//refer to intialize state machine below
			display_state_init:
			begin
				tx_byte <= 8'b00000000;
				display_state <= init_state_fifteenms;
				main_delay_load <= 1'b1;
				main_delay_value <= 750000;
			end

			init_state_fifteenms: 
			begin
				main_delay_load <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_one;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end	

			init_state_one: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_two;
					main_delay_load <= 1'b1;
					main_delay_value <= 205000;
				end 
			end

			init_state_two: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_three;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_three: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_four;
					main_delay_load <= 1'b1;
					main_delay_value <= 5000;
				end
			end

			init_state_four: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_five;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_five: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0011;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_six;
					main_delay_load <= 1'b1;
					main_delay_value <= 2000;
				end
			end

			init_state_six: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= init_state_seven;
					main_delay_load <= 1'b1;
					main_delay_value <= 11;
				end
			end

			init_state_seven: 
			begin
				main_delay_load <= 1'b0;
				SF_D1 <= 4'b0010;
				LCD_E1 <= 1'b1;
				if(delay_done) begin
					display_state <= init_state_eight;
					main_delay_load <= 1'b1;
					main_delay_value <= 2000;
				end
			end

			init_state_eight: 
			begin
				main_delay_load <= 1'b0;
				LCD_E1 <= 1'b0;
				if(delay_done) begin
					display_state <= display_state_function_set;
				end
			end

			//every other state but pause uses the transmit state machine
			display_state_function_set:
			begin
				tx_byte <= 8'b00101000;
				if(tx_done)
					display_state <= display_state_entry_set;
			end
				
			display_state_entry_set:
			begin
				tx_byte <= 8'b00000110;
				if(tx_done)
					display_state <= display_state_set_display;
			end
			
			display_state_set_display:
			begin
				tx_byte <= 8'b00001100;
				if(tx_done)
					display_state <= display_state_clr_display;
			end
				
			display_state_clr_display:
			begin
				tx_byte <= 8'b00000001;
				if(tx_done) begin
					display_state <= display_state_pause_setup;
					main_delay_load <= 1;
					main_delay_value <= 82000;
				end
			end

			display_state_pause_setup:
			begin
				display_state <= display_state_pause;
			end

			display_state_pause:
			begin
				tx_byte <= 8'b00000000;
				if(delay_done) 
					display_state <= display_state_done;
			end

			display_state_done:
			begin
				tx_byte <= 8'b00000000;
				if (we) begin
					display_state <= display_state_set_addr;
					wr_addr <= addr;
					wr_dat <= dat;
				end else
					display_state <= display_state_done;
			end

			display_state_set_addr:
			begin
				tx_byte <= { 1'b1 , wr_addr};
				if(tx_done) begin
					display_state <= display_state_char_write;
				end
			end

			display_state_char_write:
			begin
				tx_byte <= wr_dat;
				if(tx_done)
					display_state <= display_state_done;

			end

		endcase
	end
end


// transmit (tx) state machine, specified by datasheet
always @(posedge clk, posedge reset)
begin
	if(reset==1'b1)
		tx_state <= tx_state_done;
	else
	begin
		case (tx_state)
			tx_state_high_setup: // 40 ns
			begin
				LCD_E0 <= 1'b0;
				SF_D0 <= tx_byte[7 : 4];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_high_hold;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 12;
				end
			end

			tx_state_high_hold: // 230 ns
			begin
				LCD_E0 <= 1'b1;
				SF_D0 <= tx_byte[7 : 4];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_oneus;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 50;
				end
			end

			tx_state_oneus: 
			begin
				LCD_E0 <= 1'b0;
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_low_setup;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2;
				end
			end

			tx_state_low_setup: // 40 ns
			begin
				LCD_E0 <= 1'b0;
				SF_D0 <= tx_byte[3 : 0];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_low_hold;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 12;
				end
			end

			tx_state_low_hold: // 230 ns
			begin
				LCD_E0 <= 1'b1;
				SF_D0 <= tx_byte[3 : 0];
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_fortyus;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2000;
				end
			end

			tx_state_fortyus: 
			begin
				LCD_E0 <= 1'b0;
				tx_delay_load <= 1'b0;
				if(delay_done) begin
					tx_state <= tx_state_done;
					tx_done <= 1'b1;
				end
			end

			tx_state_done: 
			begin
				LCD_E0 <= 1'b0;
				tx_done <= 1'b0;
				tx_delay_load <= 1'b0;
				if(tx_init == 1'b1) begin
					tx_state <= tx_state_high_setup;
					tx_delay_load <= 1'b1;
					tx_delay_value <= 2;
				end
			end
		endcase
	end
end
endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/wb_lcd_ramless/rtl/wb_lcd.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wb_lcd.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   -  Wishbone wrapper.                                       ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module wb_lcd (
	//
	// I/O Ports
	//
	input			wb_clk_i,
	input			wb_rst_i,

	//
	// WB slave interface
	//
	input	[`WB_DAT_RNG]	wb_dat_i,
	output	[`WB_DAT_RNG]	wb_dat_o,
	input	[`WB_ADDR_RNG]	wb_adr_i,
	input	[`WB_BSEL_RNG]	wb_sel_i,
	input			wb_we_i,
	input			wb_cyc_i,
	input			wb_stb_i,
	output			wb_ack_o,
	
	//
	// LCD interface
	//
	output	[3:0]		SF_D,
	output			LCD_E,
	output			LCD_RS,
	output			LCD_RW
	);
	


wire lcd_busy;
wire lcd_we;

assign wb_ack_o = wb_cyc_i & wb_stb_i;
assign lcd_we   = wb_cyc_i & wb_stb_i & wb_we_i & (wb_adr_i != 128);
assign wb_dat_o = lcd_busy ? `STATUS_BUSY_CODE : `STATUS_IDDLE_CODE;


//----------------------------------------------------------------------------
// Memory mapped LCD display controller
//----------------------------------------------------------------------------

lcd lcd(
	.clk	( wb_clk_i ),
	.reset	( wb_rst_i ),
	
	.dat	( wb_dat_i[`DAT_RNG] ),
	.addr	( wb_adr_i[`ADDR_WIDTH-1:0] ),
	.we	( lcd_we ),
	
	.busy	( lcd_busy ),	
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	


endmodule

