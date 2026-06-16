// Curated RTL benchmark case.
// case_id: bench_0226_crypto_core_fast_aes_128_encryption_only_cores
// source_project: crypto_core_fast_aes-128_encryption_only_cores
// top_module: aes_cipher_top


// -----------------------------------------------------------------------------
// Source file: aes_10cycle_10stage/aes_cipher_top.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Cipher Top Level                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
 
//// Modified to achieve 10 cycle - 10 stage functionality	     ////
//// By Tariq Bashir Ahmad					     //// 	
////  tariq.bashir@gmail.com					     ////
////  http://www.ecs.umass.edu/~tbashir				     ////	



`timescale 1 ns/1 ps

module aes_cipher_top(clk, rst, ld, done, key, text_in, text_out);

input		clk, rst;
input		ld;
output		done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;


reg	[127:0]	text_in_r;

reg	[127:0]	text_out_stage1;
reg	[127:0]	text_out_stage2;
reg	[127:0]	text_out_stage3;
reg	[127:0]	text_out_stage4;
reg	[127:0]	text_out_stage5;
reg	[127:0]	text_out_stage6;
reg	[127:0]	text_out_stage7;
reg	[127:0]	text_out_stage8;
reg	[127:0]	text_out_stage9;


reg	[127:0]	text_out;     //10th stage output

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[31:0]	w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22,
               w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36, w37, w38, w39, w40, w41, w42, w43;
					
/*reg	[127:0]	text_out_temp;
*/
//round 1 wires
reg	[7:0]	sa00, sa01, sa02, sa03;
reg	[7:0]	sa10, sa11, sa12, sa13;
reg	[7:0]	sa20, sa21, sa22, sa23;
reg	[7:0]	sa30, sa31, sa32, sa33;

wire	[7:0]	sa00_next, sa01_next, sa02_next, sa03_next;
wire	[7:0]	sa10_next, sa11_next, sa12_next, sa13_next;
wire	[7:0]	sa20_next, sa21_next, sa22_next, sa23_next;
wire	[7:0]	sa30_next, sa31_next, sa32_next, sa33_next;

wire	[7:0]	sa00_sub, sa01_sub, sa02_sub, sa03_sub;
wire	[7:0]	sa10_sub, sa11_sub, sa12_sub, sa13_sub;
wire  [7:0]	sa20_sub, sa21_sub, sa22_sub, sa23_sub;
wire	[7:0]	sa30_sub, sa31_sub, sa32_sub, sa33_sub;

wire	[7:0]	sa00_sr, sa01_sr, sa02_sr, sa03_sr;
wire	[7:0]	sa10_sr, sa11_sr, sa12_sr, sa13_sr;
wire	[7:0]	sa20_sr, sa21_sr, sa22_sr, sa23_sr;
wire	[7:0]	sa30_sr, sa31_sr, sa32_sr, sa33_sr;

wire	[7:0]	sa00_mc, sa01_mc, sa02_mc, sa03_mc;
wire	[7:0]	sa10_mc, sa11_mc, sa12_mc, sa13_mc;
wire	[7:0]	sa20_mc, sa21_mc, sa22_mc, sa23_mc;
wire	[7:0]	sa30_mc, sa31_mc, sa32_mc, sa33_mc;


//round2 wires
wire	[7:0]	sa00_next_round2, sa01_next_round2, sa02_next_round2, sa03_next_round2;
wire	[7:0]	sa10_next_round2, sa11_next_round2, sa12_next_round2, sa13_next_round2;
wire	[7:0]	sa20_next_round2, sa21_next_round2, sa22_next_round2, sa23_next_round2;
wire	[7:0]	sa30_next_round2, sa31_next_round2, sa32_next_round2, sa33_next_round2;

wire	[7:0]	sa00_sub_round2, sa01_sub_round2, sa02_sub_round2, sa03_sub_round2;
wire	[7:0]	sa10_sub_round2, sa11_sub_round2, sa12_sub_round2, sa13_sub_round2;
wire  [7:0]	sa20_sub_round2, sa21_sub_round2, sa22_sub_round2, sa23_sub_round2;
wire	[7:0]	sa30_sub_round2, sa31_sub_round2, sa32_sub_round2, sa33_sub_round2;

wire	[7:0]	sa00_sr_round2, sa01_sr_round2, sa02_sr_round2, sa03_sr_round2;
wire	[7:0]	sa10_sr_round2, sa11_sr_round2, sa12_sr_round2, sa13_sr_round2;
wire	[7:0]	sa20_sr_round2, sa21_sr_round2, sa22_sr_round2, sa23_sr_round2;
wire	[7:0]	sa30_sr_round2, sa31_sr_round2, sa32_sr_round2, sa33_sr_round2;

wire	[7:0]	sa00_mc_round2, sa01_mc_round2, sa02_mc_round2, sa03_mc_round2;
wire	[7:0]	sa10_mc_round2, sa11_mc_round2, sa12_mc_round2, sa13_mc_round2;
wire	[7:0]	sa20_mc_round2, sa21_mc_round2, sa22_mc_round2, sa23_mc_round2;
wire	[7:0]	sa30_mc_round2, sa31_mc_round2, sa32_mc_round2, sa33_mc_round2;


//round3 wires
wire	[7:0]	sa00_next_round3, sa01_next_round3, sa02_next_round3, sa03_next_round3;
wire	[7:0]	sa10_next_round3, sa11_next_round3, sa12_next_round3, sa13_next_round3;
wire	[7:0]	sa20_next_round3, sa21_next_round3, sa22_next_round3, sa23_next_round3;
wire	[7:0]	sa30_next_round3, sa31_next_round3, sa32_next_round3, sa33_next_round3;

wire	[7:0]	sa00_sub_round3, sa01_sub_round3, sa02_sub_round3, sa03_sub_round3;
wire	[7:0]	sa10_sub_round3, sa11_sub_round3, sa12_sub_round3, sa13_sub_round3;
wire  [7:0]	sa20_sub_round3, sa21_sub_round3, sa22_sub_round3, sa23_sub_round3;
wire	[7:0]	sa30_sub_round3, sa31_sub_round3, sa32_sub_round3, sa33_sub_round3;

wire	[7:0]	sa00_sr_round3, sa01_sr_round3, sa02_sr_round3, sa03_sr_round3;
wire	[7:0]	sa10_sr_round3, sa11_sr_round3, sa12_sr_round3, sa13_sr_round3;
wire	[7:0]	sa20_sr_round3, sa21_sr_round3, sa22_sr_round3, sa23_sr_round3;
wire	[7:0]	sa30_sr_round3, sa31_sr_round3, sa32_sr_round3, sa33_sr_round3;

wire	[7:0]	sa00_mc_round3, sa01_mc_round3, sa02_mc_round3, sa03_mc_round3;
wire	[7:0]	sa10_mc_round3, sa11_mc_round3, sa12_mc_round3, sa13_mc_round3;
wire	[7:0]	sa20_mc_round3, sa21_mc_round3, sa22_mc_round3, sa23_mc_round3;
wire	[7:0]	sa30_mc_round3, sa31_mc_round3, sa32_mc_round3, sa33_mc_round3;



//round4 wires
wire	[7:0]	sa00_next_round4, sa01_next_round4, sa02_next_round4, sa03_next_round4;
wire	[7:0]	sa10_next_round4, sa11_next_round4, sa12_next_round4, sa13_next_round4;
wire	[7:0]	sa20_next_round4, sa21_next_round4, sa22_next_round4, sa23_next_round4;
wire	[7:0]	sa30_next_round4, sa31_next_round4, sa32_next_round4, sa33_next_round4;

wire	[7:0]	sa00_sub_round4, sa01_sub_round4, sa02_sub_round4, sa03_sub_round4;
wire	[7:0]	sa10_sub_round4, sa11_sub_round4, sa12_sub_round4, sa13_sub_round4;
wire  [7:0]	sa20_sub_round4, sa21_sub_round4, sa22_sub_round4, sa23_sub_round4;
wire	[7:0]	sa30_sub_round4, sa31_sub_round4, sa32_sub_round4, sa33_sub_round4;

wire	[7:0]	sa00_sr_round4, sa01_sr_round4, sa02_sr_round4, sa03_sr_round4;
wire	[7:0]	sa10_sr_round4, sa11_sr_round4, sa12_sr_round4, sa13_sr_round4;
wire	[7:0]	sa20_sr_round4, sa21_sr_round4, sa22_sr_round4, sa23_sr_round4;
wire	[7:0]	sa30_sr_round4, sa31_sr_round4, sa32_sr_round4, sa33_sr_round4;

wire	[7:0]	sa00_mc_round4, sa01_mc_round4, sa02_mc_round4, sa03_mc_round4;
wire	[7:0]	sa10_mc_round4, sa11_mc_round4, sa12_mc_round4, sa13_mc_round4;
wire	[7:0]	sa20_mc_round4, sa21_mc_round4, sa22_mc_round4, sa23_mc_round4;
wire	[7:0]	sa30_mc_round4, sa31_mc_round4, sa32_mc_round4, sa33_mc_round4;

//round5 wires
wire	[7:0]	sa00_next_round5, sa01_next_round5, sa02_next_round5, sa03_next_round5;
wire	[7:0]	sa10_next_round5, sa11_next_round5, sa12_next_round5, sa13_next_round5;
wire	[7:0]	sa20_next_round5, sa21_next_round5, sa22_next_round5, sa23_next_round5;
wire	[7:0]	sa30_next_round5, sa31_next_round5, sa32_next_round5, sa33_next_round5;

wire	[7:0]	sa00_sub_round5, sa01_sub_round5, sa02_sub_round5, sa03_sub_round5;
wire	[7:0]	sa10_sub_round5, sa11_sub_round5, sa12_sub_round5, sa13_sub_round5;
wire  [7:0]	sa20_sub_round5, sa21_sub_round5, sa22_sub_round5, sa23_sub_round5;
wire	[7:0]	sa30_sub_round5, sa31_sub_round5, sa32_sub_round5, sa33_sub_round5;

wire	[7:0]	sa00_sr_round5, sa01_sr_round5, sa02_sr_round5, sa03_sr_round5;
wire	[7:0]	sa10_sr_round5, sa11_sr_round5, sa12_sr_round5, sa13_sr_round5;
wire	[7:0]	sa20_sr_round5, sa21_sr_round5, sa22_sr_round5, sa23_sr_round5;
wire	[7:0]	sa30_sr_round5, sa31_sr_round5, sa32_sr_round5, sa33_sr_round5;

wire	[7:0]	sa00_mc_round5, sa01_mc_round5, sa02_mc_round5, sa03_mc_round5;
wire	[7:0]	sa10_mc_round5, sa11_mc_round5, sa12_mc_round5, sa13_mc_round5;
wire	[7:0]	sa20_mc_round5, sa21_mc_round5, sa22_mc_round5, sa23_mc_round5;
wire	[7:0]	sa30_mc_round5, sa31_mc_round5, sa32_mc_round5, sa33_mc_round5;


//round6 wires
wire	[7:0]	sa00_next_round6, sa01_next_round6, sa02_next_round6, sa03_next_round6;
wire	[7:0]	sa10_next_round6, sa11_next_round6, sa12_next_round6, sa13_next_round6;
wire	[7:0]	sa20_next_round6, sa21_next_round6, sa22_next_round6, sa23_next_round6;
wire	[7:0]	sa30_next_round6, sa31_next_round6, sa32_next_round6, sa33_next_round6;

wire	[7:0]	sa00_sub_round6, sa01_sub_round6, sa02_sub_round6, sa03_sub_round6;
wire	[7:0]	sa10_sub_round6, sa11_sub_round6, sa12_sub_round6, sa13_sub_round6;
wire  [7:0]	sa20_sub_round6, sa21_sub_round6, sa22_sub_round6, sa23_sub_round6;
wire	[7:0]	sa30_sub_round6, sa31_sub_round6, sa32_sub_round6, sa33_sub_round6;

wire	[7:0]	sa00_sr_round6, sa01_sr_round6, sa02_sr_round6, sa03_sr_round6;
wire	[7:0]	sa10_sr_round6, sa11_sr_round6, sa12_sr_round6, sa13_sr_round6;
wire	[7:0]	sa20_sr_round6, sa21_sr_round6, sa22_sr_round6, sa23_sr_round6;
wire	[7:0]	sa30_sr_round6, sa31_sr_round6, sa32_sr_round6, sa33_sr_round6;

wire	[7:0]	sa00_mc_round6, sa01_mc_round6, sa02_mc_round6, sa03_mc_round6;
wire	[7:0]	sa10_mc_round6, sa11_mc_round6, sa12_mc_round6, sa13_mc_round6;
wire	[7:0]	sa20_mc_round6, sa21_mc_round6, sa22_mc_round6, sa23_mc_round6;
wire	[7:0]	sa30_mc_round6, sa31_mc_round6, sa32_mc_round6, sa33_mc_round6;


//round7 wires
wire	[7:0]	sa00_next_round7, sa01_next_round7, sa02_next_round7, sa03_next_round7;
wire	[7:0]	sa10_next_round7, sa11_next_round7, sa12_next_round7, sa13_next_round7;
wire	[7:0]	sa20_next_round7, sa21_next_round7, sa22_next_round7, sa23_next_round7;
wire	[7:0]	sa30_next_round7, sa31_next_round7, sa32_next_round7, sa33_next_round7;

wire	[7:0]	sa00_sub_round7, sa01_sub_round7, sa02_sub_round7, sa03_sub_round7;
wire	[7:0]	sa10_sub_round7, sa11_sub_round7, sa12_sub_round7, sa13_sub_round7;
wire  [7:0]	sa20_sub_round7, sa21_sub_round7, sa22_sub_round7, sa23_sub_round7;
wire	[7:0]	sa30_sub_round7, sa31_sub_round7, sa32_sub_round7, sa33_sub_round7;

wire	[7:0]	sa00_sr_round7, sa01_sr_round7, sa02_sr_round7, sa03_sr_round7;
wire	[7:0]	sa10_sr_round7, sa11_sr_round7, sa12_sr_round7, sa13_sr_round7;
wire	[7:0]	sa20_sr_round7, sa21_sr_round7, sa22_sr_round7, sa23_sr_round7;
wire	[7:0]	sa30_sr_round7, sa31_sr_round7, sa32_sr_round7, sa33_sr_round7;

wire	[7:0]	sa00_mc_round7, sa01_mc_round7, sa02_mc_round7, sa03_mc_round7;
wire	[7:0]	sa10_mc_round7, sa11_mc_round7, sa12_mc_round7, sa13_mc_round7;
wire	[7:0]	sa20_mc_round7, sa21_mc_round7, sa22_mc_round7, sa23_mc_round7;
wire	[7:0]	sa30_mc_round7, sa31_mc_round7, sa32_mc_round7, sa33_mc_round7;


//round8 wires
wire	[7:0]	sa00_next_round8, sa01_next_round8, sa02_next_round8, sa03_next_round8;
wire	[7:0]	sa10_next_round8, sa11_next_round8, sa12_next_round8, sa13_next_round8;
wire	[7:0]	sa20_next_round8, sa21_next_round8, sa22_next_round8, sa23_next_round8;
wire	[7:0]	sa30_next_round8, sa31_next_round8, sa32_next_round8, sa33_next_round8;

wire	[7:0]	sa00_sub_round8, sa01_sub_round8, sa02_sub_round8, sa03_sub_round8;
wire	[7:0]	sa10_sub_round8, sa11_sub_round8, sa12_sub_round8, sa13_sub_round8;
wire  [7:0]	sa20_sub_round8, sa21_sub_round8, sa22_sub_round8, sa23_sub_round8;
wire	[7:0]	sa30_sub_round8, sa31_sub_round8, sa32_sub_round8, sa33_sub_round8;

wire	[7:0]	sa00_sr_round8, sa01_sr_round8, sa02_sr_round8, sa03_sr_round8;
wire	[7:0]	sa10_sr_round8, sa11_sr_round8, sa12_sr_round8, sa13_sr_round8;
wire	[7:0]	sa20_sr_round8, sa21_sr_round8, sa22_sr_round8, sa23_sr_round8;
wire	[7:0]	sa30_sr_round8, sa31_sr_round8, sa32_sr_round8, sa33_sr_round8;

wire	[7:0]	sa00_mc_round8, sa01_mc_round8, sa02_mc_round8, sa03_mc_round8;
wire	[7:0]	sa10_mc_round8, sa11_mc_round8, sa12_mc_round8, sa13_mc_round8;
wire	[7:0]	sa20_mc_round8, sa21_mc_round8, sa22_mc_round8, sa23_mc_round8;
wire	[7:0]	sa30_mc_round8, sa31_mc_round8, sa32_mc_round8, sa33_mc_round8;


//round9 wires
wire	[7:0]	sa00_next_round9, sa01_next_round9, sa02_next_round9, sa03_next_round9;
wire	[7:0]	sa10_next_round9, sa11_next_round9, sa12_next_round9, sa13_next_round9;
wire	[7:0]	sa20_next_round9, sa21_next_round9, sa22_next_round9, sa23_next_round9;
wire	[7:0]	sa30_next_round9, sa31_next_round9, sa32_next_round9, sa33_next_round9;

wire	[7:0]	sa00_sub_round9, sa01_sub_round9, sa02_sub_round9, sa03_sub_round9;
wire	[7:0]	sa10_sub_round9, sa11_sub_round9, sa12_sub_round9, sa13_sub_round9;
wire  [7:0]	sa20_sub_round9, sa21_sub_round9, sa22_sub_round9, sa23_sub_round9;
wire	[7:0]	sa30_sub_round9, sa31_sub_round9, sa32_sub_round9, sa33_sub_round9;

wire	[7:0]	sa00_sr_round9, sa01_sr_round9, sa02_sr_round9, sa03_sr_round9;
wire	[7:0]	sa10_sr_round9, sa11_sr_round9, sa12_sr_round9, sa13_sr_round9;
wire	[7:0]	sa20_sr_round9, sa21_sr_round9, sa22_sr_round9, sa23_sr_round9;
wire	[7:0]	sa30_sr_round9, sa31_sr_round9, sa32_sr_round9, sa33_sr_round9;

wire	[7:0]	sa00_mc_round9, sa01_mc_round9, sa02_mc_round9, sa03_mc_round9;
wire	[7:0]	sa10_mc_round9, sa11_mc_round9, sa12_mc_round9, sa13_mc_round9;
wire	[7:0]	sa20_mc_round9, sa21_mc_round9, sa22_mc_round9, sa23_mc_round9;
wire	[7:0]	sa30_mc_round9, sa31_mc_round9, sa32_mc_round9, sa33_mc_round9;


//round10 wires
wire	[7:0]	sa00_next_round10, sa01_next_round10, sa02_next_round10, sa03_next_round10;
wire	[7:0]	sa10_next_round10, sa11_next_round10, sa12_next_round10, sa13_next_round10;
wire	[7:0]	sa20_next_round10, sa21_next_round10, sa22_next_round10, sa23_next_round10;
wire	[7:0]	sa30_next_round10, sa31_next_round10, sa32_next_round10, sa33_next_round10;

wire	[7:0]	sa00_sub_round10, sa01_sub_round10, sa02_sub_round10, sa03_sub_round10;
wire	[7:0]	sa10_sub_round10, sa11_sub_round10, sa12_sub_round10, sa13_sub_round10;
wire  [7:0]	sa20_sub_round10, sa21_sub_round10, sa22_sub_round10, sa23_sub_round10;
wire	[7:0]	sa30_sub_round10, sa31_sub_round10, sa32_sub_round10, sa33_sub_round10;

wire	[7:0]	sa00_sr_round10, sa01_sr_round10, sa02_sr_round10, sa03_sr_round10;
wire	[7:0]	sa10_sr_round10, sa11_sr_round10, sa12_sr_round10, sa13_sr_round10;
wire	[7:0]	sa20_sr_round10, sa21_sr_round10, sa22_sr_round10, sa23_sr_round10;
wire	[7:0]	sa30_sr_round10, sa31_sr_round10, sa32_sr_round10, sa33_sr_round10;



reg		done, ld_r;
reg	[3:0]	dcnt;
reg 		done2;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
begin
	if(~rst)	begin dcnt <=  4'h0;	 end
	else
	if(ld)	begin	dcnt <=  4'hb;	 end
	else
	if(|dcnt) begin	dcnt <=  dcnt - 4'h1;  end

end

always @(posedge clk) done <=  !(|dcnt[3:1]) & dcnt[0] & !ld;
always @(posedge clk) if(ld) text_in_r <=  text_in;
always @(posedge clk) ld_r <=  ld;



////////////////////////////////////////////////////////////////////
// key expansion


aes_key_expand_128 u0(
	.clk(		clk	),
	.key(		key	),
	.w0(		w0	),
	.w1(		w1	),
	.w2(		w2	),
	.w3(		w3	),
	.w4(		w4	),
	.w5(		w5	),
	.w6(		w6	),
	.w7(		w7	),
	.w8(		w8	),
	.w9(		w9	),
	.w10(		w10	),
	.w11(		w11	),
	.w12(		w12	),
	.w13(		w13	),
	.w14(		w14	),
	.w15(		w15	),
	.w16(		w16	),
	.w17(		w17	),
	.w18(		w18	),
	.w19(		w19	),	
	.w20(		w20	),
	.w21(		w21	),
	.w22(		w22	),
	.w23(		w23	),
	.w24(		w24	),
	.w25(		w25	),
	.w26(		w26	),
	.w27(		w27	),
	.w28(		w28	),
	.w29(		w29	),
	.w30(		w30	),
	.w31(		w31	),
	.w32(		w32	),
	.w33(		w33	),
	.w34(		w34	),
	.w35(		w35	),
	.w36(		w36	),
	.w37(		w37	),
	.w38(		w38	),
	.w39(		w39	),
	.w40(		w40	),
	.w41(		w41	),
	.w42(		w42	),
	.w43(		w43	)
					);

always @(posedge clk) 
begin
   	sa33 <=   text_in_r[007:000] ^ w3[07:00]; //sa33_mc_round2 ^ w3[07:00];
    	sa23 <=   text_in_r[015:008] ^ w3[15:08]; //sa23_mc_round2 ^ w3[15:08];
    	sa13 <=   text_in_r[023:016] ^ w3[23:16]; //sa13_mc_round2 ^ w3[23:16];
    	sa03 <=   text_in_r[031:024] ^ w3[31:24]; //sa03_mc_round2 ^ w3[31:24];
    	sa32 <=   text_in_r[039:032] ^ w2[07:00]; //sa32_mc_round2 ^ w2[07:00];
    	sa22 <=   text_in_r[047:040] ^ w2[15:08]; //sa22_mc_round2 ^ w2[15:08];
    	sa12 <=   text_in_r[055:048] ^ w2[23:16]; //sa12_mc_round2 ^ w2[23:16];
    	sa02 <=   text_in_r[063:056] ^ w2[31:24]; //sa02_mc_round2 ^ w2[31:24];
    	sa31 <=   text_in_r[071:064] ^ w1[07:00]; //sa31_mc_round2 ^ w1[07:00];
    	sa21 <=   text_in_r[079:072] ^ w1[15:08]; //sa21_mc_round2 ^ w1[15:08];
    	sa11 <=   text_in_r[087:080] ^ w1[23:16]; //sa11_mc_round2 ^ w1[23:16];
    	sa01 <=   text_in_r[095:088] ^ w1[31:24]; //sa01_mc_round2 ^ w1[31:24];
    	sa30 <=   text_in_r[103:096] ^ w0[07:00]; //sa30_mc_round2 ^ w0[07:00];
    	sa20 <=   text_in_r[111:104] ^ w0[15:08]; //sa20_mc_round2 ^ w0[15:08];
    	sa10 <=   text_in_r[119:112] ^ w0[23:16]; //sa10_mc_round2 ^ w0[23:16];
    	sa00 <=   text_in_r[127:120] ^ w0[31:24]; //sa00_mc_round2 ^ w0[31:24];
				
end


//sbox lookup
aes_sbox us00(	.a(	sa00	), .d(	sa00_sub	));
aes_sbox us01(	.a(	sa01	), .d(	sa01_sub	));
aes_sbox us02(	.a(	sa02	), .d(	sa02_sub	));
aes_sbox us03(	.a(	sa03	), .d(	sa03_sub	));
aes_sbox us10(	.a(	sa10	), .d(	sa10_sub	));
aes_sbox us11(	.a(	sa11	), .d(	sa11_sub	));
aes_sbox us12(	.a(	sa12	), .d(	sa12_sub	));
aes_sbox us13(	.a(	sa13	), .d(	sa13_sub	));
aes_sbox us20(	.a(	sa20	), .d(	sa20_sub	));
aes_sbox us21(	.a(	sa21	), .d(	sa21_sub	));
aes_sbox us22(	.a(	sa22	), .d(	sa22_sub	));
aes_sbox us23(	.a(	sa23	), .d(	sa23_sub	));
aes_sbox us30(	.a(	sa30	), .d(	sa30_sub	));
aes_sbox us31(	.a(	sa31	), .d(	sa31_sub	));
aes_sbox us32(	.a(	sa32	), .d(	sa32_sub	));
aes_sbox us33(	.a(	sa33	), .d(	sa33_sub	));

//shift rows

assign sa00_sr = sa00_sub;		//
assign sa01_sr = sa01_sub;		//no shift
assign sa02_sr = sa02_sub;		//
assign sa03_sr = sa03_sub;		//

assign sa10_sr = sa11_sub;		//
assign sa11_sr = sa12_sub;		// left shift by 1
assign sa12_sr = sa13_sub;		//
assign sa13_sr = sa10_sub;		//

assign sa20_sr = sa22_sub;		//
assign sa21_sr = sa23_sub;		//	left shift by 2
assign sa22_sr = sa20_sub;		//
assign sa23_sr = sa21_sub;		//

assign sa30_sr = sa33_sub;		//
assign sa31_sr = sa30_sub;		// left shift by 3
assign sa32_sr = sa31_sub;		//
assign sa33_sr = sa32_sub;		//

// mix column operation
assign {sa00_mc, sa10_mc, sa20_mc, sa30_mc}  = mix_col(sa00_sr,sa10_sr,sa20_sr,sa30_sr);
assign {sa01_mc, sa11_mc, sa21_mc, sa31_mc}  = mix_col(sa01_sr,sa11_sr,sa21_sr,sa31_sr);
assign {sa02_mc, sa12_mc, sa22_mc, sa32_mc}  = mix_col(sa02_sr,sa12_sr,sa22_sr,sa32_sr);
assign {sa03_mc, sa13_mc, sa23_mc, sa33_mc}  = mix_col(sa03_sr,sa13_sr,sa23_sr,sa33_sr);

//// add round key
assign sa00_next_round2 = sa00_mc ^ w4[31:24];		
assign sa01_next_round2 = sa01_mc ^ w5[31:24];
assign sa02_next_round2 = sa02_mc ^ w6[31:24];
assign sa03_next_round2 = sa03_mc ^ w7[31:24];
assign sa10_next_round2 = sa10_mc ^ w4[23:16];
assign sa11_next_round2 = sa11_mc ^ w5[23:16];
assign sa12_next_round2 = sa12_mc ^ w6[23:16];
assign sa13_next_round2 = sa13_mc ^ w7[23:16];
assign sa20_next_round2 = sa20_mc ^ w4[15:08];
assign sa21_next_round2 = sa21_mc ^ w5[15:08];
assign sa22_next_round2 = sa22_mc ^ w6[15:08];
assign sa23_next_round2 = sa23_mc ^ w7[15:08];
assign sa30_next_round2 = sa30_mc ^ w4[07:00];
assign sa31_next_round2 = sa31_mc ^ w5[07:00];
assign sa32_next_round2 = sa32_mc ^ w6[07:00];
assign sa33_next_round2 = sa33_mc ^ w7[07:00];



always @(posedge clk)
	begin
		  text_out_stage1[127:120] <=  sa00_next_round2;	 
		  text_out_stage1[095:088] <=  sa01_next_round2;	 
		  text_out_stage1[063:056] <=  sa02_next_round2;	 
		  text_out_stage1[031:024] <=  sa03_next_round2;	 
		  text_out_stage1[119:112] <=  sa10_next_round2;	 
		  text_out_stage1[087:080] <=  sa11_next_round2;	 
		  text_out_stage1[055:048] <=  sa12_next_round2;	 
		  text_out_stage1[023:016] <=  sa13_next_round2;	 
		  text_out_stage1[111:104] <=  sa20_next_round2;	 
		  text_out_stage1[079:072] <=  sa21_next_round2;	 
		  text_out_stage1[047:040] <=  sa22_next_round2;	 
		  text_out_stage1[015:008] <=  sa23_next_round2;	 
		  text_out_stage1[103:096] <=  sa30_next_round2;	 
		  text_out_stage1[071:064] <=  sa31_next_round2;	 
		  text_out_stage1[039:032] <=  sa32_next_round2;	 
		  text_out_stage1[007:000] <=  sa33_next_round2;
			
	end



//////////////////////  round 2 //////////////////////////////////

//sbox lookup
aes_sbox us00_round2(	.a(text_out_stage1[127:120]		), .d(	sa00_sub_round2	));
aes_sbox us01_round2(	.a(text_out_stage1[095:088]		), .d(	sa01_sub_round2	));
aes_sbox us02_round2(	.a(text_out_stage1[063:056]		), .d(	sa02_sub_round2	));
aes_sbox us03_round2(	.a(text_out_stage1[031:024]		), .d(	sa03_sub_round2	));
aes_sbox us10_round2(	.a(text_out_stage1[119:112]		), .d(	sa10_sub_round2	));
aes_sbox us11_round2(	.a(text_out_stage1[087:080]		), .d(	sa11_sub_round2	));
aes_sbox us12_round2(	.a(text_out_stage1[055:048]		), .d(	sa12_sub_round2	));
aes_sbox us13_round2(	.a(text_out_stage1[023:016]		), .d(	sa13_sub_round2	));
aes_sbox us20_round2(	.a(text_out_stage1[111:104]		), .d(	sa20_sub_round2	));
aes_sbox us21_round2(	.a(text_out_stage1[079:072]		), .d(	sa21_sub_round2	));
aes_sbox us22_round2(	.a(text_out_stage1[047:040]		), .d(	sa22_sub_round2	));
aes_sbox us23_round2(	.a(text_out_stage1[015:008]		), .d(	sa23_sub_round2	));
aes_sbox us30_round2(	.a(text_out_stage1[103:096]		), .d(	sa30_sub_round2	));
aes_sbox us31_round2(	.a(text_out_stage1[071:064]		), .d(	sa31_sub_round2	));
aes_sbox us32_round2(	.a(text_out_stage1[039:032]		), .d(	sa32_sub_round2	));
aes_sbox us33_round2(	.a(text_out_stage1[007:000]		), .d(	sa33_sub_round2	));

//shift rows

assign sa00_sr_round2 = sa00_sub_round2;		//
assign sa01_sr_round2 = sa01_sub_round2;		//no shift
assign sa02_sr_round2 = sa02_sub_round2;		//
assign sa03_sr_round2 = sa03_sub_round2;		//

assign sa10_sr_round2 = sa11_sub_round2;		//
assign sa11_sr_round2 = sa12_sub_round2;		// left shift by 1
assign sa12_sr_round2 = sa13_sub_round2;		//
assign sa13_sr_round2 = sa10_sub_round2;		//

assign sa20_sr_round2 = sa22_sub_round2;		//
assign sa21_sr_round2 = sa23_sub_round2;		//	left shift by 2
assign sa22_sr_round2 = sa20_sub_round2;		//
assign sa23_sr_round2 = sa21_sub_round2;		//

assign sa30_sr_round2 = sa33_sub_round2;		//
assign sa31_sr_round2 = sa30_sub_round2;		// left shift by 3
assign sa32_sr_round2 = sa31_sub_round2;		//
assign sa33_sr_round2 = sa32_sub_round2;		//

// mix column operation
assign {sa00_mc_round2, sa10_mc_round2, sa20_mc_round2, sa30_mc_round2}  = mix_col(sa00_sr_round2,sa10_sr_round2,sa20_sr_round2,sa30_sr_round2);
assign {sa01_mc_round2, sa11_mc_round2, sa21_mc_round2, sa31_mc_round2}  = mix_col(sa01_sr_round2,sa11_sr_round2,sa21_sr_round2,sa31_sr_round2);
assign {sa02_mc_round2, sa12_mc_round2, sa22_mc_round2, sa32_mc_round2}  = mix_col(sa02_sr_round2,sa12_sr_round2,sa22_sr_round2,sa32_sr_round2);
assign {sa03_mc_round2, sa13_mc_round2, sa23_mc_round2, sa33_mc_round2}  = mix_col(sa03_sr_round2,sa13_sr_round2,sa23_sr_round2,sa33_sr_round2);

//add round key
assign sa33_next_round3 = 		   sa33_mc_round2 ^ w11[07:00];
assign sa23_next_round3 =     	sa23_mc_round2 ^ w11[15:08];
assign sa13_next_round3 =     	sa13_mc_round2 ^ w11[23:16];
assign sa03_next_round3 =     	sa03_mc_round2 ^ w11[31:24];
assign sa32_next_round3 =     	sa32_mc_round2 ^ w10[07:00];
assign sa22_next_round3 =     	sa22_mc_round2 ^ w10[15:08];
assign sa12_next_round3 =     	sa12_mc_round2 ^ w10[23:16];
assign sa02_next_round3 =     	sa02_mc_round2 ^ w10[31:24];
assign sa31_next_round3 =     	sa31_mc_round2 ^ w9[07:00];
assign sa21_next_round3 =     	sa21_mc_round2 ^ w9[15:08];
assign sa11_next_round3 =     	sa11_mc_round2 ^ w9[23:16];
assign sa01_next_round3 =     	sa01_mc_round2 ^ w9[31:24];
assign sa30_next_round3 =     	sa30_mc_round2 ^ w8[07:00];
assign sa20_next_round3 =     	sa20_mc_round2 ^ w8[15:08];
assign sa10_next_round3 =     	sa10_mc_round2 ^ w8[23:16];
assign sa00_next_round3 =     	sa00_mc_round2 ^ w8[31:24];



always @(posedge clk)
	begin
		  text_out_stage2[127:120] <=  sa00_next_round3;	 
		  text_out_stage2[095:088] <=  sa01_next_round3;	 
		  text_out_stage2[063:056] <=  sa02_next_round3;	 
		  text_out_stage2[031:024] <=  sa03_next_round3;	 
		  text_out_stage2[119:112] <=  sa10_next_round3;	 
		  text_out_stage2[087:080] <=  sa11_next_round3;	 
		  text_out_stage2[055:048] <=  sa12_next_round3;	 
		  text_out_stage2[023:016] <=  sa13_next_round3;	 
		  text_out_stage2[111:104] <=  sa20_next_round3;	 
		  text_out_stage2[079:072] <=  sa21_next_round3;	 
		  text_out_stage2[047:040] <=  sa22_next_round3;	 
		  text_out_stage2[015:008] <=  sa23_next_round3;	 
		  text_out_stage2[103:096] <=  sa30_next_round3;	 
		  text_out_stage2[071:064] <=  sa31_next_round3;	 
		  text_out_stage2[039:032] <=  sa32_next_round3;	 
		  text_out_stage2[007:000] <=  sa33_next_round3;
			
	end



//////////////////////  round 3 //////////////////////////////////

//sbox lookup
aes_sbox us00_round3(	.a(text_out_stage2[127:120]		), .d(	sa00_sub_round3	));
aes_sbox us01_round3(	.a(text_out_stage2[095:088]		), .d(	sa01_sub_round3	));
aes_sbox us02_round3(	.a(text_out_stage2[063:056]		), .d(	sa02_sub_round3	));
aes_sbox us03_round3(	.a(text_out_stage2[031:024]		), .d(	sa03_sub_round3	));
aes_sbox us10_round3(	.a(text_out_stage2[119:112]		), .d(	sa10_sub_round3	));
aes_sbox us11_round3(	.a(text_out_stage2[087:080]		), .d(	sa11_sub_round3	));
aes_sbox us12_round3(	.a(text_out_stage2[055:048]		), .d(	sa12_sub_round3	));
aes_sbox us13_round3(	.a(text_out_stage2[023:016]		), .d(	sa13_sub_round3	));
aes_sbox us20_round3(	.a(text_out_stage2[111:104]		), .d(	sa20_sub_round3	));
aes_sbox us21_round3(	.a(text_out_stage2[079:072]		), .d(	sa21_sub_round3	));
aes_sbox us22_round3(	.a(text_out_stage2[047:040]		), .d(	sa22_sub_round3	));
aes_sbox us23_round3(	.a(text_out_stage2[015:008]		), .d(	sa23_sub_round3	));
aes_sbox us30_round3(	.a(text_out_stage2[103:096]		), .d(	sa30_sub_round3	));
aes_sbox us31_round3(	.a(text_out_stage2[071:064]		), .d(	sa31_sub_round3	));
aes_sbox us32_round3(	.a(text_out_stage2[039:032]		), .d(	sa32_sub_round3	));
aes_sbox us33_round3(	.a(text_out_stage2[007:000]		), .d(	sa33_sub_round3	));



//shift rows

assign sa00_sr_round3 = sa00_sub_round3;		//
assign sa01_sr_round3 = sa01_sub_round3;		//no shift
assign sa02_sr_round3 = sa02_sub_round3;		//
assign sa03_sr_round3 = sa03_sub_round3;		//

assign sa10_sr_round3 = sa11_sub_round3;		//
assign sa11_sr_round3 = sa12_sub_round3;		// left shift by 1
assign sa12_sr_round3 = sa13_sub_round3;		//
assign sa13_sr_round3 = sa10_sub_round3;		//

assign sa20_sr_round3 = sa22_sub_round3;		//
assign sa21_sr_round3 = sa23_sub_round3;		//	left shift by 2
assign sa22_sr_round3 = sa20_sub_round3;		//
assign sa23_sr_round3 = sa21_sub_round3;		//

assign sa30_sr_round3 = sa33_sub_round3;		//
assign sa31_sr_round3 = sa30_sub_round3;		// left shift by 3
assign sa32_sr_round3 = sa31_sub_round3;		//
assign sa33_sr_round3 = sa32_sub_round3;		//

// mix column operation
assign {sa00_mc_round3, sa10_mc_round3, sa20_mc_round3, sa30_mc_round3}  = mix_col(sa00_sr_round3,sa10_sr_round3,sa20_sr_round3,sa30_sr_round3);
assign {sa01_mc_round3, sa11_mc_round3, sa21_mc_round3, sa31_mc_round3}  = mix_col(sa01_sr_round3,sa11_sr_round3,sa21_sr_round3,sa31_sr_round3);
assign {sa02_mc_round3, sa12_mc_round3, sa22_mc_round3, sa32_mc_round3}  = mix_col(sa02_sr_round3,sa12_sr_round3,sa22_sr_round3,sa32_sr_round3);
assign {sa03_mc_round3, sa13_mc_round3, sa23_mc_round3, sa33_mc_round3}  = mix_col(sa03_sr_round3,sa13_sr_round3,sa23_sr_round3,sa33_sr_round3);


//add round key
assign sa33_next_round4 = 		   sa33_mc_round3 ^ w15[07:00];
assign sa23_next_round4 =     	sa23_mc_round3 ^ w15[15:08];
assign sa13_next_round4 =     	sa13_mc_round3 ^ w15[23:16];
assign sa03_next_round4 =     	sa03_mc_round3 ^ w15[31:24];
assign sa32_next_round4 =     	sa32_mc_round3 ^ w14[07:00];
assign sa22_next_round4 =     	sa22_mc_round3 ^ w14[15:08];
assign sa12_next_round4 =     	sa12_mc_round3 ^ w14[23:16];
assign sa02_next_round4 =     	sa02_mc_round3 ^ w14[31:24];
assign sa31_next_round4 =     	sa31_mc_round3 ^ w13[07:00];
assign sa21_next_round4 =     	sa21_mc_round3 ^ w13[15:08];
assign sa11_next_round4 =     	sa11_mc_round3 ^ w13[23:16];
assign sa01_next_round4 =     	sa01_mc_round3 ^ w13[31:24];
assign sa30_next_round4 =     	sa30_mc_round3 ^ w12[07:00];
assign sa20_next_round4 =     	sa20_mc_round3 ^ w12[15:08];
assign sa10_next_round4 =     	sa10_mc_round3 ^ w12[23:16];
assign sa00_next_round4 =     	sa00_mc_round3 ^ w12[31:24];


always @(posedge clk)
	begin
		  text_out_stage3[127:120] <=  sa00_next_round4;	 
		  text_out_stage3[095:088] <=  sa01_next_round4;	 
		  text_out_stage3[063:056] <=  sa02_next_round4;	 
		  text_out_stage3[031:024] <=  sa03_next_round4;	 
		  text_out_stage3[119:112] <=  sa10_next_round4;	 
		  text_out_stage3[087:080] <=  sa11_next_round4;	 
		  text_out_stage3[055:048] <=  sa12_next_round4;	 
		  text_out_stage3[023:016] <=  sa13_next_round4;	 
		  text_out_stage3[111:104] <=  sa20_next_round4;	 
		  text_out_stage3[079:072] <=  sa21_next_round4;	 
		  text_out_stage3[047:040] <=  sa22_next_round4;	 
		  text_out_stage3[015:008] <=  sa23_next_round4;	 
		  text_out_stage3[103:096] <=  sa30_next_round4;	 
		  text_out_stage3[071:064] <=  sa31_next_round4;	 
		  text_out_stage3[039:032] <=  sa32_next_round4;	 
		  text_out_stage3[007:000] <=  sa33_next_round4;
			
	end



//////////////////////  round 4 //////////////////////////////////

//sbox lookup
aes_sbox us00_round4(	.a(text_out_stage3[127:120]		), .d(	sa00_sub_round4	));
aes_sbox us01_round4(	.a(text_out_stage3[095:088]		), .d(	sa01_sub_round4	));
aes_sbox us02_round4(	.a(text_out_stage3[063:056]		), .d(	sa02_sub_round4	));
aes_sbox us03_round4(	.a(text_out_stage3[031:024]		), .d(	sa03_sub_round4	));
aes_sbox us10_round4(	.a(text_out_stage3[119:112]		), .d(	sa10_sub_round4	));
aes_sbox us11_round4(	.a(text_out_stage3[087:080]		), .d(	sa11_sub_round4	));
aes_sbox us12_round4(	.a(text_out_stage3[055:048]		), .d(	sa12_sub_round4	));
aes_sbox us13_round4(	.a(text_out_stage3[023:016]		), .d(	sa13_sub_round4	));
aes_sbox us20_round4(	.a(text_out_stage3[111:104]		), .d(	sa20_sub_round4	));
aes_sbox us21_round4(	.a(text_out_stage3[079:072]		), .d(	sa21_sub_round4	));
aes_sbox us22_round4(	.a(text_out_stage3[047:040]		), .d(	sa22_sub_round4	));
aes_sbox us23_round4(	.a(text_out_stage3[015:008]		), .d(	sa23_sub_round4	));
aes_sbox us30_round4(	.a(text_out_stage3[103:096]		), .d(	sa30_sub_round4	));
aes_sbox us31_round4(	.a(text_out_stage3[071:064]		), .d(	sa31_sub_round4	));
aes_sbox us32_round4(	.a(text_out_stage3[039:032]		), .d(	sa32_sub_round4	));
aes_sbox us33_round4(	.a(text_out_stage3[007:000]		), .d(	sa33_sub_round4	));


//shift rows

assign sa00_sr_round4 = sa00_sub_round4;		//
assign sa01_sr_round4 = sa01_sub_round4;		//no shift
assign sa02_sr_round4 = sa02_sub_round4;		//
assign sa03_sr_round4 = sa03_sub_round4;		//

assign sa10_sr_round4 = sa11_sub_round4;		//
assign sa11_sr_round4 = sa12_sub_round4;		// left shift by 1
assign sa12_sr_round4 = sa13_sub_round4;		//
assign sa13_sr_round4 = sa10_sub_round4;		//

assign sa20_sr_round4 = sa22_sub_round4;		//
assign sa21_sr_round4 = sa23_sub_round4;		//	left shift by 2
assign sa22_sr_round4 = sa20_sub_round4;		//
assign sa23_sr_round4 = sa21_sub_round4;		//

assign sa30_sr_round4 = sa33_sub_round4;		//
assign sa31_sr_round4 = sa30_sub_round4;		// left shift by 3
assign sa32_sr_round4 = sa31_sub_round4;		//
assign sa33_sr_round4 = sa32_sub_round4;		//

// mix column operation
assign {sa00_mc_round4, sa10_mc_round4, sa20_mc_round4, sa30_mc_round4}  = mix_col(sa00_sr_round4,sa10_sr_round4,sa20_sr_round4,sa30_sr_round4);
assign {sa01_mc_round4, sa11_mc_round4, sa21_mc_round4, sa31_mc_round4}  = mix_col(sa01_sr_round4,sa11_sr_round4,sa21_sr_round4,sa31_sr_round4);
assign {sa02_mc_round4, sa12_mc_round4, sa22_mc_round4, sa32_mc_round4}  = mix_col(sa02_sr_round4,sa12_sr_round4,sa22_sr_round4,sa32_sr_round4);
assign {sa03_mc_round4, sa13_mc_round4, sa23_mc_round4, sa33_mc_round4}  = mix_col(sa03_sr_round4,sa13_sr_round4,sa23_sr_round4,sa33_sr_round4);


//add round key
assign sa33_next_round5 = 		   sa33_mc_round4 ^ w19[07:00];
assign sa23_next_round5 =     	sa23_mc_round4 ^ w19[15:08];
assign sa13_next_round5 =     	sa13_mc_round4 ^ w19[23:16];
assign sa03_next_round5 =     	sa03_mc_round4 ^ w19[31:24];
assign sa32_next_round5 =     	sa32_mc_round4 ^ w18[07:00];
assign sa22_next_round5 =     	sa22_mc_round4 ^ w18[15:08];
assign sa12_next_round5 =     	sa12_mc_round4 ^ w18[23:16];
assign sa02_next_round5 =     	sa02_mc_round4 ^ w18[31:24];
assign sa31_next_round5 =     	sa31_mc_round4 ^ w17[07:00];
assign sa21_next_round5 =     	sa21_mc_round4 ^ w17[15:08];
assign sa11_next_round5 =     	sa11_mc_round4 ^ w17[23:16];
assign sa01_next_round5 =     	sa01_mc_round4 ^ w17[31:24];
assign sa30_next_round5 =     	sa30_mc_round4 ^ w16[07:00];
assign sa20_next_round5 =     	sa20_mc_round4 ^ w16[15:08];
assign sa10_next_round5 =     	sa10_mc_round4 ^ w16[23:16];
assign sa00_next_round5 =     	sa00_mc_round4 ^ w16[31:24];


always @(posedge clk)
	begin
		  text_out_stage4[127:120] <=  sa00_next_round5;	 
		  text_out_stage4[095:088] <=  sa01_next_round5;	 
		  text_out_stage4[063:056] <=  sa02_next_round5;	 
		  text_out_stage4[031:024] <=  sa03_next_round5;	 
		  text_out_stage4[119:112] <=  sa10_next_round5;	 
		  text_out_stage4[087:080] <=  sa11_next_round5;	 
		  text_out_stage4[055:048] <=  sa12_next_round5;	 
		  text_out_stage4[023:016] <=  sa13_next_round5;	 
		  text_out_stage4[111:104] <=  sa20_next_round5;	 
		  text_out_stage4[079:072] <=  sa21_next_round5;	 
		  text_out_stage4[047:040] <=  sa22_next_round5;	 
		  text_out_stage4[015:008] <=  sa23_next_round5;	 
		  text_out_stage4[103:096] <=  sa30_next_round5;	 
		  text_out_stage4[071:064] <=  sa31_next_round5;	 
		  text_out_stage4[039:032] <=  sa32_next_round5;	 
		  text_out_stage4[007:000] <=  sa33_next_round5;
			
	end



//////////////////////  round 5 //////////////////////////////////

//sbox lookup
aes_sbox us00_round5(	.a(text_out_stage4[127:120]		), .d(	sa00_sub_round5	));
aes_sbox us01_round5(	.a(text_out_stage4[095:088]		), .d(	sa01_sub_round5	));
aes_sbox us02_round5(	.a(text_out_stage4[063:056]		), .d(	sa02_sub_round5	));
aes_sbox us03_round5(	.a(text_out_stage4[031:024]		), .d(	sa03_sub_round5	));
aes_sbox us10_round5(	.a(text_out_stage4[119:112]		), .d(	sa10_sub_round5	));
aes_sbox us11_round5(	.a(text_out_stage4[087:080]		), .d(	sa11_sub_round5	));
aes_sbox us12_round5(	.a(text_out_stage4[055:048]		), .d(	sa12_sub_round5	));
aes_sbox us13_round5(	.a(text_out_stage4[023:016]		), .d(	sa13_sub_round5	));
aes_sbox us20_round5(	.a(text_out_stage4[111:104]		), .d(	sa20_sub_round5	));
aes_sbox us21_round5(	.a(text_out_stage4[079:072]		), .d(	sa21_sub_round5	));
aes_sbox us22_round5(	.a(text_out_stage4[047:040]		), .d(	sa22_sub_round5	));
aes_sbox us23_round5(	.a(text_out_stage4[015:008]		), .d(	sa23_sub_round5	));
aes_sbox us30_round5(	.a(text_out_stage4[103:096]		), .d(	sa30_sub_round5	));
aes_sbox us31_round5(	.a(text_out_stage4[071:064]		), .d(	sa31_sub_round5	));
aes_sbox us32_round5(	.a(text_out_stage4[039:032]		), .d(	sa32_sub_round5	));
aes_sbox us33_round5(	.a(text_out_stage4[007:000]		), .d(	sa33_sub_round5	));





//shift rows

assign sa00_sr_round5 = sa00_sub_round5;		//
assign sa01_sr_round5 = sa01_sub_round5;		//no shift
assign sa02_sr_round5 = sa02_sub_round5;		//
assign sa03_sr_round5 = sa03_sub_round5;		//

assign sa10_sr_round5 = sa11_sub_round5;		//
assign sa11_sr_round5 = sa12_sub_round5;		// left shift by 1
assign sa12_sr_round5 = sa13_sub_round5;		//
assign sa13_sr_round5 = sa10_sub_round5;		//

assign sa20_sr_round5 = sa22_sub_round5;		//
assign sa21_sr_round5 = sa23_sub_round5;		//	left shift by 2
assign sa22_sr_round5 = sa20_sub_round5;		//
assign sa23_sr_round5 = sa21_sub_round5;		//

assign sa30_sr_round5 = sa33_sub_round5;		//
assign sa31_sr_round5 = sa30_sub_round5;		// left shift by 3
assign sa32_sr_round5 = sa31_sub_round5;		//
assign sa33_sr_round5 = sa32_sub_round5;		//

// mix column operation
assign {sa00_mc_round5, sa10_mc_round5, sa20_mc_round5, sa30_mc_round5}  = mix_col(sa00_sr_round5,sa10_sr_round5,sa20_sr_round5,sa30_sr_round5);
assign {sa01_mc_round5, sa11_mc_round5, sa21_mc_round5, sa31_mc_round5}  = mix_col(sa01_sr_round5,sa11_sr_round5,sa21_sr_round5,sa31_sr_round5);
assign {sa02_mc_round5, sa12_mc_round5, sa22_mc_round5, sa32_mc_round5}  = mix_col(sa02_sr_round5,sa12_sr_round5,sa22_sr_round5,sa32_sr_round5);
assign {sa03_mc_round5, sa13_mc_round5, sa23_mc_round5, sa33_mc_round5}  = mix_col(sa03_sr_round5,sa13_sr_round5,sa23_sr_round5,sa33_sr_round5);


//add round key
assign sa33_next_round6 = 		   sa33_mc_round5 ^ w23[07:00];
assign sa23_next_round6 =     	sa23_mc_round5 ^ w23[15:08];
assign sa13_next_round6 =     	sa13_mc_round5 ^ w23[23:16];
assign sa03_next_round6 =     	sa03_mc_round5 ^ w23[31:24];
assign sa32_next_round6 =     	sa32_mc_round5 ^ w22[07:00];
assign sa22_next_round6 =     	sa22_mc_round5 ^ w22[15:08];
assign sa12_next_round6 =     	sa12_mc_round5 ^ w22[23:16];
assign sa02_next_round6 =     	sa02_mc_round5 ^ w22[31:24];
assign sa31_next_round6 =     	sa31_mc_round5 ^ w21[07:00];
assign sa21_next_round6 =     	sa21_mc_round5 ^ w21[15:08];
assign sa11_next_round6 =     	sa11_mc_round5 ^ w21[23:16];
assign sa01_next_round6 =     	sa01_mc_round5 ^ w21[31:24];
assign sa30_next_round6 =     	sa30_mc_round5 ^ w20[07:00];
assign sa20_next_round6 =     	sa20_mc_round5 ^ w20[15:08];
assign sa10_next_round6 =     	sa10_mc_round5 ^ w20[23:16];
assign sa00_next_round6 =     	sa00_mc_round5 ^ w20[31:24];


always @(posedge clk)
	begin
		  text_out_stage5[127:120] <=  sa00_next_round6;	 
		  text_out_stage5[095:088] <=  sa01_next_round6;	 
		  text_out_stage5[063:056] <=  sa02_next_round6;	 
		  text_out_stage5[031:024] <=  sa03_next_round6;	 
		  text_out_stage5[119:112] <=  sa10_next_round6;	 
		  text_out_stage5[087:080] <=  sa11_next_round6;	 
		  text_out_stage5[055:048] <=  sa12_next_round6;	 
		  text_out_stage5[023:016] <=  sa13_next_round6;	 
		  text_out_stage5[111:104] <=  sa20_next_round6;	 
		  text_out_stage5[079:072] <=  sa21_next_round6;	 
		  text_out_stage5[047:040] <=  sa22_next_round6;	 
		  text_out_stage5[015:008] <=  sa23_next_round6;	 
		  text_out_stage5[103:096] <=  sa30_next_round6;	 
		  text_out_stage5[071:064] <=  sa31_next_round6;	 
		  text_out_stage5[039:032] <=  sa32_next_round6;	 
		  text_out_stage5[007:000] <=  sa33_next_round6;
			
	end



//////////////////////  round 6 //////////////////////////////////

//sbox lookup
aes_sbox us00_round6(	.a(text_out_stage5[127:120]		), .d(	sa00_sub_round6	));
aes_sbox us01_round6(	.a(text_out_stage5[095:088]		), .d(	sa01_sub_round6	));
aes_sbox us02_round6(	.a(text_out_stage5[063:056]		), .d(	sa02_sub_round6	));
aes_sbox us03_round6(	.a(text_out_stage5[031:024]		), .d(	sa03_sub_round6	));
aes_sbox us10_round6(	.a(text_out_stage5[119:112]		), .d(	sa10_sub_round6	));
aes_sbox us11_round6(	.a(text_out_stage5[087:080]		), .d(	sa11_sub_round6	));
aes_sbox us12_round6(	.a(text_out_stage5[055:048]		), .d(	sa12_sub_round6	));
aes_sbox us13_round6(	.a(text_out_stage5[023:016]		), .d(	sa13_sub_round6	));
aes_sbox us20_round6(	.a(text_out_stage5[111:104]		), .d(	sa20_sub_round6	));
aes_sbox us21_round6(	.a(text_out_stage5[079:072]		), .d(	sa21_sub_round6	));
aes_sbox us22_round6(	.a(text_out_stage5[047:040]		), .d(	sa22_sub_round6	));
aes_sbox us23_round6(	.a(text_out_stage5[015:008]		), .d(	sa23_sub_round6	));
aes_sbox us30_round6(	.a(text_out_stage5[103:096]		), .d(	sa30_sub_round6	));
aes_sbox us31_round6(	.a(text_out_stage5[071:064]		), .d(	sa31_sub_round6	));
aes_sbox us32_round6(	.a(text_out_stage5[039:032]		), .d(	sa32_sub_round6	));
aes_sbox us33_round6(	.a(text_out_stage5[007:000]		), .d(	sa33_sub_round6	));


//shift rows

assign sa00_sr_round6 = sa00_sub_round6;		//
assign sa01_sr_round6 = sa01_sub_round6;		//no shift
assign sa02_sr_round6 = sa02_sub_round6;		//
assign sa03_sr_round6 = sa03_sub_round6;		//

assign sa10_sr_round6 = sa11_sub_round6;		//
assign sa11_sr_round6 = sa12_sub_round6;		// left shift by 1
assign sa12_sr_round6 = sa13_sub_round6;		//
assign sa13_sr_round6 = sa10_sub_round6;		//

assign sa20_sr_round6 = sa22_sub_round6;		//
assign sa21_sr_round6 = sa23_sub_round6;		//	left shift by 2
assign sa22_sr_round6 = sa20_sub_round6;		//
assign sa23_sr_round6 = sa21_sub_round6;		//

assign sa30_sr_round6 = sa33_sub_round6;		//
assign sa31_sr_round6 = sa30_sub_round6;		// left shift by 3
assign sa32_sr_round6 = sa31_sub_round6;		//
assign sa33_sr_round6 = sa32_sub_round6;		//

// mix column operation
assign {sa00_mc_round6, sa10_mc_round6, sa20_mc_round6, sa30_mc_round6}  = mix_col(sa00_sr_round6,sa10_sr_round6,sa20_sr_round6,sa30_sr_round6);
assign {sa01_mc_round6, sa11_mc_round6, sa21_mc_round6, sa31_mc_round6}  = mix_col(sa01_sr_round6,sa11_sr_round6,sa21_sr_round6,sa31_sr_round6);
assign {sa02_mc_round6, sa12_mc_round6, sa22_mc_round6, sa32_mc_round6}  = mix_col(sa02_sr_round6,sa12_sr_round6,sa22_sr_round6,sa32_sr_round6);
assign {sa03_mc_round6, sa13_mc_round6, sa23_mc_round6, sa33_mc_round6}  = mix_col(sa03_sr_round6,sa13_sr_round6,sa23_sr_round6,sa33_sr_round6);


//add round key
assign sa33_next_round7 = 		   sa33_mc_round6 ^ w27[07:00];
assign sa23_next_round7 =     	sa23_mc_round6 ^ w27[15:08];
assign sa13_next_round7 =     	sa13_mc_round6 ^ w27[23:16];
assign sa03_next_round7 =     	sa03_mc_round6 ^ w27[31:24];
assign sa32_next_round7 =     	sa32_mc_round6 ^ w26[07:00];
assign sa22_next_round7 =     	sa22_mc_round6 ^ w26[15:08];
assign sa12_next_round7 =     	sa12_mc_round6 ^ w26[23:16];
assign sa02_next_round7 =     	sa02_mc_round6 ^ w26[31:24];
assign sa31_next_round7 =     	sa31_mc_round6 ^ w25[07:00];
assign sa21_next_round7 =     	sa21_mc_round6 ^ w25[15:08];
assign sa11_next_round7 =     	sa11_mc_round6 ^ w25[23:16];
assign sa01_next_round7 =     	sa01_mc_round6 ^ w25[31:24];
assign sa30_next_round7 =     	sa30_mc_round6 ^ w24[07:00];
assign sa20_next_round7 =     	sa20_mc_round6 ^ w24[15:08];
assign sa10_next_round7 =     	sa10_mc_round6 ^ w24[23:16];
assign sa00_next_round7 =     	sa00_mc_round6 ^ w24[31:24];


always @(posedge clk)
	begin
		  text_out_stage6[127:120] <=  sa00_next_round7;	 
		  text_out_stage6[095:088] <=  sa01_next_round7;	 
		  text_out_stage6[063:056] <=  sa02_next_round7;	 
		  text_out_stage6[031:024] <=  sa03_next_round7;	 
		  text_out_stage6[119:112] <=  sa10_next_round7;	 
		  text_out_stage6[087:080] <=  sa11_next_round7;	 
		  text_out_stage6[055:048] <=  sa12_next_round7;	 
		  text_out_stage6[023:016] <=  sa13_next_round7;	 
		  text_out_stage6[111:104] <=  sa20_next_round7;	 
		  text_out_stage6[079:072] <=  sa21_next_round7;	 
		  text_out_stage6[047:040] <=  sa22_next_round7;	 
		  text_out_stage6[015:008] <=  sa23_next_round7;	 
		  text_out_stage6[103:096] <=  sa30_next_round7;	 
		  text_out_stage6[071:064] <=  sa31_next_round7;	 
		  text_out_stage6[039:032] <=  sa32_next_round7;	 
		  text_out_stage6[007:000] <=  sa33_next_round7;
			
	end



//////////////////////  round 7 //////////////////////////////////

//sbox lookup
aes_sbox us00_round7(	.a(text_out_stage6[127:120]		), .d(	sa00_sub_round7	));
aes_sbox us01_round7(	.a(text_out_stage6[095:088]		), .d(	sa01_sub_round7	));
aes_sbox us02_round7(	.a(text_out_stage6[063:056]		), .d(	sa02_sub_round7	));
aes_sbox us03_round7(	.a(text_out_stage6[031:024]		), .d(	sa03_sub_round7	));
aes_sbox us10_round7(	.a(text_out_stage6[119:112]		), .d(	sa10_sub_round7	));
aes_sbox us11_round7(	.a(text_out_stage6[087:080]		), .d(	sa11_sub_round7	));
aes_sbox us12_round7(	.a(text_out_stage6[055:048]		), .d(	sa12_sub_round7	));
aes_sbox us13_round7(	.a(text_out_stage6[023:016]		), .d(	sa13_sub_round7	));
aes_sbox us20_round7(	.a(text_out_stage6[111:104]		), .d(	sa20_sub_round7	));
aes_sbox us21_round7(	.a(text_out_stage6[079:072]		), .d(	sa21_sub_round7	));
aes_sbox us22_round7(	.a(text_out_stage6[047:040]		), .d(	sa22_sub_round7	));
aes_sbox us23_round7(	.a(text_out_stage6[015:008]		), .d(	sa23_sub_round7	));
aes_sbox us30_round7(	.a(text_out_stage6[103:096]		), .d(	sa30_sub_round7	));
aes_sbox us31_round7(	.a(text_out_stage6[071:064]		), .d(	sa31_sub_round7	));
aes_sbox us32_round7(	.a(text_out_stage6[039:032]		), .d(	sa32_sub_round7	));
aes_sbox us33_round7(	.a(text_out_stage6[007:000]		), .d(	sa33_sub_round7	));



//shift rows

assign sa00_sr_round7 = sa00_sub_round7;		//
assign sa01_sr_round7 = sa01_sub_round7;		//no shift
assign sa02_sr_round7 = sa02_sub_round7;		//
assign sa03_sr_round7 = sa03_sub_round7;		//

assign sa10_sr_round7 = sa11_sub_round7;		//
assign sa11_sr_round7 = sa12_sub_round7;		// left shift by 1
assign sa12_sr_round7 = sa13_sub_round7;		//
assign sa13_sr_round7 = sa10_sub_round7;		//

assign sa20_sr_round7 = sa22_sub_round7;		//
assign sa21_sr_round7 = sa23_sub_round7;		//	left shift by 2
assign sa22_sr_round7 = sa20_sub_round7;		//
assign sa23_sr_round7 = sa21_sub_round7;		//

assign sa30_sr_round7 = sa33_sub_round7;		//
assign sa31_sr_round7 = sa30_sub_round7;		// left shift by 3
assign sa32_sr_round7 = sa31_sub_round7;		//
assign sa33_sr_round7 = sa32_sub_round7;		//

// mix column operation
assign {sa00_mc_round7, sa10_mc_round7, sa20_mc_round7, sa30_mc_round7}  = mix_col(sa00_sr_round7,sa10_sr_round7,sa20_sr_round7,sa30_sr_round7);
assign {sa01_mc_round7, sa11_mc_round7, sa21_mc_round7, sa31_mc_round7}  = mix_col(sa01_sr_round7,sa11_sr_round7,sa21_sr_round7,sa31_sr_round7);
assign {sa02_mc_round7, sa12_mc_round7, sa22_mc_round7, sa32_mc_round7}  = mix_col(sa02_sr_round7,sa12_sr_round7,sa22_sr_round7,sa32_sr_round7);
assign {sa03_mc_round7, sa13_mc_round7, sa23_mc_round7, sa33_mc_round7}  = mix_col(sa03_sr_round7,sa13_sr_round7,sa23_sr_round7,sa33_sr_round7);


//add round key
assign sa33_next_round8 = 		   sa33_mc_round7 ^ w31[07:00];
assign sa23_next_round8 =     	sa23_mc_round7 ^ w31[15:08];
assign sa13_next_round8 =     	sa13_mc_round7 ^ w31[23:16];
assign sa03_next_round8 =     	sa03_mc_round7 ^ w31[31:24];
assign sa32_next_round8 =     	sa32_mc_round7 ^ w30[07:00];
assign sa22_next_round8 =     	sa22_mc_round7 ^ w30[15:08];
assign sa12_next_round8 =     	sa12_mc_round7 ^ w30[23:16];
assign sa02_next_round8 =     	sa02_mc_round7 ^ w30[31:24];
assign sa31_next_round8 =     	sa31_mc_round7 ^ w29[07:00];
assign sa21_next_round8 =     	sa21_mc_round7 ^ w29[15:08];
assign sa11_next_round8 =     	sa11_mc_round7 ^ w29[23:16];
assign sa01_next_round8 =     	sa01_mc_round7 ^ w29[31:24];
assign sa30_next_round8 =     	sa30_mc_round7 ^ w28[07:00];
assign sa20_next_round8 =     	sa20_mc_round7 ^ w28[15:08];
assign sa10_next_round8 =     	sa10_mc_round7 ^ w28[23:16];
assign sa00_next_round8 =     	sa00_mc_round7 ^ w28[31:24];

always @(posedge clk)
	begin
		  text_out_stage7[127:120] <=  sa00_next_round8;	 
		  text_out_stage7[095:088] <=  sa01_next_round8;	 
		  text_out_stage7[063:056] <=  sa02_next_round8;	 
		  text_out_stage7[031:024] <=  sa03_next_round8;	 
		  text_out_stage7[119:112] <=  sa10_next_round8;	 
		  text_out_stage7[087:080] <=  sa11_next_round8;	 
		  text_out_stage7[055:048] <=  sa12_next_round8;	 
		  text_out_stage7[023:016] <=  sa13_next_round8;	 
		  text_out_stage7[111:104] <=  sa20_next_round8;	 
		  text_out_stage7[079:072] <=  sa21_next_round8;	 
		  text_out_stage7[047:040] <=  sa22_next_round8;	 
		  text_out_stage7[015:008] <=  sa23_next_round8;	 
		  text_out_stage7[103:096] <=  sa30_next_round8;	 
		  text_out_stage7[071:064] <=  sa31_next_round8;	 
		  text_out_stage7[039:032] <=  sa32_next_round8;	 
		  text_out_stage7[007:000] <=  sa33_next_round8;
			
	end



//////////////////////  round 8 //////////////////////////////////

//sbox lookup
aes_sbox us00_round8(	.a(text_out_stage7[127:120]		), .d(	sa00_sub_round8	));
aes_sbox us01_round8(	.a(text_out_stage7[095:088]		), .d(	sa01_sub_round8	));
aes_sbox us02_round8(	.a(text_out_stage7[063:056]		), .d(	sa02_sub_round8	));
aes_sbox us03_round8(	.a(text_out_stage7[031:024]		), .d(	sa03_sub_round8	));
aes_sbox us10_round8(	.a(text_out_stage7[119:112]		), .d(	sa10_sub_round8	));
aes_sbox us11_round8(	.a(text_out_stage7[087:080]		), .d(	sa11_sub_round8	));
aes_sbox us12_round8(	.a(text_out_stage7[055:048]		), .d(	sa12_sub_round8	));
aes_sbox us13_round8(	.a(text_out_stage7[023:016]		), .d(	sa13_sub_round8	));
aes_sbox us20_round8(	.a(text_out_stage7[111:104]		), .d(	sa20_sub_round8	));
aes_sbox us21_round8(	.a(text_out_stage7[079:072]		), .d(	sa21_sub_round8	));
aes_sbox us22_round8(	.a(text_out_stage7[047:040]		), .d(	sa22_sub_round8	));
aes_sbox us23_round8(	.a(text_out_stage7[015:008]		), .d(	sa23_sub_round8	));
aes_sbox us30_round8(	.a(text_out_stage7[103:096]		), .d(	sa30_sub_round8	));
aes_sbox us31_round8(	.a(text_out_stage7[071:064]		), .d(	sa31_sub_round8	));
aes_sbox us32_round8(	.a(text_out_stage7[039:032]		), .d(	sa32_sub_round8	));
aes_sbox us33_round8(	.a(text_out_stage7[007:000]		), .d(	sa33_sub_round8	));



//shift rows

assign sa00_sr_round8 = sa00_sub_round8;		//
assign sa01_sr_round8 = sa01_sub_round8;		//no shift
assign sa02_sr_round8 = sa02_sub_round8;		//
assign sa03_sr_round8 = sa03_sub_round8;		//

assign sa10_sr_round8 = sa11_sub_round8;		//
assign sa11_sr_round8 = sa12_sub_round8;		// left shift by 1
assign sa12_sr_round8 = sa13_sub_round8;		//
assign sa13_sr_round8 = sa10_sub_round8;		//

assign sa20_sr_round8 = sa22_sub_round8;		//
assign sa21_sr_round8 = sa23_sub_round8;		//	left shift by 2
assign sa22_sr_round8 = sa20_sub_round8;		//
assign sa23_sr_round8 = sa21_sub_round8;		//

assign sa30_sr_round8 = sa33_sub_round8;		//
assign sa31_sr_round8 = sa30_sub_round8;		// left shift by 3
assign sa32_sr_round8 = sa31_sub_round8;		//
assign sa33_sr_round8 = sa32_sub_round8;		//

// mix column operation
assign {sa00_mc_round8, sa10_mc_round8, sa20_mc_round8, sa30_mc_round8}  = mix_col(sa00_sr_round8,sa10_sr_round8,sa20_sr_round8,sa30_sr_round8);
assign {sa01_mc_round8, sa11_mc_round8, sa21_mc_round8, sa31_mc_round8}  = mix_col(sa01_sr_round8,sa11_sr_round8,sa21_sr_round8,sa31_sr_round8);
assign {sa02_mc_round8, sa12_mc_round8, sa22_mc_round8, sa32_mc_round8}  = mix_col(sa02_sr_round8,sa12_sr_round8,sa22_sr_round8,sa32_sr_round8);
assign {sa03_mc_round8, sa13_mc_round8, sa23_mc_round8, sa33_mc_round8}  = mix_col(sa03_sr_round8,sa13_sr_round8,sa23_sr_round8,sa33_sr_round8);


//add round key
assign sa33_next_round9 = 		   sa33_mc_round8 ^ w35[07:00];
assign sa23_next_round9 =     	sa23_mc_round8 ^ w35[15:08];
assign sa13_next_round9 =     	sa13_mc_round8 ^ w35[23:16];
assign sa03_next_round9 =     	sa03_mc_round8 ^ w35[31:24];
assign sa32_next_round9 =     	sa32_mc_round8 ^ w34[07:00];
assign sa22_next_round9 =     	sa22_mc_round8 ^ w34[15:08];
assign sa12_next_round9 =     	sa12_mc_round8 ^ w34[23:16];
assign sa02_next_round9 =     	sa02_mc_round8 ^ w34[31:24];
assign sa31_next_round9 =     	sa31_mc_round8 ^ w33[07:00];
assign sa21_next_round9 =     	sa21_mc_round8 ^ w33[15:08];
assign sa11_next_round9 =     	sa11_mc_round8 ^ w33[23:16];
assign sa01_next_round9 =     	sa01_mc_round8 ^ w33[31:24];
assign sa30_next_round9 =     	sa30_mc_round8 ^ w32[07:00];
assign sa20_next_round9 =     	sa20_mc_round8 ^ w32[15:08];
assign sa10_next_round9 =     	sa10_mc_round8 ^ w32[23:16];
assign sa00_next_round9 =     	sa00_mc_round8 ^ w32[31:24];



always @(posedge clk)
	begin
		  text_out_stage8[127:120] <=  sa00_next_round9;	 
		  text_out_stage8[095:088] <=  sa01_next_round9;	 
		  text_out_stage8[063:056] <=  sa02_next_round9;	 
		  text_out_stage8[031:024] <=  sa03_next_round9;	 
		  text_out_stage8[119:112] <=  sa10_next_round9;	 
		  text_out_stage8[087:080] <=  sa11_next_round9;	 
		  text_out_stage8[055:048] <=  sa12_next_round9;	 
		  text_out_stage8[023:016] <=  sa13_next_round9;	 
		  text_out_stage8[111:104] <=  sa20_next_round9;	 
		  text_out_stage8[079:072] <=  sa21_next_round9;	 
		  text_out_stage8[047:040] <=  sa22_next_round9;	 
		  text_out_stage8[015:008] <=  sa23_next_round9;	 
		  text_out_stage8[103:096] <=  sa30_next_round9;	 
		  text_out_stage8[071:064] <=  sa31_next_round9;	 
		  text_out_stage8[039:032] <=  sa32_next_round9;	 
		  text_out_stage8[007:000] <=  sa33_next_round9;
			
	end



//////////////////////  round 9 //////////////////////////////////

//sbox lookup
aes_sbox us00_round9(	.a(text_out_stage8[127:120]		), .d(	sa00_sub_round9	));
aes_sbox us01_round9(	.a(text_out_stage8[095:088]		), .d(	sa01_sub_round9	));
aes_sbox us02_round9(	.a(text_out_stage8[063:056]		), .d(	sa02_sub_round9	));
aes_sbox us03_round9(	.a(text_out_stage8[031:024]		), .d(	sa03_sub_round9	));
aes_sbox us10_round9(	.a(text_out_stage8[119:112]		), .d(	sa10_sub_round9	));
aes_sbox us11_round9(	.a(text_out_stage8[087:080]		), .d(	sa11_sub_round9	));
aes_sbox us12_round9(	.a(text_out_stage8[055:048]		), .d(	sa12_sub_round9	));
aes_sbox us13_round9(	.a(text_out_stage8[023:016]		), .d(	sa13_sub_round9	));
aes_sbox us20_round9(	.a(text_out_stage8[111:104]		), .d(	sa20_sub_round9	));
aes_sbox us21_round9(	.a(text_out_stage8[079:072]		), .d(	sa21_sub_round9	));
aes_sbox us22_round9(	.a(text_out_stage8[047:040]		), .d(	sa22_sub_round9	));
aes_sbox us23_round9(	.a(text_out_stage8[015:008]		), .d(	sa23_sub_round9	));
aes_sbox us30_round9(	.a(text_out_stage8[103:096]		), .d(	sa30_sub_round9	));
aes_sbox us31_round9(	.a(text_out_stage8[071:064]		), .d(	sa31_sub_round9	));
aes_sbox us32_round9(	.a(text_out_stage8[039:032]		), .d(	sa32_sub_round9	));
aes_sbox us33_round9(	.a(text_out_stage8[007:000]		), .d(	sa33_sub_round9	));



//shift rows

assign sa00_sr_round9 = sa00_sub_round9;		//
assign sa01_sr_round9 = sa01_sub_round9;		//no shift
assign sa02_sr_round9 = sa02_sub_round9;		//
assign sa03_sr_round9 = sa03_sub_round9;		//

assign sa10_sr_round9 = sa11_sub_round9;		//
assign sa11_sr_round9 = sa12_sub_round9;		// left shift by 1
assign sa12_sr_round9 = sa13_sub_round9;		//
assign sa13_sr_round9 = sa10_sub_round9;		//

assign sa20_sr_round9 = sa22_sub_round9;		//
assign sa21_sr_round9 = sa23_sub_round9;		//	left shift by 2
assign sa22_sr_round9 = sa20_sub_round9;		//
assign sa23_sr_round9 = sa21_sub_round9;		//

assign sa30_sr_round9 = sa33_sub_round9;		//
assign sa31_sr_round9 = sa30_sub_round9;		// left shift by 3
assign sa32_sr_round9 = sa31_sub_round9;		//
assign sa33_sr_round9 = sa32_sub_round9;		//

// mix column operation
assign {sa00_mc_round9, sa10_mc_round9, sa20_mc_round9, sa30_mc_round9}  = mix_col(sa00_sr_round9,sa10_sr_round9,sa20_sr_round9,sa30_sr_round9);
assign {sa01_mc_round9, sa11_mc_round9, sa21_mc_round9, sa31_mc_round9}  = mix_col(sa01_sr_round9,sa11_sr_round9,sa21_sr_round9,sa31_sr_round9);
assign {sa02_mc_round9, sa12_mc_round9, sa22_mc_round9, sa32_mc_round9}  = mix_col(sa02_sr_round9,sa12_sr_round9,sa22_sr_round9,sa32_sr_round9);
assign {sa03_mc_round9, sa13_mc_round9, sa23_mc_round9, sa33_mc_round9}  = mix_col(sa03_sr_round9,sa13_sr_round9,sa23_sr_round9,sa33_sr_round9);


//add round key
assign sa33_next_round10 = 		sa33_mc_round9 ^ w39[07:00];
assign sa23_next_round10 =     	sa23_mc_round9 ^ w39[15:08];
assign sa13_next_round10 =     	sa13_mc_round9 ^ w39[23:16];
assign sa03_next_round10 =     	sa03_mc_round9 ^ w39[31:24];
assign sa32_next_round10 =     	sa32_mc_round9 ^ w38[07:00];
assign sa22_next_round10 =     	sa22_mc_round9 ^ w38[15:08];
assign sa12_next_round10 =     	sa12_mc_round9 ^ w38[23:16];
assign sa02_next_round10 =     	sa02_mc_round9 ^ w38[31:24];
assign sa31_next_round10 =     	sa31_mc_round9 ^ w37[07:00];
assign sa21_next_round10 =     	sa21_mc_round9 ^ w37[15:08];
assign sa11_next_round10 =     	sa11_mc_round9 ^ w37[23:16];
assign sa01_next_round10 =     	sa01_mc_round9 ^ w37[31:24];
assign sa30_next_round10 =     	sa30_mc_round9 ^ w36[07:00];
assign sa20_next_round10 =     	sa20_mc_round9 ^ w36[15:08];
assign sa10_next_round10 =     	sa10_mc_round9 ^ w36[23:16];
assign sa00_next_round10 =     	sa00_mc_round9 ^ w36[31:24];



always @(posedge clk)
	begin
		  text_out_stage9[127:120] <=  sa00_next_round10;	 
		  text_out_stage9[095:088] <=  sa01_next_round10;	 
		  text_out_stage9[063:056] <=  sa02_next_round10;	 
		  text_out_stage9[031:024] <=  sa03_next_round10;	 
		  text_out_stage9[119:112] <=  sa10_next_round10;	 
		  text_out_stage9[087:080] <=  sa11_next_round10;	 
		  text_out_stage9[055:048] <=  sa12_next_round10;	 
		  text_out_stage9[023:016] <=  sa13_next_round10;	 
		  text_out_stage9[111:104] <=  sa20_next_round10;	 
		  text_out_stage9[079:072] <=  sa21_next_round10;	 
		  text_out_stage9[047:040] <=  sa22_next_round10;	 
		  text_out_stage9[015:008] <=  sa23_next_round10;	 
		  text_out_stage9[103:096] <=  sa30_next_round10;	 
		  text_out_stage9[071:064] <=  sa31_next_round10;	 
		  text_out_stage9[039:032] <=  sa32_next_round10;	 
		  text_out_stage9[007:000] <=  sa33_next_round10;
			
	end



//////////////////////  round 10 //////////////////////////////////

//sbox lookup
aes_sbox us00_round10(	.a(text_out_stage9[127:120]		), .d(	sa00_sub_round10	));
aes_sbox us01_round10(	.a(text_out_stage9[095:088]		), .d(	sa01_sub_round10	));
aes_sbox us02_round10(	.a(text_out_stage9[063:056]		), .d(	sa02_sub_round10	));
aes_sbox us03_round10(	.a(text_out_stage9[031:024]		), .d(	sa03_sub_round10	));
aes_sbox us10_round10(	.a(text_out_stage9[119:112]		), .d(	sa10_sub_round10	));
aes_sbox us11_round10(	.a(text_out_stage9[087:080]		), .d(	sa11_sub_round10	));
aes_sbox us12_round10(	.a(text_out_stage9[055:048]		), .d(	sa12_sub_round10	));
aes_sbox us13_round10(	.a(text_out_stage9[023:016]		), .d(	sa13_sub_round10	));
aes_sbox us20_round10(	.a(text_out_stage9[111:104]		), .d(	sa20_sub_round10	));
aes_sbox us21_round10(	.a(text_out_stage9[079:072]		), .d(	sa21_sub_round10	));
aes_sbox us22_round10(	.a(text_out_stage9[047:040]		), .d(	sa22_sub_round10	));
aes_sbox us23_round10(	.a(text_out_stage9[015:008]		), .d(	sa23_sub_round10	));
aes_sbox us30_round10(	.a(text_out_stage9[103:096]		), .d(	sa30_sub_round10	));
aes_sbox us31_round10(	.a(text_out_stage9[071:064]		), .d(	sa31_sub_round10	));
aes_sbox us32_round10(	.a(text_out_stage9[039:032]		), .d(	sa32_sub_round10	));
aes_sbox us33_round10(	.a(text_out_stage9[007:000]		), .d(	sa33_sub_round10	));



//shift rows

assign sa00_sr_round10 = sa00_sub_round10;		//
assign sa01_sr_round10 = sa01_sub_round10;		//no shift
assign sa02_sr_round10 = sa02_sub_round10;		//
assign sa03_sr_round10 = sa03_sub_round10;		//

assign sa10_sr_round10 = sa11_sub_round10;		//
assign sa11_sr_round10 = sa12_sub_round10;		// left shift by 1
assign sa12_sr_round10 = sa13_sub_round10;		//
assign sa13_sr_round10 = sa10_sub_round10;		//

assign sa20_sr_round10 = sa22_sub_round10;		//
assign sa21_sr_round10 = sa23_sub_round10;		//	left shift by 2
assign sa22_sr_round10 = sa20_sub_round10;		//
assign sa23_sr_round10 = sa21_sub_round10;		//

assign sa30_sr_round10 = sa33_sub_round10;		//
assign sa31_sr_round10 = sa30_sub_round10;		// left shift by 3
assign sa32_sr_round10 = sa31_sub_round10;		//
assign sa33_sr_round10 = sa32_sub_round10;		//


// Final text output


always @(posedge clk)
 begin 
		/*  $strobe($time,": round_key2 is %h\n",{w4,w5,w6,w7});
		  $strobe($time,": roundkeyeven = %h, text_out_even is %h\n",{w4,w5,w6,w7},text_out);*/
		  text_out[127:120] <=  sa00_sr_round10 ^ w40[31:24];	 
		  text_out[095:088] <=  sa01_sr_round10 ^ w41[31:24];	 
		  text_out[063:056] <=  sa02_sr_round10 ^ w42[31:24];	 
		  text_out[031:024] <=  sa03_sr_round10 ^ w43[31:24];	 
		  text_out[119:112] <=  sa10_sr_round10 ^ w40[23:16];	 
		  text_out[087:080] <=  sa11_sr_round10 ^ w41[23:16];	 
		  text_out[055:048] <=  sa12_sr_round10 ^ w42[23:16];	 
		  text_out[023:016] <=  sa13_sr_round10 ^ w43[23:16];	 
		  text_out[111:104] <=  sa20_sr_round10 ^ w40[15:08];	 
		  text_out[079:072] <=  sa21_sr_round10 ^ w41[15:08];	 
		  text_out[047:040] <=  sa22_sr_round10 ^ w42[15:08];	 
		  text_out[015:008] <=  sa23_sr_round10 ^ w43[15:08];	 
		  text_out[103:096] <=  sa30_sr_round10 ^ w40[07:00];	 
		  text_out[071:064] <=  sa31_sr_round10 ^ w41[07:00];	 
		  text_out[039:032] <=  sa32_sr_round10 ^ w42[07:00];	 
		  text_out[007:000] <=  sa33_sr_round10 ^ w43[07:00];
	end
	
////////////////////////////////////////////////////////////////////
//
// Generic Functions
//

function [31:0] mix_col;
input	[7:0]	s0,s1,s2,s3;
//reg	[7:0]	s0_o,s1_o,s2_o,s3_o;
begin
mix_col[31:24]=xtime(s0)^xtime(s1)^s1^s2^s3;
mix_col[23:16]=s0^xtime(s1)^xtime(s2)^s2^s3;
mix_col[15:08]=s0^s1^xtime(s2)^xtime(s3)^s3;
mix_col[07:00]=xtime(s0)^s0^s1^s2^xtime(s3);
end
endfunction

function [7:0] xtime;
input [7:0] b; xtime={b[6:0],1'b0}^(8'h1b&{8{b[7]}});
endfunction



endmodule




// -----------------------------------------------------------------------------
// Source file: aes_10cycle_10stage/aes_key_expand_128.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Key Expand Block (for 128 bit keys)                    ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
 
//// Modified to achieve 10 cycle - 10 stage functionality 	     ////
//// By Tariq Bashir Ahmad					     //// 	
////  tariq.bashir@gmail.com					     ////
////  http://www.ecs.umass.edu/~tbashir				     ////	


`timescale 1 ns/1 ps

module aes_key_expand_128(clk, key, w0,w1,w2,w3,w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17,
													  w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33,
													  w34, w35, w36, w37, w38, w39, w40, w41, w42, w43);
input		clk;
input	[127:0]	key;
output reg	[31:0]	w0,w1,w2,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17,
							w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33,
							w34, w35, w36, w37, w38, w39, w40, w41, w42, w43;
wire	[31:0]	subword, subword2,subword3,subword4,subword5, subword6, subword7,subword8,subword9,subword10;
wire	[7:0]	rcon, rcon2,rcon3,rcon4,rcon5, rcon6, rcon7,rcon8,rcon9,rcon10;			



		
always @*
begin
 
w0 =  key[127:096];
w1 =  key[095:064];
w2 =  key[063:032];
w3 =  key[031:000];

w4 =  key[127:096]^subword^{8'h01,24'b0};
w5 =  key[095:064]^key[127:096]^subword^{8'h01,24'b0};
w6 =  key[063:032]^key[095:064]^key[127:096]^subword^{8'h01,24'b0}; 
w7 =  key[127:096]^key[095:064]^key[063:032]^key[031:000]^subword^{8'h01,24'b0};

w8  =  w4^subword2^{rcon2,24'b0};
w9  =  w5^w4^subword2^{rcon2,24'b0};
w10 =  w6^w5^w4^subword2^{rcon2,24'b0}; 
w11 =  w7^w6^w5^w4^subword2^{rcon2,24'b0};


w12  =  w8^subword3^{rcon3,24'b0};
w13  =  w8^w9^subword3^{rcon3,24'b0};
w14  =  w8^w9^w10^subword3^{rcon3,24'b0}; 
w15  =  w8^w9^w10^w11^subword3^{rcon3,24'b0};


w16  =  w12^subword4^{rcon4,24'b0};
w17  =  w12^w13^subword4^{rcon4,24'b0};
w18  =  w12^w13^w14^subword4^{rcon4,24'b0}; 
w19  =  w12^w13^w14^w15^subword4^{rcon4,24'b0};


w20  =  w16^subword5^{rcon5,24'b0};
w21  =  w16^w17^subword5^{rcon5,24'b0};
w22  =  w16^w17^w18^subword5^{rcon5,24'b0}; 
w23  =  w16^w17^w18^w19^subword5^{rcon5,24'b0};


w24  =  w20^subword6^{rcon6,24'b0};
w25  =  w20^w21^subword6^{rcon6,24'b0};
w26  =  w20^w21^w22^subword6^{rcon6,24'b0}; 
w27  =  w20^w21^w22^w23^subword6^{rcon6,24'b0};

w28  =  w24^subword7^{rcon7,24'b0};
w29  =  w24^w25^subword7^{rcon7,24'b0};
w30  =  w24^w25^w26^subword7^{rcon7,24'b0}; 
w31  =  w24^w25^w26^w27^subword7^{rcon7,24'b0};


w32  =  w28^subword8^{rcon8,24'b0};
w33  =  w28^w29^subword8^{rcon8,24'b0};
w34  =  w28^w29^w30^subword8^{rcon8,24'b0}; 
w35  =  w28^w29^w30^w31^subword8^{rcon8,24'b0};

w36  =  w32^subword9^{rcon9,24'b0};
w37  =  w32^w33^subword9^{rcon9,24'b0};
w38  =  w32^w33^w34^subword9^{rcon9,24'b0}; 
w39  =  w32^w33^w34^w35^subword9^{rcon9,24'b0};

w40  =  w36^subword10^{rcon10,24'b0};
w41  =  w36^w37^subword10^{rcon10,24'b0};
w42  =  w36^w37^w38^subword10^{rcon10,24'b0}; 
w43  =  w36^w37^w38^w39^subword10^{rcon10,24'b0};

/*$display($time,": subword5 is %h\n",subword2);
$display($time,": rcon5 is %h\n",rcon5);
$display($time,": key5 is %h, key6 is %h\n",{w16,w17,w18,w19},{w20,w21,w22,w23});*/

end

aes_rcon inst5(.clk(clk),            .out(rcon),   .out2(rcon2),
												 .out3(rcon3), .out4(rcon4),
												 .out5(rcon5), .out6(rcon6),
												 .out7(rcon7), .out8(rcon8),
												 .out9(rcon9), .out10(rcon10));

aes_sbox u0(	.a(w3[23:16]), .d(subword[31:24]));
aes_sbox u1(	.a(w3[15:08]), .d(subword[23:16]));
aes_sbox u2(	.a(w3[07:00]), .d(subword[15:08]));
aes_sbox u3(	.a(w3[31:24]), .d(subword[07:00])); 

aes_sbox u4(	.a(w7[23:16]), .d(subword2[31:24]));
aes_sbox u5(	.a(w7[15:08]), .d(subword2[23:16]));
aes_sbox u6(	.a(w7[07:00]), .d(subword2[15:08]));
aes_sbox u7(	.a(w7[31:24]), .d(subword2[07:00])); 


aes_sbox u8(	.a(w11[23:16]), .d(subword3[31:24]));
aes_sbox u9(	.a(w11[15:08]), .d(subword3[23:16]));
aes_sbox u10(	.a(w11[07:00]), .d(subword3[15:08]));
aes_sbox u11(	.a(w11[31:24]), .d(subword3[07:00])); 


aes_sbox u12(	.a(w15[23:16]), .d(subword4[31:24]));
aes_sbox u13(	.a(w15[15:08]), .d(subword4[23:16]));
aes_sbox u14(	.a(w15[07:00]), .d(subword4[15:08]));
aes_sbox u15(	.a(w15[31:24]), .d(subword4[07:00])); 

aes_sbox u16(	.a(w19[23:16]), .d(subword5[31:24]));
aes_sbox u17(	.a(w19[15:08]), .d(subword5[23:16]));
aes_sbox u18(	.a(w19[07:00]), .d(subword5[15:08]));
aes_sbox u19(	.a(w19[31:24]), .d(subword5[07:00])); 

aes_sbox u20(	.a(w23[23:16]), .d(subword6[31:24]));
aes_sbox u21(	.a(w23[15:08]), .d(subword6[23:16]));
aes_sbox u22(	.a(w23[07:00]), .d(subword6[15:08]));
aes_sbox u23(	.a(w23[31:24]), .d(subword6[07:00])); 

aes_sbox u24(	.a(w27[23:16]), .d(subword7[31:24]));
aes_sbox u25(	.a(w27[15:08]), .d(subword7[23:16]));
aes_sbox u26(	.a(w27[07:00]), .d(subword7[15:08]));
aes_sbox u27(	.a(w27[31:24]), .d(subword7[07:00])); 

aes_sbox u28(	.a(w31[23:16]), .d(subword8[31:24]));
aes_sbox u29(	.a(w31[15:08]), .d(subword8[23:16]));
aes_sbox u30(	.a(w31[07:00]), .d(subword8[15:08]));
aes_sbox u31(	.a(w31[31:24]), .d(subword8[07:00])); 

aes_sbox u32(	.a(w35[23:16]), .d(subword9[31:24]));
aes_sbox u33(	.a(w35[15:08]), .d(subword9[23:16]));
aes_sbox u34(	.a(w35[07:00]), .d(subword9[15:08]));
aes_sbox u35(	.a(w35[31:24]), .d(subword9[07:00])); 

aes_sbox u36(	.a(w39[23:16]), .d(subword10[31:24]));
aes_sbox u37(	.a(w39[15:08]), .d(subword10[23:16]));
aes_sbox u38(	.a(w39[07:00]), .d(subword10[15:08]));
aes_sbox u39(	.a(w39[31:24]), .d(subword10[07:00])); 


endmodule


// -----------------------------------------------------------------------------
// Source file: aes_10cycle_10stage/aes_rcon.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES RCON Block                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1 ns/1 ps

module aes_rcon(clk,out,out2,out3,out4,out5,out6,out7,out8,out9,out10);

input		clk;

output [7:0] out,out2,out3,out4,out5,out6,out7,out8,out9,out10;



assign		out  = frcon(0);
assign		out2 = frcon(1); 
assign		out3 = frcon(2);
assign		out4 = frcon(3);
assign		out5 = frcon(4);
assign		out6 = frcon(5);
assign		out7 = frcon(6); 
assign		out8 = frcon(7);
assign		out9 = frcon(8);
assign		out10 = frcon(9);		 

function [7:0]	frcon;

input	[3:0]	i;

case(i)	// synopsys parallel_case
   4'h0: frcon=8'h01;		//1
   4'h1: frcon=8'h02;		//x
   4'h2: frcon=8'h04;		//x^2
   4'h3: frcon=8'h08;		//x^3
   4'h4: frcon=8'h10;		//x^4
   4'h5: frcon=8'h20;		//x^5
   4'h6: frcon=8'h40;		//x^6
   4'h7: frcon=8'h80;		//x^7
   4'h8: frcon=8'h1b;		//x^8
   4'h9: frcon=8'h36;		//x^9
   default: frcon=8'h00;
endcase

endfunction



endmodule

// -----------------------------------------------------------------------------
// Source file: aes_10cycle_10stage/aes_sbox.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES SBOX (ROM)                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1 ns/1 ps


module aes_sbox(a,d);
input	[7:0]	a;
output	[7:0]	d;
reg	[7:0]	d;

always @(a)
	case(a)		// synopsys full_case parallel_case
	   8'h00: d=8'h63;
	   8'h01: d=8'h7c;
	   8'h02: d=8'h77;
	   8'h03: d=8'h7b;
	   8'h04: d=8'hf2;
	   8'h05: d=8'h6b;
	   8'h06: d=8'h6f;
	   8'h07: d=8'hc5;
	   8'h08: d=8'h30;
	   8'h09: d=8'h01;
	   8'h0a: d=8'h67;
	   8'h0b: d=8'h2b;
	   8'h0c: d=8'hfe;
	   8'h0d: d=8'hd7;
	   8'h0e: d=8'hab;
	   8'h0f: d=8'h76;
	   8'h10: d=8'hca;
	   8'h11: d=8'h82;
	   8'h12: d=8'hc9;
	   8'h13: d=8'h7d;
	   8'h14: d=8'hfa;
	   8'h15: d=8'h59;
	   8'h16: d=8'h47;
	   8'h17: d=8'hf0;
	   8'h18: d=8'had;
	   8'h19: d=8'hd4;
	   8'h1a: d=8'ha2;
	   8'h1b: d=8'haf;
	   8'h1c: d=8'h9c;
	   8'h1d: d=8'ha4;
	   8'h1e: d=8'h72;
	   8'h1f: d=8'hc0;
	   8'h20: d=8'hb7;
	   8'h21: d=8'hfd;
	   8'h22: d=8'h93;
	   8'h23: d=8'h26;
	   8'h24: d=8'h36;
	   8'h25: d=8'h3f;
	   8'h26: d=8'hf7;
	   8'h27: d=8'hcc;
	   8'h28: d=8'h34;
	   8'h29: d=8'ha5;
	   8'h2a: d=8'he5;
	   8'h2b: d=8'hf1;
	   8'h2c: d=8'h71;
	   8'h2d: d=8'hd8;
	   8'h2e: d=8'h31;
	   8'h2f: d=8'h15;
	   8'h30: d=8'h04;
	   8'h31: d=8'hc7;
	   8'h32: d=8'h23;
	   8'h33: d=8'hc3;
	   8'h34: d=8'h18;
	   8'h35: d=8'h96;
	   8'h36: d=8'h05;
	   8'h37: d=8'h9a;
	   8'h38: d=8'h07;
	   8'h39: d=8'h12;
	   8'h3a: d=8'h80;
	   8'h3b: d=8'he2;
	   8'h3c: d=8'heb;
	   8'h3d: d=8'h27;
	   8'h3e: d=8'hb2;
	   8'h3f: d=8'h75;
	   8'h40: d=8'h09;
	   8'h41: d=8'h83;
	   8'h42: d=8'h2c;
	   8'h43: d=8'h1a;
	   8'h44: d=8'h1b;
	   8'h45: d=8'h6e;
	   8'h46: d=8'h5a;
	   8'h47: d=8'ha0;
	   8'h48: d=8'h52;
	   8'h49: d=8'h3b;
	   8'h4a: d=8'hd6;
	   8'h4b: d=8'hb3;
	   8'h4c: d=8'h29;
	   8'h4d: d=8'he3;
	   8'h4e: d=8'h2f;
	   8'h4f: d=8'h84;
	   8'h50: d=8'h53;
	   8'h51: d=8'hd1;
	   8'h52: d=8'h00;
	   8'h53: d=8'hed;
	   8'h54: d=8'h20;
	   8'h55: d=8'hfc;
	   8'h56: d=8'hb1;
	   8'h57: d=8'h5b;
	   8'h58: d=8'h6a;
	   8'h59: d=8'hcb;
	   8'h5a: d=8'hbe;
	   8'h5b: d=8'h39;
	   8'h5c: d=8'h4a;
	   8'h5d: d=8'h4c;
	   8'h5e: d=8'h58;
	   8'h5f: d=8'hcf;
	   8'h60: d=8'hd0;
	   8'h61: d=8'hef;
	   8'h62: d=8'haa;
	   8'h63: d=8'hfb;
	   8'h64: d=8'h43;
	   8'h65: d=8'h4d;
	   8'h66: d=8'h33;
	   8'h67: d=8'h85;
	   8'h68: d=8'h45;
	   8'h69: d=8'hf9;
	   8'h6a: d=8'h02;
	   8'h6b: d=8'h7f;
	   8'h6c: d=8'h50;
	   8'h6d: d=8'h3c;
	   8'h6e: d=8'h9f;
	   8'h6f: d=8'ha8;
	   8'h70: d=8'h51;
	   8'h71: d=8'ha3;
	   8'h72: d=8'h40;
	   8'h73: d=8'h8f;
	   8'h74: d=8'h92;
	   8'h75: d=8'h9d;
	   8'h76: d=8'h38;
	   8'h77: d=8'hf5;
	   8'h78: d=8'hbc;
	   8'h79: d=8'hb6;
	   8'h7a: d=8'hda;
	   8'h7b: d=8'h21;
	   8'h7c: d=8'h10;
	   8'h7d: d=8'hff;
	   8'h7e: d=8'hf3;
	   8'h7f: d=8'hd2;
	   8'h80: d=8'hcd;
	   8'h81: d=8'h0c;
	   8'h82: d=8'h13;
	   8'h83: d=8'hec;
	   8'h84: d=8'h5f;
	   8'h85: d=8'h97;
	   8'h86: d=8'h44;
	   8'h87: d=8'h17;
	   8'h88: d=8'hc4;
	   8'h89: d=8'ha7;
	   8'h8a: d=8'h7e;
	   8'h8b: d=8'h3d;
	   8'h8c: d=8'h64;
	   8'h8d: d=8'h5d;
	   8'h8e: d=8'h19;
	   8'h8f: d=8'h73;
	   8'h90: d=8'h60;
	   8'h91: d=8'h81;
	   8'h92: d=8'h4f;
	   8'h93: d=8'hdc;
	   8'h94: d=8'h22;
	   8'h95: d=8'h2a;
	   8'h96: d=8'h90;
	   8'h97: d=8'h88;
	   8'h98: d=8'h46;
	   8'h99: d=8'hee;
	   8'h9a: d=8'hb8;
	   8'h9b: d=8'h14;
	   8'h9c: d=8'hde;
	   8'h9d: d=8'h5e;
	   8'h9e: d=8'h0b;
	   8'h9f: d=8'hdb;
	   8'ha0: d=8'he0;
	   8'ha1: d=8'h32;
	   8'ha2: d=8'h3a;
	   8'ha3: d=8'h0a;
	   8'ha4: d=8'h49;
	   8'ha5: d=8'h06;
	   8'ha6: d=8'h24;
	   8'ha7: d=8'h5c;
	   8'ha8: d=8'hc2;
	   8'ha9: d=8'hd3;
	   8'haa: d=8'hac;
	   8'hab: d=8'h62;
	   8'hac: d=8'h91;
	   8'had: d=8'h95;
	   8'hae: d=8'he4;
	   8'haf: d=8'h79;
	   8'hb0: d=8'he7;
	   8'hb1: d=8'hc8;
	   8'hb2: d=8'h37;
	   8'hb3: d=8'h6d;
	   8'hb4: d=8'h8d;
	   8'hb5: d=8'hd5;
	   8'hb6: d=8'h4e;
	   8'hb7: d=8'ha9;
	   8'hb8: d=8'h6c;
	   8'hb9: d=8'h56;
	   8'hba: d=8'hf4;
	   8'hbb: d=8'hea;
	   8'hbc: d=8'h65;
	   8'hbd: d=8'h7a;
	   8'hbe: d=8'hae;
	   8'hbf: d=8'h08;
	   8'hc0: d=8'hba;
	   8'hc1: d=8'h78;
	   8'hc2: d=8'h25;
	   8'hc3: d=8'h2e;
	   8'hc4: d=8'h1c;
	   8'hc5: d=8'ha6;
	   8'hc6: d=8'hb4;
	   8'hc7: d=8'hc6;
	   8'hc8: d=8'he8;
	   8'hc9: d=8'hdd;
	   8'hca: d=8'h74;
	   8'hcb: d=8'h1f;
	   8'hcc: d=8'h4b;
	   8'hcd: d=8'hbd;
	   8'hce: d=8'h8b;
	   8'hcf: d=8'h8a;
	   8'hd0: d=8'h70;
	   8'hd1: d=8'h3e;
	   8'hd2: d=8'hb5;
	   8'hd3: d=8'h66;
	   8'hd4: d=8'h48;
	   8'hd5: d=8'h03;
	   8'hd6: d=8'hf6;
	   8'hd7: d=8'h0e;
	   8'hd8: d=8'h61;
	   8'hd9: d=8'h35;
	   8'hda: d=8'h57;
	   8'hdb: d=8'hb9;
	   8'hdc: d=8'h86;
	   8'hdd: d=8'hc1;
	   8'hde: d=8'h1d;
	   8'hdf: d=8'h9e;
	   8'he0: d=8'he1;
	   8'he1: d=8'hf8;
	   8'he2: d=8'h98;
	   8'he3: d=8'h11;
	   8'he4: d=8'h69;
	   8'he5: d=8'hd9;
	   8'he6: d=8'h8e;
	   8'he7: d=8'h94;
	   8'he8: d=8'h9b;
	   8'he9: d=8'h1e;
	   8'hea: d=8'h87;
	   8'heb: d=8'he9;
	   8'hec: d=8'hce;
	   8'hed: d=8'h55;
	   8'hee: d=8'h28;
	   8'hef: d=8'hdf;
	   8'hf0: d=8'h8c;
	   8'hf1: d=8'ha1;
	   8'hf2: d=8'h89;
	   8'hf3: d=8'h0d;
	   8'hf4: d=8'hbf;
	   8'hf5: d=8'he6;
	   8'hf6: d=8'h42;
	   8'hf7: d=8'h68;
	   8'hf8: d=8'h41;
	   8'hf9: d=8'h99;
	   8'hfa: d=8'h2d;
	   8'hfb: d=8'h0f;
	   8'hfc: d=8'hb0;
	   8'hfd: d=8'h54;
	   8'hfe: d=8'hbb;
	   8'hff: d=8'h16;
	endcase

endmodule



// -----------------------------------------------------------------------------
// Source file: aes_1cycle_1stage/aes_cipher_top.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Cipher Top Level                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
 
//// Modified to achieve 1 cycle functionality 			     ////
//// By Tariq Bashir Ahmad					     //// 	
////  tariq.bashir@gmail.com					     ////
////  http://www.ecs.umass.edu/~tbashir				     ////	



`timescale 1 ns/1 ps

module aes_cipher_top(clk, rst, ld, done, key, text_in, text_out);

input		clk, rst;
input		ld;
output		done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;


reg	[127:0]	text_in_r;
reg	[127:0]	text_out;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[31:0]	w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22,
               w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33, w34, w35, w36, w37, w38, w39, w40, w41, w42, w43;
					
reg	[127:0]	text_out_temp;

//round 1 wires
reg	[7:0]	sa00, sa01, sa02, sa03;
reg	[7:0]	sa10, sa11, sa12, sa13;
reg	[7:0]	sa20, sa21, sa22, sa23;
reg	[7:0]	sa30, sa31, sa32, sa33;

wire	[7:0]	sa00_next, sa01_next, sa02_next, sa03_next;
wire	[7:0]	sa10_next, sa11_next, sa12_next, sa13_next;
wire	[7:0]	sa20_next, sa21_next, sa22_next, sa23_next;
wire	[7:0]	sa30_next, sa31_next, sa32_next, sa33_next;

wire	[7:0]	sa00_sub, sa01_sub, sa02_sub, sa03_sub;
wire	[7:0]	sa10_sub, sa11_sub, sa12_sub, sa13_sub;
wire  [7:0]	sa20_sub, sa21_sub, sa22_sub, sa23_sub;
wire	[7:0]	sa30_sub, sa31_sub, sa32_sub, sa33_sub;

wire	[7:0]	sa00_sr, sa01_sr, sa02_sr, sa03_sr;
wire	[7:0]	sa10_sr, sa11_sr, sa12_sr, sa13_sr;
wire	[7:0]	sa20_sr, sa21_sr, sa22_sr, sa23_sr;
wire	[7:0]	sa30_sr, sa31_sr, sa32_sr, sa33_sr;

wire	[7:0]	sa00_mc, sa01_mc, sa02_mc, sa03_mc;
wire	[7:0]	sa10_mc, sa11_mc, sa12_mc, sa13_mc;
wire	[7:0]	sa20_mc, sa21_mc, sa22_mc, sa23_mc;
wire	[7:0]	sa30_mc, sa31_mc, sa32_mc, sa33_mc;


//round2 wires
wire	[7:0]	sa00_next_round2, sa01_next_round2, sa02_next_round2, sa03_next_round2;
wire	[7:0]	sa10_next_round2, sa11_next_round2, sa12_next_round2, sa13_next_round2;
wire	[7:0]	sa20_next_round2, sa21_next_round2, sa22_next_round2, sa23_next_round2;
wire	[7:0]	sa30_next_round2, sa31_next_round2, sa32_next_round2, sa33_next_round2;

wire	[7:0]	sa00_sub_round2, sa01_sub_round2, sa02_sub_round2, sa03_sub_round2;
wire	[7:0]	sa10_sub_round2, sa11_sub_round2, sa12_sub_round2, sa13_sub_round2;
wire  [7:0]	sa20_sub_round2, sa21_sub_round2, sa22_sub_round2, sa23_sub_round2;
wire	[7:0]	sa30_sub_round2, sa31_sub_round2, sa32_sub_round2, sa33_sub_round2;

wire	[7:0]	sa00_sr_round2, sa01_sr_round2, sa02_sr_round2, sa03_sr_round2;
wire	[7:0]	sa10_sr_round2, sa11_sr_round2, sa12_sr_round2, sa13_sr_round2;
wire	[7:0]	sa20_sr_round2, sa21_sr_round2, sa22_sr_round2, sa23_sr_round2;
wire	[7:0]	sa30_sr_round2, sa31_sr_round2, sa32_sr_round2, sa33_sr_round2;

wire	[7:0]	sa00_mc_round2, sa01_mc_round2, sa02_mc_round2, sa03_mc_round2;
wire	[7:0]	sa10_mc_round2, sa11_mc_round2, sa12_mc_round2, sa13_mc_round2;
wire	[7:0]	sa20_mc_round2, sa21_mc_round2, sa22_mc_round2, sa23_mc_round2;
wire	[7:0]	sa30_mc_round2, sa31_mc_round2, sa32_mc_round2, sa33_mc_round2;


//round3 wires
wire	[7:0]	sa00_next_round3, sa01_next_round3, sa02_next_round3, sa03_next_round3;
wire	[7:0]	sa10_next_round3, sa11_next_round3, sa12_next_round3, sa13_next_round3;
wire	[7:0]	sa20_next_round3, sa21_next_round3, sa22_next_round3, sa23_next_round3;
wire	[7:0]	sa30_next_round3, sa31_next_round3, sa32_next_round3, sa33_next_round3;

wire	[7:0]	sa00_sub_round3, sa01_sub_round3, sa02_sub_round3, sa03_sub_round3;
wire	[7:0]	sa10_sub_round3, sa11_sub_round3, sa12_sub_round3, sa13_sub_round3;
wire  [7:0]	sa20_sub_round3, sa21_sub_round3, sa22_sub_round3, sa23_sub_round3;
wire	[7:0]	sa30_sub_round3, sa31_sub_round3, sa32_sub_round3, sa33_sub_round3;

wire	[7:0]	sa00_sr_round3, sa01_sr_round3, sa02_sr_round3, sa03_sr_round3;
wire	[7:0]	sa10_sr_round3, sa11_sr_round3, sa12_sr_round3, sa13_sr_round3;
wire	[7:0]	sa20_sr_round3, sa21_sr_round3, sa22_sr_round3, sa23_sr_round3;
wire	[7:0]	sa30_sr_round3, sa31_sr_round3, sa32_sr_round3, sa33_sr_round3;

wire	[7:0]	sa00_mc_round3, sa01_mc_round3, sa02_mc_round3, sa03_mc_round3;
wire	[7:0]	sa10_mc_round3, sa11_mc_round3, sa12_mc_round3, sa13_mc_round3;
wire	[7:0]	sa20_mc_round3, sa21_mc_round3, sa22_mc_round3, sa23_mc_round3;
wire	[7:0]	sa30_mc_round3, sa31_mc_round3, sa32_mc_round3, sa33_mc_round3;



//round4 wires
wire	[7:0]	sa00_next_round4, sa01_next_round4, sa02_next_round4, sa03_next_round4;
wire	[7:0]	sa10_next_round4, sa11_next_round4, sa12_next_round4, sa13_next_round4;
wire	[7:0]	sa20_next_round4, sa21_next_round4, sa22_next_round4, sa23_next_round4;
wire	[7:0]	sa30_next_round4, sa31_next_round4, sa32_next_round4, sa33_next_round4;

wire	[7:0]	sa00_sub_round4, sa01_sub_round4, sa02_sub_round4, sa03_sub_round4;
wire	[7:0]	sa10_sub_round4, sa11_sub_round4, sa12_sub_round4, sa13_sub_round4;
wire  [7:0]	sa20_sub_round4, sa21_sub_round4, sa22_sub_round4, sa23_sub_round4;
wire	[7:0]	sa30_sub_round4, sa31_sub_round4, sa32_sub_round4, sa33_sub_round4;

wire	[7:0]	sa00_sr_round4, sa01_sr_round4, sa02_sr_round4, sa03_sr_round4;
wire	[7:0]	sa10_sr_round4, sa11_sr_round4, sa12_sr_round4, sa13_sr_round4;
wire	[7:0]	sa20_sr_round4, sa21_sr_round4, sa22_sr_round4, sa23_sr_round4;
wire	[7:0]	sa30_sr_round4, sa31_sr_round4, sa32_sr_round4, sa33_sr_round4;

wire	[7:0]	sa00_mc_round4, sa01_mc_round4, sa02_mc_round4, sa03_mc_round4;
wire	[7:0]	sa10_mc_round4, sa11_mc_round4, sa12_mc_round4, sa13_mc_round4;
wire	[7:0]	sa20_mc_round4, sa21_mc_round4, sa22_mc_round4, sa23_mc_round4;
wire	[7:0]	sa30_mc_round4, sa31_mc_round4, sa32_mc_round4, sa33_mc_round4;

//round5 wires
wire	[7:0]	sa00_next_round5, sa01_next_round5, sa02_next_round5, sa03_next_round5;
wire	[7:0]	sa10_next_round5, sa11_next_round5, sa12_next_round5, sa13_next_round5;
wire	[7:0]	sa20_next_round5, sa21_next_round5, sa22_next_round5, sa23_next_round5;
wire	[7:0]	sa30_next_round5, sa31_next_round5, sa32_next_round5, sa33_next_round5;

wire	[7:0]	sa00_sub_round5, sa01_sub_round5, sa02_sub_round5, sa03_sub_round5;
wire	[7:0]	sa10_sub_round5, sa11_sub_round5, sa12_sub_round5, sa13_sub_round5;
wire  [7:0]	sa20_sub_round5, sa21_sub_round5, sa22_sub_round5, sa23_sub_round5;
wire	[7:0]	sa30_sub_round5, sa31_sub_round5, sa32_sub_round5, sa33_sub_round5;

wire	[7:0]	sa00_sr_round5, sa01_sr_round5, sa02_sr_round5, sa03_sr_round5;
wire	[7:0]	sa10_sr_round5, sa11_sr_round5, sa12_sr_round5, sa13_sr_round5;
wire	[7:0]	sa20_sr_round5, sa21_sr_round5, sa22_sr_round5, sa23_sr_round5;
wire	[7:0]	sa30_sr_round5, sa31_sr_round5, sa32_sr_round5, sa33_sr_round5;

wire	[7:0]	sa00_mc_round5, sa01_mc_round5, sa02_mc_round5, sa03_mc_round5;
wire	[7:0]	sa10_mc_round5, sa11_mc_round5, sa12_mc_round5, sa13_mc_round5;
wire	[7:0]	sa20_mc_round5, sa21_mc_round5, sa22_mc_round5, sa23_mc_round5;
wire	[7:0]	sa30_mc_round5, sa31_mc_round5, sa32_mc_round5, sa33_mc_round5;


//round6 wires
wire	[7:0]	sa00_next_round6, sa01_next_round6, sa02_next_round6, sa03_next_round6;
wire	[7:0]	sa10_next_round6, sa11_next_round6, sa12_next_round6, sa13_next_round6;
wire	[7:0]	sa20_next_round6, sa21_next_round6, sa22_next_round6, sa23_next_round6;
wire	[7:0]	sa30_next_round6, sa31_next_round6, sa32_next_round6, sa33_next_round6;

wire	[7:0]	sa00_sub_round6, sa01_sub_round6, sa02_sub_round6, sa03_sub_round6;
wire	[7:0]	sa10_sub_round6, sa11_sub_round6, sa12_sub_round6, sa13_sub_round6;
wire  [7:0]	sa20_sub_round6, sa21_sub_round6, sa22_sub_round6, sa23_sub_round6;
wire	[7:0]	sa30_sub_round6, sa31_sub_round6, sa32_sub_round6, sa33_sub_round6;

wire	[7:0]	sa00_sr_round6, sa01_sr_round6, sa02_sr_round6, sa03_sr_round6;
wire	[7:0]	sa10_sr_round6, sa11_sr_round6, sa12_sr_round6, sa13_sr_round6;
wire	[7:0]	sa20_sr_round6, sa21_sr_round6, sa22_sr_round6, sa23_sr_round6;
wire	[7:0]	sa30_sr_round6, sa31_sr_round6, sa32_sr_round6, sa33_sr_round6;

wire	[7:0]	sa00_mc_round6, sa01_mc_round6, sa02_mc_round6, sa03_mc_round6;
wire	[7:0]	sa10_mc_round6, sa11_mc_round6, sa12_mc_round6, sa13_mc_round6;
wire	[7:0]	sa20_mc_round6, sa21_mc_round6, sa22_mc_round6, sa23_mc_round6;
wire	[7:0]	sa30_mc_round6, sa31_mc_round6, sa32_mc_round6, sa33_mc_round6;


//round7 wires
wire	[7:0]	sa00_next_round7, sa01_next_round7, sa02_next_round7, sa03_next_round7;
wire	[7:0]	sa10_next_round7, sa11_next_round7, sa12_next_round7, sa13_next_round7;
wire	[7:0]	sa20_next_round7, sa21_next_round7, sa22_next_round7, sa23_next_round7;
wire	[7:0]	sa30_next_round7, sa31_next_round7, sa32_next_round7, sa33_next_round7;

wire	[7:0]	sa00_sub_round7, sa01_sub_round7, sa02_sub_round7, sa03_sub_round7;
wire	[7:0]	sa10_sub_round7, sa11_sub_round7, sa12_sub_round7, sa13_sub_round7;
wire  [7:0]	sa20_sub_round7, sa21_sub_round7, sa22_sub_round7, sa23_sub_round7;
wire	[7:0]	sa30_sub_round7, sa31_sub_round7, sa32_sub_round7, sa33_sub_round7;

wire	[7:0]	sa00_sr_round7, sa01_sr_round7, sa02_sr_round7, sa03_sr_round7;
wire	[7:0]	sa10_sr_round7, sa11_sr_round7, sa12_sr_round7, sa13_sr_round7;
wire	[7:0]	sa20_sr_round7, sa21_sr_round7, sa22_sr_round7, sa23_sr_round7;
wire	[7:0]	sa30_sr_round7, sa31_sr_round7, sa32_sr_round7, sa33_sr_round7;

wire	[7:0]	sa00_mc_round7, sa01_mc_round7, sa02_mc_round7, sa03_mc_round7;
wire	[7:0]	sa10_mc_round7, sa11_mc_round7, sa12_mc_round7, sa13_mc_round7;
wire	[7:0]	sa20_mc_round7, sa21_mc_round7, sa22_mc_round7, sa23_mc_round7;
wire	[7:0]	sa30_mc_round7, sa31_mc_round7, sa32_mc_round7, sa33_mc_round7;


//round8 wires
wire	[7:0]	sa00_next_round8, sa01_next_round8, sa02_next_round8, sa03_next_round8;
wire	[7:0]	sa10_next_round8, sa11_next_round8, sa12_next_round8, sa13_next_round8;
wire	[7:0]	sa20_next_round8, sa21_next_round8, sa22_next_round8, sa23_next_round8;
wire	[7:0]	sa30_next_round8, sa31_next_round8, sa32_next_round8, sa33_next_round8;

wire	[7:0]	sa00_sub_round8, sa01_sub_round8, sa02_sub_round8, sa03_sub_round8;
wire	[7:0]	sa10_sub_round8, sa11_sub_round8, sa12_sub_round8, sa13_sub_round8;
wire  [7:0]	sa20_sub_round8, sa21_sub_round8, sa22_sub_round8, sa23_sub_round8;
wire	[7:0]	sa30_sub_round8, sa31_sub_round8, sa32_sub_round8, sa33_sub_round8;

wire	[7:0]	sa00_sr_round8, sa01_sr_round8, sa02_sr_round8, sa03_sr_round8;
wire	[7:0]	sa10_sr_round8, sa11_sr_round8, sa12_sr_round8, sa13_sr_round8;
wire	[7:0]	sa20_sr_round8, sa21_sr_round8, sa22_sr_round8, sa23_sr_round8;
wire	[7:0]	sa30_sr_round8, sa31_sr_round8, sa32_sr_round8, sa33_sr_round8;

wire	[7:0]	sa00_mc_round8, sa01_mc_round8, sa02_mc_round8, sa03_mc_round8;
wire	[7:0]	sa10_mc_round8, sa11_mc_round8, sa12_mc_round8, sa13_mc_round8;
wire	[7:0]	sa20_mc_round8, sa21_mc_round8, sa22_mc_round8, sa23_mc_round8;
wire	[7:0]	sa30_mc_round8, sa31_mc_round8, sa32_mc_round8, sa33_mc_round8;


//round9 wires
wire	[7:0]	sa00_next_round9, sa01_next_round9, sa02_next_round9, sa03_next_round9;
wire	[7:0]	sa10_next_round9, sa11_next_round9, sa12_next_round9, sa13_next_round9;
wire	[7:0]	sa20_next_round9, sa21_next_round9, sa22_next_round9, sa23_next_round9;
wire	[7:0]	sa30_next_round9, sa31_next_round9, sa32_next_round9, sa33_next_round9;

wire	[7:0]	sa00_sub_round9, sa01_sub_round9, sa02_sub_round9, sa03_sub_round9;
wire	[7:0]	sa10_sub_round9, sa11_sub_round9, sa12_sub_round9, sa13_sub_round9;
wire  [7:0]	sa20_sub_round9, sa21_sub_round9, sa22_sub_round9, sa23_sub_round9;
wire	[7:0]	sa30_sub_round9, sa31_sub_round9, sa32_sub_round9, sa33_sub_round9;

wire	[7:0]	sa00_sr_round9, sa01_sr_round9, sa02_sr_round9, sa03_sr_round9;
wire	[7:0]	sa10_sr_round9, sa11_sr_round9, sa12_sr_round9, sa13_sr_round9;
wire	[7:0]	sa20_sr_round9, sa21_sr_round9, sa22_sr_round9, sa23_sr_round9;
wire	[7:0]	sa30_sr_round9, sa31_sr_round9, sa32_sr_round9, sa33_sr_round9;

wire	[7:0]	sa00_mc_round9, sa01_mc_round9, sa02_mc_round9, sa03_mc_round9;
wire	[7:0]	sa10_mc_round9, sa11_mc_round9, sa12_mc_round9, sa13_mc_round9;
wire	[7:0]	sa20_mc_round9, sa21_mc_round9, sa22_mc_round9, sa23_mc_round9;
wire	[7:0]	sa30_mc_round9, sa31_mc_round9, sa32_mc_round9, sa33_mc_round9;


//round10 wires
wire	[7:0]	sa00_next_round10, sa01_next_round10, sa02_next_round10, sa03_next_round10;
wire	[7:0]	sa10_next_round10, sa11_next_round10, sa12_next_round10, sa13_next_round10;
wire	[7:0]	sa20_next_round10, sa21_next_round10, sa22_next_round10, sa23_next_round10;
wire	[7:0]	sa30_next_round10, sa31_next_round10, sa32_next_round10, sa33_next_round10;

wire	[7:0]	sa00_sub_round10, sa01_sub_round10, sa02_sub_round10, sa03_sub_round10;
wire	[7:0]	sa10_sub_round10, sa11_sub_round10, sa12_sub_round10, sa13_sub_round10;
wire  [7:0]	sa20_sub_round10, sa21_sub_round10, sa22_sub_round10, sa23_sub_round10;
wire	[7:0]	sa30_sub_round10, sa31_sub_round10, sa32_sub_round10, sa33_sub_round10;

wire	[7:0]	sa00_sr_round10, sa01_sr_round10, sa02_sr_round10, sa03_sr_round10;
wire	[7:0]	sa10_sr_round10, sa11_sr_round10, sa12_sr_round10, sa13_sr_round10;
wire	[7:0]	sa20_sr_round10, sa21_sr_round10, sa22_sr_round10, sa23_sr_round10;
wire	[7:0]	sa30_sr_round10, sa31_sr_round10, sa32_sr_round10, sa33_sr_round10;



reg		done, ld_r;
reg	[3:0]	dcnt;
reg 		done2;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
begin
	if(~rst)	begin dcnt <=  4'h0;	 end
	else
	if(ld)	begin	dcnt <=  4'h2;	 end
	else
	if(|dcnt) begin	dcnt <=  dcnt - 4'h1;  end

end

always @(posedge clk) done <=  !(|dcnt[3:1]) & dcnt[0] & !ld;
always @(posedge clk) if(ld) text_in_r <=  text_in;
always @(posedge clk) ld_r <=  ld;



////////////////////////////////////////////////////////////////////
// key expansion


aes_key_expand_128 u0(
	.clk(		clk	),
	.key(		key	),
	.w0(		w0	),
	.w1(		w1	),
	.w2(		w2	),
	.w3(		w3	),
	.w4(		w4	),
	.w5(		w5	),
	.w6(		w6	),
	.w7(		w7	),
	.w8(		w8	),
	.w9(		w9	),
	.w10(		w10	),
	.w11(		w11	),
	.w12(		w12	),
	.w13(		w13	),
	.w14(		w14	),
	.w15(		w15	),
	.w16(		w16	),
	.w17(		w17	),
	.w18(		w18	),
	.w19(		w19	),	
	.w20(		w20	),
	.w21(		w21	),
	.w22(		w22	),
	.w23(		w23	),
	.w24(		w24	),
	.w25(		w25	),
	.w26(		w26	),
	.w27(		w27	),
	.w28(		w28	),
	.w29(		w29	),
	.w30(		w30	),
	.w31(		w31	),
	.w32(		w32	),
	.w33(		w33	),
	.w34(		w34	),
	.w35(		w35	),
	.w36(		w36	),
	.w37(		w37	),
	.w38(		w38	),
	.w39(		w39	),
	.w40(		w40	),
	.w41(		w41	),
	.w42(		w42	),
	.w43(		w43	)
					);

always @(posedge clk) 
begin
   	sa33 <=   text_in_r[007:000] ^ w3[07:00]; //sa33_mc_round2 ^ w3[07:00];
    	sa23 <=   text_in_r[015:008] ^ w3[15:08]; //sa23_mc_round2 ^ w3[15:08];
    	sa13 <=   text_in_r[023:016] ^ w3[23:16]; //sa13_mc_round2 ^ w3[23:16];
    	sa03 <=   text_in_r[031:024] ^ w3[31:24]; //sa03_mc_round2 ^ w3[31:24];
    	sa32 <=   text_in_r[039:032] ^ w2[07:00]; //sa32_mc_round2 ^ w2[07:00];
    	sa22 <=   text_in_r[047:040] ^ w2[15:08]; //sa22_mc_round2 ^ w2[15:08];
    	sa12 <=   text_in_r[055:048] ^ w2[23:16]; //sa12_mc_round2 ^ w2[23:16];
    	sa02 <=   text_in_r[063:056] ^ w2[31:24]; //sa02_mc_round2 ^ w2[31:24];
    	sa31 <=   text_in_r[071:064] ^ w1[07:00]; //sa31_mc_round2 ^ w1[07:00];
    	sa21 <=   text_in_r[079:072] ^ w1[15:08]; //sa21_mc_round2 ^ w1[15:08];
    	sa11 <=   text_in_r[087:080] ^ w1[23:16]; //sa11_mc_round2 ^ w1[23:16];
    	sa01 <=   text_in_r[095:088] ^ w1[31:24]; //sa01_mc_round2 ^ w1[31:24];
    	sa30 <=   text_in_r[103:096] ^ w0[07:00]; //sa30_mc_round2 ^ w0[07:00];
    	sa20 <=   text_in_r[111:104] ^ w0[15:08]; //sa20_mc_round2 ^ w0[15:08];
    	sa10 <=   text_in_r[119:112] ^ w0[23:16]; //sa10_mc_round2 ^ w0[23:16];
    	sa00 <=   text_in_r[127:120] ^ w0[31:24]; //sa00_mc_round2 ^ w0[31:24];
				
end


//sbox lookup
aes_sbox us00(	.a(	sa00	), .d(	sa00_sub	));
aes_sbox us01(	.a(	sa01	), .d(	sa01_sub	));
aes_sbox us02(	.a(	sa02	), .d(	sa02_sub	));
aes_sbox us03(	.a(	sa03	), .d(	sa03_sub	));
aes_sbox us10(	.a(	sa10	), .d(	sa10_sub	));
aes_sbox us11(	.a(	sa11	), .d(	sa11_sub	));
aes_sbox us12(	.a(	sa12	), .d(	sa12_sub	));
aes_sbox us13(	.a(	sa13	), .d(	sa13_sub	));
aes_sbox us20(	.a(	sa20	), .d(	sa20_sub	));
aes_sbox us21(	.a(	sa21	), .d(	sa21_sub	));
aes_sbox us22(	.a(	sa22	), .d(	sa22_sub	));
aes_sbox us23(	.a(	sa23	), .d(	sa23_sub	));
aes_sbox us30(	.a(	sa30	), .d(	sa30_sub	));
aes_sbox us31(	.a(	sa31	), .d(	sa31_sub	));
aes_sbox us32(	.a(	sa32	), .d(	sa32_sub	));
aes_sbox us33(	.a(	sa33	), .d(	sa33_sub	));

//shift rows

assign sa00_sr = sa00_sub;		//
assign sa01_sr = sa01_sub;		//no shift
assign sa02_sr = sa02_sub;		//
assign sa03_sr = sa03_sub;		//

assign sa10_sr = sa11_sub;		//
assign sa11_sr = sa12_sub;		// left shift by 1
assign sa12_sr = sa13_sub;		//
assign sa13_sr = sa10_sub;		//

assign sa20_sr = sa22_sub;		//
assign sa21_sr = sa23_sub;		//	left shift by 2
assign sa22_sr = sa20_sub;		//
assign sa23_sr = sa21_sub;		//

assign sa30_sr = sa33_sub;		//
assign sa31_sr = sa30_sub;		// left shift by 3
assign sa32_sr = sa31_sub;		//
assign sa33_sr = sa32_sub;		//

// mix column operation
assign {sa00_mc, sa10_mc, sa20_mc, sa30_mc}  = mix_col(sa00_sr,sa10_sr,sa20_sr,sa30_sr);
assign {sa01_mc, sa11_mc, sa21_mc, sa31_mc}  = mix_col(sa01_sr,sa11_sr,sa21_sr,sa31_sr);
assign {sa02_mc, sa12_mc, sa22_mc, sa32_mc}  = mix_col(sa02_sr,sa12_sr,sa22_sr,sa32_sr);
assign {sa03_mc, sa13_mc, sa23_mc, sa33_mc}  = mix_col(sa03_sr,sa13_sr,sa23_sr,sa33_sr);

//// add round key
assign sa00_next_round2 = sa00_mc ^ w4[31:24];		
assign sa01_next_round2 = sa01_mc ^ w5[31:24];
assign sa02_next_round2 = sa02_mc ^ w6[31:24];
assign sa03_next_round2 = sa03_mc ^ w7[31:24];
assign sa10_next_round2 = sa10_mc ^ w4[23:16];
assign sa11_next_round2 = sa11_mc ^ w5[23:16];
assign sa12_next_round2 = sa12_mc ^ w6[23:16];
assign sa13_next_round2 = sa13_mc ^ w7[23:16];
assign sa20_next_round2 = sa20_mc ^ w4[15:08];
assign sa21_next_round2 = sa21_mc ^ w5[15:08];
assign sa22_next_round2 = sa22_mc ^ w6[15:08];
assign sa23_next_round2 = sa23_mc ^ w7[15:08];
assign sa30_next_round2 = sa30_mc ^ w4[07:00];
assign sa31_next_round2 = sa31_mc ^ w5[07:00];
assign sa32_next_round2 = sa32_mc ^ w6[07:00];
assign sa33_next_round2 = sa33_mc ^ w7[07:00];



//////////////////////  round 2 //////////////////////////////////

//sbox lookup
aes_sbox us00_round2(	.a(	sa00_next_round2	), .d(	sa00_sub_round2	));
aes_sbox us01_round2(	.a(	sa01_next_round2	), .d(	sa01_sub_round2	));
aes_sbox us02_round2(	.a(	sa02_next_round2	), .d(	sa02_sub_round2	));
aes_sbox us03_round2(	.a(	sa03_next_round2	), .d(	sa03_sub_round2	));
aes_sbox us10_round2(	.a(	sa10_next_round2	), .d(	sa10_sub_round2	));
aes_sbox us11_round2(	.a(	sa11_next_round2	), .d(	sa11_sub_round2	));
aes_sbox us12_round2(	.a(	sa12_next_round2	), .d(	sa12_sub_round2	));
aes_sbox us13_round2(	.a(	sa13_next_round2	), .d(	sa13_sub_round2	));
aes_sbox us20_round2(	.a(	sa20_next_round2	), .d(	sa20_sub_round2	));
aes_sbox us21_round2(	.a(	sa21_next_round2	), .d(	sa21_sub_round2	));
aes_sbox us22_round2(	.a(	sa22_next_round2	), .d(	sa22_sub_round2	));
aes_sbox us23_round2(	.a(	sa23_next_round2	), .d(	sa23_sub_round2	));
aes_sbox us30_round2(	.a(	sa30_next_round2	), .d(	sa30_sub_round2	));
aes_sbox us31_round2(	.a(	sa31_next_round2	), .d(	sa31_sub_round2	));
aes_sbox us32_round2(	.a(	sa32_next_round2	), .d(	sa32_sub_round2	));
aes_sbox us33_round2(	.a(	sa33_next_round2	), .d(	sa33_sub_round2	));

//shift rows

assign sa00_sr_round2 = sa00_sub_round2;		//
assign sa01_sr_round2 = sa01_sub_round2;		//no shift
assign sa02_sr_round2 = sa02_sub_round2;		//
assign sa03_sr_round2 = sa03_sub_round2;		//

assign sa10_sr_round2 = sa11_sub_round2;		//
assign sa11_sr_round2 = sa12_sub_round2;		// left shift by 1
assign sa12_sr_round2 = sa13_sub_round2;		//
assign sa13_sr_round2 = sa10_sub_round2;		//

assign sa20_sr_round2 = sa22_sub_round2;		//
assign sa21_sr_round2 = sa23_sub_round2;		//	left shift by 2
assign sa22_sr_round2 = sa20_sub_round2;		//
assign sa23_sr_round2 = sa21_sub_round2;		//

assign sa30_sr_round2 = sa33_sub_round2;		//
assign sa31_sr_round2 = sa30_sub_round2;		// left shift by 3
assign sa32_sr_round2 = sa31_sub_round2;		//
assign sa33_sr_round2 = sa32_sub_round2;		//

// mix column operation
assign {sa00_mc_round2, sa10_mc_round2, sa20_mc_round2, sa30_mc_round2}  = mix_col(sa00_sr_round2,sa10_sr_round2,sa20_sr_round2,sa30_sr_round2);
assign {sa01_mc_round2, sa11_mc_round2, sa21_mc_round2, sa31_mc_round2}  = mix_col(sa01_sr_round2,sa11_sr_round2,sa21_sr_round2,sa31_sr_round2);
assign {sa02_mc_round2, sa12_mc_round2, sa22_mc_round2, sa32_mc_round2}  = mix_col(sa02_sr_round2,sa12_sr_round2,sa22_sr_round2,sa32_sr_round2);
assign {sa03_mc_round2, sa13_mc_round2, sa23_mc_round2, sa33_mc_round2}  = mix_col(sa03_sr_round2,sa13_sr_round2,sa23_sr_round2,sa33_sr_round2);

//add round key
assign sa33_next_round3 = 		   sa33_mc_round2 ^ w11[07:00];
assign sa23_next_round3 =     	sa23_mc_round2 ^ w11[15:08];
assign sa13_next_round3 =     	sa13_mc_round2 ^ w11[23:16];
assign sa03_next_round3 =     	sa03_mc_round2 ^ w11[31:24];
assign sa32_next_round3 =     	sa32_mc_round2 ^ w10[07:00];
assign sa22_next_round3 =     	sa22_mc_round2 ^ w10[15:08];
assign sa12_next_round3 =     	sa12_mc_round2 ^ w10[23:16];
assign sa02_next_round3 =     	sa02_mc_round2 ^ w10[31:24];
assign sa31_next_round3 =     	sa31_mc_round2 ^ w9[07:00];
assign sa21_next_round3 =     	sa21_mc_round2 ^ w9[15:08];
assign sa11_next_round3 =     	sa11_mc_round2 ^ w9[23:16];
assign sa01_next_round3 =     	sa01_mc_round2 ^ w9[31:24];
assign sa30_next_round3 =     	sa30_mc_round2 ^ w8[07:00];
assign sa20_next_round3 =     	sa20_mc_round2 ^ w8[15:08];
assign sa10_next_round3 =     	sa10_mc_round2 ^ w8[23:16];
assign sa00_next_round3 =     	sa00_mc_round2 ^ w8[31:24];


/////////////////////////round #3 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round3(	.a(	sa00_next_round3	), .d(	sa00_sub_round3	));
aes_sbox us01_round3(	.a(	sa01_next_round3	), .d(	sa01_sub_round3	));
aes_sbox us02_round3(	.a(	sa02_next_round3	), .d(	sa02_sub_round3	));
aes_sbox us03_round3(	.a(	sa03_next_round3	), .d(	sa03_sub_round3	));
aes_sbox us10_round3(	.a(	sa10_next_round3	), .d(	sa10_sub_round3	));
aes_sbox us11_round3(	.a(	sa11_next_round3	), .d(	sa11_sub_round3	));
aes_sbox us12_round3(	.a(	sa12_next_round3	), .d(	sa12_sub_round3	));
aes_sbox us13_round3(	.a(	sa13_next_round3	), .d(	sa13_sub_round3	));
aes_sbox us20_round3(	.a(	sa20_next_round3	), .d(	sa20_sub_round3	));
aes_sbox us21_round3(	.a(	sa21_next_round3	), .d(	sa21_sub_round3	));
aes_sbox us22_round3(	.a(	sa22_next_round3	), .d(	sa22_sub_round3	));
aes_sbox us23_round3(	.a(	sa23_next_round3	), .d(	sa23_sub_round3	));
aes_sbox us30_round3(	.a(	sa30_next_round3	), .d(	sa30_sub_round3	));
aes_sbox us31_round3(	.a(	sa31_next_round3	), .d(	sa31_sub_round3	));
aes_sbox us32_round3(	.a(	sa32_next_round3	), .d(	sa32_sub_round3	));
aes_sbox us33_round3(	.a(	sa33_next_round3	), .d(	sa33_sub_round3	));

//shift rows

assign sa00_sr_round3 = sa00_sub_round3;		//
assign sa01_sr_round3 = sa01_sub_round3;		//no shift
assign sa02_sr_round3 = sa02_sub_round3;		//
assign sa03_sr_round3 = sa03_sub_round3;		//

assign sa10_sr_round3 = sa11_sub_round3;		//
assign sa11_sr_round3 = sa12_sub_round3;		// left shift by 1
assign sa12_sr_round3 = sa13_sub_round3;		//
assign sa13_sr_round3 = sa10_sub_round3;		//

assign sa20_sr_round3 = sa22_sub_round3;		//
assign sa21_sr_round3 = sa23_sub_round3;		//	left shift by 2
assign sa22_sr_round3 = sa20_sub_round3;		//
assign sa23_sr_round3 = sa21_sub_round3;		//

assign sa30_sr_round3 = sa33_sub_round3;		//
assign sa31_sr_round3 = sa30_sub_round3;		// left shift by 3
assign sa32_sr_round3 = sa31_sub_round3;		//
assign sa33_sr_round3 = sa32_sub_round3;		//

// mix column operation
assign {sa00_mc_round3, sa10_mc_round3, sa20_mc_round3, sa30_mc_round3}  = mix_col(sa00_sr_round3,sa10_sr_round3,sa20_sr_round3,sa30_sr_round3);
assign {sa01_mc_round3, sa11_mc_round3, sa21_mc_round3, sa31_mc_round3}  = mix_col(sa01_sr_round3,sa11_sr_round3,sa21_sr_round3,sa31_sr_round3);
assign {sa02_mc_round3, sa12_mc_round3, sa22_mc_round3, sa32_mc_round3}  = mix_col(sa02_sr_round3,sa12_sr_round3,sa22_sr_round3,sa32_sr_round3);
assign {sa03_mc_round3, sa13_mc_round3, sa23_mc_round3, sa33_mc_round3}  = mix_col(sa03_sr_round3,sa13_sr_round3,sa23_sr_round3,sa33_sr_round3);


//add round key
assign sa33_next_round4 = 		   sa33_mc_round3 ^ w15[07:00];
assign sa23_next_round4 =     	sa23_mc_round3 ^ w15[15:08];
assign sa13_next_round4 =     	sa13_mc_round3 ^ w15[23:16];
assign sa03_next_round4 =     	sa03_mc_round3 ^ w15[31:24];
assign sa32_next_round4 =     	sa32_mc_round3 ^ w14[07:00];
assign sa22_next_round4 =     	sa22_mc_round3 ^ w14[15:08];
assign sa12_next_round4 =     	sa12_mc_round3 ^ w14[23:16];
assign sa02_next_round4 =     	sa02_mc_round3 ^ w14[31:24];
assign sa31_next_round4 =     	sa31_mc_round3 ^ w13[07:00];
assign sa21_next_round4 =     	sa21_mc_round3 ^ w13[15:08];
assign sa11_next_round4 =     	sa11_mc_round3 ^ w13[23:16];
assign sa01_next_round4 =     	sa01_mc_round3 ^ w13[31:24];
assign sa30_next_round4 =     	sa30_mc_round3 ^ w12[07:00];
assign sa20_next_round4 =     	sa20_mc_round3 ^ w12[15:08];
assign sa10_next_round4 =     	sa10_mc_round3 ^ w12[23:16];
assign sa00_next_round4 =     	sa00_mc_round3 ^ w12[31:24];

/////////////////////////round #4 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round4(	.a(	sa00_next_round4	), .d(	sa00_sub_round4	));
aes_sbox us01_round4(	.a(	sa01_next_round4	), .d(	sa01_sub_round4	));
aes_sbox us02_round4(	.a(	sa02_next_round4	), .d(	sa02_sub_round4	));
aes_sbox us03_round4(	.a(	sa03_next_round4	), .d(	sa03_sub_round4	));
aes_sbox us10_round4(	.a(	sa10_next_round4	), .d(	sa10_sub_round4	));
aes_sbox us11_round4(	.a(	sa11_next_round4	), .d(	sa11_sub_round4	));
aes_sbox us12_round4(	.a(	sa12_next_round4	), .d(	sa12_sub_round4	));
aes_sbox us13_round4(	.a(	sa13_next_round4	), .d(	sa13_sub_round4	));
aes_sbox us20_round4(	.a(	sa20_next_round4	), .d(	sa20_sub_round4	));
aes_sbox us21_round4(	.a(	sa21_next_round4	), .d(	sa21_sub_round4	));
aes_sbox us22_round4(	.a(	sa22_next_round4	), .d(	sa22_sub_round4	));
aes_sbox us23_round4(	.a(	sa23_next_round4	), .d(	sa23_sub_round4	));
aes_sbox us30_round4(	.a(	sa30_next_round4	), .d(	sa30_sub_round4	));
aes_sbox us31_round4(	.a(	sa31_next_round4	), .d(	sa31_sub_round4	));
aes_sbox us32_round4(	.a(	sa32_next_round4	), .d(	sa32_sub_round4	));
aes_sbox us33_round4(	.a(	sa33_next_round4	), .d(	sa33_sub_round4	));

//shift rows

assign sa00_sr_round4 = sa00_sub_round4;		//
assign sa01_sr_round4 = sa01_sub_round4;		//no shift
assign sa02_sr_round4 = sa02_sub_round4;		//
assign sa03_sr_round4 = sa03_sub_round4;		//

assign sa10_sr_round4 = sa11_sub_round4;		//
assign sa11_sr_round4 = sa12_sub_round4;		// left shift by 1
assign sa12_sr_round4 = sa13_sub_round4;		//
assign sa13_sr_round4 = sa10_sub_round4;		//

assign sa20_sr_round4 = sa22_sub_round4;		//
assign sa21_sr_round4 = sa23_sub_round4;		//	left shift by 2
assign sa22_sr_round4 = sa20_sub_round4;		//
assign sa23_sr_round4 = sa21_sub_round4;		//

assign sa30_sr_round4 = sa33_sub_round4;		//
assign sa31_sr_round4 = sa30_sub_round4;		// left shift by 3
assign sa32_sr_round4 = sa31_sub_round4;		//
assign sa33_sr_round4 = sa32_sub_round4;		//

// mix column operation
assign {sa00_mc_round4, sa10_mc_round4, sa20_mc_round4, sa30_mc_round4}  = mix_col(sa00_sr_round4,sa10_sr_round4,sa20_sr_round4,sa30_sr_round4);
assign {sa01_mc_round4, sa11_mc_round4, sa21_mc_round4, sa31_mc_round4}  = mix_col(sa01_sr_round4,sa11_sr_round4,sa21_sr_round4,sa31_sr_round4);
assign {sa02_mc_round4, sa12_mc_round4, sa22_mc_round4, sa32_mc_round4}  = mix_col(sa02_sr_round4,sa12_sr_round4,sa22_sr_round4,sa32_sr_round4);
assign {sa03_mc_round4, sa13_mc_round4, sa23_mc_round4, sa33_mc_round4}  = mix_col(sa03_sr_round4,sa13_sr_round4,sa23_sr_round4,sa33_sr_round4);


//add round key
assign sa33_next_round5 = 		   sa33_mc_round4 ^ w19[07:00];
assign sa23_next_round5 =     	sa23_mc_round4 ^ w19[15:08];
assign sa13_next_round5 =     	sa13_mc_round4 ^ w19[23:16];
assign sa03_next_round5 =     	sa03_mc_round4 ^ w19[31:24];
assign sa32_next_round5 =     	sa32_mc_round4 ^ w18[07:00];
assign sa22_next_round5 =     	sa22_mc_round4 ^ w18[15:08];
assign sa12_next_round5 =     	sa12_mc_round4 ^ w18[23:16];
assign sa02_next_round5 =     	sa02_mc_round4 ^ w18[31:24];
assign sa31_next_round5 =     	sa31_mc_round4 ^ w17[07:00];
assign sa21_next_round5 =     	sa21_mc_round4 ^ w17[15:08];
assign sa11_next_round5 =     	sa11_mc_round4 ^ w17[23:16];
assign sa01_next_round5 =     	sa01_mc_round4 ^ w17[31:24];
assign sa30_next_round5 =     	sa30_mc_round4 ^ w16[07:00];
assign sa20_next_round5 =     	sa20_mc_round4 ^ w16[15:08];
assign sa10_next_round5 =     	sa10_mc_round4 ^ w16[23:16];
assign sa00_next_round5 =     	sa00_mc_round4 ^ w16[31:24];


/////////////////////////round #5 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round5(	.a(	sa00_next_round5	), .d(	sa00_sub_round5	));
aes_sbox us01_round5(	.a(	sa01_next_round5	), .d(	sa01_sub_round5	));
aes_sbox us02_round5(	.a(	sa02_next_round5	), .d(	sa02_sub_round5	));
aes_sbox us03_round5(	.a(	sa03_next_round5	), .d(	sa03_sub_round5	));
aes_sbox us10_round5(	.a(	sa10_next_round5	), .d(	sa10_sub_round5	));
aes_sbox us11_round5(	.a(	sa11_next_round5	), .d(	sa11_sub_round5	));
aes_sbox us12_round5(	.a(	sa12_next_round5	), .d(	sa12_sub_round5	));
aes_sbox us13_round5(	.a(	sa13_next_round5	), .d(	sa13_sub_round5	));
aes_sbox us20_round5(	.a(	sa20_next_round5	), .d(	sa20_sub_round5	));
aes_sbox us21_round5(	.a(	sa21_next_round5	), .d(	sa21_sub_round5	));
aes_sbox us22_round5(	.a(	sa22_next_round5	), .d(	sa22_sub_round5	));
aes_sbox us23_round5(	.a(	sa23_next_round5	), .d(	sa23_sub_round5	));
aes_sbox us30_round5(	.a(	sa30_next_round5	), .d(	sa30_sub_round5	));
aes_sbox us31_round5(	.a(	sa31_next_round5	), .d(	sa31_sub_round5	));
aes_sbox us32_round5(	.a(	sa32_next_round5	), .d(	sa32_sub_round5	));
aes_sbox us33_round5(	.a(	sa33_next_round5	), .d(	sa33_sub_round5	));

//shift rows

assign sa00_sr_round5 = sa00_sub_round5;		//
assign sa01_sr_round5 = sa01_sub_round5;		//no shift
assign sa02_sr_round5 = sa02_sub_round5;		//
assign sa03_sr_round5 = sa03_sub_round5;		//

assign sa10_sr_round5 = sa11_sub_round5;		//
assign sa11_sr_round5 = sa12_sub_round5;		// left shift by 1
assign sa12_sr_round5 = sa13_sub_round5;		//
assign sa13_sr_round5 = sa10_sub_round5;		//

assign sa20_sr_round5 = sa22_sub_round5;		//
assign sa21_sr_round5 = sa23_sub_round5;		//	left shift by 2
assign sa22_sr_round5 = sa20_sub_round5;		//
assign sa23_sr_round5 = sa21_sub_round5;		//

assign sa30_sr_round5 = sa33_sub_round5;		//
assign sa31_sr_round5 = sa30_sub_round5;		// left shift by 3
assign sa32_sr_round5 = sa31_sub_round5;		//
assign sa33_sr_round5 = sa32_sub_round5;		//

// mix column operation
assign {sa00_mc_round5, sa10_mc_round5, sa20_mc_round5, sa30_mc_round5}  = mix_col(sa00_sr_round5,sa10_sr_round5,sa20_sr_round5,sa30_sr_round5);
assign {sa01_mc_round5, sa11_mc_round5, sa21_mc_round5, sa31_mc_round5}  = mix_col(sa01_sr_round5,sa11_sr_round5,sa21_sr_round5,sa31_sr_round5);
assign {sa02_mc_round5, sa12_mc_round5, sa22_mc_round5, sa32_mc_round5}  = mix_col(sa02_sr_round5,sa12_sr_round5,sa22_sr_round5,sa32_sr_round5);
assign {sa03_mc_round5, sa13_mc_round5, sa23_mc_round5, sa33_mc_round5}  = mix_col(sa03_sr_round5,sa13_sr_round5,sa23_sr_round5,sa33_sr_round5);


//add round key
assign sa33_next_round6 = 		   sa33_mc_round5 ^ w23[07:00];
assign sa23_next_round6 =     	sa23_mc_round5 ^ w23[15:08];
assign sa13_next_round6 =     	sa13_mc_round5 ^ w23[23:16];
assign sa03_next_round6 =     	sa03_mc_round5 ^ w23[31:24];
assign sa32_next_round6 =     	sa32_mc_round5 ^ w22[07:00];
assign sa22_next_round6 =     	sa22_mc_round5 ^ w22[15:08];
assign sa12_next_round6 =     	sa12_mc_round5 ^ w22[23:16];
assign sa02_next_round6 =     	sa02_mc_round5 ^ w22[31:24];
assign sa31_next_round6 =     	sa31_mc_round5 ^ w21[07:00];
assign sa21_next_round6 =     	sa21_mc_round5 ^ w21[15:08];
assign sa11_next_round6 =     	sa11_mc_round5 ^ w21[23:16];
assign sa01_next_round6 =     	sa01_mc_round5 ^ w21[31:24];
assign sa30_next_round6 =     	sa30_mc_round5 ^ w20[07:00];
assign sa20_next_round6 =     	sa20_mc_round5 ^ w20[15:08];
assign sa10_next_round6 =     	sa10_mc_round5 ^ w20[23:16];
assign sa00_next_round6 =     	sa00_mc_round5 ^ w20[31:24];


/////////////////////////round #6 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round6(	.a(	sa00_next_round6	), .d(	sa00_sub_round6	));
aes_sbox us01_round6(	.a(	sa01_next_round6	), .d(	sa01_sub_round6	));
aes_sbox us02_round6(	.a(	sa02_next_round6	), .d(	sa02_sub_round6	));
aes_sbox us03_round6(	.a(	sa03_next_round6	), .d(	sa03_sub_round6	));
aes_sbox us10_round6(	.a(	sa10_next_round6	), .d(	sa10_sub_round6	));
aes_sbox us11_round6(	.a(	sa11_next_round6	), .d(	sa11_sub_round6	));
aes_sbox us12_round6(	.a(	sa12_next_round6	), .d(	sa12_sub_round6	));
aes_sbox us13_round6(	.a(	sa13_next_round6	), .d(	sa13_sub_round6	));
aes_sbox us20_round6(	.a(	sa20_next_round6	), .d(	sa20_sub_round6	));
aes_sbox us21_round6(	.a(	sa21_next_round6	), .d(	sa21_sub_round6	));
aes_sbox us22_round6(	.a(	sa22_next_round6	), .d(	sa22_sub_round6	));
aes_sbox us23_round6(	.a(	sa23_next_round6	), .d(	sa23_sub_round6	));
aes_sbox us30_round6(	.a(	sa30_next_round6	), .d(	sa30_sub_round6	));
aes_sbox us31_round6(	.a(	sa31_next_round6	), .d(	sa31_sub_round6	));
aes_sbox us32_round6(	.a(	sa32_next_round6	), .d(	sa32_sub_round6	));
aes_sbox us33_round6(	.a(	sa33_next_round6	), .d(	sa33_sub_round6	));

//shift rows

assign sa00_sr_round6 = sa00_sub_round6;		//
assign sa01_sr_round6 = sa01_sub_round6;		//no shift
assign sa02_sr_round6 = sa02_sub_round6;		//
assign sa03_sr_round6 = sa03_sub_round6;		//

assign sa10_sr_round6 = sa11_sub_round6;		//
assign sa11_sr_round6 = sa12_sub_round6;		// left shift by 1
assign sa12_sr_round6 = sa13_sub_round6;		//
assign sa13_sr_round6 = sa10_sub_round6;		//

assign sa20_sr_round6 = sa22_sub_round6;		//
assign sa21_sr_round6 = sa23_sub_round6;		//	left shift by 2
assign sa22_sr_round6 = sa20_sub_round6;		//
assign sa23_sr_round6 = sa21_sub_round6;		//

assign sa30_sr_round6 = sa33_sub_round6;		//
assign sa31_sr_round6 = sa30_sub_round6;		// left shift by 3
assign sa32_sr_round6 = sa31_sub_round6;		//
assign sa33_sr_round6 = sa32_sub_round6;		//

// mix column operation
assign {sa00_mc_round6, sa10_mc_round6, sa20_mc_round6, sa30_mc_round6}  = mix_col(sa00_sr_round6,sa10_sr_round6,sa20_sr_round6,sa30_sr_round6);
assign {sa01_mc_round6, sa11_mc_round6, sa21_mc_round6, sa31_mc_round6}  = mix_col(sa01_sr_round6,sa11_sr_round6,sa21_sr_round6,sa31_sr_round6);
assign {sa02_mc_round6, sa12_mc_round6, sa22_mc_round6, sa32_mc_round6}  = mix_col(sa02_sr_round6,sa12_sr_round6,sa22_sr_round6,sa32_sr_round6);
assign {sa03_mc_round6, sa13_mc_round6, sa23_mc_round6, sa33_mc_round6}  = mix_col(sa03_sr_round6,sa13_sr_round6,sa23_sr_round6,sa33_sr_round6);


//add round key
assign sa33_next_round7 = 		   sa33_mc_round6 ^ w27[07:00];
assign sa23_next_round7 =     	sa23_mc_round6 ^ w27[15:08];
assign sa13_next_round7 =     	sa13_mc_round6 ^ w27[23:16];
assign sa03_next_round7 =     	sa03_mc_round6 ^ w27[31:24];
assign sa32_next_round7 =     	sa32_mc_round6 ^ w26[07:00];
assign sa22_next_round7 =     	sa22_mc_round6 ^ w26[15:08];
assign sa12_next_round7 =     	sa12_mc_round6 ^ w26[23:16];
assign sa02_next_round7 =     	sa02_mc_round6 ^ w26[31:24];
assign sa31_next_round7 =     	sa31_mc_round6 ^ w25[07:00];
assign sa21_next_round7 =     	sa21_mc_round6 ^ w25[15:08];
assign sa11_next_round7 =     	sa11_mc_round6 ^ w25[23:16];
assign sa01_next_round7 =     	sa01_mc_round6 ^ w25[31:24];
assign sa30_next_round7 =     	sa30_mc_round6 ^ w24[07:00];
assign sa20_next_round7 =     	sa20_mc_round6 ^ w24[15:08];
assign sa10_next_round7 =     	sa10_mc_round6 ^ w24[23:16];
assign sa00_next_round7 =     	sa00_mc_round6 ^ w24[31:24];


/////////////////////////round #7 transformations/////////////////////////////


//sbox lookup
aes_sbox us00_round7(	.a(	sa00_next_round7	), .d(	sa00_sub_round7	));
aes_sbox us01_round7(	.a(	sa01_next_round7	), .d(	sa01_sub_round7	));
aes_sbox us02_round7(	.a(	sa02_next_round7	), .d(	sa02_sub_round7	));
aes_sbox us03_round7(	.a(	sa03_next_round7	), .d(	sa03_sub_round7	));
aes_sbox us10_round7(	.a(	sa10_next_round7	), .d(	sa10_sub_round7	));
aes_sbox us11_round7(	.a(	sa11_next_round7	), .d(	sa11_sub_round7	));
aes_sbox us12_round7(	.a(	sa12_next_round7	), .d(	sa12_sub_round7	));
aes_sbox us13_round7(	.a(	sa13_next_round7	), .d(	sa13_sub_round7	));
aes_sbox us20_round7(	.a(	sa20_next_round7	), .d(	sa20_sub_round7	));
aes_sbox us21_round7(	.a(	sa21_next_round7	), .d(	sa21_sub_round7	));
aes_sbox us22_round7(	.a(	sa22_next_round7	), .d(	sa22_sub_round7	));
aes_sbox us23_round7(	.a(	sa23_next_round7	), .d(	sa23_sub_round7	));
aes_sbox us30_round7(	.a(	sa30_next_round7	), .d(	sa30_sub_round7	));
aes_sbox us31_round7(	.a(	sa31_next_round7	), .d(	sa31_sub_round7	));
aes_sbox us32_round7(	.a(	sa32_next_round7	), .d(	sa32_sub_round7	));
aes_sbox us33_round7(	.a(	sa33_next_round7	), .d(	sa33_sub_round7	));

//shift rows

assign sa00_sr_round7 = sa00_sub_round7;		//
assign sa01_sr_round7 = sa01_sub_round7;		//no shift
assign sa02_sr_round7 = sa02_sub_round7;		//
assign sa03_sr_round7 = sa03_sub_round7;		//

assign sa10_sr_round7 = sa11_sub_round7;		//
assign sa11_sr_round7 = sa12_sub_round7;		// left shift by 1
assign sa12_sr_round7 = sa13_sub_round7;		//
assign sa13_sr_round7 = sa10_sub_round7;		//

assign sa20_sr_round7 = sa22_sub_round7;		//
assign sa21_sr_round7 = sa23_sub_round7;		//	left shift by 2
assign sa22_sr_round7 = sa20_sub_round7;		//
assign sa23_sr_round7 = sa21_sub_round7;		//

assign sa30_sr_round7 = sa33_sub_round7;		//
assign sa31_sr_round7 = sa30_sub_round7;		// left shift by 3
assign sa32_sr_round7 = sa31_sub_round7;		//
assign sa33_sr_round7 = sa32_sub_round7;		//

// mix column operation
assign {sa00_mc_round7, sa10_mc_round7, sa20_mc_round7, sa30_mc_round7}  = mix_col(sa00_sr_round7,sa10_sr_round7,sa20_sr_round7,sa30_sr_round7);
assign {sa01_mc_round7, sa11_mc_round7, sa21_mc_round7, sa31_mc_round7}  = mix_col(sa01_sr_round7,sa11_sr_round7,sa21_sr_round7,sa31_sr_round7);
assign {sa02_mc_round7, sa12_mc_round7, sa22_mc_round7, sa32_mc_round7}  = mix_col(sa02_sr_round7,sa12_sr_round7,sa22_sr_round7,sa32_sr_round7);
assign {sa03_mc_round7, sa13_mc_round7, sa23_mc_round7, sa33_mc_round7}  = mix_col(sa03_sr_round7,sa13_sr_round7,sa23_sr_round7,sa33_sr_round7);


//add round key
assign sa33_next_round8 = 		   sa33_mc_round7 ^ w31[07:00];
assign sa23_next_round8 =     	sa23_mc_round7 ^ w31[15:08];
assign sa13_next_round8 =     	sa13_mc_round7 ^ w31[23:16];
assign sa03_next_round8 =     	sa03_mc_round7 ^ w31[31:24];
assign sa32_next_round8 =     	sa32_mc_round7 ^ w30[07:00];
assign sa22_next_round8 =     	sa22_mc_round7 ^ w30[15:08];
assign sa12_next_round8 =     	sa12_mc_round7 ^ w30[23:16];
assign sa02_next_round8 =     	sa02_mc_round7 ^ w30[31:24];
assign sa31_next_round8 =     	sa31_mc_round7 ^ w29[07:00];
assign sa21_next_round8 =     	sa21_mc_round7 ^ w29[15:08];
assign sa11_next_round8 =     	sa11_mc_round7 ^ w29[23:16];
assign sa01_next_round8 =     	sa01_mc_round7 ^ w29[31:24];
assign sa30_next_round8 =     	sa30_mc_round7 ^ w28[07:00];
assign sa20_next_round8 =     	sa20_mc_round7 ^ w28[15:08];
assign sa10_next_round8 =     	sa10_mc_round7 ^ w28[23:16];
assign sa00_next_round8 =     	sa00_mc_round7 ^ w28[31:24];

/////////////////////////round #8 transformations/////////////////////////////

	
//sbox lookup
aes_sbox us00_round8(	.a(	sa00_next_round8	), .d(	sa00_sub_round8	));
aes_sbox us01_round8(	.a(	sa01_next_round8	), .d(	sa01_sub_round8	));
aes_sbox us02_round8(	.a(	sa02_next_round8	), .d(	sa02_sub_round8	));
aes_sbox us03_round8(	.a(	sa03_next_round8	), .d(	sa03_sub_round8	));
aes_sbox us10_round8(	.a(	sa10_next_round8	), .d(	sa10_sub_round8	));
aes_sbox us11_round8(	.a(	sa11_next_round8	), .d(	sa11_sub_round8	));
aes_sbox us12_round8(	.a(	sa12_next_round8	), .d(	sa12_sub_round8	));
aes_sbox us13_round8(	.a(	sa13_next_round8	), .d(	sa13_sub_round8	));
aes_sbox us20_round8(	.a(	sa20_next_round8	), .d(	sa20_sub_round8	));
aes_sbox us21_round8(	.a(	sa21_next_round8	), .d(	sa21_sub_round8	));
aes_sbox us22_round8(	.a(	sa22_next_round8	), .d(	sa22_sub_round8	));
aes_sbox us23_round8(	.a(	sa23_next_round8	), .d(	sa23_sub_round8	));
aes_sbox us30_round8(	.a(	sa30_next_round8	), .d(	sa30_sub_round8	));
aes_sbox us31_round8(	.a(	sa31_next_round8	), .d(	sa31_sub_round8	));
aes_sbox us32_round8(	.a(	sa32_next_round8	), .d(	sa32_sub_round8	));
aes_sbox us33_round8(	.a(	sa33_next_round8	), .d(	sa33_sub_round8	));

//shift rows

assign sa00_sr_round8 = sa00_sub_round8;		//
assign sa01_sr_round8 = sa01_sub_round8;		//no shift
assign sa02_sr_round8 = sa02_sub_round8;		//
assign sa03_sr_round8 = sa03_sub_round8;		//

assign sa10_sr_round8 = sa11_sub_round8;		//
assign sa11_sr_round8 = sa12_sub_round8;		// left shift by 1
assign sa12_sr_round8 = sa13_sub_round8;		//
assign sa13_sr_round8 = sa10_sub_round8;		//

assign sa20_sr_round8 = sa22_sub_round8;		//
assign sa21_sr_round8 = sa23_sub_round8;		//	left shift by 2
assign sa22_sr_round8 = sa20_sub_round8;		//
assign sa23_sr_round8 = sa21_sub_round8;		//

assign sa30_sr_round8 = sa33_sub_round8;		//
assign sa31_sr_round8 = sa30_sub_round8;		// left shift by 3
assign sa32_sr_round8 = sa31_sub_round8;		//
assign sa33_sr_round8 = sa32_sub_round8;		//

// mix column operation
assign {sa00_mc_round8, sa10_mc_round8, sa20_mc_round8, sa30_mc_round8}  = mix_col(sa00_sr_round8,sa10_sr_round8,sa20_sr_round8,sa30_sr_round8);
assign {sa01_mc_round8, sa11_mc_round8, sa21_mc_round8, sa31_mc_round8}  = mix_col(sa01_sr_round8,sa11_sr_round8,sa21_sr_round8,sa31_sr_round8);
assign {sa02_mc_round8, sa12_mc_round8, sa22_mc_round8, sa32_mc_round8}  = mix_col(sa02_sr_round8,sa12_sr_round8,sa22_sr_round8,sa32_sr_round8);
assign {sa03_mc_round8, sa13_mc_round8, sa23_mc_round8, sa33_mc_round8}  = mix_col(sa03_sr_round8,sa13_sr_round8,sa23_sr_round8,sa33_sr_round8);


//add round key
assign sa33_next_round9 = 		   sa33_mc_round8 ^ w35[07:00];
assign sa23_next_round9 =     	sa23_mc_round8 ^ w35[15:08];
assign sa13_next_round9 =     	sa13_mc_round8 ^ w35[23:16];
assign sa03_next_round9 =     	sa03_mc_round8 ^ w35[31:24];
assign sa32_next_round9 =     	sa32_mc_round8 ^ w34[07:00];
assign sa22_next_round9 =     	sa22_mc_round8 ^ w34[15:08];
assign sa12_next_round9 =     	sa12_mc_round8 ^ w34[23:16];
assign sa02_next_round9 =     	sa02_mc_round8 ^ w34[31:24];
assign sa31_next_round9 =     	sa31_mc_round8 ^ w33[07:00];
assign sa21_next_round9 =     	sa21_mc_round8 ^ w33[15:08];
assign sa11_next_round9 =     	sa11_mc_round8 ^ w33[23:16];
assign sa01_next_round9 =     	sa01_mc_round8 ^ w33[31:24];
assign sa30_next_round9 =     	sa30_mc_round8 ^ w32[07:00];
assign sa20_next_round9 =     	sa20_mc_round8 ^ w32[15:08];
assign sa10_next_round9 =     	sa10_mc_round8 ^ w32[23:16];
assign sa00_next_round9 =     	sa00_mc_round8 ^ w32[31:24];



/////////////////////////round #9 transformations/////////////////////////////

	
//sbox lookup
aes_sbox us00_round9(	.a(	sa00_next_round9	), .d(	sa00_sub_round9	));
aes_sbox us01_round9(	.a(	sa01_next_round9	), .d(	sa01_sub_round9	));
aes_sbox us02_round9(	.a(	sa02_next_round9	), .d(	sa02_sub_round9	));
aes_sbox us03_round9(	.a(	sa03_next_round9	), .d(	sa03_sub_round9	));
aes_sbox us10_round9(	.a(	sa10_next_round9	), .d(	sa10_sub_round9	));
aes_sbox us11_round9(	.a(	sa11_next_round9	), .d(	sa11_sub_round9	));
aes_sbox us12_round9(	.a(	sa12_next_round9	), .d(	sa12_sub_round9	));
aes_sbox us13_round9(	.a(	sa13_next_round9	), .d(	sa13_sub_round9	));
aes_sbox us20_round9(	.a(	sa20_next_round9	), .d(	sa20_sub_round9	));
aes_sbox us21_round9(	.a(	sa21_next_round9	), .d(	sa21_sub_round9	));
aes_sbox us22_round9(	.a(	sa22_next_round9	), .d(	sa22_sub_round9	));
aes_sbox us23_round9(	.a(	sa23_next_round9	), .d(	sa23_sub_round9	));
aes_sbox us30_round9(	.a(	sa30_next_round9	), .d(	sa30_sub_round9	));
aes_sbox us31_round9(	.a(	sa31_next_round9	), .d(	sa31_sub_round9	));
aes_sbox us32_round9(	.a(	sa32_next_round9	), .d(	sa32_sub_round9	));
aes_sbox us33_round9(	.a(	sa33_next_round9	), .d(	sa33_sub_round9	));

//shift rows

assign sa00_sr_round9 = sa00_sub_round9;		//
assign sa01_sr_round9 = sa01_sub_round9;		//no shift
assign sa02_sr_round9 = sa02_sub_round9;		//
assign sa03_sr_round9 = sa03_sub_round9;		//

assign sa10_sr_round9 = sa11_sub_round9;		//
assign sa11_sr_round9 = sa12_sub_round9;		// left shift by 1
assign sa12_sr_round9 = sa13_sub_round9;		//
assign sa13_sr_round9 = sa10_sub_round9;		//

assign sa20_sr_round9 = sa22_sub_round9;		//
assign sa21_sr_round9 = sa23_sub_round9;		//	left shift by 2
assign sa22_sr_round9 = sa20_sub_round9;		//
assign sa23_sr_round9 = sa21_sub_round9;		//

assign sa30_sr_round9 = sa33_sub_round9;		//
assign sa31_sr_round9 = sa30_sub_round9;		// left shift by 3
assign sa32_sr_round9 = sa31_sub_round9;		//
assign sa33_sr_round9 = sa32_sub_round9;		//

// mix column operation
assign {sa00_mc_round9, sa10_mc_round9, sa20_mc_round9, sa30_mc_round9}  = mix_col(sa00_sr_round9,sa10_sr_round9,sa20_sr_round9,sa30_sr_round9);
assign {sa01_mc_round9, sa11_mc_round9, sa21_mc_round9, sa31_mc_round9}  = mix_col(sa01_sr_round9,sa11_sr_round9,sa21_sr_round9,sa31_sr_round9);
assign {sa02_mc_round9, sa12_mc_round9, sa22_mc_round9, sa32_mc_round9}  = mix_col(sa02_sr_round9,sa12_sr_round9,sa22_sr_round9,sa32_sr_round9);
assign {sa03_mc_round9, sa13_mc_round9, sa23_mc_round9, sa33_mc_round9}  = mix_col(sa03_sr_round9,sa13_sr_round9,sa23_sr_round9,sa33_sr_round9);


//add round key
assign sa33_next_round10 = 		sa33_mc_round9 ^ w39[07:00];
assign sa23_next_round10 =     	sa23_mc_round9 ^ w39[15:08];
assign sa13_next_round10 =     	sa13_mc_round9 ^ w39[23:16];
assign sa03_next_round10 =     	sa03_mc_round9 ^ w39[31:24];
assign sa32_next_round10 =     	sa32_mc_round9 ^ w38[07:00];
assign sa22_next_round10 =     	sa22_mc_round9 ^ w38[15:08];
assign sa12_next_round10 =     	sa12_mc_round9 ^ w38[23:16];
assign sa02_next_round10 =     	sa02_mc_round9 ^ w38[31:24];
assign sa31_next_round10 =     	sa31_mc_round9 ^ w37[07:00];
assign sa21_next_round10 =     	sa21_mc_round9 ^ w37[15:08];
assign sa11_next_round10 =     	sa11_mc_round9 ^ w37[23:16];
assign sa01_next_round10 =     	sa01_mc_round9 ^ w37[31:24];
assign sa30_next_round10 =     	sa30_mc_round9 ^ w36[07:00];
assign sa20_next_round10 =     	sa20_mc_round9 ^ w36[15:08];
assign sa10_next_round10 =     	sa10_mc_round9 ^ w36[23:16];
assign sa00_next_round10 =     	sa00_mc_round9 ^ w36[31:24];


/////////////////////////round # 10 transformations/////////////////////////////

	
//sbox lookup
aes_sbox us00_round10(	.a(	sa00_next_round10	), .d(	sa00_sub_round10	));
aes_sbox us01_round10(	.a(	sa01_next_round10	), .d(	sa01_sub_round10	));
aes_sbox us02_round10(	.a(	sa02_next_round10	), .d(	sa02_sub_round10	));
aes_sbox us03_round10(	.a(	sa03_next_round10	), .d(	sa03_sub_round10	));
aes_sbox us10_round10(	.a(	sa10_next_round10	), .d(	sa10_sub_round10	));
aes_sbox us11_round10(	.a(	sa11_next_round10	), .d(	sa11_sub_round10	));
aes_sbox us12_round10(	.a(	sa12_next_round10	), .d(	sa12_sub_round10	));
aes_sbox us13_round10(	.a(	sa13_next_round10	), .d(	sa13_sub_round10	));
aes_sbox us20_round10(	.a(	sa20_next_round10	), .d(	sa20_sub_round10	));
aes_sbox us21_round10(	.a(	sa21_next_round10	), .d(	sa21_sub_round10	));
aes_sbox us22_round10(	.a(	sa22_next_round10	), .d(	sa22_sub_round10	));
aes_sbox us23_round10(	.a(	sa23_next_round10	), .d(	sa23_sub_round10	));
aes_sbox us30_round10(	.a(	sa30_next_round10	), .d(	sa30_sub_round10	));
aes_sbox us31_round10(	.a(	sa31_next_round10	), .d(	sa31_sub_round10	));
aes_sbox us32_round10(	.a(	sa32_next_round10	), .d(	sa32_sub_round10	));
aes_sbox us33_round10(	.a(	sa33_next_round10	), .d(	sa33_sub_round10	));

//shift rows

assign sa00_sr_round10 = sa00_sub_round10;		//
assign sa01_sr_round10 = sa01_sub_round10;		//no shift
assign sa02_sr_round10 = sa02_sub_round10;		//
assign sa03_sr_round10 = sa03_sub_round10;		//

assign sa10_sr_round10 = sa11_sub_round10;		//
assign sa11_sr_round10 = sa12_sub_round10;		// left shift by 1
assign sa12_sr_round10 = sa13_sub_round10;		//
assign sa13_sr_round10 = sa10_sub_round10;		//

assign sa20_sr_round10 = sa22_sub_round10;		//
assign sa21_sr_round10 = sa23_sub_round10;		//	left shift by 2
assign sa22_sr_round10 = sa20_sub_round10;		//
assign sa23_sr_round10 = sa21_sub_round10;		//

assign sa30_sr_round10 = sa33_sub_round10;		//
assign sa31_sr_round10 = sa30_sub_round10;		// left shift by 3
assign sa32_sr_round10 = sa31_sub_round10;		//
assign sa33_sr_round10 = sa32_sub_round10;		//


// Final text output


always @(posedge clk)
 begin 
		/*  $strobe($time,": round_key2 is %h\n",{w4,w5,w6,w7});
		  $strobe($time,": roundkeyeven = %h, text_out_even is %h\n",{w4,w5,w6,w7},text_out);*/
		  text_out[127:120] <=  sa00_sr_round10 ^ w40[31:24];	 
		  text_out[095:088] <=  sa01_sr_round10 ^ w41[31:24];	 
		  text_out[063:056] <=  sa02_sr_round10 ^ w42[31:24];	 
		  text_out[031:024] <=  sa03_sr_round10 ^ w43[31:24];	 
		  text_out[119:112] <=  sa10_sr_round10 ^ w40[23:16];	 
		  text_out[087:080] <=  sa11_sr_round10 ^ w41[23:16];	 
		  text_out[055:048] <=  sa12_sr_round10 ^ w42[23:16];	 
		  text_out[023:016] <=  sa13_sr_round10 ^ w43[23:16];	 
		  text_out[111:104] <=  sa20_sr_round10 ^ w40[15:08];	 
		  text_out[079:072] <=  sa21_sr_round10 ^ w41[15:08];	 
		  text_out[047:040] <=  sa22_sr_round10 ^ w42[15:08];	 
		  text_out[015:008] <=  sa23_sr_round10 ^ w43[15:08];	 
		  text_out[103:096] <=  sa30_sr_round10 ^ w40[07:00];	 
		  text_out[071:064] <=  sa31_sr_round10 ^ w41[07:00];	 
		  text_out[039:032] <=  sa32_sr_round10 ^ w42[07:00];	 
		  text_out[007:000] <=  sa33_sr_round10 ^ w43[07:00];
	end


////////////////////////////////////////////////////////////////////
//
// Generic Functions
//

function [31:0] mix_col;
input	[7:0]	s0,s1,s2,s3;
//reg	[7:0]	s0_o,s1_o,s2_o,s3_o;
begin
mix_col[31:24]=xtime(s0)^xtime(s1)^s1^s2^s3;
mix_col[23:16]=s0^xtime(s1)^xtime(s2)^s2^s3;
mix_col[15:08]=s0^s1^xtime(s2)^xtime(s3)^s3;
mix_col[07:00]=xtime(s0)^s0^s1^s2^xtime(s3);
end
endfunction

function [7:0] xtime;
input [7:0] b; xtime={b[6:0],1'b0}^(8'h1b&{8{b[7]}});
endfunction



endmodule




// -----------------------------------------------------------------------------
// Source file: aes_1cycle_1stage/aes_key_expand_128.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Key Expand Block (for 128 bit keys)                    ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
//// Modified to achieve 1 cycle functionality 			     ////
//// By Tariq Bashir Ahmad					     //// 	
////  tariq.bashir@gmail.com					     ////
////  http://www.ecs.umass.edu/~tbashir				     ////	


`timescale 1 ns/1 ps

module aes_key_expand_128(clk, key, w0,w1,w2,w3,w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17,
													  w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33,
													  w34, w35, w36, w37, w38, w39, w40, w41, w42, w43);
input		clk;
input	[127:0]	key;
output reg	[31:0]	w0,w1,w2,w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16, w17,
							w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29, w30, w31, w32, w33,
							w34, w35, w36, w37, w38, w39, w40, w41, w42, w43;
wire	[31:0]	subword, subword2,subword3,subword4,subword5, subword6, subword7,subword8,subword9,subword10;
wire	[7:0]	rcon, rcon2,rcon3,rcon4,rcon5, rcon6, rcon7,rcon8,rcon9,rcon10;			



		
always @*
begin
 
w0 =  key[127:096];
w1 =  key[095:064];
w2 =  key[063:032];
w3 =  key[031:000];

w4 =  key[127:096]^subword^{8'h01,24'b0};
w5 =  key[095:064]^key[127:096]^subword^{8'h01,24'b0};
w6 =  key[063:032]^key[095:064]^key[127:096]^subword^{8'h01,24'b0}; 
w7 =  key[127:096]^key[095:064]^key[063:032]^key[031:000]^subword^{8'h01,24'b0};

w8  =  w4^subword2^{rcon2,24'b0};
w9  =  w5^w4^subword2^{rcon2,24'b0};
w10 =  w6^w5^w4^subword2^{rcon2,24'b0}; 
w11 =  w7^w6^w5^w4^subword2^{rcon2,24'b0};


w12  =  w8^subword3^{rcon3,24'b0};
w13  =  w8^w9^subword3^{rcon3,24'b0};
w14  =  w8^w9^w10^subword3^{rcon3,24'b0}; 
w15  =  w8^w9^w10^w11^subword3^{rcon3,24'b0};


w16  =  w12^subword4^{rcon4,24'b0};
w17  =  w12^w13^subword4^{rcon4,24'b0};
w18  =  w12^w13^w14^subword4^{rcon4,24'b0}; 
w19  =  w12^w13^w14^w15^subword4^{rcon4,24'b0};


w20  =  w16^subword5^{rcon5,24'b0};
w21  =  w16^w17^subword5^{rcon5,24'b0};
w22  =  w16^w17^w18^subword5^{rcon5,24'b0}; 
w23  =  w16^w17^w18^w19^subword5^{rcon5,24'b0};


w24  =  w20^subword6^{rcon6,24'b0};
w25  =  w20^w21^subword6^{rcon6,24'b0};
w26  =  w20^w21^w22^subword6^{rcon6,24'b0}; 
w27  =  w20^w21^w22^w23^subword6^{rcon6,24'b0};

w28  =  w24^subword7^{rcon7,24'b0};
w29  =  w24^w25^subword7^{rcon7,24'b0};
w30  =  w24^w25^w26^subword7^{rcon7,24'b0}; 
w31  =  w24^w25^w26^w27^subword7^{rcon7,24'b0};


w32  =  w28^subword8^{rcon8,24'b0};
w33  =  w28^w29^subword8^{rcon8,24'b0};
w34  =  w28^w29^w30^subword8^{rcon8,24'b0}; 
w35  =  w28^w29^w30^w31^subword8^{rcon8,24'b0};

w36  =  w32^subword9^{rcon9,24'b0};
w37  =  w32^w33^subword9^{rcon9,24'b0};
w38  =  w32^w33^w34^subword9^{rcon9,24'b0}; 
w39  =  w32^w33^w34^w35^subword9^{rcon9,24'b0};

w40  =  w36^subword10^{rcon10,24'b0};
w41  =  w36^w37^subword10^{rcon10,24'b0};
w42  =  w36^w37^w38^subword10^{rcon10,24'b0}; 
w43  =  w36^w37^w38^w39^subword10^{rcon10,24'b0};

/*$display($time,": subword5 is %h\n",subword2);
$display($time,": rcon5 is %h\n",rcon5);
$display($time,": key5 is %h, key6 is %h\n",{w16,w17,w18,w19},{w20,w21,w22,w23});*/

end

aes_rcon inst5(.clk(clk),            .out(rcon),   .out2(rcon2),
												 .out3(rcon3), .out4(rcon4),
												 .out5(rcon5), .out6(rcon6),
												 .out7(rcon7), .out8(rcon8),
												 .out9(rcon9), .out10(rcon10));

aes_sbox u0(	.a(w3[23:16]), .d(subword[31:24]));
aes_sbox u1(	.a(w3[15:08]), .d(subword[23:16]));
aes_sbox u2(	.a(w3[07:00]), .d(subword[15:08]));
aes_sbox u3(	.a(w3[31:24]), .d(subword[07:00])); 

aes_sbox u4(	.a(w7[23:16]), .d(subword2[31:24]));
aes_sbox u5(	.a(w7[15:08]), .d(subword2[23:16]));
aes_sbox u6(	.a(w7[07:00]), .d(subword2[15:08]));
aes_sbox u7(	.a(w7[31:24]), .d(subword2[07:00])); 


aes_sbox u8(	.a(w11[23:16]), .d(subword3[31:24]));
aes_sbox u9(	.a(w11[15:08]), .d(subword3[23:16]));
aes_sbox u10(	.a(w11[07:00]), .d(subword3[15:08]));
aes_sbox u11(	.a(w11[31:24]), .d(subword3[07:00])); 


aes_sbox u12(	.a(w15[23:16]), .d(subword4[31:24]));
aes_sbox u13(	.a(w15[15:08]), .d(subword4[23:16]));
aes_sbox u14(	.a(w15[07:00]), .d(subword4[15:08]));
aes_sbox u15(	.a(w15[31:24]), .d(subword4[07:00])); 

aes_sbox u16(	.a(w19[23:16]), .d(subword5[31:24]));
aes_sbox u17(	.a(w19[15:08]), .d(subword5[23:16]));
aes_sbox u18(	.a(w19[07:00]), .d(subword5[15:08]));
aes_sbox u19(	.a(w19[31:24]), .d(subword5[07:00])); 

aes_sbox u20(	.a(w23[23:16]), .d(subword6[31:24]));
aes_sbox u21(	.a(w23[15:08]), .d(subword6[23:16]));
aes_sbox u22(	.a(w23[07:00]), .d(subword6[15:08]));
aes_sbox u23(	.a(w23[31:24]), .d(subword6[07:00])); 

aes_sbox u24(	.a(w27[23:16]), .d(subword7[31:24]));
aes_sbox u25(	.a(w27[15:08]), .d(subword7[23:16]));
aes_sbox u26(	.a(w27[07:00]), .d(subword7[15:08]));
aes_sbox u27(	.a(w27[31:24]), .d(subword7[07:00])); 

aes_sbox u28(	.a(w31[23:16]), .d(subword8[31:24]));
aes_sbox u29(	.a(w31[15:08]), .d(subword8[23:16]));
aes_sbox u30(	.a(w31[07:00]), .d(subword8[15:08]));
aes_sbox u31(	.a(w31[31:24]), .d(subword8[07:00])); 

aes_sbox u32(	.a(w35[23:16]), .d(subword9[31:24]));
aes_sbox u33(	.a(w35[15:08]), .d(subword9[23:16]));
aes_sbox u34(	.a(w35[07:00]), .d(subword9[15:08]));
aes_sbox u35(	.a(w35[31:24]), .d(subword9[07:00])); 

aes_sbox u36(	.a(w39[23:16]), .d(subword10[31:24]));
aes_sbox u37(	.a(w39[15:08]), .d(subword10[23:16]));
aes_sbox u38(	.a(w39[07:00]), .d(subword10[15:08]));
aes_sbox u39(	.a(w39[31:24]), .d(subword10[07:00])); 


endmodule


// -----------------------------------------------------------------------------
// Source file: aes_1cycle_1stage/aes_rcon.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES RCON Block                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////



`timescale 1 ns/1 ps

module aes_rcon(clk,out,out2,out3,out4,out5,out6,out7,out8,out9,out10);

input		clk;

output [7:0] out,out2,out3,out4,out5,out6,out7,out8,out9,out10;



assign		out  = frcon(0);
assign		out2 = frcon(1); 
assign		out3 = frcon(2);
assign		out4 = frcon(3);
assign		out5 = frcon(4);
assign		out6 = frcon(5);
assign		out7 = frcon(6); 
assign		out8 = frcon(7);
assign		out9 = frcon(8);
assign		out10 = frcon(9);		 

function [7:0]	frcon;

input	[3:0]	i;

case(i)	// synopsys parallel_case
   4'h0: frcon=8'h01;		//1
   4'h1: frcon=8'h02;		//x
   4'h2: frcon=8'h04;		//x^2
   4'h3: frcon=8'h08;		//x^3
   4'h4: frcon=8'h10;		//x^4
   4'h5: frcon=8'h20;		//x^5
   4'h6: frcon=8'h40;		//x^6
   4'h7: frcon=8'h80;		//x^7
   4'h8: frcon=8'h1b;		//x^8
   4'h9: frcon=8'h36;		//x^9
   default: frcon=8'h00;
endcase

endfunction



endmodule

// -----------------------------------------------------------------------------
// Source file: aes_1cycle_1stage/aes_sbox.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES SBOX (ROM)                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1 ns/1 ps


module aes_sbox(a,d);
input	[7:0]	a;
output	[7:0]	d;
reg	[7:0]	d;

always @(a)
	case(a)		// synopsys full_case parallel_case
	   8'h00: d=8'h63;
	   8'h01: d=8'h7c;
	   8'h02: d=8'h77;
	   8'h03: d=8'h7b;
	   8'h04: d=8'hf2;
	   8'h05: d=8'h6b;
	   8'h06: d=8'h6f;
	   8'h07: d=8'hc5;
	   8'h08: d=8'h30;
	   8'h09: d=8'h01;
	   8'h0a: d=8'h67;
	   8'h0b: d=8'h2b;
	   8'h0c: d=8'hfe;
	   8'h0d: d=8'hd7;
	   8'h0e: d=8'hab;
	   8'h0f: d=8'h76;
	   8'h10: d=8'hca;
	   8'h11: d=8'h82;
	   8'h12: d=8'hc9;
	   8'h13: d=8'h7d;
	   8'h14: d=8'hfa;
	   8'h15: d=8'h59;
	   8'h16: d=8'h47;
	   8'h17: d=8'hf0;
	   8'h18: d=8'had;
	   8'h19: d=8'hd4;
	   8'h1a: d=8'ha2;
	   8'h1b: d=8'haf;
	   8'h1c: d=8'h9c;
	   8'h1d: d=8'ha4;
	   8'h1e: d=8'h72;
	   8'h1f: d=8'hc0;
	   8'h20: d=8'hb7;
	   8'h21: d=8'hfd;
	   8'h22: d=8'h93;
	   8'h23: d=8'h26;
	   8'h24: d=8'h36;
	   8'h25: d=8'h3f;
	   8'h26: d=8'hf7;
	   8'h27: d=8'hcc;
	   8'h28: d=8'h34;
	   8'h29: d=8'ha5;
	   8'h2a: d=8'he5;
	   8'h2b: d=8'hf1;
	   8'h2c: d=8'h71;
	   8'h2d: d=8'hd8;
	   8'h2e: d=8'h31;
	   8'h2f: d=8'h15;
	   8'h30: d=8'h04;
	   8'h31: d=8'hc7;
	   8'h32: d=8'h23;
	   8'h33: d=8'hc3;
	   8'h34: d=8'h18;
	   8'h35: d=8'h96;
	   8'h36: d=8'h05;
	   8'h37: d=8'h9a;
	   8'h38: d=8'h07;
	   8'h39: d=8'h12;
	   8'h3a: d=8'h80;
	   8'h3b: d=8'he2;
	   8'h3c: d=8'heb;
	   8'h3d: d=8'h27;
	   8'h3e: d=8'hb2;
	   8'h3f: d=8'h75;
	   8'h40: d=8'h09;
	   8'h41: d=8'h83;
	   8'h42: d=8'h2c;
	   8'h43: d=8'h1a;
	   8'h44: d=8'h1b;
	   8'h45: d=8'h6e;
	   8'h46: d=8'h5a;
	   8'h47: d=8'ha0;
	   8'h48: d=8'h52;
	   8'h49: d=8'h3b;
	   8'h4a: d=8'hd6;
	   8'h4b: d=8'hb3;
	   8'h4c: d=8'h29;
	   8'h4d: d=8'he3;
	   8'h4e: d=8'h2f;
	   8'h4f: d=8'h84;
	   8'h50: d=8'h53;
	   8'h51: d=8'hd1;
	   8'h52: d=8'h00;
	   8'h53: d=8'hed;
	   8'h54: d=8'h20;
	   8'h55: d=8'hfc;
	   8'h56: d=8'hb1;
	   8'h57: d=8'h5b;
	   8'h58: d=8'h6a;
	   8'h59: d=8'hcb;
	   8'h5a: d=8'hbe;
	   8'h5b: d=8'h39;
	   8'h5c: d=8'h4a;
	   8'h5d: d=8'h4c;
	   8'h5e: d=8'h58;
	   8'h5f: d=8'hcf;
	   8'h60: d=8'hd0;
	   8'h61: d=8'hef;
	   8'h62: d=8'haa;
	   8'h63: d=8'hfb;
	   8'h64: d=8'h43;
	   8'h65: d=8'h4d;
	   8'h66: d=8'h33;
	   8'h67: d=8'h85;
	   8'h68: d=8'h45;
	   8'h69: d=8'hf9;
	   8'h6a: d=8'h02;
	   8'h6b: d=8'h7f;
	   8'h6c: d=8'h50;
	   8'h6d: d=8'h3c;
	   8'h6e: d=8'h9f;
	   8'h6f: d=8'ha8;
	   8'h70: d=8'h51;
	   8'h71: d=8'ha3;
	   8'h72: d=8'h40;
	   8'h73: d=8'h8f;
	   8'h74: d=8'h92;
	   8'h75: d=8'h9d;
	   8'h76: d=8'h38;
	   8'h77: d=8'hf5;
	   8'h78: d=8'hbc;
	   8'h79: d=8'hb6;
	   8'h7a: d=8'hda;
	   8'h7b: d=8'h21;
	   8'h7c: d=8'h10;
	   8'h7d: d=8'hff;
	   8'h7e: d=8'hf3;
	   8'h7f: d=8'hd2;
	   8'h80: d=8'hcd;
	   8'h81: d=8'h0c;
	   8'h82: d=8'h13;
	   8'h83: d=8'hec;
	   8'h84: d=8'h5f;
	   8'h85: d=8'h97;
	   8'h86: d=8'h44;
	   8'h87: d=8'h17;
	   8'h88: d=8'hc4;
	   8'h89: d=8'ha7;
	   8'h8a: d=8'h7e;
	   8'h8b: d=8'h3d;
	   8'h8c: d=8'h64;
	   8'h8d: d=8'h5d;
	   8'h8e: d=8'h19;
	   8'h8f: d=8'h73;
	   8'h90: d=8'h60;
	   8'h91: d=8'h81;
	   8'h92: d=8'h4f;
	   8'h93: d=8'hdc;
	   8'h94: d=8'h22;
	   8'h95: d=8'h2a;
	   8'h96: d=8'h90;
	   8'h97: d=8'h88;
	   8'h98: d=8'h46;
	   8'h99: d=8'hee;
	   8'h9a: d=8'hb8;
	   8'h9b: d=8'h14;
	   8'h9c: d=8'hde;
	   8'h9d: d=8'h5e;
	   8'h9e: d=8'h0b;
	   8'h9f: d=8'hdb;
	   8'ha0: d=8'he0;
	   8'ha1: d=8'h32;
	   8'ha2: d=8'h3a;
	   8'ha3: d=8'h0a;
	   8'ha4: d=8'h49;
	   8'ha5: d=8'h06;
	   8'ha6: d=8'h24;
	   8'ha7: d=8'h5c;
	   8'ha8: d=8'hc2;
	   8'ha9: d=8'hd3;
	   8'haa: d=8'hac;
	   8'hab: d=8'h62;
	   8'hac: d=8'h91;
	   8'had: d=8'h95;
	   8'hae: d=8'he4;
	   8'haf: d=8'h79;
	   8'hb0: d=8'he7;
	   8'hb1: d=8'hc8;
	   8'hb2: d=8'h37;
	   8'hb3: d=8'h6d;
	   8'hb4: d=8'h8d;
	   8'hb5: d=8'hd5;
	   8'hb6: d=8'h4e;
	   8'hb7: d=8'ha9;
	   8'hb8: d=8'h6c;
	   8'hb9: d=8'h56;
	   8'hba: d=8'hf4;
	   8'hbb: d=8'hea;
	   8'hbc: d=8'h65;
	   8'hbd: d=8'h7a;
	   8'hbe: d=8'hae;
	   8'hbf: d=8'h08;
	   8'hc0: d=8'hba;
	   8'hc1: d=8'h78;
	   8'hc2: d=8'h25;
	   8'hc3: d=8'h2e;
	   8'hc4: d=8'h1c;
	   8'hc5: d=8'ha6;
	   8'hc6: d=8'hb4;
	   8'hc7: d=8'hc6;
	   8'hc8: d=8'he8;
	   8'hc9: d=8'hdd;
	   8'hca: d=8'h74;
	   8'hcb: d=8'h1f;
	   8'hcc: d=8'h4b;
	   8'hcd: d=8'hbd;
	   8'hce: d=8'h8b;
	   8'hcf: d=8'h8a;
	   8'hd0: d=8'h70;
	   8'hd1: d=8'h3e;
	   8'hd2: d=8'hb5;
	   8'hd3: d=8'h66;
	   8'hd4: d=8'h48;
	   8'hd5: d=8'h03;
	   8'hd6: d=8'hf6;
	   8'hd7: d=8'h0e;
	   8'hd8: d=8'h61;
	   8'hd9: d=8'h35;
	   8'hda: d=8'h57;
	   8'hdb: d=8'hb9;
	   8'hdc: d=8'h86;
	   8'hdd: d=8'hc1;
	   8'hde: d=8'h1d;
	   8'hdf: d=8'h9e;
	   8'he0: d=8'he1;
	   8'he1: d=8'hf8;
	   8'he2: d=8'h98;
	   8'he3: d=8'h11;
	   8'he4: d=8'h69;
	   8'he5: d=8'hd9;
	   8'he6: d=8'h8e;
	   8'he7: d=8'h94;
	   8'he8: d=8'h9b;
	   8'he9: d=8'h1e;
	   8'hea: d=8'h87;
	   8'heb: d=8'he9;
	   8'hec: d=8'hce;
	   8'hed: d=8'h55;
	   8'hee: d=8'h28;
	   8'hef: d=8'hdf;
	   8'hf0: d=8'h8c;
	   8'hf1: d=8'ha1;
	   8'hf2: d=8'h89;
	   8'hf3: d=8'h0d;
	   8'hf4: d=8'hbf;
	   8'hf5: d=8'he6;
	   8'hf6: d=8'h42;
	   8'hf7: d=8'h68;
	   8'hf8: d=8'h41;
	   8'hf9: d=8'h99;
	   8'hfa: d=8'h2d;
	   8'hfb: d=8'h0f;
	   8'hfc: d=8'hb0;
	   8'hfd: d=8'h54;
	   8'hfe: d=8'hbb;
	   8'hff: d=8'h16;
	endcase

endmodule



// -----------------------------------------------------------------------------
// Source file: aes_5cycle_2stage/aes_cipher_top.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Cipher Top Level                                       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
 
//// Modified to achieve 5 cycles - stage  functionality 	     ////
//// By Tariq Bashir Ahmad					     				 //// 	
////  tariq.bashir@gmail.com					     			 ////
////  http://www.ecs.umass.edu/~tbashir				    		 ////



`timescale 1 ns/1 ps

module aes_cipher_top(clk, rst, ld, done, key, text_in, text_out);

input		clk, rst;
input		ld;
output		done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[31:0]	w0, w1, w2, w3, w4, w5, w6, w7;
/*wire	[127:0]	key_odd,key_even;
*/
reg	[127:0]	text_in_r;
reg	[127:0]	text_out;

reg	[127:0]	text_out_temp;

reg	[7:0]	sa00, sa01, sa02, sa03;
reg	[7:0]	sa10, sa11, sa12, sa13;
reg	[7:0]	sa20, sa21, sa22, sa23;
reg	[7:0]	sa30, sa31, sa32, sa33;

wire	[7:0]	sa00_next, sa01_next, sa02_next, sa03_next;
wire	[7:0]	sa10_next, sa11_next, sa12_next, sa13_next;
wire	[7:0]	sa20_next, sa21_next, sa22_next, sa23_next;
wire	[7:0]	sa30_next, sa31_next, sa32_next, sa33_next;

wire	[7:0]	sa00_sub, sa01_sub, sa02_sub, sa03_sub;
wire	[7:0]	sa10_sub, sa11_sub, sa12_sub, sa13_sub;
wire  [7:0]	sa20_sub, sa21_sub, sa22_sub, sa23_sub;
wire	[7:0]	sa30_sub, sa31_sub, sa32_sub, sa33_sub;

wire	[7:0]	sa00_sr, sa01_sr, sa02_sr, sa03_sr;
wire	[7:0]	sa10_sr, sa11_sr, sa12_sr, sa13_sr;
wire	[7:0]	sa20_sr, sa21_sr, sa22_sr, sa23_sr;
wire	[7:0]	sa30_sr, sa31_sr, sa32_sr, sa33_sr;

wire	[7:0]	sa00_mc, sa01_mc, sa02_mc, sa03_mc;
wire	[7:0]	sa10_mc, sa11_mc, sa12_mc, sa13_mc;
wire	[7:0]	sa20_mc, sa21_mc, sa22_mc, sa23_mc;
wire	[7:0]	sa30_mc, sa31_mc, sa32_mc, sa33_mc;


wire	[7:0]	sa00_next_round2, sa01_next_round2, sa02_next_round2, sa03_next_round2;
wire	[7:0]	sa10_next_round2, sa11_next_round2, sa12_next_round2, sa13_next_round2;
wire	[7:0]	sa20_next_round2, sa21_next_round2, sa22_next_round2, sa23_next_round2;
wire	[7:0]	sa30_next_round2, sa31_next_round2, sa32_next_round2, sa33_next_round2;

wire	[7:0]	sa00_sub_round2, sa01_sub_round2, sa02_sub_round2, sa03_sub_round2;
wire	[7:0]	sa10_sub_round2, sa11_sub_round2, sa12_sub_round2, sa13_sub_round2;
wire  [7:0]	sa20_sub_round2, sa21_sub_round2, sa22_sub_round2, sa23_sub_round2;
wire	[7:0]	sa30_sub_round2, sa31_sub_round2, sa32_sub_round2, sa33_sub_round2;

wire	[7:0]	sa00_sr_round2, sa01_sr_round2, sa02_sr_round2, sa03_sr_round2;
wire	[7:0]	sa10_sr_round2, sa11_sr_round2, sa12_sr_round2, sa13_sr_round2;
wire	[7:0]	sa20_sr_round2, sa21_sr_round2, sa22_sr_round2, sa23_sr_round2;
wire	[7:0]	sa30_sr_round2, sa31_sr_round2, sa32_sr_round2, sa33_sr_round2;

wire	[7:0]	sa00_mc_round2, sa01_mc_round2, sa02_mc_round2, sa03_mc_round2;
wire	[7:0]	sa10_mc_round2, sa11_mc_round2, sa12_mc_round2, sa13_mc_round2;
wire	[7:0]	sa20_mc_round2, sa21_mc_round2, sa22_mc_round2, sa23_mc_round2;
wire	[7:0]	sa30_mc_round2, sa31_mc_round2, sa32_mc_round2, sa33_mc_round2;




reg		done, ld_r;
reg	[3:0]	dcnt;
reg 		done2;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
begin
	if(~rst)	begin dcnt <=  4'h0;	 end
	else
	if(ld)	begin	dcnt <=  4'h6;	 end
	else
	if(|dcnt) begin	dcnt <=  dcnt - 4'h1;  end

end

always @(posedge clk) done <=  !(|dcnt[3:1]) & dcnt[0] & !ld;
always @(posedge clk) if(ld) text_in_r <=  text_in;
always @(posedge clk) ld_r <=  ld;



////////////////////////////////////////////////////////////////////
// key expansion


aes_key_expand_128 u0(
	.clk(		clk	),
	.kld(		ld_r	),
	.key(		key	),
	.w0(		w0	),
	.w1(		w1	),
	.w2(		w2	),
	.w3(		w3	),
	.w4_reg(		w4	),
	.w5_reg(		w5	),
	.w6_reg(		w6	),
	.w7_reg(		w7	)
							);
/*assign key_odd  = {w0,w1,w2,w3};
assign key_even = {w4,w5,w6,w7};
*/

/*assign {w0,w1,w2,w3} = 128'h0;

assign {w4,w5,w6,w7} = 128'h62636363626363636263636362636363;
*/							
// Initial Permutation (AddRoundKey)
//
/*
always @(posedge clk)
begin
  w0 <= w0_net;
  w1 <= w1_net;
  w2 <= w2_net;
  w3 <= w3_net;
  w4 <= w4_net;
  w5 <= w5_net;
  w6 <= w6_net;
  w7 <= w7_net;
end
*/
always @(posedge clk) 
begin
   	sa33 <=  ld_r ? text_in_r[007:000] ^ w3[07:00] : sa33_mc_round2 ^ w3[07:00];
    	sa23 <=  ld_r ? text_in_r[015:008] ^ w3[15:08] : sa23_mc_round2 ^ w3[15:08];
    	sa13 <=  ld_r ? text_in_r[023:016] ^ w3[23:16] : sa13_mc_round2 ^ w3[23:16];
    	sa03 <=  ld_r ? text_in_r[031:024] ^ w3[31:24] : sa03_mc_round2 ^ w3[31:24];
    	sa32 <=  ld_r ? text_in_r[039:032] ^ w2[07:00] : sa32_mc_round2 ^ w2[07:00];
    	sa22 <=  ld_r ? text_in_r[047:040] ^ w2[15:08] : sa22_mc_round2 ^ w2[15:08];
    	sa12 <=  ld_r ? text_in_r[055:048] ^ w2[23:16] : sa12_mc_round2 ^ w2[23:16];
    	sa02 <=  ld_r ? text_in_r[063:056] ^ w2[31:24] : sa02_mc_round2 ^ w2[31:24];
    	sa31 <=  ld_r ? text_in_r[071:064] ^ w1[07:00] : sa31_mc_round2 ^ w1[07:00];
    	sa21 <=  ld_r ? text_in_r[079:072] ^ w1[15:08] : sa21_mc_round2 ^ w1[15:08];
    	sa11 <=  ld_r ? text_in_r[087:080] ^ w1[23:16] : sa11_mc_round2 ^ w1[23:16];
    	sa01 <=  ld_r ? text_in_r[095:088] ^ w1[31:24] : sa01_mc_round2 ^ w1[31:24];
    	sa30 <=  ld_r ? text_in_r[103:096] ^ w0[07:00] : sa30_mc_round2 ^ w0[07:00];
    	sa20 <=  ld_r ? text_in_r[111:104] ^ w0[15:08] : sa20_mc_round2 ^ w0[15:08];
    	sa10 <=  ld_r ? text_in_r[119:112] ^ w0[23:16] : sa10_mc_round2 ^ w0[23:16];
    	sa00 <=  ld_r ? text_in_r[127:120] ^ w0[31:24] : sa00_mc_round2 ^ w0[31:24];
		
		/*$strobe($time,": roundkeyodd = %h\n",{w0,w1,w2,w3});
		$strobe($time,": state is %h\n",{sa00, sa01, sa02, sa03,
													 sa10, sa11, sa12, sa13,
													 sa20, sa21, sa22, sa23,
													 sa30, sa31, sa32, sa33});*/
		
end

////////////////////////////////////////////////////////////////////
//
// Modules instantiation
//

//sbox lookup
aes_sbox us00(	.a(	sa00	), .d(	sa00_sub	));
aes_sbox us01(	.a(	sa01	), .d(	sa01_sub	));
aes_sbox us02(	.a(	sa02	), .d(	sa02_sub	));
aes_sbox us03(	.a(	sa03	), .d(	sa03_sub	));
aes_sbox us10(	.a(	sa10	), .d(	sa10_sub	));
aes_sbox us11(	.a(	sa11	), .d(	sa11_sub	));
aes_sbox us12(	.a(	sa12	), .d(	sa12_sub	));
aes_sbox us13(	.a(	sa13	), .d(	sa13_sub	));
aes_sbox us20(	.a(	sa20	), .d(	sa20_sub	));
aes_sbox us21(	.a(	sa21	), .d(	sa21_sub	));
aes_sbox us22(	.a(	sa22	), .d(	sa22_sub	));
aes_sbox us23(	.a(	sa23	), .d(	sa23_sub	));
aes_sbox us30(	.a(	sa30	), .d(	sa30_sub	));
aes_sbox us31(	.a(	sa31	), .d(	sa31_sub	));
aes_sbox us32(	.a(	sa32	), .d(	sa32_sub	));
aes_sbox us33(	.a(	sa33	), .d(	sa33_sub	));

////////////////////////////////////////////////////////////////////
//
// Round Permutations
//

assign sa00_sr = sa00_sub;		//
assign sa01_sr = sa01_sub;		//no shift
assign sa02_sr = sa02_sub;		//
assign sa03_sr = sa03_sub;		//

assign sa10_sr = sa11_sub;		//
assign sa11_sr = sa12_sub;		// left shift by 1
assign sa12_sr = sa13_sub;		//
assign sa13_sr = sa10_sub;		//

assign sa20_sr = sa22_sub;		//
assign sa21_sr = sa23_sub;		//	left shift by 2
assign sa22_sr = sa20_sub;		//
assign sa23_sr = sa21_sub;		//

assign sa30_sr = sa33_sub;		//
assign sa31_sr = sa30_sub;		// left shift by 3
assign sa32_sr = sa31_sub;		//
assign sa33_sr = sa32_sub;		//

// mix column operation
assign {sa00_mc, sa10_mc, sa20_mc, sa30_mc}  = mix_col(sa00_sr,sa10_sr,sa20_sr,sa30_sr);
assign {sa01_mc, sa11_mc, sa21_mc, sa31_mc}  = mix_col(sa01_sr,sa11_sr,sa21_sr,sa31_sr);
assign {sa02_mc, sa12_mc, sa22_mc, sa32_mc}  = mix_col(sa02_sr,sa12_sr,sa22_sr,sa32_sr);
assign {sa03_mc, sa13_mc, sa23_mc, sa33_mc}  = mix_col(sa03_sr,sa13_sr,sa23_sr,sa33_sr);

//// add round key
assign sa00_next_round2 = sa00_mc ^ w4[31:24];		
assign sa01_next_round2 = sa01_mc ^ w5[31:24];
assign sa02_next_round2 = sa02_mc ^ w6[31:24];
assign sa03_next_round2 = sa03_mc ^ w7[31:24];
assign sa10_next_round2 = sa10_mc ^ w4[23:16];
assign sa11_next_round2 = sa11_mc ^ w5[23:16];
assign sa12_next_round2 = sa12_mc ^ w6[23:16];
assign sa13_next_round2 = sa13_mc ^ w7[23:16];
assign sa20_next_round2 = sa20_mc ^ w4[15:08];
assign sa21_next_round2 = sa21_mc ^ w5[15:08];
assign sa22_next_round2 = sa22_mc ^ w6[15:08];
assign sa23_next_round2 = sa23_mc ^ w7[15:08];
assign sa30_next_round2 = sa30_mc ^ w4[07:00];
assign sa31_next_round2 = sa31_mc ^ w5[07:00];
assign sa32_next_round2 = sa32_mc ^ w6[07:00];
assign sa33_next_round2 = sa33_mc ^ w7[07:00];


always @(posedge clk)
begin 
	  
	 /* $strobe($time,": roundkeyodd = %h, text_out_odd is %h\n",{w0,w1,w2,w3},text_out_temp);
	  $strobe($time,": roundkeyeven is %h\n",{w4,w5,w6,w7}); 	*/
	  text_out_temp[127:120] <=  sa00_sr ^ w4[31:24];	 
	  text_out_temp[095:088] <=  sa01_sr ^ w5[31:24];	 
          text_out_temp[063:056] <=  sa02_sr ^ w6[31:24];	 
	  text_out_temp[031:024] <=  sa03_sr ^ w7[31:24];	 
	  text_out_temp[119:112] <=  sa10_sr ^ w4[23:16];	 
	  text_out_temp[087:080] <=  sa11_sr ^ w5[23:16];	 
	  text_out_temp[055:048] <=  sa12_sr ^ w6[23:16];	 
	  text_out_temp[023:016] <=  sa13_sr ^ w7[23:16];	 
	  text_out_temp[111:104] <=  sa20_sr ^ w4[15:08];	 
	  text_out_temp[079:072] <=  sa21_sr ^ w5[15:08];	 
	  text_out_temp[047:040] <=  sa22_sr ^ w6[15:08];	 
	  text_out_temp[015:008] <=  sa23_sr ^ w7[15:08];	 
	  text_out_temp[103:096] <=  sa30_sr ^ w4[07:00];	 
	  text_out_temp[071:064] <=  sa31_sr ^ w5[07:00];	 
	  text_out_temp[039:032] <=  sa32_sr ^ w6[07:00];	 
	  text_out_temp[007:000] <=  sa33_sr ^ w7[07:00];    
end




//////////////////////  round i + 1 //////////////////////////////////
//sbox lookup
aes_sbox us00_round2(	.a(	sa00_next_round2	), .d(	sa00_sub_round2	));
aes_sbox us01_round2(	.a(	sa01_next_round2	), .d(	sa01_sub_round2	));
aes_sbox us02_round2(	.a(	sa02_next_round2	), .d(	sa02_sub_round2	));
aes_sbox us03_round2(	.a(	sa03_next_round2	), .d(	sa03_sub_round2	));
aes_sbox us10_round2(	.a(	sa10_next_round2	), .d(	sa10_sub_round2	));
aes_sbox us11_round2(	.a(	sa11_next_round2	), .d(	sa11_sub_round2	));
aes_sbox us12_round2(	.a(	sa12_next_round2	), .d(	sa12_sub_round2	));
aes_sbox us13_round2(	.a(	sa13_next_round2	), .d(	sa13_sub_round2	));
aes_sbox us20_round2(	.a(	sa20_next_round2	), .d(	sa20_sub_round2	));
aes_sbox us21_round2(	.a(	sa21_next_round2	), .d(	sa21_sub_round2	));
aes_sbox us22_round2(	.a(	sa22_next_round2	), .d(	sa22_sub_round2	));
aes_sbox us23_round2(	.a(	sa23_next_round2	), .d(	sa23_sub_round2	));
aes_sbox us30_round2(	.a(	sa30_next_round2	), .d(	sa30_sub_round2	));
aes_sbox us31_round2(	.a(	sa31_next_round2	), .d(	sa31_sub_round2	));
aes_sbox us32_round2(	.a(	sa32_next_round2	), .d(	sa32_sub_round2	));
aes_sbox us33_round2(	.a(	sa33_next_round2	), .d(	sa33_sub_round2	));


// Round Permutations
//

assign sa00_sr_round2 = sa00_sub_round2;		//
assign sa01_sr_round2 = sa01_sub_round2;		//no shift
assign sa02_sr_round2 = sa02_sub_round2;		//
assign sa03_sr_round2 = sa03_sub_round2;		//

assign sa10_sr_round2 = sa11_sub_round2;		//
assign sa11_sr_round2 = sa12_sub_round2;		// left shift by 1
assign sa12_sr_round2 = sa13_sub_round2;		//
assign sa13_sr_round2 = sa10_sub_round2;		//

assign sa20_sr_round2 = sa22_sub_round2;		//
assign sa21_sr_round2 = sa23_sub_round2;		//	left shift by 2
assign sa22_sr_round2 = sa20_sub_round2;		//
assign sa23_sr_round2 = sa21_sub_round2;		//

assign sa30_sr_round2 = sa33_sub_round2;		//
assign sa31_sr_round2 = sa30_sub_round2;		// left shift by 3
assign sa32_sr_round2 = sa31_sub_round2;		//
assign sa33_sr_round2 = sa32_sub_round2;		//

// mix column operation
assign {sa00_mc_round2, sa10_mc_round2, sa20_mc_round2, sa30_mc_round2}  = mix_col(sa00_sr_round2,sa10_sr_round2,sa20_sr_round2,sa30_sr_round2);
assign {sa01_mc_round2, sa11_mc_round2, sa21_mc_round2, sa31_mc_round2}  = mix_col(sa01_sr_round2,sa11_sr_round2,sa21_sr_round2,sa31_sr_round2);
assign {sa02_mc_round2, sa12_mc_round2, sa22_mc_round2, sa32_mc_round2}  = mix_col(sa02_sr_round2,sa12_sr_round2,sa22_sr_round2,sa32_sr_round2);
assign {sa03_mc_round2, sa13_mc_round2, sa23_mc_round2, sa33_mc_round2}  = mix_col(sa03_sr_round2,sa13_sr_round2,sa23_sr_round2,sa33_sr_round2);

////////////////////////////////////////////////////////////////////
//
// Final text output
//


always @(posedge clk)
 begin 
		/*  $strobe($time,": round_key2 is %h\n",{w4,w5,w6,w7});
		  $strobe($time,": roundkeyeven = %h, text_out_even is %h\n",{w4,w5,w6,w7},text_out);*/
		  text_out[127:120] <=  sa00_sr_round2 ^ w0[31:24];	 
		  text_out[095:088] <=  sa01_sr_round2 ^ w1[31:24];	 
		  text_out[063:056] <=  sa02_sr_round2 ^ w2[31:24];	 
		  text_out[031:024] <=  sa03_sr_round2 ^ w3[31:24];	 
		  text_out[119:112] <=  sa10_sr_round2 ^ w0[23:16];	 
		  text_out[087:080] <=  sa11_sr_round2 ^ w1[23:16];	 
		  text_out[055:048] <=  sa12_sr_round2 ^ w2[23:16];	 
		  text_out[023:016] <=  sa13_sr_round2 ^ w3[23:16];	 
		  text_out[111:104] <=  sa20_sr_round2 ^ w0[15:08];	 
		  text_out[079:072] <=  sa21_sr_round2 ^ w1[15:08];	 
		  text_out[047:040] <=  sa22_sr_round2 ^ w2[15:08];	 
		  text_out[015:008] <=  sa23_sr_round2 ^ w3[15:08];	 
		  text_out[103:096] <=  sa30_sr_round2 ^ w0[07:00];	 
		  text_out[071:064] <=  sa31_sr_round2 ^ w1[07:00];	 
		  text_out[039:032] <=  sa32_sr_round2 ^ w2[07:00];	 
		  text_out[007:000] <=  sa33_sr_round2 ^ w3[07:00];
	end


/* -----\/----- EXCLUDED -----\/-----
always @(posedge clk)
	begin
/-*	$strobe($time,": text_out_temp is %h\n",text_out_temp);


*-/	/-*
	$strobe($time,": subbytes is %h\n",{sa00_sub, sa01_sub, sa02_sub, sa03_sub,
													 sa10_sub, sa11_sub, sa12_sub, sa13_sub,
													 sa20_sub, sa21_sub, sa22_sub, sa23_sub,
													 sa30_sub, sa31_sub, sa32_sub, sa33_sub});
													 
	$strobe($time,": shiftrows is %h\n",{sa00_sr, sa01_sr, sa02_sr, sa03_sr,
													  sa10_sr, sa11_sr, sa12_sr, sa13_sr,
													  sa20_sr, sa21_sr, sa22_sr, sa23_sr,
													  sa30_sr, sa31_sr, sa32_sr, sa33_sr});
													  
	$strobe($time,": mixcolumn is %h\n",{sa00_mc, sa01_mc, sa02_mc, sa03_mc,
													  sa10_mc, sa11_mc, sa12_mc, sa13_mc,
													  sa20_mc, sa21_mc, sa22_mc, sa23_mc,
													  sa30_mc, sa31_mc, sa32_mc, sa33_mc});
	
	$strobe($time,": sa_next_into_even is %h\n",{sa00_next_round2, sa01_next_round2, sa02_next_round2, sa03_next_round2,
																 sa10_next_round2, sa11_next_round2, sa12_next_round2, sa13_next_round2,
																 sa20_next_round2, sa21_next_round2, sa22_next_round2, sa23_next_round2,
																 sa30_next_round2, sa31_next_round2, sa32_next_round2, sa33_next_round2});
																 
	$strobe($time,": subbytes_e is %h\n",{sa00_sub_round2, sa01_sub_round2, sa02_sub_round2, sa03_sub_round2,
													 sa10_sub_round2, sa11_sub_round2, sa12_sub_round2, sa13_sub_round2,
													 sa20_sub_round2, sa21_sub_round2, sa22_sub_round2, sa23_sub_round2,
													 sa30_sub_round2, sa31_sub_round2, sa32_sub_round2, sa33_sub_round2});
													 
	$strobe($time,": shiftrows_e is %h\n",{sa00_sr_round2, sa01_sr_round2, sa02_sr_round2, sa03_sr_round2,
													  sa10_sr_round2, sa11_sr_round2, sa12_sr_round2, sa13_sr_round2,
													  sa20_sr_round2, sa21_sr_round2, sa22_sr_round2, sa23_sr_round2,
													  sa30_sr_round2, sa31_sr_round2, sa32_sr_round2, sa33_sr_round2});
													  
	$strobe($time,": mixcolumn_e is %h\n",{sa00_mc_round2, sa01_mc_round2, sa02_mc_round2, sa03_mc_round2,
													  sa10_mc_round2, sa11_mc_round2, sa12_mc_round2, sa13_mc_round2,
													  sa20_mc_round2, sa21_mc_round2, sa22_mc_round2, sa23_mc_round2,
													  sa30_mc_round2, sa31_mc_round2, sa32_mc_round2, sa33_mc_round2});																
	*-/															 
	end
	
	
/-*
always @(posedge clk)
       begin
				if(done)
						begin
							text_out_64 <= text_out[127:64];
//							done2 <= 1;
						end
				else if(~done)
							text_out_64 <= text_out[63:0];
		end
	*-/	 
		 
/-*
always @(posedge clk)
			 begin
				if(done2)
					begin
						text_out_64 <= text_out[63:0];
					end	
		 end
*-/		 
 -----/\----- EXCLUDED -----/\----- */
////////////////////////////////////////////////////////////////////
//
// Generic Functions
//

function [31:0] mix_col;
input	[7:0]	s0,s1,s2,s3;
//reg	[7:0]	s0_o,s1_o,s2_o,s3_o;
begin
mix_col[31:24]=xtime(s0)^xtime(s1)^s1^s2^s3;
mix_col[23:16]=s0^xtime(s1)^xtime(s2)^s2^s3;
mix_col[15:08]=s0^s1^xtime(s2)^xtime(s3)^s3;
mix_col[07:00]=xtime(s0)^s0^s1^s2^xtime(s3);
end
endfunction

function [7:0] xtime;
input [7:0] b; xtime={b[6:0],1'b0}^(8'h1b&{8{b[7]}});
endfunction



endmodule




// -----------------------------------------------------------------------------
// Source file: aes_5cycle_2stage/aes_key_expand_128.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Key Expand Block (for 128 bit keys)                    ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1 ns/1 ps

module aes_key_expand_128(clk, kld, key, w0,w1,w2,w3,w4_reg,w5_reg,w6_reg,w7_reg);
input		clk;
input		kld;
input	[127:0]	key;
output reg	[31:0]	w0,w1,w2,w3;
		 reg [31:0]	   w4,w5,w6,w7;

output reg   [31:0]   w4_reg,w5_reg,w6_reg,w7_reg;
wire	[31:0]	tmp_w,tmp_w2;
wire	[31:0]	subword, subword2;
wire	[31:0]	rcon, rcon2;			//round constant



always @(posedge clk)
begin
	w4_reg <=  w4;
	w5_reg <=  w5;
	w6_reg <=  w6;
	w7_reg <=  w7;
/*   $strobe($time,": next round_key is %h\n",{w4_reg,w5_reg,w6_reg,w7_reg}); 
*/end

		
always @*
begin
 
w0 =  kld ? key[127:096] :w4_reg^subword2^{rcon[31:24],24'b0};
w1 =  kld ? key[095:064] :w5_reg^w4_reg^subword2^{rcon[31:24],24'b0};
w2 =  kld ? key[063:032] :w6_reg^w5_reg^w4_reg^subword2^{rcon[31:24],24'b0};
w3 =  kld ? key[031:000] :w7_reg^w6_reg^w5_reg^w4_reg^subword2^{rcon[31:24],24'b0};

w4 =  (1'b0)? key[127:096]^subword^{8'h01,24'b0} : w0^subword^{rcon2[31:24],24'b0};
w5 =  (1'b0)? key[095:064]^key[127:096]^subword^{8'h01,24'b0} :w1^w0^subword^{rcon2[31:24],24'b0};
w6 =  (1'b0)? key[063:032]^key[095:064]^key[127:096]^subword^{8'h01,24'b0} : w2^w1^w0^subword^{rcon2[31:24],24'b0}; 
w7 =  (1'b0)? key[127:096]^key[095:064]^key[063:032]^key[031:000]^subword^{8'h01,24'b0} : w3^w2^w1^w0^subword^{rcon2[31:24],24'b0};

/*$display($time,": rcon is %d, rcon2 is %d\n",rcon[31:24],rcon2[31:24]);*/
/*$display($time,": round_key is %h\n",{w0,w1,w2,w3}); 	
$display($time,": next_round_key is %h\n",{w4,w5,w6,w7});*/
end


/*assign tmp_w =  w3;  //subword
assign tmp_w2 = w7 ;  //subword2
*/
/*
assign subword[31:24]     = aes_sbox(tmp_w[23:16]);
assign subword[23:16]	  = aes_sbox(tmp_w[15:08]);
assign subword[15:08]	  = aes_sbox(tmp_w[07:00]);
assign subword[07:00]     = aes_sbox(tmp_w[31:24]);
*/

aes_sbox inst1(	.a(w3[23:16]), .d(subword[31:24]));
aes_sbox inst2(	.a(w3[15:08]), .d(subword[23:16]));
aes_sbox inst3(	.a(w3[07:00]), .d(subword[15:08]));
aes_sbox inst4(	.a(w3[31:24]), .d(subword[07:00])); 
aes_rcon inst5(.clk(clk), .kld(kld), .out(rcon[31:24]), .out2(rcon2[31:24]));


aes_sbox u4(	.a(w7_reg[23:16]), .d(subword2[31:24]));
aes_sbox u5(	.a(w7_reg[15:08]), .d(subword2[23:16]));
aes_sbox u6(	.a(w7_reg[07:00]), .d(subword2[15:08]));
aes_sbox u7(	.a(w7_reg[31:24]), .d(subword2[07:00])); 



endmodule


// -----------------------------------------------------------------------------
// Source file: aes_5cycle_2stage/aes_rcon.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES RCON Block                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1 ns/1 ps

module aes_rcon(clk, kld,out,out2);

input		clk;
input		kld;

output reg  [7:0] out,out2;

reg	[3:0]	rcnt_reg;
wire	[3:0]	rcnt_next;


assign rcnt_next = (kld) ? 0 : rcnt_reg+2;


always @*
begin
		out  = kld ? 8'h01:frcon(rcnt_next-1);
		out2 = kld ? 8'h01:frcon(rcnt_next); 
end		 


always @(posedge clk)
begin

		rcnt_reg <= rcnt_next;
/*		$strobe($time,": out is %h, out2 is %h\n",out,out2);
*/	
end	



function [7:0]	frcon;
input	[3:0]	i;
case(i)	// synopsys parallel_case
   4'h0: frcon=8'h01;		//1
   4'h1: frcon=8'h02;		//x
   4'h2: frcon=8'h04;		//x^2
   4'h3: frcon=8'h08;		//x^3
   4'h4: frcon=8'h10;		//x^4
   4'h5: frcon=8'h20;		//x^5
   4'h6: frcon=8'h40;		//x^6
   4'h7: frcon=8'h80;		//x^7
   4'h8: frcon=8'h1b;		//x^8
   4'h9: frcon=8'h36;		//x^9
   default: frcon=8'h00;
endcase
endfunction

endmodule

// -----------------------------------------------------------------------------
// Source file: aes_5cycle_2stage/aes_sbox.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES SBOX (ROM)                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


`timescale 1 ns/1 ps


module aes_sbox(a,d);
input	[7:0]	a;
output	[7:0]	d;
reg	[7:0]	d;

always @(a)
	case(a)		// synopsys full_case parallel_case
	   8'h00: d=8'h63;
	   8'h01: d=8'h7c;
	   8'h02: d=8'h77;
	   8'h03: d=8'h7b;
	   8'h04: d=8'hf2;
	   8'h05: d=8'h6b;
	   8'h06: d=8'h6f;
	   8'h07: d=8'hc5;
	   8'h08: d=8'h30;
	   8'h09: d=8'h01;
	   8'h0a: d=8'h67;
	   8'h0b: d=8'h2b;
	   8'h0c: d=8'hfe;
	   8'h0d: d=8'hd7;
	   8'h0e: d=8'hab;
	   8'h0f: d=8'h76;
	   8'h10: d=8'hca;
	   8'h11: d=8'h82;
	   8'h12: d=8'hc9;
	   8'h13: d=8'h7d;
	   8'h14: d=8'hfa;
	   8'h15: d=8'h59;
	   8'h16: d=8'h47;
	   8'h17: d=8'hf0;
	   8'h18: d=8'had;
	   8'h19: d=8'hd4;
	   8'h1a: d=8'ha2;
	   8'h1b: d=8'haf;
	   8'h1c: d=8'h9c;
	   8'h1d: d=8'ha4;
	   8'h1e: d=8'h72;
	   8'h1f: d=8'hc0;
	   8'h20: d=8'hb7;
	   8'h21: d=8'hfd;
	   8'h22: d=8'h93;
	   8'h23: d=8'h26;
	   8'h24: d=8'h36;
	   8'h25: d=8'h3f;
	   8'h26: d=8'hf7;
	   8'h27: d=8'hcc;
	   8'h28: d=8'h34;
	   8'h29: d=8'ha5;
	   8'h2a: d=8'he5;
	   8'h2b: d=8'hf1;
	   8'h2c: d=8'h71;
	   8'h2d: d=8'hd8;
	   8'h2e: d=8'h31;
	   8'h2f: d=8'h15;
	   8'h30: d=8'h04;
	   8'h31: d=8'hc7;
	   8'h32: d=8'h23;
	   8'h33: d=8'hc3;
	   8'h34: d=8'h18;
	   8'h35: d=8'h96;
	   8'h36: d=8'h05;
	   8'h37: d=8'h9a;
	   8'h38: d=8'h07;
	   8'h39: d=8'h12;
	   8'h3a: d=8'h80;
	   8'h3b: d=8'he2;
	   8'h3c: d=8'heb;
	   8'h3d: d=8'h27;
	   8'h3e: d=8'hb2;
	   8'h3f: d=8'h75;
	   8'h40: d=8'h09;
	   8'h41: d=8'h83;
	   8'h42: d=8'h2c;
	   8'h43: d=8'h1a;
	   8'h44: d=8'h1b;
	   8'h45: d=8'h6e;
	   8'h46: d=8'h5a;
	   8'h47: d=8'ha0;
	   8'h48: d=8'h52;
	   8'h49: d=8'h3b;
	   8'h4a: d=8'hd6;
	   8'h4b: d=8'hb3;
	   8'h4c: d=8'h29;
	   8'h4d: d=8'he3;
	   8'h4e: d=8'h2f;
	   8'h4f: d=8'h84;
	   8'h50: d=8'h53;
	   8'h51: d=8'hd1;
	   8'h52: d=8'h00;
	   8'h53: d=8'hed;
	   8'h54: d=8'h20;
	   8'h55: d=8'hfc;
	   8'h56: d=8'hb1;
	   8'h57: d=8'h5b;
	   8'h58: d=8'h6a;
	   8'h59: d=8'hcb;
	   8'h5a: d=8'hbe;
	   8'h5b: d=8'h39;
	   8'h5c: d=8'h4a;
	   8'h5d: d=8'h4c;
	   8'h5e: d=8'h58;
	   8'h5f: d=8'hcf;
	   8'h60: d=8'hd0;
	   8'h61: d=8'hef;
	   8'h62: d=8'haa;
	   8'h63: d=8'hfb;
	   8'h64: d=8'h43;
	   8'h65: d=8'h4d;
	   8'h66: d=8'h33;
	   8'h67: d=8'h85;
	   8'h68: d=8'h45;
	   8'h69: d=8'hf9;
	   8'h6a: d=8'h02;
	   8'h6b: d=8'h7f;
	   8'h6c: d=8'h50;
	   8'h6d: d=8'h3c;
	   8'h6e: d=8'h9f;
	   8'h6f: d=8'ha8;
	   8'h70: d=8'h51;
	   8'h71: d=8'ha3;
	   8'h72: d=8'h40;
	   8'h73: d=8'h8f;
	   8'h74: d=8'h92;
	   8'h75: d=8'h9d;
	   8'h76: d=8'h38;
	   8'h77: d=8'hf5;
	   8'h78: d=8'hbc;
	   8'h79: d=8'hb6;
	   8'h7a: d=8'hda;
	   8'h7b: d=8'h21;
	   8'h7c: d=8'h10;
	   8'h7d: d=8'hff;
	   8'h7e: d=8'hf3;
	   8'h7f: d=8'hd2;
	   8'h80: d=8'hcd;
	   8'h81: d=8'h0c;
	   8'h82: d=8'h13;
	   8'h83: d=8'hec;
	   8'h84: d=8'h5f;
	   8'h85: d=8'h97;
	   8'h86: d=8'h44;
	   8'h87: d=8'h17;
	   8'h88: d=8'hc4;
	   8'h89: d=8'ha7;
	   8'h8a: d=8'h7e;
	   8'h8b: d=8'h3d;
	   8'h8c: d=8'h64;
	   8'h8d: d=8'h5d;
	   8'h8e: d=8'h19;
	   8'h8f: d=8'h73;
	   8'h90: d=8'h60;
	   8'h91: d=8'h81;
	   8'h92: d=8'h4f;
	   8'h93: d=8'hdc;
	   8'h94: d=8'h22;
	   8'h95: d=8'h2a;
	   8'h96: d=8'h90;
	   8'h97: d=8'h88;
	   8'h98: d=8'h46;
	   8'h99: d=8'hee;
	   8'h9a: d=8'hb8;
	   8'h9b: d=8'h14;
	   8'h9c: d=8'hde;
	   8'h9d: d=8'h5e;
	   8'h9e: d=8'h0b;
	   8'h9f: d=8'hdb;
	   8'ha0: d=8'he0;
	   8'ha1: d=8'h32;
	   8'ha2: d=8'h3a;
	   8'ha3: d=8'h0a;
	   8'ha4: d=8'h49;
	   8'ha5: d=8'h06;
	   8'ha6: d=8'h24;
	   8'ha7: d=8'h5c;
	   8'ha8: d=8'hc2;
	   8'ha9: d=8'hd3;
	   8'haa: d=8'hac;
	   8'hab: d=8'h62;
	   8'hac: d=8'h91;
	   8'had: d=8'h95;
	   8'hae: d=8'he4;
	   8'haf: d=8'h79;
	   8'hb0: d=8'he7;
	   8'hb1: d=8'hc8;
	   8'hb2: d=8'h37;
	   8'hb3: d=8'h6d;
	   8'hb4: d=8'h8d;
	   8'hb5: d=8'hd5;
	   8'hb6: d=8'h4e;
	   8'hb7: d=8'ha9;
	   8'hb8: d=8'h6c;
	   8'hb9: d=8'h56;
	   8'hba: d=8'hf4;
	   8'hbb: d=8'hea;
	   8'hbc: d=8'h65;
	   8'hbd: d=8'h7a;
	   8'hbe: d=8'hae;
	   8'hbf: d=8'h08;
	   8'hc0: d=8'hba;
	   8'hc1: d=8'h78;
	   8'hc2: d=8'h25;
	   8'hc3: d=8'h2e;
	   8'hc4: d=8'h1c;
	   8'hc5: d=8'ha6;
	   8'hc6: d=8'hb4;
	   8'hc7: d=8'hc6;
	   8'hc8: d=8'he8;
	   8'hc9: d=8'hdd;
	   8'hca: d=8'h74;
	   8'hcb: d=8'h1f;
	   8'hcc: d=8'h4b;
	   8'hcd: d=8'hbd;
	   8'hce: d=8'h8b;
	   8'hcf: d=8'h8a;
	   8'hd0: d=8'h70;
	   8'hd1: d=8'h3e;
	   8'hd2: d=8'hb5;
	   8'hd3: d=8'h66;
	   8'hd4: d=8'h48;
	   8'hd5: d=8'h03;
	   8'hd6: d=8'hf6;
	   8'hd7: d=8'h0e;
	   8'hd8: d=8'h61;
	   8'hd9: d=8'h35;
	   8'hda: d=8'h57;
	   8'hdb: d=8'hb9;
	   8'hdc: d=8'h86;
	   8'hdd: d=8'hc1;
	   8'hde: d=8'h1d;
	   8'hdf: d=8'h9e;
	   8'he0: d=8'he1;
	   8'he1: d=8'hf8;
	   8'he2: d=8'h98;
	   8'he3: d=8'h11;
	   8'he4: d=8'h69;
	   8'he5: d=8'hd9;
	   8'he6: d=8'h8e;
	   8'he7: d=8'h94;
	   8'he8: d=8'h9b;
	   8'he9: d=8'h1e;
	   8'hea: d=8'h87;
	   8'heb: d=8'he9;
	   8'hec: d=8'hce;
	   8'hed: d=8'h55;
	   8'hee: d=8'h28;
	   8'hef: d=8'hdf;
	   8'hf0: d=8'h8c;
	   8'hf1: d=8'ha1;
	   8'hf2: d=8'h89;
	   8'hf3: d=8'h0d;
	   8'hf4: d=8'hbf;
	   8'hf5: d=8'he6;
	   8'hf6: d=8'h42;
	   8'hf7: d=8'h68;
	   8'hf8: d=8'h41;
	   8'hf9: d=8'h99;
	   8'hfa: d=8'h2d;
	   8'hfb: d=8'h0f;
	   8'hfc: d=8'hb0;
	   8'hfd: d=8'h54;
	   8'hfe: d=8'hbb;
	   8'hff: d=8'h16;
	endcase

endmodule


