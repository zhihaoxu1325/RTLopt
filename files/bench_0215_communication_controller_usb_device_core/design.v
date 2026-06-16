// Curated RTL benchmark case.
// case_id: bench_0215_communication_controller_usb_device_core
// source_project: communication_controller_usb_device_core
// top_module: usbf_device


// -----------------------------------------------------------------------------
// Source file: rtl/usbf_device.v
// -----------------------------------------------------------------------------
//-----------------------------------------------------------------
//                       USB Device Core
//                           V0.1
//                     Ultra-Embedded.com
//                       Copyright 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2013 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: USB device core (top)
//-----------------------------------------------------------------
module usbf_device
(
    // Clocking (48MHz) & Reset
    input               clk_i /*verilator public*/,
    input               rst_i /*verilator public*/,

    // Interrupt output
    output              intr_o /*verilator public*/,
    
    // Peripheral Interface (from CPU)
    input [7:0]         addr_i /*verilator public*/,
    input [31:0]        data_i /*verilator public*/,
    output [31:0]       data_o /*verilator public*/,
    input               we_i /*verilator public*/,
    input               stb_i /*verilator public*/,

    // USB Transceiver Interface
    output              usb_vmo_o /*verilator public*/,
    output              usb_vpo_o /*verilator public*/,
    output              usb_oe_o /*verilator public*/,
    input               usb_rx_i /*verilator public*/,
    input               usb_vp_i /*verilator public*/,
    input               usb_vm_i /*verilator public*/,
    output              usb_speed_o /*verilator public*/,
    output              usb_susp_o /*verilator public*/,
    output              usb_mode_o /*verilator public*/,
    output              usb_en_o /*verilator public*/
);

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
wire [7:0]              utmi_data_w;
wire [7:0]              utmi_data_r;
wire                    utmi_txvalid;
wire                    utmi_txready;
wire                    utmi_rxvalid;
wire                    utmi_rxactive;
wire                    utmi_rxerror;
wire [1:0]              utmi_linestate;

wire                    usb_oen;
wire                    usb_tx_p;
wire                    usb_tx_n;
wire                    usb_rx_p;
wire                    usb_rx_n;
wire                    usb_rx;
wire                    usb_rst;

wire                    nrst;

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------
usbf_sie
usb
(
    // Clocking (48MHz) & Reset
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Interrupt output
    .intr_o(intr_o),
    
    // Peripheral Interface (from CPU)
    .addr_i(addr_i),
    .data_i(data_i),
    .data_o(data_o),
    .we_i(we_i),
    .stb_i(stb_i),

    // UTMI interface
    .utmi_rst_i(usb_rst),
    .utmi_data_w(utmi_data_w),
    .utmi_data_r(utmi_data_r),
    .utmi_txvalid_o(utmi_txvalid),
    .utmi_txready_i(utmi_txready),
    .utmi_rxvalid_i(utmi_rxvalid),
    .utmi_rxactive_i(utmi_rxactive),
    .utmi_rxerror_i(utmi_rxerror),
    .utmi_linestate_i(utmi_linestate),

    // Pull-up enable
    .usb_en_o(usb_en_o)    
);

// USB-PHY module (UTMI->PHY interface)
usb_phy
u_phy
(
    // Clock (48MHz) & reset
    .clk(clk_i),
    .rst(nrst),

    // PHY Transmit Mode:
    // When phy_tx_mode_i is '0' the outputs are encoded as:
    //  TX- TX+
    //      0    0    Differential Logic '0'
    //      0    1    Differential Logic '1'
    //      1    0    Single Ended '0'
    //      1    1    Single Ended '0'
    // When phy_tx_mode_i is '1' the outputs are encoded as:
    //  TX- TX+
    //      0    0    Single Ended '0'
    //      0    1    Differential Logic '1'
    //      1    0    Differential Logic '0'
    //      1    1    Illegal State
    .phy_tx_mode_i(1'b0),

    // USB bus reset event
    .usb_rst_o(usb_rst),
    .usb_rst_i(1'b0),

    // Transciever Interface
    // Tx +/-
    .tx_dp_o(usb_tx_p),
    .tx_dn_o(usb_tx_n),

    // Tx output enable (active low)
    .tx_oen_o(usb_oen),

    // Receive data
    .rx_rcv_i(usb_rx),

    // Rx +/-
    .rx_dp_i(usb_rx_p),
    .rx_dn_i(usb_rx_n),

    // UTMI Interface

    // Transmit data [7:0]
    .utmi_data_i(utmi_data_w),

    // Transmit data enable
    .utmi_txvalid_i(utmi_txvalid),

    // Transmit ready (L=hold,H=load data)
    .utmi_txready_o(utmi_txready),

    // Receive data [7:0]
    .utmi_data_o(utmi_data_r),

    // Valid data on utmi_data_o
    .utmi_rxvalid_o(utmi_rxvalid),

    // Receive active (SYNC recieved)
    .utmi_rxactive_o(utmi_rxactive),

    // Rx error occurred
    .utmi_rxerror_o(utmi_rxerror),

    // Receive line state [1=RX-, 0=RX+]
    .utmi_linestate_o(utmi_linestate)
);

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign usb_rx       = usb_rx_i;
assign usb_rx_p     = usb_vp_i;
assign usb_rx_n     = usb_vm_i;
assign usb_vpo_o    = usb_tx_p;
assign usb_vmo_o    = usb_tx_n;
assign usb_oe_o     = usb_oen;

assign usb_mode_o   = 1'b0;
assign usb_speed_o  = 1'b1;
assign usb_susp_o   = 1'b0;

assign nrst         = !rst_i;

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/phy/usb_phy.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 PHY                                                ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb_phy/   ////
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

//-----------------------------------------------------------------
// Module:
//-----------------------------------------------------------------
module usb_phy
(
    // Clock (48MHz) & reset
    clk, 
    rst, 
    
    // PHY Transmit Mode:
    // When phy_tx_mode_i is '0' the outputs are encoded as:
    //  TX- TX+
    // 	 0	0	Differential Logic '0'
    // 	 0	1	Differential Logic '1'
    // 	 1	0	Single Ended '0'
    // 	 1	1	Single Ended '0'
    // When phy_tx_mode_i is '1' the outputs are encoded as:
    //  TX- TX+
    // 	 0	0	Single Ended '0'
    // 	 0	1	Differential Logic '1'
    // 	 1	0	Differential Logic '0'
    // 	 1	1	Illegal State
    phy_tx_mode_i, 
    
    // USB bus reset event
    usb_rst_o,
    usb_rst_i,
	
	// Transciever Interface
	// Tx +/-
	tx_dp_o, 
	tx_dn_o, 
	
	// Tx output enable (active low)
	tx_oen_o,
	
	// Receive data
	rx_rcv_i, 
	
	// Rx +/-
	rx_dp_i, 
	rx_dn_i,

	// UTMI Interface
	
	// Transmit data [7:0]
	utmi_data_i, 
	
	// Transmit data enable
	utmi_txvalid_i, 
	
	// Transmit ready (L=hold,H=load data)
	utmi_txready_o, 
	
	// Receive data [7:0]
	utmi_data_o, 
	
	// Valid data on utmi_data_o
	utmi_rxvalid_o,
	
	// Receive active (SYNC recieved)
	utmi_rxactive_o, 
	
	// Rx error occurred
	utmi_rxerror_o, 	
	
	// Receive line state [1=RX-, 0=RX+]
	utmi_linestate_o
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------  
input		clk;
input		rst;
input		phy_tx_mode_i;
output		usb_rst_o;
input		usb_rst_i;
output		tx_dp_o, tx_dn_o, tx_oen_o;
input		rx_rcv_i, rx_dp_i, rx_dn_i;
input	[7:0]	utmi_data_i;
input		utmi_txvalid_i;
output		utmi_txready_o;
output	[7:0]	utmi_data_o;
output		utmi_rxvalid_o;
output		utmi_rxactive_o;
output		utmi_rxerror_o;
output	[1:0]	utmi_linestate_o;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg	[4:0]	rst_cnt;
reg		    usb_rst_o;
wire		fs_ce;
wire		rst;

wire        tx_dp_int;
wire        tx_dn_int;
wire        tx_oen_int;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

///////////////////////////////////////////////////////////////////
//
// TX Phy
//

usb_tx_phy i_tx_phy(
	.clk(		clk		),
	.rst(		rst		),
	.fs_ce(		fs_ce		),
	.phy_mode(	phy_tx_mode_i ),

	// Transciever Interface
	.txdp(		tx_dp_int		),
	.txdn(		tx_dn_int		),
	.txoe(		tx_oen_int		),

	// UTMI Interface
	.DataOut_i(	utmi_data_i	),
	.TxValid_i(	utmi_txvalid_i	),
	.TxReady_o(	utmi_txready_o	)
	);

///////////////////////////////////////////////////////////////////
//
// RX Phy and DPLL
//

usb_rx_phy i_rx_phy(
	.clk(		clk		),
	.rst(		rst		),
	.fs_ce(		fs_ce		),

	// Transciever Interface
	.rxd(		rx_rcv_i		),
	.rxdp(		rx_dp_i		),
	.rxdn(		rx_dn_i		),

	// UTMI Interface
	.DataIn_o(	utmi_data_o	),
	.RxValid_o(	utmi_rxvalid_o	),
	.RxActive_o(	utmi_rxactive_o	),
	.RxError_o(	utmi_rxerror_o	),
	.RxEn_i(	tx_oen_o		),
	.LineState(	utmi_linestate_o	)
	);

///////////////////////////////////////////////////////////////////
//
// Generate an USB Reset is we see SE0 for at least 2.5uS
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)			rst_cnt <= 5'h0;
	else
	if(utmi_linestate_o != 2'h0)  rst_cnt <= 5'h0;
	else	
	if(!usb_rst_o && fs_ce)		rst_cnt <= rst_cnt + 5'h1;

`ifdef CONF_TARGET_SIM
// Disable RST_O
always @(posedge clk)
	usb_rst_o <= 1'b0;
`else
always @(posedge clk)
	usb_rst_o <= (rst_cnt == 5'h1f);
`endif
	
// Host generate USB reset event (SE0)
assign tx_dp_o  = usb_rst_i ? 1'b0 : tx_dp_int;
assign tx_dn_o  = usb_rst_i ? 1'b1 : tx_dn_int;
assign tx_oen_o = usb_rst_i ? 1'b0 : tx_oen_int;
	
endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/phy/usb_rx_phy.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 PHY                                                ////
////  RX & DPLL                                                  ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb_phy/   ////
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
//  $Id: usb_rx_phy.v,v 1.5 2004-10-19 09:29:07 rudi Exp $
//
//  $Date: 2004-10-19 09:29:07 $
//  $Revision: 1.5 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.4  2003/12/02 04:56:00  rudi
//               Fixed a bug reported by Karl C. Posch from Graz University of Technology. Thanks Karl !
//
//               Revision 1.3  2003/10/19 18:07:45  rudi
//               - Fixed Sync Error to be only checked/generated during the sync phase
//
//               Revision 1.2  2003/10/19 17:40:13  rudi
//               - Made core more robust against line noise
//               - Added Error Checking and Reporting
//               (See README.txt for more info)
//
//               Revision 1.1.1.1  2002/09/16 14:27:01  rudi
//               Created Directory Structure
//
//
//
//
//
//
//
//

module usb_rx_phy(	clk, rst, fs_ce,
	
			// Transciever Interface
			rxd, rxdp, rxdn,

			// UTMI Interface
			RxValid_o, RxActive_o, RxError_o, DataIn_o,
			RxEn_i, LineState);

input		clk;
input		rst;
output		fs_ce;
input		rxd, rxdp, rxdn;
output	[7:0]	DataIn_o;
output		RxValid_o;
output		RxActive_o;
output		RxError_o;
input		RxEn_i;
output	[1:0]	LineState;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg		rxd_s0, rxd_s1,  rxd_s;
reg		rxdp_s0, rxdp_s1, rxdp_s, rxdp_s_r;
reg		rxdn_s0, rxdn_s1, rxdn_s, rxdn_s_r;
reg		synced_d;
wire		k, j, se0;
reg		rxd_r;
reg		rx_en;
reg		rx_active;
reg	[2:0]	bit_cnt;
reg		rx_valid1, rx_valid;
reg		shift_en;
reg		sd_r;
reg		sd_nrzi;
reg	[7:0]	hold_reg;
wire		drop_bit;	// Indicates a stuffed bit
reg	[2:0]	one_cnt;

reg	[1:0]	dpll_state, dpll_next_state;
reg		fs_ce_d;
reg		fs_ce;
wire		change;
wire		lock_en;
reg	[2:0]	fs_state, fs_next_state;
reg		rx_valid_r;
reg		sync_err_d, sync_err;
reg		bit_stuff_err;
reg		se0_r, byte_err;
reg		se0_s;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign RxActive_o = rx_active;
assign RxValid_o = rx_valid;
assign RxError_o = sync_err | bit_stuff_err | byte_err;
assign DataIn_o = hold_reg;
assign LineState = {rxdn_s1, rxdp_s1};

always @(posedge clk)	rx_en <= RxEn_i;
always @(posedge clk)	sync_err <= !rx_active & sync_err_d;

///////////////////////////////////////////////////////////////////
//
// Synchronize Inputs
//

// First synchronize to the local system clock to
// avoid metastability outside the sync block (*_s0).
// Then make sure we see the signal for at least two
// clock cycles stable to avoid glitches and noise

always @(posedge clk)	rxd_s0  <= rxd;
always @(posedge clk)	rxd_s1  <= rxd_s0;
always @(posedge clk)							// Avoid detecting Line Glitches and noise
	if(rxd_s0 && rxd_s1)	rxd_s <= 1'b1;
	else
	if(!rxd_s0 && !rxd_s1)	rxd_s <= 1'b0;

always @(posedge clk)	rxdp_s0  <= rxdp;
always @(posedge clk)	rxdp_s1  <= rxdp_s0;
always @(posedge clk)	rxdp_s_r <= rxdp_s0 & rxdp_s1;
always @(posedge clk)	rxdp_s   <= (rxdp_s0 & rxdp_s1) | rxdp_s_r;	// Avoid detecting Line Glitches and noise

always @(posedge clk)	rxdn_s0  <= rxdn;
always @(posedge clk)	rxdn_s1  <= rxdn_s0;
always @(posedge clk)	rxdn_s_r <= rxdn_s0 & rxdn_s1;
always @(posedge clk)	rxdn_s   <= (rxdn_s0 & rxdn_s1) | rxdn_s_r;	// Avoid detecting Line Glitches and noise

assign k = !rxdp_s &  rxdn_s;
assign j =  rxdp_s & !rxdn_s;
assign se0 = !rxdp_s & !rxdn_s;

always @(posedge clk)	if(fs_ce)	se0_s <= se0;

///////////////////////////////////////////////////////////////////
//
// DPLL
//

// This design uses a clock enable to do 12Mhz timing and not a
// real 12Mhz clock. Everything always runs at 48Mhz. We want to
// make sure however, that the clock enable is always exactly in
// the middle between two virtual 12Mhz rising edges.
// We monitor rxdp and rxdn for any changes and do the appropiate
// adjustments.
// In addition to the locking done in the dpll FSM, we adjust the
// final latch enable to compensate for various sync registers ...

// Allow lockinf only when we are receiving
assign	lock_en = rx_en;

always @(posedge clk)	rxd_r <= rxd_s;

// Edge detector
assign change = rxd_r != rxd_s;

// DPLL FSM
`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	dpll_state <= 2'h1;
	else		dpll_state <= dpll_next_state;

always @(dpll_state or lock_en or change)
   begin
	fs_ce_d = 1'b0;
	case(dpll_state)	// synopsys full_case parallel_case
	   2'h0:
		if(lock_en && change)	dpll_next_state = 2'h0;
		else			dpll_next_state = 2'h1;
	   2'h1:begin
		fs_ce_d = 1'b1;
		if(lock_en && change)	dpll_next_state = 2'h3;
		else			dpll_next_state = 2'h2;
		end
	   2'h2:
		if(lock_en && change)	dpll_next_state = 2'h0;
		else			dpll_next_state = 2'h3;
	   2'h3:
		if(lock_en && change)	dpll_next_state = 2'h0;
		else			dpll_next_state = 2'h0;
	endcase
   end

// Compensate for sync registers at the input - allign full speed
// clock enable to be in the middle between two bit changes ...
reg	fs_ce_r1, fs_ce_r2;

always @(posedge clk)	fs_ce_r1 <= fs_ce_d;
always @(posedge clk)	fs_ce_r2 <= fs_ce_r1;
always @(posedge clk)	fs_ce <= fs_ce_r2;


///////////////////////////////////////////////////////////////////
//
// Find Sync Pattern FSM
//

parameter	FS_IDLE	= 3'h0,
		K1	= 3'h1,
		J1	= 3'h2,
		K2	= 3'h3,
		J2	= 3'h4,
		K3	= 3'h5,
		J3	= 3'h6,
		K4	= 3'h7;

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	fs_state <= FS_IDLE;
	else		fs_state <= fs_next_state;

always @(fs_state or fs_ce or k or j or rx_en or rx_active or se0 or se0_s)
   begin
	synced_d = 1'b0;
	sync_err_d = 1'b0;
	fs_next_state = fs_state;
	if(fs_ce && !rx_active && !se0 && !se0_s)
	   case(fs_state)	// synopsys full_case parallel_case
		FS_IDLE:
		     begin
			if(k && rx_en)	fs_next_state = K1;
		     end
		K1:
		     begin
			if(j && rx_en)	fs_next_state = J1;
			else
			   begin
					sync_err_d = 1'b1;
					fs_next_state = FS_IDLE;
			   end
		     end
		J1:
		     begin
			if(k && rx_en)	fs_next_state = K2;
			else
			   begin
					sync_err_d = 1'b1;
					fs_next_state = FS_IDLE;
			   end
		     end
		K2:
		     begin
			if(j && rx_en)	fs_next_state = J2;
			else
			   begin
					sync_err_d = 1'b1;
					fs_next_state = FS_IDLE;
			   end
		     end
		J2:
		     begin
			if(k && rx_en)	fs_next_state = K3;
			else
			   begin
					sync_err_d = 1'b1;
					fs_next_state = FS_IDLE;
			   end
		     end
		K3:
		     begin
			if(j && rx_en)	fs_next_state = J3;
			else
			if(k && rx_en)
			   begin
					fs_next_state = FS_IDLE;	// Allow missing first K-J
					synced_d = 1'b1;
			   end
			else
			   begin
					sync_err_d = 1'b1;
					fs_next_state = FS_IDLE;
			   end
		     end
		J3:
		     begin
			if(k && rx_en)	fs_next_state = K4;
			else
			   begin
					sync_err_d = 1'b1;
					fs_next_state = FS_IDLE;
			   end
		     end
		K4:
		     begin
			if(k)	synced_d = 1'b1;
			fs_next_state = FS_IDLE;
		     end
	   endcase
   end

///////////////////////////////////////////////////////////////////
//
// Generate RxActive
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)		rx_active <= 1'b0;
	else
	if(synced_d && rx_en)	rx_active <= 1'b1;
	else
	if(se0 && rx_valid_r)	rx_active <= 1'b0;

always @(posedge clk)
	if(rx_valid)	rx_valid_r <= 1'b1;
	else
	if(fs_ce)	rx_valid_r <= 1'b0;

///////////////////////////////////////////////////////////////////
//
// NRZI Decoder
//

always @(posedge clk)
	if(fs_ce)	sd_r <= rxd_s;

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)		sd_nrzi <= 1'b0;
	else
	if(!rx_active)		sd_nrzi <= 1'b1;
	else
	if(rx_active && fs_ce)	sd_nrzi <= !(rxd_s ^ sd_r);

///////////////////////////////////////////////////////////////////
//
// Bit Stuff Detect
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	one_cnt <= 3'h0;
	else
	if(!shift_en)	one_cnt <= 3'h0;
	else
	if(fs_ce)
	   begin
		if(!sd_nrzi || drop_bit)	one_cnt <= 3'h0;
		else				one_cnt <= one_cnt + 3'h1;
	   end

assign drop_bit = (one_cnt==3'h6);

always @(posedge clk)	bit_stuff_err <= drop_bit & sd_nrzi & fs_ce & !se0 & rx_active; // Bit Stuff Error

///////////////////////////////////////////////////////////////////
//
// Serial => Parallel converter
//

always @(posedge clk)
	if(fs_ce)	shift_en <= synced_d | rx_active;

always @(posedge clk)
	if(fs_ce && shift_en && !drop_bit)
		hold_reg <= {sd_nrzi, hold_reg[7:1]};

///////////////////////////////////////////////////////////////////
//
// Generate RxValid
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)		bit_cnt <= 3'b0;
	else
	if(!shift_en)		bit_cnt <= 3'h0;
	else
	if(fs_ce && !drop_bit)	bit_cnt <= bit_cnt + 3'h1;

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)					rx_valid1 <= 1'b0;
	else
	if(fs_ce && !drop_bit && (bit_cnt==3'h7))	rx_valid1 <= 1'b1;
	else
	if(rx_valid1 && fs_ce && !drop_bit)		rx_valid1 <= 1'b0;

always @(posedge clk)	rx_valid <= !drop_bit & rx_valid1 & fs_ce;

always @(posedge clk)	se0_r <= se0;

always @(posedge clk)	byte_err <= se0 & !se0_r & (|bit_cnt[2:1]) & rx_active;

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/phy/usb_tx_phy.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 PHY                                                ////
////  TX                                                         ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb_phy/   ////
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
//  $Id: usb_tx_phy.v,v 1.4 2004-10-19 09:29:07 rudi Exp $
//
//  $Date: 2004-10-19 09:29:07 $
//  $Revision: 1.4 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.3  2003/10/21 05:58:41  rudi
//               usb_rst is no longer or'ed with the incomming reset internally.
//               Now usb_rst is simply an output, the application can decide how
//               to utilize it.
//
//               Revision 1.2  2003/10/19 17:40:13  rudi
//               - Made core more robust against line noise
//               - Added Error Checking and Reporting
//               (See README.txt for more info)
//
//               Revision 1.1.1.1  2002/09/16 14:27:02  rudi
//               Created Directory Structure
//
//
//
//
//
//
//

module usb_tx_phy(
		clk, rst, fs_ce, phy_mode,
	
		// Transciever Interface
		txdp, txdn, txoe,	

		// UTMI Interface
		DataOut_i, TxValid_i, TxReady_o
		);

input		clk;
input		rst;
input		fs_ce;
input		phy_mode;
output		txdp, txdn, txoe;
input	[7:0]	DataOut_i;
input		TxValid_i;
output		TxReady_o;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

parameter IDLE	= 3'd0;
parameter SOP	= 3'h1;
parameter DATA	= 3'h2;
parameter EOP	= 3'h3;

reg		TxReady_o;
reg	[2:0]	state, next_state;
reg		tx_ready_d;
reg		ld_sop_d;
reg		ld_data_d;
reg		ld_eop_d;
reg		tx_ip;
reg		tx_ip_sync;
reg	[2:0]	bit_cnt;
reg	[7:0]	hold_reg;
reg	[7:0]	hold_reg_d;

reg	[2:0]	eop_cnt;
wire    eop_done;

reg		sd_raw_o;
wire		hold;
reg		data_done;
reg		sft_done;
reg		sft_done_r;
wire		sft_done_e;
reg		ld_data;
reg	[2:0]	one_cnt;
wire		stuff;
reg		sd_bs_o;
reg		sd_nrzi_o;
reg		txdp, txdn;
reg		txoe_r1, txoe_r2;
reg		txoe;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	TxReady_o <= 1'b0;
	else		TxReady_o <= tx_ready_d & TxValid_i;

always @(posedge clk) ld_data <= ld_data_d;

///////////////////////////////////////////////////////////////////
//
// Transmit in progress indicator
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	tx_ip <= 1'b0;
	else
	if(ld_sop_d)	tx_ip <= 1'b1;
	else
	if(eop_done)	tx_ip <= 1'b0;

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)		tx_ip_sync <= 1'b0;
	else
	if(fs_ce)		tx_ip_sync <= tx_ip;

// data_done helps us to catch cases where TxValid drops due to
// packet end and then gets re-asserted as a new packet starts.
// We might not see this because we are still transmitting.
// data_done should solve those cases ...
`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)			data_done <= 1'b0;
	else
	if(TxValid_i && ! tx_ip)	data_done <= 1'b1;
	else
	if(!TxValid_i)			data_done <= 1'b0;

///////////////////////////////////////////////////////////////////
//
// Shift Register
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)		
	begin
	    bit_cnt <= 3'h0;
	end
	else
	if(!tx_ip_sync)		bit_cnt <= 3'h0;
	else
	if(fs_ce && !hold)
	begin	
	    bit_cnt <= bit_cnt + 3'h1;
	end

assign hold = stuff;

always @(posedge clk)
	if(!tx_ip_sync)		
	begin
	    sd_raw_o <= 1'b0;
	end
	else
	begin
	case(bit_cnt)	// synopsys full_case parallel_case
	   3'h0: sd_raw_o <= hold_reg_d[0];
	   3'h1: sd_raw_o <= hold_reg_d[1];
	   3'h2: sd_raw_o <= hold_reg_d[2];
	   3'h3: sd_raw_o <= hold_reg_d[3];
	   3'h4: sd_raw_o <= hold_reg_d[4];
	   3'h5: sd_raw_o <= hold_reg_d[5];
	   3'h6: sd_raw_o <= hold_reg_d[6];
	   3'h7: sd_raw_o <= hold_reg_d[7];
	endcase
	
`ifdef CONF_DISPLAY_USB_TX	
	if (fs_ce)
    case(bit_cnt)	// synopsys full_case parallel_case
	   3'h0: $display("\nTx0=%01d", hold_reg_d[0]);
	   3'h1: $display("Tx1=%01d", hold_reg_d[1]);
	   3'h2: $display("Tx2=%01d", hold_reg_d[2]);
	   3'h3: $display("Tx3=%01d", hold_reg_d[3]);
	   3'h4: $display("Tx4=%01d", hold_reg_d[4]);
	   3'h5: $display("Tx5=%01d", hold_reg_d[5]);
	   3'h6: $display("Tx6=%01d", hold_reg_d[6]);
	   3'h7: $display("Tx7=%01d", hold_reg_d[7]);
	endcase
`endif	
		
	end

always @(posedge clk)
	sft_done <= !hold & (bit_cnt == 3'h7);

always @(posedge clk)
	sft_done_r <= sft_done;

assign sft_done_e = sft_done & !sft_done_r;

// Out Data Hold Register
always @(posedge clk)
	if(ld_sop_d)	hold_reg <= 8'h80;
	else
	if(ld_data)	hold_reg <= DataOut_i;

always @(posedge clk) hold_reg_d <= hold_reg;

///////////////////////////////////////////////////////////////////
//
// Bit Stuffer
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	one_cnt <= 3'h0;
	else
	if(!tx_ip_sync)	one_cnt <= 3'h0;
	else
	if(fs_ce)
	   begin
		if(!sd_raw_o || stuff)	one_cnt <= 3'h0;
		else			one_cnt <= one_cnt + 3'h1;
	   end

assign stuff = (one_cnt==3'h6);

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	sd_bs_o <= 1'h0;
	else
	if(fs_ce)	sd_bs_o <= !tx_ip_sync ? 1'b0 : (stuff ? 1'b0 : sd_raw_o);

///////////////////////////////////////////////////////////////////
//
// NRZI Encoder
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)			sd_nrzi_o <= 1'b1;
	else
	if(!tx_ip_sync || !txoe_r1)	sd_nrzi_o <= 1'b1;
	else
	if(fs_ce)			sd_nrzi_o <= sd_bs_o ? sd_nrzi_o : ~sd_nrzi_o;

///////////////////////////////////////////////////////////////////
//
// EOP append logic
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	
	begin
	    eop_cnt <= 3'b000;
	end
	else
	begin
	    if (ld_eop_d)
	        eop_cnt <= 3'b001;
	    else if(fs_ce && eop_cnt != 3'b000)	
	    begin
	        if (stuff && eop_cnt == 3'b010)
	            eop_cnt <= eop_cnt;
	        else
	            eop_cnt <= eop_cnt + 1;
	    end
    end	    


assign eop_done = (eop_cnt == 3'h4 || eop_cnt == 3'h5) ? 1'b1 : 1'b0;

///////////////////////////////////////////////////////////////////
//
// Output Enable Logic
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	txoe_r1 <= 1'b0;
	else
	if(fs_ce)	txoe_r1 <= tx_ip_sync;

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	txoe_r2 <= 1'b0;
	else
	if(fs_ce)	txoe_r2 <= txoe_r1;

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	txoe <= 1'b1;
	else
	if(fs_ce)	txoe <= !(txoe_r1 | txoe_r2);

///////////////////////////////////////////////////////////////////
//
// Output Registers
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	txdp <= 1'b1;
	else
	if(fs_ce)	txdp <= phy_mode ?
						(!eop_done &  sd_nrzi_o) : sd_nrzi_o;

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	txdn <= 1'b0;
	else
	begin
	    if(fs_ce)	
	            txdn <= phy_mode ?
						(!eop_done & ~sd_nrzi_o) : eop_done;
	end

///////////////////////////////////////////////////////////////////
//
// Tx state machine
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)	state <= IDLE;
	else		state <= next_state;

always @(state or TxValid_i or data_done or sft_done_e or  fs_ce or eop_cnt)
   begin
	next_state = state;
	tx_ready_d = 1'b0;

	ld_sop_d = 1'b0;
	ld_data_d = 1'b0;
	ld_eop_d = 1'b0;

	case(state)	// synopsys full_case parallel_case
	   IDLE:
			if(TxValid_i)
			   begin
				ld_sop_d = 1'b1;
				next_state = SOP;
			   end
	   SOP:
			if(sft_done_e)
			   begin
				tx_ready_d = 1'b1;
				ld_data_d = 1'b1;
				next_state = DATA;
			   end
	   DATA:
		   begin
			if(!data_done && sft_done_e)
			   begin
				ld_eop_d = 1'b1;
				next_state = EOP;
			   end
			
			if(data_done && sft_done_e)
			   begin
				tx_ready_d = 1'b1;
				ld_data_d = 1'b1;
			   end
		   end
	   EOP:
			if(fs_ce && eop_cnt == 3'h7) 
			    next_state = IDLE;
       default :
            next_state = IDLE;
	endcase
   end

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/usbf_crc16.v
// -----------------------------------------------------------------------------
//-----------------------------------------------------------------
//                       USB Device Core
//                           V0.1
//                     Ultra-Embedded.com
//                       Copyright 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2013 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: 16-bit CRC used by USB data packets
//-----------------------------------------------------------------
module usbf_crc16
(
    input    [15:0]    crc_in,
    input    [7:0]     din,
    output   [15:0]    crc_out
);

//-----------------------------------------------------------------
// Logic
//-----------------------------------------------------------------
assign crc_out[15] =    din[0] ^ din[1] ^ din[2] ^ din[3] ^ din[4] ^ din[5] ^ din[6] ^ din[7] ^ 
                        crc_in[7] ^ crc_in[6] ^ crc_in[5] ^ crc_in[4] ^ crc_in[3] ^ crc_in[2] ^ crc_in[1] ^ crc_in[0];
assign crc_out[14] =    din[0] ^ din[1] ^ din[2] ^ din[3] ^ din[4] ^ din[5] ^ din[6] ^
                        crc_in[6] ^ crc_in[5] ^ crc_in[4] ^ crc_in[3] ^ crc_in[2] ^ crc_in[1] ^ crc_in[0];
assign crc_out[13] =    din[6] ^ din[7] ^ 
                        crc_in[7] ^ crc_in[6];
assign crc_out[12] =    din[5] ^ din[6] ^ 
                        crc_in[6] ^ crc_in[5];
assign crc_out[11] =    din[4] ^ din[5] ^ 
                        crc_in[5] ^ crc_in[4];
assign crc_out[10] =    din[3] ^ din[4] ^ 
                        crc_in[4] ^ crc_in[3];
assign crc_out[9] =     din[2] ^ din[3] ^ 
                        crc_in[3] ^ crc_in[2];
assign crc_out[8] =     din[1] ^ din[2] ^ 
                        crc_in[2] ^ crc_in[1];
assign crc_out[7] =     din[0] ^ din[1] ^ 
                        crc_in[15] ^ crc_in[1] ^ crc_in[0];
assign crc_out[6] =     din[0] ^ 
                        crc_in[14] ^ crc_in[0];
assign crc_out[5] =     crc_in[13];
assign crc_out[4] =     crc_in[12];
assign crc_out[3] =     crc_in[11];
assign crc_out[2] =     crc_in[10];
assign crc_out[1] =     crc_in[9];
assign crc_out[0] =     din[0] ^ din[1] ^ din[2] ^ din[3] ^ din[4] ^ din[5] ^ din[6] ^ din[7] ^
                        crc_in[8] ^ crc_in[7] ^ crc_in[6] ^ crc_in[5] ^ crc_in[4] ^ crc_in[3] ^ crc_in[2] ^ crc_in[1] ^ crc_in[0];

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/usbf_fifo.v
// -----------------------------------------------------------------------------
//-----------------------------------------------------------------
//                       USB Device Core
//                           V0.1
//                     Ultra-Embedded.com
//                       Copyright 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2013 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: USB FIFO - simple FIFO
//-----------------------------------------------------------------
module usbf_fifo
(
    clk_i,
    rst_i,

    data_i,
    push_i,

    full_o,
    empty_o,

    data_o,
    pop_i,

    flush_i
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter               WIDTH   = 8;
parameter               DEPTH   = 4;
parameter               ADDR_W  = 2;
parameter               COUNT_W = ADDR_W + 1;

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------
input                   clk_i /*verilator public*/;
input                   rst_i /*verilator public*/;
input [WIDTH-1:0]       data_i /*verilator public*/;
input                   push_i /*verilator public*/;
output                  full_o /*verilator public*/;
output                  empty_o /*verilator public*/;
output [WIDTH-1:0]      data_o /*verilator public*/;
input                   pop_i /*verilator public*/;
input                   flush_i /*verilator public*/;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [WIDTH-1:0]         ram [DEPTH-1:0];
reg [ADDR_W-1:0]        rd_ptr;
reg [ADDR_W-1:0]        wr_ptr;
reg [COUNT_W-1:0]       count;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
    if (rst_i == 1'b1)
    begin
        count   <= {(COUNT_W) {1'b0}};
        rd_ptr  <= {(ADDR_W) {1'b0}};
        wr_ptr  <= {(ADDR_W) {1'b0}};
    end
    else
    begin

        if (flush_i)
        begin
            count   <= {(COUNT_W) {1'b0}};
            rd_ptr  <= {(ADDR_W) {1'b0}};
            wr_ptr  <= {(ADDR_W) {1'b0}};
        end

        // Push
        if (push_i & ~full_o)
        begin
            ram[wr_ptr] <= data_i;
            wr_ptr      <= wr_ptr + 1;
        end

        // Pop
        if (pop_i & ~empty_o)
        begin
            rd_ptr      <= rd_ptr + 1;
        end

        // Count up
        if ((push_i & ~full_o) & ~(pop_i & ~empty_o))
        begin
            count <= count + 1;
        end
        // Count down
        else if (~(push_i & ~full_o) & (pop_i & ~empty_o))
        begin
            count <= count - 1;
        end
    end
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
assign full_o    = (count == DEPTH);
assign empty_o   = (count == 0);

assign data_o    = ram[rd_ptr];

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/usbf_sie.v
// -----------------------------------------------------------------------------
//-----------------------------------------------------------------
//                       USB Device Core
//                           V0.1
//                     Ultra-Embedded.com
//                       Copyright 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2013 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
//              !!!! This file is auto generated !!!!
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module: Simplified USB device serial interface engine
//-----------------------------------------------------------------
module usbf_sie
(
    // Clocking (48MHz) & Reset
    input  wire           clk_i /*verilator public*/,
    input  wire           rst_i /*verilator public*/,

    // Interrupt output
    output reg            intr_o /*verilator public*/,

    // Peripheral Interface
    input  wire [7:0]     addr_i /*verilator public*/,
    input  wire [31:0]    data_i /*verilator public*/,
    output reg [31:0]     data_o /*verilator public*/,
    input  wire           we_i /*verilator public*/,
    input  wire           stb_i /*verilator public*/,

    // UTMI interface
    input  wire           utmi_rst_i /*verilator public*/,
    output wire [7:0]     utmi_data_w /*verilator public*/,
    input  wire [7:0]     utmi_data_r /*verilator public*/,
    output reg            utmi_txvalid_o /*verilator public*/,
    input  wire           utmi_txready_i /*verilator public*/,
    input  wire           utmi_rxvalid_i /*verilator public*/,
    input  wire           utmi_rxactive_i /*verilator public*/,
    input  wire           utmi_rxerror_i /*verilator public*/,
    input  wire [1:0]     utmi_linestate_i /*verilator public*/,

    // Pull-up enable
    output reg            usb_en_o /*verilator public*/
);

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------

// Current state
parameter STATE_RX_IDLE                 = 4'b0000;
parameter STATE_RX_TOKEN2               = 4'b0001;
parameter STATE_RX_TOKEN3               = 4'b0010;
parameter STATE_RX_TOKEN_COMPLETE       = 4'b0011;
parameter STATE_RX_SOF2                 = 4'b0100;
parameter STATE_RX_SOF3                 = 4'b0101;
parameter STATE_RX_DATA                 = 4'b0110;
parameter STATE_RX_DATA_IGNORE          = 4'b0111;
parameter STATE_RX_DATA_COMPLETE        = 4'b1000;
parameter STATE_TX_DATA                 = 4'b1001;
parameter STATE_TX_CRC                  = 4'b1010;
parameter STATE_TX_CRC1                 = 4'b1011;
parameter STATE_TX_CRC2                 = 4'b1100;
parameter STATE_TX_ACK                  = 4'b1101;
parameter STATE_TX_NAK                  = 4'b1110;
parameter STATE_TX_STALL                = 4'b1111;
reg [3:0] usb_state;

reg  [7:0]                utmi_txdata;

// CRC16
reg [15:0]                crc_sum;
wire [15:0]               crc_out;
wire [7:0]                crc_data_in;

// Others
reg [6:0]                 usb_this_device;
reg [6:0]                 usb_next_address;
reg                       usb_address_pending;
reg                       usb_event_bus_reset;

// Interrupt enables
reg                       usb_int_en_tx;
reg                       usb_int_en_rx;
reg                       usb_int_en_sof;

// Incoming request type
reg                       usb_rx_pid_out;
reg                       usb_rx_pid_in;
reg                       usb_rx_pid_setup;

// Request details
reg [10:0]                usb_frame_number;
reg [6:0]                 usb_address;
reg [2-1:0]               usb_endpoint;

// Request action
reg                       usb_rx_accept_data;
reg                       usb_rx_send_nak;
reg                       usb_rx_send_stall;

// Transmit details
reg [7:0] usb_tx_idx;

// Endpoint state
reg                       usb_ep_tx_pend[3:0];
reg                       usb_ep_tx_data1[3:0];
reg [7:0]                 usb_ep_tx_count[3:0];
reg                       usb_ep_stall[3:0];
reg                       usb_ep_iso[3:0];

reg [7:0]                 usb_rx_count;

reg                       usb_ep0_rx_setup;

reg                       usb_ep_full[3:0];
reg [7:0]                 usb_ep_rx_count[3:0];
reg                       usb_ep_crc_err[3:0];

// Endpoint receive FIFO (Host -> Device)
reg                       usb_fifo_rd_push[3:0];
reg                       usb_fifo_rd_flush[3:0];
reg                       usb_fifo_rd_pop[3:0];
reg [7:0]                 usb_fifo_rd_in;
wire [7:0]                usb_fifo_rd_out[3:0];

// Endpoint transmit FIFO (Device -> Host)
reg                       usb_fifo_wr_push[3:0];
reg                       usb_fifo_wr_pop[3:0];
reg                       usb_fifo_wr_flush[3:0];
reg [7:0]                 usb_fifo_wr_data[3:0];
wire [7:0]                usb_fifo_wr_out[3:0];
reg [7:0]                 usb_write_data;

wire new_data_ready       = utmi_rxvalid_i & utmi_rxactive_i;

//-----------------------------------------------------------------
// Peripheral Memory Map
//-----------------------------------------------------------------
`define USB_FUNC_CTRL              8'd0
`define USB_FUNC_STAT              8'd0
`define USB_FUNC_EP0            8'd4
`define USB_FUNC_EP0_DATA       8'd32
`define USB_FUNC_EP1            8'd8
`define USB_FUNC_EP1_DATA       8'd36
`define USB_FUNC_EP2            8'd12
`define USB_FUNC_EP2_DATA       8'd40
`define USB_FUNC_EP3            8'd16
`define USB_FUNC_EP3_DATA       8'd44

//-----------------------------------------------------------------
// Register Definitions
//-----------------------------------------------------------------
// USB_FUNC_CTRL
`define USB_FUNC_CTRL_ADDR         6:0
`define USB_FUNC_CTRL_ADDR_SET     8
`define USB_FUNC_CTRL_INT_EN_TX    9
`define USB_FUNC_CTRL_INT_EN_RX    10
`define USB_FUNC_CTRL_INT_EN_SOF   11
`define USB_FUNC_CTRL_PULLUP_EN    12

// USB_FUNC_STAT
`define USB_FUNC_STAT_FRAME        10:0
`define USB_FUNC_STAT_LS_RXP       16
`define USB_FUNC_STAT_LS_RXN       17
`define USB_FUNC_STAT_RST          18

// USB_FUNC_EPx
`define USB_EP_COUNT               7:0
`define USB_EP_TX_READY            16
`define USB_EP_RX_AVAIL            17
`define USB_EP_RX_ACK              18
`define USB_EP_RX_SETUP            18
`define USB_EP_RX_CRC_ERR          19
`define USB_EP_STALL               20
`define USB_EP_TX_FLUSH            21
`define USB_EP_ISO                 22

//-----------------------------------------------------------------
// Definitions
//-----------------------------------------------------------------

// Tokens
`define PID_OUT                    8'hE1
`define PID_IN                     8'h69
`define PID_SOF                    8'hA5
`define PID_SETUP                  8'h2D

// Data
`define PID_DATA0                  8'hC3
`define PID_DATA1                  8'h4B

// Handshake
`define PID_ACK                    8'hD2
`define PID_NAK                    8'h5A
`define PID_STALL                  8'h1E

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------

// CRC16
usbf_crc16
u_crc16
(
    .crc_in(crc_sum),
    .din(crc_data_in),
    .crc_out(crc_out)
);

//-----------------------------------------------------------------
// Endpoint 0: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(8),
  .ADDR_W(3)
)
u_fifo_rx_ep0
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_rd_in),
    .push_i(usb_fifo_rd_push[0]),

    .flush_i(usb_fifo_rd_flush[0]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_rd_out[0]),
    .pop_i(usb_fifo_rd_pop[0])
);

//-----------------------------------------------------------------
// Endpoint 0: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(8),
  .ADDR_W(3)
)
u_fifo_tx_ep0
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_wr_data[0]),
    .push_i(usb_fifo_wr_push[0]),

    .flush_i(usb_fifo_wr_flush[0]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_wr_out[0]),
    .pop_i(usb_fifo_wr_pop[0])
);
//-----------------------------------------------------------------
// Endpoint 1: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_rx_ep1
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_rd_in),
    .push_i(usb_fifo_rd_push[1]),

    .flush_i(usb_fifo_rd_flush[1]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_rd_out[1]),
    .pop_i(usb_fifo_rd_pop[1])
);

//-----------------------------------------------------------------
// Endpoint 1: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_tx_ep1
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_wr_data[1]),
    .push_i(usb_fifo_wr_push[1]),

    .flush_i(usb_fifo_wr_flush[1]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_wr_out[1]),
    .pop_i(usb_fifo_wr_pop[1])
);
//-----------------------------------------------------------------
// Endpoint 2: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_rx_ep2
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_rd_in),
    .push_i(usb_fifo_rd_push[2]),

    .flush_i(usb_fifo_rd_flush[2]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_rd_out[2]),
    .pop_i(usb_fifo_rd_pop[2])
);

//-----------------------------------------------------------------
// Endpoint 2: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_tx_ep2
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_wr_data[2]),
    .push_i(usb_fifo_wr_push[2]),

    .flush_i(usb_fifo_wr_flush[2]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_wr_out[2]),
    .pop_i(usb_fifo_wr_pop[2])
);
//-----------------------------------------------------------------
// Endpoint 3: Host -> Device
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_rx_ep3
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_rd_in),
    .push_i(usb_fifo_rd_push[3]),

    .flush_i(usb_fifo_rd_flush[3]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_rd_out[3]),
    .pop_i(usb_fifo_rd_pop[3])
);

//-----------------------------------------------------------------
// Endpoint 3: Device -> Host
//-----------------------------------------------------------------
usbf_fifo
#(
  .DEPTH(64),
  .ADDR_W(6)
)
u_fifo_tx_ep3
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    .data_i(usb_fifo_wr_data[3]),
    .push_i(usb_fifo_wr_push[3]),

    .flush_i(usb_fifo_wr_flush[3]),

    .full_o(),
    .empty_o(),

    .data_o(usb_fifo_wr_out[3]),
    .pop_i(usb_fifo_wr_pop[3])
);

//-----------------------------------------------------------------
// Next state
//-----------------------------------------------------------------
reg [3:0] next_state_r;

always @ *
begin
    next_state_r = usb_state;

    //-----------------------------------------
    // State Machine
    //-----------------------------------------
    case (usb_state)

        //-----------------------------------------
        // IDLE
        //-----------------------------------------
        STATE_RX_IDLE :
        begin
           if (new_data_ready)
           begin
               // Decode PID
               case (utmi_data_r)

                  `PID_OUT, `PID_IN, `PID_SETUP:
                        next_state_r  = STATE_RX_TOKEN2;

                  `PID_SOF:
                        next_state_r  = STATE_RX_SOF2;

                  `PID_DATA0, `PID_DATA1:
                  begin
                        if (usb_rx_accept_data && !usb_rx_send_stall)
                            next_state_r  = STATE_RX_DATA;
                        else
                            next_state_r  = STATE_RX_DATA_IGNORE;
                  end

                  `PID_ACK, `PID_NAK, `PID_STALL:
                        next_state_r  = STATE_RX_IDLE;

                  default :
                    ;
               endcase
           end
        end

        //-----------------------------------------
        // SOF (BYTE 2)
        //-----------------------------------------
        STATE_RX_SOF2 :
        begin
           if (new_data_ready)
               next_state_r = STATE_RX_SOF3;
        end

        //-----------------------------------------
        // SOF (BYTE 3)
        //-----------------------------------------
        STATE_RX_SOF3 :
        begin
           if (new_data_ready)
               next_state_r = STATE_RX_IDLE;
        end

        //-----------------------------------------
        // TOKEN (IN/OUT/SETUP) (Address/Endpoint)
        //-----------------------------------------
        STATE_RX_TOKEN2 :
        begin
           if (new_data_ready)
               next_state_r = STATE_RX_TOKEN3;
        end

        //-----------------------------------------
        // TOKEN (IN/OUT/SETUP) (Endpoint/CRC)
        //-----------------------------------------
        STATE_RX_TOKEN3 :
        begin
           if (new_data_ready)
               next_state_r = STATE_RX_TOKEN_COMPLETE;
        end

        //-----------------------------------------
        // RX_TOKEN_COMPLETE
        //-----------------------------------------
        STATE_RX_TOKEN_COMPLETE :
        begin
            next_state_r  = STATE_RX_IDLE;

            // Addressed to this device?
            if (usb_address == usb_this_device)
            begin
                //-------------------------------
                // IN transfer (device -> host)
                //-------------------------------
                if (usb_rx_pid_in)
                begin
                    // Stalled endpoint?
                    if (usb_ep_stall[usb_endpoint])
                        next_state_r  = STATE_TX_STALL;
                    // Some data to TX?
                    else if (usb_ep_tx_pend[usb_endpoint])
                        next_state_r  = STATE_TX_DATA;
                    // No data to TX
                    else
                        next_state_r  = STATE_TX_NAK;
                end
            end
        end

        //-----------------------------------------
        // RX_DATA
        //-----------------------------------------
        STATE_RX_DATA :
        begin
           // Receive complete
           if (utmi_rxactive_i == 1'b0)
                next_state_r = STATE_RX_DATA_COMPLETE;
        end

        //-----------------------------------------
        // RX_DATA_IGNORE
        //-----------------------------------------
        STATE_RX_DATA_IGNORE :
        begin
           // Receive complete
           if (utmi_rxactive_i == 1'b0)
           begin
                // ISO endpoint?
                if (usb_ep_iso[usb_endpoint])
                    next_state_r  = STATE_RX_IDLE;
                // Send STALL?
                else if (usb_rx_send_stall)
                    next_state_r  = STATE_TX_STALL;
                // Send NAK
                else if (usb_rx_send_nak)
                    next_state_r  = STATE_TX_NAK;
                else
                    next_state_r  = STATE_RX_IDLE;
           end
        end

        //-----------------------------------------
        // RX_DATA_COMPLETE
        //-----------------------------------------
        STATE_RX_DATA_COMPLETE :
        begin
            // Check for CRC error on receive data
            if (crc_sum != 16'hB001)
                next_state_r = STATE_RX_IDLE;
            // Good CRC
            else
            begin
                // ISO endpoint?
                if (usb_ep_iso[usb_endpoint])
                    next_state_r = STATE_RX_IDLE;
                // Non-ISO, send ACK
                else
                    next_state_r = STATE_TX_ACK;
            end
        end

        //-----------------------------------------
        // TX_ACK/NAK/STALL
        //-----------------------------------------
        STATE_TX_ACK, STATE_TX_NAK, STATE_TX_STALL :
        begin
            // Data sent?
            if (utmi_txready_i)
               next_state_r = STATE_RX_IDLE;
        end

        //-----------------------------------------
        // TX_DATA
        //-----------------------------------------
        STATE_TX_DATA :
        begin
            // Data sent?
            if (utmi_txready_i)
            begin
                // Generate CRC16 at end of packet
                if (usb_tx_idx == usb_ep_tx_count[usb_endpoint])
                    next_state_r  = STATE_TX_CRC;
            end
        end

        //-----------------------------------------
        // TX_CRC (generate)
        //-----------------------------------------
        STATE_TX_CRC :
            next_state_r  = STATE_TX_CRC1;

        //-----------------------------------------
        // TX_CRC1 (first byte)
        //-----------------------------------------
        STATE_TX_CRC1 :
        begin
            // Data sent?
            if (utmi_txready_i)
                next_state_r  = STATE_TX_CRC2;
        end

        //-----------------------------------------
        // TX_CRC (second byte)
        //-----------------------------------------
        STATE_TX_CRC2 :
        begin
            // Data sent?
            if (utmi_txready_i)
                next_state_r  = STATE_RX_IDLE;
        end

        default :
           ;

    endcase

    //-----------------------------------------
    // USB Bus Reset (HOST->DEVICE)
    //----------------------------------------- 
    if (utmi_rst_i)
        next_state_r  = STATE_RX_IDLE;
end

// Update state
always @ (posedge rst_i or posedge clk_i)
begin
   if (rst_i == 1'b1)
        usb_state   <= STATE_RX_IDLE;
   else
        usb_state   <= next_state_r;
end

//-----------------------------------------------------------------
// Tx
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        utmi_txvalid_o      <= 1'b0;
        utmi_txdata         <= 8'h00;

        usb_tx_idx          <= 8'b0;

        usb_ep_tx_pend[0]   <= 1'b0;
        usb_ep_tx_data1[0]  <= 1'b0;
        usb_ep_tx_count[0]  <= 8'b0;
        usb_fifo_wr_pop[0]  <= 1'b0;
        usb_fifo_wr_push[0] <= 1'b0;
        usb_fifo_wr_data[0] <= 8'h00;
        usb_fifo_wr_flush[0]<= 1'b0;
        usb_ep_tx_pend[1]   <= 1'b0;
        usb_ep_tx_data1[1]  <= 1'b0;
        usb_ep_tx_count[1]  <= 8'b0;
        usb_fifo_wr_pop[1]  <= 1'b0;
        usb_fifo_wr_push[1] <= 1'b0;
        usb_fifo_wr_data[1] <= 8'h00;
        usb_fifo_wr_flush[1]<= 1'b0;
        usb_ep_tx_pend[2]   <= 1'b0;
        usb_ep_tx_data1[2]  <= 1'b0;
        usb_ep_tx_count[2]  <= 8'b0;
        usb_fifo_wr_pop[2]  <= 1'b0;
        usb_fifo_wr_push[2] <= 1'b0;
        usb_fifo_wr_data[2] <= 8'h00;
        usb_fifo_wr_flush[2]<= 1'b0;
        usb_ep_tx_pend[3]   <= 1'b0;
        usb_ep_tx_data1[3]  <= 1'b0;
        usb_ep_tx_count[3]  <= 8'b0;
        usb_fifo_wr_pop[3]  <= 1'b0;
        usb_fifo_wr_push[3] <= 1'b0;
        usb_fifo_wr_data[3] <= 8'h00;
        usb_fifo_wr_flush[3]<= 1'b0;
   end
   else
   begin
        usb_fifo_wr_pop[0]   <= 1'b0;
        usb_fifo_wr_push[0]  <= 1'b0;
        usb_fifo_wr_flush[0] <= 1'b0;
        usb_fifo_wr_pop[1]   <= 1'b0;
        usb_fifo_wr_push[1]  <= 1'b0;
        usb_fifo_wr_flush[1] <= 1'b0;
        usb_fifo_wr_pop[2]   <= 1'b0;
        usb_fifo_wr_push[2]  <= 1'b0;
        usb_fifo_wr_flush[2] <= 1'b0;
        usb_fifo_wr_pop[3]   <= 1'b0;
        usb_fifo_wr_push[3]  <= 1'b0;
        usb_fifo_wr_flush[3] <= 1'b0;

        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_RX_IDLE :
            begin
               if (new_data_ready)
               begin
                   usb_tx_idx <= 8'b0;

                   // Decode PID
                   case (utmi_data_r)
                      `PID_SETUP:
                      begin
                            // Send DATA1 when responding to SETUP
                            usb_ep_tx_data1[0]  <= 1'b1;
                      end

                      default :
                          ;
                   endcase
               end
            end

            //-----------------------------------------
            // TX_ACK
            //-----------------------------------------
            STATE_TX_ACK :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;

                // Data to send
                utmi_txdata     <= `PID_ACK;

                // Data sent?
                if (utmi_txready_i)
                begin

                   utmi_txvalid_o   <= 1'b0;
                end
            end

            //-----------------------------------------
            // TX_NAK
            //-----------------------------------------
            STATE_TX_NAK :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;

                // Data to send
                utmi_txdata     <= `PID_NAK;

                // Data sent?
                if (utmi_txready_i)
                begin

                   utmi_txvalid_o   <= 1'b0;
                end
            end

            //-----------------------------------------
            // TX_STALL
            //-----------------------------------------
            STATE_TX_STALL :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;

                // Data to send
                utmi_txdata     <= `PID_STALL;

                // Data sent?
                if (utmi_txready_i)
                begin

                   utmi_txvalid_o   <= 1'b0;
                end
            end

            //-----------------------------------------
            // TX_DATA
            //-----------------------------------------
            STATE_TX_DATA :
            begin
                // Tx active
                utmi_txvalid_o    <= 1'b1;

                // Send PID (first byte - DATA0 or DATA1)
                if (usb_tx_idx == 8'b0)
                begin
                    if (usb_ep_tx_data1[usb_endpoint])
                        utmi_txdata     <= `PID_DATA1;
                    else
                        utmi_txdata     <= `PID_DATA0;
                end
                // Data to send
                else
                    utmi_txdata     <= usb_write_data;

                // Data sent?
                if (utmi_txready_i)
                begin
                   // First byte is PID (not CRC'd)
                   if (usb_tx_idx == 8'b0)
                   begin
                        usb_tx_idx   <= usb_tx_idx + 8'd1;

                        // Switch to next DATAx
                        usb_ep_tx_data1[usb_endpoint] <= ~usb_ep_tx_data1[usb_endpoint];
                   end
                   else
                   begin

                        // Pop FIFO
                        usb_fifo_wr_pop[usb_endpoint]  <= 1'b1;

                        // Increment index
                        usb_tx_idx      <= usb_tx_idx + 8'd1;
                   end
                end
            end

            //-----------------------------------------
            // TX_CRC1 (first byte)
            //-----------------------------------------
            STATE_TX_CRC1 :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;
            end

            //-----------------------------------------
            // TX_CRC (second byte)
            //-----------------------------------------
            STATE_TX_CRC2 :
            begin
                // Tx active
                utmi_txvalid_o  <= 1'b1;

                // Data sent?
                if (utmi_txready_i)
                begin
                    // Transfer now complete
                    utmi_txvalid_o  <= 1'b0;

                    // Mark data as sent
                    usb_ep_tx_pend[usb_endpoint]   <= 1'b0;

                end
            end

            //-----------------------------------------
            // RX_TOKEN_COMPLETE
            //-----------------------------------------
            STATE_RX_TOKEN_COMPLETE :
            begin
                // Addressed to this device?
                if (usb_address == usb_this_device)
                begin
                    //-------------------------------
                    // SETUP transfer (EP0)
                    //-------------------------------
                    if (usb_rx_pid_setup)
                    begin
                        // New SETUP token resets Tx pending status on EP0
                        usb_ep_tx_pend[0]    <= 1'b0;
                        usb_fifo_wr_flush[0] <= 1'b1;
                    end
                end
            end

            default :
               ;

        endcase

        //-----------------------------------------------------------------
        // Peripheral Registers (Write)
        //-----------------------------------------------------------------
        if (we_i & stb_i)
           case (addr_i)

           `USB_FUNC_EP0 :
           begin
                usb_ep_tx_pend[0]  <= data_i[`USB_EP_TX_READY];
                usb_ep_tx_count[0] <= data_i[`USB_EP_COUNT];
           end

           `USB_FUNC_EP1 :
           begin
                usb_ep_tx_pend[1]    <= data_i[`USB_EP_TX_READY];
                usb_ep_tx_count[1]   <= data_i[`USB_EP_COUNT];

                // Flush transmit FIFO?
                if (data_i[`USB_EP_TX_FLUSH])
                  usb_fifo_wr_flush[1]   <= 1'b1;
           end
           `USB_FUNC_EP2 :
           begin
                usb_ep_tx_pend[2]    <= data_i[`USB_EP_TX_READY];
                usb_ep_tx_count[2]   <= data_i[`USB_EP_COUNT];

                // Flush transmit FIFO?
                if (data_i[`USB_EP_TX_FLUSH])
                  usb_fifo_wr_flush[2]   <= 1'b1;
           end
           `USB_FUNC_EP3 :
           begin
                usb_ep_tx_pend[3]    <= data_i[`USB_EP_TX_READY];
                usb_ep_tx_count[3]   <= data_i[`USB_EP_COUNT];

                // Flush transmit FIFO?
                if (data_i[`USB_EP_TX_FLUSH])
                  usb_fifo_wr_flush[3]   <= 1'b1;
           end

           `USB_FUNC_EP0_DATA:
           begin
             usb_fifo_wr_data[0] <= data_i[7:0];
             usb_fifo_wr_push[0] <= 1'b1;
           end
           `USB_FUNC_EP1_DATA:
           begin
             usb_fifo_wr_data[1] <= data_i[7:0];
             usb_fifo_wr_push[1] <= 1'b1;
           end
           `USB_FUNC_EP2_DATA:
           begin
             usb_fifo_wr_data[2] <= data_i[7:0];
             usb_fifo_wr_push[2] <= 1'b1;
           end
           `USB_FUNC_EP3_DATA:
           begin
             usb_fifo_wr_data[3] <= data_i[7:0];
             usb_fifo_wr_push[3] <= 1'b1;
           end

           default :
               ;
           endcase

        //-----------------------------------------
        // USB Bus Reset (HOST->DEVICE)
        //----------------------------------------- 
        if (utmi_rst_i)
        begin
            // Reset endpoint state    
            usb_ep_tx_pend[0] <= 1'b0;
            usb_ep_tx_data1[0]<= 1'b0;
            usb_ep_tx_pend[1] <= 1'b0;
            usb_ep_tx_data1[1]<= 1'b0;
            usb_ep_tx_pend[2] <= 1'b0;
            usb_ep_tx_data1[2]<= 1'b0;
            usb_ep_tx_pend[3] <= 1'b0;
            usb_ep_tx_data1[3]<= 1'b0;

            // Reset to IDLE
            utmi_txvalid_o        <= 1'b0;
        end
   end
end

//-----------------------------------------------------------------
// Rx
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        // Other
        usb_rx_pid_out      <= 1'b0;
        usb_rx_pid_in       <= 1'b0;
        usb_rx_pid_setup    <= 1'b0;

        usb_endpoint        <= 2'b0;

        usb_rx_accept_data  <= 1'b0;
        usb_rx_send_nak     <= 1'b0;
        usb_rx_send_stall   <= 1'b0;

        usb_rx_count        <= 8'b0;
        usb_ep0_rx_setup    <= 1'b0;

        usb_ep_stall[0]     <= 1'b0;
        usb_ep_iso[0]       <= 1'b0;
        usb_fifo_rd_push[0] <= 1'b0;
        usb_fifo_rd_flush[0]<= 1'b0;

        usb_ep_full[0]      <= 1'b0;
        usb_ep_rx_count[0]  <= 8'b0;
        usb_ep_crc_err[0]   <= 1'b0;
        usb_ep_stall[1]     <= 1'b0;
        usb_ep_iso[1]       <= 1'b0;
        usb_fifo_rd_push[1] <= 1'b0;
        usb_fifo_rd_flush[1]<= 1'b0;

        usb_ep_full[1]      <= 1'b0;
        usb_ep_rx_count[1]  <= 8'b0;
        usb_ep_crc_err[1]   <= 1'b0;
        usb_ep_stall[2]     <= 1'b0;
        usb_ep_iso[2]       <= 1'b0;
        usb_fifo_rd_push[2] <= 1'b0;
        usb_fifo_rd_flush[2]<= 1'b0;

        usb_ep_full[2]      <= 1'b0;
        usb_ep_rx_count[2]  <= 8'b0;
        usb_ep_crc_err[2]   <= 1'b0;
        usb_ep_stall[3]     <= 1'b0;
        usb_ep_iso[3]       <= 1'b0;
        usb_fifo_rd_push[3] <= 1'b0;
        usb_fifo_rd_flush[3]<= 1'b0;

        usb_ep_full[3]      <= 1'b0;
        usb_ep_rx_count[3]  <= 8'b0;
        usb_ep_crc_err[3]   <= 1'b0;
        usb_fifo_rd_in  <= 8'b0;
   end
   else
   begin
        usb_fifo_rd_push[0]  <= 1'b0;
        usb_fifo_rd_flush[0] <= 1'b0;
        usb_fifo_rd_push[1]  <= 1'b0;
        usb_fifo_rd_flush[1] <= 1'b0;
        usb_fifo_rd_push[2]  <= 1'b0;
        usb_fifo_rd_flush[2] <= 1'b0;
        usb_fifo_rd_push[3]  <= 1'b0;
        usb_fifo_rd_flush[3] <= 1'b0;

        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_RX_IDLE :
            begin
               if (new_data_ready)
               begin
                   // Decode PID
                   case (utmi_data_r)

                      `PID_OUT:
                      begin
                            usb_rx_pid_out      <= 1'b1;
                            usb_rx_pid_in       <= 1'b0;
                            usb_rx_pid_setup    <= 1'b0;
                      end

                      `PID_IN:
                      begin
                            usb_rx_pid_out      <= 1'b0;
                            usb_rx_pid_in       <= 1'b1;
                            usb_rx_pid_setup    <= 1'b0;
                      end

                      `PID_SETUP:
                      begin
                            usb_rx_pid_out      <= 1'b0;
                            usb_rx_pid_in       <= 1'b0;
                            usb_rx_pid_setup    <= 1'b1;

                            // Reset EP0 stall status on SETUP
                            usb_rx_send_stall   <= 1'b0;
                            usb_ep_stall[0]     <= 1'b0;
                      end

                      `PID_DATA0:
                      begin
                            if (usb_rx_accept_data && !usb_rx_send_stall)
                            begin
                                usb_rx_accept_data  <= 1'b0;
                                usb_rx_count        <= 0;
                            end
                      end

                      `PID_DATA1:
                      begin
                            if (usb_rx_accept_data && !usb_rx_send_stall)
                            begin
                                usb_rx_accept_data  <= 1'b0;
                                usb_rx_count        <= 0;
                            end
                      end

                      `PID_ACK:
                      begin
                      end

                      `PID_NAK:
                      begin
                      end

                      `PID_STALL:
                      begin
                      end

                      default :
                      begin
                            // Reset state
                            usb_rx_pid_out      <= 1'b0;
                            usb_rx_pid_in       <= 1'b0;
                            usb_rx_pid_setup    <= 1'b0;
                      end

                   endcase
               end
            end

            //-----------------------------------------
            // TOKEN (IN/OUT/SETUP) (Address/Endpoint)
            //-----------------------------------------
            STATE_RX_TOKEN2 :
            begin
               if (new_data_ready)
                   usb_endpoint[0]  <= utmi_data_r[7];
            end

            //-----------------------------------------
            // TOKEN (IN/OUT/SETUP) (Endpoint/CRC)
            //-----------------------------------------
            STATE_RX_TOKEN3 :
            begin
               if (new_data_ready)
                   usb_endpoint[2-1:1] <= utmi_data_r[2-2:0];
            end

            //-----------------------------------------
            // RX_TOKEN_COMPLETE
            //-----------------------------------------
            STATE_RX_TOKEN_COMPLETE :
            begin

                // Ignore following data unless addressed
                usb_rx_accept_data <= 1'b0;
                usb_rx_send_nak    <= 1'b0;
                usb_rx_send_stall  <= 1'b0;

                // Addressed to this device?
                if (usb_address == usb_this_device)
                begin
                    //-------------------------------
                    // OUT transfer (host -> device)
                    //-------------------------------
                    if (usb_rx_pid_out)
                    begin
                        usb_rx_accept_data      <= !usb_ep_full[usb_endpoint];
                        usb_rx_send_nak         <= usb_ep_full[usb_endpoint];
                        usb_rx_send_stall       <= usb_ep_stall[usb_endpoint];
                    end
                    //-------------------------------
                    // SETUP transfer (EP0)
                    //-------------------------------
                    else if (usb_rx_pid_setup)
                    begin
                        // Must accept data!
                        usb_rx_accept_data      <= 1'b1;
                    end
                end
                else
                begin
                end
            end

            //-----------------------------------------
            // RX_DATA
            //-----------------------------------------
            STATE_RX_DATA :
            begin
               if (new_data_ready)
               begin
                   // Increment index
                   usb_rx_count     <= usb_rx_count + 1;

                   // Write incoming data to FIFO
                   usb_fifo_rd_in   <= utmi_data_r;

                   // Push data into correct EP FIFO
                   usb_fifo_rd_push[usb_endpoint]  <= 1'b1;

               end
            end

            //-----------------------------------------
            // RX_DATA_IGNORE
            //-----------------------------------------
            STATE_RX_DATA_IGNORE :
            begin
            end

            //-----------------------------------------
            // RX_DATA_COMPLETE
            //-----------------------------------------
            STATE_RX_DATA_COMPLETE :
            begin
                // Check for CRC error on receive data
                if (crc_sum != 16'hB001)
                begin

                    // Signal error and reset FIFO
                    usb_ep_full[usb_endpoint]       <= 1'b0;
                    usb_ep_crc_err[usb_endpoint]    <= 1'b1;
                    usb_fifo_rd_flush[usb_endpoint] <= 1'b1;
                    usb_ep_rx_count[usb_endpoint]   <= 8'b0;
                end
                // Good CRC
                else
                begin
                    // Update status
                    usb_ep_full[usb_endpoint]       <= 1'b1;
                    usb_ep_rx_count[usb_endpoint]   <= usb_rx_count;

                    // Endpoint 0 is different
                    if (usb_endpoint == 2'b0)
                    begin
                        usb_ep0_rx_setup    <= usb_rx_pid_setup;
                    end
                end
            end

            default :
               ;

        endcase

        //-----------------------------------------------------------------
        // Peripheral Registers (Write)
        //-----------------------------------------------------------------
        if (we_i & stb_i)
           case (addr_i)

           `USB_FUNC_EP0 :
           begin
                // Clear receive status?
                if (data_i[`USB_EP_RX_ACK])
                begin
                    usb_ep_full[0]       <= 1'b0;
                    usb_ep0_rx_setup     <= 1'b0;
                    usb_ep_crc_err[0]    <= 1'b0;
                    usb_fifo_rd_flush[0] <= 1'b1;
                end
                usb_ep_iso[0]      <= 1'b0;

                // Respond with STALL on EP0?
                if (data_i[`USB_EP_STALL])
                    usb_ep_stall[0]     <= 1'b1;
           end

           `USB_FUNC_EP1 :
           begin
                // Clear receive status?
                if (data_i[`USB_EP_RX_ACK])
                begin
                    usb_ep_full[1]       <= 1'b0;
                    usb_ep_crc_err[1]    <= 1'b0;
                    usb_fifo_rd_flush[1] <= 1'b1;
                end
                usb_ep_iso[1]        <= data_i[`USB_EP_ISO];

                // Endpoint stalled?
                usb_ep_stall[1]      <= data_i[`USB_EP_STALL];
           end
           `USB_FUNC_EP2 :
           begin
                // Clear receive status?
                if (data_i[`USB_EP_RX_ACK])
                begin
                    usb_ep_full[2]       <= 1'b0;
                    usb_ep_crc_err[2]    <= 1'b0;
                    usb_fifo_rd_flush[2] <= 1'b1;
                end
                usb_ep_iso[2]        <= data_i[`USB_EP_ISO];

                // Endpoint stalled?
                usb_ep_stall[2]      <= data_i[`USB_EP_STALL];
           end
           `USB_FUNC_EP3 :
           begin
                // Clear receive status?
                if (data_i[`USB_EP_RX_ACK])
                begin
                    usb_ep_full[3]       <= 1'b0;
                    usb_ep_crc_err[3]    <= 1'b0;
                    usb_fifo_rd_flush[3] <= 1'b1;
                end
                usb_ep_iso[3]        <= data_i[`USB_EP_ISO];

                // Endpoint stalled?
                usb_ep_stall[3]      <= data_i[`USB_EP_STALL];
           end

           default :
               ;
           endcase

        //-----------------------------------------
        // USB Bus Reset (HOST->DEVICE)
        //----------------------------------------- 
        if (utmi_rst_i)
        begin
            // Reset endpoint state    
            usb_ep_full[0]    <= 1'b0;
            usb_ep_rx_count[0]<= 8'b0;
            usb_ep_full[1]    <= 1'b0;
            usb_ep_rx_count[1]<= 8'b0;
            usb_ep_full[2]    <= 1'b0;
            usb_ep_rx_count[2]<= 8'b0;
            usb_ep_full[3]    <= 1'b0;
            usb_ep_rx_count[3]<= 8'b0;

            usb_ep0_rx_setup      <= 1'b0;
        end
   end
end

//-----------------------------------------------------------------
// CRC generation
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        crc_sum             <= 16'hFFFF;
   end
   else
   begin
        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // IDLE
            //-----------------------------------------
            STATE_RX_IDLE :
            begin
               if (new_data_ready)
               begin
                   // Data packet?
                   if (utmi_data_r == `PID_DATA0 || utmi_data_r == `PID_DATA1)
                      if (usb_rx_accept_data && !usb_rx_send_stall)
                          crc_sum             <= 16'hFFFF;
               end
            end

            //-----------------------------------------
            // RX_DATA
            //-----------------------------------------
            STATE_RX_DATA :
            begin
               if (new_data_ready)
                   crc_sum          <= crc_out;
            end

            //-----------------------------------------
            // TX_DATA
            //-----------------------------------------
            STATE_TX_DATA :
            begin
                // Data sent?
                if (utmi_txready_i)
                begin
                   // First byte is PID (not CRC'd)
                   if (usb_tx_idx == 8'b0)
                   begin
                        // Reset CRC16
                        crc_sum      <= 16'hFFFF;
                   end
                   else
                   begin
                        // Next CRC start value
                        crc_sum      <= crc_out;
                   end
                end
            end

            //-----------------------------------------
            // TX_CRC (generate)
            //-----------------------------------------
            STATE_TX_CRC :
            begin
                // Next CRC start value
                crc_sum   <= crc_sum ^ 16'hFFFF;
            end

            default :
               ;

        endcase
   end
end

//-----------------------------------------------------------------
// Address / Frame / Misc
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        usb_en_o            <= 1'b0;

        usb_frame_number    <= 11'h000;
        usb_address         <= 7'h00;
        usb_this_device     <= 7'h00;
        usb_next_address    <= 7'h00;
        usb_address_pending <= 1'b0;
        usb_event_bus_reset <= 1'b0;
   end
   else
   begin
        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // SOF (BYTE 2)
            //-----------------------------------------
            STATE_RX_SOF2 :
            begin
               if (new_data_ready)
                   usb_frame_number[7:0]    <= utmi_data_r;
            end

            //-----------------------------------------
            // SOF (BYTE 3)
            //-----------------------------------------
            STATE_RX_SOF3 :
            begin
               if (new_data_ready)
                   usb_frame_number[10:8]   <= utmi_data_r[2:0];
            end

            //-----------------------------------------
            // TOKEN (IN/OUT/SETUP) (Address/Endpoint)
            //-----------------------------------------
            STATE_RX_TOKEN2 :
            begin
               if (new_data_ready)
                   usb_address  <= utmi_data_r[6:0];
            end

            //-----------------------------------------
            // TX_CRC (second byte)
            //-----------------------------------------
            STATE_TX_CRC2 :
            begin
                // Data sent?
                if (utmi_txready_i)
                begin
                    // Address changes actually occur in status phase    
                    if (usb_address_pending)
                    begin
                        usb_address_pending <= 1'b0;
                        usb_this_device     <= usb_next_address;

                    end
                end
            end

            default :
               ;

        endcase

        //-----------------------------------------------------------------
        // Peripheral Registers (Write)
        //-----------------------------------------------------------------
        if (we_i & stb_i)
           case (addr_i)

           `USB_FUNC_CTRL :
           begin
                // Set new device address?
                if (data_i[`USB_FUNC_CTRL_ADDR_SET])
                begin

                    // Device address change occurs in the status stage
                    usb_next_address    <= data_i[`USB_FUNC_CTRL_ADDR];
                    usb_address_pending <= 1'b1;
                end

                usb_en_o            <= data_i[`USB_FUNC_CTRL_PULLUP_EN];

                // Clear bus reset event status
                usb_event_bus_reset <= 1'b0;
           end

           default :
               ;
           endcase

        //-----------------------------------------
        // USB Bus Reset (HOST->DEVICE)
        //----------------------------------------- 
        if (utmi_rst_i)
        begin
            usb_event_bus_reset   <= 1'b1;

            // Reset SOF
            usb_frame_number      <= 11'h000;

            // Reset device address
            usb_this_device       <= 7'h00;
            usb_address_pending   <= 1'b0;
        end
   end
end

//-----------------------------------------------------------------
// Interrupts
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        intr_o              <= 1'b0;

        // Interrupt control
        usb_int_en_tx       <= 1'b0;
        usb_int_en_rx       <= 1'b0;
        usb_int_en_sof      <= 1'b0;
   end
   else
   begin
        intr_o              <= 1'b0;

        //-----------------------------------------
        // State Machine
        //-----------------------------------------
        case (usb_state)

            //-----------------------------------------
            // SOF (BYTE 3)
            //-----------------------------------------
            STATE_RX_SOF3 :
            begin
               if (new_data_ready)
               begin
                   // Generate interrupt?
                   if (usb_int_en_sof)
                        intr_o <= 1'b1;
               end
            end

            //-----------------------------------------
            // RX_DATA_COMPLETE
            //-----------------------------------------
            STATE_RX_DATA_COMPLETE :
            begin
                // Generate interrupt on Rx complete?
                if (usb_int_en_rx)
                    intr_o <= 1'b1;
            end

            //-----------------------------------------
            // TX_CRC (second byte)
            //-----------------------------------------
            STATE_TX_CRC2 :
            begin
                // Data sent?
                if (utmi_txready_i)
                begin
                    // Generate interrupt on Tx complete?
                    if (usb_int_en_tx)
                        intr_o <= 1'b1;
                end
            end

            default :
               ;

        endcase

        //-----------------------------------------------------------------
        // Peripheral Registers (Write)
        //-----------------------------------------------------------------
        if (we_i & stb_i)
           case (addr_i)

           `USB_FUNC_CTRL :
           begin
                // Interrupt control
                usb_int_en_tx       <= data_i[`USB_FUNC_CTRL_INT_EN_TX];
                usb_int_en_rx       <= data_i[`USB_FUNC_CTRL_INT_EN_RX];
                usb_int_en_sof      <= data_i[`USB_FUNC_CTRL_INT_EN_SOF];
           end

           default :
               ;
           endcase
   end
end

//-----------------------------------------------------------------
// Peripheral Registers (Read)
//-----------------------------------------------------------------
always @ *
begin
   case (addr_i)

   `USB_FUNC_STAT :
   begin
        data_o = 32'b0;
        data_o[`USB_FUNC_STAT_FRAME]  = usb_frame_number;
        data_o[`USB_FUNC_STAT_LS_RXP] = utmi_linestate_i[0];
        data_o[`USB_FUNC_STAT_LS_RXN] = utmi_linestate_i[1];
        data_o[`USB_FUNC_STAT_RST]    = usb_event_bus_reset;
   end

   `USB_FUNC_EP0:
   begin
        data_o = 32'b0;
        data_o[`USB_EP_COUNT]     = usb_ep_rx_count[0];
        data_o[`USB_EP_TX_READY]  = usb_ep_tx_pend[0];
        data_o[`USB_EP_RX_AVAIL]  = usb_ep_full[0];
        data_o[`USB_EP_RX_SETUP]  = usb_ep0_rx_setup;
        data_o[`USB_EP_RX_CRC_ERR]= usb_ep_crc_err[0];
        data_o[`USB_EP_STALL]     = usb_ep_stall[0];
   end

   `USB_FUNC_EP1:
   begin
        data_o = 32'b0;
        data_o[`USB_EP_COUNT]     = usb_ep_rx_count[1];
        data_o[`USB_EP_TX_READY]  = usb_ep_tx_pend[1];
        data_o[`USB_EP_RX_AVAIL]  = usb_ep_full[1];
        data_o[`USB_EP_RX_CRC_ERR]= usb_ep_crc_err[1];
        data_o[`USB_EP_STALL]     = usb_ep_stall[1];
   end
   `USB_FUNC_EP2:
   begin
        data_o = 32'b0;
        data_o[`USB_EP_COUNT]     = usb_ep_rx_count[2];
        data_o[`USB_EP_TX_READY]  = usb_ep_tx_pend[2];
        data_o[`USB_EP_RX_AVAIL]  = usb_ep_full[2];
        data_o[`USB_EP_RX_CRC_ERR]= usb_ep_crc_err[2];
        data_o[`USB_EP_STALL]     = usb_ep_stall[2];
   end
   `USB_FUNC_EP3:
   begin
        data_o = 32'b0;
        data_o[`USB_EP_COUNT]     = usb_ep_rx_count[3];
        data_o[`USB_EP_TX_READY]  = usb_ep_tx_pend[3];
        data_o[`USB_EP_RX_AVAIL]  = usb_ep_full[3];
        data_o[`USB_EP_RX_CRC_ERR]= usb_ep_crc_err[3];
        data_o[`USB_EP_STALL]     = usb_ep_stall[3];
   end

   `USB_FUNC_EP0_DATA:
        data_o = {24'b0, usb_fifo_rd_out[0]};
   `USB_FUNC_EP1_DATA:
        data_o = {24'b0, usb_fifo_rd_out[1]};
   `USB_FUNC_EP2_DATA:
        data_o = {24'b0, usb_fifo_rd_out[2]};
   `USB_FUNC_EP3_DATA:
        data_o = {24'b0, usb_fifo_rd_out[3]};

   default :
        data_o = 32'h00000000;
   endcase
end

always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        usb_fifo_rd_pop[0]   <= 1'b0;
        usb_fifo_rd_pop[1]   <= 1'b0;
        usb_fifo_rd_pop[2]   <= 1'b0;
        usb_fifo_rd_pop[3]   <= 1'b0;
   end
   else
   begin

        usb_fifo_rd_pop[0]   <= 1'b0;
        usb_fifo_rd_pop[1]   <= 1'b0;
        usb_fifo_rd_pop[2]   <= 1'b0;
        usb_fifo_rd_pop[3]   <= 1'b0;

       // Read cycle?
       if (~we_i & stb_i)
           case (addr_i)
           `USB_FUNC_EP0_DATA:
                usb_fifo_rd_pop[0] <= 1'b1;
           `USB_FUNC_EP1_DATA:
                usb_fifo_rd_pop[1] <= 1'b1;
           `USB_FUNC_EP2_DATA:
                usb_fifo_rd_pop[2] <= 1'b1;
           `USB_FUNC_EP3_DATA:
                usb_fifo_rd_pop[3] <= 1'b1;

           default :
                ;
           endcase
   end
end

// Decode endpoint to FIFO
always @ *
begin
  usb_write_data = 8'b0;
  case (usb_endpoint)
    0 : usb_write_data  = usb_fifo_wr_out[0];
    1 : usb_write_data  = usb_fifo_wr_out[1];
    2 : usb_write_data  = usb_fifo_wr_out[2];
    3 : usb_write_data  = usb_fifo_wr_out[3];
  endcase
end

//-----------------------------------------------------------------
// Assignments
//-----------------------------------------------------------------
assign utmi_data_w = (usb_state == STATE_TX_CRC1) ? crc_sum[7:0] :
                     (usb_state == STATE_TX_CRC2) ? crc_sum[15:8] :
                     utmi_txdata;

assign crc_data_in = (usb_state == STATE_RX_DATA || usb_state == STATE_RX_IDLE) ? utmi_data_r : usb_write_data;

endmodule
