// Curated RTL benchmark case.
// case_id: bench_0203_communication_controller_sata_phy
// source_project: communication_controller_sata_phy
// top_module: sata_phy_top_x6series


// -----------------------------------------------------------------------------
// Source file: hdl/sata_constants.v
// -----------------------------------------------------------------------------

`define ALIGN_VAL     32'h7B_4A_4A_BC   
`define CONT_VAL      32'h99_99_AA_7C   
`define DMAT_VAL      32'h36_36_B5_7C   
`define EOF_VAL       32'hD5_D5_B5_7C   
`define HOLD_VAL      32'hD5_D5_AA_7C   
`define HOLDA_VAL     32'h95_95_AA_7C   
`define PMACK_VAL     32'h95_95_95_7C   
`define PMNAK_VAL     32'hF5_F5_95_7C   
`define PMREQ_P_VAL   32'h17_17_B5_7C   
`define PMREQ_S_VAL   32'h75_75_95_7C   
`define R_ERR_VAL     32'h56_56_B5_7C   
`define R_IP_VAL      32'h55_55_B5_7C   
`define R_OK_VAL      32'h35_35_B5_7C   
`define R_RDY_VAL     32'h4A_4A_95_7C   
`define SOF_VAL       32'h37_37_B5_7C   
`define SYNC_VAL      32'hB5_B5_95_7C   
`define WTRM_VAL      32'h58_58_B5_7C   
`define X_RDY_VAL     32'h57_57_B5_7C   
                                        

// -----------------------------------------------------------------------------
// Source file: hdl/sata_phy_top_x6series.v
// -----------------------------------------------------------------------------
////////////////////////////////////////////////////////////
//
// This confidential and proprietary software may be used
// only as authorized by a licensing agreement from
// Bean Digital Ltd
// In the event of publication, the following notice is
// applicable:
//
// (C)COPYRIGHT 2012 BEAN DIGITAL LTD.
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all
// authorized copies.
//
// File        : sata_phy_top_x6series.v
// Author      : J.Bean
// Date        : Mar 2012
// Description : SATA PHY Layer Top Xilinx 6 Series
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

`include "sata_constants.v"

module sata_phy_top_x6series
  #(parameter DATA_BITS = 32,                         // Data Bits
    parameter IS_HOST   = 1,                          // 1 = Host, 0 = Device  
    parameter SATA_REV  = 1)(                         // SATA Revision (1, 2, 3)
  input  wire                     clk,                // Clock
  input  wire                     clk_phy,            // Clock PHY
  input  wire                     rst_n,              // Reset
  // Link Transmit
  input  wire [DATA_BITS-1:0]     lnk_tx_tdata_i,     // Link Transmit Data 
  input  wire                     lnk_tx_tvalid_i,    // Link Transmit Source Ready 
  output wire                     lnk_tx_tready_o,    // Link Transmit Destination Ready
  input  wire [3:0]               lnk_tx_tuser_i,     // Link Transmit User
  // Link Receive
  output wire [DATA_BITS-1:0]     lnk_rx_tdata_o,     // Link Receive Data 
  output wire                     lnk_rx_tvalid_o,    // Link Receive Source Ready     
  input  wire                     lnk_rx_tready_i,    // Link Receive Destination Ready     
  output wire [7:0]               lnk_rx_tuser_o,     // Link Receive User    
  // Status
  output wire [7:0]               phy_status_o,       // PHY Status      
  // Transceiver
  input  wire                     gt_rst_done_i,      // GT Reset Done
  input  wire [15:0]              gt_rx_data_i,       // GT Receive Data
  input  wire [1:0]               gt_rx_charisk_i,    // GT Receive K/D
  input  wire [1:0]               gt_rx_disp_err_i,   // GT Receive Disparity Error
  input  wire [1:0]               gt_rx_8b10b_err_i,  // GT Receive 8b10b Error
  input  wire                     gt_rx_elec_idle_i,  // GT Receive Electrical Idle
  input  wire [2:0]               gt_rx_status_i,     // GT Receive Status     
  output wire [15:0]              gt_tx_data_o,       // GT Transmit Data
  output wire [1:0]               gt_tx_charisk_o,    // GT Transmit K/D
  output wire                     gt_tx_elec_idle_o,  // GT Transmit Electrical Idle
  output wire                     gt_tx_com_strt_o,   // GT Transmit Com Start 
  output wire                     gt_tx_com_type_o    // GT Transmit Com Type
);

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

wire                 link_up;         // Link Up
reg                  tx_data_mux_sel; // Transmit Mux Data Select
reg  [7:0]           rx_data_mux_sel; // Receive Mux Data Select
wire [31:0]          gt_rx_data;      // GT Receive Data
reg  [31:0]          gt_rx_data_r;    // GT Receive Data
wire [3:0]           gt_rx_charisk;   // GT Receive K/D
reg  [3:0]           gt_rx_charisk_r; // GT Receive K/D
wire [3:0]           gt_rx_err;       // GT Receive Error
reg  [3:0]           gt_rx_err_r;     // GT Receive Error
reg                  gt_rx_valid;     // GT Receive Valid
reg  [47:0]          gt_rx_data_sr;   // GT Receive Data Shift Reg
reg  [5:0]           gt_rx_k_sr;      // GT Receive K/D Shift Reg
reg  [5:0]           gt_rx_err_sr;    // GT Receive Error Shift Reg
wire [31:0]          gt_tx_data;      // GT Transmit Data
wire [3:0]           gt_tx_charisk;   // GT Transmit K/D
wire [DATA_BITS-1:0] lnk_tx_tdata;    // Link Transmit Data
wire                 lnk_tx_tvalid;   // Link Transmit Source Ready  
reg                  lnk_tx_tready;   // Link Transmit Destination Ready
wire [3:0]           lnk_tx_tuser;    // Link Transmit User 
wire [DATA_BITS-1:0] lnk_rx_tdata;    // Link Receive Data
wire                 lnk_rx_tvalid;   // Link Receive Source Ready  
wire                 lnk_rx_tready;   // Link Receive Destination Ready
wire [7:0]           lnk_rx_tuser;    // Link Receive User

////////////////////////////////////////////////////////////
// Comb Assign : PHY Status
// Description : 
////////////////////////////////////////////////////////////

assign phy_status_o = {7'd0, link_up};

////////////////////////////////////////////////////////////
// Comb Assign : Port Signals
// Description : 
////////////////////////////////////////////////////////////

assign lnk_rx_tdata      = gt_rx_data_r;
assign lnk_rx_tvalid     = gt_rx_valid;
assign lnk_rx_tuser[3:0] = gt_rx_charisk_r;
assign lnk_rx_tuser[7:4] = gt_rx_err_r;

////////////////////////////////////////////////////////////
// Instance    : PHY Transmit FIFO
// Description : 
////////////////////////////////////////////////////////////

axis_fifo_36W_16D U_phy_tx_fifo(
  .m_aclk        (clk_phy), 
  .s_aclk        (clk), 
  .s_aresetn     (rst_n), 
  .s_axis_tdata  (lnk_tx_tdata_i),
  .s_axis_tuser  (lnk_tx_tuser_i),  
  .s_axis_tvalid (lnk_tx_tvalid_i),
  .s_axis_tready (lnk_tx_tready_o),
  .m_axis_tdata  (lnk_tx_tdata),
  .m_axis_tuser  (lnk_tx_tuser),  
  .m_axis_tvalid (lnk_tx_tvalid), 
  .m_axis_tready (lnk_tx_tready));
  
////////////////////////////////////////////////////////////
// Instance    : PHY Receive FIFO
// Description : 
////////////////////////////////////////////////////////////

axis_fifo_40W_16D U_phy_rx_fifo(
  .m_aclk        (clk), 
  .s_aclk        (clk_phy), 
  .s_aresetn     (rst_n), 
  .s_axis_tdata  (lnk_rx_tdata),
  .s_axis_tuser  (lnk_rx_tuser),  
  .s_axis_tvalid (lnk_rx_tvalid),
  .s_axis_tready (lnk_rx_tready),
  .m_axis_tdata  (lnk_rx_tdata_o),
  .m_axis_tuser  (lnk_rx_tuser_o),  
  .m_axis_tvalid (lnk_rx_tvalid_o), 
  .m_axis_tready (lnk_rx_tready_i));

////////////////////////////////////////////////////////////
// Instance    : GT Receive Data
// Description : 
////////////////////////////////////////////////////////////
  
mux #(
  .DATA_BITS  (DATA_BITS),
  .IP_NUM     (2),
  .USE_OP_REG (0))
  U_rx_data_mux(
  .clk        (clk_phy),
  .data_i     ({gt_rx_data_sr[39:8], gt_rx_data_sr[31:0]}),
  .sel_i      (rx_data_mux_sel),
  .data_o     (gt_rx_data));

////////////////////////////////////////////////////////////
// Instance    : GT Receive K/D
// Description : 
////////////////////////////////////////////////////////////
  
mux #(
  .DATA_BITS  (4),
  .IP_NUM     (2),
  .USE_OP_REG (0))
  U_rx_charisk_mux(
  .clk        (clk_phy),
  .data_i     ({gt_rx_k_sr[4:1], gt_rx_k_sr[3:0]}),
  .sel_i      (rx_data_mux_sel),
  .data_o     (gt_rx_charisk));
    
////////////////////////////////////////////////////////////
// Instance    : GT Receive Error
// Description : 
////////////////////////////////////////////////////////////

mux #(
  .DATA_BITS  (4),
  .IP_NUM     (2),
  .USE_OP_REG (0))
  U_rx_err_mux(
  .clk        (clk_phy),
  .data_i     ({gt_rx_err_sr[4:1], gt_rx_err_sr[3:0]}),
  .sel_i      (rx_data_mux_sel),
  .data_o     (gt_rx_err));

////////////////////////////////////////////////////////////
// Instance    : GT Transmit Data
// Description : 
////////////////////////////////////////////////////////////
  
mux #(
  .DATA_BITS  (16),
  .IP_NUM     (4),
  .USE_OP_REG (1))
  U_txdata_mux(
  .clk        (clk_phy),
  .data_i     ({lnk_tx_tdata[31:16], lnk_tx_tdata[15:0], gt_tx_data[31:16], gt_tx_data[15:0]}),
  .sel_i      ({6'd0, link_up, tx_data_mux_sel}),
  .data_o     (gt_tx_data_o));

////////////////////////////////////////////////////////////
// Instance    : GT Transmit K/D
// Description : 
////////////////////////////////////////////////////////////

mux #(
  .DATA_BITS  (2),
  .IP_NUM     (4),
  .USE_OP_REG (1))
  U_txcharisk_mux(
  .clk        (clk_phy),
  .data_i     ({lnk_tx_tuser[3:2], lnk_tx_tuser[1:0], gt_tx_charisk[3:2], gt_tx_charisk[1:0]}),
  .sel_i      ({6'd0, link_up, tx_data_mux_sel}),
  .data_o     (gt_tx_charisk_o));

////////////////////////////////////////////////////////////
// Instance    : SATA Spartan 6 PHY Control
// Description : 
////////////////////////////////////////////////////////////
  
generate 
  if (IS_HOST == 1) begin
    sata_phy_host_ctrl_x6series #(
      .SATA_REV          (SATA_REV))
      U_phy_host_ctrl_x6series(
      .clk_phy           (clk_phy),
      .rst_n		      		   (rst_n),
      .link_up_o         (link_up), 
      .gt_rst_done_i     (gt_rst_done_i),  
      .gt_tx_data_o      (gt_tx_data),		         
      .gt_tx_charisk_o   (gt_tx_charisk),  
      .gt_tx_com_strt_o  (gt_tx_com_strt_o),
      .gt_tx_com_type_o  (gt_tx_com_type_o),
      .gt_tx_elec_idle_o (gt_tx_elec_idle_o),     
      .gt_rx_data_i      (lnk_rx_tdata_o),                                                                  
      .gt_rx_status_i    (gt_rx_status_i),
      .gt_rx_elec_idle_i (gt_rx_elec_idle_i));
  end else begin
    sata_phy_dev_ctrl_x6series #(
      .SATA_REV          (SATA_REV))
      U_phy_dev_ctrl_x6series(
      .clk_phy           (clk_phy),
      .rst_n		      		   (rst_n),
      .link_up_o         (link_up), 
      .gt_rst_done_i     (gt_rst_done_i),  
      .gt_tx_data_o      (gt_tx_data),		         
      .gt_tx_charisk_o   (gt_tx_charisk),   
      .gt_tx_com_strt_o  (gt_tx_com_strt_o),
      .gt_tx_com_type_o  (gt_tx_com_type_o),
      .gt_tx_elec_idle_o (gt_tx_elec_idle_o),     
      .gt_rx_data_i      (lnk_rx_tdata_o),                                                                       
      .gt_rx_status_i    (gt_rx_status_i));
  end
endgenerate  

////////////////////////////////////////////////////////////
// Seq Block   : Receive Data Shift Register
// Description : 
////////////////////////////////////////////////////////////

always@(posedge clk_phy)
begin
  gt_rx_data_sr[47:32] <= gt_rx_data_i;
  gt_rx_data_sr[31:0]  <= gt_rx_data_sr[47:16];
end

////////////////////////////////////////////////////////////
// Seq Block   : Receive K Shift Register
// Description : 
////////////////////////////////////////////////////////////

always@(posedge clk_phy)
begin
  gt_rx_k_sr[5:4] <= gt_rx_charisk_i;
  gt_rx_k_sr[3:0] <= gt_rx_k_sr[5:2];
end

////////////////////////////////////////////////////////////
// Seq Block   : Receive Error Shift Register
// Description : 
////////////////////////////////////////////////////////////

always@(posedge clk_phy)
begin
  gt_rx_err_sr[4]   <= gt_rx_disp_err_i[0] | gt_rx_8b10b_err_i[0];
  gt_rx_err_sr[5]   <= gt_rx_disp_err_i[1] | gt_rx_8b10b_err_i[1];
  gt_rx_err_sr[3:0] <= gt_rx_err_sr[5:2];
end

////////////////////////////////////////////////////////////
// Seq Block   : Link Transmit Desrination Ready
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy)
begin
  if (rst_n == 0) begin
    lnk_tx_tready <= 0;
  end else begin
    if (lnk_tx_tready == 0) begin
      lnk_tx_tready <= 1;    
    end else begin
      lnk_tx_tready <= 0;    
    end      
  end   
end

////////////////////////////////////////////////////////////
// Comb Block  : Transmit Mux Data Select
// Description : Selects 16-bit data to send to the transceiver
//               from the 32-bit data on the mux input.
////////////////////////////////////////////////////////////

always @(*)
begin
  if ((lnk_tx_tvalid == 1) && (lnk_tx_tready == 1)) begin
    tx_data_mux_sel = 0;
  end else begin
    tx_data_mux_sel = 1;  
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Receive Mux Data Select
// Description : Determines the location of the data in the 
//               GT receive data, and then sets the select.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy)
begin
  if (rst_n == 0) begin
    rx_data_mux_sel <= 0;
  end else begin
    // Test for the ALIGN primitive in bits 31:0
    if ((gt_rx_k_sr[3:0] == 4'b0001) && (gt_rx_data_sr[31:0] == `ALIGN_VAL)) begin
      rx_data_mux_sel <= 0;    
    end else begin  
      // Test for the ALIGN primitive in bits 39:8
      if ((gt_rx_k_sr[4:1] == 4'b0001) && (gt_rx_data_sr[39:8] == `ALIGN_VAL)) begin
        rx_data_mux_sel <= 1;    
      end
    end
  end   
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Receive Valid
// Description : Indicates when the data is valid. It is 
//               synchronised to the ALIGN primitive.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy)
begin 
  if (rst_n == 0) begin
    gt_rx_valid <= 0;
  end	else begin
    if ((gt_rx_charisk == 4'b0001) && (gt_rx_data == `ALIGN_VAL)) begin
      gt_rx_valid <= 1;
    end else begin
      if (gt_rx_valid == 1) begin
        gt_rx_valid <= 0;
      end else begin
        gt_rx_valid <= 1;
      end
    end      
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Receive Data
// Description :
////////////////////////////////////////////////////////////

always @(posedge clk_phy)
begin    
  gt_rx_data_r <= gt_rx_data;
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Receive K/D
// Description :
////////////////////////////////////////////////////////////

always @(posedge clk_phy)
begin    
  gt_rx_charisk_r <= gt_rx_charisk;
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Receive Error
// Description :
////////////////////////////////////////////////////////////

always @(posedge clk_phy)
begin    
  gt_rx_err_r <= gt_rx_err;
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/axis_fifo_36W_16D.v
// -----------------------------------------------------------------------------
/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used solely      *
*     for design, simulation, implementation and creation of design files      *
*     limited to Xilinx devices or technologies. Use with non-Xilinx           *
*     devices or technologies is expressly prohibited and immediately          *
*     terminates your license.                                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY     *
*     FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY     *
*     PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE              *
*     IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS       *
*     MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY       *
*     CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY        *
*     RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY        *
*     DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE    *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A    *
*     PARTICULAR PURPOSE.                                                      *
*                                                                              *
*     Xilinx products are not intended for use in life support appliances,     *
*     devices, or systems.  Use in such applications are expressly             *
*     prohibited.                                                              *
*                                                                              *
*     (c) Copyright 1995-2012 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// You must compile the wrapper file axis_fifo_36W_16D.v when simulating
// the core, axis_fifo_36W_16D. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

// The synthesis directives "translate_off/translate_on" specified below are
// supported by Xilinx, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

`timescale 1ns/1ps

module axis_fifo_36W_16D(
  m_aclk,
  s_aclk,
  s_aresetn,
  s_axis_tvalid,
  s_axis_tready,
  s_axis_tdata,
  s_axis_tuser,
  m_axis_tvalid,
  m_axis_tready,
  m_axis_tdata,
  m_axis_tuser
);

input m_aclk;
input s_aclk;
input s_aresetn;
input s_axis_tvalid;
output s_axis_tready;
input [31 : 0] s_axis_tdata;
input [3 : 0] s_axis_tuser;
output m_axis_tvalid;
input m_axis_tready;
output [31 : 0] m_axis_tdata;
output [3 : 0] m_axis_tuser;

// synthesis translate_off

  FIFO_GENERATOR_V8_4 #(
    .C_ADD_NGC_CONSTRAINT(0),
    .C_APPLICATION_TYPE_AXIS(0),
    .C_APPLICATION_TYPE_RACH(0),
    .C_APPLICATION_TYPE_RDCH(0),
    .C_APPLICATION_TYPE_WACH(0),
    .C_APPLICATION_TYPE_WDCH(0),
    .C_APPLICATION_TYPE_WRCH(0),
    .C_AXI_ADDR_WIDTH(32),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_DATA_WIDTH(64),
    .C_AXI_ID_WIDTH(4),
    .C_AXI_RUSER_WIDTH(1),
    .C_AXI_TYPE(0),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXIS_TDATA_WIDTH(32),
    .C_AXIS_TDEST_WIDTH(4),
    .C_AXIS_TID_WIDTH(8),
    .C_AXIS_TKEEP_WIDTH(4),
    .C_AXIS_TSTRB_WIDTH(4),
    .C_AXIS_TUSER_WIDTH(4),
    .C_AXIS_TYPE(0),
    .C_COMMON_CLOCK(0),
    .C_COUNT_TYPE(0),
    .C_DATA_COUNT_WIDTH(10),
    .C_DEFAULT_VALUE("BlankString"),
    .C_DIN_WIDTH(18),
    .C_DIN_WIDTH_AXIS(36),
    .C_DIN_WIDTH_RACH(32),
    .C_DIN_WIDTH_RDCH(64),
    .C_DIN_WIDTH_WACH(32),
    .C_DIN_WIDTH_WDCH(64),
    .C_DIN_WIDTH_WRCH(2),
    .C_DOUT_RST_VAL("0"),
    .C_DOUT_WIDTH(18),
    .C_ENABLE_RLOCS(0),
    .C_ENABLE_RST_SYNC(1),
    .C_ERROR_INJECTION_TYPE(0),
    .C_ERROR_INJECTION_TYPE_AXIS(0),
    .C_ERROR_INJECTION_TYPE_RACH(0),
    .C_ERROR_INJECTION_TYPE_RDCH(0),
    .C_ERROR_INJECTION_TYPE_WACH(0),
    .C_ERROR_INJECTION_TYPE_WDCH(0),
    .C_ERROR_INJECTION_TYPE_WRCH(0),
    .C_FAMILY("spartan6"),
    .C_FULL_FLAGS_RST_VAL(1),
    .C_HAS_ALMOST_EMPTY(0),
    .C_HAS_ALMOST_FULL(0),
    .C_HAS_AXI_ARUSER(0),
    .C_HAS_AXI_AWUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_RD_CHANNEL(0),
    .C_HAS_AXI_RUSER(0),
    .C_HAS_AXI_WR_CHANNEL(0),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXIS_TDATA(1),
    .C_HAS_AXIS_TDEST(0),
    .C_HAS_AXIS_TID(0),
    .C_HAS_AXIS_TKEEP(0),
    .C_HAS_AXIS_TLAST(0),
    .C_HAS_AXIS_TREADY(1),
    .C_HAS_AXIS_TSTRB(0),
    .C_HAS_AXIS_TUSER(1),
    .C_HAS_BACKUP(0),
    .C_HAS_DATA_COUNT(0),
    .C_HAS_DATA_COUNTS_AXIS(0),
    .C_HAS_DATA_COUNTS_RACH(0),
    .C_HAS_DATA_COUNTS_RDCH(0),
    .C_HAS_DATA_COUNTS_WACH(0),
    .C_HAS_DATA_COUNTS_WDCH(0),
    .C_HAS_DATA_COUNTS_WRCH(0),
    .C_HAS_INT_CLK(0),
    .C_HAS_MASTER_CE(0),
    .C_HAS_MEMINIT_FILE(0),
    .C_HAS_OVERFLOW(0),
    .C_HAS_PROG_FLAGS_AXIS(0),
    .C_HAS_PROG_FLAGS_RACH(0),
    .C_HAS_PROG_FLAGS_RDCH(0),
    .C_HAS_PROG_FLAGS_WACH(0),
    .C_HAS_PROG_FLAGS_WDCH(0),
    .C_HAS_PROG_FLAGS_WRCH(0),
    .C_HAS_RD_DATA_COUNT(0),
    .C_HAS_RD_RST(0),
    .C_HAS_RST(1),
    .C_HAS_SLAVE_CE(0),
    .C_HAS_SRST(0),
    .C_HAS_UNDERFLOW(0),
    .C_HAS_VALID(0),
    .C_HAS_WR_ACK(0),
    .C_HAS_WR_DATA_COUNT(0),
    .C_HAS_WR_RST(0),
    .C_IMPLEMENTATION_TYPE(0),
    .C_IMPLEMENTATION_TYPE_AXIS(12),
    .C_IMPLEMENTATION_TYPE_RACH(12),
    .C_IMPLEMENTATION_TYPE_RDCH(11),
    .C_IMPLEMENTATION_TYPE_WACH(12),
    .C_IMPLEMENTATION_TYPE_WDCH(11),
    .C_IMPLEMENTATION_TYPE_WRCH(12),
    .C_INIT_WR_PNTR_VAL(0),
    .C_INTERFACE_TYPE(1),
    .C_MEMORY_TYPE(1),
    .C_MIF_FILE_NAME("BlankString"),
    .C_MSGON_VAL(1),
    .C_OPTIMIZATION_MODE(0),
    .C_OVERFLOW_LOW(0),
    .C_PRELOAD_LATENCY(1),
    .C_PRELOAD_REGS(0),
    .C_PRIM_FIFO_TYPE("4kx4"),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL(2),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(13),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(13),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1021),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(13),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1021),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(13),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL(3),
    .C_PROG_EMPTY_TYPE(0),
    .C_PROG_EMPTY_TYPE_AXIS(5),
    .C_PROG_EMPTY_TYPE_RACH(5),
    .C_PROG_EMPTY_TYPE_RDCH(5),
    .C_PROG_EMPTY_TYPE_WACH(5),
    .C_PROG_EMPTY_TYPE_WDCH(5),
    .C_PROG_EMPTY_TYPE_WRCH(5),
    .C_PROG_FULL_THRESH_ASSERT_VAL(1022),
    .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(15),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(15),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(15),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(15),
    .C_PROG_FULL_THRESH_NEGATE_VAL(1021),
    .C_PROG_FULL_TYPE(0),
    .C_PROG_FULL_TYPE_AXIS(5),
    .C_PROG_FULL_TYPE_RACH(5),
    .C_PROG_FULL_TYPE_RDCH(5),
    .C_PROG_FULL_TYPE_WACH(5),
    .C_PROG_FULL_TYPE_WDCH(5),
    .C_PROG_FULL_TYPE_WRCH(5),
    .C_RACH_TYPE(0),
    .C_RD_DATA_COUNT_WIDTH(10),
    .C_RD_DEPTH(1024),
    .C_RD_FREQ(1),
    .C_RD_PNTR_WIDTH(10),
    .C_RDCH_TYPE(0),
    .C_REG_SLICE_MODE_AXIS(0),
    .C_REG_SLICE_MODE_RACH(0),
    .C_REG_SLICE_MODE_RDCH(0),
    .C_REG_SLICE_MODE_WACH(0),
    .C_REG_SLICE_MODE_WDCH(0),
    .C_REG_SLICE_MODE_WRCH(0),
    .C_SYNCHRONIZER_STAGE(2),
    .C_UNDERFLOW_LOW(0),
    .C_USE_COMMON_OVERFLOW(0),
    .C_USE_COMMON_UNDERFLOW(0),
    .C_USE_DEFAULT_SETTINGS(0),
    .C_USE_DOUT_RST(1),
    .C_USE_ECC(0),
    .C_USE_ECC_AXIS(0),
    .C_USE_ECC_RACH(0),
    .C_USE_ECC_RDCH(0),
    .C_USE_ECC_WACH(0),
    .C_USE_ECC_WDCH(0),
    .C_USE_ECC_WRCH(0),
    .C_USE_EMBEDDED_REG(0),
    .C_USE_FIFO16_FLAGS(0),
    .C_USE_FWFT_DATA_COUNT(0),
    .C_VALID_LOW(0),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(0),
    .C_WR_ACK_LOW(0),
    .C_WR_DATA_COUNT_WIDTH(10),
    .C_WR_DEPTH(1024),
    .C_WR_DEPTH_AXIS(16),
    .C_WR_DEPTH_RACH(16),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_WACH(16),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_FREQ(1),
    .C_WR_PNTR_WIDTH(10),
    .C_WR_PNTR_WIDTH_AXIS(4),
    .C_WR_PNTR_WIDTH_RACH(4),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_WACH(4),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_RESPONSE_LATENCY(1),
    .C_WRCH_TYPE(0)
  )
  inst (
    .M_ACLK(m_aclk),
    .S_ACLK(s_aclk),
    .S_ARESETN(s_aresetn),
    .S_AXIS_TVALID(s_axis_tvalid),
    .S_AXIS_TREADY(s_axis_tready),
    .S_AXIS_TDATA(s_axis_tdata),
    .S_AXIS_TUSER(s_axis_tuser),
    .M_AXIS_TVALID(m_axis_tvalid),
    .M_AXIS_TREADY(m_axis_tready),
    .M_AXIS_TDATA(m_axis_tdata),
    .M_AXIS_TUSER(m_axis_tuser),
    .BACKUP(),
    .BACKUP_MARKER(),
    .CLK(),
    .RST(),
    .SRST(),
    .WR_CLK(),
    .WR_RST(),
    .RD_CLK(),
    .RD_RST(),
    .DIN(),
    .WR_EN(),
    .RD_EN(),
    .PROG_EMPTY_THRESH(),
    .PROG_EMPTY_THRESH_ASSERT(),
    .PROG_EMPTY_THRESH_NEGATE(),
    .PROG_FULL_THRESH(),
    .PROG_FULL_THRESH_ASSERT(),
    .PROG_FULL_THRESH_NEGATE(),
    .INT_CLK(),
    .INJECTDBITERR(),
    .INJECTSBITERR(),
    .DOUT(),
    .FULL(),
    .ALMOST_FULL(),
    .WR_ACK(),
    .OVERFLOW(),
    .EMPTY(),
    .ALMOST_EMPTY(),
    .VALID(),
    .UNDERFLOW(),
    .DATA_COUNT(),
    .RD_DATA_COUNT(),
    .WR_DATA_COUNT(),
    .PROG_FULL(),
    .PROG_EMPTY(),
    .SBITERR(),
    .DBITERR(),
    .M_ACLK_EN(),
    .S_ACLK_EN(),
    .S_AXI_AWID(),
    .S_AXI_AWADDR(),
    .S_AXI_AWLEN(),
    .S_AXI_AWSIZE(),
    .S_AXI_AWBURST(),
    .S_AXI_AWLOCK(),
    .S_AXI_AWCACHE(),
    .S_AXI_AWPROT(),
    .S_AXI_AWQOS(),
    .S_AXI_AWREGION(),
    .S_AXI_AWUSER(),
    .S_AXI_AWVALID(),
    .S_AXI_AWREADY(),
    .S_AXI_WID(),
    .S_AXI_WDATA(),
    .S_AXI_WSTRB(),
    .S_AXI_WLAST(),
    .S_AXI_WUSER(),
    .S_AXI_WVALID(),
    .S_AXI_WREADY(),
    .S_AXI_BID(),
    .S_AXI_BRESP(),
    .S_AXI_BUSER(),
    .S_AXI_BVALID(),
    .S_AXI_BREADY(),
    .M_AXI_AWID(),
    .M_AXI_AWADDR(),
    .M_AXI_AWLEN(),
    .M_AXI_AWSIZE(),
    .M_AXI_AWBURST(),
    .M_AXI_AWLOCK(),
    .M_AXI_AWCACHE(),
    .M_AXI_AWPROT(),
    .M_AXI_AWQOS(),
    .M_AXI_AWREGION(),
    .M_AXI_AWUSER(),
    .M_AXI_AWVALID(),
    .M_AXI_AWREADY(),
    .M_AXI_WID(),
    .M_AXI_WDATA(),
    .M_AXI_WSTRB(),
    .M_AXI_WLAST(),
    .M_AXI_WUSER(),
    .M_AXI_WVALID(),
    .M_AXI_WREADY(),
    .M_AXI_BID(),
    .M_AXI_BRESP(),
    .M_AXI_BUSER(),
    .M_AXI_BVALID(),
    .M_AXI_BREADY(),
    .S_AXI_ARID(),
    .S_AXI_ARADDR(),
    .S_AXI_ARLEN(),
    .S_AXI_ARSIZE(),
    .S_AXI_ARBURST(),
    .S_AXI_ARLOCK(),
    .S_AXI_ARCACHE(),
    .S_AXI_ARPROT(),
    .S_AXI_ARQOS(),
    .S_AXI_ARREGION(),
    .S_AXI_ARUSER(),
    .S_AXI_ARVALID(),
    .S_AXI_ARREADY(),
    .S_AXI_RID(),
    .S_AXI_RDATA(),
    .S_AXI_RRESP(),
    .S_AXI_RLAST(),
    .S_AXI_RUSER(),
    .S_AXI_RVALID(),
    .S_AXI_RREADY(),
    .M_AXI_ARID(),
    .M_AXI_ARADDR(),
    .M_AXI_ARLEN(),
    .M_AXI_ARSIZE(),
    .M_AXI_ARBURST(),
    .M_AXI_ARLOCK(),
    .M_AXI_ARCACHE(),
    .M_AXI_ARPROT(),
    .M_AXI_ARQOS(),
    .M_AXI_ARREGION(),
    .M_AXI_ARUSER(),
    .M_AXI_ARVALID(),
    .M_AXI_ARREADY(),
    .M_AXI_RID(),
    .M_AXI_RDATA(),
    .M_AXI_RRESP(),
    .M_AXI_RLAST(),
    .M_AXI_RUSER(),
    .M_AXI_RVALID(),
    .M_AXI_RREADY(),
    .S_AXIS_TSTRB(),
    .S_AXIS_TKEEP(),
    .S_AXIS_TLAST(),
    .S_AXIS_TID(),
    .S_AXIS_TDEST(),
    .M_AXIS_TSTRB(),
    .M_AXIS_TKEEP(),
    .M_AXIS_TLAST(),
    .M_AXIS_TID(),
    .M_AXIS_TDEST(),
    .AXI_AW_INJECTSBITERR(),
    .AXI_AW_INJECTDBITERR(),
    .AXI_AW_PROG_FULL_THRESH(),
    .AXI_AW_PROG_EMPTY_THRESH(),
    .AXI_AW_DATA_COUNT(),
    .AXI_AW_WR_DATA_COUNT(),
    .AXI_AW_RD_DATA_COUNT(),
    .AXI_AW_SBITERR(),
    .AXI_AW_DBITERR(),
    .AXI_AW_OVERFLOW(),
    .AXI_AW_UNDERFLOW(),
    .AXI_W_INJECTSBITERR(),
    .AXI_W_INJECTDBITERR(),
    .AXI_W_PROG_FULL_THRESH(),
    .AXI_W_PROG_EMPTY_THRESH(),
    .AXI_W_DATA_COUNT(),
    .AXI_W_WR_DATA_COUNT(),
    .AXI_W_RD_DATA_COUNT(),
    .AXI_W_SBITERR(),
    .AXI_W_DBITERR(),
    .AXI_W_OVERFLOW(),
    .AXI_W_UNDERFLOW(),
    .AXI_B_INJECTSBITERR(),
    .AXI_B_INJECTDBITERR(),
    .AXI_B_PROG_FULL_THRESH(),
    .AXI_B_PROG_EMPTY_THRESH(),
    .AXI_B_DATA_COUNT(),
    .AXI_B_WR_DATA_COUNT(),
    .AXI_B_RD_DATA_COUNT(),
    .AXI_B_SBITERR(),
    .AXI_B_DBITERR(),
    .AXI_B_OVERFLOW(),
    .AXI_B_UNDERFLOW(),
    .AXI_AR_INJECTSBITERR(),
    .AXI_AR_INJECTDBITERR(),
    .AXI_AR_PROG_FULL_THRESH(),
    .AXI_AR_PROG_EMPTY_THRESH(),
    .AXI_AR_DATA_COUNT(),
    .AXI_AR_WR_DATA_COUNT(),
    .AXI_AR_RD_DATA_COUNT(),
    .AXI_AR_SBITERR(),
    .AXI_AR_DBITERR(),
    .AXI_AR_OVERFLOW(),
    .AXI_AR_UNDERFLOW(),
    .AXI_R_INJECTSBITERR(),
    .AXI_R_INJECTDBITERR(),
    .AXI_R_PROG_FULL_THRESH(),
    .AXI_R_PROG_EMPTY_THRESH(),
    .AXI_R_DATA_COUNT(),
    .AXI_R_WR_DATA_COUNT(),
    .AXI_R_RD_DATA_COUNT(),
    .AXI_R_SBITERR(),
    .AXI_R_DBITERR(),
    .AXI_R_OVERFLOW(),
    .AXI_R_UNDERFLOW(),
    .AXIS_INJECTSBITERR(),
    .AXIS_INJECTDBITERR(),
    .AXIS_PROG_FULL_THRESH(),
    .AXIS_PROG_EMPTY_THRESH(),
    .AXIS_DATA_COUNT(),
    .AXIS_WR_DATA_COUNT(),
    .AXIS_RD_DATA_COUNT(),
    .AXIS_SBITERR(),
    .AXIS_DBITERR(),
    .AXIS_OVERFLOW(),
    .AXIS_UNDERFLOW()
  );

// synthesis translate_on

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/axis_fifo_40W_16D.v
// -----------------------------------------------------------------------------
/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used solely      *
*     for design, simulation, implementation and creation of design files      *
*     limited to Xilinx devices or technologies. Use with non-Xilinx           *
*     devices or technologies is expressly prohibited and immediately          *
*     terminates your license.                                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY     *
*     FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY     *
*     PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE              *
*     IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS       *
*     MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY       *
*     CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY        *
*     RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY        *
*     DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE    *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A    *
*     PARTICULAR PURPOSE.                                                      *
*                                                                              *
*     Xilinx products are not intended for use in life support appliances,     *
*     devices, or systems.  Use in such applications are expressly             *
*     prohibited.                                                              *
*                                                                              *
*     (c) Copyright 1995-2012 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// You must compile the wrapper file axis_fifo_40W_16D.v when simulating
// the core, axis_fifo_40W_16D. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

// The synthesis directives "translate_off/translate_on" specified below are
// supported by Xilinx, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

`timescale 1ns/1ps

module axis_fifo_40W_16D(
  m_aclk,
  s_aclk,
  s_aresetn,
  s_axis_tvalid,
  s_axis_tready,
  s_axis_tdata,
  s_axis_tuser,
  m_axis_tvalid,
  m_axis_tready,
  m_axis_tdata,
  m_axis_tuser
);

input m_aclk;
input s_aclk;
input s_aresetn;
input s_axis_tvalid;
output s_axis_tready;
input [31 : 0] s_axis_tdata;
input [7 : 0] s_axis_tuser;
output m_axis_tvalid;
input m_axis_tready;
output [31 : 0] m_axis_tdata;
output [7 : 0] m_axis_tuser;

// synthesis translate_off

  FIFO_GENERATOR_V8_4 #(
    .C_ADD_NGC_CONSTRAINT(0),
    .C_APPLICATION_TYPE_AXIS(0),
    .C_APPLICATION_TYPE_RACH(0),
    .C_APPLICATION_TYPE_RDCH(0),
    .C_APPLICATION_TYPE_WACH(0),
    .C_APPLICATION_TYPE_WDCH(0),
    .C_APPLICATION_TYPE_WRCH(0),
    .C_AXI_ADDR_WIDTH(32),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_DATA_WIDTH(64),
    .C_AXI_ID_WIDTH(4),
    .C_AXI_RUSER_WIDTH(1),
    .C_AXI_TYPE(0),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXIS_TDATA_WIDTH(32),
    .C_AXIS_TDEST_WIDTH(4),
    .C_AXIS_TID_WIDTH(8),
    .C_AXIS_TKEEP_WIDTH(4),
    .C_AXIS_TSTRB_WIDTH(4),
    .C_AXIS_TUSER_WIDTH(8),
    .C_AXIS_TYPE(0),
    .C_COMMON_CLOCK(0),
    .C_COUNT_TYPE(0),
    .C_DATA_COUNT_WIDTH(10),
    .C_DEFAULT_VALUE("BlankString"),
    .C_DIN_WIDTH(18),
    .C_DIN_WIDTH_AXIS(40),
    .C_DIN_WIDTH_RACH(32),
    .C_DIN_WIDTH_RDCH(64),
    .C_DIN_WIDTH_WACH(32),
    .C_DIN_WIDTH_WDCH(64),
    .C_DIN_WIDTH_WRCH(2),
    .C_DOUT_RST_VAL("0"),
    .C_DOUT_WIDTH(18),
    .C_ENABLE_RLOCS(0),
    .C_ENABLE_RST_SYNC(1),
    .C_ERROR_INJECTION_TYPE(0),
    .C_ERROR_INJECTION_TYPE_AXIS(0),
    .C_ERROR_INJECTION_TYPE_RACH(0),
    .C_ERROR_INJECTION_TYPE_RDCH(0),
    .C_ERROR_INJECTION_TYPE_WACH(0),
    .C_ERROR_INJECTION_TYPE_WDCH(0),
    .C_ERROR_INJECTION_TYPE_WRCH(0),
    .C_FAMILY("spartan6"),
    .C_FULL_FLAGS_RST_VAL(1),
    .C_HAS_ALMOST_EMPTY(0),
    .C_HAS_ALMOST_FULL(0),
    .C_HAS_AXI_ARUSER(0),
    .C_HAS_AXI_AWUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_RD_CHANNEL(0),
    .C_HAS_AXI_RUSER(0),
    .C_HAS_AXI_WR_CHANNEL(0),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXIS_TDATA(1),
    .C_HAS_AXIS_TDEST(0),
    .C_HAS_AXIS_TID(0),
    .C_HAS_AXIS_TKEEP(0),
    .C_HAS_AXIS_TLAST(0),
    .C_HAS_AXIS_TREADY(1),
    .C_HAS_AXIS_TSTRB(0),
    .C_HAS_AXIS_TUSER(1),
    .C_HAS_BACKUP(0),
    .C_HAS_DATA_COUNT(0),
    .C_HAS_DATA_COUNTS_AXIS(0),
    .C_HAS_DATA_COUNTS_RACH(0),
    .C_HAS_DATA_COUNTS_RDCH(0),
    .C_HAS_DATA_COUNTS_WACH(0),
    .C_HAS_DATA_COUNTS_WDCH(0),
    .C_HAS_DATA_COUNTS_WRCH(0),
    .C_HAS_INT_CLK(0),
    .C_HAS_MASTER_CE(0),
    .C_HAS_MEMINIT_FILE(0),
    .C_HAS_OVERFLOW(0),
    .C_HAS_PROG_FLAGS_AXIS(0),
    .C_HAS_PROG_FLAGS_RACH(0),
    .C_HAS_PROG_FLAGS_RDCH(0),
    .C_HAS_PROG_FLAGS_WACH(0),
    .C_HAS_PROG_FLAGS_WDCH(0),
    .C_HAS_PROG_FLAGS_WRCH(0),
    .C_HAS_RD_DATA_COUNT(0),
    .C_HAS_RD_RST(0),
    .C_HAS_RST(1),
    .C_HAS_SLAVE_CE(0),
    .C_HAS_SRST(0),
    .C_HAS_UNDERFLOW(0),
    .C_HAS_VALID(0),
    .C_HAS_WR_ACK(0),
    .C_HAS_WR_DATA_COUNT(0),
    .C_HAS_WR_RST(0),
    .C_IMPLEMENTATION_TYPE(0),
    .C_IMPLEMENTATION_TYPE_AXIS(12),
    .C_IMPLEMENTATION_TYPE_RACH(12),
    .C_IMPLEMENTATION_TYPE_RDCH(11),
    .C_IMPLEMENTATION_TYPE_WACH(12),
    .C_IMPLEMENTATION_TYPE_WDCH(11),
    .C_IMPLEMENTATION_TYPE_WRCH(12),
    .C_INIT_WR_PNTR_VAL(0),
    .C_INTERFACE_TYPE(1),
    .C_MEMORY_TYPE(1),
    .C_MIF_FILE_NAME("BlankString"),
    .C_MSGON_VAL(1),
    .C_OPTIMIZATION_MODE(0),
    .C_OVERFLOW_LOW(0),
    .C_PRELOAD_LATENCY(1),
    .C_PRELOAD_REGS(0),
    .C_PRIM_FIFO_TYPE("4kx4"),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL(2),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(13),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(13),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1021),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(13),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1021),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(13),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL(3),
    .C_PROG_EMPTY_TYPE(0),
    .C_PROG_EMPTY_TYPE_AXIS(5),
    .C_PROG_EMPTY_TYPE_RACH(5),
    .C_PROG_EMPTY_TYPE_RDCH(5),
    .C_PROG_EMPTY_TYPE_WACH(5),
    .C_PROG_EMPTY_TYPE_WDCH(5),
    .C_PROG_EMPTY_TYPE_WRCH(5),
    .C_PROG_FULL_THRESH_ASSERT_VAL(1022),
    .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(15),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(15),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(15),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(15),
    .C_PROG_FULL_THRESH_NEGATE_VAL(1021),
    .C_PROG_FULL_TYPE(0),
    .C_PROG_FULL_TYPE_AXIS(5),
    .C_PROG_FULL_TYPE_RACH(5),
    .C_PROG_FULL_TYPE_RDCH(5),
    .C_PROG_FULL_TYPE_WACH(5),
    .C_PROG_FULL_TYPE_WDCH(5),
    .C_PROG_FULL_TYPE_WRCH(5),
    .C_RACH_TYPE(0),
    .C_RD_DATA_COUNT_WIDTH(10),
    .C_RD_DEPTH(1024),
    .C_RD_FREQ(1),
    .C_RD_PNTR_WIDTH(10),
    .C_RDCH_TYPE(0),
    .C_REG_SLICE_MODE_AXIS(0),
    .C_REG_SLICE_MODE_RACH(0),
    .C_REG_SLICE_MODE_RDCH(0),
    .C_REG_SLICE_MODE_WACH(0),
    .C_REG_SLICE_MODE_WDCH(0),
    .C_REG_SLICE_MODE_WRCH(0),
    .C_SYNCHRONIZER_STAGE(2),
    .C_UNDERFLOW_LOW(0),
    .C_USE_COMMON_OVERFLOW(0),
    .C_USE_COMMON_UNDERFLOW(0),
    .C_USE_DEFAULT_SETTINGS(0),
    .C_USE_DOUT_RST(1),
    .C_USE_ECC(0),
    .C_USE_ECC_AXIS(0),
    .C_USE_ECC_RACH(0),
    .C_USE_ECC_RDCH(0),
    .C_USE_ECC_WACH(0),
    .C_USE_ECC_WDCH(0),
    .C_USE_ECC_WRCH(0),
    .C_USE_EMBEDDED_REG(0),
    .C_USE_FIFO16_FLAGS(0),
    .C_USE_FWFT_DATA_COUNT(0),
    .C_VALID_LOW(0),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(0),
    .C_WR_ACK_LOW(0),
    .C_WR_DATA_COUNT_WIDTH(10),
    .C_WR_DEPTH(1024),
    .C_WR_DEPTH_AXIS(16),
    .C_WR_DEPTH_RACH(16),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_WACH(16),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_FREQ(1),
    .C_WR_PNTR_WIDTH(10),
    .C_WR_PNTR_WIDTH_AXIS(4),
    .C_WR_PNTR_WIDTH_RACH(4),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_WACH(4),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_RESPONSE_LATENCY(1),
    .C_WRCH_TYPE(0)
  )
  inst (
    .M_ACLK(m_aclk),
    .S_ACLK(s_aclk),
    .S_ARESETN(s_aresetn),
    .S_AXIS_TVALID(s_axis_tvalid),
    .S_AXIS_TREADY(s_axis_tready),
    .S_AXIS_TDATA(s_axis_tdata),
    .S_AXIS_TUSER(s_axis_tuser),
    .M_AXIS_TVALID(m_axis_tvalid),
    .M_AXIS_TREADY(m_axis_tready),
    .M_AXIS_TDATA(m_axis_tdata),
    .M_AXIS_TUSER(m_axis_tuser),
    .BACKUP(),
    .BACKUP_MARKER(),
    .CLK(),
    .RST(),
    .SRST(),
    .WR_CLK(),
    .WR_RST(),
    .RD_CLK(),
    .RD_RST(),
    .DIN(),
    .WR_EN(),
    .RD_EN(),
    .PROG_EMPTY_THRESH(),
    .PROG_EMPTY_THRESH_ASSERT(),
    .PROG_EMPTY_THRESH_NEGATE(),
    .PROG_FULL_THRESH(),
    .PROG_FULL_THRESH_ASSERT(),
    .PROG_FULL_THRESH_NEGATE(),
    .INT_CLK(),
    .INJECTDBITERR(),
    .INJECTSBITERR(),
    .DOUT(),
    .FULL(),
    .ALMOST_FULL(),
    .WR_ACK(),
    .OVERFLOW(),
    .EMPTY(),
    .ALMOST_EMPTY(),
    .VALID(),
    .UNDERFLOW(),
    .DATA_COUNT(),
    .RD_DATA_COUNT(),
    .WR_DATA_COUNT(),
    .PROG_FULL(),
    .PROG_EMPTY(),
    .SBITERR(),
    .DBITERR(),
    .M_ACLK_EN(),
    .S_ACLK_EN(),
    .S_AXI_AWID(),
    .S_AXI_AWADDR(),
    .S_AXI_AWLEN(),
    .S_AXI_AWSIZE(),
    .S_AXI_AWBURST(),
    .S_AXI_AWLOCK(),
    .S_AXI_AWCACHE(),
    .S_AXI_AWPROT(),
    .S_AXI_AWQOS(),
    .S_AXI_AWREGION(),
    .S_AXI_AWUSER(),
    .S_AXI_AWVALID(),
    .S_AXI_AWREADY(),
    .S_AXI_WID(),
    .S_AXI_WDATA(),
    .S_AXI_WSTRB(),
    .S_AXI_WLAST(),
    .S_AXI_WUSER(),
    .S_AXI_WVALID(),
    .S_AXI_WREADY(),
    .S_AXI_BID(),
    .S_AXI_BRESP(),
    .S_AXI_BUSER(),
    .S_AXI_BVALID(),
    .S_AXI_BREADY(),
    .M_AXI_AWID(),
    .M_AXI_AWADDR(),
    .M_AXI_AWLEN(),
    .M_AXI_AWSIZE(),
    .M_AXI_AWBURST(),
    .M_AXI_AWLOCK(),
    .M_AXI_AWCACHE(),
    .M_AXI_AWPROT(),
    .M_AXI_AWQOS(),
    .M_AXI_AWREGION(),
    .M_AXI_AWUSER(),
    .M_AXI_AWVALID(),
    .M_AXI_AWREADY(),
    .M_AXI_WID(),
    .M_AXI_WDATA(),
    .M_AXI_WSTRB(),
    .M_AXI_WLAST(),
    .M_AXI_WUSER(),
    .M_AXI_WVALID(),
    .M_AXI_WREADY(),
    .M_AXI_BID(),
    .M_AXI_BRESP(),
    .M_AXI_BUSER(),
    .M_AXI_BVALID(),
    .M_AXI_BREADY(),
    .S_AXI_ARID(),
    .S_AXI_ARADDR(),
    .S_AXI_ARLEN(),
    .S_AXI_ARSIZE(),
    .S_AXI_ARBURST(),
    .S_AXI_ARLOCK(),
    .S_AXI_ARCACHE(),
    .S_AXI_ARPROT(),
    .S_AXI_ARQOS(),
    .S_AXI_ARREGION(),
    .S_AXI_ARUSER(),
    .S_AXI_ARVALID(),
    .S_AXI_ARREADY(),
    .S_AXI_RID(),
    .S_AXI_RDATA(),
    .S_AXI_RRESP(),
    .S_AXI_RLAST(),
    .S_AXI_RUSER(),
    .S_AXI_RVALID(),
    .S_AXI_RREADY(),
    .M_AXI_ARID(),
    .M_AXI_ARADDR(),
    .M_AXI_ARLEN(),
    .M_AXI_ARSIZE(),
    .M_AXI_ARBURST(),
    .M_AXI_ARLOCK(),
    .M_AXI_ARCACHE(),
    .M_AXI_ARPROT(),
    .M_AXI_ARQOS(),
    .M_AXI_ARREGION(),
    .M_AXI_ARUSER(),
    .M_AXI_ARVALID(),
    .M_AXI_ARREADY(),
    .M_AXI_RID(),
    .M_AXI_RDATA(),
    .M_AXI_RRESP(),
    .M_AXI_RLAST(),
    .M_AXI_RUSER(),
    .M_AXI_RVALID(),
    .M_AXI_RREADY(),
    .S_AXIS_TSTRB(),
    .S_AXIS_TKEEP(),
    .S_AXIS_TLAST(),
    .S_AXIS_TID(),
    .S_AXIS_TDEST(),
    .M_AXIS_TSTRB(),
    .M_AXIS_TKEEP(),
    .M_AXIS_TLAST(),
    .M_AXIS_TID(),
    .M_AXIS_TDEST(),
    .AXI_AW_INJECTSBITERR(),
    .AXI_AW_INJECTDBITERR(),
    .AXI_AW_PROG_FULL_THRESH(),
    .AXI_AW_PROG_EMPTY_THRESH(),
    .AXI_AW_DATA_COUNT(),
    .AXI_AW_WR_DATA_COUNT(),
    .AXI_AW_RD_DATA_COUNT(),
    .AXI_AW_SBITERR(),
    .AXI_AW_DBITERR(),
    .AXI_AW_OVERFLOW(),
    .AXI_AW_UNDERFLOW(),
    .AXI_W_INJECTSBITERR(),
    .AXI_W_INJECTDBITERR(),
    .AXI_W_PROG_FULL_THRESH(),
    .AXI_W_PROG_EMPTY_THRESH(),
    .AXI_W_DATA_COUNT(),
    .AXI_W_WR_DATA_COUNT(),
    .AXI_W_RD_DATA_COUNT(),
    .AXI_W_SBITERR(),
    .AXI_W_DBITERR(),
    .AXI_W_OVERFLOW(),
    .AXI_W_UNDERFLOW(),
    .AXI_B_INJECTSBITERR(),
    .AXI_B_INJECTDBITERR(),
    .AXI_B_PROG_FULL_THRESH(),
    .AXI_B_PROG_EMPTY_THRESH(),
    .AXI_B_DATA_COUNT(),
    .AXI_B_WR_DATA_COUNT(),
    .AXI_B_RD_DATA_COUNT(),
    .AXI_B_SBITERR(),
    .AXI_B_DBITERR(),
    .AXI_B_OVERFLOW(),
    .AXI_B_UNDERFLOW(),
    .AXI_AR_INJECTSBITERR(),
    .AXI_AR_INJECTDBITERR(),
    .AXI_AR_PROG_FULL_THRESH(),
    .AXI_AR_PROG_EMPTY_THRESH(),
    .AXI_AR_DATA_COUNT(),
    .AXI_AR_WR_DATA_COUNT(),
    .AXI_AR_RD_DATA_COUNT(),
    .AXI_AR_SBITERR(),
    .AXI_AR_DBITERR(),
    .AXI_AR_OVERFLOW(),
    .AXI_AR_UNDERFLOW(),
    .AXI_R_INJECTSBITERR(),
    .AXI_R_INJECTDBITERR(),
    .AXI_R_PROG_FULL_THRESH(),
    .AXI_R_PROG_EMPTY_THRESH(),
    .AXI_R_DATA_COUNT(),
    .AXI_R_WR_DATA_COUNT(),
    .AXI_R_RD_DATA_COUNT(),
    .AXI_R_SBITERR(),
    .AXI_R_DBITERR(),
    .AXI_R_OVERFLOW(),
    .AXI_R_UNDERFLOW(),
    .AXIS_INJECTSBITERR(),
    .AXIS_INJECTDBITERR(),
    .AXIS_PROG_FULL_THRESH(),
    .AXIS_PROG_EMPTY_THRESH(),
    .AXIS_DATA_COUNT(),
    .AXIS_WR_DATA_COUNT(),
    .AXIS_RD_DATA_COUNT(),
    .AXIS_SBITERR(),
    .AXIS_DBITERR(),
    .AXIS_OVERFLOW(),
    .AXIS_UNDERFLOW()
  );

// synthesis translate_on

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/det_pos_edge.v
// -----------------------------------------------------------------------------
////////////////////////////////////////////////////////////
//
// This confidential and proprietary software may be used
// only as authorized by a licensing agreement from
// Bean Digital Ltd
// In the event of publication, the following notice is
// applicable:
//
// (C)COPYRIGHT 2009 BEAN DIGITAL LTD.
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all
// authorized copies.
//
// File        : det_pos_edge.v
// Author      : J.Bean
// Date        : Nov 2009
// Description : Detect a positive edge.
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

module det_pos_edge(
  input  wire clk,
  input  wire rst_n,
  input  wire d,
  output wire q
);

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

reg d_p1;

////////////////////////////////////////////////////////////
// Comb Assign : Q
// Description : 
////////////////////////////////////////////////////////////

assign q = d & ~d_p1;

////////////////////////////////////////////////////////////
// Seq Block   : Data pipeline
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk)
begin
  if (rst_n == 0) begin
    d_p1 <= 0;
  end else begin
    d_p1 <= d;
  end
end 
            
endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/mux.v
// -----------------------------------------------------------------------------
////////////////////////////////////////////////////////////
//
// This confidential and proprietary software may be used
// only as authorized by a licensing agreement from
// Bean Digital Ltd
// In the event of publication, the following notice is
// applicable:
//
// (C)COPYRIGHT 2009 BEAN DIGITAL LTD.
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all
// authorized copies.
//
// File        : mux.v
// Author      : J.Bean
// Date        : Sep 2009
// Description : Multiplexer
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

module mux
  #(parameter DATA_BITS  = 16,                // Data bits
    parameter IP_NUM     = 4,                 // Number of inputs
    parameter USE_OP_REG = 0)(                // Enable Register on Output 
  input  wire                        clk,     // Clock
  input  wire [IP_NUM*DATA_BITS-1:0] data_i,  // Data Input
  input  wire [7:0]                  sel_i,   // Input Select
  output wire [DATA_BITS-1:0]        data_o   // Data Output
);

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

genvar i;
reg  [DATA_BITS-1:0] ip_array [0:IP_NUM-1];
wire [DATA_BITS-1:0] data_c;
reg  [DATA_BITS-1:0] data_r;

////////////////////////////////////////////////////////////
// Comb Assign : Data Output
// Description : 
////////////////////////////////////////////////////////////

assign data_o = (USE_OP_REG == 1) ? data_r : data_c;

////////////////////////////////////////////////////////////
// Comb Assign : Data Comb
// Description : Assign an input vector from the array.
////////////////////////////////////////////////////////////

assign data_c = ip_array[sel_i];

////////////////////////////////////////////////////////////
// Generate    : Input array
// Description : Create an array of input vectors.
////////////////////////////////////////////////////////////

generate
  for(i=0; i<IP_NUM; i=i+1) begin: mux_gen  
    always @(*)
    begin
      ip_array[i] = data_i[(i+1)*DATA_BITS-1:i*DATA_BITS];
    end
  end
endgenerate

////////////////////////////////////////////////////////////
// Seq Block   : Data Registered
// Description : 
// Assign an input vector from the array.
////////////////////////////////////////////////////////////

always @(posedge clk)
begin
  data_r <= ip_array[sel_i];
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/sata_phy_dev_ctrl_x6series.v
// -----------------------------------------------------------------------------
////////////////////////////////////////////////////////////
//
// This confidential and proprietary software may be used
// only as authorized by a licensing agreement from
// Bean Digital Ltd
// In the event of publication, the following notice is
// applicable:
//
// (C)COPYRIGHT 2012 BEAN DIGITAL LTD.
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all
// authorized copies.
//
// File        : sata_phy_dev_ctrl_x6series.v
// Author      : J.Bean
// Date        : Mar 2012
// Description : SATA PHY Layer Device Control Xilinx 6 Series
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

`include "sata_constants.v"

module sata_phy_dev_ctrl_x6series
  #(parameter SATA_REV = 1)(              // SATA Revision (1, 2, 3)
  input  wire         clk_phy,	           // Clock PHY
  input  wire         rst_n,	             // Reset
  output reg          link_up_o,          // Link Up     
  // Transceiver  
  input  wire         gt_rst_done_i,      // GT Reset Done
  output reg  [31:0]  gt_tx_data_o,	      // GT Transmit Data
  output reg  [3:0]   gt_tx_charisk_o,	   // GT Transmit K/D
  output reg          gt_tx_com_strt_o,	  // GT Transmit	COM Start
  output reg          gt_tx_com_type_o,	  // GT Transmit COM Type
  output reg          gt_tx_elec_idle_o,  // GT Transmit Electrical Idle	                   
  input  wire [31:0]  gt_rx_data_i,       // GT Receive Data                
  input  wire [2:0]   gt_rx_status_i      // GT Receive Status
);

////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////// 

// Time delays
parameter SATA1_10MS            = 750000;   // 75MHz * 750000
parameter SATA2_10MS            = 1500000;  // 150MHz * 1500000
parameter SATA3_10MS            = 3000000;  // 300MHz * 3000000
parameter SATA1_55US            = 4095;     // 75MHz * 4095
parameter SATA2_55US            = 8190;     // 150MHz * 8190
parameter SATA3_55US            = 16380;    // 300MHz * 16380

// State machine states
parameter DP1_RESET             = 0;
parameter DP2_COMINIT           = 1;
parameter DP3_AWAIT_COMWAKE     = 2;
parameter DP3B_AWAIT_NO_COMWAKE = 3;
parameter DP4_CALIBRATE         = 4;
parameter DP5_COMWAKE           = 5;
parameter DP6_SEND_ALIGN        = 6;
parameter DP7_READY             = 7;
parameter DP11_ERROR            = 8;

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

reg  [3:0]   state_cs;          // Current state
reg  [3:0]   state_ns;          // Next state  
reg  [199:0] state_ascii;       // ASCII state
reg	 [31:0]	 align_timeout_cnt; // ALIGN Timeout Count
reg  [31:0]  retry_cnt;         // Retry Count 
wire         comreset_detect;   // COMRESET Detect
wire         comwake_detect;    // COMWAKE Detect
wire         align_detect;      // ALIGN Detected
reg          tx_com_strt;       // Transmit COM Start
wire         tx_com_strt_pedge; // Transmit COM Start Positive Edge
reg          tx_com_done;       // Transmit COM Done

////////////////////////////////////////////////////////////
// Instance    : Transmit Com Start Pos Edge
// Description : Detect positive edge on COM start signal.
////////////////////////////////////////////////////////////
  
det_pos_edge U_tx_com_strt_pedge(
  .clk   (clk_phy),
  .rst_n (rst_n),
  .d     (tx_com_strt),
  .q     (tx_com_strt_pedge));
  
////////////////////////////////////////////////////////////
// Comb Assign : ALIGN primitive detect
// Description : 
////////////////////////////////////////////////////////////

assign align_detect = (gt_rx_data_i == 32'h7B4A4ABC); 

////////////////////////////////////////////////////////////
// Comb Assign : COMWAKE Detect
// Description : 
////////////////////////////////////////////////////////////

assign comwake_detect = gt_rx_status_i[1];

////////////////////////////////////////////////////////////
// Comb Assign : COMRESET Detect
// Description : 
////////////////////////////////////////////////////////////

assign comreset_detect = gt_rx_status_i[2];
 
////////////////////////////////////////////////////////////
// Seq Block   : State machine seq logic
// Description : Sets the current state to the next state.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin
  if (rst_n == 0) begin
    state_cs <= DP1_RESET;   
  end else begin
    if (comreset_detect == 1) begin
      state_cs <= DP1_RESET;   
    end else begin
      state_cs <= state_ns;
    end
  end
end  

////////////////////////////////////////////////////////////
// Comb Block  : State machine ascii 
// Description : Converts the state to ascii for debug.
////////////////////////////////////////////////////////////

always @(*)
begin
  case (state_cs)
    DP1_RESET:             state_ascii = "DP1_RESET";
    DP2_COMINIT:           state_ascii = "DP2_COMINIT";
    DP3_AWAIT_COMWAKE:     state_ascii = "DP3_AWAIT_COMWAKE";
    DP3B_AWAIT_NO_COMWAKE: state_ascii = "DP3B_AWAIT_NO_COMWAKE";
    DP4_CALIBRATE:         state_ascii = "DP4_CALIBRATE";
    DP5_COMWAKE:           state_ascii = "DP5_COMWAKE";
    DP6_SEND_ALIGN:        state_ascii = "DP6_SEND_ALIGN";
    DP7_READY:             state_ascii = "DP7_READY";
    DP11_ERROR:            state_ascii = "DP11_ERROR"; 
  endcase
end

////////////////////////////////////////////////////////////
// Comb Block  : State machine comb logic
// Description : Assigns the next state.
////////////////////////////////////////////////////////////

always @(*)
begin
  state_ns = state_cs;

  case (state_cs)
    // DP1_RESET - Interface quiescent
    DP1_RESET: begin
      if ((gt_rst_done_i == 1) && (comreset_detect == 0)) begin
        state_ns = DP2_COMINIT; 
      end  
    end
    
    // DP2_COMINIT - Send COMINIT
    DP2_COMINIT: begin
      if (tx_com_done == 1) begin
        state_ns = DP3_AWAIT_COMWAKE;
      end  
    end    
    
    // DP3_AWAIT_COMWAKE - Wait for COMWAKE to be detected
    DP3_AWAIT_COMWAKE: begin
      if (comwake_detect == 1) begin
        state_ns = DP3B_AWAIT_NO_COMWAKE; 
      end else begin
        if (retry_cnt == 0) begin
          state_ns = DP1_RESET;
        end
      end    
    end        
    
    // DP3B_AWAIT_NO_COMWAKE - Wait for COMWAKE to finish
    DP3B_AWAIT_NO_COMWAKE: begin
      if (comwake_detect == 0) begin
        state_ns = DP4_CALIBRATE; 
      end          
    end        
    
    // DP4_CALIBRATE 
    DP4_CALIBRATE: begin
      state_ns = DP5_COMWAKE;
    end   

    // DP5_COMWAKE - Send COMWAKE
    DP5_COMWAKE: begin
      if (tx_com_done == 1) begin
        state_ns = DP6_SEND_ALIGN;
      end      
    end     
    
    // DP6_SEND_ALIGN - Send ALIGN
    DP6_SEND_ALIGN: begin
      if (align_detect == 1) begin
        state_ns = DP7_READY; 
      end else begin
        if (align_timeout_cnt == 0) begin
          state_ns = DP11_ERROR;
        end      
      end     
    end   
    
    // DP7_READY - Link ready
    DP7_READY: begin
      state_ns = DP7_READY;    
    end   
    
    // DP11_ERROR
    DP11_ERROR: begin
      state_ns = DP1_RESET; 
    end
    
    default: begin
      state_ns = 'bx;
    end    
  endcase
end

////////////////////////////////////////////////////////////
// Seq Block   : Link Up
// Description : Set when communication has been established
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    link_up_o <= 0;
  end	else begin
    case (state_cs)
      // DP7_READY - Link ready
      DP7_READY: begin
        link_up_o <= 1;
      end 
      
      default: begin
        link_up_o <= 0;
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit COM Start
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_com_strt_o <= 0;
  end	else begin
    gt_tx_com_strt_o <= tx_com_strt_pedge;
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Transmit COM Type
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_com_type_o <= 0;
  end	else begin
    case (state_cs)
      // DP2_COMINIT - Send COMINIT
      DP2_COMINIT: begin
        gt_tx_com_type_o <= 0;	      
      end          
  
      // DP5_COMWAKE - Send COMWAKE
      DP5_COMWAKE: begin
        gt_tx_com_type_o <= 1;	  
      end  
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit Electrical Idle
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_elec_idle_o <= 0;
  end	else begin
    case (state_cs) 
      // DP5_COMWAKE - Send COMWAKE
      DP5_COMWAKE: begin
        if (tx_com_done == 1) begin
          gt_tx_elec_idle_o <= 0;	
        end         
      end     
    
      // DP6_SEND_ALIGN - Send ALIGN
      DP6_SEND_ALIGN: begin
        gt_tx_elec_idle_o <= 0;	    
      end 
      
      // DP7_READY - Link ready
      DP7_READY: begin
        gt_tx_elec_idle_o <= 0;	    
      end  

      default: begin
        gt_tx_elec_idle_o <= 1;
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit Data
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_data_o <= 0;
  end	else begin
    case (state_cs)  
      // DP6_SEND_ALIGN - Send ALIGN
      DP6_SEND_ALIGN: begin
        gt_tx_data_o <= `ALIGN_VAL; // ALIGN;        
      end 
      
      // DP7_READY - Link ready
      DP7_READY: begin
        gt_tx_data_o <= `SYNC_VAL;  // SYNC;     
      end  
      
      default: begin
        gt_tx_data_o <= 0;      
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit K/D
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_charisk_o <= 0;
  end	else begin
    case (state_cs)  
      // DP6_SEND_ALIGN - Send ALIGN
      DP6_SEND_ALIGN: begin
        gt_tx_charisk_o <= 4'b0001; // ALIGN;        
      end 
      
      // DP7_READY - Link ready
      DP7_READY: begin
        gt_tx_charisk_o <= 4'b0001; // SYNC;     
      end  
      
      default: begin
        gt_tx_charisk_o <= 0;      
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Transmit COM Start
// Description : Starts transmission of a COM sequence.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    tx_com_strt <= 0;
  end	else begin
    case (state_cs)
      // DP2_COMINIT - Send COMINIT
      DP2_COMINIT: begin
        tx_com_strt <= 1;		     
      end          

      // DP5_COMWAKE - Send COMWAKE
      DP5_COMWAKE: begin
        tx_com_strt <= 1;		         
      end  
      
      default: begin
        tx_com_strt <= 0;   
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Transmit COM Done
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    tx_com_done <= 0;
  end	else begin
    case (state_cs)   
      // DP1_RESET - Interface quiescent
      DP1_RESET: begin
        tx_com_done <= 0;
      end
      
      // DP2_COMINIT - Send COMINIT
      DP2_COMINIT: begin
        if (gt_rx_status_i[0] == 1) begin
          tx_com_done <= 1;
        end     
      end    
    
      // DP5_COMWAKE - Send COMWAKE
      DP5_COMWAKE: begin
        if (gt_rx_status_i[0] == 1) begin
          tx_com_done <= 1;
        end   
      end  
      
      default: begin
        tx_com_done <= 0;
      end
    endcase     
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : ALIGN Timeout Count
// Description : Error if ALIGN not detected within 54.6us.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		align_timeout_cnt <= 0;
	end	else begin
    case (state_cs)     
      // DP1_RESET - Interface quiescent
      DP1_RESET: begin
        case (SATA_REV)
          1:       align_timeout_cnt <= SATA1_55US;
          2:       align_timeout_cnt <= SATA2_55US;
          3:       align_timeout_cnt <= SATA3_55US;    
          default: align_timeout_cnt <= SATA1_55US;    
        endcase   
      end  
      
      // DP6_SEND_ALIGN - Send ALIGN
      DP6_SEND_ALIGN: begin
        align_timeout_cnt <= align_timeout_cnt - 1;
      end        
	  endcase
	end
end

////////////////////////////////////////////////////////////
// Seq Block   : Retry Count
// Description : Used to for async signal recovery (10 ms)
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		retry_cnt <= 0;
	end	else begin
	  case (state_cs)  
      // DP1_RESET - Interface quiescent
      DP1_RESET: begin
        case (SATA_REV)
          1:       retry_cnt <= SATA1_10MS;
          2:       retry_cnt <= SATA2_10MS;
          3:       retry_cnt <= SATA3_10MS;    
          default: retry_cnt <= SATA1_10MS;    
        endcase	       
      end
      
      // DP3_AWAIT_COMWAKE - Wait for COMWAKE to be detected
      DP3_AWAIT_COMWAKE: begin
        retry_cnt <= retry_cnt - 1;
      end  
    endcase	  
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/sata_phy_host_ctrl_x6series.v
// -----------------------------------------------------------------------------
////////////////////////////////////////////////////////////
//
// This confidential and proprietary software may be used
// only as authorized by a licensing agreement from
// Bean Digital Ltd
// In the event of publication, the following notice is
// applicable:
//
// (C)COPYRIGHT 2012 BEAN DIGITAL LTD.
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all
// authorized copies.
//
// File        : sata_phy_host_ctrl_x6series.v
// Author      : J.Bean
// Date        : Mar 2012
// Description : SATA PHY Layer Host Control Xilinx 6 Series
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

`include "sata_constants.v"

module sata_phy_host_ctrl_x6series
  #(parameter SATA_REV = 1)(              // SATA Revision (1, 2, 3)
  input  wire          clk_phy,           // Clock PHY
  input  wire          rst_n,	            // Reset
  output reg           link_up_o,         // Link Up
  // Transceiver
  input  wire          gt_rst_done_i,     // GT Reset Done
  output reg  [31:0]   gt_tx_data_o,	     // GT Transmit Data
  output reg  [3:0]    gt_tx_charisk_o,	  // GT Transmit K/D
  output reg           gt_tx_com_strt_o,  // GT Transmit	COM Start
  output reg           gt_tx_com_type_o,	 // GT Transmit COM Type
  output reg           gt_tx_elec_idle_o, // GT Transmit Electrical Idle
  input  wire [31:0]   gt_rx_data_i,      // GT Receive Data   
  input  wire [2:0]    gt_rx_status_i,	   // GT Receive Status
  input  wire          gt_rx_elec_idle_i 	// GT Receive Electrical Idle   
);

////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////// 

// Time delays
parameter SATA1_10MS            = 750000;   // 75MHz * 750000
parameter SATA2_10MS            = 1500000;  // 150MHz * 1500000
parameter SATA3_10MS            = 3000000;  // 300MHz * 3000000
parameter SATA1_873US           = 65535;    // 75MHz * 65535
parameter SATA2_873US           = 131070;   // 150MHz * 131070
parameter SATA3_873US           = 262140;   // 300MHz * 262140

// State machine states
parameter HP1_RESET             = 0;
parameter HP2_AWAIT_COMINIT     = 1;
parameter HP2B_AWAIT_NO_COMINIT = 2;
parameter HP3_CALIBRATE         = 3;
parameter HP4_COMWAKE           = 4;
parameter HP5_AWAIT_COMWAKE     = 5;
parameter HP5B_AWAIT_NO_COMWAKE = 6;
parameter HP6_AWAIT_ALIGN       = 7;
parameter HP7_SEND_ALIGN        = 8;
parameter HP8_READY             = 9;

////////////////////////////////////////////////////////////
// Signals
//////////////////////////////////////////////////////////// 

reg  [3:0]   state_cs;            // Current state
reg  [3:0]   state_ns;            // Next state  
reg  [199:0] state_ascii;         // ASCII state
wire         phy_ctrl_strt;       // PHY Control Start
reg	 [31:0]	 align_timeout_cnt;   // ALIGN Timeout Count
reg  [31:0]  retry_cnt;           // Retry Count 
wire         cominit_detect;      // COMINIT Detect
wire         comwake_detect;      // COMWAKE Detect
wire         align_detect;        // ALIGN Detected
wire         align_timeout;       // ALIGN Timeout
reg  [1:0]   non_align_cnt;       // Non ALIGN Count
reg          tx_com_strt;         // Transmit COM Start
wire         tx_com_strt_pedge;   // Transmit COM Start Positive Edge
reg          tx_com_done;         // Transmit COM Done

////////////////////////////////////////////////////////////
// Instance    : Transmit Com Start Pos Edge
// Description : Detect positive edge on com start signal.
////////////////////////////////////////////////////////////

det_pos_edge U_tx_com_strt_pedge(
  .clk   (clk_phy),
  .rst_n (rst_n),
  .d     (tx_com_strt),
  .q     (tx_com_strt_pedge));

////////////////////////////////////////////////////////////
// Comb Assign : PHY Control Start
// Description : Starts the control.
////////////////////////////////////////////////////////////

assign phy_ctrl_strt = gt_rst_done_i;

////////////////////////////////////////////////////////////
// Comb Assign : COMWAKE Detect
// Description : 
////////////////////////////////////////////////////////////

assign comwake_detect = gt_rx_status_i[1];

////////////////////////////////////////////////////////////
// Comb Assign : COMINIT Detect
// Description : 
////////////////////////////////////////////////////////////

assign cominit_detect = gt_rx_status_i[2];

////////////////////////////////////////////////////////////
// Comb Assign : ALIGN Timeout
// Description : 
////////////////////////////////////////////////////////////

assign align_timeout = (align_timeout_cnt == 0);

////////////////////////////////////////////////////////////
// Comb Assign : ALIGN primitive detect
// Description : 
////////////////////////////////////////////////////////////

assign align_detect = (gt_rx_data_i == 32'h7B4A4ABC); 

////////////////////////////////////////////////////////////
// Seq Block   : State machine seq logic
// Description : Sets the current state to the next state.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin
  if (rst_n == 0) begin
    state_cs <= HP1_RESET;   
  end else begin
    state_cs <= state_ns;
  end
end  

////////////////////////////////////////////////////////////
// Comb Block  : State machine ascii 
// Description : Converts the state to ascii for debug.
////////////////////////////////////////////////////////////

always @(*)
begin
  case (state_cs)
    HP1_RESET:             state_ascii = "HP1_RESET";
    HP2_AWAIT_COMINIT:     state_ascii = "HP2_AWAIT_COMINIT";
    HP2B_AWAIT_NO_COMINIT: state_ascii = "HP2B_AWAIT_NO_COMINIT";
    HP3_CALIBRATE:         state_ascii = "HP3_CALIBRATE";
    HP4_COMWAKE:           state_ascii = "HP4_COMWAKE";
    HP5_AWAIT_COMWAKE:     state_ascii = "HP5_AWAIT_COMWAKE";
    HP5B_AWAIT_NO_COMWAKE: state_ascii = "HP5B_AWAIT_NO_COMWAKE";
    HP6_AWAIT_ALIGN:       state_ascii = "HP6_AWAIT_ALIGN";
    HP7_SEND_ALIGN:        state_ascii = "HP7_SEND_ALIGN";
    HP8_READY:             state_ascii = "HP8_READY"; 
  endcase
end

////////////////////////////////////////////////////////////
// Comb Block  : State machine comb logic
// Description : Assigns the next state.
////////////////////////////////////////////////////////////

always @(*)
begin
  state_ns = state_cs;

  case (state_cs)
    // HP1_RESET - Interface quiescent
    HP1_RESET: begin
      if ((phy_ctrl_strt == 1) && (tx_com_done == 1) && (cominit_detect == 0)) begin
        state_ns = HP2_AWAIT_COMINIT;
      end	      
    end
    
    // HP2_AWAIT_COMINIT - Wait for COMINIT to be detected
    HP2_AWAIT_COMINIT: begin
      if (cominit_detect == 1) begin
        state_ns = HP2B_AWAIT_NO_COMINIT;
      end else begin
        // Test if need to send COMRESET again
        if (retry_cnt == 0) begin
          state_ns = HP1_RESET;
        end
      end
    end

    // HP2B_AWAIT_NO_COMINIT - Wait for COMINIT to finish
    HP2B_AWAIT_NO_COMINIT: begin
      if (cominit_detect == 0) begin
        state_ns = HP3_CALIBRATE;
      end
    end
    
    // HP3_CALIBRATE
    HP3_CALIBRATE: begin
      state_ns = HP4_COMWAKE;
    end
    
    // HP4_COMWAKE - Send COMWAKE
    HP4_COMWAKE: begin
      if (tx_com_done == 1) begin
        state_ns = HP5_AWAIT_COMWAKE;
      end
    end
    
    // HP5_AWAIT_COMWAKE - Wait for COMWAKE to be detected
    HP5_AWAIT_COMWAKE: begin
      if (comwake_detect == 1) begin
        state_ns = HP5B_AWAIT_NO_COMWAKE;
      end else begin
        // Test if need to send COMRESET again
        if (retry_cnt == 0) begin
          state_ns = HP1_RESET;
        end
      end
    end
    
    // HP5B_AWAIT_NO_COMWAKE - Wait for COMWAKE to finish
    HP5B_AWAIT_NO_COMWAKE: begin
      if (comwake_detect == 0) begin
        state_ns = HP6_AWAIT_ALIGN;
      end
    end
    
    // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
    HP6_AWAIT_ALIGN: begin
      casez({align_detect, align_timeout})
        2'b10:   state_ns = HP7_SEND_ALIGN; 
        2'b01:   state_ns = HP1_RESET; 
        default: state_ns = HP6_AWAIT_ALIGN; 
      endcase
    end
    
    // HP7_SEND_ALIGN - Send ALIGN
    HP7_SEND_ALIGN: begin
      if (non_align_cnt == 3) begin
        state_ns = HP8_READY; 
      end
    end
    
    // HP8_READY - Link ready
    HP8_READY: begin
      if (gt_rx_elec_idle_i == 1) begin
        state_ns = HP1_RESET;
      end     
    end    
    
    default: begin
      state_ns = 'bx;
    end
  endcase
end

////////////////////////////////////////////////////////////
// Seq Block   : Link Up
// Description : Set when communication has been established
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    link_up_o <= 0;
  end	else begin
    case (state_cs)
      // HP8_READY - Link ready
      HP8_READY: begin
        link_up_o <= 1;
      end  
      
      default: begin
        link_up_o <= 0;
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit COM Start
// Description : Transmits the selected COM signal.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_com_strt_o <= 0;
  end	else begin
    gt_tx_com_strt_o <= tx_com_strt_pedge;
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit COM Type
// Description : 0 = COMRESET/COMINIT, 1 = COMWAKE
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_com_type_o <= 0;
  end	else begin
    case (state_cs)
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        if (phy_ctrl_strt == 1) begin
          gt_tx_com_type_o <= 0;		
        end	      
      end
      
      // HP4_COMWAKE - Send COMWAKE
      HP4_COMWAKE: begin
        gt_tx_com_type_o <= 1;		
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit Electrical Idle
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_elec_idle_o <= 0;
  end	else begin
    case (state_cs)
      // HP5B_AWAIT_NO_COMWAKE - Wait for COMWAKE to finish
      HP5B_AWAIT_NO_COMWAKE: begin
        if (comwake_detect == 0) begin
          gt_tx_elec_idle_o <= 0;
        end
      end
    
      // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
      HP6_AWAIT_ALIGN: begin
        gt_tx_elec_idle_o <= 0;
      end
      
      // HP7_SEND_ALIGN - Send ALIGN
      HP7_SEND_ALIGN: begin
        gt_tx_elec_idle_o <= 0;
      end
      
      // HP8_READY - Link ready
      HP8_READY: begin
        gt_tx_elec_idle_o <= 0;
      end          
      
      default: begin
        gt_tx_elec_idle_o <= 1;
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit Data
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_data_o <= 0;
  end	else begin
    case (state_cs)  
      // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
      HP6_AWAIT_ALIGN: begin
        gt_tx_data_o <= 32'h4A4A4A4A; // D10.2     
      end
      
      // HP7_SEND_ALIGN - Send ALIGN
      HP7_SEND_ALIGN: begin
        gt_tx_data_o <= `ALIGN_VAL;   // ALIGN; 
      end
      
      // HP8_READY - Link ready
      HP8_READY: begin
        gt_tx_data_o <= `SYNC_VAL;    // SYNC;  
      end        
      
      default: begin
        gt_tx_data_o <= 0;      
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : GT Transmit K/D
// Description : 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    gt_tx_charisk_o <= 0;
  end	else begin
    case (state_cs)  
      // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
      HP6_AWAIT_ALIGN: begin
        gt_tx_charisk_o <= 4'b0000; // D10.2     
      end
      
      // HP7_SEND_ALIGN - Send ALIGN
      HP7_SEND_ALIGN: begin
        gt_tx_charisk_o <= 4'b0001; // ALIGN; 
      end
      
      // HP8_READY - Link ready
      HP8_READY: begin
        gt_tx_charisk_o <= 4'b0001; // SYNC;  
      end        
      
      default: begin
        gt_tx_charisk_o <= 0;      
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Transmit COM Start
// Description : Starts transmission of a COM sequence.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    tx_com_strt <= 0;
  end	else begin
    case (state_cs)
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        if (phy_ctrl_strt == 1) begin
          tx_com_strt <= 1;	
        end	else begin
          tx_com_strt <= 0;
        end
      end
      
      // HP4_COMWAKE - Send COMWAKE
      HP4_COMWAKE: begin
        tx_com_strt <= 1;	
      end
          
      default: begin
        tx_com_strt <= 0;   
      end
    endcase
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : Transmit COM Done
// Description : Detects when COM signal has been sent.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
    tx_com_done <= 0;
  end	else begin
    case (state_cs)     
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        if ((phy_ctrl_strt == 1) && (tx_com_done == 1) && (cominit_detect == 0)) begin
          tx_com_done <= 0;
        end else begin
          if (gt_rx_status_i[0] == 1) begin
            tx_com_done <= 1;
          end
        end     
      end
      
      // HP4_COMWAKE - Send COMWAKE
      HP4_COMWAKE: begin
        if (tx_com_done == 1) begin
          tx_com_done <= 0;
        end else begin
          if (gt_rx_status_i[0] == 1) begin
            tx_com_done <= 1;
          end
        end   
      end
    endcase     
  end
end

////////////////////////////////////////////////////////////
// Seq Block   : ALIGN Timeout Count
// Description : Used to send COMRESET if ALIGN primitives
//               are not detected within 873.8us.
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		align_timeout_cnt <= 0;
	end	else begin
	  case (state_cs)     
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        case (SATA_REV)
          1:       align_timeout_cnt <= SATA1_873US;
          2:       align_timeout_cnt <= SATA2_873US;
          3:       align_timeout_cnt <= SATA3_873US;    
          default: align_timeout_cnt <= SATA1_873US;    
        endcase
      end	   
      
      // HP6_AWAIT_ALIGN - Wait for ALIGN to be detected
      HP6_AWAIT_ALIGN: begin
        align_timeout_cnt <= align_timeout_cnt - 1;
      end      
	  endcase
	end
end

////////////////////////////////////////////////////////////
// Seq Block   : Retry Count
// Description : Used to for async signal recovery (10 ms)
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		retry_cnt <= 0;
	end	else begin
	  case (state_cs)  
      // HP1_RESET - Interface quiescent
      HP1_RESET: begin
        case (SATA_REV)
          1:       retry_cnt <= SATA1_10MS;
          2:       retry_cnt <= SATA2_10MS;
          3:       retry_cnt <= SATA3_10MS;    
          default: retry_cnt <= SATA1_10MS;    
        endcase	       
      end
      
      // HP2_AWAIT_COMINIT - Wait for COMINIT to be detected
      HP2_AWAIT_COMINIT: begin
        retry_cnt <= retry_cnt - 1;
      end	 
      
      // HP2B_AWAIT_NO_COMINIT - Wait for COMINIT to finish
      HP2B_AWAIT_NO_COMINIT: begin
        case (SATA_REV)
          1:       retry_cnt <= SATA1_10MS;
          2:       retry_cnt <= SATA2_10MS;
          3:       retry_cnt <= SATA3_10MS;    
          default: retry_cnt <= SATA1_10MS;    
        endcase	 
      end      
      
      // HP5_AWAIT_COMWAKE - Wait for COMWAKE to be detected
      HP5_AWAIT_COMWAKE: begin
        retry_cnt <= retry_cnt - 1;
      end      
	  endcase	  
	end
end

////////////////////////////////////////////////////////////
// Seq Block   : Non ALIGN Count
// Description : Counts 3 non ALIGN primitives. 
////////////////////////////////////////////////////////////

always @(negedge rst_n or posedge clk_phy) 
begin 
  if (rst_n == 0) begin
		non_align_cnt <= 0;
	end	else begin
	  case (state_cs)  
      // HP7_SEND_ALIGN - Send ALIGN
      HP7_SEND_ALIGN: begin
  	    // Look for K28.3
        if (gt_rx_data_i[7:0] == 8'hbc) begin
        		non_align_cnt <= non_align_cnt + 1;
        end else begin
  		      non_align_cnt <= 0;	  
        end    
      end	    
      
      default: begin
        non_align_cnt <= 0;	 
      end
	  endcase	  
	end
end

endmodule
