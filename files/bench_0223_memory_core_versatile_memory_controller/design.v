// Curated RTL benchmark case.
// case_id: bench_0223_memory_core_versatile_memory_controller
// source_project: memory_core_versatile_memory_controller
// top_module: ddr2_module


// -----------------------------------------------------------------------------
// Source file: sdr_sdram_ctrl.v
// -----------------------------------------------------------------------------
//`include "versatile_mem_ctrl_defines.v"
`ifdef SDR
`timescale 1ns/1ns
`define MODULE sdr16
module `BASE`MODULE (
`undef MODULE
    // wisbone i/f
`ifdef SDR_NO_BURST
    dat_i, adr_i, sel_i, we_i, cyc_i, stb_i, dat_o, ack_o,
`else
    dat_i, adr_i, sel_i, bte_i, we_i, cyc_i, stb_i, dat_o, ack_o,
`endif
    // SDR SDRAM
    ba, a, cmd, cke, cs_n, dqm, dq_i, dq_o, dq_oe,
    // system
    clk, rst);

    // external data bus size
    parameter dat_size = `SDR_SDRAM_DATA_WIDTH;
    
    // memory geometry parameters
    parameter ba_size  = `SDR_BA_SIZE;   
    parameter row_size = `SDR_ROW_SIZE;
    parameter col_size = `SDR_COL_SIZE;
    parameter cl = `SDR_INIT_CL;
    // memory timing parameters
    parameter tRFC = `SDR_TRFC;
    parameter tRP  = `SDR_TRP;
    parameter tRCD = `SDR_TRCD;
    parameter tMRD = `SDR_TMRD;
   
    // LMR
    // [12:10] reserved
    // [9]     WB, write burst; 0 - programmed burst length, 1 - single location
    // [8:7]   OP Mode, 2'b00
    // [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
    // [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
    // [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
    parameter init_wb = `SDR_INIT_WB;
    parameter init_cl = `SDR_INIT_CL;
    parameter init_bt = `SDR_INIT_BT;
    parameter init_bl = `SDR_INIT_BL;
	
    input [31:0] dat_i;
    input [ba_size+col_size+row_size:1] adr_i;
    input [3:0] sel_i;
`ifndef SDR_NO_BURST
    input [1:0] bte_i;
`endif
    input we_i, cyc_i, stb_i;
    output [31:0] dat_o;
    output ack_o;

    output [ba_size-1:0]    ba;
    output reg [12:0]   a;
    output reg [2:0]    cmd; // {ras,cas,we}
    output cke, cs_n;
    output reg [1:0]    dqm;
    output [dat_size-1:0]       dq_o;
    output reg          dq_oe;
    input  [dat_size-1:0]       dq_i;

    input clk, rst;

    wire [ba_size-1:0] 	bank;
    wire [row_size-1:0] row;
    wire [col_size-1:0] col;
    wire [12:0]         col_a10_fix;
`ifdef SDR_BEAT16
    parameter col_reg_width = 5;
    reg [4:0]		col_reg;
`else
`ifdef SDR_BEAT8
    parameter col_reg_width = 4;
    reg [3:0]		col_reg;
`else
`ifdef SDR_BEAT4
    parameter col_reg_width = 3;
    reg [2:0]		col_reg;
`endif
`endif
`endif
    wire [0:31] 	shreg; 
    wire		count0;
    wire 		stall; // active if write burst need data
    wire 		ref_cnt_zero;
    reg                 refresh_req; 

    wire ack_rd, rd_ack_emptyflag;
    wire ack_wr;

    // to keep track of open rows per bank
    reg [row_size-1:0] 	open_row[0:3];
    reg [0:3] 		open_ba;
    reg 		current_bank_closed, current_row_open;  

`ifndef SDR_RFR_WRAP_VALUE
    parameter rfr_length = 10;
    parameter rfr_wrap_value = 1010;
`else
    parameter rfr_length = `SDR_RFR_LENGTH;
    parameter rfr_wrap_value = `SDR_RFR_WRAP_VALUE;	
`endif

    // cti
    parameter [2:0] classic = 3'b000,
                    endofburst = 3'b111;

    // bte	
    parameter [1:0] linear = 2'b00,
                    beat4  = 2'b01,
                    beat8  = 2'b10,
                    beat16 = 2'b11;

    parameter [2:0] cmd_nop = 3'b111,
                    cmd_act = 3'b011,
                    cmd_rd  = 3'b101,
                    cmd_wr  = 3'b100,
                    cmd_pch = 3'b010,
                    cmd_rfr = 3'b001,
                    cmd_lmr = 3'b000;

// ctrl FSM
`define FSM_INIT 3'b000
`define FSM_IDLE 3'b001
`define FSM_RFR  3'b010
`define FSM_ADR  3'b011
`define FSM_PCH  3'b100
`define FSM_ACT  3'b101
`define FSM_RW   3'b111

    assign cke = 1'b1;
    assign cs_n = 1'b0;
	   
    reg [2:0] state, next;

    function [12:0] a10_fix;
        input [col_size-1:0] a;
        integer i;
    begin
	for (i=0;i<13;i=i+1) begin
            if (i<10)
              if (i<col_size)
                a10_fix[i] = a[i];
              else
                a10_fix[i] = 1'b0;
            else if (i==10)
              a10_fix[i] = 1'b0;
            else
              if (i<col_size)
                a10_fix[i] = a[i-1];
              else
                a10_fix[i] = 1'b0;
	end
    end
    endfunction

    assign {bank,row,col} = adr_i;

    always @ (posedge clk or posedge rst)
    if (rst)
       state <= `FSM_INIT;
    else
       state <= next;
   
    always @*
    begin
	next = state;
	case (state)
	`FSM_INIT:
            if (shreg[3+tRP+tRFC+tRFC+tMRD]) next = `FSM_IDLE;
        `FSM_IDLE:   
	    if (refresh_req) next = `FSM_RFR;
            else if (cyc_i & stb_i & rd_ack_emptyflag) next = `FSM_ADR;
        `FSM_RFR: 
            if (shreg[tRP+tRFC-2]) next = `FSM_IDLE; // take away two cycles because no cmd will be issued in idle and adr
	`FSM_ADR:
            if (current_bank_closed) next = `FSM_ACT;
	    else if (current_row_open) next = `FSM_RW;
	    else next = `FSM_PCH;
	`FSM_PCH: 
            if (shreg[tRP]) next = `FSM_ACT;
	`FSM_ACT:
            if (shreg[tRCD]) next = `FSM_RW;
	`FSM_RW:
`ifdef SDR_NO_BURST
            if (shreg[1]) next = `FSM_IDLE;
`else
            if (bte_i==linear & shreg[1]) next = `FSM_IDLE;
`ifdef SDR_BEAT4
            else if (bte_i==beat4 & shreg[7]) next = `FSM_IDLE;
`endif
`ifdef SDR_BEAT8
            else if (bte_i==beat8 & shreg[15]) next = `FSM_IDLE;
`endif
`ifdef SDR_BEAT16
            else if (bte_i==beat16 & shreg[31]) next = `FSM_IDLE;
`endif
`endif
	endcase
    end

    // active if write burst need data
    assign stall = state==`FSM_RW & next==`FSM_RW & ~stb_i & count0 & we_i;
   
    // counter
`define MODULE cnt_shreg_ce_clear 
    `VLBASE`MODULE # ( .length(32))
`undef MODULE
        cnt0 (
            .cke(!stall),
            .clear(state!=next),
            .q(shreg),
            .rst(rst),
            .clk(clk));

`define MODULE dff_ce_clear
    `VLBASE`MODULE
`undef MODULE
        dff_count0 (
            .d(!count0),
            .ce(!stall),
            .clear(state!=next),
            .q(count0),
            .rst(rst),
            .clk(clk));

    // ba, a, cmd
    // col_reg_a10 has bit [10] set to zero to disable auto precharge
`ifdef SDR_NO_BURST
    assign col_a10_fix = a10_fix(col);
`else
    assign col_a10_fix = a10_fix({col[col_size-1:col_reg_width],col_reg});
`endif

    // outputs dependent on state vector
    always @ (*)
        begin
   	    {a,cmd} = {13'd0,cmd_nop};
            dqm = 2'b11;
            dq_oe = 1'b0;
            case (state)
            `FSM_INIT:
                if (shreg[3]) begin
                    {a,cmd} = {13'b0010000000000, cmd_pch};
                end else if (shreg[3+tRP] | shreg[3+tRP+tRFC])
                    {a,cmd} = {13'd0, cmd_rfr};
                else if (shreg[3+tRP+tRFC+tRFC])
                    {a,cmd} = {3'b000,init_wb,2'b00,init_cl,init_bt,init_bl,cmd_lmr};
            `FSM_RFR:
        	if (shreg[0])
                    {a,cmd} = {13'b0010000000000, cmd_pch};
        	else if (shreg[tRP])
                    {a,cmd} = {13'd0, cmd_rfr};
	    `FSM_PCH:
        	if (shreg[0])
                    {a,cmd} = {13'd0,cmd_pch};
            `FSM_ACT:
                if (shreg[0])
                    {a[row_size-1:0],cmd} = {row,cmd_act};
            `FSM_RW:
                begin
                    if (we_i & !count0)
                        cmd = cmd_wr;
                    else if (!count0)
                        cmd = cmd_rd;
                    else
                        cmd = cmd_nop;
                    if (we_i & !count0)
                        dqm = ~sel_i[3:2];
                    else if (we_i & count0)
                        dqm = ~sel_i[1:0];
                    else
                        dqm = 2'b00;
                    if (we_i)
                        dq_oe = 1'b1;
                    if (~stall)
                        a = col_a10_fix;
                end
            endcase
        end

    assign ba = bank;
    
    // precharge individual bank A10=0
    // precharge all bank A10=1
    genvar i;
    generate
    for (i=0;i<2<<ba_size-1;i=i+1) begin
    
        always @ (posedge clk or posedge rst)
        if (rst)
            {open_ba[i],open_row[i]} <= {1'b0,{row_size{1'b0}}};
        else
            if (cmd==cmd_pch & (a[10] | bank==i))
                open_ba[i] <= 1'b0;
            else if (cmd==cmd_act & bank==i)
                {open_ba[i],open_row[i]} <= {1'b1,row};

    end
    endgenerate

`ifndef SDR_NO_BURST    
    always @ (posedge clk or posedge rst)
	if (rst)
           col_reg <= {col_reg_width{1'b0}};
        else
            case (state)
	    `FSM_IDLE:
	       col_reg <= col[col_reg_width-1:0];
            `FSM_RW:
               if (~stall)
                  case (bte_i)
`ifdef SDR_BEAT4
                        beat4:  col_reg[2:0] <= col_reg[2:0] + 3'd1;
`endif
`ifdef SDR_BEAT8    
                        beat8:  col_reg[3:0] <= col_reg[3:0] + 4'd1;
`endif
`ifdef SDR_BEAT16   
                        beat16: col_reg[4:0] <= col_reg[4:0] + 5'd1;
`endif
                  endcase
            endcase
`endif

    // bank and row open ?
    always @ (posedge clk or posedge rst)
    if (rst)
       {current_bank_closed, current_row_open} <= {1'b1, 1'b0};
    else
       {current_bank_closed, current_row_open} <= {!(open_ba[bank]), open_row[bank]==row};

    // refresh counter
`define MODULE cnt_lfsr_zq  
    `VLBASE`MODULE # ( .length(rfr_length), .wrap_value (rfr_wrap_value)) ref_counter0( .zq(ref_cnt_zero), .rst(rst), .clk(clk));
`undef MODULE

    always @ (posedge clk or posedge rst)
    if (rst)
    	refresh_req <= 1'b0;
    else
    	if (ref_cnt_zero)
            refresh_req <= 1'b1;
       	else if (state==`FSM_RFR)
            refresh_req <= 1'b0;

    assign dat_o[15:0] = dq_i;
`define MODULE dff    
    `VLBASE`MODULE # ( .width(16)) wb_dat_dff ( .d(dat_o[15:0]), .q(dat_o[31:16]), .clk(clk), .rst(rst));
`undef MODULE

    assign ack_wr = (state==`FSM_RW & count0 & we_i);

`define MODULE delay_emptyflag  
    `VLBASE`MODULE # ( .depth(cl+2)) delay0 ( .d(state==`FSM_RW & count0 & !we_i), .q(ack_rd), .emptyflag(rd_ack_emptyflag), .clk(clk), .rst(rst));
`undef MODULE

    assign ack_o = ack_rd | ack_wr;

    assign dq_o = (!count0) ? dat_i[31:16] : dat_i[15:0];

endmodule
`endif

// -----------------------------------------------------------------------------
// Source file: versatile_mem_ctrl_top.v
// -----------------------------------------------------------------------------
/*
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_clk, wbs_rst,
	// wishbone master side
	wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_bte_o, wbm_cti_o, wbm_we_o, wbm_cyc_o, wbm_stb_o, wbm_dat_i, wbm_ack_i, wbm_clk, wbm_rst);

`ifdef WB3_ARBITER_TYPE1
`define MODULE wb3_arbiter_type1
module `BASE`MODULE (
`undef MODULE
    wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_cti_o, wbm_bte_o, wbm_we_o, wbm_stb_o, wbm_cyc_o,
    wbm_dat_i, wbm_ack_i, wbm_err_i, wbm_rty_i,
    wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_stb_i, wbs_cyc_i,
    wbs_dat_o, wbs_ack_o, wbs_err_o, wbs_rty_o,
    wb_clk, wb_rst
);
*/
//`include "versatile_mem_ctrl_defines.v"
`define MODULE top
module `BASE`MODULE (
`undef MODULE
    input  [31:0] wbs_1_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_1_adr_i,
    input   [3:0] wbs_1_sel_i,
    input   [2:0] wbs_1_cti_i,
    input   [1:0] wbs_1_bte_i,
    input         wbs_1_we_i,
    input         wbs_1_stb_i,
    input         wbs_1_cyc_i,
    output [31:0] wbs_1_dat_o,
    output        wbs_1_ack_o,
    input         wbs_1_clk_i,
    input         wbs_1_rst_i,
`ifdef WB_GRPS_2
    input  [31:0] wbs_2_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_2_adr_i,
    input   [3:0] wbs_2_sel_i,
    input   [2:0] wbs_2_cti_i,
    input   [1:0] wbs_2_bte_i,
    input         wbs_2_we_i,
    input         wbs_2_stb_i,
    input         wbs_2_cyc_i,
    output [31:0] wbs_2_dat_o,
    output        wbs_2_ack_o,
    input         wbs_2_clk_i,
    input         wbs_2_rst_i,
`endif
`ifdef WB_GRPS_3
    input  [31:0] wbs_3_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_3_adr_i,
    input   [3:0] wbs_3_sel_i,
    input   [2:0] wbs_3_cti_i,
    input   [1:0] wbs_3_bte_i,
    input         wbs_3_we_i,
    input         wbs_3_stb_i,
    input         wbs_3_cyc_i,
    output [31:0] wbs_3_dat_o,
    output        wbs_3_ack_o,
    input         wbs_3_clk_i,
    input         wbs_3_rst_i,
`endif
`ifdef WB_GRPS_4
    input  [31:0] wbs_4_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_4_adr_i,
    input   [3:0] wbs_4_sel_i,
    input   [2:0] wbs_4_cti_i,
    input   [1:0] wbs_4_bte_i,
    input         wbs_4_we_i,
    input         wbs_4_stb_i,
    input         wbs_4_cyc_i,
    output [31:0] wbs_4_dat_o,
    output        wbs_4_ack_o,
    input         wbs_4_clk_i,
    input         wbs_4_rst_i,
`endif
`ifdef WB_GRPS_5
    input  [31:0] wbs_5_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_5_adr_i,
    input   [3:0] wbs_5_sel_i,
    input   [2:0] wbs_5_cti_i,
    input   [1:0] wbs_5_bte_i,
    input         wbs_5_we_i,
    input         wbs_5_stb_i,
    input         wbs_5_cyc_i,
    output [31:0] wbs_5_dat_o,
    output        wbs_5_ack_o,
    input         wbs_5_clk_i,
    input         wbs_5_rst_i,
`endif
`ifdef WB_GRPS_6
    input  [31:0] wbs_6_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_6_adr_i,
    input   [3:0] wbs_6_sel_i,
    input   [2:0] wbs_6_cti_i,
    input   [1:0] wbs_6_bte_i,
    input         wbs_6_we_i,
    input         wbs_6_stb_i,
    input         wbs_6_cyc_i,
    output [31:0] wbs_6_dat_o,
    output        wbs_6_ack_o,
    input         wbs_6_clk_i,
    input         wbs_6_rst_i,
`endif
`ifdef WB_GRPS_7
    input  [31:0] wbs_7_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_7_adr_i,
    input   [3:0] wbs_7_sel_i,
    input   [2:0] wbs_7_cti_i,
    input   [1:0] wbs_7_bte_i,
    input         wbs_7_we_i,
    input         wbs_7_stb_i,
    input         wbs_7_cyc_i,
    output [31:0] wbs_7_dat_o,
    output        wbs_7_ack_o,
    input         wbs_7_clk_i,
    input         wbs_7_rst_i,
`endif
`ifdef WB_GRPS_8
    input  [31:0] wbs_8_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_8_adr_i,
    input   [3:0] wbs_8_sel_i,
    input   [2:0] wbs_8_cti_i,
    input   [1:0] wbs_8_bte_i,
    input         wbs_8_we_i,
    input         wbs_8_stb_i,
    input         wbs_8_cyc_i,
    output [31:0] wbs_8_dat_o,
    output        wbs_8_ack_o,
    input         wbs_8_clk_i,
    input         wbs_8_rst_i,
`endif
`ifdef SDR
    output  [1:0] ba,
    output [12:0] a,
    output  [2:0] cmd,
    output       cke,
    output       cs_n,
    output [`SDR_SDRAM_DATA_WIDTH/8-1:0] dqm,
    output [`SDR_SDRAM_DATA_WIDTH-1:0] dq_o,
    input  [`SDR_SDRAM_DATA_WIDTH-1:0] dq_i,
    output dq_oe,
`endif
`ifdef DDR3
    output [12:0] mem_addr,
    output [2:0] mem_ba,
    output mem_cas_n,
    output mem_cke,
    inout mem_clk,
    inout mem_clk_n,
    output mem_cs_n,
    output [1:0] mem_dm,
    inout [15:0] mem_dq,
    inout [1:0] mem_dqs,
    inout [1:0] mem_dqsn,
    output mem_odt,
    output mem_ras_n,
    input mem_reset_n,
    output mem_we_n,
    input mem_ref_clk, /* 100MHz */		       
`endif
    input mem_clk_i,
    input mem_rst_i
);

wire  [31:0] wbm_1_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_1_adr_o;
wire   [3:0] wbm_1_sel_o;
wire   [2:0] wbm_1_cti_o;
wire   [1:0] wbm_1_bte_o;
wire         wbm_1_we_o;
wire         wbm_1_stb_o;
wire         wbm_1_cyc_o;
wire  [31:0] wbm_1_dat_i;
wire         wbm_1_ack_i;
`ifdef WB_GRPS_2
wire  [31:0] wbm_2_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_2_adr_o;
wire   [3:0] wbm_2_sel_o;
wire   [2:0] wbm_2_cti_o;
wire   [1:0] wbm_2_bte_o;
wire         wbm_2_we_o;
wire         wbm_2_stb_o;
wire         wbm_2_cyc_o;
wire  [31:0] wbm_2_dat_i;
wire         wbm_2_ack_i;
`endif
`ifdef WB_GRPS_3
wire  [31:0] wbm_3_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_3_adr_o;
wire   [3:0] wbm_3_sel_o;
wire   [2:0] wbm_3_cti_o;
wire   [1:0] wbm_3_bte_o;
wire         wbm_3_we_o;
wire         wbm_3_stb_o;
wire         wbm_3_cyc_o;
wire  [31:0] wbm_3_dat_i;
wire         wbm_3_ack_i;
`endif
`ifdef WB_GRPS_4
wire  [31:0] wbm_4_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_4_adr_o;
wire   [3:0] wbm_4_sel_o;
wire   [2:0] wbm_4_cti_o;
wire   [1:0] wbm_4_bte_o;
wire         wbm_4_we_o;
wire         wbm_4_stb_o;
wire         wbm_4_cyc_o;
wire  [31:0] wbm_4_dat_i;
wire         wbm_4_ack_i;
`endif
`ifdef WB_GRPS_5
wire  [31:0] wbm_5_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_5_adr_o;
wire   [3:0] wbm_5_sel_o;
wire   [2:0] wbm_5_cti_o;
wire   [1:0] wbm_5_bte_o;
wire         wbm_5_we_o;
wire         wbm_5_stb_o;
wire         wbm_5_cyc_o;
wire  [31:0] wbm_5_dat_i;
wire         wbm_5_ack_i;
`endif
`ifdef WB_GRPS_6
wire  [31:0] wbm_6_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_6_adr_o;
wire   [3:0] wbm_6_sel_o;
wire   [2:0] wbm_6_cti_o;
wire   [1:0] wbm_6_bte_o;
wire         wbm_6_we_o;
wire         wbm_6_stb_o;
wire         wbm_6_cyc_o;
wire  [31:0] wbm_6_dat_i;
wire         wbm_6_ack_i;
`endif
`ifdef WB_GRPS_7
wire  [31:0] wbm_7_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_7_adr_o;
wire   [3:0] wbm_7_sel_o;
wire   [2:0] wbm_7_cti_o;
wire   [1:0] wbm_7_bte_o;
wire         wbm_7_we_o;
wire         wbm_7_stb_o;
wire         wbm_7_cyc_o;
wire  [31:0] wbm_7_dat_i;
wire         wbm_7_ack_i;
`endif
`ifdef WB_GRPS_8
wire  [31:0] wbm_8_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_8_adr_o;
wire   [3:0] wbm_8_sel_o;
wire   [2:0] wbm_8_cti_o;
wire   [1:0] wbm_8_bte_o;
wire         wbm_8_we_o;
wire         wbm_8_stb_o;
wire         wbm_8_cyc_o;
wire  [31:0] wbm_8_dat_i;
wire         wbm_8_ack_i;
`endif
wire  [31:0] wbs_dat_i;
wire  [`WB_ADR_SIZE-1:2] wbs_adr_i;
wire   [3:0] wbs_sel_i;
wire   [2:0] wbs_cti_i;
wire   [1:0] wbs_bte_i;
wire         wbs_we_i;
wire         wbs_stb_i;
wire         wbs_cyc_i;
wire  [31:0] wbs_dat_o;
wire         wbs_ack_o;

`define MODULE wb3wb3_bridge

`ifdef WB1_CLK
wire [31-(`WB_ADR_SIZE):0] dummy1;
`VLBASE`MODULE wbwb1 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_1_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_1_adr_i}),
    .wbs_sel_i(wbs_1_sel_i),
    .wbs_bte_i(wbs_1_bte_i),
    .wbs_cti_i(wbs_1_cti_i),
    .wbs_we_i (wbs_1_we_i),
    .wbs_cyc_i(wbs_1_cyc_i),
    .wbs_stb_i(wbs_1_stb_i),
    .wbs_dat_o(wbs_1_dat_o),
    .wbs_ack_o(wbs_1_ack_o),
    .wbs_clk(wbs_1_clk_i),
    .wbs_rst(wbs_1_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_1_dat_o),
    .wbm_adr_o({dummy1,wbm_1_adr_o}),
    .wbm_sel_o(wbm_1_sel_o),
    .wbm_bte_o(wbm_1_bte_o),
    .wbm_cti_o(wbm_1_cti_o),
    .wbm_we_o(wbm_1_we_o),
    .wbm_cyc_o(wbm_1_cyc_o),
    .wbm_stb_o(wbm_1_stb_o),
    .wbm_dat_i(wbm_1_dat_i),
    .wbm_ack_i(wbm_1_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB1_MEM_CLK
    assign wbm_1_dat_o = wbs_1_dat_i;
    assign wbm_1_adr_o = wbs_1_adr_i;
    assign wbm_1_sel_o = wbs_1_sel_i;
    assign wbm_1_bte_o = wbs_1_bte_i;
    assign wbm_1_cti_o = wbs_1_cti_i;
    assign wbm_1_we_o  = wbs_1_we_i;
    assign wbm_1_cyc_o = wbs_1_cyc_i;
    assign wbm_1_stb_o = wbs_1_stb_i;
    assign wbs_1_dat_o = wbm_1_dat_i;
    assign wbs_1_ack_o = wbm_1_ack_i;
`endif

`ifdef WB_GRPS_2
`ifdef WB2_CLK
wire [31-(`WB_ADR_SIZE):0] dummy2;
`VLBASE`MODULE wbwb2 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_2_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_2_adr_i}),
    .wbs_sel_i(wbs_2_sel_i),
    .wbs_bte_i(wbs_2_bte_i),
    .wbs_cti_i(wbs_2_cti_i),
    .wbs_we_i (wbs_2_we_i),
    .wbs_cyc_i(wbs_2_cyc_i),
    .wbs_stb_i(wbs_2_stb_i),
    .wbs_dat_o(wbs_2_dat_o),
    .wbs_ack_o(wbs_2_ack_o),
    .wbs_clk(wbs_2_clk_i),
    .wbs_rst(wbs_2_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_2_dat_o),
    .wbm_adr_o({dummy2,wbm_2_adr_o}),
    .wbm_sel_o(wbm_2_sel_o),
    .wbm_bte_o(wbm_2_bte_o),
    .wbm_cti_o(wbm_2_cti_o),
    .wbm_we_o(wbm_2_we_o),
    .wbm_cyc_o(wbm_2_cyc_o),
    .wbm_stb_o(wbm_2_stb_o),
    .wbm_dat_i(wbm_2_dat_i),
    .wbm_ack_i(wbm_2_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB2_MEM_CLK
    assign wbm_2_dat_o = wbs_2_dat_i;
    assign wbm_2_adr_o = wbs_2_adr_i;
    assign wbm_2_sel_o = wbs_2_sel_i;
    assign wbm_2_bte_o = wbs_2_bte_i;
    assign wbm_2_cti_o = wbs_2_cti_i;
    assign wbm_2_we_o  = wbs_2_we_i;
    assign wbm_2_cyc_o = wbs_2_cyc_i;
    assign wbm_2_stb_o = wbs_2_stb_i;
    assign wbs_2_dat_o = wbm_2_dat_i;
    assign wbs_2_ack_o = wbm_2_ack_i;
`endif
`endif

`ifdef WB_GRPS_3
`ifdef WB3_CLK
wire [31-(`WB_ADR_SIZE):0] dummy3;
`VLBASE`MODULE wbwb3 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_3_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_3_adr_i}),
    .wbs_sel_i(wbs_3_sel_i),
    .wbs_bte_i(wbs_3_bte_i),
    .wbs_cti_i(wbs_3_cti_i),
    .wbs_we_i (wbs_3_we_i),
    .wbs_cyc_i(wbs_3_cyc_i),
    .wbs_stb_i(wbs_3_stb_i),
    .wbs_dat_o(wbs_3_dat_o),
    .wbs_ack_o(wbs_3_ack_o),
    .wbs_clk(wbs_3_clk_i),
    .wbs_rst(wbs_3_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_3_dat_o),
    .wbm_adr_o({dummy3,wbm_3_adr_o}),
    .wbm_sel_o(wbm_3_sel_o),
    .wbm_bte_o(wbm_3_bte_o),
    .wbm_cti_o(wbm_3_cti_o),
    .wbm_we_o(wbm_3_we_o),
    .wbm_cyc_o(wbm_3_cyc_o),
    .wbm_stb_o(wbm_3_stb_o),
    .wbm_dat_i(wbm_3_dat_i),
    .wbm_ack_i(wbm_3_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB3_MEM_CLK
    assign wbm_3_dat_o = wbs_3_dat_i;
    assign wbm_3_adr_o = wbs_3_adr_i;
    assign wbm_3_sel_o = wbs_3_sel_i;
    assign wbm_3_bte_o = wbs_3_bte_i;
    assign wbm_3_cti_o = wbs_3_cti_i;
    assign wbm_3_we_o  = wbs_3_we_i;
    assign wbm_3_cyc_o = wbs_3_cyc_i;
    assign wbm_3_stb_o = wbs_3_stb_i;
    assign wbs_3_dat_o = wbm_3_dat_i;
    assign wbs_3_ack_o = wbm_3_ack_i;
`endif
`endif

`ifdef WB_GRPS_4
`ifdef WB4_CLK
wire [31-(`WB_ADR_SIZE):0] dummy4;
`VLBASE`MODULE wbwb4 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_4_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_4_adr_i}),
    .wbs_sel_i(wbs_4_sel_i),
    .wbs_bte_i(wbs_4_bte_i),
    .wbs_cti_i(wbs_4_cti_i),
    .wbs_we_i (wbs_4_we_i),
    .wbs_cyc_i(wbs_4_cyc_i),
    .wbs_stb_i(wbs_4_stb_i),
    .wbs_dat_o(wbs_4_dat_o),
    .wbs_ack_o(wbs_4_ack_o),
    .wbs_clk(wbs_4_clk_i),
    .wbs_rst(wbs_4_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_4_dat_o),
    .wbm_adr_o({dummy4,wbm_4_adr_o}),
    .wbm_sel_o(wbm_4_sel_o),
    .wbm_bte_o(wbm_4_bte_o),
    .wbm_cti_o(wbm_4_cti_o),
    .wbm_we_o(wbm_4_we_o),
    .wbm_cyc_o(wbm_4_cyc_o),
    .wbm_stb_o(wbm_4_stb_o),
    .wbm_dat_i(wbm_4_dat_i),
    .wbm_ack_i(wbm_4_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB4_MEM_CLK
    assign wbm_4_dat_o = wbs_4_dat_i;
    assign wbm_4_adr_o = wbs_4_adr_i;
    assign wbm_4_sel_o = wbs_4_sel_i;
    assign wbm_4_bte_o = wbs_4_bte_i;
    assign wbm_4_cti_o = wbs_4_cti_i;
    assign wbm_4_we_o  = wbs_4_we_i;
    assign wbm_4_cyc_o = wbs_4_cyc_i;
    assign wbm_4_stb_o = wbs_4_stb_i;
    assign wbs_4_dat_o = wbm_4_dat_i;
    assign wbs_4_ack_o = wbm_4_ack_i;
`endif
`endif

`ifdef WB_GRPS_5
`ifdef WB5_CLK
wire [31-(`WB_ADR_SIZE):0] dummy5;
`VLBASE`MODULE wbwb5 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_5_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_5_adr_i}),
    .wbs_sel_i(wbs_5_sel_i),
    .wbs_bte_i(wbs_5_bte_i),
    .wbs_cti_i(wbs_5_cti_i),
    .wbs_we_i (wbs_5_we_i),
    .wbs_cyc_i(wbs_5_cyc_i),
    .wbs_stb_i(wbs_5_stb_i),
    .wbs_dat_o(wbs_5_dat_o),
    .wbs_ack_o(wbs_5_ack_o),
    .wbs_clk(wbs_5_clk_i),
    .wbs_rst(wbs_5_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_5_dat_o),
    .wbm_adr_o({dummy5,wbm_5_adr_o}),
    .wbm_sel_o(wbm_5_sel_o),
    .wbm_bte_o(wbm_5_bte_o),
    .wbm_cti_o(wbm_5_cti_o),
    .wbm_we_o(wbm_5_we_o),
    .wbm_cyc_o(wbm_5_cyc_o),
    .wbm_stb_o(wbm_5_stb_o),
    .wbm_dat_i(wbm_5_dat_i),
    .wbm_ack_i(wbm_5_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB5_MEM_CLK
    assign wbm_5_dat_o = wbs_5_dat_i;
    assign wbm_5_adr_o = wbs_5_adr_i;
    assign wbm_5_sel_o = wbs_5_sel_i;
    assign wbm_5_bte_o = wbs_5_bte_i;
    assign wbm_5_cti_o = wbs_5_cti_i;
    assign wbm_5_we_o  = wbs_5_we_i;
    assign wbm_5_cyc_o = wbs_5_cyc_i;
    assign wbm_5_stb_o = wbs_5_stb_i;
    assign wbs_5_dat_o = wbm_5_dat_i;
    assign wbs_5_ack_o = wbm_5_ack_i;
`endif
`endif

`ifdef WB_GRPS_6
`ifdef WB6_CLK
wire [31-(`WB_ADR_SIZE):0] dummy6;
`VLBASE`MODULE wbwb6 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_6_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_6_adr_i}),
    .wbs_sel_i(wbs_6_sel_i),
    .wbs_bte_i(wbs_6_bte_i),
    .wbs_cti_i(wbs_6_cti_i),
    .wbs_we_i (wbs_6_we_i),
    .wbs_cyc_i(wbs_6_cyc_i),
    .wbs_stb_i(wbs_6_stb_i),
    .wbs_dat_o(wbs_6_dat_o),
    .wbs_ack_o(wbs_6_ack_o),
    .wbs_clk(wbs_6_clk_i),
    .wbs_rst(wbs_6_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_6_dat_o),
    .wbm_adr_o({dummy6,wbm_6_adr_o}),
    .wbm_sel_o(wbm_6_sel_o),
    .wbm_bte_o(wbm_6_bte_o),
    .wbm_cti_o(wbm_6_cti_o),
    .wbm_we_o(wbm_6_we_o),
    .wbm_cyc_o(wbm_6_cyc_o),
    .wbm_stb_o(wbm_6_stb_o),
    .wbm_dat_i(wbm_6_dat_i),
    .wbm_ack_i(wbm_6_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB6_MEM_CLK
    assign wbm_6_dat_o = wbs_6_dat_i;
    assign wbm_6_adr_o = wbs_6_adr_i;
    assign wbm_6_sel_o = wbs_6_sel_i;
    assign wbm_6_bte_o = wbs_6_bte_i;
    assign wbm_6_cti_o = wbs_6_cti_i;
    assign wbm_6_we_o  = wbs_6_we_i;
    assign wbm_6_cyc_o = wbs_6_cyc_i;
    assign wbm_6_stb_o = wbs_6_stb_i;
    assign wbs_6_dat_o = wbm_6_dat_i;
    assign wbs_6_ack_o = wbm_6_ack_i;
`endif
`endif

`ifdef WB_GRPS_7
`ifdef WB7_CLK
wire [31-(`WB_ADR_SIZE):0] dummy7;
`VLBASE`MODULE wbwb7 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_7_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_7_adr_i}),
    .wbs_sel_i(wbs_7_sel_i),
    .wbs_bte_i(wbs_7_bte_i),
    .wbs_cti_i(wbs_7_cti_i),
    .wbs_we_i (wbs_7_we_i),
    .wbs_cyc_i(wbs_7_cyc_i),
    .wbs_stb_i(wbs_7_stb_i),
    .wbs_dat_o(wbs_7_dat_o),
    .wbs_ack_o(wbs_7_ack_o),
    .wbs_clk(wbs_7_clk_i),
    .wbs_rst(wbs_7_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_7_dat_o),
    .wbm_adr_o({dummy7,wbm_7_adr_o}),
    .wbm_sel_o(wbm_7_sel_o),
    .wbm_bte_o(wbm_7_bte_o),
    .wbm_cti_o(wbm_7_cti_o),
    .wbm_we_o(wbm_7_we_o),
    .wbm_cyc_o(wbm_7_cyc_o),
    .wbm_stb_o(wbm_7_stb_o),
    .wbm_dat_i(wbm_7_dat_i),
    .wbm_ack_i(wbm_7_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB7_MEM_CLK
    assign wbm_7_dat_o = wbs_7_dat_i;
    assign wbm_7_adr_o = wbs_7_adr_i;
    assign wbm_7_sel_o = wbs_7_sel_i;
    assign wbm_7_bte_o = wbs_7_bte_i;
    assign wbm_7_cti_o = wbs_7_cti_i;
    assign wbm_7_we_o  = wbs_7_we_i;
    assign wbm_7_cyc_o = wbs_7_cyc_i;
    assign wbm_7_stb_o = wbs_7_stb_i;
    assign wbs_7_dat_o = wbm_7_dat_i;
    assign wbs_7_ack_o = wbm_7_ack_i;
`endif
`endif

`ifdef WB_GRPS_8
`ifdef WB8_CLK
wire [31-(`WB_ADR_SIZE):0] dummy8;
`VLBASE`MODULE wbwb8 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_8_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_8_adr_i}),
    .wbs_sel_i(wbs_8_sel_i),
    .wbs_bte_i(wbs_8_bte_i),
    .wbs_cti_i(wbs_8_cti_i),
    .wbs_we_i (wbs_8_we_i),
    .wbs_cyc_i(wbs_8_cyc_i),
    .wbs_stb_i(wbs_8_stb_i),
    .wbs_dat_o(wbs_8_dat_o),
    .wbs_ack_o(wbs_8_ack_o),
    .wbs_clk(wbs_8_clk_i),
    .wbs_rst(wbs_8_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_8_dat_o),
    .wbm_adr_o({dummy8,wbm_8_adr_o}),
    .wbm_sel_o(wbm_8_sel_o),
    .wbm_bte_o(wbm_8_bte_o),
    .wbm_cti_o(wbm_8_cti_o),
    .wbm_we_o(wbm_8_we_o),
    .wbm_cyc_o(wbm_8_cyc_o),
    .wbm_stb_o(wbm_8_stb_o),
    .wbm_dat_i(wbm_8_dat_i),
    .wbm_ack_i(wbm_8_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB8_MEM_CLK
    assign wbm_8_dat_o = wbs_8_dat_i;
    assign wbm_8_adr_o = wbs_8_adr_i;
    assign wbm_8_sel_o = wbs_8_sel_i;
    assign wbm_8_bte_o = wbs_8_bte_i;
    assign wbm_8_cti_o = wbs_8_cti_i;
    assign wbm_8_we_o  = wbs_8_we_i;
    assign wbm_8_cyc_o = wbs_8_cyc_i;
    assign wbm_8_stb_o = wbs_8_stb_i;
    assign wbs_8_dat_o = wbm_8_dat_i;
    assign wbs_8_ack_o = wbm_8_ack_i;
`endif
`endif

`undef MODULE

`ifdef WB_GRPS_2
// we have at least two ports and need an arbiter
`define MODULE wb3_arbiter_type1
`VLBASE`MODULE
# (.nr_of_ports(`NR_OF_PORTS), .adr_size(`WB_ADR_SIZE))
wb0(
`undef MODULE
    .wbm_dat_o({wbm_1_dat_o,wbm_2_dat_o
`ifdef WB_GRPS_3
    ,wbm_3_dat_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_dat_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_dat_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_dat_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_dat_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_dat_o
`endif
    }),
    .wbm_adr_o({wbm_1_adr_o,wbm_2_adr_o
`ifdef WB_GRPS_3
    ,wbm_3_adr_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_adr_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_adr_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_adr_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_adr_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_adr_o
`endif
    }),
    .wbm_sel_o({wbm_1_sel_o,wbm_2_sel_o
`ifdef WB_GRPS_3
    ,wbm_3_sel_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_sel_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_sel_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_sel_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_sel_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_sel_o
`endif
    }),
    .wbm_cti_o({wbm_1_cti_o,wbm_2_cti_o
`ifdef WB_GRPS_3
    ,wbm_3_cti_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_cti_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_cti_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_cti_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_cti_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_cti_o
`endif
    }),
    .wbm_bte_o({wbm_1_bte_o,wbm_2_bte_o
`ifdef WB_GRPS_3
    ,wbm_3_bte_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_bte_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_bte_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_bte_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_bte_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_bte_o
`endif
    }),
    .wbm_we_o({wbm_1_we_o,wbm_2_we_o
`ifdef WB_GRPS_3
    ,wbm_3_we_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_we_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_we_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_we_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_we_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_we_o
`endif
    }),
    .wbm_stb_o({wbm_1_stb_o,wbm_2_stb_o
`ifdef WB_GRPS_3
    ,wbm_3_stb_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_stb_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_stb_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_stb_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_stb_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_stb_o
`endif
    }),
    .wbm_cyc_o({wbm_1_cyc_o,wbm_2_cyc_o
`ifdef WB_GRPS_3
    ,wbm_3_cyc_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_cyc_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_cyc_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_cyc_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_cyc_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_cyc_o
`endif
    }),
    .wbm_dat_i({wbm_1_dat_i,wbm_2_dat_i
`ifdef WB_GRPS_3
    ,wbm_3_dat_i
`endif
`ifdef WB_GRPS_4
    ,wbm_4_dat_i
`endif
`ifdef WB_GRPS_5
    ,wbm_5_dat_i
`endif
`ifdef WB_GRPS_6
    ,wbm_6_dat_i
`endif
`ifdef WB_GRPS_7
    ,wbm_7_dat_i
`endif
`ifdef WB_GRPS_8
    ,wbm_8_dat_i
`endif
    }),
    .wbm_ack_i({wbm_1_ack_i,wbm_2_ack_i
`ifdef WB_GRPS_3
    ,wbm_3_ack_i
`endif
`ifdef WB_GRPS_4
    ,wbm_4_ack_i
`endif
`ifdef WB_GRPS_5
    ,wbm_5_ack_i
`endif
`ifdef WB_GRPS_6
    ,wbm_6_ack_i
`endif
`ifdef WB_GRPS_7
    ,wbm_7_ack_i
`endif
`ifdef WB_GRPS_8
    ,wbm_8_ack_i
`endif
    }),
    .wbm_err_i({wbm_1_err_i,wbm_2_err_i
`ifdef WB_GRPS_3
    ,wbm_3_err_i
`endif
`ifdef WB_GRPS_4
    ,wbm_4_err_i
`endif
`ifdef WB_GRPS_5
    ,wbm_5_err_i
`endif
`ifdef WB_GRPS_6
    ,wbm_6_err_i
`endif
`ifdef WB_GRPS_7
    ,wbm_7_err_i
`endif
`ifdef WB_GRPS_8
    ,wbm_8_err_i
`endif
    }),
    .wbm_rty_i({wbm_1_rty_i,wbm_2_rty_i
`ifdef WB_GRPS_3
    ,wbm_3_rty_i
`endif
`ifdef WB_GRPS_4
    ,wbm_4_rty_i
`endif
`ifdef WB_GRPS_5
    ,wbm_5_rty_i
`endif
`ifdef WB_GRPS_6
    ,wbm_6_rty_i
`endif
`ifdef WB_GRPS_7
    ,wbm_7_rty_i
`endif
`ifdef WB_GRPS_8
    ,wbm_8_rty_i
`endif
    }),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_we_i(wbs_we_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o),
    .wbs_err_o(wbs_err_o),
    .wbs_rty_o(wbs_rty_o),
    .wb_clk(mem_clk),
    .wb_rst(mem_clk)
);

`else
// only one external port an no need for arbiter
assign wbs_dat_i = wbm_dat_i;
assign wbs_adr_i = wbm_adr_i;
assign wbs_sel_i = wbm_sel_i;
assign wbs_cti_i = wbm_cti_i;
assign wbs_bte_i = wbm_bte_i;
assign wbs_we_i  = wbm_we_i;
assign wbs_stb_i = wbm_stb_i;
assign wbs_cyc_i = wbm_cyc_i;
assign wbm_dat_o = wbs_dat_o;
assign wbm_ack_o = wbs_ack_o;
`endif

`ifdef SHADOW_RAM
wire [31:0] wbs_ram_dat_o;
wire        wbs_ram_ack_o;
wire [31:0] wbs_sdram_dat_o;
wire        wbs_sdram_ack_o;
assign select_sdram = wbs_adr_i > (`RAM_MEM_SIZE-1);
assign wbs_dat_o = select_sdram ? wbs_sdram_dat_o : wbs_ram_dat_o;
assign wbs_ack_o = select_sdram ? wbs_sdram_ack_o : wbs_ram_ack_o;
`endif

`ifdef RAM
`define MODULE wb_b3_ram_be
`VLBASE`MODULE
`undef MODULE
# (
    .adr_size(`RAM_ADR_SIZE),
    .mem_size(`RAM_MEM_SIZE),
    .memory_init(`RAM_MEM_INIT),
    .memory_file(`RAM_MEM_INIT_FILE)
)
ram0 (
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_we_i(wbs_we_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i), 
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o),
    .wb_clk(mem_clk),
    .wb_rst(mem_rst));
`else
`ifdef SHADOW_RAM
`define MODULE wb_b3_ram_be
`VLBASE`MODULE
`undef MODULE
# (
    .adr_size(`RAM_ADR_SIZE),
    .mem_size(`RAM_MEM_SIZE),
    .memory_init(`RAM_MEM_INIT),
    .memory_file(`RAM_MEM_INIT_FILE)
)
ram0 (
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i[`WB_RAM_ADR_SIZE-2-1:0]),
    .wbs_cti_i(wbs_cti_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_we_i(wbs_we_i),
    .wbs_stb_i(wbs_stb_i),    
    .wbs_cyc_i(wbs_cyc_i & ~select_sdram), 
    .wbs_dat_o(wbs_ram_dat_o),
    .wbs_ack_o(wbs_ram_ack_o),
    .wb_clk(mem_clk),
    .wb_rst(mem_rst));
`endif
`endif

`ifdef SDR
`define MODULE sdr16
`BASE`MODULE sdr16_0(
`undef MODULE
    // wisbone i/f
    .dat_i(wbs_dat_i),
    .adr_i({wbs_adr_i,1'b0}),
    .sel_i(wbs_sel_i),
`ifndef SDR_NO_BURST
    .bte_i(wbs_bte_i),
`endif
    .we_i(wbs_we_i),
`ifdef SHADOW_RAM
    .cyc_i(wbs_cyc_i & select_sdram),
`else
    .cyc_i(wbs_cyc_i),
`endif
    .stb_i(wbs_stb_i),
`ifdef SHADOW_RAM
    .dat_o(wbs_sdram_dat_o),
    .ack_o(wbs_sdram_ack_o),
`else
    .dat_o(wbs_dat_o),
    .ack_o(wbs_ack_o),
`endif
    // SDR SDRAM
    .ba(ba),
    .a(a),
    .cmd(cmd),
    .cke(cke),
    .cs_n(cs_n),
    .dqm(dqm),
    .dq_i(dq_i),
    .dq_o(dq_o),
    .dq_oe(dq_oe),
    // system
    .clk(mem_clk),
    .rst(mem_rst));
`endif

`ifdef DDR2
`endif

`ifdef DDR3
`ifdef DDR3_BOARD_2AGX125N
ddr3_2agx125n_if ddr3_0 (
    .wb_adr_i(wbs_adr_i),
    .wb_stb_i(wbs_stb_i),
`ifdef SHADOW_RAM
    .wb_cyc_i(wbs_cyc_i & select_sdram),
`else
    .wb_cyc_i(wbs_cyc_i),
`endif
    .wb_cti_i(wbs_cti_i),
    .wb_bte_i(wbs_bte_i),
    .wb_we_i (wbs_we_i),
    .wb_sel_i(wbs_sel_i),
    .wb_dat_i(wbs_dat_i),
`ifdef SHADOW_RAM
    .wb_dat_o(wbs_sdram_dat_o),
    .wb_ack_o(wbs_sdram_ack_o),
`else
    .wb_dat_o(wbs_dat_o),
    .wb_ack_o(wbs_ack_o),
`endif

    .mem_addr(mem_addr),
    .mem_ba(mem_ba),
    .mem_cas_n(mem_cas_n),
    .mem_cke(mem_cke),
    .mem_clk(mem_clk),
    .mem_clk_n(mem_clk_n),
    .mem_cs_n(mem_cs_n),
    .mem_dm(mem_dm),
    .mem_dq(mem_dq),
    .mem_dqs(mem_dqs),
    .mem_dqsn(mem_dqsn),
    .mem_odt(mem_odt),
    .mem_ras_n(mem_ras_n),
    .mem_reset_n(mem_reset_n),
    .mem_we_n(mem_we_n),
    .mem_ref_clk(mem_ref_clk), /* 100MHz */		       

    .wb_clk(mem_clk),
    .wb_rst(mem_rst));
`endif
`endif

endmodule

// -----------------------------------------------------------------------------
// Source file: versatile_mem_ctrl_defines.v
// -----------------------------------------------------------------------------
//=tab Main

// Number of WB groups
//=select
//`define WB_GRPS_1 // 1
//`define WB_GRPS_2 // 2
`define WB_GRPS_3 // 3
//`define WB_GRPS_4 // 4
//`define WB_GRPS_5 // 5
//`define WB_GRPS_6 // 6
//`define WB_GRPS_7 // 7
//`define WB_GRPS_8 // 8
//=end

`ifdef WB_GRPS_2
    `define WB_GRPS_1
    `define NR_OF_WB_GRPS 2
    `define NR_OF_PORTS 2
`endif
`ifdef WB_GRPS_3
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define NR_OF_WB_GRPS 3
    `define NR_OF_PORTS 3
`endif
`ifdef WB_GRPS_4
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define NR_OF_WB_GRPS 4
    `define NR_OF_PORTS 4
`endif
`ifdef WB_GRPS_5
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define WB_GRPS_4
    `define NR_OF_WB_GRPS 5
    `define NR_OF_PORTS 5
`endif
`ifdef WB_GRPS_6
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define WB_GRPS_4
    `define WB_GRPS_5
    `define NR_OF_WB_GRPS 6
    `define NR_OF_PORTS 6
`endif
`ifdef WB_GRPS_7
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define WB_GRPS_4
    `define WB_GRPS_5
    `define WB_GRPS_6
    `define NR_OF_WB_GRPS 7
    `define NR_OF_PORTS 7
`endif
`ifdef WB_GRPS_8
    `define WB_GRPS_1
    `define WB_GRPS_2
    `define WB_GRPS_3
    `define WB_GRPS_4
    `define WB_GRPS_5
    `define WB_GRPS_6
    `define WB_GRPS_7
    `define NR_OF_WB_GRPS 8
    `define NR_OF_PORTS 8
`endif

// Clock domain crossing WB1
//=select
//`define WB1_MEM_CLK // mem clk domain
`define WB1_CLK // wb1 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB2_MEM_CLK // mem clk domain
`define WB2_CLK // wb2 clk domain
//=end
// Clock domain crossing WB1
//=select
`define WB3_MEM_CLK // mem clk domain
//`define WB3_CLK // wb3 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB4_MEM_CLK // mem clk domain
`define WB4_CLK // wb4 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB5_MEM_CLK // mem clk domain
`define WB5_CLK // wb5 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB6_MEM_CLK // mem clk domain
`define WB6_CLK // wb6 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB7_MEM_CLK // mem clk domain
`define WB7_CLK // wb7 clk domain
//=end
// Clock domain crossing WB1
//=select
//`define WB8_MEM_CLK // mem clk domain
`define WB8_CLK // wb8 clk domain
//=end

// Module base name
`define BASE versatile_mem_ctrl_

// Memory type
//=select
//`define RAM // RAM
//`define SDR // SDR
//`define DDR2 // DDR2
`define DDR3 // DDR3
//=end

// Shadow RAM
`define SHADOW_RAM

//=tab RAM
// Number of bits in address
`define RAM_ADR_SIZE 16
// Capacity in KBytes
`define RAM_MEM_SIZE_KB 48
`ifdef RAM_MEM_SIZE_KB
`define RAM_MEM_SIZE `RAM_MEM_SIZE_KB*1024
`endif

// Memory init
`define RAM_MEM_INIT_DUMMY
`ifndef RAM_MEM_INIT_DUMMY
    `define RAM_MEM_INIT 0
`else
    `define RAM_MEM_INIT 1
`endif

// Memory init file
`define RAM_MEM_INIT_FILE "ram_init.v"

`ifdef RAM
`define WB_ADR_SIZE `RAM_ADR_SIZE
`endif
`ifdef SHADOW_RAM
`define WB_RAM_ADR_SIZE `RAM_ADR_SIZE
`endif
//=tab SDR SDRAM

// External data bus size
`define SDR_EXT_DAT_SIZE 16

// Memory part
//=select Memory part
//`define MT48LC4M16 // Micron 4M16, 8MB
`define MT48LC16M16 // Micron 16M16, 32MB
//`define MT48LC32M16 // Micron 32M16, 64MB
//=end

// SDRAM clock frequency
// set refresh counter timeout
// all rows should be refreshed every 64 ms
// SDRAM CLK frequency
//=select SDRAM CLK
`define SDR_SDRAM_CLK_64 // SDRAM_CLK_64
//`define SDR_SDRAM_CLK_75 // SDRAM_CLK_75
//`define SDR_SDRAM_CLK_125 // SDRAM_CLK_125
//`define SDR_SDRAM_CLK_133 // SDRAM_CLK_133
//`define SDR_SDRAM_CLK_154 // SDRAM_CLK_154
//=end

`ifdef MT48LC4M16
// using 1 of MT48LC4M16
// SDRAM data width is 16
`define SDR_SDRAM_DATA_WIDTH 16
`define SDR_SDRAM_DATA_WIDTH_16
`define SDR_COL_SIZE 8
`define SDR_ROW_SIZE 12
`define SDR_ROW_SIZE_12
`define SDR_BA_SIZE 2
`endif //  `ifdef MT48LC4M16

`ifdef MT48LC16M16
// using 1 of MT48LC16M16
// SDRAM data width is 16
`define SDR_SDRAM_DATA_WIDTH 16
`define SDR_SDRAM_DATA_WIDTH_16
`define SDR_COL_SIZE 9
`define SDR_ROW_SIZE 13
`define SDR_ROW_SIZE_13
`define SDR_BA_SIZE 2
`endif //  `ifdef MT48LC16M16

`ifdef MT48LC32M16
// using 1 of MT48LC32M16
// SDRAM data width is 16
`define SDR_SDRAM_DATA_WIDTH 16
`define SDR_SDRAM_DATA_WIDTH_16
`define SDR_COL_SIZE 10
`define SDR_ROW_SIZE 13
`define SDR_ROW_SIZE_13
`define SDR_BA_SIZE 2
`endif //  `ifdef MT48LC16M16

// Refresh whole memory every 64 ms
// Refresh each row every 64 ms
// refresh timeout = 64 ms / Tperiod / number_of_rows

// 64 MHz, row_size=12
// 64ms / (1/64MHz) / 2^12 = 1000
// ./VersatileCounter.php 10 1000
// 0101100100

`ifdef SDR_SDRAM_CLK_64
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 10
        `define SDR_RFR_WRAP_VALUE 0101100100
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 9
        `define SDR_RFR_WRAP_VALUE 001000011
    `endif
`endif
`ifdef SDR_SDRAM_CLK_75
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 11
        `define SDR_RFR_WRAP_VALUE 00110001101
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 10
        `define SDR_RFR_WRAP_VALUE 0110111101
    `endif
`endif
`ifdef SDR_SDRAM_CLK_125
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 11
        `define SDR_RFR_WRAP_VALUE 10001000001
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 10
        `define SDR_RFR_WRAP_VALUE 1010000111
    `endif
`endif
`ifdef SDR_SDRAM_CLK_133
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 12
        `define SDR_RFR_WRAP_VALUE 101100000111
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 11
        `define SDR_RFR_WRAP_VALUE 11111111010
    `endif
`endif
`ifdef SDR_SDRAM_CLK_154
    `ifdef SDR_ROW_SIZE_12
        `define SDR_RFR_LENGTH 12
        `define SDR_RFR_WRAP_VALUE 000101011110
    `endif
    `ifdef SDR_ROW_SIZE_13
        `define SDR_RFR_LENGTH 11
        `define SDR_RFR_WRAP_VALUE 00111101010
    `endif
`endif


// Disable burst
//`define SDR_NO_BURST
// Enable 4 beat wishbone busrt
`define SDR_BEAT4
// Enable 8 beat wishbone busrt
`define SDR_BEAT8
// Enable 16 beat wishbone busrt
`define SDR_BEAT16

// tRFC
`define SDR_TRFC 9
// tRP
`define SDR_TRP 2
// tRCD
`define SDR_TRCD 2
// tMRD
`define SDR_TMRD 2

// LMR
// [12:10] reserved
// [9]     WB, write burst; 0 - programmed burst length, 1 - single location
// [8:7]   OP Mode, 2'b00
// [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
// [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
// [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
// LMR: Write burst
`define SDR_INIT_WB 1'b0
// LMR: CAS latency
`define SDR_INIT_CL 3'b010
// LMR: Burst type
`define SDR_INIT_BT 1'b0
// LMR: Burst length
`define SDR_INIT_BL 3'b001

`ifdef SDR
    `ifdef SDR_SDRAM_DATA_WIDTH_16
        `define WB_ADR_SIZE `SDR_BA_SIZE+`SDR_COL_SIZE+`SDR_ROW_SIZE+1
    `endif
`endif

//=tab DDR2 SDRAM

// Use existing Avalon compatible IP
`define DDR2_AVALON
// IP module name
`define DDR2_IP_NAME ALTERA_DDR2

`ifdef DDR2
`define WB_ADR_SIZE 24
`endif

//=tab DDR3 SDRAM

// Board
//=select
`define DDR3_BOARD_2AGX125N // ARRIAII BOARD 2AGX125N
//=end
`ifdef DDR3
`ifdef DDR3_BOARD_2AGX125N
`define WB_ADR_SIZE 30
`endif
`endif

// -----------------------------------------------------------------------------
// Source file: ddr2_module.v
// -----------------------------------------------------------------------------
/****************************************************************************************
*
*    File Name:  ddr2_module.v
*
* Dependencies:  ddr2.v, ddr2.v, ddr2_parameters.vh
*
*  Description:  Micron SDRAM DDR2 (Double Data Rate 2) module model
*
*   Limitation:  - SPD (Serial Presence-Detect) is not modeled
*
*   Disclaimer   This software code and all associated documentation, comments or other 
*  of Warranty:  information (collectively "Software") is provided "AS IS" without 
*                warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
*                DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
*                TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
*                OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
*                WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
*                OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
*                FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
*                THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
*                ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
*                OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
*                ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
*                INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
*                WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
*                OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
*                THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
*                DAMAGES. Because some jurisdictions prohibit the exclusion or 
*                limitation of liability for consequential or incidental damages, the 
*                above limitation may not apply to you.
*
*                Copyright 2003 Micron Technology, Inc. All rights reserved.
*
****************************************************************************************/
 `timescale 1ps / 1ps

module ddr2_module (
`ifdef SODIMM
`else
    reset_n,
    cb     ,
`endif
    ck     ,
    ck_n   ,
    cke    ,
    s_n    ,
    ras_n  ,
    cas_n  ,
    we_n   ,
    ba     ,
    addr   ,
    odt    ,
    dqs    ,
    dqs_n  ,
    dq     ,
    scl    ,
    sa     ,
    sda
);

`include "ddr2_parameters.vh"

    input            [1:0] cke    ;
    input                  ras_n  ;
    input                  cas_n  ;
    input                  we_n   ;
    input            [2:0] ba     ;
    input           [15:0] addr   ;
    input            [1:0] odt    ;
    inout           [17:0] dqs    ;
    inout           [17:0] dqs_n  ;
    inout           [63:0] dq     ;
    input                  scl    ; // no connect
    inout                  sda    ; // no connect

`ifdef QUAD_RANK
    initial if (DEBUG) $display("%m: Quad Rank");
`else `ifdef DUAL_RANK
    initial if (DEBUG) $display("%m: Dual Rank");
`else
    initial if (DEBUG) $display("%m: Single Rank");
`endif `endif

`ifdef ECC
    initial if (DEBUG) $display("%m: ECC");
    `ifdef SODIMM
    initial begin
        $display("%m ERROR: ECC is not available on SODIMM configurations");
        if (STOP_ON_ERROR) $stop(0);
    end
    `endif
`else
    initial if (DEBUG) $display("%m: non ECC");
`endif

`ifdef RDIMM
    initial if (DEBUG) $display("%m: RDIMM");
    input                  reset_n;
    input                  ck     ;
    input                  ck_n   ;
    input            [3:0] s_n    ;
    inout            [7:0] cb     ;
    input            [2:0] sa     ; // no connect

    wire             [5:0] rck    = {6{ck}};
    wire             [5:0] rck_n  = {6{ck_n}};
    reg              [3:0] rs_n   ;
    reg                    rras_n ;
    reg                    rcas_n ;
    reg                    rwe_n  ;
    reg              [2:0] rba    ;
    reg             [15:0] raddr  ;
    reg              [3:0] rcke   ;
    reg              [3:0] rodt   ;

    always @(negedge reset_n or posedge ck) begin
        if (!reset_n) begin
            rs_n   <= #(500) 0;
            rras_n <= #(500) 0;
            rcas_n <= #(500) 0;
            rwe_n  <= #(500) 0;
            rba    <= #(500) 0;
            raddr  <= #(500) 0;
            rcke   <= #(500) 0;
            rodt   <= #(500) 0;
        end else begin
            rs_n   <= #(500) s_n  ;
            rras_n <= #(500) ras_n;
            rcas_n <= #(500) cas_n;
            rwe_n  <= #(500) we_n ;
            rba    <= #(500) ba   ;
            raddr  <= #(500) addr ;
    `ifdef QUAD_RANK
            rcke   <= #(500) {{2{cke[1]}}, {2{cke[0]}}};
            rodt   <= #(500) {{2{odt[1]}}, {2{odt[0]}}};
    `else
            rcke   <= #(500) {2'b00, cke};
            rodt   <= #(500) {2'b00, odt};
    `endif

        end
    end
`else
    `ifdef SODIMM
    initial if (DEBUG) $display("%m: SODIMM");
    input            [1:0] ck     ;
    input            [1:0] ck_n   ;
    input            [1:0] s_n    ;
    input            [1:0] sa     ; // no connect

    wire             [7:0] cb;
    wire             [5:0] rck    = {{3{ck[1]}}, {3{ck[0]}}};
    wire             [5:0] rck_n  = {{3{ck_n[1]}}, {3{ck_n[0]}}};
    `else
    initial if (DEBUG) $display("%m: UDIMM");
    input                  reset_n;
    input            [2:0] ck     ;
    input            [2:0] ck_n   ;
    input            [1:0] s_n    ;
    inout            [7:0] cb     ;
    input            [2:0] sa     ; // no connect

    wire             [5:0] rck    = {2{ck}};
    wire             [5:0] rck_n  = {2{ck_n}};
    `endif

    wire             [2:0] rba    = ba   ;
    wire            [15:0] raddr  = addr ;
    wire                   rras_n = ras_n;
    wire                   rcas_n = cas_n;
    wire                   rwe_n  = we_n ;
    `ifdef QUAD_RANK
    wire             [3:0] rs_n   = {{2{s_n[1]}}, {2{s_n[0]}}};
    wire             [3:0] rcke   = {{2{cke[1]}}, {2{cke[0]}}};
    wire             [3:0] rodt   = {{2{odt[1]}}, {2{odt[0]}}};
    `else
    wire             [3:0] rs_n   = {2'b00, s_n};
    wire             [3:0] rcke   = {2'b00, cke};
    wire             [3:0] rodt   = {2'b00, odt};
    `endif
`endif
    wire            [15:0] rcb    = {8'b0, cb};
    wire                   zero   = 1'b0;
    wire                   one    = 1'b1;

  //ddr2       (ck    , ck_n    , cke    , cs_n   , ras_n , cas_n , we_n , dm_rdqs       , ba , addr                , dq        , dqs           , dqs_n     , rdqs_n   , odt    );
`ifdef x4
    initial if (DEBUG) $display("%m: Component Width = x4");
    ddr2 U1R0  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [ 3: 0], dqs[  0]      , dqs_n[  0],          , rodt[0]);
    ddr2 U2R0  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [11: 8], dqs[  1]      , dqs_n[  1],          , rodt[0]);
    ddr2 U3R0  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [19:16], dqs[  2]      , dqs_n[  2],          , rodt[0]);
    ddr2 U4R0  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [27:24], dqs[  3]      , dqs_n[  3],          , rodt[0]);
    ddr2 U6R0  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [35:32], dqs[  4]      , dqs_n[  4],          , rodt[0]);
    ddr2 U7R0  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [43:40], dqs[  5]      , dqs_n[  5],          , rodt[0]);
    ddr2 U8R0  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [51:48], dqs[  6]      , dqs_n[  6],          , rodt[0]);
    ddr2 U9R0  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [59:56], dqs[  7]      , dqs_n[  7],          , rodt[0]);
    `ifdef ECC                 
    ddr2 U5R0  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], rcb[ 3: 0], dqs[  8]      , dqs_n[  8],          , rodt[0]);
    `endif
    ddr2 U18R0 (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [ 7: 4], dqs[  9]      , dqs_n[  9],          , rodt[0]);
    ddr2 U17R0 (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [15:12], dqs[ 10]      , dqs_n[ 10],          , rodt[0]);
    ddr2 U16R0 (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [23:20], dqs[ 11]      , dqs_n[ 11],          , rodt[0]);
    ddr2 U15R0 (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [31:28], dqs[ 12]      , dqs_n[ 12],          , rodt[0]);
    ddr2 U13R0 (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [39:36], dqs[ 13]      , dqs_n[ 13],          , rodt[0]);
    ddr2 U12R0 (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [47:44], dqs[ 14]      , dqs_n[ 14],          , rodt[0]);
    ddr2 U11R0 (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [55:52], dqs[ 15]      , dqs_n[ 15],          , rodt[0]);
    ddr2 U10R0 (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [63:60], dqs[ 16]      , dqs_n[ 16],          , rodt[0]);
    `ifdef ECC                 
    ddr2 U14R0 (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], rcb[ 7: 4], dqs[ 17]      , dqs_n[ 17],          , rodt[0]);
    `endif
    `ifdef DUAL_RANK
    ddr2 U1R1  (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [ 3: 0], dqs[  0]      , dqs_n[  0],          , rodt[1]);
    ddr2 U2R1  (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [11: 8], dqs[  1]      , dqs_n[  1],          , rodt[1]);
    ddr2 U3R1  (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [19:16], dqs[  2]      , dqs_n[  2],          , rodt[1]);
    ddr2 U4R1  (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [27:24], dqs[  3]      , dqs_n[  3],          , rodt[1]);
    ddr2 U6R1  (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [35:32], dqs[  4]      , dqs_n[  4],          , rodt[1]);
    ddr2 U7R1  (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [43:40], dqs[  5]      , dqs_n[  5],          , rodt[1]);
    ddr2 U8R1  (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [51:48], dqs[  6]      , dqs_n[  6],          , rodt[1]);
    ddr2 U9R1  (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [59:56], dqs[  7]      , dqs_n[  7],          , rodt[1]);
        `ifdef  ECC            
    ddr2 U5R1  (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], rcb[ 3: 0], dqs[  8]      , dqs_n[  8],          , rodt[1]);
        `endif
    ddr2 U18R1 (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [ 7: 4], dqs[  9]      , dqs_n[  9],          , rodt[1]);
    ddr2 U17R1 (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [15:12], dqs[ 10]      , dqs_n[ 10],          , rodt[1]);
    ddr2 U16R1 (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [23:20], dqs[ 11]      , dqs_n[ 11],          , rodt[1]);
    ddr2 U15R1 (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [31:28], dqs[ 12]      , dqs_n[ 12],          , rodt[1]);
    ddr2 U13R1 (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [39:36], dqs[ 13]      , dqs_n[ 13],          , rodt[1]);
    ddr2 U12R1 (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [47:44], dqs[ 14]      , dqs_n[ 14],          , rodt[1]);
    ddr2 U11R1 (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [55:52], dqs[ 15]      , dqs_n[ 15],          , rodt[1]);
    ddr2 U10R1 (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [63:60], dqs[ 16]      , dqs_n[ 16],          , rodt[1]);
        `ifdef ECC            
    ddr2 U14R1 (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], rcb[ 7: 4], dqs[ 17]      , dqs_n[ 17],          , rodt[1]);
        `endif
    `endif
    `ifdef QUAD_RANK
    ddr2 U1R2  (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [ 3: 0], dqs[  0]      , dqs_n[  0],          , rodt[2]);
    ddr2 U2R2  (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [11: 8], dqs[  1]      , dqs_n[  1],          , rodt[2]);
    ddr2 U3R2  (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [19:16], dqs[  2]      , dqs_n[  2],          , rodt[2]);
    ddr2 U4R2  (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [27:24], dqs[  3]      , dqs_n[  3],          , rodt[2]);
    ddr2 U6R2  (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [35:32], dqs[  4]      , dqs_n[  4],          , rodt[2]);
    ddr2 U7R2  (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [43:40], dqs[  5]      , dqs_n[  5],          , rodt[2]);
    ddr2 U8R2  (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [51:48], dqs[  6]      , dqs_n[  6],          , rodt[2]);
    ddr2 U9R2  (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [59:56], dqs[  7]      , dqs_n[  7],          , rodt[2]);
        `ifdef ECC                 
    ddr2 U5R2  (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], rcb[ 3: 0], dqs[  8]      , dqs_n[  8],          , rodt[2]);
        `endif
    ddr2 U18R2 (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [ 7: 4], dqs[  9]      , dqs_n[  9],          , rodt[2]);
    ddr2 U17R2 (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [15:12], dqs[ 10]      , dqs_n[ 10],          , rodt[2]);
    ddr2 U16R2 (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [23:20], dqs[ 11]      , dqs_n[ 11],          , rodt[2]);
    ddr2 U15R2 (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [31:28], dqs[ 12]      , dqs_n[ 12],          , rodt[2]);
    ddr2 U13R2 (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [39:36], dqs[ 13]      , dqs_n[ 13],          , rodt[2]);
    ddr2 U12R2 (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [47:44], dqs[ 14]      , dqs_n[ 14],          , rodt[2]);
    ddr2 U11R2 (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [55:52], dqs[ 15]      , dqs_n[ 15],          , rodt[2]);
    ddr2 U10R2 (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [63:60], dqs[ 16]      , dqs_n[ 16],          , rodt[2]);
        `ifdef ECC                 
    ddr2 U14R2 (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], rcb[ 7: 4], dqs[ 17]      , dqs_n[ 17],          , rodt[2]);
        `endif
    ddr2 U1R3  (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [ 3: 0], dqs[  0]      , dqs_n[  0],          , rodt[3]);
    ddr2 U2R3  (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [11: 8], dqs[  1]      , dqs_n[  1],          , rodt[3]);
    ddr2 U3R3  (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [19:16], dqs[  2]      , dqs_n[  2],          , rodt[3]);
    ddr2 U4R3  (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [27:24], dqs[  3]      , dqs_n[  3],          , rodt[3]);
    ddr2 U6R3  (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [35:32], dqs[  4]      , dqs_n[  4],          , rodt[3]);
    ddr2 U7R3  (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [43:40], dqs[  5]      , dqs_n[  5],          , rodt[3]);
    ddr2 U8R3  (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [51:48], dqs[  6]      , dqs_n[  6],          , rodt[3]);
    ddr2 U9R3  (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [59:56], dqs[  7]      , dqs_n[  7],          , rodt[3]);
        `ifdef  ECC            
    ddr2 U5R3  (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], rcb[ 3: 0], dqs[  8]      , dqs_n[  8],          , rodt[3]);
        `endif
    ddr2 U18R3 (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [ 7: 4], dqs[  9]      , dqs_n[  9],          , rodt[3]);
    ddr2 U17R3 (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [15:12], dqs[ 10]      , dqs_n[ 10],          , rodt[3]);
    ddr2 U16R3 (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [23:20], dqs[ 11]      , dqs_n[ 11],          , rodt[3]);
    ddr2 U15R3 (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [31:28], dqs[ 12]      , dqs_n[ 12],          , rodt[3]);
    ddr2 U13R3 (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [39:36], dqs[ 13]      , dqs_n[ 13],          , rodt[3]);
    ddr2 U12R3 (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [47:44], dqs[ 14]      , dqs_n[ 14],          , rodt[3]);
    ddr2 U11R3 (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [55:52], dqs[ 15]      , dqs_n[ 15],          , rodt[3]);
    ddr2 U10R3 (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], dq [63:60], dqs[ 16]      , dqs_n[ 16],          , rodt[3]);
        `ifdef ECC            
    ddr2 U14R3 (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, zero          , rba, raddr[ADDR_BITS-1:0], rcb[ 7: 4], dqs[ 17]      , dqs_n[ 17],          , rodt[3]);
        `endif
    `endif
`else `ifdef x8
    initial if (DEBUG) $display("%m: Component Width = x8");
    ddr2 U1R0  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[ 9]       , rba, raddr[ADDR_BITS-1:0], dq [ 7: 0], dqs[  0]      , dqs_n[  0], dqs_n[ 9], rodt[0]);
    ddr2 U2R0  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[10]       , rba, raddr[ADDR_BITS-1:0], dq [15: 8], dqs[  1]      , dqs_n[  1], dqs_n[10], rodt[0]);
    ddr2 U3R0  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[11]       , rba, raddr[ADDR_BITS-1:0], dq [23:16], dqs[  2]      , dqs_n[  2], dqs_n[11], rodt[0]);
    ddr2 U4R0  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[12]       , rba, raddr[ADDR_BITS-1:0], dq [31:24], dqs[  3]      , dqs_n[  3], dqs_n[12], rodt[0]);
    ddr2 U6R0  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[13]       , rba, raddr[ADDR_BITS-1:0], dq [39:32], dqs[  4]      , dqs_n[  4], dqs_n[13], rodt[0]);
    ddr2 U7R0  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[14]       , rba, raddr[ADDR_BITS-1:0], dq [47:40], dqs[  5]      , dqs_n[  5], dqs_n[14], rodt[0]);
    ddr2 U8R0  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[15]       , rba, raddr[ADDR_BITS-1:0], dq [55:48], dqs[  6]      , dqs_n[  6], dqs_n[15], rodt[0]);
    ddr2 U9R0  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[16]       , rba, raddr[ADDR_BITS-1:0], dq [63:56], dqs[  7]      , dqs_n[  7], dqs_n[16], rodt[0]);
    `ifdef ECC                 
    ddr2 U5R0  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[17]       , rba, raddr[ADDR_BITS-1:0], rcb[ 7: 0], dqs[  8]      , dqs_n[  8], dqs_n[17], rodt[0]);
    `endif
    `ifdef DUAL_RANK
    ddr2 U1R1  (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[ 9]       , rba, raddr[ADDR_BITS-1:0], dq [ 7: 0], dqs[  0]      , dqs_n[  0], dqs_n[ 9], rodt[1]);
    ddr2 U2R1  (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[10]       , rba, raddr[ADDR_BITS-1:0], dq [15: 8], dqs[  1]      , dqs_n[  1], dqs_n[10], rodt[1]);
    ddr2 U3R1  (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[11]       , rba, raddr[ADDR_BITS-1:0], dq [23:16], dqs[  2]      , dqs_n[  2], dqs_n[11], rodt[1]);
    ddr2 U4R1  (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[12]       , rba, raddr[ADDR_BITS-1:0], dq [31:24], dqs[  3]      , dqs_n[  3], dqs_n[12], rodt[1]);
    ddr2 U6R1  (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[13]       , rba, raddr[ADDR_BITS-1:0], dq [39:32], dqs[  4]      , dqs_n[  4], dqs_n[13], rodt[1]);
    ddr2 U7R1  (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[14]       , rba, raddr[ADDR_BITS-1:0], dq [47:40], dqs[  5]      , dqs_n[  5], dqs_n[14], rodt[1]);
    ddr2 U8R1  (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[15]       , rba, raddr[ADDR_BITS-1:0], dq [55:48], dqs[  6]      , dqs_n[  6], dqs_n[15], rodt[1]);
    ddr2 U9R1  (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[16]       , rba, raddr[ADDR_BITS-1:0], dq [63:56], dqs[  7]      , dqs_n[  7], dqs_n[16], rodt[1]);
        `ifdef ECC            
    ddr2 U5R1  (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[17]       , rba, raddr[ADDR_BITS-1:0], rcb[ 7: 0], dqs[  8]      , dqs_n[  8], dqs_n[17], rodt[1]);
        `endif
    `endif
    `ifdef QUAD_RANK
    ddr2 U1R2  (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[ 9]       , rba, raddr[ADDR_BITS-1:0], dq [ 7: 0], dqs[  0]      , dqs_n[  0], dqs_n[ 9], rodt[2]);
    ddr2 U2R2  (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[10]       , rba, raddr[ADDR_BITS-1:0], dq [15: 8], dqs[  1]      , dqs_n[  1], dqs_n[10], rodt[2]);
    ddr2 U3R2  (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[11]       , rba, raddr[ADDR_BITS-1:0], dq [23:16], dqs[  2]      , dqs_n[  2], dqs_n[11], rodt[2]);
    ddr2 U4R2  (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[12]       , rba, raddr[ADDR_BITS-1:0], dq [31:24], dqs[  3]      , dqs_n[  3], dqs_n[12], rodt[2]);
    ddr2 U6R2  (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[13]       , rba, raddr[ADDR_BITS-1:0], dq [39:32], dqs[  4]      , dqs_n[  4], dqs_n[13], rodt[2]);
    ddr2 U7R2  (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[14]       , rba, raddr[ADDR_BITS-1:0], dq [47:40], dqs[  5]      , dqs_n[  5], dqs_n[14], rodt[2]);
    ddr2 U8R2  (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[15]       , rba, raddr[ADDR_BITS-1:0], dq [55:48], dqs[  6]      , dqs_n[  6], dqs_n[15], rodt[2]);
    ddr2 U9R2  (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[16]       , rba, raddr[ADDR_BITS-1:0], dq [63:56], dqs[  7]      , dqs_n[  7], dqs_n[16], rodt[2]);
        `ifdef ECC                 
    ddr2 U5R2  (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[17]       , rba, raddr[ADDR_BITS-1:0], rcb[ 7: 0], dqs[  8]      , dqs_n[  8], dqs_n[17], rodt[2]);
        `endif
    ddr2 U1R3  (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[ 9]       , rba, raddr[ADDR_BITS-1:0], dq [ 7: 0], dqs[  0]      , dqs_n[  0], dqs_n[ 9], rodt[3]);
    ddr2 U2R3  (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[10]       , rba, raddr[ADDR_BITS-1:0], dq [15: 8], dqs[  1]      , dqs_n[  1], dqs_n[10], rodt[3]);
    ddr2 U3R3  (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[11]       , rba, raddr[ADDR_BITS-1:0], dq [23:16], dqs[  2]      , dqs_n[  2], dqs_n[11], rodt[3]);
    ddr2 U4R3  (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[12]       , rba, raddr[ADDR_BITS-1:0], dq [31:24], dqs[  3]      , dqs_n[  3], dqs_n[12], rodt[3]);
    ddr2 U6R3  (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[13]       , rba, raddr[ADDR_BITS-1:0], dq [39:32], dqs[  4]      , dqs_n[  4], dqs_n[13], rodt[3]);
    ddr2 U7R3  (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[14]       , rba, raddr[ADDR_BITS-1:0], dq [47:40], dqs[  5]      , dqs_n[  5], dqs_n[14], rodt[3]);
    ddr2 U8R3  (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[15]       , rba, raddr[ADDR_BITS-1:0], dq [55:48], dqs[  6]      , dqs_n[  6], dqs_n[15], rodt[3]);
    ddr2 U9R3  (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[16]       , rba, raddr[ADDR_BITS-1:0], dq [63:56], dqs[  7]      , dqs_n[  7], dqs_n[16], rodt[3]);
        `ifdef ECC            
    ddr2 U5R3  (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[17]       , rba, raddr[ADDR_BITS-1:0], rcb[ 7: 0], dqs[  8]      , dqs_n[  8], dqs_n[17], rodt[3]);
        `endif
    `endif
`else `ifdef x16
    initial if (DEBUG) $display("%m: Component Width = x16");
    ddr2 U1R0  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[10: 9]    , rba, raddr[ADDR_BITS-1:0], dq [15: 0], dqs[1:0]      , dqs_n[1:0],          , rodt[0]);
    ddr2 U2R0  (rck[1], rck_n[1], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[12:11]    , rba, raddr[ADDR_BITS-1:0], dq [31:16], dqs[3:2]      , dqs_n[3:2],          , rodt[0]);
    ddr2 U4R0  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[14:13]    , rba, raddr[ADDR_BITS-1:0], dq [47:32], dqs[5:4]      , dqs_n[5:4],          , rodt[0]);
    ddr2 U5R0  (rck[2], rck_n[2], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, dqs[16:15]    , rba, raddr[ADDR_BITS-1:0], dq [63:48], dqs[7:6]      , dqs_n[7:6],          , rodt[0]);
    `ifdef ECC
    ddr2 U3R0  (rck[0], rck_n[0], rcke[0], rs_n[0], rras_n, rcas_n, rwe_n, {one, dqs[17]}, rba, raddr[ADDR_BITS-1:0], rcb[15: 0], {zero, dqs[8]}, {one, dqs_n[8]},     , rodt[0]);
    `endif
    `ifdef DUAL_RANK
    ddr2 U1R1  (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[10: 9]    , rba, raddr[ADDR_BITS-1:0], dq [15: 0], dqs[1:0]      , dqs_n[1:0],          , rodt[1]);
    ddr2 U2R1  (rck[4], rck_n[4], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[12:11]    , rba, raddr[ADDR_BITS-1:0], dq [31:16], dqs[3:2]      , dqs_n[3:2],          , rodt[1]);
    ddr2 U4R1  (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[14:13]    , rba, raddr[ADDR_BITS-1:0], dq [47:32], dqs[5:4]      , dqs_n[5:4],          , rodt[1]);
    ddr2 U5R1  (rck[5], rck_n[5], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, dqs[16:15]    , rba, raddr[ADDR_BITS-1:0], dq [63:48], dqs[7:6]      , dqs_n[7:6],          , rodt[1]);
        `ifdef ECC
    ddr2 U3R1  (rck[3], rck_n[3], rcke[1], rs_n[1], rras_n, rcas_n, rwe_n, {one, dqs[17]}, rba, raddr[ADDR_BITS-1:0], rcb[15: 0], {zero, dqs[8]}, {one, dqs_n[8]},     , rodt[1]);
        `endif
    `endif
    `ifdef QUAD_RANK
    ddr2 U1R2  (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[10: 9]    , rba, raddr[ADDR_BITS-1:0], dq [15: 0], dqs[1:0]      , dqs_n[1:0],          , rodt[2]);
    ddr2 U2R2  (rck[1], rck_n[1], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[12:11]    , rba, raddr[ADDR_BITS-1:0], dq [31:16], dqs[3:2]      , dqs_n[3:2],          , rodt[2]);
    ddr2 U4R2  (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[14:13]    , rba, raddr[ADDR_BITS-1:0], dq [47:32], dqs[5:4]      , dqs_n[5:4],          , rodt[2]);
    ddr2 U5R2  (rck[2], rck_n[2], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, dqs[16:15]    , rba, raddr[ADDR_BITS-1:0], dq [63:48], dqs[7:6]      , dqs_n[7:6],          , rodt[2]);
        `ifdef ECC
    ddr2 U3R2  (rck[0], rck_n[0], rcke[2], rs_n[2], rras_n, rcas_n, rwe_n, {one, dqs[17]}, rba, raddr[ADDR_BITS-1:0], rcb[15: 0], {zero, dqs[8]}, {one, dqs_n[8]},     , rodt[2]);
        `endif
    ddr2 U1R3  (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[10: 9]    , rba, raddr[ADDR_BITS-1:0], dq [15: 0], dqs[1:0]      , dqs_n[1:0],          , rodt[3]);
    ddr2 U2R3  (rck[4], rck_n[4], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[12:11]    , rba, raddr[ADDR_BITS-1:0], dq [31:16], dqs[3:2]      , dqs_n[3:2],          , rodt[3]);
    ddr2 U4R3  (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[14:13]    , rba, raddr[ADDR_BITS-1:0], dq [47:32], dqs[5:4]      , dqs_n[5:4],          , rodt[3]);
    ddr2 U5R3  (rck[5], rck_n[5], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, dqs[16:15]    , rba, raddr[ADDR_BITS-1:0], dq [63:48], dqs[7:6]      , dqs_n[7:6],          , rodt[3]);
        `ifdef ECC
    ddr2 U3R3  (rck[3], rck_n[3], rcke[3], rs_n[3], rras_n, rcas_n, rwe_n, {one, dqs[17]}, rba, raddr[ADDR_BITS-1:0], rcb[15: 0], {zero, dqs[8]}, {one, dqs_n[8]},     , rodt[3]);
        `endif
    `endif
`endif `endif `endif

endmodule

// -----------------------------------------------------------------------------
// Source file: ddr2.v
// -----------------------------------------------------------------------------
/****************************************************************************************
*
*    File Name:  ddr2.v
*      Version:  5.80
*        Model:  BUS Functional
*
* Dependencies:  ddr2_parameters.vh
*
*  Description:  Micron SDRAM DDR2 (Double Data Rate 2)
*
*   Limitation:  - doesn't check for average refresh timings
*                - positive ck and ck_n edges are used to form internal clock
*                - positive dqs and dqs_n edges are used to latch data
*                - test mode is not modeled
*
*         Note:  - Set simulator resolution to "ps" accuracy
*                - Set Debug = 0 to disable $display messages
*
*   Disclaimer   This software code and all associated documentation, comments or other 
*  of Warranty:  information (collectively "Software") is provided "AS IS" without 
*                warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
*                DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
*                TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
*                OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
*                WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
*                OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
*                FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
*                THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
*                ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
*                OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
*                ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
*                INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
*                WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
*                OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
*                THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
*                DAMAGES. Because some jurisdictions prohibit the exclusion or 
*                limitation of liability for consequential or incidental damages, the 
*                above limitation may not apply to you.
*
*                Copyright 2003 Micron Technology, Inc. All rights reserved.
*
* Rev   Author   Date        Changes
* ---------------------------------------------------------------------------------------
* 1.00  JMK      07/29/03    Initial Release
* 1.10  JMK      08/09/03    Timing Parameter updates to tIS, tIH, tDS, tDH
* 2.20  JMK      08/07/03    General cleanup
* 2.30  JMK      11/26/03    Added CL_MIN, CL_MAX, wl_min and wl_max parameters.
*                            Added AL_MIN and AL_MAX parameters.
*                            Removed support for OCD.
* 2.40  JMK      01/15/04    Removed verilog 2001 constructs.
* 2.50  JMK      01/29/04    Removed tRP checks during Precharge command.
* 2.60  JMK      04/20/04    Fixed tWTR check.
* 2.70  JMK      04/30/04    Added tRFC maximum check.
*                            Combined Self Refresh and Power Down always blocks.
*                            Added Reset Function (CKE LOW Anytime).
* 2.80  JMK      08/19/04    Precharge is treated as NOP when bank is not active.  
*                            Added checks for tRAS, tWR, tRTP to any bank during Pre-All.
*                            tRFC maximum violation will only display one time.
* 2.90  JMK      11/05/04    Fixed DQS checking during write.
*                            Fixed false tRFC max assertion during power up and self ref.
*                            Added warning for 200us CKE low time during initialization.
*                            Added -3, -3E, and -37V speed grades to ddr2_parameters.v
* 3.00  JMK      04/22/05    Removed ODT off requirement during power down.
*                            Added tAOND, tAOFD, tANPD, tAXPD, tAONPD, and tAOFPD parameters.
*                            Added ODT status messages.
*                            Updated the initialization sequence.
*                            Disable ODT and CLK pins during self refresh.
*                            Disable cmd and addr pins during power down and self refresh.
* 3.10  JMK      06/07/05    Disable trpa checking if the part does not have 8 banks.
*                            Changed tAXPD message from error to a warning.
*                            Added tDSS checking.
*                            Removed tDQSL checking during tWPRE and tWPST.
*                            Fixed a burst order error during writes.
*                            Renamed parameters file with .vh extension.
* 3.20  JMK      07/18/05    Removed 14 tCK requirement from LMR to READ.
* 3.30  JMK      08/03/05    Added check for interrupting a burst with auto precharge.
* 4.00  JMK      11/21/05    Parameter names all UPPERCASE, signal names all lowercase.
*                            Clock jitter can be tolerated within specification range.
*                            Clock frequency is sampled from the CK pin.
*                            Scaleable up to 64 DQ and 16 DQS bits.
*                            Read data can be randomly skewed using RANDOM_OUT_DELAY.
*                            Parameterized read and write DQS, and read DQ.
*                            Initialization can be bypassed using initialize task.
* 4.10  JMK      11/30/05    Fixed compile errors when `MAX_MEM was defined.
* 4.20  JMK      12/09/05    Fixed memory addressing error when `MAX_MEM was defined.
* 4.30  JMK      02/15/06    Added dummy write to initialization sequence.
*                            Removed tWPST maximum checking.
*                            Rising dqs_n edge latches data when enabled in EMR.
*                            Fixed a sign error in the tJIT(cc) calculation.
* 4.40  JMK      02/16/06    Fixed dummy write when`MAX_MEM was defined.
* 4.50  JMK      02/27/06    Fixed extra tDQSS assertions.
*                            Fixed tRCD and tWTR checking.
*                            Errors entering Power Down or Self Refresh will cause reset.
*                            Ignore dqs_n when disabled in EMR.
* 5.00  JMK      04/24/06    Test stimulus now included from external file (subtest.vh)
*                            Fixed tRFC max assertion during self refresh.
*                            Fixed tANPD checking during Power Down.
*                            Removed dummy write from initialization sequence.
* 5.01  JMK      04/28/06    Fixed Auto Precharge to Load Mode, Refresh and Self Refresh.
*                            Removed Auto Precharge error message during Power Down Enter.
* 5.10  JMK      07/26/06    Created internal clock using ck and ck_n.
*                            RDQS can only be enabled in EMR for x8 configurations.
*                            CAS latency is checked vs frequency when DLL locks.
*                            tMOD changed from tCK units to ns units.
*                            Added 50 Ohm setting for Rtt in EMR.
*                            Improved checking of DQS during writes.
* 5.20  JMK      10/02/06    Fixed DQS checking for interrupting write to write and x16.
* 5.30  JMK      05/25/07    Fixed checking for 0-Z transition on write postamble.
* 5.50  JMK      05/30/08    Renamed ddr2_dimm.v to ddr2_module.v and added SODIMM support.
*                            Added a register delay to ddr2_module.v when RDIMM is defined.
*                            Added multi-chip package model support in ddr2_mcp.v
*                            Added High Temp Self Refresh rate setting in EMRS2[7]
* 5.70  JMK      04/23/09    Updated tRPA definition
*                            Increased internal width to 72 bit DQ bus
* 5.80  SPH      08/12/09    Fixed tRAS maximum violation (only check if bank still open)
****************************************************************************************/

// DO NOT CHANGE THE TIMESCALE
// MAKE SURE YOUR SIMULATOR USES "PS" RESOLUTION
`timescale 1ps / 1ps

module ddr2 (
    ck,
    ck_n,
    cke,
    cs_n,
    ras_n,
    cas_n,
    we_n,
    dm_rdqs,
    ba,
    addr,
    dq,
    dqs,
    dqs_n,
    rdqs_n,
    odt
);

    `include "ddr2_parameters.vh"

    // text macros
    `define DQ_PER_DQS DQ_BITS/DQS_BITS
    `define BANKS      (1<<BA_BITS)
    `define MAX_BITS   (BA_BITS+ROW_BITS+COL_BITS-BL_BITS)
    `define MAX_SIZE   (1<<(BA_BITS+ROW_BITS+COL_BITS-BL_BITS))
    `define MEM_SIZE   (1<<MEM_BITS)
    `define MAX_PIPE   2*(AL_MAX + CL_MAX)

    // Declare Ports
    input   ck;
    input   ck_n;
    input   cke;
    input   cs_n;
    input   ras_n;
    input   cas_n;
    input   we_n;
    inout   [DM_BITS-1:0]   dm_rdqs;
    input   [BA_BITS-1:0]   ba;
    input   [ADDR_BITS-1:0] addr;
    inout   [DQ_BITS-1:0]   dq;
    inout   [DQS_BITS-1:0]  dqs;
    inout   [DQS_BITS-1:0]  dqs_n;
    output  [DQS_BITS-1:0]  rdqs_n;
    input   odt;
                            
    // clock jitter
    real    tck_avg;
    time    tck_sample [TDLLK-1:0];
    time    tch_sample [TDLLK-1:0];
    time    tcl_sample [TDLLK-1:0];
    time    tck_i;
    time    tch_i;
    time    tcl_i;
    real    tch_avg;
    real    tcl_avg;
    time    tm_ck_pos;
    time    tm_ck_neg;
    real    tjit_per_rtime;
    integer tjit_cc_time;
    real    terr_nper_rtime;

    // clock skew
    real    out_delay;
    integer dqsck [DQS_BITS-1:0];
    integer dqsck_min;
    integer dqsck_max;
    integer dqsq_min;
    integer dqsq_max;
    integer seed;

    // Mode Registers
    reg     burst_order;
    reg     [BL_BITS:0] burst_length;
    integer cas_latency;
    integer additive_latency;
    reg     dll_reset;
    reg     dll_locked;
    reg     dll_en;
    integer write_recovery;
    reg     low_power;
    reg     [1:0] odt_rtt;
    reg     odt_en;
    reg     [2:0] ocd;
    reg     dqs_n_en;
    reg     rdqs_en;
    reg     out_en;
    integer read_latency;
    integer write_latency;

    // cmd encoding
    parameter
        LOAD_MODE = 4'b0000,
        REFRESH   = 4'b0001,
        PRECHARGE = 4'b0010,
        ACTIVATE  = 4'b0011,
        WRITE     = 4'b0100,
        READ      = 4'b0101,
        NOP       = 4'b0111,
        PWR_DOWN  = 4'b1000,
        SELF_REF  = 4'b1001
    ;

    reg [8*9-1:0] cmd_string [9:0];
    initial begin
        cmd_string[LOAD_MODE] = "Load Mode";
        cmd_string[REFRESH  ] = "Refresh  ";
        cmd_string[PRECHARGE] = "Precharge";
        cmd_string[ACTIVATE ] = "Activate ";
        cmd_string[WRITE    ] = "Write    ";
        cmd_string[READ     ] = "Read     ";
        cmd_string[NOP      ] = "No Op    ";
        cmd_string[PWR_DOWN ] = "Pwr Down ";
        cmd_string[SELF_REF ] = "Self Ref ";
    end

    // command state
    reg     [`BANKS-1:0] active_bank;
    reg     [`BANKS-1:0] auto_precharge_bank;
    reg     [`BANKS-1:0] write_precharge_bank;
    reg     [`BANKS-1:0] read_precharge_bank;
    reg     [ROW_BITS-1:0] active_row [`BANKS-1:0];
    reg     in_power_down;
    reg     in_self_refresh;
    reg     [3:0] init_mode_reg;
    reg     init_done;
    integer init_step;
    reg     er_trfc_max;
    reg     odt_state;
    reg     prev_odt;

    // cmd timers/counters
    integer ref_cntr;
    integer ck_cntr;
    integer ck_load_mode;
    integer ck_write;
    integer ck_read;
    integer ck_write_ap;
    integer ck_power_down;
    integer ck_slow_exit_pd;
    integer ck_self_refresh;
    integer ck_cke;
    integer ck_odt;
    integer ck_dll_reset;
    integer ck_bank_write     [`BANKS-1:0];
    integer ck_bank_read      [`BANKS-1:0];
    time    tm_refresh;
    time    tm_precharge;
    time    tm_precharge_all;
    time    tm_activate;
    time    tm_write_end;
    time    tm_self_refresh;
    time    tm_odt_en;
    time    tm_bank_precharge [`BANKS-1:0];
    time    tm_bank_activate  [`BANKS-1:0];
    time    tm_bank_write_end [`BANKS-1:0];
    time    tm_bank_read_end  [`BANKS-1:0];

    // pipelines
    reg     [`MAX_PIPE:0]   al_pipeline;
    reg     [`MAX_PIPE:0]   wr_pipeline;
    reg     [`MAX_PIPE:0]   rd_pipeline;
    reg     [`MAX_PIPE:0]   odt_pipeline;
    reg     [BA_BITS-1:0]   ba_pipeline  [`MAX_PIPE:0];
    reg     [ROW_BITS-1:0]  row_pipeline [`MAX_PIPE:0];
    reg     [COL_BITS-1:0]  col_pipeline [`MAX_PIPE:0];
    reg     prev_cke;
    
    // data state
    reg     [BL_MAX*DQ_BITS-1:0] memory_data;
    reg     [BL_MAX*DQ_BITS-1:0] bit_mask;
    reg     [BL_BITS-1:0]        burst_position;
    reg     [BL_BITS:0]          burst_cntr;
    reg     [DQ_BITS-1:0]        dq_temp;
    reg     [35:0] check_write_postamble;
    reg     [35:0] check_write_preamble;
    reg     [35:0] check_write_dqs_high;
    reg     [35:0] check_write_dqs_low;
    reg     [17:0] check_dm_tdipw;
    reg     [71:0] check_dq_tdipw;

    // data timers/counters
    time    tm_cke;
    time    tm_odt;
    time    tm_tdqss;
    time    tm_dm        [17:0];
    time    tm_dqs       [17:0];
    time    tm_dqs_pos   [35:0];
    time    tm_dqss_pos  [35:0];
    time    tm_dqs_neg   [35:0];
    time    tm_dq        [71:0];
    time    tm_cmd_addr  [22:0];
    reg [8*7-1:0] cmd_addr_string [22:0];
    initial begin
        cmd_addr_string[ 0] = "CS_N   ";
        cmd_addr_string[ 1] = "RAS_N  ";
        cmd_addr_string[ 2] = "CAS_N  ";
        cmd_addr_string[ 3] = "WE_N   ";
        cmd_addr_string[ 4] = "BA 0   ";
        cmd_addr_string[ 5] = "BA 1   ";
        cmd_addr_string[ 6] = "BA 2   ";
        cmd_addr_string[ 7] = "ADDR  0";
        cmd_addr_string[ 8] = "ADDR  1";
        cmd_addr_string[ 9] = "ADDR  2";
        cmd_addr_string[10] = "ADDR  3";
        cmd_addr_string[11] = "ADDR  4";
        cmd_addr_string[12] = "ADDR  5";
        cmd_addr_string[13] = "ADDR  6";
        cmd_addr_string[14] = "ADDR  7";
        cmd_addr_string[15] = "ADDR  8";
        cmd_addr_string[16] = "ADDR  9";
        cmd_addr_string[17] = "ADDR 10";
        cmd_addr_string[18] = "ADDR 11";
        cmd_addr_string[19] = "ADDR 12";
        cmd_addr_string[20] = "ADDR 13";
        cmd_addr_string[21] = "ADDR 14";
        cmd_addr_string[22] = "ADDR 15";
    end

    reg [8*5-1:0] dqs_string [1:0];
    initial begin
        dqs_string[0] = "DQS  ";
        dqs_string[1] = "DQS_N";
    end

    // Memory Storage
`ifdef MAX_MEM
    reg     [BL_MAX*DQ_BITS-1:0] memory  [0:`MAX_SIZE-1];
`else
    reg     [BL_MAX*DQ_BITS-1:0] memory  [0:`MEM_SIZE-1];
    reg     [`MAX_BITS-1:0]      address [0:`MEM_SIZE-1];
    reg     [MEM_BITS:0]         memory_index;
    reg     [MEM_BITS:0]         memory_used;
`endif

    // receive
    reg            ck_in;
    reg            ck_n_in;
    reg            cke_in;
    reg            cs_n_in;
    reg            ras_n_in;
    reg            cas_n_in;
    reg            we_n_in;
    reg     [17:0] dm_in;
    reg     [2:0]  ba_in;
    reg     [15:0] addr_in;
    reg     [71:0] dq_in;
    reg     [35:0] dqs_in;
    reg            odt_in;

    reg     [17:0] dm_in_pos;
    reg     [17:0] dm_in_neg;
    reg     [71:0] dq_in_pos;
    reg     [71:0] dq_in_neg;
    reg            dq_in_valid;
    reg            dqs_in_valid;
    integer        wdqs_cntr;
    integer        wdq_cntr;
    integer        wdqs_pos_cntr [35:0];
    reg            b2b_write;
    reg     [35:0] prev_dqs_in;
    reg            diff_ck;

    always @(ck     ) ck_in     <= #BUS_DELAY ck;
    always @(ck_n   ) ck_n_in   <= #BUS_DELAY ck_n;
    always @(cke    ) cke_in    <= #BUS_DELAY cke;
    always @(cs_n   ) cs_n_in   <= #BUS_DELAY cs_n;
    always @(ras_n  ) ras_n_in  <= #BUS_DELAY ras_n;
    always @(cas_n  ) cas_n_in  <= #BUS_DELAY cas_n;
    always @(we_n   ) we_n_in   <= #BUS_DELAY we_n;
    always @(dm_rdqs) dm_in     <= #BUS_DELAY dm_rdqs;
    always @(ba     ) ba_in     <= #BUS_DELAY ba;
    always @(addr   ) addr_in   <= #BUS_DELAY addr;
    always @(dq     ) dq_in     <= #BUS_DELAY dq;
    always @(dqs or dqs_n) dqs_in <= #BUS_DELAY (dqs_n<<18) | dqs;
    always @(odt    ) odt_in    <= #BUS_DELAY odt;
    // create internal clock
    always @(posedge ck_in)   diff_ck <= ck_in;
    always @(posedge ck_n_in) diff_ck <= ~ck_n_in;

    wire    [17:0] dqs_even = dqs_in[17:0];
    wire    [17:0] dqs_odd  = dqs_n_en ? dqs_in[35:18] : ~dqs_in[17:0];
    wire    [3:0]  cmd_n_in = !cs_n_in ? {ras_n_in, cas_n_in, we_n_in} : NOP;  //deselect = nop 

    // transmit
    reg                    dqs_out_en;
    reg     [DQS_BITS-1:0] dqs_out_en_dly;
    reg                    dqs_out;
    reg     [DQS_BITS-1:0] dqs_out_dly;
    reg                    dq_out_en;
    reg     [DQ_BITS-1:0]  dq_out_en_dly;
    reg     [DQ_BITS-1:0]  dq_out;
    reg     [DQ_BITS-1:0]  dq_out_dly;
    integer                rdqsen_cntr;
    integer                rdqs_cntr;
    integer                rdqen_cntr;
    integer                rdq_cntr;

    bufif1 buf_dqs    [DQS_BITS-1:0] (dqs,     dqs_out_dly,  dqs_out_en_dly & {DQS_BITS{out_en}});
    bufif1 buf_dm     [DM_BITS-1:0]  (dm_rdqs, dqs_out_dly,  dqs_out_en_dly & {DM_BITS {out_en}} & {DM_BITS{rdqs_en}});
    bufif1 buf_dqs_n  [DQS_BITS-1:0] (dqs_n,   ~dqs_out_dly, dqs_out_en_dly & {DQS_BITS{out_en}} & {DQS_BITS{dqs_n_en}});
    bufif1 buf_rdqs_n [DQS_BITS-1:0] (rdqs_n,  ~dqs_out_dly, dqs_out_en_dly & {DQS_BITS{out_en}} & {DQS_BITS{dqs_n_en}} & {DQS_BITS{rdqs_en}});
    bufif1 buf_dq     [DQ_BITS-1:0]  (dq,      dq_out_dly,   dq_out_en_dly  & {DQ_BITS {out_en}});

    initial begin
        if (BL_MAX < 2) 
            $display("%m ERROR: BL_MAX parameter must be >= 2.  \nBL_MAX = %d", BL_MAX);
        if ((1<<BO_BITS) > BL_MAX) 
            $display("%m ERROR: 2^BO_BITS cannot be greater than BL_MAX parameter.");
        $timeformat (-12, 1, " ps", 1);
        reset_task;
        seed = RANDOM_SEED;
        ck_cntr = 0;
    end

    // calculate the absolute value of a real number
    function real abs_value;
    input arg;
    real arg;
    begin
        if (arg < 0.0)
            abs_value = -1.0 * arg;
        else
            abs_value = arg;
    end
    endfunction

`ifdef MAX_MEM
`else
    function get_index;
        input [`MAX_BITS-1:0] addr;
        begin : index
            get_index = 0;
            for (memory_index=0; memory_index<memory_used; memory_index=memory_index+1) begin
                if (address[memory_index] == addr) begin
                    get_index = 1;
                    disable index;
                end
            end
        end
    endfunction
`endif

    task memory_write;
        input  [BA_BITS-1:0]  bank;
        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;
        input  [BL_MAX*DQ_BITS-1:0] data;
        reg    [`MAX_BITS-1:0] addr;
        begin
            // chop off the lowest address bits
            addr = {bank, row, col}/BL_MAX;
`ifdef MAX_MEM
            memory[addr] = data;
`else
            if (get_index(addr)) begin
                address[memory_index] = addr;
                memory[memory_index] = data;
            end else if (memory_used == `MEM_SIZE) begin
                $display ("%m: at time %t ERROR: Memory overflow.  Write to Address %h with Data %h will be lost.\nYou must increase the MEM_BITS parameter or define MAX_MEM.", $time, addr, data);
                if (STOP_ON_ERROR) $stop(0);
            end else begin
                address[memory_used] = addr;
                memory[memory_used] = data;
                memory_used = memory_used + 1;
            end
`endif
        end
    endtask

    task memory_read;
        input  [BA_BITS-1:0]  bank;
        input  [ROW_BITS-1:0] row;
        input  [COL_BITS-1:0] col;
        output [BL_MAX*DQ_BITS-1:0] data;
        reg    [`MAX_BITS-1:0] addr;
        begin
            // chop off the lowest address bits
            addr = {bank, row, col}/BL_MAX;
`ifdef MAX_MEM
            data = memory[addr];
`else
            if (get_index(addr)) begin
                data = memory[memory_index];
            end else begin
                data = {BL_MAX*DQ_BITS{1'bx}};
            end
`endif
        end
    endtask

    // Before this task runs, the model must be in a valid state for precharge power down.
    // After this task runs, NOP commands must be issued until tRFC has been met
    task initialize;
        input [ADDR_BITS-1:0] mode_reg0;
        input [ADDR_BITS-1:0] mode_reg1;
        input [ADDR_BITS-1:0] mode_reg2;
        input [ADDR_BITS-1:0] mode_reg3;
        begin
            if (DEBUG) $display ("%m: at time %t INFO: Performing Initialization Sequence", $time);
            cmd_task(1,       NOP, 'bx, 'bx);
            cmd_task(1, PRECHARGE, 'bx, 1<<AP);           // Precharege ALL
            cmd_task(1, LOAD_MODE, 3, mode_reg3);
            cmd_task(1, LOAD_MODE, 2, mode_reg2);
            cmd_task(1, LOAD_MODE, 1, mode_reg1);
            cmd_task(1, LOAD_MODE, 0, mode_reg0 | 'h100); // DLL Reset
            cmd_task(1, PRECHARGE, 'bx, 1<<AP);           // Precharege ALL
            cmd_task(1,   REFRESH, 'bx, 'bx);
            cmd_task(1,   REFRESH, 'bx, 'bx);
            cmd_task(1, LOAD_MODE, 0, mode_reg0);
            cmd_task(1, LOAD_MODE, 1, mode_reg1 | 'h380); // OCD Default
            cmd_task(1, LOAD_MODE, 1, mode_reg1);
            cmd_task(0,       NOP, 'bx, 'bx);
        end
    endtask
    
    task reset_task;
        integer i;
        begin
            // disable inputs
            dq_in_valid          = 0;
            dqs_in_valid        <= 0;
            wdqs_cntr            = 0;
            wdq_cntr             = 0;
            for (i=0; i<36; i=i+1) begin
                wdqs_pos_cntr[i]    <= 0;
            end
            b2b_write           <= 0;
            // disable outputs
            out_en               = 0;
            dqs_n_en             = 0;
            rdqs_en              = 0;
            dq_out_en            = 0;
            rdq_cntr             = 0;
            dqs_out_en           = 0;
            rdqs_cntr            = 0;
            // disable ODT
            odt_en               = 0;
            odt_state            = 0;
            // reset bank state
            active_bank          = {`BANKS{1'b1}};
            auto_precharge_bank  = 0;
	        read_precharge_bank  = 0;
	        write_precharge_bank = 0;
            // require initialization sequence
            init_done            = 0;
            init_step            = 0;
            init_mode_reg        = 0;
            // reset DLL
            dll_en               = 0;
            dll_reset            = 0;
            dll_locked           = 0;
            ocd                  = 0;
            // exit power down and self refresh
            in_power_down        = 0;
            in_self_refresh      = 0;
            // clear pipelines
            al_pipeline          = 0;
            wr_pipeline          = 0;
            rd_pipeline          = 0;
            odt_pipeline         = 0;
            // clear memory
`ifdef MAX_MEM
            for (i=0; i<=`MAX_SIZE; i=i+1) begin //erase memory ... one address at a time
                memory[i] <= 'bx;
            end
`else
            memory_used <= 0; //erase memory
`endif
            // clear maximum timing checks
            tm_refresh <= 'bx;
            for (i=0; i<`BANKS; i=i+1) begin
                tm_bank_activate[i] <= 'bx;
            end
        end
    endtask

    task chk_err;
        input samebank;
        input [BA_BITS-1:0] bank;
        input [3:0] fromcmd;
        input [3:0] cmd;
        reg err;
    begin
        // all matching case expressions will be evaluated
        casex ({samebank, fromcmd, cmd})
            {1'b0, LOAD_MODE, 4'b0xxx  } : begin if (ck_cntr - ck_load_mode < TMRD)                                                                                       $display ("%m: at time %t ERROR:  tMRD violation during %s", $time, cmd_string[cmd]);                         end
            {1'b0, LOAD_MODE, 4'b100x  } : begin if (ck_cntr - ck_load_mode < TMRD)                                                                                 begin $display ("%m: at time %t INFO: Load Mode to Reset condition.", $time);                    init_done = 0; end end
            {1'b0, REFRESH  , 4'b0xxx  } : begin if ($time - tm_refresh < TRFC_MIN)                                                                                       $display ("%m: at time %t ERROR:  tRFC violation during %s", $time, cmd_string[cmd]);                         end
            {1'b0, REFRESH  , PWR_DOWN } : ; // 1 tCK
            {1'b0, REFRESH  , SELF_REF } : begin if ($time - tm_refresh < TRFC_MIN)                                                                                 begin $display ("%m: at time %t INFO: Refresh to Reset condition", $time);                       init_done = 0; end end
            {1'b0, PRECHARGE, 4'b000x  } : begin if ($time - tm_precharge_all < TRPA)                                                                                     $display ("%m: at time %t ERROR:  tRPA violation during %s", $time, cmd_string[cmd]);
                                                 if ($time - tm_precharge < TRP)                                                                                          $display ("%m: at time %t ERROR:   tRP violation during %s", $time, cmd_string[cmd]);                         end
            {1'b1, PRECHARGE, PRECHARGE} : begin if (DEBUG && ($time - tm_precharge_all < TRPA))                                                                          $display ("%m: at time %t INFO: Precharge All interruption during %s", $time, cmd_string[cmd]);
                                                 if (DEBUG && ($time - tm_bank_precharge[bank] < TRP))                                                                    $display ("%m: at time %t INFO: Precharge bank %d interruption during %s", $time, cmd_string[cmd], bank);  end
            {1'b1, PRECHARGE, ACTIVATE } : begin if ($time - tm_precharge_all < TRPA)                                                                                     $display ("%m: at time %t ERROR:  tRPA violation during %s", $time, cmd_string[cmd]);
                                                 if ($time - tm_bank_precharge[bank] < TRP)                                                                               $display ("%m: at time %t ERROR:   tRP violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b0, PRECHARGE, PWR_DOWN } : ; //1 tCK, can be concurrent with auto precharge
            {1'b0, PRECHARGE, SELF_REF } : begin if (($time - tm_precharge_all < TRPA) || ($time - tm_precharge < TRP))                                             begin $display ("%m: at time %t INFO: Precharge to Reset condition", $time);                     init_done = 0; end end
            {1'b0, ACTIVATE , REFRESH  } : begin if ($time - tm_activate < TRC)                                                                                           $display ("%m: at time %t ERROR:   tRC violation during %s", $time, cmd_string[cmd]);                         end
            {1'b1, ACTIVATE , PRECHARGE} : begin if (($time - tm_bank_activate[bank] > TRAS_MAX) && (active_bank[bank] === 1'b1))                                         $display ("%m: at time %t ERROR:  tRAS maximum violation during %s to bank %d", $time, cmd_string[cmd], bank);
                                                 if ($time - tm_bank_activate[bank] < TRAS_MIN)                                                                           $display ("%m: at time %t ERROR:  tRAS minimum violation during %s to bank %d", $time, cmd_string[cmd], bank);end
            {1'b0, ACTIVATE , ACTIVATE } : begin if ($time - tm_activate < TRRD)                                                                                          $display ("%m: at time %t ERROR:  tRRD violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b1, ACTIVATE , ACTIVATE } : begin if ($time - tm_bank_activate[bank] < TRC)                                                                                $display ("%m: at time %t ERROR:   tRC violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b1, ACTIVATE , 4'b010x  } : ; // tRCD is checked outside this task
            {1'b1, ACTIVATE , PWR_DOWN } : ; // 1 tCK
            {1'b1, WRITE    , PRECHARGE} : begin if ((ck_cntr - ck_bank_write[bank] <= write_latency + burst_length/2) || ($time - tm_bank_write_end[bank] < TWR))        $display ("%m: at time %t ERROR:   tWR violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b0, WRITE    , WRITE    } : begin if (ck_cntr - ck_write < TCCD)                                                                                           $display ("%m: at time %t ERROR:  tCCD violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b0, WRITE    , READ     } : begin if ((ck_load_mode < ck_write) && (ck_cntr - ck_write < write_latency + burst_length/2 + 2 - additive_latency))           $display ("%m: at time %t ERROR:  tWTR violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b0, WRITE    , PWR_DOWN } : begin if ((ck_load_mode < ck_write) && (
                                                    |write_precharge_bank
                                                 || (ck_cntr - ck_write_ap < 1)
                                                 || (ck_cntr - ck_write < write_latency + burst_length/2 + 2) 
                                                 || ($time - tm_write_end < TWTR)))                                                                                 begin $display ("%m: at time %t INFO: Write to Reset condition", $time);                         init_done = 0; end end
            {1'b1, READ     , PRECHARGE} : begin if ((ck_cntr - ck_bank_read[bank] < additive_latency + burst_length/2) || ($time - tm_bank_read_end[bank] < TRTP))       $display ("%m: at time %t ERROR:  tRTP violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b0, READ     , WRITE    } : begin if ((ck_load_mode < ck_read) && (ck_cntr - ck_read < read_latency + burst_length/2 + 1 - write_latency))                 $display ("%m: at time %t ERROR:  tRTW violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b0, READ     , READ     } : begin if (ck_cntr - ck_read < TCCD)                                                                                            $display ("%m: at time %t ERROR:  tCCD violation during %s to bank %d", $time, cmd_string[cmd], bank);        end
            {1'b0, READ     , PWR_DOWN } : begin if ((ck_load_mode < ck_read) && (ck_cntr - ck_read < read_latency + burst_length/2 + 1))                           begin $display ("%m: at time %t INFO: Read to Reset condition", $time);                          init_done = 0; end end
            {1'b0, PWR_DOWN , 4'b00xx  } : begin if (ck_cntr - ck_power_down < TXP)                                                                                       $display ("%m: at time %t ERROR:   tXP violation during %s", $time, cmd_string[cmd]);                         end
            {1'b0, PWR_DOWN , WRITE    } : begin if (ck_cntr - ck_power_down < TXP)                                                                                       $display ("%m: at time %t ERROR:   tXP violation during %s", $time, cmd_string[cmd]);                         end
            {1'b0, PWR_DOWN , READ     } : begin if (ck_cntr - ck_slow_exit_pd < TXARDS - additive_latency)                                                               $display ("%m: at time %t ERROR: tXARDS violation during %s", $time, cmd_string[cmd]);
                                            else if (ck_cntr - ck_power_down < TXARD)                                                                                     $display ("%m: at time %t ERROR: tXARD violation during %s", $time, cmd_string[cmd]);                         end
            {1'b0, SELF_REF , 4'b00xx  } : begin if ($time - tm_self_refresh < TXSNR)                                                                                     $display ("%m: at time %t ERROR: tXSNR violation during %s", $time, cmd_string[cmd]);                         end
            {1'b0, SELF_REF , WRITE    } : begin if ($time - tm_self_refresh < TXSNR)                                                                                     $display ("%m: at time %t ERROR: tXSNR violation during %s", $time, cmd_string[cmd]);                         end
            {1'b0, SELF_REF , READ     } : begin if (ck_cntr - ck_self_refresh < TXSRD)                                                                                   $display ("%m: at time %t ERROR: tXSRD violation during %s", $time, cmd_string[cmd]);                         end
            {1'b0, 4'b100x  , 4'b100x  } : begin if (ck_cntr - ck_cke < TCKE)                                                                                       begin $display ("%m: at time %t ERROR:  tCKE violation on CKE", $time);                          init_done = 0; end end
        endcase
    end
    endtask

    task cmd_task;
        input cke;
        input [2:0] cmd;
        input [BA_BITS-1:0] bank;
        input [ADDR_BITS-1:0] addr;
        reg [`BANKS:0] i;
        integer j;
        reg [`BANKS:0] tfaw_cntr;
        reg [COL_BITS-1:0] col;
        begin

            // tRFC max check
            if (!er_trfc_max && !in_self_refresh) begin
                if ($time - tm_refresh > TRFC_MAX) begin
                    $display ("%m: at time %t ERROR:  tRFC maximum violation during %s", $time, cmd_string[cmd]);
                    er_trfc_max = 1;
                end
            end
            if (cke) begin
                if ((cmd < NOP) && ((cmd != PRECHARGE) || !addr[AP])) begin
                    for (j=0; j<NOP; j=j+1) begin
                        chk_err(1'b0, bank, j, cmd);
                        chk_err(1'b1, bank, j, cmd);
                    end
                    chk_err(1'b0, bank, PWR_DOWN, cmd);
                    chk_err(1'b0, bank, SELF_REF, cmd);
                end

                case (cmd)
                    LOAD_MODE : begin
                        if (|active_bank) begin
                            $display ("%m: at time %t ERROR: %s Failure.  All banks must be Precharged.", $time, cmd_string[cmd]);
                            if (STOP_ON_ERROR) $stop(0);
                        end else begin
                            if (DEBUG) $display ("%m: at time %t INFO: %s %d", $time, cmd_string[cmd], bank);
                            case (bank)
                                0 : begin
                                    // Burst Length
                                    burst_length = 1<<addr[2:0];
                                    if ((burst_length >= BL_MIN) && (burst_length <= BL_MAX)) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Burst Length = %d", $time, cmd_string[cmd], bank, burst_length);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal Burst Length = %d", $time, cmd_string[cmd], bank, burst_length);
                                    end
                                    // Burst Order
                                    burst_order = addr[3];
                                    if (!burst_order) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Burst Order = Sequential", $time, cmd_string[cmd], bank);
                                    end else if (burst_order) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Burst Order = Interleaved", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal Burst Order = %d", $time, cmd_string[cmd], bank, burst_order);
                                    end
                                    // CAS Latency
                                    cas_latency = addr[6:4];
                                    read_latency = cas_latency + additive_latency;
                                    write_latency = read_latency - 1;
                                    if ((cas_latency >= CL_MIN) && (cas_latency <= CL_MAX)) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d CAS Latency = %d", $time, cmd_string[cmd], bank, cas_latency);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal CAS Latency = %d", $time, cmd_string[cmd], bank, cas_latency);
                                    end
                                    // Test Mode
                                    if (!addr[7]) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Test Mode = Normal", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal Test Mode = %d", $time, cmd_string[cmd], bank, addr[7]);
                                    end
                                    // DLL Reset
                                    dll_reset = addr[8];
                                    if (!dll_reset) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d DLL Reset = Normal", $time, cmd_string[cmd], bank);
                                    end else if (dll_reset) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d DLL Reset = Reset DLL", $time, cmd_string[cmd], bank);
                                        dll_locked = 0;
                                        ck_dll_reset <= ck_cntr;
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal DLL Reset = %d", $time, cmd_string[cmd], bank, dll_reset);
                                    end
                                    // Write Recovery
                                    write_recovery  = addr[11:9] + 1;
                                    if ((write_recovery >= WR_MIN) && (write_recovery <= WR_MAX)) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Write Recovery = %d", $time, cmd_string[cmd], bank, write_recovery);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal Write Recovery = %d", $time, cmd_string[cmd], bank, write_recovery);
                                    end
                                    // Power Down Mode
                                    low_power = addr[12];
                                    if (!low_power) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Power Down Mode = Fast Exit", $time, cmd_string[cmd], bank);
                                    end else if (low_power) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Power Down Mode = Slow Exit", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal Power Down Mode = %d", $time, cmd_string[cmd], bank, low_power);
                                    end
                                end
                                1 : begin
                                    // DLL Enable
                                    dll_en = !addr[0];
                                    if (!dll_en) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d DLL Enable = Disabled", $time, cmd_string[cmd], bank);
                                    end else if (dll_en) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d DLL Enable = Enabled", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal DLL Enable = %d", $time, cmd_string[cmd], bank, dll_en);
                                    end
                                    // Output Drive Strength
                                    if (!addr[1]) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Output Drive Strength = Full", $time, cmd_string[cmd], bank);
                                    end else if (addr[1]) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Output Drive Strength = Reduced", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal Output Drive Strength = %d", $time, cmd_string[cmd], bank, addr[1]);
                                    end
                                    // ODT Rtt
                                    odt_rtt = {addr[6], addr[2]};
                                    if (odt_rtt == 2'b00) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d ODT Rtt = Disabled", $time, cmd_string[cmd], bank);
                                        odt_en = 0;
                                    end else if (odt_rtt == 2'b01) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d ODT Rtt = 75 Ohm", $time, cmd_string[cmd], bank);
                                        odt_en = 1;
                                        tm_odt_en <= $time;
                                    end else if (odt_rtt == 2'b10) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d ODT Rtt = 150 Ohm", $time, cmd_string[cmd], bank);
                                        odt_en = 1;
                                        tm_odt_en <= $time;
                                    end else if (odt_rtt == 2'b11) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d ODT Rtt = 50 Ohm", $time, cmd_string[cmd], bank);
                                        odt_en = 1;
                                        tm_odt_en <= $time;
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal ODT Rtt = %d", $time, cmd_string[cmd], bank, odt_rtt);
                                        odt_en = 0;
                                    end
                                    // Additive Latency
                                    additive_latency = addr[5:3];
                                    read_latency = cas_latency + additive_latency;
                                    write_latency = read_latency - 1;
                                    if ((additive_latency >= AL_MIN) && (additive_latency <= AL_MAX)) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Additive Latency = %d", $time, cmd_string[cmd], bank, additive_latency);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal Additive Latency = %d", $time, cmd_string[cmd], bank, additive_latency);
                                    end
                                    // OCD Program
                                    ocd = addr[9:7];
                                    if (ocd == 3'b000) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d OCD Program = OCD Exit", $time, cmd_string[cmd], bank);
                                    end else if (ocd == 3'b111) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d OCD Program = OCD Default", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal OCD Program = %b", $time, cmd_string[cmd], bank, ocd);
                                    end

                                    // DQS_N Enable
                                    dqs_n_en = !addr[10];
                                    if (!dqs_n_en) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d DQS_N Enable = Disabled", $time, cmd_string[cmd], bank);
                                    end else if (dqs_n_en) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d DQS_N Enable = Enabled", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal DQS_N Enable = %d", $time, cmd_string[cmd], bank, dqs_n_en);
                                    end 
                                    // RDQS Enable
                                    rdqs_en = addr[11];
                                    if (!rdqs_en) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d RDQS Enable = Disabled", $time, cmd_string[cmd], bank);
                                    end else if (rdqs_en) begin
`ifdef x8
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d RDQS Enable = Enabled", $time, cmd_string[cmd], bank);
`else
                                        $display ("%m: at time %t WARNING: %s %d Illegal RDQS Enable.  RDQS only exists on a x8 part", $time, cmd_string[cmd], bank);
                                        rdqs_en = 0;
`endif
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal RDQS Enable = %d", $time, cmd_string[cmd], bank, rdqs_en);
                                    end 
                                    // Output Enable
                                    out_en = !addr[12];
                                    if (!out_en) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Output Enable = Disabled", $time, cmd_string[cmd], bank);
                                    end else if (out_en) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d Output Enable = Enabled", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal Output Enable = %d", $time, cmd_string[cmd], bank, out_en);
                                    end 
                                end
                                2 : begin
                                    // High Temperature Self Refresh rate
                                    if (!addr[7]) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d High Temperature Self Refresh rate = Disabled", $time, cmd_string[cmd], bank);
                                    end else if (addr[1]) begin
                                        if (DEBUG) $display ("%m: at time %t INFO: %s %d High Temperature Self Refresh rate = Enabled", $time, cmd_string[cmd], bank);
                                    end else begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal High Temperature Self Refresh rate = %d", $time, cmd_string[cmd], bank, addr[7]);
                                    end
                                    if ((addr & ~(1<<7)) !== 0) begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal value.  Reserved bits must be programmed to zero", $time, cmd_string[cmd], bank);
                                    end
                                end
                                3 : begin
                                    if (addr !== 0) begin
                                        $display ("%m: at time %t ERROR: %s %d Illegal value.  Reserved bits must be programmed to zero", $time, cmd_string[cmd], bank);
                                    end
                                end
                            endcase
                            init_mode_reg[bank] = 1;
                            ck_load_mode <= ck_cntr;
                        end
                    end
                    REFRESH : begin
                        if (|active_bank) begin
                            $display ("%m: at time %t ERROR: %s Failure.  All banks must be Precharged.", $time, cmd_string[cmd]);
                            if (STOP_ON_ERROR) $stop(0);
                        end else begin
                            if (DEBUG) $display ("%m: at time %t INFO: %s", $time, cmd_string[cmd]);
                            er_trfc_max = 0;
                            ref_cntr = ref_cntr + 1;
                            tm_refresh <= $time;
                        end
                    end
                    PRECHARGE : begin
                        if (addr[AP]) begin
                            // tRPA timing applies when the PRECHARGE (ALL) command is issued, regardless of
                            // the number of banks already open or closed.
                            for (i=0; i<`BANKS; i=i+1) begin
                                for (j=0; j<NOP; j=j+1) begin
                                    chk_err(1'b0, i, j, cmd);
                                    chk_err(1'b1, i, j, cmd);
                                end
                                chk_err(1'b0, i, PWR_DOWN, cmd);
                                chk_err(1'b0, i, SELF_REF, cmd);
                            end
                            if (|auto_precharge_bank) begin
                                $display ("%m: at time %t ERROR: %s All Failure.  Auto Precharge is scheduled.", $time, cmd_string[cmd]);
                                if (STOP_ON_ERROR) $stop(0);
                            end else begin
                                if (DEBUG) $display ("%m: at time %t INFO: %s All", $time, cmd_string[cmd]);
                                active_bank = 0;
                                tm_precharge_all <= $time;
                            end
                        end else begin
                            // A PRECHARGE command is allowed if there is no open row in that bank (idle state) 
                            // or if the previously open row is already in the process of precharging. 
                            // However, the precharge period will be determined by the last PRECHARGE command issued to the bank.
                            if (auto_precharge_bank[bank]) begin
                                $display ("%m: at time %t ERROR: %s Failure.  Auto Precharge is scheduled to bank %d.", $time, cmd_string[cmd], bank);
                                if (STOP_ON_ERROR) $stop(0);
                            end else begin
                                if (DEBUG) $display ("%m: at time %t INFO: %s bank %d", $time, cmd_string[cmd], bank);
                                active_bank[bank] = 1'b0;
                                tm_bank_precharge[bank] <= $time;
                                tm_precharge <= $time;
                            end
                        end
                    end
                    ACTIVATE : begin
                        if (`BANKS == 8) begin
                            tfaw_cntr = 0;
                            for (i=0; i<`BANKS; i=i+1) begin
                                if ($time - tm_bank_activate[i] < TFAW) begin
                                    tfaw_cntr = tfaw_cntr + 1;
                                end
                            end
                            if (tfaw_cntr > 3) begin
                                $display ("%m: at time %t ERROR:  tFAW violation during %s to bank %d", $time, cmd_string[cmd], bank);
                            end
                        end

                        if (!init_done) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Initialization sequence is not complete.", $time, cmd_string[cmd]);
                            if (STOP_ON_ERROR) $stop(0);
                        end else if (active_bank[bank]) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Bank %d must be Precharged.", $time, cmd_string[cmd], bank);
                            if (STOP_ON_ERROR) $stop(0);
                        end else begin
                            if (addr >= 1<<ROW_BITS) begin
                                $display ("%m: at time %t WARNING: row = %h does not exist.  Maximum row = %h", $time, addr, (1<<ROW_BITS)-1);
                            end
                            if (DEBUG) $display ("%m: at time %t INFO: %s bank %d row %h", $time, cmd_string[cmd], bank, addr);
                            active_bank[bank] = 1'b1;
                            active_row[bank] = addr;
                            tm_bank_activate[bank] <= $time;
                            tm_activate <= $time;
                        end
                        
                    end
                    WRITE : begin
                        if (!init_done) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Initialization sequence is not complete.", $time, cmd_string[cmd]);
                            if (STOP_ON_ERROR) $stop(0);
                        end else if (!active_bank[bank]) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Bank %d must be Activated.", $time, cmd_string[cmd], bank);
                            if (STOP_ON_ERROR) $stop(0);
                        end else if (auto_precharge_bank[bank]) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Auto Precharge is scheduled to bank %d.", $time, cmd_string[cmd], bank);
                            if (STOP_ON_ERROR) $stop(0);
                        end else if ((ck_cntr - ck_write < burst_length/2) && (ck_cntr - ck_write)%2) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Illegal burst interruption.", $time, cmd_string[cmd]);
                            if (STOP_ON_ERROR) $stop(0);
                        end else begin
                            if (addr[AP]) begin
                                auto_precharge_bank[bank] = 1'b1;
                                write_precharge_bank[bank] = 1'b1;
                            end
                            col = ((addr>>1) & -1*(1<<AP)) | (addr & {AP{1'b1}});
                            if (col >= 1<<COL_BITS) begin
                                $display ("%m: at time %t WARNING: col = %h does not exist.  Maximum col = %h", $time, col, (1<<COL_BITS)-1);
                            end
                            if (DEBUG) $display ("%m: at time %t INFO: %s bank %d col %h, auto precharge %d", $time, cmd_string[cmd], bank, col, addr[AP]);
                            wr_pipeline[2*write_latency + 1]  = 1;
                            ba_pipeline[2*write_latency + 1]  = bank;
                            row_pipeline[2*write_latency + 1] = active_row[bank];
                            col_pipeline[2*write_latency + 1] = col;
                            ck_bank_write[bank] <= ck_cntr;
                            ck_write <= ck_cntr;
                        end
                    end
                    READ : begin
                        if (!dll_locked)
                            $display ("%m: at time %t WARNING: %s prior to DLL locked.  Failing to wait for synchronization to occur may result in a violation of the tAC or tDQSCK parameters.", $time, cmd_string[cmd]);
                        if (!init_done) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Initialization sequence is not complete.", $time, cmd_string[cmd]);
                            if (STOP_ON_ERROR) $stop(0);
                        end else if (!active_bank[bank]) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Bank %d must be Activated.", $time, cmd_string[cmd], bank);
                            if (STOP_ON_ERROR) $stop(0);
                        end else if (auto_precharge_bank[bank]) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Auto Precharge is scheduled to bank %d.", $time, cmd_string[cmd], bank);
                            if (STOP_ON_ERROR) $stop(0);
                        end else if ((ck_cntr - ck_read < burst_length/2) && (ck_cntr - ck_read)%2) begin
                            $display ("%m: at time %t ERROR: %s Failure.  Illegal burst interruption.", $time, cmd_string[cmd]);
                            if (STOP_ON_ERROR) $stop(0);
                        end else begin
                            if (addr[AP]) begin
                                auto_precharge_bank[bank] = 1'b1;
                                read_precharge_bank[bank] = 1'b1;
                            end
                            col = ((addr>>1) & -1*(1<<AP)) | (addr & {AP{1'b1}});
                            if (col >= 1<<COL_BITS) begin
                                $display ("%m: at time %t WARNING: col = %h does not exist.  Maximum col = %h", $time, col, (1<<COL_BITS)-1);
                            end
                            if (DEBUG) $display ("%m: at time %t INFO: %s bank %d col %h, auto precharge %d", $time, cmd_string[cmd], bank, col, addr[AP]);
                            rd_pipeline[2*read_latency - 1]  = 1;
                            ba_pipeline[2*read_latency - 1]  = bank;
                            row_pipeline[2*read_latency - 1] = active_row[bank];
                            col_pipeline[2*read_latency - 1] = col;
                            ck_bank_read[bank] <= ck_cntr;
                            ck_read <= ck_cntr;
                        end
                    end
                    NOP: begin
                        if (in_power_down) begin
                            if (DEBUG) $display ("%m: at time %t INFO: Power Down Exit", $time);
                            in_power_down = 0;
                            if (|active_bank & low_power) begin // slow exit active power down
                                ck_slow_exit_pd <= ck_cntr;
                            end
                            ck_power_down <= ck_cntr;
                        end
                        if (in_self_refresh) begin
                            if ($time - tm_cke < TISXR)
                                $display ("%m: at time %t ERROR: tISXR violation during Self Refresh Exit", $time);
                            if (DEBUG) $display ("%m: at time %t INFO: Self Refresh Exit", $time);
                            in_self_refresh = 0;
                            ck_dll_reset <= ck_cntr;
                            ck_self_refresh <= ck_cntr;
                            tm_self_refresh <= $time;
                            tm_refresh <= $time;
                        end
                    end
                endcase
                if ((prev_cke !== 1) && (cmd !== NOP)) begin
                    $display ("%m: at time %t ERROR: NOP or Deselect is required when CKE goes active.", $time);
                end
                if (!init_done) begin
                    case (init_step)
                        0 : begin
                            if ($time < 200000000) 
                                $display ("%m: at time %t WARNING: 200 us is required before CKE goes active.", $time);
//                          if (cmd_chk + 200000000 > $time)
//                              $display("%m: at time %t WARNING: NOP or DESELECT is required for 200 us before CKE is brought high", $time);
                            init_step = init_step + 1;
                        end
                        1 : if (dll_en)        init_step = init_step + 1;
                        2 : begin
                            if (&init_mode_reg && dll_reset) begin
                                active_bank = {`BANKS{1'b1}};   // require Precharge All or bank Precharges
                                ref_cntr = 0;                   // require refresh
                                init_step = init_step + 1;
                            end
                        end
                        3 : if (ref_cntr == 2) begin
                            init_step = init_step + 1;
                        end
                        4 : if (!dll_reset)    init_step = init_step + 1;
                        5 : if (ocd == 3'b111) init_step = init_step + 1;
                        6 : begin
                            if (ocd == 3'b000) begin
                                if (DEBUG) $display ("%m: at time %t INFO: Initialization Sequence is complete", $time);
                                init_done = 1;
                            end
                        end
                    endcase
                end
            end else if (prev_cke) begin
                if ((!init_done) && (init_step > 1)) begin
                    $display ("%m: at time %t ERROR: CKE must remain active until the initialization sequence is complete.", $time);
                    if (STOP_ON_ERROR) $stop(0);
                end
                case (cmd)
                    REFRESH : begin
                        for (j=0; j<NOP; j=j+1) begin
                            chk_err(1'b0, bank, j, SELF_REF);
                        end
                        chk_err(1'b0, bank, PWR_DOWN, SELF_REF);
                        chk_err(1'b0, bank, SELF_REF, SELF_REF);
                        if (|active_bank) begin
                            $display ("%m: at time %t ERROR: Self Refresh Failure.  All banks must be Precharged.", $time);
                            if (STOP_ON_ERROR) $stop(0);
                            init_done = 0;
                        end else if (odt_en && odt_state) begin
                            $display ("%m: at time %t ERROR: ODT must be off prior to entering Self Refresh", $time);
                            if (STOP_ON_ERROR) $stop(0);
                            init_done = 0;
                        end else if (!init_done) begin
                            $display ("%m: at time %t ERROR: Self Refresh Failure.  Initialization sequence is not complete.", $time);
                            if (STOP_ON_ERROR) $stop(0);
                        end else begin
                            if (DEBUG) $display ("%m: at time %t INFO: Self Refresh Enter", $time);
                            in_self_refresh = 1;
                            dll_locked = 0;
                        end
                    end
                    NOP : begin
                        // entering slow_exit or precharge power down and tANPD has not been satisfied
                        if ((low_power || (active_bank == 0)) && (ck_cntr - ck_odt < TANPD))
                            $display ("%m: at time %t WARNING: tANPD violation during %s.  Synchronous or asynchronous change in termination resistance is possible.", $time, cmd_string[PWR_DOWN]);
                        for (j=0; j<NOP; j=j+1) begin
                            chk_err(1'b0, bank, j, PWR_DOWN);
                        end
                        chk_err(1'b0, bank, PWR_DOWN, PWR_DOWN);
                        chk_err(1'b0, bank, SELF_REF, PWR_DOWN);

                        if (!init_done) begin
                            $display ("%m: at time %t ERROR: Power Down Failure.  Initialization sequence is not complete.", $time);
                            if (STOP_ON_ERROR) $stop(0);
                        end else begin
                            if (DEBUG) begin
                                if (|active_bank) begin
                                    $display ("%m: at time %t INFO: Active Power Down Enter", $time);
                                end else begin
                                    $display ("%m: at time %t INFO: Precharge Power Down Enter", $time);
                                end
                            end
                            in_power_down = 1;
                        end
                    end
                    default : begin
                        $display ("%m: at time %t ERROR: NOP, Deselect, or Refresh is required when CKE goes inactive.", $time);
                        init_done = 0;
                    end
                endcase
                if (!init_done) begin
                    if (DEBUG) $display ("%m: at time %t WARNING: Reset has occurred.  Device must be re-initialized.", $time);
                    reset_task;
                end
            end
            prev_cke  = cke;
        end
    endtask

    task data_task;
        reg [BA_BITS-1:0] bank;
        reg [ROW_BITS-1:0] row;
        reg [COL_BITS-1:0] col;
        integer i;
        integer j;
        begin

            if (diff_ck) begin
                for (i=0; i<36; i=i+1) begin
                    if (dq_in_valid && dll_locked && ($time - tm_dqs_neg[i] < $rtoi(TDSS*tck_avg)))
                        $display ("%m: at time %t ERROR: tDSS violation on %s bit %d", $time, dqs_string[i/18], i%18);
                    if (check_write_dqs_high[i])
                        $display ("%m: at time %t ERROR: %s bit %d latching edge required during the preceding clock period.", $time, dqs_string[i/18], i%18);
                end
                check_write_dqs_high <= 0;
            end else begin
                for (i=0; i<36; i=i+1) begin
                    if (dll_locked && dq_in_valid) begin
                        tm_tdqss = abs_value(1.0*tm_ck_pos - tm_dqss_pos[i]);
                        if ((tm_tdqss < tck_avg/2.0) && (tm_tdqss > TDQSS*tck_avg))
                            $display ("%m: at time %t ERROR: tDQSS violation on %s bit %d", $time, dqs_string[i/18], i%18); 
                    end
                    if (check_write_dqs_low[i])
                        $display ("%m: at time %t ERROR: %s bit %d latching edge required during the preceding clock period", $time, dqs_string[i/18], i%18);
                end
                check_write_preamble <= 0;
                check_write_postamble <= 0;
                check_write_dqs_low <= 0;
            end

            if (wr_pipeline[0] || rd_pipeline[0]) begin
                bank = ba_pipeline[0];
                row = row_pipeline[0];
                col = col_pipeline[0];
                burst_cntr = 0;
                memory_read(bank, row, col, memory_data);
            end

            // burst counter
            if (burst_cntr < burst_length) begin
                burst_position = col ^ burst_cntr;
                if (!burst_order) begin
                    burst_position[BO_BITS-1:0] = col + burst_cntr;
                end
                burst_cntr = burst_cntr + 1;
            end

            // write dqs counter
            if (wr_pipeline[WDQS_PRE + 1]) begin
                wdqs_cntr = WDQS_PRE + burst_length + WDQS_PST - 1;
            end
            // write dqs
            if ((wdqs_cntr == burst_length + WDQS_PST) && (wdq_cntr == 0)) begin //write preamble
                check_write_preamble <= ({DQS_BITS{dqs_n_en}}<<18) | {DQS_BITS{1'b1}};
            end
            if (wdqs_cntr > 1) begin  // write data
                if ((wdqs_cntr - WDQS_PST)%2) begin
                    check_write_dqs_high <= ({DQS_BITS{dqs_n_en}}<<18) | {DQS_BITS{1'b1}};
                end else begin
                    check_write_dqs_low <= ({DQS_BITS{dqs_n_en}}<<18) | {DQS_BITS{1'b1}};
                end
            end
            if (wdqs_cntr == WDQS_PST) begin // write postamble
                check_write_postamble <= ({DQS_BITS{dqs_n_en}}<<18) | {DQS_BITS{1'b1}};
            end 
            if (wdqs_cntr > 0) begin
                wdqs_cntr = wdqs_cntr - 1;
            end

            // write dq
            if (dq_in_valid) begin // write data
                bit_mask = 0;
                if (diff_ck) begin
                    for (i=0; i<DM_BITS; i=i+1) begin
                        bit_mask = bit_mask | ({`DQ_PER_DQS{~dm_in_neg[i]}}<<(burst_position*DQ_BITS + i*`DQ_PER_DQS));
                    end
                    memory_data = (dq_in_neg<<(burst_position*DQ_BITS) & bit_mask) | (memory_data & ~bit_mask);
                end else begin
                    for (i=0; i<DM_BITS; i=i+1) begin
                        bit_mask = bit_mask | ({`DQ_PER_DQS{~dm_in_pos[i]}}<<(burst_position*DQ_BITS + i*`DQ_PER_DQS));
                    end
                    memory_data = (dq_in_pos<<(burst_position*DQ_BITS) & bit_mask) | (memory_data & ~bit_mask);
                end
                dq_temp = memory_data>>(burst_position*DQ_BITS);
                if (DEBUG) $display ("%m: at time %t INFO: WRITE @ DQS= bank = %h row = %h col = %h data = %h",$time, bank, row, (-1*BL_MAX & col) + burst_position, dq_temp);
                if (burst_cntr%BL_MIN == 0) begin
                    memory_write(bank, row, col, memory_data);
                end
            end
            if (wr_pipeline[1]) begin
                wdq_cntr = burst_length;
            end
            if (wdq_cntr > 0) begin
                wdq_cntr = wdq_cntr - 1;
                dq_in_valid = 1'b1;
            end else begin
                dq_in_valid = 1'b0;
                dqs_in_valid <= 1'b0;
                for (i=0; i<36; i=i+1) begin
                    wdqs_pos_cntr[i] <= 0;
                end
            end
            if (wr_pipeline[0]) begin
                b2b_write <= 1'b0;
            end
            if (wr_pipeline[2]) begin
                if (dqs_in_valid) begin
                    b2b_write <= 1'b1;
                end
                dqs_in_valid <= 1'b1;
            end
            // read dqs enable counter
            if (rd_pipeline[RDQSEN_PRE]) begin
                rdqsen_cntr = RDQSEN_PRE + burst_length + RDQSEN_PST - 1;
            end
            if (rdqsen_cntr > 0) begin
                rdqsen_cntr = rdqsen_cntr - 1;
                dqs_out_en = 1'b1;
            end else begin
                dqs_out_en = 1'b0;
            end
            
            // read dqs counter
            if (rd_pipeline[RDQS_PRE]) begin
                rdqs_cntr = RDQS_PRE + burst_length + RDQS_PST - 1;
            end
            // read dqs
            if ((rdqs_cntr >= burst_length + RDQS_PST) && (rdq_cntr == 0)) begin //read preamble
                dqs_out = 1'b0;
            end else if (rdqs_cntr > RDQS_PST) begin // read data
                dqs_out = rdqs_cntr - RDQS_PST;
            end else if (rdqs_cntr > 0) begin // read postamble
                dqs_out = 1'b0;
            end else begin
                dqs_out = 1'b1;
            end
            if (rdqs_cntr > 0) begin
                rdqs_cntr = rdqs_cntr - 1;
            end

            // read dq enable counter
            if (rd_pipeline[RDQEN_PRE]) begin
                rdqen_cntr = RDQEN_PRE + burst_length + RDQEN_PST;
            end
            if (rdqen_cntr > 0) begin
                rdqen_cntr = rdqen_cntr - 1;
                dq_out_en = 1'b1;
            end else begin
                dq_out_en = 1'b0;
            end
            // read dq
            if (rd_pipeline[0]) begin
                rdq_cntr = burst_length;
            end
            if (rdq_cntr > 0) begin // read data
                dq_temp = memory_data>>(burst_position*DQ_BITS);
                dq_out = dq_temp;
                if (DEBUG) $display ("%m: at time %t INFO: READ @ DQS= bank = %h row = %h col = %h data = %h",$time, bank, row, (-1*BL_MAX & col) + burst_position, dq_temp);
                rdq_cntr = rdq_cntr - 1;
            end else begin
                dq_out = {DQ_BITS{1'b1}};
            end

            // delay signals prior to output
            if (RANDOM_OUT_DELAY && (dqs_out_en || |dqs_out_en_dly || dq_out_en || |dq_out_en_dly)) begin
                for (i=0; i<DQS_BITS; i=i+1) begin
                    // DQSCK requirements
                    // 1.) less than tDQSCK
                    // 2.) greater than -tDQSCK
                    // 3.) cannot change more than tQHS + tDQSQ from previous DQS edge
                    dqsck_max = TDQSCK;
                    if (dqsck_max > dqsck[i] + TQHS + TDQSQ) begin
                        dqsck_max = dqsck[i] + TQHS + TDQSQ;
                    end
                    dqsck_min = -1*TDQSCK;
                    if (dqsck_min < dqsck[i] - TQHS - TDQSQ) begin
                        dqsck_min = dqsck[i] - TQHS - TDQSQ;
                    end

                    // DQSQ requirements
                    // 1.) less than tAC - DQSCK
                    // 2.) less than tDQSQ
                    // 3.) greater than -tAC
                    // 4.) greater than tQH from previous DQS edge
                    dqsq_min = -1*TAC;
                    if (dqsq_min < dqsck[i] - TQHS) begin
                        dqsq_min = dqsck[i] - TQHS;
                    end
                    if (dqsck_min == dqsck_max) begin
                        dqsck[i] = dqsck_min;
                    end else begin
                        dqsck[i] = $dist_uniform(seed, dqsck_min, dqsck_max);
                    end
                    dqsq_max = TAC;
                    if (dqsq_max > TDQSQ + dqsck[i]) begin
                        dqsq_max = TDQSQ + dqsck[i];
                    end

                    dqs_out_en_dly[i] <= #(tck_avg/2.0 + ($random % TAC)) dqs_out_en;
                    dqs_out_dly[i]    <= #(tck_avg/2.0 + dqsck[i]) dqs_out;
                    for (j=0; j<`DQ_PER_DQS; j=j+1) begin
                        if (dq_out_en) begin // tLZ2
                            dq_out_en_dly[i*`DQ_PER_DQS + j] <= #(tck_avg/2.0 + $dist_uniform(seed, -2*TAC, dqsq_max)) dq_out_en;
                        end else begin // tHZ
                            dq_out_en_dly[i*`DQ_PER_DQS + j] <= #(tck_avg/2.0 + ($random % TAC)) dq_out_en;
                        end
                        if (dqsq_min == dqsq_max) begin
                            dq_out_dly   [i*`DQ_PER_DQS + j] <= #(tck_avg/2.0 + dqsq_min) dq_out[i*`DQ_PER_DQS + j];
                        end else begin
                            dq_out_dly   [i*`DQ_PER_DQS + j] <= #(tck_avg/2.0 + $dist_uniform(seed, dqsq_min, dqsq_max)) dq_out[i*`DQ_PER_DQS + j];
                        end
                    end
                end
            end else begin
                out_delay = tck_avg/2.0;
                dqs_out_en_dly <= #(out_delay) {DQS_BITS{dqs_out_en}};
                dqs_out_dly    <= #(out_delay) {DQS_BITS{dqs_out   }};
                dq_out_en_dly  <= #(out_delay) {DQ_BITS {dq_out_en }};
                dq_out_dly     <= #(out_delay) {DQ_BITS {dq_out    }};
            end
        end
    endtask

    always @(diff_ck) begin : main
        integer i;

        if (!in_self_refresh && (diff_ck !== 1'b0) && (diff_ck !== 1'b1))
            $display ("%m: at time %t ERROR: CK and CK_N are not allowed to go to an unknown state.", $time);
        data_task;
        if (diff_ck) begin
            // check setup of command signals
            if ($time > TIS) begin
                if ($time - tm_cke < TIS) 
                    $display ("%m: at time %t ERROR:   tIS violation on CKE by %t", $time, tm_cke + TIS - $time);
                if (cke_in) begin
                    for (i=0; i<22; i=i+1) begin
                        if ($time - tm_cmd_addr[i] < TIS) 
                            $display ("%m: at time %t ERROR:   tIS violation on %s by %t", $time, cmd_addr_string[i], tm_cmd_addr[i] + TIS - $time);
                    end
                end
            end

            // update current state
            if (!dll_locked && !in_self_refresh && (ck_cntr - ck_dll_reset == TDLLK)) begin
                // check CL value against the clock frequency
                if (cas_latency*tck_avg < CL_TIME)
                    $display ("%m: at time %t ERROR: CAS Latency = %d is illegal @tCK(avg) = %f", $time, cas_latency, tck_avg);
                // check WR value against the clock frequency
                if (write_recovery*tck_avg < TWR)
                    $display ("%m: at time %t ERROR: Write Recovery = %d is illegal @tCK(avg) = %f", $time, write_recovery, tck_avg);
                dll_locked = 1;
            end
            if (|auto_precharge_bank) begin
                for (i=0; i<`BANKS; i=i+1) begin
                    // Write with Auto Precharge Calculation
                    // 1.  Meet minimum tRAS requirement
                    // 2.  Write Latency PLUS BL/2 cycles PLUS WR after Write command
                    if (write_precharge_bank[i]
                        && ($time - tm_bank_activate[i] >= TRAS_MIN)
                        && (ck_cntr - ck_bank_write[i] >= write_latency + burst_length/2 + write_recovery)) begin

                        if (DEBUG) $display ("%m: at time %t INFO: Auto Precharge bank %d", $time, i);
                        write_precharge_bank[i] = 0;
                        active_bank[i] = 0;
                        auto_precharge_bank[i] = 0;
                        ck_write_ap = ck_cntr;
                        tm_bank_precharge[i] = $time;
                        tm_precharge = $time;
                    end
                    // Read with Auto Precharge Calculation
                    // 1.  Meet minimum tRAS requirement
                    // 2.  Additive Latency plus BL/2 cycles after Read command
                    // 3.  tRTP after the last 4-bit prefetch
                    if (read_precharge_bank[i]
                        && ($time - tm_bank_activate[i] >= TRAS_MIN) 
                        && (ck_cntr - ck_bank_read[i] >= additive_latency + burst_length/2)) begin

                        read_precharge_bank[i] = 0;
                        // In case the internal precharge is pushed out by tRTP, tRP starts at the point where
                        // the internal precharge happens (not at the next rising clock edge after this event).
                        if ($time - tm_bank_read_end[i] < TRTP) begin
                            if (DEBUG) $display ("%m: at time %t INFO: Auto Precharge bank %d", tm_bank_read_end[i] + TRTP, i);
                            active_bank[i] <= #(tm_bank_read_end[i] + TRTP - $time) 0;
                            auto_precharge_bank[i] <= #(tm_bank_read_end[i] + TRTP - $time) 0;
                            tm_bank_precharge[i] <= #(tm_bank_read_end[i] + TRTP - $time) tm_bank_read_end[i] + TRTP;
                            tm_precharge <= #(tm_bank_read_end[i] + TRTP - $time) tm_bank_read_end[i] + TRTP;
                        end else begin
                            if (DEBUG) $display ("%m: at time %t INFO: Auto Precharge bank %d", $time, i);
                            active_bank[i] = 0;
                            auto_precharge_bank[i] = 0;
                            tm_bank_precharge[i] = $time;
                            tm_precharge = $time;
                        end
                    end
                end
            end

            // respond to incoming command
            if (cke_in ^ prev_cke) begin
                ck_cke <= ck_cntr;
            end

            cmd_task(cke_in, cmd_n_in, ba_in, addr_in);
            if ((cmd_n_in == WRITE) || (cmd_n_in == READ)) begin
                al_pipeline[2*additive_latency] = 1'b1;
            end
            if (al_pipeline[0]) begin
                // check tRCD after additive latency
                if ($time - tm_bank_activate[ba_pipeline[2*cas_latency - 1]] < TRCD) begin
                    if (rd_pipeline[2*cas_latency - 1]) begin
                        $display ("%m: at time %t ERROR:  tRCD violation during %s", $time, cmd_string[READ]);
                    end else begin
                        $display ("%m: at time %t ERROR:  tRCD violation during %s", $time, cmd_string[WRITE]);
                    end
                end
                // check tWTR after additive latency
                if (rd_pipeline[2*cas_latency - 1]) begin
                    if ($time - tm_write_end < TWTR)
                        $display ("%m: at time %t ERROR:  tWTR violation during %s", $time, cmd_string[READ]);
                end
            end
            if (rd_pipeline[2*(cas_latency - burst_length/2 + 2) - 1]) begin
                tm_bank_read_end[ba_pipeline[2*(cas_latency - burst_length/2 + 2) - 1]] <= $time;
            end
            for (i=0; i<`BANKS; i=i+1) begin
                if ((ck_cntr - ck_bank_write[i] > write_latency) && (ck_cntr - ck_bank_write[i] <= write_latency + burst_length/2)) begin
                    tm_bank_write_end[i] <= $time;
                    tm_write_end <= $time;
                end
            end

            // clk pin is disabled during self refresh
            if (!in_self_refresh) begin
                tjit_cc_time = $time - tm_ck_pos - tck_i;
                tck_i   = $time - tm_ck_pos;
                tck_avg = tck_avg - tck_sample[ck_cntr%TDLLK]/$itor(TDLLK);
                tck_avg = tck_avg + tck_i/$itor(TDLLK);
                tck_sample[ck_cntr%TDLLK] = tck_i;
                tjit_per_rtime = tck_i - tck_avg;

                if (dll_locked) begin
                    // check accumulated error
                    terr_nper_rtime = 0;
                    for (i=0; i<50; i=i+1) begin
                        terr_nper_rtime = terr_nper_rtime + tck_sample[i] - tck_avg;
                        terr_nper_rtime = abs_value(terr_nper_rtime);
                        case (i)
                                  0 :;
                                  1 : if (terr_nper_rtime - TERR_2PER >= 1.0) $display ("%m: at time %t ERROR: tERR(2per) violation by %f ps.", $time, terr_nper_rtime - TERR_2PER);
                                  2 : if (terr_nper_rtime - TERR_3PER >= 1.0) $display ("%m: at time %t ERROR: tERR(3per) violation by %f ps.", $time, terr_nper_rtime - TERR_3PER);
                                  3 : if (terr_nper_rtime - TERR_4PER >= 1.0) $display ("%m: at time %t ERROR: tERR(4per) violation by %f ps.", $time, terr_nper_rtime - TERR_4PER);
                                  4 : if (terr_nper_rtime - TERR_5PER >= 1.0) $display ("%m: at time %t ERROR: tERR(5per) violation by %f ps.", $time, terr_nper_rtime - TERR_5PER);
                          5,6,7,8,9 : if (terr_nper_rtime - TERR_N1PER >= 1.0) $display ("%m: at time %t ERROR: tERR(n1per) violation by %f ps.", $time, terr_nper_rtime - TERR_N1PER);
                            default : if (terr_nper_rtime - TERR_N2PER >= 1.0) $display ("%m: at time %t ERROR: tERR(n2per) violation by %f ps.", $time, terr_nper_rtime - TERR_N2PER);
                        endcase
                    end

                    // check tCK min/max/jitter
                    if (abs_value(tjit_per_rtime) - TJIT_PER >= 1.0) 
                        $display ("%m: at time %t ERROR: tJIT(per) violation by %f ps.", $time, abs_value(tjit_per_rtime) - TJIT_PER);
                    if (abs_value(tjit_cc_time) - TJIT_CC >= 1.0) 
                        $display ("%m: at time %t ERROR: tJIT(cc) violation by %f ps.", $time, abs_value(tjit_cc_time) - TJIT_CC);
                    if (TCK_MIN - tck_avg >= 1.0)
                        $display ("%m: at time %t ERROR: tCK(avg) minimum violation by %f ps.", $time, TCK_MIN - tck_avg);
                    if (tck_avg - TCK_MAX >= 1.0) 
                        $display ("%m: at time %t ERROR: tCK(avg) maximum violation by %f ps.", $time, tck_avg - TCK_MAX);
                    if (tm_ck_pos + TCK_MIN - TJIT_PER > $time) 
                        $display ("%m: at time %t ERROR: tCK(abs) minimum violation by %t", $time, tm_ck_pos + TCK_MIN - TJIT_PER - $time);
                    if (tm_ck_pos + TCK_MAX + TJIT_PER < $time) 
                        $display ("%m: at time %t ERROR: tCK(abs) maximum violation by %t", $time, $time - tm_ck_pos - TCK_MAX - TJIT_PER);

                    // check tCL
                    if (tm_ck_neg + TCL_MIN*tck_avg - TJIT_DUTY > $time) 
                        $display ("%m: at time %t ERROR: tCL(abs) minimum violation on CLK by %t", $time, tm_ck_neg + TCL_MIN*tck_avg - TJIT_DUTY - $time);
                    if (tm_ck_neg + TCL_MAX*tck_avg + TJIT_DUTY < $time) 
                        $display ("%m: at time %t ERROR: tCL(abs) maximum violation on CLK by %t", $time, $time - tm_ck_neg - TCL_MAX*tck_avg - TJIT_DUTY);
                    if (tcl_avg < TCL_MIN*tck_avg) 
                        $display ("%m: at time %t ERROR: tCL(avg) minimum violation on CLK by %t", $time, TCL_MIN*tck_avg - tcl_avg);
                    if (tcl_avg > TCL_MAX*tck_avg) 
                        $display ("%m: at time %t ERROR: tCL(avg) maximum violation on CLK by %t", $time, tcl_avg - TCL_MAX*tck_avg);
                end

                // calculate the tch avg jitter
                tch_avg = tch_avg - tch_sample[ck_cntr%TDLLK]/$itor(TDLLK);
                tch_avg = tch_avg + tch_i/$itor(TDLLK);
                tch_sample[ck_cntr%TDLLK] = tch_i;

                // update timers/counters
                tcl_i <= $time - tm_ck_neg;
            end

            prev_odt <= odt_in;
            // update timers/counters
            ck_cntr <= ck_cntr + 1;
            tm_ck_pos <= $time;
        end else begin
            // clk pin is disabled during self refresh
            if (!in_self_refresh) begin
                if (dll_locked) begin
                    if (tm_ck_pos + TCH_MIN*tck_avg - TJIT_DUTY > $time) 
                        $display ("%m: at time %t ERROR: tCH(abs) minimum violation on CLK by %t", $time, tm_ck_pos + TCH_MIN*tck_avg - TJIT_DUTY + $time);
                    if (tm_ck_pos + TCH_MAX*tck_avg + TJIT_DUTY < $time) 
                        $display ("%m: at time %t ERROR: tCH(abs) maximum violation on CLK by %t", $time, $time - tm_ck_pos - TCH_MAX*tck_avg - TJIT_DUTY);
                    if (tch_avg < TCH_MIN*tck_avg) 
                        $display ("%m: at time %t ERROR: tCH(avg) minimum violation on CLK by %t", $time, TCH_MIN*tck_avg - tch_avg);
                    if (tch_avg > TCH_MAX*tck_avg) 
                        $display ("%m: at time %t ERROR: tCH(avg) maximum violation on CLK by %t", $time, tch_avg - TCH_MAX*tck_avg);
                end

                // calculate the tcl avg jitter
                tcl_avg = tcl_avg - tcl_sample[ck_cntr%TDLLK]/$itor(TDLLK);
                tcl_avg = tcl_avg + tcl_i/$itor(TDLLK);
                tcl_sample[ck_cntr%TDLLK] = tcl_i;

                // update timers/counters
                tch_i <= $time - tm_ck_pos;
            end
            tm_ck_neg <= $time;
        end

        // on die termination
        if (odt_en) begin
            // clk pin is disabled during self refresh
            if (!in_self_refresh && diff_ck) begin
                if ($time - tm_odt < TIS) begin
                    $display ("%m: at time %t ERROR: tIS violation on ODT by %t", $time, tm_odt + TIS - $time);
                end
                if (prev_odt ^ odt_in) begin
                    if (!dll_locked)
                        $display ("%m: at time %t WARNING: tDLLK violation during ODT transition.", $time);
                    if (odt_in && ($time - tm_odt_en  < TMOD))
                        $display ("%m: at time %t ERROR:  tMOD violation during ODT transition", $time);
                    if ($time - tm_self_refresh < TXSNR)
                        $display ("%m: at time %t ERROR: tXSNR violation during ODT transition", $time);
                    if (in_self_refresh)
                        $display ("%m: at time %t ERROR:  Illegal ODT transition during Self Refresh.", $time);

                    // async ODT mode applies:
                    // 1.) during active power down with slow exit
                    // 2.) during precharge power down
                    // 3.) if tANPD has not been satisfied
                    // 4.) until tAXPD has been satisfied
                    if ((in_power_down && (low_power || (active_bank == 0))) || (ck_cntr - ck_slow_exit_pd < TAXPD)) begin
                        if (ck_cntr - ck_slow_exit_pd < TAXPD)
                            $display ("%m: at time %t WARNING: tAXPD violation during ODT transition.  Synchronous or asynchronous change in termination resistance is possible.", $time);
                        if (odt_in) begin
                            if (DEBUG) $display ("%m: at time %t INFO: Async On Die Termination = %d", $time + TAONPD, 1'b1);
                            odt_state <= #(TAONPD) 1'b1;
                        end else begin
                            if (DEBUG) $display ("%m: at time %t INFO: Async On Die Termination = %d", $time + TAOFPD, 1'b0);
                            odt_state <= #(TAOFPD) 1'b0;
                        end
                    // sync ODT mode applies:
                    // 1.) during normal operation
                    // 2.) during active power down with fast exit
                    end else begin
                        if (odt_in) begin
                            i = TAOND*2;
                            odt_pipeline[i] = 1'b1;
                        end else begin
                            i = TAOFD*2;
                            odt_pipeline[i] = 1'b1;
                        end
                    end
                    ck_odt <= ck_cntr;
                end
            end
            if (odt_pipeline[0]) begin
                odt_state = ~odt_state;
                if (DEBUG) $display ("%m: at time %t INFO: Sync On Die Termination = %d", $time, odt_state);
            end
        end

        // shift pipelines
        if (|wr_pipeline || |rd_pipeline || |al_pipeline) begin
            al_pipeline = al_pipeline>>1;
            wr_pipeline = wr_pipeline>>1;
            rd_pipeline = rd_pipeline>>1;
            for (i=0; i<`MAX_PIPE; i=i+1) begin
                ba_pipeline[i] = ba_pipeline[i+1];
                row_pipeline[i] = row_pipeline[i+1];
                col_pipeline[i] = col_pipeline[i+1];
            end
        end
        if (|odt_pipeline) begin
            odt_pipeline = odt_pipeline>>1;
        end
    end

    // receiver(s)
    task dqs_even_receiver;
        input [4:0] i;
        reg [71:0] bit_mask;
        begin
            bit_mask = {`DQ_PER_DQS{1'b1}}<<(i*`DQ_PER_DQS);
            if (dqs_even[i]) begin
                if (rdqs_en) begin // rdqs disables dm
                    dm_in_pos[i] = 1'b0;
                end else begin
                    dm_in_pos[i] = dm_in[i];
                end
                dq_in_pos = (dq_in & bit_mask) | (dq_in_pos & ~bit_mask);
            end
        end
    endtask

    always @(posedge dqs_even[ 0]) dqs_even_receiver( 0);
    always @(posedge dqs_even[ 1]) dqs_even_receiver( 1);
    always @(posedge dqs_even[ 2]) dqs_even_receiver( 2);
    always @(posedge dqs_even[ 3]) dqs_even_receiver( 3);
    always @(posedge dqs_even[ 4]) dqs_even_receiver( 4);
    always @(posedge dqs_even[ 5]) dqs_even_receiver( 5);
    always @(posedge dqs_even[ 6]) dqs_even_receiver( 6);
    always @(posedge dqs_even[ 7]) dqs_even_receiver( 7);
    always @(posedge dqs_even[ 8]) dqs_even_receiver( 8);
    always @(posedge dqs_even[ 9]) dqs_even_receiver( 9);
    always @(posedge dqs_even[10]) dqs_even_receiver(10);
    always @(posedge dqs_even[11]) dqs_even_receiver(11);
    always @(posedge dqs_even[12]) dqs_even_receiver(12);
    always @(posedge dqs_even[13]) dqs_even_receiver(13);
    always @(posedge dqs_even[14]) dqs_even_receiver(14);
    always @(posedge dqs_even[15]) dqs_even_receiver(15);
    always @(posedge dqs_even[16]) dqs_even_receiver(16);
    always @(posedge dqs_even[17]) dqs_even_receiver(17);

    task dqs_odd_receiver;
        input [4:0] i;
        reg [71:0] bit_mask;
        begin
            bit_mask = {`DQ_PER_DQS{1'b1}}<<(i*`DQ_PER_DQS);
            if (dqs_odd[i]) begin
                if (rdqs_en) begin // rdqs disables dm
                    dm_in_neg[i] = 1'b0;
                end else begin
                    dm_in_neg[i] = dm_in[i];
                end
                dq_in_neg = (dq_in & bit_mask) | (dq_in_neg & ~bit_mask);
            end
        end
    endtask

    always @(posedge dqs_odd[ 0]) dqs_odd_receiver( 0);
    always @(posedge dqs_odd[ 1]) dqs_odd_receiver( 1);
    always @(posedge dqs_odd[ 2]) dqs_odd_receiver( 2);
    always @(posedge dqs_odd[ 3]) dqs_odd_receiver( 3);
    always @(posedge dqs_odd[ 4]) dqs_odd_receiver( 4);
    always @(posedge dqs_odd[ 5]) dqs_odd_receiver( 5);
    always @(posedge dqs_odd[ 6]) dqs_odd_receiver( 6);
    always @(posedge dqs_odd[ 7]) dqs_odd_receiver( 7);
    always @(posedge dqs_odd[ 8]) dqs_odd_receiver( 8);
    always @(posedge dqs_odd[ 9]) dqs_odd_receiver( 9);
    always @(posedge dqs_odd[10]) dqs_odd_receiver(10);
    always @(posedge dqs_odd[11]) dqs_odd_receiver(11);
    always @(posedge dqs_odd[12]) dqs_odd_receiver(12);
    always @(posedge dqs_odd[13]) dqs_odd_receiver(13);
    always @(posedge dqs_odd[14]) dqs_odd_receiver(14);
    always @(posedge dqs_odd[15]) dqs_odd_receiver(15);
    always @(posedge dqs_odd[16]) dqs_odd_receiver(16);
    always @(posedge dqs_odd[17]) dqs_odd_receiver(17);
 
    // Processes to check hold and pulse width of control signals
    always @(cke_in) begin
        if ($time > TIH) begin
            if ($time - tm_ck_pos < TIH) 
                $display ("%m: at time %t ERROR:  tIH violation on CKE by %t", $time, tm_ck_pos + TIH - $time);
        end
        if (dll_locked && ($time - tm_cke < $rtoi(TIPW*tck_avg)))
            $display ("%m: at time %t ERROR: tIPW violation on CKE by %t", $time, tm_cke + TIPW*tck_avg - $time);
        tm_cke = $time;
    end
    always @(odt_in) begin
        if (odt_en && !in_self_refresh) begin
            if ($time - tm_ck_pos < TIH) 
                $display ("%m: at time %t ERROR:  tIH violation on ODT by %t", $time, tm_ck_pos + TIH - $time);
            if (dll_locked && ($time - tm_odt < $rtoi(TIPW*tck_avg)))
                $display ("%m: at time %t ERROR: tIPW violation on ODT by %t", $time, tm_odt + TIPW*tck_avg - $time);
        end
        tm_odt = $time;
    end

    task cmd_addr_timing_check;
    input i;
    reg [4:0] i;
    begin
        if (prev_cke) begin
            if ($time - tm_ck_pos < TIH) 
                $display ("%m: at time %t ERROR:  tIH violation on %s by %t", $time, cmd_addr_string[i], tm_ck_pos + TIH - $time);
            if (dll_locked && ($time - tm_cmd_addr[i] < $rtoi(TIPW*tck_avg)))
                $display ("%m: at time %t ERROR: tIPW violation on %s by %t", $time, cmd_addr_string[i], tm_cmd_addr[i] + TIPW*tck_avg - $time);
        end
        tm_cmd_addr[i] = $time;
    end
    endtask

    always @(cs_n_in    ) cmd_addr_timing_check( 0);
    always @(ras_n_in   ) cmd_addr_timing_check( 1);
    always @(cas_n_in   ) cmd_addr_timing_check( 2);
    always @(we_n_in    ) cmd_addr_timing_check( 3);
    always @(ba_in  [ 0]) cmd_addr_timing_check( 4);
    always @(ba_in  [ 1]) cmd_addr_timing_check( 5);
    always @(ba_in  [ 2]) cmd_addr_timing_check( 6);
    always @(addr_in[ 0]) cmd_addr_timing_check( 7);
    always @(addr_in[ 1]) cmd_addr_timing_check( 8);
    always @(addr_in[ 2]) cmd_addr_timing_check( 9);
    always @(addr_in[ 3]) cmd_addr_timing_check(10);
    always @(addr_in[ 4]) cmd_addr_timing_check(11);
    always @(addr_in[ 5]) cmd_addr_timing_check(12);
    always @(addr_in[ 6]) cmd_addr_timing_check(13);
    always @(addr_in[ 7]) cmd_addr_timing_check(14);
    always @(addr_in[ 8]) cmd_addr_timing_check(15);
    always @(addr_in[ 9]) cmd_addr_timing_check(16);
    always @(addr_in[10]) cmd_addr_timing_check(17);
    always @(addr_in[11]) cmd_addr_timing_check(18);
    always @(addr_in[12]) cmd_addr_timing_check(19);
    always @(addr_in[13]) cmd_addr_timing_check(20);
    always @(addr_in[14]) cmd_addr_timing_check(21);
    always @(addr_in[15]) cmd_addr_timing_check(22);

    // Processes to check setup and hold of data signals
    task dm_timing_check;
    input i;
    reg [4:0] i;
    begin
        if (dqs_in_valid) begin
            if ($time - tm_dqs[i] < TDH) 
                $display ("%m: at time %t ERROR:   tDH violation on DM bit %d by %t", $time, i, tm_dqs[i] + TDH - $time);
            if (check_dm_tdipw[i]) begin
                if (dll_locked && ($time - tm_dm[i] < $rtoi(TDIPW*tck_avg)))
                    $display ("%m: at time %t ERROR: tDIPW violation on DM bit %d by %t", $time, i, tm_dm[i] + TDIPW*tck_avg - $time);
            end
        end
        check_dm_tdipw[i] <= 1'b0;
        tm_dm[i] = $time;
    end
    endtask

    always @(dm_in[ 0]) dm_timing_check( 0);
    always @(dm_in[ 1]) dm_timing_check( 1);
    always @(dm_in[ 2]) dm_timing_check( 2);
    always @(dm_in[ 3]) dm_timing_check( 3);
    always @(dm_in[ 4]) dm_timing_check( 4);
    always @(dm_in[ 5]) dm_timing_check( 5);
    always @(dm_in[ 6]) dm_timing_check( 6);
    always @(dm_in[ 7]) dm_timing_check( 7);
    always @(dm_in[ 8]) dm_timing_check( 8);
    always @(dm_in[ 9]) dm_timing_check( 9);
    always @(dm_in[10]) dm_timing_check(10);
    always @(dm_in[11]) dm_timing_check(11);
    always @(dm_in[12]) dm_timing_check(12);
    always @(dm_in[13]) dm_timing_check(13);
    always @(dm_in[14]) dm_timing_check(14);
    always @(dm_in[15]) dm_timing_check(15);
    always @(dm_in[16]) dm_timing_check(16);
    always @(dm_in[17]) dm_timing_check(17);

    task dq_timing_check;
    input i;
    reg [6:0] i;
    begin
        if (dqs_in_valid) begin
            if ($time - tm_dqs[i/`DQ_PER_DQS] < TDH) 
                $display ("%m: at time %t ERROR:   tDH violation on DQ bit %d by %t", $time, i, tm_dqs[i/`DQ_PER_DQS] + TDH - $time);
            if (check_dq_tdipw[i]) begin
                if (dll_locked && ($time - tm_dq[i] < $rtoi(TDIPW*tck_avg)))
                    $display ("%m: at time %t ERROR: tDIPW violation on DQ bit %d by %t", $time, i, tm_dq[i] + TDIPW*tck_avg - $time);
            end
        end
        check_dq_tdipw[i] <= 1'b0;
        tm_dq[i] = $time;
    end 
    endtask

    always @(dq_in[ 0]) dq_timing_check( 0);
    always @(dq_in[ 1]) dq_timing_check( 1);
    always @(dq_in[ 2]) dq_timing_check( 2);
    always @(dq_in[ 3]) dq_timing_check( 3);
    always @(dq_in[ 4]) dq_timing_check( 4);
    always @(dq_in[ 5]) dq_timing_check( 5);
    always @(dq_in[ 6]) dq_timing_check( 6);
    always @(dq_in[ 7]) dq_timing_check( 7);
    always @(dq_in[ 8]) dq_timing_check( 8);
    always @(dq_in[ 9]) dq_timing_check( 9);
    always @(dq_in[10]) dq_timing_check(10);
    always @(dq_in[11]) dq_timing_check(11);
    always @(dq_in[12]) dq_timing_check(12);
    always @(dq_in[13]) dq_timing_check(13);
    always @(dq_in[14]) dq_timing_check(14);
    always @(dq_in[15]) dq_timing_check(15);
    always @(dq_in[16]) dq_timing_check(16);
    always @(dq_in[17]) dq_timing_check(17);
    always @(dq_in[18]) dq_timing_check(18);
    always @(dq_in[19]) dq_timing_check(19);
    always @(dq_in[20]) dq_timing_check(20);
    always @(dq_in[21]) dq_timing_check(21);
    always @(dq_in[22]) dq_timing_check(22);
    always @(dq_in[23]) dq_timing_check(23);
    always @(dq_in[24]) dq_timing_check(24);
    always @(dq_in[25]) dq_timing_check(25);
    always @(dq_in[26]) dq_timing_check(26);
    always @(dq_in[27]) dq_timing_check(27);
    always @(dq_in[28]) dq_timing_check(28);
    always @(dq_in[29]) dq_timing_check(29);
    always @(dq_in[30]) dq_timing_check(30);
    always @(dq_in[31]) dq_timing_check(31);
    always @(dq_in[32]) dq_timing_check(32);
    always @(dq_in[33]) dq_timing_check(33);
    always @(dq_in[34]) dq_timing_check(34);
    always @(dq_in[35]) dq_timing_check(35);
    always @(dq_in[36]) dq_timing_check(36);
    always @(dq_in[37]) dq_timing_check(37);
    always @(dq_in[38]) dq_timing_check(38);
    always @(dq_in[39]) dq_timing_check(39);
    always @(dq_in[40]) dq_timing_check(40);
    always @(dq_in[41]) dq_timing_check(41);
    always @(dq_in[42]) dq_timing_check(42);
    always @(dq_in[43]) dq_timing_check(43);
    always @(dq_in[44]) dq_timing_check(44);
    always @(dq_in[45]) dq_timing_check(45);
    always @(dq_in[46]) dq_timing_check(46);
    always @(dq_in[47]) dq_timing_check(47);
    always @(dq_in[48]) dq_timing_check(48);
    always @(dq_in[49]) dq_timing_check(49);
    always @(dq_in[50]) dq_timing_check(50);
    always @(dq_in[51]) dq_timing_check(51);
    always @(dq_in[52]) dq_timing_check(52);
    always @(dq_in[53]) dq_timing_check(53);
    always @(dq_in[54]) dq_timing_check(54);
    always @(dq_in[55]) dq_timing_check(55);
    always @(dq_in[56]) dq_timing_check(56);
    always @(dq_in[57]) dq_timing_check(57);
    always @(dq_in[58]) dq_timing_check(58);
    always @(dq_in[59]) dq_timing_check(59);
    always @(dq_in[60]) dq_timing_check(60);
    always @(dq_in[61]) dq_timing_check(61);
    always @(dq_in[62]) dq_timing_check(62);
    always @(dq_in[63]) dq_timing_check(63);
    always @(dq_in[64]) dq_timing_check(64);
    always @(dq_in[65]) dq_timing_check(65);
    always @(dq_in[66]) dq_timing_check(66);
    always @(dq_in[67]) dq_timing_check(67);
    always @(dq_in[68]) dq_timing_check(68);
    always @(dq_in[69]) dq_timing_check(69);
    always @(dq_in[70]) dq_timing_check(70);
    always @(dq_in[71]) dq_timing_check(71);

    task dqs_pos_timing_check;
    input i;
    reg [5:0] i;
    reg [3:0] j;
    begin
        if (dqs_in_valid && ((wdqs_pos_cntr[i] < burst_length/2) || b2b_write) && (dqs_n_en || i<18)) begin
            if (dqs_in[i] ^ prev_dqs_in[i]) begin
                if (dll_locked) begin
                    if (check_write_preamble[i]) begin
                        if ($time - tm_dqs_neg[i] < $rtoi(TWPRE*tck_avg))
                            $display ("%m: at time %t ERROR: tWPRE violation on &s bit %d", $time, dqs_string[i/18], i%18);
                    end else if (check_write_postamble[i]) begin
                        if ($time - tm_dqs_neg[i] < $rtoi(TWPST*tck_avg))
                            $display ("%m: at time %t ERROR: tWPST violation on %s bit %d", $time, dqs_string[i/18], i%18);
                    end else begin
                        if ($time - tm_dqs_neg[i] < $rtoi(TDQSL*tck_avg))
                            $display ("%m: at time %t ERROR: tDQSL violation on %s bit %d", $time, dqs_string[i/18], i%18);
                    end
                end
                if ($time - tm_dm[i%18] < TDS) 
                    $display ("%m: at time %t ERROR: tDS violation on DM bit %d by %t", $time, i,  tm_dm[i%18] + TDS - $time);
                if (!dq_out_en) begin
                    for (j=0; j<`DQ_PER_DQS; j=j+1) begin
                        if ($time - tm_dq[i*`DQ_PER_DQS+j] < TDS) 
                            $display ("%m: at time %t ERROR: tDS violation on DQ bit %d by %t", $time, i*`DQ_PER_DQS+j, tm_dq[i*`DQ_PER_DQS+j] + TDS - $time);
                        check_dq_tdipw[i*`DQ_PER_DQS+j] <= 1'b1;
                    end
                end
                if ((wdqs_pos_cntr[i] < burst_length/2) && !b2b_write) begin
                    wdqs_pos_cntr[i] <= wdqs_pos_cntr[i] + 1;
                end else begin
                    wdqs_pos_cntr[i] <= 1;
                end
                check_dm_tdipw[i%18] <= 1'b1;
                check_write_preamble[i] <= 1'b0;
                check_write_postamble[i] <= 1'b0;
                check_write_dqs_low[i] <= 1'b0;
                tm_dqs[i%18] <= $time;
            end else begin
                $display ("%m: at time %t ERROR: Invalid latching edge on %s bit %d", $time, dqs_string[i/18], i%18);
            end
        end
        tm_dqss_pos[i] <= $time;
        tm_dqs_pos[i] = $time;
        prev_dqs_in[i] <= dqs_in[i];
    end
    endtask

    always @(posedge dqs_in[ 0]) dqs_pos_timing_check( 0);
    always @(posedge dqs_in[ 1]) dqs_pos_timing_check( 1);
    always @(posedge dqs_in[ 2]) dqs_pos_timing_check( 2);
    always @(posedge dqs_in[ 3]) dqs_pos_timing_check( 3);
    always @(posedge dqs_in[ 4]) dqs_pos_timing_check( 4);
    always @(posedge dqs_in[ 5]) dqs_pos_timing_check( 5);
    always @(posedge dqs_in[ 6]) dqs_pos_timing_check( 6);
    always @(posedge dqs_in[ 7]) dqs_pos_timing_check( 7);
    always @(posedge dqs_in[ 8]) dqs_pos_timing_check( 8);
    always @(posedge dqs_in[ 9]) dqs_pos_timing_check( 9);
    always @(posedge dqs_in[10]) dqs_pos_timing_check(10);
    always @(posedge dqs_in[11]) dqs_pos_timing_check(11);
    always @(posedge dqs_in[12]) dqs_pos_timing_check(12);
    always @(posedge dqs_in[13]) dqs_pos_timing_check(13);
    always @(posedge dqs_in[14]) dqs_pos_timing_check(14);
    always @(posedge dqs_in[15]) dqs_pos_timing_check(15);
    always @(posedge dqs_in[16]) dqs_pos_timing_check(16);
    always @(posedge dqs_in[17]) dqs_pos_timing_check(17);
    always @(negedge dqs_in[18]) dqs_pos_timing_check(18);
    always @(negedge dqs_in[19]) dqs_pos_timing_check(19);
    always @(negedge dqs_in[20]) dqs_pos_timing_check(20);
    always @(negedge dqs_in[21]) dqs_pos_timing_check(21);
    always @(negedge dqs_in[22]) dqs_pos_timing_check(22);
    always @(negedge dqs_in[23]) dqs_pos_timing_check(23);
    always @(negedge dqs_in[24]) dqs_pos_timing_check(24);
    always @(negedge dqs_in[25]) dqs_pos_timing_check(25);
    always @(negedge dqs_in[26]) dqs_pos_timing_check(26);
    always @(negedge dqs_in[27]) dqs_pos_timing_check(27);
    always @(negedge dqs_in[28]) dqs_pos_timing_check(28);
    always @(negedge dqs_in[29]) dqs_pos_timing_check(29);
    always @(negedge dqs_in[30]) dqs_pos_timing_check(30);
    always @(negedge dqs_in[31]) dqs_pos_timing_check(31);
    always @(negedge dqs_in[32]) dqs_neg_timing_check(32);
    always @(negedge dqs_in[33]) dqs_neg_timing_check(33);
    always @(negedge dqs_in[34]) dqs_neg_timing_check(34);
    always @(negedge dqs_in[35]) dqs_neg_timing_check(35);

    task dqs_neg_timing_check;
    input i;
    reg [5:0] i;
    reg [3:0] j;
    begin
        if (dqs_in_valid && (wdqs_pos_cntr[i] > 0) && check_write_dqs_high[i] && (dqs_n_en || i < 18)) begin
            if (dqs_in[i] ^ prev_dqs_in[i]) begin
                if (dll_locked) begin
                    if ($time - tm_dqs_pos[i] < $rtoi(TDQSH*tck_avg))
                        $display ("%m: at time %t ERROR: tDQSH violation on %s bit %d", $time, dqs_string[i/18], i%18);
                    if ($time - tm_ck_pos < $rtoi(TDSH*tck_avg))
                        $display ("%m: at time %t ERROR: tDSH violation on %s bit %d", $time, dqs_string[i/18], i%18); 
                end
                if ($time - tm_dm[i%18] < TDS) 
                    $display ("%m: at time %t ERROR: tDS violation on DM bit %d by %t", $time, i,  tm_dm[i%18] + TDS - $time);
                if (!dq_out_en) begin
                    for (j=0; j<`DQ_PER_DQS; j=j+1) begin
                        if ($time - tm_dq[i*`DQ_PER_DQS+j] < TDS) 
                            $display ("%m: at time %t ERROR: tDS violation on DQ bit %d by %t", $time, i*`DQ_PER_DQS+j, tm_dq[i*`DQ_PER_DQS+j] + TDS - $time);
                        check_dq_tdipw[i*`DQ_PER_DQS+j] <= 1'b1;
                    end
                end
                check_dm_tdipw[i%18] <= 1'b1;
                check_write_dqs_high[i] <= 1'b0;
                tm_dqs[i%18] <= $time;
            end else begin
                $display ("%m: at time %t ERROR: Invalid latching edge on %s bit %d", $time, dqs_string[i/18], i%18);
            end
        end
        tm_dqs_neg[i] = $time;
        prev_dqs_in[i] <= dqs_in[i];
    end
    endtask

    always @(negedge dqs_in[ 0]) dqs_neg_timing_check( 0);
    always @(negedge dqs_in[ 1]) dqs_neg_timing_check( 1);
    always @(negedge dqs_in[ 2]) dqs_neg_timing_check( 2);
    always @(negedge dqs_in[ 3]) dqs_neg_timing_check( 3);
    always @(negedge dqs_in[ 4]) dqs_neg_timing_check( 4);
    always @(negedge dqs_in[ 5]) dqs_neg_timing_check( 5);
    always @(negedge dqs_in[ 6]) dqs_neg_timing_check( 6);
    always @(negedge dqs_in[ 7]) dqs_neg_timing_check( 7);
    always @(negedge dqs_in[ 8]) dqs_neg_timing_check( 8);
    always @(negedge dqs_in[ 9]) dqs_neg_timing_check( 9);
    always @(negedge dqs_in[10]) dqs_neg_timing_check(10);
    always @(negedge dqs_in[11]) dqs_neg_timing_check(11);
    always @(negedge dqs_in[12]) dqs_neg_timing_check(12);
    always @(negedge dqs_in[13]) dqs_neg_timing_check(13);
    always @(negedge dqs_in[14]) dqs_neg_timing_check(14);
    always @(negedge dqs_in[15]) dqs_neg_timing_check(15);
    always @(negedge dqs_in[16]) dqs_neg_timing_check(16);
    always @(negedge dqs_in[17]) dqs_neg_timing_check(17);
    always @(posedge dqs_in[18]) dqs_neg_timing_check(18);
    always @(posedge dqs_in[19]) dqs_neg_timing_check(19);
    always @(posedge dqs_in[20]) dqs_neg_timing_check(20);
    always @(posedge dqs_in[21]) dqs_neg_timing_check(21);
    always @(posedge dqs_in[22]) dqs_neg_timing_check(22);
    always @(posedge dqs_in[23]) dqs_neg_timing_check(23);
    always @(posedge dqs_in[24]) dqs_neg_timing_check(24);
    always @(posedge dqs_in[25]) dqs_neg_timing_check(25);
    always @(posedge dqs_in[26]) dqs_neg_timing_check(26);
    always @(posedge dqs_in[27]) dqs_neg_timing_check(27);
    always @(posedge dqs_in[28]) dqs_neg_timing_check(28);
    always @(posedge dqs_in[29]) dqs_neg_timing_check(29);
    always @(posedge dqs_in[30]) dqs_neg_timing_check(30);
    always @(posedge dqs_in[31]) dqs_neg_timing_check(31);
    always @(posedge dqs_in[32]) dqs_neg_timing_check(32);
    always @(posedge dqs_in[33]) dqs_neg_timing_check(33);
    always @(posedge dqs_in[34]) dqs_neg_timing_check(34);
    always @(posedge dqs_in[35]) dqs_neg_timing_check(35);

endmodule
