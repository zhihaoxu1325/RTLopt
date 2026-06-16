// Curated RTL benchmark case.
// case_id: bench_0086_communication_controller_ethernet_10ge_low_latency_mac
// source_project: communication_controller_ethernet_10ge_low_latency_mac
// top_module: oc_mac


// -----------------------------------------------------------------------------
// Source file: rtl/oc_mac.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
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

//`include "technology.h"
`include "oc_mac.h"
`default_nettype none
module oc_mac (
		input wire		res_n,
		input wire 		clk,
		input wire		tx_start,
		input wire [63:0]	tx_data,
		input wire [7:0]	tx_data_valid,
		input wire [63:0]	xgmii_rxd,
		input wire [7:0]	xgmii_rxc,

		output wire		tx_ack,
		output wire		rx_bad_frame,
		output wire		rx_good_frame,
		output wire [63:0]	rx_data,
		output wire [7:0]	rx_data_valid,
		output wire [7:0]	xgmii_txc,
		output wire[63:0]	xgmii_txd
	);

wire [1:0]	local_fault_msg_det;
wire [1:0]	remote_fault_msg_det;
wire		status_fragment_error_tog;
wire		status_pause_frame_rx_tog;


wire [63:0]	txdfifo_wdata;
wire [7:0]	txdfifo_wstatus;

wire [63:0]	xgmii_data_in;
wire [7:0]	xgmii_data_status;


rx_enqueue rx_eq0(
                  // Outputs
		.xgmii_data_in		(xgmii_data_in),
		.xgmii_data_status	(xgmii_data_status),
		.local_fault_msg_det  (local_fault_msg_det),
		.remote_fault_msg_det (remote_fault_msg_det),
		.status_fragment_error_tog(status_fragment_error_tog),
		.status_pause_frame_rx_tog(status_pause_frame_rx_tog),
		// Inputs
		.clk         		(clk),
		.res_n    		(res_n),
		.xgmii_rxd		(xgmii_rxd),
		.xgmii_rxc		(xgmii_rxc));


rx_control rx_ctrl(
                  // Outputs
		.rx_data		(rx_data),
		.rx_data_valid		(rx_data_valid),
		.rx_good_frame		(rx_good_frame),
		.rx_bad_frame		(rx_bad_frame),
		//.status_rxdfifo_udflow_tog(status_rxdfifo_udflow_tog),
		// Inputs
		.clk	 		(clk),
		.res_n			(res_n),
		.rx_inc_data		(xgmii_data_in),
		.rx_inc_status		(xgmii_data_status));


tx_dequeue tx_dq0(
                  // Outputs
		.xgmii_txd            	(xgmii_txd),
		.xgmii_txc            	(xgmii_txc),
		// Inputs
		.clk	         	(clk),
		.res_n		     	(res_n),
		.txdfifo_rdata        	(txdfifo_wdata),
		.txdfifo_rstatus      	(txdfifo_wstatus));

tx_control tx_ctrl(
		// Outputs

		.txdfifo_wdata		(txdfifo_wdata),
		.txdfifo_wstatus	(txdfifo_wstatus),
		.tx_ack			(tx_ack),

		.clk			(clk),
		.res_n			(res_n),
		.tx_start		(tx_start),
		.tx_data		(tx_data),
		.tx_data_valid		(tx_data_valid));
		


endmodule
`default_nettype wire

// -----------------------------------------------------------------------------
// Source file: rtl/rx_control.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
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

`include "oc_mac.h"

//`include "technology.h"

`default_nettype none

module rx_control(
		// Inputs
		input wire		clk,
		input wire		res_n,
		input wire [63:0]	rx_inc_data,
		input wire [7:0]	rx_inc_status,
		// Outputs

		output reg [63:0]	rx_data,
		output reg [7:0]	rx_data_valid,
		output reg		rx_good_frame,
		output reg		rx_bad_frame);


reg 	error;


`ifdef ASYNC_RES
always @(posedge clk or negedge res_n) `else
always @(posedge clk) `endif
begin
	if (res_n == 1'b0) begin

		rx_data <= 64'b0;
		rx_data_valid <= 8'b0;
		rx_good_frame <= 1'b0;
		rx_bad_frame <= 1'b0;
		error <= 1'b0;
	end
	else begin
	
	rx_data <= rx_inc_data;
	
	case ({rx_inc_status[`RXSTATUS_SOP], rx_inc_status[`RXSTATUS_EOP], rx_inc_status[`RXSTATUS_VALID], rx_inc_status[`RXSTATUS_ERR]})
		4'b1010: begin	// normal start
				rx_data_valid <= 8'hff;
				error <= 1'b0;
				rx_bad_frame <= 1'b0;
				rx_good_frame <= 1'b0;
			end
		4'b0110: begin // normal end
				if (error) begin
					rx_bad_frame <= 1'b1;
					rx_good_frame <= 1'b0;
				end
				else begin
					rx_bad_frame <= 1'b0;
					rx_good_frame <= 1'b1;
				end
				case(rx_inc_status[2:0])
					3'b000:  rx_data_valid	<= 8'b11111111;
					3'b001:  rx_data_valid	<= 8'b00000001;
					3'b010:  rx_data_valid	<= 8'b00000011;
					3'b011:  rx_data_valid	<= 8'b00000111;
					3'b100:  rx_data_valid	<= 8'b00001111;
					3'b101:  rx_data_valid	<= 8'b00011111;
					3'b110:  rx_data_valid	<= 8'b00111111;
					default: rx_data_valid	<= 8'b01111111;
				endcase
			end
		4'b0111: begin // end of frame bad
				rx_bad_frame <= 1'b1;
				rx_good_frame <= 1'b0;
				case(rx_inc_status[2:0])
					3'b000:  rx_data_valid	<= 8'b11111111;
					3'b001:  rx_data_valid	<= 8'b00000001;
					3'b010:  rx_data_valid	<= 8'b00000011;
					3'b011:  rx_data_valid	<= 8'b00000111;
					3'b100:  rx_data_valid	<= 8'b00001111;
					3'b101:  rx_data_valid	<= 8'b00011111;
					3'b110:  rx_data_valid	<= 8'b00111111;
					default: rx_data_valid	<= 8'b01111111;
				endcase
			end
		4'b0010: begin // ongoing transmission
				rx_data_valid <= 8'hff;
				rx_bad_frame <= 1'b0;
				rx_good_frame <= 1'b0;
			end
		4'b0011: begin
				rx_data_valid <= 8'hff;
				error <= 1'b1;
				rx_bad_frame <= 1'b0;
				rx_good_frame <= 1'b0;
			end
			
		default: begin
				rx_data_valid <= 8'h00;
				error <= 1'b1;
				rx_bad_frame <= 1'b0;
				rx_good_frame <= 1'b0;
			end
	endcase
	end

		
end
		
endmodule
`default_nettype wire

// -----------------------------------------------------------------------------
// Source file: rtl/rx_enqueue.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
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

`include "oc_mac.h"
`include "oc_mac_crc_func.h"

module rx_enqueue(
		input wire		clk,
		input wire		res_n,
		
		input wire [63:0]	xgmii_rxd,
		input wire [7:0]	xgmii_rxc,

		

		output reg [63:0]	xgmii_data_in,
		output reg [7:0]	xgmii_data_status,


		output reg [1:0]	local_fault_msg_det,
		output reg [1:0]	remote_fault_msg_det,

		output reg		status_fragment_error_tog,
		output reg		status_pause_frame_rx_tog);


reg [63:32]	xgmii_rxd_d1;
reg [7:4]	xgmii_rxc_d1;

reg [63:0]	xgxs_rxd_barrel;
reg [7:0]	xgxs_rxc_barrel;

reg [63:0]	xgxs_rxd_barrel_d1;
reg [7:0]	xgxs_rxc_barrel_d1;

reg [63:0]	rx_inc_data;
reg [7:0]	rx_inc_status;

reg		barrel_shift;

reg [31:0]	crc32_d64;

`ifdef SIMULATION 
reg		crc_good; 
`endif
reg		crc_clear;

reg [31:0]	crc_rx;
reg [31:0]	next_crc_rx;

reg [2:0]	curr_state;
reg [2:0]	next_state;

reg [13:0]	curr_byte_cnt;
reg [13:0]	next_byte_cnt;

reg		fragment_error;



reg [7:0]	addmask;
reg [7:0]	datamask;

reg		pause_frame;
reg		next_pause_frame;







parameter [2:0]
	SM_IDLE = 3'd0,
	SM_RX = 3'd1;



	
`ifdef ASYNC_RES
always @(posedge clk or negedge res_n) `else
always @(posedge clk) `endif
begin
	if (res_n == 1'b0) begin

	
		xgmii_data_in <= 64'b0;
		xgmii_data_status <= 8'b0;
		xgmii_rxd_d1 <= 32'b0;
		xgmii_rxc_d1 <= 4'b0;

		xgxs_rxd_barrel <= 64'b0;
		xgxs_rxc_barrel <= 8'b0;

		xgxs_rxd_barrel_d1 <= 64'b0;
		xgxs_rxc_barrel_d1 <= 8'b0;

		barrel_shift <= 1'b0;

		local_fault_msg_det <= 2'b0;
		remote_fault_msg_det <= 2'b0;

		crc32_d64 <= 32'b0;

		crc_rx <= 32'b0;

		status_fragment_error_tog <= 1'b0;

		status_pause_frame_rx_tog <= 1'b0;


		//sm
		curr_state <= SM_IDLE;
		curr_byte_cnt <= 14'b0;
		pause_frame <= 1'b0;

		
	end
	else begin
		//sm

		xgmii_data_in <= rx_inc_data;
		xgmii_data_status <= rx_inc_status;
		

		curr_state <= next_state;
		curr_byte_cnt <= next_byte_cnt;
		pause_frame <= next_pause_frame;


		//---
		// Link status RC layer
		// Look for local/remote messages on lower 4 lanes and upper
		// 4 lanes. This is a 64-bit interface but look at each 32-bit
		// independantly.
		
		local_fault_msg_det[1] <= (xgmii_rxd[63:32] ==
					{`LOCAL_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
					xgmii_rxc[7:4] == 4'b0001);

		local_fault_msg_det[0] <= (xgmii_rxd[31:0] ==
					{`LOCAL_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
					xgmii_rxc[3:0] == 4'b0001);

		remote_fault_msg_det[1] <= (xgmii_rxd[63:32] ==
					{`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
					xgmii_rxc[7:4] == 4'b0001);

		remote_fault_msg_det[0] <= (xgmii_rxd[31:0] ==
					{`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE} &&
					xgmii_rxc[3:0] == 4'b0001);



		
		
		//---
		// Rotating barrel. This function allow us to always align the start of
		// a frame with LANE0. If frame starts in LANE4, it will be shifted 4 bytes
		// to LANE0, thus reducing the amount of logic needed at the next stage.

		xgmii_rxd_d1[63:32] <= xgmii_rxd[63:32];
		xgmii_rxc_d1[7:4] <= xgmii_rxc[7:4];

		if (xgmii_rxd[`LANE0] == `START && xgmii_rxc[0]) begin
			
			xgxs_rxd_barrel <= xgmii_rxd;
			xgxs_rxc_barrel <= xgmii_rxc;

			barrel_shift <= 1'b0;

		end
		else if (xgmii_rxd[`LANE4] == `START && xgmii_rxc[4]) begin

			xgxs_rxd_barrel <= {xgmii_rxd[31:0], xgmii_rxd_d1[63:32]};
			xgxs_rxc_barrel <= {xgmii_rxc[3:0], xgmii_rxc_d1[7:4]};

			barrel_shift <= 1'b1;

		end
		else if (barrel_shift) begin

			xgxs_rxd_barrel <= {xgmii_rxd[31:0], xgmii_rxd_d1[63:32]};
			xgxs_rxc_barrel <= {xgmii_rxc[3:0], xgmii_rxc_d1[7:4]};

		end
		else begin

			xgxs_rxd_barrel <= xgmii_rxd;
			xgxs_rxc_barrel <= xgmii_rxc;

		end

		xgxs_rxd_barrel_d1 <= xgxs_rxd_barrel;
		xgxs_rxc_barrel_d1 <= xgxs_rxc_barrel;


		crc_rx <= next_crc_rx;

		if (crc_clear) begin

		// CRC is cleared at the beginning of the frame, calculate
		// 64-bit at a time otherwise

			crc32_d64 <= 32'hffffffff;

		end
		else begin

			crc32_d64 <= next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b0);			

		end
		
		//---
		// Error detection


		if (fragment_error) begin
			status_fragment_error_tog <= ~status_fragment_error_tog;
		end


		//---
		// Frame receive indication

// 		if (good_pause_frame) begin
// 		status_pause_frame_rx_tog <= ~status_pause_frame_rx_tog;
// 		end

	end

	end
		


always @(/*AS*/crc_rx or curr_byte_cnt or curr_state
	or pause_frame or xgxs_rxc_barrel or xgxs_rxc_barrel_d1
	or xgxs_rxd_barrel or xgxs_rxd_barrel_d1) 
begin

	next_state = curr_state;

	rx_inc_data = xgxs_rxd_barrel_d1;
	rx_inc_status = `RXSTATUS_NONE;


	addmask[0] = !(xgxs_rxd_barrel_d1[`LANE0] == `TERMINATE && xgxs_rxc_barrel_d1[0]);
	addmask[1] = !(xgxs_rxd_barrel_d1[`LANE1] == `TERMINATE && xgxs_rxc_barrel_d1[1]);
	addmask[2] = !(xgxs_rxd_barrel_d1[`LANE2] == `TERMINATE && xgxs_rxc_barrel_d1[2]);
	addmask[3] = !(xgxs_rxd_barrel_d1[`LANE3] == `TERMINATE && xgxs_rxc_barrel_d1[3]);
	addmask[4] = !(xgxs_rxd_barrel_d1[`LANE4] == `TERMINATE && xgxs_rxc_barrel_d1[4]);
	addmask[5] = !(xgxs_rxd_barrel_d1[`LANE5] == `TERMINATE && xgxs_rxc_barrel_d1[5]);
	addmask[6] = !(xgxs_rxd_barrel_d1[`LANE6] == `TERMINATE && xgxs_rxc_barrel_d1[6]);
	addmask[7] = !(xgxs_rxd_barrel_d1[`LANE7] == `TERMINATE && xgxs_rxc_barrel_d1[7]);

	datamask[0] = addmask[0];
	datamask[1] = &addmask[1:0];
	datamask[2] = &addmask[2:0];
	datamask[3] = &addmask[3:0];
	datamask[4] = &addmask[4:0];
	datamask[5] = &addmask[5:0];
	datamask[6] = &addmask[6:0];
	datamask[7] = &addmask[7:0];


	next_crc_rx = crc_rx;
	crc_clear = 1'b0;
	`ifdef SIMULATION 
	crc_good = 1'b0;
	`endif
	

	next_byte_cnt = curr_byte_cnt;

	fragment_error = 1'b0;

	next_pause_frame = pause_frame;

	case (curr_state)

		SM_IDLE: begin
			next_byte_cnt = 14'b0;
			crc_clear = 1'b1;
			next_pause_frame = 1'b0;
		

			// Detect the start of a frame
			
			if (xgxs_rxd_barrel_d1[`LANE0] == `START && xgxs_rxc_barrel_d1[0] &&
				xgxs_rxd_barrel_d1[`LANE1] == `PREAMBLE && !xgxs_rxc_barrel_d1[1] &&
				xgxs_rxd_barrel_d1[`LANE2] == `PREAMBLE && !xgxs_rxc_barrel_d1[2] &&
				xgxs_rxd_barrel_d1[`LANE3] == `PREAMBLE && !xgxs_rxc_barrel_d1[3] &&
				xgxs_rxd_barrel_d1[`LANE4] == `PREAMBLE && !xgxs_rxc_barrel_d1[4] &&
				xgxs_rxd_barrel_d1[`LANE5] == `PREAMBLE && !xgxs_rxc_barrel_d1[5] &&
				xgxs_rxd_barrel_d1[`LANE6] == `PREAMBLE && !xgxs_rxc_barrel_d1[6] &&
				xgxs_rxd_barrel_d1[`LANE7] == `SFD && !xgxs_rxc_barrel_d1[7])
			begin
				next_state = SM_RX;
			end

		end

		SM_RX:	begin

			rx_inc_status[`RXSTATUS_VALID] = 1'b1;

			if (xgxs_rxd_barrel_d1[`LANE0] == `START && xgxs_rxc_barrel_d1[0] &&
				xgxs_rxd_barrel_d1[`LANE7] == `SFD && !xgxs_rxc_barrel_d1[7]) begin

				// Fragment received, if we are still at SOP stage don't store
				// the frame. If not, write a fake EOP and flag frame as bad.

				next_byte_cnt = 14'b0;
				crc_clear = 1'b1;

				fragment_error = 1'b1;
				rx_inc_status[`RXSTATUS_ERR] = 1'b1;

				if (curr_byte_cnt == 14'b0) begin
					//rxhfifo_wen = 1'b0;
				end
				else begin
					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
				end

			end
			else if (curr_byte_cnt +datamask[0] + datamask[1] + datamask[2] + datamask[3] +
						datamask[4] + datamask[5] + datamask[6] + datamask[7] > 14'd1518) begin //6 da + 6 sa +2 typelength, +1500 payload +4 crc

				// Frame too long, TERMMINATE must have been corrupted.
				// Abort transfer, write a fake EOP, report as fragment.

				fragment_error = 1'b1;
				rx_inc_status[`RXSTATUS_ERR] = 1'b1;

				rx_inc_status[`RXSTATUS_EOP] = 1'b1;
				next_state = SM_IDLE;

			end
			else begin

				// Pause frame receive, these frame will be filtered
				//- TODO
				if (curr_byte_cnt == 14'd0 && xgxs_rxd_barrel_d1[47:0] == `PAUSE_FRAME) begin

				//rxhfifo_wen = 1'b0; 
					next_pause_frame = 1'b1;
				end



				// Write SOP to status bits during first byte

				if (curr_byte_cnt == 14'b0) begin
					rx_inc_status[`RXSTATUS_SOP] = 1'b1;
				end
				
				next_byte_cnt = curr_byte_cnt +
						addmask[0] + addmask[1] + addmask[2] + addmask[3] +
						addmask[4] + addmask[5] + addmask[6] + addmask[7];
				
				




				// Look one cycle ahead for TERMINATE in lanes 0 to 4
				if (curr_byte_cnt + datamask[0] + datamask[1] + datamask[2] + datamask[3] +
						datamask[4] + datamask[5] + datamask[6] + datamask[7] < 14'd64 && |(xgxs_rxc_barrel_d1 & datamask) ) begin // ethernet min. 64 byte check
					
					next_state = SM_IDLE;
					rx_inc_status[`RXSTATUS_ERR] = 1'b1;
					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					
					
					
				end
				else if (xgxs_rxd_barrel[`LANE4] == `TERMINATE && xgxs_rxc_barrel[4]) begin
		
					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd0;

					if (  xgxs_rxd_barrel[31:0] !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b000))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end

				else if (xgxs_rxd_barrel[`LANE3] == `TERMINATE && xgxs_rxc_barrel[3]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd7;

					if (  {xgxs_rxd_barrel[23:0], xgxs_rxd_barrel_d1[63:56]} !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b111))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;						
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end
			
				else if (xgxs_rxd_barrel[`LANE2] == `TERMINATE && xgxs_rxc_barrel[2]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd6;

					if (  {xgxs_rxd_barrel[15:0], xgxs_rxd_barrel_d1[63:48]} !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b110))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end

				else if (xgxs_rxd_barrel[`LANE1] == `TERMINATE && xgxs_rxc_barrel[1]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd5;

					if ( {xgxs_rxd_barrel[7:0], xgxs_rxd_barrel_d1[63:40]} !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b101))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end
			
				else if (xgxs_rxd_barrel[`LANE0] == `TERMINATE && xgxs_rxc_barrel[0]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd4;

					if ( xgxs_rxd_barrel_d1[63:32] !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b100))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif						
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end

				// Look at current cycle for TERMINATE in lanes 5 to 7

				else if (xgxs_rxd_barrel_d1[`LANE7] == `TERMINATE &&
					xgxs_rxc_barrel_d1[7]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd3;

					if ( xgxs_rxd_barrel_d1[55:24] !=  ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b011))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end
			
				else if (xgxs_rxd_barrel_d1[`LANE6] == `TERMINATE &&
					xgxs_rxc_barrel_d1[6]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd2;

					if ( xgxs_rxd_barrel_d1[47:16] != ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b010))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif
					next_state = SM_IDLE;

				end
			
				else if (xgxs_rxd_barrel_d1[`LANE5] == `TERMINATE &&
					xgxs_rxc_barrel_d1[5]) begin

					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					rx_inc_status[2:0] = 3'd1;
					if ( xgxs_rxd_barrel_d1[39:8] != ~reverse_32b(next_crc32_data64_be(reverse_64b(xgxs_rxd_barrel_d1), crc32_d64, 3'b001))) begin
						rx_inc_status[`RXSTATUS_ERR] = 1'b1;
						`ifdef SIMULATION
						crc_good = 1'b0;
						`endif
					end
					`ifdef SIMULATION
					else begin
						crc_good = 1'b1;
					end
					`endif

					next_state = SM_IDLE;

				end
				else if(|(xgxs_rxc_barrel_d1 & datamask)) begin // no terminate signal, but cmd != 0
					`ifdef SIMULATION
					crc_good = 1'b0;
					`endif
					rx_inc_status[`RXSTATUS_ERR] = 1'b1;
					rx_inc_status[`RXSTATUS_EOP] = 1'b1;
					next_state = SM_IDLE;
					
				
				end
				`ifdef SIMULATION
				else begin
					crc_good = 1'b0;
				end
				`endif
			
			end
		end

		default: begin
			next_state = SM_IDLE;
		end

	endcase

end


endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/tx_control.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
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

//`include "technology.h"
`include "oc_mac.h"

`default_nettype none

module tx_control(
		// Inputs
		input wire		clk,
		input wire		res_n,
		input wire		tx_start,
		input wire [63:0]	tx_data,
		input wire [7:0]	tx_data_valid,
		// Outputs

		output reg [63:0]	txdfifo_wdata,
		output reg [7:0]	txdfifo_wstatus,
		output reg		tx_ack);


reg [3:0]	frame_cnt;

// Shift register for EOP
reg [63:0]	txdfifo_wdata_prev;
reg [7:0]	txdfifo_wstatus_prev;
reg [2:0]	current_state;

parameter [2:0]
		SM_IDLE = 3'd0,
		SM_START = 3'd1,
		SM_TX = 3'd2;

// Full status if data fifo is almost full.
// Current packet can complete transfer since data input rate
// matches output rate. But next packet must wait for more headroom.
// 

//SM!!

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n) `else
always @(posedge clk) `endif
begin
	if (res_n == 1'b0) begin
		txdfifo_wdata <= 64'b0;
		txdfifo_wstatus <= 8'b0;
		frame_cnt <= 4'b0;
		current_state <= 3'b0;
		txdfifo_wdata_prev <= 64'b0;
		txdfifo_wstatus_prev <= 8'b0;
		tx_ack <= 1'b0;
		

	end
	else begin

		txdfifo_wdata <= txdfifo_wdata_prev;
		txdfifo_wdata_prev <= tx_data;
		case (current_state)
			
		SM_IDLE: begin

			txdfifo_wstatus_prev <= 8'b0;
			txdfifo_wstatus <= txdfifo_wstatus_prev;
			if(tx_start == 1'b1) begin
				current_state <= SM_START;
			end
			else begin
				current_state <= SM_IDLE;
				if (frame_cnt != 4'b0)
					frame_cnt <= frame_cnt - 4'b1;
			end

		end
		SM_START: begin

			if (frame_cnt == 4'd0) begin
				tx_ack <= 1'b1;
				current_state <= SM_TX;
				txdfifo_wstatus <= txdfifo_wstatus_prev;
				frame_cnt <= 4'd9;
			end
			else begin
				tx_ack <= 1'b0;
				current_state <= SM_START;
				txdfifo_wstatus_prev <= 8'b0;
				txdfifo_wstatus <= txdfifo_wstatus_prev;
				frame_cnt <= frame_cnt - 4'b1;
			end
		end
		SM_TX: begin
			
			if(frame_cnt != 4'd0) begin
				frame_cnt <= frame_cnt - 4'b1;
			end
			if(tx_ack == 1'b1) begin
				txdfifo_wstatus_prev <= `TXSTATUS_START;
				tx_ack <= 1'b0;
				txdfifo_wstatus <= txdfifo_wstatus_prev;
			end 
			else if (tx_data_valid == 8'hFF) begin
				txdfifo_wstatus <= txdfifo_wstatus_prev;
				txdfifo_wstatus_prev <= `TXSTATUS_NONE;
				txdfifo_wstatus <= txdfifo_wstatus_prev;
				current_state <= SM_TX;
			end
			else if (tx_data_valid == 8'b00) begin	
				txdfifo_wstatus <= `TXSTATUS_END;
				txdfifo_wstatus_prev <= 8'b0;
				current_state <= SM_IDLE;
			end
			else begin
				case (tx_data_valid)
					8'b11111111:	txdfifo_wstatus_prev[2:0]	<= 3'h0; // all lanes with valid data(implementation error, not working)
					8'b01111111:	txdfifo_wstatus_prev[2:0]	<= 3'h7;
					8'b00111111:	txdfifo_wstatus_prev[2:0]	<= 3'h6;
					8'b00011111:	txdfifo_wstatus_prev[2:0]	<= 3'h5;
					8'b00001111:	txdfifo_wstatus_prev[2:0]	<= 3'h4;
					8'b00000111:	txdfifo_wstatus_prev[2:0]	<= 3'h3;
					8'b00000011:	txdfifo_wstatus_prev[2:0]	<= 3'h2;
					8'b00000001:	txdfifo_wstatus_prev[2:0]	<= 3'h1;
					8'b00000000:	txdfifo_wstatus_prev[2:0]	<= 3'h0; // not defined in OC
					default:	txdfifo_wstatus_prev[2:0]	<= 3'h0; // unsure.
				endcase

				txdfifo_wstatus_prev[`TXSTATUS_EOP] <= 1'b1;
				txdfifo_wstatus_prev[`TXSTATUS_VALID] <= 1'b1;
				txdfifo_wstatus_prev[`TXSTATUS_SOP] <= 1'b0;
				txdfifo_wstatus_prev[5] <= 1'b0;
				txdfifo_wstatus_prev[3] <= 1'b0;

				txdfifo_wstatus <= txdfifo_wstatus_prev;
				current_state <= SM_IDLE;
			end
		end
			
		endcase//- SM 
		
	end
end
		
endmodule
`default_nettype wire

// -----------------------------------------------------------------------------
// Source file: rtl/tx_dequeue.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  This file is part of the "10GE LL MAC" project              ////
////  http://www.opencores.org/cores/xge_ll_mac/                  ////
////                                                              ////
////  This project is derived from the "10GE MAC" project of      ////
////  A. Tanguay (antanguay@opencores.org) by Andreas Peters      ////
////  for his Diploma Thesis at the University of Heidelberg.     ////
////  The Thesis was supervised by Christian Leber                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Andreas Peters                                        ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008-2012 AUTHORS. All rights reserved.        ////
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

`include "oc_mac.h"
`include "oc_mac_crc_func.h"

module tx_dequeue(
  // Outputs
	input wire		clk,
	input wire		res_n,
	input wire [63:0]	txdfifo_rdata,
	input wire [7:0]	txdfifo_rstatus,
	
	output reg [63:0]	xgmii_txd,
	output reg [7:0]	xgmii_txc);



reg [63:0]	xgxs_txd;
reg [7:0]	xgxs_txc;

reg [63:0]	next_xgxs_txd;
reg [7:0]	next_xgxs_txc;

reg [2:0]	curr_state_enc;
reg [2:0]	next_state_enc;

reg [0:0]	curr_state_pad;
reg[0:0]	next_state_pad;




reg [7:0]	eop;
reg [7:0]	next_eop;



reg [63:0]	txhfifo_wdata_d1;

reg [13:0]	byte_cnt;

reg [31:0]	crc32_d64;
reg [31:0]	crc32_tx;

reg [31:0]	crc_data;




reg [63:0]	next_txhfifo_wdata;
reg [7:0]	next_txhfifo_wstatus;
reg		next_txhfifo_wen;


reg [63:0]	txhfifo_wdata;
reg [7:0]	txhfifo_wstatus;

reg		status_local_fault_ctx; // for later implementations
reg		status_remote_fault_ctx;



parameter [2:0]
	//SM_IDLE      = 3'd0,
	SM_PREAMBLE  = 3'd0,
	SM_TX        = 3'd2,
	SM_EOP       = 3'd3,
	SM_TERM      = 3'd4,
	SM_TERM_FAIL = 3'd5;

parameter [0:0]
	SM_PAD_EQ    = 1'd0,
	SM_PAD_PAD   = 1'd1;


//---
// RC layer

`ifdef ASYNC_RES
always @(posedge clk or negedge res_n) `else
always @(posedge clk) `endif
begin

	if (res_n == 1'b0) begin

		xgmii_txd <= {8{`IDLE}};
		xgmii_txc <= 8'hff;
		status_remote_fault_ctx <= 1'b0;
		status_local_fault_ctx <= 1'b0;

		curr_state_enc <= SM_PREAMBLE;


		eop <= 8'b0;

		txhfifo_wdata_d1 <= 64'b0;





		xgxs_txd <= {8{`IDLE}};
		xgxs_txc <= 8'hff;

		curr_state_pad <= SM_PAD_EQ;


		txhfifo_wdata <= 64'b0;
		txhfifo_wstatus <= 8'b0; 

		byte_cnt <= 14'b0;


	end
	else begin
		// no faults expected.
		status_remote_fault_ctx <= 1'b0;
		status_local_fault_ctx <= 1'b0;
		//---
		// RC Layer, insert local or remote fault messages based on status
		// of fault state-machine

		if (status_local_fault_ctx) begin

		// If local fault detected, send remote fault message to
		// link partner
			xgmii_txd <= {`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE,
					`REMOTE_FAULT, 8'h0, 8'h0, `SEQUENCE};
			xgmii_txc <= {4'b0001, 4'b0001};
		end
		else if (status_remote_fault_ctx) begin

		// If remote fault detected, inhibit transmission and send
		// idle codes
			xgmii_txd <= {8{`IDLE}};
			xgmii_txc <= 8'hff;
		end
		else begin
			xgmii_txd <= xgxs_txd;
			xgmii_txc <= xgxs_txc;
		end

		curr_state_enc <= next_state_enc;


		eop <= next_eop;

		txhfifo_wdata_d1 <= txhfifo_wdata;



		xgxs_txd <= next_xgxs_txd;
		xgxs_txc <= next_xgxs_txc;

		curr_state_pad <= next_state_pad;


		txhfifo_wdata <= next_txhfifo_wdata;
		txhfifo_wstatus <= next_txhfifo_wstatus;


		//---
		// Reset byte count on SOP
		


		if (next_txhfifo_wstatus[`TXSTATUS_SOP]) begin
			byte_cnt <= 14'd8;
		end
		else if (next_txhfifo_wstatus[`TXSTATUS_VALID]) begin
			byte_cnt <= byte_cnt + 14'd8; 
		end


		// ========================================
		// ============CRC_CALC====================
		// ========================================


		if (txhfifo_wstatus[`TXSTATUS_VALID]) begin

			crc32_d64 <= next_crc32_data64_be(reverse_64b(txhfifo_wdata), crc_data, 3'b000);

		end

		if (txhfifo_wstatus[`TXSTATUS_VALID] && txhfifo_wstatus[`TXSTATUS_EOP]) begin

			
			crc32_tx <= ~reverse_32b(next_crc32_data64_be(reverse_64b(txhfifo_wdata), crc32_d64, txhfifo_wstatus[2:0]));


		end


	end

end


	always @(crc32_tx or curr_state_enc or eop
		or txhfifo_wdata_d1
		or txhfifo_wstatus) begin

	next_state_enc = curr_state_enc;


	next_eop = eop;

	next_xgxs_txd = {8{`IDLE}};
	next_xgxs_txc = 8'hff;

	


	case (curr_state_enc)

		SM_PREAMBLE: begin

			// On reading SOP 

			if (txhfifo_wstatus[`TXSTATUS_SOP] && txhfifo_wstatus[`TXSTATUS_VALID]) begin

				next_xgxs_txd = {`SFD, {6{`PREAMBLE}}, `START};
				next_xgxs_txc = 8'h01;

				next_state_enc = SM_TX;

			end
			else begin
				next_state_enc = SM_PREAMBLE;

			end



		end

		SM_TX: begin

			next_xgxs_txd = txhfifo_wdata_d1;
			next_xgxs_txc = 8'h00;



			// Wait for EOP indication to be read from the fifo, then
			// transition to next state.

			if (txhfifo_wstatus[`TXSTATUS_EOP]) begin
				
				next_state_enc = SM_EOP;

			end
			else if (txhfifo_wstatus[`TXSTATUS_SOP]) begin

				// Failure condition, we did not see EOP and there
				// is no more data in fifo or SOP, force end of packet transmit.
				next_state_enc = SM_TERM_FAIL;

			end

			next_eop[0] = txhfifo_wstatus[2:0] == 3'd1;
			next_eop[1] = txhfifo_wstatus[2:0] == 3'd2;
			next_eop[2] = txhfifo_wstatus[2:0] == 3'd3;
			next_eop[3] = txhfifo_wstatus[2:0] == 3'd4;
			next_eop[4] = txhfifo_wstatus[2:0] == 3'd5;
			next_eop[5] = txhfifo_wstatus[2:0] == 3'd6;
			next_eop[6] = txhfifo_wstatus[2:0] == 3'd7;
			next_eop[7] = txhfifo_wstatus[2:0] == 3'd0;
				
		end

		SM_EOP:
			begin

			// Insert TERMINATE character in correct lane depending on position
			// of EOP read from fifo. Also insert CRC read from control fifo.

			if (eop[0]) begin
				next_xgxs_txd = {{2{`IDLE}}, `TERMINATE, 
						crc32_tx[31:0], txhfifo_wdata_d1[7:0]};
				next_xgxs_txc = 8'b11100000;
			end

			else if (eop[1]) begin
				next_xgxs_txd = {`IDLE, `TERMINATE,
						crc32_tx[31:0], txhfifo_wdata_d1[15:0]};
				next_xgxs_txc = 8'b11000000;
			end

			else if (eop[2]) begin
				next_xgxs_txd = {`TERMINATE, crc32_tx[31:0], txhfifo_wdata_d1[23:0]};
				next_xgxs_txc = 8'b10000000;
			end

			else if (eop[3]) begin
				next_xgxs_txd = {crc32_tx[31:0], txhfifo_wdata_d1[31:0]};
				next_xgxs_txc = 8'b00000000;
			end

			else if (eop[4]) begin
				next_xgxs_txd = {crc32_tx[23:0], txhfifo_wdata_d1[39:0]};
				next_xgxs_txc = 8'b00000000;
			end

			else if (eop[5]) begin
				next_xgxs_txd = {crc32_tx[15:0], txhfifo_wdata_d1[47:0]};
				next_xgxs_txc = 8'b00000000;
			end

			else if (eop[6]) begin
				next_xgxs_txd = {crc32_tx[7:0], txhfifo_wdata_d1[55:0]};
				next_xgxs_txc = 8'b00000000;
			end

			else if (eop[7]) begin
				next_xgxs_txd = {txhfifo_wdata_d1[63:0]};
				next_xgxs_txc = 8'b00000000;
			end



			if (|eop[2:0]) begin

				if (!txhfifo_wstatus[`TXSTATUS_VALID]) begin

					next_state_enc = SM_PREAMBLE;

				end
			end

			if (|eop[7:3]) begin
				next_state_enc = SM_TERM;
			end

		end

		SM_TERM: begin

		// Insert TERMINATE character in correct lane depending on position
		// of EOP read from fifo. Also insert CRC read from control fifo.

			if (eop[3]) begin
				next_xgxs_txd = {{7{`IDLE}}, `TERMINATE};
				next_xgxs_txc = 8'b11111111;
			end

			else if (eop[4]) begin
				next_xgxs_txd = {{6{`IDLE}}, `TERMINATE, crc32_tx[31:24]};
				next_xgxs_txc = 8'b11111110;
			end

			else if (eop[5]) begin
				next_xgxs_txd = {{5{`IDLE}}, `TERMINATE, crc32_tx[31:16]};
				next_xgxs_txc = 8'b11111100;
			end

			else if (eop[6]) begin
				next_xgxs_txd = {{4{`IDLE}}, `TERMINATE, crc32_tx[31:8]};
				next_xgxs_txc = 8'b11111000;
			end

			else if (eop[7]) begin
				next_xgxs_txd = {{3{`IDLE}}, `TERMINATE, crc32_tx[31:0]};
				next_xgxs_txc = 8'b11110000;
			end

			next_state_enc = SM_PREAMBLE;


		end

		SM_TERM_FAIL: begin

			next_xgxs_txd = {{7{`IDLE}}, `TERMINATE};
			next_xgxs_txc = 8'b11111111;
			next_state_enc = SM_PREAMBLE;
		end


		default: begin

			next_state_enc = SM_PREAMBLE;
		end

	endcase

	end


always @(/*AS*//*crc32_d64 or txhfifo_wen or txhfifo_wstatus*/ *) begin

    if (txhfifo_wstatus[`TXSTATUS_SOP]) begin
        crc_data = 32'hffffffff;
    end
    else begin
        crc_data = crc32_d64;
    end
    
end



// ==================================== STATE_MACHINE FOR PADDING =========================


always @(/*AS*//*byte_cnt or curr_state_pad or txdfifo_rdata
         or txdfifo_rempty or txdfifo_ren_d1 or txdfifo_rstatus
         or txhfifo_walmost_full*/ *) begin

	next_state_pad = curr_state_pad;

	next_txhfifo_wdata = txdfifo_rdata;
	next_txhfifo_wstatus = txdfifo_rstatus;
	

	case (curr_state_pad)

	SM_PAD_EQ: begin


		if (txdfifo_rstatus[`TXSTATUS_VALID]) begin


              // On EOP, decide if padding is required for this packet.

			if (txdfifo_rstatus[`TXSTATUS_EOP]) begin
		
				if (byte_cnt < 14'd56) begin
					next_txhfifo_wstatus = `TXSTATUS_NONE;
					next_state_pad = SM_PAD_PAD;
				end
				else if (	byte_cnt == 14'd56 &&
					(txdfifo_rstatus[2:0] == 3'd1 ||
					txdfifo_rstatus[2:0] == 3'd2 ||
					txdfifo_rstatus[2:0] == 3'd3))
				begin

					// Pad up to LANE3, keep the other 4 bytes for crc that will
					// be inserted by dequeue engine.
					
					next_txhfifo_wstatus[2:0] = 3'd4;

					// Pad end bytes with zeros.

					if (txdfifo_rstatus[2:0] == 3'd1)
						next_txhfifo_wdata[31:8] = 24'b0;
					if (txdfifo_rstatus[2:0] == 3'd2)
						next_txhfifo_wdata[31:16] = 16'b0;
					if (txdfifo_rstatus[2:0] == 3'd3)
						next_txhfifo_wdata[31:24] = 8'b0;
				end
                  

			end
        
		end

	end

	SM_PAD_PAD: begin

          //---
          // Pad packet to 64 bytes by writting zeros to holding fifo.

         

		next_txhfifo_wdata = 64'b0;
		next_txhfifo_wstatus = `TXSTATUS_NONE;
		
		if (byte_cnt == 14'd56) begin

			// Pad up to LANE3, keep the other 4 bytes for crc that will
			// be inserted by dequeue engine.

			next_txhfifo_wstatus[`TXSTATUS_EOP] = 1'b1;
			next_txhfifo_wstatus[2:0] = 3'd4;

			next_state_pad = SM_PAD_EQ;

		end

	end

	default: begin

		next_state_pad = SM_PAD_EQ;
	end

	endcase

end


endmodule

