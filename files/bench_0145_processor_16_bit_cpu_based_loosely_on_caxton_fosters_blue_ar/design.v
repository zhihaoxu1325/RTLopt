// Curated RTL benchmark case.
// case_id: bench_0145_processor_16_bit_cpu_based_loosely_on_caxton_fosters_blue_ar
// source_project: processor_16-bit_cpu_based_loosely_on_caxton_fosters_blue_ar
// top_module: PSG16


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
