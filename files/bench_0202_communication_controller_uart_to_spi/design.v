// Curated RTL benchmark case.
// case_id: bench_0202_communication_controller_uart_to_spi
// source_project: communication_controller_uart_to_spi
// top_module: top


// -----------------------------------------------------------------------------
// Source file: rtl/top/top.v
// -----------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  UART2SPI  Top Module                                        ////
////                                                              ////
////  This file is part of the uart2spi  cores project            ////
////  http://www.opencores.org/cores/uart2spi/                    ////
////                                                              ////
////  Description                                                 ////
////  Uart2SPI top level integration.                             ////
////    1. spi_core                                               ////
////    2. uart_core                                              ////
////    3. uart_msg_handler                                       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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

module top (  
        line_reset_n ,
        line_clk ,

	// configuration control
        cfg_tx_enable  , // Enable Transmit Path
        cfg_rx_enable  , // Enable Received Path
        cfg_stop_bit   , // 0 -> 1 Start , 1 -> 2 Stop Bits
        cfg_pri_mod    , // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
	cfg_baud_16x   ,

       // Status information
        frm_error      ,
	par_error      ,

	baud_clk_16x,

       // Line Interface
        rxd,
        txd,

      // Spi I/F
        sck,
        so,
        si,
        cs_n  

     );



//---------------------------------
// Global Dec
// ---------------------------------

input        line_reset_n         ; // line reset
input        line_clk             ; // line clock

//-------------------------------------
// Configuration 
// -------------------------------------
input         cfg_tx_enable        ; // Tx Enable
input         cfg_rx_enable        ; // Rx Enable
input         cfg_stop_bit         ; // 0 -> 1 Stop, 1 -> 2 Stop
input   [1:0] cfg_pri_mod          ; // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
input   [11:0] cfg_baud_16x        ; // 16x Baud clock generation

//--------------------------------------
// ERROR Indication
// -------------------------------------
output        frm_error            ; // framing error
output        par_error            ; // par error

output        baud_clk_16x         ; // 16x Baud clock


//-------------------------------------
// Line Interface
// -------------------------------------
input         rxd                  ; // uart rxd
output        txd                  ; // uart txd

//-------------------------------------
// Spi I/F
//-------------------------------------
output              sck            ; // clock out
output              so             ; // serial data out
input               si             ; // serial data in
output [3:0]        cs_n           ; // cs_n
//---------------------------------------
// Control Unit interface
// --------------------------------------

wire  [15:0] reg_addr           ; // Register Address
wire  [31:0]  reg_wdata          ; // Register Wdata
wire         reg_req            ; // Register Request
wire         reg_wr             ; // 1 -> write; 0 -> read
wire          reg_ack            ; // Register Ack
wire   [31:0] reg_rdata          ;
//--------------------------------------
// TXD Path
// -------------------------------------
wire         tx_data_avail        ; // Indicate valid TXD Data 
wire [7:0]   tx_data              ; // TXD Data to be transmited
wire        tx_rd                ; // Indicate TXD Data Been Read


//--------------------------------------
// RXD Path
// -------------------------------------
wire         rx_ready           ; // Indicate Ready to accept the Read Data
wire [7:0]  rx_data             ; // RXD Data 
wire        rx_wr               ; // Valid RXD Data

spi_core  u_spi (

             .clk                (baud_clk_16x),
             .reset_n            (line_reset_n),
               
        // Reg Bus Interface Signal
             .reg_cs             (reg_req      ),
             .reg_wr             (reg_wr       ),
             .reg_addr           (reg_addr[5:2]),
             .reg_wdata          (reg_wdata    ),
             .reg_be             (4'b1111      ),

            // Outputs
            .reg_rdata           (reg_rdata    ),
            .reg_ack             (reg_ack      ),

          // line interface
               .sck              (sck          ),
               .so               (so           ),
               .si               (si           ),
               .cs_n             (cs_n         ) 

           );

 uart_core u_core (  
          .line_reset_n       (line_reset_n) ,
          .line_clk           (line_clk) ,

	// configuration control
          .cfg_tx_enable      (cfg_tx_enable) , 
          .cfg_rx_enable      (cfg_rx_enable) , 
          .cfg_stop_bit       (cfg_stop_bit) , 
          .cfg_pri_mod        (cfg_pri_mod) , 
	  .cfg_baud_16x       (cfg_baud_16x) ,

    // TXD Information
          .tx_data_avail      (tx_data_avail) ,
          .tx_rd              (tx_rd) ,
          .tx_data            (tx_data) ,
         

    // RXD Information
          .rx_ready           (rx_ready) ,
          .rx_wr              (rx_wr) ,
          .rx_data            (rx_data) ,

       // Status information
          .frm_error          (frm_error) ,
	  .par_error          (par_error) ,

	  .baud_clk_16x       (baud_clk_16x) ,

       // Line Interface
          .rxd                (rxd) ,
          .txd                (txd) 

     );



uart_msg_handler u_msg (  
          .reset_n            (line_reset_n ) ,
          .sys_clk            (baud_clk_16x ) ,


    // UART-TX Information
          .tx_data_avail      (tx_data_avail) ,
          .tx_rd              (tx_rd) ,
          .tx_data            (tx_data) ,
         

    // UART-RX Information
          .rx_ready           (rx_ready) ,
          .rx_wr              (rx_wr) ,
          .rx_data            (rx_data) ,

      // Towards Control Unit
          .reg_addr          (reg_addr),
          .reg_wr            (reg_wr),
          .reg_wdata         (reg_wdata),
          .reg_req           (reg_req),
          .reg_ack           (reg_ack),
	  .reg_rdata         (reg_rdata) 

     );

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/lib/registers.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores common library Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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
//`timescale 1ns/100ps

/*********************************************************************
** module: bit register

** description: infers a register, make it modular
 ***********************************************************************/
module bit_register (
		 //inputs
		 we,		 
		 clk,
		 reset_n,
		 data_in,
		 
		 //outputs
		 data_out
		 );

//---------------------------------
// Reset Default value
//---------------------------------
parameter  RESET_DEFAULT = 1'h0;

  input	 we;
  input	 clk;
  input	 reset_n;
  input	 data_in;
  output data_out;
  
  reg	 data_out;
  
  //infer the register
  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
	data_out <= RESET_DEFAULT;
      else if (we)
	data_out <= data_in;
    end // always @ (posedge clk or negedge reset_n)
endmodule // register


/*********************************************************************
** module: req register.

** description: This register is set by cpu writting 1 and reset by
                harward req = 1

 Note: When there is a clash between cpu and hardware, cpu is given higher
       priority

 ***********************************************************************/
module req_register (
		 //inputs
		 clk,
		 reset_n,
		 cpu_we,		 
		 cpu_req,
		 hware_ack,
		 
		 //outputs
		 data_out
		 );

//---------------------------------
// Reset Default value
//---------------------------------
parameter  RESET_DEFAULT = 1'h0;

  input	 clk      ;
  input	 reset_n  ;
  input	 cpu_we   ; // cpu write enable
  input	 cpu_req  ; // CPU Request
  input	 hware_ack; // Hardware Ack
  output data_out ;
  
  reg	 data_out;
  
  //infer the register
  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
	data_out <= RESET_DEFAULT;
      else if (cpu_we & cpu_req) // Set on CPU Request
	 data_out <= 1'b1;
      else if (hware_ack)  // Reset the flag on Hardware ack
	 data_out <= 1'b0;
    end // always @ (posedge clk or negedge reset_n)
endmodule // register


/*********************************************************************
** module: req register.

** description: This register is cleared by cpu writting 1 and set by
                harward req = 1

 Note: When there is a clash between cpu and hardware, 
       hardware is given higher priority

 ***********************************************************************/
module stat_register (
		 //inputs
		 clk,
		 reset_n,
		 cpu_we,		 
		 cpu_ack,
		 hware_req,
		 
		 //outputs
		 data_out
		 );

//---------------------------------
// Reset Default value
//---------------------------------
parameter  RESET_DEFAULT = 1'h0;

  input	 clk      ;
  input	 reset_n  ;
  input	 cpu_we   ; // cpu write enable
  input	 cpu_ack  ; // CPU Ack
  input	 hware_req; // Hardware Req
  output data_out ;
  
  reg	 data_out;
  
  //infer the register
  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
	data_out <= RESET_DEFAULT;
      else if (hware_req)  // Set the flag on Hardware Req
	 data_out <= 1'b1;
      else if (cpu_we & cpu_ack) // Clear on CPU Ack
	 data_out <= 1'b0;
    end // always @ (posedge clk or negedge reset_n)
endmodule // register





/*********************************************************************
** copyright message here.

** module: generic register

***********************************************************************/
module  generic_register	(
	      //List of Inputs
	      we,		 
	      data_in,
	      reset_n,
	      clk,
	      
	      //List of Outs
	      data_out
	      );

  parameter   WD               = 1;  
  parameter   RESET_DEFAULT    = 0;  
  input [WD-1:0]     we;	
  input [WD-1:0]     data_in;	
  input              reset_n;
  input		     clk;
  output [WD-1:0]    data_out;


generate
  genvar i;
  for (i = 0; i < WD; i = i + 1) begin : gen_bit_reg
    bit_register #(RESET_DEFAULT[i]) u_bit_reg (   
                .we         (we[i]),
                .clk        (clk),
                .reset_n    (reset_n),
                .data_in    (data_in[i]),
                .data_out   (data_out[i])
            );
  end
endgenerate


endmodule


/*********************************************************************
** copyright message here.

** module: generic register

***********************************************************************/
module  generic_intr_stat_reg	(
		 //inputs
		 clk,
		 reset_n,
		 reg_we,		 
		 reg_din,
		 hware_req,
		 
		 //outputs
		 data_out
	      );

  parameter   WD               = 1;  
  parameter   RESET_DEFAULT    = 0;  
  input [WD-1:0]     reg_we;	
  input [WD-1:0]     reg_din;	
  input [WD-1:0]     hware_req;	
  input              reset_n;
  input		     clk;
  output [WD-1:0]    data_out;


generate
  genvar i;
  for (i = 0; i < WD; i = i + 1) begin : gen_bit_reg
    stat_register #(RESET_DEFAULT[i]) u_bit_reg (
		 //inputs
		 . clk        (clk           ),
		 . reset_n    (reset_n       ),
		 . cpu_we     (reg_we[i]     ),		 
		 . cpu_ack    (reg_din[i]    ),
		 . hware_req  (hware_req[i]  ),
		 
		 //outputs
		 . data_out  (data_out[i]    )
		 );

  end
endgenerate


endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/msg_hand/uart_msg_handler.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  UART Message Handler Module                                 ////
////                                                              ////
////  This file is part of the uart2spi cores project             ////
////  http://www.opencores.org/cores/uart2spi/                    ////
////                                                              ////
////  Description                                                 ////
////  Uart Message Handler definitions.                           ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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

module uart_msg_handler (  
        reset_n ,
        sys_clk ,


    // UART-TX Information
        tx_data_avail,
        tx_rd,
        tx_data,
         

    // UART-RX Information
        rx_ready,
        rx_wr,
        rx_data,

      // Towards Register Interface
        reg_addr,
        reg_wr,  
        reg_wdata,
        reg_req,
	reg_ack,
	reg_rdata

     );


// Define the Message Hanlde States
`define IDLE	         4'h0
`define IDLE_TX_MSG1	 4'h1
`define IDLE_TX_MSG2	 4'h2
`define RX_CMD_PHASE	 4'h3
`define WR_ADR_PHASE	 4'h4
`define WR_DATA_PHASE	 4'h5
`define SEND_WR_REQ	 4'h6
`define RD_ADDR_PHASE	 4'h7
`define SEND_RD_REQ	 4'h8
`define SEND_RD_DATA	 4'h9
`define TX_MSG           4'hA
     
`define BREAK_CHAR       8'h0A

//---------------------------------
// Global Dec
// ---------------------------------

input        reset_n               ; // line reset
input        sys_clk               ; // line clock


//--------------------------------------
// UART TXD Path
// -------------------------------------
output         tx_data_avail        ; // Indicate valid TXD Data available
output [7:0]   tx_data              ; // TXD Data to be transmited
input          tx_rd                ; // Indicate TXD Data Been Read


//--------------------------------------
// UART RXD Path
// -------------------------------------
output         rx_ready            ; // Indicate Ready to accept the Read Data
input [7:0]    rx_data             ; // RXD Data 
input          rx_wr               ; // Valid RXD Data

//---------------------------------------
// Control Unit interface
// --------------------------------------

output  [15:0] reg_addr           ; // Operend-1
output  [31:0]  reg_wdata          ; // Operend-2
output         reg_req            ; // Register Request
output         reg_wr             ; // 1 -> write; 0 -> read
input          reg_ack            ; // Register Ack
input   [31:0] reg_rdata          ;

// Local Wire/Register Decleration
//
//
reg             tx_data_avail      ;
reg [7:0]       tx_data            ;
reg [16*8-1:0]  TxMsgBuf           ; // 16 Byte Tx Message Buffer
reg  [4:0]      TxMsgSize          ;
reg  [4:0]      RxMsgCnt           ; // Count the Receive Message Count
reg  [3:0]      State              ;
reg  [3:0]      NextState          ;
reg  [15:0]     cmd                ; // command
reg  [15:0]     reg_addr           ; // reg_addr
reg  [31:0]      reg_wdata          ; // reg_addr
reg             reg_wr             ; // 1 -> Reg Write request, 0 -> Read Requestion
reg             reg_req            ; // 1 -> Register request


wire rx_ready = 1; 
/****************************************************************
*  UART Message Hanlding Steps
*
*  1. On Reset Or Unknown command, Send the Default Message
*     Select Option:
*     wr <addr> <data>
*     rd <addr>
*  2. Wait for User command <wr/rd> 
*  3. On <wr> command move to write address phase;
*  phase
*       A. After write address phase move to write data phase
*       B. After write data phase, once user press \r command ; send register req
*          and write request and address + data 
*       C. On receiving register ack response; send <success> message back and move
*          to state-2
*  3.  On <rd> command move to read address phase;
*       A. After read address phase , once user press '\r' command; send
*          register req , read request 
*       C. On receiving register ack response; send <response + read_data> message and move
*          to state-2
*  *****************************************************************/

always @(negedge reset_n or posedge sys_clk)
begin
   if(reset_n == 1'b0) begin
      tx_data_avail <= 0;
      reg_req       <= 0;
      State         <= `IDLE;
      NextState     <= `IDLE;
   end else begin
   case(State)
      // Send Default Message
      `IDLE: begin
   	  TxMsgBuf      <= "Command Format:\n";  // Align to 16 character format by appending space character
          TxMsgSize     <= 16;
	  tx_data_avail <= 0;
	  State         <= `TX_MSG;
	  NextState     <= `IDLE_TX_MSG1;
       end

      // Send Default Message (Contd..)
      `IDLE_TX_MSG1: begin
	   TxMsgBuf      <= "wm <ad> <data>\n "; // Align to 16 character format by appending space character 
           TxMsgSize     <= 15;
	   tx_data_avail <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `IDLE_TX_MSG2;
        end

      // Send Default Message (Contd..)
      `IDLE_TX_MSG2: begin
	   TxMsgBuf      <= "rm <ad>\n>>      ";  // Align to 16 character format by appending space character
           TxMsgSize     <= 10;
	   tx_data_avail <= 0;
	   RxMsgCnt      <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `RX_CMD_PHASE;
      end

       // Wait for Response
    `RX_CMD_PHASE: begin
	if(rx_wr == 1) begin
	   //if(RxMsgCnt == 0 && rx_data == " ") begin // Ignore the same
	   if(RxMsgCnt == 0 && rx_data == 8'h20) begin // Ignore the same
	   //end else if(RxMsgCnt > 0 && rx_data == " ") begin // Check the command
	   end else if(RxMsgCnt > 0 && rx_data == 8'h20) begin // Check the command
	     //if(cmd == "wm") begin
	     if(cmd == 16'h776D) begin
		 RxMsgCnt <= 0;
		 reg_addr <= 0;
		 reg_wdata <= 0;
		 State <= `WR_ADR_PHASE;
	      //end else if(cmd == "rm") begin
	      end else if(cmd == 16'h726D) begin
		 reg_addr <= 0;
		 RxMsgCnt <= 0;
		 State <= `RD_ADDR_PHASE;
             end else begin // Unknow command
	        State         <= `IDLE;
             end
	   //end else if(rx_data == "\n") begin // Error State
	   end else if(rx_data == `BREAK_CHAR) begin // Error State
	      State         <= `IDLE;
	   end 
	   else begin
              cmd <=  (cmd << 8) | rx_data ;
	      RxMsgCnt <= RxMsgCnt+1;
           end
        end 
     end
       // Write Address Phase 
    `WR_ADR_PHASE: begin
	if(rx_wr == 1) begin
	   //if(RxMsgCnt == 0 && rx_data == " ") begin // Ignore the Space character
	   if(RxMsgCnt == 0 && rx_data == 8'h20) begin // Ignore the Space character
	   //end else if(RxMsgCnt > 0 && rx_data == " ") begin // Move to write data phase
	   end else if(RxMsgCnt > 0 && rx_data == 8'h20) begin // Move to write data phase
	      State         <= `WR_DATA_PHASE;
	   //end else if(rx_data == "\n") begin // Error State
	   end else if(rx_data == `BREAK_CHAR) begin // Error State
	      State         <= `IDLE;
	   end else begin 
              reg_addr <= (reg_addr << 4) | char2hex(rx_data); 
	      RxMsgCnt <= RxMsgCnt+1;
           end
	end
     end
    // Write Data Phase 
    `WR_DATA_PHASE: begin
	if(rx_wr == 1) begin
	   //if(rx_data == " ") begin // Ignore the Space character
	   if(rx_data == 8'h20) begin // Ignore the Space character
	   //end else if(rx_data == "\n") begin // Error State
	   end else if(rx_data == `BREAK_CHAR) begin // Error State
	      State           <= `SEND_WR_REQ;
	      reg_wr          <= 1'b1; // Write request
	      reg_req         <= 1'b1;
	   end else begin // A to F
                 reg_wdata <= (reg_wdata << 4) | char2hex(rx_data); 
           end
	end
     end
    `SEND_WR_REQ: begin
	if(reg_ack)  begin
	   reg_req       <= 1'b0;
	   TxMsgBuf      <= "cmd success\n>>  "; // Align to 16 character format by appending space character 
           TxMsgSize     <= 14;
	   tx_data_avail <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `RX_CMD_PHASE;
       end
    end

       // Write Address Phase 
    `RD_ADDR_PHASE: begin
	if(rx_wr == 1) begin
	   //if(rx_data == " ") begin // Ignore the Space character
	   if(rx_data == 8'h20) begin // Ignore the Space character
	   //end else if(rx_data == "\n") begin // Error State
	   end else if(rx_data == `BREAK_CHAR) begin // Error State
	      State           <= `SEND_RD_REQ;
	      reg_wr          <= 1'b0; // Read request
	      reg_req         <= 1'b1; // Reg Request
	   end 
	   else begin // A to F
                 reg_addr     <= (reg_addr << 4) | char2hex(rx_data); 
	         RxMsgCnt <= RxMsgCnt+1;
	      end
           end
	end

    `SEND_RD_REQ: begin
	if(reg_ack)  begin
	   reg_req       <= 1'b0;
	   TxMsgBuf      <= "Response:       "; // Align to 16 character format by appending space character 
           TxMsgSize     <= 10;
	   tx_data_avail <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `SEND_RD_DATA;
       end
    end
    `SEND_RD_DATA: begin // Wait for Operation Completion
	   TxMsgBuf[16*8-1:15*8] <= hex2char(reg_rdata[31:28]);
	   TxMsgBuf[15*8-1:14*8] <= hex2char(reg_rdata[27:24]);
	   TxMsgBuf[14*8-1:13*8] <= hex2char(reg_rdata[23:20]);
	   TxMsgBuf[13*8-1:12*8] <= hex2char(reg_rdata[19:16]);
	   TxMsgBuf[12*8-1:11*8] <= hex2char(reg_rdata[15:12]);
	   TxMsgBuf[11*8-1:10*8] <= hex2char(reg_rdata[11:8]);
	   TxMsgBuf[10*8-1:9*8]  <= hex2char(reg_rdata[7:4]);
	   TxMsgBuf[9*8-1:8*8]   <= hex2char(reg_rdata[3:0]);
	   TxMsgBuf[8*8-1:7*8]   <= "\n";
           TxMsgSize     <= 9;
	   tx_data_avail <= 0;
	   State         <= `TX_MSG;
	   NextState     <= `RX_CMD_PHASE;
     end

       // Send Default Message (Contd..)
    `TX_MSG: begin
	   tx_data_avail    <= 1;
	   tx_data          <= TxMsgBuf[16*8-1:15*8];
	   if(TxMsgSize == 0) begin
	      tx_data_avail <= 0;
	      State         <= NextState;
           end else if(tx_rd) begin
   	      TxMsgBuf      <= TxMsgBuf << 8;
              TxMsgSize     <= TxMsgSize -1;
           end
        end
   endcase
   end
end


// Character to hex number
function [3:0] char2hex;
input [7:0] data_in;
case (data_in)
     8'h30:	char2hex = 4'h0; // character '0' 
     8'h31:	char2hex = 4'h1; // character '1'
     8'h32:	char2hex = 4'h2; // character '2'
     8'h33:	char2hex = 4'h3; // character '3'
     8'h34:	char2hex = 4'h4; // character '4' 
     8'h35:	char2hex = 4'h5; // character '5'
     8'h36:	char2hex = 4'h6; // character '6'
     8'h37:	char2hex = 4'h7; // character '7'
     8'h38:	char2hex = 4'h8; // character '8'
     8'h39:	char2hex = 4'h9; // character '9'
     8'h41:	char2hex = 4'hA; // character 'A'
     8'h42:	char2hex = 4'hB; // character 'B'
     8'h43:	char2hex = 4'hC; // character 'C'
     8'h44:	char2hex = 4'hD; // character 'D'
     8'h45:	char2hex = 4'hE; // character 'E'
     8'h46:	char2hex = 4'hF; // character 'F'
     8'h61:	char2hex = 4'hA; // character 'a'
     8'h62:	char2hex = 4'hB; // character 'b'
     8'h63:	char2hex = 4'hC; // character 'c'
     8'h64:	char2hex = 4'hD; // character 'd'
     8'h65:	char2hex = 4'hE; // character 'e'
     8'h66:	char2hex = 4'hF; // character 'f'
      default :  char2hex = 4'hF;
   endcase 
endfunction

// Hex to Asci Character 
function [7:0] hex2char;
input [3:0] data_in;
case (data_in)
     4'h0:	hex2char = 8'h30; // character '0' 
     4'h1:	hex2char = 8'h31; // character '1'
     4'h2:	hex2char = 8'h32; // character '2'
     4'h3:	hex2char = 8'h33; // character '3'
     4'h4:	hex2char = 8'h34; // character '4' 
     4'h5:	hex2char = 8'h35; // character '5'
     4'h6:	hex2char = 8'h36; // character '6'
     4'h7:	hex2char = 8'h37; // character '7'
     4'h8:	hex2char = 8'h38; // character '8'
     4'h9:	hex2char = 8'h39; // character '9'
     4'hA:	hex2char = 8'h41; // character 'A'
     4'hB:	hex2char = 8'h42; // character 'B'
     4'hC:	hex2char = 8'h43; // character 'C'
     4'hD:	hex2char = 8'h44; // character 'D'
     4'hE:	hex2char = 8'h45; // character 'E'
     4'hF:	hex2char = 8'h46; // character 'F'
   endcase 
endfunction
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/spi/spi_cfg.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores SPI Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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



module spi_cfg (

             mclk,
             reset_n,

        // Reg Bus Interface Signal
             reg_cs,
             reg_wr,
             reg_addr,
             reg_wdata,
             reg_be,

            // Outputs
            reg_rdata,
            reg_ack,


           // configuration signal
           cfg_tgt_sel        ,
           cfg_op_req         , // SPI operation request
           cfg_op_type        , // SPI operation type
           cfg_transfer_size  , // SPI transfer size
           cfg_sck_period     , // sck clock period
           cfg_sck_cs_period  , // cs setup/hold period
           cfg_cs_byte        , // cs bit information
           cfg_datain         , // data for transfer
           cfg_dataout        , // data for received
           hware_op_done      // operation done

        );



input         mclk;
input         reset_n;

output [1:0]  cfg_tgt_sel        ;

output        cfg_op_req         ; // SPI operation request
output [1:0]  cfg_op_type        ; // SPI operation type
output [1:0]  cfg_transfer_size  ; // SPI transfer size
output [5:0]  cfg_sck_period     ; // sck clock period
output [4:0]  cfg_sck_cs_period  ; // cs setup/hold period
output [7:0]  cfg_cs_byte        ; // cs bit information
output [31:0] cfg_datain         ; // data for transfer
input  [31:0] cfg_dataout        ; // data for received
input         hware_op_done      ; // operation done

//---------------------------------
// Reg Bus Interface Signal
//---------------------------------
input             reg_cs         ;
input             reg_wr         ;
input [3:0]       reg_addr       ;
input [31:0]      reg_wdata      ;
input [3:0]       reg_be         ;

// Outputs
output [31:0]     reg_rdata      ;
output            reg_ack        ;



//-----------------------------------------------------------------------
// Internal Wire Declarations
//-----------------------------------------------------------------------

wire           sw_rd_en;
wire           sw_wr_en;
wire  [3:0]    sw_addr ; // addressing 16 registers
wire  [3:0]    wr_be   ;

reg   [31:0]  reg_rdata      ;
reg           reg_ack     ;

wire [31:0]    reg_0;  // Software_Reg_0
wire [31:0]    reg_1;  // Software-Reg_1
wire [31:0]    reg_2;  // Software-Reg_2
wire [31:0]    reg_3 = 0;  // Software-Reg_3
wire [31:0]    reg_4 = 0;  // Software-Reg_4
wire [31:0]    reg_5 = 0;  // Software-Reg_5
wire [31:0]    reg_6 = 0;  // Software-Reg_6
wire [31:0]    reg_7 = 0;  // Software-Reg_7
wire [31:0]    reg_8 = 0;  // Software-Reg_8
wire [31:0]    reg_9 = 0;  // Software-Reg_9
wire [31:0]    reg_10 = 0; // Software-Reg_10
wire [31:0]    reg_11 = 0; // Software-Reg_11
wire [31:0]    reg_12 = 0; // Software-Reg_12
wire [31:0]    reg_13 = 0; // Software-Reg_13
wire [31:0]    reg_14 = 0; // Software-Reg_14
wire [31:0]    reg_15 = 0; // Software-Reg_15
reg  [31:0]    reg_out;

//-----------------------------------------------------------------------
// Main code starts here
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Internal Logic Starts here
//-----------------------------------------------------------------------
    assign sw_addr       = reg_addr [3:0];
    assign sw_rd_en      = reg_cs & !reg_wr;
    assign sw_wr_en      = reg_cs & reg_wr;
    assign wr_be         = reg_be;


//-----------------------------------------------------------------------
// Read path mux
//-----------------------------------------------------------------------

always @ (posedge mclk or negedge reset_n)
begin : preg_out_Seq
   if (reset_n == 1'b0)
   begin
      reg_rdata [31:0]  <= 32'h0000_0000;
      reg_ack           <= 1'b0;
   end
   else if (sw_rd_en && !reg_ack) 
   begin
      reg_rdata [31:0]  <= reg_out [31:0];
      reg_ack           <= 1'b1;
   end
   else if (sw_wr_en && !reg_ack) 
      reg_ack           <= 1'b1;
   else
   begin
      reg_ack        <= 1'b0;
   end
end


//-----------------------------------------------------------------------
// register read enable and write enable decoding logic
//-----------------------------------------------------------------------
wire   sw_wr_en_0 = sw_wr_en & (sw_addr == 4'h0);
wire   sw_rd_en_0 = sw_rd_en & (sw_addr == 4'h0);
wire   sw_wr_en_1 = sw_wr_en & (sw_addr == 4'h1);
wire   sw_rd_en_1 = sw_rd_en & (sw_addr == 4'h1);
wire   sw_wr_en_2 = sw_wr_en & (sw_addr == 4'h2);
wire   sw_rd_en_2 = sw_rd_en & (sw_addr == 4'h2);
wire   sw_wr_en_3 = sw_wr_en & (sw_addr == 4'h3);
wire   sw_rd_en_3 = sw_rd_en & (sw_addr == 4'h3);
wire   sw_wr_en_4 = sw_wr_en & (sw_addr == 4'h4);
wire   sw_rd_en_4 = sw_rd_en & (sw_addr == 4'h4);
wire   sw_wr_en_5 = sw_wr_en & (sw_addr == 4'h5);
wire   sw_rd_en_5 = sw_rd_en & (sw_addr == 4'h5);
wire   sw_wr_en_6 = sw_wr_en & (sw_addr == 4'h6);
wire   sw_rd_en_6 = sw_rd_en & (sw_addr == 4'h6);
wire   sw_wr_en_7 = sw_wr_en & (sw_addr == 4'h7);
wire   sw_rd_en_7 = sw_rd_en & (sw_addr == 4'h7);
wire   sw_wr_en_8 = sw_wr_en & (sw_addr == 4'h8);
wire   sw_rd_en_8 = sw_rd_en & (sw_addr == 4'h8);
wire   sw_wr_en_9 = sw_wr_en & (sw_addr == 4'h9);
wire   sw_rd_en_9 = sw_rd_en & (sw_addr == 4'h9);
wire   sw_wr_en_10 = sw_wr_en & (sw_addr == 4'hA);
wire   sw_rd_en_10 = sw_rd_en & (sw_addr == 4'hA);
wire   sw_wr_en_11 = sw_wr_en & (sw_addr == 4'hB);
wire   sw_rd_en_11 = sw_rd_en & (sw_addr == 4'hB);
wire   sw_wr_en_12 = sw_wr_en & (sw_addr == 4'hC);
wire   sw_rd_en_12 = sw_rd_en & (sw_addr == 4'hC);
wire   sw_wr_en_13 = sw_wr_en & (sw_addr == 4'hD);
wire   sw_rd_en_13 = sw_rd_en & (sw_addr == 4'hD);
wire   sw_wr_en_14 = sw_wr_en & (sw_addr == 4'hE);
wire   sw_rd_en_14 = sw_rd_en & (sw_addr == 4'hE);
wire   sw_wr_en_15 = sw_wr_en & (sw_addr == 4'hF);
wire   sw_rd_en_15 = sw_rd_en & (sw_addr == 4'hF);


always @( *)
begin : preg_sel_Com

  reg_out [31:0] = 32'd0;

  case (sw_addr [3:0])
    4'b0000 : reg_out [31:0] = reg_0 [31:0];     
    4'b0001 : reg_out [31:0] = reg_1 [31:0];    
    4'b0010 : reg_out [31:0] = reg_2 [31:0];     
    4'b0011 : reg_out [31:0] = reg_3 [31:0];    
    4'b0100 : reg_out [31:0] = reg_4 [31:0];    
    4'b0101 : reg_out [31:0] = reg_5 [31:0];    
    4'b0110 : reg_out [31:0] = reg_6 [31:0];    
    4'b0111 : reg_out [31:0] = reg_7 [31:0];    
    4'b1000 : reg_out [31:0] = reg_8 [31:0];    
    4'b1001 : reg_out [31:0] = reg_9 [31:0];    
    4'b1010 : reg_out [31:0] = reg_10 [31:0];   
    4'b1011 : reg_out [31:0] = reg_11 [31:0];   
    4'b1100 : reg_out [31:0] = reg_12 [31:0];   
    4'b1101 : reg_out [31:0] = reg_13 [31:0];
    4'b1110 : reg_out [31:0] = reg_14 [31:0];
    4'b1111 : reg_out [31:0] = reg_15 [31:0]; 
  endcase
end



//-----------------------------------------------------------------------
// Individual register assignments
//-----------------------------------------------------------------------
// Logic for Register 0 : SPI Control Register
//-----------------------------------------------------------------------
wire         cfg_op_req         = reg_0[31];    // cpu request
wire [1:0]   cfg_tgt_sel        = reg_0[24:23]; // target chip select
wire [1:0]   cfg_op_type        = reg_0[22:21]; // SPI operation type
wire [1:0]   cfg_transfer_size  = reg_0[20:19]; // SPI transfer size
wire [5:0]   cfg_sck_period     = reg_0[18:13]; // sck clock period
wire [4:0]   cfg_sck_cs_period  = reg_0[12:8];  // cs setup/hold period
wire [7:0]   cfg_cs_byte        = reg_0[7:0];   // cs bit information

generic_register #(8,0  ) u_spi_ctrl_be0 (
	      .we            ({8{sw_wr_en_0 & 
                                 wr_be[0]   }}  ),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[7:0]        )
          );

generic_register #(8,0  ) u_spi_ctrl_be1 (
	      .we            ({8{sw_wr_en_0 & 
                                wr_be[1]   }}  ),		 
	      .data_in       (reg_wdata[15:8]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[15:8]       )
          );

generic_register #(8,0  ) u_spi_ctrl_be2 (
	      .we            ({8{sw_wr_en_0 & 
                                wr_be[2]   }}  ),		 
	      .data_in       (reg_wdata[23:16] ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[23:16]       )
          );

assign reg_0[30:24] = 7'h0;

req_register #(0  ) u_spi_ctrl_req (
	      .cpu_we       ({sw_wr_en_0 & 
                             wr_be[3]   }       ),		 
	      .cpu_req      (reg_wdata[31]      ),
	      .hware_ack    (hware_op_done      ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_0[31]         )
          );




//-----------------------------------------------------------------------
// Logic for Register 1 : SPI Data In Register
//-----------------------------------------------------------------------
wire [31:0]   cfg_datain        = reg_1[31:0]; 

generic_register #(8,0  ) u_spi_din_be0 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[0]   }}  ),		 
	      .data_in       (reg_wdata[7:0]    ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[7:0]        )
          );

generic_register #(8,0  ) u_spi_din_be1 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[1]   }}  ),		 
	      .data_in       (reg_wdata[15:8]   ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[15:8]       )
          );

generic_register #(8,0  ) u_spi_din_be2 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[2]   }}  ),		 
	      .data_in       (reg_wdata[23:16]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[23:16]      )
          );


generic_register #(8,0  ) u_spi_din_be3 (
	      .we            ({8{sw_wr_en_1 & 
                                wr_be[3]   }}  ),		 
	      .data_in       (reg_wdata[31:24]  ),
	      .reset_n       (reset_n           ),
	      .clk           (mclk              ),
	      
	      //List of Outs
	      .data_out      (reg_1[31:24]      )
          );


//-----------------------------------------------------------------------
// Logic for Register 2 : SPI Data output Register
//-----------------------------------------------------------------------
assign  reg_2 = cfg_dataout; 



endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/spi/spi_core.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores SPI Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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
module spi_core (

               clk,
               reset_n,
               
        // Reg Bus Interface Signal
             reg_cs,
             reg_wr,
             reg_addr,
             reg_wdata,
             reg_be,

            // Outputs
            reg_rdata,
            reg_ack,

          // line interface
               sck                ,
               so                 ,
               si                 ,
               cs_n  

           );
 
input               clk                           ;
input               reset_n                       ;          


//---------------------------------
// Reg Bus Interface Signal
//---------------------------------
input               reg_cs                        ;
input               reg_wr                        ;
input [3:0]         reg_addr                      ;
input [31:0]        reg_wdata                     ;
input [3:0]         reg_be                        ;

// Outputs
output [31:0]       reg_rdata                     ;
output              reg_ack                       ;

//-------------------------------------------
// Line Interface
//-------------------------------------------

output              sck                           ; // clock out
output              so                            ; // serial data out
input               si                            ; // serial data in
output [3:0]        cs_n                          ; // cs_n

//------------------------------------
// Wires
//------------------------------------

wire [7:0]          byte_in                       ;
wire [7:0]          byte_out                      ;


wire  [1:0]         cfg_tgt_sel                   ;

wire                cfg_op_req                    ; // SPI operation request
wire  [1:0]         cfg_op_type                   ; // SPI operation type
wire  [1:0]         cfg_transfer_size             ; // SPI transfer size
wire  [5:0]         cfg_sck_period                ; // sck clock period
wire  [4:0]         cfg_sck_cs_period             ; // cs setup/hold period
wire  [7:0]         cfg_cs_byte                   ; // cs bit information
wire  [31:0]        cfg_datain                    ; // data for transfer
wire  [31:0]        cfg_dataout                   ; // data for received
wire                hware_op_done                 ; // operation done

spi_if  u_spi_if
          (
          . clk                         (clk                          ), 
          . reset_n                     (reset_n                      ),

           // towards ctrl i/f
          . sck_pe                      (sck_pe                       ),
          . sck_int                     (sck_int                      ),
          . cs_int_n                    (cs_int_n                     ),
          . byte_in                     (byte_in                      ),
          . load_byte                   (load_byte                    ),
          . byte_out                    (byte_out                     ),
          . shift_out                   (shift_out                    ),
          . shift_in                    (shift_in                     ),

          . cfg_tgt_sel                 (cfg_tgt_sel                  ),

          . sck                         (sck                          ),
          . so                          (so                           ),
          . si                          (si                           ),
          . cs_n                        (cs_n                         )
           );


spi_ctl  u_spi_ctrl
       ( 
          . clk                         (clk                          ),
          . reset_n                     (reset_n                      ),

          . cfg_op_req                  (cfg_op_req                   ),
          . cfg_op_type                 (cfg_op_type                  ),
          . cfg_transfer_size           (cfg_transfer_size            ),
          . cfg_sck_period              (cfg_sck_period               ),
          . cfg_sck_cs_period           (cfg_sck_cs_period            ),
          . cfg_cs_byte                 (cfg_cs_byte                  ),
          . cfg_datain                  (cfg_datain                   ),
          . cfg_dataout                 (cfg_dataout                  ),
          . op_done                     (hware_op_done                ),

          . sck_int                     (sck_int                      ),
          . cs_int_n                    (cs_int_n                     ),
          . sck_pe                      (sck_pe                       ),
          . sck_ne                      (sck_ne                       ),
          . shift_out                   (shift_out                    ),
          . shift_in                    (shift_in                     ),
          . load_byte                   (load_byte                    ),
          . byte_out                    (byte_out                     ),
          . byte_in                     (byte_in                      )
         
         );




spi_cfg u_cfg (

          . mclk                        (clk                          ),
          . reset_n                     (reset_n                      ),

        // Reg Bus Interface Signal
          . reg_cs                      (reg_cs                       ),
          . reg_wr                      (reg_wr                       ),
          . reg_addr                    (reg_addr                     ),
          . reg_wdata                   (reg_wdata                    ),
          . reg_be                      (reg_be                       ),

            // Outputs
          . reg_rdata                   (reg_rdata                    ),
          . reg_ack                     (reg_ack                      ),


           // configuration signal
          . cfg_tgt_sel                 (cfg_tgt_sel                  ),
          . cfg_op_req                  (cfg_op_req                   ), // SPI operation request
          . cfg_op_type                 (cfg_op_type                  ), // SPI operation type
          . cfg_transfer_size           (cfg_transfer_size            ), // SPI transfer size
          . cfg_sck_period              (cfg_sck_period               ), // sck clock period
          . cfg_sck_cs_period           (cfg_sck_cs_period            ), // cs setup/hold period
          . cfg_cs_byte                 (cfg_cs_byte                  ), // cs bit information
          . cfg_datain                  (cfg_datain                   ), // data for transfer
          . cfg_dataout                 (cfg_dataout                  ), // data for received
          . hware_op_done               (hware_op_done                )  // operation done

        );

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/spi/spi_ctl.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores SPI Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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



module spi_ctl
       ( clk,
         reset_n,
         sck_int,


         cfg_op_req,
         cfg_op_type,
         cfg_transfer_size,
         cfg_sck_period,
         cfg_sck_cs_period,
         cfg_cs_byte,
         cfg_datain,
         cfg_dataout,
         op_done,

         cs_int_n,
         sck_pe,
         sck_ne,
         shift_out,
         shift_in,
         byte_out,
         byte_in,
         load_byte
         
         );

 //*************************************************************************

  input          clk, reset_n;
  input          cfg_op_req;
  input [1:0]    cfg_op_type;
  input [1:0]    cfg_transfer_size;
    
  input [5:0]    cfg_sck_period;
  input [4:0]    cfg_sck_cs_period; // cs setup & hold period
  input [7:0]    cfg_cs_byte;
  input [31:0]   cfg_datain;
  output [31:0]  cfg_dataout;

  output [7:0]    byte_out; // Byte out for Serial Shifting out
  input  [7:0]    byte_in;  // Serial Received Byte
  output          sck_int;
  output          cs_int_n;
  output          sck_pe;
  output          sck_ne;
  output          shift_out;
  output          shift_in;
  output          load_byte;
  output          op_done;

  reg    [31:0]   cfg_dataout;
  reg             sck_ne;
  reg             sck_pe;
  reg             sck_int;
  reg [5:0]       clk_cnt;
  reg [5:0]       sck_cnt;

  reg [3:0]       spiif_cs;
  reg             shift_enb;
  reg             cs_int_n;
  reg             clr_sck_cnt ;
  reg             sck_out_en;

  wire [5:0]      sck_half_period;
  reg             load_byte;
  reg             shift_in;
  reg             op_done;
  reg [2:0]       byte_cnt;


  `define SPI_IDLE   4'b0000
  `define SPI_CS_SU  4'b0001
  `define SPI_WRITE  4'b0010
  `define SPI_READ   4'b0011
  `define SPI_CS_HLD 4'b0100
  `define SPI_WAIT   4'b0101


  assign sck_half_period = {1'b0, cfg_sck_period[5:1]};
  // The first transition on the sck_toggle happens one SCK period
  // after op_en or boot_en is asserted
  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        sck_ne   <= 1'b0;
        clk_cnt  <= 6'h1;
        sck_pe   <= 1'b0;
        sck_int  <= 1'b0;
     end // if (!reset_n)
     else 
     begin
        if(cfg_op_req) 
        begin
           if(clk_cnt == sck_half_period) 
           begin
              sck_ne <= 1'b1;
              sck_pe <= 1'b0;
              if(sck_out_en) sck_int <= 0;
              clk_cnt <= clk_cnt + 1'b1;
           end // if (clk_cnt == sck_half_period)
           else 
           begin
              if(clk_cnt == cfg_sck_period) 
              begin
                 sck_ne <= 1'b0;
                 sck_pe <= 1'b1;
                 if(sck_out_en) sck_int <= 1;
                 clk_cnt <= 6'h1;
              end // if (clk_cnt == cfg_sck_period)
              else 
              begin
                 clk_cnt <= clk_cnt + 1'b1;
                 sck_pe <= 1'b0;
                 sck_ne <= 1'b0;
              end // else: !if(clk_cnt == cfg_sck_period)
           end // else: !if(clk_cnt == sck_half_period)
        end // if (op_en)
        else 
        begin
           clk_cnt    <= 6'h1;
           sck_pe     <= 1'b0;
           sck_ne     <= 1'b0;
        end // else: !if(op_en)
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)
  

wire [1:0] cs_data =  (byte_cnt == 2'b00) ? cfg_cs_byte[7:6]  :
                      (byte_cnt == 2'b01) ? cfg_cs_byte[5:4]  :
                      (byte_cnt == 2'b10) ? cfg_cs_byte[3:2]  : cfg_cs_byte[1:0] ;

wire [7:0] byte_out = (byte_cnt == 2'b00) ? cfg_datain[31:24] :
                      (byte_cnt == 2'b01) ? cfg_datain[23:16] :
                      (byte_cnt == 2'b10) ? cfg_datain[15:8]  : cfg_datain[7:0] ;
         
assign shift_out =  shift_enb && sck_ne;

always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
      spiif_cs    <= `SPI_IDLE;
      sck_cnt     <= 6'h0;
      shift_in    <= 1'b0;
      clr_sck_cnt <= 1'b1;
      byte_cnt    <= 2'b00;
      cs_int_n    <= 1'b1;
      sck_out_en  <= 1'b0;
      shift_enb   <= 1'b0;
      cfg_dataout <= 32'h0;
      load_byte   <= 1'b0;
   end
   else begin
      if(sck_ne)
         sck_cnt <=  clr_sck_cnt  ? 6'h0 : sck_cnt + 1 ;

      case(spiif_cs)
      `SPI_IDLE   : 
      begin
          op_done     <= 0;
          clr_sck_cnt <= 1'b1;
          sck_out_en  <= 1'b0;
          shift_enb   <= 1'b0;
          if(cfg_op_req) 
          begin
              cfg_dataout <= 32'h0;
              spiif_cs    <= `SPI_CS_SU;
           end 
           else begin
              spiif_cs <= `SPI_IDLE;
           end 
      end 

      `SPI_CS_SU  : 
       begin
          if(sck_ne) begin
            cs_int_n <= cs_data[1];
            if(sck_cnt == cfg_sck_cs_period) begin
               clr_sck_cnt <= 1'b1;
               if(cfg_op_type == 0) begin // Write Mode
                  load_byte   <= 1'b1;
                  spiif_cs    <= `SPI_WRITE;
                  shift_enb   <= 1'b0;
               end else begin
                  shift_in    <= 1;
                  spiif_cs    <= `SPI_READ;
                end
             end
             else begin 
                clr_sck_cnt <= 1'b0;
             end
         end
      end 

      `SPI_WRITE : 
       begin 
         load_byte   <= 1'b0;
         if(sck_ne) begin
           if(sck_cnt == 3'h7 )begin
              clr_sck_cnt <= 1'b1;
              spiif_cs    <= `SPI_CS_HLD;
              shift_enb   <= 1'b0;
              sck_out_en  <= 1'b0; // Disable clock output
           end
           else begin
              shift_enb   <= 1'b1;
              sck_out_en  <= 1'b1;
              clr_sck_cnt <= 1'b0;
           end
         end else begin
            shift_enb   <= 1'b1;
         end
      end 

      `SPI_READ : 
       begin 
         if(sck_ne) begin
             if( sck_cnt == 3'h7 ) begin
                clr_sck_cnt <= 1'b1;
                shift_in    <= 0;
                spiif_cs    <= `SPI_CS_HLD;
                sck_out_en  <= 1'b0; // Disable clock output
             end
             else begin
                sck_out_en  <= 1'b1; // Disable clock output
                clr_sck_cnt <= 1'b0;
             end
         end
      end 

      `SPI_CS_HLD : begin
         if(sck_ne) begin
             cs_int_n <= cs_data[0];
            if(sck_cnt == cfg_sck_cs_period) begin
               if(cfg_op_type == 1) begin // Read Mode
                  cfg_dataout <= (byte_cnt[1:0] == 2'b00) ? { byte_in, cfg_dataout[23:0] } :
                                 (byte_cnt[1:0] == 2'b01) ? { cfg_dataout[31:24] ,
                                                              byte_in, cfg_dataout[15:0] } :
                                 (byte_cnt[1:0] == 2'b10) ? { cfg_dataout[31:16] ,
                                                              byte_in, cfg_dataout[7:0]  } :
                                                            { cfg_dataout[31:8]  ,
                                                              byte_in  } ;
               end
               clr_sck_cnt <= 1'b1;
               if(byte_cnt == cfg_transfer_size) begin
                  spiif_cs <= `SPI_WAIT;
                  byte_cnt <= 0;
                  op_done  <= 1;
               end else begin
                  byte_cnt <= byte_cnt +1;
                  spiif_cs <= `SPI_CS_SU;
               end
            end
            else begin
                clr_sck_cnt <= 1'b0;
            end
         end 
      end // case: `SPI_CS_HLD    
      `SPI_WAIT : begin
          if(!cfg_op_req) // Wait for Request de-assertion
             spiif_cs <= `SPI_IDLE;
       end
    endcase // casex(spiif_cs)
   end
end // always @(sck_ne

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/spi/spi_if.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores SPI Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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

module spi_if
          (
           clk, 
           reset_n,

           // towards ctrl i/f
           sck_pe,
           sck_int,
           cs_int_n,
           byte_in,
           load_byte,
           byte_out,
           shift_out,
           shift_in,

           cfg_tgt_sel,

           sck,
           so,
           si,
           cs_n
           );

  input clk,reset_n;
  input sck_pe;
  input sck_int,cs_int_n;
  
  input       load_byte;
  input [1:0] cfg_tgt_sel;

  input [7:0] byte_out;
  input       shift_out,shift_in;

  output [7:0] byte_in;
  output       sck,so;
  output [3:0] cs_n;
  input        si;


  reg [7:0]    so_reg;
  reg [7:0]    si_reg;
  wire [7:0]   byte_out;
  wire         sck;
  reg          so;
  wire [3:0]   cs_n;


  //Output Shift Register

  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        so_reg <= 8'h00;
        so <= 1'b0;
     end
     else begin
        if(load_byte) begin
           so_reg <= byte_out;
           if(shift_out) begin 
              // Handling backto back case : 
              // Last Transfer bit + New Trasfer Load
              so <= so_reg[7];
           end
        end // if (load_byte)
        else begin
           if(shift_out) begin
              so <= so_reg[7];
              so_reg <= {so_reg[6:0],1'b0};
           end // if (shift_out)
        end // else: !if(load_byte)
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)


// Input shift register
  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        si_reg <= 8'h0;
     end
     else begin
        if(sck_pe & shift_in) begin
           si_reg[7:0] <= {si_reg[6:0],si};
        end // if (sck_pe & shift_in)
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)


  assign byte_in[7:0] = si_reg[7:0];
  assign cs_n[0] = (cfg_tgt_sel[1:0] == 2'b00) ? cs_int_n : 1'b1;
  assign cs_n[1] = (cfg_tgt_sel[1:0] == 2'b01) ? cs_int_n : 1'b1;
  assign cs_n[2] = (cfg_tgt_sel[1:0] == 2'b10) ? cs_int_n : 1'b1;
  assign cs_n[3] = (cfg_tgt_sel[1:0] == 2'b11) ? cs_int_n : 1'b1;
  assign sck = sck_int;

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/uart_core/clk_ctl.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores common library Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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

// #################################################################
// Module: clk_ctl
//
// Description:  Generic clock control logic , clk-out = mclk/(2+clk_div_ratio)
//
//  
// #################################################################


module clk_ctl (
   // Outputs
       clk_o,
   // Inputs
       mclk,
       reset_n, 
       clk_div_ratio 
   );

//---------------------------------
// CLOCK Default Divider value.
// This value will be change from outside
//---------------------------------
parameter  WD = 'h1;

//---------------------------------------------
// All the input to this block are declared here
// --------------------------------------------
   input        mclk          ;// 
   input        reset_n       ;// primary reset signal
   input [WD:0] clk_div_ratio ;// primary clock divide ratio
                               // output clock = selected clock / (div_ratio+1)
   
//---------------------------------------------
// All the output to this block are declared here
// --------------------------------------------
   output       clk_o             ; // clock out

               

//------------------------------------
// Clock Divide func is done here
//------------------------------------
reg  [WD-1:0]    high_count       ; // high level counter
reg  [WD-1:0]    low_count        ; // low level counter
reg              mclk_div         ; // divided clock


assign clk_o  = mclk_div;

always @ (posedge mclk or negedge reset_n)
begin // {
   if(reset_n == 1'b0) 
   begin 
      high_count  <= 'h0;
      low_count   <= 'h0;
      mclk_div    <= 'b0;
   end   
   else 
   begin 
      if(high_count != 0)
      begin // {
         high_count    <= high_count - 1;
         mclk_div      <= 1'b1;
      end   // }
      else if(low_count != 0)
      begin // {
         low_count     <= low_count - 1;
         mclk_div      <= 1'b0;
      end   // }
      else
      begin // {
         high_count    <= clk_div_ratio[WD:1] + clk_div_ratio[0];
         low_count     <= clk_div_ratio[WD:1] + 1;
         mclk_div      <= ~mclk_div;
      end   // }
   end   // }
end   // }


endmodule 


// -----------------------------------------------------------------------------
// Source file: rtl/uart_core/uart_core.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores UART Interface Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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
module uart_core (  
        line_reset_n ,
        line_clk ,

	// configuration control
        cfg_tx_enable  , // Enable Transmit Path
        cfg_rx_enable  , // Enable Received Path
        cfg_stop_bit   , // 0 -> 1 Start , 1 -> 2 Stop Bits
        cfg_pri_mod    , // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
	cfg_baud_16x   ,

    // TXD Information
        tx_data_avail,
        tx_rd,
        tx_data,
         

    // RXD Information
        rx_ready,
        rx_wr,
        rx_data,

       // Status information
        frm_error,
	par_error,

	baud_clk_16x,

       // Line Interface
        rxd,
        txd

     );



//---------------------------------
// Global Dec
// ---------------------------------

input        line_reset_n         ; // line reset
input        line_clk             ; // line clock

//-------------------------------------
// Configuration 
// -------------------------------------
input         cfg_tx_enable        ; // Tx Enable
input         cfg_rx_enable        ; // Rx Enable
input         cfg_stop_bit         ; // 0 -> 1 Stop, 1 -> 2 Stop
input   [1:0] cfg_pri_mod          ; // priority mode, 0 -> nop, 1 -> Even, 2 -> Odd
input   [11:0] cfg_baud_16x        ; // 16x Baud clock generation

//--------------------------------------
// TXD Path
// -------------------------------------
input         tx_data_avail        ; // Indicate valid TXD Data 
input [7:0]   tx_data              ; // TXD Data to be transmited
output        tx_rd                ; // Indicate TXD Data Been Read


//--------------------------------------
// RXD Path
// -------------------------------------
input         rx_ready            ; // Indicate Ready to accept the Read Data
output [7:0]  rx_data             ; // RXD Data 
output        rx_wr               ; // Valid RXD Data


//--------------------------------------
// ERROR Indication
// -------------------------------------
output        frm_error            ; // framing error
output        par_error            ; // par error

output        baud_clk_16x         ; // 16x Baud clock


//-------------------------------------
// Line Interface
// -------------------------------------
input         rxd                  ; // uart rxd
output        txd                  ; // uart txd

// Wire Declaration

wire [1  : 0]   error_ind          ;


// 16x Baud clock generation
// Example: to generate 19200 Baud clock from 50Mhz Link clock
//    50 * 1000 * 1000 / (2 + cfg_baud_16x) = 19200 * 16
//    cfg_baud_16x = 0xA0 (160)

clk_ctl #(11) u_clk_ctl (
   // Outputs
       .clk_o          (baud_clk_16x),

   // Inputs
       .mclk           (line_clk),
       .reset_n        (line_reset_n), 
       .clk_div_ratio  (cfg_baud_16x)
   );


uart_txfsm u_txfsm (
               . reset_n           ( line_reset_n      ),
               . baud_clk_16x      ( baud_clk_16x      ),

               . cfg_tx_enable     ( cfg_tx_enable     ),
               . cfg_stop_bit      ( cfg_stop_bit      ),
               . cfg_pri_mod       ( cfg_pri_mod       ),

       // FIFO control signal
               . fifo_empty        ( !tx_data_avail    ),
               . fifo_rd           ( tx_rd             ),
               . fifo_data         ( tx_data           ),

          // Line Interface
               . so                ( txd                )
          );


uart_rxfsm u_rxfsm (
               . reset_n           (  line_reset_n     ),
               . baud_clk_16x      (  baud_clk_16x     ) ,

               . cfg_rx_enable     (  cfg_rx_enable    ),
               . cfg_stop_bit      (  cfg_stop_bit     ),
               . cfg_pri_mod       (  cfg_pri_mod      ),

               . error_ind         (  error_ind        ),

       // FIFO control signal
               .  fifo_aval        ( rx_ready          ),
               .  fifo_wr          ( rx_wr             ),
               .  fifo_data        ( rx_data           ),

          // Line Interface
               .  si               (rxd              )
          );


wire   frm_error          = (error_ind == 2'b01);
wire   par_error          = (error_ind == 2'b10);



endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/uart_core/uart_rxfsm.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores UART Interface Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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

// UART rx state machine

module uart_rxfsm (
             reset_n        ,
             baud_clk_16x   ,

             cfg_rx_enable  ,
             cfg_stop_bit   ,
             cfg_pri_mod    ,

             error_ind      ,

       // FIFO control signal
             fifo_aval      ,
             fifo_wr        ,
             fifo_data      ,

          // Line Interface
             si  
          );


input             reset_n        ; // active low reset signal
input             baud_clk_16x   ; // baud clock-16x

input             cfg_rx_enable  ; // transmit interface enable
input             cfg_stop_bit   ; // stop bit 
                                   // 0 --> 1 stop, 1 --> 2 Stop
input   [1:0]     cfg_pri_mod    ;// Priority Mode
                                   // 2'b00 --> None
                                   // 2'b10 --> Even priority
                                   // 2'b11 --> Odd priority

output [1:0]      error_ind     ; // 2'b00 --> Normal
                                  // 2'b01 --> framing error
                                  // 2'b10 --> parity error
                                  // 2'b11 --> fifo full
//--------------------------------------
//   FIFO control signal
//--------------------------------------
input             fifo_aval      ; // fifo empty
output            fifo_wr        ; // fifo write, assumed no back to back write
output  [7:0]     fifo_data      ; // fifo write data

// Line Interface
input             si             ;  // rxd pin



reg     [7:0]    fifo_data       ; // fifo write data
reg              fifo_wr         ; // fifo write 
reg    [1:0]     error_ind       ; 
reg    [2:0]     cnt             ;
reg    [3:0]     offset          ; // free-running counter from 0 - 15
reg    [3:0]     rxpos           ; // stable rx position
reg    [2:0]     rxstate         ;
reg              si_d            ; // delayed si
reg              si_2d           ; // 2 cycle delayed si

parameter idle_st      = 3'b000;
parameter xfr_start    = 3'b001;
parameter xfr_data_st  = 3'b010;
parameter xfr_pri_st   = 3'b011;
parameter xfr_stop_st1 = 3'b100;
parameter xfr_stop_st2 = 3'b101;


always @(negedge reset_n or posedge baud_clk_16x) begin
   if(reset_n == 0) begin
      rxstate   <= 3'b0;
      offset    <= 4'b0;
      rxpos     <= 4'b0;
      cnt       <= 3'b0;
      error_ind <= 2'b0;
      fifo_wr   <= 1'b0;
      fifo_data <= 8'h0;
      si_d      <= 1'b1;
      si_2d     <= 1'b1;
   end
   else begin
      // two cycle double sync uart-si to take care of async behaviour
      si_d      <= si;
      si_2d     <= si_d;
      offset     <= offset + 1;
      case(rxstate)
       idle_st   : begin
            if(!si_2d) begin // Start indication
               if(fifo_aval && cfg_rx_enable) begin
                 rxstate   <=   xfr_start;
                 cnt       <=   0;
                 rxpos     <=   offset + 8; // Assign center rxoffset
                 error_ind <= 2'b00;
               end
               else begin
                  error_ind <= 2'b11; // fifo full error indication
               end
            end else begin
               error_ind <= 2'b00; // Reset Error
            end
         end
      xfr_start : begin
            // Make Sure that minimum 8 cycle low is detected
            if(cnt < 7 && si_2d) begin // Start indication
               rxstate <=   idle_st;
            end
            else if(cnt == 7 && !si_2d) begin // Start indication
                rxstate <=   xfr_data_st;
                cnt     <=   0;
            end else begin
              cnt  <= cnt +1;
            end
         end
      xfr_data_st : begin
             if(rxpos == offset) begin
                fifo_data[cnt] <= si_2d;
                cnt            <= cnt+1;
                if(cnt == 7) begin
                   fifo_wr <= 1;
                   if(cfg_pri_mod == 2'b00)  // No Priority
                       rxstate <=   xfr_stop_st1;
                   else rxstate <= xfr_pri_st;  
                end
             end
          end
       xfr_pri_st   : begin
            fifo_wr <= 0;
            if(rxpos == offset) begin
               if(cfg_pri_mod == 2'b10)  // even priority
                  if( si_2d != ^fifo_data) error_ind <= 2'b10;
               else  // Odd Priority
                  if( si_2d != ~(^fifo_data)) error_ind <= 2'b10;
               rxstate <=   xfr_stop_st1;
            end
         end
       xfr_stop_st1  : begin
          fifo_wr <= 0;
          if(rxpos == offset) begin
             if(si_2d) begin
               if(cfg_stop_bit) // Two Stop bit
                  rxstate <=   xfr_stop_st2;
               else   
                  rxstate <=   idle_st;
             end else begin // Framing error
                error_ind <= 2'b01;
                rxstate   <=   idle_st;
             end
          end
       end
       xfr_stop_st2  : begin
          if(rxpos == offset) begin
             if(si_2d) begin
                rxstate <=   idle_st;
             end else begin // Framing error
                error_ind <= 2'b01;
                rxstate   <=   idle_st;
             end
          end
       end
    endcase
   end
end


endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/uart_core/uart_txfsm.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores UART Interface Module                       ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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


// UART tx state machine

module uart_txfsm (
             reset_n        ,
             baud_clk_16x   ,

             cfg_tx_enable  ,
             cfg_stop_bit   ,
             cfg_pri_mod    ,

       // FIFO control signal
             fifo_empty     ,
             fifo_rd        ,
             fifo_data      ,

          // Line Interface
             so  
          );


input             reset_n        ; // active low reset signal
input             baud_clk_16x   ; // baud clock-16x

input             cfg_tx_enable  ; // transmit interface enable
input             cfg_stop_bit   ; // stop bit 
                                   // 0 --> 1 stop, 1 --> 2 Stop
input   [1:0]     cfg_pri_mod    ;// Priority Mode
                                   // 2'b00 --> None
                                   // 2'b10 --> Even priority
                                   // 2'b11 --> Odd priority

//--------------------------------------
//   FIFO control signal
//--------------------------------------
input             fifo_empty     ; // fifo empty
output            fifo_rd        ; // fifo read, assumed no back to back read
input  [7:0]      fifo_data      ; // fifo read data

// Line Interface
output            so             ;  // txd pin


reg  [2:0]         txstate       ; // tx state
reg                so            ; // txd pin
reg  [7:0]         txdata        ; // local txdata
reg                fifo_rd       ; // Fifo read enable
reg  [2:0]         cnt           ; // local data cont
reg  [3:0]         divcnt        ; // clock div count

parameter idle_st      = 3'b000;
parameter xfr_data_st  = 3'b001;
parameter xfr_pri_st   = 3'b010;
parameter xfr_stop_st1 = 3'b011;
parameter xfr_stop_st2 = 3'b100;


always @(negedge reset_n or posedge baud_clk_16x)
begin
   if(reset_n == 1'b0) begin
      txstate  <= idle_st;
      so       <= 1'b1;
      cnt      <= 3'b0;
      txdata   <= 8'h0;
      fifo_rd  <= 1'b0;
      divcnt   <= 4'b0;
   end
   else begin
      divcnt <= divcnt+1;
      if(divcnt == 4'b0000) begin // Do at once in 16 clock
         case(txstate)
          idle_st      : begin
               if(!fifo_empty && cfg_tx_enable) begin
                  so       <= 1'b0 ; // Start bit
                  cnt      <= 3'b0;
                  fifo_rd  <= 1'b1;
                  txdata   <= fifo_data;
                  txstate  <= xfr_data_st;  
               end
            end

          xfr_data_st  : begin
              fifo_rd  <= 1'b0;
              so   <= txdata[cnt];
              cnt  <= cnt+1;
              if(cnt == 7) begin
                 if(cfg_pri_mod == 2'b00) begin // No Priority
                    txstate  <= xfr_stop_st1;  
                 end
                 else begin
                    txstate <= xfr_pri_st;  
                 end
              end
           end

          xfr_pri_st   : begin
               if(cfg_pri_mod == 2'b10)  // even priority
                   so <= ^txdata;
               else begin // Odd Priority
                   so <= ~(^txdata);
               end
               txstate  <= xfr_stop_st1;  
            end

          xfr_stop_st1  : begin // First Stop Bit
               so <= 1;
               if(cfg_stop_bit == 0)  // 1 Stop Bit
                    txstate <= idle_st;
               else // 2 Stop Bit 
                  txstate  <= xfr_stop_st2;
            end

          xfr_stop_st2  : begin // Second Stop Bit
               so <= 1;
               txstate <= idle_st;
            end
         endcase
      end else begin
        fifo_rd  <= 1'b0;
     end
   end
end


endmodule
