// Curated RTL benchmark case.
// case_id: bench_0045_communication_controller_ps_2_host_controller
// source_project: communication_controller_ps-2_host_controller
// top_module: ps2_host


// -----------------------------------------------------------------------------
// Source file: hdl/ps2_host_defines.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_defines.v                                          ////
////                                                              ////
////  Description                                                 ////
////  Bunch of defines used in this core                          ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

`ifndef SYS_CLOCK_HZ
`define SYS_CLOCK_HZ 100_000_000
`endif

`define T_100_MICROSECONDS (`SYS_CLOCK_HZ / 10_000)
`define T_200_MICROSECONDS (`SYS_CLOCK_HZ /  5_000)
// Ideally below define should be $clog2(`T_100_MICROSECONDS + 1)
`define T_100_MICROSECONDS_SIZE 14
// ... and same here $clog2(`T_200_MICROSECONDS + 1)
`define T_200_MICROSECONDS_SIZE 15

// -----------------------------------------------------------------------------
// Source file: hdl/ps2_host.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host.v                                                  ////
////                                                              ////
////  Description                                                 ////
////  Top file, gluing all parts together                         ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "ps2_host_clk_ctrl.v"
`include "ps2_host_watchdog.v"
`include "ps2_host_rx.v"
`include "ps2_host_tx.v"

module ps2_host(
  input wire sys_clk,
  input wire sys_rst,
  inout wire ps2_clk,
  inout wire ps2_data,

  input  wire [7:0] tx_data,
  input  wire send_req,
  output wire busy,

  output wire [7:0] rx_data,
  output wire ready,
  output wire error
);

ps2_host_clk_ctrl ps2_host_clk_ctrl (
  .sys_clk(sys_clk),
  .sys_rst(sys_rst),
  .send_req(send_req),
  .ps2_clk(ps2_clk),
  .ps2_clk_posedge(ps2_clk_posedge),
  .ps2_clk_negedge(ps2_clk_negedge)
);

ps2_host_watchdog ps2_host_watchdog(
  .sys_clk(sys_clk),
  .sys_rst(sys_rst),
  .ps2_clk_posedge(ps2_clk_posedge),
  .ps2_clk_negedge(ps2_clk_negedge),
  .watchdog_rst(watchdog_rst)
);

ps2_host_rx ps2_host_rx(
  .sys_clk(sys_clk),
  .sys_rst(sys_rst | busy | watchdog_rst),
  .ps2_clk_negedge(ps2_clk_negedge),
  .ps2_data(ps2_data),
  .rx_data(rx_data),
  .ready(ready),
  .error(error)
);

ps2_host_tx ps2_host_tx(
  .sys_clk(sys_clk),
  .sys_rst(sys_rst | watchdog_rst),
  .ps2_clk_posedge(ps2_clk_posedge),
  .ps2_data(ps2_data),
  .tx_data(tx_data),
  .send_req(send_req),
  .busy(busy)
);

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/ps2_host_clk_ctrl.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_clk_ctrl.v                                         ////
////                                                              ////
////  Description                                                 ////
////  Taking care of all interactions with ps2_clk line           ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "ps2_host_defines.v"

module ps2_host_clk_ctrl(
  input  wire sys_clk,
  input  wire sys_rst,
  input  wire send_req,
  inout  wire ps2_clk,
  output wire ps2_clk_posedge,
  output wire ps2_clk_negedge
);

// Sample ps2_clk and detect rising and falling edge
reg [1:0] ps2_clk_samples;
always @(posedge sys_clk)
begin
  ps2_clk_samples <= (sys_rst) ? 2'b11 : {ps2_clk_samples[0], ps2_clk};
end

assign ps2_clk_posedge = (~ps2_clk_samples[1] &  ps2_clk_samples[0]);
assign ps2_clk_negedge = ( ps2_clk_samples[1] & ~ps2_clk_samples[0]);

// When send_req pulse arrives pull ps2_clk to zero for 100us
reg [`T_100_MICROSECONDS_SIZE - 1:0] inhibit_timer;
wire timer_is_zero = ~|inhibit_timer;
always @(posedge sys_clk)
begin
  if (sys_rst | (~send_req & timer_is_zero)) begin
    inhibit_timer <= 0;
  end
  else begin
    inhibit_timer <= (timer_is_zero) ? `T_100_MICROSECONDS : inhibit_timer - 1;
  end
end

assign ps2_clk = (timer_is_zero) ? 1'bz : 1'b0;

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/ps2_host_rx.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_rx.v                                               ////
////                                                              ////
////  Description                                                 ////
////  Receiver part, gathering bits from the ps2_data line        ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module ps2_host_rx(
  input  wire sys_clk,
  input  wire sys_rst,
  input  wire ps2_clk_negedge,
  input  wire ps2_data,
  output reg [7:0] rx_data,
  output reg ready,
  output reg error
);

// Read in 11 bit long frame.
reg [11:0] frame;
always @(posedge sys_clk)
begin
  if (sys_rst | ready) begin
    frame <= 1;
  end
  else begin
    frame <= (ps2_clk_negedge) ? {frame[10:0], ps2_data} : frame;
  end
end

// 12th bit marks end of frame.
always @(posedge sys_clk)
begin
  ready <= (sys_rst) ? 0 : frame[11];
end

// Return rx_data in most significant bit first order.
always @(posedge sys_clk)
begin
  if (sys_rst) begin
    rx_data <= 0;
  end
  else begin
    rx_data <= (frame[11]) ? {frame[2], frame[3], frame[4], frame[5],
                              frame[6], frame[7], frame[8], frame[9]} : rx_data;
  end
end

// Check that 1st bit is 0, odd parity bit is correct and last bit is 1.
always @(posedge sys_clk)
begin
  if (sys_rst) begin
    error <= 0;
  end
  else begin
    error <= (frame[11]) ? ~(~frame[10] & (~frame[1] == ^frame[9:2]) & frame[0]) : error;
  end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/ps2_host_tx.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_tx.v                                               ////
////                                                              ////
////  Description                                                 ////
////  Transmitter part, sending bits down the ps2_data line       ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module ps2_host_tx(
  input  wire sys_clk,
  input  wire sys_rst,
  input  wire ps2_clk_posedge,
  inout  wire ps2_data,
  input  wire [7:0] tx_data,
  input  wire send_req,
  output wire busy
);

reg [11:0] frame;
wire frame_is_zero = ~|frame;
always @(posedge sys_clk)
begin
  if (sys_rst | (~send_req & frame_is_zero)) begin
    frame <= 0;
  end
  else if (frame_is_zero) begin
    frame <= {2'b00, tx_data[0], tx_data[1], tx_data[2], tx_data[3],
                     tx_data[4], tx_data[5], tx_data[6], tx_data[7], ~^tx_data, 1'b1};
  end
  else begin
    frame <= (ps2_clk_posedge) ? {frame[10:0], 1'b0} : frame;
  end
end

// Send data down the line.
assign ps2_data = ((~|frame[10:0]) | frame[0]) ? 1'bz : frame[11];

// Keep high until all bits transmitted and ACK received
assign busy = ~frame_is_zero;

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/ps2_host_watchdog.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_host_watchdog.v                                         ////
////                                                              ////
////  Description                                                 ////
////  Generate reset signal if ps2_clk line is too quiet          ////
////                                                              ////
////  Author:                                                     ////
////      - Piotr Foltyn, piotr.foltyn@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2011 Author                                    ////
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "ps2_host_defines.v"

module ps2_host_watchdog(
  input  wire sys_clk,
  input  wire sys_rst,
  input  wire ps2_clk_posedge,
  input  wire ps2_clk_negedge,
  output wire watchdog_rst
);

wire ps2_clk_edge = ps2_clk_posedge | ps2_clk_negedge;

reg watchdog_active;
always @(posedge sys_clk)
begin
  if (sys_rst | watchdog_rst | ~(watchdog_active | ps2_clk_edge)) begin
    watchdog_active = 0;
  end
  else begin
    watchdog_active = 1;
  end
end

reg [`T_200_MICROSECONDS_SIZE - 1:0] watchdog_timer;
always @(posedge sys_clk)
begin
  if (sys_rst | watchdog_rst | ~watchdog_active | ps2_clk_edge) begin
    watchdog_timer <= `T_200_MICROSECONDS;
  end
  else begin
    watchdog_timer <= watchdog_timer - 1;
  end
end

assign watchdog_rst = (|watchdog_timer) ? 1'b0 : 1'b1;

endmodule
