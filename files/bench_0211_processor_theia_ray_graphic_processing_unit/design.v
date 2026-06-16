// Curated RTL benchmark case.
// case_id: bench_0211_processor_theia_ray_graphic_processing_unit
// source_project: processor_theia_ray_graphic_processing_unit
// top_module: VectorALU


// -----------------------------------------------------------------------------
// Source file: RTL/aDefinitions.v
// -----------------------------------------------------------------------------
/**********************************************************************************
Theaia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2009  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/


/*******************************************************************************
Module Description:

	This module defines constants that are going to be used
	all over the code. By now you have may noticed that all
	constants are pre-compilation define directives. This is
	for simulation perfomance reasons mainly.
*******************************************************************************/

`define MAX_CORES 4 		//The number of cores, make sure you update MAX_CORE_BITS!
`define MAX_CORE_BITS 2 		// 2 ^ MAX_CORE_BITS = MAX_CORES
`define MAX_TMEM_BANKS 4 		//The number of memory banks for TMEM
`define SELECT_ALL_CORES `MAX_CORES'b1111 		//XXX: Change for more cores
//---------------------------------------------------------------------------------
//Verilog provides a `default_nettype none compiler directive.  When
//this directive is set, implicit data types are disabled, which will make any
//undeclared signal name a syntax error.This is very usefull to avoid annoying
//automatic 1 bit long wire declaration where you don't want them to be!
`default_nettype none

//The clock cycle
`define CLOCK_CYCLE  5
`define CLOCK_PERIOD 10
//---------------------------------------------------------------------------------
//Defines the Scale. This very important because it sets the fixed point precision.
//The Scale defines the number bits that are used as the decimal part of the number.
//The code has been written in such a way that allows you to change the value of the
//Scale, so that it is possible to experiment with different scenarios. SCALE can be
//no smaller that 1 and no bigger that WIDTH.
`define SCALE        17

//The next section defines the length of the registers, buses and other structures, 
//do not change this valued unless you really know what you are doing (seriously!)
`define WIDTH        32
`define WB_WIDTH     32  //width of wish-bone buses		
`define LONG_WIDTH   64

`define WB_SIMPLE_READ_CYCLE  0
`define WB_SIMPLE_WRITE_CYCLE 1
//---------------------------------------------------------------------------------
//Next are the constants that define the size of the instructions.
//instructions are formed like this:
// Tupe I:
// Operand         (of size INSTRUCTION_OP_LENGTH )
// DestinationAddr (of size DATA_ADDRESS_WIDTH )
// SourceAddrr1    (of size DATA_ADDRESS_WIDTH )
// SourceAddrr2    (of size DATA_ADDRESS_WIDTH )	
//Type II:
// Operand         (of size INSTRUCTION_OP_LENGTH )
// DestinationAddr (of size DATA_ADDRESS_WIDTH )
// InmeadiateValue (of size WIDTH = DATA_ADDRESS_WIDTH * 2 )
//
//You can play around with the size of instuctions, but keep
//in mind that Bits 3 and 4 of the Operand have a special meaning
//that is used for the jump familiy of instructions (see Documentation).
//Also the MSB of Operand is used by the decoder to distinguish 
//between Type I and Type II instructions.
`define INSTRUCTION_WIDTH       64
`define INSTRUCTION_OP_LENGTH   16
`define INSTRUCTION_IMM_BITPOS  54
`define INSTRUCTION_IMM_BIT     6	//don't change this!

//Defines the Lenght of Memory blocks
`define DATA_ROW_WIDTH        96
`define DATA_ADDRESS_WIDTH    16
`define ROM_ADDRESS_WIDTH     16
`define ROM_ADDRESS_SEL_MASK  `ROM_ADDRESS_WIDTH'h8000

//---------------------------------------------------------------------------------
//The next section defines the code memory entry point for the various code routines
//Please keep this syntax ENTRYPOINT_ADDR_* because the perl script that
//parses the user code expects this pattern in order to read in the tokens

//Internal Entry points (default ROM Address)
`define ENTRYPOINT_ADRR_INITIAL                 `ROM_ADDRESS_WIDTH'd0   //0 - This should always be zero
`define ENTRYPOINT_ADRR_CPPU                    `ROM_ADDRESS_WIDTH'd44   
`define ENTRYPOINT_ADRR_RGU                     `ROM_ADDRESS_WIDTH'd47  
`define ENTRYPOINT_ADRR_AABBIU                  `ROM_ADDRESS_WIDTH'd69  
`define ENTRYPOINT_ADRR_BIU                     `ROM_ADDRESS_WIDTH'd157 
`define ENTRYPOINT_ADRR_PSU                     `ROM_ADDRESS_WIDTH'd232 
`define ENTRYPOINT_ADRR_PSU2                    `ROM_ADDRESS_WIDTH'd248 
`define ENTRYPOINT_ADRR_TCC                     `ROM_ADDRESS_WIDTH'd190 
`define ENTRYPOINT_ADRR_NPG                     `ROM_ADDRESS_WIDTH'd55  
//User Entry points (default ROM Address)
`define ENTRYPOINT_ADRR_USERCONSTANTS           `ROM_ADDRESS_WIDTH'd276
`define ENTRYPOINT_ADRR_PIXELSHADER             `ROM_ADDRESS_WIDTH'd278
`define ENTRYPOINT_ADRR_MAIN                    `ROM_ADDRESS_WIDTH'd37 

//Please keep this syntax ENTRYPOINT_INDEX_* because the perl script that
//parses the user code expects this pattern in order to read in the tokens
//Internal subroutines
`define ENTRYPOINT_INDEX_INITIAL                `ROM_ADDRESS_WIDTH'h8000
`define ENTRYPOINT_INDEX_CPPU                   `ROM_ADDRESS_WIDTH'h8001
`define ENTRYPOINT_INDEX_RGU                    `ROM_ADDRESS_WIDTH'h8002
`define ENTRYPOINT_INDEX_AABBIU                 `ROM_ADDRESS_WIDTH'h8003
`define ENTRYPOINT_INDEX_BIU                    `ROM_ADDRESS_WIDTH'h8004
`define ENTRYPOINT_INDEX_PSU                    `ROM_ADDRESS_WIDTH'h8005
`define ENTRYPOINT_INDEX_PSU2                   `ROM_ADDRESS_WIDTH'h8006
`define ENTRYPOINT_INDEX_TCC                    `ROM_ADDRESS_WIDTH'h8007
`define ENTRYPOINT_INDEX_NPG                    `ROM_ADDRESS_WIDTH'h8008
//User defined subroutines
`define ENTRYPOINT_INDEX_USERCONSTANTS          `ROM_ADDRESS_WIDTH'h8009
`define ENTRYPOINT_INDEX_PIXELSHADER            `ROM_ADDRESS_WIDTH'h800A
`define ENTRYPOINT_INDEX_MAIN                   `ROM_ADDRESS_WIDTH'h800B

`define USER_AABBIU_UCODE_ADDRESS `ROM_ADDRESS_WIDTH'b1000000000000000
//---------------------------------------------------------------------------------
//This handy little macro allows me to print stuff either to STDOUT or a file.
//Notice that the compilation vairable DUMP_CODE must be set if you want to print
//to a file. In XILINX right click 'Simulate Beahvioral Model' -> Properties and
//under 'Specify `define macro name and value' type 'DEBUG=1|DUMP_CODE=1|DEBUG_CORE=<core you want to dump>'
`ifdef DUMP_CODE
	
	`define LOGME  $fwrite(ucode_file,
`else
	`define LOGME  $write(
`endif
//---------------------------------------------------------------------------------	
`define TRUE     32'h1
`define FALSE    32'h0
`define RT_TRUE  48'b1
`define RT_FALSE 48'b0
//---------------------------------------------------------------------------------	

`define GENERAL_PURPOSE_REG_ADDR_MASK  `DATA_ADDRESS_WIDTH'h1F
`define VOID                           `DATA_ADDRESS_WIDTH'd0	//0000
//** Control register bits **//
`define CR_EN_LIGHTS   0
`define CR_EN_TEXTURE  1
`define CR_USER_AABBIU 2
/** Swapping registers **/
//** Configuration Registers **//
`define CREG_LIGHT_INFO                   `DATA_ADDRESS_WIDTH'd0	
`define CREG_CAMERA_POSITION              `DATA_ADDRESS_WIDTH'd1	
`define CREG_PROJECTION_WINDOW_MIN        `DATA_ADDRESS_WIDTH'd2	
`define CREG_PROJECTION_WINDOW_MAX        `DATA_ADDRESS_WIDTH'd3	
`define CREG_RESOLUTION                   `DATA_ADDRESS_WIDTH'd4	
`define CREG_TEXTURE_SIZE                 `DATA_ADDRESS_WIDTH'd5	
`define CREG_PIXEL_2D_INITIAL_POSITION    `DATA_ADDRESS_WIDTH'd6 
`define CREG_PIXEL_2D_FINAL_POSITION      `DATA_ADDRESS_WIDTH'd7 
`define CREG_FIRST_LIGTH                  `DATA_ADDRESS_WIDTH'd8	
`define CREG_FIRST_LIGTH_DIFFUSE          `DATA_ADDRESS_WIDTH'd8	
//OK, so from address 0x06 to 0x0F is where the lights are,watch out values are harcoded
//for now!! (look in ROM.v for hardcoded values!!!)


//Don't change the order of the registers. CREG_V* and CREG_UV* registers
//need to be in that specific order for the triangle fetcher to work 
//correctly!

`define CREG_AABBMIN                   `DATA_ADDRESS_WIDTH'd42
`define CREG_AABBMAX                   `DATA_ADDRESS_WIDTH'd43
`define CREG_V0                        `DATA_ADDRESS_WIDTH'd44	
`define CREG_UV0                       `DATA_ADDRESS_WIDTH'd45	
`define CREG_V1                        `DATA_ADDRESS_WIDTH'd46	
`define CREG_UV1                       `DATA_ADDRESS_WIDTH'd47	
`define CREG_V2                        `DATA_ADDRESS_WIDTH'd48	
`define CREG_UV2                       `DATA_ADDRESS_WIDTH'd49	
`define CREG_TRI_DIFFUSE               `DATA_ADDRESS_WIDTH'd50	
`define CREG_TEX_COLOR1                `DATA_ADDRESS_WIDTH'd53	
`define CREG_TEX_COLOR2                `DATA_ADDRESS_WIDTH'd54	
`define CREG_TEX_COLOR3                `DATA_ADDRESS_WIDTH'd55	
`define CREG_TEX_COLOR4                `DATA_ADDRESS_WIDTH'd56
`define CREG_TEX_COLOR5                `DATA_ADDRESS_WIDTH'd57	
`define CREG_TEX_COLOR6                `DATA_ADDRESS_WIDTH'd58	
`define CREG_TEX_COLOR7                `DATA_ADDRESS_WIDTH'd59	


/** Non-Swapping registers **/
// ** User Registers **//
//General Purpose registers, the user may put what ever he/she
//wants in here...
`define C1     `DATA_ADDRESS_WIDTH'd64 
`define C2     `DATA_ADDRESS_WIDTH'd65 
`define C3     `DATA_ADDRESS_WIDTH'd66 
`define C4     `DATA_ADDRESS_WIDTH'd67 
`define C5     `DATA_ADDRESS_WIDTH'd68 
`define C6     `DATA_ADDRESS_WIDTH'd69 
`define C7     `DATA_ADDRESS_WIDTH'd70 
`define R1		`DATA_ADDRESS_WIDTH'd71 
`define R2		`DATA_ADDRESS_WIDTH'd72 
`define R3		`DATA_ADDRESS_WIDTH'd73 
`define R4		`DATA_ADDRESS_WIDTH'd74
`define R5		`DATA_ADDRESS_WIDTH'd75
`define R6		`DATA_ADDRESS_WIDTH'd76
`define R7		`DATA_ADDRESS_WIDTH'd77
`define R8		`DATA_ADDRESS_WIDTH'd78
`define R9		`DATA_ADDRESS_WIDTH'd79
`define R10		`DATA_ADDRESS_WIDTH'd80
`define R11		`DATA_ADDRESS_WIDTH'd81
`define R12		`DATA_ADDRESS_WIDTH'd82

//** Internal Registers **//
`define CREG_PROJECTION_WINDOW_SCALE   `DATA_ADDRESS_WIDTH'd83
`define CREG_UNORMALIZED_DIRECTION     `DATA_ADDRESS_WIDTH'd84
`define CREG_RAY_DIRECTION             `DATA_ADDRESS_WIDTH'd85	
`define CREG_E1_LAST                   `DATA_ADDRESS_WIDTH'd86
`define CREG_E2_LAST                   `DATA_ADDRESS_WIDTH'd87
`define CREG_T                         `DATA_ADDRESS_WIDTH'd88
`define CREG_P                         `DATA_ADDRESS_WIDTH'd89
`define CREG_Q                         `DATA_ADDRESS_WIDTH'd90
`define CREG_UV0_LAST                  `DATA_ADDRESS_WIDTH'd91
`define CREG_UV1_LAST                  `DATA_ADDRESS_WIDTH'd92
`define CREG_UV2_LAST                  `DATA_ADDRESS_WIDTH'd93
`define CREG_TRI_DIFFUSE_LAST          `DATA_ADDRESS_WIDTH'd94
`define CREG_LAST_t                    `DATA_ADDRESS_WIDTH'd95
`define CREG_LAST_u                    `DATA_ADDRESS_WIDTH'd96
`define CREG_LAST_v                    `DATA_ADDRESS_WIDTH'd97
`define CREG_COLOR_ACC                 `DATA_ADDRESS_WIDTH'd98
`define CREG_t                         `DATA_ADDRESS_WIDTH'd99
`define CREG_E1                        `DATA_ADDRESS_WIDTH'd100
`define CREG_E2                        `DATA_ADDRESS_WIDTH'd101
`define CREG_DELTA                     `DATA_ADDRESS_WIDTH'd102
`define CREG_u                         `DATA_ADDRESS_WIDTH'd103
`define CREG_v                         `DATA_ADDRESS_WIDTH'd104
`define CREG_H1                        `DATA_ADDRESS_WIDTH'd105
`define CREG_H2                        `DATA_ADDRESS_WIDTH'd106
`define CREG_H3                        `DATA_ADDRESS_WIDTH'd107
`define CREG_PIXEL_PITCH               `DATA_ADDRESS_WIDTH'd108

`define CREG_LAST_COL                  `DATA_ADDRESS_WIDTH'd109 //the last valid column, simply CREG_RESOLUTIONX - 1
`define CREG_TEXTURE_COLOR             `DATA_ADDRESS_WIDTH'd110 
`define CREG_PIXEL_2D_POSITION         `DATA_ADDRESS_WIDTH'd111
`define CREG_TEXWEIGHT1                `DATA_ADDRESS_WIDTH'd112	
`define CREG_TEXWEIGHT2                `DATA_ADDRESS_WIDTH'd113	
`define CREG_TEXWEIGHT3                `DATA_ADDRESS_WIDTH'd114	
`define CREG_TEXWEIGHT4                `DATA_ADDRESS_WIDTH'd115
`define CREG_TEX_COORD1                `DATA_ADDRESS_WIDTH'd116	
`define CREG_TEX_COORD2                `DATA_ADDRESS_WIDTH'd117
`define R99                            `DATA_ADDRESS_WIDTH'd118
`define CREG_ZERO                      `DATA_ADDRESS_WIDTH'd119
`define CREG_CURRENT_OUTPUT_PIXEL      `DATA_ADDRESS_WIDTH'd120
`define CREG_3                         `DATA_ADDRESS_WIDTH'd121
`define CREG_012                       `DATA_ADDRESS_WIDTH'd122

//** Ouput registers **//

`define OREG_PIXEL_COLOR               `DATA_ADDRESS_WIDTH'd128
`define OREG_TEX_COORD1                `DATA_ADDRESS_WIDTH'd129	
`define OREG_TEX_COORD2                `DATA_ADDRESS_WIDTH'd130	
`define OREG_ADDR_O                    `DATA_ADDRESS_WIDTH'd131
//-------------------------------------------------------------
//*** Instruction Set ***
//The order of the instructions is important here!. Don't change
//it unless you know what you are doing. For example all the 'SET'
//family of instructions have the MSB bit in 1. This means that
//if you add an instruction and the MSB=1, this instruction will treated
//as type II (see manual) meaning the second 32bit argument is expected to be
//an inmediate value instead of a register address!
//Another example is that in the JUMP family Bits 3 and 4 have a special
//meaning: b4b3 = 01 => X jump type, b4b3 = 10 => Y jump type, finally 
//b4b3 = 11 means Z jump type.
//All this is just to tell you: Don't play with these values!

// *** Type I Instructions (OP DST REG1 REG2) ***
`define NOP    `INSTRUCTION_OP_LENGTH'b0_000000 	//0
`define ADD 	`INSTRUCTION_OP_LENGTH'b0_000001 	//1
`define SUB		`INSTRUCTION_OP_LENGTH'b0_000010 	//2
`define DIV		`INSTRUCTION_OP_LENGTH'b0_000011 	//3
`define MUL 	`INSTRUCTION_OP_LENGTH'b0_000100 	//4
`define MAG		`INSTRUCTION_OP_LENGTH'b0_000101 	//5
`define COPY	`INSTRUCTION_OP_LENGTH'b0_000111 	//7
`define JGX		`INSTRUCTION_OP_LENGTH'b0_001_000  	//8
`define JLX		`INSTRUCTION_OP_LENGTH'b0_001_001	//9
`define JEQX	`INSTRUCTION_OP_LENGTH'b0_001_010 	//10 - A
`define JNEX	`INSTRUCTION_OP_LENGTH'b0_001_011 	//11 - B
`define JGEX	`INSTRUCTION_OP_LENGTH'b0_001_100	//12 - C
`define JLEX	`INSTRUCTION_OP_LENGTH'b0_001_101 	//13 - D
`define INC		`INSTRUCTION_OP_LENGTH'b0_001_110	//14 - E
`define ZERO	`INSTRUCTION_OP_LENGTH'b0_001_111	//15 - F
`define JGY		`INSTRUCTION_OP_LENGTH'b0_010_000  	//16
`define JLY		`INSTRUCTION_OP_LENGTH'b0_010_001 	//17
`define JEQY	`INSTRUCTION_OP_LENGTH'b0_010_010  	//18
`define JNEY	`INSTRUCTION_OP_LENGTH'b0_010_011 	//19
`define JGEY	`INSTRUCTION_OP_LENGTH'b0_010_100 	//20
`define JLEY	`INSTRUCTION_OP_LENGTH'b0_010_101  	//21
`define CROSS	`INSTRUCTION_OP_LENGTH'b0_010_110	//22
`define DOT		`INSTRUCTION_OP_LENGTH'b0_010_111	//23
`define JGZ		`INSTRUCTION_OP_LENGTH'b0_011_000 	//24
`define JLZ		`INSTRUCTION_OP_LENGTH'b0_011_001	//25
`define JEQZ	`INSTRUCTION_OP_LENGTH'b0_011_010 	//26
`define JNEZ	`INSTRUCTION_OP_LENGTH'b0_011_011	//27
`define JGEZ	`INSTRUCTION_OP_LENGTH'b0_011_100	//28
`define JLEZ	`INSTRUCTION_OP_LENGTH'b0_011_101 	//29

//The next instruction is for simulation debug only
//not to be synthetized! Pretty much behaves the same
//as a NOP, only that prints the register value to
//a log file called 'Registers.log'
`ifdef DEBUG
`define DEBUG_PRINT `INSTRUCTION_OP_LENGTH'b0_011_110	//30
`endif

`define MULP     `INSTRUCTION_OP_LENGTH'b0_011_111			//31	R1.z = S1.x * S1.y
`define MOD      `INSTRUCTION_OP_LENGTH'b0_100_000			//32	R = MODULO( S1,S2 )
`define FRAC     `INSTRUCTION_OP_LENGTH'b0_100_001			//33	R =FractionalPart( S1 )
`define INTP     `INSTRUCTION_OP_LENGTH'b0_100_010			//34	R =IntergerPart( S1 )
`define NEG      `INSTRUCTION_OP_LENGTH'b0_100_011			//35	R = -S1
`define DEC      `INSTRUCTION_OP_LENGTH'b0_100_100			//36	R = S1--
`define XCHANGEX `INSTRUCTION_OP_LENGTH'b0_100_101		//		R.x = S2.x, R.y = S1.y, R.z = S1.z
`define XCHANGEY `INSTRUCTION_OP_LENGTH'b0_100_110		//		R.x = S1.x, R.y = S2.y, R.z = S1.z
`define XCHANGEZ `INSTRUCTION_OP_LENGTH'b0_100_111		//		R.x = S1.x, R.y = S1.y, R.z = S2.z
`define IMUL     `INSTRUCTION_OP_LENGTH'b0_101_000		//		R = INTEGER( S1 * S2 )
`define UNSCALE  `INSTRUCTION_OP_LENGTH'b0_101_001		//		R = S1 >> SCALE
`define RESCALE  `INSTRUCTION_OP_LENGTH'b0_101_010		//		R = S1 << SCALE
`define INCX     `INSTRUCTION_OP_LENGTH'b0_101_011	   //    R.X = S1.X + 1
`define INCY     `INSTRUCTION_OP_LENGTH'b0_101_100	   //    R.Y = S1.Y + 1
`define INCZ     `INSTRUCTION_OP_LENGTH'b0_101_101	   //    R.Z = S1.Z + 1
`define OMWRITE  `INSTRUCTION_OP_LENGTH'b0_101_111	   //47    IO write to O memory
`define TMREAD   `INSTRUCTION_OP_LENGTH'b0_110_000	   //48    IO read from T memory
`define LEA      `INSTRUCTION_OP_LENGTH'b0_110_001	   //49    Load effective address

//*** Type II Instructions (OP DST REG1 IMM) ***
`define RETURN          `INSTRUCTION_OP_LENGTH'b1_000000 //64  0x40
`define SETX            `INSTRUCTION_OP_LENGTH'b1_000001 //65  0x41
`define SETY            `INSTRUCTION_OP_LENGTH'b1_000010 //66
`define SETZ            `INSTRUCTION_OP_LENGTH'b1_000011 //67
`define SWIZZLE3D       `INSTRUCTION_OP_LENGTH'b1_000100 //68 
`define JMP             `INSTRUCTION_OP_LENGTH'b1_011000 //56
`define CALL            `INSTRUCTION_OP_LENGTH'b1_011001 //57
`define RET             `INSTRUCTION_OP_LENGTH'b1_011010 //58

//-------------------------------------------------------------

//All the posible values for the SWIZZLE3D instruction are defined next
`define SWIZZLE_XXX		32'd0
`define SWIZZLE_YYY		32'd1
`define SWIZZLE_ZZZ		32'd2
`define SWIZZLE_XYY		32'd3
`define SWIZZLE_XXY		32'd4
`define SWIZZLE_XZZ		32'd5
`define SWIZZLE_XXZ		32'd6
`define SWIZZLE_YXX		32'd7
`define SWIZZLE_YYX		32'd8
`define SWIZZLE_YZZ		32'd9
`define SWIZZLE_YYZ		32'd10
`define SWIZZLE_ZXX		32'd11
`define SWIZZLE_ZZX		32'd12
`define SWIZZLE_ZYY		32'd13
`define SWIZZLE_ZZY		32'd14
`define SWIZZLE_XZX		32'd15
`define SWIZZLE_XYX		32'd16
`define SWIZZLE_YXY		32'd17
`define SWIZZLE_YZY		32'd18
`define SWIZZLE_ZXZ		32'd19
`define SWIZZLE_ZYZ		32'd20
`define SWIZZLE_YXZ		32'd21




// -----------------------------------------------------------------------------
// Source file: RTL/verilog/mmc_boot_defines.v
// -----------------------------------------------------------------------------
// Copyright 2004-2005 Openchip
// http://www.openchip.org

`ifdef MMC_BOOT_DEFINES
`else
`define MMC_BOOT_DEFINES


// send 80 clocks ?
`define CMD_INIT	4'b1111  

// Initialize
`define CMD0	 			4'b0000  

// identify, loop until ready !
`define CMD1	 			4'b0001  

// just read the rest of response
`define CMD1_IDLE	 		4'b1001  

// read CID
`define CMD2	 			4'b0010  

// assign RCA
`define CMD3	 			4'b0011	

// go transfer
`define CMD7	 			4'b0111	

// stream read command
`define CMD11 			     4'b1011  

// stream read transfer in progress
`define CMD_TRANSFER 		4'b1100  

// config done, just idle wait for reset
`define CMD_CONFIG_DONE 	     4'b1101  

// config error, just idle wait for reset
`define CMD_CONFIG_ERROR 	4'b1110  


`endif

// -----------------------------------------------------------------------------
// Source file: RTL/verilog/virtex_bitstream_const.v
// -----------------------------------------------------------------------------
// Copyright 2004-2005 Openchip
// http://www.openchip.org


// XAPP-151
`define VIRTEX_CFG_CMD_WCFG	4'b0001
`define VIRTEX_CFG_CMD_LFRM	4'b0011
`define VIRTEX_CFG_CMD_RCFG	4'b0100
`define VIRTEX_CFG_CMD_START	4'b0101
`define VIRTEX_CFG_CMD_RCAP	4'b0110
`define VIRTEX_CFG_CMD_RCRC	4'b0111
`define VIRTEX_CFG_CMD_AGHIGH	4'b1000
`define VIRTEX_CFG_CMD_SWITCH	4'b1001
// Virtex-II/Pro, S-3
`define VIRTEX_CFG_CMD_DESYNC	4'b1101 


// XAPP 151
`define VIRTEX_CFG_REG_CRC	4'b0000
`define VIRTEX_CFG_REG_FAR	4'b0001
`define VIRTEX_CFG_REG_FDRI	4'b0010
`define VIRTEX_CFG_REG_FDRO	4'b0011
`define VIRTEX_CFG_REG_CMD	4'b0100
`define VIRTEX_CFG_REG_CTL	4'b0101
`define VIRTEX_CFG_REG_MASK	4'b0110
`define VIRTEX_CFG_REG_STAT	4'b0111
`define VIRTEX_CFG_REG_LOUT	4'b1000
`define VIRTEX_CFG_REG_COR	4'b1001
`define VIRTEX_CFG_REG_FLR	4'b1011


// Virtex-II
`define VIRTEX_CFG_REG_RES_E	4'b1110


// XAPP 151
`define VIRTEX_CFG_OP_READ	2'b01
`define VIRTEX_CFG_OP_WRITE	2'b10






  

// -----------------------------------------------------------------------------
// Source file: RTL/Module_VectorALU.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "aDefinitions.v"
/**********************************************************************************
Theia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2010  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/



//--------------------------------------------------------------
module VectorALU
(
	input wire						Clock,
	input wire						Reset,
	input  wire[`INSTRUCTION_OP_LENGTH-1:0]		iOperation,
	input  wire[`WIDTH-1:0]								iChannel_Ax,
	input  wire[`WIDTH-1:0]								iChannel_Bx,
	input  wire[`WIDTH-1:0]								iChannel_Ay,
	input  wire[`WIDTH-1:0]								iChannel_By,
	input  wire[`WIDTH-1:0]								iChannel_Az,
	input  wire[`WIDTH-1:0]								iChannel_Bz,
	output wire [`WIDTH-1:0]							oResultA,
	output wire [`WIDTH-1:0]							oResultB,
	output wire [`WIDTH-1:0]							oResultC,
	input	 wire												iInputReady,
	output reg												oBranchTaken,
	output reg												oBranchNotTaken,
	output reg                                   oReturnFromSub,
	input wire [`ROM_ADDRESS_WIDTH-1:0]          iCurrentIP,
	
	//Connections to the O Memory
	output wire [`DATA_ROW_WIDTH-1:0]    oOMEMWriteAddress,
	output wire [`DATA_ROW_WIDTH-1:0]    oOMEMWriteData,
	output wire                          oOMEM_WriteEnable,
	//Connections to the R Memory
	output wire [`DATA_ROW_WIDTH-1:0]    oTMEMReadAddress,
	input wire [`DATA_ROW_WIDTH-1:0]     iTMEMReadData,
	input wire                           iTMEMDataAvailable,
	output wire                          oTMEMDataRequest,
	
	output reg 												OutputReady
	
);





wire wMultiplcationUnscaled;
assign wMultiplcationUnscaled = (iOperation == `IMUL) ? 1'b1 : 1'b0;

//--------------------------------------------------------------

reg [7:0]	 InputReadyA,InputReadyB,InputReadyC;

//------------------------------------------------------
/*
	This is the block that takes care of all tha arithmetic
	comparisons. Supported operations are <,>,<=,>=,==,!=
	
*/
//------------------------------------------------------
reg [`WIDTH-1:0] wMultiplicationA_Ax;
reg  [`WIDTH-1:0] wMultiplicationA_Bx;
wire [`LONG_WIDTH-1:0] wMultiplicationA_Result;
wire  wMultiplicationA_InputReady;
wire wMultiplicationA_OutputReady;
wire wMultiplicationOutputReady, wMultiplicationOutputReadyA,
wMultiplicationOutputReadyB,wMultiplicationOutputReadyC,wMultiplicationOutputReadyD;

wire wAddSubAOutputReady,wAddSubBOutputReady,wAddSubCOutputReady;
wire [`INSTRUCTION_OP_LENGTH-1:0] wOperation;
wire [`WIDTH-1:0] wSwizzleOutputX,wSwizzleOutputY,wSwizzleOutputZ;

//--------------------------------------------------------------------
reg [`WIDTH-1:0] ResultA,ResultB,ResultC;

//Output Flip Flops,
//This flip flop will control the outputs so that the
//values of the outputs change ONLY when when there is 
//a positive edge of OutputReady

FFD32_POSEDGE ResultAFFD
(
	.Clock( OutputReady ),
	.D( ResultA ),
	.Q( oResultA )
);

FFD32_POSEDGE ResultBFFD
(
	.Clock( OutputReady ),
	.D( ResultB ),
	.Q( oResultB )
);

FFD32_POSEDGE ResultCFFD
(
	.Clock( OutputReady ),
	.D( ResultC ),
	.Q( oResultC )
);
//--------------------------------------------------------------------



Swizzle3D Swizzle1
(
	.Source0_X( iChannel_Bx ),
	.Source0_Y( iChannel_By ),
	.Source0_Z( iChannel_Bz ),
	.iOperation( iChannel_Ax ),
		
	.SwizzleX( wSwizzleOutputX ),
	.SwizzleY( wSwizzleOutputY ),
	.SwizzleZ( wSwizzleOutputZ )
);
//---------------------------------------------------------------------
wire [`LONG_WIDTH-1:0] wModulus2N_ResultA,wModulus2N_ResultB,wModulus2N_ResultC;

//---------------------------------------------------------------------(

wire IOW_Operation,wOMEM_We;
assign IOW_Operation = (iOperation == `OMWRITE);

always @ ( * )
begin
	if (iOperation == `RET)
		oReturnFromSub <= OutputReady;
	else
		oReturnFromSub <= 1'b0;
  
end

FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD1_AWE
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( 1'b1 ),
	.D( IOW_Operation ),
	.Q( wOMEM_We )
);

assign oOMEM_WriteEnable = wOMEM_We & IOW_Operation;

FFD_POSEDGE_SYNCRONOUS_RESET # ( `DATA_ROW_WIDTH ) FFD1_A
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( {iChannel_Ax,iChannel_Ay,iChannel_Az} ),
	.Q( oOMEMWriteAddress)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `DATA_ROW_WIDTH ) FFD2_B
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( {iChannel_Bx,iChannel_By,iChannel_Bz} ),
	.Q( oOMEMWriteData )
);



wire wTMReadOutputReady;
assign wTMReadOutputReady = iTMEMDataAvailable;
/*
FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD1_ARE
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( 1'b1 ),
	.D( iTMEMDataAvailable ),
	.Q( wTMReadOutputReady )
);
*/
//assign oTMEMReadAddress = {iChannel_Ax,iChannel_Ay,iChannel_Az};

//We wait 1 clock cycle before be send the data read request, because
//we need to lathc the values at the output

wire wOpTRead;
assign wOpTRead = ( iOperation == `TMREAD ) ? 1'b1 : 1'b0;
wire wTMEMRequest;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD1_ARE123
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( 1'b1 ),
	.D( wOpTRead ),
	.Q( wTMEMRequest )
);
assign oTMEMDataRequest = wTMEMRequest & wOpTRead;
FFD_POSEDGE_SYNCRONOUS_RESET # ( `DATA_ROW_WIDTH ) FFD2_B445
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady & wOpTRead ),
	.D( {iChannel_Ax,iChannel_Ay,iChannel_Az} ),
	.Q( oTMEMReadAddress )
);

/*
	This MUX will select the apropiated X,Y or Z depending on
	wheter it is XYZ iOperation. This gets defined by the bits 3 and 4 
	of iOperation, and only applies for oBranchTaken and Store operations.
*/

wire 					wArithmeticComparison_Result;
wire 					ArithmeticComparison_InputReady;
wire 					ArithmeticComparison_OutputReady;
reg[`WIDTH-1:0] 	ArithmeticComparison_A,ArithmeticComparison_B;


always @ ( * )
begin
	case ( {iOperation[4],iOperation[3]} )
		2'b01: 		ArithmeticComparison_A = iChannel_Ax;
		2'b10: 		ArithmeticComparison_A = iChannel_Ay;
		2'b11:		ArithmeticComparison_A = iChannel_Az;
		default: ArithmeticComparison_A = 0;	//Should never happen
	endcase
end
//---------------------------------------------------------------------
always @ ( * )
begin
	case ( {iOperation[4],iOperation[3]} )
		2'b01: 		ArithmeticComparison_B = iChannel_Bx;
		2'b10: 		ArithmeticComparison_B = iChannel_By;
		2'b11:		ArithmeticComparison_B = iChannel_Bz;
		default: ArithmeticComparison_B = 0;	//Should never happen
	endcase
end

//---------------------------------------------------------------------
/*
	The onbly instance of Aritmetic comparison in the ALU,
	ArithmeticComparison operations matches the 3 LSB of 
	Global ALU iOperation for oBranchTaken Instruction family
*/

assign ArithmeticComparison_InputReady = iInputReady;

wire wArithmeticComparisonResult;

ArithmeticComparison ArithmeticComparison_1
(
	.Clock( Clock ),
	.X( ArithmeticComparison_A ),
	.Y( ArithmeticComparison_B ),
	.iOperation( iOperation[2:0] ),
	.iInputReady( ArithmeticComparison_InputReady ),
	.OutputReady( ArithmeticComparison_OutputReady ),
	.Result( wArithmeticComparisonResult )
);


assign  wArithmeticComparison_Result = wArithmeticComparisonResult && OutputReady; 
//--------------------------------------------------------------------
 RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_A
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationA_Ax ),
	.B( wMultiplicationA_Bx ),
	.R( wMultiplicationA_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationA_InputReady ),
	.OutputReady( wMultiplicationA_OutputReady )
);

//--------------------------------------------------------------------
always @ ( * )
begin
	case (iOperation)
	`CROSS: 		wMultiplicationA_Ax = iChannel_Ay;	// Ay * Bz
	`MAG:			wMultiplicationA_Ax = iChannel_Ax;
	`MULP:		wMultiplicationA_Ax = iChannel_Ax;	//Az = Ax * Ay
	default: 	wMultiplicationA_Ax = iChannel_Ax;	// Ax * Bx
	endcase
end
//--------------------------------------------------------------------

//assign wMultiplicationA_Ax = iChannel_Ax;

assign wMultiplicationA_InputReady 
	= (iOperation == `CROSS || 
		iOperation == `DOT	||
		iOperation == `MUL 	|| 
		iOperation == `IMUL 	|| 
		iOperation == `MAG	||
		iOperation == `MULP  
		) ? iInputReady : 0;
	
//--------------------------------------------------------------------
always @ ( * )
begin
	case (iOperation)
	`MUL,`IMUL:			wMultiplicationA_Bx = iChannel_Bx;	//Ax*Bx
	`MAG:			wMultiplicationA_Bx = iChannel_Ax;	//Ax^2
	`DOT:			wMultiplicationA_Bx = iChannel_Bx;	//Ax*Bx
	`CROSS:		wMultiplicationA_Bx = iChannel_Bz;	// Ay * Bz
	`MULP:		wMultiplicationA_Bx = iChannel_Ay;  //Az = Ax * Ay
	default:		wMultiplicationA_Bx = 32'b0;
	endcase
end
//--------------------------------------------------------------------

//------------------------------------------------------

reg [`WIDTH-1:0] wMultiplicationB_Ay;
reg [`WIDTH-1:0]  wMultiplicationB_By;
wire [`LONG_WIDTH-1:0] wMultiplicationB_Result;
wire wMultiplicationB_InputReady;
wire wMultiplicationB_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_B
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationB_Ay ),
	.B( wMultiplicationB_By ),
	.R( wMultiplicationB_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationB_InputReady ),
	.OutputReady( wMultiplicationB_OutputReady )
);


//----------------------------------------------------

always @ ( * )
begin
	case (iOperation)
		`CROSS: 	wMultiplicationB_Ay = iChannel_Az;	// Az * By
		`MAG: 	wMultiplicationB_Ay = iChannel_Ay;
		default: wMultiplicationB_Ay = iChannel_Ay;	// Ay * By
	endcase
end
//----------------------------------------------------
assign wMultiplicationB_InputReady 
	= (iOperation == `CROSS 			|| 
		iOperation == `DOT	||	
		iOperation == `MUL 		|| 
		iOperation == `IMUL 		|| 
		iOperation == `MAG ) ? iInputReady : 0;
	
//----------------------------------------------------
always @ ( * )
begin
	case (iOperation)
	`MUL,`IMUL:			wMultiplicationB_By = iChannel_By;	//Ay*By
	`MAG:			wMultiplicationB_By = iChannel_Ay;	//Ay^2
	`DOT:			wMultiplicationB_By = iChannel_By;	//Ay*By
	`CROSS:		wMultiplicationB_By = iChannel_By;	// Az * By
	default:		wMultiplicationB_By = 32'b0;
	endcase
end
//----------------------------------------------------
	
//------------------------------------------------------
reg [`WIDTH-1:0] wMultiplicationC_Az;
reg  [`WIDTH-1:0] wMultiplicationC_Bz;
wire [`LONG_WIDTH-1:0] wMultiplicationC_Result;
wire wMultiplicationC_InputReady;
wire wMultiplicationC_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_C
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationC_Az ),
	.B( wMultiplicationC_Bz ),
	.R( wMultiplicationC_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationC_InputReady ),
	.OutputReady( wMultiplicationC_OutputReady )
);


//----------------------------------------------------
always @ ( * )
begin
	case (iOperation)
		`CROSS: 	wMultiplicationC_Az = iChannel_Az; 	//Az*Bx
		`MAG: 	wMultiplicationC_Az = iChannel_Az;
		default: 				wMultiplicationC_Az = iChannel_Az;	//Az*Bz
	endcase	
end
//----------------------------------------------------

assign wMultiplicationC_InputReady 
	= (
		iOperation == `CROSS 			|| 
		iOperation == `DOT	||	
		iOperation == `MUL 		||
		iOperation == `IMUL 		||
		iOperation == `MAG 
		) ? iInputReady : 0;
	
//----------------------------------------------------
always @ ( * )
begin
	case (iOperation)
	`MUL,`IMUL:			wMultiplicationC_Bz = iChannel_Bz;	//Az*Bz
	`MAG:			wMultiplicationC_Bz = iChannel_Az;	//Ay^2
	`DOT:			wMultiplicationC_Bz = iChannel_Bz;	//Az*Bz
	`CROSS:		wMultiplicationC_Bz = iChannel_Bx;	//Az*Bx
	default:		wMultiplicationC_Bz = 32'b0;
	endcase
end
//----------------------------------------------------	

reg [`WIDTH-1:0] wMultiplicationD_Aw;
reg  [`WIDTH-1:0] wMultiplicationD_Bw;
wire [`LONG_WIDTH-1:0] wMultiplicationD_Result;
wire wMultiplicationD_InputReady;
wire wMultiplicationD_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_D
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationD_Aw ),
	.B( wMultiplicationD_Bw ),
	.R( wMultiplicationD_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationD_InputReady ),
	.OutputReady( wMultiplicationD_OutputReady )
);

assign wMultiplicationD_InputReady 
	= (iOperation == `CROSS ) ? iInputReady : 0;


//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationD_Aw = iChannel_Ax;	//Ax*Bz
	default:							wMultiplicationD_Aw = 32'b0;
	endcase
end
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationD_Bw = iChannel_Bz;	//Ax*Bz
	default:							wMultiplicationD_Bw = 32'b0;
	endcase
end
//----------------------------------------------------	
reg [`WIDTH-1:0] wMultiplicationE_Ak;
reg  [`WIDTH-1:0] wMultiplicationE_Bk;
wire [`LONG_WIDTH-1:0] wMultiplicationE_Result;
wire wMultiplicationE_InputReady;
wire wMultiplicationE_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_E
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationE_Ak ),
	.B( wMultiplicationE_Bk ),
	.R( wMultiplicationE_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationE_InputReady ),
	.OutputReady( wMultiplicationE_OutputReady )
);

assign wMultiplicationE_InputReady 
	= (iOperation == `CROSS ) ? iInputReady : 0;
	
	
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationE_Ak = iChannel_Ax;	//Ax*By
	default:			wMultiplicationE_Ak = 32'b0;
	endcase
end
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationE_Bk = iChannel_By;	//Ax*By
	default:			wMultiplicationE_Bk = 32'b0;
	endcase
end	
	
//----------------------------------------------------		
reg [`WIDTH-1:0] wMultiplicationF_Al;
reg  [`WIDTH-1:0] wMultiplicationF_Bl;
wire [`LONG_WIDTH-1:0] wMultiplicationF_Result;
wire wMultiplicationF_InputReady;
wire wMultiplicationF_OutputReady;


RADIX_R_MUL_32_FULL_PARALLEL MultiplicationChannel_F
(

	.Clock( Clock ),
	.Reset( Reset ),
	.A( wMultiplicationF_Al ),
	.B( wMultiplicationF_Bl ),
	.R( wMultiplicationF_Result ),
	.iUnscaled( wMultiplcationUnscaled ),
	.iInputReady( wMultiplicationF_InputReady ),
	.OutputReady( wMultiplicationF_OutputReady )
);
assign wMultiplicationF_InputReady 
	= (iOperation == `CROSS ) ? iInputReady : 0;
	
	
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationF_Al = iChannel_Ay;	//Ay*Bx
	default:			wMultiplicationF_Al = 32'b0;
	endcase
end
//----------------------------------------------------	
always @ ( * )
begin
	case (iOperation)
	`CROSS:			wMultiplicationF_Bl = iChannel_Bx;	//Ay*Bx
	default:			wMultiplicationF_Bl = 32'b0;
	endcase
end		
//------------------------------------------------------
wire [`WIDTH-1:0] wDivisionA_Result;
wire wDivisionA_OutputReady;
wire wDivisionA_InputReady;

assign wDivisionA_InputReady = 
	( iOperation == `DIV) ? iInputReady : 0;

SignedIntegerDivision DivisionChannel_A
(
.Clock( Clock ),
.Reset( Reset ),
.iDividend( iChannel_Ax ),
.iDivisor( 	iChannel_Bx ),
.xQuotient( wDivisionA_Result ),
.iInputReady( wDivisionA_InputReady ),
.OutputReady( wDivisionA_OutputReady )

);
//------------------------------------------------------
wire [`WIDTH-1:0] wDivisionB_Result;
wire wDivisionB_OutputReady;
wire wDivisionB_InputReady;

assign wDivisionB_InputReady = 
	( iOperation == `DIV) ? iInputReady : 0;

SignedIntegerDivision DivisionChannel_B
(
.Clock( Clock ),
.Reset( Reset ),
.iDividend( iChannel_Ay ),
.iDivisor( iChannel_By ),
.xQuotient( wDivisionB_Result ),
.iInputReady( wDivisionB_InputReady ),
.OutputReady( wDivisionB_OutputReady )

);
//------------------------------------------------------
wire [`WIDTH-1:0] wDivisionC_Result;
wire wDivisionC_OutputReady;
wire wDivisionC_InputReady;


assign wDivisionC_InputReady = 
	( iOperation == `DIV) ? iInputReady : 0;

SignedIntegerDivision DivisionChannel_C
(
.Clock( Clock ),
.Reset( Reset ),
.iDividend( iChannel_Az ),
.iDivisor( iChannel_Bz ),
.xQuotient( wDivisionC_Result ),
.iInputReady( wDivisionC_InputReady ),
.OutputReady( wDivisionC_OutputReady )

);
//--------------------------------------------------------------
/*
	First addtion block instance goes here.
	Note that all inputs/outputs to the block
	are wires. It has two MUXES one for each entry.
*/
reg [`LONG_WIDTH-1:0] wAddSubA_Ax,wAddSubA_Bx;
wire [`LONG_WIDTH-1:0] wAddSubA_Result;
wire wAddSubA_Operation; //Either addition or substraction
reg wAddSubA_InputReady;
wire wAddSubA_OutputReady;

assign wAddSubA_Operation 
	= ( 
		iOperation == `SUB 	 
		|| iOperation == `CROSS 
		|| iOperation == `DEC	
		|| iOperation == `MOD	
	) ? 1 : 0;

FixedAddSub AddSubChannel_A
(
.Clock( Clock ),
.Reset( Reset ),
.A( wAddSubA_Ax ),
.B( wAddSubA_Bx ),
.R( wAddSubA_Result ),
.iOperation( wAddSubA_Operation ),
.iInputReady( wAddSubA_InputReady ),		
.OutputReady( wAddSubA_OutputReady )		
);
//Diego


//----------------------------

//InpuReady Mux A
always @ ( * )
begin
	case (iOperation)
	`ADD:		wAddSubA_InputReady = iInputReady;
	`SUB:		wAddSubA_InputReady = iInputReady;
	`INC,`INCX,`INCY,`INCZ:		wAddSubA_InputReady = iInputReady;
	`DEC:		wAddSubA_InputReady = iInputReady;
	`MOD:		wAddSubA_InputReady = iInputReady;
	
	`MAG:		wAddSubA_InputReady = wMultiplicationOutputReadyA &&
												wMultiplicationOutputReadyB;
										//wMultiplicationA_OutputReady 
										//&& wMultiplicationB_OutputReady;
										
	`DOT:		wAddSubA_InputReady = 
											wMultiplicationOutputReadyA &&
											wMultiplicationOutputReadyB;
										//wMultiplicationA_OutputReady 
										//&& wMultiplicationB_OutputReady;
										
	`CROSS:	wAddSubA_InputReady =
										wMultiplicationOutputReadyA &&
										wMultiplicationOutputReadyB;
										// wMultiplicationA_OutputReady
										//&& wMultiplicationB_OutputReady;
										
	default:	wAddSubA_InputReady = 1'b0;									
	endcase
end
//----------------------------

//wAddSubA_Bx 2:1 input Mux
always @ ( * )
begin
	case (iOperation)
	
	`ADD:		wAddSubA_Ax = ( iChannel_Ax[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ax } : { 32'b0, iChannel_Ax };
	`SUB: 	wAddSubA_Ax = ( iChannel_Ax[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ax } : { 32'b0, iChannel_Ax };
	`INC,`INCX,`INCY,`INCZ:		wAddSubA_Ax = ( iChannel_Ax[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ax } : { 32'b0, iChannel_Ax };
	`DEC:		wAddSubA_Ax = ( iChannel_Ax[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ax } : { 32'b0, iChannel_Ax };
	`MOD:		wAddSubA_Ax = ( iChannel_Bx[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Bx } : { 32'b0, iChannel_Bx };
	
	`MAG:		wAddSubA_Ax = wMultiplicationA_Result;
	`DOT:		wAddSubA_Ax = wMultiplicationA_Result;
	`CROSS:	wAddSubA_Ax = wMultiplicationA_Result;
	default:	wAddSubA_Ax = 64'b0;
	endcase
end
//----------------------------
//wAddSubA_Bx 2:1 input Mux
always @ ( * )
begin
	case (iOperation)
	`ADD: wAddSubA_Bx = ( iChannel_Bx[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Bx } : { 32'b0, iChannel_Bx };
	`SUB: wAddSubA_Bx = ( iChannel_Bx[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Bx } : { 32'b0, iChannel_Bx };
	`INC,`INCX: wAddSubA_Bx = (`LONG_WIDTH'd1 << `SCALE);
	`INCY,`INCZ: wAddSubA_Bx = `LONG_WIDTH'd0;
	`DEC: wAddSubA_Bx = (`LONG_WIDTH'd1 << `SCALE);
	`MOD: wAddSubA_Bx = (`LONG_WIDTH'd1 << `SCALE);
	
	`MAG:		wAddSubA_Bx = wMultiplicationB_Result;
	`DOT:		wAddSubA_Bx = wMultiplicationB_Result;
	`CROSS:	wAddSubA_Bx = wMultiplicationB_Result;
	default:	wAddSubA_Bx = 64'b0;
	endcase
end
//--------------------------------------------------------------
/*
	Second addtion block instance goes here.
	Note that all inputs/outputs to the block
	are wires. It has two MUXES one for each entry.
*/

wire [`LONG_WIDTH-1:0] wAddSubB_Result;


wire wAddSubB_Operation; //Either addition or substraction
reg  wAddSubB_InputReady;
wire wAddSubB_OutputReady;

reg [`LONG_WIDTH-1:0] wAddSubB_Ay,wAddSubB_By;

assign wAddSubB_Operation = 
	( iOperation == `SUB 	 
	  || iOperation == `CROSS 	
	  || iOperation == `DEC		
	  || iOperation == `MOD 
	  ) ? 1 : 0;

FixedAddSub AddSubChannel_B
(
.Clock( Clock ),
.Reset( Reset ),
.A( wAddSubB_Ay ),
.B( wAddSubB_By ),
.R( wAddSubB_Result ),
.iOperation( wAddSubB_Operation ),
.iInputReady( wAddSubB_InputReady ),		
.OutputReady( wAddSubB_OutputReady )		
);
//----------------------------
wire wMultiplicationOutputReadyC_Dealy1;
FFD_POSEDGE_ASYNC_RESET # (1) FFwMultiplicationOutputReadyC_Dealy1
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( wMultiplicationOutputReadyC ),
	.Q( wMultiplicationOutputReadyC_Dealy1 )
);	





//InpuReady Mux B
always @ ( * )
begin
	case (iOperation)
	`ADD:		wAddSubB_InputReady = iInputReady;
	`SUB:		wAddSubB_InputReady = iInputReady;
	`INC,`INCX,`INCY,`INCZ:		wAddSubB_InputReady = iInputReady;
	`DEC:		wAddSubB_InputReady = iInputReady;
	`MOD:		wAddSubB_InputReady = iInputReady;
	
	`MAG:		wAddSubB_InputReady = wAddSubAOutputReady 
											&& wMultiplicationOutputReadyC_Dealy1;
										//&& wMultiplicationC_OutputReady;
										
	`DOT:		wAddSubB_InputReady = wAddSubAOutputReady 
										&& wMultiplicationOutputReadyC_Dealy1;
										//&& wMultiplicationC_OutputReady;
										
	`CROSS:	wAddSubB_InputReady = wMultiplicationOutputReadyC &&
											 wMultiplicationOutputReadyD;
										//	wMultiplicationC_OutputReady
										//&& wMultiplicationD_OutputReady;
										
	default:	wAddSubB_InputReady = 1'b0;									
	
	endcase
end
//----------------------------
// wAddSubB_Ay 2:1 input Mux
// If the iOperation is ADD or SUB, it will simply take the inputs from
// ALU Channels. If it is a VECTOR_MAGNITUDE, it take the input from the
// previus ADDER_A, same for dot product.
always @ ( * )
begin
	case (iOperation)
	`ADD: 	wAddSubB_Ay = (iChannel_Ay[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ay} : {32'b0,iChannel_Ay};		//Ay
	`SUB: 	wAddSubB_Ay = (iChannel_Ay[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ay} : {32'b0,iChannel_Ay};		//Ay
	`INC,`INCX,`INCY,`INCZ:		wAddSubB_Ay = (iChannel_Ay[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ay} : {32'b0,iChannel_Ay};		//Ay
	`DEC:		wAddSubB_Ay = (iChannel_Ay[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_Ay} : {32'b0,iChannel_Ay};		//Ay
	`MOD:		wAddSubB_Ay = (iChannel_By[31] == 1'b1) ? {32'hFFFFFFFF, iChannel_By} : {32'b0,iChannel_By};		//Ay
	`MAG:		wAddSubB_Ay = wAddSubA_Result;	//A^2+B^2
	`DOT:		wAddSubB_Ay = wAddSubA_Result;   //Ax*Bx + Ay*By
	`CROSS:	wAddSubB_Ay	= wMultiplicationC_Result;	
	default:	wAddSubB_Ay = 64'b0;
	endcase
end
//----------------------------
//wAddSubB_By 2:1 input Mux
always @ ( * )
begin
	case (iOperation)
	`ADD: 	wAddSubB_By = (iChannel_By[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_By } : {32'b0,iChannel_By};				//By
	`SUB: 	wAddSubB_By = (iChannel_By[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_By } : {32'b0,iChannel_By}; //{32'b0,iChannel_By};				//By
	`INC,`INCY:		wAddSubB_By = (`LONG_WIDTH'd1 << `SCALE);
	`INCX,`INCZ:   wAddSubB_By = `LONG_WIDTH'd0;
	`DEC:		wAddSubB_By = (`LONG_WIDTH'd1 << `SCALE);
	`MOD:		wAddSubB_By = (`LONG_WIDTH'd1 << `SCALE);
	`MAG:		wAddSubB_By = wMultiplicationC_Result;	//C^2
	`DOT:		wAddSubB_By = wMultiplicationC_Result;	//Az * Bz
	`CROSS:	wAddSubB_By	= wMultiplicationD_Result;	
	default:	wAddSubB_By = 32'b0;
	endcase
end
//--------------------------------------------------------------
wire [`LONG_WIDTH-1:0] wAddSubC_Result;
reg [`LONG_WIDTH-1:0] wAddSubC_Az,wAddSubC_Bz;

wire wAddSubC_Operation; //Either addition or substraction
reg wAddSubC_InputReady;
wire wAddSubC_OutputReady;

reg [`LONG_WIDTH-1:0] AddSubC_Az,AddSubB_Bz;

//-----------------------------------------
always @ ( * )
begin	
	case (iOperation)
		`CROSS: 	wAddSubC_Az = wMultiplicationE_Result;
		`MOD: wAddSubC_Az = (iChannel_Bz[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_Bz} : {32'b0,iChannel_Bz};
		default: 				wAddSubC_Az = (iChannel_Az[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_Az} : {32'b0,iChannel_Az};
	endcase
end	
//-----------------------------------------
always @ ( * )
begin	
	case (iOperation)
		`CROSS: 	wAddSubC_Bz = wMultiplicationF_Result;
		`INC,`INCZ:		wAddSubC_Bz = (`LONG_WIDTH'd1 << `SCALE);
		`INCX,`INCY:   wAddSubC_Bz = `LONG_WIDTH'd0;
		`DEC:		wAddSubC_Bz = (`LONG_WIDTH'd1 << `SCALE);
		`MOD:		wAddSubC_Bz = (`LONG_WIDTH'd1 << `SCALE);
		default: 				wAddSubC_Bz = (iChannel_Bz[31] == 1'b1) ? {32'hFFFFFFFF,iChannel_Bz} : {32'b0,iChannel_Bz};
	endcase
end	
//-----------------------------------------

assign wAddSubC_Operation 
	= ( 
		iOperation == `SUB 		
		|| iOperation == `CROSS 	
		|| iOperation == `DEC 		
		|| iOperation == `MOD	
		) ? 1 : 0;

FixedAddSub AddSubChannel_C
(
.Clock( Clock ),
.Reset( Reset ),
.A( wAddSubC_Az ),
.B( wAddSubC_Bz ),
.R( wAddSubC_Result ),
.iOperation( wAddSubC_Operation ),
.iInputReady( wAddSubC_InputReady ),		
.OutputReady( wAddSubC_OutputReady )		
);


always @ ( * )
begin	
	case (iOperation)
	`CROSS:	wAddSubC_InputReady = wMultiplicationE_OutputReady && 
		wMultiplicationF_OutputReady;
		
	default: wAddSubC_InputReady = iInputReady;	
	endcase
end

//------------------------------------------------------
wire [`WIDTH-1:0] wSquareRoot_Result;
wire wSquareRoot_OutputReady;


FixedPointSquareRoot SQROOT1
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Operand( wAddSubB_Result ),			
	.iInputReady( wAddSubBOutputReady && iOperation == `MAG),					
	.OutputReady( wSquareRoot_OutputReady ),	
	.Result( wSquareRoot_Result )
);
//------------------------------------------------------

assign wModulus2N_ResultA =  (iChannel_Ax  & wAddSubA_Result );
assign wModulus2N_ResultB =  (iChannel_Ay  & wAddSubB_Result );
assign wModulus2N_ResultC =  (iChannel_Az  & wAddSubC_Result );






//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&//
//****Mux for ResultA***
// Notice that the Dot Product or the Magnitud Result will
// output in ResultA.

always @ ( *  )
begin
	case ( iOperation )
	`RETURN:				ResultA = iChannel_Ax;
	`ADD:			  		ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};// & 32'h7FFFFFFF;
	`SUB:	  				ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};//wAddSubA_Result[31:0];
	`CROSS:				ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};//wAddSubA_Result[31:0];
	`DIV:		  	  		ResultA = wDivisionA_Result;
	`MUL:   				ResultA = wMultiplicationA_Result[31:0];
	`IMUL:            ResultA = wMultiplicationA_Result[31:0];
	`DOT:					ResultA = (wAddSubB_Result[63] == 1'b1) ? { 1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]};//wAddSubB_Result[31:0];
	`MAG:					ResultA = wSquareRoot_Result;
	`ZERO:				ResultA = 32'b0;
	`COPY:				ResultA = iChannel_Ax;
	`TMREAD:          ResultA = iTMEMReadData[95:64];
	`LEA:             ResultA = {16'b0,iCurrentIP};
	
	`SWIZZLE3D: ResultA  = wSwizzleOutputX;
	
	//Set Operations
	`UNSCALE:			ResultA  = iChannel_Ax >> `SCALE;
	`SETX,`RET:   	ResultA  = iChannel_Ax;
   `SETY:				ResultA  = iChannel_Bx; 	
	`SETZ:				ResultA  = iChannel_Bx;  
	`INC,`INCX,`INCY,`INCZ:					ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};
	`DEC:					ResultA = (wAddSubA_Result[63] == 1'b1) ? { 1'b1,wAddSubA_Result[30:0]} : {1'b0,wAddSubA_Result[30:0]};
	`MOD:					ResultA =  wModulus2N_ResultA;
	`FRAC:				ResultA = iChannel_Ax & (`WIDTH'hFFFFFFFF >> (`WIDTH - `SCALE));
	`MULP:			   ResultA = iChannel_Ax;
	`NEG:				 	ResultA = ~iChannel_Ax + 1'b1;
	`XCHANGEX:			ResultA  = iChannel_Bx;

	default:				
	begin
	`ifdef DEBUG
//	$display("%dns ALU: Error Unknown Operation: %d",$time,iOperation);
//	$stop();
	`endif
	ResultA =  32'b0;
	end
	endcase	
end
//------------------------------------------------------
//****Mux for RB***
always @ ( * )
begin
	case ( iOperation )
	`RETURN:				ResultB = iChannel_Ax;
	`ADD:			  		ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]}; // & 32'h7FFFFFFF;
	`SUB:		  			ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]}; //wAddSubB_Result[31:0];
	`CROSS:				ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]};//wAddSubB_Result[31:0];
	`DIV:		  	  		ResultB = wDivisionB_Result;
	`MUL:   				ResultB = wMultiplicationB_Result[31:0];
	`IMUL:            ResultB = wMultiplicationB_Result[31:0];
	`DOT:					ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]};//wAddSubB_Result[31:0];
	`MAG:					ResultB = wSquareRoot_Result;
	`ZERO:				ResultB = 32'b0;
	`COPY:				ResultB = iChannel_Ay;
	`TMREAD:          ResultB = iTMEMReadData[63:32];
	`LEA:             ResultB = {16'b0,iCurrentIP};
	
	//Set Operations
	`UNSCALE:			ResultB  = iChannel_Ay >> `SCALE;
	`SETX,`RET:		ResultB  = iChannel_By; 	// {Source1[95:64],Source0[63:32],Source0[31:0]}; 
	`SETY:				ResultB  = iChannel_Ax; 	// {Source0[95:64],Source1[95:64],Source0[31:0]}; 
	`SETZ:				ResultB  = iChannel_By;  // {Source0[95:64],Source0[63:32],Source1[95:64]}; 
	
	`SWIZZLE3D: 		ResultB  = wSwizzleOutputY;
	
	`INC,`INCX,`INCY,`INCZ:			  		ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]}; // & 32'h7FFFFFFF;
	`DEC:			  		ResultB = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]}; // & 32'h7FFFFFFF;
	`MOD:					ResultB =  wModulus2N_ResultB;
	`FRAC:				ResultB = iChannel_Ay & (`WIDTH'hFFFFFFFF >> (`WIDTH - `SCALE));
	`MULP:				ResultB = iChannel_Ay;
	`NEG:					ResultB = ~iChannel_Ay + 1'b1;
	`XCHANGEX:			ResultB = iChannel_Ay;
	
	default:				
	begin
	`ifdef DEBUG
	//$display("%dns ALU: Error Unknown Operation: %d",$time,iOperation);
	//$stop();
	`endif
	ResultB =  32'b0;
	end
	endcase	
end
//------------------------------------------------------
//****Mux for RC***
always @ ( * )
begin
	case ( iOperation )
	`RETURN:				ResultC = iChannel_Ax;
	`ADD:			  		ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]}; //wAddSubC_Result[31:0];// & 32'h7FFFFFFF;
	`SUB:		  			ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]}; //wAddSubC_Result[31:0];
	`CROSS:				ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]};//wAddSubC_Result[31:0];
	`DIV:		  	  		ResultC = wDivisionC_Result;
	`MUL:   				ResultC = wMultiplicationC_Result[31:0];
	`IMUL:            ResultC = wMultiplicationC_Result[31:0];
	`DOT:					ResultC = (wAddSubB_Result[63] == 1'b1) ? {1'b1,wAddSubB_Result[30:0]} : {1'b0,wAddSubB_Result[30:0]};//wAddSubB_Result[31:0];
	`MAG:					ResultC = wSquareRoot_Result;
	`ZERO:				ResultC = 32'b0;
	`COPY:				ResultC = iChannel_Az;
	`TMREAD:          ResultC = iTMEMReadData[31:0];
	`LEA:             ResultC = {16'b0,iCurrentIP};
	
	`SWIZZLE3D: ResultC  = wSwizzleOutputZ;
	
	//Set Operations
	`UNSCALE:			ResultC  = iChannel_Az >> `SCALE;
	`SETX,`RET:		ResultC  = iChannel_Bz; 	// {Source1[95:64],Source0[63:32],Source0[31:0]}; 
	`SETY:				ResultC  = iChannel_Bz; 	// {Source0[95:64],Source1[95:64],Source0[31:0]}; 
	`SETZ:				ResultC  = iChannel_Ax;  // {Source0[95:64],Source0[63:32],Source1[95:64]}; 
	
	`INC,`INCX,`INCY,`INCZ:			  		ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]}; //wAddSubC_Result[31:0];// & 32'h7FFFFFFF;
	`DEC:			  		ResultC = (wAddSubC_Result[63] == 1'b1) ? {1'b1,wAddSubC_Result[30:0]} : {1'b0,wAddSubC_Result[30:0]}; //wAddSubC_Result[31:0];// & 32'h7FFFFFFF;
	`MOD:					ResultC =  wModulus2N_ResultC;
	`FRAC:				ResultC = iChannel_Az & (`WIDTH'hFFFFFFFF >> (`WIDTH - `SCALE));
	`MULP:				ResultC = wMultiplicationA_Result[31:0];
	`NEG:					ResultC = ~iChannel_Az + 1'b1;
	`XCHANGEX:			ResultC = iChannel_Az;
	default:
	begin
	`ifdef DEBUG
	//$display("%dns ALU: Error Unknown Operation: %d",$time,iOperation);
	//$stop();
	`endif
	ResultC =  32'b0;
	end
	endcase	
end
//------------------------------------------------------------------------


always @ ( * )
begin
	case (iOperation)
	`JMP,`CALL,`RET: oBranchTaken = OutputReady;
	`JGX:	oBranchTaken = wArithmeticComparison_Result;
	`JGY:	oBranchTaken = wArithmeticComparison_Result;
	`JGZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JLX:	oBranchTaken = wArithmeticComparison_Result;
	`JLY:	oBranchTaken = wArithmeticComparison_Result;
	`JLZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JEQX:	oBranchTaken = wArithmeticComparison_Result;
	`JEQY:	oBranchTaken = wArithmeticComparison_Result;
	`JEQZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JNEX:	oBranchTaken = wArithmeticComparison_Result;
	`JNEY:	oBranchTaken = wArithmeticComparison_Result;
	`JNEZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JGEX:	oBranchTaken = wArithmeticComparison_Result;
	`JGEY:	oBranchTaken = wArithmeticComparison_Result;
	`JGEZ:	oBranchTaken = wArithmeticComparison_Result;
	
	`JLEX:	oBranchTaken = wArithmeticComparison_Result;
	`JLEY:	oBranchTaken = wArithmeticComparison_Result;
	`JLEZ:	oBranchTaken = wArithmeticComparison_Result;
	
	default: oBranchTaken = 0;
	endcase
	
end

always @ ( * )
begin
	case (iOperation)
	
		`JMP,`CALL,`RET,`JGX,`JGY,`JGZ,`JLX,`JLY,`JLZ,`JEQX,`JEQY,`JEQZ,
		`JNEX,`JNEY,`JNEZ,`JGEX,`JGEY,`JGEZ: oBranchNotTaken = !oBranchTaken && OutputReady;
		`JLEX: oBranchNotTaken = !oBranchTaken && OutputReady;
		`JLEY: oBranchNotTaken = !oBranchTaken && OutputReady;
		`JLEZ: oBranchNotTaken = !oBranchTaken && OutputReady;
	default:
		oBranchNotTaken = 0;
	endcase
end
//------------------------------------------------------------------------
//Output ready logic Stuff for Division...
//Some FFT will hopefully do the trick

wire wDivisionOutputReadyA,wDivisionOutputReadyB,wDivisionOutputReadyC;
wire wDivisionOutputReady;


assign wAddSubAOutputReady = wAddSubA_OutputReady;
assign wAddSubBOutputReady = wAddSubB_OutputReady;
assign wAddSubCOutputReady = wAddSubC_OutputReady;


FFT1 FFT_DivisionA
  (
   .D(1'b1),
   .Clock( wDivisionA_OutputReady ), 
   .Reset( iInputReady ), 
   .Q( wDivisionOutputReadyA )
 );

FFT1 FFT_DivisionB
  (
   .D(1'b1),
   .Clock( wDivisionB_OutputReady ), 
   .Reset( iInputReady ), 
   .Q( wDivisionOutputReadyB )
 );
 
 FFT1 FFT_DivisionC
  (
   .D(1'b1),
   .Clock( wDivisionC_OutputReady ), 
   .Reset( iInputReady ), 
   .Q( wDivisionOutputReadyC )
 );
 
 assign wDivisionOutputReady = 
 ( wDivisionOutputReadyA && wDivisionOutputReadyB && wDivisionOutputReadyC );
 
assign wMultiplicationOutputReadyA = wMultiplicationA_OutputReady;
assign wMultiplicationOutputReadyB = wMultiplicationB_OutputReady;
assign wMultiplicationOutputReadyC = wMultiplicationC_OutputReady;
assign wMultiplicationOutputReadyD = wMultiplicationD_OutputReady;
 
 assign wMultiplicationOutputReady = 
 ( wMultiplicationOutputReadyA && wMultiplicationOutputReadyB && wMultiplicationOutputReadyC );
 
 wire wSquareRootOutputReady;
 FFT1 FFT_Sqrt
  (
   .D(1'b1),
   .Clock( wSquareRoot_OutputReady ), 
   .Reset( iInputReady ), 
   .Q( wSquareRootOutputReady )
 );
 
 
//------------------------------------------------------------------------
wire wOutputDelay1Cycle,wOutputDelay2Cycle,wOutputDelay3Cycle;


FFD_POSEDGE_ASYNC_RESET # (1) FFOutputReadyDelay2
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( iInputReady ),
	.Q( wOutputDelay1Cycle )
);

FFD_POSEDGE_ASYNC_RESET # (1) FFOutputReadyDelay22
(
	.Clock( Clock  ),
	.Clear( Reset ),
	.D( wOutputDelay1Cycle ),
	.Q( wOutputDelay2Cycle )
);


FFD_POSEDGE_ASYNC_RESET # (1) FFOutputReadyDelay222
(
	.Clock( Clock &&  wOperation == `OMWRITE),
	.Clear( Reset ),
	.D( wOutputDelay2Cycle ),
	.Q( wOutputDelay3Cycle )
);




FFD_POSEDGE_SYNCRONOUS_RESET # ( `INSTRUCTION_OP_LENGTH ) SourceZ2
(
	.Clock( Clock ),
	.Reset( Reset ),
	.Enable( iInputReady ),
	.D( iOperation ),
	.Q(wOperation)
);


//Mux for output ready signal
always @ ( * )
begin
	case ( wOperation )
	`UNSCALE:			OutputReady  = wOutputDelay1Cycle;
	`RETURN: OutputReady = wOutputDelay1Cycle;
	
	`NOP: OutputReady = wOutputDelay1Cycle;
	`FRAC: OutputReady = wOutputDelay1Cycle;
	`NEG: OutputReady = wOutputDelay1Cycle;
	`OMWRITE: OutputReady = wOutputDelay3Cycle;
	`TMREAD:  OutputReady = wTMReadOutputReady;  //One cycle after TMEM data availale asserted
	
	`ifdef DEBUG
	//Debug Print behaves as a NOP in terms of ALU...
	`DEBUG_PRINT: OutputReady = wOutputDelay1Cycle;
	`endif
	
	`ADD,`INC,`INCX,`INCY,`INCZ:		OutputReady = 	wAddSubAOutputReady &&
									wAddSubBOutputReady &&
									wAddSubCOutputReady;
														  
	`SUB,`DEC:	  	OutputReady = 	wAddSubAOutputReady &&
									wAddSubBOutputReady &&
									wAddSubCOutputReady;
															
	`DIV:		OutputReady = 	wDivisionOutputReady; 
	
															
	`MUL,`IMUL:   	OutputReady = 	wMultiplicationOutputReady;
	`MULP:  OutputReady =  wMultiplicationOutputReadyA;
															
	`DOT:		OutputReady = wAddSubBOutputReady;
	
	`CROSS:	OutputReady = 	wAddSubAOutputReady && 
									wAddSubBOutputReady && 
									wAddSubCOutputReady;
	
	`MAG:		OutputReady = wSquareRootOutputReady;
	
	`ZERO:	OutputReady = wOutputDelay1Cycle;
	
	`COPY:	OutputReady = wOutputDelay1Cycle;
	
	`SWIZZLE3D: OutputReady = wOutputDelay1Cycle;
	
	`SETX,`SETY,`SETZ,`JMP,`LEA,`CALL,`RET: 	OutputReady = wOutputDelay1Cycle;
	 

	
	`JGX,`JGY,`JGZ:				OutputReady = ArithmeticComparison_OutputReady;
	`JLX,`JLY,`JLZ:				OutputReady = ArithmeticComparison_OutputReady;
	`JEQX,`JEQY,`JEQZ:			OutputReady = ArithmeticComparison_OutputReady;
	`JNEX,`JNEY,`JNEZ:			OutputReady = ArithmeticComparison_OutputReady;
	`JGEX,`JGEY,`JGEZ:			OutputReady = ArithmeticComparison_OutputReady;
	`JLEX,`JLEY,`JLEZ:			OutputReady = ArithmeticComparison_OutputReady;
	
	`MOD: OutputReady = wAddSubAOutputReady &&				//TODO: wait 1 more cycle
									wAddSubBOutputReady &&
									wAddSubCOutputReady;
									
	`XCHANGEX: OutputReady = wOutputDelay1Cycle;
	
	
	default:	
	begin
		OutputReady =  32'b0;
		//`ifdef DEBUG
		//$display("*** ALU ERROR: iOperation = %d ***",iOperation);
		//`endif
	end
	
	endcase	
end

endmodule
//------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Source file: RTL/Collaterals.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "aDefinitions.v"
/**********************************************************************************
Theia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2010  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/
//------------------------------------------------
module FFD_POSEDGE_ASYNC_RESET # ( parameter SIZE=`WIDTH )
	(
	input wire Clock,
	input wire Clear, 
	input wire [SIZE-1:0] D,
	output reg [SIZE-1:0] Q
	); 
 
  always @(posedge Clock or posedge Clear) 
    begin 
	   if (Clear) 
        Q = 0; 
      else 
        Q = D; 
    end 
endmodule 
//----------------------------------------------------
module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE=`WIDTH )
(
	input wire				Clock,
	input wire				Reset,
	input wire				Enable,
	input wire [SIZE-1:0]	D,
	output reg [SIZE-1:0]	Q
);
	

always @ (posedge Clock) 
begin
	if ( Reset )
		Q <= `WIDTH'b0;
	else
	begin	
		if (Enable) 
			Q <= D; 
	end	
 
end//always

endmodule
//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE=`WIDTH)
(
input wire Clock, Reset,
input wire [SIZE-1:0] Initial,
input wire Enable,
output reg [SIZE-1:0] Q
);


  always @(posedge Clock )
  begin
      if (Reset)
        Q <= Initial;
      else
		begin
		if (Enable)
			Q <= Q + 1;
			
		end			
  end

endmodule

//----------------------------------------------------------------------

module SELECT_1_TO_N # ( parameter SEL_WIDTH=4, parameter OUTPUT_WIDTH=16 )
 (
 input wire [SEL_WIDTH-1:0] Sel,
 input wire  En,
 output wire [OUTPUT_WIDTH-1:0] O
 );

reg[OUTPUT_WIDTH-1:0] shift;

always @ ( * )
begin
	if (~En)
		shift = 1;
	else
		shift = (1 << 	Sel);


end

assign O = ( ~En ) ? 0 : shift ;

//assign O = En & (1 << Sel);

endmodule 

//----------------------------------------------------------------------

module MUXFULLPARALELL_2SEL_GENERIC # ( parameter SIZE=`WIDTH )
 (
 input wire [1:0] Sel,
 input wire [SIZE-1:0]I1, I2, I3,I4,
 output reg [SIZE-1:0] O1
 );

always @( * )

  begin

    case (Sel)

      2'b00: O1 = I1;
      2'b01: O1 = I2;
		2'b10: O1 = I3;
		2'b11: O1 = I4;
		default: O1 = SIZE-1'b0;

    endcase

  end

endmodule 

//--------
module CIRCULAR_SHIFTLEFT_POSEDGE_EX # ( parameter SIZE=`WIDTH )
( input wire Clock, 
  input wire Reset,
  input wire[SIZE-1:0] Initial, 
  input wire      Enable,
  output wire[SIZE-1:0] O
);

reg [SIZE-1:0] tmp;


  always @(posedge Clock)
  begin
  if (Reset)
		tmp <= Initial;
	else
	begin
		if (Enable)
		begin
			if (tmp[SIZE-1])
			begin
				tmp <= Initial;
			end	
			else
			begin
				tmp <= tmp << 1;
			end	
		end	
	end	
  end
  
  
    assign O  = tmp;
endmodule
//------------------------------------------------
module MUXFULLPARALELL_3SEL_WALKINGONE # ( parameter SIZE=`WIDTH )
 (
 input wire [2:0] Sel,
 input wire [SIZE-1:0]I1, I2, I3,
 output reg [SIZE-1:0] O1
 );

always @( * )

  begin

    case (Sel)

      3'b001: O1 = I1;
      3'b010: O1 = I2;
		3'b100: O1 = I3;
		default: O1 = SIZE-1'b0;

    endcase

  end

endmodule 
//------------------------------------------------
module SHIFTLEFT_POSEDGE # ( parameter SIZE=`WIDTH )
( input wire Clock, 
  input wire Reset,
  input wire[SIZE-1:0] Initial, 
  input wire      Enable,
  output wire[SIZE-1:0] O
);

reg [SIZE-1:0] tmp;


  always @(posedge Clock)
  begin
  if (Reset)
		tmp <= Initial;
	else
	begin
		if (Enable)
			tmp <= tmp << 1;
	end	
  end
  
  
    assign O  = tmp;
endmodule
//------------------------------------------------
//------------------------------------------------
module CIRCULAR_SHIFTLEFT_POSEDGE # ( parameter SIZE=`WIDTH )
( input wire Clock, 
  input wire Reset,
  input wire[SIZE-1:0] Initial, 
  input wire      Enable,
  output wire[SIZE-1:0] O
);

reg [SIZE-1:0] tmp;


  always @(posedge Clock)
  begin
  if (Reset || tmp[SIZE-1])
		tmp <= Initial;
	else
	begin
		if (Enable)
			tmp <= tmp << 1;
	end	
  end
  
  
    assign O  = tmp;
endmodule
//-----------------------------------------------------------
/*
	Sorry forgot how this flop is called.
	Any way Truth table is this
	
	Q	S	Q_next R
	0	0	0		 0
	0	1	1		 0
	1	0	1		 0
	1	1	1		 0
	X	X	0		 1
	
	The idea is that it toggles from 0 to 1 when S = 1, but if it 
	gets another S = 1, it keeps the output to 1.
*/
module FFToggleOnce_1Bit
(
	input wire Clock,
	input wire Reset,
	input wire Enable,
	input wire S,
	output reg Q
	
);


reg Q_next;

always @ (negedge Clock)
begin
	Q <= Q_next;
end

always @ ( posedge Clock )
begin
	if (Reset)
		Q_next <= 0;
	else if (Enable)
		Q_next <= (S && !Q) || Q;
	else
		Q_next <= Q;
end
endmodule

//-----------------------------------------------------------
module UpCounter_16E
(
input wire Clock, 
input wire Reset,
input wire [15:0] Initial,
input wire Enable,
output wire [15:0] Q
);
	reg [15:0] Temp;


  always @(posedge Clock or posedge Reset)
  begin
      if (Reset)
         Temp = Initial;
      else
			if (Enable)
				Temp =  Temp + 1'b1;
  end
	assign Q = Temp;

endmodule
//-----------------------------------------------------------
module UpCounter_32
(
input wire Clock, 
input wire Reset,
input wire [31:0] Initial,
input wire Enable,
output wire [31:0] Q
);
	reg [31:0] Temp;


  always @(posedge Clock or posedge Reset)
  begin
      if (Reset)
		begin
         Temp = Initial;
		end	
      else
		begin
			if (Enable)
			begin
				Temp =  Temp + 1'b1;
			end
		end	
  end
	assign Q = Temp;

endmodule
//-----------------------------------------------------------
module UpCounter_3
(
input wire Clock, 
input wire Reset,
input wire [2:0] Initial,
input wire Enable,
output wire [2:0] Q
);
	reg [2:0] Temp;


  always @(posedge Clock or posedge Reset)
  begin
      if (Reset)
         Temp = Initial;
      else
			if (Enable)
				Temp =  Temp + 3'b1;
  end
	assign Q = Temp;

endmodule


module FFD32_POSEDGE
(
	input wire Clock,
	input wire[31:0] D,
	output reg[31:0] Q
);
	
	always @ (posedge Clock)
		Q <= D;
	
endmodule

//------------------------------------------------
module MUXFULLPARALELL_96bits_2SEL
 (
 input wire Sel,
 input wire [95:0]I1, I2,
 output reg [95:0] O1
 );



always @( * )

  begin

    case (Sel)

      1'b0: O1 = I1;
      1'b1: O1 = I2;

    endcase

  end

endmodule 
//------------------------------------------------

module MUXFULLPARALELL_16bits_2SEL_X
 (
 input wire [1:0] Sel,
 input wire [15:0]I1, I2, I3,
 output reg [15:0] O1
 );



always @( * )

  begin

    case (Sel)

      2'b00: O1 = I1;
      2'b01: O1 = I2;
		2'b10: O1 = I3;
		default: O1 = 16'b0;

    endcase

  end

endmodule 
//------------------------------------------------
module MUXFULLPARALELL_16bits_2SEL
 (
 input wire Sel,
 input wire [15:0]I1, I2,
 output reg [15:0] O1
 );



always @( * )

  begin

    case (Sel)

      1'b0: O1 = I1;
      1'b1: O1 = I2;

    endcase

  end

endmodule 

//--------------------------------------------------------------

  module FFT1 
  (
   input wire D,
   input wire Clock, 
   input wire Reset , 
   output reg Q       
 );
 
  always @ ( posedge Clock or posedge Reset )
  begin
  
	if (Reset)
	begin
    Q <= 1'b0;
   end 
	else 
	begin
		if (D) 
			Q <=  ! Q;
	end
	
  end//always
  
 endmodule
//--------------------------------------------------------------

// -----------------------------------------------------------------------------
// Source file: RTL/Module_ArithmeticComparison.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "aDefinitions.v"

//------------------------------------------------------------------
module ArithmeticComparison
(
	input wire					Clock,
	input wire[`WIDTH-1:0] 	X,Y,
	input wire[2:0] 			iOperation,
	input wire					iInputReady,
	output reg 					OutputReady,
	output reg					Result
);


wire [`WIDTH-1:0] wX,wY;
wire SignX,SignY;
reg rGreaterThan;
wire wUGt,wULT,wEQ;

assign SignX = (X == 0) ? 0: X[31];
assign SignY = (Y == 0) ? 0: Y[31];

assign wX = ( SignX ) ? ~X + 1'b1 : X;
assign wY = ( SignY ) ? ~Y + 1'b1 : Y;

assign wUGt = wX > wY;
assign wULT = wX < wY;
assign wEQ = wX == wY;

always @ ( * )
begin
	case ( {SignX,SignY} )
		//Greater than test ( X > Y )
		2'b00: rGreaterThan = wUGt;		//both numbers positive
		2'b01: rGreaterThan = 1;			//X positive, y negative	
		2'b10: rGreaterThan = 0;			//X negative, y positive
		2'b11: rGreaterThan = wULT;		//X negative, y negative
	endcase
end

always @ ( posedge Clock )
begin

if (iInputReady)
begin
	case ( iOperation )
		3'b000: Result = rGreaterThan;			//X > Y
		3'b001: Result = ~rGreaterThan;  		//X < Y
		3'b010: Result = wEQ;						//X == Y
		3'b011: Result = ~wEQ;						//X != Y
		3'b100: Result = rGreaterThan || wEQ; 	// X >= Y
		3'b101: Result = ~rGreaterThan || wEQ; // X <= Y
		default: Result = 0;
	endcase
		OutputReady = 1;
end
else
		OutputReady = 0;
end


endmodule
//---------------------------------------------

// -----------------------------------------------------------------------------
// Source file: RTL/Module_FixedPointAddtionSubstraction.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "aDefinitions.v"


//-----------------------------------------------------------
module INCREMENT # ( parameter SIZE=`WIDTH )
(
input	 wire					Clock,
input  wire					Reset,
input  wire[SIZE-1:0]	A,
output reg [SIZE-1:0]	R
);
always @ (posedge Clock)
begin
	R = A + 1;
end


endmodule
//-----------------------------------------------------------
module FixedAddSub
(
input	 wire					Clock,
input  wire					Reset,
input  wire[`LONG_WIDTH-1:0]	A,
input  wire[`LONG_WIDTH-1:0]	B,
output reg[`LONG_WIDTH-1:0]	R,
input	wire						iOperation,
input	wire					iInputReady,		//Is the input data valid?
output wire					OutputReady		//Our output data is ready!
);

reg MyOutputReady = 0;

wire [`LONG_WIDTH-1:0] wB;

assign wB = ( iOperation ) ? ~B + 1'b1 : B;
   
//Output ready just take 1 cycle
//assign OutputReady = iInputReady;

FFD_POSEDGE_ASYNC_RESET #(1) FFOutputReadyDelay2
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( iInputReady ),
	.Q( OutputReady )
);	
	
	
//-------------------------------	
always @ (posedge Clock)
begin

if (iInputReady == 1)
begin
	  R = ( A + wB );
end	
else 
begin
		R = 64'hFFFFFFFF;

end

end // always

endmodule

// -----------------------------------------------------------------------------
// Source file: RTL/Module_FixedPointDivision.v
// -----------------------------------------------------------------------------
/*
	Fixed point Multiplication Module Qm.n
	C = (A << n) / B
	
*/


//Division State Machine Constants
`define INITIAL_DIVISION_STATE					6'd1
`define DIVISION_REVERSE_LAST_ITERATION		6'd2
`define PRE_CALCULATE_REMAINDER					6'd3
`define CALCULATE_REMAINDER						6'd4
`define WRITE_DIVISION_RESULT						6'd5


`timescale 1ns / 1ps
`include "aDefinitions.v"
`define FPS_AFTER_RESET_STATE 0
//-----------------------------------------------------------------
//This only works if you dividend is power of 2
//x % 2^n == x & (2^n - 1).
/*
module Modulus2N
(
input wire 						Clock,
input wire 						Reset,
input wire [`WIDTH-1:0] 	iDividend,iDivisor,
output reg  [`WIDTH-1:0] 	oQuotient,
input  wire						iInputReady,		//Is the input data valid?
output reg						oOutputReady		//Our output data is ready!
);



FF1_POSEDGE_SYNCRONOUS_RESET FFOutputReadyDelay2
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( iInputReady ),
	.Q( oOutputReady )
);	

assign oQuotient = (iDividend & (iDivisor-1'b1));


endmodule
*/
//-----------------------------------------------------------------
/*
Be aware that the unsgined division algorith doesn't know or care
about the sign bit of the Result (bit 31). So if you divisor is very
small there is a chance that the bit 31 from the usginned division is
one even thogh the result should be positive

*/
module SignedIntegerDivision
(
input	 wire			Clock,Reset,
input  wire [`WIDTH-1:0] iDividend,iDivisor,
output reg  [`WIDTH-1:0] xQuotient,
input  wire	iInputReady,		//Is the input data valid?
output reg	OutputReady		//Our output data is ready!
);


parameter SIGN = 31;
wire Sign;

wire [`WIDTH-1:0] wDividend,wDivisor;
wire wInputReady;
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFD1
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( iDividend ),
	.Q( wDividend)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFD2
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( iDivisor ),
	.Q( wDivisor )
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD3
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( 1'b1 ),
	.D( iInputReady ),
	.Q( wInputReady )
);


//wire [7:0] wExitStatus;
wire [`WIDTH-1:0] wAbsDividend,wAbsDivisor;
wire [`WIDTH-1:0] wQuottientTemp;
wire  [`WIDTH-1:0] wAbsQuotient;

assign Sign = wDividend[SIGN] ^ wDivisor[SIGN];

assign wAbsDividend = ( wDividend[SIGN] == 1 )?
			~wDividend + 1'b1 : wDividend;
		
assign wAbsDivisor = ( wDivisor[SIGN] == 1 )?
		~wDivisor + 1'b1 : wDivisor;		

wire DivReady;


UnsignedIntegerDivision UDIV 
(
		.Clock(Clock),
		.Reset( Reset ),
		.iDividend( wAbsDividend),
		.iDivisor( wAbsDivisor ),
		.xQuotient(wQuottientTemp),
		.iInputReady( wInputReady ),
		.OutputReady( DivReady )
		
	);

//Make sure the output from the 'unsigned' operation is really posity
assign wAbsQuotient = wQuottientTemp & 32'h7FFFFFFF;

//assign Quotient = wAbsQuotient;
	
	//-----------------------------------------------
	always @ ( posedge Clock )
	begin
			
		if ( DivReady )
		begin
			if ( Sign == 1 )
				xQuotient = ~wAbsQuotient + 1'b1;
			else
				xQuotient = wAbsQuotient;
						
		end		
		
		OutputReady = DivReady;
		
		if (Reset == 1)
			OutputReady = 0;
			
		
	end
	//-----------------------------------------------

endmodule
//-----------------------------------------------------------------
/*
	
	Returns the integer part (Quotient) of a division.
	
	Division is the process of repeated subtraction. 
	Like the long division we learned in grade school, 
	a binary division algorithm works from the high 
	order digits to the low order digits and generates 
	a quotient (division result) with each step. 
	The division algorithm is divided into two steps:
   * Shift the upper bits of the dividend (the number 
   we are dividing into) into the remainder.
   * Subtract the divisor from the value in the remainder. 
   The high order bit of the result become a bit of 
   the quotient (division result).
	
*/

//-----------------------------------------------------------------
/*
Try to implemet the division as a FSM,
this basically because the behavioral Division has a for loop,
with a variable loop limit counter which I think is not friendly
to the synthetiser (dumb dumb synthetizer :) )
*/
module UnsignedIntegerDivision(
input	wire				Clock,Reset,
input	wire [`WIDTH-1:0]	iDividend,iDivisor,
//output reg	[`WIDTH-1:0]	Quotient,Remainder,

output reg	[`WIDTH-1:0]	xQuotient,

input  wire	iInputReady,		//Is the input data valid?
output reg	OutputReady	//Our output data is ready!
//output reg  [7:0]			ExitStatus
);

//reg		[`WIDTH-1:0] Dividend, Divisor;

reg [63:0] Dividend,Divisor;

//reg 	[`WIDTH-1:0] t, q, d, i,Bit,  num_bits;	
reg 	[`WIDTH-1:0]  i,num_bits;	
reg [63:0] t, q, d, Bit;
reg	[63:0]	Quotient,Remainder; 

reg	[5:0]	CurrentState, NextState;
//----------------------------------------
//Next states logic and Reset sequence
always @(negedge Clock)
begin
        if( Reset!=1 )
           CurrentState = NextState;
		  else
			  CurrentState = `FPS_AFTER_RESET_STATE;
end
//----------------------------------------

always @ (posedge Clock)
begin
case (CurrentState)
	//----------------------------------------
	`FPS_AFTER_RESET_STATE:
	begin
		OutputReady = 0;
		NextState = ( iInputReady == 1 ) ?
			`INITIAL_DIVISION_STATE : `FPS_AFTER_RESET_STATE;
	end
	//----------------------------------------
	`INITIAL_DIVISION_STATE:
	begin
		Dividend = iDividend;
		Dividend =  Dividend << `SCALE;
		
		Divisor	 = iDivisor;
		Remainder = 0;
  		Quotient = 0;
	
 		if (Divisor == 0) 
 		begin
				Quotient[31:0] = 32'h0FFF_FFFF;
   		//	ExitStatus = `DIVISION_BY_ZERO; 
				NextState = `WRITE_DIVISION_RESULT; 
 		end   
 		else if (Divisor > Dividend) 
 		begin
 	    	Remainder 	= Dividend;
			//ExitStatus 	= `NORMAL_EXIT; 
			NextState = `WRITE_DIVISION_RESULT; 
     	end
 		else if (Divisor == Dividend) 
 		begin
 	    	Quotient = 1;
    	//	ExitStatus 	= `NORMAL_EXIT; 
			NextState = `WRITE_DIVISION_RESULT;
      end
		else
		begin
         NextState = `PRE_CALCULATE_REMAINDER;
		end  
		  //num_bits = 32;
		  num_bits = 64;
	end 
	
	//----------------------------------------
	`PRE_CALCULATE_REMAINDER:
	begin
		
		//Bit = (Dividend & 32'h80000000) >> 31;
		Bit = (Dividend & 64'h8000000000000000 ) >> 63;
    	Remainder = (Remainder << 1) | Bit;
    	d = Dividend;
    	Dividend = Dividend << 1;
    	num_bits = num_bits - 1;
  		
		
//		$display("num_bits %d Remainder %d Divisor %d\n",num_bits,Remainder,Divisor);
  		NextState = (Remainder < Divisor) ? 
  			`PRE_CALCULATE_REMAINDER : `DIVISION_REVERSE_LAST_ITERATION;
	end
	//----------------------------------------
	/* 
  		The loop, above, always goes one iteration too far.
     	To avoid inserting an "if" statement inside the loop
     	the last iteration is simply reversed. 
     */
	`DIVISION_REVERSE_LAST_ITERATION:
	begin
		Dividend = d;
  		Remainder = Remainder >> 1;
  		num_bits = num_bits + 1;
		i = 0;
		
		NextState = `CALCULATE_REMAINDER;
	end
	//----------------------------------------
	`CALCULATE_REMAINDER:
	begin
			//Bit = (Dividend & 32'h80000000) >> 31;
			Bit = (Dividend & 64'h8000000000000000 ) >> 63;
    		Remainder = (Remainder << 1) | Bit;
    		t = Remainder - Divisor;
    		//q = !((t & 32'h80000000) >> 31);
			q = !((t & 64'h8000000000000000 ) >> 63);
    		Dividend = Dividend << 1;
    		Quotient = (Quotient << 1) | q;
    		if ( q != 0 ) 
       			Remainder = t;
       		i = i + 1;	
       		
       		if (i < num_bits)
       			NextState = `CALCULATE_REMAINDER;
       		else
       			NextState = `WRITE_DIVISION_RESULT;	
	end
	//----------------------------------------
	//Will go to the IDLE leaving the Result Registers
	//with the current results until next stuff comes
	//So, stay in this state until our client sets iInputReady
	//to 0 telling us he read the result
	`WRITE_DIVISION_RESULT:
	begin
		xQuotient = Quotient[32:0];	//Simply chop to round
		OutputReady = 1;
//		$display("Quotient = %h - %b \n", Quotient, Quotient);

		NextState = (iInputReady == 0) ?
		 `FPS_AFTER_RESET_STATE : `WRITE_DIVISION_RESULT;
	end
endcase	

end //always
endmodule
//-----------------------------------------------------------------

// -----------------------------------------------------------------------------
// Source file: RTL/Module_FixedPointSquareRoot.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "aDefinitions.v"

//Square Root State Machine Constants
`define SQUARE_ROOT_LOOP					1
`define WRITE_SQUARE_ROOT_RESULT			2


`define SR_AFTER_RESET_STATE 0
//-----------------------------------------------------------------
/*

	Calcualtes the SquareRoot of a Fixed Point Number
	Input:  Q32.32
	Output: Q16.16
	Notice that the result has half the precicion as the operands!!
*/	
module FixedPointSquareRoot
(
	input wire							Clock,
	input wire							Reset,
	input wire[`LONG_WIDTH-1:0] 	Operand,			
	input wire							iInputReady,					
	output	reg 						OutputReady,				
	output  reg [`WIDTH-1:0]		Result
);

reg[63:0]			x;
reg[0:`WIDTH-1] 	group,sum,diff;
reg[0:`WIDTH-1]	 	temp1,temp2;
reg	[5:0]			CurrentState, NextState;

reg myInputReady;
 
//----------------------------------------
always @(posedge Clock)
begin
	myInputReady = iInputReady;
end 
//----------------------------------------
//Next states logic
always @(negedge Clock)
begin
        if( Reset!=1 )
           CurrentState = NextState;
			 else 
				CurrentState = `SR_AFTER_RESET_STATE;
end
//----------------------------------------

always @ (posedge Clock)
begin
	case (CurrentState)
	//----------------------------------------
	`SR_AFTER_RESET_STATE:
	begin
		OutputReady = 0;
		Result		= 0;
		sum			= 0;
		diff			= 0;
		group=32;				//WAS 16
		x = 0;
		if ( myInputReady == 1  )
		begin
		  // x[31:0] = Operand;
		  x = Operand;
			x = x << `SCALE;
			NextState = `SQUARE_ROOT_LOOP;
		end else
			NextState = `SR_AFTER_RESET_STATE;
			
	end
	//----------------------------------------
	`SQUARE_ROOT_LOOP:
	begin
		
		
		
		sum = sum << 1;
		sum = sum +  1;
		temp1 = diff << 2;
		//diff = diff + (x>>(group*2)) &3;
		temp2 = group << 1;				//group * 2 ??
		diff = temp1 + ((x >> temp2) &3); 
		
		if (sum > diff)
		begin
			sum = sum -1;
		end
		else
		begin
			Result = Result + (1<<group);
			diff = diff - sum;
			sum = sum + 1;
		end//if
		
		
		if ( group != 0 )
		begin
			group = group - 1;
			NextState = `SQUARE_ROOT_LOOP;
		end	
		else
		begin	 
			NextState 	= `WRITE_SQUARE_ROOT_RESULT;
			
		end	 
	end
	//----------------------------------------
	`WRITE_SQUARE_ROOT_RESULT:
	begin
		OutputReady = 1;
		NextState = (iInputReady == 0) ?
		 `SR_AFTER_RESET_STATE : `WRITE_SQUARE_ROOT_RESULT;
	end
	//----------------------------------------
endcase	
end //always
endmodule
//-----------------------------------------------------------------

// -----------------------------------------------------------------------------
// Source file: RTL/Module_RadixRMul.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "aDefinitions.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:49:14 01/13/2009 
// Design Name: 
// Module Name:    RadixRMul 
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

`default_nettype none


//---------------------------------------------------
module MUX_4_TO_1_32Bits_FullParallel
(
	input wire [31:0] i1,i2,i3,i4,
	output reg [31:0] O,
	input wire [1:0] Sel
);

always @ ( Sel or i1 or i2 or i3 or i4 )
begin
	case (Sel)
		2'b00: O = i1;
		2'b01: O = i2;
		2'b10: O = i3;
		2'b11: O = i4;
	endcase
	
end

endmodule
//---------------------------------------------------
/*
module SHIFTER2_16_BITS
(
input wire C,
input wire[15:0] In,
output reg[15:0] Out
);

reg [15:0] Temp;
always @ (posedge C )
begin
	Out =  In << 2;
	
end

endmodule
*/
//---------------------------------------------------
module RADIX_R_MUL_32_FULL_PARALLEL
(
	input wire Clock,
	input wire Reset,
	input wire[31:0] A,
	input wire[31:0] B,
	output wire[63:0] R,
	input wire iUnscaled,
	input wire iInputReady,
	output wire OutputReady

	
);


wire wInputDelay1;
//-------------------
wire [31:0] wALatched,wBLatched;
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFD1
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( A ),
	.Q( wALatched)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFD2
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( B ),
	.Q( wBLatched )
);

//-------------------


FFD_POSEDGE_ASYNC_RESET #(1) FFOutputReadyDelay1
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( iInputReady ),
	.Q( wInputDelay1 )
);

FFD_POSEDGE_ASYNC_RESET #(1) FFOutputReadyDelay2
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D(  wInputDelay1 ),
	.Q( OutputReady  )
);

wire [31:0] wA, w2A, w3A, wB;
wire SignA,SignB;

assign SignA = wALatched[31];
assign SignB = wBLatched[31];


assign wB = (SignB == 1) ? ~wBLatched + 1'b1 : wBLatched;
assign wA = (SignA == 1) ? ~wALatched + 1'b1 : wALatched;

assign w2A = wA << 1;
assign w3A = w2A + wA;

wire [31:0] wPartialResult0,wPartialResult1,wPartialResult2,wPartialResult3,wPartialResult4,wPartialResult5;
wire [31:0] wPartialResult6,wPartialResult7,wPartialResult8,wPartialResult9,wPartialResult10,wPartialResult11;
wire [31:0] wPartialResult12,wPartialResult13,wPartialResult14,wPartialResult15;

MUX_4_TO_1_32Bits_FullParallel MUX0
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[1],wB[0]} ),
		.O( wPartialResult0 )	
);


MUX_4_TO_1_32Bits_FullParallel MUX1
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[3],wB[2]} ),
		.O( wPartialResult1 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX2
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[5],wB[4]} ),
		.O( wPartialResult2 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX3
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[7],wB[6]} ),
		.O( wPartialResult3 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX4
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[9],wB[8]} ),
		.O( wPartialResult4 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX5
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[11],wB[10]} ),
		.O( wPartialResult5 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX6
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[13],wB[12]} ),
		.O( wPartialResult6 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX7
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[15],wB[14]} ),
		.O( wPartialResult7 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX8
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[17],wB[16]} ),
		.O( wPartialResult8 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX9
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[19],wB[18]} ),
		.O( wPartialResult9 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX10
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[21],wB[20]} ),
		.O( wPartialResult10 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX11
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[23],wB[22]} ),
		.O( wPartialResult11 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX12
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[25],wB[24]} ),
		.O( wPartialResult12 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX13
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[27],wB[26]} ),
		.O( wPartialResult13 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX14
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[29],wB[28]} ),
		.O( wPartialResult14 )	
);

MUX_4_TO_1_32Bits_FullParallel MUX15
(
		.i1( 32'b 0 ),
		.i2( wA ),
		.i3( w2A ),
		.i4( w3A ),
		.Sel( {wB[31],wB[30]} ),
		.O( wPartialResult15 )	
);



wire[63:0] wPartialResult1_0,wPartialResult1_1,wPartialResult1_2,wPartialResult1_3,
wPartialResult1_4,wPartialResult1_5,wPartialResult1_6,wPartialResult1_7;


assign wPartialResult1_0 = (wPartialResult0) + (wPartialResult1<<2);
assign wPartialResult1_1 = (wPartialResult2 << 4) + (wPartialResult3<<6);
assign wPartialResult1_2 = (wPartialResult4 << 8) + (wPartialResult5<<10);
assign wPartialResult1_3 = (wPartialResult6 << 12)+ (wPartialResult7<<14);
assign wPartialResult1_4 = (wPartialResult8 << 16)+ (wPartialResult9<<18);
assign wPartialResult1_5 = (wPartialResult10 << 20) + (wPartialResult11<< 22);
assign wPartialResult1_6 = (wPartialResult12 << 24) + (wPartialResult13 << 26);
assign wPartialResult1_7 = (wPartialResult14 << 28) + (wPartialResult15 << 30);




wire [63:0] wPartialResult2_0,wPartialResult2_1,wPartialResult2_2,wPartialResult2_3;

assign wPartialResult2_0 = wPartialResult1_0 + wPartialResult1_1;
assign wPartialResult2_1 = wPartialResult1_2 + wPartialResult1_3;
assign wPartialResult2_2 = wPartialResult1_4 + wPartialResult1_5;
assign wPartialResult2_3 = wPartialResult1_6 + wPartialResult1_7;

wire [63:0] wPartialResult3_0,wPartialResult3_1;

assign wPartialResult3_0 = wPartialResult2_0 + wPartialResult2_1;
assign wPartialResult3_1 = wPartialResult2_2 + wPartialResult2_3;

wire [63:0] R_pre1,R_pre2;

//assign R_pre1 = (wPartialResult3_0 + wPartialResult3_1);
assign R_pre1 = (iUnscaled == 1) ? (wPartialResult3_0 + wPartialResult3_1) : ((wPartialResult3_0 + wPartialResult3_1) >> `SCALE);

assign R_pre2 = ( (SignA ^ SignB) == 1) ? ~R_pre1 + 1'b1 : R_pre1;

//assign R = R_pre2 >> `SCALE;
assign R = R_pre2;

endmodule

// -----------------------------------------------------------------------------
// Source file: RTL/Module_Swizzle.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
 `include "aDefinitions.v"
 //---------------------------------------------------------------------------
 module Swizzle3D
(
	input wire [`WIDTH-1:0] Source0_X,
	input wire [`WIDTH-1:0] Source0_Y,
	input wire [`WIDTH-1:0] Source0_Z,
	input wire [`WIDTH-1:0] iOperation,
	
	output reg [`WIDTH-1:0] SwizzleX,
	output reg [`WIDTH-1:0] SwizzleY,
	output reg [`WIDTH-1:0] SwizzleZ
 	
 );
 
 //wire [31:0] SwizzleX,SwizzleY,SwizzleZ;
 //-----------------------------------------------------
 always @ ( * )
 begin
	case (iOperation)
			`SWIZZLE_XXX: 	SwizzleX = Source0_X;
			`SWIZZLE_YYY: 	SwizzleX = Source0_Y;
			`SWIZZLE_ZZZ: 	SwizzleX = Source0_Z;
			`SWIZZLE_YXZ:	SwizzleX = Source0_Y;
			default: 		SwizzleX =  `DATA_ROW_WIDTH'd0;
	endcase
end
//-----------------------------------------------------
 always @ ( * )
 begin	
	case (iOperation)
			`SWIZZLE_XXX: 	SwizzleY = Source0_X;
			`SWIZZLE_YYY: 	SwizzleY = Source0_Y;
			`SWIZZLE_ZZZ: 	SwizzleY = Source0_Z;
			`SWIZZLE_YXZ:  SwizzleY = Source0_X;
			default: 		SwizzleY =  `DATA_ROW_WIDTH'd0;
	endcase
end	
//-----------------------------------------------------
 always @ ( * )
 begin
	case (iOperation)
			`SWIZZLE_XXX: 	SwizzleZ = Source0_X;
			`SWIZZLE_YYY: 	SwizzleZ = Source0_Y;
			`SWIZZLE_ZZZ: 	SwizzleZ = Source0_Z;
			`SWIZZLE_YXZ:  SwizzleZ = Source0_Z;
			default: 		SwizzleZ =  `DATA_ROW_WIDTH'd0;
	endcase
 end
 //-----------------------------------------------------
 endmodule
//---------------------------------------------------------------------------
