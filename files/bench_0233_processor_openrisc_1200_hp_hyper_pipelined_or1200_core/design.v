// Curated RTL benchmark case.
// case_id: bench_0233_processor_openrisc_1200_hp_hyper_pipelined_or1200_core
// source_project: processor_openrisc_1200_hp_hyper_pipelined_or1200_core
// top_module: PSG16


// -----------------------------------------------------------------------------
// Source file: rtl/or1200_defines.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's definitions                                        ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Parameters of the OR1200 core                               ////
////                                                              ////
////  To Do:                                                      ////
////   - add parameters that are missing                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
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
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.44  2005/10/19 11:37:56  jcastillo
// Added support for RAMB16 Xilinx4/Spartan3 primitives
//
// Revision 1.43  2005/01/07 09:23:39  andreje
// l.ff1 and l.cmov instructions added
//
// Revision 1.42  2004/06/08 18:17:36  lampret
// Non-functional changes. Coding style fixes.
//
// Revision 1.41  2004/05/09 20:03:20  lampret
// By default l.cust5 insns are disabled
//
// Revision 1.40  2004/05/09 19:49:04  lampret
// Added some l.cust5 custom instructions as example
//
// Revision 1.39  2004/04/08 11:00:46  simont
// Add support for 512B instruction cache.
//
// Revision 1.38  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.35.4.6  2004/02/11 01:40:11  lampret
// preliminary HW breakpoints support in debug unit (by default disabled). To enable define OR1200_DU_HWBKPTS.
//
// Revision 1.35.4.5  2004/01/15 06:46:38  markom
// interface to debug changed; no more opselect; stb-ack protocol
//
// Revision 1.35.4.4  2004/01/11 22:45:46  andreje
// Separate instruction and data QMEM decoders, QMEM acknowledge and byte-select added
//
// Revision 1.35.4.3  2003/12/17 13:43:38  simons
// Exception prefix configuration changed.
//
// Revision 1.35.4.2  2003/12/05 00:05:03  lampret
// Static exception prefix.
//
// Revision 1.35.4.1  2003/07/08 15:36:37  lampret
// Added embedded memory QMEM.
//
// Revision 1.35  2003/04/24 00:16:07  lampret
// No functional changes. Added defines to disable implementation of multiplier/MAC
//
// Revision 1.34  2003/04/20 22:23:57  lampret
// No functional change. Only added customization for exception vectors.
//
// Revision 1.33  2003/04/07 20:56:07  lampret
// Fixed OR1200_CLKDIV_x_SUPPORTED defines. Better description.
//
// Revision 1.32  2003/04/07 01:26:57  lampret
// RFRAM defines comments updated. Altera LPM option added.
//
// Revision 1.31  2002/12/08 08:57:56  lampret
// Added optional support for WB B3 specification (xwb_cti_o, xwb_bte_o). Made xwb_cab_o optional.
//
// Revision 1.30  2002/10/28 15:09:22  mohor
// Previous check-in was done by mistake.
//
// Revision 1.29  2002/10/28 15:03:50  mohor
// Signal scanb_sen renamed to scanb_en.
//
// Revision 1.28  2002/10/17 20:04:40  lampret
// Added BIST scan. Special VS RAMs need to be used to implement BIST.
//
// Revision 1.27  2002/09/16 03:13:23  lampret
// Removed obsolete comment.
//
// Revision 1.26  2002/09/08 05:52:16  lampret
// Added optional l.div/l.divu insns. By default they are disabled.
//
// Revision 1.25  2002/09/07 19:16:10  lampret
// If SR[CY] implemented with OR1200_IMPL_ADDC enabled, l.add/l.addi also set SR[CY].
//
// Revision 1.24  2002/09/07 05:42:02  lampret
// Added optional SR[CY]. Added define to enable additional (compare) flag modifiers. Defines are OR1200_IMPL_ADDC and OR1200_ADDITIONAL_FLAG_MODIFIERS.
//
// Revision 1.23  2002/09/04 00:50:34  lampret
// Now most of the configuration registers are updatded automatically based on defines in or1200_defines.v.
//
// Revision 1.22  2002/09/03 22:28:21  lampret
// As per Taylor Su suggestion all case blocks are full case by default and optionally (OR1200_CASE_DEFAULT) can be disabled to increase clock frequncy.
//
// Revision 1.21  2002/08/22 02:18:55  lampret
// Store buffer has been tested and it works. BY default it is still disabled until uClinux confirms correct operation on FPGA board.
//
// Revision 1.20  2002/08/18 21:59:45  lampret
// Disable SB until it is tested
//
// Revision 1.19  2002/08/18 19:53:08  lampret
// Added store buffer.
//
// Revision 1.18  2002/08/15 06:04:11  lampret
// Fixed Xilinx trace buffer address. REported by Taylor Su.
//
// Revision 1.17  2002/08/12 05:31:44  lampret
// Added OR1200_WB_RETRY. Moved WB registered outsputs / samples inputs into lower section.
//
// Revision 1.16  2002/07/14 22:17:17  lampret
// Added simple trace buffer [only for Xilinx Virtex target]. Fixed instruction fetch abort when new exception is recognized.
//
// Revision 1.15  2002/06/08 16:20:21  lampret
// Added defines for enabling generic FF based memory macro for register file.
//
// Revision 1.14  2002/03/29 16:24:06  lampret
// Changed comment about synopsys to _synopsys_ because synthesis was complaining about unknown directives
//
// Revision 1.13  2002/03/29 15:16:55  lampret
// Some of the warnings fixed.
//
// Revision 1.12  2002/03/28 19:25:42  lampret
// Added second type of Virtual Silicon two-port SRAM (for register file). Changed defines for VS STP RAMs.
//
// Revision 1.11  2002/03/28 19:13:17  lampret
// Updated defines.
//
// Revision 1.10  2002/03/14 00:30:24  lampret
// Added alternative for critical path in DU.
//
// Revision 1.9  2002/03/11 01:26:26  lampret
// Fixed async loop. Changed multiplier type for ASIC.
//
// Revision 1.8  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
//
// Revision 1.7  2002/02/01 19:56:54  lampret
// Fixed combinational loops.
//
// Revision 1.6  2002/01/19 14:10:22  lampret
// Fixed OR1200_XILINX_RAM32X1D.
//
// Revision 1.5  2002/01/18 07:56:00  lampret
// No more low/high priority interrupts (PICPR removed). Added tick timer exception. Added exception prefix (SR[EPH]). Fixed single-step bug whenreading NPC.
//
// Revision 1.4  2002/01/14 09:44:12  lampret
// Default ASIC configuration does not sample WB inputs.
//
// Revision 1.3  2002/01/08 00:51:08  lampret
// Fixed typo. OR1200_REGISTERED_OUTPUTS was not defined. Should be.
//
// Revision 1.2  2002/01/03 21:23:03  lampret
// Uncommented OR1200_REGISTERED_OUTPUTS for FPGA target.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.20  2001/12/04 05:02:36  lampret
// Added OR1200_GENERIC_MULTP2_32X32 and OR1200_ASIC_MULTP2_32X32
//
// Revision 1.19  2001/11/27 19:46:57  lampret
// Now FPGA and ASIC target are separate.
//
// Revision 1.18  2001/11/23 21:42:31  simons
// Program counter divided to PPC and NPC.
//
// Revision 1.17  2001/11/23 08:38:51  lampret
// Changed DSR/DRR behavior and exception detection.
//
// Revision 1.16  2001/11/20 21:30:38  lampret
// Added OR1200_REGISTERED_INPUTS.
//
// Revision 1.15  2001/11/19 14:29:48  simons
// Cashes disabled.
//
// Revision 1.14  2001/11/13 10:02:21  lampret
// Added 'setpc'. Renamed some signals (except_flushpipe into flushpipe etc)
//
// Revision 1.13  2001/11/12 01:45:40  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
//
// Revision 1.12  2001/11/10 03:43:57  lampret
// Fixed exceptions.
//
// Revision 1.11  2001/11/02 18:57:14  lampret
// Modified virtual silicon instantiations.
//
// Revision 1.10  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.9  2001/10/19 23:28:46  lampret
// Fixed some synthesis warnings. Configured with caches and MMUs.
//
// Revision 1.8  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.3  2001/08/17 08:01:19  lampret
// IC enable/disable.
//
// Revision 1.2  2001/08/13 03:36:20  lampret
// Added cfg regs. Moved all defines into one defines.v file. More cleanup.
//
// Revision 1.1  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/22 03:31:54  lampret
// Fixed RAM's oen bug. Cache bypass under development.
//
// Revision 1.1  2001/07/20 00:46:03  lampret
// Development version of RTL. Libraries are missing.
//
//

//
// Dump VCD
//
//`define OR1200_VCD_DUMP

//
// Generate debug messages during simulation
//
//`define OR1200_VERBOSE

//  `define OR1200_ASIC
////////////////////////////////////////////////////////
//
// Typical configuration for an ASIC
//
`ifdef OR1200_ASIC

//
// Target ASIC memories
//
//`define OR1200_ARTISAN_SSP
//`define OR1200_ARTISAN_SDP
//`define OR1200_ARTISAN_STP
`define OR1200_VIRTUALSILICON_SSP
//`define OR1200_VIRTUALSILICON_STP_T1
//`define OR1200_VIRTUALSILICON_STP_T2

//
// Do not implement Data cache
//
`define OR1200_NO_DC

//
// Do not implement Insn cache
//
`define OR1200_NO_IC

//
// Do not implement Data MMU
//
`define OR1200_NO_DMMU

//
// Do not implement Insn MMU
//
`define OR1200_NO_IMMU

//
// Select between ASIC optimized and generic multiplier
//
//`define OR1200_ASIC_MULTP2_32X32
`define OR1200_GENERIC_MULTP2_32X32

//
// Size/type of insn/data cache if implemented
//
// `define OR1200_IC_1W_512B
// `define OR1200_IC_1W_4KB
`define OR1200_IC_1W_8KB
// `define OR1200_DC_1W_4KB
`define OR1200_DC_1W_8KB

`else


/////////////////////////////////////////////////////////
//
// Typical configuration for an FPGA
//

//
// Target FPGA memories
//
//`define OR1200_ALTERA_LPM
//`define OR1200_XILINX_RAMB16
//`define OR1200_XILINX_RAMB4
//`define OR1200_XILINX_RAM32X1D
//`define OR1200_USE_RAM16X1D_FOR_RAM32X1D
`define OR1200_RAM_MODELS_VIRTEX
//`define BLK_MEM_GEN

//
// Do not implement Data cache
//
//`define OR1200_NO_DC

//
// Do not implement Insn cache
//
//`define OR1200_NO_IC

//
// Do not implement Data MMU
//
//`define OR1200_NO_DMMU

//
// Do not implement Insn MMU
//
//`define OR1200_NO_IMMU

//
// Select between ASIC and generic multiplier
//
// (Generic seems to trigger a bug in the Cadence Ncsim simulator)
//
//`define OR1200_ASIC_MULTP2_32X32
`define OR1200_GENERIC_MULTP2_32X32

//
// Size/type of insn/data cache if implemented
// (consider available FPGA memory resources)
//
//`define OR1200_IC_1W_512B
//`define OR1200_IC_1W_4KB
`define OR1200_IC_1W_8KB
//`define OR1200_DC_1W_4KB
`define OR1200_DC_1W_8KB

`endif


//////////////////////////////////////////////////////////
//
// Do not change below unless you know what you are doing
//

//
// Enable RAM BIST
//
// At the moment this only works for Virtual Silicon
// single port RAMs. For other RAMs it has not effect.
// Special wrapper for VS RAMs needs to be provided
// with scan flops to facilitate bist scan.
//
//`define OR1200_BIST

//
// Register OR1200 WISHBONE outputs
// (must be defined/enabled)
//
`define OR1200_REGISTERED_OUTPUTS

//
// Register OR1200 WISHBONE inputs
//
// (must be undefined/disabled)
//
//`define OR1200_REGISTERED_INPUTS

//
// Disable bursts if they are not supported by the
// memory subsystem (only affect cache line fill)
//
//`define OR1200_NO_BURSTS
//

//
// WISHBONE retry counter range
//
// 2^value range for retry counter. Retry counter
// is activated whenever *wb_rty_i is asserted and
// until retry counter expires, corresponding
// WISHBONE interface is deactivated.
//
// To disable retry counters and *wb_rty_i all together,
// undefine this macro.
//
//`define OR1200_WB_RETRY 7

//
// WISHBONE Consecutive Address Burst
//
// This was used prior to WISHBONE B3 specification
// to identify bursts. It is no longer needed but
// remains enabled for compatibility with old designs.
//
// To remove *wb_cab_o ports undefine this macro.
//
`define OR1200_WB_CAB

//
// WISHBONE B3 compatible interface
//
// This follows the WISHBONE B3 specification.
// It is not enabled by default because most
// designs still don't use WB b3.
//
// To enable *wb_cti_o/*wb_bte_o ports,
// define this macro.
//
//`define OR1200_WB_B3

//
// Enable additional synthesis directives if using
// _Synopsys_ synthesis tool
//
//`define OR1200_ADDITIONAL_SYNOPSYS_DIRECTIVES

//
// Enables default statement in some case blocks
// and disables Synopsys synthesis directive full_case
//
// By default it is enabled. When disabled it
// can increase clock frequency.
//
`define OR1200_CASE_DEFAULT

//
// Operand width / register file address width
//
// (DO NOT CHANGE)
//
`define OR1200_OPERAND_WIDTH		32
`define OR1200_REGFILE_ADDR_WIDTH	5

//
// l.add/l.addi/l.and and optional l.addc/l.addic
// also set (compare) flag when result of their
// operation equals zero
//
// At the time of writing this, default or32
// C/C++ compiler doesn't generate code that
// would benefit from this optimization.
//
// By default this optimization is disabled to
// save area.
//
//`define OR1200_ADDITIONAL_FLAG_MODIFIERS

//
// Implement l.addc/l.addic instructions
//
// By default implementation of l.addc/l.addic
// instructions is enabled in case you need them.
// If you don't use them, then disable implementation
// to save area.
//
`define OR1200_IMPL_ADDC

//
// Implement carry bit SR[CY]
//
// By default implementation of SR[CY] is enabled
// to be compliant with the simulator. However
// SR[CY] is explicitly only used by l.addc/l.addic
// instructions and if these two insns are not
// implemented there is not much point having SR[CY].
//
`define OR1200_IMPL_CY

//
// Implement optional l.div/l.divu instructions
//
// By default divide instructions are not implemented
// to save area and increase clock frequency. or32 C/C++
// compiler can use soft library for division.
//
// To implement divide, multiplier needs to be implemented.
//
//`define OR1200_IMPL_DIV

//
// Implement rotate in the ALU
//
// At the time of writing this, or32
// C/C++ compiler doesn't generate rotate
// instructions. However or32 assembler
// can assemble code that uses rotate insn.
// This means that rotate instructions
// must be used manually inserted.
//
// By default implementation of rotate
// is disabled to save area and increase
// clock frequency.
//
//`define OR1200_IMPL_ALU_ROTATE

//
// Type of ALU compare to implement
//
// Try either one to find what yields
// higher clock frequencyin your case.
//
//`define OR1200_IMPL_ALU_COMP1
`define OR1200_IMPL_ALU_COMP2

//
// Implement multiplier
//
// By default multiplier is implemented
//
`define OR1200_MULT_IMPLEMENTED

//
// Implement multiply-and-accumulate
//
// By default MAC is implemented. To
// implement MAC, multiplier needs to be
// implemented.
//
`define OR1200_MAC_IMPLEMENTED

//
// Low power, slower multiplier
//
// Select between low-power (larger) multiplier
// and faster multiplier. The actual difference
// is only AND logic that prevents distribution
// of operands into the multiplier when instruction
// in execution is not multiply instruction
//
//`define OR1200_LOWPWR_MULT

//
// Clock ratio RISC clock versus WB clock
//
// If you plan to run WB:RISC clock fixed to 1:1, disable
// both defines
//
// For WB:RISC 1:2 or 1:1, enable OR1200_CLKDIV_2_SUPPORTED
// and use clmode to set ratio
//
// For WB:RISC 1:4, 1:2 or 1:1, enable both defines and use
// clmode to set ratio
//
`define OR1200_CLKDIV_2_SUPPORTED
//`define OR1200_CLKDIV_4_SUPPORTED

//
// Type of register file RAM
//
// Memory macro w/ two ports (see or1200_tpram_32x32.v)
//`define OR1200_RFRAM_TWOPORT
//
// Memory macro dual port (see or1200_dpram_32x32.v)
//`define OR1200_RFRAM_DUALPORT
//
// Generic (flip-flop based) register file (see or1200_rfram_generic.v)
//`define OR1200_RFRAM_GENERIC

//
// Type of mem2reg aligner to implement.
//
// Once OR1200_IMPL_MEM2REG2 yielded faster
// circuit, however with today tools it will
// most probably give you slower circuit.
//
`define OR1200_IMPL_MEM2REG1
//`define OR1200_IMPL_MEM2REG2

//
// ALUOPs
//
`define OR1200_ALUOP_WIDTH	4
`define OR1200_ALUOP_NOP	4'd4
/* Order defined by arith insns that have two source operands both in regs
   (see binutils/include/opcode/or32.h) */
`define OR1200_ALUOP_ADD	4'd0
`define OR1200_ALUOP_ADDC	4'd1
`define OR1200_ALUOP_SUB	4'd2
`define OR1200_ALUOP_AND	4'd3
`define OR1200_ALUOP_OR		4'd4
`define OR1200_ALUOP_XOR	4'd5
`define OR1200_ALUOP_MUL	4'd6
`define OR1200_ALUOP_CUST5	4'd7
`define OR1200_ALUOP_SHROT	4'd8
`define OR1200_ALUOP_DIV	4'd9
`define OR1200_ALUOP_DIVU	4'd10
/* Order not specifically defined. */
`define OR1200_ALUOP_IMM	4'd11
`define OR1200_ALUOP_MOVHI	4'd12
`define OR1200_ALUOP_COMP	4'd13
`define OR1200_ALUOP_MTSR	4'd14
`define OR1200_ALUOP_MFSR	4'd15
`define OR1200_ALUOP_CMOV 4'd14
`define OR1200_ALUOP_FF1  4'd15
//
// MACOPs
//
`define OR1200_MACOP_WIDTH	2
`define OR1200_MACOP_NOP	2'b00
`define OR1200_MACOP_MAC	2'b01
`define OR1200_MACOP_MSB	2'b10

//
// Shift/rotate ops
//
`define OR1200_SHROTOP_WIDTH	2
`define OR1200_SHROTOP_NOP	2'd0
`define OR1200_SHROTOP_SLL	2'd0
`define OR1200_SHROTOP_SRL	2'd1
`define OR1200_SHROTOP_SRA	2'd2
`define OR1200_SHROTOP_ROR	2'd3

// Execution cycles per instruction
`define OR1200_MULTICYCLE_WIDTH	2
`define OR1200_ONE_CYCLE		2'd0
`define OR1200_TWO_CYCLES		2'd1

// Operand MUX selects
`define OR1200_SEL_WIDTH		2
`define OR1200_SEL_RF			2'd0
`define OR1200_SEL_IMM			2'd1
`define OR1200_SEL_EX_FORW		2'd2
`define OR1200_SEL_WB_FORW		2'd3

//
// BRANCHOPs
//
`define OR1200_BRANCHOP_WIDTH		3
`define OR1200_BRANCHOP_NOP		3'd0
`define OR1200_BRANCHOP_J		3'd1
`define OR1200_BRANCHOP_JR		3'd2
`define OR1200_BRANCHOP_BAL		3'd3
`define OR1200_BRANCHOP_BF		3'd4
`define OR1200_BRANCHOP_BNF		3'd5
`define OR1200_BRANCHOP_RFE		3'd6

//
// LSUOPs
//
// Bit 0: sign extend
// Bits 1-2: 00 doubleword, 01 byte, 10 halfword, 11 singleword
// Bit 3: 0 load, 1 store
`define OR1200_LSUOP_WIDTH		4
`define OR1200_LSUOP_NOP		4'b0000
`define OR1200_LSUOP_LBZ		4'b0010
`define OR1200_LSUOP_LBS		4'b0011
`define OR1200_LSUOP_LHZ		4'b0100
`define OR1200_LSUOP_LHS		4'b0101
`define OR1200_LSUOP_LWZ		4'b0110
`define OR1200_LSUOP_LWS		4'b0111
`define OR1200_LSUOP_LD		4'b0001
`define OR1200_LSUOP_SD		4'b1000
`define OR1200_LSUOP_SB		4'b1010
`define OR1200_LSUOP_SH		4'b1100
`define OR1200_LSUOP_SW		4'b1110

// FETCHOPs
`define OR1200_FETCHOP_WIDTH		1
`define OR1200_FETCHOP_NOP		1'b0
`define OR1200_FETCHOP_LW		1'b1

//
// Register File Write-Back OPs
//
// Bit 0: register file write enable
// Bits 2-1: write-back mux selects
`define OR1200_RFWBOP_WIDTH		3
`define OR1200_RFWBOP_NOP		3'b000
`define OR1200_RFWBOP_ALU		3'b001
`define OR1200_RFWBOP_LSU		3'b011
`define OR1200_RFWBOP_SPRS		3'b101
`define OR1200_RFWBOP_LR		3'b111

// Compare instructions
`define OR1200_COP_SFEQ       3'b000
`define OR1200_COP_SFNE       3'b001
`define OR1200_COP_SFGT       3'b010
`define OR1200_COP_SFGE       3'b011
`define OR1200_COP_SFLT       3'b100
`define OR1200_COP_SFLE       3'b101
`define OR1200_COP_X          3'b111
`define OR1200_SIGNED_COMPARE 'd3
`define OR1200_COMPOP_WIDTH	4

//
// TAGs for instruction bus
//
`define OR1200_ITAG_IDLE	4'h0	// idle bus
`define	OR1200_ITAG_NI		4'h1	// normal insn
`define OR1200_ITAG_BE		4'hb	// Bus error exception
`define OR1200_ITAG_PE		4'hc	// Page fault exception
`define OR1200_ITAG_TE		4'hd	// TLB miss exception

//
// TAGs for data bus
//
`define OR1200_DTAG_IDLE	4'h0	// idle bus
`define	OR1200_DTAG_ND		4'h1	// normal data
`define OR1200_DTAG_AE		4'ha	// Alignment exception
`define OR1200_DTAG_BE		4'hb	// Bus error exception
`define OR1200_DTAG_PE		4'hc	// Page fault exception
`define OR1200_DTAG_TE		4'hd	// TLB miss exception


//////////////////////////////////////////////
//
// ORBIS32 ISA specifics
//

// SHROT_OP position in machine word
`define OR1200_SHROTOP_POS		7:6

// ALU instructions multicycle field in machine word
`define OR1200_ALUMCYC_POS		9:8

//
// Instruction opcode groups (basic)
//
`define OR1200_OR32_J                 6'b000000
`define OR1200_OR32_JAL               6'b000001
`define OR1200_OR32_BNF               6'b000011
`define OR1200_OR32_BF                6'b000100
`define OR1200_OR32_NOP               6'b000101
`define OR1200_OR32_MOVHI             6'b000110
`define OR1200_OR32_XSYNC             6'b001000
`define OR1200_OR32_RFE               6'b001001
/* */
`define OR1200_OR32_JR                6'b010001
`define OR1200_OR32_JALR              6'b010010
`define OR1200_OR32_MACI              6'b010011
/* */
`define OR1200_OR32_LWZ               6'b100001
`define OR1200_OR32_LBZ               6'b100011
`define OR1200_OR32_LBS               6'b100100
`define OR1200_OR32_LHZ               6'b100101
`define OR1200_OR32_LHS               6'b100110
`define OR1200_OR32_ADDI              6'b100111
`define OR1200_OR32_ADDIC             6'b101000
`define OR1200_OR32_ANDI              6'b101001
`define OR1200_OR32_ORI               6'b101010
`define OR1200_OR32_XORI              6'b101011
`define OR1200_OR32_MULI              6'b101100
`define OR1200_OR32_MFSPR             6'b101101
`define OR1200_OR32_SH_ROTI 	      6'b101110
`define OR1200_OR32_SFXXI             6'b101111
/* */
`define OR1200_OR32_MTSPR             6'b110000
`define OR1200_OR32_MACMSB            6'b110001
/* */
`define OR1200_OR32_SW                6'b110101
`define OR1200_OR32_SB                6'b110110
`define OR1200_OR32_SH                6'b110111
`define OR1200_OR32_ALU               6'b111000
`define OR1200_OR32_SFXX              6'b111001
//`define OR1200_OR32_CUST5             6'b111100


/////////////////////////////////////////////////////
//
// Exceptions
//

//
// Exception vectors per OR1K architecture:
// 0xPPPPP100 - reset
// 0xPPPPP200 - bus error
// ... etc
// where P represents exception prefix.
//
// Exception vectors can be customized as per
// the following formula:
// 0xPPPPPNVV - exception N
//
// P represents exception prefix
// N represents exception N
// VV represents length of the individual vector space,
//   usually it is 8 bits wide and starts with all bits zero
//

//
// PPPPP and VV parts
//
// Sum of these two defines needs to be 28
//
`define OR1200_EXCEPT_EPH0_P 20'h00000
`define OR1200_EXCEPT_EPH1_P 20'hF0000
`define OR1200_EXCEPT_V		   8'h00

//
// N part width
//
`define OR1200_EXCEPT_WIDTH 4

//
// Definition of exception vectors
//
// To avoid implementation of a certain exception,
// simply comment out corresponding line
//
`define OR1200_EXCEPT_UNUSED		`OR1200_EXCEPT_WIDTH'hf
`define OR1200_EXCEPT_TRAP		`OR1200_EXCEPT_WIDTH'he
`define OR1200_EXCEPT_BREAK		`OR1200_EXCEPT_WIDTH'hd
`define OR1200_EXCEPT_SYSCALL		`OR1200_EXCEPT_WIDTH'hc
`define OR1200_EXCEPT_RANGE		`OR1200_EXCEPT_WIDTH'hb
`define OR1200_EXCEPT_ITLBMISS		`OR1200_EXCEPT_WIDTH'ha
`define OR1200_EXCEPT_DTLBMISS		`OR1200_EXCEPT_WIDTH'h9
`define OR1200_EXCEPT_INT		`OR1200_EXCEPT_WIDTH'h8
`define OR1200_EXCEPT_ILLEGAL		`OR1200_EXCEPT_WIDTH'h7
`define OR1200_EXCEPT_ALIGN		`OR1200_EXCEPT_WIDTH'h6
`define OR1200_EXCEPT_TICK		`OR1200_EXCEPT_WIDTH'h5
`define OR1200_EXCEPT_IPF		`OR1200_EXCEPT_WIDTH'h4
`define OR1200_EXCEPT_DPF		`OR1200_EXCEPT_WIDTH'h3
`define OR1200_EXCEPT_BUSERR		`OR1200_EXCEPT_WIDTH'h2
`define OR1200_EXCEPT_RESET		`OR1200_EXCEPT_WIDTH'h1
`define OR1200_EXCEPT_NONE		`OR1200_EXCEPT_WIDTH'h0


/////////////////////////////////////////////////////
//
// SPR groups
//

// Bits that define the group
`define OR1200_SPR_GROUP_BITS	15:11

// Width of the group bits
`define OR1200_SPR_GROUP_WIDTH 	5

// Bits that define offset inside the group
`define OR1200_SPR_OFS_BITS 10:0

// List of groups
`define OR1200_SPR_GROUP_SYS	5'd00
`define OR1200_SPR_GROUP_DMMU	5'd01
`define OR1200_SPR_GROUP_IMMU	5'd02
`define OR1200_SPR_GROUP_DC	5'd03
`define OR1200_SPR_GROUP_IC	5'd04
`define OR1200_SPR_GROUP_MAC	5'd05
`define OR1200_SPR_GROUP_DU	5'd06
`define OR1200_SPR_GROUP_PM	5'd08
`define OR1200_SPR_GROUP_PIC	5'd09
`define OR1200_SPR_GROUP_TT	5'd10


/////////////////////////////////////////////////////
//
// System group
//

//
// System registers
//
`define OR1200_SPR_CFGR		7'd0
`define OR1200_SPR_RF		6'd32	// 1024 >> 5
`define OR1200_SPR_NPC		11'd16
`define OR1200_SPR_SR		11'd17
`define OR1200_SPR_PPC		11'd18
`define OR1200_SPR_EPCR		11'd32
`define OR1200_SPR_EEAR		11'd48
`define OR1200_SPR_ESR		11'd64

//
// SR bits
//
`define OR1200_SR_WIDTH 16
`define OR1200_SR_SM   0
`define OR1200_SR_TEE  1
`define OR1200_SR_IEE  2
`define OR1200_SR_DCE  3
`define OR1200_SR_ICE  4
`define OR1200_SR_DME  5
`define OR1200_SR_IME  6
`define OR1200_SR_LEE  7
`define OR1200_SR_CE   8
`define OR1200_SR_F    9
`define OR1200_SR_CY   10	// Unused
`define OR1200_SR_OV   11	// Unused
`define OR1200_SR_OVE  12	// Unused
`define OR1200_SR_DSX  13	// Unused
`define OR1200_SR_EPH  14
`define OR1200_SR_FO   15
`define OR1200_SR_CID  31:28	// Unimplemented

//
// Bits that define offset inside the group
//
`define OR1200_SPROFS_BITS 10:0

//
// Default Exception Prefix
//
// 1'b0 - OR1200_EXCEPT_EPH0_P (0x0000_0000)
// 1'b1 - OR1200_EXCEPT_EPH1_P (0xF000_0000)
//
`define OR1200_SR_EPH_DEF	1'b0

/////////////////////////////////////////////////////
//
// Power Management (PM)
//

// Define it if you want PM implemented
`define OR1200_PM_IMPLEMENTED

// Bit positions inside PMR (don't change)
`define OR1200_PM_PMR_SDF 3:0
`define OR1200_PM_PMR_DME 4
`define OR1200_PM_PMR_SME 5
`define OR1200_PM_PMR_DCGE 6
`define OR1200_PM_PMR_UNUSED 31:7

// PMR offset inside PM group of registers
`define OR1200_PM_OFS_PMR 11'b0

// PM group
`define OR1200_SPRGRP_PM 5'd8

// Define if PMR can be read/written at any address inside PM group
`define OR1200_PM_PARTIAL_DECODING

// Define if reading PMR is allowed
`define OR1200_PM_READREGS

// Define if unused PMR bits should be zero
`define OR1200_PM_UNUSED_ZERO


/////////////////////////////////////////////////////
//
// Debug Unit (DU)
//

// Define it if you want DU implemented
`define OR1200_DU_IMPLEMENTED

//
// Define if you want HW Breakpoints
// (if HW breakpoints are not implemented
// only default software trapping is
// possible with l.trap insn - this is
// however already enough for use
// with or32 gdb)
//
//`define OR1200_DU_HWBKPTS

// Number of DVR/DCR pairs if HW breakpoints enabled
`define OR1200_DU_DVRDCR_PAIRS 8

// Define if you want trace buffer
//`define OR1200_DU_TB_IMPLEMENTED

//
// Address offsets of DU registers inside DU group
//
// To not implement a register, doq not define its address
//
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DU_DVR0		11'd0
`define OR1200_DU_DVR1		11'd1
`define OR1200_DU_DVR2		11'd2
`define OR1200_DU_DVR3		11'd3
`define OR1200_DU_DVR4		11'd4
`define OR1200_DU_DVR5		11'd5
`define OR1200_DU_DVR6		11'd6
`define OR1200_DU_DVR7		11'd7
`define OR1200_DU_DCR0		11'd8
`define OR1200_DU_DCR1		11'd9
`define OR1200_DU_DCR2		11'd10
`define OR1200_DU_DCR3		11'd11
`define OR1200_DU_DCR4		11'd12
`define OR1200_DU_DCR5		11'd13
`define OR1200_DU_DCR6		11'd14
`define OR1200_DU_DCR7		11'd15
`endif
`define OR1200_DU_DMR1		11'd16
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DU_DMR2		11'd17
`define OR1200_DU_DWCR0		11'd18
`define OR1200_DU_DWCR1		11'd19
`endif
`define OR1200_DU_DSR		11'd20
`define OR1200_DU_DRR		11'd21
`ifdef OR1200_DU_TB_IMPLEMENTED
`define OR1200_DU_TBADR		11'h0ff
`define OR1200_DU_TBIA		11'h1xx
`define OR1200_DU_TBIM		11'h2xx
`define OR1200_DU_TBAR		11'h3xx
`define OR1200_DU_TBTS		11'h4xx
`endif

// Position of offset bits inside SPR address
`define OR1200_DUOFS_BITS	10:0

// DCR bits
`define OR1200_DU_DCR_DP	0
`define OR1200_DU_DCR_CC	3:1
`define OR1200_DU_DCR_SC	4
`define OR1200_DU_DCR_CT	7:5

// DMR1 bits
`define OR1200_DU_DMR1_CW0	1:0
`define OR1200_DU_DMR1_CW1	3:2
`define OR1200_DU_DMR1_CW2	5:4
`define OR1200_DU_DMR1_CW3	7:6
`define OR1200_DU_DMR1_CW4	9:8
`define OR1200_DU_DMR1_CW5	11:10
`define OR1200_DU_DMR1_CW6	13:12
`define OR1200_DU_DMR1_CW7	15:14
`define OR1200_DU_DMR1_CW8	17:16
`define OR1200_DU_DMR1_CW9	19:18
`define OR1200_DU_DMR1_CW10	21:20
`define OR1200_DU_DMR1_ST	22
`define OR1200_DU_DMR1_BT	23
`define OR1200_DU_DMR1_DXFW	24
`define OR1200_DU_DMR1_ETE	25

// DMR2 bits
`define OR1200_DU_DMR2_WCE0	0
`define OR1200_DU_DMR2_WCE1	1
`define OR1200_DU_DMR2_AWTC	12:2
`define OR1200_DU_DMR2_WGB	23:13

// DWCR bits
`define OR1200_DU_DWCR_COUNT	15:0
`define OR1200_DU_DWCR_MATCH	31:16

// DSR bits
`define OR1200_DU_DSR_WIDTH	14
`define OR1200_DU_DSR_RSTE	0
`define OR1200_DU_DSR_BUSEE	1
`define OR1200_DU_DSR_DPFE	2
`define OR1200_DU_DSR_IPFE	3
`define OR1200_DU_DSR_TTE	4
`define OR1200_DU_DSR_AE	5
`define OR1200_DU_DSR_IIE	6
`define OR1200_DU_DSR_IE	7
`define OR1200_DU_DSR_DME	8
`define OR1200_DU_DSR_IME	9
`define OR1200_DU_DSR_RE	10
`define OR1200_DU_DSR_SCE	11
`define OR1200_DU_DSR_BE	12
`define OR1200_DU_DSR_TE	13

// DRR bits
`define OR1200_DU_DRR_RSTE	0
`define OR1200_DU_DRR_BUSEE	1
`define OR1200_DU_DRR_DPFE	2
`define OR1200_DU_DRR_IPFE	3
`define OR1200_DU_DRR_TTE	4
`define OR1200_DU_DRR_AE	5
`define OR1200_DU_DRR_IIE	6
`define OR1200_DU_DRR_IE	7
`define OR1200_DU_DRR_DME	8
`define OR1200_DU_DRR_IME	9
`define OR1200_DU_DRR_RE	10
`define OR1200_DU_DRR_SCE	11
`define OR1200_DU_DRR_BE	12
`define OR1200_DU_DRR_TE	13

// Define if reading DU regs is allowed
`define OR1200_DU_READREGS

// Define if unused DU registers bits should be zero
`define OR1200_DU_UNUSED_ZERO

// Define if IF/LSU status is not needed by devel i/f
`define OR1200_DU_STATUS_UNIMPLEMENTED

/////////////////////////////////////////////////////
//
// Programmable Interrupt Controller (PIC)
//

// Define it if you want PIC implemented
`define OR1200_PIC_IMPLEMENTED

// Define number of interrupt inputs (2-31)
`define OR1200_PIC_INTS 20

// Address offsets of PIC registers inside PIC group
`define OR1200_PIC_OFS_PICMR 2'd0
`define OR1200_PIC_OFS_PICSR 2'd2

// Position of offset bits inside SPR address
`define OR1200_PICOFS_BITS 1:0

// Define if you want these PIC registers to be implemented
`define OR1200_PIC_PICMR
`define OR1200_PIC_PICSR

// Define if reading PIC registers is allowed
`define OR1200_PIC_READREGS

// Define if unused PIC register bits should be zero
`define OR1200_PIC_UNUSED_ZERO


/////////////////////////////////////////////////////
//
// Tick Timer (TT)
//

// Define it if you want TT implemented
`define OR1200_TT_IMPLEMENTED

// Address offsets of TT registers inside TT group
`define OR1200_TT_OFS_TTMR 1'd0
`define OR1200_TT_OFS_TTCR 1'd1

// Position of offset bits inside SPR group
`define OR1200_TTOFS_BITS 0

// Define if you want these TT registers to be implemented
`define OR1200_TT_TTMR
`define OR1200_TT_TTCR

// TTMR bits
`define OR1200_TT_TTMR_TP 27:0
`define OR1200_TT_TTMR_IP 28
`define OR1200_TT_TTMR_IE 29
`define OR1200_TT_TTMR_M 31:30

// Define if reading TT registers is allowed
`define OR1200_TT_READREGS


//////////////////////////////////////////////
//
// MAC
//
`define OR1200_MAC_ADDR		0	// MACLO 0xxxxxxxx1, MACHI 0xxxxxxxx0
`define OR1200_MAC_SPR_WE		// Define if MACLO/MACHI are SPR writable

//
// Shift {MACHI,MACLO} into destination register when executing l.macrc
//
// According to architecture manual there is no shift, so default value is 0.
//
// However the implementation has deviated in this from the arch manual and had hard coded shift by 28 bits which
// is a useful optimization for MP3 decoding (if using libmad fixed point library). Shifts are no longer
// default setup, but if you need to remain backward compatible, define your shift bits, which were normally
// dest_GPR = {MACHI,MACLO}[59:28]
`define OR1200_MAC_SHIFTBY	0	// 0 = According to arch manual, 28 = obsolete backward compatibility


//////////////////////////////////////////////
//
// Data MMU (DMMU)
//

//
// Address that selects between TLB TR and MR
//
`define OR1200_DTLB_TM_ADDR	7

//
// DTLBMR fields
//
`define	OR1200_DTLBMR_V_BITS	0
`define	OR1200_DTLBMR_CID_BITS	4:1
`define	OR1200_DTLBMR_RES_BITS	11:5
`define OR1200_DTLBMR_VPN_BITS	31:13

//
// DTLBTR fields
//
`define	OR1200_DTLBTR_CC_BITS	0
`define	OR1200_DTLBTR_CI_BITS	1
`define	OR1200_DTLBTR_WBC_BITS	2
`define	OR1200_DTLBTR_WOM_BITS	3
`define	OR1200_DTLBTR_A_BITS	4
`define	OR1200_DTLBTR_D_BITS	5
`define	OR1200_DTLBTR_URE_BITS	6
`define	OR1200_DTLBTR_UWE_BITS	7
`define	OR1200_DTLBTR_SRE_BITS	8
`define	OR1200_DTLBTR_SWE_BITS	9
`define	OR1200_DTLBTR_RES_BITS	11:10
`define OR1200_DTLBTR_PPN_BITS	31:13

//
// DTLB configuration
//
`define	OR1200_DMMU_PS		13					// 13 for 8KB page size
`define	OR1200_DTLB_INDXW	6					// 6 for 64 entry DTLB	7 for 128 entries
`define OR1200_DTLB_INDXL	`OR1200_DMMU_PS				// 13			13
`define OR1200_DTLB_INDXH	`OR1200_DMMU_PS+`OR1200_DTLB_INDXW-1	// 18			19
`define	OR1200_DTLB_INDX	`OR1200_DTLB_INDXH:`OR1200_DTLB_INDXL	// 18:13		19:13
`define OR1200_DTLB_TAGW	32-`OR1200_DTLB_INDXW-`OR1200_DMMU_PS	// 13			12
`define OR1200_DTLB_TAGL	`OR1200_DTLB_INDXH+1			// 19			20
`define	OR1200_DTLB_TAG		31:`OR1200_DTLB_TAGL			// 31:19		31:20
`define	OR1200_DTLBMRW		`OR1200_DTLB_TAGW+1			// +1 because of V bit
`define	OR1200_DTLBTRW		32-`OR1200_DMMU_PS+5			// +5 because of protection bits and CI

//
// Cache inhibit while DMMU is not enabled/implemented
//
// cache inhibited 0GB-4GB		1'b1
// cache inhibited 0GB-2GB		!dcpu_adr_i[31]
// cache inhibited 0GB-1GB 2GB-3GB	!dcpu_adr_i[30]
// cache inhibited 1GB-2GB 3GB-4GB	dcpu_adr_i[30]
// cache inhibited 2GB-4GB (default)	dcpu_adr_i[31]
// cached 0GB-4GB			1'b0
//
`define OR1200_DMMU_CI			dcpu_adr_i[31]


//////////////////////////////////////////////
//
// Insn MMU (IMMU)
//

//
// Address that selects between TLB TR and MR
//
`define OR1200_ITLB_TM_ADDR	7

//
// ITLBMR fields
//
`define	OR1200_ITLBMR_V_BITS	0
`define	OR1200_ITLBMR_CID_BITS	4:1
`define	OR1200_ITLBMR_RES_BITS	11:5
`define OR1200_ITLBMR_VPN_BITS	31:13

//
// ITLBTR fields
//
`define	OR1200_ITLBTR_CC_BITS	0
`define	OR1200_ITLBTR_CI_BITS	1
`define	OR1200_ITLBTR_WBC_BITS	2
`define	OR1200_ITLBTR_WOM_BITS	3
`define	OR1200_ITLBTR_A_BITS	4
`define	OR1200_ITLBTR_D_BITS	5
`define	OR1200_ITLBTR_SXE_BITS	6
`define	OR1200_ITLBTR_UXE_BITS	7
`define	OR1200_ITLBTR_RES_BITS	11:8
`define OR1200_ITLBTR_PPN_BITS	31:13

//
// ITLB configuration
//
`define	OR1200_IMMU_PS		13					// 13 for 8KB page size
`define	OR1200_ITLB_INDXW	6					// 6 for 64 entry ITLB	7 for 128 entries
`define OR1200_ITLB_INDXL	`OR1200_IMMU_PS				// 13			13
`define OR1200_ITLB_INDXH	`OR1200_IMMU_PS+`OR1200_ITLB_INDXW-1	// 18			19
`define	OR1200_ITLB_INDX	`OR1200_ITLB_INDXH:`OR1200_ITLB_INDXL	// 18:13		19:13
`define OR1200_ITLB_TAGW	32-`OR1200_ITLB_INDXW-`OR1200_IMMU_PS	// 13			12
`define OR1200_ITLB_TAGL	`OR1200_ITLB_INDXH+1			// 19			20
`define	OR1200_ITLB_TAG		31:`OR1200_ITLB_TAGL			// 31:19		31:20
`define	OR1200_ITLBMRW		`OR1200_ITLB_TAGW+1			// +1 because of V bit
`define	OR1200_ITLBTRW		32-`OR1200_IMMU_PS+3			// +3 because of protection bits and CI

//
// Cache inhibit while IMMU is not enabled/implemented
// Note: all combinations that use icpu_adr_i cause async loop
//
// cache inhibited 0GB-4GB		1'b1
// cache inhibited 0GB-2GB		!icpu_adr_i[31]
// cache inhibited 0GB-1GB 2GB-3GB	!icpu_adr_i[30]
// cache inhibited 1GB-2GB 3GB-4GB	icpu_adr_i[30]
// cache inhibited 2GB-4GB (default)	icpu_adr_i[31]
// cached 0GB-4GB			1'b0
//
`define OR1200_IMMU_CI			1'b0


/////////////////////////////////////////////////
//
// Insn cache (IC)
//

// 3 for 8 bytes, 4 for 16 bytes etc
`define OR1200_ICLS		4

//
// IC configurations
//
`ifdef OR1200_IC_1W_512B
`define OR1200_ICSIZE   9     // 512
`define OR1200_ICINDX   `OR1200_ICSIZE-2 // 7
`define OR1200_ICINDXH  `OR1200_ICSIZE-1 // 8
`define OR1200_ICTAGL   `OR1200_ICINDXH+1 // 9
`define OR1200_ICTAG    `OR1200_ICSIZE-`OR1200_ICLS // 5
`define OR1200_ICTAG_W  24
`endif
`ifdef OR1200_IC_1W_4KB
`define OR1200_ICSIZE			12			// 4096
`define OR1200_ICINDX			`OR1200_ICSIZE-2	// 10
`define OR1200_ICINDXH			`OR1200_ICSIZE-1	// 11
`define OR1200_ICTAGL			`OR1200_ICINDXH+1	// 12
`define	OR1200_ICTAG			`OR1200_ICSIZE-`OR1200_ICLS	// 8
`define	OR1200_ICTAG_W			21
`endif
`ifdef OR1200_IC_1W_8KB
`define OR1200_ICSIZE			13			// 8192
`define OR1200_ICINDX			`OR1200_ICSIZE-2	// 11
`define OR1200_ICINDXH			`OR1200_ICSIZE-1	// 12
`define OR1200_ICTAGL			`OR1200_ICINDXH+1	// 13
`define	OR1200_ICTAG			`OR1200_ICSIZE-`OR1200_ICLS	// 9
`define	OR1200_ICTAG_W			20
`endif


/////////////////////////////////////////////////
//
// Data cache (DC)
//

// 3 for 8 bytes, 4 for 16 bytes etc
`define OR1200_DCLS		4

// Define to perform store refill (potential performance penalty)
// `define OR1200_DC_STORE_REFILL

//
// DC configurations
//
`ifdef OR1200_DC_1W_4KB
`define OR1200_DCSIZE			12			// 4096
`define OR1200_DCINDX			`OR1200_DCSIZE-2	// 10
`define OR1200_DCINDXH			`OR1200_DCSIZE-1	// 11
`define OR1200_DCTAGL			`OR1200_DCINDXH+1	// 12
`define	OR1200_DCTAG			`OR1200_DCSIZE-`OR1200_DCLS	// 8
`define	OR1200_DCTAG_W			21
`endif
`ifdef OR1200_DC_1W_8KB
`define OR1200_DCSIZE			13			// 8192
`define OR1200_DCINDX			`OR1200_DCSIZE-2	// 11
`define OR1200_DCINDXH			`OR1200_DCSIZE-1	// 12
`define OR1200_DCTAGL			`OR1200_DCINDXH+1	// 13
`define	OR1200_DCTAG			`OR1200_DCSIZE-`OR1200_DCLS	// 9
`define	OR1200_DCTAG_W			20
`endif

/////////////////////////////////////////////////
//
// Store buffer (SB)
//

//
// Store buffer
//
// It will improve performance by "caching" CPU stores
// using store buffer. This is most important for function
// prologues because DC can only work in write though mode
// and all stores would have to complete external WB writes
// to memory.
// Store buffer is between DC and data BIU.
// All stores will be stored into store buffer and immediately
// completed by the CPU, even though actual external writes
// will be performed later. As a consequence store buffer masks
// all data bus errors related to stores (data bus errors
// related to loads are delivered normally).
// All pending CPU loads will wait until store buffer is empty to
// ensure strict memory model. Right now this is necessary because
// we don't make destinction between cached and cache inhibited
// address space, so we simply empty store buffer until loads
// can begin.
//
// It makes design a bit bigger, depending what is the number of
// entries in SB FIFO. Number of entries can be changed further
// down.
//
//`define OR1200_SB_IMPLEMENTED

//
// Number of store buffer entries
//
// Verified number of entries are 4 and 8 entries
// (2 and 3 for OR1200_SB_LOG). OR1200_SB_ENTRIES must
// always match 2**OR1200_SB_LOG.
// To disable store buffer, undefine
// OR1200_SB_IMPLEMENTED.
//
`define OR1200_SB_LOG		2	// 2 or 3
`define OR1200_SB_ENTRIES	4	// 4 or 8


/////////////////////////////////////////////////
//
// Quick Embedded Memory (QMEM)
//

//
// Quick Embedded Memory
//
// Instantiation of dedicated insn/data memory (RAM or ROM).
// Insn fetch has effective throughput 1insn / clock cycle.
// Data load takes two clock cycles / access, data store
// takes 1 clock cycle / access (if there is no insn fetch)).
// Memory instantiation is shared between insn and data,
// meaning if insn fetch are performed, data load/store
// performance will be lower.
//
// Main reason for QMEM is to put some time critical functions
// into this memory and to have predictable and fast access
// to these functions. (soft fpu, context switch, exception
// handlers, stack, etc)
//
// It makes design a bit bigger and slower. QMEM sits behind
// IMMU/DMMU so all addresses are physical (so the MMUs can be
// used with QMEM and QMEM is seen by the CPU just like any other
// memory in the system). IC/DC are sitting behind QMEM so the
// whole design timing might be worse with QMEM implemented.
//
//`define OR1200_QMEM_IMPLEMENTED

//
// Base address and mask of QMEM
//
// Base address defines first address of QMEM. Mask defines
// QMEM range in address space. Actual size of QMEM is however
// determined with instantiated RAM/ROM. However bigger
// mask will reserve more address space for QMEM, but also
// make design faster, while more tight mask will take
// less address space but also make design slower. If
// instantiated RAM/ROM is smaller than space reserved with
// the mask, instatiated RAM/ROM will also be shadowed
// at higher addresses in reserved space.
//
`define OR1200_QMEM_IADDR	32'h0080_0000
`define OR1200_QMEM_IMASK	32'hfff0_0000	// Max QMEM size 1MB
`define OR1200_QMEM_DADDR  32'h0080_0000
`define OR1200_QMEM_DMASK  32'hfff0_0000 // Max QMEM size 1MB

//
// QMEM interface byte-select capability
//
// To enable qmem_sel* ports, define this macro.
//
//`define OR1200_QMEM_BSEL

//
// QMEM interface acknowledge
//
// To enable qmem_ack port, define this macro.
//
//`define OR1200_QMEM_ACK

/////////////////////////////////////////////////////
//
// VR, UPR and Configuration Registers
//
//
// VR, UPR and configuration registers are optional. If 
// implemented, operating system can automatically figure
// out how to use the processor because it knows 
// what units are available in the processor and how they
// are configured.
//
// This section must be last in or1200_defines.v file so
// that all units are already configured and thus
// configuration registers are properly set.
// 

// Define if you want configuration registers implemented
`define OR1200_CFGR_IMPLEMENTED

// Define if you want full address decode inside SYS group
`define OR1200_SYS_FULL_DECODE

// Offsets of VR, UPR and CFGR registers
`define OR1200_SPRGRP_SYS_VR		4'h0
`define OR1200_SPRGRP_SYS_UPR		4'h1
`define OR1200_SPRGRP_SYS_CPUCFGR	4'h2
`define OR1200_SPRGRP_SYS_DMMUCFGR	4'h3
`define OR1200_SPRGRP_SYS_IMMUCFGR	4'h4
`define OR1200_SPRGRP_SYS_DCCFGR	4'h5
`define OR1200_SPRGRP_SYS_ICCFGR	4'h6
`define OR1200_SPRGRP_SYS_DCFGR	4'h7

// VR fields
`define OR1200_VR_REV_BITS		5:0
`define OR1200_VR_RES1_BITS		15:6
`define OR1200_VR_CFG_BITS		23:16
`define OR1200_VR_VER_BITS		31:24

// VR values
`define OR1200_VR_REV			6'h01
`define OR1200_VR_RES1			10'h000
`define OR1200_VR_CFG			8'h00
`define OR1200_VR_VER			8'h12

// UPR fields
`define OR1200_UPR_UP_BITS		0
`define OR1200_UPR_DCP_BITS		1
`define OR1200_UPR_ICP_BITS		2
`define OR1200_UPR_DMP_BITS		3
`define OR1200_UPR_IMP_BITS		4
`define OR1200_UPR_MP_BITS		5
`define OR1200_UPR_DUP_BITS		6
`define OR1200_UPR_PCUP_BITS		7
`define OR1200_UPR_PMP_BITS		8
`define OR1200_UPR_PICP_BITS		9
`define OR1200_UPR_TTP_BITS		10
`define OR1200_UPR_RES1_BITS		23:11
`define OR1200_UPR_CUP_BITS		31:24

// UPR values
`define OR1200_UPR_UP			1'b1
`ifdef OR1200_NO_DC
`define OR1200_UPR_DCP			1'b0
`else
`define OR1200_UPR_DCP			1'b1
`endif
`ifdef OR1200_NO_IC
`define OR1200_UPR_ICP			1'b0
`else
`define OR1200_UPR_ICP			1'b1
`endif
`ifdef OR1200_NO_DMMU
`define OR1200_UPR_DMP			1'b0
`else
`define OR1200_UPR_DMP			1'b1
`endif
`ifdef OR1200_NO_IMMU
`define OR1200_UPR_IMP			1'b0
`else
`define OR1200_UPR_IMP			1'b1
`endif
`define OR1200_UPR_MP			1'b1	// MAC always present
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_DUP			1'b1
`else
`define OR1200_UPR_DUP			1'b0
`endif
`define OR1200_UPR_PCUP			1'b0	// Performance counters not present
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_PMP			1'b1
`else
`define OR1200_UPR_PMP			1'b0
`endif
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_PICP			1'b1
`else
`define OR1200_UPR_PICP			1'b0
`endif
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_TTP			1'b1
`else
`define OR1200_UPR_TTP			1'b0
`endif
`define OR1200_UPR_RES1			13'h0000
`define OR1200_UPR_CUP			8'h00

// CPUCFGR fields
`define OR1200_CPUCFGR_NSGF_BITS	3:0
`define OR1200_CPUCFGR_HGF_BITS	4
`define OR1200_CPUCFGR_OB32S_BITS	5
`define OR1200_CPUCFGR_OB64S_BITS	6
`define OR1200_CPUCFGR_OF32S_BITS	7
`define OR1200_CPUCFGR_OF64S_BITS	8
`define OR1200_CPUCFGR_OV64S_BITS	9
`define OR1200_CPUCFGR_RES1_BITS	31:10

// CPUCFGR values
`define OR1200_CPUCFGR_NSGF		4'h0
`define OR1200_CPUCFGR_HGF		1'b0
`define OR1200_CPUCFGR_OB32S		1'b1
`define OR1200_CPUCFGR_OB64S		1'b0
`define OR1200_CPUCFGR_OF32S		1'b0
`define OR1200_CPUCFGR_OF64S		1'b0
`define OR1200_CPUCFGR_OV64S		1'b0
`define OR1200_CPUCFGR_RES1		22'h000000

// DMMUCFGR fields
`define OR1200_DMMUCFGR_NTW_BITS	1:0
`define OR1200_DMMUCFGR_NTS_BITS	4:2
`define OR1200_DMMUCFGR_NAE_BITS	7:5
`define OR1200_DMMUCFGR_CRI_BITS	8
`define OR1200_DMMUCFGR_PRI_BITS	9
`define OR1200_DMMUCFGR_TEIRI_BITS	10
`define OR1200_DMMUCFGR_HTR_BITS	11
`define OR1200_DMMUCFGR_RES1_BITS	31:12

// DMMUCFGR values
`ifdef OR1200_NO_DMMU
`define OR1200_DMMUCFGR_NTW		2'h0	// Irrelevant
`define OR1200_DMMUCFGR_NTS		3'h0	// Irrelevant
`define OR1200_DMMUCFGR_NAE		3'h0	// Irrelevant
`define OR1200_DMMUCFGR_CRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_PRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_TEIRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_HTR		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_RES1		20'h00000
`else
`define OR1200_DMMUCFGR_NTW		2'h0	// 1 TLB way
`define OR1200_DMMUCFGR_NTS 		3'h6 //3'h`OR1200_DTLB_INDXW	// Num TLB sets
`define OR1200_DMMUCFGR_NAE		3'h0	// No ATB entries
`define OR1200_DMMUCFGR_CRI		1'b0	// No control register
`define OR1200_DMMUCFGR_PRI		1'b0	// No protection reg
`define OR1200_DMMUCFGR_TEIRI		1'b1	// TLB entry inv reg impl.
`define OR1200_DMMUCFGR_HTR		1'b0	// No HW TLB reload
`define OR1200_DMMUCFGR_RES1		20'h00000
`endif

// IMMUCFGR fields
`define OR1200_IMMUCFGR_NTW_BITS	1:0
`define OR1200_IMMUCFGR_NTS_BITS	4:2
`define OR1200_IMMUCFGR_NAE_BITS	7:5
`define OR1200_IMMUCFGR_CRI_BITS	8
`define OR1200_IMMUCFGR_PRI_BITS	9
`define OR1200_IMMUCFGR_TEIRI_BITS	10
`define OR1200_IMMUCFGR_HTR_BITS	11
`define OR1200_IMMUCFGR_RES1_BITS	31:12

// IMMUCFGR values
`ifdef OR1200_NO_IMMU
`define OR1200_IMMUCFGR_NTW		2'h0	// Irrelevant
`define OR1200_IMMUCFGR_NTS		3'h0	// Irrelevant
`define OR1200_IMMUCFGR_NAE		3'h0	// Irrelevant
`define OR1200_IMMUCFGR_CRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_PRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_TEIRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_HTR		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_RES1		20'h00000
`else
`define OR1200_IMMUCFGR_NTW		2'h0	// 1 TLB way
`define OR1200_IMMUCFGR_NTS 		3'h6 //3'h`OR1200_ITLB_INDXW	// Num TLB sets
`define OR1200_IMMUCFGR_NAE		3'h0	// No ATB entry
`define OR1200_IMMUCFGR_CRI		1'b0	// No control reg
`define OR1200_IMMUCFGR_PRI		1'b0	// No protection reg
`define OR1200_IMMUCFGR_TEIRI		1'b1	// TLB entry inv reg impl
`define OR1200_IMMUCFGR_HTR		1'b0	// No HW TLB reload
`define OR1200_IMMUCFGR_RES1		20'h00000
`endif

// DCCFGR fields
`define OR1200_DCCFGR_NCW_BITS		2:0
`define OR1200_DCCFGR_NCS_BITS		6:3
`define OR1200_DCCFGR_CBS_BITS		7
`define OR1200_DCCFGR_CWS_BITS		8
`define OR1200_DCCFGR_CCRI_BITS		9
`define OR1200_DCCFGR_CBIRI_BITS	10
`define OR1200_DCCFGR_CBPRI_BITS	11
`define OR1200_DCCFGR_CBLRI_BITS	12
`define OR1200_DCCFGR_CBFRI_BITS	13
`define OR1200_DCCFGR_CBWBRI_BITS	14
`define OR1200_DCCFGR_RES1_BITS	31:15

// DCCFGR values
`ifdef OR1200_NO_DC
`define OR1200_DCCFGR_NCW		3'h0	// Irrelevant
`define OR1200_DCCFGR_NCS		4'h0	// Irrelevant
`define OR1200_DCCFGR_CBS		1'b0	// Irrelevant
`define OR1200_DCCFGR_CWS		1'b0	// Irrelevant
`define OR1200_DCCFGR_CCRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBIRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBPRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_CBLRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_CBFRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_RES1		17'h00000
`else
`define OR1200_DCCFGR_NCW		3'h0	// 1 cache way
`define OR1200_DCCFGR_NCS (`OR1200_DCTAG)	// Num cache sets
`define OR1200_DCCFGR_CBS (`OR1200_DCLS-4)	// 16 byte cache block
`define OR1200_DCCFGR_CWS		1'b0	// Write-through strategy
`define OR1200_DCCFGR_CCRI		1'b1	// Cache control reg impl.
`define OR1200_DCCFGR_CBIRI		1'b1	// Cache block inv reg impl.
`define OR1200_DCCFGR_CBPRI		1'b0	// Cache block prefetch reg not impl.
`define OR1200_DCCFGR_CBLRI		1'b0	// Cache block lock reg not impl.
`define OR1200_DCCFGR_CBFRI		1'b1	// Cache block flush reg impl.
`define OR1200_DCCFGR_CBWBRI		1'b0	// Cache block WB reg not impl.
`define OR1200_DCCFGR_RES1		17'h00000
`endif

// ICCFGR fields
`define OR1200_ICCFGR_NCW_BITS		2:0
`define OR1200_ICCFGR_NCS_BITS		6:3
`define OR1200_ICCFGR_CBS_BITS		7
`define OR1200_ICCFGR_CWS_BITS		8
`define OR1200_ICCFGR_CCRI_BITS		9
`define OR1200_ICCFGR_CBIRI_BITS	10
`define OR1200_ICCFGR_CBPRI_BITS	11
`define OR1200_ICCFGR_CBLRI_BITS	12
`define OR1200_ICCFGR_CBFRI_BITS	13
`define OR1200_ICCFGR_CBWBRI_BITS	14
`define OR1200_ICCFGR_RES1_BITS	31:15

// ICCFGR values
`ifdef OR1200_NO_IC
`define OR1200_ICCFGR_NCW		3'h0	// Irrelevant
`define OR1200_ICCFGR_NCS 		4'h0	// Irrelevant
`define OR1200_ICCFGR_CBS 		1'b0	// Irrelevant
`define OR1200_ICCFGR_CWS		1'b0	// Irrelevant
`define OR1200_ICCFGR_CCRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBIRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBPRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBLRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBFRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_RES1		17'h00000
`else
`define OR1200_ICCFGR_NCW		3'h0	// 1 cache way
`define OR1200_ICCFGR_NCS (`OR1200_ICTAG)	// Num cache sets
`define OR1200_ICCFGR_CBS (`OR1200_ICLS-4)	// 16 byte cache block
`define OR1200_ICCFGR_CWS		1'b0	// Irrelevant
`define OR1200_ICCFGR_CCRI		1'b1	// Cache control reg impl.
`define OR1200_ICCFGR_CBIRI		1'b1	// Cache block inv reg impl.
`define OR1200_ICCFGR_CBPRI		1'b0	// Cache block prefetch reg not impl.
`define OR1200_ICCFGR_CBLRI		1'b0	// Cache block lock reg not impl.
`define OR1200_ICCFGR_CBFRI		1'b1	// Cache block flush reg impl.
`define OR1200_ICCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_RES1		17'h00000
`endif

// DCFGR fields
`define OR1200_DCFGR_NDP_BITS		2:0
`define OR1200_DCFGR_WPCI_BITS		3
`define OR1200_DCFGR_RES1_BITS		31:4

// DCFGR values
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DCFGR_NDP	3'h`OR1200_DU_DVRDCR_PAIRS // # of DVR/DCR pairs
`ifdef OR1200_DU_DWCR0
`define OR1200_DCFGR_WPCI		1'b1
`else
`define OR1200_DCFGR_WPCI		1'b0	// WP counters not impl.
`endif
`else
`define OR1200_DCFGR_NDP		3'h0	// Zero DVR/DCR pairs
`define OR1200_DCFGR_WPCI		1'b0	// WP counters not impl.
`endif
`define OR1200_DCFGR_RES1		28'h0000000
 

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/mmc_boot_defines.v
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
// Source file: rtl/verilog/virtex_bitstream_const.v
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
// Source file: rtl/rtl_orig/verilog/or1200_defines.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's definitions                                        ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  Parameters of the OR1200 core                               ////
////                                                              ////
////  To Do:                                                      ////
////   - add parameters that are missing                          ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
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
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.44  2005/10/19 11:37:56  jcastillo
// Added support for RAMB16 Xilinx4/Spartan3 primitives
//
// Revision 1.43  2005/01/07 09:23:39  andreje
// l.ff1 and l.cmov instructions added
//
// Revision 1.42  2004/06/08 18:17:36  lampret
// Non-functional changes. Coding style fixes.
//
// Revision 1.41  2004/05/09 20:03:20  lampret
// By default l.cust5 insns are disabled
//
// Revision 1.40  2004/05/09 19:49:04  lampret
// Added some l.cust5 custom instructions as example
//
// Revision 1.39  2004/04/08 11:00:46  simont
// Add support for 512B instruction cache.
//
// Revision 1.38  2004/04/05 08:29:57  lampret
// Merged branch_qmem into main tree.
//
// Revision 1.35.4.6  2004/02/11 01:40:11  lampret
// preliminary HW breakpoints support in debug unit (by default disabled). To enable define OR1200_DU_HWBKPTS.
//
// Revision 1.35.4.5  2004/01/15 06:46:38  markom
// interface to debug changed; no more opselect; stb-ack protocol
//
// Revision 1.35.4.4  2004/01/11 22:45:46  andreje
// Separate instruction and data QMEM decoders, QMEM acknowledge and byte-select added
//
// Revision 1.35.4.3  2003/12/17 13:43:38  simons
// Exception prefix configuration changed.
//
// Revision 1.35.4.2  2003/12/05 00:05:03  lampret
// Static exception prefix.
//
// Revision 1.35.4.1  2003/07/08 15:36:37  lampret
// Added embedded memory QMEM.
//
// Revision 1.35  2003/04/24 00:16:07  lampret
// No functional changes. Added defines to disable implementation of multiplier/MAC
//
// Revision 1.34  2003/04/20 22:23:57  lampret
// No functional change. Only added customization for exception vectors.
//
// Revision 1.33  2003/04/07 20:56:07  lampret
// Fixed OR1200_CLKDIV_x_SUPPORTED defines. Better description.
//
// Revision 1.32  2003/04/07 01:26:57  lampret
// RFRAM defines comments updated. Altera LPM option added.
//
// Revision 1.31  2002/12/08 08:57:56  lampret
// Added optional support for WB B3 specification (xwb_cti_o, xwb_bte_o). Made xwb_cab_o optional.
//
// Revision 1.30  2002/10/28 15:09:22  mohor
// Previous check-in was done by mistake.
//
// Revision 1.29  2002/10/28 15:03:50  mohor
// Signal scanb_sen renamed to scanb_en.
//
// Revision 1.28  2002/10/17 20:04:40  lampret
// Added BIST scan. Special VS RAMs need to be used to implement BIST.
//
// Revision 1.27  2002/09/16 03:13:23  lampret
// Removed obsolete comment.
//
// Revision 1.26  2002/09/08 05:52:16  lampret
// Added optional l.div/l.divu insns. By default they are disabled.
//
// Revision 1.25  2002/09/07 19:16:10  lampret
// If SR[CY] implemented with OR1200_IMPL_ADDC enabled, l.add/l.addi also set SR[CY].
//
// Revision 1.24  2002/09/07 05:42:02  lampret
// Added optional SR[CY]. Added define to enable additional (compare) flag modifiers. Defines are OR1200_IMPL_ADDC and OR1200_ADDITIONAL_FLAG_MODIFIERS.
//
// Revision 1.23  2002/09/04 00:50:34  lampret
// Now most of the configuration registers are updatded automatically based on defines in or1200_defines.v.
//
// Revision 1.22  2002/09/03 22:28:21  lampret
// As per Taylor Su suggestion all case blocks are full case by default and optionally (OR1200_CASE_DEFAULT) can be disabled to increase clock frequncy.
//
// Revision 1.21  2002/08/22 02:18:55  lampret
// Store buffer has been tested and it works. BY default it is still disabled until uClinux confirms correct operation on FPGA board.
//
// Revision 1.20  2002/08/18 21:59:45  lampret
// Disable SB until it is tested
//
// Revision 1.19  2002/08/18 19:53:08  lampret
// Added store buffer.
//
// Revision 1.18  2002/08/15 06:04:11  lampret
// Fixed Xilinx trace buffer address. REported by Taylor Su.
//
// Revision 1.17  2002/08/12 05:31:44  lampret
// Added OR1200_WB_RETRY. Moved WB registered outsputs / samples inputs into lower section.
//
// Revision 1.16  2002/07/14 22:17:17  lampret
// Added simple trace buffer [only for Xilinx Virtex target]. Fixed instruction fetch abort when new exception is recognized.
//
// Revision 1.15  2002/06/08 16:20:21  lampret
// Added defines for enabling generic FF based memory macro for register file.
//
// Revision 1.14  2002/03/29 16:24:06  lampret
// Changed comment about synopsys to _synopsys_ because synthesis was complaining about unknown directives
//
// Revision 1.13  2002/03/29 15:16:55  lampret
// Some of the warnings fixed.
//
// Revision 1.12  2002/03/28 19:25:42  lampret
// Added second type of Virtual Silicon two-port SRAM (for register file). Changed defines for VS STP RAMs.
//
// Revision 1.11  2002/03/28 19:13:17  lampret
// Updated defines.
//
// Revision 1.10  2002/03/14 00:30:24  lampret
// Added alternative for critical path in DU.
//
// Revision 1.9  2002/03/11 01:26:26  lampret
// Fixed async loop. Changed multiplier type for ASIC.
//
// Revision 1.8  2002/02/11 04:33:17  lampret
// Speed optimizations (removed duplicate _cyc_ and _stb_). Fixed D/IMMU cache-inhibit attr.
//
// Revision 1.7  2002/02/01 19:56:54  lampret
// Fixed combinational loops.
//
// Revision 1.6  2002/01/19 14:10:22  lampret
// Fixed OR1200_XILINX_RAM32X1D.
//
// Revision 1.5  2002/01/18 07:56:00  lampret
// No more low/high priority interrupts (PICPR removed). Added tick timer exception. Added exception prefix (SR[EPH]). Fixed single-step bug whenreading NPC.
//
// Revision 1.4  2002/01/14 09:44:12  lampret
// Default ASIC configuration does not sample WB inputs.
//
// Revision 1.3  2002/01/08 00:51:08  lampret
// Fixed typo. OR1200_REGISTERED_OUTPUTS was not defined. Should be.
//
// Revision 1.2  2002/01/03 21:23:03  lampret
// Uncommented OR1200_REGISTERED_OUTPUTS for FPGA target.
//
// Revision 1.1  2002/01/03 08:16:15  lampret
// New prefixes for RTL files, prefixed module names. Updated cache controllers and MMUs.
//
// Revision 1.20  2001/12/04 05:02:36  lampret
// Added OR1200_GENERIC_MULTP2_32X32 and OR1200_ASIC_MULTP2_32X32
//
// Revision 1.19  2001/11/27 19:46:57  lampret
// Now FPGA and ASIC target are separate.
//
// Revision 1.18  2001/11/23 21:42:31  simons
// Program counter divided to PPC and NPC.
//
// Revision 1.17  2001/11/23 08:38:51  lampret
// Changed DSR/DRR behavior and exception detection.
//
// Revision 1.16  2001/11/20 21:30:38  lampret
// Added OR1200_REGISTERED_INPUTS.
//
// Revision 1.15  2001/11/19 14:29:48  simons
// Cashes disabled.
//
// Revision 1.14  2001/11/13 10:02:21  lampret
// Added 'setpc'. Renamed some signals (except_flushpipe into flushpipe etc)
//
// Revision 1.13  2001/11/12 01:45:40  lampret
// Moved flag bit into SR. Changed RF enable from constant enable to dynamic enable for read ports.
//
// Revision 1.12  2001/11/10 03:43:57  lampret
// Fixed exceptions.
//
// Revision 1.11  2001/11/02 18:57:14  lampret
// Modified virtual silicon instantiations.
//
// Revision 1.10  2001/10/21 17:57:16  lampret
// Removed params from generic_XX.v. Added translate_off/on in sprs.v and id.v. Removed spr_addr from dc.v and ic.v. Fixed CR+LF.
//
// Revision 1.9  2001/10/19 23:28:46  lampret
// Fixed some synthesis warnings. Configured with caches and MMUs.
//
// Revision 1.8  2001/10/14 13:12:09  lampret
// MP3 version.
//
// Revision 1.1.1.1  2001/10/06 10:18:36  igorm
// no message
//
// Revision 1.3  2001/08/17 08:01:19  lampret
// IC enable/disable.
//
// Revision 1.2  2001/08/13 03:36:20  lampret
// Added cfg regs. Moved all defines into one defines.v file. More cleanup.
//
// Revision 1.1  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/22 03:31:54  lampret
// Fixed RAM's oen bug. Cache bypass under development.
//
// Revision 1.1  2001/07/20 00:46:03  lampret
// Development version of RTL. Libraries are missing.
//
//

//
// Dump VCD
//
//`define OR1200_VCD_DUMP

//
// Generate debug messages during simulation
//
//`define OR1200_VERBOSE

//  `define OR1200_ASIC
////////////////////////////////////////////////////////
//
// Typical configuration for an ASIC
//
`ifdef OR1200_ASIC

//
// Target ASIC memories
//
//`define OR1200_ARTISAN_SSP
//`define OR1200_ARTISAN_SDP
//`define OR1200_ARTISAN_STP
`define OR1200_VIRTUALSILICON_SSP
//`define OR1200_VIRTUALSILICON_STP_T1
//`define OR1200_VIRTUALSILICON_STP_T2

//
// Do not implement Data cache
//
`define OR1200_NO_DC

//
// Do not implement Insn cache
//
`define OR1200_NO_IC

//
// Do not implement Data MMU
//
`define OR1200_NO_DMMU

//
// Do not implement Insn MMU
//
`define OR1200_NO_IMMU

//
// Select between ASIC optimized and generic multiplier
//
//`define OR1200_ASIC_MULTP2_32X32
`define OR1200_GENERIC_MULTP2_32X32

//
// Size/type of insn/data cache if implemented
//
// `define OR1200_IC_1W_512B
// `define OR1200_IC_1W_4KB
`define OR1200_IC_1W_8KB
// `define OR1200_DC_1W_4KB
`define OR1200_DC_1W_8KB

`else


/////////////////////////////////////////////////////////
//
// Typical configuration for an FPGA
//

//
// Target FPGA memories
//
//`define OR1200_ALTERA_LPM
//`define OR1200_XILINX_RAMB16
//`define OR1200_XILINX_RAMB4
//`define OR1200_XILINX_RAM32X1D
//`define OR1200_USE_RAM16X1D_FOR_RAM32X1D
`define OR1200_RAM_MODELS_VIRTEX
//`define BLK_MEM_GEN

//
// Do not implement Data cache
//
//`define OR1200_NO_DC

//
// Do not implement Insn cache
//
//`define OR1200_NO_IC

//
// Do not implement Data MMU
//
//`define OR1200_NO_DMMU

//
// Do not implement Insn MMU
//
//`define OR1200_NO_IMMU

//
// Select between ASIC and generic multiplier
//
// (Generic seems to trigger a bug in the Cadence Ncsim simulator)
//
//`define OR1200_ASIC_MULTP2_32X32
`define OR1200_GENERIC_MULTP2_32X32

//
// Size/type of insn/data cache if implemented
// (consider available FPGA memory resources)
//
//`define OR1200_IC_1W_512B
//`define OR1200_IC_1W_4KB
`define OR1200_IC_1W_8KB
//`define OR1200_DC_1W_4KB
`define OR1200_DC_1W_8KB

`endif


//////////////////////////////////////////////////////////
//
// Do not change below unless you know what you are doing
//

//
// Enable RAM BIST
//
// At the moment this only works for Virtual Silicon
// single port RAMs. For other RAMs it has not effect.
// Special wrapper for VS RAMs needs to be provided
// with scan flops to facilitate bist scan.
//
//`define OR1200_BIST

//
// Register OR1200 WISHBONE outputs
// (must be defined/enabled)
//
`define OR1200_REGISTERED_OUTPUTS

//
// Register OR1200 WISHBONE inputs
//
// (must be undefined/disabled)
//
//`define OR1200_REGISTERED_INPUTS

//
// Disable bursts if they are not supported by the
// memory subsystem (only affect cache line fill)
//
//`define OR1200_NO_BURSTS
//

//
// WISHBONE retry counter range
//
// 2^value range for retry counter. Retry counter
// is activated whenever *wb_rty_i is asserted and
// until retry counter expires, corresponding
// WISHBONE interface is deactivated.
//
// To disable retry counters and *wb_rty_i all together,
// undefine this macro.
//
//`define OR1200_WB_RETRY 7

//
// WISHBONE Consecutive Address Burst
//
// This was used prior to WISHBONE B3 specification
// to identify bursts. It is no longer needed but
// remains enabled for compatibility with old designs.
//
// To remove *wb_cab_o ports undefine this macro.
//
`define OR1200_WB_CAB

//
// WISHBONE B3 compatible interface
//
// This follows the WISHBONE B3 specification.
// It is not enabled by default because most
// designs still don't use WB b3.
//
// To enable *wb_cti_o/*wb_bte_o ports,
// define this macro.
//
//`define OR1200_WB_B3

//
// Enable additional synthesis directives if using
// _Synopsys_ synthesis tool
//
//`define OR1200_ADDITIONAL_SYNOPSYS_DIRECTIVES

//
// Enables default statement in some case blocks
// and disables Synopsys synthesis directive full_case
//
// By default it is enabled. When disabled it
// can increase clock frequency.
//
`define OR1200_CASE_DEFAULT

//
// Operand width / register file address width
//
// (DO NOT CHANGE)
//
`define OR1200_OPERAND_WIDTH		32
`define OR1200_REGFILE_ADDR_WIDTH	5

//
// l.add/l.addi/l.and and optional l.addc/l.addic
// also set (compare) flag when result of their
// operation equals zero
//
// At the time of writing this, default or32
// C/C++ compiler doesn't generate code that
// would benefit from this optimization.
//
// By default this optimization is disabled to
// save area.
//
//`define OR1200_ADDITIONAL_FLAG_MODIFIERS

//
// Implement l.addc/l.addic instructions
//
// By default implementation of l.addc/l.addic
// instructions is enabled in case you need them.
// If you don't use them, then disable implementation
// to save area.
//
`define OR1200_IMPL_ADDC

//
// Implement carry bit SR[CY]
//
// By default implementation of SR[CY] is enabled
// to be compliant with the simulator. However
// SR[CY] is explicitly only used by l.addc/l.addic
// instructions and if these two insns are not
// implemented there is not much point having SR[CY].
//
`define OR1200_IMPL_CY

//
// Implement optional l.div/l.divu instructions
//
// By default divide instructions are not implemented
// to save area and increase clock frequency. or32 C/C++
// compiler can use soft library for division.
//
// To implement divide, multiplier needs to be implemented.
//
//`define OR1200_IMPL_DIV

//
// Implement rotate in the ALU
//
// At the time of writing this, or32
// C/C++ compiler doesn't generate rotate
// instructions. However or32 assembler
// can assemble code that uses rotate insn.
// This means that rotate instructions
// must be used manually inserted.
//
// By default implementation of rotate
// is disabled to save area and increase
// clock frequency.
//
//`define OR1200_IMPL_ALU_ROTATE

//
// Type of ALU compare to implement
//
// Try either one to find what yields
// higher clock frequencyin your case.
//
//`define OR1200_IMPL_ALU_COMP1
`define OR1200_IMPL_ALU_COMP2

//
// Implement multiplier
//
// By default multiplier is implemented
//
`define OR1200_MULT_IMPLEMENTED

//
// Implement multiply-and-accumulate
//
// By default MAC is implemented. To
// implement MAC, multiplier needs to be
// implemented.
//
`define OR1200_MAC_IMPLEMENTED

//
// Low power, slower multiplier
//
// Select between low-power (larger) multiplier
// and faster multiplier. The actual difference
// is only AND logic that prevents distribution
// of operands into the multiplier when instruction
// in execution is not multiply instruction
//
//`define OR1200_LOWPWR_MULT

//
// Clock ratio RISC clock versus WB clock
//
// If you plan to run WB:RISC clock fixed to 1:1, disable
// both defines
//
// For WB:RISC 1:2 or 1:1, enable OR1200_CLKDIV_2_SUPPORTED
// and use clmode to set ratio
//
// For WB:RISC 1:4, 1:2 or 1:1, enable both defines and use
// clmode to set ratio
//
`define OR1200_CLKDIV_2_SUPPORTED
//`define OR1200_CLKDIV_4_SUPPORTED

//
// Type of register file RAM
//
// Memory macro w/ two ports (see or1200_tpram_32x32.v)
//`define OR1200_RFRAM_TWOPORT
//
// Memory macro dual port (see or1200_dpram_32x32.v)
//`define OR1200_RFRAM_DUALPORT
//
// Generic (flip-flop based) register file (see or1200_rfram_generic.v)
//`define OR1200_RFRAM_GENERIC

//
// Type of mem2reg aligner to implement.
//
// Once OR1200_IMPL_MEM2REG2 yielded faster
// circuit, however with today tools it will
// most probably give you slower circuit.
//
`define OR1200_IMPL_MEM2REG1
//`define OR1200_IMPL_MEM2REG2

//
// ALUOPs
//
`define OR1200_ALUOP_WIDTH	4
`define OR1200_ALUOP_NOP	4'd4
/* Order defined by arith insns that have two source operands both in regs
   (see binutils/include/opcode/or32.h) */
`define OR1200_ALUOP_ADD	4'd0
`define OR1200_ALUOP_ADDC	4'd1
`define OR1200_ALUOP_SUB	4'd2
`define OR1200_ALUOP_AND	4'd3
`define OR1200_ALUOP_OR		4'd4
`define OR1200_ALUOP_XOR	4'd5
`define OR1200_ALUOP_MUL	4'd6
`define OR1200_ALUOP_CUST5	4'd7
`define OR1200_ALUOP_SHROT	4'd8
`define OR1200_ALUOP_DIV	4'd9
`define OR1200_ALUOP_DIVU	4'd10
/* Order not specifically defined. */
`define OR1200_ALUOP_IMM	4'd11
`define OR1200_ALUOP_MOVHI	4'd12
`define OR1200_ALUOP_COMP	4'd13
`define OR1200_ALUOP_MTSR	4'd14
`define OR1200_ALUOP_MFSR	4'd15
`define OR1200_ALUOP_CMOV 4'd14
`define OR1200_ALUOP_FF1  4'd15
//
// MACOPs
//
`define OR1200_MACOP_WIDTH	2
`define OR1200_MACOP_NOP	2'b00
`define OR1200_MACOP_MAC	2'b01
`define OR1200_MACOP_MSB	2'b10

//
// Shift/rotate ops
//
`define OR1200_SHROTOP_WIDTH	2
`define OR1200_SHROTOP_NOP	2'd0
`define OR1200_SHROTOP_SLL	2'd0
`define OR1200_SHROTOP_SRL	2'd1
`define OR1200_SHROTOP_SRA	2'd2
`define OR1200_SHROTOP_ROR	2'd3

// Execution cycles per instruction
`define OR1200_MULTICYCLE_WIDTH	2
`define OR1200_ONE_CYCLE		2'd0
`define OR1200_TWO_CYCLES		2'd1

// Operand MUX selects
`define OR1200_SEL_WIDTH		2
`define OR1200_SEL_RF			2'd0
`define OR1200_SEL_IMM			2'd1
`define OR1200_SEL_EX_FORW		2'd2
`define OR1200_SEL_WB_FORW		2'd3

//
// BRANCHOPs
//
`define OR1200_BRANCHOP_WIDTH		3
`define OR1200_BRANCHOP_NOP		3'd0
`define OR1200_BRANCHOP_J		3'd1
`define OR1200_BRANCHOP_JR		3'd2
`define OR1200_BRANCHOP_BAL		3'd3
`define OR1200_BRANCHOP_BF		3'd4
`define OR1200_BRANCHOP_BNF		3'd5
`define OR1200_BRANCHOP_RFE		3'd6

//
// LSUOPs
//
// Bit 0: sign extend
// Bits 1-2: 00 doubleword, 01 byte, 10 halfword, 11 singleword
// Bit 3: 0 load, 1 store
`define OR1200_LSUOP_WIDTH		4
`define OR1200_LSUOP_NOP		4'b0000
`define OR1200_LSUOP_LBZ		4'b0010
`define OR1200_LSUOP_LBS		4'b0011
`define OR1200_LSUOP_LHZ		4'b0100
`define OR1200_LSUOP_LHS		4'b0101
`define OR1200_LSUOP_LWZ		4'b0110
`define OR1200_LSUOP_LWS		4'b0111
`define OR1200_LSUOP_LD		4'b0001
`define OR1200_LSUOP_SD		4'b1000
`define OR1200_LSUOP_SB		4'b1010
`define OR1200_LSUOP_SH		4'b1100
`define OR1200_LSUOP_SW		4'b1110

// FETCHOPs
`define OR1200_FETCHOP_WIDTH		1
`define OR1200_FETCHOP_NOP		1'b0
`define OR1200_FETCHOP_LW		1'b1

//
// Register File Write-Back OPs
//
// Bit 0: register file write enable
// Bits 2-1: write-back mux selects
`define OR1200_RFWBOP_WIDTH		3
`define OR1200_RFWBOP_NOP		3'b000
`define OR1200_RFWBOP_ALU		3'b001
`define OR1200_RFWBOP_LSU		3'b011
`define OR1200_RFWBOP_SPRS		3'b101
`define OR1200_RFWBOP_LR		3'b111

// Compare instructions
`define OR1200_COP_SFEQ       3'b000
`define OR1200_COP_SFNE       3'b001
`define OR1200_COP_SFGT       3'b010
`define OR1200_COP_SFGE       3'b011
`define OR1200_COP_SFLT       3'b100
`define OR1200_COP_SFLE       3'b101
`define OR1200_COP_X          3'b111
`define OR1200_SIGNED_COMPARE 'd3
`define OR1200_COMPOP_WIDTH	4

//
// TAGs for instruction bus
//
`define OR1200_ITAG_IDLE	4'h0	// idle bus
`define	OR1200_ITAG_NI		4'h1	// normal insn
`define OR1200_ITAG_BE		4'hb	// Bus error exception
`define OR1200_ITAG_PE		4'hc	// Page fault exception
`define OR1200_ITAG_TE		4'hd	// TLB miss exception

//
// TAGs for data bus
//
`define OR1200_DTAG_IDLE	4'h0	// idle bus
`define	OR1200_DTAG_ND		4'h1	// normal data
`define OR1200_DTAG_AE		4'ha	// Alignment exception
`define OR1200_DTAG_BE		4'hb	// Bus error exception
`define OR1200_DTAG_PE		4'hc	// Page fault exception
`define OR1200_DTAG_TE		4'hd	// TLB miss exception


//////////////////////////////////////////////
//
// ORBIS32 ISA specifics
//

// SHROT_OP position in machine word
`define OR1200_SHROTOP_POS		7:6

// ALU instructions multicycle field in machine word
`define OR1200_ALUMCYC_POS		9:8

//
// Instruction opcode groups (basic)
//
`define OR1200_OR32_J                 6'b000000
`define OR1200_OR32_JAL               6'b000001
`define OR1200_OR32_BNF               6'b000011
`define OR1200_OR32_BF                6'b000100
`define OR1200_OR32_NOP               6'b000101
`define OR1200_OR32_MOVHI             6'b000110
`define OR1200_OR32_XSYNC             6'b001000
`define OR1200_OR32_RFE               6'b001001
/* */
`define OR1200_OR32_JR                6'b010001
`define OR1200_OR32_JALR              6'b010010
`define OR1200_OR32_MACI              6'b010011
/* */
`define OR1200_OR32_LWZ               6'b100001
`define OR1200_OR32_LBZ               6'b100011
`define OR1200_OR32_LBS               6'b100100
`define OR1200_OR32_LHZ               6'b100101
`define OR1200_OR32_LHS               6'b100110
`define OR1200_OR32_ADDI              6'b100111
`define OR1200_OR32_ADDIC             6'b101000
`define OR1200_OR32_ANDI              6'b101001
`define OR1200_OR32_ORI               6'b101010
`define OR1200_OR32_XORI              6'b101011
`define OR1200_OR32_MULI              6'b101100
`define OR1200_OR32_MFSPR             6'b101101
`define OR1200_OR32_SH_ROTI 	      6'b101110
`define OR1200_OR32_SFXXI             6'b101111
/* */
`define OR1200_OR32_MTSPR             6'b110000
`define OR1200_OR32_MACMSB            6'b110001
/* */
`define OR1200_OR32_SW                6'b110101
`define OR1200_OR32_SB                6'b110110
`define OR1200_OR32_SH                6'b110111
`define OR1200_OR32_ALU               6'b111000
`define OR1200_OR32_SFXX              6'b111001
//`define OR1200_OR32_CUST5             6'b111100


/////////////////////////////////////////////////////
//
// Exceptions
//

//
// Exception vectors per OR1K architecture:
// 0xPPPPP100 - reset
// 0xPPPPP200 - bus error
// ... etc
// where P represents exception prefix.
//
// Exception vectors can be customized as per
// the following formula:
// 0xPPPPPNVV - exception N
//
// P represents exception prefix
// N represents exception N
// VV represents length of the individual vector space,
//   usually it is 8 bits wide and starts with all bits zero
//

//
// PPPPP and VV parts
//
// Sum of these two defines needs to be 28
//
`define OR1200_EXCEPT_EPH0_P 20'h00000
`define OR1200_EXCEPT_EPH1_P 20'hF0000
`define OR1200_EXCEPT_V		   8'h00

//
// N part width
//
`define OR1200_EXCEPT_WIDTH 4

//
// Definition of exception vectors
//
// To avoid implementation of a certain exception,
// simply comment out corresponding line
//
`define OR1200_EXCEPT_UNUSED		`OR1200_EXCEPT_WIDTH'hf
`define OR1200_EXCEPT_TRAP		`OR1200_EXCEPT_WIDTH'he
`define OR1200_EXCEPT_BREAK		`OR1200_EXCEPT_WIDTH'hd
`define OR1200_EXCEPT_SYSCALL		`OR1200_EXCEPT_WIDTH'hc
`define OR1200_EXCEPT_RANGE		`OR1200_EXCEPT_WIDTH'hb
`define OR1200_EXCEPT_ITLBMISS		`OR1200_EXCEPT_WIDTH'ha
`define OR1200_EXCEPT_DTLBMISS		`OR1200_EXCEPT_WIDTH'h9
`define OR1200_EXCEPT_INT		`OR1200_EXCEPT_WIDTH'h8
`define OR1200_EXCEPT_ILLEGAL		`OR1200_EXCEPT_WIDTH'h7
`define OR1200_EXCEPT_ALIGN		`OR1200_EXCEPT_WIDTH'h6
`define OR1200_EXCEPT_TICK		`OR1200_EXCEPT_WIDTH'h5
`define OR1200_EXCEPT_IPF		`OR1200_EXCEPT_WIDTH'h4
`define OR1200_EXCEPT_DPF		`OR1200_EXCEPT_WIDTH'h3
`define OR1200_EXCEPT_BUSERR		`OR1200_EXCEPT_WIDTH'h2
`define OR1200_EXCEPT_RESET		`OR1200_EXCEPT_WIDTH'h1
`define OR1200_EXCEPT_NONE		`OR1200_EXCEPT_WIDTH'h0


/////////////////////////////////////////////////////
//
// SPR groups
//

// Bits that define the group
`define OR1200_SPR_GROUP_BITS	15:11

// Width of the group bits
`define OR1200_SPR_GROUP_WIDTH 	5

// Bits that define offset inside the group
`define OR1200_SPR_OFS_BITS 10:0

// List of groups
`define OR1200_SPR_GROUP_SYS	5'd00
`define OR1200_SPR_GROUP_DMMU	5'd01
`define OR1200_SPR_GROUP_IMMU	5'd02
`define OR1200_SPR_GROUP_DC	5'd03
`define OR1200_SPR_GROUP_IC	5'd04
`define OR1200_SPR_GROUP_MAC	5'd05
`define OR1200_SPR_GROUP_DU	5'd06
`define OR1200_SPR_GROUP_PM	5'd08
`define OR1200_SPR_GROUP_PIC	5'd09
`define OR1200_SPR_GROUP_TT	5'd10


/////////////////////////////////////////////////////
//
// System group
//

//
// System registers
//
`define OR1200_SPR_CFGR		7'd0
`define OR1200_SPR_RF		6'd32	// 1024 >> 5
`define OR1200_SPR_NPC		11'd16
`define OR1200_SPR_SR		11'd17
`define OR1200_SPR_PPC		11'd18
`define OR1200_SPR_EPCR		11'd32
`define OR1200_SPR_EEAR		11'd48
`define OR1200_SPR_ESR		11'd64

//
// SR bits
//
`define OR1200_SR_WIDTH 16
`define OR1200_SR_SM   0
`define OR1200_SR_TEE  1
`define OR1200_SR_IEE  2
`define OR1200_SR_DCE  3
`define OR1200_SR_ICE  4
`define OR1200_SR_DME  5
`define OR1200_SR_IME  6
`define OR1200_SR_LEE  7
`define OR1200_SR_CE   8
`define OR1200_SR_F    9
`define OR1200_SR_CY   10	// Unused
`define OR1200_SR_OV   11	// Unused
`define OR1200_SR_OVE  12	// Unused
`define OR1200_SR_DSX  13	// Unused
`define OR1200_SR_EPH  14
`define OR1200_SR_FO   15
`define OR1200_SR_CID  31:28	// Unimplemented

//
// Bits that define offset inside the group
//
`define OR1200_SPROFS_BITS 10:0

//
// Default Exception Prefix
//
// 1'b0 - OR1200_EXCEPT_EPH0_P (0x0000_0000)
// 1'b1 - OR1200_EXCEPT_EPH1_P (0xF000_0000)
//
`define OR1200_SR_EPH_DEF	1'b0

/////////////////////////////////////////////////////
//
// Power Management (PM)
//

// Define it if you want PM implemented
`define OR1200_PM_IMPLEMENTED

// Bit positions inside PMR (don't change)
`define OR1200_PM_PMR_SDF 3:0
`define OR1200_PM_PMR_DME 4
`define OR1200_PM_PMR_SME 5
`define OR1200_PM_PMR_DCGE 6
`define OR1200_PM_PMR_UNUSED 31:7

// PMR offset inside PM group of registers
`define OR1200_PM_OFS_PMR 11'b0

// PM group
`define OR1200_SPRGRP_PM 5'd8

// Define if PMR can be read/written at any address inside PM group
`define OR1200_PM_PARTIAL_DECODING

// Define if reading PMR is allowed
`define OR1200_PM_READREGS

// Define if unused PMR bits should be zero
`define OR1200_PM_UNUSED_ZERO


/////////////////////////////////////////////////////
//
// Debug Unit (DU)
//

// Define it if you want DU implemented
`define OR1200_DU_IMPLEMENTED

//
// Define if you want HW Breakpoints
// (if HW breakpoints are not implemented
// only default software trapping is
// possible with l.trap insn - this is
// however already enough for use
// with or32 gdb)
//
//`define OR1200_DU_HWBKPTS

// Number of DVR/DCR pairs if HW breakpoints enabled
`define OR1200_DU_DVRDCR_PAIRS 8

// Define if you want trace buffer
//`define OR1200_DU_TB_IMPLEMENTED

//
// Address offsets of DU registers inside DU group
//
// To not implement a register, doq not define its address
//
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DU_DVR0		11'd0
`define OR1200_DU_DVR1		11'd1
`define OR1200_DU_DVR2		11'd2
`define OR1200_DU_DVR3		11'd3
`define OR1200_DU_DVR4		11'd4
`define OR1200_DU_DVR5		11'd5
`define OR1200_DU_DVR6		11'd6
`define OR1200_DU_DVR7		11'd7
`define OR1200_DU_DCR0		11'd8
`define OR1200_DU_DCR1		11'd9
`define OR1200_DU_DCR2		11'd10
`define OR1200_DU_DCR3		11'd11
`define OR1200_DU_DCR4		11'd12
`define OR1200_DU_DCR5		11'd13
`define OR1200_DU_DCR6		11'd14
`define OR1200_DU_DCR7		11'd15
`endif
`define OR1200_DU_DMR1		11'd16
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DU_DMR2		11'd17
`define OR1200_DU_DWCR0		11'd18
`define OR1200_DU_DWCR1		11'd19
`endif
`define OR1200_DU_DSR		11'd20
`define OR1200_DU_DRR		11'd21
`ifdef OR1200_DU_TB_IMPLEMENTED
`define OR1200_DU_TBADR		11'h0ff
`define OR1200_DU_TBIA		11'h1xx
`define OR1200_DU_TBIM		11'h2xx
`define OR1200_DU_TBAR		11'h3xx
`define OR1200_DU_TBTS		11'h4xx
`endif

// Position of offset bits inside SPR address
`define OR1200_DUOFS_BITS	10:0

// DCR bits
`define OR1200_DU_DCR_DP	0
`define OR1200_DU_DCR_CC	3:1
`define OR1200_DU_DCR_SC	4
`define OR1200_DU_DCR_CT	7:5

// DMR1 bits
`define OR1200_DU_DMR1_CW0	1:0
`define OR1200_DU_DMR1_CW1	3:2
`define OR1200_DU_DMR1_CW2	5:4
`define OR1200_DU_DMR1_CW3	7:6
`define OR1200_DU_DMR1_CW4	9:8
`define OR1200_DU_DMR1_CW5	11:10
`define OR1200_DU_DMR1_CW6	13:12
`define OR1200_DU_DMR1_CW7	15:14
`define OR1200_DU_DMR1_CW8	17:16
`define OR1200_DU_DMR1_CW9	19:18
`define OR1200_DU_DMR1_CW10	21:20
`define OR1200_DU_DMR1_ST	22
`define OR1200_DU_DMR1_BT	23
`define OR1200_DU_DMR1_DXFW	24
`define OR1200_DU_DMR1_ETE	25

// DMR2 bits
`define OR1200_DU_DMR2_WCE0	0
`define OR1200_DU_DMR2_WCE1	1
`define OR1200_DU_DMR2_AWTC	12:2
`define OR1200_DU_DMR2_WGB	23:13

// DWCR bits
`define OR1200_DU_DWCR_COUNT	15:0
`define OR1200_DU_DWCR_MATCH	31:16

// DSR bits
`define OR1200_DU_DSR_WIDTH	14
`define OR1200_DU_DSR_RSTE	0
`define OR1200_DU_DSR_BUSEE	1
`define OR1200_DU_DSR_DPFE	2
`define OR1200_DU_DSR_IPFE	3
`define OR1200_DU_DSR_TTE	4
`define OR1200_DU_DSR_AE	5
`define OR1200_DU_DSR_IIE	6
`define OR1200_DU_DSR_IE	7
`define OR1200_DU_DSR_DME	8
`define OR1200_DU_DSR_IME	9
`define OR1200_DU_DSR_RE	10
`define OR1200_DU_DSR_SCE	11
`define OR1200_DU_DSR_BE	12
`define OR1200_DU_DSR_TE	13

// DRR bits
`define OR1200_DU_DRR_RSTE	0
`define OR1200_DU_DRR_BUSEE	1
`define OR1200_DU_DRR_DPFE	2
`define OR1200_DU_DRR_IPFE	3
`define OR1200_DU_DRR_TTE	4
`define OR1200_DU_DRR_AE	5
`define OR1200_DU_DRR_IIE	6
`define OR1200_DU_DRR_IE	7
`define OR1200_DU_DRR_DME	8
`define OR1200_DU_DRR_IME	9
`define OR1200_DU_DRR_RE	10
`define OR1200_DU_DRR_SCE	11
`define OR1200_DU_DRR_BE	12
`define OR1200_DU_DRR_TE	13

// Define if reading DU regs is allowed
`define OR1200_DU_READREGS

// Define if unused DU registers bits should be zero
`define OR1200_DU_UNUSED_ZERO

// Define if IF/LSU status is not needed by devel i/f
`define OR1200_DU_STATUS_UNIMPLEMENTED

/////////////////////////////////////////////////////
//
// Programmable Interrupt Controller (PIC)
//

// Define it if you want PIC implemented
`define OR1200_PIC_IMPLEMENTED

// Define number of interrupt inputs (2-31)
`define OR1200_PIC_INTS 20

// Address offsets of PIC registers inside PIC group
`define OR1200_PIC_OFS_PICMR 2'd0
`define OR1200_PIC_OFS_PICSR 2'd2

// Position of offset bits inside SPR address
`define OR1200_PICOFS_BITS 1:0

// Define if you want these PIC registers to be implemented
`define OR1200_PIC_PICMR
`define OR1200_PIC_PICSR

// Define if reading PIC registers is allowed
`define OR1200_PIC_READREGS

// Define if unused PIC register bits should be zero
`define OR1200_PIC_UNUSED_ZERO


/////////////////////////////////////////////////////
//
// Tick Timer (TT)
//

// Define it if you want TT implemented
`define OR1200_TT_IMPLEMENTED

// Address offsets of TT registers inside TT group
`define OR1200_TT_OFS_TTMR 1'd0
`define OR1200_TT_OFS_TTCR 1'd1

// Position of offset bits inside SPR group
`define OR1200_TTOFS_BITS 0

// Define if you want these TT registers to be implemented
`define OR1200_TT_TTMR
`define OR1200_TT_TTCR

// TTMR bits
`define OR1200_TT_TTMR_TP 27:0
`define OR1200_TT_TTMR_IP 28
`define OR1200_TT_TTMR_IE 29
`define OR1200_TT_TTMR_M 31:30

// Define if reading TT registers is allowed
`define OR1200_TT_READREGS


//////////////////////////////////////////////
//
// MAC
//
`define OR1200_MAC_ADDR		0	// MACLO 0xxxxxxxx1, MACHI 0xxxxxxxx0
`define OR1200_MAC_SPR_WE		// Define if MACLO/MACHI are SPR writable

//
// Shift {MACHI,MACLO} into destination register when executing l.macrc
//
// According to architecture manual there is no shift, so default value is 0.
//
// However the implementation has deviated in this from the arch manual and had hard coded shift by 28 bits which
// is a useful optimization for MP3 decoding (if using libmad fixed point library). Shifts are no longer
// default setup, but if you need to remain backward compatible, define your shift bits, which were normally
// dest_GPR = {MACHI,MACLO}[59:28]
`define OR1200_MAC_SHIFTBY	0	// 0 = According to arch manual, 28 = obsolete backward compatibility


//////////////////////////////////////////////
//
// Data MMU (DMMU)
//

//
// Address that selects between TLB TR and MR
//
`define OR1200_DTLB_TM_ADDR	7

//
// DTLBMR fields
//
`define	OR1200_DTLBMR_V_BITS	0
`define	OR1200_DTLBMR_CID_BITS	4:1
`define	OR1200_DTLBMR_RES_BITS	11:5
`define OR1200_DTLBMR_VPN_BITS	31:13

//
// DTLBTR fields
//
`define	OR1200_DTLBTR_CC_BITS	0
`define	OR1200_DTLBTR_CI_BITS	1
`define	OR1200_DTLBTR_WBC_BITS	2
`define	OR1200_DTLBTR_WOM_BITS	3
`define	OR1200_DTLBTR_A_BITS	4
`define	OR1200_DTLBTR_D_BITS	5
`define	OR1200_DTLBTR_URE_BITS	6
`define	OR1200_DTLBTR_UWE_BITS	7
`define	OR1200_DTLBTR_SRE_BITS	8
`define	OR1200_DTLBTR_SWE_BITS	9
`define	OR1200_DTLBTR_RES_BITS	11:10
`define OR1200_DTLBTR_PPN_BITS	31:13

//
// DTLB configuration
//
`define	OR1200_DMMU_PS		13					// 13 for 8KB page size
`define	OR1200_DTLB_INDXW	6					// 6 for 64 entry DTLB	7 for 128 entries
`define OR1200_DTLB_INDXL	`OR1200_DMMU_PS				// 13			13
`define OR1200_DTLB_INDXH	`OR1200_DMMU_PS+`OR1200_DTLB_INDXW-1	// 18			19
`define	OR1200_DTLB_INDX	`OR1200_DTLB_INDXH:`OR1200_DTLB_INDXL	// 18:13		19:13
`define OR1200_DTLB_TAGW	32-`OR1200_DTLB_INDXW-`OR1200_DMMU_PS	// 13			12
`define OR1200_DTLB_TAGL	`OR1200_DTLB_INDXH+1			// 19			20
`define	OR1200_DTLB_TAG		31:`OR1200_DTLB_TAGL			// 31:19		31:20
`define	OR1200_DTLBMRW		`OR1200_DTLB_TAGW+1			// +1 because of V bit
`define	OR1200_DTLBTRW		32-`OR1200_DMMU_PS+5			// +5 because of protection bits and CI

//
// Cache inhibit while DMMU is not enabled/implemented
//
// cache inhibited 0GB-4GB		1'b1
// cache inhibited 0GB-2GB		!dcpu_adr_i[31]
// cache inhibited 0GB-1GB 2GB-3GB	!dcpu_adr_i[30]
// cache inhibited 1GB-2GB 3GB-4GB	dcpu_adr_i[30]
// cache inhibited 2GB-4GB (default)	dcpu_adr_i[31]
// cached 0GB-4GB			1'b0
//
`define OR1200_DMMU_CI			dcpu_adr_i[31]


//////////////////////////////////////////////
//
// Insn MMU (IMMU)
//

//
// Address that selects between TLB TR and MR
//
`define OR1200_ITLB_TM_ADDR	7

//
// ITLBMR fields
//
`define	OR1200_ITLBMR_V_BITS	0
`define	OR1200_ITLBMR_CID_BITS	4:1
`define	OR1200_ITLBMR_RES_BITS	11:5
`define OR1200_ITLBMR_VPN_BITS	31:13

//
// ITLBTR fields
//
`define	OR1200_ITLBTR_CC_BITS	0
`define	OR1200_ITLBTR_CI_BITS	1
`define	OR1200_ITLBTR_WBC_BITS	2
`define	OR1200_ITLBTR_WOM_BITS	3
`define	OR1200_ITLBTR_A_BITS	4
`define	OR1200_ITLBTR_D_BITS	5
`define	OR1200_ITLBTR_SXE_BITS	6
`define	OR1200_ITLBTR_UXE_BITS	7
`define	OR1200_ITLBTR_RES_BITS	11:8
`define OR1200_ITLBTR_PPN_BITS	31:13

//
// ITLB configuration
//
`define	OR1200_IMMU_PS		13					// 13 for 8KB page size
`define	OR1200_ITLB_INDXW	6					// 6 for 64 entry ITLB	7 for 128 entries
`define OR1200_ITLB_INDXL	`OR1200_IMMU_PS				// 13			13
`define OR1200_ITLB_INDXH	`OR1200_IMMU_PS+`OR1200_ITLB_INDXW-1	// 18			19
`define	OR1200_ITLB_INDX	`OR1200_ITLB_INDXH:`OR1200_ITLB_INDXL	// 18:13		19:13
`define OR1200_ITLB_TAGW	32-`OR1200_ITLB_INDXW-`OR1200_IMMU_PS	// 13			12
`define OR1200_ITLB_TAGL	`OR1200_ITLB_INDXH+1			// 19			20
`define	OR1200_ITLB_TAG		31:`OR1200_ITLB_TAGL			// 31:19		31:20
`define	OR1200_ITLBMRW		`OR1200_ITLB_TAGW+1			// +1 because of V bit
`define	OR1200_ITLBTRW		32-`OR1200_IMMU_PS+3			// +3 because of protection bits and CI

//
// Cache inhibit while IMMU is not enabled/implemented
// Note: all combinations that use icpu_adr_i cause async loop
//
// cache inhibited 0GB-4GB		1'b1
// cache inhibited 0GB-2GB		!icpu_adr_i[31]
// cache inhibited 0GB-1GB 2GB-3GB	!icpu_adr_i[30]
// cache inhibited 1GB-2GB 3GB-4GB	icpu_adr_i[30]
// cache inhibited 2GB-4GB (default)	icpu_adr_i[31]
// cached 0GB-4GB			1'b0
//
`define OR1200_IMMU_CI			1'b0


/////////////////////////////////////////////////
//
// Insn cache (IC)
//

// 3 for 8 bytes, 4 for 16 bytes etc
`define OR1200_ICLS		4

//
// IC configurations
//
`ifdef OR1200_IC_1W_512B
`define OR1200_ICSIZE   9     // 512
`define OR1200_ICINDX   `OR1200_ICSIZE-2 // 7
`define OR1200_ICINDXH  `OR1200_ICSIZE-1 // 8
`define OR1200_ICTAGL   `OR1200_ICINDXH+1 // 9
`define OR1200_ICTAG    `OR1200_ICSIZE-`OR1200_ICLS // 5
`define OR1200_ICTAG_W  24
`endif
`ifdef OR1200_IC_1W_4KB
`define OR1200_ICSIZE			12			// 4096
`define OR1200_ICINDX			`OR1200_ICSIZE-2	// 10
`define OR1200_ICINDXH			`OR1200_ICSIZE-1	// 11
`define OR1200_ICTAGL			`OR1200_ICINDXH+1	// 12
`define	OR1200_ICTAG			`OR1200_ICSIZE-`OR1200_ICLS	// 8
`define	OR1200_ICTAG_W			21
`endif
`ifdef OR1200_IC_1W_8KB
`define OR1200_ICSIZE			13			// 8192
`define OR1200_ICINDX			`OR1200_ICSIZE-2	// 11
`define OR1200_ICINDXH			`OR1200_ICSIZE-1	// 12
`define OR1200_ICTAGL			`OR1200_ICINDXH+1	// 13
`define	OR1200_ICTAG			`OR1200_ICSIZE-`OR1200_ICLS	// 9
`define	OR1200_ICTAG_W			20
`endif


/////////////////////////////////////////////////
//
// Data cache (DC)
//

// 3 for 8 bytes, 4 for 16 bytes etc
`define OR1200_DCLS		4

// Define to perform store refill (potential performance penalty)
// `define OR1200_DC_STORE_REFILL

//
// DC configurations
//
`ifdef OR1200_DC_1W_4KB
`define OR1200_DCSIZE			12			// 4096
`define OR1200_DCINDX			`OR1200_DCSIZE-2	// 10
`define OR1200_DCINDXH			`OR1200_DCSIZE-1	// 11
`define OR1200_DCTAGL			`OR1200_DCINDXH+1	// 12
`define	OR1200_DCTAG			`OR1200_DCSIZE-`OR1200_DCLS	// 8
`define	OR1200_DCTAG_W			21
`endif
`ifdef OR1200_DC_1W_8KB
`define OR1200_DCSIZE			13			// 8192
`define OR1200_DCINDX			`OR1200_DCSIZE-2	// 11
`define OR1200_DCINDXH			`OR1200_DCSIZE-1	// 12
`define OR1200_DCTAGL			`OR1200_DCINDXH+1	// 13
`define	OR1200_DCTAG			`OR1200_DCSIZE-`OR1200_DCLS	// 9
`define	OR1200_DCTAG_W			20
`endif

/////////////////////////////////////////////////
//
// Store buffer (SB)
//

//
// Store buffer
//
// It will improve performance by "caching" CPU stores
// using store buffer. This is most important for function
// prologues because DC can only work in write though mode
// and all stores would have to complete external WB writes
// to memory.
// Store buffer is between DC and data BIU.
// All stores will be stored into store buffer and immediately
// completed by the CPU, even though actual external writes
// will be performed later. As a consequence store buffer masks
// all data bus errors related to stores (data bus errors
// related to loads are delivered normally).
// All pending CPU loads will wait until store buffer is empty to
// ensure strict memory model. Right now this is necessary because
// we don't make destinction between cached and cache inhibited
// address space, so we simply empty store buffer until loads
// can begin.
//
// It makes design a bit bigger, depending what is the number of
// entries in SB FIFO. Number of entries can be changed further
// down.
//
//`define OR1200_SB_IMPLEMENTED

//
// Number of store buffer entries
//
// Verified number of entries are 4 and 8 entries
// (2 and 3 for OR1200_SB_LOG). OR1200_SB_ENTRIES must
// always match 2**OR1200_SB_LOG.
// To disable store buffer, undefine
// OR1200_SB_IMPLEMENTED.
//
`define OR1200_SB_LOG		2	// 2 or 3
`define OR1200_SB_ENTRIES	4	// 4 or 8


/////////////////////////////////////////////////
//
// Quick Embedded Memory (QMEM)
//

//
// Quick Embedded Memory
//
// Instantiation of dedicated insn/data memory (RAM or ROM).
// Insn fetch has effective throughput 1insn / clock cycle.
// Data load takes two clock cycles / access, data store
// takes 1 clock cycle / access (if there is no insn fetch)).
// Memory instantiation is shared between insn and data,
// meaning if insn fetch are performed, data load/store
// performance will be lower.
//
// Main reason for QMEM is to put some time critical functions
// into this memory and to have predictable and fast access
// to these functions. (soft fpu, context switch, exception
// handlers, stack, etc)
//
// It makes design a bit bigger and slower. QMEM sits behind
// IMMU/DMMU so all addresses are physical (so the MMUs can be
// used with QMEM and QMEM is seen by the CPU just like any other
// memory in the system). IC/DC are sitting behind QMEM so the
// whole design timing might be worse with QMEM implemented.
//
//`define OR1200_QMEM_IMPLEMENTED

//
// Base address and mask of QMEM
//
// Base address defines first address of QMEM. Mask defines
// QMEM range in address space. Actual size of QMEM is however
// determined with instantiated RAM/ROM. However bigger
// mask will reserve more address space for QMEM, but also
// make design faster, while more tight mask will take
// less address space but also make design slower. If
// instantiated RAM/ROM is smaller than space reserved with
// the mask, instatiated RAM/ROM will also be shadowed
// at higher addresses in reserved space.
//
`define OR1200_QMEM_IADDR	32'h0080_0000
`define OR1200_QMEM_IMASK	32'hfff0_0000	// Max QMEM size 1MB
`define OR1200_QMEM_DADDR  32'h0080_0000
`define OR1200_QMEM_DMASK  32'hfff0_0000 // Max QMEM size 1MB

//
// QMEM interface byte-select capability
//
// To enable qmem_sel* ports, define this macro.
//
//`define OR1200_QMEM_BSEL

//
// QMEM interface acknowledge
//
// To enable qmem_ack port, define this macro.
//
//`define OR1200_QMEM_ACK

/////////////////////////////////////////////////////
//
// VR, UPR and Configuration Registers
//
//
// VR, UPR and configuration registers are optional. If 
// implemented, operating system can automatically figure
// out how to use the processor because it knows 
// what units are available in the processor and how they
// are configured.
//
// This section must be last in or1200_defines.v file so
// that all units are already configured and thus
// configuration registers are properly set.
// 

// Define if you want configuration registers implemented
`define OR1200_CFGR_IMPLEMENTED

// Define if you want full address decode inside SYS group
`define OR1200_SYS_FULL_DECODE

// Offsets of VR, UPR and CFGR registers
`define OR1200_SPRGRP_SYS_VR		4'h0
`define OR1200_SPRGRP_SYS_UPR		4'h1
`define OR1200_SPRGRP_SYS_CPUCFGR	4'h2
`define OR1200_SPRGRP_SYS_DMMUCFGR	4'h3
`define OR1200_SPRGRP_SYS_IMMUCFGR	4'h4
`define OR1200_SPRGRP_SYS_DCCFGR	4'h5
`define OR1200_SPRGRP_SYS_ICCFGR	4'h6
`define OR1200_SPRGRP_SYS_DCFGR	4'h7

// VR fields
`define OR1200_VR_REV_BITS		5:0
`define OR1200_VR_RES1_BITS		15:6
`define OR1200_VR_CFG_BITS		23:16
`define OR1200_VR_VER_BITS		31:24

// VR values
`define OR1200_VR_REV			6'h01
`define OR1200_VR_RES1			10'h000
`define OR1200_VR_CFG			8'h00
`define OR1200_VR_VER			8'h12

// UPR fields
`define OR1200_UPR_UP_BITS		0
`define OR1200_UPR_DCP_BITS		1
`define OR1200_UPR_ICP_BITS		2
`define OR1200_UPR_DMP_BITS		3
`define OR1200_UPR_IMP_BITS		4
`define OR1200_UPR_MP_BITS		5
`define OR1200_UPR_DUP_BITS		6
`define OR1200_UPR_PCUP_BITS		7
`define OR1200_UPR_PMP_BITS		8
`define OR1200_UPR_PICP_BITS		9
`define OR1200_UPR_TTP_BITS		10
`define OR1200_UPR_RES1_BITS		23:11
`define OR1200_UPR_CUP_BITS		31:24

// UPR values
`define OR1200_UPR_UP			1'b1
`ifdef OR1200_NO_DC
`define OR1200_UPR_DCP			1'b0
`else
`define OR1200_UPR_DCP			1'b1
`endif
`ifdef OR1200_NO_IC
`define OR1200_UPR_ICP			1'b0
`else
`define OR1200_UPR_ICP			1'b1
`endif
`ifdef OR1200_NO_DMMU
`define OR1200_UPR_DMP			1'b0
`else
`define OR1200_UPR_DMP			1'b1
`endif
`ifdef OR1200_NO_IMMU
`define OR1200_UPR_IMP			1'b0
`else
`define OR1200_UPR_IMP			1'b1
`endif
`define OR1200_UPR_MP			1'b1	// MAC always present
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_DUP			1'b1
`else
`define OR1200_UPR_DUP			1'b0
`endif
`define OR1200_UPR_PCUP			1'b0	// Performance counters not present
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_PMP			1'b1
`else
`define OR1200_UPR_PMP			1'b0
`endif
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_PICP			1'b1
`else
`define OR1200_UPR_PICP			1'b0
`endif
`ifdef OR1200_DU_IMPLEMENTED
`define OR1200_UPR_TTP			1'b1
`else
`define OR1200_UPR_TTP			1'b0
`endif
`define OR1200_UPR_RES1			13'h0000
`define OR1200_UPR_CUP			8'h00

// CPUCFGR fields
`define OR1200_CPUCFGR_NSGF_BITS	3:0
`define OR1200_CPUCFGR_HGF_BITS	4
`define OR1200_CPUCFGR_OB32S_BITS	5
`define OR1200_CPUCFGR_OB64S_BITS	6
`define OR1200_CPUCFGR_OF32S_BITS	7
`define OR1200_CPUCFGR_OF64S_BITS	8
`define OR1200_CPUCFGR_OV64S_BITS	9
`define OR1200_CPUCFGR_RES1_BITS	31:10

// CPUCFGR values
`define OR1200_CPUCFGR_NSGF		4'h0
`define OR1200_CPUCFGR_HGF		1'b0
`define OR1200_CPUCFGR_OB32S		1'b1
`define OR1200_CPUCFGR_OB64S		1'b0
`define OR1200_CPUCFGR_OF32S		1'b0
`define OR1200_CPUCFGR_OF64S		1'b0
`define OR1200_CPUCFGR_OV64S		1'b0
`define OR1200_CPUCFGR_RES1		22'h000000

// DMMUCFGR fields
`define OR1200_DMMUCFGR_NTW_BITS	1:0
`define OR1200_DMMUCFGR_NTS_BITS	4:2
`define OR1200_DMMUCFGR_NAE_BITS	7:5
`define OR1200_DMMUCFGR_CRI_BITS	8
`define OR1200_DMMUCFGR_PRI_BITS	9
`define OR1200_DMMUCFGR_TEIRI_BITS	10
`define OR1200_DMMUCFGR_HTR_BITS	11
`define OR1200_DMMUCFGR_RES1_BITS	31:12

// DMMUCFGR values
`ifdef OR1200_NO_DMMU
`define OR1200_DMMUCFGR_NTW		2'h0	// Irrelevant
`define OR1200_DMMUCFGR_NTS		3'h0	// Irrelevant
`define OR1200_DMMUCFGR_NAE		3'h0	// Irrelevant
`define OR1200_DMMUCFGR_CRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_PRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_TEIRI		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_HTR		1'b0	// Irrelevant
`define OR1200_DMMUCFGR_RES1		20'h00000
`else
`define OR1200_DMMUCFGR_NTW		2'h0	// 1 TLB way
`define OR1200_DMMUCFGR_NTS 		3'h6 //3'h`OR1200_DTLB_INDXW	// Num TLB sets
`define OR1200_DMMUCFGR_NAE		3'h0	// No ATB entries
`define OR1200_DMMUCFGR_CRI		1'b0	// No control register
`define OR1200_DMMUCFGR_PRI		1'b0	// No protection reg
`define OR1200_DMMUCFGR_TEIRI		1'b1	// TLB entry inv reg impl.
`define OR1200_DMMUCFGR_HTR		1'b0	// No HW TLB reload
`define OR1200_DMMUCFGR_RES1		20'h00000
`endif

// IMMUCFGR fields
`define OR1200_IMMUCFGR_NTW_BITS	1:0
`define OR1200_IMMUCFGR_NTS_BITS	4:2
`define OR1200_IMMUCFGR_NAE_BITS	7:5
`define OR1200_IMMUCFGR_CRI_BITS	8
`define OR1200_IMMUCFGR_PRI_BITS	9
`define OR1200_IMMUCFGR_TEIRI_BITS	10
`define OR1200_IMMUCFGR_HTR_BITS	11
`define OR1200_IMMUCFGR_RES1_BITS	31:12

// IMMUCFGR values
`ifdef OR1200_NO_IMMU
`define OR1200_IMMUCFGR_NTW		2'h0	// Irrelevant
`define OR1200_IMMUCFGR_NTS		3'h0	// Irrelevant
`define OR1200_IMMUCFGR_NAE		3'h0	// Irrelevant
`define OR1200_IMMUCFGR_CRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_PRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_TEIRI		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_HTR		1'b0	// Irrelevant
`define OR1200_IMMUCFGR_RES1		20'h00000
`else
`define OR1200_IMMUCFGR_NTW		2'h0	// 1 TLB way
`define OR1200_IMMUCFGR_NTS 		3'h6 //3'h`OR1200_ITLB_INDXW	// Num TLB sets
`define OR1200_IMMUCFGR_NAE		3'h0	// No ATB entry
`define OR1200_IMMUCFGR_CRI		1'b0	// No control reg
`define OR1200_IMMUCFGR_PRI		1'b0	// No protection reg
`define OR1200_IMMUCFGR_TEIRI		1'b1	// TLB entry inv reg impl
`define OR1200_IMMUCFGR_HTR		1'b0	// No HW TLB reload
`define OR1200_IMMUCFGR_RES1		20'h00000
`endif

// DCCFGR fields
`define OR1200_DCCFGR_NCW_BITS		2:0
`define OR1200_DCCFGR_NCS_BITS		6:3
`define OR1200_DCCFGR_CBS_BITS		7
`define OR1200_DCCFGR_CWS_BITS		8
`define OR1200_DCCFGR_CCRI_BITS		9
`define OR1200_DCCFGR_CBIRI_BITS	10
`define OR1200_DCCFGR_CBPRI_BITS	11
`define OR1200_DCCFGR_CBLRI_BITS	12
`define OR1200_DCCFGR_CBFRI_BITS	13
`define OR1200_DCCFGR_CBWBRI_BITS	14
`define OR1200_DCCFGR_RES1_BITS	31:15

// DCCFGR values
`ifdef OR1200_NO_DC
`define OR1200_DCCFGR_NCW		3'h0	// Irrelevant
`define OR1200_DCCFGR_NCS		4'h0	// Irrelevant
`define OR1200_DCCFGR_CBS		1'b0	// Irrelevant
`define OR1200_DCCFGR_CWS		1'b0	// Irrelevant
`define OR1200_DCCFGR_CCRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBIRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBPRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_CBLRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_CBFRI		1'b1	// Irrelevant
`define OR1200_DCCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_DCCFGR_RES1		17'h00000
`else
`define OR1200_DCCFGR_NCW		3'h0	// 1 cache way
`define OR1200_DCCFGR_NCS (`OR1200_DCTAG)	// Num cache sets
`define OR1200_DCCFGR_CBS (`OR1200_DCLS-4)	// 16 byte cache block
`define OR1200_DCCFGR_CWS		1'b0	// Write-through strategy
`define OR1200_DCCFGR_CCRI		1'b1	// Cache control reg impl.
`define OR1200_DCCFGR_CBIRI		1'b1	// Cache block inv reg impl.
`define OR1200_DCCFGR_CBPRI		1'b0	// Cache block prefetch reg not impl.
`define OR1200_DCCFGR_CBLRI		1'b0	// Cache block lock reg not impl.
`define OR1200_DCCFGR_CBFRI		1'b1	// Cache block flush reg impl.
`define OR1200_DCCFGR_CBWBRI		1'b0	// Cache block WB reg not impl.
`define OR1200_DCCFGR_RES1		17'h00000
`endif

// ICCFGR fields
`define OR1200_ICCFGR_NCW_BITS		2:0
`define OR1200_ICCFGR_NCS_BITS		6:3
`define OR1200_ICCFGR_CBS_BITS		7
`define OR1200_ICCFGR_CWS_BITS		8
`define OR1200_ICCFGR_CCRI_BITS		9
`define OR1200_ICCFGR_CBIRI_BITS	10
`define OR1200_ICCFGR_CBPRI_BITS	11
`define OR1200_ICCFGR_CBLRI_BITS	12
`define OR1200_ICCFGR_CBFRI_BITS	13
`define OR1200_ICCFGR_CBWBRI_BITS	14
`define OR1200_ICCFGR_RES1_BITS	31:15

// ICCFGR values
`ifdef OR1200_NO_IC
`define OR1200_ICCFGR_NCW		3'h0	// Irrelevant
`define OR1200_ICCFGR_NCS 		4'h0	// Irrelevant
`define OR1200_ICCFGR_CBS 		1'b0	// Irrelevant
`define OR1200_ICCFGR_CWS		1'b0	// Irrelevant
`define OR1200_ICCFGR_CCRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBIRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBPRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBLRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBFRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_RES1		17'h00000
`else
`define OR1200_ICCFGR_NCW		3'h0	// 1 cache way
`define OR1200_ICCFGR_NCS (`OR1200_ICTAG)	// Num cache sets
`define OR1200_ICCFGR_CBS (`OR1200_ICLS-4)	// 16 byte cache block
`define OR1200_ICCFGR_CWS		1'b0	// Irrelevant
`define OR1200_ICCFGR_CCRI		1'b1	// Cache control reg impl.
`define OR1200_ICCFGR_CBIRI		1'b1	// Cache block inv reg impl.
`define OR1200_ICCFGR_CBPRI		1'b0	// Cache block prefetch reg not impl.
`define OR1200_ICCFGR_CBLRI		1'b0	// Cache block lock reg not impl.
`define OR1200_ICCFGR_CBFRI		1'b1	// Cache block flush reg impl.
`define OR1200_ICCFGR_CBWBRI		1'b0	// Irrelevant
`define OR1200_ICCFGR_RES1		17'h00000
`endif

// DCFGR fields
`define OR1200_DCFGR_NDP_BITS		2:0
`define OR1200_DCFGR_WPCI_BITS		3
`define OR1200_DCFGR_RES1_BITS		31:4

// DCFGR values
`ifdef OR1200_DU_HWBKPTS
`define OR1200_DCFGR_NDP	3'h`OR1200_DU_DVRDCR_PAIRS // # of DVR/DCR pairs
`ifdef OR1200_DU_DWCR0
`define OR1200_DCFGR_WPCI		1'b1
`else
`define OR1200_DCFGR_WPCI		1'b0	// WP counters not impl.
`endif
`else
`define OR1200_DCFGR_NDP		3'h0	// Zero DVR/DCR pairs
`define OR1200_DCFGR_WPCI		1'b0	// WP counters not impl.
`endif
`define OR1200_DCFGR_RES1		28'h0000000
 

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSG16.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//=============================================================================
//	(C) 2007,2010,2012  Robert Finch
//	robfinch<remove>@opencores.org
//
//	PSG16.v 
//		4 Channel ADSR sound generator
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//	Registers
//	0	    ffffffff ffffffff	freq [15:0]
//	1	    ----pppp pppppppp	pulse width [11:0]
//	2	    trsg--fo -vvvvv-- 	test, ringmod, sync, gate, filter, output, voice type
//											vvvvv
//											wnpst
//	3	    ssssrrrr aaaadddd  	sustain,release,attack,decay
//
//	...
//	64      -------- ----vvvv   volume (0-15)
//	65      nnnnnnnn nnnnnnnn   osc3 oscillator 3
//	66      -------- nnnnnnnn   env3 envelope 3
//	67
//	68      aa------ --------   wave table address a15-14
//	69      aaaaaaaa aaaaaaaa   wave table address a31-16
//
//  80-87   s---kkkk kkkkkkkk   filter coefficients
//  88-96   -------- --------   reserved for more filter coefficients
//
//
//	Spartan3
//	Webpack 12.3  xc3s1200e-4fg320
//	1290 LUTs / 893 slices / 69.339 MHz
//	1 Multipliers
//=============================================================================

module PSG16(rst_i, clk_i, cyc_i, stb_i, ack_o, we_i, sel_i, adr_i, dat_i, dat_o,
	vol_o, bg, 
	m_cyc_o, m_stb_o, m_ack_i, m_we_o, m_sel_o, m_adr_o, m_dat_i, o
);
parameter pClkDivide = 66;

// WISHBONE SYSCON
input rst_i;
input clk_i;			// system clock
// WISHBONE SLAVE
input cyc_i;			// cycle valid
input stb_i;			// circuit select
output ack_o;
input we_i;				// write
input  [1:0] sel_i;		// byte selects
input [63:0] adr_i;		// address input
input [15:0] dat_i;		// data input
output [15:0] dat_o;	// data output
// WISHBONE MASTER
output m_cyc_o;			// bus request
output m_stb_o;			// strobe output
input m_ack_i;
output m_we_o;			// write enable (always inactive)
output [ 1:0] m_sel_o;	// byte lane selects
output [63:0] m_adr_o;	// wave table address
input  [11:0] m_dat_i;	// wave table data input

output vol_o;

input bg;				// bus grant

output [17:0] o;

// I/O registers
reg [15:0] dat_o;
reg vol_o;
reg [43:0] m_adr_o;

reg [3:0] test;				// test (enable note generator)
reg [4:0] vt [3:0];			// voice type
reg [15:0] freq0, freq1, freq2, freq3;	// frequency control
reg [11:0] pw0, pw1, pw2, pw3;			// pulse width control
reg [3:0] gate;
reg [3:0] attack0, attack1, attack2, attack3;
reg [3:0] decay0, decay1, decay2, decay3;
reg [3:0] sustain0, sustain1, sustain2, sustain3;
reg [3:0] relese0, relese1, relese2, relese3;
reg [3:0] sync;
reg [3:0] ringmod;
reg [3:0] outctrl;
reg [3:0] filt;                // 1 = output goes to filter
wire [23:0] acc0, acc1, acc2, acc3;
reg [3:0] volume;	// master volume
wire [11:0] ngo;	// not generator output
wire [7:0] env;		// envelope generator output
wire [7:0] env3;
wire [7:0] ibr;
wire [7:0] ibg;
wire [21:0] out1;
reg [21:0] out1a;
wire [19:0] out2;
wire [21:0] out3;
wire [19:0] out4;
wire [21:0] filtin1;	// FIR filter input
wire [14:0] filt_o;		// FIR filter output

wire cs = cyc_i && stb_i && (adr_i[63:8]==56'hFFFF_FFFF_FFD5_00);
assign m_cyc_o = |ibg & !m_ack_i;
assign m_stb_o = m_cyc_o;
assign m_we_o  = 1'b0;
assign m_sel_o = {m_cyc_o,m_cyc_o};
reg ack1;
always @(posedge clk_i)
	ack1 <= cs & !ack1;
assign ack_o = cs ? (we_i ? 1'b1 : ack1) : 1'b0;
wire my_ack = m_ack_i;

// write to registers
always @(posedge clk_i)
begin
	if (rst_i) begin
		freq0 <= 0;
		freq1 <= 0;
		freq2 <= 0;
		freq3 <= 0;
		pw0 <= 0;
		pw1 <= 0;
		pw2 <= 0;
		pw3 <= 0;
		test <= 0;
		vt[0] <= 0;
		vt[1] <= 0;
		vt[2] <= 0;
		vt[3] <= 0;
		gate <= 0;
		outctrl <= 0;
		filt <= 0;
		attack0 <= 0;
		attack1 <= 0;
		attack2 <= 0;
		attack3 <= 0;
		decay0 <= 0;
		sustain0 <= 0;
		relese0 <= 0;
		decay1 <= 0;
		sustain1 <= 0;
		relese1 <= 0;
		decay2 <= 0;
		sustain2 <= 0;
		relese2 <= 0;
		decay3 <= 0;
		sustain3 <= 0;
		relese3 <= 0;
		sync <= 0;
		ringmod <= 0;
		volume <= 0;
		m_adr_o[47:14] <= 34'b00000000_00000000_0000_0000_0000_0011_10;	// 00038000
	end
	else begin
		if (cs & we_i) begin
			case(adr_i[7:1])
			//---------------------------------------------------------
			7'd0:
					begin
						if (sel_i[0]) freq0[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) freq0[15:8] <= dat_i[15:8];
					end
			7'd1:
					begin 
						if (sel_i[0]) pw0[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) pw0[11:8] <= dat_i[11:8];
					end
			7'd2:	begin
						if (sel_i[0]) vt[0] <= dat_i[6:2];
						if (sel_i[1]) begin
							outctrl[0] <= dat_i[8];
							filt[0] <= dat_i[9];
							gate[0] <= dat_i[12];
							sync[0] <= dat_i[13];
							ringmod[0] <= dat_i[14]; 
							test[0] <= dat_i[15];
						end
					end
			7'd3:	begin
					if (sel_i[0]) attack0 <= dat_i[7:4];
					if (sel_i[0]) decay0 <= dat_i[3:0];
					if (sel_i[1]) relese0 <= dat_i[11:8];
					if (sel_i[1]) sustain0 <= dat_i[15:12];
					end

			//---------------------------------------------------------
			7'd4:
					begin
						if (sel_i[0]) freq1[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) freq1[15:8] <= dat_i[15:8];
					end
			7'd5:
					begin
						if (sel_i[0]) pw1[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) pw1[11:8] <= dat_i[11:8];
					end
			7'd6:	begin
						if (sel_i[0]) vt[1] <= dat_i[6:2];
						if (sel_i[1]) begin
							outctrl[1] <= dat_i[8];
							filt[1] <= dat_i[9];
							gate[1] <= dat_i[12];
							sync[1] <= dat_i[13];
							ringmod[1] <= dat_i[14]; 
							test[1] <= dat_i[15];
						end
					end
			7'd7:	begin
					if (sel_i[0]) attack1 <= dat_i[7:4];
					if (sel_i[0]) decay1 <= dat_i[3:0];
					if (sel_i[1]) relese1 <= dat_i[11:8];
					if (sel_i[1]) sustain1 <= dat_i[15:12];
					end

			//---------------------------------------------------------
			7'd8:
					begin
						if (sel_i[0]) freq2[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) freq2[15:8] <= dat_i[15:8];
					end
			7'd9:
					begin
						if (sel_i[0]) pw2[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) pw2[11:8] <= dat_i[11:8];
					end
			7'd10:	begin
						if (sel_i[0]) vt[2] <= dat_i[6:2];
						if (sel_i[1]) begin
							outctrl[2] <= dat_i[8];
							filt[2] <= dat_i[9];
							gate[2] <= dat_i[12];
							sync[2] <= dat_i[5];
							outctrl[0] <= dat_i[13];
							ringmod[2] <= dat_i[14]; 
							test[2] <= dat_i[15];
						end
					end
			7'd11:	begin
					if (sel_i[0]) attack2 <= dat_i[7:4];
					if (sel_i[0]) decay2 <= dat_i[3:0];
					if (sel_i[1]) relese2 <= dat_i[11:8];
					if (sel_i[1]) sustain2 <= dat_i[15:12];
					end

			//---------------------------------------------------------
			7'd12:
					begin
						if (sel_i[0]) freq3[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) freq3[15:8] <= dat_i[15:8];
					end
			7'd13:
					begin
						if (sel_i[0]) pw3[ 7:0] <= dat_i[ 7:0];
						if (sel_i[1]) pw3[11:8] <= dat_i[11:8];
					end
			7'd14:	begin
						if (sel_i[0]) vt[3] <= dat_i[6:2];
						if (sel_i[1]) begin
							outctrl[3] <= dat_i[8];
							filt[3] <= dat_i[9];
							gate[3] <= dat_i[12];
							sync[3] <= dat_i[13];
							ringmod[3] <= dat_i[14]; 
							test[3] <= dat_i[15];
						end
					end
			7'd15:	begin
					if (sel_i[0]) attack3 <= dat_i[7:4];
					if (sel_i[0]) decay3 <= dat_i[3:0];
					if (sel_i[1]) relese3 <= dat_i[11:8];
					if (sel_i[1]) sustain3 <= dat_i[15:12];
					end

			//---------------------------------------------------------
			7'd64:	if (sel_i[0]) volume <= dat_i[3:0];

			7'd68:	begin
						if (sel_i[1]) m_adr_o[15:14] <= dat_i[15:14];
					end
			7'd69:
					begin
						if (sel_i[0]) m_adr_o[23:16] <= dat_i[ 7:0];
						if (sel_i[1]) m_adr_o[31:24] <= dat_i[15:8];
					end
			7'd70:	begin
						if (sel_i[0]) m_adr_o[39:32] <= dat_i[ 7:0];
						if (sel_i[1]) m_adr_o[47:40] <= dat_i[15:8];
					end
			default:	;
			endcase
		end
	end
end


always @(posedge clk_i)
	if (cs) begin
		case(adr_i[6:0])
		7'd65:	begin
				vol_o <= 1'b1;
				dat_o <= acc3[23:8];
				end
		7'd66:	begin
				vol_o <= 1'b1;
				dat_o <= env3;
				end
		default: begin
				dat_o <= env3;
				vol_o <= 1'b0;
				end
		endcase
	end
	else begin
		dat_o <= 16'b0;
		vol_o <= 1'b0;
	end

wire [11:0] alow;

// set wave table output address
always @(ibg or acc1 or acc0 or acc2 or acc3 or alow)
begin
	m_adr_o[13:12] <= {ibg[2]|ibg[3],ibg[1]|ibg[3]};
	m_adr_o[11:0] <= alow;
end

mux4to1 #(12) u11
(
	.e(1'b1),
	.s(m_adr_o[13:12]),
	.i0({acc0[23:13],1'b0}),
	.i1({acc1[23:13],1'b0}),
	.i2({acc2[23:13],1'b0}),
	.i3({acc3[23:13],1'b0}),
	.z(alow)
);

// This counter controls channel multiplexing and the base
// operating frequency.
wire [7:0] cnt;
reg [7:0] cnt1,cnt2,cnt3;
counter #(8) u1
(
	.rst(rst_i),
	.clk(clk_i),
	.ce(1'b1),
	.ld(cnt==pClkDivide-1),
	.d(8'd0),
	.q(cnt)
);

// channel select signal
wire [1:0] sel = cnt[1:0];


// bus arbitrator for wave table access
wire [2:0] bgn;
PSGBusArb u2
(
	.rst(rst_i),
	.clk(clk_i),
	.ce(1'b1),
	.ack(1'b1),
	.seln(bgn),
	.req0(ibr[0]),
	.req1(ibr[1]),
	.req2(ibr[2]),
	.req3(ibr[3]),
	.req4(1'b0),
	.req5(1'b0),
	.req6(1'b0),
	.req7(1'b0),
	.sel0(ibg[0]),
	.sel1(ibg[1]),
	.sel2(ibg[2]),
	.sel3(ibg[3]),
	.sel4(),
	.sel5(),
	.sel6(),
	.sel7()
);

// note generator - multi-channel
PSGNoteGen u3
(
	.rst(rst_i),
	.clk(clk_i),
	.cnt(cnt),
	.br(ibr),
	.bg(ibg),
	.ack(m_ack_i),
	.bgn(bgn),
	.test(test),
	.vt0(vt[0]),
	.vt1(vt[1]),
	.vt2(vt[2]),
	.vt3(vt[3]), 
	.freq0(freq0),
	.freq1(freq1),
	.freq2(freq2),
	.freq3(freq3),
	.pw0(pw0),
	.pw1(pw1),
	.pw2(pw2),
	.pw3(pw3),
	.acc0(acc0),
	.acc1(acc1),
	.acc2(acc2),
	.acc3(acc3),
	.wave(m_dat_i),
	.sync(sync),
	.ringmod(ringmod),
	.o(ngo)
);

// envelope generator - multi-channel
PSGEnvGen u4
(
	.rst(rst_i),
	.clk(clk_i),
	.cnt(cnt),
	.gate(gate),
	.attack0(attack0),
	.attack1(attack1),
	.attack2(attack2),
	.attack3(attack3),
	.decay0(decay0),
	.decay1(decay1),
	.decay2(decay2),
	.decay3(decay3),
	.sustain0(sustain0),
	.sustain1(sustain1),
	.sustain2(sustain2),
	.sustain3(sustain3),
	.relese0(relese0),
	.relese1(relese1),
	.relese2(relese2),
	.relese3(relese3),
	.o(env)
);

// shape output according to envelope
PSGShaper u5
(
	.clk_i(clk_i),
	.ce(1'b1),
	.tgi(ngo),
	.env(env),
	.o(out2)
);

always @(posedge clk_i)
	cnt1 <= cnt;
always @(posedge clk_i)
	cnt2 <= cnt1;
always @(posedge clk_i)
	cnt3 <= cnt2;

// Sum the channels not going to the filter
PSGChannelSummer u6
(
	.clk_i(clk_i),
	.cnt(cnt1),
	.outctrl(outctrl),
	.tmc_i(out2),
	.o(out1)
);

always @(posedge clk_i)
	out1a <= out1;

// Sum the channels going to the filter
PSGChannelSummer u7
(
	.clk_i(clk_i),
	.cnt(cnt1),
	.outctrl(filt),
	.tmc_i(out2),
	.o(filtin1)
);

// The FIR filter
PSGFilter u8
(
	.rst(rst_i),
	.clk(clk_i),
	.cnt(cnt2),
	.wr(we_i && stb_i && adr_i[6:4]==3'b101),
    .adr(adr_i[3:0]),
    .din({dat_i[15],dat_i[11:0]}),
    .i(filtin1[21:7]),
    .o(filt_o)
);

// Sum the filtered and unfiltered output
PSGOutputSummer u9
(
	.clk_i(clk_i),
	.cnt(cnt3),
	.ufi(out1a),
	.fi({filt_o,7'b0}),
	.o(out3)
);

// Last stage:
// Adjust output according to master volume
PSGMasterVolumeControl u10
(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.i(out3[21:6]),
	.volume(volume),
	.o(out4)
);

assign o = out4[19:2];

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGBusArb.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//=============================================================================
//	(C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGBusArb.v
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//		Arbitrates access to the system bus among up to eight
//	wave table channels for the PSG. This arbitrator is part
//	of a tree that ends up looking like a single arbitration
//	request to the system.
//
//	Spartan3
//	19 LUTs / 11 slices
//=============================================================================

module PSGBusArb(rst, clk, ce, ack,
	req0, req1, req2, req3, req4, req5, req6, req7,
	sel0, sel1, sel2, sel3, sel4, sel5, sel6, sel7, seln);
input rst;		// reset
input clk;		// clock (eg 100MHz)
input ce;		// clock enable (eg 25MHz)
input ack;		// bus transfer completed
input req0;		// requester 0 wants the bus
input req1;		// requester 1 wants the bus
input req2;		// ...
input req3;
input req4;
input req5;
input req6;
input req7;
output sel0;	// requester 0 granted the bus
reg sel0;
output sel1;
reg sel1;
output sel2;
reg sel2;
output sel3;
reg sel3;
output sel4;
reg sel4;
output sel5;
reg sel5;
output sel6;
reg sel6;
output sel7;
reg sel7;
output [2:0] seln;	// who has the bus
reg [2:0] seln;

always @(posedge clk) begin
	if (rst) begin
		sel0 <= 1'b0;
		sel1 <= 1'b0;
		sel2 <= 1'b0;
		sel3 <= 1'b0;
		sel4 <= 1'b0;
		sel5 <= 1'b0;
		sel6 <= 1'b0;
		sel7 <= 1'b0;
		seln <= 3'd0;
	end
	else begin
		if (ce&ack) begin
			if (req0) begin
				sel0 <= 1'b1;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd0;
			end
			else if (req1) begin
				sel1 <= 1'b1;
				sel0 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd1;
			end
			else if (req2) begin
				sel2 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd2;
			end
			else if (req3) begin
				sel3 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd3;
			end
			else if (req4) begin
				sel4 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd4;
			end
			else if (req5) begin
				sel5 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd5;
			end
			else if (req6) begin
				sel6 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd6;
			end
			else if (req7) begin
				sel7 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				seln <= 3'd7;
			end
			// otherwise, hold onto last owner
			else begin
				sel0 <= sel0;
				sel1 <= sel1;
				sel2 <= sel2;
				sel3 <= sel3;
				sel4 <= sel4;
				sel5 <= sel5;
				sel6 <= sel6;
				sel7 <= sel7;
				seln <= seln;
			end
		end
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGChannelSummer.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	PSGChannelSummer.v 
//		Sums the channel outputs.
//
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//============================================================================

module PSGChannelSummer(clk_i, cnt, outctrl, tmc_i, o);
input clk_i;			// master clock
input [7:0] cnt;		// select counter
input [3:0] outctrl;	// channel output enable control
input [19:0] tmc_i;		// time-multiplexed channel input
output [21:0] o;		// summed output
reg [21:0] o;

// channel select signal
wire [1:0] sel = cnt[1:0];

always @(posedge clk_i)
	if (cnt==8'd0)
		o <= 22'd0 + (tmc_i & {20{outctrl[sel]}});
	else if (cnt < 8'd4)
		o <= o + (tmc_i & {20{outctrl[sel]}});

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGEnvGen.v
// -----------------------------------------------------------------------------
/* ============================================================================
    (C) 2007  Robert Finch
	All rights reserved.

	PSGEnvGen.v
	Version 1.1

	ADSR envelope generator.

    This source code is available for evaluation and validation purposes
    only. This copyright statement and disclaimer must remain present in
    the file.


	NO WARRANTY.
    THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
    EXPRESS OR IMPLIED. The user must assume the entire risk of using the
    Work.

    IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
    INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
    THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.

    IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
    IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
    REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
    LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
    AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
    LOSSES RELATING TO SUCH UNAUTHORIZED USE.


    Note that this envelope generator directly uses the values for attack,
    decay, sustain, and release. The original SID had to use four bit codes
    and lookup tables due to register limitations. This generator is
	built assuming there aren't any such register limitations.
	A wrapper could be built to provide that functionality.
	
    This component isn't really meant to be used in isolation. It is
    intended to be integrated into a larger audio component (eg SID
    emulator). The host component should take care of wrapping the control
    signals into a register array.

    The 'cnt' signal acts a prescaler used to determine the base frequency
    used to generate envelopes. The core expects to be driven at
    approximately a 1.0MHz rate for proper envelope generation. This is
    accomplished using the 'cnt' signal, which should the output of a
    counter used to divide the master clock frequency down to approximately
    a 1MHz rate. Therefore, the master clock frequency must be at least 4MHz
    for a 4 channel generator, 8MHZ for an 8 channel generator. The test
    system uses a 66.667MHz master clock and 'cnt' is the output of a seven
    bit counter that divides by 66.

    Note the resource space optimization. Rather than simply build a single
    channel ADSR envelope generator and instantiate it four or eight times,
    This unit uses a single envelope generator and time-multiplexes the
    controls from four (or eight) different channels. The ADSR is just
	complex enough that it's less expensive resource wise to multiplex the
	control signals. The luxury of time division multiplexing can be used
	here since audio signals are low frequency. The time division multiplex
	means that we need a clock that's four (or eight) times faster than
	would be needed if independent ADSR's were used. This probably isn't a
	problem for most cases.

	Spartan3
	Webpack 9.1i xc3s1000-4ft256
	522 LUTs / 271 slices / 81.155 MHz (speed)
============================================================================ */

/*
	sample attack values / rates
	----------------------------
	8		2ms
	32		8ms
	64		16ms
	96		24ms
	152		38ms
	224		56ms
	272		68ms
	320		80ms
	400		100ms
	955		239ms
	1998	500ms
	3196	800ms
	3995	1s
	12784	3.2s
	21174	5.3s
	31960	8s

	rate = 990.00ns x 256 x value
*/


// envelope generator states
`define ENV_IDLE	0
`define ENV_ATTACK	1
`define ENV_DECAY	2
`define ENV_SUSTAIN	3
`define ENV_RELEASE	4

// Envelope generator
module PSGEnvGen(rst, clk, cnt,
	gate,
	attack0, attack1, attack2, attack3,
	decay0, decay1, decay2, decay3,
	sustain0, sustain1, sustain2, sustain3,
	relese0, relese1, relese2, relese3,
	o);
	parameter pChannels = 4;
	parameter pPrescalerBits = 8;
	input rst;							// reset
	input clk;							// core clock
	input [pPrescalerBits-1:0] cnt;		// clock rate prescaler
	input [15:0] attack0;
	input [15:0] attack1;
	input [15:0] attack2;
	input [15:0] attack3;
	input [11:0] decay0;
	input [11:0] decay1;
	input [11:0] decay2;
	input [11:0] decay3;
	input [7:0] sustain0;
	input [7:0] sustain1;
	input [7:0] sustain2;
	input [7:0] sustain3;
	input [11:0] relese0;
	input [11:0] relese1;
	input [11:0] relese2;
	input [11:0] relese3;
	input [3:0] gate;
	output [7:0] o;

	reg [7:0] sustain;
	reg [15:0] attack;
	reg [17:0] decay;
	reg [17:0] relese;
	// Per channel count storage
	reg [7:0] envCtr [3:0];
	reg [7:0] envCtr2 [3:0];
	reg [7:0] iv [3:0];			// interval value for decay/release
	reg [2:0] icnt [3:0];		// interval count
	reg [19:0] envDvn [3:0];
	reg [2:0] envState [3:0];

	reg [2:0] envStateNxt;
	reg [15:0] envStepPeriod;	// determines the length of one step of the envelope generator
	reg [7:0] envCtrx;
	reg [19:0] envDvnx;

	// Time multiplexed values
	wire [15:0] attack_x;
	wire [11:0] decay_x;
	wire [7:0] sustain_x;
	wire [11:0] relese_x;

	integer n;

    wire [1:0] sel = cnt[1:0];

	mux4to1 #(16) u1 (
		.e(1'b1),
		.s(sel),
		.i0(attack0),
		.i1(attack1),
		.i2(attack2),
		.i3(attack3),
		.z(attack_x)
	);

	mux4to1 #(12) u2 (
		.e(1'b1),
		.s(sel),
		.i0(decay0),
		.i1(decay1),
		.i2(decay2),
		.i3(decay3),
		.z(decay_x)
	);

	mux4to1 #(8) u3 (
		.e(1'b1),
		.s(sel),
		.i0(sustain0),
		.i1(sustain1),
		.i2(sustain2),
		.i3(sustain3),
		.z(sustain_x)
	);

	mux4to1 #(12) u4 (
		.e(1'b1),
		.s(sel),
		.i0(relese0),
		.i1(relese1),
		.i2(relese2),
		.i3(relese3),
		.z(relese_x)
	);

	always @(attack_x)
		attack <= attack_x;

	always @(decay_x)
		decay <= decay_x;

	always @(sustain_x)
		sustain <= sustain_x;

	always @(relese_x)
		relese <= relese_x;


	always @(sel)
		envCtrx <= envCtr[sel];

	always @(sel)
		envDvnx <= envDvn[sel];


	// Envelope generate state machine
	// Determine the next envelope state
	always @(sel or gate or sustain)
	begin
		case (envState[sel])
		`ENV_IDLE:
			if (gate[sel])
				envStateNxt <= `ENV_ATTACK;
			else
				envStateNxt <= `ENV_IDLE;
		`ENV_ATTACK:
			if (envCtrx==8'hFE) begin
				if (sustain==8'hFF)
					envStateNxt <= `ENV_SUSTAIN;
				else
					envStateNxt <= `ENV_DECAY;
			end
			else
				envStateNxt <= `ENV_ATTACK;
		`ENV_DECAY:
			if (envCtrx==sustain)
				envStateNxt <= `ENV_SUSTAIN;
			else
				envStateNxt <= `ENV_DECAY;
		`ENV_SUSTAIN:
			if (~gate[sel])
				envStateNxt <= `ENV_RELEASE;
			else
				envStateNxt <= `ENV_SUSTAIN;
		`ENV_RELEASE: begin
			if (envCtrx==8'h00)
				envStateNxt <= `ENV_IDLE;
			else if (gate[sel])
				envStateNxt <= `ENV_SUSTAIN;
			else
				envStateNxt <= `ENV_RELEASE;
			end
		// In case of hardware problem
		default:
			envStateNxt <= `ENV_IDLE;
		endcase
	end

	always @(posedge clk)
		if (rst) begin
		    for (n = 0; n < pChannels; n = n + 1)
		        envState[n] <= `ENV_IDLE;
		end
		else if (cnt < pChannels)
			envState[sel] <= envStateNxt;


	// Handle envelope counter
	always @(posedge clk)
		if (rst) begin
		    for (n = 0; n < pChannels; n = n + 1) begin
		        envCtr[n] <= 0;
		        envCtr2[n] <= 0;
		        icnt[n] <= 0;
		        iv[n] <= 0;
		    end
		end
		else if (cnt < pChannels) begin
			case (envState[sel])
			`ENV_IDLE:
				begin
				envCtr[sel] <= 0;
				envCtr2[sel] <= 0;
				icnt[sel] <= 0;
				iv[sel] <= 0;
				end
			`ENV_SUSTAIN:
				begin
				envCtr2[sel] <= 0;
				icnt[sel] <= 0;
				iv[sel] <= sustain >> 3;
				end
			`ENV_ATTACK:
				begin
				icnt[sel] <= 0;
				iv[sel] <= (8'hff - sustain) >> 3;
				if (envDvnx==20'h0) begin
					envCtr2[sel] <= 0;
					envCtr[sel] <= envCtrx + 1;
				end
				end
			`ENV_DECAY,
			`ENV_RELEASE:
				if (envDvnx==20'h0) begin
					envCtr[sel] <= envCtrx - 1;
					if (envCtr2[sel]==iv[sel]) begin
						envCtr2[sel] <= 0;
						if (icnt[sel] < 3'd7)
							icnt[sel] <= icnt[sel] + 1;
					end
					else
						envCtr2[sel] <= envCtr2[sel] + 1;
				end
			endcase
		end

	// Determine envelope divider adjustment source
	always @(sel or attack or decay or relese)
	begin
		case(envState[sel])
		`ENV_ATTACK:	envStepPeriod <= attack;
		`ENV_DECAY:		envStepPeriod <= decay;
		`ENV_RELEASE:	envStepPeriod <= relese;
		default:		envStepPeriod <= 16'h0;
		endcase
	end


	// double the delay at appropriate points
	// for exponential modelling
	wire [19:0] envStepPeriod1 = {4'b0,envStepPeriod} << icnt[sel];


	// handle the clock divider
	// loadable down counter
	// This sets the period of each step of the envelope
	always @(posedge clk)
		if (rst) begin
			for (n = 0; n < pChannels; n = n + 1)
				envDvn[n] <= 0;
		end
		else if (cnt < pChannels) begin
			if (envDvnx==20'h0)
				envDvn[sel] <= envStepPeriod1;
			else
				envDvn[sel] <= envDvnx - 1;
		end

	assign o = envCtrx;

endmodule



// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGEnvGenDec.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//  (C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGEnvGen.v
//	Version 1.1
//
//	ADSR envelope generator.
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//    This component isn't really meant to be used in isolation. It is
//    intended to be integrated into a larger audio component (eg SID
//    emulator). The host component should take care of wrapping the control
//    signals into a register array.
//
//    The 'cnt' signal acts a prescaler used to determine the base frequency
//    used to generate envelopes. The core expects to be driven at
//    approximately a 1.0MHz rate for proper envelope generation. This is
//    accomplished using the 'cnt' signal, which should the output of a
//    counter used to divide the master clock frequency down to approximately
//    a 1MHz rate. Therefore, the master clock frequency must be at least 4MHz
//    for a 4 channel generator, 8MHZ for an 8 channel generator. The test
//    system uses a 66.667MHz master clock and 'cnt' is the output of a seven
//    bit counter that divides by 66.
//
//    Note the resource space optimization. Rather than simply build a single
//    channel ADSR envelope generator and instantiate it four or eight times,
//    This unit uses a single envelope generator and time-multiplexes the
//    controls from four (or eight) different channels. The ADSR is just
//	complex enough that it's less expensive resource wise to multiplex the
//	control signals. The luxury of time division multiplexing can be used
//	here since audio signals are low frequency. The time division multiplex
//	means that we need a clock that's four (or eight) times faster than
//	would be needed if independent ADSR's were used. This probably isn't a
//	problem for most cases.
//
//	Spartan3
//	Webpack 9.1i xc3s1000-4ft256
//	522 LUTs / 271 slices / 81.155 MHz (speed)
//============================================================================ */

/*
	code sample attack values / rates
	---------------------------------
	0   8		2ms
	1	32		8ms
	2	64		16ms
	3	96		24ms
	4	152		38ms
	5	224		56ms
	6	272		68ms
	7	320		80ms
	8	400		100ms
	9	955		239ms
	10	1998	500ms
	11	3196	800ms
	12	3995	1s
	13	12784	3.2s
	14	21174	5.3s
	15	31960	8s

	rate = 990.00ns x 256 x value
*/


// envelope generator states
`define ENV_IDLE	0
`define ENV_ATTACK	1
`define ENV_DECAY	2
`define ENV_SUSTAIN	3
`define ENV_RELEASE	4

//`define CHANNELS8

// Envelope generator
module PSGEnvGen(rst, clk, cnt,
	gate,
	attack0, attack1, attack2, attack3,
	decay0, decay1, decay2, decay3,
	sustain0, sustain1, sustain2, sustain3,
	relese0, relese1, relese2, relese3,
`ifdef CHANNELS8
	attack4, attack5, attack6, attack7,
	decay4, decay5, decay6, decay7,
	sustain4, sustain5, sustain6, sustain7,
	relese4, relese5, relese6, relese7,
`endif
	o);
	parameter pChannels = 4;
	parameter pPrescalerBits = 5;
	input rst;							// reset
	input clk;							// core clock
	input [pPrescalerBits-1:0] cnt;		// clock rate prescaler
	input [3:0] attack0;
	input [3:0] attack1;
	input [3:0] attack2;
	input [3:0] attack3;
	input [3:0] decay0;
	input [3:0] decay1;
	input [3:0] decay2;
	input [3:0] decay3;
	input [3:0] sustain0;
	input [3:0] sustain1;
	input [3:0] sustain2;
	input [3:0] sustain3;
	input [3:0] relese0;
	input [3:0] relese1;
	input [3:0] relese2;
	input [3:0] relese3;
`ifdef CHANNELS8
	input [7:0] gate;
	input [3:0] attack4;
	input [3:0] attack5;
	input [3:0] attack6;
	input [3:0] attack7;
	input [3:0] decay4;
	input [3:0] decay5;
	input [3:0] decay6;
	input [3:0] decay7;
	input [3:0] sustain4;
	input [3:0] sustain5;
	input [3:0] sustain6;
	input [3:0] sustain7;
	input [3:0] relese4;
	input [3:0] relese5;
	input [3:0] relese6;
	input [3:0] relese7;
`else
	input [3:0] gate;
`endif
	output [7:0] o;

	reg [7:0] sustain;
	reg [15:0] attack;
	reg [17:0] decay;
	reg [17:0] relese;
`ifdef CHANNELS8
	reg [7:0] envCtr [7:0];
	reg [7:0] envCtr2 [7:0];	// for counting intervals
	reg [7:0] iv[7:0];			// interval value for decay/release
	reg [2:0] icnt[7:0];			// interval count
	reg [19:0] envDvn [7:0];
	reg [2:0] envState [7:0];
`else
	reg [7:0] envCtr [3:0];
	reg [7:0] envCtr2 [3:0];
	reg [7:0] iv[3:0];			// interval value for decay/release
	reg [2:0] icnt[3:0];			// interval count
	reg [19:0] envDvn [3:0];
	reg [2:0] envState [3:0];
`endif
	reg [2:0] envStateNxt;
	reg [15:0] envStepPeriod;	// determines the length of one step of the envelope generator
	reg [7:0] envCtrx;
	reg [19:0] envDvnx;

	wire [3:0] attack_x;
	wire [3:0] decay_x;
	wire [3:0] sustain_x;
	wire [3:0] relese_x;

	integer n;

	// Decodes a 4-bit code into an attack value
	function [15:0] AttackDecode;
		input [3:0] atk;
		
		begin
		case(atk)
		4'd0:	AttackDecode = 16'd8;
		4'd1:	AttackDecode = 16'd32;
		4'd2:	AttackDecode = 16'd63;
		4'd3:	AttackDecode = 16'd95;
		4'd4:	AttackDecode = 16'd150;
		4'd5:	AttackDecode = 16'd221;
		4'd6:	AttackDecode = 16'd268;
		4'd7:	AttackDecode = 16'd316;
		4'd8:	AttackDecode = 16'd395;
		4'd9:	AttackDecode = 16'd986;
		4'd10:	AttackDecode = 16'd1973;
		4'd11:	AttackDecode = 16'd3157;
		4'd12:	AttackDecode = 16'd3946;
		4'd13:	AttackDecode = 16'd11837;
		4'd14:	AttackDecode = 16'd19729;
		4'd15:	AttackDecode = 16'd31566;
		endcase
		end

	endfunction

	// Decodes a 4-bit code into a decay/release value
	function [15:0] DecayDecode;
		input [3:0] dec;
		
		begin
		case(dec)
		4'd0:	DecayDecode = 17'd24;
		4'd1:	DecayDecode = 17'd95;
		4'd2:	DecayDecode = 17'd190;
		4'd3:	DecayDecode = 17'd285;
		4'd4:	DecayDecode = 17'd452;
		4'd5:	DecayDecode = 17'd665;
		4'd6:	DecayDecode = 17'd808;
		4'd7:	DecayDecode = 17'd951;
		4'd8:	DecayDecode = 17'd1188;
		4'd9:	DecayDecode = 17'd2971;
		4'd10:	DecayDecode = 17'd5942;
		4'd11:	DecayDecode = 17'd9507;
		4'd12:	DecayDecode = 17'd11884;
		4'd13:	DecayDecode = 17'd35651;
		4'd14:	DecayDecode = 17'd59418;
		4'd15:	DecayDecode = 17'd95068;
		endcase
		end

	endfunction

`ifdef CHANNELS8
    wire [2:0] sel = cnt[2:0];

	always @(sel or
		attack0 or attack1 or attack2 or attack3 or
		attack4 or attack5 or attack6 or attack7)
		case (sel)
		0:	attack_x <= attack0;
		1:	attack_x <= attack1;
		2:	attack_x <= attack2;
		3:	attack_x <= attack3;
		4:	attack_x <= attack4;
		5:	attack_x <= attack5;
		6:	attack_x <= attack6;
		7:	attack_x <= attack7;
		endcase

	always @(sel or
		decay0 or decay1 or decay2 or decay3 or
		decay4 or decay5 or decay6 or decay7)
		case (sel)
		0:	decay_x <= decay0;
		1:	decay_x <= decay1;
		2:	decay_x <= decay2;
		3:	decay_x <= decay3;
		4:	decay_x <= decay4;
		5:	decay_x <= decay5;
		6:	decay_x <= decay6;
		7:	decay_x <= decay7;
		endcase

	always @(sel or
		sustain0 or sustain1 or sustain2 or sustain3 or
		sustain4 or sustain5 or sustain6 or sustain7)
		case (sel)
		0:	sustain <= sustain0;
		1:	sustain <= sustain1;
		2:	sustain <= sustain2;
		3:	sustain <= sustain3;
		4:	sustain <= sustain4;
		5:	sustain <= sustain5;
		6:	sustain <= sustain6;
		7:	sustain <= sustain7;
		endcase

	always @(sel or
		relese0 or relese1 or relese2 or relese3 or
		relese4 or relese5 or relese6 or relese7)
		case (sel)
		0:	relese <= relese0;
		1:	relese <= relese1;
		2:	relese <= relese2;
		3:	relese <= relese3;
		4:	relese <= relese4;
		5:	relese <= relese5;
		6:	relese <= relese6;
		7:	relese <= relese7;
		endcase

`else

    wire [1:0] sel = cnt[1:0];

	mux4to1 #(4) u1 (
		.e(1'b1),
		.s(sel),
		.i0(attack0),
		.i1(attack1),
		.i2(attack2),
		.i3(attack3),
		.z(attack_x)
	);

	mux4to1 #(12) u2 (
		.e(1'b1),
		.s(sel),
		.i0(decay0),
		.i1(decay1),
		.i2(decay2),
		.i3(decay3),
		.z(decay_x)
	);

	mux4to1 #(8) u3 (
		.e(1'b1),
		.s(sel),
		.i0(sustain0),
		.i1(sustain1),
		.i2(sustain2),
		.i3(sustain3),
		.z(sustain_x)
	);

	mux4to1 #(12) u4 (
		.e(1'b1),
		.s(sel),
		.i0(relese0),
		.i1(relese1),
		.i2(relese2),
		.i3(relese3),
		.z(relese_x)
	);

`endif

	always @(attack_x)
		attack <= AttackDecode(attack_x);

	always @(decay_x)
		decay <= DecayDecode(decay_x);

	always @(sustain_x)
		sustain <= {sustain_x,sustain_x};

	always @(relese_x)
		relese <= DecayDecode(relese_x);


	always @(sel)
		envCtrx <= envCtr[sel];

	always @(sel)
		envDvnx <= envDvn[sel];


	// Envelope generate state machine
	// Determine the next envelope state
	always @(sel or gate or sustain)
	begin
		case (envState[sel])
		`ENV_IDLE:
			if (gate[sel])
				envStateNxt <= `ENV_ATTACK;
			else
				envStateNxt <= `ENV_IDLE;
		`ENV_ATTACK:
			if (envCtrx==8'hFE) begin
				if (sustain==8'hFF)
					envStateNxt <= `ENV_SUSTAIN;
				else
					envStateNxt <= `ENV_DECAY;
			end
			else
				envStateNxt <= `ENV_ATTACK;
		`ENV_DECAY:
			if (envCtrx==sustain)
				envStateNxt <= `ENV_SUSTAIN;
			else
				envStateNxt <= `ENV_DECAY;
		`ENV_SUSTAIN:
			if (~gate[sel])
				envStateNxt <= `ENV_RELEASE;
			else
				envStateNxt <= `ENV_SUSTAIN;
		`ENV_RELEASE: begin
			if (envCtrx==8'h00)
				envStateNxt <= `ENV_IDLE;
			else if (gate[sel])
				envStateNxt <= `ENV_SUSTAIN;
			else
				envStateNxt <= `ENV_RELEASE;
			end
		// In case of hardware problem
		default:
			envStateNxt <= `ENV_IDLE;
		endcase
	end

	always @(posedge clk)
		if (rst) begin
		    for (n = 0; n < pChannels; n = n + 1)
		        envState[n] <= `ENV_IDLE;
		end
		else if (cnt < pChannels)
			envState[sel] <= envStateNxt;


	// Handle envelope counter
	always @(posedge clk)
		if (rst) begin
		    for (n = 0; n < pChannels; n = n + 1) begin
		        envCtr[n] <= 0;
		        envCtr2[n] <= 0;
		        icnt[n] <= 0;
		        iv[n] <= 0;
		    end
		end
		else if (cnt < pChannels) begin
			case (envState[sel])
			`ENV_IDLE:
				begin
				envCtr[sel] <= 0;
				envCtr2[sel] <= 0;
				icnt[sel] <= 0;
				iv[sel] <= 0;
				end
			`ENV_SUSTAIN:
				begin
				envCtr2[sel] <= 0;
				icnt[sel] <= 0;
				iv[sel] <= sustain >> 3;
				end
			`ENV_ATTACK:
				begin
				icnt[sel] <= 0;
				iv[sel] <= (8'hff - sustain) >> 3;
				if (envDvnx==20'h0) begin
					envCtr2[sel] <= 0;
					envCtr[sel] <= envCtrx + 1;
				end
				end
			`ENV_DECAY,
			`ENV_RELEASE:
				if (envDvnx==20'h0) begin
					envCtr[sel] <= envCtrx - 1;
					if (envCtr2[sel]==iv[sel]) begin
						envCtr2[sel] <= 0;
						if (icnt[sel] < 3'd7)
							icnt[sel] <= icnt[sel] + 1;
					end
					else
						envCtr2[sel] <= envCtr2[sel] + 1;
				end
			endcase
		end

	// Determine envelope divider adjustment source
	always @(sel or attack or decay or relese)
	begin
		case(envState[sel])
		`ENV_ATTACK:	envStepPeriod <= attack;
		`ENV_DECAY:		envStepPeriod <= decay;
		`ENV_RELEASE:	envStepPeriod <= relese;
		default:		envStepPeriod <= 16'h0;
		endcase
	end


	// double the delay at appropriate points
	// for exponential modelling
	wire [19:0] envStepPeriod1 = {4'b0,envStepPeriod} << icnt[sel];


	// handle the clock divider
	// loadable down counter
	// This sets the period of each step of the envelope
	always @(posedge clk)
		if (rst) begin
			for (n = 0; n < pChannels; n = n + 1)
				envDvn[n] <= 0;
		end
		else if (cnt < pChannels) begin
			if (envDvnx==20'h0)
				envDvn[sel] <= envStepPeriod1;
			else
				envDvn[sel] <= envDvnx - 1;
		end

	assign o = envCtrx;

endmodule



// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGFilter.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGFilter.v
//	Version 1.1
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//        16-tap digital filter
//
//    Currently this filter is only partially tested. The author believes that
//    the approach used is valid however.
//	The author opted to include the filter because it is part of the design,
//	and even this untested component can provide an idea of the resource
//	requirements, and device capabilities.
//		This is a "how one might approach the problem" example, at least
//	until the author is sure the filter is working correctly.
//        
//	Time division multiplexing is used to implement this filter in order to
//	reduce the resource requirement. This should be okay because it is being
//	used to filter audio signals. The effective operating frequency of the
//	filter depends on the 'cnt' supplied (eg 1MHz)
//
//	Spartan3
//	Webpack 9.1i xc3s1000-4ft256
//	158 LUTs / 88 slices / 73.865MHz
//	1 MULT
//============================================================================
//
module PSGFilter(rst, clk, cnt, wr, adr, din, i, o);
parameter pTaps = 16;
input rst;
input clk;
input [7:0] cnt;
input wr;
input [3:0] adr;
input [12:0] din;
input [14:0] i;
output [14:0] o;
reg [14:0] o;

reg [30:0] acc;                 // accumulator
reg [14:0] tap [0:pTaps-1];     // tap registers
integer n;

// coefficient memory
reg [11:0] coeff [0:pTaps-1];   // magnitude of coefficient
reg [pTaps-1:0] sgn;            // sign of coefficient

initial begin
	for (n = 0; n < pTaps; n = n + 1)
	begin
		coeff[n] <= 0;
		sgn[n] <= 0;
	end
end

// update coefficient memory
always @(posedge clk)
    if (wr) begin
        coeff[adr] <= din[11:0];
        sgn[adr] <= din[12];
    end

// shift taps
// Note: infer a dsr by NOT resetting the registers
always @(posedge clk)
    if (cnt==8'd0) begin
        tap[0] <= i;
        for (n = 1; n < pTaps; n = n + 1)
        	tap[n] <= tap[n-1];
    end

wire [26:0] mult = coeff[cnt[3:0]] * tap[cnt[3:0]];

always @(posedge clk)
    if (rst)
        acc <= 0;
    else if (cnt==8'd0)
        acc <= sgn[cnt[3:0]] ? 0 - mult : 0 + mult;
    else if (cnt < pTaps)
        acc <= sgn[cnt[3:0]] ? acc - mult : acc + mult;

always @(posedge clk)
    if (rst)
        o <= 0;
    else if (cnt==8'd0)
        o <= acc[30:16];

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGMasterVolumeControl.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	PSGMasterVolumeControl.v 
//		Controls the PSG's output volume.
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//	
//============================================================================ */

module PSGMasterVolumeControl(rst_i, clk_i, i, volume, o);
input rst_i;
input clk_i;
input [15:0] i;
input [3:0] volume;
output [19:0] o;
reg [19:0] o;

// Multiply 16x4 bits
wire [19:0] v1 = volume[0] ? i : 20'd0;
wire [19:0] v2 = volume[1] ? {i,1'b0} + v1: v1;
wire [19:0] v3 = volume[2] ? {i,2'b0} + v2: v2;
wire [19:0] vo = volume[3] ? {i,3'b0} + v3: v3;

always @(posedge clk_i)
	if (rst_i)
		o <= 20'b0;		// Force the output volume to zero on reset
	else
		o <= vo;

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGNoteGen.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//=============================================================================
//	(C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGNoteGen.v
//	Version 1.1
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//	Note generator. 4/8 channels
//
//	Spartan3
//	Webpack 9.1i xc3s1000-4ft256
//	337 LUTs / 224 slices / 98.445 MHz
//=============================================================================

module PSGNoteGen(rst, clk, cnt, br, bg, bgn, ack, test,
	vt0, vt1, vt2, vt3,
	freq0, freq1, freq2, freq3,
	pw0, pw1, pw2, pw3,
	acc0, acc1, acc2, acc3,
	wave, sync, ringmod, o
);
input rst;
input clk;
input [7:0] cnt;
input ack;
input [11:0] wave;
input [2:0] bgn;		// bus grant number
output [3:0] br;
input [3:0] bg;
input [3:0] test;
input [4:0] vt0, vt1, vt2, vt3;
input [15:0] freq0, freq1, freq2, freq3;
input [11:0] pw0, pw1, pw2, pw3;
input [3:0] sync;
input [3:0] ringmod;
//	input pxacc25;
output [23:0] acc0, acc1, acc2, acc3;	// 1.023MHz / 2^ 24 = 0.06Hz resolution
output [11:0] o;

wire [15:0] freqx;
wire [11:0] pwx;
reg [23:0] pxacc;
reg [23:0] acc;
reg [11:0] outputT;
reg [7:0] pxacc23x;
reg [7:0] ibr;

integer n;

reg [23:0] accx [3:0];
reg [11:0] pacc [3:0];
wire [1:0] sel = cnt[1:0];
reg [11:0] outputW [3:0];
reg [22:0] lfsr [3:0];

assign br[0] =	ibr[0] & ~bg[0];
assign br[1] =	ibr[1] & ~bg[1];
assign br[2] =	ibr[2] & ~bg[2];
assign br[3] =	ibr[3] & ~bg[3];

wire [4:0] vtx;

always @(sel)
	acc <= accx[sel];


mux4to1 #(16) u1 (.e(1'b1), .s(sel), .i0(freq0), .i1(freq1), .i2(freq2), .i3(freq3), .z(freqx) );
mux4to1 #(12) u2 (.e(1'b1), .s(sel), .i0(pw0), .i1(pw1), .i2(pw2), .i3(pw3), .z(pwx) );
mux4to1 #( 5) u3 (.e(1'b1), .s(sel), .i0(vt0), .i1(vt1), .i2(vt2), .i3(vt3), .z(vtx) );


wire [22:0] lfsrx = lfsr[sel];
wire [7:0] paccx = pacc[sel];

always @(sel)
	pxacc <= accx[sel-1];
wire pxacc23 = pxacc[23];


// for sync'ing
always @(posedge clk)
	if (cnt < 8'd4)
		pxacc23x[sel] <= pxacc23;

wire synca = ~pxacc23x[sel]&pxacc23&sync[sel];


// detect a transition on the wavetable address
// previous address not equal to current address
wire accTran = pacc[sel]!=acc[23:12];

// for wave table DMA
// capture the previous address
always @(posedge clk)
	if (rst) begin
		for (n = 0; n < 4; n = n + 1)
			pacc[n] <= 0;
	end
	else if (cnt < 8'd4)
		pacc[sel] <= acc[23:12];


// capture wave input
// must be to who was granted the bus
always @(posedge clk)
	if (rst) begin
		for (n = 0; n < 8'd4; n = n + 1)
			outputW[n] <= 0;
	end
	else if (ack)
		outputW[bgn] <= wave;


// bus request control
always @(posedge clk)
	if (rst) begin
		ibr <= 0;
	end
	else if (cnt < 8'd4) begin
		// check for an address transition and wave enabled
		// if so, request bus
		if (accTran & vtx[4])
			ibr[sel] <= 1;
		// otherwise
		// turn off bus request for whoever it was granted
		else
			ibr[bgn] <= 0;
	end


// Noise generator
always @(posedge clk)
	if (cnt < 8'd4 && paccx[2] != acc[18])
		lfsr[sel] <= {lfsrx[21:0],~(lfsrx[22]^lfsrx[17])};


// Harmonic synthesizer
always @(posedge clk)
	if (rst) begin
		for (n = 0; n < 4; n = n + 1)
			accx[n] <= 0;
	end
	else if (cnt < 8'd4) begin
		if (~test[sel]) begin
			if (synca)
				accx[sel] <= 0;
			else
				accx[sel] <= acc + freqx;
		end
		else
			accx[sel] <= 0;
	end


// Triangle wave, ring modulation
wire msb = ringmod[sel] ? acc[23]^pxacc23 : acc[23];
always @(acc or msb)
	outputT <= msb ? ~acc[22:11] : acc[22:11];

// Other waveforms, ho-hum
wire [11:0] outputP = {12{acc[23:12] < pwx}};
wire [11:0] outputS = acc[23:12];
wire [11:0] outputN = lfsrx[11:0];

wire [11:0] out;
PSGNoteOutMux #(12) u4 (.s(vtx), .a(outputT), .b(outputS), .c(outputP), .d(outputN), .e(outputW[sel]), .o(out) );
assign o = out;

assign acc0 = accx[0];
assign acc1 = accx[1];
assign acc2 = accx[2];
assign acc3 = accx[3];

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGNoteOutMux.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGNoteOutMux.v
//	Version 1.0
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//	
//	Selects from one of five waveforms for output. Selected waveform
//	outputs are anded together. This is approximately how the
//	original SID worked.
//
//	Spartan3
//	Webpack 9.1i xc3s1000-4ft256
//	36 LUTs / 21 slices / 11ns
//============================================================================ */
//
module PSGNoteOutMux(s, a, b, c, d, e, o);
parameter WID = 12;
input [4:0] s;
input [WID-1:0] a,b,c,d,e;
output [WID-1:0] o;

wire [WID-1:0] o1,o2,o3,o4,o5;

assign o1 = s[4] ? e : {WID{1'b1}};
assign o2 = s[3] ? d : {WID{1'b1}};
assign o3 = s[2] ? c : {WID{1'b1}};
assign o4 = s[1] ? b : {WID{1'b1}};
assign o5 = s[0] ? a : {WID{1'b1}};

assign o = o1 & o2 & o3 & o4 & o5;

endmodule



// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGOutputSummer.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	PSGOutputSummer.v 
//		Sum the filtered and unfiltered output.
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//============================================================================ */

module PSGOutputSummer(clk_i, cnt, ufi, fi, o);
input clk_i;		// master clock
input [7:0] cnt;	// clock divider
input [21:0] ufi;	// unfiltered audio input
input [21:0] fi;	// filtered audio input
output [21:0] o;	// summed output
reg [21:0] o;

always @(posedge clk_i)
	if (cnt==8'd0)
		o <= ufi + fi;

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/PSGShaper.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	PSGShaper.v 
//		Shape the channels by applying the envelope to the tone generator
//	output.
//
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//	
//============================================================================ */

module PSGShaper(clk_i, ce, tgi, env, o);
input clk_i;		// clock
input ce;			// clock enable
input [11:0] tgi;	// tone generator input
input [7:0] env;	// envelop generator input
output [19:0] o;	// shaped output
reg [19:0] o;		// shaped output

// shape output according to envelope
always @(posedge clk_i)
	if (ce)
		o <= tgi * env;

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/mux4to1.v
// -----------------------------------------------------------------------------
// (C) 2007,2012  Robert T Finch
// robfinch<remove>@opencores.org
// All Rights Reserved.
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
// Verilog 1995
//
// Webpack 9.1i  xc3s1000-4ft256
//  slices /  LUTs / MHz

module mux4to1(e, s, i0, i1, i2, i3, z);
parameter WID=4;
input e;
input [1:0] s;
input [WID:1] i0;
input [WID:1] i1;
input [WID:1] i2;
input [WID:1] i3;
output [WID:1] z;
reg [WID:1] z;

always @(e or s or i0 or i1 or i2 or i3)
	if (!e)
		z <= {WID{1'b0}};
	else begin
		case(s)
		2'b00:	z <= i0;
		2'b01:	z <= i1;
		2'b10:	z <= i2;
		2'b11:	z <= i3;
		endcase
	end

endmodule
