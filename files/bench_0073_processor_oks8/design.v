// Curated RTL benchmark case.
// case_id: bench_0073_processor_oks8
// source_project: processor_oks8
// top_module: oks8_execute


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
// Source file: rtl/verilog/oks8_defines.v
// -----------------------------------------------------------------------------
//                              -*- Mode: Verilog -*-
// Filename        : oks8_defines.v
// Description     : OKS8 Defines
// Author          : Jian Li
// Created On      : Sat Jan 07 09:09:49 2006
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`ifndef DEFINED

// =====================================================================
// EDITABLE/CONFIGURABLE DEFINES
// =====================================================================

//
// VENDOR for RAMS
// VENDOR_FPGA = Leave it to synthesis tool to decide
`define VENDOR_FPGA

// =====================================================================
// MISC DEFINES ** DO NOT EDIT **
// =====================================================================
`define DAT_Z		8'hZZ

// =====================================================================
// ALU Internal Operation Codes
// Selection mode for the correct ALU operations
// =====================================================================
`define ALU_AND		4'b0100		// AND/TM
`define ALU_IOR		4'b0101		// IOR
`define ALU_XOR		4'b0110		// XOR/COM(COM is XOR 0xFF)
`define ALU_TCM		4'b0111		// TCM
`define ALU_SRA		4'b0000		// SRA
`define ALU_LDCX	4'b0001		// LDCD(I)/LDED(I)
`define ALU_JP		4'b0010		// JP
`define ALU_NON		4'b0011		// NON

`define ALU_ADD		4'b1000		// ADD/DEC
`define ALU_ADC		4'b1001		// ADD+C
`define ALU_SUB		4'b1010		// SUB/INC
`define ALU_SBC		4'b1011		// SUB-C
`define ALU_RR		4'b1100		// RR
`define ALU_RRC		4'b1101		// RRC
`define ALU_RL		4'b1110		// RL
`define ALU_RLC		4'b1111		// RLC

// 
// SOURCE OPERAND SOURCE
// Used to indicate Source operand source
`define SRC_DA		3'b100		// DA
`define SRC_R		3'b101		// r/R
`define SRC_IR		3'b110		// ir/IR/x[r]
`define SRC_IRR		3'b111		// irr/IRR/XS[rr]/XL[rr]
`define SRC_IM		3'b000		// IM/NONE
`define SRC_RET		3'b001		// RET
`define SRC_POP		3'b010		// POP
`define SRC_IRET	3'b011		// IRET

// 
// DESTINATION OPERAND SOURCE
// Used to indicate destination operand source
`define DST_DA		3'b100		// DA
`define DST_R		3'b101		// r/R
`define DST_IR		3'b110		// ir/IR/x[r]
`define DST_IRR		3'b111		// irr/IRR/XS[rr]/XL[rr]

`define DST_NON		3'b000		// NONE/RA
`define DST_R2		3'b001		// R2

`define DST_PUSH	3'b010		// PUSH
`define DST_CALL	3'b011		// CALL

//
// STATUS AFFECTEd
// Used to indicate which Flags are affected
`define STS_NON		2'b00
`define STS_ZS0		2'b01
`define STS_ZSV		2'b10
`define STS_ALL		2'b11

// =====================================================================
// VECTORS ** DO NOT EDIT **
// Various Program and Data Address pointers.
// Also used to decode standard internal registers.
// =====================================================================
`define V_FLAGS		8'hD5
`define V_SP		8'hD9
`define V_SYM		8'hDF
`define V_RST		13'h0100

// =====================================================================
// WIDTH DEFINES ** DO NOT EDIT **
// =====================================================================
`define W_DATA		5'd8
`define W_INST		5'd13

// *** DEFINED ***
`define DEFINED

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
// Source file: rtl/verilog/oks8_execute.v
// -----------------------------------------------------------------------------
//                              -*- Mode: Verilog -*-
// Filename        : oks8_execute.v
// Description     : OKS8 ALU and EXECUTION Unit
// Author          : Jian Li
// Created On      : Sat Jan 07 09:09:49 2006
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`include "oks8_defines.v"
`include "oks8_prims.v"

////////////////////////////////////////////////////

module oks8_execute (
  // Inputs
  clk_i, rst_i, en_i, int_i,
  dx_den, dx_alu, dx_sts, dx_r1_t, dx_r2_t, dx_r1, dx_r2, dx_r3, dat_i,
  // Outputs
  ex_final,
  ien_o, den_o, fen_o, we_o, add_o, dat_o
  );

// Inputs
input clk_i, rst_i;
input en_i, int_i;
input dx_den;
input [3:0] dx_alu;
input [1:0] dx_sts;
input [7:0] dx_r1;
input [2:0] dx_r1_t;
input [7:0] dx_r2;
input [2:0] dx_r2_t;
input [15:0] dx_r3;
input [7:0] dat_i;

// Outputs
output ex_final;
output [15:0] add_o;
output [7:0] dat_o;
output ien_o, den_o, fen_o, we_o;

// =====================================================================
// REGISTER/WIRE DECLARATIONS
// =====================================================================
// IMEM & DMEM & XMEM INTERFACE
reg fen_o, ien_o, den_o;
reg dwe_sp;

// Skipping/Jumping
reg [15:0] opc;
reg [15:0] dst_add;
wire skp_o, skp_t;
reg skp_old;

// SRC/DST
reg [7:0] src, dst;
wire [7:0] dat_dm;
wire ram_flags, ram_sp;

// INTERNAL REGISTERS & SHADOW
wire C_, Z_, S_, V_;
wire SV, CZ, ZSV;
reg C, Z, S, V;		// FLAGS
reg GIEN;			// Global Interrupt Enable Bit
reg [1:0] PS;		// Page Selection Bits
reg [7:0] sp;		// Stack pointer

// ALU
wire [7:0] r_and, r_ior, r_xor, r_tcm;
wire [8:0] r_add, r_addc, r_sub, r_sbc;
wire [8:0] r_rr, r_rl, r_rrc, r_rlc, r_sra;
wire [8:0] res_;

wire [3:0]  alu;
wire [1:0]  sts;
wire [7:0]  r1;
wire [2:0]  r1_t;
wire [7:0]  r2;
wire [2:0]  r2_t;
wire [15:0] r3;

// INTERRUPT
reg [15:0] int_vec;
reg do_int_, int_, run_;

// FLAGS
reg [1:0] ex_state;
reg src_finish, dst_finish;
wire finish;
reg ex_final;


// ===============================================================
// INTERRUPT VECTOR
// The first thing I do after reset is to get the interrupt vector.
// ===============================================================
always @(posedge clk_i)
  if (rst_i) begin
	run_ <= 0;
	int_ <= 0;
	do_int_ <= 0;
	GIEN <= 0;
	PS <= 0;
	Z <= 0;
	S <= 0;
	V <= 0;
	C <= 0;

	ex_final <= 0;
	src_finish <= 0;
	dst_finish <= 0;
	do_int_ <= 0;
	ien_o <= 1'b0;
	fen_o <= 1'b0;
	den_o <= 1'b0;
	dwe_sp <= 0;

  end else if (!run_) begin
    case (ex_state)
	  2'b00:
	  begin
		ien_o <= 1'b1;
		dst_add[15:0] <= 16'h0000;
	  end
	  2'b01:
	  begin
	    int_vec[15:8] <= dat_dm[7:0];
		dst_add[15:0] <= 16'h0001;
	  end
	  2'b10:
	  begin
	    int_vec[7:0] <= dat_dm[7:0];
		src_finish <= 1;
		dst_finish <= 1;
		run_ <= 1;
	  end
	endcase
  end

// ===============================================================
// ALU
// alu (or interrupt).
// ===============================================================
assign alu	= (en_i && do_int_) ? `ALU_NON : dx_alu;
assign sts	= (en_i && do_int_) ? `STS_NON : dx_sts;
assign r1_t	= (en_i && do_int_) ? `DST_CALL : dx_r1_t;
assign r1	= dx_r1;
assign r2_t = (en_i && do_int_) ? `SRC_DA : dx_r2_t;
assign r2	= dx_r2;
assign r3	= (en_i && do_int_) ? int_vec : dx_r3;

// ===============================================================
// ACTUAL DATA INPUT
// dat_i/flag/sp
// ===============================================================
assign dat_dm = (ram_flags) ? {C, Z, S, V, 4'h0} : 
		(ram_sp) ? sp : dat_i;

// ===============================================================
// IMEM & DMEM INTERFACE
// ===============================================================
assign add_o = (en_i) ? ((ien_o | fen_o | den_o) ? dst_add[15:0] : opc) : 16'hZZZZ;
assign we_o = (en_i) && !(ex_final) && !(alu == `ALU_JP) && (finish ? (r1_t[2] | r1_t[1]): dwe_sp);
assign dat_o = (en_i) ? res_ : `DAT_Z;

// ===============================================================
// ACTUAL ALU
// Result selection
// ===============================================================
assign res_ = (alu == `ALU_AND) ? {C, r_and} :
	(alu == `ALU_IOR) ? {C, r_ior} :
	(alu == `ALU_XOR) ? {C, r_xor} :
	(alu == `ALU_TCM) ? {C, r_tcm} :
	(alu == `ALU_ADD) ? r_add :
	(alu == `ALU_ADC) ? r_addc :
	(alu == `ALU_SUB) ? r_sub :
	(alu == `ALU_SBC) ? r_sbc :
	(alu == `ALU_RR) ? r_rr :
	(alu == `ALU_RL) ? r_rl :
	(alu == `ALU_RRC) ? r_rrc :
	(alu == `ALU_RLC) ? r_rlc :
	(alu == `ALU_SRA) ? r_sra : {C, src};

oks8_and andU0(.a_i(dst), .b_i(src), .c_o(r_and));
oks8_ior iorU0(.a_i(dst), .b_i(src), .c_o(r_ior));

// oks8_xor xorU0(.a_i(dst), .b_i(src), .c_o(r_xor));
assign r_xor = r_tcm | (dst & ~(src));
oks8_tcm tcmU0(.a_i(dst), .b_i(src), .c_o(r_tcm));

oks8_add addU0(.a_i(dst), .b_i(src), .c_o(r_add));
oks8_adc addU1(.a_i(dst), .b_i(src), .c_i(C), .c_o(r_addc));
oks8_sub subU0(.a_i(dst), .b_i(src), .c_o(r_sub));
oks8_sbc subU1(.a_i(dst), .b_i(src), .c_i(~C), .c_o(r_sbc));
oks8_rr  rrU0(.a_i(dst), .c_o(r_rr));
oks8_rl  rlU0(.a_i(dst), .c_o(r_rl));
oks8_rrc rrcU0(.a_i({C,dst}), .c_o(r_rrc));
oks8_rlc rlcU0(.a_i({C,dst}), .c_o(r_rlc));
oks8_sra sraU0(.a_i(dst), .c_o(r_sra));

// ===============================================================
// STATUS
// Status effects/Skipping
// ===============================================================

assign C_ = (sts[1] && sts[0]) ? res_[8] : C;
assign Z_ = (sts[1] || sts[0]) ? (res_[7:0] == 8'h00) : Z;
assign S_ = (sts[1] || sts[0]) ? (res_[7]) : S;
assign V_ = (sts[1]) ? ((src[7] & dst[7] & !res_[7]) |
			(~src[7] & ~dst[7] & res_[7])) : ((sts[0]) ? 0 : V);

assign SV = (S & ~V) | (~S & V);
assign ZSV = Z | SV;
assign CZ = C | Z;

assign skp_o = (en_i) && ((r1_t == `DST_CALL || r2_t == `SRC_RET ||
	r2_t == `SRC_IRET) ? 1'b1 : (alu == `ALU_JP) ? skp_t : 1'b0);

assign skp_t = (r2[2:0] == 3'b000) ? (r2[3]) : 1'bZ;
assign skp_t = (r2[2:0] == 3'b111) ? ((r2[3]) ? ~C : C) : 1'bZ;
assign skp_t = (r2[2:0] == 3'b110) ? ((r2[3]) ? ~Z : Z) : 1'bZ;
assign skp_t = (r2[2:0] == 3'b101) ? ((r2[3]) ? ~S : S) : 1'bZ;
assign skp_t = (r2[2:0] == 3'b100) ? ((r2[3]) ? ~V : V) : 1'bZ;
assign skp_t = (r2[2:0] == 3'b001) ? ((r2[3]) ? ~SV : SV) : 1'bZ;
assign skp_t = (r2[2:0] == 3'b010) ? ((r2[3]) ? ~ZSV : ZSV) : 1'bZ;
assign skp_t = (r2[2:0] == 3'b011) ? ((r2[3]) ? ~CZ : CZ) : 1'bZ;

// ===============================================================
// INTERNAL REGISTERS
// FLAG & SP & SYM
// ===============================================================
assign ram_flags = (fen_o && dst_add[7:0] == `V_FLAGS);
assign ram_sp = (fen_o && dst_add[7:0] == `V_SP);

always @(posedge clk_i)
begin
  if (finish) begin
	if (sts[1] && sts[0])
		C <= C_;
	if (sts[1] || sts[0]) begin
	  Z <= Z_;
	  S <= S_;
	  V <= V_;
	end else begin
	  if (dst_add[7:0] == `V_FLAGS)
		C <= res_[7];
	  else if (dst_add[7:0] == `V_SP)
	    sp <= res_[7:0];
	  else if (dst_add[7:0] == `V_SYM)
		{GIEN, PS} <= res_[2:0];
	end
  end
end


// ===============================================================
// INTERRUPT
// Set interrupt flag
// ===============================================================
always @(posedge dst_finish)
  if (int_) begin
    do_int_ <= 1'b1;
	ex_state <= 2'b00;
  end

// ===============================================================
// JOB FINISH
// Exit normally without interrupt.
// ===============================================================
always @(posedge clk_i)
begin
  if (finish && !do_int_)
	begin
	  if (!skp_o)
		dst_add <= opc;
	  ien_o <= 1;
	  fen_o <= 0;
	  den_o <= 0;
	  ex_final <= 1;
	end
end

// ===============================================================
// INITIALIZATION
// Do some cleanning when enter or exit
// ===============================================================
always @(posedge clk_i)
  if (rst_i)
	ex_state <= 0;
  else if (en_i)
	ex_state <= ex_state + 1'b1;

always @(en_i)
  if (en_i) begin
	opc <= add_o;
  end else
  begin
	ex_final <= 0;
	src_finish <= 0;
	dst_finish <= 0;
	ex_state <= 0;
	ien_o <= 0;
	dwe_sp <= 0;  
  end

// ===============================================================
// MAIN JOBS
// Get/Set the SRC/DST
// ===============================================================

//
// Set when src & dst finish
//
assign finish = (en_i && src_finish && dst_finish);

//
// Get/Set the DST
//
always @(posedge src_finish)
begin
  if (int_i && GIEN) begin
	int_ <= 1;
	skp_old <= skp_o;
  end
  ex_state <= 2'b01;
  fen_o <= 1'b0;
  den_o <= 1'b0;

	case (r1_t)
	  `DST_NON:
	  begin
		if (alu == `ALU_JP)
		  dst_add[15:0] <= opc[15:0] + {r1[7], r1[7], r1[7], r1[7], r1[7], r1[7],
										r1[7], r1[7], r1[7:0]};
		dst_finish <= 1;
	  end
	  `DST_DA:
	  begin
	    den_o <= dx_den;
		ien_o <= ~dx_den;
		dst_add[15:0] <= r3[15:0];
		dst_finish <= 1;
	  end
	  `DST_R:
	  begin
		fen_o <= 1'b1;
		dst_add[7:0] <= r1;
		if (alu == `ALU_NON)
		  dst_finish <= 1;
		else if (alu == `ALU_LDCX) begin
		  {dst_add[15:8], dst[7:0]} <= {dst_add[15:8], dst[7:0]} + r3[15:0];	// +1, -1
		  dwe_sp <= 1;
		end
	  end
	  `DST_R2, `DST_IR, `DST_IRR:
	  begin
		fen_o <= 1'b1;
		dst_add[7:1] <= r1[7:1];
		if (dx_den)
		  dst_add[0] <= 1'b0;
		else
		  dst_add[0] <= r1[0];
	  end
	  `DST_PUSH:
	  begin
		fen_o <= 1'b1;
		dwe_sp <= 1;
		dst_add[7:0] <= sp[7:0] + 8'hFF;
		sp <= sp + 8'hFF;
		dst_finish <= 1;
	  end
	  `DST_CALL:
	  begin
		fen_o <= 1'b1;
		dwe_sp <= 1;
		dst_add[7:0] <= sp[7:0] + 8'hFF;
		src <= opc[7:0];
		sp <= sp + 8'hFF;
	  end
	  default:
	  begin
		dst <= 8'hXX;
		dst_finish <= 1;
	  end
	endcase	// case (r1_t)
end	// always @(posedge src_finish)

always @(posedge clk_i)
begin
  if ((src_finish && !dst_finish) || (do_int_)) begin
    case (ex_state)
	  2'b00:
	  if (do_int_)
	  begin
		fen_o <= 1'b1;
		dwe_sp <= 1;
		dst_add[7:0] <= sp[7:0] + 8'hFF;
		{dst_add[15:8], dst[7:0]} <= int_vec[15:0];
		if (!skp_old) begin
		  src <= opc[7:0];
		end else begin
		  src <= dst_add[7:0];
		  opc[15:8] <= dst_add[15:8];
		end
		sp <= sp + 8'hFF;
		GIEN <= 0;
	  end

	  2'b01:
		case (r1_t)
		  `DST_R2:
		  begin
			dst <= dat_dm;
			dst_finish <= 1;
		  end
		  `DST_R:
		  if (alu == `ALU_LDCX) begin
			dst_add[7:0] <= r2[7:0];
			src[7:0] <= dst_add[15:8];
		  end else begin
			dst <= dat_dm;
			dst_finish <= 1;			
		  end
		  `DST_IR:
		  begin
			dst_add[7:0] <= dat_dm + r3[7:0];
		    if (alu == `ALU_NON)
			  dst_finish <= 1;
		  end
		  `DST_IRR:
		  begin
		    dst_add[15:8] <= dat_dm[7:0];
			if (dx_den)
			  dst_add[7:0] <= {r1[7:1], 1'b1};
			else
			  dst_add[7:0] <= r1[7:0] + 1;
		  end
		  `DST_CALL:
		  begin
			dst_add[7:0] <= sp[7:0] + 8'hFF;
			src[7:0] <= opc[15:8];
			sp <= sp + 8'hFF;
		  end
		endcase
	  2'b10:
	  begin
		case (r1_t)
		  `DST_R:
			if (alu == `ALU_LDCX) begin
			  dst_add[7:0] <= r2[7:0] + 1'b1;
			  src[7:0] <= dst[7:0];
			  dst_finish <= 1;
			end
		  `DST_CALL:
			begin
			if (do_int_) begin
			  dst_add[7:0] <= sp[7:0] + 8'hFF;
			  src[7:4] <= {C,Z,S,V};
			  sp <= sp + 8'hFF;
			end else
			begin
			  dst_add[7:0] = dst[7:0];
			  dst_finish <= 1;
			end
			end
		  `DST_IR:
		  begin
			dst <= dat_dm;
			dst_finish <= 1;
		  end
		  `DST_IRR:
		  begin
			fen_o <= 1'b0;
			if (dx_den) begin
			  den_o <= 1'b1;
			end else begin
			  ien_o <= 1'b1;
			end
			dst_add[15:0] <= {dst_add[15:8], dat_dm} + r3[15:0];
			dst_finish <= 1;
		  end
		endcase
	  end
	  2'b11:
	  begin
		if (do_int_) begin
		  dst_add[7:0] = dst[7:0];
		  fen_o <= 0;
		  ien_o <= 1;
		  ex_final <= 1;
		  int_ <= 0;
		  do_int_ <= 0;
		end else begin
		  dst_finish <= 1;
		end
	  end
	endcase	// case (ex_state)
  end
end	// always @(posedge clk_i)

//
// Get/Set the SRC
//
always @(posedge clk_i)
begin
  if (en_i && run_ && (!src_finish))
  begin
    case (ex_state)
	  2'b00:
		case (r2_t)
		  `SRC_DA:
		  if (r1_t == `DST_CALL) begin
			{dst_add[15:8], dst[7:0]} <= r3[15:0];
			src_finish <= 1;
		  end
		  else begin
		    den_o <= dx_den;
			ien_o <= ~dx_den;
			dst_add[15:0] <= r3[15:0];
		  end		
		  `SRC_IM:
		  begin
		    src <= r2;
			src_finish <= 1;
		  end
		  `SRC_R, `SRC_IR, `SRC_IRR:
		  begin
		    fen_o <= 1'b1;
			dst_add[7:1] <= r2[7:1];
			if (dx_den)
			  dst_add[0] <= 1'b0;
			else
			  dst_add[0] <= r2[0];
		  end
		  `SRC_RET, `SRC_POP, `SRC_IRET:
		  begin
		    fen_o <= 1'b1;
			dst_add[7:0] <= sp;
			sp <= sp + 1'b1;
		  end
		  default:
		  begin
			src <= 8'hXX;
			src_finish <= 1;
		  end
		endcase
	  2'b01:
		case (r2_t)
		  `SRC_DA, `SRC_R, `SRC_POP:
		  begin
			src <= dat_dm;
			ien_o <= 1'b0;
			src_finish <= 1;
		  end
		  `SRC_IR:
		  begin
			dst_add[7:0] <= dat_dm + r3[7:0];
		  end
		  `SRC_IRR:
		  begin
			dst_add[15:8] <= dat_dm[7:0];
			if (dx_den)
			  dst_add[7:0] <= {r2[7:1], 1'b1};
			else
			  dst_add[7:0] <= r2[7:0] + 1'b1;
		  end
		  `SRC_RET:
		  begin
			dst_add[15:8] <= dat_dm[7:0];
			dst_add[7:0] <= sp;
			sp <= sp + 1'b1;
		  end
		  `SRC_IRET:
		  begin
			{C, Z, S, V} = dat_dm[7:4];
			dst_add[7:0] <= sp;
			sp <= sp + 1'b1;
		  end
		endcase
	  2'b10:
		case (r2_t)
		  `SRC_IR:
		  begin
			src <= dat_dm;
			src_finish <= 1;
		  end
		  `SRC_IRR:
		  begin
			fen_o <= 1'b0;
			dst[7:0] <= dat_dm[7:0];
			if (r1_t == `DST_CALL) begin
			  src_finish <= 1;
			end
			else begin
			  if (dx_den) begin
				den_o <= 1'b1;
			  end else begin
				ien_o <= 1'b1;
			  end
			  if (alu == `ALU_LDCX)
				dst_add[7:0] <= dat_dm[7:0];
			  else
				dst_add[15:0] <= {dst_add[15:8], dat_dm[7:0]} + r3[15:0];
			end
		  end
		  `SRC_RET:
		  begin
			dst_add[7:0] <= dat_dm;
			src_finish <= 1;
		  end
		  `SRC_IRET:
		  begin
			dst_add[15:8] <= dat_dm[7:0];
			dst_add[7:0] <= sp;
			sp <= sp + 1'b1;
		  end
		endcase
	  2'b11:
	  begin
		src_finish <= 1;
		case (r2_t)
		  `SRC_IRR:
		  begin
			ien_o <= 1'b0;
			src <= dat_dm;
		  end
		  `SRC_IRET:
		  begin
			dst_add[7:0] <= dat_dm;
			GIEN <= 1;
		  end
		endcase
	  end
	endcase	// case (ex_state)
  end
end	// always @(posedge clk_i)

endmodule	// oks8_execute

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/oks8_prims.v
// -----------------------------------------------------------------------------
//                              -*- Mode: Verilog -*-
// Filename        : oks8_prims.v
// Description     : OKS8 Basic Types and Units
//					 *** Most from ae18_prims.v, See AE18 on OPENCORES ***
// Author          : Shawn Tan
// Created On      : Wed Jul 30 20:24:29 2003
// Last Modified By: Jian Li
// Last Modified On: Sat Jan 07 09:09:49 2006
// Update Count    : 2
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2003 to Shawn Tan Ser Ngiap. Aeste Works (M) Sdn Bhd.
 * Contact: shawn.tan@aeste.net
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`include "oks8_defines.v"

// =====================================================================
// OKS8_AND
// =====================================================================

module oks8_and (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0]  c_o;
   assign 	    c_o = a_i & b_i;
   
endmodule // oks8_and

// =====================================================================
// OKS8_IOR
// =====================================================================

module oks8_ior (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0] c_o;
   assign 	   c_o = a_i | b_i;
   
endmodule // oks8_ior

// =====================================================================
// OKS8_XOR
// =====================================================================

module oks8_tcm (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0]  c_o;
   assign 	    c_o = (~a_i) & b_i;
   
endmodule // oks8_tcm

module oks8_tcm2 (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0]  c_o;
   assign 	    c_o = a_i & (~b_i);
   
endmodule // oks8_tcm2

// =====================================================================
// OKS8_XOR
// =====================================================================

module oks8_xor (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0]  c_o;
   assign 	    c_o = a_i ^ b_i;
   
endmodule // oks8_xor

// =====================================================================
// OKS8_ADD
// adder
// =====================================================================

module oks8_add (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw:0]  c_o;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [dw:0]		c_o;
   // End of automatics
   
   always @(/*AUTOSENSE*/a_i or b_i)
     c_o <= a_i + b_i;
   
endmodule // oks8_add

module oks8_adc (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i, c_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   input 	  c_i;
   output [dw:0]  c_o;
   reg [dw:0] 	  c_o;
   always @(/*AUTOSENSE*/a_i or b_i or c_i)
     c_o <= a_i + b_i + c_i;
   
endmodule // oks8_adc

// =====================================================================
// OKS8_SUB
// Subtractor
// =====================================================================

module oks8_sub (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw:0]  c_o;
   reg [dw:0] 	  c_o;
   always @(/*AUTOSENSE*/a_i or b_i)
     c_o <= a_i - b_i;
   
endmodule // oks8_sub

module oks8_sbc (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i, c_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   input 	  c_i;
   output [dw:0]  c_o;
   reg [dw:0] 	  c_o;
   always @(/*AUTOSENSE*/a_i or b_i or c_i)
     c_o <= a_i - b_i - c_i;
   
endmodule // oks8_sbc

// =====================================================================
// OKS8_RR
// 8Bit Barrel
// =====================================================================

module oks8_rr (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i;
   output [dw:0]  c_o;
   assign 	    c_o = {a_i[0],a_i[0],a_i[dw-1:1]};
   
endmodule // oks8_rr

// =====================================================================
// OKS8_RRC
// 9Bit Barrel
// =====================================================================
module oks8_rrc (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw:0] a_i;
   output [dw:0]  c_o;
   assign 	  c_o = {a_i[0],a_i[dw:1]};
   
endmodule // oks8_rrc

// =====================================================================
// OKS8_RL
// 8Bit Barrel
// =====================================================================
module oks8_rl (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i;
   output [dw:0]  c_o;
   assign 	    c_o = {a_i[dw-1],a_i[dw-2:0],a_i[dw-1]};
   
endmodule // oks8_rl

// =====================================================================
// OKS8_RLC
// 9Bit Barrel
// =====================================================================

module oks8_rlc (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw:0] a_i;
   output [dw:0]  c_o;
   assign 	  c_o = {a_i[dw-1:0],a_i[dw]};
   
endmodule // oks8_rlc

// =====================================================================
// OKS8_SRA
// 9Bit Barrel
// =====================================================================

module oks8_sra (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i;
   output [dw:0]  c_o;
   assign 	  c_o = {a_i[0],a_i[dw-1],a_i[dw-1],a_i[dw-2:1]};
   
endmodule // oks8_sra
