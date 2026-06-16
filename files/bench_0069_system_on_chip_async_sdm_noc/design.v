// Curated RTL benchmark case.
// case_id: bench_0069_system_on_chip_async_sdm_noc
// source_project: system_on_chip_async-sdm-noc
// top_module: inpbuf


// -----------------------------------------------------------------------------
// Source file: sdm/define.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Router configuration header file for SDM routers.
 
 Possible configuration combinations:
 * Wormhole (set VCN to 1)
   ENABLE_EOF [ENABLE_CHANNEL_SLICING] [ENABLE_LOOKAHEAD]
 * SDM (set VCN > 1 without define ENABLE_CLOS)
   ENABLE_EOF [ENABLE_CHANNEL_SLICING] [ENABLE_LOOKAHEAD] [ENABLE_MRMA]
 * SDM-Clos (set VCN > 1 and define ENABLE_CLOS)
   ENABLE_EOF ENABLE_CLOS [ENABLE_CHANNEL_SLICING] [ENABLE_LOOKAHEAD] [ENABLE_CRRD [ENABLE_MRMA]]
 
 The combinations not presented above are illegal, which may produce unexpected failures.
  
 History:
 20/09/2009  Initial version. <wsong83@gmail.com>
 23/05/2011  Clean up for opensource. <wsong83@gmail.com>
 26/05/2011  Add ENABLE_MRMA and configuration explanations. <wsong83@gmail.com>
 
*/

// if VCN > 1, set ENABLE_CLOS to use the 2-stage Clos switch for less switching area
// `define ENABLE_CLOS

// Using the asynchronous version of the Concurrent round-robin dispatching
// algorithm for the 2-stage Clos can save some area but introduce a 5%
// throughput loss
// `define ENABLE_CRRD

// for the SDM router using crossbars and the Clos router using CRRD
// algorithm, using the multi-resource match arbiter may save the area in
// switch allocators
// `define ENABLE_MRMA

// set to enable channel slicing for fast data paths
// `define ENABLE_CHANNEL_SLICING

// set to use the early acknowledge of lookahead pipelines in the critical cycle
// `define ENABLE_LOOKAHEAD

// always set in wormhole and SDM routers to enable the eof bit in data pipeline stages
`define ENABLE_EOF

// -----------------------------------------------------------------------------
// Source file: vc/src/inpbuf.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The input buffer for VC routers.
 
 History:
 01/04/2010  Initial version. <wsong83@gmail.com>
 12/05/2010  Use MPxP crossbars. <wsong83@gmail.com>
 17/04/2010  Remove unnecessary pipeline stages. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  Remove the C-elements as muxes already have C-elements inside. <wsong83@gmail.com>
 
*/

module inpbuf (/*AUTOARG*/
   // Outputs
   dia, cor, do0, do1, do2, do3, dot, dortg, vcr, swr,
   // Inputs
   di0, di1, di2, di3, dit, divc, coa, doa, vcra, swrt, addrx, addry,
   rst_n
   );

   parameter DW = 32;		// data width
   parameter VCN = 2;		// VC number
   parameter DIR = 0;           // 0-4 south, west, north, east, local
   parameter SN = 2;		// maximal output port number
   parameter PD = 3;		// the depth of the input buffer pipeline
   parameter SCN = DW/2;	// number of 1-of-4 sub-channels
   parameter FT = 3;		// flit type, now 3, HOF, BOF, EOF
        
   // data IP
   input [SCN-1:0] di0, di1, di2, di3;
   input [FT-1:0]  dit;
   input [VCN-1:0] divc;
   output 	   dia;

   // credit flow-control
   output [VCN-1:0] cor;
   input [VCN-1:0]  coa;

   // data to crossbar
   output [VCN-1:0][SCN-1:0] do0,do1,do2,do3;
   output [VCN-1:0][FT-1:0]  dot;
   output [VCN-1:0][SN-1:0]  dortg;
   input  [VCN-1:0]	    doa;

   // request to VC allocator
   output [VCN-1:0][SN-1:0] vcr;
   input [VCN-1:0] 	    vcra;

   // output to SW allocator
   output [VCN-1:0][1:0]    swr;

   // routing guide for SW DEMUX
   input [VCN-1:0][SN-1:0]  swrt;

   // local addresses
   input [7:0] 		    addrx, addry;

   input 		    rst_n;

   //-----------------------------		    
   // VC_MUX
   wire 		    ivma, rua;
   wire [SCN-1:0] 	    di0m, di1m, di2m, di3m;
   wire [FT-1:0] 	    ditm;
   wire [VCN-1:0] 	    divcm;
   wire [VCN-1:0] 	    muxa; 	    
   
   // VC_BUF
   wire [2*PD:0][VCN-1:0][SCN-1:0] vcd0, vcd1, vcd2, vcd3; // VC data
   wire [2*PD:0][VCN-1:0][FT-1:0]  vcdt;		   // VC flit type
   wire [2*PD:0][VCN-1:0][SCN-1:0] vcdad, vcdadn;          // VC ack
   wire [2*PD:0][VCN-1:0] 	   vcdat, vcdatn;	   // VC data ack and type ack
   wire [1:0][VCN-1:0] 		   vcda;                   // the comman ack 		   

   // control path
   wire [2*PD:2*PD-2][VCN-1:0][1:0] vcft;		   // flit type on control path
   wire [2*PD:2*PD-2][VCN-1:0] 	   vcfta, vcftan;          // flit type ack, on control path
   wire [VCN-1:0] 		   vcdam;		   // need an extra ack internal signal
   wire [VCN-1:0][SN-1:0] 	   rtg;			   // routing direction guide
   wire [VCN-1:0] 		   doan;
   
   // last stage of input buffer
   wire [VCN-1:0] 		   vcor;
   wire [VCN-1:0] 		   vcog;
   wire [VCN-1:0] 		   swa;

   genvar 			   gbd, gvc, gsub, i;

   //---------------------------------------------
   // the input VCDMUX
   vcdmux #(.VCN(VCN), .DW(DW))
   IVM ( 
	 .dia   ( ivma     ), 
	 .do0   ( vcd0[0]  ), 
	 .do1   ( vcd1[0]  ), 
	 .do2   ( vcd2[0]  ), 
	 .do3   ( vcd3[0]  ), 
	 .dot   ( vcdt[0]  ),
	 .di0   ( di0m     ), 
	 .di1   ( di1m     ), 
	 .di2   ( di2m     ), 
	 .di3   ( di3m     ), 
	 .dit   ( ditm     ), 
	 .divc  ( divcm    ), 
	 .doa   ( muxa     )
	 );

   //c2 IVMA (.a0(ivma), .a1(rua), .q(dia)); divc is not checked
   ctree #(.DW(2)) ACKT(.ci({ivma, rua}), .co(dia));
   
   assign di0m = rst_n ? di0 : 0;
   assign di1m = rst_n ? di1 : 0;
   assign di2m = rst_n ? di2 : 0;
   assign di3m = rst_n ? di3 : 0;
   assign ditm = rst_n ? dit : 0;
   assign divcm = rst_n ? divc : 0;

   //---------------------------------------------
   // the VC buffers
   generate
      for(gbd=0; gbd<PD*2-2; gbd++) begin:BFN
	 for(gvc=0; gvc<VCN; gvc++) begin:V
	    for(gsub=0; gsub<SCN; gsub++) begin:SC
	       pipe4 #(.DW(2)) 
	       DP (
		   .ia ( vcdad[gbd][gvc][gsub]  ), 
		   .o0 ( vcd0[gbd+1][gvc][gsub] ), 
		   .o1 ( vcd1[gbd+1][gvc][gsub] ),
		   .o2 ( vcd2[gbd+1][gvc][gsub] ), 
		   .o3 ( vcd3[gbd+1][gvc][gsub] ), 
		   .i0 ( vcd0[gbd][gvc][gsub]   ),
		   .i1 ( vcd1[gbd][gvc][gsub]   ), 
		   .i2 ( vcd2[gbd][gvc][gsub]   ),
		   .i3 ( vcd3[gbd][gvc][gsub]   ),
		   .oa ( vcdadn[gbd+1][gvc][gsub] )
		   );
	       assign vcdadn[gbd+1][gvc][gsub] = (~vcdad[gbd+1][gvc][gsub])&rst_n;
	    end // block: SC
	    
	    pipen #(.DW(FT)) 
	    TP (
		.d_in    ( vcdt[gbd][gvc]     ),
		.d_in_a  ( vcdat[gbd][gvc]    ),
		.d_out   ( vcdt[gbd+1][gvc]   ),
		.d_out_a ( vcdatn[gbd+1][gvc]  )
		);
	    assign vcdatn[gbd+1][gvc] = (~vcdat[gbd+1][gvc])&rst_n;
	    
	 end // block: V
      end // block: BFN

      for(gvc=0; gvc<VCN; gvc++) begin:BFNV
	 if(PD>1) begin:ACKG
	    ctree #(.DW(SCN+1)) ACKT(.ci({vcdat[0],vcdad[0]}), .co(muxa[gvc]));
	    assign vcdad[PD*2-2][gvc] = {SCN{vcda[0][gvc]}};
	    assign vcdat[PD*2-2] = vcda[0][gvc];
	 end else begin
	    assign muxa[gvc] = vcda[0][gvc];
	 end
      end // block: V
      
   endgenerate

   // the last two stages of VC buffers, separate flit type and data
   generate
      for(gbd=PD*2-2; gbd<PD*2; gbd++) begin:BFL2
	 for(gvc=0; gvc<VCN; gvc++) begin:V
	    for(gsub=0; gsub<SCN; gsub++) begin:SC
	       pipe4 #(.DW(2)) 
	       DP (
		   .ia ( vcdad[gbd][gvc][gsub]    ),
		   .o0 ( vcd0[gbd+1][gvc][gsub]   ),
		   .o1 ( vcd1[gbd+1][gvc][gsub]   ),
		   .o2 ( vcd2[gbd+1][gvc][gsub]   ), 
		   .o3 ( vcd3[gbd+1][gvc][gsub]   ), 
		   .i0 ( vcd0[gbd][gvc][gsub]     ),
		   .i1 ( vcd1[gbd][gvc][gsub]     ), 
		   .i2 ( vcd2[gbd][gvc][gsub]     ),
		   .i3 ( vcd3[gbd][gvc][gsub]     ),
		   .oa ( vcdadn[gbd+1][gvc][gsub] )
		   );
	       assign vcdadn[gbd+1][gvc][gsub] = (~vcdad[gbd+1][gvc][gsub])&rst_n;
	    end // block: SC
	    
	    pipen #(.DW(FT)) 
	    TP (
		.d_in    ( vcdt[gbd][gvc]     ),
		.d_in_a  ( vcdat[gbd][gvc]    ),
		.d_out   ( vcdt[gbd+1][gvc]   ),
		.d_out_a ( vcdatn[gbd+1][gvc]  )
		);

	    assign vcdatn[gbd+1][gvc] = (~vcdat[gbd+1][gvc])&rst_n;

	    pipen #(.DW(2))
	    CTP (
		.d_in    ( vcft[gbd][gvc]     ),
		.d_in_a  ( vcfta[gbd][gvc]    ),
		.d_out   ( vcft[gbd+1][gvc]   ),
		.d_out_a ( vcftan[gbd+1][gvc] )
		);

	    assign vcftan[gbd+1][gvc] = (~vcfta[gbd+1][gvc])&rst_n;
	 end // block: V
      end // block: BFL2

      for(gvc=0; gvc<VCN; gvc++) begin:BFL2V
	 ctree #(.DW(SCN+2)) ACKT(.ci({vcfta[PD*2-2][gvc], vcdat[PD*2-2][gvc], vcdad[PD*2-2][gvc]}), .co(vcda[0][gvc]));
	 assign vcdat[PD*2][gvc] = vcda[1][gvc];
	 assign vcdad[PD*2][gvc] = {SCN{vcda[1][gvc]}};
	 assign vcfta[PD*2][gvc] = swa[gvc];
	 assign vcft[PD*2-2][gvc] = {vcdt[PD*2-2][gvc][FT-1], |vcdt[PD*2-2][gvc][FT-2:0]};
	 assign swr[gvc] = vcft[PD*2][gvc];
      end

   endgenerate
   

   // the routing guide pipeline stage
   generate
      for(gvc=0; gvc<VCN; gvc++) begin:R
	 pipen #(.DW(SN))
	 RP (
	     .d_in     ( swrt[gvc]          ),
	     .d_in_a   ( swa[gvc]           ),
	     .d_out    ( rtg[gvc]           ),
	     .d_out_a  ( (~vcda[1][gvc])&rst_n   )
	     );
      end
   endgenerate

   generate
      for(gvc=0; gvc<VCN; gvc++) begin:LPS

	 // credit control
	 dc2 FCP (.q(cor[gvc]), .d(|rtg[gvc]), .a((~coa[gvc])&rst_n));

	 // output name conversation
	 assign do0[gvc] = vcd0[PD*2][gvc];
	 assign do1[gvc] = vcd1[PD*2][gvc];
	 assign do2[gvc] = vcd2[PD*2][gvc];
	 assign do3[gvc] = vcd3[PD*2][gvc];

	 assign dot[gvc] = vcdt[PD*2][gvc];
	 assign dortg[gvc] = rtg[gvc];

	 c2 AC (.q(vcda[1][gvc]), .a0(cor[gvc]), .a1(doa[gvc]));

      end // block: LPS
   endgenerate
   
   // routing unit
   rtu #(.VCN(VCN), .DIR(DIR), .SN(SN), .PD(PD))
   RTC (
	.dia   ( rua       ), 
	.dort  ( vcr       ),
	.rst_n ( rst_n     ),
	.di0   ( di0m[3:0] ), 
	.di1   ( di1m[3:0] ), 
	.di2   ( di2m[3:0] ), 
	.di3   ( di3m[3:0] ), 
	.dit   ( ditm      ), 
	.divc  ( divcm     ), 
	.addrx ( addrx     ), 
	.addry ( addry     ), 
	.doa   ( vcra      )
   );
   
endmodule // inpbuf

   

   


   

// -----------------------------------------------------------------------------
// Source file: common/src/cell_lib.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 A synthesizable cell library for asynchronous circuis.
 Some cell are directly initialized to one of the Nangate 45nm cell lib.
 
 History:
 05/05/2009  Initial version. <wsong83@gmail.com>
 20/05/2011  Change to general verilog description for opensource. 
             The Nangate cell library is used. <wsong83@gmail.com>
 01/06/2011  The bugs in the C2 and C2P1 gates are fixed. <wsong83@gmail.com>
*/

// General 2-input C-element
module c2 (a0, a1, q);

   input a0, a1;		// two inputs
   output q;			// output

   wire [2:0] m;		// internal wires

   nand U1 (m[0], a0, a1);
   nand U2 (m[1], a0, q);
   nand U3 (m[2], a1, q);
   assign q = ~&m;
   
endmodule

// the 2-input C-element on data paths, different name for easy synthesis scription
module dc2 (d, a, q);

   input d;			// data input
   input a;			// ack input
   output q;			// data output

   wire [2:0] m;		// internal wires

   nand U1 (m[0], a, d);
   nand U2 (m[1], d, q);
   nand U3 (m[2], a, q);
   assign q = ~&m;

endmodule

// 2-input C-element with a minus input
module c2n (a, b, q);

   input a;			// the normal input
   input b;			// the minus input
   output q;			// output

   wire m;			// internal wire
   
   and U1 (m, b, q);
   or  U2 (q, m, a);
   
endmodule

// 2-input C-element with a plus input
module c2p (a, b, q);

   input a;			// the normal input
   input b;			// the plus input
   output q;			// output

   wire m;			// internal wire

   or  U1 (m, b, q);
   and U2 (q, m, a);
   
endmodule

// 2-input MUTEX cell, Nangate
module mutex2 ( a, b, qa, qb );	// !!! dont touch !!!

   input a, b;			// request inputs
   output qa, qb;		// grant outputs

   wire   qan, qbn;		// internal wires

   NAND2_X2 U1 ( .A1(a), .A2(qbn), .ZN(qan) ); // different driving strength for fast convergence
   NOR3_X2  U2 ( .A1(qbn), .A2(qbn), .A3(qbn), .ZN(qb) ); // pulse filter
   NOR3_X2  U3 ( .A1(qan), .A2(qan), .A3(qan), .ZN(qa) ); // pulse filter
   NAND2_X1 U4 ( .A1(b), .A2(qan), .ZN(qbn) );

endmodule

// 3-input C-element with a plus input
module c2p1 (a0, a1, b, q); 
   
   input a0, a1;		// normal inputs
   input b;			// plus input
   output q;			// output
                   
   wire [2:0] m;		// internal wires

   nand U1 (m[0], a0, a1, b);
   nand U2 (m[1], a0, q);
   nand U3 (m[2], a1, q);
   assign q = ~&m;

endmodule                    

// the basic element of a tree arbiter
module tarb ( ngnt, ntgnt, req, treq );

   input [1:0] req;		// request input
   output [1:0] ngnt;		// the negative grant output
   output treq;			// combined request output
   input ntgnt;			// the negative combined grant input
  
   wire  n1, n2;		// internal wires
   wire [1:0] mgnt;		// outputs of the MUTEX

   mutex2 ME ( .a(req[0]), .b(req[1]), .qa(mgnt[0]), .qb(mgnt[1]) );
   c2n C0 ( .a(ntgnt), .b(n2), .q(ngnt[0]) );
   c2n C1 ( .a(ntgnt), .b(n1), .q(ngnt[1]) );
   nand U1 (treq, n1, n2);
   nand U2 (n1, ngnt[0], mgnt[1]);
   nand U3 (n2, ngnt[1], mgnt[0]);
endmodule

// the tile in a multi-resource arbiter
module cr_blk ( bo, hs, cbi, rbi, rg, cg );

   input rg, cg;		// input requests
   input cbi, rbi;		// input blockage
   output bo;			// output blockage
   output hs;			// match result
  
   wire   blk;			// internal wire

   c2p1 XG ( .a0(rg), .a1(cg), .b(blk), .q(bo) );
   c2p1 HG ( .a0(cbi), .a1(rbi), .b(bo), .q(hs) );
   nor U1 (blk, rbi, cbi);

endmodule

// a data latch template, Nangate
module dlatch ( q, qb, d, g);
   output q, qb;
   input  d, g;

   DLH_X1 U1 (.Q(q), .D(d), .G(g));
endmodule

// a delay line, Nangate
module delay (q, a);
   input a;
   output q;
   
   BUF_X2 U (.Z(q), .A(a));
endmodule

   

// -----------------------------------------------------------------------------
// Source file: common/src/comp4.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 1-of-4 data comparator
 
 History:
 11/05/2010  Initial version. <wsong83@gmail.com>
 01/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module comp4 (/*AUTOARG*/
   // Outputs
   q,
   // Inputs
   a, b
   );

   input [3:0]   a, b;		// the data inputs to be compared
   output [2:0]  q;		// the comparison result

   // a > b
   assign q[0] = (a[3]&(|b[2:0])) | (a[2]&(|b[1:0])) | (a[1]&(|b[0:0]));

   // a < b
   assign q[1] = (a[2]&(|b[3:3])) | (a[1]&(|b[3:2])) | (a[0]&(|b[3:1]));

   // a = b
   assign q[2] = (a[3]&b[3]) | (a[2]&b[2]) | (a[1]&b[1]) | (a[0]&b[0]);

endmodule // comp4

// -----------------------------------------------------------------------------
// Source file: common/src/ctree.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 C-element tree, usually for common ack generation.
 *** SystemVerilog is used ***
 
 History:
 17/04/2011  Initial version. <wsong83@gmail.com>
 23/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module ctree (/*AUTOARG*/
   // Outputs
   co,
   // Inputs
   ci
   );

   parameter DW = 2;		// the total number of leaves of the C-element tree

   input [DW-1:0] ci;		// all input leaves
   output         co;		// the combined output

   wire [2*DW-2:0] dat;
   genvar 	   i;
   
   assign dat[DW-1:0] = ci;
   
   generate for (i=0; i<DW-1; i=i+1) begin:AT
       c2 CT (.a0(dat[i*2]), .a1(dat[i*2+1]), .q(dat[i+DW]));
   end endgenerate

   assign co = dat[2*DW-2];

endmodule // ctree


// -----------------------------------------------------------------------------
// Source file: common/src/pipe4.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 General pipeline stage using the 4-phase 1-of-4 QDI protocol.
 *** SystemVerilog is used ***
 
 History:
 05/05/2009  Initial version. <wsong83@gmail.com>
 17/04/2011  Replace the common ack generation. <wsong83@gmail.com>
 26/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module pipe4(/*AUTOARG*/
   // Outputs
   ia, o0, o1, o2, o3,
   // Inputs
   i0, i1, i2, i3, oa
`ifdef ENABLE_EOF
   , i4, o4
`endif
   );
    
   parameter DW = 32;		// the data width of the pipeline stage
   parameter SCN = DW/2;	// the number of 1-of-4 sub-stage required
   
   input  [SCN-1:0]  i0, i1, i2, i3;
   output [SCN-1:0]  o0, o1, o2, o3;
   input 	     oa;	// input ack
   output 	     ia;	// output ack

`ifdef ENABLE_EOF
   output 	     o4;	// the eof bit
   input 	     i4;
`endif
   
   // internal signals
   wire [SCN-1:0]    tack;
   
   // generate the ack line
   genvar       i;
   
   // the data pipe stage
   generate for (i=0; i<SCN; i++) begin:DD
      dc2 DC0 (.d(i0[i]), .a(oa), .q(o0[i]));
      dc2 DC1 (.d(i1[i]), .a(oa), .q(o1[i]));
      dc2 DC2 (.d(i2[i]), .a(oa), .q(o2[i]));
      dc2 DC3 (.d(i3[i]), .a(oa), .q(o3[i]));
   end endgenerate

   // the eof bit
`ifdef ENABLE_EOF
   dc2 DD_DC4 (.d(i4),  .a(oa),  .q(o4));
`endif

   // generate the input ack
   assign tack = o0|o1|o2|o3;
   ctree #(.DW(SCN)) ACKT (.ci(tack), .co(ia));

endmodule // pipe4





// -----------------------------------------------------------------------------
// Source file: common/src/pipen.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 A single 4-phase 1-of-n pipeline stage.
 
 History:
 05/05/2009  Initial version. <wsong83@gmail.com>
 01/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module pipen(/*AUTOARG*/
   // Outputs
   d_in_a, d_out,
   // Inputs
   d_in, d_out_a
   );

   parameter DW = 4;		// the wire count, the "n" of the 1-of-n code
       
   input [DW-1:0]   d_in;
   output 	    d_in_a;
   output [DW-1:0]  d_out;
   input 	    d_out_a;

   genvar 	    i;
   
   // the data pipe stage
   generate for (i=0; i<DW; i=i+1) begin:DD
       dc2 DC  (.d(d_in[i]),       .a(d_out_a),   .q(d_out[i]));
   end endgenerate

   assign d_in_a = |d_out;

endmodule // pipen

// -----------------------------------------------------------------------------
// Source file: vc/src/ddmux.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Demux for a 1-of-n buffer stage.  
 
 History:
 31/03/2010  Initial version. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  Make sure the sel pin is considered in the ack process. <wsong83@gmail.com>
 
*/

module ddmux ( /*AUTOARG*/
   // Outputs
   d_in_a, d_out,
   // Inputs
   d_in, d_sel, d_out_a
   );
   parameter VCN = 2;		// number of output VCs
   parameter DW = 32;		// data width of the input

   input [DW-1:0]   d_in;
   input [VCN-1:0]  d_sel;
   output 	    d_in_a;

   output [VCN-1:0][DW-1:0]  d_out;
   input  [VCN-1:0]	     d_out_a;
      
   genvar 		      i,j;

   /*
   generate
      for (i=0; i<VCN; i++) begin: VCD
	 for(j=0; j<DW; j++) begin: D
	    c2 C (.a0(d_in[j]), .a1(d_sel[i]), .q(d_out[i][j]));
	 end
      end
   endgenerate
    */
   
   generate
      for (i=0; i<VCN; i++) begin: VCD
	 assign d_out[i] = d_sel[i] ? d_in : 0;
      end
   endgenerate   
   
   //assign d_in_a = |d_out_a;
   c2 CACK (.a0(|d_out_a), .a1(|d_sel), .q(d_in_a));

endmodule // ddmux


// -----------------------------------------------------------------------------
// Source file: vc/src/rtu.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The routing calculation unit in every input buffer.
 p0 -> L -> p1 -> RTC -> p2 -> L -> p3 -> DEMUX -> p[0] -> L -> p[1] -> L -> p[2] -> L -> p[3] -> L -> p[4]  
 
 History:
 02/04/2010  Initial version. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  The selection pin of the demux must be considered in the ack process. <wsong83@gmail.com>
 
*/

module rtu (/*AUTOARG*/
   // Outputs
   dia, dort,
   // Inputs
   rst_n, di0, di1, di2, di3, dit, divc, addrx, addry, doa
   );
   parameter VCN = 2;
   parameter DIR = 0;
   parameter SN = 4;
   parameter PD = 2;

   input            rst_n;
   input [3:0]      di0, di1, di2, di3;
   input [2:0] 	    dit;
   input [VCN-1:0]  divc;
   output 	    dia;

   input [7:0] 	    addrx, addry;

   output [VCN-1:0][SN-1:0] dort;
   input [VCN-1:0] 	    doa;

   //------------------------------------------
   wire 	    p0an, p0ap, p0den, p0ad, p0avc;
   wire [3:0] 	    p1d0, p1d1, p1d2, p1d3;
   wire [VCN-1:0]   p1vc;
   wire 	    p1a, p1ad, p1avc, p1an;
   wire [SN-1:0]    p2d;
   wire [VCN-1:0]   p2vc;
   wire 	    p2a, p2ad, p2avc, p2an;
   wire [SN-1:0]    p3d;
   wire [VCN-1:0]   p3vc;
   wire 	    p3a, p3an;
   wire [PD*2:0][VCN-1:0][SN-1:0] pd;
   wire [PD*2:0][VCN-1:0] 	  pda, pdan;

   wire [2:0] 			  x_cmp [1:0];
   wire [2:0] 			  y_cmp [1:0];
   wire [5:0] 			  dec;
   wire 			  ds, dw, dn, de, dl;
   

   genvar 			  gvc, gbd, i;

   //------------------------------------------
   // p0 -> L -> p1

   c2 CP0DE ( .a0(dit[0]), .a1(p1an), .q(p0den));
   c2 CP0A  ( .a0(p0ad), .a1(p0avc), .q(p0ap));
   assign p0an = |dit[2:1];
   assign dia = p0an | p0ap;
   
   pipe4 #(.DW(8))
   L0D (
	.ia ( p0ad   ), 
	.o0 ( p1d0   ), 
	.o1 ( p1d1   ),
	.o2 ( p1d2   ), 
	.o3 ( p1d3   ), 
	.i0 ( di0    ),
	.i1 ( di1    ), 
	.i2 ( di2    ),
	.i3 ( di3    ),
	.oa ( p0den  )
	);

   pipen #(.DW(VCN))
   L0V (
	.d_in    ( divc    ),
	.d_in_a  ( p0avc   ),
	.d_out   ( p1vc    ),
	.d_out_a ( p0den   )
	);

   // p1 -> RTC -> p2
   comp4 X0 ( .a({p1d3[0], p1d2[0], p1d1[0], p1d0[0]}), .b(addrx[3:0]), .q(x_cmp[0]));
   comp4 X1 ( .a({p1d3[1], p1d2[1], p1d1[1], p1d0[1]}), .b(addrx[7:4]), .q(x_cmp[1]));
   comp4 Y0 ( .a({p1d3[2], p1d2[2], p1d1[2], p1d0[2]}), .b(addry[3:0]), .q(y_cmp[0]));
   comp4 Y1 ( .a({p1d3[3], p1d2[3], p1d1[3], p1d0[3]}), .b(addry[7:4]), .q(y_cmp[1]));

   assign dec[0] = x_cmp[1][0] | (x_cmp[1][2]&x_cmp[0][0]);       // frame x > addr x
   assign dec[1] = x_cmp[1][1] | (x_cmp[1][2]&x_cmp[0][1]);       // frame x < addr x
   assign dec[2] = x_cmp[1][2] & x_cmp[0][2];                     // frame x = addr x
   assign dec[3] = y_cmp[1][0] | (y_cmp[1][2]&y_cmp[0][0]);       // frame y > addr y
   assign dec[4] = y_cmp[1][1] | (y_cmp[1][2]&y_cmp[0][1]);       // frame y < addr y
   assign dec[5] = y_cmp[1][2] & y_cmp[0][2];                     // frame y = addr y

   assign ds = dec[0];
   assign dw = dec[2]&dec[4];
   assign dn = dec[1];
   assign de = dec[2]&dec[3];
   assign dl = dec[2]&dec[5];
   
   assign p2d =  
		   DIR == 0 ?   {dl, de, dn, dw}  :       // south port
                   DIR == 1 ?   {dl, de}          :       // west port
                   DIR == 2 ?   {dl, de, dw, ds}  :       // north port
                   DIR == 3 ?   {dl, dw}          :       // east port
                                {de, dn, dw, ds}  ;       // local port

   assign p2vc = p1vc;
   assign p1an = p2an;

   // p2 -> L -> p3

   c2 CP2A  ( .a0(p2ad), .a1(p2avc), .q(p2a));
   assign p2an = (~p2a) & rst_n;

   pipen #(.DW(SN))
   L2R (
	.d_in    ( p2d     ),
	.d_in_a  ( p2ad    ),
	.d_out   ( p3d     ),
	.d_out_a ( p3an    )
	);
          
   pipen #(.DW(VCN))
   L2V (
	.d_in    ( p2vc    ),
	.d_in_a  ( p2avc   ),
	.d_out   ( p3vc    ),
	.d_out_a ( p3an    )
	);

   // p3 -> DEMUX -> pd[0]
   ddmux #(.DW(SN), .VCN(VCN))
   RTDM (
	 .d_in_a  ( p3a   ), 
	 .d_out   ( pd[0] ),
	 .d_in    ( p3d   ), 
	 .d_sel   ( p3vc  ), 
	 .d_out_a ( pda[0])
	 );

   //c2 CP3A (.q(p3a), .a0(p3ad), .a1(|p3vc));
   assign p3an = (~p3a) & rst_n;

   // pd pipeline
   generate
      for(gbd=0; gbd<PD*2; gbd++) begin:RT
	 for(gvc=0; gvc<VCN; gvc++) begin:V
	    pipen #(.DW(SN))
	    P (
	       .d_in    ( pd[gbd][gvc]     ),
	       .d_in_a  ( pda[gbd][gvc]    ),
	       .d_out   ( pd[gbd+1][gvc]   ),
	       .d_out_a ( pdan[gbd+1][gvc] )
	       );
	    assign pdan[gbd+1][gvc] = (~pda[gbd+1][gvc])&rst_n;
	 end
      end // block: RT
   endgenerate

   // output
   generate
      for(gvc=0; gvc<VCN; gvc++) begin:OV
	 assign dort[gvc] = pd[PD*2][gvc];
	 assign pda[PD*2][gvc] = doa[gvc];
      end
   endgenerate

endmodule // rtu

   

   

// -----------------------------------------------------------------------------
// Source file: vc/src/vcdmux.v
// -----------------------------------------------------------------------------
/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Demux for a VC buffer stage.  
 
 History:
 31/03/2010  Initial version. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  Make sure the sel pin is considered in the ack process. <wsong83@gmail.com>

*/

module vcdmux ( /*AUTOARG*/
   // Outputs
   dia, do0, do1, do2, do3, dot,
   // Inputs
   di0, di1, di2, di3, dit, divc, doa
   );
   parameter VCN = 2;		// number of output VCs
   parameter DW = 32;		// data width of the input
   parameter SCN = DW/2;

   input [SCN-1:0]  di0, di1, di2, di3;
   input [2:0] 	    dit;
   input [VCN-1:0]  divc;
   output 	    dia;

   output [VCN-1:0][SCN-1:0] do0, do1, do2, do3;
   output [VCN-1:0][2:0]     dot;
   input  [VCN-1:0]	     doa;
      
   genvar 		      i,j;

   /*
   generate
      for (i=0; i<VCN; i++) begin: VCD
	 for(j=0; j<SCN; j++) begin: D
	    c2 C0 (.a0(di0[j]), .a1(divc[i]), .q(do0[i][j]));
	    c2 C1 (.a0(di1[j]), .a1(divc[i]), .q(do1[i][j]));
	    c2 C2 (.a0(di2[j]), .a1(divc[i]), .q(do2[i][j]));
	    c2 C3 (.a0(di3[j]), .a1(divc[i]), .q(do3[i][j]));
	 end
	 
	 for(j=0; j<3; j++) begin: T
	    c2 C0 (.a0(dit[j]), .a1(divc[i]), .q(dot[i][j]));
	 end
      end
   endgenerate
    */
   
   generate
      for (i=0; i<VCN; i++) begin: VCD
	 assign do0[i] = divc[i] ? di0 : 0;
	 assign do1[i] = divc[i] ? di1 : 0;
	 assign do2[i] = divc[i] ? di2 : 0;
	 assign do3[i] = divc[i] ? di3 : 0;
	 assign dot[i] = divc[i] ? dit : 0;
      end
   endgenerate   

   //assign dia = |doa;
   c2 CACK (.a0(|doa), .a1(|divc), .q(dia));

endmodule // vcdmux

