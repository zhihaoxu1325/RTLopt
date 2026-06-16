// Curated RTL benchmark case.
// case_id: bench_0207_memory_core_8_16_32_bit_sdram_controller
// source_project: memory_core_8-16-32_bit_sdram_controller
// top_module: sdrc_core


// -----------------------------------------------------------------------------
// Source file: rtl/core/sdrc_define.v
// -----------------------------------------------------------------------------

`define SDR_REQ_ID_W       4

`define SDR_RFSH_TIMER_W    12
`define SDR_RFSH_ROW_CNT_W   3

// B2X Command

`define OP_PRE           2'b00
`define OP_ACT           2'b01
`define OP_RD            2'b10
`define OP_WR            2'b11

// SDRAM Commands (CS_N, RAS_N, CAS_N, WE_N)

`define SDR_DESEL        4'b1111
`define SDR_NOOP         4'b0111
`define SDR_ACTIVATE     4'b0011
`define SDR_READ         4'b0101
`define SDR_WRITE        4'b0100
`define SDR_BT           4'b0110
`define SDR_PRECHARGE    4'b0010
`define SDR_REFRESH      4'b0001
`define SDR_MODE         4'b0000

`define  ASIC            1'b1
`define  FPGA            1'b0
`define  TARGET_DESIGN   `FPGA
// 12 bit subtractor is not feasibile for FPGA, so changed to 6 bits
`define  REQ_BW    (`TARGET_DESIGN == `FPGA) ? 6 : 12   //  Request Width


// -----------------------------------------------------------------------------
// Source file: rtl/core/sdrc_core.v
// -----------------------------------------------------------------------------
/*********************************************************************
                                                              
  SDRAM Controller Core File                                  
                                                              
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
                                                              
  Description: SDRAM Controller Core Module
    2 types of SDRAMs are supported, 1Mx16 2 bank, or 4Mx16 4 bank.
    This block integrate following sub modules

    sdrc_bs_convert   
        convert the system side 32 bit into equvailent 8/16/32 SDR format
    sdrc_req_gen    
        This module takes requests from the app, chops them to burst booundaries
        if wrap=0, decodes the bank and passe the request to bank_ctl
   sdrc_xfr_ctl
      This module takes requests from sdr_bank_ctl, runs the transfer and
      controls data flow to/from the app. At the end of the transfer it issues a
      burst terminate if not at the end of a burst and another command to this
      bank is not available.

   sdrc_bank_ctl
      This module takes requests from sdr_req_gen, checks for page hit/miss and
      issues precharge/activate commands and then passes the request to
      sdr_xfr_ctl. 


  Assumption: SDRAM Pads should be placed near to this module. else
  user should add a FF near the pads
                                                              
  To Do:                                                      
    nothing                                                   
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  : 0.0 - 8th Jan 2012
                Initial version with 16/32 Bit SDRAM Support
           : 0.1 - 24th Jan 2012
	         8 Bit SDRAM Support is added
             0.2 - 2nd Feb 2012
	           Improved the command pipe structure to accept up-to 
		   4 command of different bank.
	     0.3 - 7th Feb 2012
	           Bug fix for parameter defination for request length has changed from 9 to 12
             0.4 - 26th April 2013
                   SDRAM Address Bit is Extended by 12 bit to 13 bit to support higher SDRAM

                                                             
 Copyright (C) 2000 Authors and OPENCORES.ORG                
                                                             
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
                                                              
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
                                                              
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
                                                              
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
                                                              
*******************************************************************/


`include "sdrc_define.v"
module sdrc_core 
           (
		clk,
                pad_clk,
		reset_n,
                sdr_width,
		cfg_colbits,

		/* Request from app */
		app_req,	        // Transfer Request
		app_req_addr,	        // SDRAM Address
		app_req_len,	        // Burst Length (in 16 bit words)
		app_req_wrap,	        // Wrap mode request (xfr_len = 4)
		app_req_wr_n,	        // 0 => Write request, 1 => read req
		app_req_ack,	        // Request has been accepted
		cfg_req_depth,	        //how many req. buffer should hold
		
		app_wr_data,
                app_wr_en_n,
		app_last_wr,

		app_rd_data,
		app_rd_valid,
		app_last_rd,
		app_wr_next_req,
		sdr_init_done,
		app_req_dma_last,

		/* Interface to SDRAMs */
		sdr_cs_n,
		sdr_cke,
		sdr_ras_n,
		sdr_cas_n,
		sdr_we_n,
		sdr_dqm,
		sdr_ba,
		sdr_addr, 
		pad_sdr_din,
		sdr_dout,
		sdr_den_n,

		/* Parameters */
		cfg_sdr_en,
		cfg_sdr_mode_reg,
		cfg_sdr_tras_d,
		cfg_sdr_trp_d,
		cfg_sdr_trcd_d,
		cfg_sdr_cas,
		cfg_sdr_trcar_d,
		cfg_sdr_twr_d,
		cfg_sdr_rfsh,
		cfg_sdr_rfmax);
  
parameter  APP_AW   = 26;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width
parameter  APP_RW   = 9;   // Application Request Width

parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
             

//-----------------------------------------------
// Global Variable
// ----------------------------------------------
input                   clk                 ; // SDRAM Clock 
input                   pad_clk             ; // SDRAM Clock from Pad, used for registering Read Data
input                   reset_n             ; // Reset Signal
input [1:0]             sdr_width           ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
input [1:0]             cfg_colbits         ; // 2'b00 - 8 Bit column address, 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits


//------------------------------------------------
// Request from app
//------------------------------------------------
input 			app_req             ; // Application Request
input [APP_AW-1:0] 	app_req_addr        ; // Address 
input 			app_req_wr_n        ; // 0 - Write, 1 - Read
input                   app_req_wrap        ; // Address Wrap
output                  app_req_ack         ; // Application Request Ack
		
input [APP_DW-1:0] 	app_wr_data         ; // Write Data
output 		        app_wr_next_req     ; // Next Write Data Request
input [APP_BW-1:0] 	app_wr_en_n         ; // Byte wise Write Enable
output                  app_last_wr         ; // Last Write trannsfer of a given Burst
output [APP_DW-1:0] 	app_rd_data         ; // Read Data
output                  app_rd_valid        ; // Read Valid
output                  app_last_rd         ; // Last Read Transfer of a given Burst
		
//------------------------------------------------
// Interface to SDRAMs
//------------------------------------------------
output                  sdr_cke             ; // SDRAM CKE
output 			sdr_cs_n            ; // SDRAM Chip Select
output                  sdr_ras_n           ; // SDRAM ras
output                  sdr_cas_n           ; // SDRAM cas
output			sdr_we_n            ; // SDRAM write enable
output [SDR_BW-1:0] 	sdr_dqm             ; // SDRAM Data Mask
output [1:0] 		sdr_ba              ; // SDRAM Bank Enable
output [12:0] 		sdr_addr            ; // SDRAM Address
input [SDR_DW-1:0] 	pad_sdr_din         ; // SDRA Data Input
output [SDR_DW-1:0] 	sdr_dout            ; // SDRAM Data Output
output [SDR_BW-1:0] 	sdr_den_n           ; // SDRAM Data Output enable

//------------------------------------------------
// Configuration Parameter
//------------------------------------------------
output                  sdr_init_done       ; // Indicate SDRAM Initialisation Done
input [3:0] 		cfg_sdr_tras_d      ; // Active to precharge delay
input [3:0]             cfg_sdr_trp_d       ; // Precharge to active delay
input [3:0]             cfg_sdr_trcd_d      ; // Active to R/W delay
input 			cfg_sdr_en          ; // Enable SDRAM controller
input [1:0] 		cfg_req_depth       ; // Maximum Request accepted by SDRAM controller
input [APP_RW-1:0]	app_req_len         ; // Application Burst Request length in 32 bit 
input [12:0] 		cfg_sdr_mode_reg    ;
input [2:0] 		cfg_sdr_cas         ; // SDRAM CAS Latency
input [3:0] 		cfg_sdr_trcar_d     ; // Auto-refresh period
input [3:0]             cfg_sdr_twr_d       ; // Write recovery delay
input [`SDR_RFSH_TIMER_W-1 : 0] cfg_sdr_rfsh;
input [`SDR_RFSH_ROW_CNT_W -1 : 0] cfg_sdr_rfmax;
input                   app_req_dma_last;    // this signal should close the bank

/****************************************************************************/
// Internal Nets
   
// SDR_REQ_GEN
wire [`SDR_REQ_ID_W-1:0]r2b_req_id;
wire [1:0] 		r2b_ba;
wire [12:0] 		r2b_raddr;
wire [12:0] 		r2b_caddr;
wire [`REQ_BW-1:0] 	r2b_len;

// SDR BANK CTL
wire [`SDR_REQ_ID_W-1:0]b2x_id;
wire [1:0] 		b2x_ba;
wire [12:0] 		b2x_addr;
wire [`REQ_BW-1:0] 	b2x_len;
wire [1:0] 		b2x_cmd;

// SDR_XFR_CTL
wire [3:0] 		x2b_pre_ok;
wire [`SDR_REQ_ID_W-1:0]xfr_id;
wire [APP_DW-1:0] 	app_rd_data;
wire 			sdr_cs_n, sdr_cke, sdr_ras_n, sdr_cas_n, sdr_we_n; 
wire [SDR_BW-1:0] 	sdr_dqm;
wire [1:0] 		sdr_ba;
wire [12:0] 		sdr_addr;
wire [SDR_DW-1:0] 	sdr_dout;
wire [SDR_DW-1:0] 	sdr_dout_int;
wire [SDR_BW-1:0] 	sdr_den_n;
wire [SDR_BW-1:0] 	sdr_den_n_int;

wire [1:0] 		xfr_bank_sel;

wire [APP_AW-1:0]        app_req_addr;
wire [APP_RW-1:0]        app_req_len;

wire [APP_DW-1:0]        app_wr_data;
wire [SDR_DW-1:0]        a2x_wrdt       ;
wire [APP_BW-1:0]        app_wr_en_n;
wire [SDR_BW-1:0]        a2x_wren_n;

//wire [31:0] app_rd_data;
wire [SDR_DW-1:0]        x2a_rddt;


// synopsys translate_off 
   wire [3:0]           sdr_cmd;
   assign sdr_cmd = {sdr_cs_n, sdr_ras_n, sdr_cas_n, sdr_we_n}; 
// synopsys translate_on 

assign sdr_den_n = sdr_den_n_int ; 
assign sdr_dout  = sdr_dout_int ;


// To meet the timing at read path, read data is registered w.r.t pad_sdram_clock and register back to sdram_clk
// assumption, pad_sdram_clk is synhronous and delayed clock of sdram_clk.
// register w.r.t pad sdram clk
reg [SDR_DW-1:0] pad_sdr_din1;
reg [SDR_DW-1:0] pad_sdr_din2;
always@(posedge pad_clk) begin
   pad_sdr_din1 <= pad_sdr_din;
end

always@(posedge clk) begin
   pad_sdr_din2 <= pad_sdr_din1;
end


   /****************************************************************************/
   // Instantiate sdr_req_gen
   // This module takes requests from the app, chops them to burst booundaries
   // if wrap=0, decodes the bank and passe the request to bank_ctl

sdrc_req_gen #(.SDR_DW(SDR_DW) , .SDR_BW(SDR_BW)) u_req_gen (
          .clk                (clk          ),
          .reset_n            (reset_n            ),
	  .cfg_colbits        (cfg_colbits        ),
          .sdr_width          (sdr_width          ),

	/* Req to xfr_ctl */
          .r2x_idle           (r2x_idle           ),

	/* Request from app */
          .req                (app_req            ),
          .req_id             (4'b0               ),
          .req_addr           (app_req_addr       ),
          .req_len            (app_req_len        ),
          .req_wrap           (app_req_wrap       ),
          .req_wr_n           (app_req_wr_n       ),
          .req_ack            (app_req_ack        ),
		
       /* Req to bank_ctl */
          .r2b_req            (r2b_req            ),
          .r2b_req_id         (r2b_req_id         ),
          .r2b_start          (r2b_start          ),
          .r2b_last           (r2b_last           ),
          .r2b_wrap           (r2b_wrap           ),
          .r2b_ba             (r2b_ba             ),
          .r2b_raddr          (r2b_raddr          ),
          .r2b_caddr          (r2b_caddr          ),
          .r2b_len            (r2b_len            ),
          .r2b_write          (r2b_write          ),
          .b2r_ack            (b2r_ack            ),
          .b2r_arb_ok         (b2r_arb_ok         )
     );

   /****************************************************************************/
   // Instantiate sdr_bank_ctl
   // This module takes requests from sdr_req_gen, checks for page hit/miss and
   // issues precharge/activate commands and then passes the request to
   // sdr_xfr_ctl. 

sdrc_bank_ctl #(.SDR_DW(SDR_DW) ,  .SDR_BW(SDR_BW)) u_bank_ctl (
          .clk                (clk          ),
          .reset_n            (reset_n            ),
          .a2b_req_depth      (cfg_req_depth      ),
			      
      /* Req from req_gen */
          .r2b_req            (r2b_req            ),
          .r2b_req_id         (r2b_req_id         ),
          .r2b_start          (r2b_start          ),
          .r2b_last           (r2b_last           ),
          .r2b_wrap           (r2b_wrap           ),
          .r2b_ba             (r2b_ba             ),
          .r2b_raddr          (r2b_raddr          ),
          .r2b_caddr          (r2b_caddr          ),
          .r2b_len            (r2b_len            ),
          .r2b_write          (r2b_write          ),
          .b2r_arb_ok         (b2r_arb_ok         ),
          .b2r_ack            (b2r_ack            ),
			      
      /* Transfer request to xfr_ctl */
          .b2x_idle           (b2x_idle           ),
          .b2x_req            (b2x_req            ),
          .b2x_start          (b2x_start          ),
          .b2x_last           (b2x_last           ),
          .b2x_wrap           (b2x_wrap           ),
          .b2x_id             (b2x_id             ),
          .b2x_ba             (b2x_ba             ),
          .b2x_addr           (b2x_addr           ),
          .b2x_len            (b2x_len            ),
          .b2x_cmd            (b2x_cmd            ),
          .x2b_ack            (x2b_ack            ),
		     
      /* Status from xfr_ctl */
          .b2x_tras_ok        (b2x_tras_ok        ),
          .x2b_refresh        (x2b_refresh        ),
          .x2b_pre_ok         (x2b_pre_ok         ),
          .x2b_act_ok         (x2b_act_ok         ),
          .x2b_rdok           (x2b_rdok           ),
          .x2b_wrok           (x2b_wrok           ),

      /* for generate cuurent xfr address msb */
          .sdr_req_norm_dma_last(app_req_dma_last),
          .xfr_bank_sel       (xfr_bank_sel       ),

       /* SDRAM Timing */
          .tras_delay         (cfg_sdr_tras_d     ),
          .trp_delay          (cfg_sdr_trp_d      ),
          .trcd_delay         (cfg_sdr_trcd_d     )
      );
   
   /****************************************************************************/
   // Instantiate sdr_xfr_ctl
   // This module takes requests from sdr_bank_ctl, runs the transfer and
   // controls data flow to/from the app. At the end of the transfer it issues a
   // burst terminate if not at the end of a burst and another command to this
   // bank is not available.

sdrc_xfr_ctl #(.SDR_DW(SDR_DW) ,  .SDR_BW(SDR_BW)) u_xfr_ctl (
          .clk                (clk          ),
          .reset_n            (reset_n            ),
			    
      /* Transfer request from bank_ctl */
          .r2x_idle           (r2x_idle           ),
          .b2x_idle           (b2x_idle           ),
          .b2x_req            (b2x_req            ),
          .b2x_start          (b2x_start          ),
          .b2x_last           (b2x_last           ),
          .b2x_wrap           (b2x_wrap           ),
          .b2x_id             (b2x_id             ),
          .b2x_ba             (b2x_ba             ),
          .b2x_addr           (b2x_addr           ),
          .b2x_len            (b2x_len            ),
          .b2x_cmd            (b2x_cmd            ),
          .x2b_ack            (x2b_ack            ),
		     
       /* Status to bank_ctl, req_gen */
          .b2x_tras_ok        (b2x_tras_ok        ),
          .x2b_refresh        (x2b_refresh        ),
          .x2b_pre_ok         (x2b_pre_ok         ),
          .x2b_act_ok         (x2b_act_ok         ),
          .x2b_rdok           (x2b_rdok           ),
          .x2b_wrok           (x2b_wrok           ),
		    
       /* SDRAM I/O */
          .sdr_cs_n           (sdr_cs_n           ),
          .sdr_cke            (sdr_cke            ),
          .sdr_ras_n          (sdr_ras_n          ),
          .sdr_cas_n          (sdr_cas_n          ),
          .sdr_we_n           (sdr_we_n           ),
          .sdr_dqm            (sdr_dqm            ),
          .sdr_ba             (sdr_ba             ),
          .sdr_addr           (sdr_addr           ),
          .sdr_din            (pad_sdr_din2       ),
          .sdr_dout           (sdr_dout_int       ),
          .sdr_den_n          (sdr_den_n_int      ),
      /* Data Flow to the app */
          .x2a_rdstart        (x2a_rdstart        ),
          .x2a_wrstart        (x2a_wrstart        ),
          .x2a_id             (xfr_id             ),
          .x2a_rdlast         (x2a_rdlast         ),
          .x2a_wrlast         (x2a_wrlast         ),
          .a2x_wrdt           (a2x_wrdt           ),
          .a2x_wren_n         (a2x_wren_n         ),
          .x2a_wrnext         (x2a_wrnext         ),
          .x2a_rddt           (x2a_rddt           ),
          .x2a_rdok           (x2a_rdok           ),
          .sdr_init_done      (sdr_init_done      ),
			    
      /* SDRAM Parameters */
          .sdram_enable       (cfg_sdr_en         ),
          .sdram_mode_reg     (cfg_sdr_mode_reg   ),
		    
      /* current xfr bank */
          .xfr_bank_sel       (xfr_bank_sel       ),

      /* SDRAM Timing */
          .cas_latency        (cfg_sdr_cas        ),
          .trp_delay          (cfg_sdr_trp_d      ),
          .trcar_delay        (cfg_sdr_trcar_d    ),
          .twr_delay          (cfg_sdr_twr_d      ),
          .rfsh_time          (cfg_sdr_rfsh       ),
          .rfsh_rmax          (cfg_sdr_rfmax      )
    );
   
   /****************************************************************************/
   // Instantiate sdr_bs_convert
   //    This model handle the bus with transaltion from application layer to
   //       8/16/32 SDRAM Memory format
   //     During Write Phase, this block split the data as per SDRAM Width
   //     During Read Phase, This block does the re-packing based on SDRAM
   //     Width
   //---------------------------------------------------------------------------
sdrc_bs_convert #(.SDR_DW(SDR_DW) ,  .SDR_BW(SDR_BW)) u_bs_convert (
          .clk                (clk          ),
          .reset_n            (reset_n            ),
          .sdr_width          (sdr_width          ),

   /* Control Signal from xfr ctrl */
          // Read Interface Inputs
          .x2a_rdstart        (x2a_rdstart        ),
          .x2a_rdlast         (x2a_rdlast         ),
          .x2a_rdok           (x2a_rdok           ),
	  // Read Interface outputs
          .x2a_rddt           (x2a_rddt           ),

          // Write Interface, Inputs
          .x2a_wrstart        (x2a_wrstart        ),
          .x2a_wrlast         (x2a_wrlast         ),
          .x2a_wrnext         (x2a_wrnext         ),

          // Write Interface, Outputs
          .a2x_wrdt           (a2x_wrdt           ),
          .a2x_wren_n         (a2x_wren_n         ),

   /* Control Signal from sdrc_bank_ctl  */

   /*  Control Signal from/to to application i/f  */
          .app_wr_data        (app_wr_data        ),
          .app_wr_en_n        (app_wr_en_n        ),
          .app_wr_next        (app_wr_next_req    ),
	  .app_last_wr        (app_last_wr        ),
          .app_rd_data        (app_rd_data        ),
          .app_rd_valid       (app_rd_valid       ),
	  .app_last_rd        (app_last_rd        )

       );   
   
endmodule // sdrc_core

// -----------------------------------------------------------------------------
// Source file: rtl/core/sdrc_bank_ctl.v
// -----------------------------------------------------------------------------
/*********************************************************************
                                                              
  SDRAM Controller Bank Controller
                                                              
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
                                                              
  Description: 
    This module takes requests from sdrc_req_gen, checks for page hit/miss and
    issues precharge/activate commands and then passes the request to sdrc_xfr_ctl. 
                                                              
  To Do:                                                      
    nothing                                                   
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  :  1.0  - 8th Jan 2012
                                                              

                                                             
 Copyright (C) 2000 Authors and OPENCORES.ORG                
                                                             
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
                                                              
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
                                                              
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
                                                              
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
                                                              
*******************************************************************/


`include "sdrc_define.v"

module sdrc_bank_ctl (clk,
		     reset_n,
		     a2b_req_depth,  // Number of requests we can buffer

		     /* Req from req_gen */
		     r2b_req,	   // request
		     r2b_req_id,   // ID
		     r2b_start,	   // First chunk of burst
		     r2b_last,	   // Last chunk of burst
		     r2b_wrap,
		     r2b_ba,	   // bank address
		     r2b_raddr,	   // row address
		     r2b_caddr,	   // col address
		     r2b_len,	   // length
		     r2b_write,	   // write request
		     b2r_arb_ok,   // OK to arbitrate for next xfr
		     b2r_ack,

		     /* Transfer request to xfr_ctl */
		     b2x_idle,	   // All banks are idle
		     b2x_req,	   // Request to xfr_ctl
		     b2x_start,	   // first chunk of transfer
		     b2x_last,	   // last chunk of transfer
		     b2x_wrap,
		     b2x_id,	   // Transfer ID
		     b2x_ba,	   // bank address
		     b2x_addr,	   // row/col address
		     b2x_len,	   // transfer length
		     b2x_cmd,	   // transfer command
		     x2b_ack,	   // command accepted
		     
		     /* Status to/from xfr_ctl */
		     b2x_tras_ok,  // TRAS OK for all banks
		     x2b_refresh,  // We did a refresh
		     x2b_pre_ok,   // OK to do a precharge (per bank)
		     x2b_act_ok,   // OK to do an activate
		     x2b_rdok,	   // OK to do a read
		     x2b_wrok,	   // OK to do a write

		     /* xfr msb address */
		     xfr_bank_sel,
                     sdr_req_norm_dma_last,

		     /* SDRAM Timing */
		     tras_delay,   // Active to precharge delay
		     trp_delay,	   // Precharge to active delay
		     trcd_delay);  // Active to R/W delay
   
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
   input                        clk, reset_n;

   input [1:0] 			a2b_req_depth;
   
   /* Req from bank_ctl */
   input 			r2b_req, r2b_start, r2b_last,
				r2b_write, r2b_wrap;
   input [`SDR_REQ_ID_W-1:0] 	r2b_req_id;
   input [1:0] 			r2b_ba;
   input [12:0] 		r2b_raddr;
   input [12:0] 		r2b_caddr;
   input [`REQ_BW-1:0] 	        r2b_len;
   output 			b2r_arb_ok, b2r_ack;
   input                        sdr_req_norm_dma_last;

   /* Req to xfr_ctl */
   output 			b2x_idle, b2x_req, b2x_start, b2x_last,
				b2x_tras_ok, b2x_wrap;
   output [`SDR_REQ_ID_W-1:0] 	b2x_id;
   output [1:0] 		b2x_ba;
   output [12:0] 		b2x_addr;
   output [`REQ_BW-1:0] 	b2x_len;
   output [1:0] 		b2x_cmd;
   input 			x2b_ack;

   /* Status from xfr_ctl */
   input [3:0] 			x2b_pre_ok;
   input 			x2b_refresh, x2b_act_ok, x2b_rdok,
				x2b_wrok;
   
   input [3:0] 			tras_delay, trp_delay, trcd_delay;

   input [1:0] xfr_bank_sel;

   /****************************************************************************/
   // Internal Nets

   wire [3:0] 			r2i_req, i2r_ack, i2x_req, 
				i2x_start, i2x_last, i2x_wrap, tras_ok;
   wire [12:0] 			i2x_addr0, i2x_addr1, i2x_addr2, i2x_addr3;
   wire [`REQ_BW-1:0] 	i2x_len0, i2x_len1, i2x_len2, i2x_len3;
   wire [1:0] 			i2x_cmd0, i2x_cmd1, i2x_cmd2, i2x_cmd3;
   wire [`SDR_REQ_ID_W-1:0] 	i2x_id0, i2x_id1, i2x_id2, i2x_id3;

   reg 				b2x_req;
   wire 			b2x_idle, b2x_start, b2x_last, b2x_wrap;
   wire [`SDR_REQ_ID_W-1:0] 	b2x_id;
   wire [12:0] 			b2x_addr;
   wire [`REQ_BW-1:0] 	b2x_len;
   wire [1:0] 			b2x_cmd;
   wire [3:0] 			x2i_ack;
   reg [1:0] 			b2x_ba;
   
   reg [`SDR_REQ_ID_W-1:0] 	curr_id;

   wire [1:0] 			xfr_ba;
   wire  			xfr_ba_last;
   wire [3:0] 			xfr_ok;

   // This 8 bit register stores the bank addresses for upto 4 requests.
   reg [7:0] 			rank_ba;
   reg [3:0] 			rank_ba_last;
   // This 3 bit counter counts the number of requests we have
   // buffered so far, legal values are 0, 1, 2, 3, or 4.
   reg [2:0] 			rank_cnt;
   wire [3:0] 			rank_req, rank_wr_sel;
   wire 			rank_fifo_wr, rank_fifo_rd;
   wire 			rank_fifo_full, rank_fifo_mt;
   
   wire [12:0] bank0_row, bank1_row, bank2_row, bank3_row;

   assign  b2x_tras_ok        = &tras_ok;


   // Distribute the request from req_gen

   assign r2i_req[0] = (r2b_ba == 2'b00) ? r2b_req & ~rank_fifo_full : 1'b0;
   assign r2i_req[1] = (r2b_ba == 2'b01) ? r2b_req & ~rank_fifo_full : 1'b0;
   assign r2i_req[2] = (r2b_ba == 2'b10) ? r2b_req & ~rank_fifo_full : 1'b0;
   assign r2i_req[3] = (r2b_ba == 2'b11) ? r2b_req & ~rank_fifo_full : 1'b0;

   /******************
   Modified the Better FPGA Timing Purpose
   assign b2r_ack = (r2b_ba == 2'b00) ? i2r_ack[0] :
		    (r2b_ba == 2'b01) ? i2r_ack[1] :
		    (r2b_ba == 2'b10) ? i2r_ack[2] :
		    (r2b_ba == 2'b11) ? i2r_ack[3] : 1'b0;
   ********************/
   // Assumption: Only one Ack Will be asserted at a time.
   assign b2r_ack  =|i2r_ack; 

   assign b2r_arb_ok = ~rank_fifo_full;
   
   // Put the requests from the 4 bank_fsms into a 4 deep shift
   // register file. The earliest request is prioritized over the
   // later requests. Also the number of requests we are allowed to
   // buffer is limited by a 2 bit external input
   
   // Mux the req/cmd to xfr_ctl. Allow RD/WR commands from the request in
   // rank0, allow only PR/ACT commands from the requests in other ranks
   // If the rank_fifo is empty, send the request from the bank addressed by
   // r2b_ba 

   // In FPGA Mode, to improve the timing, also send the rank_ba
   assign xfr_ba = (`TARGET_DESIGN == `FPGA) ? rank_ba[1:0]:
	           ((rank_fifo_mt) ? r2b_ba : rank_ba[1:0]);
   assign xfr_ba_last = (`TARGET_DESIGN == `FPGA) ? rank_ba_last[0]:
	                ((rank_fifo_mt) ? sdr_req_norm_dma_last : rank_ba_last[0]);
   
   assign rank_req[0] = i2x_req[xfr_ba];     // each rank generates requests
			
   assign rank_req[1] = (rank_cnt < 3'h2) ? 1'b0 :
			(rank_ba[3:2] == 2'b00) ? i2x_req[0] & ~i2x_cmd0[1] :
			(rank_ba[3:2] == 2'b01) ? i2x_req[1] & ~i2x_cmd1[1] :
			(rank_ba[3:2] == 2'b10) ? i2x_req[2] & ~i2x_cmd2[1] : 
			i2x_req[3] & ~i2x_cmd3[1];
			
   assign rank_req[2] = (rank_cnt < 3'h3) ? 1'b0 :
			(rank_ba[5:4] == 2'b00) ? i2x_req[0] & ~i2x_cmd0[1] :
			(rank_ba[5:4] == 2'b01) ? i2x_req[1] & ~i2x_cmd1[1] :
			(rank_ba[5:4] == 2'b10) ? i2x_req[2] & ~i2x_cmd2[1] : 
			i2x_req[3] & ~i2x_cmd3[1];
			
   assign rank_req[3] = (rank_cnt < 3'h4) ? 1'b0 :
			(rank_ba[7:6] == 2'b00) ? i2x_req[0] & ~i2x_cmd0[1] :
			(rank_ba[7:6] == 2'b01) ? i2x_req[1] & ~i2x_cmd1[1] :
			(rank_ba[7:6] == 2'b10) ? i2x_req[2] & ~i2x_cmd2[1] : 
			i2x_req[3] & ~i2x_cmd3[1];
			
   always @ (*) begin
      b2x_req = 1'b0;
      b2x_ba =   xfr_ba;

      if(`TARGET_DESIGN == `ASIC) begin // Support Multiple Rank request only on ASIC
         if (rank_req[0]) begin 
	    b2x_req = 1'b1;
	    b2x_ba = xfr_ba;
         end // if (rank_req[0])
	 else if (rank_req[1]) begin 
	   b2x_req = 1'b1;
	   b2x_ba = rank_ba[3:2];
        end // if (rank_req[1])
        else if (rank_req[2]) begin 
	  b2x_req = 1'b1;
	  b2x_ba = rank_ba[5:4];
        end // if (rank_req[2])
        else if (rank_req[3]) begin 
	  b2x_req = 1'b1;
	  b2x_ba = rank_ba[7:6];
        end // if (rank_req[3])
      end else begin // If FPGA
         if (rank_req[0]) begin 
	    b2x_req = 1'b1;
	 end
      end
  end // always @ (rank_req or rank_fifo_mt or r2b_ba or rank_ba)

   assign b2x_idle = rank_fifo_mt;
   assign b2x_start = i2x_start[b2x_ba];
   assign b2x_last = i2x_last[b2x_ba];
   assign b2x_wrap = i2x_wrap[b2x_ba];

   assign b2x_addr = (b2x_ba == 2'b11) ? i2x_addr3 :
		     (b2x_ba == 2'b10) ? i2x_addr2 :
		     (b2x_ba == 2'b01) ? i2x_addr1 : i2x_addr0;
   
   assign b2x_len = (b2x_ba == 2'b11) ? i2x_len3 :
		    (b2x_ba == 2'b10) ? i2x_len2 :
		    (b2x_ba == 2'b01) ? i2x_len1 : i2x_len0;
   
   assign b2x_cmd = (b2x_ba == 2'b11) ? i2x_cmd3 :
		    (b2x_ba == 2'b10) ? i2x_cmd2 :
		    (b2x_ba == 2'b01) ? i2x_cmd1 : i2x_cmd0;
   
   assign b2x_id = (b2x_ba == 2'b11) ? i2x_id3 :
		   (b2x_ba == 2'b10) ? i2x_id2 :
		   (b2x_ba == 2'b01) ? i2x_id1 : i2x_id0;
   
   assign x2i_ack[0] = (b2x_ba == 2'b00) ? x2b_ack : 1'b0;
   assign x2i_ack[1] = (b2x_ba == 2'b01) ? x2b_ack : 1'b0;
   assign x2i_ack[2] = (b2x_ba == 2'b10) ? x2b_ack : 1'b0;
   assign x2i_ack[3] = (b2x_ba == 2'b11) ? x2b_ack : 1'b0;

   // Rank Fifo
   // On a write write to selected rank and increment rank_cnt
   // On a read shift rank_ba right 2 bits and decrement rank_cnt

   assign rank_fifo_wr = b2r_ack;

   assign rank_fifo_rd = b2x_req & b2x_cmd[1] & x2b_ack;
   
   assign rank_wr_sel[0] = (rank_cnt == 3'h0) ? rank_fifo_wr : 
			   (rank_cnt == 3'h1) ? rank_fifo_wr & rank_fifo_rd : 
			   1'b0;

   assign rank_wr_sel[1] = (rank_cnt == 3'h1) ? rank_fifo_wr & ~rank_fifo_rd :
			   (rank_cnt == 3'h2) ? rank_fifo_wr & rank_fifo_rd :
			   1'b0; 

   assign rank_wr_sel[2] = (rank_cnt == 3'h2) ? rank_fifo_wr & ~rank_fifo_rd :
			   (rank_cnt == 3'h3) ? rank_fifo_wr & rank_fifo_rd :
			   1'b0; 

   assign rank_wr_sel[3] = (rank_cnt == 3'h3) ? rank_fifo_wr & ~rank_fifo_rd :
			   (rank_cnt == 3'h4) ? rank_fifo_wr & rank_fifo_rd :
			   1'b0; 

   assign rank_fifo_mt = (rank_cnt == 3'b0) ? 1'b1 : 1'b0;

   assign rank_fifo_full = (rank_cnt[2]) ? 1'b1 : 
			   (rank_cnt[1:0] == a2b_req_depth) ? 1'b1 : 1'b0; 

   // FIFO Check

   // synopsys translate_off

   always @ (posedge clk) begin

      if (~rank_fifo_wr & rank_fifo_rd && rank_cnt == 3'h0) begin
	 $display ("%t: %m: ERROR!!! Read from empty Fifo", $time);
	 $stop;
      end // if (rank_fifo_rd && rank_cnt == 3'h0)

      if (rank_fifo_wr && ~rank_fifo_rd && rank_cnt == 3'h4) begin
	 $display ("%t: %m: ERROR!!! Write to full Fifo", $time);
	 $stop;
      end // if (rank_fifo_wr && ~rank_fifo_rd && rank_cnt == 3'h4)
      
   end // always @ (posedge clk)
   
   // synopsys translate_on
      
   always @ (posedge clk)
      if (~reset_n) begin
	 rank_cnt <= 3'b0;
	 rank_ba <= 8'b0;
	 rank_ba_last <= 4'b0;

      end // if (~reset_n)
      else begin

	 rank_cnt <= (rank_fifo_wr & ~rank_fifo_rd) ? rank_cnt + 3'b1 :
		     (~rank_fifo_wr & rank_fifo_rd) ? rank_cnt - 3'b1 :
		     rank_cnt;

	 rank_ba[1:0] <= (rank_wr_sel[0]) ? r2b_ba :
			 (rank_fifo_rd) ? rank_ba[3:2] : rank_ba[1:0];
	 
	 rank_ba[3:2] <= (rank_wr_sel[1]) ? r2b_ba :
			 (rank_fifo_rd) ? rank_ba[5:4] : rank_ba[3:2];
	 
	 rank_ba[5:4] <= (rank_wr_sel[2]) ? r2b_ba :
			 (rank_fifo_rd) ? rank_ba[7:6] : rank_ba[5:4];
	 
	 rank_ba[7:6] <= (rank_wr_sel[3]) ? r2b_ba :
			 (rank_fifo_rd) ? 2'b00 : rank_ba[7:6];

	 if(`TARGET_DESIGN == `ASIC) begin // This Logic is implemented for ASIC Only
	    // Note: Currenly top-level does not generate the
	    // sdr_req_norm_dma_last signal and can be tied zero at top-level
            rank_ba_last[0] <= (rank_wr_sel[0]) ? sdr_req_norm_dma_last :
                            (rank_fifo_rd) ?  rank_ba_last[1] : rank_ba_last[0];

            rank_ba_last[1] <= (rank_wr_sel[1]) ? sdr_req_norm_dma_last :
                               (rank_fifo_rd) ?  rank_ba_last[2] : rank_ba_last[1];

            rank_ba_last[2] <= (rank_wr_sel[2]) ? sdr_req_norm_dma_last :
                               (rank_fifo_rd) ?  rank_ba_last[3] : rank_ba_last[2];

            rank_ba_last[3] <= (rank_wr_sel[3]) ? sdr_req_norm_dma_last :
                               (rank_fifo_rd) ?  1'b0 : rank_ba_last[3];
         end

      end // else: !if(~reset_n)
   
   assign xfr_ok[0] = (xfr_ba == 2'b00) ? 1'b1 : 1'b0;
   assign xfr_ok[1] = (xfr_ba == 2'b01) ? 1'b1 : 1'b0;
   assign xfr_ok[2] = (xfr_ba == 2'b10) ? 1'b1 : 1'b0;
   assign xfr_ok[3] = (xfr_ba == 2'b11) ? 1'b1 : 1'b0;
   
   /****************************************************************************/
   // Instantiate Bank Ctl FSM 0

   sdrc_bank_fsm bank0_fsm (.clk (clk),
			   .reset_n (reset_n),

			   /* Req from req_gen */
			   .r2b_req (r2i_req[0]),
			   .r2b_req_id (r2b_req_id),
			   .r2b_start (r2b_start),
			   .r2b_last (r2b_last),
			   .r2b_wrap (r2b_wrap),
			   .r2b_raddr (r2b_raddr),
			   .r2b_caddr (r2b_caddr),
			   .r2b_len (r2b_len),
			   .r2b_write (r2b_write),
			   .b2r_ack (i2r_ack[0]),
                           .sdr_dma_last(rank_ba_last[0]),

			   /* Transfer request to xfr_ctl */
			   .b2x_req (i2x_req[0]),
			   .b2x_start (i2x_start[0]),
			   .b2x_last (i2x_last[0]),
			   .b2x_wrap (i2x_wrap[0]),
			   .b2x_id (i2x_id0),
			   .b2x_addr (i2x_addr0),
			   .b2x_len (i2x_len0),
			   .b2x_cmd (i2x_cmd0),
			   .x2b_ack (x2i_ack[0]),
		     
			   /* Status to/from xfr_ctl */
			   .tras_ok (tras_ok[0]),
			   .xfr_ok (xfr_ok[0]),
			   .x2b_refresh (x2b_refresh),
			   .x2b_pre_ok (x2b_pre_ok[0]),
			   .x2b_act_ok (x2b_act_ok),
			   .x2b_rdok (x2b_rdok),
			   .x2b_wrok (x2b_wrok),

			   .bank_row(bank0_row),

			   /* SDRAM Timing */
			   .tras_delay (tras_delay),
			   .trp_delay (trp_delay),
			   .trcd_delay (trcd_delay));
   
   /****************************************************************************/
   // Instantiate Bank Ctl FSM 1

   sdrc_bank_fsm bank1_fsm (.clk (clk),
			   .reset_n (reset_n),

			   /* Req from req_gen */
			   .r2b_req (r2i_req[1]),
			   .r2b_req_id (r2b_req_id),
			   .r2b_start (r2b_start),
			   .r2b_last (r2b_last),
			   .r2b_wrap (r2b_wrap),
			   .r2b_raddr (r2b_raddr),
			   .r2b_caddr (r2b_caddr),
			   .r2b_len (r2b_len),
			   .r2b_write (r2b_write),
			   .b2r_ack (i2r_ack[1]),
                           .sdr_dma_last(rank_ba_last[1]),

			   /* Transfer request to xfr_ctl */
			   .b2x_req (i2x_req[1]),
			   .b2x_start (i2x_start[1]),
			   .b2x_last (i2x_last[1]),
			   .b2x_wrap (i2x_wrap[1]),
			   .b2x_id (i2x_id1),
			   .b2x_addr (i2x_addr1),
			   .b2x_len (i2x_len1),
			   .b2x_cmd (i2x_cmd1),
			   .x2b_ack (x2i_ack[1]),
		     
			   /* Status to/from xfr_ctl */
			   .tras_ok (tras_ok[1]),           
			   .xfr_ok (xfr_ok[1]),
			   .x2b_refresh (x2b_refresh),
			   .x2b_pre_ok (x2b_pre_ok[1]),
			   .x2b_act_ok (x2b_act_ok),
			   .x2b_rdok (x2b_rdok),
			   .x2b_wrok (x2b_wrok),

			   .bank_row(bank1_row),

			   /* SDRAM Timing */
			   .tras_delay (tras_delay),
			   .trp_delay (trp_delay),
			   .trcd_delay (trcd_delay));
   
   /****************************************************************************/
   // Instantiate Bank Ctl FSM 2

   sdrc_bank_fsm bank2_fsm (.clk (clk),
			   .reset_n (reset_n),

			   /* Req from req_gen */
			   .r2b_req (r2i_req[2]),
			   .r2b_req_id (r2b_req_id),
			   .r2b_start (r2b_start),
			   .r2b_last (r2b_last),
			   .r2b_wrap (r2b_wrap),
			   .r2b_raddr (r2b_raddr),
			   .r2b_caddr (r2b_caddr),
			   .r2b_len (r2b_len),
			   .r2b_write (r2b_write),
			   .b2r_ack (i2r_ack[2]),
                           .sdr_dma_last(rank_ba_last[2]),

			   /* Transfer request to xfr_ctl */
			   .b2x_req (i2x_req[2]),
			   .b2x_start (i2x_start[2]),
			   .b2x_last (i2x_last[2]),
			   .b2x_wrap (i2x_wrap[2]),
			   .b2x_id (i2x_id2),
			   .b2x_addr (i2x_addr2),
			   .b2x_len (i2x_len2),
			   .b2x_cmd (i2x_cmd2),
			   .x2b_ack (x2i_ack[2]),
		     
			   /* Status to/from xfr_ctl */
			   .tras_ok (tras_ok[2]),           
			   .xfr_ok (xfr_ok[2]),
			   .x2b_refresh (x2b_refresh),
			   .x2b_pre_ok (x2b_pre_ok[2]),
			   .x2b_act_ok (x2b_act_ok),
			   .x2b_rdok (x2b_rdok),
			   .x2b_wrok (x2b_wrok),

			   .bank_row(bank2_row),

			   /* SDRAM Timing */
			   .tras_delay (tras_delay),
			   .trp_delay (trp_delay),
			   .trcd_delay (trcd_delay));
   
   /****************************************************************************/
   // Instantiate Bank Ctl FSM 3

   sdrc_bank_fsm bank3_fsm (.clk (clk),
			   .reset_n (reset_n),

			   /* Req from req_gen */
			   .r2b_req (r2i_req[3]),
			   .r2b_req_id (r2b_req_id),
			   .r2b_start (r2b_start),
			   .r2b_last (r2b_last),
			   .r2b_wrap (r2b_wrap),
			   .r2b_raddr (r2b_raddr),
			   .r2b_caddr (r2b_caddr),
			   .r2b_len (r2b_len),
			   .r2b_write (r2b_write),
			   .b2r_ack (i2r_ack[3]),
                           .sdr_dma_last(rank_ba_last[3]),

			   /* Transfer request to xfr_ctl */
			   .b2x_req (i2x_req[3]),
			   .b2x_start (i2x_start[3]),
			   .b2x_last (i2x_last[3]),
			   .b2x_wrap (i2x_wrap[3]),
			   .b2x_id (i2x_id3),
			   .b2x_addr (i2x_addr3),
			   .b2x_len (i2x_len3),
			   .b2x_cmd (i2x_cmd3),
			   .x2b_ack (x2i_ack[3]),
		     
			   /* Status to/from xfr_ctl */
			   .tras_ok (tras_ok[3]),           
			   .xfr_ok (xfr_ok[3]),
			   .x2b_refresh (x2b_refresh),
			   .x2b_pre_ok (x2b_pre_ok[3]),
			   .x2b_act_ok (x2b_act_ok),
			   .x2b_rdok (x2b_rdok),
			   .x2b_wrok (x2b_wrok),

			   .bank_row(bank3_row),

			   /* SDRAM Timing */
			   .tras_delay (tras_delay),
			   .trp_delay (trp_delay),
			   .trcd_delay (trcd_delay));
   

/* address for current xfr, debug only */
wire [12:0] cur_row = (xfr_bank_sel==3) ? bank3_row:
			(xfr_bank_sel==2) ? bank2_row: 
			(xfr_bank_sel==1) ? bank1_row: bank0_row; 

 

endmodule // sdr_bank_ctl

// -----------------------------------------------------------------------------
// Source file: rtl/core/sdrc_bank_fsm.v
// -----------------------------------------------------------------------------
/*********************************************************************
                                                              
  SDRAM Controller Bank Controller
                                                              
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
                                                              
  Description: 
    This module takes requests from sdrc_req_gen, checks for page hit/miss and
    issues precharge/activate commands and then passes the request to sdrc_xfr_ctl. 
                                                              
  To Do:                                                      
    nothing                                                   
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  :  1.0  - 8th Jan 2012
                                                              

                                                             
 Copyright (C) 2000 Authors and OPENCORES.ORG                
                                                             
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
                                                              
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
                                                              
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
                                                              
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
                                                              
*******************************************************************/


`include "sdrc_define.v"

module sdrc_bank_fsm (clk,
		     reset_n,

		     /* Req from req_gen */
		     r2b_req,	   // request
		     r2b_req_id,   // ID
		     r2b_start,	   // First chunk of burst
		     r2b_last,	   // Last chunk of burst
		     r2b_wrap,
		     r2b_raddr,	   // row address
		     r2b_caddr,	   // col address
		     r2b_len,	   // length
		     r2b_write,	   // write request
		     b2r_ack,
                     sdr_dma_last,

		     /* Transfer request to xfr_ctl */
		     b2x_req,	   // Request to xfr_ctl
		     b2x_start,	   // first chunk of transfer
		     b2x_last,	   // last chunk of transfer
		     b2x_wrap,
		     b2x_id,	   // Transfer ID
		     b2x_addr,	   // row/col address
		     b2x_len,	   // transfer length
		     b2x_cmd,	   // transfer command
		     x2b_ack,	   // command accepted
		     
		     /* Status to/from xfr_ctl */
		     tras_ok,      // TRAS OK for this bank
		     xfr_ok,
		     x2b_refresh,  // We did a refresh
		     x2b_pre_ok,   // OK to do a precharge (per bank)
		     x2b_act_ok,   // OK to do an activate
		     x2b_rdok,	   // OK to do a read
		     x2b_wrok,	   // OK to do a write

		     /* current xfr row address of the bank */
		     bank_row,

		     /* SDRAM Timing */
		     tras_delay,   // Active to precharge delay
		     trp_delay,	   // Precharge to active delay
		     trcd_delay);  // Active to R/W delay
   

parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width

   input                        clk, reset_n;

   /* Req from bank_ctl */
   input 			r2b_req, r2b_start, r2b_last,
				r2b_write, r2b_wrap;
   input [`SDR_REQ_ID_W-1:0] 	r2b_req_id;
   input [12:0] 		r2b_raddr;
   input [12:0] 		r2b_caddr;
   input [`REQ_BW-1:0] 	r2b_len;
   output 			b2r_ack;
   input                        sdr_dma_last;

   /* Req to xfr_ctl */
   output 			b2x_req, b2x_start, b2x_last,
				tras_ok, b2x_wrap;
   output [`SDR_REQ_ID_W-1:0] 	b2x_id;
   output [12:0] 		b2x_addr;
   output [`REQ_BW-1:0] 	b2x_len;
   output [1:0] 		b2x_cmd;
   input 			x2b_ack;

   /* Status from xfr_ctl */
   input 			x2b_refresh, x2b_act_ok, x2b_rdok,
				x2b_wrok, x2b_pre_ok, xfr_ok;
   
   input [3:0] 			tras_delay, trp_delay, trcd_delay;

   output [12:0] 			bank_row;

   /****************************************************************************/
   // Internal Nets

   `define BANK_IDLE         3'b000
   `define BANK_PRE          3'b001
   `define BANK_ACT          3'b010
   `define BANK_XFR          3'b011
   `define BANK_DMA_LAST_PRE 3'b100

   reg [2:0] 			bank_st, next_bank_st;
   wire 			b2x_start, b2x_last;
   reg 				l_start, l_last;
   reg 				b2x_req, b2r_ack;
   wire [`SDR_REQ_ID_W-1:0] 	b2x_id;
   reg [`SDR_REQ_ID_W-1:0] 	l_id;
   reg [12:0] 			b2x_addr;
   reg [`REQ_BW-1:0] 	l_len;
   wire [`REQ_BW-1:0] 	b2x_len;
   reg [1:0] 			b2x_cmd_t;
   reg  			bank_valid;
   reg [12:0] 			bank_row;
   reg [3:0] 			tras_cntr, timer0;
   reg 				l_wrap, l_write;
   wire 			b2x_wrap;
   reg [12:0] 			l_raddr;
   reg [12:0] 			l_caddr;
   reg                          l_sdr_dma_last;
   reg                          bank_prech_page_closed;
   
   wire  			tras_ok_internal, tras_ok, activate_bank;
   
   wire 			page_hit, timer0_tc_t, ld_trp, ld_trcd;

   /*** Timing Break Logic Added for FPGA - Start ****/
   reg	x2b_wrok_r, xfr_ok_r , x2b_rdok_r;
   reg [1:0] b2x_cmd_r,timer0_tc_r,tras_ok_r,x2b_pre_ok_r,x2b_act_ok_r;
   always @ (posedge clk)
      if (~reset_n) begin
	 x2b_wrok_r <= 1'b0;
	 xfr_ok_r   <= 1'b0;
	 x2b_rdok_r <= 1'b0;
	 b2x_cmd_r  <= 2'b0;
	 timer0_tc_r  <= 1'b0;
	 tras_ok_r    <= 1'b0;
	 x2b_pre_ok_r <= 1'b0;
	 x2b_act_ok_r <= 1'b0;
      end
      else begin
	 x2b_wrok_r <= x2b_wrok;
	 xfr_ok_r   <= xfr_ok;
	 x2b_rdok_r <= x2b_rdok;
	 b2x_cmd_r  <= b2x_cmd_t;
	 timer0_tc_r <= (ld_trp | ld_trcd) ? 1'b0 : timer0_tc_t;
	 tras_ok_r   <= tras_ok_internal;
	 x2b_pre_ok_r  <= x2b_pre_ok;
	 x2b_act_ok_r  <= x2b_act_ok;
      end

 wire  x2b_wrok_t     = (`TARGET_DESIGN == `FPGA) ? x2b_wrok_r : x2b_wrok;
 wire  xfr_ok_t       = (`TARGET_DESIGN == `FPGA) ? xfr_ok_r : xfr_ok;
 wire  x2b_rdok_t     = (`TARGET_DESIGN == `FPGA) ? x2b_rdok_r : x2b_rdok;
 wire [1:0] b2x_cmd   = (`TARGET_DESIGN == `FPGA) ? b2x_cmd_r : b2x_cmd_t;
 wire  timer0_tc      = (`TARGET_DESIGN == `FPGA) ? timer0_tc_r : timer0_tc_t;
 assign  tras_ok      = (`TARGET_DESIGN == `FPGA) ? tras_ok_r : tras_ok_internal;
 wire  x2b_pre_ok_t   = (`TARGET_DESIGN == `FPGA) ? x2b_pre_ok_r : x2b_pre_ok;
 wire  x2b_act_ok_t   = (`TARGET_DESIGN == `FPGA) ? x2b_act_ok_r : x2b_act_ok;

   /*** Timing Break Logic Added for FPGA - End****/


   always @ (posedge clk)
      if (~reset_n) begin
	 bank_valid <= 1'b0;
	 tras_cntr <= 4'b0;
	 timer0 <= 4'b0;
	 bank_st <= `BANK_IDLE;
      end // if (~reset_n)

      else begin

	 bank_valid <= (x2b_refresh || bank_prech_page_closed) ? 1'b0 :  // force the bank status to be invalid
		       (activate_bank) ? 1'b1 : bank_valid;

	 tras_cntr <= (activate_bank) ? tras_delay :
		      (~tras_ok_internal) ? tras_cntr - 4'b1 : 4'b0;
	 
	 timer0 <= (ld_trp) ? trp_delay :
		   (ld_trcd) ? trcd_delay :
		   (timer0 != 'h0) ? timer0 - 4'b1 : timer0;
	 
	 bank_st <= next_bank_st;

      end // else: !if(~reset_n)

   always @ (posedge clk) begin 

      bank_row <= (bank_st == `BANK_ACT) ? b2x_addr : bank_row;

      if (~reset_n) begin
	 l_start <= 1'b0;
	 l_last <= 1'b0;
	 l_id <= 1'b0;
	 l_len <= 1'b0;
	 l_wrap <= 1'b0;
	 l_write <= 1'b0;
	 l_raddr <= 1'b0;
	 l_caddr <= 1'b0;
         l_sdr_dma_last <= 1'b0;
      end
      else begin
        if (b2r_ack) begin
  	   l_start <= r2b_start;
  	   l_last <= r2b_last;
  	   l_id <= r2b_req_id;
  	   l_len <= r2b_len;
  	   l_wrap <= r2b_wrap;
  	   l_write <= r2b_write;
  	   l_raddr <= r2b_raddr;
  	   l_caddr <= r2b_caddr;
           l_sdr_dma_last <= sdr_dma_last;
        end // if (b2r_ack)
      end

   end // always @ (posedge clk)
   
   assign tras_ok_internal = ~|tras_cntr;

   assign activate_bank = (b2x_cmd == `OP_ACT) & x2b_ack;

   assign page_hit = (r2b_raddr == bank_row) ? bank_valid : 1'b0;    // its a hit only if bank is valid

   assign timer0_tc_t = ~|timer0;

   assign ld_trp = (b2x_cmd == `OP_PRE) ? x2b_ack : 1'b0;

   assign ld_trcd = (b2x_cmd == `OP_ACT) ? x2b_ack : 1'b0;
   


   always @ (*) begin

       bank_prech_page_closed = 1'b0;
       b2x_req = 1'b0;
       b2x_cmd_t = 2'bx;
       b2r_ack = 1'b0;
       b2x_addr = 13'bx;
       next_bank_st = bank_st;

      case (bank_st)

	`BANK_IDLE : begin
		if(`TARGET_DESIGN == `FPGA) begin // To break the timing, b2x request are generated delayed
	             if (~r2b_req) begin
	                next_bank_st = `BANK_IDLE;
	             end // if (~r2b_req)
	             else if (page_hit) begin 
	                b2r_ack = 1'b1;
	                b2x_cmd_t = (r2b_write) ? `OP_WR : `OP_RD;
	                next_bank_st = `BANK_XFR;  
	             end // if (page_hit)
	             else begin  // page_miss
	                b2r_ack = 1'b1;
	                b2x_cmd_t = `OP_PRE;
	                next_bank_st = `BANK_PRE;  // bank was precharged on l_sdr_dma_last
	             end // else: !if(page_hit)
		end else begin // ASIC
	             if (~r2b_req) begin
                        bank_prech_page_closed = 1'b0;
	                b2x_req = 1'b0;
	                b2x_cmd_t = 2'bx;
	                b2r_ack = 1'b0;
	                b2x_addr = 13'bx;
	                next_bank_st = `BANK_IDLE;
	             end // if (~r2b_req)
	             else if (page_hit) begin 
	                b2x_req = (r2b_write) ? x2b_wrok_t & xfr_ok_t : 
			                       x2b_rdok_t & xfr_ok_t;
	                b2x_cmd_t = (r2b_write) ? `OP_WR : `OP_RD;
	                b2r_ack = 1'b1;
	                b2x_addr = r2b_caddr;
	                next_bank_st = (x2b_ack) ? `BANK_IDLE : `BANK_XFR;  // in case of hit, stay here till xfr sm acks
	             end // if (page_hit)
	             else begin  // page_miss
	                b2x_req = tras_ok & x2b_pre_ok_t;
	                b2x_cmd_t = `OP_PRE;
	                b2r_ack = 1'b1;
	                b2x_addr = r2b_raddr & 13'hBFF;	   // Dont want to pre all banks!
	                next_bank_st = (l_sdr_dma_last) ? `BANK_PRE : (x2b_ack) ? `BANK_ACT : `BANK_PRE;  // bank was precharged on l_sdr_dma_last
	             end // else: !if(page_hit)
	        end
	end // case: `BANK_IDLE

	`BANK_PRE : begin
	   b2x_req = tras_ok & x2b_pre_ok_t;
	   b2x_cmd_t = `OP_PRE;
	   b2r_ack = 1'b0;
	   b2x_addr = l_raddr & 13'hBFF;	   // Dont want to pre all banks!
           bank_prech_page_closed = 1'b0;
	   next_bank_st = (x2b_ack) ? `BANK_ACT : `BANK_PRE;
	end // case: `BANK_PRE

	`BANK_ACT : begin
	   b2x_req = timer0_tc & x2b_act_ok_t;
	   b2x_cmd_t = `OP_ACT;
	   b2r_ack = 1'b0;
	   b2x_addr = l_raddr;
           bank_prech_page_closed = 1'b0;
	   next_bank_st = (x2b_ack) ? `BANK_XFR : `BANK_ACT;
	end // case: `BANK_ACT
	
	`BANK_XFR : begin
	   b2x_req = (l_write) ? timer0_tc & x2b_wrok_t & xfr_ok_t :
		     timer0_tc & x2b_rdok_t & xfr_ok_t; 
	   b2x_cmd_t = (l_write) ? `OP_WR : `OP_RD;
	   b2r_ack = 1'b0;
	   b2x_addr = l_caddr;
           bank_prech_page_closed = 1'b0;
	   next_bank_st = (x2b_refresh) ? `BANK_ACT : 
                          (x2b_ack & l_sdr_dma_last) ? `BANK_DMA_LAST_PRE :
			  (x2b_ack) ? `BANK_IDLE : `BANK_XFR;
	end // case: `BANK_XFR

        `BANK_DMA_LAST_PRE : begin
	   b2x_req = tras_ok & x2b_pre_ok_t;
	   b2x_cmd_t = `OP_PRE;
	   b2r_ack = 1'b0;
	   b2x_addr = l_raddr & 13'hBFF;	   // Dont want to pre all banks!
           bank_prech_page_closed = 1'b1;
	   next_bank_st = (x2b_ack) ? `BANK_IDLE : `BANK_DMA_LAST_PRE;
	end // case: `BANK_DMA_LAST_PRE
          
      endcase // case(bank_st)

   end // always @ (bank_st or ...)

   assign b2x_start = (bank_st == `BANK_IDLE) ? r2b_start : l_start;

   assign b2x_last = (bank_st == `BANK_IDLE) ? r2b_last : l_last;

   assign b2x_id = (bank_st == `BANK_IDLE) ? r2b_req_id : l_id;

   assign b2x_len = (bank_st == `BANK_IDLE) ? r2b_len : l_len;

   assign b2x_wrap = (bank_st == `BANK_IDLE) ? r2b_wrap : l_wrap;
   
endmodule // sdr_bank_fsm

// -----------------------------------------------------------------------------
// Source file: rtl/core/sdrc_bs_convert.v
// -----------------------------------------------------------------------------
/*********************************************************************
                                                              
  SDRAM Controller buswidth converter                                  
                                                              
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
                                                              
  Description: SDRAM Controller Buswidth converter

  This module does write/read data transalation between
     application data to SDRAM bus width
                                                              
  To Do:                                                      
    nothing                                                   
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  :  0.0  - 8th Jan 2012 - Initial structure
              0.2 - 2nd Feb 2012
	         Improved the command pipe structure to accept up-to 4 command of different bank.
	      0.3 - 6th Feb 2012
	         Bug fix on read valid generation
                                                              

                                                             
 Copyright (C) 2000 Authors and OPENCORES.ORG                
                                                             
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
                                                              
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
                                                              
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
                                                              
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
                                                              
*******************************************************************/

`include "sdrc_define.v"
module sdrc_bs_convert (
                    clk                 ,
                    reset_n             ,
                    sdr_width           ,

        /* Control Signal from xfr ctrl */
                    x2a_rdstart         ,
                    x2a_wrstart         ,
                    x2a_rdlast          ,
                    x2a_wrlast          ,
                    x2a_rddt            ,
                    x2a_rdok            ,
                    a2x_wrdt            ,
                    a2x_wren_n          ,
                    x2a_wrnext          ,

   /*  Control Signal from/to to application i/f  */
                    app_wr_data         ,
                    app_wr_en_n         ,
                    app_wr_next         ,
                    app_last_wr         ,
                    app_rd_data         ,
                    app_rd_valid        ,
		    app_last_rd
		);


parameter  APP_AW   = 30;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width

parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
   
input                    clk              ;
input                    reset_n          ;
input [1:0]              sdr_width        ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit

/* Control Signal from xfr ctrl Read Transaction*/
input                    x2a_rdstart      ; // read start indication
input                    x2a_rdlast       ; //  read last burst access
input [SDR_DW-1:0]       x2a_rddt         ;
input                    x2a_rdok         ;

/* Control Signal from xfr ctrl Write Transaction*/
input                    x2a_wrstart      ; // writ start indication
input                    x2a_wrlast       ; // write last transfer
input                    x2a_wrnext       ;
output [SDR_DW-1:0]      a2x_wrdt         ;
output [SDR_BW-1:0]      a2x_wren_n       ;

// Application Write Transaction
input  [APP_DW-1:0]      app_wr_data      ;
input  [APP_BW-1:0]      app_wr_en_n      ;
output                   app_wr_next      ;
output                   app_last_wr      ; // Indicate last Write Transfer for a given burst size

// Application Read Transaction
output [APP_DW-1:0]      app_rd_data      ;
output                   app_rd_valid     ;
output                   app_last_rd      ; // Indicate last Read Transfer for a given burst size

//----------------------------------------------
// Local Decleration
// ----------------------------------------

reg [APP_DW-1:0]         app_rd_data      ;
reg                      app_rd_valid     ;
reg [SDR_DW-1:0]         a2x_wrdt         ;
reg [SDR_BW-1:0]         a2x_wren_n       ;
reg                      app_wr_next      ;

reg [23:0]               saved_rd_data    ;
reg [1:0]                rd_xfr_count     ;
reg [1:0]                wr_xfr_count     ;


assign  app_last_wr = x2a_wrlast;
assign  app_last_rd = x2a_rdlast;

always @(*) begin
        if(sdr_width == 2'b00) // 32 Bit SDR Mode
          begin
            a2x_wrdt             = app_wr_data;
            a2x_wren_n           = app_wr_en_n;
            app_wr_next          = x2a_wrnext;
            app_rd_data          = x2a_rddt;
            app_rd_valid         = x2a_rdok;
          end
        else if(sdr_width == 2'b01) // 16 Bit SDR Mode
        begin
           // Changed the address and length to match the 16 bit SDR Mode
            app_wr_next          = (x2a_wrnext & wr_xfr_count[0]);
            app_rd_valid         = (x2a_rdok & rd_xfr_count[0]);
            if(wr_xfr_count[0] == 1'b1)
              begin
                a2x_wren_n      = app_wr_en_n[3:2];
                a2x_wrdt        = app_wr_data[31:16];
              end
            else
              begin
                a2x_wren_n      = app_wr_en_n[1:0];
                a2x_wrdt        = app_wr_data[15:0];
              end
            
            app_rd_data = {x2a_rddt,saved_rd_data[15:0]};
        end else  // 8 Bit SDR Mode
        begin
           // Changed the address and length to match the 16 bit SDR Mode
            app_wr_next         = (x2a_wrnext & (wr_xfr_count[1:0]== 2'b11));
            app_rd_valid        = (x2a_rdok &   (rd_xfr_count[1:0]== 2'b11));
            if(wr_xfr_count[1:0] == 2'b11)
            begin
                a2x_wren_n      = app_wr_en_n[3];
                a2x_wrdt        = app_wr_data[31:24];
            end
            else if(wr_xfr_count[1:0] == 2'b10)
            begin
                a2x_wren_n      = app_wr_en_n[2];
                a2x_wrdt        = app_wr_data[23:16];
            end
            else if(wr_xfr_count[1:0] == 2'b01)
            begin
                a2x_wren_n      = app_wr_en_n[1];
                a2x_wrdt        = app_wr_data[15:8];
            end
            else begin
                a2x_wren_n      = app_wr_en_n[0];
                a2x_wrdt        = app_wr_data[7:0];
            end
            
            app_rd_data         = {x2a_rddt,saved_rd_data[23:0]};
          end
     end



always @(posedge clk)
  begin
    if(!reset_n)
      begin
        rd_xfr_count    <= 8'b0;
        wr_xfr_count    <= 8'b0;
	saved_rd_data   <= 24'h0;
      end
    else begin

	// During Write Phase
        if(x2a_wrlast) begin
           wr_xfr_count    <= 0;
        end
        else if(x2a_wrnext) begin
           wr_xfr_count <= wr_xfr_count + 1'b1;
        end

	// During Read Phase
        if(x2a_rdlast) begin
           rd_xfr_count    <= 0;
        end
        else if(x2a_rdok) begin
           rd_xfr_count   <= rd_xfr_count + 1'b1;
	end

	// Save Previous Data
        if(x2a_rdok) begin
	   if(sdr_width == 2'b01) // 16 Bit SDR Mode
	      saved_rd_data[15:0]  <= x2a_rddt;
            else begin// 8 bit SDR Mode - 
	       if(rd_xfr_count[1:0] == 2'b00)      saved_rd_data[7:0]   <= x2a_rddt[7:0];
	       else if(rd_xfr_count[1:0] == 2'b01) saved_rd_data[15:8]  <= x2a_rddt[7:0];
	       else if(rd_xfr_count[1:0] == 2'b10) saved_rd_data[23:16] <= x2a_rddt[7:0];
	    end
        end
    end
end

endmodule // sdr_bs_convert

// -----------------------------------------------------------------------------
// Source file: rtl/core/sdrc_req_gen.v
// -----------------------------------------------------------------------------
/*********************************************************************
                                                              
  SDRAM Controller Request Generation                                  
                                                              
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
                                                              
  Description: SDRAM Controller Reguest Generation

  Address Generation Based on cfg_colbits
     cfg_colbits= 2'b00
            Address[7:0]    - Column Address
            Address[9:8]    - Bank Address
            Address[22:10]  - Row Address
     cfg_colbits= 2'b01
            Address[8:0]    - Column Address
            Address[10:9]   - Bank Address
            Address[23:11]  - Row Address
     cfg_colbits= 2'b10
            Address[9:0]    - Column Address
            Address[11:10]   - Bank Address
            Address[24:12]  - Row Address
     cfg_colbits= 2'b11
            Address[10:0]    - Column Address
            Address[12:11]   - Bank Address
            Address[25:13]  - Row Address

  The SDRAMs are operated in 4 beat burst mode.

  If Wrap = 0; 
      If the current burst cross the page boundary, then this block split the request 
      into two coressponding change in address and request length

  if the current burst cross the page boundar.
  This module takes requests from the memory controller, 
  chops them to page boundaries if wrap=0, 
  and passes the request to bank_ctl

  Note: With Wrap = 0, each request from Application layer will be splited into two request, 
	if the current burst cross the page boundary. 

  To Do:                                                      
    nothing                                                   
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  : 0.0 - 8th Jan 2012
             0.1 - 5th Feb 2012, column/row/bank address are register to improve the timing issue in FPGA synthesis
                                                              

                                                             
 Copyright (C) 2000 Authors and OPENCORES.ORG                
                                                             
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
                                                              
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
                                                              
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
                                                              
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
                                                              
*******************************************************************/

`include "sdrc_define.v"

module sdrc_req_gen (clk,
		    reset_n,
		    cfg_colbits,
		    sdr_width,

		    /* Request from app */
		    req,	        // Transfer Request
		    req_id,	        // ID for this transfer
		    req_addr,	        // SDRAM Address
		    req_len,	        // Burst Length (in 32 bit words)
		    req_wrap,	        // Wrap mode request (xfr_len = 4)
		    req_wr_n,	        // 0 => Write request, 1 => read req
		    req_ack,	        // Request has been accepted
		    
		    /* Req to xfr_ctl */
		    r2x_idle,

		    /* Req to bank_ctl */
		    r2b_req,	        // request
		    r2b_req_id,	        // ID
		    r2b_start,	        // First chunk of burst
		    r2b_last,	        // Last chunk of burst
		    r2b_wrap,	        // Wrap Mode
		    r2b_ba,	        // bank address
		    r2b_raddr,	        // row address
		    r2b_caddr,	        // col address
		    r2b_len,	        // length
		    r2b_write,	        // write request
		    b2r_ack,
		    b2r_arb_ok
		    );

parameter  APP_AW   = 26;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width
parameter  APP_RW   = 9;   // Application Request Width

parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width


input                   clk           ;
input                   reset_n       ;
input [1:0]             cfg_colbits   ; // 2'b00 - 8 Bit column address, 2'b01 - 9 Bit, 10 - 10 bit, 11 - 11Bits

/* Request from app */
input 			req           ; // Request 
input [`SDR_REQ_ID_W-1:0] req_id      ; // Request ID
input [APP_AW-1:0] 	req_addr      ; // Request Address
input [APP_RW-1:0] 	req_len       ; // Request length
input 			req_wr_n      ; // 0 -Write, 1 - Read
input                   req_wrap      ; // 1 - Wrap the Address on page boundary
output 			req_ack       ; // Request Ack
		
/* Req to bank_ctl */
output 			r2x_idle      ; 
output                  r2b_req       ; // Request
output                  r2b_start     ; // First Junk of the Burst Access
output                  r2b_last      ; // Last Junk of the Burst Access
output                  r2b_write     ; // 1 - Write, 0 - Read
output                  r2b_wrap      ; // 1 - Wrap the Address at the page boundary.
output [`SDR_REQ_ID_W-1:0] 	r2b_req_id;
output [1:0] 		r2b_ba        ; // Bank Address
output [12:0] 		r2b_raddr     ; // Row Address
output [12:0] 		r2b_caddr     ; // Column Address
output [`REQ_BW-1:0] 	r2b_len       ; // Burst Length
input 			b2r_ack       ; // Request Ack
input                   b2r_arb_ok    ; // Bank controller fifo is not full and ready to accept the command
//
input [1:0] 	        sdr_width; // 2'b00 - 32 Bit, 2'b01 - 16 Bit, 2'b1x - 8Bit
                                         

   /****************************************************************************/
   // Internal Nets

   `define REQ_IDLE        2'b00
   `define REQ_ACTIVE      2'b01
   `define REQ_PAGE_WRAP   2'b10

   reg  [1:0]		req_st, next_req_st;
   reg 			r2x_idle, req_ack, r2b_req, r2b_start, 
			r2b_write, req_idle, req_ld, lcl_wrap;
   reg [`SDR_REQ_ID_W-1:0] 	r2b_req_id;
   reg [`REQ_BW-1:0] 	lcl_req_len;

   wire 		r2b_last, page_ovflw;
   reg page_ovflw_r;
   wire [`REQ_BW-1:0] 	r2b_len, next_req_len;
   wire [12:0] 	        max_r2b_len;
   reg  [12:0] 	        max_r2b_len_r;

   reg [1:0] 		r2b_ba;
   reg [12:0] 		r2b_raddr;
   reg [12:0] 		r2b_caddr;

   reg [APP_AW-1:0] 	curr_sdr_addr ;
   wire [APP_AW-1:0] 	next_sdr_addr ;


//--------------------------------------------------------------------
// Generate the internal Adress and Burst length Based on sdram width
//--------------------------------------------------------------------
reg [APP_AW:0]           req_addr_int;
reg [APP_RW-1:0]         req_len_int;

always @(*) begin
   if(sdr_width == 2'b00) begin // 32 Bit SDR Mode
      req_addr_int     = {1'b0,req_addr};
      req_len_int      = req_len;
   end else if(sdr_width == 2'b01) begin // 16 Bit SDR Mode
      // Changed the address and length to match the 16 bit SDR Mode
      req_addr_int     = {req_addr,1'b0};
      req_len_int      = {req_len,1'b0};
   end else  begin // 8 Bit SDR Mode
      // Changed the address and length to match the 16 bit SDR Mode
      req_addr_int    = {req_addr,2'b0};
      req_len_int     = {req_len,2'b0};
   end
end

   //
   // Identify the page over flow.
   // Find the Maximum Burst length allowed from the selected column
   // address, If the requested burst length is more than the allowed Maximum
   // burst length, then we need to handle the bank cross over case and we
   // need to split the reuest.
   //
   assign max_r2b_len = (cfg_colbits == 2'b00) ? (12'h100 - {4'b0, req_addr_int[7:0]}) :
	                (cfg_colbits == 2'b01) ? (12'h200 - {3'b0, req_addr_int[8:0]}) :
			(cfg_colbits == 2'b10) ? (12'h400 - {2'b0, req_addr_int[9:0]}) : (12'h800 - {1'b0, req_addr_int[10:0]});


     // If the wrap = 0 and current application burst length is crossing the page boundary, 
     // then request will be split into two with corresponding change in request address and request length.
     //
     // If the wrap = 0 and current burst length is not crossing the page boundary, 
     // then request from application layer will be transparently passed on the bank control block.

     //
     // if the wrap = 1, then this block will not modify the request address and length. 
     // The wrapping functionality will be handle by the bank control module and 
     // column address will rewind back as follows XX -> FF ? 00 ? 1
     //
     // Note: With Wrap = 0, each request from Application layer will be spilited into two request, 
     //	if the current burst cross the page boundary. 
   assign page_ovflw = ({1'b0, req_len_int} > max_r2b_len) ? ~r2b_wrap : 1'b0;

   assign r2b_len = r2b_start ? ((page_ovflw_r) ? max_r2b_len_r : lcl_req_len) :
                      lcl_req_len;

   assign next_req_len = lcl_req_len - r2b_len;

   assign next_sdr_addr = curr_sdr_addr + r2b_len;


   assign r2b_wrap = lcl_wrap;

   assign r2b_last = (r2b_start & !page_ovflw_r) | (req_st == `REQ_PAGE_WRAP);
//
//
//
   always @ (posedge clk) begin

      page_ovflw_r   <= (req_ack) ? page_ovflw: 'h0;

      max_r2b_len_r  <= (req_ack) ? max_r2b_len: 'h0;
      r2b_start      <= (req_ack) ? 1'b1 :
		        (b2r_ack) ? 1'b0 : r2b_start;

      r2b_write      <= (req_ack) ? ~req_wr_n : r2b_write;

      r2b_req_id     <= (req_ack) ? req_id : r2b_req_id;

      lcl_wrap       <= (req_ack) ? req_wrap : lcl_wrap;
	     
      lcl_req_len    <= (req_ack) ? req_len_int  :
		        (req_ld) ? next_req_len : lcl_req_len;

      curr_sdr_addr  <= (req_ack) ? req_addr_int :
		        (req_ld) ? next_sdr_addr : curr_sdr_addr;

   end // always @ (posedge clk)
   
   always @ (*) begin
      r2x_idle    = 1'b0;
      req_idle    = 1'b0;
      req_ack     = 1'b0;
      req_ld      = 1'b0;
      r2b_req     = 1'b0;
      next_req_st = `REQ_IDLE;

      case (req_st)      // synopsys full_case parallel_case

	`REQ_IDLE : begin
	   r2x_idle = ~req;
	   req_idle = 1'b1;
	   req_ack = req & b2r_arb_ok;
	   req_ld = 1'b0;
	   r2b_req = 1'b0;
	   next_req_st = (req & b2r_arb_ok) ? `REQ_ACTIVE : `REQ_IDLE;
	end // case: `REQ_IDLE

	`REQ_ACTIVE : begin
	   r2x_idle = 1'b0;
	   req_idle = 1'b0;
	   req_ack = 1'b0;
	   req_ld = b2r_ack;
	   r2b_req = 1'b1;                       // req_gen to bank_req
	   next_req_st = (b2r_ack ) ? ((page_ovflw_r) ? `REQ_PAGE_WRAP :`REQ_IDLE) : `REQ_ACTIVE;
	end // case: `REQ_ACTIVE
	`REQ_PAGE_WRAP : begin
	   r2x_idle = 1'b0;
	   req_idle = 1'b0;
	   req_ack  = 1'b0;
	   req_ld = b2r_ack;
	   r2b_req = 1'b1;                       // req_gen to bank_req
	   next_req_st = (b2r_ack) ? `REQ_IDLE : `REQ_PAGE_WRAP;
	end // case: `REQ_ACTIVE

      endcase // case(req_st)

   end // always @ (req_st or ....)

   always @ (posedge clk)
      if (~reset_n) begin
	 req_st <= `REQ_IDLE;
      end // if (~reset_n)
      else begin
	 req_st <= next_req_st;
      end // else: !if(~reset_n)
//
// addrs bits for the bank, row and column
//
// Register row/column/bank to improve fpga timing issue
wire [APP_AW-1:0] 	map_address ;

assign      map_address  = (req_ack) ? req_addr_int :
		           (req_ld)  ? next_sdr_addr : curr_sdr_addr;

always @ (posedge clk) begin
// Bank Bits are always - 2 Bits
    r2b_ba <= (cfg_colbits == 2'b00) ? {map_address[9:8]}   :
	      (cfg_colbits == 2'b01) ? {map_address[10:9]}  :
	      (cfg_colbits == 2'b10) ? {map_address[11:10]} : map_address[12:11];

/********************
*  Colbits Mapping:
*           2'b00 - 8 Bit
*           2'b01 - 16 Bit
*           2'b10 - 10 Bit
*           2'b11 - 11 Bits
************************/
    r2b_caddr <= (cfg_colbits == 2'b00) ? {5'b0, map_address[7:0]} :
	         (cfg_colbits == 2'b01) ? {4'b0, map_address[8:0]} :
	         (cfg_colbits == 2'b10) ? {3'b0, map_address[9:0]} : {2'b0, map_address[10:0]};

    r2b_raddr <= (cfg_colbits == 2'b00)  ? map_address[22:10] :
	         (cfg_colbits == 2'b01)  ? map_address[23:11] :
	         (cfg_colbits == 2'b10)  ? map_address[24:12] : map_address[25:13];
end	   
   
endmodule // sdr_req_gen

// -----------------------------------------------------------------------------
// Source file: rtl/core/sdrc_xfr_ctl.v
// -----------------------------------------------------------------------------
/*********************************************************************
                                                              
  SDRAM Controller Transfer control
                                                              
  This file is part of the sdram controller project           
  http://www.opencores.org/cores/sdr_ctrl/                    
                                                              
  Description: SDRAM Controller Transfer control

  This module takes requests from sdrc_bank_ctl and runs the
  transfer. The input request is guaranteed to be in a bank that is
  precharged and activated. This block runs the transfer until a
  burst boundary is reached, then issues another read/write command
  to sequentially step thru memory if wrap=0, until the transfer is
  completed.
   
  if a read transfer finishes and the caddr is not at a burst boundary 
  a burst terminate command is issued unless another read/write or
  precharge to the same bank is pending.
  
  if a write transfer finishes and the caddr is not at a burst boundary 
  a burst terminate command is issued unless a read/write is pending.
  
   If a refresh request is made, the bank_ctl will be held off until
   the number of refreshes requested are completed.

   This block also handles SDRAM initialization.
  

  To Do:                                                      
    nothing                                                   
                                                              
  Author(s):                                                  
      - Dinesh Annayya, dinesha@opencores.org                 
  Version  : 1.0 - 8th Jan 2012
                                                              

                                                             
 Copyright (C) 2000 Authors and OPENCORES.ORG                
                                                             
 This source file may be used and distributed without         
 restriction provided that this copyright statement is not    
 removed from the file and that any derivative work contains  
 the original copyright notice and the associated disclaimer. 
                                                              
 This source file is free software; you can redistribute it   
 and/or modify it under the terms of the GNU Lesser General   
 Public License as published by the Free Software Foundation; 
 either version 2.1 of the License, or (at your option) any   
later version.                                               
                                                              
 This source is distributed in the hope that it will be       
 useful, but WITHOUT ANY WARRANTY; without even the implied   
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
 PURPOSE.  See the GNU Lesser General Public License for more 
 details.                                                     
                                                              
 You should have received a copy of the GNU Lesser General    
 Public License along with this source; if not, download it   
 from http://www.opencores.org/lgpl.shtml                     
                                                              
*******************************************************************/

`include "sdrc_define.v"

module sdrc_xfr_ctl (clk,
		    reset_n,
		    
		    /* Transfer request from bank_ctl */
		    r2x_idle,	   // Req is idle
		    b2x_idle,      // All banks are idle
		    b2x_req,	   // Req from bank_ctl
		    b2x_start,	   // first chunk of transfer
		    b2x_last,	   // last chunk of transfer
		    b2x_id,	   // Transfer ID
		    b2x_ba,	   // bank address
		    b2x_addr,	   // row/col address
		    b2x_len,	   // transfer length
		    b2x_cmd,	   // transfer command
		    b2x_wrap,	   // Wrap mode transfer
		    x2b_ack,	   // command accepted
		     
		    /* Status to bank_ctl, req_gen */
		    b2x_tras_ok,   // Tras for all banks expired
		    x2b_refresh,   // We did a refresh
		    x2b_pre_ok,	   // OK to do a precharge (per bank)
		    x2b_act_ok,	   // OK to do an activate
		    x2b_rdok,	   // OK to do a read
		    x2b_wrok,	   // OK to do a write
		    
		    /* SDRAM I/O */
		    sdr_cs_n,
		    sdr_cke,
		    sdr_ras_n,
		    sdr_cas_n,
		    sdr_we_n,
		    sdr_dqm,
		    sdr_ba,
		    sdr_addr, 
		    sdr_din,
		    sdr_dout,
		    sdr_den_n,
		    
		    /* Data Flow to the app */
		    x2a_rdstart,
		    x2a_wrstart,
		    x2a_rdlast,
		    x2a_wrlast,
		    x2a_id,
		    a2x_wrdt,
		    a2x_wren_n,
		    x2a_wrnext,
		    x2a_rddt,
		    x2a_rdok,
		    sdr_init_done,
		    
		    /* SDRAM Parameters */
		    sdram_enable,
		    sdram_mode_reg,
		    
		    /* output for generate row address of the transfer */
		    xfr_bank_sel,

		    /* SDRAM Timing */
		    cas_latency,
		    trp_delay,	   // Precharge to refresh delay
		    trcar_delay,   // Auto-refresh period
		    twr_delay,	   // Write recovery delay
		    rfsh_time,	   // time per row (31.25 or 15.6125 uS)
		    rfsh_rmax);	   // Number of rows to rfsh at a time (<120uS)
   
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width


input            clk, reset_n; 

   /* Req from bank_ctl */
input 			b2x_req, b2x_start, b2x_last, b2x_tras_ok,
				b2x_wrap, r2x_idle, b2x_idle; 
input [`SDR_REQ_ID_W-1:0] 	b2x_id;
input [1:0] 			b2x_ba;
input [12:0] 		b2x_addr;
input [`REQ_BW-1:0] 	b2x_len;
input [1:0] 			b2x_cmd;
output 			x2b_ack;

/* Status to bank_ctl */
output [3:0] 		x2b_pre_ok;
output 			x2b_refresh, x2b_act_ok, x2b_rdok,
				x2b_wrok;
/* Data Flow to the app */
output 			x2a_rdstart, x2a_wrstart, x2a_rdlast, x2a_wrlast;
output [`SDR_REQ_ID_W-1:0] 	x2a_id;

input [SDR_DW-1:0] 	a2x_wrdt;
input [SDR_BW-1:0] 	a2x_wren_n;
output [SDR_DW-1:0] 	x2a_rddt;
output 			x2a_wrnext, x2a_rdok, sdr_init_done;
		
/* Interface to SDRAMs */
output 			sdr_cs_n, sdr_cke, sdr_ras_n, sdr_cas_n,
				sdr_we_n; 
output [SDR_BW-1:0] 	sdr_dqm;
output [1:0] 		sdr_ba;
output [12:0] 		sdr_addr;
input [SDR_DW-1:0] 	sdr_din;
output [SDR_DW-1:0] 	sdr_dout;
output [SDR_BW-1:0] 	sdr_den_n;

   output [1:0]			xfr_bank_sel;

   input 			sdram_enable;
   input [12:0] 		sdram_mode_reg;
   input [2:0] 			cas_latency;
   input [3:0] 			trp_delay, trcar_delay, twr_delay;
   input [`SDR_RFSH_TIMER_W-1 : 0] rfsh_time;
   input [`SDR_RFSH_ROW_CNT_W-1:0] rfsh_rmax;
   

   /************************************************************************/
   // Internal Nets

   `define XFR_IDLE        2'b00
   `define XFR_WRITE       2'b01
   `define XFR_READ        2'b10
   `define XFR_RDWT        2'b11

   reg [1:0] 			xfr_st, next_xfr_st;
   reg [12:0] 			xfr_caddr;
   wire 			last_burst;
   wire 			x2a_rdstart, x2a_wrstart, x2a_rdlast, x2a_wrlast;
   reg 				l_start, l_last, l_wrap;
   wire [`SDR_REQ_ID_W-1:0] 	x2a_id;
   reg [`SDR_REQ_ID_W-1:0] 	l_id;
   wire [1:0] 			xfr_ba;
   reg [1:0] 			l_ba;
   wire [12:0] 			xfr_addr;
   wire [`REQ_BW-1:0] 	xfr_len, next_xfr_len;
   reg [`REQ_BW-1:0] 	l_len;

   reg 				mgmt_idle, mgmt_req;
   reg [3:0] 			mgmt_cmd;
   reg [12:0] 			mgmt_addr;
   reg [1:0] 			mgmt_ba;

   reg 				sel_mgmt, sel_b2x;
   reg 				cb_pre_ok, rdok, wrok, wr_next,
				rd_next, sdr_init_done, act_cmd, d_act_cmd;
   wire [3:0] 			b2x_sdr_cmd, xfr_cmd;
   reg [3:0] 			i_xfr_cmd;
   wire 			mgmt_ack, x2b_ack, b2x_read, b2x_write, 
				b2x_prechg, d_rd_next, dt_next, xfr_end,
				rd_pipe_mt, ld_xfr, rd_last, d_rd_last, 
				wr_last, l_xfr_end, rd_start, d_rd_start,
				wr_start, page_hit, burst_bdry, xfr_wrap,
				b2x_prechg_hit;
   reg [6:0] 			l_rd_next, l_rd_start, l_rd_last;
   
   assign b2x_read = (b2x_cmd == `OP_RD) ? 1'b1 : 1'b0;

   assign b2x_write = (b2x_cmd == `OP_WR) ? 1'b1 : 1'b0;

   assign b2x_prechg = (b2x_cmd == `OP_PRE) ? 1'b1 : 1'b0;
   
   assign b2x_sdr_cmd = (b2x_cmd == `OP_PRE) ? `SDR_PRECHARGE :
			(b2x_cmd == `OP_ACT) ? `SDR_ACTIVATE :
			(b2x_cmd == `OP_RD) ? `SDR_READ :
			(b2x_cmd == `OP_WR) ? `SDR_WRITE : `SDR_DESEL;

   assign page_hit = (b2x_ba == l_ba) ? 1'b1 : 1'b0;

   assign b2x_prechg_hit = b2x_prechg & page_hit;
   
   assign xfr_cmd = (sel_mgmt) ? mgmt_cmd :
		    (sel_b2x) ? b2x_sdr_cmd : i_xfr_cmd;

   assign xfr_addr = (sel_mgmt) ? mgmt_addr : 
		     (sel_b2x) ? b2x_addr : xfr_caddr+1;

   assign mgmt_ack = sel_mgmt;

   assign x2b_ack = sel_b2x;

   assign ld_xfr = sel_b2x & (b2x_read | b2x_write);
   
   assign xfr_len = (ld_xfr) ? b2x_len : l_len;

   //assign next_xfr_len = (l_xfr_end && !ld_xfr) ? l_len : xfr_len - 1;
   assign next_xfr_len = (ld_xfr) ? b2x_len : 
	                 (l_xfr_end) ? l_len:  l_len - 1;

   assign d_rd_next = (cas_latency == 3'b001) ? l_rd_next[2] :
		      (cas_latency == 3'b010) ? l_rd_next[3] :
		      (cas_latency == 3'b011) ? l_rd_next[4] :
		      (cas_latency == 3'b100) ? l_rd_next[5] :
		      l_rd_next[6];

   assign d_rd_last = (cas_latency == 3'b001) ? l_rd_last[2] :
		      (cas_latency == 3'b010) ? l_rd_last[3] :
		      (cas_latency == 3'b011) ? l_rd_last[4] :
		      (cas_latency == 3'b100) ? l_rd_last[5] :
		      l_rd_last[6];

   assign d_rd_start = (cas_latency == 3'b001) ? l_rd_start[2] :
		       (cas_latency == 3'b010) ? l_rd_start[3] :
		       (cas_latency == 3'b011) ? l_rd_start[4] :
		       (cas_latency == 3'b100) ? l_rd_start[5] :
		       l_rd_start[6];

   assign rd_pipe_mt = (cas_latency == 3'b001) ? ~|l_rd_next[1:0] :
		       (cas_latency == 3'b010) ? ~|l_rd_next[2:0] :
		       (cas_latency == 3'b011) ? ~|l_rd_next[3:0] :
		       (cas_latency == 3'b100) ? ~|l_rd_next[4:0] :
		       ~|l_rd_next[5:0];

   assign dt_next = wr_next | d_rd_next;

   assign xfr_end = ~|xfr_len;

   assign l_xfr_end = ~|(l_len-1);

   assign rd_start = ld_xfr & b2x_read & b2x_start;

   assign wr_start = ld_xfr & b2x_write & b2x_start;
   
   assign rd_last = rd_next & last_burst & ~|xfr_len[`REQ_BW-1:1];

   //assign wr_last = wr_next & last_burst & ~|xfr_len[APP_RW-1:1];

   assign wr_last = last_burst & ~|xfr_len[`REQ_BW-1:1];
   
   //assign xfr_ba = (ld_xfr) ? b2x_ba : l_ba;
   assign xfr_ba = (sel_mgmt) ? mgmt_ba : 
		   (sel_b2x) ? b2x_ba : l_ba;

   assign xfr_wrap = (ld_xfr) ? b2x_wrap : l_wrap;
   
//   assign burst_bdry = ~|xfr_caddr[2:0];
   wire [1:0] xfr_caddr_lsb = (xfr_caddr[1:0]+1);
   assign burst_bdry = ~|(xfr_caddr_lsb[1:0]);
  
   always @ (posedge clk) begin
      if (~reset_n) begin
	 xfr_caddr <= 13'b0;
	 l_start <= 1'b0;
	 l_last <= 1'b0;
	 l_wrap <= 1'b0;
	 l_id <= 0;
	 l_ba <= 0;
	 l_len <= 0;
	 l_rd_next <= 7'b0;
	 l_rd_start <= 7'b0;
	 l_rd_last <= 7'b0;
	 act_cmd <= 1'b0;
	 d_act_cmd <= 1'b0;
	 xfr_st <= `XFR_IDLE;
      end // if (~reset_n)

      else begin
	 xfr_caddr <= (ld_xfr) ? b2x_addr :
		      (rd_next | wr_next) ? xfr_caddr + 1 : xfr_caddr; 
	 l_start <= (dt_next) ? 1'b0 : 
		   (ld_xfr) ? b2x_start : l_start;
	 l_last <= (ld_xfr) ? b2x_last : l_last;
	 l_wrap <= (ld_xfr) ? b2x_wrap : l_wrap;
	 l_id <= (ld_xfr) ? b2x_id : l_id;
	 l_ba <= (ld_xfr) ? b2x_ba : l_ba;
	 l_len <= next_xfr_len;
	 l_rd_next <= {l_rd_next[5:0], rd_next};
	 l_rd_start <= {l_rd_start[5:0], rd_start};
	 l_rd_last <= {l_rd_last[5:0], rd_last};
	 act_cmd <= (xfr_cmd == `SDR_ACTIVATE) ? 1'b1 : 1'b0;
	 d_act_cmd <= act_cmd;
	 xfr_st <= next_xfr_st;
      end // else: !if(~reset_n)
      
   end // always @ (posedge clk)
   

   always @ (*) begin 
      case (xfr_st)

	`XFR_IDLE : begin

	   sel_mgmt = mgmt_req;
	   sel_b2x = ~mgmt_req & sdr_init_done & b2x_req;
	   i_xfr_cmd = `SDR_DESEL;
	   rd_next = ~mgmt_req & sdr_init_done & b2x_req & b2x_read;
	   wr_next = ~mgmt_req & sdr_init_done & b2x_req & b2x_write;
	   rdok = ~mgmt_req;
	   cb_pre_ok = 1'b1;
	   wrok = ~mgmt_req;
	   next_xfr_st = (mgmt_req | ~sdr_init_done) ? `XFR_IDLE :
			 (~b2x_req) ? `XFR_IDLE :
			 (b2x_read) ? `XFR_READ :
			 (b2x_write) ? `XFR_WRITE : `XFR_IDLE;

	end // case: `XFR_IDLE
	   
	`XFR_READ : begin
	   rd_next = ~l_xfr_end |
		     l_xfr_end & ~mgmt_req & b2x_req & b2x_read;
	   wr_next = 1'b0;
	   rdok = l_xfr_end & ~mgmt_req;
	   // Break the timing path for FPGA Based Design
	   cb_pre_ok = (`TARGET_DESIGN == `FPGA) ? 1'b0 : l_xfr_end;
	   wrok = 1'b0;
	   sel_mgmt = 1'b0;

	   if (l_xfr_end) begin		  // end of transfer

	      if (~l_wrap) begin
		 // Current transfer was not wrap mode, may need BT
		 // If next cmd is a R or W or PRE to same bank allow
		 // it else issue BT 
		 // This is a little pessimistic since BT is issued
		 // for non-wrap mode transfers even if the transfer
		 // ends on a burst boundary, but is felt to be of
		 // minimal performance impact.

		 i_xfr_cmd = `SDR_BT;
		 sel_b2x = b2x_req & ~mgmt_req & (b2x_read | b2x_prechg_hit);

	      end // if (~l_wrap)
	      
	      else begin
		 // Wrap mode transfer, by definition is end of burst
		 // boundary 

		 i_xfr_cmd = `SDR_DESEL;
		 sel_b2x = b2x_req & ~mgmt_req & ~b2x_write;

	      end // else: !if(~l_wrap)
		 
	      next_xfr_st = (sdr_init_done) ? ((b2x_req & ~mgmt_req & b2x_read) ? `XFR_READ : `XFR_RDWT) : `XFR_IDLE;

	   end // if (l_xfr_end)

	   else begin
	      // Not end of transfer
	      // If current transfer was not wrap mode and we are at
	      // the start of a burst boundary issue another R cmd to
	      // step sequemtially thru memory, ELSE,
	      // issue precharge/activate commands from the bank control

	      i_xfr_cmd = (burst_bdry & ~l_wrap) ? `SDR_READ : `SDR_DESEL;
	      sel_b2x = ~(burst_bdry & ~l_wrap) & b2x_req;
	      next_xfr_st = `XFR_READ;

	   end // else: !if(l_xfr_end)
	   
	end // case: `XFR_READ
	
	`XFR_RDWT : begin 
	   rd_next = ~mgmt_req & b2x_req & b2x_read;
	   wr_next = rd_pipe_mt & ~mgmt_req & b2x_req & b2x_write;
	   rdok = ~mgmt_req;
	   cb_pre_ok = 1'b1;
	   wrok = rd_pipe_mt & ~mgmt_req;

	   sel_mgmt = mgmt_req;
	   
	   sel_b2x = ~mgmt_req & b2x_req;

	   i_xfr_cmd = `SDR_DESEL;

	   next_xfr_st = (~mgmt_req & b2x_req & b2x_read) ? `XFR_READ : 
			 (~rd_pipe_mt) ? `XFR_RDWT :
			 (~mgmt_req & b2x_req & b2x_write) ? `XFR_WRITE : 
			 `XFR_IDLE;

	end // case: `XFR_RDWT
	
	`XFR_WRITE : begin
	   rd_next = l_xfr_end & ~mgmt_req & b2x_req & b2x_read;
	   wr_next = ~l_xfr_end |
		     l_xfr_end & ~mgmt_req & b2x_req & b2x_write;
	   rdok = l_xfr_end & ~mgmt_req;
	   cb_pre_ok = 1'b0;
	   wrok = l_xfr_end & ~mgmt_req;
	   sel_mgmt = 1'b0;

	   if (l_xfr_end) begin		  // End of transfer

	      if (~l_wrap) begin
		 // Current transfer was not wrap mode, may need BT
		 // If next cmd is a R or W allow it else issue BT 
		 // This is a little pessimistic since BT is issued
		 // for non-wrap mode transfers even if the transfer
		 // ends on a burst boundary, but is felt to be of
		 // minimal performance impact.


		 sel_b2x = b2x_req & ~mgmt_req & (b2x_read | b2x_write);
		 i_xfr_cmd = `SDR_BT;
	      end // if (~l_wrap)

	      else begin
		 // Wrap mode transfer, by definition is end of burst
		 // boundary 

		 sel_b2x = b2x_req & ~mgmt_req & ~b2x_prechg_hit;
		 i_xfr_cmd = `SDR_DESEL;
	      end // else: !if(~l_wrap)
	      
	      next_xfr_st = (~mgmt_req & b2x_req & b2x_read) ? `XFR_READ : 
			    (~mgmt_req & b2x_req & b2x_write) ? `XFR_WRITE : 
			    `XFR_IDLE;

	   end // if (l_xfr_end)

	   else begin
	      // Not end of transfer
	      // If current transfer was not wrap mode and we are at
	      // the start of a burst boundary issue another R cmd to
	      // step sequemtially thru memory, ELSE,
	      // issue precharge/activate commands from the bank control

	      if (burst_bdry & ~l_wrap) begin
		 sel_b2x = 1'b0;
		 i_xfr_cmd = `SDR_WRITE;
	      end // if (burst_bdry & ~l_wrap)
	      
	      else begin
		 sel_b2x = b2x_req & ~mgmt_req;
		 i_xfr_cmd = `SDR_DESEL;
	      end // else: !if(burst_bdry & ~l_wrap)

	      next_xfr_st = `XFR_WRITE;
	   end // else: !if(l_xfr_end)

	end // case: `XFR_WRITE

      endcase // case(xfr_st)

   end // always @ (xfr_st or ...)

   // signals to bank_ctl (x2b_refresh, x2b_act_ok, x2b_rdok, x2b_wrok,
   // x2b_pre_ok[3:0] 

   assign x2b_refresh = (xfr_cmd == `SDR_REFRESH) ? 1'b1 : 1'b0;

   assign x2b_act_ok = ~act_cmd & ~d_act_cmd;

   assign x2b_rdok = rdok;

   assign x2b_wrok = wrok;

   //assign x2b_pre_ok[0] = (l_ba == 2'b00) ? cb_pre_ok : 1'b1;
   //assign x2b_pre_ok[1] = (l_ba == 2'b01) ? cb_pre_ok : 1'b1;
   //assign x2b_pre_ok[2] = (l_ba == 2'b10) ? cb_pre_ok : 1'b1;
   //assign x2b_pre_ok[3] = (l_ba == 2'b11) ? cb_pre_ok : 1'b1;
   
   assign x2b_pre_ok[0] = cb_pre_ok;
   assign x2b_pre_ok[1] = cb_pre_ok;
   assign x2b_pre_ok[2] = cb_pre_ok;
   assign x2b_pre_ok[3] = cb_pre_ok;
   assign last_burst = (ld_xfr) ? b2x_last : l_last;
   
   /************************************************************************/
   // APP Data I/F

   wire [SDR_DW-1:0] 	x2a_rddt;

   //assign x2a_start = (ld_xfr) ? b2x_start : l_start;
   assign x2a_rdstart = d_rd_start;
   assign x2a_wrstart = wr_start;
   
   assign x2a_rdlast = d_rd_last;
   assign x2a_wrlast = wr_last;

   assign x2a_id = (ld_xfr) ? b2x_id : l_id;

   assign x2a_rddt = sdr_din;

   assign x2a_wrnext = wr_next;

   assign x2a_rdok = d_rd_next;
   
   /************************************************************************/
   // SDRAM I/F

   reg 				sdr_cs_n, sdr_cke, sdr_ras_n, sdr_cas_n,
				sdr_we_n; 
   reg [SDR_BW-1:0] 	sdr_dqm;
   reg [1:0] 			sdr_ba;
   reg [12:0] 			sdr_addr;
   reg [SDR_DW-1:0] 	sdr_dout;
   reg [SDR_BW-1:0] 	sdr_den_n;

   always @ (posedge clk)
      if (~reset_n) begin
	 sdr_cs_n <= 1'b1;
	 sdr_cke <= 1'b1;
	 sdr_ras_n <= 1'b1;
	 sdr_cas_n <= 1'b1;
	 sdr_we_n <= 1'b1;
	 sdr_dqm   <= {SDR_BW{1'b1}};
	 sdr_den_n <= {SDR_BW{1'b1}};
      end // if (~reset_n)
      else begin
	 sdr_cs_n <= xfr_cmd[3];
	 sdr_ras_n <= xfr_cmd[2];
	 sdr_cas_n <= xfr_cmd[1];
	 sdr_we_n <= xfr_cmd[0];
	 sdr_cke <= (xfr_st != `XFR_IDLE) ? 1'b1 : 
		    ~(mgmt_idle & b2x_idle & r2x_idle);
	 sdr_dqm <= (wr_next) ? a2x_wren_n : {SDR_BW{1'b0}};
         sdr_den_n <= (wr_next) ? {SDR_BW{1'b0}} : {SDR_BW{1'b1}};
      end // else: !if(~reset_n)

   always @ (posedge clk) begin 

      if (~xfr_cmd[3]) begin 
	 sdr_addr <= xfr_addr;
	 sdr_ba <= xfr_ba;
      end // if (~xfr_cmd[3])
      
      sdr_dout <= (wr_next) ? a2x_wrdt : sdr_dout;

   end // always @ (posedge clk)
   
   /************************************************************************/
   // Refresh and Initialization

   `define MGM_POWERUP         3'b000
   `define MGM_PRECHARGE    3'b001
   `define MGM_PCHWT        3'b010
   `define MGM_REFRESH      3'b011
   `define MGM_REFWT        3'b100
   `define MGM_MODE_REG     3'b101
   `define MGM_MODE_WT      3'b110
   `define MGM_ACTIVE       3'b111
   
   reg [2:0]       mgmt_st, next_mgmt_st;
   reg [3:0] 	   tmr0, tmr0_d;
   reg [3:0] 	   cntr1, cntr1_d;
   wire 	   tmr0_tc, cntr1_tc, rfsh_timer_tc, ref_req, precharge_ok;
   reg 		   ld_tmr0, ld_cntr1, dec_cntr1, set_sdr_init_done;
   reg [`SDR_RFSH_TIMER_W-1 : 0]  rfsh_timer;
   reg [`SDR_RFSH_ROW_CNT_W-1:0]  rfsh_row_cnt;
   
   always @ (posedge clk) 
      if (~reset_n) begin
	 mgmt_st <= `MGM_POWERUP;
	 tmr0 <= 4'b0;
	 cntr1 <= 4'h7;
	 rfsh_timer <= 0;
	 rfsh_row_cnt <= 0;
	 sdr_init_done <= 1'b0;
      end // if (~reset_n)
      else begin
	 mgmt_st <= next_mgmt_st;
	 tmr0 <= (ld_tmr0) ? tmr0_d :
		  (~tmr0_tc) ? tmr0 - 1 : tmr0;
	 cntr1 <= (ld_cntr1) ? cntr1_d :
		  (dec_cntr1) ? cntr1 - 1 : cntr1;
	 sdr_init_done <= (set_sdr_init_done | sdr_init_done) & sdram_enable;
	 rfsh_timer <= (rfsh_timer_tc) ? 0 : rfsh_timer + 1;
	 rfsh_row_cnt <= (~set_sdr_init_done) ? 0 :
			 (rfsh_timer_tc) ? rfsh_row_cnt + 1 : rfsh_row_cnt;
      end // else: !if(~reset_n)

   assign tmr0_tc = ~|tmr0;

   assign cntr1_tc = ~|cntr1;

   assign rfsh_timer_tc = (rfsh_timer == rfsh_time) ? 1'b1 : 1'b0;

   assign ref_req = (rfsh_row_cnt >= rfsh_rmax) ? 1'b1 : 1'b0;

   assign precharge_ok = cb_pre_ok & b2x_tras_ok;

   assign xfr_bank_sel = l_ba;
   
   always @ (mgmt_st or sdram_enable or mgmt_ack or trp_delay or tmr0_tc or
	     cntr1_tc or trcar_delay or rfsh_row_cnt or ref_req or sdr_init_done
	     or precharge_ok or sdram_mode_reg) begin 

      case (mgmt_st)          // synopsys full_case parallel_case

	`MGM_POWERUP : begin
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b0;
	   mgmt_cmd = `SDR_DESEL;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 13'h400;    // A10 = 1 => all banks
	   ld_tmr0 = 1'b0;
	   tmr0_d = 4'b0;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = 1'b1;
	   cntr1_d = 4'hf; // changed for sdrams with higher refresh cycles during initialization
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (sdram_enable) ? `MGM_PRECHARGE : `MGM_POWERUP; 
	end // case: `MGM_POWERUP

	`MGM_PRECHARGE : begin	   // Precharge all banks
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = (precharge_ok) ? `SDR_PRECHARGE : `SDR_DESEL;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 13'h400;	   // A10 = 1 => all banks
	   ld_tmr0 = mgmt_ack;
	   tmr0_d = trp_delay;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   dec_cntr1 = 1'b0;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (precharge_ok & mgmt_ack) ? `MGM_PCHWT : `MGM_PRECHARGE;
	end // case: `MGM_PRECHARGE
	
	`MGM_PCHWT : begin	   // Wait for Trp
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = `SDR_DESEL;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 13'h400;	   // A10 = 1 => all banks
	   ld_tmr0 = 1'b0;
	   tmr0_d = trp_delay;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'b0;
	   dec_cntr1 = 1'b0;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (tmr0_tc) ? `MGM_REFRESH : `MGM_PCHWT;
	end // case: `MGM_PRECHARGE
	
	`MGM_REFRESH : begin	   // Refresh
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = `SDR_REFRESH;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 13'h400;	   // A10 = 1 => all banks
	   ld_tmr0 = mgmt_ack;
	   tmr0_d = trcar_delay;
	   dec_cntr1 = mgmt_ack;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (mgmt_ack) ? `MGM_REFWT : `MGM_REFRESH;
	end // case: `MGM_REFRESH
	
	`MGM_REFWT : begin	   // Wait for trcar
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = `SDR_DESEL;
	   mgmt_ba = 2'b0;
	   mgmt_addr = 13'h400;	   // A10 = 1 => all banks
	   ld_tmr0 = 1'b0;
	   tmr0_d = trcar_delay;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (~tmr0_tc) ? `MGM_REFWT : 
			  (~cntr1_tc) ? `MGM_REFRESH :
			  (sdr_init_done) ? `MGM_ACTIVE : `MGM_MODE_REG;
	end // case: `MGM_REFWT
	
	`MGM_MODE_REG : begin	   // Program mode Register & wait for 
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = `SDR_MODE;
	   mgmt_ba = {1'b0, sdram_mode_reg[11]};
	   mgmt_addr = sdram_mode_reg;
	   ld_tmr0 = mgmt_ack;
	   tmr0_d = 4'h7;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (mgmt_ack) ? `MGM_MODE_WT : `MGM_MODE_REG;
	end // case: `MGM_MODE_REG
	
	`MGM_MODE_WT : begin	   // Wait for tMRD
	   mgmt_idle = 1'b0;
	   mgmt_req = 1'b1;
	   mgmt_cmd = `SDR_DESEL;
	   mgmt_ba = 2'bx;
	   mgmt_addr = 13'bx;
	   ld_tmr0 = 1'b0;
	   tmr0_d = 4'h7;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = 1'b0;
	   cntr1_d = 4'h7;
	   set_sdr_init_done = 1'b0;
	   next_mgmt_st = (~tmr0_tc) ? `MGM_MODE_WT : `MGM_ACTIVE;
	end // case: `MGM_MODE_WT
	
	`MGM_ACTIVE : begin	   // Wait for ref_req
	   mgmt_idle = ~ref_req;
	   mgmt_req = 1'b0;
	   mgmt_cmd = `SDR_DESEL;
	   mgmt_ba = 2'bx;
	   mgmt_addr = 13'bx;
	   ld_tmr0 = 1'b0;
	   tmr0_d = 4'h7;
	   dec_cntr1 = 1'b0;
	   ld_cntr1 = ref_req;
	   cntr1_d = rfsh_row_cnt;
	   set_sdr_init_done = 1'b1;
	   next_mgmt_st =  (~sdram_enable) ? `MGM_POWERUP :
                           (ref_req) ? `MGM_PRECHARGE : `MGM_ACTIVE;
	end // case: `MGM_MODE_WT
	
      endcase // case(mgmt_st)

   end // always @ (mgmt_st or ....)
   
	   

endmodule // sdr_xfr_ctl
