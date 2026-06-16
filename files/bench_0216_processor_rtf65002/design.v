// Curated RTL benchmark case.
// case_id: bench_0216_processor_rtf65002
// source_project: processor_rtf65002
// top_module: rtf65002d


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
// Source file: rtl/verilog/rtf65002_defines.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//
// rtf65002.v
//  - 32 bit CPU
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
// ============================================================================
//
`ifndef RTF65002_DEFINES
`define RTF65002_DEFINES	1'b1

`define TRUE		1'b1
`define FALSE		1'b0

`define DEBUG		1'b1

`define SUPPORT_ICACHE	1'b1
`define ICACHE_4K		1'b1
//`define ICACHE_16K		1'b1
//`define ICACHE_2WAY		1'b1
//`define SUPPORT_DCACHE	1'b1
`define SUPPORT_BCD		1'b1
`define SUPPORT_DIVMOD		1'b1
`define SUPPORT_EM8		1'b1
`define SUPPORT_816		1'b1
//`define SUPPORT_EXEC	1'b1
`define SUPPORT_BERR	1'b1
`define SUPPORT_STRING	1'b1
`define SUPPORT_SHIFT	1'b1

`define RST_VECT	34'h3FFFFFFF8
`define NMI_VECT	34'h3FFFFFFF4
`define IRQ_VECT	34'h3FFFFFFF0
`define BRK_VECTNO	9'd0
`define SLP_VECTNO	9'd1
`define BYTE_RST_VECT	34'h00000FFFC
`define BYTE_NMI_VECT	34'h00000FFFA
`define BYTE_IRQ_VECT	34'h00000FFFE
`define RST_VECT_816	34'h00000FFFC
`define IRQ_VECT_816	34'h00000FFEE
`define NMI_VECT_816	34'h00000FFEA
`define ABT_VECT_816	34'h00000FFE8
`define BRK_VECT_816	34'h00000FFE6
`define COP_VECT_816	34'h00000FFE4

`define BRK			9'h00
`define RTI			9'h40
`define RTS			9'h60
`define PHP			9'h08
`define CLC			9'h18
`define PLP			9'h28
`define SEC			9'h38
`define PHA			9'h48
`define CLI			9'h58
`define PLA			9'h68
`define SEI			9'h78
`define DEY			9'h88
`define TYA			9'h98
`define TAY			9'hA8
`define CLV			9'hB8
`define INY			9'hC8
`define CLD			9'hD8
`define INX			9'hE8
`define SED			9'hF8
`define ROR_ACC		9'h6A
`define TXA			9'h8A
`define TXS			9'h9A
`define TAX			9'hAA
`define TSX			9'hBA
`define DEX			9'hCA
`define NOP			9'hEA
`define TXY			9'h9B
`define TYX			9'hBB
`define TAS			9'h1B
`define TSA			9'h3B
`define TRS			9'h8B
`define TSR			9'hAB
`define TCD			9'h5B
`define TDC			9'h7B
`define STP			9'hDB
`define NAT			9'hFB
`define EMM			9'hFB
`define XCE			9'hFB
`define INA			9'h1A
`define DEA			9'h3A
`define SEP			9'hE2
`define REP			9'hC2
`define PEA			9'hF4
`define PEI			9'hD4
`define PER			9'h62
`define WDM			9'h42

`define RR			9'h02
`define ADD_RR			4'd0
`define SUB_RR			4'd1
`define CMP_RR			4'd2
`define AND_RR			4'd3
`define EOR_RR			4'd4
`define OR_RR			4'd5
`define MUL_RR			4'd8
`define MULS_RR			4'd9
`define DIV_RR			4'd10
`define DIVS_RR			4'd11
`define MOD_RR			4'd12
`define MODS_RR			4'd13
`define ASL_RRR			4'd14
`define LSR_RRR			4'd15
`define LD_RR		9'h7B

`define ADD_R		9'h77
`define ADD_IMM4	9'h67
`define ADD_IMM8	9'h65		// 8 bit operand
`define ADD_IMM16	9'h79		// 16 bit operand
`define ADD_IMM32	9'h69		// 32 bit operand
`define ADD_ZPX		9'h75		// there is no ZP mode, use R0 to syntheisze
`define ADD_IX		9'h61
`define ADD_IY		9'h71
`define ADD_ABS		9'h6D
`define ADD_ABSX	9'h7D
`define ADD_RIND	9'h72
`define ADD_DSP		9'h63

`define SUB_R		9'hF7
`define SUB_IMM4	9'hE7
`define SUB_IMM8	9'hE5
`define SUB_IMM16	9'hF9
`define SUB_IMM32	9'hE9
`define SUB_ZPX		9'hF5
`define SUB_IX		9'hE1
`define SUB_IY		9'hF1
`define SUB_ABS		9'hED
`define SUB_ABSX	9'hFD
`define SUB_RIND	9'hF2
`define SUB_DSP		9'hE3

// CMP = SUB r0,....

`define ADC_IMM		9'h69
`define ADC_ZP		9'h65
`define ADC_ZPX		9'h75
`define ADC_IX		9'h61
`define ADC_IY		9'h71
`define ADC_IYL		9'h77
`define ADC_ABS		9'h6D
`define ADC_ABSX	9'h7D
`define ADC_ABSY	9'h79
`define ADC_I		9'h72
`define ADC_IL		9'h67
`define ADC_AL		9'h6F
`define ADC_ALX		9'h7F
`define ADC_DSP		9'h63
`define ADC_DSPIY	9'h73

`define SBC_IMM		9'hE9
`define SBC_ZP		9'hE5
`define SBC_ZPX		9'hF5
`define SBC_IX		9'hE1
`define SBC_IY		9'hF1
`define SBC_IYL		9'hF7
`define SBC_ABS		9'hED
`define SBC_ABSX	9'hFD
`define SBC_ABSY	9'hF9
`define SBC_I		9'hF2
`define SBC_IL		9'hE7
`define SBC_AL		9'hEF
`define SBC_ALX		9'hFF
`define SBC_DSP		9'hE3
`define SBC_DSPIY	9'hF3

`define CMP_IMM8	9'hC5
`define CMP_IMM32	9'hC9
`define CMP_IMM		9'hC9
`define CMP_ZP		9'hC5
`define CMP_ZPX		9'hD5
`define CMP_IX		9'hC1
`define CMP_IY		9'hD1
`define CMP_IYL		8'hD7
`define CMP_ABS		9'hCD
`define CMP_ABSX	9'hDD
`define CMP_ABSY	9'hD9
`define CMP_I		9'hD2
`define CMP_IL		9'hC7
`define CMP_AL		9'hCF
`define CMP_ALX		9'hDF
`define CMP_DSP		9'hC3
`define CMP_DSPIY	9'hD3

`define LDA_IMM8	9'hA5
`define LDA_IMM16	9'hB9
`define LDA_IMM32	9'hA9

`define AND_R		9'h37
`define AND_IMM4	9'h27
`define AND_IMM8	9'h25
`define AND_IMM16	9'h39
`define AND_IMM32	9'h29
`define AND_IMM		9'h29
`define AND_ZP		9'h25
`define AND_ZPX		9'h35
`define AND_IX		9'h21
`define AND_IY		9'h31
`define AND_IYL		9'h37
`define AND_ABS		9'h2D
`define AND_ABSX	9'h3D
`define AND_ABSY	9'h39
`define AND_RIND	9'h32
`define AND_I		9'h32
`define AND_IL		9'h27
`define AND_DSP		9'h23
`define AND_DSPIY	9'h33
`define AND_AL		9'h2F
`define AND_ALX		9'h3F

`define OR_R		9'h17
`define OR_IMM4		9'h07
`define OR_IMM8		9'h05
`define OR_IMM16	9'h19
`define OR_IMM32	9'h09
`define OR_ZPX		9'h15
`define OR_IX		9'h01
`define OR_IY		9'h11
`define OR_ABS		9'h0D
`define OR_ABSX		9'h1D
`define OR_RIND		9'h12
`define OR_DSP		9'h03

`define ORA_IMM		9'h09
`define ORA_ZP		9'h05
`define ORA_ZPX		9'h15
`define ORA_IX		9'h01
`define ORA_IY		9'h11
`define ORA_IYL		9'h17
`define ORA_ABS		9'h0D
`define ORA_ABSX	9'h1D
`define ORA_ABSY	9'h19
`define ORA_I		9'h12
`define ORA_IL		9'h07
`define ORA_AL		9'h0F
`define ORA_ALX		9'h1F
`define ORA_DSP		9'h03
`define ORA_DSPIY	9'h13

`define EOR_R		9'h57
`define EOR_IMM4	9'h47
`define EOR_IMM		9'h49
`define EOR_IMM8	9'h45
`define EOR_IMM16	9'h59
`define EOR_IMM32	9'h49
`define EOR_ZP		9'h45
`define EOR_ZPX		9'h55
`define EOR_IX		9'h41
`define EOR_IY		9'h51
`define EOR_IYL		9'h57
`define EOR_ABS		9'h4D
`define EOR_ABSX	9'h5D
`define EOR_ABSY	9'h59
`define EOR_RIND	9'h52
`define EOR_I		9'h52
`define EOR_IL		9'h47
`define EOR_DSP		9'h43
`define EOR_DSPIY	9'h53
`define EOR_AL		9'h4F
`define EOR_ALX		9'h5F

// LD is OR rt,r0,....

`define ST_ZPX		9'h95
`define ST_IX		9'h81
`define ST_IY		9'h91
`define ST_ABS		9'h8D
`define ST_ABSX		9'h9D
`define ST_RIND		9'h92
`define ST_DSP		9'h83

`define ORB_ZPX		9'hB5
`define ORB_IX		9'hA1
`define ORB_IY		9'hB1
`define ORB_ABS		9'hAD
`define ORB_ABSX	9'hBD

`define STB_ZPX		9'h74
`define STB_ABS		9'h9C
`define STB_ABSX	9'h9E


//`define LDB_RIND	9'hB2	// Conflict with LDX #imm16

`define LDA_IMM		9'hA9
`define LDA_ZP		9'hA5
`define LDA_ZPX		9'hB5
`define LDA_IX		9'hA1
`define LDA_IY		9'hB1
`define LDA_IYL		9'hB7
`define LDA_ABS		9'hAD
`define LDA_ABSX	9'hBD
`define LDA_ABSY	9'hB9
`define LDA_I		9'hB2
`define LDA_IL		9'hA7
`define LDA_AL		9'hAF
`define LDA_ALX		9'hBF
`define LDA_DSP		9'hA3
`define LDA_DSPIY	9'hB3

`define STA_ZP		9'h85
`define STA_ZPX		9'h95
`define STA_IX		9'h81
`define STA_IY		9'h91
`define STA_IYL		9'h97
`define STA_ABS		9'h8D
`define STA_ABSX	9'h9D
`define STA_ABSY	9'h99
`define STA_I		9'h92
`define STA_IL		9'h87
`define STA_AL		9'h8F
`define STA_ALX		9'h9F
`define STA_DSP		9'h83
`define STA_DSPIY	9'h93

`define ASL_IMM8	9'h24
`define ASL_ACC		9'h0A
`define ASL_ZP		9'h06
`define ASL_RR		9'h06
`define ASL_ZPX		9'h16
`define ASL_ABS		9'h0E
`define ASL_ABSX	9'h1E

`define ROL_ACC		9'h2A
`define ROL_ZP		9'h26
`define ROL_RR		9'h26
`define ROL_ZPX		9'h36
`define ROL_ABS		9'h2E
`define ROL_ABSX	9'h3E

`define LSR_IMM8	9'h34
`define LSR_ACC		9'h4A
`define LSR_ZP		9'h46
`define LSR_RR		9'h46
`define LSR_ZPX		9'h56
`define LSR_ABS		9'h4E
`define LSR_ABSX	9'h5E

`define ROR_RR		9'h66
`define ROR_ZP		9'h66
`define ROR_ZPX		9'h76
`define ROR_ABS		9'h6E
`define ROR_ABSX	9'h7E

`define DEC_RR		9'hC6
`define DEC_ZP		9'hC6
`define DEC_ZPX		9'hD6
`define DEC_ABS		9'hCE
`define DEC_ABSX	9'hDE
`define INC_RR		9'hE6
`define INC_ZP		9'hE6
`define INC_ZPX		9'hF6
`define INC_ABS		9'hEE
`define INC_ABSX	9'hFE

`define BIT_IMM		9'h89
`define BIT_ZP		9'h24
`define BIT_ZPX		9'h34
`define BIT_ABS		9'h2C
`define BIT_ABSX	9'h3C

// CMP = SUB r0,...
// BIT = AND r0,...
`define BPL			9'h10
`define BVC			9'h50
`define BCC			9'h90
`define BNE			9'hD0
`define BMI			9'h30
`define BVS			9'h70
`define BCS			9'hB0
`define BEQ			9'hF0
`define BRL			9'h82
`define BRA			9'h80
`define BHI			9'h13
`define BLS			9'h33
`define BGE			9'h93
`define BLT			9'hB3
`define BGT			9'hD3
`define BLE			9'hF3

`define JML			9'h5C
`define JMP			9'h4C
`define JMP_IND		9'h6C
`define JMP_INDX	9'h7C
`define JMP_RIND	9'hD2
`define JSR			9'h20
`define JSL			9'h22
`define JSR_IND		9'h2C
`define JSR_INDX	9'hFC
`define JSR_RIND	9'hC2
`define RTS			9'h60
`define RTL			9'h6B
`define BSR			9'h62
`define NOP			9'hEA

`define BRK			9'h00
`define PLX			9'hFA
`define PLY			9'h7A
`define PHX			9'hDA
`define PHY			9'h5A
`define WAI			9'hCB
`define PUSH		9'h0B
`define POP			9'h2B
`define PHB			9'h8B
`define PHD			9'h0B
`define PHK			9'h4B
`define XBA			9'hEB
`define COP			9'h02
`define PLB			9'hAB
`define PLD			9'h2B

`define LDX_IMM		9'hA2
`define LDX_ZP		9'hA6
`define LDX_ZPX		9'hB6
`define LDX_ZPY		9'hB6
`define LDX_ABS		9'hAE
`define LDX_ABSY	9'hBE

`define LDX_IMM32	9'hA2
`define LDX_IMM16	9'hB2
`define LDX_IMM8	9'hA6

`define LDY_IMM		9'hA0
`define LDY_ZP		9'hA4
`define LDY_ZPX		9'hB4
`define LDY_IMM32	9'hA0
`define LDY_ABS		9'hAC
`define LDY_ABSX	9'hBC

`define STX_ZP		9'h86
`define STX_ZPX		9'h96
`define STX_ZPY		9'h96
`define STX_ABS		9'h8E

`define STY_ZP		9'h84
`define STY_ZPX		9'h94
`define STY_ABS		9'h8C

`define STZ_ZP		9'h64
`define STZ_ZPX		9'h74
`define STZ_ABS		9'h9C
`define STZ_ABSX	9'h9E

`define CPX_IMM		9'hE0
`define CPX_IMM32	9'hE0
`define CPX_ZP		9'hE4
`define CPX_ZPX		9'hE4
`define CPX_ABS		9'hEC
`define CPY_IMM		9'hC0
`define CPY_IMM32	9'hC0
`define CPY_ZP		9'hC4
`define CPY_ZPX		9'hC4
`define CPY_ABS		9'hCC

`define TRB_ZP		9'h14
`define TRB_ZPX		9'h14
`define TRB_ABS		9'h1C
`define TSB_ZP		9'h04
`define TSB_ZPX		9'h04
`define TSB_ABS		9'h0C

`define BAZ			9'hC1
`define BXZ			9'hD1
`define BEQ_RR		9'hE2
`define INT0		9'hDC
`define INT1		9'hDD
`define SUB_SP8		9'h85
`define SUB_SP16	9'h99
`define SUB_SP32	9'h89
`define MVP			9'h44
`define MVN			9'h54
`define STS			9'h64
`define EXEC		9'hEB
`define ATNI		9'h4B
`define MDR			9'h3C

// Page Two Opcodes
`define PG2			9'h42

`define TOFF		9'h118
`define TON			9'h138
`define MUL_IMM8	9'h105
`define MUL_IMM16	9'h119
`define MUL_IMM32	9'h109
`define DIV_IMM8	9'h145
`define DIV_IMM16	9'h159
`define DIV_IMM32	9'h149
`define MOD_IMM8	9'h185
`define MOD_IMM16	9'h199
`define MOD_IMM32	9'h189
`define PUSHA		9'h10B
`define POPA		9'h12B
`define BMS_ZPX		9'h106
`define BMS_ABS		9'h10E
`define BMS_ABSX	9'h11E
`define BMC_ZPX		9'h126
`define BMC_ABS		9'h12E
`define BMC_ABSX	9'h13E
`define BMF_ZPX		9'h146
`define BMF_ABS		9'h14E
`define BMF_ABSX	9'h15E
`define BMT_ZPX		9'h166
`define BMT_ABS		9'h16E
`define BMT_ABSX	9'h17E
`define HOFF		9'h158
`define CMPS		9'h144
`define SPL_ABS		9'h18E
`define SPL_ABSX	9'h19E

`define LEA_ZPX		9'h1D5
`define LEA_IX		9'h1C1
`define LEA_IY		9'h1D1
`define LEA_ABS		9'h1CD
`define LEA_ABSX	9'h1DD
`define LEA_RIND	9'h1D2
`define LEA_I		9'h1D2
`define LEA_DSP		9'h1C3

`define NOTHING		5'd0
`define SR_70		5'd1
`define SR_310		5'd2
`define BYTE_70		5'd3
`define WORD_310	5'd4
`define PC_70		5'd5
`define PC_158		5'd6
`define PC_2316		5'd7
`define PC_3124		5'd8
`define PC_310		5'd9
`define WORD_311	5'd10
`define IA_310		5'd11
`define IA_70		5'd12
`define IA_158		5'd13
`define BYTE_71		5'd14
`define WORD_312	5'd15
`define WORD_313	5'd16
`define WORD_314	5'd17
`define IA_2316		5'd18
`define HALF_70		5'd19
`define HALF_158	5'd20
`define HALF_71		5'd21
`define HALF_159	5'd22
`define HALF_71S	5'd23
`define HALF_159S	5'd24
`define BYTE_72		5'd25

`define STW_DEF		6'h0
`define STW_ACC		6'd1
`define STW_X		6'd2
`define STW_Y		6'd3
`define STW_PC		6'd4
`define STW_PC2		6'd5
`define STW_PCHWI	6'd6
`define STW_SR		6'd7
`define STW_RFA		6'd8
`define STW_RFA8	6'd9
`define STW_A		6'd10
`define STW_B		6'd11
`define STW_CALC	6'd12
`define STW_OPC		6'd13
`define STW_RES8	6'd14

`define STW_ACC8	6'd16
`define STW_X8		6'd17
`define STW_Y8		6'd18
`define STW_PC3124	6'd19
`define STW_PC2316	6'd20
`define STW_PC158	6'd21
`define STW_PC70	6'd22
`define STW_SR70	6'd23
`define STW_Z8		6'd24
`define STW_DEF8	6'd25
`define STW_DEF70	6'd26
`define STW_DEF158	6'd27

`define STW_ACC70	6'd32
`define STW_ACC158	6'd33
`define STW_X70		6'd34
`define STW_X158	6'd35
`define STW_Y70		6'd36
`define STW_Y158	6'd37
`define STW_Z70		6'd38
`define STW_Z158	6'd39
`define STW_DBR		6'd40
`define STW_DPR158	6'd41
`define STW_DPR70	6'd42
`define STW_TMP158	6'd43
`define STW_TMP70	6'd44
`define STW_IA158	6'd45
`define STW_IA70	6'd46

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
// Source file: rtl/verilog/rtf65002d.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2013, 2014  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//
// rtf65002.v
//  - 32 bit CPU
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
// ============================================================================
//
`include "rtf65002_defines.v"

module rtf65002d(rst_md, rst_i, clk_i, nmi_i, irq_i, irq_vect, bte_o, cti_o, bl_o, lock_o, cyc_o, stb_o, ack_i, rty_i, err_i, we_o, sel_o, adr_o, dat_i, dat_o, km_o);
parameter RESET1 = 6'd0;
parameter IFETCH = 6'd1;
parameter DECODE = 6'd2;
parameter STORE1 = 6'd3;
parameter STORE2 = 6'd4;
parameter CALC = 6'd5;
parameter JSR161 = 6'd6;
parameter RTS1 = 6'd7;
parameter IY3 = 6'd8;
parameter BSR1 = 6'd9;
parameter BYTE_IX5 = 6'd10;
parameter BYTE_IY5 = 6'd11;
parameter WAIT_DHIT = 6'd12;
parameter RESET2 = 6'd13;
parameter MULDIV1 = 6'd14;
parameter MULDIV2 = 6'd15;
parameter BYTE_DECODE = 6'd16;
parameter BYTE_CALC = 6'd17;
parameter BUS_ERROR = 6'd18;
parameter LOAD_MAC1 = 6'd19;
parameter LOAD_MAC2 = 6'd20;
parameter LOAD_MAC3 = 6'd21;
parameter MVN3 = 6'd22;
parameter PUSHA1 = 6'd23;
parameter POPA1 = 6'd24;
parameter BYTE_IFETCH = 6'd25;
parameter LOAD_DCACHE = 6'd26;
parameter LOAD_ICACHE = 6'd27;
parameter LOAD_IBUF1 = 6'd28;
parameter LOAD_IBUF2 = 6'd29;
parameter LOAD_IBUF3 = 6'd30;
parameter ICACHE1 = 6'd31;
parameter IBUF1 = 6'd32;
parameter DCACHE1 = 6'd33;
parameter CMPS1 = 6'd34;
parameter HALF_CALC = 6'd35;
parameter MVN816 = 6'd36;

parameter SPIN_CYCLES = 8'd30;

input rst_md;		// reset mode, 1=emulation mode, 0=native mode
input rst_i;
input clk_i;
input nmi_i;
input irq_i;
input [8:0] irq_vect;
output reg [1:0] bte_o;
output reg [2:0] cti_o;
output reg [5:0] bl_o;
output reg lock_o;
output reg cyc_o;
output reg stb_o;
input ack_i;
input rty_i;
input err_i;
output reg we_o;
output reg [3:0] sel_o;
output reg [33:0] adr_o;
input [31:0] dat_i;
output reg [31:0] dat_o;

output km_o;

reg [5:0] state;
reg [5:0] retstate;
wire [63:0] insn;
reg [63:0] ibuf;
reg [31:0] bufadr;
reg [63:0] exbuf;

integer n;
reg cf,nf,zf,vf,bf,im,df,em;
reg tf;		// trace mode flag
reg ttrig;	// trace trigger
reg em1;
reg gie;	// global interrupt enable (set when sp is loaded)
reg hwi;	// hardware interrupt indicator
reg nmoi;	// native mode on interrupt
wire [31:0] sr = {nf,vf,em,tf,17'b0,m816,m_bit,x_bit,3'b0,bf,df,im,zf,cf};
reg m_bit;	// acc/mem is 16 bit
reg x_bit;	// index regs are 16 bit
reg m816;	// 816 mode
wire m16 = m816 & ~m_bit;
wire xb16 = m816 & ~x_bit;
wire [7:0] sr8 = m816 ? {nf,vf,m_bit,x_bit,df,im,zf,cf} : {nf,vf,1'b0,bf,df,im,zf,cf};
reg nmi1,nmi_edge;
reg wai;
reg spi;		// spinlock interrupt
reg [7:0] spi_cnt;
reg wrrf;		// write register file
reg [31:0] acc;
reg [31:0] x;
reg [31:0] y;
reg [15:0] sp;
reg [15:0] dpr;		// direct page register
reg [7:0] dbr;		// data bank register
reg [31:0] spage;	// stack page
wire [7:0] acc8 = acc[7:0];
wire [7:0] x8 = x[7:0];
wire [7:0] y8 = y[7:0];
wire [15:0] acc16 = acc[15:0];
wire [15:0] x16 = x[15:0];
wire [15:0] y16 = y[15:0];
wire [31:0] x_dec = x - 32'd1;
wire [31:0] x_inc = x + 32'd1;
wire [31:0] y_dec = y - 32'd1;
wire [31:0] y_inc = y + 32'd1;
wire [31:0] acc_dec = acc - 32'd1;
wire [31:0] acc_inc = acc + 32'd1;
reg [31:0] isp;		// interrupt stack pointer
reg [31:0] oisp;	// original isp for bus retry
wire [63:0] prod;
reg [15:0] tmp16;
wire [31:0] q,r;
reg [31:0] tick;
wire [15:0] sp_dec = sp - 16'd1;
wire [15:0] sp_inc = sp + 16'd1;
wire [15:0] sp_dec2 = sp - 16'd2;
wire [31:0] isp_dec = isp - 32'd1;
wire [31:0] isp_inc = isp + 32'd1;
reg [3:0] suppress_pcinc;
reg [31:0] pc;
reg [31:0] opc;
wire [3:0] pc_inc;
reg [3:0] pc_inc2;
wire [3:0] pc_inc8;
wire [31:0] pcp2 = pc + (32'd2 & suppress_pcinc);	// for branches
wire [31:0] pcp4 = pc + (32'd4 & suppress_pcinc);	// for branches
wire [31:0] pcp8 = pc + 32'd8;						// cache controller needs this
reg [31:0] abs8;	// 8 bit mode absolute address register
reg [31:0] vbr;		// vector table base register
wire bhit=pc==bufadr;
reg [2:0] bcnt;		// burst count for cache controller
reg [31:0] regfile [15:0];
reg [63:0] ir;
reg pg2;
wire [8:0] ir9 = {pg2,ir[7:0]};
wire [3:0] Ra = ir[11:8];
wire [3:0] Rb = ir[15:12];
reg [31:0] rfoa;
reg [31:0] rfob;
always @(Ra or x or y or acc)
case(Ra)
4'h0:	rfoa <= 32'd0;
4'h1:	rfoa <= acc;
4'h2:	rfoa <= x;
4'h3:	rfoa <= y;
default:	rfoa <= regfile[Ra];
endcase
always @(Rb or x or y or acc)
case(Rb)
4'h0:	rfob <= 32'd0;
4'h1:	rfob <= acc;
4'h2:	rfob <= x;
4'h3:	rfob <= y;
default:	rfob <= regfile[Rb];
endcase
reg [3:0] Rt;
reg [33:0] ea;
reg first_ifetch;
reg [5:0] ic_whence;
reg [31:0] lfsr;
wire lfsr_fb; 
xnor(lfsr_fb,lfsr[0],lfsr[1],lfsr[21],lfsr[31]);
reg [31:0] a, b;
wire signed [31:0] as = a;
wire signed [31:0] bs = b;
wire lt = as < bs;
wire eq = a==b;
wire ltu = a < b;

reg [7:0] b8;
reg [15:0] b16;
wire [32:0] alu_out;
reg [32:0] res;
reg [16:0] res16;
reg [8:0] res8;
wire resv8,resv16,resv32;
wire resc8 = res8[8];
wire resc16 = res16[16];
wire resc32 = res[32];
wire resz8 = ~|res8[7:0];
wire resz16 = ~|res16[15:0];
wire resz32 = ~|res[31:0];
wire resn8 = res8[7];
wire resn16 = res16[15];
wire resn32 = res[31];

reg [33:0] vect;
reg [31:0] ia;			// temporary reg to hold indirect address
reg isInsnCacheLoad;
reg isDataCacheLoad;
reg isCacheReset;
wire hit0,hit1;
`ifdef SUPPORT_DCACHE
wire dhit;
`else
wire dhit = 1'b0;
`endif
reg write_allocate;
wire wr;
reg [3:0] wrsel;
reg [31:0] radr;
reg [1:0] radr2LSB;
wire [33:0] radr34 = {radr,radr2LSB};
wire [33:0] radr34p1 = radr34 + 34'd1;
reg [31:0] wadr;
reg [1:0] wadr2LSB;
reg [31:0] wdat;
wire [31:0] rdat;
reg [4:0] load_what;
reg [5:0] store_what;
reg [8:0] intno;			// interrupt number to take
reg [31:0] derr_address;
reg imiss;
reg dmiss;
reg icacheOn,dcacheOn;
`ifdef SUPPORT_DCACHE
wire unCachedData = radr[31:20]==12'hFFD || !dcacheOn;	// I/O area is uncached
`else
wire unCachedData = 1'b1;
`endif
`ifdef SUPPORT_ICACHE
wire unCachedInsn = pc[31:13]==19'h0 || !icacheOn;		// The lowest 8kB is uncached.
`else
wire unCachedInsn = 1'b1;
`endif
`ifdef ICACHE_2WAY
reg [31:0] clfsr;
wire clfsr_fb; 
xnor(clfsr_fb,clfsr[0],clfsr[1],clfsr[21],clfsr[31]);
wire [1:0] whichrd;
wire whichwr=clfsr[0];
`endif
reg [31:0] ilfsr;
wire ilfsr_fb;
xnor(ilfsr_fb,ilfsr[0],ilfsr[1],ilfsr[21],ilfsr[31]);
reg km;			// kernel mode indicator
assign km_o = km;

`ifdef DEBUG
reg [31:0] history_buf [127:0];
reg [6:0] history_ndx;
reg hist_capture;
`endif

reg isBusErr;
reg isBrk,isMove,isSts;
reg isMove816;
reg isRTI,isRTL,isRTS;
reg isOrb,isStb;
reg isRMW;
reg isSub,isSub8;
reg isJsrIndx,isJsrInd;
reg ldMuldiv;
reg isPusha,isPopa;

wire isCmp = ir9==`CPX_ZPX || ir9==`CPX_ABS || ir9==`CPX_IMM32 ||
			 ir9==`CPY_ZPX || ir9==`CPY_ABS || ir9==`CPY_IMM32;
wire isRMW32 =
			 ir9==`ASL_ZPX || ir9==`ROL_ZPX || ir9==`LSR_ZPX || ir9==`ROR_ZPX || ir9==`INC_ZPX || ir9==`DEC_ZPX ||
			 ir9==`ASL_ABS || ir9==`ROL_ABS || ir9==`LSR_ABS || ir9==`ROR_ABS || ir9==`INC_ABS || ir9==`DEC_ABS ||
			 ir9==`ASL_ABSX || ir9==`ROL_ABSX || ir9==`LSR_ABSX || ir9==`ROR_ABSX || ir9==`INC_ABSX || ir9==`DEC_ABSX ||
			 ir9==`TRB_ZP || ir9==`TRB_ZPX || ir9==`TRB_ABS || ir9==`TSB_ZP || ir9==`TSB_ZPX || ir9==`TSB_ABS ||
			 ir9==`BMS_ZPX || ir9==`BMS_ABS || ir9==`BMS_ABSX ||
			 ir9==`BMC_ZPX || ir9==`BMC_ABS || ir9==`BMC_ABSX ||
			 ir9==`BMF_ZPX || ir9==`BMF_ABS || ir9==`BMF_ABSX
			 ;
wire isRMW8 =
			 ir9==`ASL_ZP || ir9==`ROL_ZP || ir9==`LSR_ZP || ir9==`ROR_ZP || ir9==`INC_ZP || ir9==`DEC_ZP ||
			 ir9==`ASL_ZPX || ir9==`ROL_ZPX || ir9==`LSR_ZPX || ir9==`ROR_ZPX || ir9==`INC_ZPX || ir9==`DEC_ZPX ||
			 ir9==`ASL_ABS || ir9==`ROL_ABS || ir9==`LSR_ABS || ir9==`ROR_ABS || ir9==`INC_ABS || ir9==`DEC_ABS ||
			 ir9==`ASL_ABSX || ir9==`ROL_ABSX || ir9==`LSR_ABSX || ir9==`ROR_ABSX || ir9==`INC_ABSX || ir9==`DEC_ABSX ||
			 ir9==`TRB_ZP || ir9==`TRB_ZPX || ir9==`TRB_ABS || ir9==`TSB_ZP || ir9==`TSB_ZPX || ir9==`TSB_ABS;
			 ;

// Registerable decodes
// The following decodes can be registered because they aren't needed until at least the cycle after
// the DECODE stage.

always @(posedge clk)
	if (state==DECODE||state==BYTE_DECODE) begin
		isSub <= ir9==`SUB_ZPX || ir9==`SUB_IX || ir9==`SUB_IY ||
			 ir9==`SUB_ABS || ir9==`SUB_ABSX || ir9==`SUB_IMM8 || ir9==`SUB_IMM16 || ir9==`SUB_IMM32;
		isSub8 <= ir9==`SBC_ZP || ir9==`SBC_ZPX || ir9==`SBC_IX || ir9==`SBC_IY || ir9==`SBC_I ||
			 ir9==`SBC_ABS || ir9==`SBC_ABSX || ir9==`SBC_ABSY || ir9==`SBC_IMM;
		isRMW <= em ? isRMW8 : isRMW32;
		isOrb <= ir9==`ORB_ZPX || ir9==`ORB_IX || ir9==`ORB_IY || ir9==`ORB_ABS || ir9==`ORB_ABSX;
		isStb <= ir9==`STB_ZPX || ir9==`STB_ABS || ir9==`STB_ABSX;
		isRTI <= ir9==`RTI;
		isRTL <= ir9==`RTL;
		isRTS <= ir9==`RTS;
		isBrk <= ir9==`BRK;
		isMove <= ir9==`MVP || ir9==`MVN;
		isSts <= ir9==`STS;
		isJsrIndx <= ir9==`JSR_INDX;
		isJsrInd <= ir9==`JSR_IND;
		ldMuldiv <= ir9==`MUL_IMM8 || ir9==`MUL_IMM16 || ir9==`MUL_IMM32 ||
			ir9==`DIV_IMM8 || ir9==`MOD_IMM8 || ir9==`DIV_IMM16 || ir9==`DIV_IMM32 || ir9==`MOD_IMM16 || ir9==`MOD_IMM32 ||
			(ir9==`RR && (
			ir[23:20]==`MUL_RR || ir[23:20]==`MULS_RR || ir[23:20]==`DIV_RR || ir[23:20]==`DIVS_RR || ir[23:20]==`MOD_RR || ir[23:20]==`MODS_RR)); 
		isPusha <= ir9==`PUSHA;
		isPopa <= ir9==`POPA;
	end
	else
		ldMuldiv <= 1'b0;

`ifdef SUPPORT_EXEC
wire isExec = ir9==`EXEC;
wire isAtni = ir9==`ATNI;
`else
wire isExec = 1'b0;
wire isAtni = 1'b0;
`endif
wire md_done;
wire clk;
reg isIY;
reg isIY24;
reg isI24;

rtf65002_pcinc upci1
(
	.opcode(ir9),
	.suppress_pcinc(suppress_pcinc),
	.inc(pc_inc)
);

rtf65002_pcinc8 upci2
(
	.opcode(ir[7:0]),
	.suppress_pcinc(suppress_pcinc),
	.inc(pc_inc8),
	.m16(m16),
	.xb16(xb16)
);
	
mult_div umd1
(
	.rst(rst_i),
	.clk(clk),
	.ld(ldMuldiv),
	.op(ir9),
	.fn(ir[23:20]),
	.a(a),
	.b(b),
	.p(prod),
	.q(q),
	.r(r),
	.done(md_done)
);

`ifdef SUPPORT_ICACHE
`ifdef ICACHE_2WAY
rtf65002_icachemem2way icm0 (
	.whichrd(whichrd),
	.whichwr(whichwr),
	.wclk(clk),
	.wr(ack_i & isInsnCacheLoad),
	.adr(adr_o),
	.dat(dat_i),
	.rclk(~clk),
	.pc(pc),
	.insn(insn)
);

rtf65002_itagmem2way tgm0 (
	.whichrd(whichrd),
	.whichwr(isCacheReset ? adr_o[13]: whichwr),
	.wclk(clk),
	.wr((ack_i & isInsnCacheLoad)|isCacheReset),
	.adr({adr_o[31:1],!isCacheReset}),
	.rclk(~clk),
	.pc(pc),
	.hit0(hit0),
	.hit1(hit1)
);
`else
`ifdef ICACHE_4K
rtf65002_icachemem4k icm0 (
	.wclk(clk),
	.wr(ack_i & isInsnCacheLoad),
	.adr(adr_o),
	.dat(dat_i),
	.rclk(~clk),
	.pc(pc),
	.insn(insn)
);

rtf65002_itagmem4k tgm0 (
	.wclk(clk),
	.wr((ack_i & isInsnCacheLoad)|isCacheReset),
	.adr({adr_o[33:1],!isCacheReset}),
	.rclk(~clk),
	.pc(pc),
	.hit0(hit0),
	.hit1(hit1)
);
`endif
`ifdef ICACHE_8K
rtf65002_icachemem8k icm0 (
	.wclk(clk),
	.wr(ack_i & isInsnCacheLoad),
	.adr(adr_o),
	.dat(dat_i),
	.rclk(~clk),
	.pc(pc),
	.insn(insn)
);

rtf65002_itagmem8k tgm0 (
	.wclk(clk),
	.wr((ack_i & isInsnCacheLoad)|isCacheReset),
	.adr({adr_o[33:1],!isCacheReset}),
	.rclk(~clk),
	.pc(pc),
	.hit0(hit0),
	.hit1(hit1)
);
`endif
`ifdef ICACHE_16K
rtf65002_icachemem icm0 (
	.wclk(clk),
	.wr(ack_i & isInsnCacheLoad),
	.adr(adr_o),
	.dat(dat_i),
	.rclk(~clk),
	.pc(pc),
	.insn(insn)
);

rtf65002_itagmem tgm0 (
	.wclk(clk),
	.wr((ack_i & isInsnCacheLoad)|isCacheReset),
	.adr({adr_o[31:1],!isCacheReset}),
	.rclk(~clk),
	.pc(pc),
	.hit0(hit0),
	.hit1(hit1)
);
`endif
`endif	// ICACHE_2WAY

wire ihit = (hit0 & hit1);//(pc[2:0] > 3'd1 ? hit1 : 1'b1));
`else
wire ihit = 1'b0;
`endif

`ifdef SUPPORT_DCACHE
assign wr = state==STORE2 && dhit && ack_i;

rtf65002_dcachemem dcm0 (
	.wclk(clk),
	.wr(wr | (ack_i & isDataCacheLoad)),
	.sel(sel_o),
	.wadr(adr_o[33:2]),
	.wdat(wr ? dat_o : dat_i),
	.rclk(~clk),
	.radr(radr),
	.rdat(rdat)
);

rtf65002_dtagmem dtm0 (
	.wclk(clk),
	.wr(wr | (ack_i & isDataCacheLoad) | isCacheReset),
	.wadr(adr_o[33:2]),
	.cr(!isCacheReset),
	.rclk(~clk),
	.radr(radr),
	.hit(dhit)
);
`endif

overflow uovr1 (
	.op(isSub),
	.a(a[31]),
	.b(b[31]),
	.s(res[31]),
	.v(resv32)
);

overflow uovr2 (
	.op(isSub8),
	.a(acc8[7]),
	.b(b8[7]),
	.s(res8[7]),
	.v(resv8)
);

wire [15:0] bcaio;
wire [15:0] bcao;
wire [15:0] bcsio;
wire [15:0] bcso;
wire bcaico,bcaco,bcsico,bcsco;
wire bcaico8,bcaco8,bcsico8,bcsco8;

`ifdef SUPPORT_BCD
BCDAdd4 ubcdai1 (.ci(cf),.a(acc16),.b(ir[23:8]),.o(bcaio),.c(bcaico),.c8(bcaico8));
BCDAdd4 ubcda2 (.ci(cf),.a(acc16),.b(b8),.o(bcao),.c(bcaco),.c8(bcaco8));
BCDSub4 ubcdsi1 (.ci(cf),.a(acc16),.b(ir[23:8]),.o(bcsio),.c(bcsico),.c8(bcsico8));
BCDSub4 ubcds2 (.ci(cf),.a(acc16),.b(b8),.o(bcso),.c(bcsco),.c8(bcsco8));
`endif

reg [7:0] dati;
always @(radr2LSB or dat_i)
case(radr2LSB)
2'd0:	dati <= dat_i[7:0];
2'd1:	dati <= dat_i[15:8];
2'd2:	dati <= dat_i[23:16];
2'd3:	dati <= dat_i[31:24];
endcase
`ifdef SUPPORT_DCACHE
reg [7:0] rdat8;
always @(radr2LSB or rdat)
case(radr2LSB)
2'd0:	rdat8 <= rdat[7:0];
2'd1:	rdat8 <= rdat[15:8];
2'd2:	rdat8 <= rdat[23:16];
2'd3:	rdat8 <= rdat[31:24];
endcase
`endif

// Evaluate branches
// 
reg takb;
always @(ir9 or cf or vf or nf or zf)
case(ir9)
`BEQ:	takb <= zf;
`BNE:	takb <= !zf;
`BPL:	takb <= !nf;
`BMI:	takb <= nf;
`BCS:	takb <= cf;
`BCC:	takb <= !cf;
`BVS:	takb <= vf;
`BVC:	takb <= !vf;
`BRA:	takb <= 1'b1;
`BRL:	takb <= 1'b1;
`BHI:	takb <= cf & !zf;
`BLS:	takb <= !cf | zf;
`BGE:	takb <= (nf & vf)|(!nf & !vf);
`BLT:	takb <= (nf & !vf)|(!nf & vf);
`BGT:	takb <= (nf & vf & !zf) + (!nf & !vf & !zf);
`BLE:	takb <= zf | (nf & !vf)|(!nf & vf);
default:	takb <= 1'b0;
endcase

wire [31:0] mvnsrc_address	= {abs8[31:24],ir[23:16],x16};
wire [31:0] mvndst_address	= {abs8[31:24],ir[15: 8],y16};
wire [31:0] iapy8 			= ia + y16;		// Don't add in abs8, already included with ia
wire [31:0] zp_address 		= {abs8[31:16],8'h00,ir[15:8]} + dpr;
wire [31:0] zpx_address 	= {abs8[31:16],{8'h00,ir[15:8]} + x16} + dpr;
wire [31:0] zpy_address	 	= {abs8[31:16],{8'h00,ir[15:8]} + y16} + dpr;
wire [31:0] abs_address 	= {abs8[31:24],dbr,ir[23:8]};
wire [31:0] absx_address 	= {abs8[31:24],dbr,ir[23:8] + x16};	// simulates 64k bank wrap-around
wire [31:0] absy_address 	= {abs8[31:24],dbr,ir[23:8] + y16};
wire [31:0] al_address		= {abs8[31:24],ir[31:8]};
wire [31:0] alx_address		= {abs8[31:24],ir[31:8] + x16};
wire [31:0] zpx32xy_address 	= ir[23:12] + rfoa;
wire [31:0] absx32xy_address 	= ir[47:16] + rfob;
wire [31:0] zpx32_address 		= ir[31:20] + rfob;
wire [31:0] absx32_address 		= ir[55:24] + rfob;

wire [31:0] dsp_address = m816 ? {abs8[31:24],8'h00,sp + ir[15:8]} : {abs8[31:16],8'h01,sp[7:0]+ir[15:8]};

rtf65002_alu ualu1
(
	.clk(clk),
	.state(state),
	.resin(res),
	.pg2(pg2),
	.ir(ir),
	.acc(acc),
	.x(x),
	.y(y),
	.isp(isp),
	.rfoa(rfoa),
	.rfob(rfob),
	.a(a),
	.b(b),
	.b8(b8),
	.Rt(Rt),
	.icacheOn(icacheOn),
	.dcacheOn(dcacheOn),
	.write_allocate(write_allocate),
	.prod(prod),
	.tick(tick),
	.lfsr(lfsr),
	.abs8(abs8),
	.vbr(vbr),
	.nmoi(nmoi),
	.derr_address(derr_address),
	.history_buf(history_buf[history_ndx]),
	.spage(spage),
	.sp(sp),
	.df(df),
	.cf(cf),
	.res(alu_out)
);


//-----------------------------------------------------------------------------
// Clock control
// - reset or NMI reenables the clock
// - this circuit must be under the clk_i domain
//-----------------------------------------------------------------------------
//
reg cpu_clk_en;
reg clk_en;
BUFGCE u20 (.CE(cpu_clk_en), .I(clk_i), .O(clk) );

always @(posedge clk_i)
if (rst_i) begin
	cpu_clk_en <= 1'b1;
	nmi1 <= 1'b0;
end
else begin
	nmi1 <= nmi_i;
	if (nmi_i)
		cpu_clk_en <= 1'b1;
	else
		cpu_clk_en <= clk_en;
end

always @(posedge clk)
if (rst_i) begin
	bte_o <= 2'b00;
	cti_o <= 3'b000;
	bl_o <= 6'd0;
	cyc_o <= 1'b0;
	stb_o <= 1'b0;
	we_o <= 1'b0;
	sel_o <= 4'h0;
	adr_o <= 34'd0;
	dat_o <= 32'd0;
	nmi_edge <= 1'b0;
	wai <= 1'b0;
	spi <= 1'b0;
	spi_cnt <= SPIN_CYCLES;
	cf <= 1'b0;
	ir <= 64'hEAEAEAEAEAEAEAEA;
	imiss <= `FALSE;
	dmiss <= `FALSE;
	dcacheOn <= 1'b0;
	icacheOn <= 1'b1;
	write_allocate <= 1'b0;
	nmoi <= 1'b1;
	state <= RESET1;
	m816 <= 1'b0;
	m_bit <= 1'b1;
	x_bit <= 1'b1;
	if (rst_md) begin
		pc <= 32'h0000FFF0;		// set high-order pc to zero
		vect <= `BYTE_RST_VECT;
		em <= 1'b1;
	end
	else begin
		vect <= `RST_VECT;
		em <= 1'b0;
		pc <= 32'hFFFFFFF0;
	end
	suppress_pcinc <= 4'hF;
	exbuf <= 64'd0;
	dbr <= 8'h00;
	dpr <= 16'h0000;
	spage <= 32'h00000100;
	bufadr <= 32'd0;
	abs8 <= 32'd0;
	clk_en <= 1'b1;
	isCacheReset <= `TRUE;
	gie <= 1'b0;
	tick <= 32'd0;
	isIY <= 1'b0;
	isIY24 <= 1'b0;
	isI24 <= `FALSE;
	load_what <= `NOTHING;
`ifdef DEBUG
	hist_capture <= `TRUE;
	history_ndx <= 6'd0;
`endif
	pg2 <= `FALSE;
	tf <= `FALSE;
	km <= `TRUE;
	wrrf <= 1'b0;
end
else begin
wrrf <= 1'b0;
tick <= tick + 32'd1;
ilfsr <= {ilfsr,ilfsr_fb};
if (nmi_i & !nmi1)
	nmi_edge <= 1'b1;
if (nmi_i|nmi1)
	clk_en <= 1'b1;
case(state)
// Loop in this state until all the cache address tage have been flagged as
// invalid.
//
RESET1:
	begin
		adr_o <= adr_o + 32'd4;
		if (adr_o[13:4]==10'h3FF) begin
			state <= RESET2;
			isCacheReset <= `FALSE;
		end
	end
RESET2:
	begin
		radr <= vect[31:2];
		radr2LSB <= vect[1:0];
		load_what <= em ? `PC_70 : `PC_310;
		state <= LOAD_MAC1;
	end

`include "ifetch.v"
`ifdef SUPPORT_EM8
`include "byte_ifetch.v"
`include "byte_decode.v"
`include "byte_calc.v"
`ifdef SUPPORT_816
`include "half_calc.v"
`endif
`endif

`include "load_mac.v"
`include "store.v"

// This state waits for a data hit before continuing. It's used after a store 
// operation when write allocation is taking place.
WAIT_DHIT:
	if (dhit)
		state <= retstate;

DECODE:	decode_tsk();
CALC:	calc_tsk();

MULDIV1:	state <= MULDIV2;
MULDIV2:
	if (md_done) begin
		state <= IFETCH;
		case(ir9)
		`RR:
			case(ir[23:20])
			`MUL_RR:	begin res <= prod[31:0]; end
			`MULS_RR:	begin res <= prod[31:0]; end
`ifdef SUPPORT_DIVMOD
			`DIV_RR:	begin res <= q; end
			`DIVS_RR:	begin res <= q; end
			`MOD_RR:	begin res <= r; end
			`MODS_RR:	begin res <= r; end
`endif
			endcase
		`MUL_IMM8,`MUL_IMM16,`MUL_IMM32:	res <= prod[31:0];
`ifdef SUPPORT_DIVMOD
		`DIV_IMM8,`DIV_IMM16,`DIV_IMM32:	res <= q;
		`MOD_IMM8,`MOD_IMM16,`MOD_IMM32:	res <= r;
`endif
		endcase
	end

`ifdef SUPPORT_BERR
BUS_ERROR:
	begin
		pg2 <= `FALSE;
		ir <= {8{`BRK}};
`ifdef DEBUG
		hist_capture <= `FALSE;
`endif
		radr <= isp_dec;
		wadr <= isp_dec;
		isp <= isp_dec;
		store_what <= `STW_OPC;
		vect <= {vbr[31:9],intno,2'b00};
		hwi <= `TRUE;
		isBusErr <= `TRUE;
		next_state(STORE1);
	end
`endif

`include "rtf65002_string.v"
`include "cache_controller.v"

endcase

if (wrrf || state==IFETCH || state==LOAD_MAC3) begin
	regfile[Rt] <= res[31:0];
	case(Rt)
	4'h1:	acc <= res[31:0];
	4'h2:	x <= res[31:0];
	4'h3:	y <= res[31:0];
	default:	;
	endcase
end

end


`include "decode.v"
`include "calc.v"
`include "load_tsk.v"
`include "wb_task.v"
`include "misc_task.v"

task next_state;
input [5:0] nxt;
begin
	state <= nxt;
end
endtask

function [127:0] fnStateName;
input [5:0] state;
case(state)
RESET1:	fnStateName = "RESET1     ";
RESET2:	fnStateName = "RESET2     ";
IFETCH:	fnStateName = "IFETCH     ";
DECODE:	fnStateName = "DECODE     ";
STORE1:	fnStateName = "STORE1     ";
STORE2:	fnStateName = "STORE2     ";
CALC:	fnStateName = "CALC       ";
RTS1:	fnStateName = "RTS1       ";
IY3:	fnStateName = "IY3        ";
BYTE_IX5:	fnStateName = "BYTE_IX5   ";
BYTE_IY5:	fnStateName = "BYTE_IY5   ";
WAIT_DHIT:	fnStateName = "WAIT_DHIT  ";
MULDIV1:	fnStateName = "MULDIV1    ";
MULDIV2:	fnStateName = "MULDIV2    ";
BYTE_DECODE:	fnStateName = "BYTE_DECODE";
BYTE_CALC:	fnStateName = "BYTE_CALC  ";
BUS_ERROR:	fnStateName = "BUS_ERROR  ";
LOAD_MAC1:	fnStateName = "LOAD_MAC1  ";
LOAD_MAC2:	fnStateName = "LOAD_MAC2  ";
LOAD_MAC3:	fnStateName = "LOAD_MAC3  ";
MVN3:		fnStateName = "MVN3       ";
PUSHA1:		fnStateName = "PUSHA1     ";
POPA1:		fnStateName = "POPA1      ";
BYTE_IFETCH:	fnStateName = "BYTE_IFETCH";
LOAD_DCACHE:	fnStateName = "LOAD_DCACHE";
LOAD_ICACHE:	fnStateName = "LOAD_ICACHE";
LOAD_IBUF1:		fnStateName = "LOAD_IBUF1 ";
LOAD_IBUF2:		fnStateName = "LOAD_IBUF2 ";
LOAD_IBUF3:		fnStateName = "LOAD_IBUF3 ";
ICACHE1:		fnStateName = "ICACHE1    ";
IBUF1:			fnStateName = "IBUF1      ";
DCACHE1:		fnStateName = "DCACHE1    ";
CMPS1:			fnStateName = "CMPS1      ";
HALF_CALC:		fnStateName = "HALF_CALC  ";
default:		fnStateName = "UNKNOWN    ";
endcase
endfunction

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/mult_div.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//
// rtf65002.v
//  - 32 bit CPU multiplier/divider
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
// ============================================================================
//
`include "rtf65002_defines.v"

module mult_div(rst, clk, ld, op, fn, a, b, p, q, r, done);
parameter IDLE=3'd0;
parameter MULT1=3'd1;
parameter MULT2=3'd2;
parameter MULT3=3'd3;
parameter FIX_SIGN=3'd4;
parameter DIV=3'd5;
input rst;
input clk;
input ld;
input [8:0] op;
input [3:0] fn;
input [31:0] a;
input [31:0] b;
output reg [63:0] p;
output reg [31:0] q;
output reg [31:0] r;
output done;

reg [31:0] aa, bb;
reg res_sgn;

reg [2:0] state;

assign done = state==IDLE;
wire [31:0] diff = r - bb;
wire [31:0] pa = a[31] ? -a : a;
wire [63:0] p1 = aa * bb;
reg [5:0] cnt;

always @(posedge clk)
if (rst)
state <= IDLE;
else begin
case(state)
IDLE:
	if (ld) begin
		cnt <= 6'd32;
		case(op)
		`MUL_IMM8,`MUL_IMM16,`MUL_IMM32:
			begin
				aa <= a;
				bb <= b;
				res_sgn <= 1'b0;
				state <= MULT1;
			end
`ifdef SUPPORT_DIVMOD
		`DIV_IMM8,`DIV_IMM16,`DIV_IMM32,
		`MOD_IMM8,`MOD_IMM16,`MOD_IMM32:
			begin
				aa <= a;
				bb <= b;
				q <= a[30:0];
				r <= a[31];
				res_sgn <= 1'b0;
				state <= DIV;
			end
`endif
		`RR:
			case(fn)
			`MUL_RR:
				begin
					aa <= a;
					bb <= b;
					res_sgn <= 1'b0;
					state <= MULT1;
				end
			`MULS_RR:
				begin
					aa <= a[31] ? -a : a;
					bb <= b[31] ? -b : b;
					res_sgn <= a[31] ^ b[31];
					state <= MULT1;
				end
`ifdef SUPPORT_DIVMOD
			`DIV_RR,`MOD_RR:
				begin
					aa <= a;
					bb <= b;
					q <= a[30:0];
					r <= a[31];
					res_sgn <= 1'b0;
					state <= DIV;
				end
			`DIVS_RR,`MODS_RR:
				begin
					aa <= a[31] ? -a : a;
					bb <= b[31] ? -b : b;
					q <= pa[30:0];
					r <= pa[31];
					res_sgn <= a[31] ^ b[31];
					state <= DIV;
				end
`endif
			default:
				state <= IDLE;
			endcase
		endcase
	end
// Three waut states for the multiply to take effect. These are needed at
// higher clock frequencies. The multipler is a multi-cycle path that
// requires a timing constraint.
MULT1:	state <= MULT2;
MULT2:	state <= MULT3;
MULT3:	begin
			p <= p1;
			state <= res_sgn ? FIX_SIGN : IDLE;
		end

`ifdef SUPPORT_DIVMOD
DIV:
	begin
		q <= {q[30:0],~diff[31]};
		if (cnt==6'd0) begin
			state <= res_sgn ? FIX_SIGN : IDLE;
			if (diff[31])
				r <= r[30:0];
			else
				r <= diff[30:0];
		end
		else begin
			if (diff[31])
				r <= {r[30:0],q[31]};
			else
				r <= {diff[30:0],q[31]};
		end
		cnt <= cnt - 6'd1;
	end
`endif

FIX_SIGN:
	begin
		state <= IDLE;
		if (res_sgn) begin
			p <= -p;
			q <= -q;
			r <= -r;
		end
	end
default:	state <= IDLE;
endcase
end

endmodule

module multdiv_tb();
reg rst;
reg clk;
reg ld;

initial begin
	#0 clk = 1'b0;
	#0 rst = 1'b0;
	#10 rst = 1'b1;
	#10 rst = 1'b0;
	#10 ld = 1'b1;
	#20 ld = 1'b0;
end

always #10 clk = ~clk;

mult_div umd1 (
	.rst(rst),
	.clk(clk),
	.ld(ld),
	.op(`RR),
	.fn(`DIV_RR),
	.a(32'h12345678),
	.b(32'd10),
	.p(),
	.q(),
	.r(),
	.done()
);

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/overflow.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module overflow(op, a, b, s, v);

input op;	// 0=add,1=sub
input a;
input b;
input s;	// sum
output v;

// Overflow:
// Add: the signs of the inputs are the same, and the sign of the
// sum is different
// Sub: the signs of the inputs are different, and the sign of
// the sum is the same as B
assign v = (op ^ s ^ b) & (~op ^ a ^ b);

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_alu.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
`include "rtf65002_defines.v"

module rtf65002_alu(clk, state, resin, pg2, ir, acc, x, y, isp, rfoa, rfob, a, b, b8, Rt,
	icacheOn, dcacheOn, write_allocate, prod, tick, lfsr, abs8, vbr, nmoi,
	derr_address, history_buf, spage, sp, df, cf,
	res);
input clk;
input [5:0] state;
input [32:0] resin;
input pg2;
input [63:0] ir;
input [31:0] acc;
input [31:0] x;
input [31:0] y;
input [31:0] isp;
input [31:0] rfoa;
input [31:0] rfob;
input [31:0] a;
input [31:0] b;
input [7:0] b8;
input [3:0] Rt;
input icacheOn;
input dcacheOn;
input write_allocate;
input [63:0] prod;
input [31:0] tick;
input [31:0] lfsr;
input [31:0] abs8;
input [31:0] vbr;
input nmoi;
input [31:0] derr_address;
input [31:0] history_buf;
input [31:0] spage;
input [15:0] sp;
input df;
input cf;
output reg [32:0] res;

`ifdef SUPPORT_SHIFT
wire [31:0] shlo = a << b[4:0];
wire [31:0] shro = a >> b[4:0];
`else
wire [31:0] shlo = 32'd0;
wire [31:0] shro = 32'd0;
`endif

always @*
	case({pg2,ir[7:0]})
	`DEX:	res <= x - 32'd1;
	`INX:	res <= x + 32'd1;
	`DEY,`MVP:	res <= y - 32'd1;
	`INY:	res <= y + 32'd1;
	`STS,`MVN,`CMPS:	res <= y + 32'd1;
	`DEA:	res <= acc - 32'd1;
	`INA:	res <= acc + 32'd1;
	`TSX,`TSA:	res <= isp;
	`TXS,`TXA,`TXY:	res <= x;
	`TAX,`TAY,`TAS:	res <= acc;
	`TYA,`TYX:	res <= y;
	`TRS:		res <= rfoa;
	`TSR:		begin
					case(ir[11:8])
					4'h0:	
						begin
`ifdef SUPPORT_ICACHE
							res[0] <= icacheOn;
`endif
`ifdef SUPPORT_DCACHE
							res[1] <= dcacheOn;
							res[2] <= write_allocate;
`endif
							res[32:3] <= 30'd0;
						end
					4'h2:	res <= prod[31:0];
					4'h3:	res <= prod[63:32];
					4'h4:	res <= tick;
					4'h5:	res <= lfsr;
					4'd7:	res <= abs8;
					4'h8:	res <= {vbr[31:1],nmoi};
					4'h9:	res <= derr_address;
`ifdef DEBUG
					4'hA:	res <= history_buf;
`endif
					4'hE:	res <= {spage[31:16],sp};
					4'hF:	res <= isp;
					default:	res <= 33'd0;
					endcase
				end
	`ASL_ACC:	res <= {acc,1'b0};
	`ROL_ACC:	res <= {acc,cf};
	`LSR_ACC:	res <= {acc[0],1'b0,acc[31:1]};
	`ROR_ACC:	res <= {acc[0],cf,acc[31:1]};

	`RR:
		begin
			case(ir[23:20])
			`ADD_RR:	res <= rfoa + rfob + {31'b0,df&cf};
			`SUB_RR:	res <= rfoa - rfob - {31'b0,df&~cf&|ir[19:16]};
			`AND_RR:	res <= rfoa & rfob;
			`OR_RR:		res <= rfoa | rfob;
			`EOR_RR:	res <= rfoa ^ rfob;
`ifdef SUPPORT_SHIFT
			`ASL_RRR:	res <= shlo;
			`LSR_RRR:	res <= shro;
`endif
			default:	res <= 33'd0;
			endcase
		end
	`LD_RR:		res <= rfoa;
	`ASL_RR:	res <= {rfoa,1'b0};
	`ROL_RR:	res <= {rfoa,cf};
	`LSR_RR:	res <= {rfoa[0],1'b0,rfoa[31:1]};
	`ROR_RR:	res <= {rfoa[0],cf,rfoa[31:1]};
	`DEC_RR:	res <= rfoa - 32'd1;
	`INC_RR:	res <= rfoa + 32'd1;
	
	`ADD_R:		res <= rfoa + rfob + {31'b0,df&cf};
	`SUB_R:		res <= rfoa - rfob - {31'b0,df&~cf&|ir[15:12]};
	`AND_R:		res <= rfoa & rfob;
	`OR_R:		res <= rfoa | rfob;
	`EOR_R:		res <= rfoa ^ rfob;
	
	`ADD_IMM4:	res <= rfoa + {{28{ir[15]}},ir[15:12]} + {31'b0,df&cf};
	`SUB_IMM4:	res <= rfoa - {{28{ir[15]}},ir[15:12]} - {31'b0,df&~cf&|ir[11:8]};
	`OR_IMM4:	res <= rfoa | {{28{ir[15]}},ir[15:12]};
	`AND_IMM4: 	res <= rfoa & {{28{ir[15]}},ir[15:12]};
	`EOR_IMM4:	res <= rfoa ^ {{28{ir[15]}},ir[15:12]};

	`ADD_IMM8:	res <= rfoa + {{24{ir[23]}},ir[23:16]} + {31'b0,df&cf};
	`SUB_IMM8:	res <= rfoa - {{24{ir[23]}},ir[23:16]} - {31'b0,df&~cf&|ir[15:12]};
	`MUL_IMM8:	res <= 33'd0;
`ifdef SUPPORT_DIVMOD
	`DIV_IMM8:	res <= 33'd0;
	`MOD_IMM8:	res <= 33'd0;
`endif
	`OR_IMM8:	res <= rfoa | {{24{ir[23]}},ir[23:16]};
	`AND_IMM8: 	res <= rfoa & {{24{ir[23]}},ir[23:16]};
	`EOR_IMM8:	res <= rfoa ^ {{24{ir[23]}},ir[23:16]};
	`CMP_IMM8:	res <= acc - {{24{ir[15]}},ir[15:8]};


	`ADD_IMM16:	res <= rfoa + {{16{ir[31]}},ir[31:16]} + {31'b0,df&cf};
	`SUB_IMM16:	res <= rfoa - {{16{ir[31]}},ir[31:16]} - {31'b0,df&~cf&|ir[15:12]};
	`MUL_IMM16:	res <= 33'd0;
`ifdef SUPPORT_DIVMOD
	`DIV_IMM16:	res <= 33'd0;
	`MOD_IMM16:	res <= 33'd0;
`endif
	`OR_IMM16:	res <= rfoa | {{16{ir[31]}},ir[31:16]};
	`AND_IMM16:	
		begin
		res <= rfoa & {{16{ir[31]}},ir[31:16]};
		$display("%h & %h", rfoa, {{16{ir[31]}},ir[31:16]});
		end
	`EOR_IMM16:	res <= rfoa ^ {{16{ir[31]}},ir[31:16]};

	`ADD_IMM32:	res <= rfoa + ir[47:16] + {31'b0,df&cf};
	`SUB_IMM32:	res <= rfoa - ir[47:16] - {31'b0,df&~cf&|ir[15:12]};
	`MUL_IMM16:	res <= 33'd0;
`ifdef SUPPORT_DIVMOD
	`DIV_IMM32:	res <= 33'd0;
	`MOD_IMM32:	res <= 33'd0;
`endif
	`OR_IMM32:	res <= rfoa | ir[47:16];
	`AND_IMM32:	res <= rfoa & ir[47:16];
	`EOR_IMM32:	res <= rfoa ^ ir[47:16];

	`LDX_IMM32,`LDY_IMM32,`LDA_IMM32:	res <= ir[39:8];
	`LDX_IMM16,`LDA_IMM16:	res <= {{16{ir[23]}},ir[23:8]};
	`LDX_IMM8,`LDA_IMM8: res <= {{24{ir[15]}},ir[15:8]};

	`SUB_SP8:	res <= isp - {{24{ir[15]}},ir[15:8]};
	`SUB_SP16:	res <= isp - {{16{ir[23]}},ir[23:8]};
	`SUB_SP32:	res <= isp - ir[39:8];

	`CPX_IMM32:	res <= x - ir[39:8];
	`CPY_IMM32:	res <= y - ir[39:8];
	// The following results are available for CALC only after the DECODE/LOAD_MAC
	// stage as the 'a' and 'b' side registers need to be loaded.
	`ADD_ZPX,`ADD_IX,`ADD_IY,`ADD_ABS,`ADD_ABSX,`ADD_RIND,`ADD_DSP:	res <= a + b + {31'b0,df&cf};
	`SUB_ZPX,`SUB_IX,`SUB_IY,`SUB_ABS,`SUB_ABSX,`SUB_RIND,`SUB_DSP:	res <= a - b - {31'b0,df&~cf&|Rt}; // Also CMP
	`AND_ZPX,`AND_IX,`AND_IY,`AND_ABS,`AND_ABSX,`AND_RIND,`AND_DSP:	res <= a & b;	// Also BIT
	`OR_ZPX,`OR_IX,`OR_IY,`OR_ABS,`OR_ABSX,`OR_RIND,`OR_DSP:		res <= a | b;	// Also LD
	`EOR_ZPX,`EOR_IX,`EOR_IY,`EOR_ABS,`EOR_ABSX,`EOR_RIND,`EOR_DSP:	res <= a ^ b;
	`LDX_ZPY,`LDX_ABS,`LDX_ABSY:	res <= b;
	`LDY_ZPX,`LDY_ABS,`LDY_ABSX:	res <= b;
	`CPX_ZPX,`CPX_ABS:	res <= x - b;
	`CPY_ZPX,`CPY_ABS:	res <= y - b;
`ifdef SUPPORT_SHIFT
	`ASL_IMM8:	res <= shlo;
	`LSR_IMM8:	res <= shro;
`endif
	`ASL_ZPX,`ASL_ABS,`ASL_ABSX:	res <= {b,1'b0};
	`ROL_ZPX,`ROL_ABS,`ROL_ABSX:	res <= {b,cf};
	`LSR_ZPX,`LSR_ABS,`LSR_ABSX:	res <= {b[0],1'b0,b[31:1]};
	`ROR_ZPX,`ROR_ABS,`ROR_ABSX:	res <= {b[0],cf,b[31:1]};
	`INC_ZPX,`INC_ABS,`INC_ABSX:	res <= b + 32'd1;
	`DEC_ZPX,`DEC_ABS,`DEC_ABSX:	res <= b - 32'd1;
	`ORB_ZPX,`ORB_ABS,`ORB_ABSX:	res <= a | {24'h0,b8};
	`BMS_ZPX,`BMS_ABS,`BMS_ABSX:	res <= b | (32'b1 << acc[4:0]);
	`BMC_ZPX,`BMC_ABS,`BMC_ABSX:	res <= b & (~(32'b1 << acc[4:0]));
	`BMF_ZPX,`BMF_ABS,`BMF_ABSX:	res <= b ^ (32'b1 << acc[4:0]);
	`BMT_ZPX,`BMT_ABS,`BMT_ABSX:	res <= b & (32'b1 << acc[4:0]);
	`TRB_ZPX,`TRB_ABS:	res <= ~a & b;
	`TSB_ZPX,`TSB_ABS:	res <= a | b;
	`SPL_ABS,`SPL_ABSX:	res <= b;
	default:	res <= 33'd0;
	endcase
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_dcachemem.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_dcachemem(wclk, wr, sel, wadr, wdat, rclk, radr, rdat);
input wclk;
input wr;
input [3:0] sel;
input [31:0] wadr;
input [31:0] wdat;
input rclk;
input [31:0] radr;
output [31:0] rdat;

syncRam2kx32_1rw1r ram0 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wsel(sel),
	.wadr(wadr[10:0]),
	.i(wdat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(radr[10:0]),
	.o(rdat)
);

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_dtagmem.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_dtagmem(wclk, wr, wadr, cr, rclk, radr, hit);
input wclk;
input wr;
input [31:0] wadr;
input cr;
input rclk;
input [31:0] radr;
output hit;

reg [31:0] rradr;
wire [31:0] tag;

syncRam512x32_1rw1r u1
	(
		.wrst(1'b0),
		.wclk(wclk),
		.wce(1'b1),
		.we(wr),
		.wadr(wadr[10:2]),
		.i({wadr[31:1],cr}),
		.wo(),
		.rrst(1'b0),
		.rclk(rclk),
		.rce(1'b1),
		.radr(radr[10:2]),
		.o(tag)
	);


always @(posedge rclk)
	rradr <= radr;
	
assign hit = tag[31:11]==rradr[31:11] && tag[0];

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_icachemem.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_icachemem(wclk, wr, adr, dat, rclk, pc, insn);
input wclk;
input wr;
input [33:0] adr;
input [31:0] dat;
input rclk;
input [31:0] pc;
output reg [63:0] insn;

wire [63:0] insn0;
wire [63:0] insn1;
wire [31:0] pcp8 = pc + 32'd8;
reg [31:0] rpc;

always @(posedge rclk)
	rpc <= pc;

// memL and memH combined allow a 64 bit read
syncRam2kx32_1rw1r ramL0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[13:3]),
	.o(insn0[31:0])
);

syncRam2kx32_1rw1r ramH0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[13:3]),
	.o(insn0[63:32])
);

syncRam2kx32_1rw1r ramL1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[13:3]),
	.o(insn1[31:0])
);

syncRam2kx32_1rw1r ramH1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[13:3]),
	.o(insn1[63:32])
);

always @(rpc or insn0 or insn1)
case(rpc[2:0])
3'd0:	insn <= insn0[63:0];
3'd1:	insn <= {insn1[7:0],insn0[63:8]};
3'd2:	insn <= {insn1[15:0],insn0[63:16]};
3'd3:	insn <= {insn1[23:0],insn0[63:24]};
3'd4:	insn <= {insn1[31:0],insn0[63:32]};
3'd5:	insn <= {insn1[39:0],insn0[63:40]};
3'd6:	insn <= {insn1[47:0],insn0[63:48]};
3'd7:	insn <= {insn1[55:0],insn0[63:56]};
endcase 
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_icachemem16k.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_icachemem(wclk, wr, adr, dat, rclk, pc, insn);
input wclk;
input wr;
input [33:0] adr;
input [31:0] dat;
input rclk;
input [31:0] pc;
output reg [63:0] insn;

wire [63:0] insn0;
wire [63:0] insn1;
wire [31:0] pcp8 = pc + 32'd8;
reg [31:0] rpc;

always @(posedge rclk)
	rpc <= pc;

// memL and memH combined allow a 64 bit read
syncRam2kx32_1rw1r ramL0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[13:3]),
	.o(insn0[31:0])
);

syncRam2kx32_1rw1r ramH0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[13:3]),
	.o(insn0[63:32])
);

syncRam2kx32_1rw1r ramL1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[13:3]),
	.o(insn1[31:0])
);

syncRam2kx32_1rw1r ramH1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[13:3]),
	.o(insn1[63:32])
);

always @(rpc or insn0 or insn1)
case(rpc[2:0])
3'd0:	insn <= insn0[63:0];
3'd1:	insn <= {insn1[7:0],insn0[63:8]};
3'd2:	insn <= {insn1[15:0],insn0[63:16]};
3'd3:	insn <= {insn1[23:0],insn0[63:24]};
3'd4:	insn <= {insn1[31:0],insn0[63:32]};
3'd5:	insn <= {insn1[39:0],insn0[63:40]};
3'd6:	insn <= {insn1[47:0],insn0[63:48]};
3'd7:	insn <= {insn1[55:0],insn0[63:56]};
endcase 
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_icachemem2way.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_icachemem2way(whichrd, whichwr, wclk, wr, adr, dat, rclk, pc, insn);
input [1:0] whichrd;	// which set to read
input whichwr;			// which set to update
input wclk;
input wr;
input [33:0] adr;
input [31:0] dat;
input rclk;
input [31:0] pc;
output reg [63:0] insn;

wire [63:0] insn0a,insn0b;
wire [63:0] insn1a,insn1b;
wire [31:0] pcp8 = pc + 32'd8;
reg [31:0] rpc;

always @(posedge rclk)
	rpc <= pc;

// memL and memH combined allow a 64 bit read
syncRam1kx32_1rw1r ramL0a
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2] & ~whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0a[31:0])
);

syncRam1kx32_1rw1r ramH0a
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2] & ~whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0a[63:32])
);

syncRam1kx32_1rw1r ramL1a
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2] & ~whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1a[31:0])
);

syncRam1kx32_1rw1r ramH1a
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2] & ~whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1a[63:32])
);

syncRam1kx32_1rw1r ramL0b
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2] & whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0b[31:0])
);

syncRam1kx32_1rw1r ramH0b
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2] & whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0b[63:32])
);

syncRam1kx32_1rw1r ramL1b
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2] & whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1b[31:0])
);

syncRam1kx32_1rw1r ramH1b
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2] & whichwr),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1b[63:32])
);

always @(rpc or insn0a or insn1a or insn0b or insn1b or whichrd)
case({whichrd,rpc[2:0]})
5'd0:	insn <= insn0a[63:0];
5'd1:	insn <= {insn1a[7:0],insn0a[63:8]};
5'd2:	insn <= {insn1a[15:0],insn0a[63:16]};
5'd3:	insn <= {insn1a[23:0],insn0a[63:24]};
5'd4:	insn <= {insn1a[31:0],insn0a[63:32]};
5'd5:	insn <= {insn1a[39:0],insn0a[63:40]};
5'd6:	insn <= {insn1a[47:0],insn0a[63:48]};
5'd7:	insn <= {insn1a[55:0],insn0a[63:56]};
5'd8:	insn <= insn0b[63:0];
5'd9:	insn <= {insn1b[7:0],insn0b[63:8]};
5'd10:	insn <= {insn1b[15:0],insn0b[63:16]};
5'd11:	insn <= {insn1b[23:0],insn0b[63:24]};
5'd12:	insn <= {insn1b[31:0],insn0b[63:32]};
5'd13:	insn <= {insn1b[39:0],insn0b[63:40]};
5'd14:	insn <= {insn1b[47:0],insn0b[63:48]};
5'd15:	insn <= {insn1b[55:0],insn0b[63:56]};
5'd16:	insn <= insn0a[63:0];
5'd17:	insn <= {insn1b[7:0],insn0a[63:8]};
5'd18:	insn <= {insn1b[15:0],insn0a[63:16]};
5'd19:	insn <= {insn1b[23:0],insn0a[63:24]};
5'd20:	insn <= {insn1b[31:0],insn0a[63:32]};
5'd21:	insn <= {insn1b[39:0],insn0a[63:40]};
5'd22:	insn <= {insn1b[47:0],insn0a[63:48]};
5'd23:	insn <= {insn1b[55:0],insn0a[63:56]};
5'd24:	insn <= insn0b[63:0];
5'd25:	insn <= {insn1a[7:0],insn0b[63:8]};
5'd26:	insn <= {insn1a[15:0],insn0b[63:16]};
5'd27:	insn <= {insn1a[23:0],insn0b[63:24]};
5'd28:	insn <= {insn1a[31:0],insn0b[63:32]};
5'd29:	insn <= {insn1a[39:0],insn0b[63:40]};
5'd30:	insn <= {insn1a[47:0],insn0b[63:48]};
5'd31:	insn <= {insn1a[55:0],insn0b[63:56]};
endcase 
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_icachemem4k.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_icachemem4k(wclk, wr, adr, dat, rclk, pc, insn);
input wclk;
input wr;
input [33:0] adr;
input [31:0] dat;
input rclk;
input [31:0] pc;
output reg [63:0] insn;

wire [63:0] insn0;
wire [63:0] insn1;
wire [31:0] pcp8 = pc + 32'd8;
reg [31:0] rpc;

always @(posedge rclk)
	rpc <= pc;

// memL and memH combined allow a 64 bit read
syncRam512x32_1rw1r ramL0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wadr(adr[11:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[11:3]),
	.o(insn0[31:0])
);

syncRam512x32_1rw1r ramH0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wadr(adr[11:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[11:3]),
	.o(insn0[63:32])
);

syncRam512x32_1rw1r ramL1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wadr(adr[11:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[11:3]),
	.o(insn1[31:0])
);

syncRam512x32_1rw1r ramH1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wadr(adr[11:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[11:3]),
	.o(insn1[63:32])
);

always @(rpc or insn0 or insn1)
case(rpc[2:0])
3'd0:	insn <= insn0[63:0];
3'd1:	insn <= {insn1[7:0],insn0[63:8]};
3'd2:	insn <= {insn1[15:0],insn0[63:16]};
3'd3:	insn <= {insn1[23:0],insn0[63:24]};
3'd4:	insn <= {insn1[31:0],insn0[63:32]};
3'd5:	insn <= {insn1[39:0],insn0[63:40]};
3'd6:	insn <= {insn1[47:0],insn0[63:48]};
3'd7:	insn <= {insn1[55:0],insn0[63:56]};
endcase 
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_icachemem8k.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_icachemem8k(wclk, wr, adr, dat, rclk, pc, insn);
input wclk;
input wr;
input [33:0] adr;
input [31:0] dat;
input rclk;
input [31:0] pc;
output reg [63:0] insn;

wire [63:0] insn0;
wire [63:0] insn1;
wire [31:0] pcp8 = pc + 32'd8;
reg [31:0] rpc;

always @(posedge rclk)
	rpc <= pc;

// memL and memH combined allow a 64 bit read
syncRam1kx32_1rw1r ramL0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0[31:0])
);

syncRam1kx32_1rw1r ramH0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0[63:32])
);

syncRam1kx32_1rw1r ramL1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1[31:0])
);

syncRam1kx32_1rw1r ramH1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1[63:32])
);

always @(rpc or insn0 or insn1)
case(rpc[2:0])
3'd0:	insn <= insn0[63:0];
3'd1:	insn <= {insn1[7:0],insn0[63:8]};
3'd2:	insn <= {insn1[15:0],insn0[63:16]};
3'd3:	insn <= {insn1[23:0],insn0[63:24]};
3'd4:	insn <= {insn1[31:0],insn0[63:32]};
3'd5:	insn <= {insn1[39:0],insn0[63:40]};
3'd6:	insn <= {insn1[47:0],insn0[63:48]};
3'd7:	insn <= {insn1[55:0],insn0[63:56]};
endcase 
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_itagmem.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_itagmem(wclk, wr, adr, rclk, pc, hit0, hit1);
input wclk;
input wr;
input [33:0] adr;
input rclk;
input [31:0] pc;
output hit0;
output hit1;

wire [31:0] pcp8 = pc + 32'd8;
wire [31:0] tag0;
wire [31:0] tag1;
reg [31:0] rpc;
reg [31:0] rpcp8;

always @(posedge rclk)
	rpc <= pc;
always @(posedge rclk)
	rpcp8 <= pcp8;

syncRam1kx32_1rw1r ram0 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[13:4]),
	.o(tag0)
);

syncRam1kx32_1rw1r ram1 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[13:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[13:4]),
	.o(tag1)
);

assign hit0 = tag0[31:14]==rpc[31:14] && tag0[0];
assign hit1 = tag1[31:14]==rpcp8[31:14] && tag1[0];

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_itagmem2way.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_itagmem2way(whichrd, whichwr, wclk, wr, adr, rclk, pc, hit0, hit1);
output reg [1:0] whichrd;
input whichwr;
input wclk;
input wr;
input [33:0] adr;
input rclk;
input [31:0] pc;
output reg hit0;
output reg hit1;

wire [31:0] pcp8 = pc + 32'd8;
wire [31:0] tag0a,tag0b;
wire [31:0] tag1a,tag1b;
reg [31:0] rpc;
reg [31:0] rpcp8;
wire hit0a,hit1a;
wire hit0b,hit1b;

always @(posedge rclk)
	rpc <= pc;
always @(posedge rclk)
	rpcp8 <= pcp8;

syncRam512x32_1rw1r ram0 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(!whichwr),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(tag0a)
);

syncRam512x32_1rw1r ram1 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(!whichwr),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:4]),
	.o(tag1a)
);

syncRam512x32_1rw1r ram2 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(whichwr),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(tag0b)
);

syncRam512x32_1rw1r ram3 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(whichwr),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:4]),
	.o(tag1b)
);

assign hit0a = tag0a[31:13]==rpc[31:13] && tag0a[0];
assign hit1a = tag1a[31:13]==rpcp8[31:13] && tag1a[0];
assign hit0b = tag0b[31:13]==rpc[31:13] && tag0b[0];
assign hit1b = tag1b[31:13]==rpcp8[31:13] && tag1b[0];

always @(hit0a or hit1a or hit0b or hit1b or whichwr)
if (hit0a & hit1a) begin
	hit0 <= 1'b1;
	hit1 <= 1'b1;
	whichrd <= 2'b00;
end
else if (hit0b & hit1b) begin
	hit0 <= 1'b1;
	hit1 <= 1'b1;
	whichrd <= 2'b01;
end
else if (hit0a & hit1b) begin
	hit0 <= 1'b1;
	hit1 <= 1'b1;
	whichrd <= 2'b10;
end
else if (hit0b & hit1a) begin
	hit0 <= 1'b1;
	hit1 <= 1'b1;
	whichrd <= 2'b11;
end
else begin
	whichrd <= 2'b00;
	if (whichwr) begin
		hit0 <= hit0b;
		hit1 <= hit1b;
	end
	else begin
		hit0 <= hit0a;
		hit1 <= hit1a;
	end
end


endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_itagmem4k.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_itagmem4k(wclk, wr, adr, rclk, pc, hit0, hit1);
input wclk;
input wr;
input [33:0] adr;
input rclk;
input [31:0] pc;
output hit0;
output hit1;

wire [31:0] pcp8 = pc + 32'd8;
wire [31:0] tag0;
wire [31:0] tag1;
reg [31:0] rpc;
reg [31:0] rpcp8;

always @(posedge rclk)
	rpc <= pc;
always @(posedge rclk)
	rpcp8 <= pcp8;

// Note that only 1/2 the tag ram is used.
syncRam512x32_1rw1r ram0 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wadr({1'b0,adr[11:4]}),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr({1'b0,pc[11:4]}),
	.o(tag0)
);

syncRam512x32_1rw1r ram1 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wadr({1'b0,adr[11:4]}),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr({1'b0,pcp8[11:4]}),
	.o(tag1)
);

assign hit0 = tag0[31:12]==rpc[31:12] && tag0[0];
assign hit1 = tag1[31:12]==rpcp8[31:12] && tag1[0];

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_itagmem8k.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
module rtf65002_itagmem8k(wclk, wr, adr, rclk, pc, hit0, hit1);
input wclk;
input wr;
input [33:0] adr;
input rclk;
input [31:0] pc;
output hit0;
output hit1;

wire [31:0] pcp8 = pc + 32'd8;
wire [31:0] tag0;
wire [31:0] tag1;
reg [31:0] rpc;
reg [31:0] rpcp8;

always @(posedge rclk)
	rpc <= pc;
always @(posedge rclk)
	rpcp8 <= pcp8;

syncRam512x32_1rw1r ram0 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(tag0)
);

syncRam512x32_1rw1r ram1 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:4]),
	.o(tag1)
);

assign hit0 = tag0[31:13]==rpc[31:13] && tag0[0];
assign hit1 = tag1[31:13]==rpcp8[31:13] && tag1[0];

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_pcinc.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
`include "rtf65002_defines.v"

// This table being setup to set the pc increment. It should synthesize to a ROM.
module rtf65002_pcinc(opcode,suppress_pcinc,inc);
input [8:0] opcode;
input [3:0] suppress_pcinc;
output reg [3:0] inc;

always @(opcode,suppress_pcinc)
if (suppress_pcinc==4'hF)
	case(opcode)
	`BRK:	inc <= 4'd0;
	`INT0,`INT1: inc <= 4'd0;
	`BPL,`BMI,`BCS,`BCC,`BVS,`BVC,`BEQ,`BNE,`BRA,`BGT,`BLE,`BGE,`BLT,`BHI,`BLS:	inc <= 4'd2;
	`BRL: inc <= 4'd3;
	`EXEC,`ATNI: inc <= 4'd2;
	`CLC,`SEC,`CLD,`SED,`CLV,`CLI,`SEI:	inc <= 4'd1;
	`TAS,`TSA,`TAY,`TYA,`TAX,`TXA,`TSX,`TXS,`TYX,`TXY:	inc <= 4'd1;
	`TRS,`TSR: inc <= 4'd2;
	`INY,`DEY,`INX,`DEX,`INA,`DEA: inc <= 4'd1;
	`XCE: inc <= 4'd1;
	`STP,`WAI: inc <= 4'd1;
	`JMP,`JML,`JMP_IND,`JMP_INDX,`JMP_RIND,
	`JSR,`JSR_RIND,`JSL,`BSR,`JSR_INDX,`RTS,`RTL,`RTI: inc <= 4'd0;
	`JML,`JSL,`JMP_IND,`JMP_INDX,`JSR_INDX:	inc <= 4'd5;
	`JMP_RIND,`JSR_RIND: inc <= 4'd2;
	`NOP: inc <= 4'd1;
	`BSR: inc <= 4'd3;
	`RR: inc <= 4'd3;
	`LD_RR:	inc <= 4'd2;
	`ADD_IMM4,`SUB_IMM4,`AND_IMM4,`OR_IMM4,`EOR_IMM4,
	`ADD_R,`SUB_R,`AND_R,`OR_R,`EOR_R:	inc <= 4'd2;
	`ADD_IMM8,`SUB_IMM8,`AND_IMM8,`OR_IMM8,`EOR_IMM8,`ASL_IMM8,`LSR_IMM8:	inc <= 4'd3;
	`MUL_IMM8,`DIV_IMM8,`MOD_IMM8: inc <= 4'd3;
	`LDX_IMM8,`LDA_IMM8,`CMP_IMM8,`SUB_SP8: inc <= 4'd2;
	`ADD_IMM16,`SUB_IMM16,`AND_IMM16,`OR_IMM16,`EOR_IMM16:	inc <= 4'd4;
	`MUL_IMM16,`DIV_IMM16,`MOD_IMM16: inc <= 4'd4;
	`LDX_IMM16,`LDA_IMM16,`SUB_SP16: inc <= 4'd3;
	`ADD_IMM32,`SUB_IMM32,`AND_IMM32,`OR_IMM32,`EOR_IMM32:	inc <= 4'd6;
	`MUL_IMM32,`DIV_IMM32,`MOD_IMM32: inc <= 4'd6;
	`LDX_IMM32,`LDY_IMM32,`LDA_IMM32,`SUB_SP32,`CPX_IMM32,`CPY_IMM32: inc <= 4'd5;
	`ADD_ZPX,`SUB_ZPX,`AND_ZPX,`OR_ZPX,`EOR_ZPX,`LEA_ZPX: inc <= 4'd4;
	`ADD_IX,`SUB_IX,`AND_IX,`OR_IX,`EOR_IX,`LEA_IX: inc <= 4'd4;
	`ADD_IY,`SUB_IY,`AND_IY,`OR_IY,`EOR_IY,`LEA_IY: inc <= 4'd4;
	`ADD_ABS,`SUB_ABS,`AND_ABS,`OR_ABS,`EOR_ABS,`LEA_ABS: inc <= 4'd6;
	`ADD_ABSX,`SUB_ABSX,`AND_ABSX,`OR_ABSX,`EOR_ABSX,`LEA_ABSX: inc <= 4'd7;
	`ADD_RIND,`SUB_RIND,`AND_RIND,`OR_RIND,`EOR_RIND,`LEA_RIND: inc <= 4'd3;
	`ADD_DSP,`SUB_DSP,`AND_DSP,`OR_DSP,`EOR_DSP,`LEA_DSP: inc <= 4'd3;
	`ASL_ACC,`LSR_ACC,`ROR_ACC,`ROL_ACC: inc <= 4'd1;
	`ASL_RR,`ROL_RR,`LSR_RR,`ROR_RR,`INC_RR,`DEC_RR: inc <= 4'd2;
	`ST_RIND: inc <= 4'd2;
	`LDX_ZPX,`LDY_ZPX,`ST_DSP,`STX_ZPX,`STY_ZPX,`CPX_ZPX,`CPY_ZPX,
	`BMS_ZPX,`BMC_ZPX,`BMF_ZPX,`BMT_ZPX,
	`ASL_ZPX,`ROL_ZPX,`LSR_ZPX,`ROR_ZPX,`INC_ZPX,`DEC_ZPX,
	`ADD_DSP,`SUB_DSP,`OR_DSP,`AND_DSP,`EOR_DSP: inc <= 4'd3;
	`ORB_ZPX,`ST_ZPX,`STB_ZPX,`ADD_ZPX,`SUB_ZPX,`OR_ZPX,`AND_ZPX,`EOR_ZPX,
	`ADD_IX,`SUB_IX,`OR_IX,`AND_IX,`EOR_IX,`ST_IX,
	`ADD_IY,`SUB_IY,`OR_IY,`AND_IY,`EOR_IY,`ST_IY: inc <= 4'd4;
	`LDX_ABS,`LDY_ABS,`STX_ABS,`STY_ABS,
	`BMS_ABS,`BMC_ABS,`BMF_ABS,`BMT_ABS,
	`ASL_ABS,`ROL_ABS,`LSR_ABS,`ROR_ABS,`INC_ABS,`DEC_ABS,`CPX_ABS,`CPY_ABS: inc <= 4'd5;
	`ORB_ABS,`LDX_ABSY,`LDY_ABSX,`ST_ABS,`STB_ABS,
	`ADD_ABS,`SUB_ABS,`OR_ABS,`AND_ABS,`EOR_ABS,
	`BMS_ABSX,`BMC_ABSX,`BMF_ABSX,`BMT_ABSX,
	`ASL_ABSX,`ROL_ABSX,`LSR_ABSX,`ROR_ABSX,`INC_ABSX,`DEC_ABSX,`SPL_ABSX: inc <= 4'd6;
	`ORB_ABSX,`ST_ABSX,`STB_ABSX,
	`ADD_ABSX,`SUB_ABSX,`OR_ABSX,`AND_ABSX,`EOR_ABSX: inc <= 4'd7;
	`PHP,`PHA,`PHX,`PHY,`PLP,`PLA,`PLX,`PLY: inc <= 4'd1;
	`PUSH,`POP: inc <= 4'd2;
	`MVN,`MVP,`STS: inc <= 4'd1;
	`PG2:	inc <= 4'd1;
	`TON,`TOFF:	inc <= 4'd1;
	`PUSHA,`POPA: inc <= 4'd1;
	`SPL_ABS:	inc <= 4'd5;
	default:	inc <= 4'd0;	// unimplemented instruction
	endcase
else
	inc <= 4'd0;
endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/rtf65002_pcinc8.v
// -----------------------------------------------------------------------------
// ============================================================================
//        __
//   \\__/ o\    (C) 2013, 2014  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// ============================================================================
//
`include "rtf65002_defines.v"

module rtf65002_pcinc8(opcode,suppress_pcinc,inc,m16,xb16);
input [7:0] opcode;
input [3:0] suppress_pcinc;
output reg [3:0] inc;
input m16;
input xb16;

always @(opcode,suppress_pcinc)
if (suppress_pcinc==4'hF)
	case(opcode)
	`SEP,`REP:	inc <= 4'd2;
	`BRK:	inc <= 4'd0;
	`BPL,`BMI,`BCS,`BCC,`BVS,`BVC,`BEQ,`BNE,`BRA:	inc <= 4'd2;
	`BRL: inc <= 4'd3;
	`CLC,`SEC,`CLD,`SED,`CLV,`CLI,`SEI:	inc <= 4'd1;
	`TAS,`TSA,`TAY,`TYA,`TAX,`TXA,`TSX,`TXS,`TYX,`TXY,`TCD,`TDC,`XBA:	inc <= 4'd1;
	`INY,`DEY,`INX,`DEX,`INA,`DEA: inc <= 4'd1;
	`XCE,`WDM: inc <= 4'd1;
	`STP,`WAI: inc <= 4'd1;
	`JMP,`JML,`JMP_IND,`JMP_INDX,
	`RTS,`RTL,`RTI: inc <= 4'd0;
	`JSR,`JSR_INDX:	inc <= 4'd2;
	`JSL:	inc <= 4'd3;
	`NOP: inc <= 4'd1;

	`ADC_IMM,`SBC_IMM,`CMP_IMM,`AND_IMM,`ORA_IMM,`EOR_IMM,`LDA_IMM,`BIT_IMM:	inc <= m16 ? 4'd3 : 4'd2;
	`LDX_IMM,`LDY_IMM,`CPX_IMM,`CPY_IMM: inc <= xb16 ? 4'd3 : 4'd2;

	`TRB_ZP,`TSB_ZP,
	`ADC_ZP,`SBC_ZP,`CMP_ZP,`AND_ZP,`ORA_ZP,`EOR_ZP,`LDA_ZP,`STA_ZP: inc <= 4'd2;
	`LDY_ZP,`LDX_ZP,`STY_ZP,`STX_ZP,`CPX_ZP,`CPY_ZP,`BIT_ZP,`STZ_ZP: inc <= 4'd2;
	`ASL_ZP,`ROL_ZP,`LSR_ZP,`ROR_ZP,`INC_ZP,`DEC_ZP: inc <= 4'd2;

	`ADC_ZPX,`SBC_ZPX,`CMP_ZPX,`AND_ZPX,`ORA_ZPX,`EOR_ZPX,`LDA_ZPX,`STA_ZPX: inc <= 4'd2;
	`LDY_ZPX,`STY_ZPX,`BIT_ZPX,`STZ_ZPX: inc <= 4'd2;
	`ASL_ZPX,`ROL_ZPX,`LSR_ZPX,`ROR_ZPX,`INC_ZPX,`DEC_ZPX: inc <= 4'd2;
	`LDX_ZPY,`STX_ZPY: inc <= 4'd2;

	`ADC_I,`SBC_I,`AND_I,`ORA_I,`EOR_I,`CMP_I,`LDA_I,`STA_I,
	`ADC_IL,`SBC_IL,`AND_IL,`ORA_IL,`EOR_IL,`CMP_IL,`LDA_IL,`STA_IL,
	`ADC_IX,`SBC_IX,`CMP_IX,`AND_IX,`OR_IX,`EOR_IX,`LDA_IX,`STA_IX: inc <= 4'd2;

	`ADC_IY,`SBC_IY,`CMP_IY,`AND_IY,`OR_IY,`EOR_IY,`LDA_IY,`STA_IY: inc <= 4'd2;
	`ADC_IYL,`SBC_IYL,`CMP_IYL,`AND_IYL,`ORA_IYL,`EOR_IYL,`LDA_IYL,`STA_IYL: inc <= 4'd2;

	`TRB_ABS,`TSB_ABS,
	`ADC_ABS,`SBC_ABS,`CMP_ABS,`AND_ABS,`OR_ABS,`EOR_ABS,`LDA_ABS,`STA_ABS: inc <= 4'd3;
	`LDX_ABS,`LDY_ABS,`STX_ABS,`STY_ABS,`CPX_ABS,`CPY_ABS,`BIT_ABS,`STZ_ABS: inc <= 4'd3;
	`ASL_ABS,`ROL_ABS,`LSR_ABS,`ROR_ABS,`INC_ABS,`DEC_ABS: inc <= 4'd3;

	`ADC_ABSX,`SBC_ABSX,`CMP_ABSX,`AND_ABSX,`OR_ABSX,`EOR_ABSX,`LDA_ABSX,`STA_ABSX: inc <= 4'd3;
	`LDY_ABSX,`BIT_ABSX,`STZ_ABSX:	inc <= 4'd3;
	`ASL_ABSX,`ROL_ABSX,`LSR_ABSX,`ROR_ABSX,`INC_ABSX,`DEC_ABSX: inc <= 4'd3;

	`ADC_ABSY,`SBC_ABSY,`CMP_ABSY,`AND_ABSY,`ORA_ABSY,`EOR_ABSY,`LDA_ABSY,`STA_ABSY: inc <= 4'd3;
	`LDX_ABSY: inc <= 4'd3;

	`ADC_AL,`SBC_AL,`CMP_AL,`AND_AL,`ORA_AL,`EOR_AL,`LDA_AL,`STA_AL: inc <= 4'd4;
	`ADC_ALX,`SBC_ALX,`CMP_ALX,`AND_ALX,`ORA_ALX,`EOR_ALX,`LDA_ALX,`STA_ALX: inc <= 4'd4;

	`ADC_DSP,`SBC_DSP,`CMP_DSP,`AND_DSP,`ORA_DSP,`EOR_DSP,`LDA_DSP,`STA_DSP: inc <= 4'd2;
	`ADC_DSPIY,`SBC_DSPIY,`CMP_DSPIY,`AND_DSPIY,`ORA_DSPIY,`EOR_DSPIY,`LDA_DSPIY,`STA_DSPIY: inc <= 4'd2;

	`ASL_ACC,`LSR_ACC,`ROR_ACC,`ROL_ACC: inc <= 4'd1;

	`PHP,`PHA,`PHX,`PHY,`PHK,`PHB,`PHD,`PLP,`PLA,`PLX,`PLY,`PLB,`PLD: inc <= 4'd1;
	`PEA,`PER,`MVN,`MVP: inc <= 4'd3;
	`PEI:	inc <= 4'd2;

	default:	inc <= 4'd0;	// unimplemented instruction
	endcase
else
	inc <= 4'd0;
endmodule
