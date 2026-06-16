// Curated RTL benchmark case.
// case_id: bench_0201_memory_core_ddr2_mem_controller_for_digilent_genesys_board
// source_project: memory_core_ddr2_mem_controller_for_digilent_genesys_board
// top_module: MEMCtrl


// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/MEMCtrl.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: MEMCtrl.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   Top-level  module. Simple model for what the user might use
//   Typically, the user will only instantiate MEM_INTERFACE_TOP in their
//   code, and generate all backend logic (test bench) and all the other infrastructure logic
//    separately.
//   In addition to the memory controller, the module instantiates:
//     1. Reset logic based on user clocks
//     2. IDELAY control block
//Reference:
//Revision History:
//   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
//   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.3 - Parameter IODELAY_GRP added. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

(* X_CORE_INFO = "mig_v3_61_ddr2_v5, Coregen 12.4" , CORE_GENERATION_INFO = "ddr2_v5,mig_v3_61,{component_name=MEMCtrl, BANK_WIDTH=2, CKE_WIDTH=1, CLK_WIDTH=2, COL_WIDTH=10, CS_NUM=1, CS_WIDTH=1, DM_WIDTH=8, DQ_WIDTH=64, DQ_PER_DQS=8, DQS_WIDTH=8, ODT_WIDTH=1, ROW_WIDTH=13, ADDITIVE_LAT=0, BURST_LEN=4, BURST_TYPE=0, CAS_LAT=3, ECC_ENABLE=0, MULTI_BANK_EN=1, TWO_T_TIME_EN=1, ODT_TYPE=1, REDUCE_DRV=0, REG_ENABLE=0, TREFI_NS=7800, TRAS=40000, TRCD=15000, TRFC=105000, TRP=15000, TRTP=7500, TWR=15000, TWTR=7500, CLK_PERIOD=8000, RST_ACT_LOW=1, INTERFACE_TYPE=DDR2_SDRAM, LANGUAGE=Verilog, SYNTHESIS_TOOL=ISE, NO_OF_CONTROLLERS=1}" *)
module MEMCtrl #
  (
   parameter BANK_WIDTH              = 2,       
                                       // # of memory bank addr bits.
   parameter CKE_WIDTH               = 1,       
                                       // # of memory clock enable outputs.
   parameter CLK_WIDTH               = 2,       
                                       // # of clock outputs.
   parameter COL_WIDTH               = 10,       
                                       // # of memory column bits.
   parameter CS_NUM                  = 1,       
                                       // # of separate memory chip selects.
   parameter CS_WIDTH                = 1,       
                                       // # of total memory chip selects.
   parameter CS_BITS                 = 0,       
                                       // set to log2(CS_NUM) (rounded up).
   parameter DM_WIDTH                = 8,       
                                       // # of data mask bits.
   parameter DQ_WIDTH                = 64,       
                                       // # of data width.
   parameter DQ_PER_DQS              = 8,       
                                       // # of DQ data bits per strobe.
   parameter DQS_WIDTH               = 8,       
                                       // # of DQS strobes.
   parameter DQ_BITS                 = 6,       
                                       // set to log2(DQS_WIDTH*DQ_PER_DQS).
   parameter DQS_BITS                = 3,       
                                       // set to log2(DQS_WIDTH).
   parameter ODT_WIDTH               = 1,       
                                       // # of memory on-die term enables.
   parameter ROW_WIDTH               = 13,       
                                       // # of memory row and # of addr bits.
   parameter ADDITIVE_LAT            = 0,       
                                       // additive write latency.
   parameter BURST_LEN               = 4,       
                                       // burst length (in double words).
   parameter BURST_TYPE              = 0,       
                                       // burst type (=0 seq; =1 interleaved).
   parameter CAS_LAT                 = 3,       
                                       // CAS latency.
   parameter ECC_ENABLE              = 0,       
                                       // enable ECC (=1 enable).
   parameter APPDATA_WIDTH           = 128,       
                                       // # of usr read/write data bus bits.
   parameter MULTI_BANK_EN           = 1,       
                                       // Keeps multiple banks open. (= 1 enable).
   parameter TWO_T_TIME_EN           = 1,       
                                       // 2t timing for unbuffered dimms.
   parameter ODT_TYPE                = 1,       
                                       // ODT (=0(none),=1(75),=2(150),=3(50)).
   parameter REDUCE_DRV              = 0,       
                                       // reduced strength mem I/O (=1 yes).
   parameter REG_ENABLE              = 0,       
                                       // registered addr/ctrl (=1 yes).
   parameter TREFI_NS                = 7800,       
                                       // auto refresh interval (ns).
   parameter TRAS                    = 40000,       
                                       // active->precharge delay.
   parameter TRCD                    = 15000,       
                                       // active->read/write delay.
   parameter TRFC                    = 105000,       
                                       // refresh->refresh, refresh->active delay.
   parameter TRP                     = 15000,       
                                       // precharge->command delay.
   parameter TRTP                    = 7500,       
                                       // read->precharge delay.
   parameter TWR                     = 15000,       
                                       // used to determine write->precharge.
   parameter TWTR                    = 7500,       
                                       // write->read delay.
   parameter HIGH_PERFORMANCE_MODE   = "TRUE",       
                              // # = TRUE, the IODELAY performance mode is set
                              // to high.
                              // # = FALSE, the IODELAY performance mode is set
                              // to low.
   parameter SIM_ONLY                = 0,       
                                       // = 1 to skip SDRAM power up delay.
   parameter DEBUG_EN                = 0,       
                                       // Enable debug signals/controls.
                                       // When this parameter is changed from 0 to 1,
                                       // make sure to uncomment the coregen commands
                                       // in ise_flow.bat or create_ise.bat files in
                                       // par folder.
   parameter CLK_PERIOD              = 8000,       
                                       // Core/Memory clock period (in ps).
   parameter RST_ACT_LOW             = 1        
                                       // =1 for active low reset, =0 for active high.
   )
  (
   inout  [DQ_WIDTH-1:0]              ddr2_dq,
   output [ROW_WIDTH-1:0]             ddr2_a,
   output [BANK_WIDTH-1:0]            ddr2_ba,
   output                             ddr2_ras_n,
   output                             ddr2_cas_n,
   output                             ddr2_we_n,
   output [CS_WIDTH-1:0]              ddr2_cs_n,
   output [ODT_WIDTH-1:0]             ddr2_odt,
   output [CKE_WIDTH-1:0]             ddr2_cke,
   output [DM_WIDTH-1:0]              ddr2_dm,
   input                              sys_rst_n,
   output                             phy_init_done,
   input                              locked,
   output                             rst0_tb,
   input                              clk0,
   output                             clk0_tb,
   input                              clk90,
   input                              clkdiv0,
   input                              clk200,
   output                             app_wdf_afull,
   output                             app_af_afull,
   output                             rd_data_valid,
   input                              app_wdf_wren,
   input                              app_af_wren,
   input  [30:0]                      app_af_addr,
   input  [2:0]                       app_af_cmd,
   output [(APPDATA_WIDTH)-1:0]                rd_data_fifo_out,
   input  [(APPDATA_WIDTH)-1:0]                app_wdf_data,
   input  [(APPDATA_WIDTH/8)-1:0]              app_wdf_mask_data,
   inout  [DQS_WIDTH-1:0]             ddr2_dqs,
   inout  [DQS_WIDTH-1:0]             ddr2_dqs_n,
   output [CLK_WIDTH-1:0]             ddr2_ck,
   output [CLK_WIDTH-1:0]             ddr2_ck_n//,
	//ADAUGAT PT LEDURI
	//output error_o, error_cmp_o
   );

  //***************************************************************************
  // IODELAY Group Name: Replication and placement of IDELAYCTRLs will be
  // handled automatically by software tools if IDELAYCTRLs have same refclk,
  // reset and rdy nets. Designs with a unique RESET will commonly create a
  // unique RDY. Constraint IODELAY_GROUP is associated to a set of IODELAYs
  // with an IDELAYCTRL. The parameter IODELAY_GRP value can be any string.
  //***************************************************************************

  localparam IODELAY_GRP = "IODELAY_MIG";





  wire                              rst0;
  wire                              rst90;
  wire                              rstdiv0;
  wire                              rst200;
  wire                              idelay_ctrl_rdy;

  wire error;
  wire error_cmp;
  wire [35:0] control;
  wire [71:0] data;
  wire [7:0] trig0;

  //Debug signals


  wire [3:0]                        dbg_calib_done;
  wire [3:0]                        dbg_calib_err;
  wire [(6*DQ_WIDTH)-1:0]           dbg_calib_dq_tap_cnt;
  wire [(6*DQS_WIDTH)-1:0]          dbg_calib_dqs_tap_cnt;
  wire [(6*DQS_WIDTH)-1:0]          dbg_calib_gate_tap_cnt;
  wire [DQS_WIDTH-1:0]              dbg_calib_rd_data_sel;
  wire [(5*DQS_WIDTH)-1:0]          dbg_calib_rden_dly;
  wire [(5*DQS_WIDTH)-1:0]          dbg_calib_gate_dly;
  wire                              dbg_idel_up_all;
  wire                              dbg_idel_down_all;
  wire                              dbg_idel_up_dq;
  wire                              dbg_idel_down_dq;
  wire                              dbg_idel_up_dqs;
  wire                              dbg_idel_down_dqs;
  wire                              dbg_idel_up_gate;
  wire                              dbg_idel_down_gate;
  wire [DQ_BITS-1:0]                dbg_sel_idel_dq;
  wire                              dbg_sel_all_idel_dq;
  wire [DQS_BITS:0]                 dbg_sel_idel_dqs;
  wire                              dbg_sel_all_idel_dqs;
  wire [DQS_BITS:0]                 dbg_sel_idel_gate;
  wire                              dbg_sel_all_idel_gate;


    // Debug signals (optional use)

  //***********************************
  // PHY Debug Port demo
  //***********************************
  wire [35:0]                        cs_control0;
  wire [35:0]                        cs_control1;
  wire [35:0]                        cs_control2;
  wire [35:0]                        cs_control3;
  wire [191:0]                       vio0_in;
  wire [95:0]                        vio1_in;
  wire [99:0]                        vio2_in;
  wire [31:0]                        vio3_out;




  //***************************************************************************

  assign  rst0_tb = rst0;
  assign  clk0_tb = clk0;


ddr2_idelay_ctrl #
   (
    .IODELAY_GRP         (IODELAY_GRP)
   )
   u_ddr2_idelay_ctrl
   (
   .rst200                 (rst200),
   .clk200                 (clk200),
   .idelay_ctrl_rdy        (idelay_ctrl_rdy)
   );

 ddr2_infrastructure #
 (
   .RST_ACT_LOW            (RST_ACT_LOW)
   )
u_ddr2_infrastructure
 (
   .sys_rst_n              (sys_rst_n),
   .locked                 (locked),
   .rst0                   (rst0),
   .rst90                  (rst90),
   .rstdiv0                (rstdiv0),
   .rst200                 (rst200),
   .clk0                   (clk0),
   .clk90                  (clk90),
   .clkdiv0                (clkdiv0),
   .clk200                 (clk200),
   .idelay_ctrl_rdy        (idelay_ctrl_rdy)
   );

 ddr2_top #
 (
   .BANK_WIDTH             (BANK_WIDTH),
   .CKE_WIDTH              (CKE_WIDTH),
   .CLK_WIDTH              (CLK_WIDTH),
   .COL_WIDTH              (COL_WIDTH),
   .CS_NUM                 (CS_NUM),
   .CS_WIDTH               (CS_WIDTH),
   .CS_BITS                (CS_BITS),
   .DM_WIDTH               (DM_WIDTH),
   .DQ_WIDTH               (DQ_WIDTH),
   .DQ_PER_DQS             (DQ_PER_DQS),
   .DQS_WIDTH              (DQS_WIDTH),
   .DQ_BITS                (DQ_BITS),
   .DQS_BITS               (DQS_BITS),
   .ODT_WIDTH              (ODT_WIDTH),
   .ROW_WIDTH              (ROW_WIDTH),
   .ADDITIVE_LAT           (ADDITIVE_LAT),
   .BURST_LEN              (BURST_LEN),
   .BURST_TYPE             (BURST_TYPE),
   .CAS_LAT                (CAS_LAT),
   .ECC_ENABLE             (ECC_ENABLE),
   .APPDATA_WIDTH          (APPDATA_WIDTH),
   .MULTI_BANK_EN          (MULTI_BANK_EN),
   .TWO_T_TIME_EN          (TWO_T_TIME_EN),
   .ODT_TYPE               (ODT_TYPE),
   .REDUCE_DRV             (REDUCE_DRV),
   .REG_ENABLE             (REG_ENABLE),
   .TREFI_NS               (TREFI_NS),
   .TRAS                   (TRAS),
   .TRCD                   (TRCD),
   .TRFC                   (TRFC),
   .TRP                    (TRP),
   .TRTP                   (TRTP),
   .TWR                    (TWR),
   .TWTR                   (TWTR),
   .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),
   .IODELAY_GRP            (IODELAY_GRP),
   .SIM_ONLY               (SIM_ONLY),
   .DEBUG_EN               (DEBUG_EN),
   .FPGA_SPEED_GRADE       (3),
   .USE_DM_PORT            (1),
   .CLK_PERIOD             (CLK_PERIOD)
   )
u_ddr2_top_0
(
   .ddr2_dq                (ddr2_dq),
   .ddr2_a                 (ddr2_a),
   .ddr2_ba                (ddr2_ba),
   .ddr2_ras_n             (ddr2_ras_n),
   .ddr2_cas_n             (ddr2_cas_n),
   .ddr2_we_n              (ddr2_we_n),
   .ddr2_cs_n              (ddr2_cs_n),
   .ddr2_odt               (ddr2_odt),
   .ddr2_cke               (ddr2_cke),
   .ddr2_dm                (ddr2_dm),
   .phy_init_done          (phy_init_done),
   .rst0                   (rst0),
   .rst90                  (rst90),
   .rstdiv0                (rstdiv0),
   .clk0                   (clk0),
   .clk90                  (clk90),
   .clkdiv0                (clkdiv0),
   .app_wdf_afull          (app_wdf_afull),
   .app_af_afull           (app_af_afull),
   .rd_data_valid          (rd_data_valid),
   .app_wdf_wren           (app_wdf_wren),
   .app_af_wren            (app_af_wren),
   .app_af_addr            (app_af_addr),
   .app_af_cmd             (app_af_cmd),
   .rd_data_fifo_out       (rd_data_fifo_out),
   .app_wdf_data           (app_wdf_data),
   .app_wdf_mask_data      (app_wdf_mask_data),
   .ddr2_dqs               (ddr2_dqs),
   .ddr2_dqs_n             (ddr2_dqs_n),
   .ddr2_ck                (ddr2_ck),
   .rd_ecc_error           (),
   .ddr2_ck_n              (ddr2_ck_n),

   .dbg_calib_done         (dbg_calib_done),
   .dbg_calib_err          (dbg_calib_err),
   .dbg_calib_dq_tap_cnt   (dbg_calib_dq_tap_cnt),
   .dbg_calib_dqs_tap_cnt  (dbg_calib_dqs_tap_cnt),
   .dbg_calib_gate_tap_cnt  (dbg_calib_gate_tap_cnt),
   .dbg_calib_rd_data_sel  (dbg_calib_rd_data_sel),
   .dbg_calib_rden_dly     (dbg_calib_rden_dly),
   .dbg_calib_gate_dly     (dbg_calib_gate_dly),
   .dbg_idel_up_all        (dbg_idel_up_all),
   .dbg_idel_down_all      (dbg_idel_down_all),
   .dbg_idel_up_dq         (dbg_idel_up_dq),
   .dbg_idel_down_dq       (dbg_idel_down_dq),
   .dbg_idel_up_dqs        (dbg_idel_up_dqs),
   .dbg_idel_down_dqs      (dbg_idel_down_dqs),
   .dbg_idel_up_gate       (dbg_idel_up_gate),
   .dbg_idel_down_gate     (dbg_idel_down_gate),
   .dbg_sel_idel_dq        (dbg_sel_idel_dq),
   .dbg_sel_all_idel_dq    (dbg_sel_all_idel_dq),
   .dbg_sel_idel_dqs       (dbg_sel_idel_dqs),
   .dbg_sel_all_idel_dqs   (dbg_sel_all_idel_dqs),
   .dbg_sel_idel_gate      (dbg_sel_idel_gate),
   .dbg_sel_all_idel_gate  (dbg_sel_all_idel_gate)
   );

 
   //*****************************************************************
  // Hooks to prevent sim/syn compilation errors (mainly for VHDL - but
  // keep it also in Verilog version of code) w/ floating inputs if
  // DEBUG_EN = 0.
  //*****************************************************************

  generate
    if (DEBUG_EN == 0) begin: gen_dbg_tie_off
      assign dbg_idel_up_all       = 'b0;
      assign dbg_idel_down_all     = 'b0;
      assign dbg_idel_up_dq        = 'b0;
      assign dbg_idel_down_dq      = 'b0;
      assign dbg_idel_up_dqs       = 'b0;
      assign dbg_idel_down_dqs     = 'b0;
      assign dbg_idel_up_gate      = 'b0;
      assign dbg_idel_down_gate    = 'b0;
      assign dbg_sel_idel_dq       = 'b0;
      assign dbg_sel_all_idel_dq   = 'b0;
      assign dbg_sel_idel_dqs      = 'b0;
      assign dbg_sel_all_idel_dqs  = 'b0;
      assign dbg_sel_idel_gate     = 'b0;
      assign dbg_sel_all_idel_gate = 'b0;
    end else begin: gen_dbg_enable
      
      //*****************************************************************
      // PHY Debug Port example - see MIG User's Guide, XAPP858 or 
      // Answer Record 29443
      // This logic supports up to 32 DQ and 8 DQS I/O
      // NOTES:
      //   1. PHY Debug Port demo connects to 4 VIO modules:
      //     - 3 VIO modules with only asynchronous inputs
      //      * Monitor IDELAY taps for DQ, DQS, DQS Gate
      //      * Calibration status
      //     - 1 VIO module with synchronous outputs
      //      * Allow dynamic adjustment o f IDELAY taps
      //   2. User may need to modify this code to incorporate other
      //      chipscope-related modules in their larger design (e.g.
      //      if they have other ILA/VIO modules, they will need to
      //      for example instantiate a larger ICON module). In addition
      //      user may want to instantiate more VIO modules to control
      //      IDELAY for more DQ, DQS than is shown here
      //*****************************************************************

      icon4 u_icon
        (
         .control0 (cs_control0),
         .control1 (cs_control1),
         .control2 (cs_control2),
         .control3 (cs_control3)
         );

      //*****************************************************************
      // VIO ASYNC input: Display current IDELAY setting for up to 32
      // DQ taps (32x6) = 192
      //*****************************************************************

      vio_async_in192 u_vio0
        (
         .control  (cs_control0),
         .async_in (vio0_in)
         );

      //*****************************************************************
      // VIO ASYNC input: Display current IDELAY setting for up to 8 DQS
      // and DQS Gate taps (8x6x2) = 96
      //*****************************************************************

      vio_async_in96 u_vio1
        (
         .control  (cs_control1),
         .async_in (vio1_in)
         );

      //*****************************************************************
      // VIO ASYNC input: Display other calibration results
      //*****************************************************************

      vio_async_in100 u_vio2
        (
         .control  (cs_control2),
         .async_in (vio2_in)
         );
      
      //*****************************************************************
      // VIO SYNC output: Dynamically change IDELAY taps
      //*****************************************************************
      
      vio_sync_out32 u_vio3
        (
         .control  (cs_control3),
         .clk      (clkdiv0),
         .sync_out (vio3_out)
         );

      //*****************************************************************
      // Bit assignments:
      // NOTE: Not all VIO, ILA inputs/outputs may be used - these will
      //       be dependent on the user's particular bit width
      //*****************************************************************

      if (DQ_WIDTH <= 32) begin: gen_dq_le_32
        assign vio0_in[(6*DQ_WIDTH)-1:0] 
                 = dbg_calib_dq_tap_cnt[(6*DQ_WIDTH)-1:0];
      end else begin: gen_dq_gt_32
        assign vio0_in = dbg_calib_dq_tap_cnt[191:0];
      end

      if (DQS_WIDTH <= 8) begin: gen_dqs_le_8
        assign vio1_in[(6*DQS_WIDTH)-1:0]
                 = dbg_calib_dqs_tap_cnt[(6*DQS_WIDTH)-1:0];
        assign vio1_in[(12*DQS_WIDTH)-1:(6*DQS_WIDTH)] 
                 =  dbg_calib_gate_tap_cnt[(6*DQS_WIDTH)-1:0];
      end else begin: gen_dqs_gt_32
        assign vio1_in[47:0]  = dbg_calib_dqs_tap_cnt[47:0];
        assign vio1_in[95:48] = dbg_calib_gate_tap_cnt[47:0];
      end
 
//dbg_calib_rd_data_sel

     if (DQS_WIDTH <= 8) begin: gen_rdsel_le_8
        assign vio2_in[(DQS_WIDTH)+7:8]    
	         = dbg_calib_rd_data_sel[(DQS_WIDTH)-1:0];
     end else begin: gen_rdsel_gt_32
      assign vio2_in[15:8]    
                 = dbg_calib_rd_data_sel[7:0];
     end
 
//dbg_calib_rden_dly

     if (DQS_WIDTH <= 8) begin: gen_calrd_le_8
       assign vio2_in[(5*DQS_WIDTH)+19:20]   
                 = dbg_calib_rden_dly[(5*DQS_WIDTH)-1:0];
     end else begin: gen_calrd_gt_32
       assign vio2_in[59:20]   
                 = dbg_calib_rden_dly[39:0];
     end

//dbg_calib_gate_dly

     if (DQS_WIDTH <= 8) begin: gen_calgt_le_8
       assign vio2_in[(5*DQS_WIDTH)+59:60]   
                 = dbg_calib_gate_dly[(5*DQS_WIDTH)-1:0];
     end else begin: gen_calgt_gt_32
       assign vio2_in[99:60]   
                 = dbg_calib_gate_dly[39:0];
     end

//dbg_sel_idel_dq

     if (DQ_BITS <= 5) begin: gen_selid_le_5
       assign dbg_sel_idel_dq[DQ_BITS-1:0]      
                 = vio3_out[DQ_BITS+7:8];
     end else begin: gen_selid_gt_32
       assign dbg_sel_idel_dq[4:0]      
                 = vio3_out[12:8];
     end

//dbg_sel_idel_dqs

     if (DQS_BITS <= 3) begin: gen_seldqs_le_3
       assign dbg_sel_idel_dqs[DQS_BITS:0]     
                 = vio3_out[(DQS_BITS+16):16];
     end else begin: gen_seldqs_gt_32
       assign dbg_sel_idel_dqs[3:0]     
                 = vio3_out[19:16];
     end

//dbg_sel_idel_gate

     if (DQS_BITS <= 3) begin: gen_gtdqs_le_3
       assign dbg_sel_idel_gate[DQS_BITS:0]    
                 = vio3_out[(DQS_BITS+21):21];
     end else begin: gen_gtdqs_gt_32
       assign dbg_sel_idel_gate[3:0]    
                 = vio3_out[24:21];
     end


      assign vio2_in[3:0]              = dbg_calib_done;
      assign vio2_in[7:4]              = dbg_calib_err;
      
      assign dbg_idel_up_all           = vio3_out[0];
      assign dbg_idel_down_all         = vio3_out[1];
      assign dbg_idel_up_dq            = vio3_out[2];
      assign dbg_idel_down_dq          = vio3_out[3];
      assign dbg_idel_up_dqs           = vio3_out[4];
      assign dbg_idel_down_dqs         = vio3_out[5];
      assign dbg_idel_up_gate          = vio3_out[6];
      assign dbg_idel_down_gate        = vio3_out[7];
      assign dbg_sel_all_idel_dq       = vio3_out[15];
      assign dbg_sel_all_idel_dqs      = vio3_out[20];
      assign dbg_sel_all_idel_gate     = vio3_out[25];
    end
  endgenerate
  

endmodule




// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/ddr2_chipscope.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_chipscope.v
// /___/   /\     Date Last Modified: $Data$ 
// \   \  /  \	  Date Created: 9/14/06
//  \___\/\___\
//
//Device: Virtex-5
//Purpose:
//   Skeleton Chipscope module declarations - for simulation only
//Reference:
//Revision History:
//
//*****************************************************************************

`timescale 1ns/1ps

module icon4 
  (
      control0,
      control1,
      control2,
      control3
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  output [35:0] control0;
  output [35:0] control1;
  output [35:0] control2;
  output [35:0] control3;
endmodule

module vio_async_in192
  (
    control,
    async_in
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  input  [35:0] control;
  input  [191:0] async_in;
endmodule

module vio_async_in96
  (
    control,
    async_in
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  input  [35:0] control;
  input  [95:0] async_in;
endmodule

module vio_async_in100
  (
    control,
    async_in
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  input  [35:0] control;
  input  [99:0] async_in;
endmodule

module vio_sync_out32
  (
    control,
    clk,
    sync_out
  )
  /* synthesis syn_black_box syn_noprune = 1 */;
  input  [35:0] control;
  input  clk;
  output [31:0] sync_out;
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/ddr2_idelay_ctrl.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_idelay_ctrl.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module instantiates the IDELAYCTRL primitive of the Virtex-5 device
//   which continuously calibrates the IDELAY elements in the region in case of
//   varying operating conditions. It takes a 200MHz clock as an input
//Reference:
//Revision History:
//   Rev 1.1 - Parameter IODELAY_GRP added and constraint IODELAY_GROUP added
//             on IOELAYCTRL primitive. Generate logic on IDELAYCTRL removed
//             since tools will replicate idelactrl primitives.PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_idelay_ctrl #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter IODELAY_GRP     = "IODELAY_MIG"
   )

  (
   input  clk200,
   input  rst200,
   output idelay_ctrl_rdy
   );

  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY(idelay_ctrl_rdy),
     .REFCLK(clk200),
     .RST(rst200)
     );

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/ddr2_mem_if_top.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_mem_if_top.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR/DDR2
//Purpose:
//   Top-level for parameterizable (DDR or DDR2) memory interface
//Reference:
//Revision History:
//   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
//   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.3 - Parameter CS_BITS added. PK. 10/8/08
//   Rev 1.4 - Parameter IODELAY_GRP added. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_mem_if_top #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH            = 2,
   parameter CKE_WIDTH             = 1,
   parameter CLK_WIDTH             = 1,
   parameter COL_WIDTH             = 10,
   parameter CS_BITS               = 0,
   parameter CS_NUM                = 1,
   parameter CS_WIDTH              = 1,
   parameter USE_DM_PORT           = 1,
   parameter DM_WIDTH              = 9,
   parameter DQ_WIDTH              = 72,
   parameter DQ_BITS               = 7,
   parameter DQ_PER_DQS            = 8,
   parameter DQS_BITS              = 4,
   parameter DQS_WIDTH             = 9,
   parameter HIGH_PERFORMANCE_MODE = "TRUE",
   parameter IODELAY_GRP           = "IODELAY_MIG",
   parameter ODT_WIDTH             = 1,
   parameter ROW_WIDTH             = 14,
   parameter APPDATA_WIDTH         = 144,
   parameter ADDITIVE_LAT          = 0,
   parameter BURST_LEN             = 4,
   parameter BURST_TYPE            = 0,
   parameter CAS_LAT               = 5,
   parameter ECC_ENABLE            = 0,
   parameter MULTI_BANK_EN         = 1,
   parameter TWO_T_TIME_EN         = 0,
   parameter ODT_TYPE              = 1,
   parameter DDR_TYPE              = 1,
   parameter REDUCE_DRV            = 0,
   parameter REG_ENABLE            = 1,
   parameter TREFI_NS              = 7800,
   parameter TRAS                  = 40000,
   parameter TRCD                  = 15000,
   parameter TRFC                  = 105000,
   parameter TRP                   = 15000,
   parameter TRTP                  = 7500,
   parameter TWR                   = 15000,
   parameter TWTR                  = 10000,
   parameter CLK_PERIOD            = 3000,
   parameter SIM_ONLY              = 0,
   parameter DEBUG_EN              = 0,
   parameter FPGA_SPEED_GRADE      = 2
   )
  (
   input                                    clk0,
   input                                    clk90,
   input                                    clkdiv0,
   input                                    rst0,
   input                                    rst90,
   input                                    rstdiv0,
   input [2:0]                              app_af_cmd,
   input [30:0]                             app_af_addr,
   input                                    app_af_wren,
   input                                    app_wdf_wren,
   input [APPDATA_WIDTH-1:0]                app_wdf_data,
   input [(APPDATA_WIDTH/8)-1:0]            app_wdf_mask_data,
   output [1:0]                             rd_ecc_error,
   output                                   app_af_afull,
   output                                   app_wdf_afull,
   output                                   rd_data_valid,
   output [APPDATA_WIDTH-1:0]               rd_data_fifo_out,
   output                                   phy_init_done,
   output [CLK_WIDTH-1:0]                   ddr_ck,
   output [CLK_WIDTH-1:0]                   ddr_ck_n,
   output [ROW_WIDTH-1:0]                   ddr_addr,
   output [BANK_WIDTH-1:0]                  ddr_ba,
   output                                   ddr_ras_n,
   output                                   ddr_cas_n,
   output                                   ddr_we_n,
   output [CS_WIDTH-1:0]                    ddr_cs_n,
   output [CKE_WIDTH-1:0]                   ddr_cke,
   output [ODT_WIDTH-1:0]                   ddr_odt,
   output [DM_WIDTH-1:0]                    ddr_dm,
   inout [DQS_WIDTH-1:0]                    ddr_dqs,
   inout [DQS_WIDTH-1:0]                    ddr_dqs_n,
   inout [DQ_WIDTH-1:0]                     ddr_dq,
   // Debug signals (optional use)
   input                                    dbg_idel_up_all,
   input                                    dbg_idel_down_all,
   input                                    dbg_idel_up_dq,
   input                                    dbg_idel_down_dq,
   input                                    dbg_idel_up_dqs,
   input                                    dbg_idel_down_dqs,
   input                                    dbg_idel_up_gate,
   input                                    dbg_idel_down_gate,
   input [DQ_BITS-1:0]                      dbg_sel_idel_dq,
   input                                    dbg_sel_all_idel_dq,
   input [DQS_BITS:0]                       dbg_sel_idel_dqs,
   input                                    dbg_sel_all_idel_dqs,
   input [DQS_BITS:0]                       dbg_sel_idel_gate,
   input                                    dbg_sel_all_idel_gate,
   output [3:0]                             dbg_calib_done,
   output [3:0]                             dbg_calib_err,
   output [(6*DQ_WIDTH)-1:0]                dbg_calib_dq_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]               dbg_calib_dqs_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]               dbg_calib_gate_tap_cnt,
   output [DQS_WIDTH-1:0]                   dbg_calib_rd_data_sel,
   output [(5*DQS_WIDTH)-1:0]               dbg_calib_rden_dly,
   output [(5*DQS_WIDTH)-1:0]               dbg_calib_gate_dly
   );

  wire [30:0]                       af_addr;
  wire [2:0]                        af_cmd;
  wire                              af_empty;
  wire [ROW_WIDTH-1:0]              ctrl_addr;
  wire                              ctrl_af_rden;
  wire [BANK_WIDTH-1:0]             ctrl_ba;
  wire                              ctrl_cas_n;
  wire [CS_NUM-1:0]                 ctrl_cs_n;
  wire                              ctrl_ras_n;
  wire                              ctrl_rden;
  wire                              ctrl_ref_flag;
  wire                              ctrl_we_n;
  wire                              ctrl_wren;
  wire [DQS_WIDTH-1:0]              phy_calib_rden;
  wire [DQS_WIDTH-1:0]              phy_calib_rden_sel;
  wire [DQ_WIDTH-1:0]               rd_data_fall;
  wire [DQ_WIDTH-1:0]               rd_data_rise;
  wire [(2*DQ_WIDTH)-1:0]           wdf_data;
  wire [((2*DQ_WIDTH)/8)-1:0]       wdf_mask_data;
  wire                              wdf_rden;

  //***************************************************************************

  ddr2_phy_top #
    (
     .BANK_WIDTH            (BANK_WIDTH),
     .CKE_WIDTH             (CKE_WIDTH),
     .CLK_WIDTH             (CLK_WIDTH),
     .COL_WIDTH             (COL_WIDTH),
     .CS_BITS               (CS_BITS),
     .CS_NUM                (CS_NUM),
     .CS_WIDTH              (CS_WIDTH),
     .USE_DM_PORT           (USE_DM_PORT),
     .DM_WIDTH              (DM_WIDTH),
     .DQ_WIDTH              (DQ_WIDTH),
     .DQ_BITS               (DQ_BITS),
     .DQ_PER_DQS            (DQ_PER_DQS),
     .DQS_BITS              (DQS_BITS),
     .DQS_WIDTH             (DQS_WIDTH),
     .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
     .IODELAY_GRP           (IODELAY_GRP),
     .ODT_WIDTH             (ODT_WIDTH),
     .ROW_WIDTH             (ROW_WIDTH),
     .TWO_T_TIME_EN         (TWO_T_TIME_EN),
     .ADDITIVE_LAT          (ADDITIVE_LAT),
     .BURST_LEN             (BURST_LEN),
     .BURST_TYPE            (BURST_TYPE),
     .CAS_LAT               (CAS_LAT),
     .ECC_ENABLE            (ECC_ENABLE),
     .ODT_TYPE              (ODT_TYPE),
     .DDR_TYPE              (DDR_TYPE),
     .REDUCE_DRV            (REDUCE_DRV),
     .REG_ENABLE            (REG_ENABLE),
     .TWR                   (TWR),
     .CLK_PERIOD            (CLK_PERIOD),
     .SIM_ONLY              (SIM_ONLY),
     .DEBUG_EN              (DEBUG_EN),
     .FPGA_SPEED_GRADE      (FPGA_SPEED_GRADE)
     )
    u_phy_top
      (
       .clk0                   (clk0),
       .clk90                  (clk90),
       .clkdiv0                (clkdiv0),
       .rst0                   (rst0),
       .rst90                  (rst90),
       .rstdiv0                (rstdiv0),
       .ctrl_wren              (ctrl_wren),
       .ctrl_addr              (ctrl_addr),
       .ctrl_ba                (ctrl_ba),
       .ctrl_ras_n             (ctrl_ras_n),
       .ctrl_cas_n             (ctrl_cas_n),
       .ctrl_we_n              (ctrl_we_n),
       .ctrl_cs_n              (ctrl_cs_n),
       .ctrl_rden              (ctrl_rden),
       .ctrl_ref_flag          (ctrl_ref_flag),
       .wdf_data               (wdf_data),
       .wdf_mask_data          (wdf_mask_data),
       .wdf_rden               (wdf_rden),
       .phy_init_done          (phy_init_done),
       .phy_calib_rden         (phy_calib_rden),
       .phy_calib_rden_sel     (phy_calib_rden_sel),
       .rd_data_rise           (rd_data_rise),
       .rd_data_fall           (rd_data_fall),
       .ddr_ck                 (ddr_ck),
       .ddr_ck_n               (ddr_ck_n),
       .ddr_addr               (ddr_addr),
       .ddr_ba                 (ddr_ba),
       .ddr_ras_n              (ddr_ras_n),
       .ddr_cas_n              (ddr_cas_n),
       .ddr_we_n               (ddr_we_n),
       .ddr_cs_n               (ddr_cs_n),
       .ddr_cke                (ddr_cke),
       .ddr_odt                (ddr_odt),
       .ddr_dm                 (ddr_dm),
       .ddr_dqs                (ddr_dqs),
       .ddr_dqs_n              (ddr_dqs_n),
       .ddr_dq                 (ddr_dq),
       .dbg_idel_up_all        (dbg_idel_up_all),
       .dbg_idel_down_all      (dbg_idel_down_all),
       .dbg_idel_up_dq         (dbg_idel_up_dq),
       .dbg_idel_down_dq       (dbg_idel_down_dq),
       .dbg_idel_up_dqs        (dbg_idel_up_dqs),
       .dbg_idel_down_dqs      (dbg_idel_down_dqs),
       .dbg_idel_up_gate       (dbg_idel_up_gate),
       .dbg_idel_down_gate     (dbg_idel_down_gate),
       .dbg_sel_idel_dq        (dbg_sel_idel_dq),
       .dbg_sel_all_idel_dq    (dbg_sel_all_idel_dq),
       .dbg_sel_idel_dqs       (dbg_sel_idel_dqs),
       .dbg_sel_all_idel_dqs   (dbg_sel_all_idel_dqs),
       .dbg_sel_idel_gate      (dbg_sel_idel_gate),
       .dbg_sel_all_idel_gate  (dbg_sel_all_idel_gate),
       .dbg_calib_done         (dbg_calib_done),
       .dbg_calib_err          (dbg_calib_err),
       .dbg_calib_dq_tap_cnt   (dbg_calib_dq_tap_cnt),
       .dbg_calib_dqs_tap_cnt  (dbg_calib_dqs_tap_cnt),
       .dbg_calib_gate_tap_cnt (dbg_calib_gate_tap_cnt),
       .dbg_calib_rd_data_sel  (dbg_calib_rd_data_sel),
       .dbg_calib_rden_dly     (dbg_calib_rden_dly),
       .dbg_calib_gate_dly     (dbg_calib_gate_dly)
       );

  ddr2_usr_top #
    (
     .BANK_WIDTH    (BANK_WIDTH),
     .COL_WIDTH     (COL_WIDTH),
     .CS_BITS       (CS_BITS),
     .DQ_WIDTH      (DQ_WIDTH),
     .DQ_PER_DQS    (DQ_PER_DQS),
     .DQS_WIDTH     (DQS_WIDTH),
     .APPDATA_WIDTH (APPDATA_WIDTH),
     .ECC_ENABLE    (ECC_ENABLE),
     .ROW_WIDTH     (ROW_WIDTH)
     )
    u_usr_top
      (
       .clk0              (clk0),
       .clk90             (clk90),
       .rst0              (rst0),
       .rd_data_in_rise   (rd_data_rise),
       .rd_data_in_fall   (rd_data_fall),
       .phy_calib_rden    (phy_calib_rden),
       .phy_calib_rden_sel(phy_calib_rden_sel),
       .rd_data_valid     (rd_data_valid),
       .rd_ecc_error      (rd_ecc_error),
       .rd_data_fifo_out  (rd_data_fifo_out),
       .app_af_cmd        (app_af_cmd),
       .app_af_addr       (app_af_addr),
       .app_af_wren       (app_af_wren),
       .ctrl_af_rden      (ctrl_af_rden),
       .af_cmd            (af_cmd),
       .af_addr           (af_addr),
       .af_empty          (af_empty),
       .app_af_afull      (app_af_afull),
       .app_wdf_wren      (app_wdf_wren),
       .app_wdf_data      (app_wdf_data),
       .app_wdf_mask_data (app_wdf_mask_data),
       .wdf_rden          (wdf_rden),
       .app_wdf_afull     (app_wdf_afull),
       .wdf_data          (wdf_data),
       .wdf_mask_data     (wdf_mask_data)
       );


  ddr2_ctrl #
    (
     .BANK_WIDTH    (BANK_WIDTH),
     .COL_WIDTH     (COL_WIDTH),
     .CS_BITS       (CS_BITS),
     .CS_NUM        (CS_NUM),
     .ROW_WIDTH     (ROW_WIDTH),
     .ADDITIVE_LAT  (ADDITIVE_LAT),
     .BURST_LEN     (BURST_LEN),
     .CAS_LAT       (CAS_LAT),
     .ECC_ENABLE    (ECC_ENABLE),
     .REG_ENABLE    (REG_ENABLE),
     .MULTI_BANK_EN (MULTI_BANK_EN),
     .TWO_T_TIME_EN (TWO_T_TIME_EN),
     .TREFI_NS      (TREFI_NS),
     .TRAS          (TRAS),
     .TRCD          (TRCD),
     .TRFC          (TRFC),
     .TRP           (TRP),
     .TRTP          (TRTP),
     .TWR           (TWR),
     .TWTR          (TWTR),
     .CLK_PERIOD    (CLK_PERIOD),
     .DDR_TYPE      (DDR_TYPE)
     )
    u_ctrl
      (
       .clk           (clk0),
       .rst           (rst0),
       .af_cmd        (af_cmd),
       .af_addr       (af_addr),
       .af_empty      (af_empty),
       .phy_init_done (phy_init_done),
       .ctrl_ref_flag (ctrl_ref_flag),
       .ctrl_af_rden  (ctrl_af_rden),
       .ctrl_wren     (ctrl_wren),
       .ctrl_rden     (ctrl_rden),
       .ctrl_addr     (ctrl_addr),
       .ctrl_ba       (ctrl_ba),
       .ctrl_ras_n    (ctrl_ras_n),
       .ctrl_cas_n    (ctrl_cas_n),
       .ctrl_we_n     (ctrl_we_n),
       .ctrl_cs_n     (ctrl_cs_n)
       );

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/ddr2_phy_top.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_phy_top.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   Top-level for memory physical layer (PHY) interface
//Reference:
//Revision History:
//   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
//   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.3 - Parameter CS_BITS added. PK. 10/8/08
//   Rev 1.4 - Parameter IODELAY_GRP added. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

(* X_CORE_INFO = "mig_v3_61_ddr2_sdram_v5, Coregen 12.4" , CORE_GENERATION_INFO = "ddr2_sdram_v5,mig_v3_61,{component_name=ddr2_phy_top, BANK_WIDTH=2, CKE_WIDTH=1, CLK_WIDTH=2, COL_WIDTH=10, CS_NUM=1, CS_WIDTH=1, DM_WIDTH=8, DQ_WIDTH=64, DQ_PER_DQS=8, DQS_WIDTH=8, ODT_WIDTH=1, ROW_WIDTH=13, ADDITIVE_LAT=0, BURST_LEN=4, BURST_TYPE=0, CAS_LAT=3, ECC_ENABLE=0, MULTI_BANK_EN=1, TWO_T_TIME_EN=1, ODT_TYPE=1, REDUCE_DRV=0, REG_ENABLE=0, TREFI_NS=7800, TRAS=40000, TRCD=15000, TRFC=105000, TRP=15000, TRTP=7500, TWR=15000, TWTR=7500, CLK_PERIOD=8000, RST_ACT_LOW=1, INTERFACE_TYPE=DDR2_SDRAM, LANGUAGE=Verilog, SYNTHESIS_TOOL=ISE, NO_OF_CONTROLLERS=1}" *)
module ddr2_phy_top #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH            = 2,
   parameter CLK_WIDTH             = 1,
   parameter CKE_WIDTH             = 1,
   parameter COL_WIDTH             = 10,
   parameter CS_BITS               = 0,
   parameter CS_NUM                = 1,
   parameter CS_WIDTH              = 1,
   parameter USE_DM_PORT           = 1,
   parameter DM_WIDTH              = 9,
   parameter DQ_WIDTH              = 72,
   parameter DQ_BITS               = 7,
   parameter DQ_PER_DQS            = 8,
   parameter DQS_WIDTH             = 9,
   parameter DQS_BITS              = 4,
   parameter HIGH_PERFORMANCE_MODE = "TRUE",
   parameter IODELAY_GRP           = "IODELAY_MIG",
   parameter ODT_WIDTH             = 1,
   parameter ROW_WIDTH             = 14,
   parameter ADDITIVE_LAT          = 0,
   parameter TWO_T_TIME_EN         = 0,
   parameter BURST_LEN             = 4,
   parameter BURST_TYPE            = 0,
   parameter CAS_LAT               = 5,
   parameter TWR                   = 15000,
   parameter ECC_ENABLE            = 0,
   parameter ODT_TYPE              = 1,
   parameter DDR_TYPE              = 1,
   parameter REDUCE_DRV            = 0,
   parameter REG_ENABLE            = 1,
   parameter CLK_PERIOD            = 3000,
   parameter SIM_ONLY              = 0,
   parameter DEBUG_EN              = 0,
   parameter FPGA_SPEED_GRADE      = 2
   )
  (
   input                                  clk0,
   input                                  clk90,
   input                                  clkdiv0,
   input                                  rst0,
   input                                  rst90,
   input                                  rstdiv0,
   input                                  ctrl_wren,
   input [ROW_WIDTH-1:0]                  ctrl_addr,
   input [BANK_WIDTH-1:0]                 ctrl_ba,
   input                                  ctrl_ras_n,
   input                                  ctrl_cas_n,
   input                                  ctrl_we_n,
   input [CS_NUM-1:0]                     ctrl_cs_n,
   input                                  ctrl_rden,
   input                                  ctrl_ref_flag,
   input [(2*DQ_WIDTH)-1:0]               wdf_data,
   input [(2*DQ_WIDTH/8)-1:0]             wdf_mask_data,
   output                                 wdf_rden,
   output                                 phy_init_done,
   output [DQS_WIDTH-1:0]                 phy_calib_rden,
   output [DQS_WIDTH-1:0]                 phy_calib_rden_sel,
   output [DQ_WIDTH-1:0]                  rd_data_rise,
   output [DQ_WIDTH-1:0]                  rd_data_fall,
   output [CLK_WIDTH-1:0]                 ddr_ck,
   output [CLK_WIDTH-1:0]                 ddr_ck_n,
   output [ROW_WIDTH-1:0]                 ddr_addr,
   output [BANK_WIDTH-1:0]                ddr_ba,
   output                                 ddr_ras_n,
   output                                 ddr_cas_n,
   output                                 ddr_we_n,
   output [CS_WIDTH-1:0]                  ddr_cs_n,
   output [CKE_WIDTH-1:0]                 ddr_cke,
   output [ODT_WIDTH-1:0]                 ddr_odt,
   output [DM_WIDTH-1:0]                  ddr_dm,
   inout [DQS_WIDTH-1:0]                  ddr_dqs,
   inout [DQS_WIDTH-1:0]                  ddr_dqs_n,
   inout [DQ_WIDTH-1:0]                   ddr_dq,
   // Debug signals (optional use)
   input                                  dbg_idel_up_all,
   input                                  dbg_idel_down_all,
   input                                  dbg_idel_up_dq,
   input                                  dbg_idel_down_dq,
   input                                  dbg_idel_up_dqs,
   input                                  dbg_idel_down_dqs,
   input                                  dbg_idel_up_gate,
   input                                  dbg_idel_down_gate,
   input [DQ_BITS-1:0]                    dbg_sel_idel_dq,
   input                                  dbg_sel_all_idel_dq,
   input [DQS_BITS:0]                     dbg_sel_idel_dqs,
   input                                  dbg_sel_all_idel_dqs,
   input [DQS_BITS:0]                     dbg_sel_idel_gate,
   input                                  dbg_sel_all_idel_gate,
   output [3:0]                           dbg_calib_done,
   output [3:0]                           dbg_calib_err,
   output [(6*DQ_WIDTH)-1:0]              dbg_calib_dq_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]             dbg_calib_dqs_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]             dbg_calib_gate_tap_cnt,
   output [DQS_WIDTH-1:0]                 dbg_calib_rd_data_sel,
   output [(5*DQS_WIDTH)-1:0]             dbg_calib_rden_dly,
   output [(5*DQS_WIDTH)-1:0]             dbg_calib_gate_dly
   );

  wire [3:0]               calib_done;
  wire                     calib_ref_done;
  wire                     calib_ref_req;
  wire [3:0]               calib_start;
  wire                     dm_ce;
  wire [1:0]               dq_oe_n;
  wire                     dqs_oe_n;
  wire                     dqs_rst_n;
  wire [(DQ_WIDTH/8)-1:0]  mask_data_fall;
  wire [(DQ_WIDTH/8)-1:0]  mask_data_rise;
  wire [CS_NUM-1:0]        odt;
  wire [ROW_WIDTH-1:0]     phy_init_addr;
  wire [BANK_WIDTH-1:0]    phy_init_ba;
  wire                     phy_init_cas_n;
  wire [CKE_WIDTH-1:0]     phy_init_cke;
  wire [CS_NUM-1:0]        phy_init_cs_n;
  wire                     phy_init_data_sel;
  wire                     phy_init_ras_n;
  wire                     phy_init_rden;
  wire                     phy_init_we_n;
  wire                     phy_init_wren;
  wire [DQ_WIDTH-1:0]      wr_data_fall;
  wire [DQ_WIDTH-1:0]      wr_data_rise;

  //***************************************************************************

  ddr2_phy_write #
    (
     .DQ_WIDTH     (DQ_WIDTH),
     .CS_NUM       (CS_NUM),
     .ADDITIVE_LAT (ADDITIVE_LAT),
     .CAS_LAT      (CAS_LAT),
     .ECC_ENABLE   (ECC_ENABLE),
     .ODT_TYPE     (ODT_TYPE),
     .REG_ENABLE   (REG_ENABLE),
     .DDR_TYPE     (DDR_TYPE)
     )
    u_phy_write
      (
       .clk0                    (clk0),
       .clk90                   (clk90),
       .rst90                   (rst90),
       .wdf_data                (wdf_data),
       .wdf_mask_data           (wdf_mask_data),
       .ctrl_wren               (ctrl_wren),
       .phy_init_wren           (phy_init_wren),
       .phy_init_data_sel       (phy_init_data_sel),
       .dm_ce                   (dm_ce),
       .dq_oe_n                 (dq_oe_n),
       .dqs_oe_n                (dqs_oe_n),
       .dqs_rst_n               (dqs_rst_n),
       .wdf_rden                (wdf_rden),
       .odt                     (odt),
       .wr_data_rise            (wr_data_rise),
       .wr_data_fall            (wr_data_fall),
       .mask_data_rise          (mask_data_rise),
       .mask_data_fall          (mask_data_fall)
       );

  ddr2_phy_io #
    (
     .CLK_WIDTH             (CLK_WIDTH),
     .USE_DM_PORT           (USE_DM_PORT),
     .DM_WIDTH              (DM_WIDTH),
     .DQ_WIDTH              (DQ_WIDTH),
     .DQ_BITS               (DQ_BITS),
     .DQ_PER_DQS            (DQ_PER_DQS),
     .DQS_BITS              (DQS_BITS),
     .DQS_WIDTH             (DQS_WIDTH),
     .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
     .IODELAY_GRP           (IODELAY_GRP),
     .ODT_WIDTH             (ODT_WIDTH),
     .ADDITIVE_LAT          (ADDITIVE_LAT),
     .CAS_LAT               (CAS_LAT),
     .REG_ENABLE            (REG_ENABLE),
     .CLK_PERIOD            (CLK_PERIOD),
     .DDR_TYPE              (DDR_TYPE),
     .SIM_ONLY              (SIM_ONLY),
     .DEBUG_EN              (DEBUG_EN),
     .FPGA_SPEED_GRADE      (FPGA_SPEED_GRADE)
     )
    u_phy_io
      (
       .clk0                   (clk0),
       .clk90                  (clk90),
       .clkdiv0                (clkdiv0),
       .rst0                   (rst0),
       .rst90                  (rst90),
       .rstdiv0                (rstdiv0),
       .dm_ce                  (dm_ce),
       .dq_oe_n                (dq_oe_n),
       .dqs_oe_n               (dqs_oe_n),
       .dqs_rst_n              (dqs_rst_n),
       .calib_start            (calib_start),
       .ctrl_rden              (ctrl_rden),
       .phy_init_rden          (phy_init_rden),
       .calib_ref_done         (calib_ref_done),
       .calib_done             (calib_done),
       .calib_ref_req          (calib_ref_req),
       .calib_rden             (phy_calib_rden),
       .calib_rden_sel         (phy_calib_rden_sel),
       .wr_data_rise           (wr_data_rise),
       .wr_data_fall           (wr_data_fall),
       .mask_data_rise         (mask_data_rise),
       .mask_data_fall         (mask_data_fall),
       .rd_data_rise           (rd_data_rise),
       .rd_data_fall           (rd_data_fall),
       .ddr_ck                 (ddr_ck),
       .ddr_ck_n               (ddr_ck_n),
       .ddr_dm                 (ddr_dm),
       .ddr_dqs                (ddr_dqs),
       .ddr_dqs_n              (ddr_dqs_n),
       .ddr_dq                 (ddr_dq),
       .dbg_idel_up_all        (dbg_idel_up_all),
       .dbg_idel_down_all      (dbg_idel_down_all),
       .dbg_idel_up_dq         (dbg_idel_up_dq),
       .dbg_idel_down_dq       (dbg_idel_down_dq),
       .dbg_idel_up_dqs        (dbg_idel_up_dqs),
       .dbg_idel_down_dqs      (dbg_idel_down_dqs),
       .dbg_idel_up_gate       (dbg_idel_up_gate),
       .dbg_idel_down_gate     (dbg_idel_down_gate),
       .dbg_sel_idel_dq        (dbg_sel_idel_dq),
       .dbg_sel_all_idel_dq    (dbg_sel_all_idel_dq),
       .dbg_sel_idel_dqs       (dbg_sel_idel_dqs),
       .dbg_sel_all_idel_dqs   (dbg_sel_all_idel_dqs),
       .dbg_sel_idel_gate      (dbg_sel_idel_gate),
       .dbg_sel_all_idel_gate  (dbg_sel_all_idel_gate),
       .dbg_calib_done         (dbg_calib_done),
       .dbg_calib_err          (dbg_calib_err),
       .dbg_calib_dq_tap_cnt   (dbg_calib_dq_tap_cnt),
       .dbg_calib_dqs_tap_cnt  (dbg_calib_dqs_tap_cnt),
       .dbg_calib_gate_tap_cnt (dbg_calib_gate_tap_cnt),
       .dbg_calib_rd_data_sel  (dbg_calib_rd_data_sel),
       .dbg_calib_rden_dly     (dbg_calib_rden_dly),
       .dbg_calib_gate_dly     (dbg_calib_gate_dly)
       );

  ddr2_phy_ctl_io #
    (
     .BANK_WIDTH    (BANK_WIDTH),
     .CKE_WIDTH     (CKE_WIDTH),
     .COL_WIDTH     (COL_WIDTH),
     .CS_NUM        (CS_NUM),
     .CS_WIDTH      (CS_WIDTH),
     .TWO_T_TIME_EN (TWO_T_TIME_EN),
     .ODT_WIDTH     (ODT_WIDTH),
     .ROW_WIDTH     (ROW_WIDTH),
     .DDR_TYPE      (DDR_TYPE)
     )
    u_phy_ctl_io
      (
       .clk0                    (clk0),
       .clk90                   (clk90),
       .rst0                    (rst0),
       .rst90                   (rst90),
       .ctrl_addr               (ctrl_addr),
       .ctrl_ba                 (ctrl_ba),
       .ctrl_ras_n              (ctrl_ras_n),
       .ctrl_cas_n              (ctrl_cas_n),
       .ctrl_we_n               (ctrl_we_n),
       .ctrl_cs_n               (ctrl_cs_n),
       .phy_init_addr           (phy_init_addr),
       .phy_init_ba             (phy_init_ba),
       .phy_init_ras_n          (phy_init_ras_n),
       .phy_init_cas_n          (phy_init_cas_n),
       .phy_init_we_n           (phy_init_we_n),
       .phy_init_cs_n           (phy_init_cs_n),
       .phy_init_cke            (phy_init_cke),
       .phy_init_data_sel       (phy_init_data_sel),
       .odt                     (odt),
       .ddr_addr                (ddr_addr),
       .ddr_ba                  (ddr_ba),
       .ddr_ras_n               (ddr_ras_n),
       .ddr_cas_n               (ddr_cas_n),
       .ddr_we_n                (ddr_we_n),
       .ddr_cke                 (ddr_cke),
       .ddr_cs_n                (ddr_cs_n),
       .ddr_odt                 (ddr_odt)
       );

  ddr2_phy_init #
    (
     .BANK_WIDTH   (BANK_WIDTH),
     .CKE_WIDTH    (CKE_WIDTH),
     .COL_WIDTH    (COL_WIDTH),
     .CS_BITS      (CS_BITS),
     .CS_NUM       (CS_NUM),
     .DQ_WIDTH     (DQ_WIDTH),
     .ODT_WIDTH    (ODT_WIDTH),
     .ROW_WIDTH    (ROW_WIDTH),
     .ADDITIVE_LAT (ADDITIVE_LAT),
     .BURST_LEN    (BURST_LEN),
     .BURST_TYPE   (BURST_TYPE),
     .TWO_T_TIME_EN(TWO_T_TIME_EN),
     .CAS_LAT      (CAS_LAT),
     .ODT_TYPE     (ODT_TYPE),
     .REDUCE_DRV   (REDUCE_DRV),
     .REG_ENABLE   (REG_ENABLE),
     .TWR          (TWR),
     .CLK_PERIOD   (CLK_PERIOD),
     .DDR_TYPE     (DDR_TYPE),
     .SIM_ONLY     (SIM_ONLY)
     )
    u_phy_init
      (
       .clk0                    (clk0),
       .clkdiv0                 (clkdiv0),
       .rst0                    (rst0),
       .rstdiv0                 (rstdiv0),
       .calib_done              (calib_done),
       .ctrl_ref_flag           (ctrl_ref_flag),
       .calib_ref_req           (calib_ref_req),
       .calib_start             (calib_start),
       .calib_ref_done          (calib_ref_done),
       .phy_init_wren           (phy_init_wren),
       .phy_init_rden           (phy_init_rden),
       .phy_init_addr           (phy_init_addr),
       .phy_init_ba             (phy_init_ba),
       .phy_init_ras_n          (phy_init_ras_n),
       .phy_init_cas_n          (phy_init_cas_n),
       .phy_init_we_n           (phy_init_we_n),
       .phy_init_cs_n           (phy_init_cs_n),
       .phy_init_cke            (phy_init_cke),
       .phy_init_done           (phy_init_done),
       .phy_init_data_sel       (phy_init_data_sel)
       );

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/ddr2_top.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_top.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 16 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   System level module. This level contains just the memory controller.
//   This level will be intiantated when the user wants to remove the
//   synthesizable test bench, IDELAY control block and the clock
//   generation modules.
//Reference:
//Revision History:
//   Rev 1.1 - Parameter USE_DM_PORT added. PK. 6/25/08
//   Rev 1.2 - Parameter HIGH_PERFORMANCE_MODE added. PK. 7/10/08
//   Rev 1.3 - Parameter IODELAY_GRP added. PK. 11/27/08
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_top #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH            = 2,      // # of memory bank addr bits
   parameter CKE_WIDTH             = 1,      // # of memory clock enable outputs
   parameter CLK_WIDTH             = 1,      // # of clock outputs
   parameter COL_WIDTH             = 10,     // # of memory column bits
   parameter CS_NUM                = 1,      // # of separate memory chip selects
   parameter CS_BITS               = 0,      // set to log2(CS_NUM) (rounded up)
   parameter CS_WIDTH              = 1,      // # of total memory chip selects
   parameter USE_DM_PORT           = 1,      // enable Data Mask (=1 enable)
   parameter DM_WIDTH              = 9,      // # of data mask bits
   parameter DQ_WIDTH              = 72,     // # of data width
   parameter DQ_BITS               = 7,      // set to log2(DQS_WIDTH*DQ_PER_DQS)
   parameter DQ_PER_DQS            = 8,      // # of DQ data bits per strobe
   parameter DQS_WIDTH             = 9,      // # of DQS strobes
   parameter DQS_BITS              = 4,      // set to log2(DQS_WIDTH)
   parameter HIGH_PERFORMANCE_MODE = "TRUE", // IODELAY Performance Mode
   parameter IODELAY_GRP           = "IODELAY_MIG", // IODELAY Group Name
   parameter ODT_WIDTH             = 1,      // # of memory on-die term enables
   parameter ROW_WIDTH             = 14,     // # of memory row & # of addr bits
   parameter APPDATA_WIDTH         = 144,    // # of usr read/write data bus bits
   parameter ADDITIVE_LAT          = 0,      // additive write latency
   parameter BURST_LEN             = 4,      // burst length (in double words)
   parameter BURST_TYPE            = 0,      // burst type (=0 seq; =1 interlved)
   parameter CAS_LAT               = 5,      // CAS latency
   parameter ECC_ENABLE            = 0,      // enable ECC (=1 enable)
   parameter ODT_TYPE              = 1,      // ODT (=0(none),=1(75),=2(150),=3(50))
   parameter MULTI_BANK_EN         = 1,      // enable bank management
   parameter TWO_T_TIME_EN         = 0,      // 2t timing for unbuffered dimms
   parameter REDUCE_DRV            = 0,      // reduced strength mem I/O (=1 yes)
   parameter REG_ENABLE            = 1,      // registered addr/ctrl (=1 yes)
   parameter TREFI_NS              = 7800,   // auto refresh interval (ns)
   parameter TRAS                  = 40000,  // active->precharge delay
   parameter TRCD                  = 15000,  // active->read/write delay
   parameter TRFC                  = 105000, // ref->ref, ref->active delay
   parameter TRP                   = 15000,  // precharge->command delay
   parameter TRTP                  = 7500,   // read->precharge delay
   parameter TWR                   = 15000,  // used to determine wr->prech
   parameter TWTR                  = 10000,  // write->read delay
   parameter CLK_PERIOD            = 3000,   // Core/Mem clk period (in ps)
   parameter SIM_ONLY              = 0,      // = 1 to skip power up delay
   parameter DEBUG_EN              = 0,      // Enable debug signals/controls
   parameter FPGA_SPEED_GRADE      = 2       // FPGA Speed Grade
   )
  (
   input                                    clk0,
   input                                    clk90,
   input                                    clkdiv0,
   input                                    rst0,
   input                                    rst90,
   input                                    rstdiv0,
   input [2:0]                              app_af_cmd,
   input [30:0]                             app_af_addr,
   input                                    app_af_wren,
   input                                    app_wdf_wren,
   input [APPDATA_WIDTH-1:0]                app_wdf_data,
   input [(APPDATA_WIDTH/8)-1:0]            app_wdf_mask_data,
   output                                   app_af_afull,
   output                                   app_wdf_afull,
   output                                   rd_data_valid,
   output [APPDATA_WIDTH-1:0]               rd_data_fifo_out,
   output [1:0]                             rd_ecc_error,
   output                                   phy_init_done,
   output [CLK_WIDTH-1:0]                   ddr2_ck,
   output [CLK_WIDTH-1:0]                   ddr2_ck_n,
   output [ROW_WIDTH-1:0]                   ddr2_a,
   output [BANK_WIDTH-1:0]                  ddr2_ba,
   output                                   ddr2_ras_n,
   output                                   ddr2_cas_n,
   output                                   ddr2_we_n,
   output [CS_WIDTH-1:0]                    ddr2_cs_n,
   output [CKE_WIDTH-1:0]                   ddr2_cke,
   output [ODT_WIDTH-1:0]                   ddr2_odt,
   output [DM_WIDTH-1:0]                    ddr2_dm,
   inout [DQS_WIDTH-1:0]                    ddr2_dqs,
   inout [DQS_WIDTH-1:0]                    ddr2_dqs_n,
   inout [DQ_WIDTH-1:0]                     ddr2_dq,
   // Debug signals (optional use)
   input                                    dbg_idel_up_all,
   input                                    dbg_idel_down_all,
   input                                    dbg_idel_up_dq,
   input                                    dbg_idel_down_dq,
   input                                    dbg_idel_up_dqs,
   input                                    dbg_idel_down_dqs,
   input                                    dbg_idel_up_gate,
   input                                    dbg_idel_down_gate,
   input [DQ_BITS-1:0]                      dbg_sel_idel_dq,
   input                                    dbg_sel_all_idel_dq,
   input [DQS_BITS:0]                       dbg_sel_idel_dqs,
   input                                    dbg_sel_all_idel_dqs,
   input [DQS_BITS:0]                       dbg_sel_idel_gate,
   input                                    dbg_sel_all_idel_gate,
   output [3:0]                             dbg_calib_done,
   output [3:0]                             dbg_calib_err,
   output [(6*DQ_WIDTH)-1:0]                dbg_calib_dq_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]               dbg_calib_dqs_tap_cnt,
   output [(6*DQS_WIDTH)-1:0]               dbg_calib_gate_tap_cnt,
   output [DQS_WIDTH-1:0]                   dbg_calib_rd_data_sel,
   output [(5*DQS_WIDTH)-1:0]               dbg_calib_rden_dly,
   output [(5*DQS_WIDTH)-1:0]               dbg_calib_gate_dly
   );

  // memory initialization/control logic
  ddr2_mem_if_top #
    (
     .BANK_WIDTH            (BANK_WIDTH),
     .CKE_WIDTH             (CKE_WIDTH),
     .CLK_WIDTH             (CLK_WIDTH),
     .COL_WIDTH             (COL_WIDTH),
     .CS_BITS               (CS_BITS),
     .CS_NUM                (CS_NUM),
     .CS_WIDTH              (CS_WIDTH),
     .USE_DM_PORT           (USE_DM_PORT),
     .DM_WIDTH              (DM_WIDTH),
     .DQ_WIDTH              (DQ_WIDTH),
     .DQ_BITS               (DQ_BITS),
     .DQ_PER_DQS            (DQ_PER_DQS),
     .DQS_BITS              (DQS_BITS),
     .DQS_WIDTH             (DQS_WIDTH),
     .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),
     .IODELAY_GRP           (IODELAY_GRP),
     .ODT_WIDTH             (ODT_WIDTH),
     .ROW_WIDTH             (ROW_WIDTH),
     .APPDATA_WIDTH         (APPDATA_WIDTH),
     .ADDITIVE_LAT          (ADDITIVE_LAT),
     .BURST_LEN             (BURST_LEN),
     .BURST_TYPE            (BURST_TYPE),
     .CAS_LAT               (CAS_LAT),
     .ECC_ENABLE            (ECC_ENABLE),
     .MULTI_BANK_EN         (MULTI_BANK_EN),
     .TWO_T_TIME_EN         (TWO_T_TIME_EN),
     .ODT_TYPE              (ODT_TYPE),
     .DDR_TYPE              (1),
     .REDUCE_DRV            (REDUCE_DRV),
     .REG_ENABLE            (REG_ENABLE),
     .TREFI_NS              (TREFI_NS),
     .TRAS                  (TRAS),
     .TRCD                  (TRCD),
     .TRFC                  (TRFC),
     .TRP                   (TRP),
     .TRTP                  (TRTP),
     .TWR                   (TWR),
     .TWTR                  (TWTR),
     .CLK_PERIOD            (CLK_PERIOD),
     .SIM_ONLY              (SIM_ONLY),
     .DEBUG_EN              (DEBUG_EN),
     .FPGA_SPEED_GRADE      (FPGA_SPEED_GRADE)
     )
    u_mem_if_top
      (
       .clk0                   (clk0),
       .clk90                  (clk90),
       .clkdiv0                (clkdiv0),
       .rst0                   (rst0),
       .rst90                  (rst90),
       .rstdiv0                (rstdiv0),
       .app_af_cmd             (app_af_cmd),
       .app_af_addr            (app_af_addr),
       .app_af_wren            (app_af_wren),
       .app_wdf_wren           (app_wdf_wren),
       .app_wdf_data           (app_wdf_data),
       .app_wdf_mask_data      (app_wdf_mask_data),
       .app_af_afull           (app_af_afull),
       .app_wdf_afull          (app_wdf_afull),
       .rd_data_valid          (rd_data_valid),
       .rd_data_fifo_out       (rd_data_fifo_out),
       .rd_ecc_error           (rd_ecc_error),
       .phy_init_done          (phy_init_done),
       .ddr_ck                 (ddr2_ck),
       .ddr_ck_n               (ddr2_ck_n),
       .ddr_addr               (ddr2_a),
       .ddr_ba                 (ddr2_ba),
       .ddr_ras_n              (ddr2_ras_n),
       .ddr_cas_n              (ddr2_cas_n),
       .ddr_we_n               (ddr2_we_n),
       .ddr_cs_n               (ddr2_cs_n),
       .ddr_cke                (ddr2_cke),
       .ddr_odt                (ddr2_odt),
       .ddr_dm                 (ddr2_dm),
       .ddr_dqs                (ddr2_dqs),
       .ddr_dqs_n              (ddr2_dqs_n),
       .ddr_dq                 (ddr2_dq),
       .dbg_idel_up_all        (dbg_idel_up_all),
       .dbg_idel_down_all      (dbg_idel_down_all),
       .dbg_idel_up_dq         (dbg_idel_up_dq),
       .dbg_idel_down_dq       (dbg_idel_down_dq),
       .dbg_idel_up_dqs        (dbg_idel_up_dqs),
       .dbg_idel_down_dqs      (dbg_idel_down_dqs),
       .dbg_idel_up_gate       (dbg_idel_up_gate),
       .dbg_idel_down_gate     (dbg_idel_down_gate),
       .dbg_sel_idel_dq        (dbg_sel_idel_dq),
       .dbg_sel_all_idel_dq    (dbg_sel_all_idel_dq),
       .dbg_sel_idel_dqs       (dbg_sel_idel_dqs),
       .dbg_sel_all_idel_dqs   (dbg_sel_all_idel_dqs),
       .dbg_sel_idel_gate      (dbg_sel_idel_gate),
       .dbg_sel_all_idel_gate  (dbg_sel_all_idel_gate),
       .dbg_calib_done         (dbg_calib_done),
       .dbg_calib_err          (dbg_calib_err),
       .dbg_calib_dq_tap_cnt   (dbg_calib_dq_tap_cnt),
       .dbg_calib_dqs_tap_cnt  (dbg_calib_dqs_tap_cnt),
       .dbg_calib_gate_tap_cnt (dbg_calib_gate_tap_cnt),
       .dbg_calib_rd_data_sel  (dbg_calib_rd_data_sel),
       .dbg_calib_rden_dly     (dbg_calib_rden_dly),
       .dbg_calib_gate_dly     (dbg_calib_gate_dly)
       );

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/ddr2_usr_addr_fifo.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_usr_addr_fifo.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Mon Aug 28 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module instantiates the block RAM based FIFO to store the user
//   address and the command information. Also calculates potential bank/row
//   conflicts by comparing the new address with last address issued.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_usr_addr_fifo #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH    = 2,
   parameter COL_WIDTH     = 10,
   parameter CS_BITS       = 0,
   parameter ROW_WIDTH     = 14
   )
  (
   input          clk0,
   input          rst0,
   input [2:0]    app_af_cmd,
   input [30:0]   app_af_addr,
   input          app_af_wren,
   input          ctrl_af_rden,
   output [2:0]   af_cmd,
   output [30:0]  af_addr,
   output         af_empty,
   output         app_af_afull
   );

  wire [35:0]     fifo_data_out;
   reg            rst_r;


  always @(posedge clk0)
     rst_r <= rst0;


  //***************************************************************************

  assign af_cmd      = fifo_data_out[33:31];
  assign af_addr     = fifo_data_out[30:0];

  //***************************************************************************

  FIFO36 #
    (
     .ALMOST_EMPTY_OFFSET     (13'h0007),
     .ALMOST_FULL_OFFSET      (13'h000F),
     .DATA_WIDTH              (36),
     .DO_REG                  (1),
     .EN_SYN                  ("TRUE"),
     .FIRST_WORD_FALL_THROUGH ("FALSE")
     )
    u_af
      (
       .ALMOSTEMPTY (),
       .ALMOSTFULL  (app_af_afull),
       .DO          (fifo_data_out[31:0]),
       .DOP         (fifo_data_out[35:32]),
       .EMPTY       (af_empty),
       .FULL        (),
       .RDCOUNT     (),
       .RDERR       (),
       .WRCOUNT     (),
       .WRERR       (),
       .DI          ({app_af_cmd[0],app_af_addr}),
       .DIP         ({2'b00,app_af_cmd[2:1]}),
       .RDCLK       (clk0),
       .RDEN        (ctrl_af_rden),
       .RST         (rst_r),
       .WRCLK       (clk0),
       .WREN        (app_af_wren)
       );

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/ddr2_usr_top.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_usr_top.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Mon Aug 28 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR2
//Purpose:
//   This module interfaces with the user. The user should provide the data
//   and  various commands.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_usr_top #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH     = 2,
   parameter CS_BITS        = 0,
   parameter COL_WIDTH      = 10,
   parameter DQ_WIDTH       = 72,
   parameter DQ_PER_DQS     = 8,
   parameter APPDATA_WIDTH  = 144,
   parameter ECC_ENABLE     = 0,
   parameter DQS_WIDTH      = 9,
   parameter ROW_WIDTH      = 14
   )
  (
   input                                     clk0,
   input                                     clk90,
   input                                     rst0,
   input [DQ_WIDTH-1:0]                      rd_data_in_rise,
   input [DQ_WIDTH-1:0]                      rd_data_in_fall,
   input [DQS_WIDTH-1:0]                     phy_calib_rden,
   input [DQS_WIDTH-1:0]                     phy_calib_rden_sel,
   output                                    rd_data_valid,
   output [APPDATA_WIDTH-1:0]                rd_data_fifo_out,
   input [2:0]                               app_af_cmd,
   input [30:0]                              app_af_addr,
   input                                     app_af_wren,
   input                                     ctrl_af_rden,
   output [2:0]                              af_cmd,
   output [30:0]                             af_addr,
   output                                    af_empty,
   output                                    app_af_afull,
   output [1:0]                              rd_ecc_error,
   input                                     app_wdf_wren,
   input [APPDATA_WIDTH-1:0]                 app_wdf_data,
   input [(APPDATA_WIDTH/8)-1:0]             app_wdf_mask_data,
   input                                     wdf_rden,
   output                                    app_wdf_afull,
   output [(2*DQ_WIDTH)-1:0]                 wdf_data,
   output [((2*DQ_WIDTH)/8)-1:0]             wdf_mask_data
   );

  wire [(APPDATA_WIDTH/2)-1:0] i_rd_data_fifo_out_fall;
  wire [(APPDATA_WIDTH/2)-1:0] i_rd_data_fifo_out_rise;

  //***************************************************************************

  assign rd_data_fifo_out = {i_rd_data_fifo_out_fall,
                             i_rd_data_fifo_out_rise};

  // read data de-skew and ECC calculation
  ddr2_usr_rd #
    (
     .DQ_PER_DQS    (DQ_PER_DQS),
     .ECC_ENABLE    (ECC_ENABLE),
     .APPDATA_WIDTH (APPDATA_WIDTH),
     .DQS_WIDTH     (DQS_WIDTH)
     )
     u_usr_rd
      (
       .clk0             (clk0),
       .rst0             (rst0),
       .rd_data_in_rise  (rd_data_in_rise),
       .rd_data_in_fall  (rd_data_in_fall),
       .rd_ecc_error     (rd_ecc_error),
       .ctrl_rden        (phy_calib_rden),
       .ctrl_rden_sel    (phy_calib_rden_sel),
       .rd_data_valid    (rd_data_valid),
       .rd_data_out_rise (i_rd_data_fifo_out_rise),
       .rd_data_out_fall (i_rd_data_fifo_out_fall)
       );

  // Command/Addres FIFO
  ddr2_usr_addr_fifo #
    (
     .BANK_WIDTH (BANK_WIDTH),
     .COL_WIDTH  (COL_WIDTH),
     .CS_BITS    (CS_BITS),
     .ROW_WIDTH  (ROW_WIDTH)
     )
     u_usr_addr_fifo
      (
       .clk0         (clk0),
       .rst0         (rst0),
       .app_af_cmd   (app_af_cmd),
       .app_af_addr  (app_af_addr),
       .app_af_wren  (app_af_wren),
       .ctrl_af_rden (ctrl_af_rden),
       .af_cmd       (af_cmd),
       .af_addr      (af_addr),
       .af_empty     (af_empty),
       .app_af_afull (app_af_afull)
       );

  ddr2_usr_wr #
    (
     .BANK_WIDTH    (BANK_WIDTH),
     .COL_WIDTH     (COL_WIDTH),
     .CS_BITS       (CS_BITS),
     .DQ_WIDTH      (DQ_WIDTH),
     .APPDATA_WIDTH (APPDATA_WIDTH),
     .ECC_ENABLE    (ECC_ENABLE),
     .ROW_WIDTH     (ROW_WIDTH)
     )
    u_usr_wr
      (
       .clk0              (clk0),
       .clk90             (clk90),
       .rst0              (rst0),
       .app_wdf_wren      (app_wdf_wren),
       .app_wdf_data      (app_wdf_data),
       .app_wdf_mask_data (app_wdf_mask_data),
       .wdf_rden          (wdf_rden),
       .app_wdf_afull     (app_wdf_afull),
       .wdf_data          (wdf_data),
       .wdf_mask_data     (wdf_mask_data)
       );

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/ipcore_dir/MEMCtrl/user_design/rtl/ddr2_usr_wr.v
// -----------------------------------------------------------------------------
//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_usr_wr.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Mon Aug 28 2006
//  \___\/\___\
//
//Device: Virtex-5
//Design Name: DDR/DDR2
//Purpose:
//   This module instantiates the modules containing internal FIFOs
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_usr_wr #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference 
   // board design). Actual values may be different. Actual parameters values 
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH    = 2,
   parameter COL_WIDTH     = 10,
   parameter CS_BITS       = 0,
   parameter DQ_WIDTH      = 72,
   parameter APPDATA_WIDTH = 144,
   parameter ECC_ENABLE    = 0,
   parameter ROW_WIDTH     = 14
   )
  (
   input                         clk0,
   input                         clk90,
   input                         rst0,
   // Write data FIFO interface
   input                         app_wdf_wren,
   input [APPDATA_WIDTH-1:0]     app_wdf_data,
   input [(APPDATA_WIDTH/8)-1:0] app_wdf_mask_data,
   input                         wdf_rden,
   output                        app_wdf_afull,
   output [(2*DQ_WIDTH)-1:0]     wdf_data,
   output [((2*DQ_WIDTH)/8)-1:0] wdf_mask_data
   );

  // determine number of FIFO72's to use based on data width
  // round up to next integer value when determining WDF_FIFO_NUM
  localparam WDF_FIFO_NUM = (ECC_ENABLE) ? (APPDATA_WIDTH+63)/64 :
             ((2*DQ_WIDTH)+63)/64;
  // MASK_WIDTH = number of bytes in data bus
  localparam MASK_WIDTH = DQ_WIDTH/8;

  wire [WDF_FIFO_NUM-1:0]      i_wdf_afull;
  wire [DQ_WIDTH-1:0]          i_wdf_data_fall_in;
  wire [DQ_WIDTH-1:0]          i_wdf_data_fall_out;
  wire [(64*WDF_FIFO_NUM)-1:0] i_wdf_data_in;
  wire [(64*WDF_FIFO_NUM)-1:0] i_wdf_data_out;
  wire [DQ_WIDTH-1:0]          i_wdf_data_rise_in;
  wire [DQ_WIDTH-1:0]          i_wdf_data_rise_out;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_fall_in;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_fall_out;
  wire [(8*WDF_FIFO_NUM)-1:0]  i_wdf_mask_data_in;
  wire [(8*WDF_FIFO_NUM)-1:0]  i_wdf_mask_data_out;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_rise_in;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_rise_out;
  reg                          rst_r;

  // ECC signals
  wire [(2*DQ_WIDTH)-1:0]      i_wdf_data_out_ecc;
  wire [((2*DQ_WIDTH)/8)-1:0]  i_wdf_mask_data_out_ecc;
  wire [63:0]                  i_wdf_mask_data_out_ecc_wire;
  wire [((2*DQ_WIDTH)/8)-1:0]  mask_data_in_ecc;
  wire [63:0]                  mask_data_in_ecc_wire;

  //***************************************************************************

  assign app_wdf_afull = i_wdf_afull[0];

  always @(posedge clk0 )
      rst_r <= rst0;

  genvar wdf_di_i;
  genvar wdf_do_i;
  genvar mask_i;
  genvar wdf_i;
  generate
    if(ECC_ENABLE) begin    // ECC code

      assign wdf_data = i_wdf_data_out_ecc;

      // the byte 9 dm is always held to 0
      assign wdf_mask_data = i_wdf_mask_data_out_ecc;



      // generate for write data fifo .
      for (wdf_i = 0; wdf_i < WDF_FIFO_NUM; wdf_i = wdf_i + 1) begin: gen_wdf

        FIFO36_72  #
          (
           .ALMOST_EMPTY_OFFSET     (9'h007),
           .ALMOST_FULL_OFFSET      (9'h00F),
           .DO_REG                  (1),          // extra CC output delay
           .EN_ECC_WRITE            ("TRUE"),
           .EN_ECC_READ             ("FALSE"),
           .EN_SYN                  ("FALSE"),
           .FIRST_WORD_FALL_THROUGH ("FALSE")
           )
          u_wdf_ecc
            (
             .ALMOSTEMPTY (),
             .ALMOSTFULL  (i_wdf_afull[wdf_i]),
             .DBITERR     (),
             .DO          (i_wdf_data_out_ecc[((64*(wdf_i+1))+(wdf_i *8))-1:
                                              (64*wdf_i)+(wdf_i *8)]),
             .DOP         (i_wdf_data_out_ecc[(72*(wdf_i+1))-1:
                                              (64*(wdf_i+1))+ (8*wdf_i) ]),
             .ECCPARITY   (),
             .EMPTY       (),
             .FULL        (),
             .RDCOUNT     (),
             .RDERR       (),
             .SBITERR     (),
             .WRCOUNT     (),
             .WRERR       (),
             .DI          (app_wdf_data[(64*(wdf_i+1))-1:
                                        (64*wdf_i)]),
             .DIP         (),
             .RDCLK       (clk90),
             .RDEN        (wdf_rden),
             .RST         (rst_r),          // or can use rst0
             .WRCLK       (clk0),
             .WREN        (app_wdf_wren)
             );
      end

      // remapping the mask data. The mask data from user i/f does not have
      // the mask for the ECC byte. Assigning 0 to the ECC mask byte.
      for (mask_i = 0; mask_i < (DQ_WIDTH)/36;
           mask_i = mask_i +1) begin: gen_mask
        assign mask_data_in_ecc[((8*(mask_i+1))+ mask_i)-1:((8*mask_i)+mask_i)]
                 = app_wdf_mask_data[(8*(mask_i+1))-1:8*(mask_i)] ;
        assign mask_data_in_ecc[((8*(mask_i+1))+mask_i)] = 1'd0;
      end

      // assign ecc bits to temp variables to avoid
      // sim warnings. Not all the 64 bits of the fifo
      // are used in ECC mode.
       assign  mask_data_in_ecc_wire[((2*DQ_WIDTH)/8)-1:0] = mask_data_in_ecc;
       assign  mask_data_in_ecc_wire[63:((2*DQ_WIDTH)/8)]  =
              {(64-((2*DQ_WIDTH)/8)){1'b0}};
       assign i_wdf_mask_data_out_ecc =
               i_wdf_mask_data_out_ecc_wire[((2*DQ_WIDTH)/8)-1:0];


      FIFO36_72  #
        (
         .ALMOST_EMPTY_OFFSET     (9'h007),
         .ALMOST_FULL_OFFSET      (9'h00F),
         .DO_REG                  (1),          // extra CC output delay
         .EN_ECC_WRITE            ("TRUE"),
         .EN_ECC_READ             ("FALSE"),
         .EN_SYN                  ("FALSE"),
         .FIRST_WORD_FALL_THROUGH ("FALSE")
         )
        u_wdf_ecc_mask
          (
           .ALMOSTEMPTY (),
           .ALMOSTFULL  (),
           .DBITERR     (),
           .DO          (i_wdf_mask_data_out_ecc_wire),
           .DOP         (),
           .ECCPARITY   (),
           .EMPTY       (),
           .FULL        (),
           .RDCOUNT     (),
           .RDERR       (),
           .SBITERR     (),
           .WRCOUNT     (),
           .WRERR       (),
           .DI          (mask_data_in_ecc_wire),
           .DIP         (),
           .RDCLK       (clk90),
           .RDEN        (wdf_rden),
           .RST         (rst_r),          // or can use rst0
           .WRCLK       (clk0),
           .WREN        (app_wdf_wren)
           );
    end else begin

      //***********************************************************************

      // Define intermediate buses:
      assign i_wdf_data_rise_in
        = app_wdf_data[DQ_WIDTH-1:0];
      assign i_wdf_data_fall_in
        = app_wdf_data[(2*DQ_WIDTH)-1:DQ_WIDTH];
      assign i_wdf_mask_data_rise_in
        = app_wdf_mask_data[MASK_WIDTH-1:0];
      assign i_wdf_mask_data_fall_in
        = app_wdf_mask_data[(2*MASK_WIDTH)-1:MASK_WIDTH];

      //***********************************************************************
      // Write data FIFO Input:
      // Arrange DQ's so that the rise data and fall data are interleaved.
      // the data arrives at the input of the wdf fifo as {fall,rise}.
      // It is remapped as:
      //     {...fall[15:8],rise[15:8],fall[7:0],rise[7:0]}
      // This is done to avoid having separate fifo's for rise and fall data
      // and to keep rise/fall data for the same DQ's on same FIFO
      // Data masks are interleaved in a similar manner
      // NOTE: Initialization data from PHY_INIT module does not need to be
      //  interleaved - it's already in the correct format - and the same
      //  initialization pattern from PHY_INIT is sent to all write FIFOs
      //***********************************************************************

      for (wdf_di_i = 0; wdf_di_i < MASK_WIDTH;
           wdf_di_i = wdf_di_i + 1) begin: gen_wdf_data_in
        assign i_wdf_data_in[(16*wdf_di_i)+15:(16*wdf_di_i)]
                 = {i_wdf_data_fall_in[(8*wdf_di_i)+7:(8*wdf_di_i)],
                    i_wdf_data_rise_in[(8*wdf_di_i)+7:(8*wdf_di_i)]};
        assign i_wdf_mask_data_in[(2*wdf_di_i)+1:(2*wdf_di_i)]
                 = {i_wdf_mask_data_fall_in[wdf_di_i],
                    i_wdf_mask_data_rise_in[wdf_di_i]};
      end

      //***********************************************************************
      // Write data FIFO Output:
      // FIFO DQ and mask outputs must be untangled and put in the standard
      // format of {fall,rise}. Same goes for mask output
      //***********************************************************************

      for (wdf_do_i = 0; wdf_do_i < MASK_WIDTH;
           wdf_do_i = wdf_do_i + 1) begin: gen_wdf_data_out
        assign i_wdf_data_rise_out[(8*wdf_do_i)+7:(8*wdf_do_i)]
                 = i_wdf_data_out[(16*wdf_do_i)+7:(16*wdf_do_i)];
        assign i_wdf_data_fall_out[(8*wdf_do_i)+7:(8*wdf_do_i)]
                 = i_wdf_data_out[(16*wdf_do_i)+15:(16*wdf_do_i)+8];
        assign i_wdf_mask_data_rise_out[wdf_do_i]
                 = i_wdf_mask_data_out[2*wdf_do_i];
        assign i_wdf_mask_data_fall_out[wdf_do_i]
                 = i_wdf_mask_data_out[(2*wdf_do_i)+1];
      end

      assign wdf_data = {i_wdf_data_fall_out,
                         i_wdf_data_rise_out};

      assign wdf_mask_data = {i_wdf_mask_data_fall_out,
                              i_wdf_mask_data_rise_out};

      //***********************************************************************

      for (wdf_i = 0; wdf_i < WDF_FIFO_NUM; wdf_i = wdf_i + 1) begin: gen_wdf

        FIFO36_72  #
          (
           .ALMOST_EMPTY_OFFSET     (9'h007),
           .ALMOST_FULL_OFFSET      (9'h00F),
           .DO_REG                  (1),          // extra CC output delay
           .EN_ECC_WRITE            ("FALSE"),
           .EN_ECC_READ             ("FALSE"),
           .EN_SYN                  ("FALSE"),
           .FIRST_WORD_FALL_THROUGH ("FALSE")
           )
          u_wdf
            (
             .ALMOSTEMPTY (),
             .ALMOSTFULL  (i_wdf_afull[wdf_i]),
             .DBITERR     (),
             .DO          (i_wdf_data_out[(64*(wdf_i+1))-1:64*wdf_i]),
             .DOP         (i_wdf_mask_data_out[(8*(wdf_i+1))-1:8*wdf_i]),
             .ECCPARITY   (),
             .EMPTY       (),
             .FULL        (),
             .RDCOUNT     (),
             .RDERR       (),
             .SBITERR     (),
             .WRCOUNT     (),
             .WRERR       (),
             .DI          (i_wdf_data_in[(64*(wdf_i+1))-1:64*wdf_i]),
             .DIP         (i_wdf_mask_data_in[(8*(wdf_i+1))-1:8*wdf_i]),
             .RDCLK       (clk90),
             .RDEN        (wdf_rden),
             .RST         (rst_r),          // or can use rst0
             .WRCLK       (clk0),
             .WREN        (app_wdf_wren)
             );
      end
    end
  endgenerate

endmodule
