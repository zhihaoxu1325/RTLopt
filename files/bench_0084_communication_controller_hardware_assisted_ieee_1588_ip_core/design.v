// Curated RTL benchmark case.
// case_id: bench_0084_communication_controller_hardware_assisted_ieee_1588_ip_core
// source_project: communication_controller_hardware_assisted_ieee_1588_ip_core
// top_module: ha1588


// -----------------------------------------------------------------------------
// Source file: rtl/top/ha1588.v
// -----------------------------------------------------------------------------
/*
 * ha1588.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

// TODO: add define to generate rtc only or tsu only.

module ha1588 (
  input         rst,clk,
  input         wr_in,rd_in,
  input  [ 7:0] addr_in,
  input  [31:0] data_in,
  output [31:0] data_out,

  input         rtc_clk,
  output [31:0] rtc_time_ptp_ns,
  output [47:0] rtc_time_ptp_sec,
  output        rtc_time_one_pps,

  input       rx_gmii_clk,
  input       rx_gmii_ctrl,
  input [7:0] rx_gmii_data,
  input       rx_giga_mode,

  input       tx_gmii_clk,
  input       tx_gmii_ctrl,
  input [7:0] tx_gmii_data,
  input       tx_giga_mode
);

parameter addr_is_in_word = 0;
wire [ 5: 0] word_addr_in;
wire [ 7: 0] byte_addr_in;
generate
  if (addr_is_in_word)
    assign word_addr_in = addr_in[ 5: 0];
  else
    assign word_addr_in = addr_in[ 7: 2];
endgenerate
assign byte_addr_in = {word_addr_in, 2'b00};

wire rtc_rst;
wire rtc_time_ld, rtc_period_ld, rtc_adj_ld, adj_ld_done;
wire [37:0] rtc_time_reg_ns;
wire [47:0] rtc_time_reg_sec;
wire [39:0] rtc_period;
wire [31:0] rtc_adj_ld_data;
wire [39:0] rtc_period_adj;
wire [37:0] rtc_time_reg_ns_val;
wire [47:0] rtc_time_reg_sec_val;
wire [79:0] rtc_time_ptp_val = {rtc_time_ptp_sec[47:0], rtc_time_ptp_ns[31:0]};

wire rx_q_rst, rx_q_clk;
wire rx_q_rd_en;
wire [  7:0] rx_q_ptp_msgid_mask;
wire [  7:0] rx_q_stat;
wire [127:0] rx_q_data;
wire tx_q_rst, tx_q_clk;
wire tx_q_rd_en;
wire [  7:0] tx_q_ptp_msgid_mask;
wire [  7:0] tx_q_stat;
wire [127:0] tx_q_data;

rgs u_rgs
(
  .rst(rst),
  .clk(clk),
  .wr_in(wr_in),
  .rd_in(rd_in),
  .addr_in(byte_addr_in),
  .data_in(data_in),
  .data_out(data_out),
  .rtc_clk_in(rtc_clk),
  .rtc_rst_out(rtc_rst),
  .time_ld_out(rtc_time_ld),
  .time_reg_ns_out(rtc_time_reg_ns),
  .time_reg_sec_out(rtc_time_reg_sec),
  .period_ld_out(rtc_period_ld),
  .period_out(rtc_period),
  .adj_ld_out(rtc_adj_ld),
  .adj_ld_data_out(rtc_adj_ld_data),
  .period_adj_out(rtc_period_adj),
  .adj_ld_done_in(adj_ld_done),
  .time_reg_ns_in(rtc_time_reg_ns_val),
  .time_reg_sec_in(rtc_time_reg_sec_val),
  .rx_q_rst_out(rx_q_rst),
  .rx_q_rd_clk_out(rx_q_clk),
  .rx_q_rd_en_out(rx_q_rd_en),
  .rx_q_ptp_msgid_mask_out(rx_q_ptp_msgid_mask),
  .rx_q_stat_in(rx_q_stat),
  .rx_q_data_in(rx_q_data),
  .tx_q_rst_out(tx_q_rst),
  .tx_q_rd_clk_out(tx_q_clk),
  .tx_q_rd_en_out(tx_q_rd_en),
  .tx_q_ptp_msgid_mask_out(tx_q_ptp_msgid_mask),
  .tx_q_stat_in(tx_q_stat),
  .tx_q_data_in(tx_q_data)
);

rtc u_rtc
(
  .rst(rtc_rst),
  .clk(rtc_clk),
  .time_ld(rtc_time_ld),
  .time_reg_ns_in(rtc_time_reg_ns),
  .time_reg_sec_in(rtc_time_reg_sec),
  .period_ld(rtc_period_ld),
  .period_in(rtc_period),
  .adj_ld(rtc_adj_ld),
  .adj_ld_data(rtc_adj_ld_data),
  .adj_ld_done(adj_ld_done),
  .period_adj(rtc_period_adj),
  .time_reg_ns(rtc_time_reg_ns_val),
  .time_reg_sec(rtc_time_reg_sec_val),
  .time_one_pps(rtc_time_one_pps),
  .time_ptp_ns(rtc_time_ptp_ns),
  .time_ptp_sec(rtc_time_ptp_sec)
);

tsu u_rx_tsu
(
  .rst(rst),
  .gmii_clk(rx_gmii_clk),
  .gmii_ctrl(rx_gmii_ctrl),
  .gmii_data(rx_gmii_data),
  .giga_mode(rx_giga_mode),
  .ptp_msgid_mask(rx_q_ptp_msgid_mask),
  .rtc_timer_clk(rtc_clk),
  .rtc_timer_in(rtc_time_ptp_val),
  .q_rst(rx_q_rst),
  .q_rd_clk(rx_q_clk),
  .q_rd_en(rx_q_rd_en),
  .q_rd_stat(rx_q_stat),
  .q_rd_data(rx_q_data)
);

tsu u_tx_tsu
(
  .rst(rst),
  .gmii_clk(tx_gmii_clk),
  .gmii_ctrl(tx_gmii_ctrl),
  .gmii_data(tx_gmii_data),
  .giga_mode(tx_giga_mode),
  .ptp_msgid_mask(tx_q_ptp_msgid_mask),
  .rtc_timer_clk(rtc_clk),
  .rtc_timer_in(rtc_time_ptp_val),
  .q_rst(tx_q_rst),
  .q_rd_clk(tx_q_clk),
  .q_rd_en(tx_q_rd_en),
  .q_rd_stat(tx_q_stat),
  .q_rd_data(tx_q_data)
);

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/reg/reg.v
// -----------------------------------------------------------------------------
/*
 * reg.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

module rgs (
  // generic bus interface
  input         rst,clk,
  input         wr_in,rd_in,
  input  [ 7:0] addr_in,
  input  [31:0] data_in,
  output [31:0] data_out,
  // rtc interface
  input         rtc_clk_in,
  output        rtc_rst_out,
  output        time_ld_out,
  output [37:0] time_reg_ns_out,
  output [47:0] time_reg_sec_out,
  output        period_ld_out,
  output [39:0] period_out,
  output        adj_ld_out,
  output [31:0] adj_ld_data_out,
  output [39:0] period_adj_out,
  input         adj_ld_done_in,
  input  [37:0] time_reg_ns_in,
  input  [47:0] time_reg_sec_in,
  // rx tsu interface
  output         rx_q_rst_out,
  output         rx_q_rd_clk_out,
  output         rx_q_rd_en_out,
  output [  7:0] rx_q_ptp_msgid_mask_out,
  input  [  7:0] rx_q_stat_in,
  input  [127:0] rx_q_data_in,
  // tx tsu interface
  output         tx_q_rst_out,
  output         tx_q_rd_clk_out,
  output         tx_q_rd_en_out,
  output [  7:0] tx_q_ptp_msgid_mask_out,
  input  [  7:0] tx_q_stat_in,
  input  [127:0] tx_q_data_in
);

parameter const_00 = 8'h00;
parameter const_04 = 8'h04;
parameter const_08 = 8'h08;
parameter const_0c = 8'h0C;
parameter const_10 = 8'h10;
parameter const_14 = 8'h14;
parameter const_18 = 8'h18;
parameter const_1c = 8'h1C;
parameter const_20 = 8'h20;
parameter const_24 = 8'h24;
parameter const_28 = 8'h28;
parameter const_2c = 8'h2C;
parameter const_30 = 8'h30;
parameter const_34 = 8'h34;
parameter const_38 = 8'h38;
parameter const_3c = 8'h3C;
parameter const_40 = 8'h40;
parameter const_44 = 8'h44;
parameter const_48 = 8'h48;
parameter const_4c = 8'h4C;
parameter const_50 = 8'h50;
parameter const_54 = 8'h54;
parameter const_58 = 8'h58;
parameter const_5c = 8'h5C;
parameter const_60 = 8'h60;
parameter const_64 = 8'h64;
parameter const_68 = 8'h68;
parameter const_6c = 8'h6C;
parameter const_70 = 8'h70;
parameter const_74 = 8'h74;
parameter const_78 = 8'h78;
parameter const_7c = 8'h7C;

wire cs_00 = (addr_in[7:2]==const_00[7:2])? 1'b1: 1'b0;
wire cs_04 = (addr_in[7:2]==const_04[7:2])? 1'b1: 1'b0;
wire cs_08 = (addr_in[7:2]==const_08[7:2])? 1'b1: 1'b0;
wire cs_0c = (addr_in[7:2]==const_0c[7:2])? 1'b1: 1'b0;
wire cs_10 = (addr_in[7:2]==const_10[7:2])? 1'b1: 1'b0;
wire cs_14 = (addr_in[7:2]==const_14[7:2])? 1'b1: 1'b0;
wire cs_18 = (addr_in[7:2]==const_18[7:2])? 1'b1: 1'b0;
wire cs_1c = (addr_in[7:2]==const_1c[7:2])? 1'b1: 1'b0;
wire cs_20 = (addr_in[7:2]==const_20[7:2])? 1'b1: 1'b0;
wire cs_24 = (addr_in[7:2]==const_24[7:2])? 1'b1: 1'b0;
wire cs_28 = (addr_in[7:2]==const_28[7:2])? 1'b1: 1'b0;
wire cs_2c = (addr_in[7:2]==const_2c[7:2])? 1'b1: 1'b0;
wire cs_30 = (addr_in[7:2]==const_30[7:2])? 1'b1: 1'b0;
wire cs_34 = (addr_in[7:2]==const_34[7:2])? 1'b1: 1'b0;
wire cs_38 = (addr_in[7:2]==const_38[7:2])? 1'b1: 1'b0;
wire cs_3c = (addr_in[7:2]==const_3c[7:2])? 1'b1: 1'b0;
wire cs_40 = (addr_in[7:2]==const_40[7:2])? 1'b1: 1'b0;
wire cs_44 = (addr_in[7:2]==const_44[7:2])? 1'b1: 1'b0;
wire cs_48 = (addr_in[7:2]==const_48[7:2])? 1'b1: 1'b0;
wire cs_4c = (addr_in[7:2]==const_4c[7:2])? 1'b1: 1'b0;
wire cs_50 = (addr_in[7:2]==const_50[7:2])? 1'b1: 1'b0;
wire cs_54 = (addr_in[7:2]==const_54[7:2])? 1'b1: 1'b0;
wire cs_58 = (addr_in[7:2]==const_58[7:2])? 1'b1: 1'b0;
wire cs_5c = (addr_in[7:2]==const_5c[7:2])? 1'b1: 1'b0;
wire cs_60 = (addr_in[7:2]==const_60[7:2])? 1'b1: 1'b0;
wire cs_64 = (addr_in[7:2]==const_64[7:2])? 1'b1: 1'b0;
wire cs_68 = (addr_in[7:2]==const_68[7:2])? 1'b1: 1'b0;
wire cs_6c = (addr_in[7:2]==const_6c[7:2])? 1'b1: 1'b0;
wire cs_70 = (addr_in[7:2]==const_70[7:2])? 1'b1: 1'b0;
wire cs_74 = (addr_in[7:2]==const_74[7:2])? 1'b1: 1'b0;
wire cs_78 = (addr_in[7:2]==const_78[7:2])? 1'b1: 1'b0;
wire cs_7c = (addr_in[7:2]==const_7c[7:2])? 1'b1: 1'b0;

reg [31:0] reg_00;  // ctrl 5 bit
reg [31:0] reg_04;  // scratch reg
reg [31:0] reg_08;  // null
reg [31:0] reg_0c;  // null
reg [31:0] reg_10;  // time 16 bit s
reg [31:0] reg_14;  // time 32 bit s
reg [31:0] reg_18;  // time 30 bit ns
reg [31:0] reg_1c;  // time  8 bit nsf
reg [31:0] reg_20;  // peri  8 bit ns
reg [31:0] reg_24;  // peri 32 bit nsf
reg [31:0] reg_28;  // ajpr  8 bit ns
reg [31:0] reg_2c;  // ajpr 32 bit nsf
reg [31:0] reg_30;  // ajld 32 bit
reg [31:0] reg_34;  // null
reg [31:0] reg_38;  // null
reg [31:0] reg_3c;  // null
reg [31:0] reg_40;  // ctrl  2 bit
reg [31:0] reg_44;  // qsta  8 bit
reg [31:0] reg_48;  // null
reg [31:0] reg_4c;  // null
reg [31:0] reg_50;  // rxqu 32 bit
reg [31:0] reg_54;  // rxqu 32 bit
reg [31:0] reg_58;  // rxqu 32 bit
reg [31:0] reg_5c;  // rxqu 32 bit
reg [31:0] reg_60;  // ctrl  2 bit
reg [31:0] reg_64;  // qsta  8 bit
reg [31:0] reg_68;  // null
reg [31:0] reg_6c;  // null
reg [31:0] reg_70;  // txqu 32 bit
reg [31:0] reg_74;  // txqu 32 bit
reg [31:0] reg_78;  // txqu 32 bit
reg [31:0] reg_7c;  // txqu 32 bit

// write registers
always @(posedge clk) begin
  if (wr_in && cs_00) reg_00 <= data_in;
  if (wr_in && cs_04) reg_04 <= data_in;
  if (wr_in && cs_08) reg_08 <= data_in;
  if (wr_in && cs_0c) reg_0c <= data_in;
  if (wr_in && cs_10) reg_10 <= data_in;
  if (wr_in && cs_14) reg_14 <= data_in;
  if (wr_in && cs_18) reg_18 <= data_in;
  if (wr_in && cs_1c) reg_1c <= data_in;
  if (wr_in && cs_20) reg_20 <= data_in;
  if (wr_in && cs_24) reg_24 <= data_in;
  if (wr_in && cs_28) reg_28 <= data_in;
  if (wr_in && cs_2c) reg_2c <= data_in;
  if (wr_in && cs_30) reg_30 <= data_in;
  if (wr_in && cs_34) reg_34 <= data_in;
  if (wr_in && cs_38) reg_38 <= data_in;
  if (wr_in && cs_3c) reg_3c <= data_in;
  if (wr_in && cs_40) reg_40 <= data_in;
  if (wr_in && cs_44) reg_44 <= data_in;
  if (wr_in && cs_48) reg_48 <= data_in;
  if (wr_in && cs_4c) reg_4c <= data_in;
  if (wr_in && cs_50) reg_50 <= data_in;
  if (wr_in && cs_54) reg_54 <= data_in;
  if (wr_in && cs_58) reg_58 <= data_in;
  if (wr_in && cs_5c) reg_5c <= data_in;
  if (wr_in && cs_60) reg_60 <= data_in;
  if (wr_in && cs_64) reg_64 <= data_in;
  if (wr_in && cs_68) reg_68 <= data_in;
  if (wr_in && cs_6c) reg_6c <= data_in;
  if (wr_in && cs_70) reg_70 <= data_in;
  if (wr_in && cs_74) reg_74 <= data_in;
  if (wr_in && cs_78) reg_78 <= data_in;
  if (wr_in && cs_7c) reg_7c <= data_in;
end

// read registers
reg  [37:0] time_reg_ns_int;
reg  [47:0] time_reg_sec_int;
reg  [127:0] rx_q_data_int;
reg  [  7:0] rx_q_stat_int;
reg  [127:0] tx_q_data_int;
reg  [  7:0] tx_q_stat_int;
reg         time_ok;
reg         rxqu_ok;
reg         txqu_ok;

reg  [31:0] data_out_reg;
always @(posedge clk) begin
  // register mapping: RTC
  if (rd_in && cs_00) data_out_reg <= {27'd0, reg_00[ 4: 2], adj_ld_done_in, time_ok};
  if (rd_in && cs_04) data_out_reg <= reg_04;
  if (rd_in && cs_08) data_out_reg <= 32'd0;
  if (rd_in && cs_0c) data_out_reg <= 32'd0;
  if (rd_in && cs_10) data_out_reg <= {16'd0, time_reg_sec_int[47:32]};
  if (rd_in && cs_14) data_out_reg <=         time_reg_sec_int[31: 0] ;
  if (rd_in && cs_18) data_out_reg <= { 2'd0, time_reg_ns_int [37: 8]};
  if (rd_in && cs_1c) data_out_reg <= {24'd0, time_reg_ns_int [ 7: 0]};
  if (rd_in && cs_20) data_out_reg <= {24'd0, reg_20[ 7: 0]};
  if (rd_in && cs_24) data_out_reg <= reg_24;
  if (rd_in && cs_28) data_out_reg <= {24'd0, reg_28[ 7: 0]};
  if (rd_in && cs_2c) data_out_reg <= reg_2c;
  if (rd_in && cs_30) data_out_reg <= reg_30;
  if (rd_in && cs_34) data_out_reg <= 32'd0;
  if (rd_in && cs_38) data_out_reg <= 32'd0;
  if (rd_in && cs_3c) data_out_reg <= 32'd0;
  // register mapping: TSU RX
  if (rd_in && cs_40) data_out_reg <= {30'd0, reg_40[ 1], rxqu_ok};
  if (rd_in && cs_44) data_out_reg <= {reg_44[31:24], 16'd0, rx_q_stat_int[ 7: 0]};
  if (rd_in && cs_48) data_out_reg <= 32'd0;
  if (rd_in && cs_4c) data_out_reg <= 32'd0;
  if (rd_in && cs_50) data_out_reg <= rx_q_data_int[127: 96];
  if (rd_in && cs_54) data_out_reg <= rx_q_data_int[ 95: 64];
  if (rd_in && cs_58) data_out_reg <= rx_q_data_int[ 63: 32];
  if (rd_in && cs_5c) data_out_reg <= rx_q_data_int[ 31:  0];
  // register mapping: TSU TX
  if (rd_in && cs_60) data_out_reg <= {30'd0, reg_60[ 1], txqu_ok}; 
  if (rd_in && cs_64) data_out_reg <= {reg_64[31:24], 16'd0, tx_q_stat_int[ 7: 0]};
  if (rd_in && cs_68) data_out_reg <= 32'd0;
  if (rd_in && cs_6c) data_out_reg <= 32'd0;
  if (rd_in && cs_70) data_out_reg <= tx_q_data_int[127: 96];
  if (rd_in && cs_74) data_out_reg <= tx_q_data_int[ 95: 64];
  if (rd_in && cs_78) data_out_reg <= tx_q_data_int[ 63: 32];
  if (rd_in && cs_7c) data_out_reg <= tx_q_data_int[ 31:  0];
end
assign data_out = data_out_reg;

// register mapping: RTC
//wire       = reg_00[ 7];
//wire       = reg_00[ 6];
//wire       = reg_00[ 5];
wire rtc_rst = reg_00[ 4];
wire time_ld = reg_00[ 3];
wire perd_ld = reg_00[ 2];
wire adjt_ld = reg_00[ 1];
wire time_rd = reg_00[ 0];
assign time_reg_sec_out [47:0] = {reg_10[15: 0], reg_14[31: 0]};
assign time_reg_ns_out  [37:0] = {reg_18[29: 0], reg_1c[ 7: 0]};
assign period_out       [39:0] = {reg_20[ 7: 0], reg_24[31: 0]};
assign period_adj_out   [39:0] = {reg_28[ 7: 0], reg_2c[31: 0]};
assign adj_ld_data_out  [31:0] =  reg_30[31: 0];

// register mapping: TSU RX
//wire       = reg_40[ 7];
//wire       = reg_40[ 6];
//wire       = reg_40[ 5];
//wire       = reg_40[ 4];
//wire       = reg_40[ 3];
//wire       = reg_40[ 2];
wire rxq_rst = reg_40[ 1];
wire rxqu_rd = reg_40[ 0];
assign rx_q_ptp_msgid_mask_out [7:0] = reg_44[31:24];

// register mapping: TSU TX
//wire       = reg_60[ 7];
//wire       = reg_60[ 6];
//wire       = reg_60[ 5];
//wire       = reg_60[ 4];
//wire       = reg_60[ 3];
//wire       = reg_60[ 2];
wire txq_rst = reg_60[ 1];
wire txqu_rd = reg_60[ 0];
assign tx_q_ptp_msgid_mask_out [7:0] = reg_64[31:24];
// TODO: add configurable VLANTPID values

// real time clock
reg rtc_rst_s1, rtc_rst_s2, rtc_rst_s3;
assign rtc_rst_out = rtc_rst_s2 && !rtc_rst_s3;
always @(posedge rtc_clk_in) begin
  rtc_rst_s1 <= rtc_rst;
  rtc_rst_s2 <= rtc_rst_s1;
  rtc_rst_s3 <= rtc_rst_s2;
end

reg time_ld_s1, time_ld_s2, time_ld_s3;
assign time_ld_out = time_ld_s2 && !time_ld_s3;
always @(posedge rtc_clk_in) begin
  time_ld_s1 <= time_ld;
  time_ld_s2 <= time_ld_s1;
  time_ld_s3 <= time_ld_s2;
end

reg perd_ld_s1, perd_ld_s2, perd_ld_s3;
assign period_ld_out  = perd_ld_s2 && !perd_ld_s3;
always @(posedge rtc_clk_in) begin
  perd_ld_s1 <= perd_ld;
  perd_ld_s2 <= perd_ld_s1;
  perd_ld_s3 <= perd_ld_s2;
end

reg adjt_ld_s1, adjt_ld_s2, adjt_ld_s3;
assign adj_ld_out = adjt_ld_s2 && !adjt_ld_s3;
always @(posedge rtc_clk_in) begin
  adjt_ld_s1 <= adjt_ld;
  adjt_ld_s2 <= adjt_ld_s1;
  adjt_ld_s3 <= adjt_ld_s2;
end

// RTC time read CDC hand-shaking
reg time_rd_s1, time_rd_s2, time_rd_s3;
wire time_rd_ack = time_rd_s2 && !time_rd_s3;
always @(posedge rtc_clk_in) begin
  time_rd_s1 <= time_rd;
  time_rd_s2 <= time_rd_s1;
  time_rd_s3 <= time_rd_s2;
end

always @(posedge rtc_clk_in) begin
  if (time_rd_ack) begin
    time_reg_ns_int  <= time_reg_ns_in;
    time_reg_sec_int <= time_reg_sec_in;	  
  end
end

reg time_rd_d1;
wire time_rd_req = time_rd && !time_rd_d1;
always @(posedge clk) begin
  time_rd_d1 <= time_rd;
end

always @(posedge clk or posedge time_rd_ack) begin
  if (time_rd_ack)
    time_ok <= 1'b1;
  else if (time_rd_req)
    time_ok <= 1'b0;
end

// rx time stamp queue
assign rx_q_rd_clk_out = clk;

reg rxq_rst_d1, rxq_rst_d2, rxq_rst_d3;
assign rx_q_rst_out = rxq_rst_d2 && !rxq_rst_d3;
always @(posedge clk) begin
  rxq_rst_d1 <= rxq_rst;
  rxq_rst_d2 <= rxq_rst_d1;
  rxq_rst_d3 <= rxq_rst_d2;
end

reg rxqu_rd_d1, rxqu_rd_d2, rxqu_rd_d3, rxqu_rd_d4, rxqu_rd_d5;
assign rx_q_rd_en_out = rxqu_rd_d2 && !rxqu_rd_d3;
wire   rx_q_rd_req    = rxqu_rd_d2 && !rxqu_rd_d3;
wire   rx_q_rd_ack    = rxqu_rd_d4 && !rxqu_rd_d5;
always @(posedge clk) begin
  rxqu_rd_d1 <= rxqu_rd;
  rxqu_rd_d2 <= rxqu_rd_d1;
  rxqu_rd_d3 <= rxqu_rd_d2;
  rxqu_rd_d4 <= rxqu_rd_d3;
  rxqu_rd_d5 <= rxqu_rd_d4;
end

always @(posedge clk) begin
  if (rx_q_rd_ack)
    rxqu_ok <= 1'b1;
  else if (rx_q_rd_req)
    rxqu_ok <= 1'b0;
end

always @(posedge clk) begin
  rx_q_data_int <= rx_q_data_in;
  rx_q_stat_int <= rx_q_stat_in;
end

// tx time stamp queue
assign tx_q_rd_clk_out = clk;

reg txq_rst_d1, txq_rst_d2, txq_rst_d3;
assign tx_q_rst_out = txq_rst_d2 && !txq_rst_d3;
always @(posedge clk) begin
  txq_rst_d1 <= txq_rst;
  txq_rst_d2 <= txq_rst_d1;
  txq_rst_d3 <= txq_rst_d2;
end

reg txqu_rd_d1, txqu_rd_d2, txqu_rd_d3, txqu_rd_d4, txqu_rd_d5;
assign tx_q_rd_en_out = txqu_rd_d2 && !txqu_rd_d3;
wire   tx_q_rd_req    = txqu_rd_d2 && !txqu_rd_d3;
wire   tx_q_rd_ack    = txqu_rd_d4 && !txqu_rd_d5;
always @(posedge clk) begin
  txqu_rd_d1 <= txqu_rd;
  txqu_rd_d2 <= txqu_rd_d1;
  txqu_rd_d3 <= txqu_rd_d2;
  txqu_rd_d4 <= txqu_rd_d3;
  txqu_rd_d5 <= txqu_rd_d4;
end

always @(posedge clk) begin
  if (tx_q_rd_ack)
    txqu_ok <= 1'b1;
  else if (tx_q_rd_req)
    txqu_ok <= 1'b0;
end

always @(posedge clk) begin
  tx_q_data_int <= tx_q_data_in;
  tx_q_stat_int <= tx_q_stat_in;
end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/rtc/rtc.v
// -----------------------------------------------------------------------------
/*
 * rtc.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

module rtc (
  input rst, clk,
  // 1. direct time adjustment: ToD set up
  input        time_ld,
  input [37:0] time_reg_ns_in,   // 37:8 ns, 7:0 ns_fraction
  input [47:0] time_reg_sec_in,  // 47:0 sec
  // 2. frequency adjustment: frequency set up for drift compensation
  input        period_ld,
  input [39:0] period_in,        // 39:32 ns, 31:0 ns_fraction
  // 3. precise time adjustment: small time difference adjustment with a time mark
  input        adj_ld,
  input [31:0] adj_ld_data,
  output reg   adj_ld_done,
  input [39:0] period_adj,  // 39:32 ns, 31:0 ns_fraction

  // time output: for internal with ns fraction
  output [37:0] time_reg_ns,  // 37:8 ns, 7:0 ns_fraction
  output [47:0] time_reg_sec, // 47:0 sec
  // time output: for external with one pps accuracy 
  output reg    time_one_pps,
  // time output: for external with ptp standard
  output [31:0] time_ptp_ns,  // 31:0 ns
  output [47:0] time_ptp_sec  // 47:0 sec
);

parameter time_acc_modulo = 38'd256000000000;  // 1,000,000,000ns * 256ns_fraction, 1s carry_out

reg  [39:0] period_fix;  // 39:32 ns, 31:0 ns_fraction
reg  [31:0] adj_cnt;
reg  [39:0] time_adj;    // 39:32 ns, 31:0 ns_fraction
// frequency and small time difference adjustment registers
always @(posedge rst or posedge clk) begin
  if (rst) begin
    period_fix  <= period_fix;  //40'd0;
    adj_cnt     <= 32'hffffffff;
    time_adj    <= time_adj;    //40'd0;
    adj_ld_done <= 1'b0;
  end
  else begin
    if (period_ld)  // load period adjustment
      period_fix <= period_in;
    else
      period_fix <= period_fix;

    if (adj_ld)  // load precise time adjustment time mark
      adj_cnt  <= adj_ld_data;
    else if (adj_cnt==32'hffffffff)
      adj_cnt  <= adj_cnt;  // no cycling
    else
      adj_cnt  <= adj_cnt - 1;  // counting down

    if (adj_cnt==0)  // change period temparorily
      time_adj <= period_fix + period_adj;
    else
      time_adj <= period_fix + 0;

    if (adj_cnt==32'hffffffff)
      adj_ld_done <= 1'b1;
    else
      adj_ld_done <= 1'b0;
  end
end

reg  [39:0] time_adj_08n_32f;      //             39:32 ns, 31:0 ns_fraction
reg  [39:0] time_adj_16b_00n_24f;  // 39:24 sign,           23:0 ns_fraction
wire [37:0] time_adj_22b_08n_08f;  // 37:16 sign, 15: 8 ns,  7:0 ns_fraction
// delta-sigma circuit to keep the lower 24bit of time_adj
always @(posedge rst or posedge clk) begin
  if (rst) begin
    time_adj_08n_32f     <= 40'd0;
    time_adj_16b_00n_24f <= 24'd0;
  end
  else begin
    time_adj_08n_32f     <= time_adj[39: 0] + time_adj_16b_00n_24f;  // add the delta
    time_adj_16b_00n_24f <= {16'h0000, time_adj_08n_32f[23: 0]}; // save the delta
  end
end
assign time_adj_22b_08n_08f = time_adj_08n_32f[39]? {22'h3fffff, time_adj_08n_32f[39:24]}: {22'h000000, time_adj_08n_32f[39:24]};  // preserve the sign

reg  [37:0] time_acc_30n_08f_pre_pos;  // 37:8 ns , 7:0 ns_fraction
reg  [37:0] time_acc_30n_08f_pre_neg;  // 37:8 ns , 7:0 ns_fraction
wire        time_acc_48s_inc = (time_acc_30n_08f_pre_pos >= time_acc_modulo)? 1'b1: 1'b0;
// time accumulator pre adder (48bit_s + 30bit_ns + 8bit_ns_fraction)
always @(posedge rst or posedge clk) begin
  if (rst) begin
    time_acc_30n_08f_pre_pos <= 38'd0;
    time_acc_30n_08f_pre_neg <= 38'd0;
  end
  else begin
    if (time_ld) begin  // direct write
      time_acc_30n_08f_pre_pos <= time_reg_ns_in + time_adj_22b_08n_08f;
      time_acc_30n_08f_pre_neg <= time_reg_ns_in + time_adj_22b_08n_08f;
    end
    else begin
      if (time_acc_48s_inc) begin
        time_acc_30n_08f_pre_pos <= time_acc_30n_08f_pre_neg + time_adj_22b_08n_08f;
        time_acc_30n_08f_pre_neg <= time_acc_30n_08f_pre_neg + time_adj_22b_08n_08f - time_acc_modulo;
      end
      else begin
        time_acc_30n_08f_pre_pos <= time_acc_30n_08f_pre_pos + time_adj_22b_08n_08f;
        time_acc_30n_08f_pre_neg <= time_acc_30n_08f_pre_pos + time_adj_22b_08n_08f - time_acc_modulo;
      end
    end
  end
end

reg  [37:0] time_acc_30n_08f;          // 37:8 ns , 7:0 ns_fraction
reg  [47:0] time_acc_48s;              // 47:0 sec
// time accumulator (48bit_s + 30bit_ns + 8bit_ns_fraction)
always @(posedge rst or posedge clk) begin
  if (rst) begin
    time_acc_30n_08f <= 38'd0;
    time_acc_48s     <= 48'd0;
  end
  else begin
    if (time_ld) begin  // direct write
      time_acc_30n_08f <= time_reg_ns_in;
      time_acc_48s     <= time_reg_sec_in;
    end
    else begin

      if (time_acc_48s_inc)
        time_acc_30n_08f <= time_acc_30n_08f_pre_neg;
      else
        time_acc_30n_08f <= time_acc_30n_08f_pre_pos;

      if (time_acc_48s_inc)
        time_acc_48s     <= time_acc_48s + 1;
      else
        time_acc_48s     <= time_acc_48s;

    end
  end
end

// time output (48bit_s + 30bit_ns + 8bit_ns_fraction)
assign time_reg_ns  = time_acc_30n_08f;
assign time_reg_sec = time_acc_48s;
// time output (48bit_s + 32bit_ns)
assign time_ptp_ns  = {2'b00, time_acc_30n_08f[37:8]};  // 30bit is enough to represent 1,000,000,000ns
assign time_ptp_sec = time_acc_48s;
// time output one pps
always @(posedge rst or posedge clk) begin
  if (rst)
    time_one_pps <= 1'b0;
  else
    time_one_pps <= time_acc_48s_inc;
end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/tsu/ptp_parser.v
// -----------------------------------------------------------------------------
/*
 * ptp_parser.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

module ptp_parser (
  input        clk, rst,
  input [31:0] int_data,
  input        int_valid,
  input        int_sop,
  input        int_eop,
  input [ 1:0] int_mod,

  input [ 7:0] ptp_msgid_mask,

  output reg        ptp_found,
  output reg [31:0] ptp_infor
);

// constant values
parameter c_vlan_tpid_1 = 16'h8100;
parameter c_vlan_tpid_2 = 16'h88a8;
parameter c_vlan_tpid_3 = 16'h9100;

parameter c_mpls_type_1 = 16'h8847;
parameter c_mpls_type_2 = 16'h8848;

parameter c_ipv4_type   = 16'h0800;
parameter c_ipv6_type   = 16'h86dd;

parameter c_ptp2_type   = 16'h88f7;
parameter c_ptp4_port_1 = 16'h013f;
parameter c_ptp4_port_2 = 16'h0140;

// buffer data input
reg [31:0] int_data_d1;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_data_d1  <= 32'h00000000;
  end
  else begin
    if (int_valid) begin
      int_data_d1  <= int_data;
    end
  end
end

// packet parser: counter
reg [ 9:0] int_cnt, bypass_ipv4_cnt, bypass_ipv6_cnt, bypass_udp_cnt, ptp_cnt;
reg bypass_vlan, ptp_l2, bypass_mpls, bypass_ipv4, bypass_ipv6, found_udp, bypass_udp, ptp_l4, ptp_event;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_cnt <= 10'd0;
    bypass_ipv4_cnt <= 10'd0;
    bypass_ipv6_cnt <= 10'd0;
    bypass_udp_cnt <= 10'd0;
  end
  else begin
    if (int_valid && int_sop)
      int_cnt <= 10'd0;
    else if (int_valid)
      int_cnt <= int_cnt + 10'd1 - bypass_vlan - bypass_mpls - (bypass_ipv4 || bypass_ipv6 || bypass_udp);

    if (int_valid && int_sop)
      bypass_ipv4_cnt <= 10'd0;
    else if (int_valid && bypass_ipv4)
      bypass_ipv4_cnt <= bypass_ipv4_cnt + 10'd1;

    if (int_valid && int_sop)
      bypass_ipv6_cnt <= 10'd0;
    else if (int_valid && bypass_ipv6)
      bypass_ipv6_cnt <= bypass_ipv6_cnt + 10'd1;

    if (int_valid && int_sop)
      bypass_udp_cnt <= 10'd0;
    else if (int_valid && bypass_udp)
      bypass_udp_cnt <= bypass_udp_cnt + 10'd1;

    if (int_valid && int_sop)
      ptp_cnt <= 10'd0;
    else if (int_valid && (ptp_l2 || (bypass_udp_cnt>=10'd2 && ptp_l4)))
      ptp_cnt <= ptp_cnt + 10'd1;
  end
end

// packet parser: comparator
always @(posedge rst or posedge clk) begin
  if (rst) begin
    bypass_vlan  <= 1'b0;
    bypass_mpls  <= 1'b0;
    bypass_ipv4  <= 1'b0;
    bypass_ipv6  <= 1'b0;
    found_udp    <= 1'b0;
    bypass_udp   <= 1'b0;
    ptp_l2    <= 1'b0;
    ptp_l4    <= 1'b0;
    ptp_event <= 1'b0;
  end
  else if (int_valid && int_sop) begin
    bypass_vlan  <= 1'b0;
    bypass_mpls  <= 1'b0;
    bypass_ipv4  <= 1'b0;
    bypass_ipv6  <= 1'b0;
    found_udp    <= 1'b0;
    bypass_udp   <= 1'b0;
    ptp_l2    <= 1'b0;
    ptp_l4    <= 1'b0;
    ptp_event <= 1'b0;
  end
  else begin
    // bypass vlan
    if      (int_valid && int_cnt==10'd4 && (int_data[31:16]==c_vlan_tpid_1 || int_data[31:16]==c_vlan_tpid_2 || int_data[31:16]==c_vlan_tpid_3))  // ether_type == vlan
      bypass_vlan <= 1'b1;
    else if (int_valid && int_cnt==10'd5 && (int_data[31:16]==c_vlan_tpid_1 || int_data[31:16]==c_vlan_tpid_2 || int_data[31:16]==c_vlan_tpid_3) && bypass_vlan)  // vlan_type == vlan
      bypass_vlan <= 1'b1;
    else if (int_valid && bypass_vlan)
      bypass_vlan <= 1'b0;

    // bypass mpls
    if      (int_valid && (int_cnt==10'd4 || bypass_vlan && int_cnt==10'd5) && 
            (int_data[31:16]==c_mpls_type_1 || int_data[31:16]==c_mpls_type_2))  // ether_type == mpls
      bypass_mpls <= 1'b1;
    else if (int_valid &&  int_cnt==10'd5 && bypass_mpls && 
             int_data[24]==1'b0)  // bottom of label stack == 0
      bypass_mpls <= 1'b1;
    else if (int_valid && bypass_mpls)
      bypass_mpls <= 1'b0;

    // bypass ipv4
    if      (int_valid && (int_cnt==10'd4 || (bypass_vlan || bypass_mpls) && int_cnt==10'd5) && bypass_ipv4_cnt==10'd0 &&
            (int_data[31:16]==c_ipv4_type || bypass_mpls) && int_data[15:12]==4'h4)  // ether_type == ipv4, ip_version == 4
      bypass_ipv4 <= 1'b1;
    else if (int_valid && bypass_ipv4_cnt==10'd4)
      bypass_ipv4 <= 1'b0;

    // bypass ipv6
    if      (int_valid && (int_cnt==10'd4 || (bypass_vlan || bypass_mpls) && int_cnt==10'd5) && bypass_ipv6_cnt==10'd0 &&
            (int_data[31:16]==c_ipv6_type || bypass_mpls) && int_data[15:12]==4'h6)  // ether_type == ipv6, ip_version == 6
      bypass_ipv6 <= 1'b1;
    else if (int_valid && bypass_ipv6_cnt==10'd9)
      bypass_ipv6 <= 1'b0;

    // check if it is udp
    if      (int_valid && bypass_ipv4_cnt==10'd1 && int_data[ 7: 0]== 8'h11)  // ipv4_protocol == udp
      found_udp <= 1'b1;
    else if (int_valid && bypass_ipv6_cnt==10'd1 && int_data[31:24]== 8'h11)  // ipv6_protocol == udp
      found_udp <= 1'b1;

    // bypass udp
    if      (int_valid && bypass_ipv4_cnt==10'd4 && bypass_udp_cnt==10'd0 && found_udp)  // ipv4_udp
      bypass_udp <= 1'b1;
    else if (int_valid && bypass_ipv6_cnt==10'd9 && bypass_udp_cnt==10'd0 && found_udp)  // ipv6_udp
      bypass_udp <= 1'b1;
    else if (int_valid && bypass_udp_cnt==10'd2)
      bypass_udp <= 1'b0;

    // check if it is L2 PTP
    if (int_valid && (int_cnt==10'd4 || bypass_vlan && int_cnt==10'd5) && int_data[31:16]==c_ptp2_type)  // ether_type == ptp
      ptp_l2 <= 1'b1;
    // check if it is L4 PTP
    if (int_valid && bypass_udp_cnt==10'd0 && bypass_udp &&
       (int_data[31:16]==c_ptp4_port_1 || int_data[31:16]==c_ptp4_port_2))  // udp_dest_port == ptp_event || ptp_general
      ptp_l4 <= 1'b1;

    // check if it is PTP Event message
    if      (int_valid && (int_cnt==10'd4 || bypass_vlan && int_cnt==10'd5) && int_data[31:16]==c_ptp2_type &&
            (ptp_msgid_mask[int_data[11: 8]]))  // ptp_message_id == ptp_event
      ptp_event <= 1'b1;
    else if (int_valid && int_cnt==10'd5 && bypass_udp_cnt==10'd1 && ptp_l4 &&
            (ptp_msgid_mask[int_data[11: 8]]))  // ptp_message_id == ptp_event 
      ptp_event <= 1'b1;
  end
end

// ptp message
reg [31:0] ptp_data;
reg [ 3:0] ptp_msgid;
reg [15:0] ptp_seqid;
reg [11:0] ptp_cksum;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    ptp_data  <= 32'd0;
    ptp_msgid <= 4'd0;
    ptp_seqid <= 16'd0;
    ptp_cksum <= 12'd0;
  end
  else if (int_valid && int_sop) begin
    ptp_data  <= 32'd0;
    ptp_msgid <= 4'd0;
    ptp_seqid <= 16'd0;
    ptp_cksum <= 12'd0;
  end
  else begin
    // get PTP identification information as additional information to Timestamp
    // ptp message body
    if (int_valid && (ptp_l2 || (bypass_udp_cnt>=10'd2 && ptp_l4)))
      ptp_data <= {int_data_d1[15:0], int_data[31:16]};
    // message id
    if (int_valid && ptp_cnt==10'd1)
      ptp_msgid <= ptp_data[27:24];
    // sequence id
    if (int_valid && ptp_cnt==10'd8)
      ptp_seqid <= ptp_data[15:0];
    // sum up clock id and source port id
    if (int_valid && ptp_cnt==10'd6)
      ptp_cksum <= ptp_data[31:24] + ptp_data[23:16] + ptp_data[15: 8] + ptp_data[ 7: 0] + ptp_cksum;
    if (int_valid && ptp_cnt==10'd7)
      ptp_cksum <= ptp_data[31:24] + ptp_data[23:16] + ptp_data[15: 8] + ptp_data[ 7: 0] + ptp_cksum;
    if (int_valid && ptp_cnt==10'd8)
      ptp_cksum <= ptp_data[31:24] + ptp_data[23:16]                                     + ptp_cksum;
  end
end

// parser output
always @(posedge rst or posedge clk) begin
  if (rst) begin
    ptp_found <=  1'b0;
    ptp_infor <= 32'd0;
  end
  else if (int_valid && int_sop) begin
    ptp_found <=  1'b0;
    ptp_infor <= 32'd0;
  end
  else if (int_valid && ptp_cnt==10'd9) begin
    ptp_found <=  ptp_event;
    ptp_infor <= {ptp_msgid, ptp_cksum, ptp_seqid};  // 4+12+16
  end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/tsu/ptp_queue.v
// -----------------------------------------------------------------------------
/*
 * ptp_queue.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software, you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY, without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library, if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns
`include "define.h"

module ptp_queue (
  input          aclr,
  input	 [127:0] data,
  input	         rdclk,
  input	         rdreq,
  input	         wrclk,
  input	         wrreq,
  output [127:0] q,
  output         rdempty,
  output [  3:0] rdusedw,
  output         wrfull,
  output [  3:0] wrusedw
);

`ifdef USE_ALTERA_IP
dcfifo_128b_16 dcfifo(
  .aclr(aclr),

  .wrclk(wrclk),
  .wrreq(wrreq),
  .data(data),
  .wrfull(wrfull),
  .wrusedw(wrusedw),

  .rdclk(rdclk),
  .rdreq(rdreq),
  .q(q),
  .rdempty(rdempty),
  .rdusedw(rdusedw)
);
`endif

`ifdef USE_XILINX_IP
dcfifo_128b_16 dcfifo(
  .rst(aclr),

  .wr_clk(wrclk),
  .wr_en(wrreq),
  .din(data),
  .full(wrfull),
  .wr_data_count(wrusedw),

  .rd_clk(rdclk),
  .rd_en(rdreq),
  .dout(q),
  .empty(rdempty),
  .rd_data_count(rdusedw)
);
`endif

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/tsu/tsu.v
// -----------------------------------------------------------------------------
/*
 * tsu.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

module tsu (
    input       rst,

    input       gmii_clk,
    input       gmii_ctrl,
    input [7:0] gmii_data,
    input       giga_mode,

    input [7:0] ptp_msgid_mask,
    
    input        rtc_timer_clk,
    input [79:0] rtc_timer_in,  // timeStamp1s_48bit + timeStamp1ns_32bit

    input         q_rst,
    input         q_rd_clk,
    input         q_rd_en,
    output [  7:0] q_rd_stat,
    output [127:0] q_rd_data  // null_16bit + timeStamp1s_48bit + timeStamp1ns_32bit + msgId_4bit + ckSum_12bit + seqId_16bit 
);

// mii to gmii converter
reg nibble_h;
always @(posedge rst or posedge gmii_clk) begin
  if (rst)
    nibble_h <= 1'b0;
  else if (gmii_ctrl)
    nibble_h <= !nibble_h;
end

reg       gmii_ctrl_conv;
reg [7:0] gmii_data_conv;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    gmii_ctrl_conv <= 1'b0;
    gmii_data_conv <= 8'd0;
  end
  else begin
    if (giga_mode) begin
      gmii_ctrl_conv      <= gmii_ctrl;
      gmii_data_conv[7:0] <= gmii_data[7:0];
    end
    else begin
      // 4b-8b datapath gearbox
      if (gmii_ctrl) begin
        gmii_ctrl_conv      <= ( nibble_h)? 1'b1:1'b0;
        gmii_data_conv[7:4] <= ( nibble_h)? gmii_data[3:0]:gmii_data_conv[7:4];
        gmii_data_conv[3:0] <= (!nibble_h)? gmii_data[3:0]:gmii_data_conv[3:0];
      end
      else begin
        gmii_ctrl_conv      <= 1'b0;
        gmii_data_conv[7:4] <= gmii_data_conv[7:4];
        gmii_data_conv[3:0] <= gmii_data_conv[3:0];
      end
    end
  end
end

// buffer gmii input
reg       gmii_ctrl_conv_d1, gmii_ctrl_conv_d2, gmii_ctrl_conv_d3, gmii_ctrl_conv_d4,
          gmii_ctrl_conv_d5, gmii_ctrl_conv_d6, gmii_ctrl_conv_d7, gmii_ctrl_conv_d8,
          gmii_ctrl_conv_d9, gmii_ctrl_conv_da;
reg [7:0] gmii_data_conv_d1, gmii_data_conv_d2, gmii_data_conv_d3, gmii_data_conv_d4,
          gmii_data_conv_d5, gmii_data_conv_d6, gmii_data_conv_d7, gmii_data_conv_d8,
          gmii_data_conv_d9, gmii_data_conv_da;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    gmii_ctrl_conv_d1 <= 1'b0;
    gmii_ctrl_conv_d2 <= 1'b0;
    gmii_ctrl_conv_d3 <= 1'b0;
    gmii_ctrl_conv_d4 <= 1'b0;
    gmii_ctrl_conv_d5 <= 1'b0;
    gmii_ctrl_conv_d6 <= 1'b0;
    gmii_ctrl_conv_d7 <= 1'b0;
    gmii_ctrl_conv_d8 <= 1'b0;
    gmii_ctrl_conv_d9 <= 1'b0;
    gmii_ctrl_conv_da <= 1'b0;
    gmii_data_conv_d1 <= 8'd0;
    gmii_data_conv_d2 <= 8'd0;
    gmii_data_conv_d3 <= 8'd0;
    gmii_data_conv_d4 <= 8'd0;
    gmii_data_conv_d5 <= 8'd0;
    gmii_data_conv_d6 <= 8'd0;
    gmii_data_conv_d7 <= 8'd0;
    gmii_data_conv_d8 <= 8'd0;
    gmii_data_conv_d9 <= 8'd0;
    gmii_data_conv_da <= 8'd0;
  end
  else begin
    gmii_ctrl_conv_d1 <= gmii_ctrl_conv;
    gmii_ctrl_conv_d2 <= gmii_ctrl_conv_d1;
    gmii_ctrl_conv_d3 <= gmii_ctrl_conv_d2;
    gmii_ctrl_conv_d4 <= gmii_ctrl_conv_d3;
    gmii_ctrl_conv_d5 <= gmii_ctrl_conv_d4;
    gmii_ctrl_conv_d6 <= gmii_ctrl_conv_d5;
    gmii_ctrl_conv_d7 <= gmii_ctrl_conv_d6;
    gmii_ctrl_conv_d8 <= gmii_ctrl_conv_d7;
    gmii_ctrl_conv_d9 <= gmii_ctrl_conv_d8;
    gmii_ctrl_conv_da <= gmii_ctrl_conv_d9;
    gmii_data_conv_d1 <= gmii_data_conv;
    gmii_data_conv_d2 <= gmii_data_conv_d1;
    gmii_data_conv_d3 <= gmii_data_conv_d2;
    gmii_data_conv_d4 <= gmii_data_conv_d3;
    gmii_data_conv_d5 <= gmii_data_conv_d4;
    gmii_data_conv_d6 <= gmii_data_conv_d5;
    gmii_data_conv_d7 <= gmii_data_conv_d6;
    gmii_data_conv_d8 <= gmii_data_conv_d7;
    gmii_data_conv_d9 <= gmii_data_conv_d8;
    gmii_data_conv_da <= gmii_data_conv_d9;
  end
end

// choose buffered gmii input
reg       int_gmii_ctrl;
reg       int_gmii_ctrl_d1, int_gmii_ctrl_d2, int_gmii_ctrl_d3, int_gmii_ctrl_d4,
          int_gmii_ctrl_d5;
reg [7:0] int_gmii_data;
reg [7:0] int_gmii_data_d1, int_gmii_data_d2, int_gmii_data_d3, int_gmii_data_d4,
          int_gmii_data_d5;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    int_gmii_ctrl    <= 1'b0;
    int_gmii_data    <= 8'h00;
    int_gmii_ctrl_d1 <= 1'b0;
    int_gmii_data_d1 <= 8'h00;
    int_gmii_ctrl_d2 <= 1'b0;
    int_gmii_data_d2 <= 8'h00;
    int_gmii_ctrl_d3 <= 1'b0;
    int_gmii_data_d3 <= 8'h00;
    int_gmii_ctrl_d4 <= 1'b0;
    int_gmii_data_d4 <= 8'h00;
    int_gmii_ctrl_d5 <= 1'b0;
    int_gmii_data_d5 <= 8'h00;
  end
  else begin
    if (giga_mode) begin
      int_gmii_ctrl    <= gmii_ctrl_conv;
      int_gmii_data    <= gmii_data_conv;
      int_gmii_ctrl_d1 <= gmii_ctrl_conv_d1;
      int_gmii_data_d1 <= gmii_data_conv_d1;
      int_gmii_ctrl_d2 <= gmii_ctrl_conv_d2;
      int_gmii_data_d2 <= gmii_data_conv_d2;
      int_gmii_ctrl_d3 <= gmii_ctrl_conv_d3;
      int_gmii_data_d3 <= gmii_data_conv_d3;
      int_gmii_ctrl_d4 <= gmii_ctrl_conv_d4;
      int_gmii_data_d4 <= gmii_data_conv_d4;
      int_gmii_ctrl_d5 <= gmii_ctrl_conv_d5;
      int_gmii_data_d5 <= gmii_data_conv_d5;
    end
    else begin
      int_gmii_ctrl    <= gmii_ctrl_conv;
      int_gmii_data    <= gmii_data_conv;
      int_gmii_ctrl_d1 <= gmii_ctrl_conv_d2;
      int_gmii_data_d1 <= gmii_data_conv_d2;
      int_gmii_ctrl_d2 <= gmii_ctrl_conv_d4;
      int_gmii_data_d2 <= gmii_data_conv_d4;
      int_gmii_ctrl_d3 <= gmii_ctrl_conv_d6;
      int_gmii_data_d3 <= gmii_data_conv_d6;
      int_gmii_ctrl_d4 <= gmii_ctrl_conv_d8;
      int_gmii_data_d4 <= gmii_data_conv_d8;
      int_gmii_ctrl_d5 <= gmii_ctrl_conv_da;
      int_gmii_data_d5 <= gmii_data_conv_da;
    end
  end
end

// ptp CDC time stamping
wire ts_req = int_gmii_ctrl;  // TODO: check frame start delimiter
reg  ts_req_d1, ts_req_d2, ts_req_d3;
always @(posedge rst or posedge rtc_timer_clk) begin
  if (rst) begin
    ts_req_d1 <= 1'b0;
    ts_req_d2 <= 1'b0;
    ts_req_d3 <= 1'b0;
  end
  else begin
    ts_req_d1 <= ts_req;
    ts_req_d2 <= ts_req_d1;
    ts_req_d3 <= ts_req_d2;
  end
end
reg [79:0] rtc_time_stamp;
always @(posedge rst or posedge rtc_timer_clk) begin
  if (rst)
    rtc_time_stamp <= 80'd0;
  else 
    if (ts_req_d2 & !ts_req_d3)
      rtc_time_stamp <= rtc_timer_in;
end
reg ts_ack, ts_ack_clr;
always @(posedge ts_ack_clr or posedge rtc_timer_clk) begin
  if (ts_ack_clr)
    ts_ack <= 1'b0;
  else
    if (ts_req_d2 & !ts_req_d3)
      ts_ack <= 1'b1;
end

reg ts_ack_d1, ts_ack_d2, ts_ack_d3;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    ts_ack_d1 <= 1'b0;
    ts_ack_d2 <= 1'b0;
    ts_ack_d3 <= 1'b0;
  end
  else begin
    ts_ack_d1 <= ts_ack;
    ts_ack_d2 <= ts_ack_d1;
    ts_ack_d3 <= ts_ack_d2;
  end
end
reg [79:0] tsu_time_stamp;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    tsu_time_stamp <= 80'd0;
    ts_ack_clr      <= 1'b0;
  end
  else begin
    if (ts_ack_d2 & !ts_ack_d3) begin
      tsu_time_stamp <= rtc_time_stamp;
      ts_ack_clr      <= 1'b1;
    end
    else begin
      tsu_time_stamp <= tsu_time_stamp;
      ts_ack_clr      <= 1'b0;
    end
  end
end

// 8b-32b datapath gearbox
reg        int_valid;
reg        int_sop, int_eop;
reg [ 1:0] int_bcnt, int_mod;
reg [31:0] int_data;
always @(posedge rst or posedge gmii_clk) begin
  if (rst)
    int_bcnt <= 2'd0;
  else
    if      ( int_gmii_ctrl & !int_gmii_ctrl_d1)
      int_bcnt <= 2'd0;  // clear on sop
    else if ( int_gmii_ctrl)
      int_bcnt <= int_bcnt + 2'd1;  // increment
    else if (!int_gmii_ctrl & int_gmii_ctrl_d3 & (int_bcnt!=2'd0))
      int_bcnt <= int_bcnt + 2'd1;  // end on eop with mod
end
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    int_data  <= 32'd0;
    int_valid <=  1'b0;
    int_mod   <=  2'd0;
  end
  else begin
    if (int_gmii_ctrl) begin
      int_data[ 7: 0] <= (int_bcnt==2'd3)? int_gmii_data_d1:int_data[ 7: 0];
      int_data[15: 8] <= (int_bcnt==2'd2)? int_gmii_data_d1:int_data[15: 8];
      int_data[23:16] <= (int_bcnt==2'd1)? int_gmii_data_d1:int_data[23:16];
      int_data[31:24] <= (int_bcnt==2'd0)? int_gmii_data_d1:int_data[31:24];
    end

    if (int_gmii_ctrl & int_bcnt==2'd3)
      int_valid <= 1'b1;
    else
      int_valid <= 1'b0;

    if (int_gmii_ctrl_d1 & !int_gmii_ctrl_d2)
      int_mod <= 2'd0;
    else if (!int_gmii_ctrl_d1 & int_gmii_ctrl_d2)
      int_mod <= int_bcnt;

    if (int_gmii_ctrl_d4 & !int_gmii_ctrl_d5 & int_bcnt==2'd3)
      int_sop <= 1'b1;
    else
      int_sop <= 1'b0;

    if (!int_gmii_ctrl   &  int_gmii_ctrl_d3 & int_bcnt==2'd3)
      int_eop <= 1'b1;
    else
      int_eop <= 1'b0;

  end
end

reg [31:0] int_data_d1;
reg        int_valid_d1;
reg        int_sop_d1;
reg        int_eop_d1;
reg [ 1:0] int_mod_d1;
always @(posedge rst or posedge gmii_clk) begin
  if (rst) begin
    int_data_d1  <= 32'h00000000;
    int_valid_d1 <= 1'b0;
    int_sop_d1   <= 1'b0;
    int_eop_d1   <= 1'b0;
    int_mod_d1   <= 2'b00;
  end
  else begin
    if (int_valid) begin
      int_data_d1  <= int_data;
      int_mod_d1   <= int_mod;
    end
      int_valid_d1 <= int_valid;
      int_sop_d1   <= int_sop;
      int_eop_d1   <= int_eop;
  end
end

// ptp packet parser here
// works at 1/4 gmii_clk frequency, needs multicycle timing constraint
wire        ptp_found;
wire [31:0] ptp_infor;
ptp_parser parser(
  .clk(gmii_clk),
  .rst(rst),
  .int_data(int_data_d1),
  .int_valid(int_valid_d1),
  .int_sop(int_sop_d1),
  .int_eop(int_eop_d1),
  .int_mod(int_mod_d1),
  .ptp_msgid_mask(ptp_msgid_mask),
  .ptp_found(ptp_found),
  .ptp_infor(ptp_infor)
);

// ptp time stamp dcfifo
wire q_wr_clk = gmii_clk;
wire q_wr_en = ptp_found && int_eop_d1;
wire [127:0] q_wr_data = {16'd0, tsu_time_stamp, ptp_infor};  // 16+80+32 bit
wire [3:0] q_wrusedw;
wire [3:0] q_rdusedw;
wire q_wr_full;
wire q_rd_empty;

ptp_queue queue(
  .aclr(q_rst),

  .wrclk(q_wr_clk),
  .wrreq(q_wr_en && !q_wr_full),  // write with overflow protection
  .data(q_wr_data),
  .wrfull(q_wr_full),
  .wrusedw(q_wrusedw),

  .rdclk(q_rd_clk),
  .rdreq(q_rd_en && !q_rd_empty),  // read with underflow protection
  .q(q_rd_data),
  .rdempty(q_rd_empty),
  .rdusedw(q_rdusedw)
);

assign q_rd_stat = {4'd0, q_rdusedw};

endmodule
