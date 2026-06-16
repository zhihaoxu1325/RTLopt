// Curated RTL benchmark case.
// case_id: bench_0205_memory_core_high_performance_dynamic_memory_controller
// source_project: memory_core_high_performance_dynamic_memory_controller
// top_module: hpdmc


// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/hpdmc.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc #(
	parameter csr_addr = 4'h0,
	/*
	 * The depth of the SDRAM array, in bytes.
	 * Capacity (in bytes) is 2^sdram_depth.
	 */
	parameter sdram_depth = 26,
	
	/*
	 * The number of column address bits of the SDRAM.
	 */
	parameter sdram_columndepth = 9
) (
	input sys_clk,
	input sys_clk_n,
	/*
	 * Clock used to generate DQS.
	 * Typically sys_clk phased out by 90 degrees,
	 * as data is sent synchronously to sys_clk.
	 */
	input dqs_clk,
	input dqs_clk_n,
	
	input sys_rst,
	
	/* Control interface */
	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output [31:0] csr_do,
	
	/* Simple FML 4x64 interface to the memory contents */
	input [sdram_depth-1:0] fml_adr,
	input fml_stb,
	input fml_we,
	output fml_ack,
	input [7:0] fml_sel,
	input [63:0] fml_di,
	output [63:0] fml_do,
	
	/* SDRAM interface.
	 * The SDRAM clock should be driven synchronously to the system clock.
	 * It is not generated inside this core so you can take advantage of
	 * architecture-dependent clocking resources to generate a clean
	 * differential clock.
	 */
	output reg sdram_cke,
	output reg sdram_cs_n,
	output reg sdram_we_n,
	output reg sdram_cas_n,
	output reg sdram_ras_n,
	output reg [12:0] sdram_adr,
	output reg [1:0] sdram_ba,
	
	output [3:0] sdram_dm,
	inout [31:0] sdram_dq,
	inout [3:0] sdram_dqs,
	
	/* Interface to the DCM generating DQS */
	output dqs_psen,
	output dqs_psincdec,
	input dqs_psdone,

	input [1:0] pll_stat
);

/* Register all control signals, leaving the possibility to use IOB registers */
wire sdram_cke_r;
wire sdram_cs_n_r;
wire sdram_we_n_r;
wire sdram_cas_n_r;
wire sdram_ras_n_r;
wire [12:0] sdram_adr_r;
wire [1:0] sdram_ba_r;

always @(posedge sys_clk) begin
	sdram_cke <= sdram_cke_r;
	sdram_cs_n <= sdram_cs_n_r;
	sdram_we_n <= sdram_we_n_r;
	sdram_cas_n <= sdram_cas_n_r;
	sdram_ras_n <= sdram_ras_n_r;
	sdram_ba <= sdram_ba_r;
	sdram_adr <= sdram_adr_r;
end

/* Mux the control signals according to the "bypass" selection.
 * CKE always comes from the control interface.
 */
wire bypass;

wire sdram_cs_n_bypass;
wire sdram_we_n_bypass;
wire sdram_cas_n_bypass;
wire sdram_ras_n_bypass;
wire [12:0] sdram_adr_bypass;
wire [1:0] sdram_ba_bypass;

wire sdram_cs_n_mgmt;
wire sdram_we_n_mgmt;
wire sdram_cas_n_mgmt;
wire sdram_ras_n_mgmt;
wire [12:0] sdram_adr_mgmt;
wire [1:0] sdram_ba_mgmt;

assign sdram_cs_n_r = bypass ? sdram_cs_n_bypass : sdram_cs_n_mgmt;
assign sdram_we_n_r = bypass ? sdram_we_n_bypass : sdram_we_n_mgmt;
assign sdram_cas_n_r = bypass ? sdram_cas_n_bypass : sdram_cas_n_mgmt;
assign sdram_ras_n_r = bypass ? sdram_ras_n_bypass : sdram_ras_n_mgmt;
assign sdram_adr_r = bypass ? sdram_adr_bypass : sdram_adr_mgmt;
assign sdram_ba_r = bypass ? sdram_ba_bypass : sdram_ba_mgmt;

/* Control interface */
wire sdram_rst;

wire [2:0] tim_rp;
wire [2:0] tim_rcd;
wire tim_cas;
wire [10:0] tim_refi;
wire [3:0] tim_rfc;
wire [1:0] tim_wr;

wire idelay_rst;
wire idelay_ce;
wire idelay_inc;

hpdmc_ctlif #(
	.csr_addr(csr_addr)
) ctlif (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	
	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_di(csr_di),
	.csr_do(csr_do),
	
	.bypass(bypass),
	.sdram_rst(sdram_rst),
	
	.sdram_cke(sdram_cke_r),
	.sdram_cs_n(sdram_cs_n_bypass),
	.sdram_we_n(sdram_we_n_bypass),
	.sdram_cas_n(sdram_cas_n_bypass),
	.sdram_ras_n(sdram_ras_n_bypass),
	.sdram_adr(sdram_adr_bypass),
	.sdram_ba(sdram_ba_bypass),
	
	.tim_rp(tim_rp),
	.tim_rcd(tim_rcd),
	.tim_cas(tim_cas),
	.tim_refi(tim_refi),
	.tim_rfc(tim_rfc),
	.tim_wr(tim_wr),
	
	.idelay_rst(idelay_rst),
	.idelay_ce(idelay_ce),
	.idelay_inc(idelay_inc),
	
	.dqs_psen(dqs_psen),
	.dqs_psincdec(dqs_psincdec),
	.dqs_psdone(dqs_psdone),

	.pll_stat(pll_stat)
);

/* SDRAM management unit */
wire mgmt_stb;
wire mgmt_we;
wire [sdram_depth-3-1:0] mgmt_address;
wire mgmt_ack;

wire read;
wire write;
wire [3:0] concerned_bank;
wire read_safe;
wire write_safe;
wire [3:0] precharge_safe;

hpdmc_mgmt #(
	.sdram_depth(sdram_depth),
	.sdram_columndepth(sdram_columndepth)
) mgmt (
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.tim_rp(tim_rp),
	.tim_rcd(tim_rcd),
	.tim_refi(tim_refi),
	.tim_rfc(tim_rfc),
	
	.stb(mgmt_stb),
	.we(mgmt_we),
	.address(mgmt_address),
	.ack(mgmt_ack),
	
	.read(read),
	.write(write),
	.concerned_bank(concerned_bank),
	.read_safe(read_safe),
	.write_safe(write_safe),
	.precharge_safe(precharge_safe),
	
	.sdram_cs_n(sdram_cs_n_mgmt),
	.sdram_we_n(sdram_we_n_mgmt),
	.sdram_cas_n(sdram_cas_n_mgmt),
	.sdram_ras_n(sdram_ras_n_mgmt),
	.sdram_adr(sdram_adr_mgmt),
	.sdram_ba(sdram_ba_mgmt)
);

/* Bus interface */
wire data_ack;

hpdmc_busif #(
	.sdram_depth(sdram_depth)
) busif (
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.fml_adr(fml_adr),
	.fml_stb(fml_stb),
	.fml_we(fml_we),
	.fml_ack(fml_ack),
	
	.mgmt_stb(mgmt_stb),
	.mgmt_we(mgmt_we),
	.mgmt_address(mgmt_address),
	.mgmt_ack(mgmt_ack),
	
	.data_ack(data_ack)
);

/* Data path controller */
wire direction;
wire direction_r;

hpdmc_datactl datactl(
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.read(read),
	.write(write),
	.concerned_bank(concerned_bank),
	.read_safe(read_safe),
	.write_safe(write_safe),
	.precharge_safe(precharge_safe),
	
	.ack(data_ack),
	.direction(direction),
	.direction_r(direction_r),
	
	.tim_cas(tim_cas),
	.tim_wr(tim_wr)
);

/* Data path */
hpdmc_ddrio ddrio(
	.sys_clk(sys_clk),
	.sys_clk_n(sys_clk_n),
	.dqs_clk(dqs_clk),
	.dqs_clk_n(dqs_clk_n),
	
	.direction(direction),
	.direction_r(direction_r),
	/* Bit meaning is the opposite between
	 * the FML selection signal and SDRAM DM pins.
	 */
	.mo(~fml_sel),
	.do(fml_di),
	.di(fml_do),
	
	.sdram_dm(sdram_dm),
	.sdram_dq(sdram_dq),
	.sdram_dqs(sdram_dqs),
	
	.idelay_rst(idelay_rst),
	.idelay_ce(idelay_ce),
	.idelay_inc(idelay_inc)
);

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/hpdmc_banktimer.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc_banktimer(
	input sys_clk,
	input sdram_rst,
	
	input tim_cas,
	input [1:0] tim_wr,
	
	input read,
	input write,
	output reg precharge_safe
);

reg [2:0] counter;
always @(posedge sys_clk) begin
	if(sdram_rst) begin
		counter <= 3'd0;
		precharge_safe <= 1'b1;
	end else begin
		if(read) begin
			/* see p.26 of datasheet :
			 * "A Read burst may be followed by, or truncated with, a Precharge command
			 * to the same bank. The Precharge command should be issued x cycles after
			 * the Read command, where x equals the number of desired data element
			 * pairs"
			 */
			counter <= 3'd4;
			precharge_safe <= 1'b0;
		end else if(write) begin
			counter <= {1'b1, tim_wr};
			precharge_safe <= 1'b0;
		end else begin
			if(counter == 3'b1)
				precharge_safe <= 1'b1;
			if(~precharge_safe)
				counter <= counter - 3'b1;
		end
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/hpdmc_busif.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/* Simple FML interface for HPDMC */

module hpdmc_busif #(
	parameter sdram_depth = 26
) (
	input sys_clk,
	input sdram_rst,
	
	input [sdram_depth-1:0] fml_adr,
	input fml_stb,
	input fml_we,
	output fml_ack,
	
	output mgmt_stb,
	output mgmt_we,
	output [sdram_depth-3-1:0] mgmt_address, /* in 64-bit words */
	input mgmt_ack,
	
	input data_ack
);

reg mgmt_stb_en;

assign mgmt_stb = fml_stb & mgmt_stb_en;
assign mgmt_we = fml_we;
assign mgmt_address = fml_adr[sdram_depth-1:3];

assign fml_ack = data_ack;

always @(posedge sys_clk) begin
	if(sdram_rst)
		mgmt_stb_en = 1'b1;
	else begin
		if(mgmt_ack)
			mgmt_stb_en = 1'b0;
		if(data_ack)
			mgmt_stb_en = 1'b1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/hpdmc_ctlif.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc_ctlif #(
	parameter csr_addr = 4'h0
) (
	input sys_clk,
	input sys_rst,
	
	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output reg [31:0] csr_do,
	
	output reg bypass,
	output reg sdram_rst,
	
	output reg sdram_cke,
	output reg sdram_cs_n,
	output reg sdram_we_n,
	output reg sdram_cas_n,
	output reg sdram_ras_n,
	output reg [12:0] sdram_adr,
	output reg [1:0] sdram_ba,
	
	/* Clocks we must wait following a PRECHARGE command (usually tRP). */
	output reg [2:0] tim_rp,
	/* Clocks we must wait following an ACTIVATE command (usually tRCD). */
	output reg [2:0] tim_rcd,
	/* CAS latency, 0 = 2 */
	output reg tim_cas,
	/* Auto-refresh period (usually tREFI). */
	output reg [10:0] tim_refi,
	/* Clocks we must wait following an AUTO REFRESH command (usually tRFC). */
	output reg [3:0] tim_rfc,
	/* Clocks we must wait following the last word written to the SDRAM (usually tWR). */
	output reg [1:0] tim_wr,
	
	output reg idelay_rst,
	output reg idelay_ce,
	output reg idelay_inc,
	
	output reg dqs_psen,
	output reg dqs_psincdec,
	input dqs_psdone,

	input [1:0] pll_stat
);

reg psready;
always @(posedge sys_clk) begin
	if(dqs_psdone)
		psready <= 1'b1;
	else if(dqs_psen)
		psready <= 1'b0;
end

wire csr_selected = csr_a[13:10] == csr_addr;

/* Double-latching on pll_stat (asynchronous) */
reg [1:0] pll_stat1;
reg [1:0] pll_stat2;
always @(posedge sys_clk) begin
	pll_stat1 <= pll_stat;
	pll_stat2 <= pll_stat1;
end

always @(posedge sys_clk) begin
	if(sys_rst) begin
		csr_do <= 32'd0;
	
		bypass <= 1'b1;
		sdram_rst <= 1'b1;
		
		sdram_cke <= 1'b0;
		sdram_adr <= 13'd0;
		sdram_ba <= 2'd0;
		
		tim_rp <= 3'd2;
		tim_rcd <= 3'd2;
		tim_cas <= 1'b0;
		tim_refi <= 11'd740;
		tim_rfc <= 4'd8;
		tim_wr <= 2'd2;
	end else begin
		sdram_cs_n <= 1'b1;
		sdram_we_n <= 1'b1;
		sdram_cas_n <= 1'b1;
		sdram_ras_n <= 1'b1;
		
		idelay_rst <= 1'b0;
		idelay_ce <= 1'b0;
		idelay_inc <= 1'b0;
			
		dqs_psen <= 1'b0;
		dqs_psincdec <= 1'b0;
		
		csr_do <= 32'd0;
		if(csr_selected) begin
			if(csr_we) begin
				case(csr_a[1:0])
					2'b00: begin
						bypass <= csr_di[0];
						sdram_rst <= csr_di[1];
						sdram_cke <= csr_di[2];
					end
					2'b01: begin
						sdram_cs_n <= ~csr_di[0];
						sdram_we_n <= ~csr_di[1];
						sdram_cas_n <= ~csr_di[2];
						sdram_ras_n <= ~csr_di[3];
						sdram_adr <= csr_di[16:4];
						sdram_ba <= csr_di[18:17];
					end
					2'b10: begin
						tim_rp <= csr_di[2:0];
						tim_rcd <= csr_di[5:3];
						tim_cas <= csr_di[6];
						tim_refi <= csr_di[17:7];
						tim_rfc <= csr_di[21:18];
						tim_wr <= csr_di[23:22];
					end
					2'b11: begin
						idelay_rst <= csr_di[0];
						idelay_ce <= csr_di[1];
						idelay_inc <= csr_di[2];
						
						dqs_psen <= csr_di[3];
						dqs_psincdec <= csr_di[4];
					end
				endcase
			end
			case(csr_a[1:0])
				2'b00: csr_do <= {sdram_cke, sdram_rst, bypass};
				2'b01: csr_do <= {sdram_ba, sdram_adr, 4'h0};
				2'b10: csr_do <= {tim_wr, tim_rfc, tim_refi, tim_cas, tim_rcd, tim_rp};
				2'b11: csr_do <= {pll_stat2, psready, 5'd0};
			endcase
		end
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/hpdmc_datactl.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc_datactl(
	input sys_clk,
	input sdram_rst,
	
	input read,
	input write,
	input [3:0] concerned_bank,
	output reg read_safe,
	output reg write_safe,
	output [3:0] precharge_safe,
	
	output reg ack,
	output reg direction,
	output direction_r,
	
	input tim_cas,
	input [1:0] tim_wr
);

/*
 * read_safe: whether it is safe to register a Read command
 * into the SDRAM at the next cycle.
 */

reg [2:0] read_safe_counter;
always @(posedge sys_clk) begin
	if(sdram_rst) begin
		read_safe_counter <= 3'd0;
		read_safe <= 1'b1;
	end else begin
		if(read) begin
			read_safe_counter <= 3'd4;
			read_safe <= 1'b0;
		end else if(write) begin
			/* after a write, read is unsafe for 5 cycles (4 transfers + tWTR=1) */
			read_safe_counter <= 3'd5;
			read_safe <= 1'b0;
		end else begin
			if(read_safe_counter == 3'd1)
				read_safe <= 1'b1;
			if(~read_safe)
				read_safe_counter <= read_safe_counter - 3'd1;
		end
	end
end

/*
 * write_safe: whether it is safe to register a Write command
 * into the SDRAM at the next cycle.
 */

reg [2:0] write_safe_counter;
always @(posedge sys_clk) begin
	if(sdram_rst) begin
		write_safe_counter <= 3'd0;
		write_safe <= 1'b1;
	end else begin
		if(read) begin
			write_safe_counter <= {1'b1, tim_cas, ~tim_cas};
			write_safe <= 1'b0;
		end else if(write) begin
			write_safe_counter <= 3'd3;
			write_safe <= 1'b0;
		end else begin
			if(write_safe_counter == 3'd1)
				write_safe <= 1'b1;
			if(~write_safe)
				write_safe_counter <= write_safe_counter - 3'd1;
		end
	end
end

/* Generate ack signal.
 * After write is asserted, it should pulse after 2 cycles.
 * After read is asserted, it should pulse after CL+3 cycles, that is
 * 5 cycles when tim_cas = 0
 * 6 cycles when tim_cas = 1
 */

reg ack_read3;
reg ack_read2;
reg ack_read1;
reg ack_read0;

always @(posedge sys_clk) begin
	if(sdram_rst) begin
		ack_read3 <= 1'b0;
		ack_read2 <= 1'b0;
		ack_read1 <= 1'b0;
		ack_read0 <= 1'b0;
	end else begin
		if(tim_cas) begin
			ack_read3 <= read;
			ack_read2 <= ack_read3;
			ack_read1 <= ack_read2;
			ack_read0 <= ack_read1;
		end else begin
			ack_read2 <= read;
			ack_read1 <= ack_read2;
			ack_read0 <= ack_read1;
		end
	end
end

reg ack0;
always @(posedge sys_clk) begin
	if(sdram_rst) begin
		ack0 <= 1'b0;
		ack <= 1'b0;
	end else begin
		ack0 <= ack_read0|write;
		ack <= ack0;
	end
end

/* during a 4-word write, we drive the pins for 5 cycles 
 * and 1 cycle in advance (first word is invalid)
 * so that we remove glitches on DQS without resorting
 * to asynchronous logic.
 */

/* direction must be glitch-free, as it directly drives the
 * tri-state enable for DQ and DQS.
 */
reg write_d;
reg [2:0] counter_writedirection;
always @(posedge sys_clk) begin
	if(sdram_rst) begin
		counter_writedirection <= 3'd0;
		direction <= 1'b0;
	end else begin
		if(write_d) begin
			counter_writedirection <= 3'b101;
			direction <= 1'b1;
		end else begin
			if(counter_writedirection == 3'b001)
				direction <= 1'b0;
			if(direction)
				counter_writedirection <= counter_writedirection - 3'd1;
		end
	end
end

assign direction_r = write_d|(|counter_writedirection);

always @(posedge sys_clk) begin
	if(sdram_rst)
		write_d <= 1'b0;
	else
		write_d <= write;
end

/* Counters that prevent a busy bank from being precharged */
hpdmc_banktimer banktimer0(
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.tim_cas(tim_cas),
	.tim_wr(tim_wr),
	
	.read(read & concerned_bank[0]),
	.write(write & concerned_bank[0]),
	.precharge_safe(precharge_safe[0])
);
hpdmc_banktimer banktimer1(
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.tim_cas(tim_cas),
	.tim_wr(tim_wr),
	
	.read(read & concerned_bank[1]),
	.write(write & concerned_bank[1]),
	.precharge_safe(precharge_safe[1])
);
hpdmc_banktimer banktimer2(
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.tim_cas(tim_cas),
	.tim_wr(tim_wr),
	
	.read(read & concerned_bank[2]),
	.write(write & concerned_bank[2]),
	.precharge_safe(precharge_safe[2])
);
hpdmc_banktimer banktimer3(
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.tim_cas(tim_cas),
	.tim_wr(tim_wr),
	
	.read(read & concerned_bank[3]),
	.write(write & concerned_bank[3]),
	.precharge_safe(precharge_safe[3])
);

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/hpdmc_mgmt.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc_mgmt #(
	parameter sdram_depth = 26,
	parameter sdram_columndepth = 9
) (
	input sys_clk,
	input sdram_rst,
	
	input [2:0] tim_rp,
	input [2:0] tim_rcd,
	input [10:0] tim_refi,
	input [3:0] tim_rfc,
	
	input stb,
	input we,
	input [sdram_depth-3-1:0] address, /* in 64-bit words */
	output reg ack,
	
	output reg read,
	output reg write,
	output [3:0] concerned_bank,
	input read_safe,
	input write_safe,
	input [3:0] precharge_safe,
	
	output sdram_cs_n,
	output sdram_we_n,
	output sdram_cas_n,
	output sdram_ras_n,
	output [12:0] sdram_adr,
	output [1:0] sdram_ba
);

/*
 * Address Mapping :
 * |    ROW ADDRESS   |    BANK NUMBER    |  COL ADDRESS  | for 32-bit words
 * |depth-1 coldepth+2|coldepth+1 coldepth|coldepth-1    0|
 * (depth for 32-bit words, which is sdram_depth-2)
 */

parameter rowdepth = sdram_depth-2-1-(sdram_columndepth+2)+1;

wire [sdram_depth-2-1:0] address32 = {address, 1'b0};

wire [sdram_columndepth-1:0] col_address = address32[sdram_columndepth-1:0];
wire [1:0] bank_address = address32[sdram_columndepth+1:sdram_columndepth];
wire [rowdepth-1:0] row_address = address32[sdram_depth-2-1:sdram_columndepth+2];

reg [3:0] bank_address_onehot;
always @(*) begin
	case(bank_address)
		2'b00: bank_address_onehot <= 4'b0001;
		2'b01: bank_address_onehot <= 4'b0010;
		2'b10: bank_address_onehot <= 4'b0100;
		2'b11: bank_address_onehot <= 4'b1000;
	endcase
end

/* Track open rows */
reg [3:0] has_openrow;
reg [rowdepth-1:0] openrows[0:3];
reg [3:0] track_close;
reg [3:0] track_open;

always @(posedge sys_clk) begin
	if(sdram_rst) begin
		has_openrow = 4'h0;
	end else begin
		has_openrow = (has_openrow | track_open) & ~track_close;
		
		if(track_open[0]) openrows[0] <= row_address;
		if(track_open[1]) openrows[1] <= row_address;
		if(track_open[2]) openrows[2] <= row_address;
 		if(track_open[3]) openrows[3] <= row_address;
	end
end

/* Bank precharge safety */
assign concerned_bank = bank_address_onehot;
wire current_precharge_safe =
	 (precharge_safe[0] | ~bank_address_onehot[0])
	&(precharge_safe[1] | ~bank_address_onehot[1])
	&(precharge_safe[2] | ~bank_address_onehot[2])
	&(precharge_safe[3] | ~bank_address_onehot[3]);


/* Check for page hits */
wire bank_open = has_openrow[bank_address];
wire page_hit = bank_open & (openrows[bank_address] == row_address);

/* Address drivers */
reg sdram_adr_loadrow;
reg sdram_adr_loadcol;
reg sdram_adr_loadA10;
assign sdram_adr =
	 ({13{sdram_adr_loadrow}}	& row_address)
	|({13{sdram_adr_loadcol}}	& col_address)
	|({13{sdram_adr_loadA10}}	& 13'd1024);

assign sdram_ba = bank_address;

/* Command drivers */
reg sdram_cs;
reg sdram_we;
reg sdram_cas;
reg sdram_ras;
assign sdram_cs_n = ~sdram_cs;
assign sdram_we_n = ~sdram_we;
assign sdram_cas_n = ~sdram_cas;
assign sdram_ras_n = ~sdram_ras;

/* Timing counters */

/* The number of clocks we must wait following a PRECHARGE command (usually tRP). */
reg [2:0] precharge_counter;
reg reload_precharge_counter;
wire precharge_done = (precharge_counter == 3'd0);
always @(posedge sys_clk) begin
	if(reload_precharge_counter)
		precharge_counter <= tim_rp;
	else if(~precharge_done)
		precharge_counter <= precharge_counter - 3'd1;
end

/* The number of clocks we must wait following an ACTIVATE command (usually tRCD). */
reg [2:0] activate_counter;
reg reload_activate_counter;
wire activate_done = (activate_counter == 3'd0);
always @(posedge sys_clk) begin
	if(reload_activate_counter)
		activate_counter <= tim_rcd;
	else if(~activate_done)
		activate_counter <= activate_counter - 3'd1;
end

/* The number of clocks we have left before we must refresh one row in the SDRAM array (usually tREFI). */
reg [10:0] refresh_counter;
reg reload_refresh_counter;
wire must_refresh = refresh_counter == 11'd0;
always @(posedge sys_clk) begin
	if(sdram_rst)
		refresh_counter <= 11'd0;
	else begin
		if(reload_refresh_counter)
			refresh_counter <= tim_refi;
		else if(~must_refresh)
			refresh_counter <= refresh_counter - 11'd1;
	end
end

/* The number of clocks we must wait following an AUTO REFRESH command (usually tRFC). */
reg [3:0] autorefresh_counter;
reg reload_autorefresh_counter;
wire autorefresh_done = (autorefresh_counter == 4'd0);
always @(posedge sys_clk) begin
	if(reload_autorefresh_counter)
		autorefresh_counter <= tim_rfc;
	else if(~autorefresh_done)
		autorefresh_counter <= autorefresh_counter - 4'd1;
end

/* FSM that pushes commands into the SDRAM */

reg [3:0] state;
reg [3:0] next_state;

parameter IDLE			= 4'd0;
parameter ACTIVATE		= 4'd1;
parameter READ			= 4'd2;
parameter WRITE			= 4'd3;
parameter PRECHARGEALL		= 4'd4;
parameter AUTOREFRESH		= 4'd5;
parameter AUTOREFRESH_WAIT	= 4'd6;

always @(posedge sys_clk) begin
	if(sdram_rst)
		state <= IDLE;
	else begin
		//$display("state: %d -> %d", state, next_state);
		state <= next_state;
	end
end

always @(*) begin
	next_state = state;
	
	reload_precharge_counter = 1'b0;
	reload_activate_counter = 1'b0;
	reload_refresh_counter = 1'b0;
	reload_autorefresh_counter = 1'b0;
	
	sdram_cs = 1'b0;
	sdram_we = 1'b0;
	sdram_cas = 1'b0;
	sdram_ras = 1'b0;
	
	sdram_adr_loadrow = 1'b0;
	sdram_adr_loadcol = 1'b0;
	sdram_adr_loadA10 = 1'b0;
	
	track_close = 4'b0000;
	track_open = 4'b0000;
	
	read = 1'b0;
	write = 1'b0;
	
	ack = 1'b0;
	
	case(state)
		IDLE: begin
			if(must_refresh)
				next_state = PRECHARGEALL;
			else begin
				if(stb) begin
					if(page_hit) begin
						if(we) begin
							if(write_safe) begin
								/* Write */
								sdram_cs = 1'b1;
								sdram_ras = 1'b0;
								sdram_cas = 1'b1;
								sdram_we = 1'b1;
								sdram_adr_loadcol = 1'b1;
								
								write = 1'b1;
								ack = 1'b1;
							end
						end else begin
							if(read_safe) begin
								/* Read */
								sdram_cs = 1'b1;
								sdram_ras = 1'b0;
								sdram_cas = 1'b1;
								sdram_we = 1'b0;
								sdram_adr_loadcol = 1'b1;
								
								read = 1'b1;
								ack = 1'b1;
							end
						end
					end else begin
						if(bank_open) begin
							if(current_precharge_safe) begin
								/* Precharge Bank */
								sdram_cs = 1'b1;
								sdram_ras = 1'b1;
								sdram_cas = 1'b0;
								sdram_we = 1'b1;
								
								track_close = bank_address_onehot;
								reload_precharge_counter = 1'b1;
								next_state = ACTIVATE;
							end
						end else begin
							/* Activate */
							sdram_cs = 1'b1;
							sdram_ras = 1'b1;
							sdram_cas = 1'b0;
							sdram_we = 1'b0;
							sdram_adr_loadrow = 1'b1;
				
							track_open = bank_address_onehot;
							reload_activate_counter = 1'b1;
							if(we)
								next_state = WRITE;
							else
								next_state = READ;
						end
					end
				end
			end
		end
		
		ACTIVATE: begin
			if(precharge_done) begin
				sdram_cs = 1'b1;
				sdram_ras = 1'b1;
				sdram_cas = 1'b0;
				sdram_we = 1'b0;
				sdram_adr_loadrow = 1'b1;
				
				track_open = bank_address_onehot;
				reload_activate_counter = 1'b1;
				if(we)
					next_state = WRITE;
				else
					next_state = READ;
			end
		end
		READ: begin
			if(activate_done) begin
				if(read_safe) begin
					sdram_cs = 1'b1;
					sdram_ras = 1'b0;
					sdram_cas = 1'b1;
					sdram_we = 1'b0;
					sdram_adr_loadcol = 1'b1;
					
					read = 1'b1;
					ack = 1'b1;
					next_state = IDLE;
				end
			end
		end
		WRITE: begin
			if(activate_done) begin
				if(write_safe) begin
					sdram_cs = 1'b1;
					sdram_ras = 1'b0;
					sdram_cas = 1'b1;
					sdram_we = 1'b1;
					sdram_adr_loadcol = 1'b1;
					
					write = 1'b1;
					ack = 1'b1;
					next_state = IDLE;
				end
			end
		end
		
		PRECHARGEALL: begin
			if(precharge_safe == 4'b1111) begin
				sdram_cs = 1'b1;
				sdram_ras = 1'b1;
				sdram_cas = 1'b0;
				sdram_we = 1'b1;
				sdram_adr_loadA10 = 1'b1;
	
				reload_precharge_counter = 1'b1;
				
				track_close = 4'b1111;
				
				next_state = AUTOREFRESH;
			end
		end
		AUTOREFRESH: begin
			if(precharge_done) begin
				sdram_cs = 1'b1;
				sdram_ras = 1'b1;
				sdram_cas = 1'b1;
				sdram_we = 1'b0;
				reload_refresh_counter = 1'b1;
				reload_autorefresh_counter = 1'b1;
				next_state = AUTOREFRESH_WAIT;
			end
		end
		AUTOREFRESH_WAIT: begin
			if(autorefresh_done)
				next_state = IDLE;
		end
		
	endcase
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/spartan6/hpdmc_ddrio.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc_ddrio(
	input sys_clk,
	input sys_clk_n,
	input dqs_clk,
	input dqs_clk_n,
	
	input direction,
	input direction_r,
	input [7:0] mo,
	input [63:0] do,
	output [63:0] di,
	
	output [3:0] sdram_dm,
	inout [31:0] sdram_dq,
	inout [3:0] sdram_dqs,
	
	input idelay_rst,
	input idelay_ce,
	input idelay_inc
);

/******/
/* DQ */
/******/

wire [31:0] sdram_dq_t;
wire [31:0] sdram_dq_out;
wire [31:0] sdram_dq_in;

hpdmc_iobuf32 iobuf_dq(
	.T(sdram_dq_t),
	.I(sdram_dq_out),
	.O(sdram_dq_in),
	.IO(sdram_dq)
);

hpdmc_oddr32 oddr_dq_t(
	.Q(sdram_dq_t),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0({32{~direction_r}}),
	.D1({32{~direction_r}}),
	.R(1'b0),
	.S(1'b0)
);

hpdmc_oddr32 oddr_dq(
	.Q(sdram_dq_out),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0(do[63:32]),
	.D1(do[31:0]),
	.R(1'b0),
	.S(1'b0)
);

hpdmc_iddr32 iddr_dq(
	.Q0(di[31:0]),
	.Q1(di[63:32]),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D(sdram_dq_in),
	.R(1'b0),
	.S(1'b0)
);

/*******/
/* DM */
/*******/

hpdmc_oddr4 oddr_dm(
	.Q(sdram_dm),
	.C0(sys_clk),
	.C1(sys_clk_n),
	.CE(1'b1),
	.D0(mo[7:4]),
	.D1(mo[3:0]),
	.R(1'b0),
	.S(1'b0)
);

/*******/
/* DQS */
/*******/

wire [3:0] sdram_dqs_t;
wire [3:0] sdram_dqs_out;

hpdmc_obuft4 obuft_dqs(
	.T(sdram_dqs_t),
	.I(sdram_dqs_out),
	.O(sdram_dqs)
);

hpdmc_oddr4 oddr_dqs_t(
	.Q(sdram_dqs_t),
	.C0(dqs_clk),
	.C1(dqs_clk_n),
	.CE(1'b1),
	.D0({4{~direction_r}}),
	.D1({4{~direction_r}}),
	.R(1'b0),
	.S(1'b0)
);

hpdmc_oddr4 oddr_dqs(
	.Q(sdram_dqs_out),
	.C0(dqs_clk),
	.C1(dqs_clk_n),
	.CE(1'b1),
	.D0(4'hf),
	.D1(4'h0),
	.R(1'b0),
	.S(1'b0)
);

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/spartan6/hpdmc_iddr32.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Verilog code that really should be replaced with a generate
 * statement, but it does not work with some free simulators.
 * So I put it in a module so as not to make other code unreadable,
 * and keep compatibility with as many simulators as possible.
 */

module hpdmc_iddr32 #(
	parameter DDR_ALIGNMENT = "C0",
	parameter INIT_Q0 = 1'b0,
	parameter INIT_Q1 = 1'b0,
	parameter SRTYPE = "ASYNC"
) (
	output [31:0] Q0,
	output [31:0] Q1,
	input C0,
	input C1,
	input CE,
	input [31:0] D,
	input R,
	input S
);

IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr0 (
	.Q0(Q0[0]),
	.Q1(Q1[0]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[0]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr1 (
	.Q0(Q0[1]),
	.Q1(Q1[1]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[1]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr2 (
	.Q0(Q0[2]),
	.Q1(Q1[2]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[2]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr3 (
	.Q0(Q0[3]),
	.Q1(Q1[3]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[3]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr4 (
	.Q0(Q0[4]),
	.Q1(Q1[4]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[4]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr5 (
	.Q0(Q0[5]),
	.Q1(Q1[5]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[5]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr6 (
	.Q0(Q0[6]),
	.Q1(Q1[6]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[6]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr7 (
	.Q0(Q0[7]),
	.Q1(Q1[7]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[7]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr8 (
	.Q0(Q0[8]),
	.Q1(Q1[8]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[8]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr9 (
	.Q0(Q0[9]),
	.Q1(Q1[9]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[9]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr10 (
	.Q0(Q0[10]),
	.Q1(Q1[10]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[10]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr11 (
	.Q0(Q0[11]),
	.Q1(Q1[11]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[11]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr12 (
	.Q0(Q0[12]),
	.Q1(Q1[12]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[12]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr13 (
	.Q0(Q0[13]),
	.Q1(Q1[13]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[13]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr14 (
	.Q0(Q0[14]),
	.Q1(Q1[14]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[14]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr15 (
	.Q0(Q0[15]),
	.Q1(Q1[15]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[15]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr16 (
	.Q0(Q0[16]),
	.Q1(Q1[16]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[16]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr17 (
	.Q0(Q0[17]),
	.Q1(Q1[17]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[17]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr18 (
	.Q0(Q0[18]),
	.Q1(Q1[18]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[18]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr19 (
	.Q0(Q0[19]),
	.Q1(Q1[19]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[19]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr20 (
	.Q0(Q0[20]),
	.Q1(Q1[20]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[20]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr21 (
	.Q0(Q0[21]),
	.Q1(Q1[21]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[21]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr22 (
	.Q0(Q0[22]),
	.Q1(Q1[22]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[22]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr23 (
	.Q0(Q0[23]),
	.Q1(Q1[23]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[23]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr24 (
	.Q0(Q0[24]),
	.Q1(Q1[24]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[24]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr25 (
	.Q0(Q0[25]),
	.Q1(Q1[25]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[25]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr26 (
	.Q0(Q0[26]),
	.Q1(Q1[26]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[26]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr27 (
	.Q0(Q0[27]),
	.Q1(Q1[27]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[27]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr28 (
	.Q0(Q0[28]),
	.Q1(Q1[28]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[28]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr29 (
	.Q0(Q0[29]),
	.Q1(Q1[29]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[29]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr30 (
	.Q0(Q0[30]),
	.Q1(Q1[30]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[30]),
	.R(R),
	.S(S)
);
IDDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT_Q0(INIT_Q0),
	.INIT_Q1(INIT_Q1),
	.SRTYPE(SRTYPE)
) iddr31 (
	.Q0(Q0[31]),
	.Q1(Q1[31]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D(D[31]),
	.R(R),
	.S(S)
);

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/spartan6/hpdmc_iobuf32.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Verilog code that really should be replaced with a generate
 * statement, but it does not work with some free simulators.
 * So I put it in a module so as not to make other code unreadable,
 * and keep compatibility with as many simulators as possible.
 */

module hpdmc_iobuf32(
	input [31:0] T,
	input [31:0] I,
	output [31:0] O,
	inout [31:0] IO
);

IOBUF iobuf0(
	.T(T[0]),
	.I(I[0]),
	.O(O[0]),
	.IO(IO[0])
);
IOBUF iobuf1(
	.T(T[1]),
	.I(I[1]),
	.O(O[1]),
	.IO(IO[1])
);
IOBUF iobuf2(
	.T(T[2]),
	.I(I[2]),
	.O(O[2]),
	.IO(IO[2])
);
IOBUF iobuf3(
	.T(T[3]),
	.I(I[3]),
	.O(O[3]),
	.IO(IO[3])
);
IOBUF iobuf4(
	.T(T[4]),
	.I(I[4]),
	.O(O[4]),
	.IO(IO[4])
);
IOBUF iobuf5(
	.T(T[5]),
	.I(I[5]),
	.O(O[5]),
	.IO(IO[5])
);
IOBUF iobuf6(
	.T(T[6]),
	.I(I[6]),
	.O(O[6]),
	.IO(IO[6])
);
IOBUF iobuf7(
	.T(T[7]),
	.I(I[7]),
	.O(O[7]),
	.IO(IO[7])
);
IOBUF iobuf8(
	.T(T[8]),
	.I(I[8]),
	.O(O[8]),
	.IO(IO[8])
);
IOBUF iobuf9(
	.T(T[9]),
	.I(I[9]),
	.O(O[9]),
	.IO(IO[9])
);
IOBUF iobuf10(
	.T(T[10]),
	.I(I[10]),
	.O(O[10]),
	.IO(IO[10])
);
IOBUF iobuf11(
	.T(T[11]),
	.I(I[11]),
	.O(O[11]),
	.IO(IO[11])
);
IOBUF iobuf12(
	.T(T[12]),
	.I(I[12]),
	.O(O[12]),
	.IO(IO[12])
);
IOBUF iobuf13(
	.T(T[13]),
	.I(I[13]),
	.O(O[13]),
	.IO(IO[13])
);
IOBUF iobuf14(
	.T(T[14]),
	.I(I[14]),
	.O(O[14]),
	.IO(IO[14])
);
IOBUF iobuf15(
	.T(T[15]),
	.I(I[15]),
	.O(O[15]),
	.IO(IO[15])
);
IOBUF iobuf16(
	.T(T[16]),
	.I(I[16]),
	.O(O[16]),
	.IO(IO[16])
);
IOBUF iobuf17(
	.T(T[17]),
	.I(I[17]),
	.O(O[17]),
	.IO(IO[17])
);
IOBUF iobuf18(
	.T(T[18]),
	.I(I[18]),
	.O(O[18]),
	.IO(IO[18])
);
IOBUF iobuf19(
	.T(T[19]),
	.I(I[19]),
	.O(O[19]),
	.IO(IO[19])
);
IOBUF iobuf20(
	.T(T[20]),
	.I(I[20]),
	.O(O[20]),
	.IO(IO[20])
);
IOBUF iobuf21(
	.T(T[21]),
	.I(I[21]),
	.O(O[21]),
	.IO(IO[21])
);
IOBUF iobuf22(
	.T(T[22]),
	.I(I[22]),
	.O(O[22]),
	.IO(IO[22])
);
IOBUF iobuf23(
	.T(T[23]),
	.I(I[23]),
	.O(O[23]),
	.IO(IO[23])
);
IOBUF iobuf24(
	.T(T[24]),
	.I(I[24]),
	.O(O[24]),
	.IO(IO[24])
);
IOBUF iobuf25(
	.T(T[25]),
	.I(I[25]),
	.O(O[25]),
	.IO(IO[25])
);
IOBUF iobuf26(
	.T(T[26]),
	.I(I[26]),
	.O(O[26]),
	.IO(IO[26])
);
IOBUF iobuf27(
	.T(T[27]),
	.I(I[27]),
	.O(O[27]),
	.IO(IO[27])
);
IOBUF iobuf28(
	.T(T[28]),
	.I(I[28]),
	.O(O[28]),
	.IO(IO[28])
);
IOBUF iobuf29(
	.T(T[29]),
	.I(I[29]),
	.O(O[29]),
	.IO(IO[29])
);
IOBUF iobuf30(
	.T(T[30]),
	.I(I[30]),
	.O(O[30]),
	.IO(IO[30])
);
IOBUF iobuf31(
	.T(T[31]),
	.I(I[31]),
	.O(O[31]),
	.IO(IO[31])
);

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/spartan6/hpdmc_obuft4.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Verilog code that really should be replaced with a generate
 * statement, but it does not work with some free simulators.
 * So I put it in a module so as not to make other code unreadable,
 * and keep compatibility with as many simulators as possible.
 */

module hpdmc_obuft4(
	input [3:0] T,
	input [3:0] I,
	output [3:0] O
);

OBUFT obuft0(
	.T(T[0]),
	.I(I[0]),
	.O(O[0])
);
OBUFT obuft1(
	.T(T[1]),
	.I(I[1]),
	.O(O[1])
);
OBUFT obuft2(
	.T(T[2]),
	.I(I[2]),
	.O(O[2])
);
OBUFT obuft3(
	.T(T[3]),
	.I(I[3]),
	.O(O[3])
);

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/spartan6/hpdmc_oddr32.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Verilog code that really should be replaced with a generate
 * statement, but it does not work with some free simulators.
 * So I put it in a module so as not to make other code unreadable,
 * and keep compatibility with as many simulators as possible.
 */

module hpdmc_oddr32 #(
	parameter DDR_ALIGNMENT = "C0",
	parameter INIT = 1'b0,
	parameter SRTYPE = "ASYNC"
) (
	output [31:0] Q,
	input C0,
	input C1,
	input CE,
	input [31:0] D0,
	input [31:0] D1,
	input R,
	input S
);

ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr0 (
	.Q(Q[0]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[0]),
	.D1(D1[0]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr1 (
	.Q(Q[1]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[1]),
	.D1(D1[1]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr2 (
	.Q(Q[2]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[2]),
	.D1(D1[2]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr3 (
	.Q(Q[3]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[3]),
	.D1(D1[3]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr4 (
	.Q(Q[4]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[4]),
	.D1(D1[4]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr5 (
	.Q(Q[5]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[5]),
	.D1(D1[5]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr6 (
	.Q(Q[6]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[6]),
	.D1(D1[6]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr7 (
	.Q(Q[7]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[7]),
	.D1(D1[7]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr8 (
	.Q(Q[8]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[8]),
	.D1(D1[8]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr9 (
	.Q(Q[9]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[9]),
	.D1(D1[9]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr10 (
	.Q(Q[10]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[10]),
	.D1(D1[10]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr11 (
	.Q(Q[11]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[11]),
	.D1(D1[11]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr12 (
	.Q(Q[12]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[12]),
	.D1(D1[12]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr13 (
	.Q(Q[13]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[13]),
	.D1(D1[13]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr14 (
	.Q(Q[14]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[14]),
	.D1(D1[14]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr15 (
	.Q(Q[15]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[15]),
	.D1(D1[15]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr16 (
	.Q(Q[16]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[16]),
	.D1(D1[16]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr17 (
	.Q(Q[17]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[17]),
	.D1(D1[17]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr18 (
	.Q(Q[18]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[18]),
	.D1(D1[18]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr19 (
	.Q(Q[19]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[19]),
	.D1(D1[19]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr20 (
	.Q(Q[20]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[20]),
	.D1(D1[20]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr21 (
	.Q(Q[21]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[21]),
	.D1(D1[21]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr22 (
	.Q(Q[22]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[22]),
	.D1(D1[22]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr23 (
	.Q(Q[23]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[23]),
	.D1(D1[23]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr24 (
	.Q(Q[24]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[24]),
	.D1(D1[24]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr25 (
	.Q(Q[25]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[25]),
	.D1(D1[25]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr26 (
	.Q(Q[26]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[26]),
	.D1(D1[26]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr27 (
	.Q(Q[27]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[27]),
	.D1(D1[27]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr28 (
	.Q(Q[28]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[28]),
	.D1(D1[28]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr29 (
	.Q(Q[29]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[29]),
	.D1(D1[29]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr30 (
	.Q(Q[30]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[30]),
	.D1(D1[30]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr31 (
	.Q(Q[31]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[31]),
	.D1(D1[31]),
	.R(R),
	.S(S)
);

endmodule

// -----------------------------------------------------------------------------
// Source file: hpdmc_ddr32/rtl/spartan6/hpdmc_oddr4.v
// -----------------------------------------------------------------------------
/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Verilog code that really should be replaced with a generate
 * statement, but it does not work with some free simulators.
 * So I put it in a module so as not to make other code unreadable,
 * and keep compatibility with as many simulators as possible.
 */

module hpdmc_oddr4 #(
	parameter DDR_ALIGNMENT = "C0",
	parameter INIT = 1'b0,
	parameter SRTYPE = "ASYNC"
) (
	output [3:0] Q,
	input C0,
	input C1,
	input CE,
	input [3:0] D0,
	input [3:0] D1,
	input R,
	input S
);

ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr0 (
	.Q(Q[0]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[0]),
	.D1(D1[0]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr1 (
	.Q(Q[1]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[1]),
	.D1(D1[1]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr2 (
	.Q(Q[2]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[2]),
	.D1(D1[2]),
	.R(R),
	.S(S)
);
ODDR2 #(
	.DDR_ALIGNMENT(DDR_ALIGNMENT),
	.INIT(INIT),
	.SRTYPE(SRTYPE)
) oddr3 (
	.Q(Q[3]),
	.C0(C0),
	.C1(C1),
	.CE(CE),
	.D0(D0[3]),
	.D1(D1[3]),
	.R(R),
	.S(S)
);

endmodule
