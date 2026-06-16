// Curated RTL benchmark case.
// case_id: bench_0214_communication_controller_wishbone_sd_card_controller
// source_project: communication_controller_wishbone_sd_card_controller
// top_module: sdc_controller


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sdc_controller.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sdc_controller.v                                             ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Top level entity.                                            ////
//// This core is based on the "sd card controller" project from  ////
//// http://opencores.org/project,sdcard_mass_storage_controller  ////
//// but has been largely rewritten. A lot of effort has been     ////
//// made to make the core more generic and easily usable         ////
//// with OSs like Linux.                                         ////
//// - data transfer commands are not fixed                       ////
//// - data transfer block size is configurable                   ////
//// - multiple block transfer support                            ////
//// - R2 responses (136 bit) support                             ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "sd_defines.h"

module sdc_controller(
           // WISHBONE common
           wb_clk_i, 
           wb_rst_i, 
           // WISHBONE slave
           wb_dat_i, 
           wb_dat_o,
           wb_adr_i, 
           wb_sel_i, 
           wb_we_i, 
           wb_cyc_i, 
           wb_stb_i, 
           wb_ack_o,
           // WISHBONE master
           m_wb_dat_o,
           m_wb_dat_i,
           m_wb_adr_o, 
           m_wb_sel_o, 
           m_wb_we_o,
           m_wb_cyc_o,
           m_wb_stb_o, 
           m_wb_ack_i,
           m_wb_cti_o, 
           m_wb_bte_o,
           //SD BUS
           sd_cmd_dat_i, 
           sd_cmd_out_o, 
           sd_cmd_oe_o, 
           //card_detect,
           sd_dat_dat_i, 
           sd_dat_out_o, 
           sd_dat_oe_o, 
           sd_clk_o_pad,
           sd_clk_i_pad,
           int_cmd, 
           int_data
       );

input wb_clk_i;
input wb_rst_i;
input [31:0] wb_dat_i;
output [31:0] wb_dat_o;
//input card_detect;
input [7:0] wb_adr_i;
input [3:0] wb_sel_i;
input wb_we_i;
input wb_cyc_i;
input wb_stb_i;
output wb_ack_o;
output [31:0] m_wb_adr_o;
output [3:0] m_wb_sel_o;
output m_wb_we_o;
input [31:0] m_wb_dat_i;
output [31:0] m_wb_dat_o;
output m_wb_cyc_o;
output m_wb_stb_o;
input m_wb_ack_i;
output [2:0] m_wb_cti_o;
output [1:0] m_wb_bte_o;
input wire [3:0] sd_dat_dat_i;
output wire [3:0] sd_dat_out_o;
output wire sd_dat_oe_o;
input wire sd_cmd_dat_i;
output wire sd_cmd_out_o;
output wire sd_cmd_oe_o;
output sd_clk_o_pad;
input wire sd_clk_i_pad;
output int_cmd, int_data;

//SD clock
wire sd_clk_o; //Sd_clk used in the system

wire go_idle;
wire cmd_start_wb_clk;
wire cmd_start_sd_clk;
wire cmd_start;
wire [1:0] cmd_setting;
wire cmd_start_tx;
wire [39:0] cmd;
wire [119:0] cmd_response;
wire cmd_crc_ok;
wire cmd_index_ok;
wire cmd_finish;

wire d_write;
wire d_read;
wire [31:0] data_in_rx_fifo;
wire [31:0] data_out_tx_fifo;
wire start_tx_fifo;
wire start_rx_fifo;
wire tx_fifo_empty;
wire tx_fifo_full;
wire rx_fifo_full;
wire sd_data_busy;
wire data_busy;
wire data_crc_ok;
wire rd_fifo;
wire we_fifo;

wire data_start_rx;
wire data_start_tx;
wire cmd_int_rst_wb_clk;
wire cmd_int_rst_sd_clk;
wire cmd_int_rst;
wire data_int_rst_wb_clk;
wire data_int_rst_sd_clk;
wire data_int_rst;

//wb accessible registers
wire [31:0] argument_reg_wb_clk;
wire [`CMD_REG_SIZE-1:0] command_reg_wb_clk;
wire [15:0] timeout_reg_wb_clk;
wire [0:0] software_reset_reg_wb_clk;
wire [31:0] response_0_reg_wb_clk;
wire [31:0] response_1_reg_wb_clk;
wire [31:0] response_2_reg_wb_clk;
wire [31:0] response_3_reg_wb_clk;
wire [`BLKSIZE_W-1:0] block_size_reg_wb_clk;
wire [15:0] controll_setting_reg_wb_clk;
wire [`INT_CMD_SIZE-1:0] cmd_int_status_reg_wb_clk;
wire [`INT_DATA_SIZE-1:0] data_int_status_reg_wb_clk;
wire [`INT_CMD_SIZE-1:0] cmd_int_enable_reg_wb_clk;
wire [`INT_DATA_SIZE-1:0] data_int_enable_reg_wb_clk;
wire [`BLKCNT_W-1:0] block_count_reg_wb_clk;
wire [31:0] dma_addr_reg_wb_clk;
wire [7:0] clock_divider_reg_wb_clk;

wire [31:0] argument_reg_sd_clk;
wire [`CMD_REG_SIZE-1:0] command_reg_sd_clk;
wire [15:0] timeout_reg_sd_clk;
wire [0:0] software_reset_reg_sd_clk;
wire [31:0] response_0_reg_sd_clk;
wire [31:0] response_1_reg_sd_clk;
wire [31:0] response_2_reg_sd_clk;
wire [31:0] response_3_reg_sd_clk;
wire [`BLKSIZE_W-1:0] block_size_reg_sd_clk;
wire [15:0] controll_setting_reg_sd_clk;
wire [`INT_CMD_SIZE-1:0] cmd_int_status_reg_sd_clk;
wire [2:0] data_int_status_reg_sd_clk;
wire [`INT_CMD_SIZE-1:0] cmd_int_enable_reg_sd_clk;
wire [2:0] data_int_enable_reg_sd_clk;
wire [`BLKCNT_W-1:0] block_count_reg_sd_clk;
wire [31:0] dma_addr_reg_sd_clk;
wire [7:0] clock_divider_reg_sd_clk;

sd_clock_divider clock_divider0(
                     .CLK (sd_clk_i_pad),
                     .DIVIDER (clock_divider_reg_sd_clk),
                     .RST  (wb_rst_i),
                     .SD_CLK  (sd_clk_o)
                 );

assign sd_clk_o_pad  = sd_clk_o ;

sd_cmd_master sd_cmd_master0(
           .sd_clk       (sd_clk_o),
           .rst          (wb_rst_i | software_reset_reg_sd_clk[0]),
           .start_i      (cmd_start_sd_clk),
           .int_status_rst_i(cmd_int_rst_sd_clk),
           .setting_o    (cmd_setting),
           .start_xfr_o  (cmd_start_tx),
           .go_idle_o    (go_idle),
           .cmd_o        (cmd),
           .response_i   (cmd_response),
           .crc_ok_i     (cmd_crc_ok),
           .index_ok_i   (cmd_index_ok),
           .busy_i       (sd_data_busy),
           .finish_i     (cmd_finish),
           //input card_detect,
           .argument_i   (argument_reg_sd_clk),
           .command_i    (command_reg_sd_clk),
           .timeout_i    (timeout_reg_sd_clk),
           .int_status_o (cmd_int_status_reg_sd_clk),
           .response_0_o (response_0_reg_sd_clk),
           .response_1_o (response_1_reg_sd_clk),
           .response_2_o (response_2_reg_sd_clk),
           .response_3_o (response_3_reg_sd_clk)
       );
       
sd_cmd_serial_host cmd_serial_host0(
                       .sd_clk     (sd_clk_o),
                       .rst        (wb_rst_i | software_reset_reg_sd_clk[0] | go_idle),
                       .setting_i  (cmd_setting),
                       .cmd_i      (cmd),
                       .start_i    (cmd_start_tx),
                       .finish_o   (cmd_finish),
                       .response_o (cmd_response),
                       .crc_ok_o   (cmd_crc_ok),
                       .index_ok_o (cmd_index_ok),
                       .cmd_dat_i  (sd_cmd_dat_i),
                       .cmd_out_o  (sd_cmd_out_o),
                       .cmd_oe_o   (sd_cmd_oe_o)
                   );
                   
sd_data_master sd_data_master0(
           .sd_clk           (sd_clk_o),
           .rst              (wb_rst_i | software_reset_reg_sd_clk[0]),
           .start_tx_i       (data_start_tx),
           .start_rx_i       (data_start_rx),
           .d_write_o        (d_write),
           .d_read_o         (d_read),
           .start_tx_fifo_o  (start_tx_fifo),
           .start_rx_fifo_o  (start_rx_fifo),
           .tx_fifo_empty_i  (tx_fifo_empty),
           .tx_fifo_full_i   (tx_fifo_full),
           .rx_fifo_full_i   (rx_fifo_full),
           .xfr_complete_i   (!data_busy),
           .crc_ok_i         (data_crc_ok),
           .int_status_o     (data_int_status_reg_sd_clk),
           .int_status_rst_i (data_int_rst_sd_clk)
       );

sd_data_serial_host sd_data_serial_host0(
                        .sd_clk         (sd_clk_o),
                        .rst            (wb_rst_i | software_reset_reg_sd_clk[0]),
                        .data_in        (data_out_tx_fifo),
                        .rd             (rd_fifo),
                        .data_out       (data_in_rx_fifo),
                        .we             (we_fifo),
                        .DAT_oe_o       (sd_dat_oe_o),
                        .DAT_dat_o      (sd_dat_out_o),
                        .DAT_dat_i      (sd_dat_dat_i),
                        .blksize        (block_size_reg_sd_clk),
                        .bus_4bit       (controll_setting_reg_sd_clk[0]),
                        .blkcnt         (block_count_reg_sd_clk),
                        .start          ({d_read, d_write}),
                        .sd_data_busy   (sd_data_busy),
                        .busy           (data_busy),
                        .crc_ok         (data_crc_ok)
                    );
       
sd_fifo_filler sd_fifo_filler0(
            .wb_clk    (wb_clk_i),
            .rst       (wb_rst_i | software_reset_reg_sd_clk[0]),
            .wbm_adr_o (m_wb_adr_o),
            .wbm_we_o  (m_wb_we_o),
            .wbm_dat_o (m_wb_dat_o),
            .wbm_dat_i (m_wb_dat_i),
            .wbm_cyc_o (m_wb_cyc_o),
            .wbm_stb_o (m_wb_stb_o),
            .wbm_ack_i (m_wb_ack_i),
            .en_rx_i   (start_rx_fifo),
            .en_tx_i   (start_tx_fifo),
            .adr_i     (dma_addr_reg_sd_clk),
            .sd_clk    (sd_clk_o),
            .dat_i     (data_in_rx_fifo),
            .dat_o     (data_out_tx_fifo),
            .wr_i      (we_fifo),
            .rd_i      (rd_fifo),
            .sd_empty_o   (tx_fifo_empty),
            .sd_full_o   (rx_fifo_full),
            .wb_empty_o   (),
            .wb_full_o    (tx_fifo_full)
        );
        
sd_data_xfer_trig sd_data_xfer_trig0 (
           .sd_clk                (sd_clk_o),
           .rst                   (wb_rst_i | software_reset_reg_sd_clk[0]),
           .cmd_with_data_start_i (cmd_start_sd_clk & (command_reg_sd_clk[`CMD_WITH_DATA] != 2'b00)),
           .r_w_i                 (command_reg_sd_clk[`CMD_WITH_DATA] == 2'b01),
           .cmd_int_status_i      (cmd_int_status_reg_sd_clk),
           .start_tx_o            (data_start_tx),
           .start_rx_o            (data_start_rx)
       );

sd_controller_wb sd_controller_wb0(
                     .wb_clk_i                       (wb_clk_i),
                     .wb_rst_i                       (wb_rst_i),
                     .wb_dat_i                       (wb_dat_i),
                     .wb_dat_o                       (wb_dat_o),
                     .wb_adr_i                       (wb_adr_i),
                     .wb_sel_i                       (wb_sel_i),
                     .wb_we_i                        (wb_we_i),
                     .wb_stb_i                       (wb_stb_i),
                     .wb_cyc_i                       (wb_cyc_i),
                     .wb_ack_o                       (wb_ack_o),
                     .cmd_start                      (cmd_start),
                     .data_int_rst                   (data_int_rst),
                     .cmd_int_rst                    (cmd_int_rst),
                     .argument_reg                   (argument_reg_wb_clk),
                     .command_reg                    (command_reg_wb_clk),
                     .response_0_reg                 (response_0_reg_wb_clk),
                     .response_1_reg                 (response_1_reg_wb_clk),
                     .response_2_reg                 (response_2_reg_wb_clk),
                     .response_3_reg                 (response_3_reg_wb_clk),
                     .software_reset_reg             (software_reset_reg_wb_clk),
                     .timeout_reg                    (timeout_reg_wb_clk),
                     .block_size_reg                 (block_size_reg_wb_clk),
                     .controll_setting_reg           (controll_setting_reg_wb_clk),
                     .cmd_int_status_reg             (cmd_int_status_reg_wb_clk),
                     .cmd_int_enable_reg             (cmd_int_enable_reg_wb_clk),
                     .clock_divider_reg              (clock_divider_reg_wb_clk),
                     .block_count_reg                (block_count_reg_wb_clk),
                     .dma_addr_reg                   (dma_addr_reg_wb_clk),
                     .data_int_status_reg            (data_int_status_reg_wb_clk),
                     .data_int_enable_reg            (data_int_enable_reg_wb_clk)
                 );

//clock domain crossing regiters
//assign cmd_start_sd_clk = cmd_start_wb_clk;
//assign data_int_rst_sd_clk = data_int_rst_wb_clk;
//assign cmd_int_rst_sd_clk = cmd_int_rst_wb_clk;
//assign argument_reg_sd_clk = argument_reg_wb_clk;
//assign command_reg_sd_clk = command_reg_wb_clk;
//assign response_0_reg_wb_clk = response_0_reg_sd_clk;
//assign response_1_reg_wb_clk = response_1_reg_sd_clk;
//assign response_2_reg_wb_clk = response_2_reg_sd_clk;
//assign response_3_reg_wb_clk = response_3_reg_sd_clk;
//assign software_reset_reg_sd_clk = software_reset_reg_wb_clk;
//assign timeout_reg_sd_clk = timeout_reg_wb_clk;
//assign block_size_reg_sd_clk = block_size_reg_wb_clk;
//assign controll_setting_reg_sd_clk = controll_setting_reg_wb_clk;
//assign cmd_int_status_reg_wb_clk = cmd_int_status_reg_sd_clk;
//assign cmd_int_enable_reg_sd_clk = cmd_int_enable_reg_wb_clk;
//assign clock_divider_reg_sd_clk = clock_divider_reg_wb_clk;
//assign block_count_reg_sd_clk = block_count_reg_wb_clk;
//assign dma_addr_reg_sd_clk = dma_addr_reg_wb_clk;
//assign data_int_status_reg_wb_clk = data_int_status_reg_sd_clk;
//assign data_int_enable_reg_sd_clk = data_int_enable_reg_wb_clk;

edge_detect cmd_start_edge(.rst(wb_rst_i), .clk(wb_clk_i), .sig(cmd_start), .rise(cmd_start_wb_clk), .fall());
edge_detect data_int_rst_edge(.rst(wb_rst_i), .clk(wb_clk_i), .sig(data_int_rst), .rise(data_int_rst_wb_clk), .fall());
edge_detect cmd_int_rst_edge(.rst(wb_rst_i), .clk(wb_clk_i), .sig(cmd_int_rst), .rise(cmd_int_rst_wb_clk), .fall());
monostable_domain_cross cmd_start_cross(wb_rst_i, wb_clk_i, cmd_start_wb_clk, sd_clk_o, cmd_start_sd_clk);
monostable_domain_cross data_int_rst_cross(wb_rst_i, wb_clk_i, data_int_rst_wb_clk, sd_clk_o, data_int_rst_sd_clk);
monostable_domain_cross cmd_int_rst_cross(wb_rst_i, wb_clk_i, cmd_int_rst_wb_clk, sd_clk_o, cmd_int_rst_sd_clk);
bistable_domain_cross #(32) argument_reg_cross(wb_rst_i, wb_clk_i, argument_reg_wb_clk, sd_clk_o, argument_reg_sd_clk);
bistable_domain_cross #(`CMD_REG_SIZE) command_reg_cross(wb_rst_i, wb_clk_i, command_reg_wb_clk, sd_clk_o, command_reg_sd_clk);
bistable_domain_cross #(32) response_0_reg_cross(wb_rst_i, sd_clk_o, response_0_reg_sd_clk, wb_clk_i, response_0_reg_wb_clk);
bistable_domain_cross #(32) response_1_reg_cross(wb_rst_i, sd_clk_o, response_1_reg_sd_clk, wb_clk_i, response_1_reg_wb_clk);
bistable_domain_cross #(32) response_2_reg_cross(wb_rst_i, sd_clk_o, response_2_reg_sd_clk, wb_clk_i, response_2_reg_wb_clk);
bistable_domain_cross #(32) response_3_reg_cross(wb_rst_i, sd_clk_o, response_3_reg_sd_clk, wb_clk_i, response_3_reg_wb_clk);
bistable_domain_cross software_reset_reg_cross(wb_rst_i, wb_clk_i, software_reset_reg_wb_clk, sd_clk_o, software_reset_reg_sd_clk);
bistable_domain_cross #(16) timeout_reg_cross(wb_rst_i, wb_clk_i, timeout_reg_wb_clk, sd_clk_o, timeout_reg_sd_clk);
bistable_domain_cross #(`BLKSIZE_W) block_size_reg_cross(wb_rst_i, wb_clk_i, block_size_reg_wb_clk, sd_clk_o, block_size_reg_sd_clk);
bistable_domain_cross #(16) controll_setting_reg_cross(wb_rst_i, wb_clk_i, controll_setting_reg_wb_clk, sd_clk_o, controll_setting_reg_sd_clk);
bistable_domain_cross #(`INT_CMD_SIZE) cmd_int_status_reg_cross(wb_rst_i, sd_clk_o, cmd_int_status_reg_sd_clk, wb_clk_i, cmd_int_status_reg_wb_clk);
bistable_domain_cross #(`INT_CMD_SIZE) cmd_int_enable_reg_cross(wb_rst_i, wb_clk_i, cmd_int_enable_reg_wb_clk, sd_clk_o, cmd_int_enable_reg_sd_clk);
bistable_domain_cross #(8) clock_divider_reg_cross(wb_rst_i, wb_clk_i, clock_divider_reg_wb_clk, sd_clk_i_pad, clock_divider_reg_sd_clk);
bistable_domain_cross #(`BLKCNT_W) block_count_reg_cross(wb_rst_i, wb_clk_i, block_count_reg_wb_clk, sd_clk_o, block_count_reg_sd_clk);
bistable_domain_cross #(32) dma_addr_reg_cross(wb_rst_i, wb_clk_i, dma_addr_reg_wb_clk, sd_clk_o, dma_addr_reg_sd_clk);
bistable_domain_cross #(`INT_DATA_SIZE) data_int_status_reg_cross(wb_rst_i, sd_clk_o, data_int_status_reg_sd_clk, wb_clk_i, data_int_status_reg_wb_clk);
bistable_domain_cross #(`INT_DATA_SIZE) data_int_enable_reg_cross(wb_rst_i, wb_clk_i, data_int_enable_reg_wb_clk, sd_clk_o, data_int_enable_reg_sd_clk);

assign m_wb_cti_o = 3'b000;
assign m_wb_bte_o = 2'b00;

assign int_cmd =  |(cmd_int_status_reg_wb_clk & cmd_int_enable_reg_wb_clk);
assign int_data =  |(data_int_status_reg_wb_clk & data_int_enable_reg_wb_clk);

assign m_wb_sel_o = 4'b1111;

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/bistable_domain_cross.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// bistable_domain_cross.v                                      ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Clock synchronisation beetween two clock domains.            ////
//// Assumption is that input signal duration has to be at least  ////
//// one clk_b clock period.                                      //// 
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module bistable_domain_cross(
    rst,
    clk_a,
    in,
    clk_b,
    out
);
parameter width = 1;
input rst;
input clk_a;
input [width-1:0] in;
input clk_b;
output [width-1:0] out;

// We use a two-stages shift-register to synchronize in to the clk_b clock domain
reg [width-1:0] sync_clk_b [1:0];
always @(posedge clk_b or posedge rst)
begin
    if (rst == 1) begin
        sync_clk_b[0] <= 0;
        sync_clk_b[1] <= 0;
    end else begin
        sync_clk_b[0] <= in;
        sync_clk_b[1] <= sync_clk_b[0];
    end
end

assign out = sync_clk_b[1];  // new signal synchronized to (=ready to be used in) clk_b domain

endmodule 

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/edge_detect.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// edge_detect.v                                                ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Signal edge detection. If input signal transitions between   ////
//// two states, output signal is generated for one clock cycle.  ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module edge_detect (
    input rst,
    input clk, 
    input sig,
    output rise,
    output fall
);

reg [1:0] sig_reg;

always @(posedge clk or posedge rst)
    if (rst == 1'b1)
        sig_reg <= 2'b00;
    else
        sig_reg <= {sig_reg[0], sig};

assign rise = sig_reg[0] == 1'b1 && sig_reg[1] == 1'b0 ? 1'b1 : 1'b0;
assign fall = sig_reg[0] == 1'b0 && sig_reg[1] == 1'b1 ? 1'b1 : 1'b0;

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/generic_dpram.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Generic Dual-Port Synchronous RAM                           ////
////                                                              ////
////  This file is part of memory library available from          ////
////  http://www.opencores.org/cvsweb.shtml/generic_memories/     ////
////                                                              ////
////  Description                                                 ////
////  This block is a wrapper with common dual-port               ////
////  synchronous memory interface for different                  ////
////  types of ASIC and FPGA RAMs. Beside universal memory        ////
////  interface it also provides behavioral model of generic      ////
////  dual-port synchronous RAM.                                  ////
////  It also contains a fully synthesizeable model for FPGAs.    ////
////  It should be used in all OPENCORES designs that want to be  ////
////  portable accross different target technologies and          ////
////  independent of target memory.                               ////
////                                                              ////
////  Supported ASIC RAMs are:                                    ////
////  - Artisan Dual-Port Sync RAM                                ////
////  - Avant! Two-Port Sync RAM (*)                              ////
////  - Virage 2-port Sync RAM                                    ////
////                                                              ////
////  Supported FPGA RAMs are:                                    ////
////  - Generic FPGA (VENDOR_FPGA)                                ////
////    Tested RAMs: Altera, Xilinx                               ////
////    Synthesis tools: LeonardoSpectrum, Synplicity             ////
////  - Xilinx (VENDOR_XILINX)                                    ////
////  - Altera (VENDOR_ALTERA)                                    ////
////                                                              ////
////  To Do:                                                      ////
////   - fix Avant!                                               ////
////   - add additional RAMs (VS etc)                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - Richard Herveille, richard@asics.ws                   ////
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
// Revision 1.3  2001/11/09 00:34:18  samg
// minor changes: unified with all common rams
//
// Revision 1.2  2001/11/08 19:11:31  samg
// added valid checks to behvioral model
//
// Revision 1.1.1.1  2001/09/14 09:57:10  rherveille
// Major cleanup.
// Files are now compliant to Altera & Xilinx memories.
// Memories are now compatible, i.e. drop-in replacements.
// Added synthesizeable generic FPGA description.
// Created "generic_memories" cvs entry.
//
// Revision 1.1.1.2  2001/08/21 13:09:27  damjan
// *** empty log message ***
//
// Revision 1.1  2001/08/20 18:23:20  damjan
// Initial revision
//
// Revision 1.1  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/30 05:38:02  lampret
// Adding empty directories required by HDL coding guidelines
//
//

//`include "timescale.v"

`define VENDOR_FPGA
//`define VENDOR_XILINX
//`define VENDOR_ALTERA

module generic_dpram(
	// Generic synchronous dual-port RAM interface
	rclk, rrst, rce, oe, raddr, do,
	wclk, wrst, wce, we, waddr, di
);

	//
	// Default address and data buses width
	//
	parameter aw = 5;  // number of bits in address-bus
	parameter dw = 16; // number of bits in data-bus

	//
	// Generic synchronous double-port RAM interface
	//
	// read port
	input           rclk;  // read clock, rising edge trigger
	input           rrst;  // read port reset, active high
	input           rce;   // read port chip enable, active high
	input           oe;	   // output enable, active high
	input  [aw-1:0] raddr; // read address
	output [dw-1:0] do;    // data output

	// write port
	input          wclk;  // write clock, rising edge trigger
	input          wrst;  // write port reset, active high
	input          wce;   // write port chip enable, active high
	input          we;    // write enable, active high
	input [aw-1:0] waddr; // write address
	input [dw-1:0] di;    // data input

	//
	// Module body
	//

`ifdef VENDOR_FPGA
	//
	// Instantiation synthesizeable FPGA memory
	//
	// This code has been tested using LeonardoSpectrum and Synplicity.
	// The code correctly instantiates Altera EABs and Xilinx BlockRAMs.
	//
	reg [dw-1:0] mem [(1<<aw) -1:0]; // instantiate memory
	reg [aw-1:0] ra;                 // register read address

	// read operation
	always @(posedge rclk)
	  if (rce)
	    ra <= raddr;

	assign do = mem[ra];

	// write operation
	always@(posedge wclk)
		if (we && wce)
			mem[waddr] <= di;

`else

`ifdef VENDOR_XILINX
	//
	// Instantiation of FPGA memory:
	//
	// Virtex/Spartan2 BlockRAMs
	//
	xilinx_ram_dp xilinx_ram(
		// read port
		.CLKA(rclk),
		.RSTA(rrst),
		.ENA(rce),
		.ADDRA(raddr),
		.DIA( {dw{1'b0}} ),
		.WEA(1'b0),
		.DOA(do),

		// write port
		.CLKB(wclk),
		.RSTB(wrst),
		.ENB(wce),
		.ADDRB(waddr),
		.DIB(di),
		.WEB(we),
		.DOB()
	);

	defparam
		xilinx_ram.dwidth = dw,
		xilinx_ram.awidth = aw;

`else

`ifdef VENDOR_ALTERA
	//
	// Instantiation of FPGA memory:
	//
	// Altera FLEX/APEX EABs
	//
	altera_ram_dp altera_ram(
		// read port
		.rdclock(rclk),
		.rdclocken(rce),
		.rdaddress(raddr),
		.q(do),

		// write port
		.wrclock(wclk),
		.wrclocken(wce),
		.wren(we),
		.wraddress(waddr),
		.data(di)
	);

	defparam
		altera_ram.dwidth = dw,
		altera_ram.awidth = aw;

`else

`ifdef VENDOR_ARTISAN

	//
	// Instantiation of ASIC memory:
	//
	// Artisan Synchronous Double-Port RAM (ra2sh)
	//
	art_hsdp #(dw, 1<<aw, aw) artisan_sdp(
		// read port
		.qa(do),
		.clka(rclk),
		.cena(~rce),
		.wena(1'b1),
		.aa(raddr),
		.da( {dw{1'b0}} ),
		.oena(~oe),

		// write port
		.qb(),
		.clkb(wclk),
		.cenb(~wce),
		.wenb(~we),
		.ab(waddr),
		.db(di),
		.oenb(1'b1)
	);

`else

`ifdef VENDOR_AVANT

	//
	// Instantiation of ASIC memory:
	//
	// Avant! Asynchronous Two-Port RAM
	//
	avant_atp avant_atp(
		.web(~we),
		.reb(),
		.oeb(~oe),
		.rcsb(),
		.wcsb(),
		.ra(raddr),
		.wa(waddr),
		.di(di),
		.do(do)
	);

`else

`ifdef VENDOR_VIRAGE

	//
	// Instantiation of ASIC memory:
	//
	// Virage Synchronous 2-port R/W RAM
	//
	virage_stp virage_stp(
		// read port
		.CLKA(rclk),
		.MEA(rce_a),
		.ADRA(raddr),
		.DA( {dw{1'b0}} ),
		.WEA(1'b0),
		.OEA(oe),
		.QA(do),

		// write port
		.CLKB(wclk),
		.MEB(wce),
		.ADRB(waddr),
		.DB(di),
		.WEB(we),
		.OEB(1'b1),
		.QB()
	);

`else

	//
	// Generic dual-port synchronous RAM model
	//

	//
	// Generic RAM's registers and wires
	//
	reg	[dw-1:0]	mem [(1<<aw)-1:0]; // RAM content
	reg	[dw-1:0]	do_reg;            // RAM data output register

	//
	// Data output drivers
	//
	assign do = (oe & rce) ? do_reg : {dw{1'bz}};

	// read operation
	always @(posedge rclk)
		if (rce)
          		do_reg <= (we && (waddr==raddr)) ? {dw{1'b x}} : mem[raddr];

	// write operation
	always @(posedge wclk)
		if (wce && we)
			mem[waddr] <= di;


	// Task prints range of memory
	// *** Remember that tasks are non reentrant, don't call this task in parallel for multiple instantiations.
	task print_ram;
	input [aw-1:0] start;
	input [aw-1:0] finish;
	integer rnum;
  	begin
    		for (rnum=start;rnum<=finish;rnum=rnum+1)
      			$display("Addr %h = %h",rnum,mem[rnum]);
  	end
	endtask

`endif // !VENDOR_VIRAGE
`endif // !VENDOR_AVANT
`endif // !VENDOR_ARTISAN
`endif // !VENDOR_ALTERA
`endif // !VENDOR_XILINX
`endif // !VENDOR_FPGA

endmodule

//
// Black-box modules
//

`ifdef VENDOR_ALTERA
	module altera_ram_dp(
		data,
		wraddress,
		rdaddress,
		wren,
		wrclock,
		wrclocken,
		rdclock,
		rdclocken,
		q) /* synthesis black_box */;

		parameter awidth = 7;
		parameter dwidth = 8;

		input [dwidth -1:0] data;
		input [awidth -1:0] wraddress;
		input [awidth -1:0] rdaddress;
		input               wren;
		input               wrclock;
		input               wrclocken;
		input               rdclock;
		input               rdclocken;
		output [dwidth -1:0] q;

		// synopsis translate_off
		// exemplar translate_off

		syn_dpram_rowr #(
			"UNUSED",
			dwidth,
			awidth,
			1 << awidth
		)
		altera_dpram_model (
			// read port
			.RdClock(rdclock),
			.RdClken(rdclocken),
			.RdAddress(rdaddress),
			.RdEn(1'b1),
			.Q(q),

			// write port
			.WrClock(wrclock),
			.WrClken(wrclocken),
			.WrAddress(wraddress),
			.WrEn(wren),
			.Data(data)
		);

		// exemplar translate_on
		// synopsis translate_on

	endmodule
`endif // VENDOR_ALTERA

`ifdef VENDOR_XILINX
	module xilinx_ram_dp (
		ADDRA,
		CLKA,
		ADDRB,
		CLKB,
		DIA,
		WEA,
		DIB,
		WEB,
		ENA,
		ENB,
		RSTA,
		RSTB,
		DOA,
		DOB) /* synthesis black_box */ ;

	parameter awidth = 7;
	parameter dwidth = 8;

	// port_a
	input               CLKA;
	input               RSTA;
	input               ENA;
	input [awidth-1:0]  ADDRA;
	input [dwidth-1:0]  DIA;
	input               WEA;
	output [dwidth-1:0] DOA;

	// port_b
	input               CLKB;
	input               RSTB;
	input               ENB;
	input [awidth-1:0]  ADDRB;
	input [dwidth-1:0]  DIB;
	input               WEB;
	output [dwidth-1:0] DOB;

	// insert simulation model


	// synopsys translate_off
	// exemplar translate_off

	C_MEM_DP_BLOCK_V1_0 #(
		awidth,
		awidth,
		1,
		1,
		"0",
		1 << awidth,
		1 << awidth,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		"",
		16,
		0,
		0,
		1,
		1,
		1,
		1,
		dwidth,
		dwidth)
	xilinx_dpram_model (
		.ADDRA(ADDRA),
		.CLKA(CLKA),
		.ADDRB(ADDRB),
		.CLKB(CLKB),
		.DIA(DIA),
		.WEA(WEA),
		.DIB(DIB),
		.WEB(WEB),
		.ENA(ENA),
		.ENB(ENB),
		.RSTA(RSTA),
		.RSTB(RSTB),
		.DOA(DOA),
		.DOB(DOB));

		// exemplar translate_on
		// synopsys translate_on

	endmodule
`endif // VENDOR_XILINX

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/generic_fifo_dc_gray.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Universal FIFO Dual Clock, gray encoded                    ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  D/L from: http://www.opencores.org/cores/generic_fifos/    ////
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



//  CVS Log
//
//  $Id: generic_fifo_dc_gray.v,v 1.2 2004-01-13 09:11:55 rudi Exp $
//
//  $Date: 2004-01-13 09:11:55 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1  2003/10/14 09:34:41  rudi
//               Dual clock FIFO Gray Code encoded version.
//
//
//
//
//


//`include "timescale.v"

/*

Description
===========

I/Os
----
rd_clk	Read Port Clock
wr_clk	Write Port Clock
rst	low active, either sync. or async. master reset (see below how to select)
clr	synchronous clear (just like reset but always synchronous), high active
re	read enable, synchronous, high active
we	read enable, synchronous, high active
din	Data Input
dout	Data Output

full	Indicates the FIFO is full (driven at the rising edge of wr_clk)
empty	Indicates the FIFO is empty (driven at the rising edge of rd_clk)

wr_level	indicates the FIFO level:
		2'b00	0-25%	 full
		2'b01	25-50%	 full
		2'b10	50-75%	 full
		2'b11	%75-100% full

rd_level	indicates the FIFO level:
		2'b00	0-25%	 empty
		2'b01	25-50%	 empty
		2'b10	50-75%	 empty
		2'b11	%75-100% empty

Status Timing
-------------
All status outputs are registered. They are asserted immediately
as the full/empty condition occurs, however, there is a 2 cycle
delay before they are de-asserted once the condition is not true
anymore.

Parameters
----------
The FIFO takes 2 parameters:
dw	Data bus width
aw	Address bus width (Determines the FIFO size by evaluating 2^aw)

Synthesis Results
-----------------
In a Spartan 2e a 8 bit wide, 8 entries deep FIFO, takes 97 LUTs and runs
at about 113 MHz (IO insertion disabled). 

Misc
----
This design assumes you will do appropriate status checking externally.

IMPORTANT ! writing while the FIFO is full or reading while the FIFO is
empty will place the FIFO in an undefined state.

*/


module generic_fifo_dc_gray(	rd_clk, wr_clk, rst, clr, din, we,
		dout, re, full, empty, wr_level, rd_level );

parameter dw=16;
parameter aw=8;

input			rd_clk, wr_clk, rst, clr;
input	[dw-1:0]	din;
input			we;
output	[dw-1:0]	dout;
input			re;
output			full; 
output			empty;
output	[1:0]		wr_level;
output	[1:0]		rd_level;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[aw:0]		wp_bin, wp_gray;
reg	[aw:0]		rp_bin, rp_gray;
reg	[aw:0]		wp_s, rp_s;
reg			full, empty;

wire	[aw:0]		wp_bin_next, wp_gray_next;
wire	[aw:0]		rp_bin_next, rp_gray_next;

wire	[aw:0]		wp_bin_x, rp_bin_x;
reg	[aw-1:0]	d1, d2;

reg			rd_rst, wr_rst;
reg			rd_rst_r, wr_rst_r;
reg			rd_clr, wr_clr;
reg			rd_clr_r, wr_clr_r;

////////////////////////////////////////////////////////////////////
//
// Reset Logic
//

always @(posedge rd_clk or negedge rst)
	if(!rst)	rd_rst <= 1'b0;
	else
	if(rd_rst_r)	rd_rst <= 1'b1;		// Release Reset

always @(posedge rd_clk or negedge rst)
	if(!rst)	rd_rst_r <= 1'b0;
	else		rd_rst_r <= 1'b1;

always @(posedge wr_clk or negedge rst)
	if(!rst)	wr_rst <= 1'b0;
	else
	if(wr_rst_r)	wr_rst <= 1'b1;		// Release Reset

always @(posedge wr_clk or negedge rst)
	if(!rst)	wr_rst_r <= 1'b0;
	else		wr_rst_r <= 1'b1;

always @(posedge rd_clk or posedge clr)
	if(clr)		rd_clr <= 1'b1;
	else
	if(!rd_clr_r)	rd_clr <= 1'b0;		// Release Clear

always @(posedge rd_clk or posedge clr)
	if(clr)		rd_clr_r <= 1'b1;
	else		rd_clr_r <= 1'b0;

always @(posedge wr_clk or posedge clr)
	if(clr)		wr_clr <= 1'b1;
	else
	if(!wr_clr_r)	wr_clr <= 1'b0;		// Release Clear

always @(posedge wr_clk or posedge clr)
	if(clr)		wr_clr_r <= 1'b1;
	else		wr_clr_r <= 1'b0;

////////////////////////////////////////////////////////////////////
//
// Memory Block
//

generic_dpram  #(aw,dw) u0(
	.rclk(		rd_clk		),
	.rrst(		!rd_rst		),
	.rce(		1'b1		),
	.oe(		1'b1		),
	.raddr(		rp_bin[aw-1:0]	),
	.do(		dout		),
	.wclk(		wr_clk		),
	.wrst(		!wr_rst		),
	.wce(		1'b1		),
	.we(		we		),
	.waddr(		wp_bin[aw-1:0]	),
	.di(		din		)
	);

////////////////////////////////////////////////////////////////////
//
// Read/Write Pointers Logic
//

always @(posedge wr_clk)
	if(!wr_rst)	wp_bin <= {aw+1{1'b0}};
	else
	if(wr_clr)	wp_bin <= {aw+1{1'b0}};
	else
	if(we)		wp_bin <= wp_bin_next;

always @(posedge wr_clk)
	if(!wr_rst)	wp_gray <= {aw+1{1'b0}};
	else
	if(wr_clr)	wp_gray <= {aw+1{1'b0}};
	else
	if(we)		wp_gray <= wp_gray_next;

assign wp_bin_next  = wp_bin + {{aw{1'b0}},1'b1};
assign wp_gray_next = wp_bin_next ^ {1'b0, wp_bin_next[aw:1]};

always @(posedge rd_clk)
	if(!rd_rst)	rp_bin <= {aw+1{1'b0}};
	else
	if(rd_clr)	rp_bin <= {aw+1{1'b0}};
	else
	if(re)		rp_bin <= rp_bin_next;

always @(posedge rd_clk)
	if(!rd_rst)	rp_gray <= {aw+1{1'b0}};
	else
	if(rd_clr)	rp_gray <= {aw+1{1'b0}};
	else
	if(re)		rp_gray <= rp_gray_next;

assign rp_bin_next  = rp_bin + {{aw{1'b0}},1'b1};
assign rp_gray_next = rp_bin_next ^ {1'b0, rp_bin_next[aw:1]};

////////////////////////////////////////////////////////////////////
//
// Synchronization Logic
//

// write pointer
always @(posedge rd_clk)	wp_s <= wp_gray;

// read pointer
always @(posedge wr_clk)	rp_s <= rp_gray;

////////////////////////////////////////////////////////////////////
//
// Registered Full & Empty Flags
//

assign wp_bin_x = wp_s ^ {1'b0, wp_bin_x[aw:1]};	// convert gray to binary
assign rp_bin_x = rp_s ^ {1'b0, rp_bin_x[aw:1]};	// convert gray to binary

always @(posedge rd_clk)
        empty <= (wp_s == rp_gray) | (re & (wp_s == rp_gray_next));

always @(posedge wr_clk)
        full <= ((wp_bin[aw-1:0] == rp_bin_x[aw-1:0]) & (wp_bin[aw] != rp_bin_x[aw])) |
        (we & (wp_bin_next[aw-1:0] == rp_bin_x[aw-1:0]) & (wp_bin_next[aw] != rp_bin_x[aw]));

////////////////////////////////////////////////////////////////////
//
// Registered Level Indicators
//
reg	[1:0]		wr_level;
reg	[1:0]		rd_level;
reg	[aw-1:0]	wp_bin_xr, rp_bin_xr;
reg			full_rc;
reg			full_wc;

always @(posedge wr_clk)	full_wc <= full;
always @(posedge wr_clk)	rp_bin_xr <=  ~rp_bin_x[aw-1:0] + {{aw-1{1'b0}}, 1'b1};
always @(posedge wr_clk)	d1 <= wp_bin[aw-1:0] + rp_bin_xr[aw-1:0];

always @(posedge wr_clk)	wr_level <= {d1[aw-1] | full | full_wc, d1[aw-2] | full | full_wc};

always @(posedge rd_clk)	wp_bin_xr <=  ~wp_bin_x[aw-1:0];
always @(posedge rd_clk)	d2 <= rp_bin[aw-1:0] + wp_bin_xr[aw-1:0];

always @(posedge rd_clk)	full_rc <= full;
always @(posedge rd_clk)	rd_level <= full_rc ? 2'h0 : {d2[aw-1] | empty, d2[aw-2] | empty};

////////////////////////////////////////////////////////////////////
//
// Sanity Check
//

// synopsys translate_off
//always @(posedge wr_clk)
//	if(we && full)
//		$display("%m WARNING: Writing while fifo is FULL (%t)",$time);

//always @(posedge rd_clk)
//	if(re && empty)
//		$display("%m WARNING: Reading while fifo is EMPTY (%t)",$time);
// synopsys translate_on

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/monostable_domain_cross.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// monostable_domain_cross.v                                    ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Clock synchronisation beetween two clock domains.            ////
//// Assumption is that input signal duration is always           //// 
//// one clk_a clock period. If that is true output signal        ////
//// duration is always one clk_b clock period.                   ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module monostable_domain_cross(
    input rst,
    input clk_a,
    input in, 
    input clk_b,
    output out
);

// this changes level when the in is seen in clk_a
reg toggle_clk_a;
always @(posedge clk_a or posedge rst)
begin
    if (rst)
        toggle_clk_a <= 0;
    else
        toggle_clk_a <= toggle_clk_a ^ in;
end

// which can then be sync-ed to clk_b
reg [2:0] sync_clk_b;
always @(posedge clk_b or posedge rst)
begin
    if (rst)
        sync_clk_b <= 0;
    else
        sync_clk_b <= {sync_clk_b[1:0], toggle_clk_a};
end

// and recreate the flag in clk_b
assign out = (sync_clk_b[2] ^ sync_clk_b[1]);

endmodule 

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_clock_divider.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_clock_divider.v                                           ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Control of sd card clock rate                                ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module sd_clock_divider (
           input CLK,
           input [7:0] DIVIDER,
           input RST,
           output SD_CLK
       );

reg [7:0] ClockDiv;
reg SD_CLK_O;

//assign SD_CLK = DIVIDER[7] ? CLK : SD_CLK_O;
assign SD_CLK = SD_CLK_O;

always @(posedge CLK or posedge RST)
begin
    if (RST) begin
        ClockDiv <= 8'b0000_0000;
        SD_CLK_O <= 0;
    end
    else if (ClockDiv == DIVIDER) begin
        ClockDiv <= 0;
        SD_CLK_O <= ~SD_CLK_O;
    end else begin
        ClockDiv <= ClockDiv + 8'h1;
        SD_CLK_O <= SD_CLK_O;
    end
end

endmodule



// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_cmd_master.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_cmd_master.v                                              ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// State machine resposible for controlling command transfers   ////
//// on 1-bit sd card command interface                           ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "sd_defines.h"

module sd_cmd_master(
           input sd_clk,
           input rst,
           input start_i,
           input int_status_rst_i,
           output [1:0] setting_o,
           output reg start_xfr_o,
           output reg go_idle_o,
           output reg  [39:0] cmd_o,
           input [119:0] response_i,
           input crc_ok_i,
           input index_ok_i,
           input finish_i,
           input busy_i, //direct signal from data sd data input (data[0])
           //input card_detect,
           input [31:0] argument_i,
           input [`CMD_REG_SIZE-1:0] command_i,
           input [15:0] timeout_i,
           output [`INT_CMD_SIZE-1:0] int_status_o,
           output reg [31:0] response_0_o,
           output reg [31:0] response_1_o,
           output reg [31:0] response_2_o,
           output reg [31:0] response_3_o
       );

//-----------Types--------------------------------------------------------
reg [15:0] timeout_reg;
reg crc_check;
reg index_check;
reg busy_check;
reg expect_response;
reg long_response;
reg [`INT_CMD_SIZE-1:0] int_status_reg;
//reg card_present;
//reg [3:0]debounce;
reg [15:0] watchdog;
parameter SIZE = 2;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE       = 2'b00;
parameter EXECUTE    = 2'b01;
parameter BUSY_CHECK = 2'b10;

assign setting_o[1:0] = {long_response, expect_response};
assign int_status_o = state == IDLE ? int_status_reg : 5'h0;

//---------------Input ports---------------

// always @ (posedge sd_clk or posedge rst   )
// begin
//     if (rst) begin
//         debounce<=0;
//         card_present<=0;
//     end
//     else begin
//         if (!card_detect) begin//Card present
//             if (debounce!=4'b1111)
//                 debounce<=debounce+1'b1;
//         end
//         else
//             debounce<=0;
// 
//         if (debounce==4'b1111)
//             card_present<=1'b1;
//         else
//             card_present<=1'b0;
//     end
// end

always @(state or start_i or finish_i or go_idle_o or busy_check or busy_i)
begin: FSM_COMBO
    case(state)
        IDLE: begin
            if (start_i)
                next_state <= EXECUTE;
            else
                next_state <= IDLE;
        end
        EXECUTE: begin
            if ((finish_i && !busy_check) || go_idle_o)
                next_state <= IDLE;
            else if (finish_i && busy_check)
                next_state <= BUSY_CHECK;
            else
                next_state <= EXECUTE;
        end
        BUSY_CHECK: begin
            if (!busy_i)
                next_state <= IDLE;
            else
                next_state <= BUSY_CHECK;
        end
        default: next_state <= IDLE;
    endcase
end

always @(posedge sd_clk or posedge rst)
begin: FSM_SEQ
    if (rst) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @(posedge sd_clk or posedge rst)
begin
    if (rst) begin
        crc_check <= 0;
        response_0_o <= 0;
        response_1_o <= 0;
        response_2_o <= 0;
        response_3_o <= 0;
        int_status_reg <= 0;
        expect_response <= 0;
        long_response <= 0;
        cmd_o <= 0;
        start_xfr_o <= 0;
        index_check <= 0;
        busy_check <= 0;
        watchdog <= 0;
        timeout_reg <= 0;
        go_idle_o <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                go_idle_o <= 0;
                index_check <= command_i[`CMD_IDX_CHECK];
                crc_check <= command_i[`CMD_CRC_CHECK];
                busy_check <= command_i[`CMD_BUSY_CHECK];
                if (command_i[`CMD_RESPONSE_CHECK]  == 2'b10 || command_i[`CMD_RESPONSE_CHECK] == 2'b11) begin
                    expect_response <=  1;
                    long_response <= 1;
                end
                else if (command_i[`CMD_RESPONSE_CHECK] == 2'b01) begin
                    expect_response <= 1;
                    long_response <= 0;
                end
                else begin
                    expect_response <= 0;
                    long_response <= 0;
                end
                cmd_o[39:38] <= 2'b01;
                cmd_o[37:32] <= command_i[`CMD_INDEX];  //CMD_INDEX
                cmd_o[31:0] <= argument_i; //CMD_Argument
                timeout_reg <= timeout_i;
                watchdog <= 0;
                if (start_i) begin
                    start_xfr_o <= 1;
                    int_status_reg <= 0;
                end
            end
            EXECUTE: begin
                start_xfr_o <= 0;
                watchdog <= watchdog + 16'd1;
                if (watchdog > timeout_reg) begin
                    int_status_reg[`INT_CMD_CTE] <= 1;
                    int_status_reg[`INT_CMD_EI] <= 1;
                    go_idle_o <= 1;
                end
                //Incoming New Status
                else begin //if ( req_in_int == 1) begin
                    if (finish_i) begin //Data avaible
                        if (crc_check & !crc_ok_i) begin
                            int_status_reg[`INT_CMD_CCRCE] <= 1;
                            int_status_reg[`INT_CMD_EI] <= 1;
                        end
                        if (index_check & !index_ok_i) begin
                            int_status_reg[`INT_CMD_CIE] <= 1;
                            int_status_reg[`INT_CMD_EI] <= 1;
                        end
                        int_status_reg[`INT_CMD_CC] <= 1;
                        if (expect_response != 0) begin
                            response_0_o <= response_i[119:88];
                            response_1_o <= response_i[87:56];
                            response_2_o <= response_i[55:24];
                            response_3_o <= {response_i[23:0], 8'h00};
                        end
                        // end
                    end ////Data avaible
                end //Status change
            end //EXECUTE state
            BUSY_CHECK: begin
                start_xfr_o <= 0;
                go_idle_o <= 0;
            end
        endcase
        if (int_status_rst_i)
            int_status_reg <= 0;
    end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_cmd_serial_host.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_cmd_serial_host.v                                         ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Module resposible for sending and receiving commands         ////
//// through 1-bit sd card command interface                      ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module sd_cmd_serial_host (
           sd_clk,
           rst,
           setting_i,
           cmd_i,
           start_i,
           response_o,
           crc_ok_o,
           index_ok_o,
           finish_o,
           cmd_dat_i,
           cmd_out_o,
           cmd_oe_o
       );

//---------------Input ports---------------
input sd_clk;
input rst;
input [1:0] setting_i;
input [39:0] cmd_i;
input start_i;
input cmd_dat_i;
//---------------Output ports---------------
output reg [119:0] response_o;
output reg finish_o;
output reg crc_ok_o;
output reg index_ok_o;
output reg cmd_oe_o;
output reg cmd_out_o;

//-------------Internal Constant-------------
parameter INIT_DELAY = 4;
parameter BITS_TO_SEND = 48;
parameter CMD_SIZE = 40;
parameter RESP_SIZE = 128;

//---------------Internal variable-----------
reg cmd_dat_reg;
integer resp_len;
reg with_response;
reg [CMD_SIZE-1:0] cmd_buff;
reg [RESP_SIZE-1:0] resp_buff;
integer resp_idx;
//CRC
reg crc_rst;
reg [6:0]crc_in;
wire [6:0] crc_val;
reg crc_enable;
reg crc_bit;
reg crc_ok;
//-Internal Counterns
integer counter;
//-State Machine
parameter STATE_SIZE = 10;
parameter
    INIT = 7'h00,
    IDLE = 7'h01,
    SETUP_CRC = 7'h02,
    WRITE = 7'h04,
    READ_WAIT = 7'h08,
    READ = 7'h10,
    FINISH_WR = 7'h20,
    FINISH_WO = 7'h40;
reg [STATE_SIZE-1:0] state;
reg [STATE_SIZE-1:0] next_state;
//Misc
`define cmd_idx  (CMD_SIZE-1-counter) 

//sd cmd input pad register
always @(posedge sd_clk)
    cmd_dat_reg <= cmd_dat_i;

//------------------------------------------
sd_crc_7 CRC_7(
             crc_bit,
             crc_enable,
             sd_clk,
             crc_rst,
             crc_val);

//------------------------------------------
always @(state or counter or start_i or with_response or cmd_dat_reg or resp_len)
begin: FSM_COMBO
    case(state)
        INIT: begin
            if (counter >= INIT_DELAY) begin
                next_state <= IDLE;
            end
            else begin
                next_state <= INIT;
            end
        end
        IDLE: begin
            if (start_i) begin
                next_state <= SETUP_CRC;
            end
            else begin
                next_state <= IDLE;
            end
        end
        SETUP_CRC:
            next_state <= WRITE;
        WRITE:
            if (counter >= BITS_TO_SEND && with_response) begin
                next_state <= READ_WAIT;
            end
            else if (counter >= BITS_TO_SEND) begin
                next_state <= FINISH_WO;
            end
            else begin
                next_state <= WRITE;
            end
        READ_WAIT:
            if (!cmd_dat_reg) begin
                next_state <= READ;
            end
            else begin
                next_state <= READ_WAIT;
            end
        FINISH_WO:
            next_state <= IDLE;
        READ:
            if (counter >= resp_len+8) begin
                next_state <= FINISH_WR;
            end
            else begin
                next_state <= READ;
            end
        FINISH_WR:
            next_state <= IDLE;
        default: 
            next_state <= INIT;
    endcase
end

always @(posedge sd_clk or posedge rst)
begin: COMMAND_DECODER
    if (rst) begin
        resp_len <= 0;
        with_response <= 0;
        cmd_buff <= 0;
    end
    else begin
        if (start_i == 1) begin
            resp_len <= setting_i[1] ? 127 : 39;
            with_response <= setting_i[0];
            cmd_buff <= cmd_i;
        end
    end
end

//----------------Seq logic------------
always @(posedge sd_clk or posedge rst)
begin: FSM_SEQ
    if (rst) begin
        state <= INIT;
    end
    else begin
        state <= next_state;
    end
end

//-------------OUTPUT_LOGIC-------
always @(posedge sd_clk or posedge rst)
begin: FSM_OUT
    if (rst) begin
        crc_enable <= 0;
        resp_idx <= 0;
        cmd_oe_o <= 1;
        cmd_out_o <= 1;
        resp_buff <= 0;
        finish_o <= 0;
        crc_rst <= 1;
        crc_bit <= 0;
        crc_in <= 0;
        response_o <= 0;
        index_ok_o <= 0;
        crc_ok_o <= 0;
        crc_ok <= 0;
        counter <= 0;
    end
    else begin
        case(state)
            INIT: begin
                counter <= counter+1;
                cmd_oe_o <= 1;
                cmd_out_o <= 1;
            end
            IDLE: begin
                cmd_oe_o <= 0;      //Put CMD to Z
                counter <= 0;
                crc_rst <= 1;
                crc_enable <= 0;
                response_o <= 0;
                resp_idx <= 0;
                crc_ok_o <= 0;
                index_ok_o <= 0;
                finish_o <= 0;
            end
            SETUP_CRC: begin
                crc_rst <= 0;
                crc_enable <= 1;
                crc_bit <= cmd_buff[`cmd_idx];
            end
            WRITE: begin
                if (counter < BITS_TO_SEND-8) begin  // 1->40 CMD, (41 >= CNT && CNT <=47) CRC, 48 stop_bit
                    cmd_oe_o <= 1;
                    cmd_out_o <= cmd_buff[`cmd_idx];
                    if (counter < BITS_TO_SEND-9) begin //1 step ahead
                        crc_bit <= cmd_buff[`cmd_idx-1];
                    end else begin
                        crc_enable <= 0;
                    end
                end
                else if (counter < BITS_TO_SEND-1) begin
                    cmd_oe_o <= 1;
                    crc_enable <= 0;
                    cmd_out_o <= crc_val[BITS_TO_SEND-counter-2];
                end
                else if (counter == BITS_TO_SEND-1) begin
                    cmd_oe_o <= 1;
                    cmd_out_o <= 1'b1;
                end
                else begin
                    cmd_oe_o <= 0;
                    cmd_out_o <= 1'b1;
                end
                counter <= counter+1;
            end
            READ_WAIT: begin
                crc_enable <= 0;
                crc_rst <= 1;
                counter <= 1;
                cmd_oe_o <= 0;
                resp_buff[RESP_SIZE-1] <= cmd_dat_reg;
            end
            FINISH_WO: begin
                finish_o <= 1;
                crc_enable <= 0;
                crc_rst <= 1;
                counter <= 0;
                cmd_oe_o <= 0;
            end
            READ: begin
                crc_rst <= 0;
                crc_enable <= (resp_len != RESP_SIZE-1 || counter > 7);
                cmd_oe_o <= 0;
                if (counter <= resp_len) begin
                    if (counter < 8) //1+1+6 (S,T,Index)
                        resp_buff[RESP_SIZE-1-counter] <= cmd_dat_reg;
                    else begin
                        resp_idx <= resp_idx + 1;
                        resp_buff[RESP_SIZE-9-resp_idx] <= cmd_dat_reg;
                    end
                    crc_bit <= cmd_dat_reg;
                end
                else if (counter-resp_len <= 7) begin
                    crc_in[(resp_len+7)-(counter)] <= cmd_dat_reg;
                    crc_enable <= 0;
                end
                else begin
                    crc_enable <= 0;
                    if (crc_in == crc_val) crc_ok <= 1;
                    else crc_ok <= 0;
                end
                counter <= counter + 1;
            end
            FINISH_WR: begin
                if (cmd_buff[37:32] == resp_buff[125:120])
                    index_ok_o <= 1;
                else
                    index_ok_o <= 0;
                crc_ok_o <= crc_ok;
                finish_o <= 1;
                crc_enable <= 0;
                crc_rst <= 1;
                counter <= 0;
                cmd_oe_o <= 0;
                response_o <= resp_buff[119:0];
            end
        endcase
    end
end

endmodule



// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_controller_wb.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_controller_wb.v                                           ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Wishbone interface responsible for comunication with core    ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "sd_defines.h"

module sd_controller_wb(
           // WISHBONE slave
           wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o,
           wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o,
           cmd_start,
           data_int_rst,
           cmd_int_rst,
           argument_reg,
           command_reg,
           response_0_reg,
           response_1_reg,
           response_2_reg,
           response_3_reg,
           software_reset_reg,
           timeout_reg,
           block_size_reg,
           controll_setting_reg,
           cmd_int_status_reg,
           cmd_int_enable_reg,
           clock_divider_reg,
           block_count_reg,
           dma_addr_reg,
           data_int_status_reg,
           data_int_enable_reg
       );

// WISHBONE common
input wb_clk_i;     // WISHBONE clock
input wb_rst_i;     // WISHBONE reset
input [31:0] wb_dat_i;     // WISHBONE data input
output reg [31:0] wb_dat_o;     // WISHBONE data output
// WISHBONE error output

// WISHBONE slave
input [7:0] wb_adr_i;     // WISHBONE address input
input [3:0] wb_sel_i;     // WISHBONE byte select input
input wb_we_i;      // WISHBONE write enable input
input wb_cyc_i;     // WISHBONE cycle input
input wb_stb_i;     // WISHBONE strobe input
output reg wb_ack_o;     // WISHBONE acknowledge output
output reg cmd_start;
//Buss accessible registers
output reg [31:0] argument_reg;
output reg [`CMD_REG_SIZE-1:0] command_reg;
input wire [31:0] response_0_reg;
input wire [31:0] response_1_reg;
input wire [31:0] response_2_reg;
input wire [31:0] response_3_reg;
output reg [0:0] software_reset_reg;
output reg [15:0] timeout_reg;
output reg [`BLKSIZE_W-1:0] block_size_reg;
output reg [15:0] controll_setting_reg;
input wire [`INT_CMD_SIZE-1:0] cmd_int_status_reg;
output reg [`INT_CMD_SIZE-1:0] cmd_int_enable_reg;
output reg [7:0] clock_divider_reg;
input  wire [`INT_DATA_SIZE-1:0] data_int_status_reg;
output reg [`INT_DATA_SIZE-1:0] data_int_enable_reg;
//Register Controll
output reg data_int_rst;
output reg cmd_int_rst;
output reg [`BLKCNT_W-1:0]block_count_reg;
output reg [31:0] dma_addr_reg;

parameter voltage_controll_reg  = `SUPPLY_VOLTAGE_mV;
parameter capabilies_reg = 16'b0000_0000_0000_0000;

always @(posedge wb_clk_i or posedge wb_rst_i)
begin
    if (wb_rst_i)begin
        argument_reg <= 0;
        command_reg <= 0;
        software_reset_reg <= 0;
        timeout_reg <= 0;
        block_size_reg <= `RESET_BLOCK_SIZE;
        controll_setting_reg <= 0;
        cmd_int_enable_reg <= 0;
        clock_divider_reg <= `RESET_CLK_DIV;
        wb_ack_o <= 0;
        cmd_start <= 0;
        data_int_rst <= 0;
        data_int_enable_reg <= 0;
        cmd_int_rst <= 0;
        block_count_reg <= 0;
        dma_addr_reg <= 0;
    end
    else
    begin
        cmd_start <= 1'b0;
        data_int_rst <= 0;
        cmd_int_rst <= 0;
        if ((wb_stb_i & wb_cyc_i) || wb_ack_o)begin
            if (wb_we_i) begin
                case (wb_adr_i)
                    `argument: begin
                        argument_reg <= wb_dat_i;
                        cmd_start <= 1'b1;
                    end
                    `command: command_reg <= wb_dat_i[`CMD_REG_SIZE-1:0];
                    `reset: software_reset_reg <= wb_dat_i[0];
                    `timeout: timeout_reg  <=  wb_dat_i[15:0];
                    `blksize: block_size_reg <= wb_dat_i[`BLKSIZE_W-1:0];
                    `controller: controll_setting_reg <= wb_dat_i[15:0];
                    `cmd_iser: cmd_int_enable_reg <= wb_dat_i[4:0];
                    `cmd_isr: cmd_int_rst <= 1;
                    `clock_d: clock_divider_reg <= wb_dat_i[7:0];
                    `data_isr: data_int_rst <= 1;
                    `data_iser: data_int_enable_reg <= wb_dat_i[`INT_DATA_SIZE-1:0];
                    `dst_src_addr: dma_addr_reg <= wb_dat_i;
                    `blkcnt: block_count_reg <= wb_dat_i[`BLKCNT_W-1:0];
                endcase
            end
            wb_ack_o <= wb_cyc_i & wb_stb_i & ~wb_ack_o;
        end
    end
end

always @(posedge wb_clk_i or posedge wb_rst_i)begin
    if (wb_rst_i == 1)
        wb_dat_o <= 0;
    else
        if (wb_stb_i & wb_cyc_i) begin //CS
            case (wb_adr_i)
                `argument: wb_dat_o <= argument_reg;
                `command: wb_dat_o <= command_reg;
                `resp0: wb_dat_o <= response_0_reg;
                `resp1: wb_dat_o <= response_1_reg;
                `resp2: wb_dat_o <= response_2_reg;
                `resp3: wb_dat_o <= response_3_reg;
                `controller: wb_dat_o <= controll_setting_reg;
                `blksize: wb_dat_o <= block_size_reg;
                `voltage: wb_dat_o <= voltage_controll_reg;
                `reset: wb_dat_o <= software_reset_reg;
                `timeout: wb_dat_o <= timeout_reg;
                `cmd_isr: wb_dat_o <= cmd_int_status_reg;
                `cmd_iser: wb_dat_o <= cmd_int_enable_reg;
                `clock_d: wb_dat_o <= clock_divider_reg;
                `capa: wb_dat_o <= capabilies_reg;
                `data_isr: wb_dat_o <= data_int_status_reg;
                `blkcnt: wb_dat_o <= block_count_reg;
                `data_iser: wb_dat_o <= data_int_enable_reg;
                `dst_src_addr: wb_dat_o <= dma_addr_reg;
            endcase
        end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_crc_16.v
// -----------------------------------------------------------------------------
// ==========================================================================
// CRC Generation Unit - Linear Feedback Shift Register implementation
// (c) Kay Gorontzi, GHSi.de, distributed under the terms of LGPL
// ==========================================================================
module sd_crc_16(BITVAL, ENABLE, BITSTRB, CLEAR, CRC);
   input        BITVAL;                            // Next input bit
   input        ENABLE;                            // Enable calculation
   input        BITSTRB;                           // Current bit valid (Clock)
   input        CLEAR;                             // Init CRC value
   output [15:0] CRC;                               // Current output CRC value

   reg    [15:0] CRC;                               // We need output registers
   wire         inv;
   
   assign inv = BITVAL ^ CRC[15];                   // XOR required?
   
   always @(posedge BITSTRB or posedge CLEAR) begin
      if (CLEAR) begin
         CRC <= 0;                                  // Init before calculation
         end
      else begin
         if (ENABLE == 1) begin
             CRC[15] <= CRC[14];
             CRC[14] <= CRC[13];
             CRC[13] <= CRC[12];
             CRC[12] <= CRC[11] ^ inv;
             CRC[11] <= CRC[10];
             CRC[10] <= CRC[9];
             CRC[9] <= CRC[8];
             CRC[8] <= CRC[7];
             CRC[7] <= CRC[6];
             CRC[6] <= CRC[5];
             CRC[5] <= CRC[4] ^ inv;
             CRC[4] <= CRC[3];
             CRC[3] <= CRC[2];
             CRC[2] <= CRC[1];
             CRC[1] <= CRC[0];
             CRC[0] <= inv;
             end
         end
      end
   
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_crc_7.v
// -----------------------------------------------------------------------------
// ==========================================================================
// CRC Generation Unit - Linear Feedback Shift Register implementation
// (c) Kay Gorontzi, GHSi.de, distributed under the terms of LGPL
// ==========================================================================
module sd_crc_7(BITVAL, ENABLE, BITSTRB, CLEAR, CRC);
   input        BITVAL;                            // Next input bit
   input        ENABLE;                            // Enable calculation
   input        BITSTRB;                           // Current bit valid (Clock)
   input        CLEAR;                             // Init CRC value
   output [6:0] CRC;                               // Current output CRC value

   reg    [6:0] CRC;                               // We need output registers
   wire         inv;
   
   assign inv = BITVAL ^ CRC[6];                   // XOR required?
   
   always @(posedge BITSTRB or posedge CLEAR) begin
      if (CLEAR) begin
         CRC <= 0;                                  // Init before calculation
         end
      else begin
         if (ENABLE == 1) begin
             CRC[6] <= CRC[5];
             CRC[5] <= CRC[4];
             CRC[4] <= CRC[3];
             CRC[3] <= CRC[2] ^ inv;
             CRC[2] <= CRC[1];
             CRC[1] <= CRC[0];
             CRC[0] <= inv;
             end
         end
      end
   
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_data_master.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_data_master.v                                             ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// State machine resposible for controlling data transfers      ////
//// on 4-bit sd card data interface                              ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "sd_defines.h"

module sd_data_master (
           input sd_clk,
           input rst,
           input start_tx_i,
           input start_rx_i,
           //Output to SD-Host Reg
           output reg d_write_o,
           output reg d_read_o,
           //To fifo filler
           output reg start_tx_fifo_o,
           output reg start_rx_fifo_o,
           input tx_fifo_empty_i,
           input tx_fifo_full_i,
           input rx_fifo_full_i,
           //SD-DATA_Host
           input xfr_complete_i,
           input crc_ok_i,
           //status output
           output reg [`INT_DATA_SIZE-1:0] int_status_o,
           input int_status_rst_i
       );

reg tx_cycle;
parameter SIZE = 3;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE          = 3'b000;
parameter START_TX_FIFO = 3'b001;
parameter START_RX_FIFO = 3'b010;
parameter DATA_TRANSFER = 3'b100;

reg trans_done;

always @(state or start_tx_i or start_rx_i or tx_fifo_full_i or xfr_complete_i or trans_done)
begin: FSM_COMBO
    case(state)
        IDLE: begin
            if (start_tx_i == 1) begin
                next_state <= START_TX_FIFO;
            end
            else if (start_rx_i == 1) begin
                next_state <= START_RX_FIFO;
            end
            else begin
                next_state <= IDLE;
            end
        end
        START_TX_FIFO: begin
            if (tx_fifo_full_i == 1 && xfr_complete_i == 0)
                next_state <= DATA_TRANSFER;
            else
                next_state <= START_TX_FIFO;
        end
        START_RX_FIFO: begin
            if (xfr_complete_i == 0)
                next_state <= DATA_TRANSFER;
            else
                next_state <= START_RX_FIFO;
        end
        DATA_TRANSFER: begin
            if (trans_done)
                next_state <= IDLE;
            else
                next_state <= DATA_TRANSFER;
        end
        default: next_state <= IDLE;
    endcase
end

//----------------Seq logic------------
always @(posedge sd_clk or posedge rst)
begin: FSM_SEQ
    if (rst) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

//Output logic-----------------
always @(posedge sd_clk or posedge rst)
begin
    if (rst) begin
        start_tx_fifo_o <= 0;
        start_rx_fifo_o <= 0;
        d_write_o <= 0;
        d_read_o <= 0;
        trans_done <= 0;
        tx_cycle <= 0;
        int_status_o <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                start_tx_fifo_o <= 0;
                start_rx_fifo_o <= 0;
                d_write_o <= 0;
                d_read_o <= 0;
                trans_done <= 0;
                tx_cycle <= 0;
            end
            START_RX_FIFO: begin
                start_rx_fifo_o <= 1;
                start_tx_fifo_o <= 0;
                tx_cycle <= 0;
                d_read_o <= 1;
            end
            START_TX_FIFO:  begin
                start_rx_fifo_o <= 0;
                start_tx_fifo_o <= 1;
                tx_cycle <= 1;
                if (tx_fifo_full_i == 1)
                    d_write_o <= 1;
            end
            DATA_TRANSFER: begin
                d_read_o <= 0;
                d_write_o <= 0;
                if (tx_cycle) begin
                    if (tx_fifo_empty_i) begin
                        if (!trans_done)
                            int_status_o[`INT_DATA_CFE] <= 1;
                        trans_done <= 1;
                        //stop sd_data_serial_host
                        d_write_o <= 1;
                        d_read_o <= 1;
                    end
                end
                else begin
                    if (rx_fifo_full_i) begin
                        if (!trans_done)
                            int_status_o[`INT_DATA_CFE] <= 1;
                        trans_done <= 1;
                        //stop sd_data_serial_host
                        d_write_o <= 1;
                        d_read_o <= 1;
                    end
                end
                if (xfr_complete_i) begin //Transfer complete
                    d_write_o <= 0;
                    d_read_o <= 0;
                    trans_done <= 1;
                    if (!crc_ok_i)  begin //Wrong CRC and Data line free.
                        if (!trans_done)
                            int_status_o[`INT_DATA_CCRCE] <= 1;
                    end
                    else if (crc_ok_i) begin //Data Line free
                        if (!trans_done)
                            int_status_o[`INT_DATA_CC] <= 1;
                    end
                end
            end
        endcase
        if (int_status_rst_i)
            int_status_o<=0;
    end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_data_serial_host.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_data_serial_host.v                                        ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Module resposible for sending and receiving data through     ////
//// 4-bit sd card data interface                                 ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "sd_defines.h"

module sd_data_serial_host(
           input sd_clk,
           input rst,
           //Tx Fifo
           input [31:0] data_in,
           output reg rd,
           //Rx Fifo
           output reg [31:0] data_out,
           output reg we,
           //tristate data
           output reg DAT_oe_o,
           output reg[3:0] DAT_dat_o,
           input [3:0] DAT_dat_i,
           //Controll signals
           input [`BLKSIZE_W-1:0] blksize,
           input bus_4bit,
           input [`BLKCNT_W-1:0] blkcnt,
           input [1:0] start,
           output sd_data_busy,
           output busy,
           output reg crc_ok
       );

reg [3:0] DAT_dat_reg;
reg [`BLKSIZE_W-1+3:0] data_cycles;
reg bus_4bit_reg;
//CRC16
reg [3:0] crc_in;
reg crc_en;
reg crc_rst;
wire [15:0] crc_out [3:0];
reg [15:0] transf_cnt;
parameter SIZE = 6;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE       = 6'b000001;
parameter WRITE_DAT  = 6'b000010;
parameter WRITE_CRC  = 6'b000100;
parameter WRITE_BUSY = 6'b001000;
parameter READ_WAIT  = 6'b010000;
parameter READ_DAT   = 6'b100000;
reg [2:0] crc_status;
reg busy_int;
reg [`BLKCNT_W-1:0] blkcnt_reg;
reg next_block;
wire start_bit;
reg [4:0] crc_c;
reg [3:0] last_din;
reg [2:0] crc_s ;
reg [4:0] data_send_index;

//sd data input pad register
always @(posedge sd_clk)
    DAT_dat_reg <= DAT_dat_i;

genvar i;
generate
    for(i=0; i<4; i=i+1) begin: CRC_16_gen
        sd_crc_16 CRC_16_i (crc_in[i],crc_en, sd_clk, crc_rst, crc_out[i]);
    end
endgenerate

assign busy = (state != IDLE);
assign start_bit = !DAT_dat_reg[0];
assign sd_data_busy = !DAT_dat_reg[0];

always @(state or start or start_bit or  transf_cnt or data_cycles or crc_status or crc_ok or busy_int or next_block)
begin: FSM_COMBO
    case(state)
        IDLE: begin
            if (start == 2'b01)
                next_state <= WRITE_DAT;
            else if  (start == 2'b10)
                next_state <= READ_WAIT;
            else
                next_state <= IDLE;
        end
        WRITE_DAT: begin
            if (transf_cnt >= data_cycles+21 && start_bit)
                next_state <= WRITE_CRC;
            else if (start == 2'b11)
                next_state <= IDLE;
            else
                next_state <= WRITE_DAT;
        end
        WRITE_CRC: begin
            if (crc_status == 3)
                next_state <= WRITE_BUSY;
            else
                next_state <= WRITE_CRC;
        end
        WRITE_BUSY: begin
            if (!busy_int && next_block && crc_ok)
                next_state <= WRITE_DAT;
            else if (!busy_int)
                next_state <= IDLE;
            else
                next_state <= WRITE_BUSY;
        end
        READ_WAIT: begin
            if (start_bit)
                next_state <= READ_DAT;
            else
                next_state <= READ_WAIT;
        end
        READ_DAT: begin
            if (transf_cnt == data_cycles+17 && next_block && crc_ok)
                next_state <= READ_WAIT;
            else if (transf_cnt == data_cycles+17)
                next_state <= IDLE;
            else if (start == 2'b11)
                next_state <= IDLE;
            else
                next_state <= READ_DAT;
        end
        default: next_state <= IDLE;
    endcase
end

always @(posedge sd_clk or posedge rst)
begin: FSM_OUT
    if (rst) begin
        state <= IDLE;
        DAT_oe_o <= 0;
        crc_en <= 0;
        crc_rst <= 1;
        transf_cnt <= 0;
        crc_c <= 15;
        rd <= 0;
        last_din <= 0;
        crc_c <= 0;
        crc_in <= 0;
        DAT_dat_o <= 0;
        crc_status <= 0;
        crc_s <= 0;
        we <= 0;
        data_out <= 0;
        crc_ok <= 0;
        busy_int <= 0;
        data_send_index <= 0;
        next_block <= 0;
        blkcnt_reg <= 0;
        data_cycles <= 0;
        bus_4bit_reg <= 0;      
    end
    else begin
        state <= next_state;
        case(state)
            IDLE: begin
                DAT_oe_o <= 0;
                DAT_dat_o <= 4'b1111;
                crc_en <= 0;
                crc_rst <= 1;
                transf_cnt <= 0;
                crc_c <= 16;
                crc_status <= 0;
                crc_s <= 0;
                we <= 0;
                rd <= 0;
                data_send_index <= 0;
                next_block <= 0;
                blkcnt_reg <= blkcnt;
                data_cycles <= (bus_4bit ? (blksize << 1) : (blksize << 3));
                bus_4bit_reg <= bus_4bit;
            end
            WRITE_DAT: begin
                crc_ok <= 0;
                transf_cnt <= transf_cnt + 16'h1;
                next_block <= 0;
                rd <= 0;
                if (transf_cnt == 1) begin
                    crc_rst <= 0;
                    crc_en <= 1;
                    if (bus_4bit_reg) begin
                        last_din <= data_in[31:28];
                        crc_in <= data_in[31:28];
                    end
                    else begin
                        last_din <= {3'h7, data_in[31]};
                        crc_in <= {3'h7, data_in[31]};
                    end
                    DAT_oe_o <= 1;
                    DAT_dat_o <= bus_4bit_reg ? 4'h0 : 4'he;
                    data_send_index <= 1;
                end
                else if ((transf_cnt >= 2) && (transf_cnt <= data_cycles+1)) begin
                    DAT_oe_o<=1;
                    if (bus_4bit_reg) begin
                        last_din <= {
                            data_in[31-(data_send_index[2:0]<<2)], 
                            data_in[30-(data_send_index[2:0]<<2)], 
                            data_in[29-(data_send_index[2:0]<<2)], 
                            data_in[28-(data_send_index[2:0]<<2)]
                            };
                        crc_in <= {
                            data_in[31-(data_send_index[2:0]<<2)], 
                            data_in[30-(data_send_index[2:0]<<2)], 
                            data_in[29-(data_send_index[2:0]<<2)], 
                            data_in[28-(data_send_index[2:0]<<2)]
                            };
                        if (data_send_index[2:0] == 3'h5/*not 7 - read delay !!!*/) begin
                            rd <= 1;
                        end
                        if (data_send_index[2:0] == 3'h7) begin
                            data_send_index <= 0;
                        end
                        else
                            data_send_index<=data_send_index + 5'h1;
                    end
                    else begin
                        last_din <= {3'h7, data_in[31-data_send_index]};
                        crc_in <= {3'h7, data_in[31-data_send_index]};
                        if (data_send_index == 29/*not 31 - read delay !!!*/) begin
                            rd <= 1;
                        end
                        if (data_send_index == 31) begin
                            data_send_index <= 0;
                        end
                        else
                            data_send_index<=data_send_index + 5'h1;
                    end
                    DAT_dat_o<= last_din;
                    if (transf_cnt == data_cycles+1)
                        crc_en<=0;
                end
                else if (transf_cnt > data_cycles+1 & crc_c!=0) begin
                    crc_en <= 0;
                    crc_c <= crc_c - 5'h1;
                    DAT_oe_o <= 1;
                    DAT_dat_o[0] <= crc_out[0][crc_c-1];
                    if (bus_4bit_reg)
                        DAT_dat_o[3:1] <= {crc_out[3][crc_c-1], crc_out[2][crc_c-1], crc_out[1][crc_c-1]};
                    else
                        DAT_dat_o[3:1] <= {3'h7};
                end
                else if (transf_cnt == data_cycles+18) begin
                    DAT_oe_o <= 1;
                    DAT_dat_o <= 4'hf;
                end
                else if (transf_cnt >= data_cycles+19) begin
                    DAT_oe_o <= 0;
                end
            end
            WRITE_CRC: begin
                DAT_oe_o <= 0;
                if (crc_status < 3)
                    crc_s[crc_status] <= DAT_dat_reg[0];
                crc_status <= crc_status + 3'h1;
                busy_int <= 1;
            end
            WRITE_BUSY: begin
                if (crc_s == 3'b010)
                    crc_ok <= 1;
                else
                    crc_ok <= 0;
                busy_int <= !DAT_dat_reg[0];
                next_block <= (blkcnt_reg != 0);
                if (next_state != WRITE_BUSY) begin
                    blkcnt_reg <= blkcnt_reg - `BLKCNT_W'h1;
                    crc_rst <= 1;
                    crc_c <= 16;
                    crc_status <= 0;
                end
                transf_cnt <= 0;
            end
            READ_WAIT: begin
                DAT_oe_o <= 0;
                crc_rst <= 0;
                crc_en <= 1;
                crc_in <= 0;
                crc_c <= 15;// end
                next_block <= 0;
                transf_cnt <= 0;
            end
            READ_DAT: begin
                if (transf_cnt < data_cycles) begin
                    if (bus_4bit_reg) begin
                        we <= (transf_cnt[2:0] == 7);
                        data_out[31-(transf_cnt[2:0]<<2)] <= DAT_dat_reg[3];
                        data_out[30-(transf_cnt[2:0]<<2)] <= DAT_dat_reg[2];
                        data_out[29-(transf_cnt[2:0]<<2)] <= DAT_dat_reg[1];
                        data_out[28-(transf_cnt[2:0]<<2)] <= DAT_dat_reg[0];
                    end
                    else begin
                        we <= (transf_cnt[4:0] == 31);
                        data_out[31-transf_cnt[4:0]] <= DAT_dat_reg[0];
                    end
                    crc_in <= DAT_dat_reg;
                    crc_ok <= 1;
                    transf_cnt <= transf_cnt + 16'h1;
                end
                else if (transf_cnt <= data_cycles+16) begin
                    transf_cnt <= transf_cnt + 16'h1;
                    crc_en <= 0;
                    last_din <= DAT_dat_reg;
                    we<=0;
                    if (transf_cnt > data_cycles) begin
                        crc_c <= crc_c - 5'h1;
                        if  (crc_out[0][crc_c] != last_din[0])
                            crc_ok <= 0;
                        if  (crc_out[1][crc_c] != last_din[1] && bus_4bit_reg)
                            crc_ok<=0;
                        if  (crc_out[2][crc_c] != last_din[2] && bus_4bit_reg)
                            crc_ok <= 0;
                        if  (crc_out[3][crc_c] != last_din[3] && bus_4bit_reg)
                            crc_ok <= 0;
                        if (crc_c == 0) begin
                            next_block <= (blkcnt_reg != 0);
                            blkcnt_reg <= blkcnt_reg - `BLKCNT_W'h1;
                            crc_rst <= 1;
                        end
                    end
                end
            end
        endcase
    end
end

endmodule






// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_data_xfer_trig.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_data_xfer_trig.v                                          ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Module resposible for triggering data transfer based on      ////
//// command transfer completition code                           ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "sd_defines.h" 

module sd_data_xfer_trig (
           input sd_clk,
           input rst,
           input cmd_with_data_start_i,
           input r_w_i,
           input [`INT_CMD_SIZE-1:0] cmd_int_status_i,
           output reg start_tx_o,
           output reg start_rx_o
       );

reg r_w_reg;
parameter SIZE = 2;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE             = 2'b00;
parameter WAIT_FOR_CMD_INT = 2'b01;
parameter TRIGGER_XFER     = 2'b10;

always @(state or cmd_with_data_start_i or r_w_i or cmd_int_status_i)
begin: FSM_COMBO
    case(state)
        IDLE: begin
            if (cmd_with_data_start_i & r_w_i)
                next_state <= TRIGGER_XFER;
            else if (cmd_with_data_start_i)
                next_state <= WAIT_FOR_CMD_INT;
            else
                next_state <= IDLE;
        end
        WAIT_FOR_CMD_INT: begin
            if (cmd_int_status_i[`INT_CMD_CC])
                next_state <= TRIGGER_XFER;
            else if (cmd_int_status_i[`INT_CMD_EI])
                next_state <= IDLE;
            else
                next_state <= WAIT_FOR_CMD_INT;
        end
        TRIGGER_XFER: begin
            next_state <= IDLE;
        end
        default: next_state <= IDLE;
    endcase
end

always @(posedge sd_clk or posedge rst)
begin: FSM_SEQ
    if (rst) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @(posedge sd_clk or posedge rst)
begin
    if (rst) begin
        start_tx_o <= 0;
        start_rx_o <= 0;
        r_w_reg <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                start_tx_o <= 0;
                start_rx_o <= 0;
                r_w_reg <= r_w_i;
            end
            WAIT_FOR_CMD_INT: begin
                start_tx_o <= 0;
                start_rx_o <= 0;
            end
            TRIGGER_XFER: begin
                start_tx_o <= ~r_w_reg;
                start_rx_o <= r_w_reg;
            end
        endcase
    end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sd_fifo_filler.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_fifo_filler.v                                             ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Fifo interface between sd card and wishbone clock domains    ////
//// and DMA engine eble to write/read to/from CPU memory         ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module sd_fifo_filler(
           input wb_clk,
           input rst,
           //WB Signals
           output [31:0] wbm_adr_o,
           output wbm_we_o,
           output [31:0] wbm_dat_o,
           input [31:0] wbm_dat_i,
           output wbm_cyc_o,
           output wbm_stb_o,
           input wbm_ack_i,
           //Data Master Control signals
           input en_rx_i,
           input en_tx_i,
           input [31:0] adr_i,
           //Data Serial signals
           input sd_clk,
           input [31:0] dat_i,
           output [31:0] dat_o,
           input wr_i,
           input rd_i,
           output sd_full_o,
           output sd_empty_o,
           output wb_full_o,
           output wb_empty_o
       );

`define FIFO_MEM_ADR_SIZE 4
`define MEM_OFFSET 4

wire reset_fifo;
wire fifo_rd;
reg [31:0] offset;
reg fifo_rd_ack;
reg fifo_rd_reg;

assign fifo_rd = wbm_cyc_o & wbm_ack_i;
assign reset_fifo = !en_rx_i & !en_tx_i;

assign wbm_we_o = en_rx_i & !wb_empty_o;
assign wbm_cyc_o = en_rx_i ? en_rx_i & !wb_empty_o : en_tx_i & !wb_full_o;
assign wbm_stb_o = en_rx_i ? wbm_cyc_o & fifo_rd_ack : wbm_cyc_o;

generic_fifo_dc_gray #(
    .dw(32), 
    .aw(`FIFO_MEM_ADR_SIZE)
    ) generic_fifo_dc_gray0 (
    .rd_clk(wb_clk),
    .wr_clk(sd_clk), 
    .rst(!(rst | reset_fifo)), 
    .clr(1'b0), 
    .din(dat_i), 
    .we(wr_i),
    .dout(wbm_dat_o), 
    .re(en_rx_i & wbm_cyc_o & wbm_ack_i), 
    .full(sd_full_o), 
    .empty(wb_empty_o), 
    .wr_level(), 
    .rd_level() 
    );
    
generic_fifo_dc_gray #(
    .dw(32), 
    .aw(`FIFO_MEM_ADR_SIZE)
    ) generic_fifo_dc_gray1 (
    .rd_clk(sd_clk),
    .wr_clk(wb_clk), 
    .rst(!(rst | reset_fifo)), 
    .clr(1'b0), 
    .din(wbm_dat_i), 
    .we(en_tx_i & wbm_cyc_o & wbm_stb_o & wbm_ack_i),
    .dout(dat_o), 
    .re(rd_i), 
    .full(wb_full_o), 
    .empty(sd_empty_o), 
    .wr_level(), 
    .rd_level() 
    );

assign wbm_adr_o = adr_i+offset;

always @(posedge wb_clk or posedge rst)
    if (rst) begin
        offset <= 0;
        fifo_rd_reg <= 0;
        fifo_rd_ack <= 1;
    end
    else begin
        fifo_rd_reg <= fifo_rd;
        fifo_rd_ack <= fifo_rd_reg | !fifo_rd;
        if (wbm_cyc_o & wbm_stb_o & wbm_ack_i)
            offset <= offset + `MEM_OFFSET;
        else if (reset_fifo)
            offset <= 0;
    end

endmodule


