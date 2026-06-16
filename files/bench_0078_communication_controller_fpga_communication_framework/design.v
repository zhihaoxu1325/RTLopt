// Curated RTL benchmark case.
// case_id: bench_0078_communication_controller_fpga_communication_framework
// source_project: communication_controller_fpga_communication_framework
// top_module: patlpp


// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/patlpp.v
// -----------------------------------------------------------------------------
// PATLPP - PATL Packet Processor
// Application Specific Processor for packet processing
// 
// Instruction set is limited to data movement, FIFO operations, and compares
//

`timescale 1ns / 100ps

module patlpp
(
	input				en, // module enable
	input				clk, // module clock
	input				rst, // module reset

	input				in_sof, // start of frame input
	input				in_eof, // end of frame input
	input				in_src_rdy, // source of input ready
	output			in_dst_rdy, // this module destination ready

	output			out_sof, // start of frame output
	output			out_eof, // end of frame output
	output			out_src_rdy, // this module source ready
	input				out_dst_rdy, // destination of output ready

	input		[7:0]	in_data, // data input
	output	[7:0]	out_data, // data output / port output
	output	[3:0] outport_addr, // Output Port address
	output	[3:0] inport_addr//, // Input Port address
	//output	[11:0] chipscope_data
);

// Parameters ----------------------------------------------------------------


// Internal wires ------------------------------------------------------------
// - Instruction wires
wire				srst; // Soft reset
wire				high_byte_reg_en; // High byte register enable
wire				output_byte_s; // Output byte select
wire				outport_reg_en; // Output Port Register Enable
wire				inport_reg_en; // Input Port Register Enable
wire	[2:0]		data_mux_s; // data mux select
wire	[1:0]		op_0_s; // Operand 0 Select
wire				op_1_s; // Operand 1 Select

wire	[3:0]		reg_addr; // register file address
wire	[1:0]		reg_wen; // write enable of higher and lower order byte in register file
wire				fcs_add; // add to checksum
wire				fcs_clear; // clear checksum

wire				sr1_in_en; // shift register 1 input enable
wire				sr2_in_en; // shift register 2 input enable
wire				sr1_out_en; // shift register 1 output enable
wire				sr2_out_en; // shift register 2 output enable

wire				flag_reg_en; // Flag register enable
wire	[2:0]		comp_mode; // Compare mode
wire	[1:0]		alu_op; // ALU Operation

wire	[7:0]		const_byte; // byte constant
wire	[15:0]	const_word; // word constant

// - Intruction logic inputs
wire				comp_res; // comparator result
wire				fcs_check; // asserted if checksum == 0

// - Datapath wires
wire	[15:0]		op0_data; // operand 0 data
wire	[15:0]		op1_data; // operand 1 data
wire	[15:0]		alu_res_data; // ALU result

wire	[7:0]			sr1_data_in; // shift register 1 data input
wire	[7:0]			sr2_data_in; // shift register 2 data input
wire	[7:0]			sr1_data_out; // shift register 1 data output
wire	[7:0]			sr2_data_out; // shift register 2 data output

wire	[7:0]			sr_data_out; // Muxed shift register data

wire	[15:0]		word_data; // word data line
wire	[15:0]		mux_output_data; // output data line

wire	[15:0]		reg_data_out; // register file output
wire	[15:0]		reg_data_in;

wire	[15:0]		checksum_data_in;
wire	[15:0]		checksum_data_out;

wire	[15:0]		alu_op0;
wire	[15:0]		alu_op1;

wire	[7:0]			output_high_byte;
wire	[7:0]			output_low_byte;

reg	[7:0]			flag_reg;
reg	[3:0]			outport_reg;
reg	[3:0]			inport_reg;

// Wire Connections ----------------------------------------------------------

// Chipscope
//assign chipscope_data[11:8] = port_addr;


// Block Instantiations ------------------------------------------------------
microcodelogic mcodelogic_inst 
(
	.clk(clk),
	.rst(rst),
	.srst(srst),

	.sof_in(in_sof),
	.eof_in(in_eof),
	.src_rdy_in(in_src_rdy),
	.dst_rdy_in(in_dst_rdy),

	.sof_out(out_sof),
	.eof_out(out_eof),
	.src_rdy_out(out_src_rdy),
	.dst_rdy_out(out_dst_rdy),

	.high_byte_reg_en(high_byte_reg_en),
	.output_byte_s(output_byte_s),
	.outport_reg_en(outport_reg_en),
	.inport_reg_en(inport_reg_en),
	.data_mux_s(data_mux_s),
	.op_0_s(op_0_s),
	.op_1_s(op_1_s),
	
	.reg_addr(reg_addr),
	.reg_wen(reg_wen),
	
	.fcs_add(fcs_add),
	.fcs_clear(fcs_clear),
	.fcs_check(fcs_check),
	
	.sr1_in_en(sr1_in_en),
	.sr2_in_en(sr2_in_en),
	.sr1_out_en(sr1_out_en),
	.sr2_out_en(sr2_out_en),
	
	.flag_reg_en(flag_reg_en),
	.comp_mode(comp_mode),
	.comp_res(comp_res),
	
	.alu_op(alu_op),
	.const_byte(const_byte),
	.const_word(const_word)//,
	//.chipscope_data(chipscope_data[7:0])
);

comparelogic comp_inst
(
	.data(alu_res_data),
	.mode(comp_mode[1:0]),
	.result(comp_res)
);

lpm_stopar #(
	.WIDTH(8),
	.DEPTH(2)
) in_sr (
	.clk(clk),
	.rst(rst),
	.en(high_byte_reg_en),
	.sin(in_data),
	.pout(word_data)
);

regfile regfile_inst
(
	.clk(clk),
	.rst(rst),
	.wren_low(reg_wen[0]),
	.wren_high(reg_wen[1]),
	.address(reg_addr),
	.data_in(reg_data_in),
	.data_out(reg_data_out)
);

shiftr sr1
(
	.en_in(sr1_in_en),
	.en_out(sr1_out_en),
	.clk(clk),
	.rst(rst),
	.srst(srst),
	.data_in(sr1_data_in),
	.data_out(sr1_data_out)
);

shiftr sr2
(
	.en_in(sr2_in_en),
	.en_out(sr2_out_en),
	.clk(clk),
	.rst(rst),
	.srst(srst),
	.data_in(sr2_data_in),
	.data_out(sr2_data_out)
);

checksum checksum_inst
(
	.clk(clk),
	.rst(rst),

	.data_in(checksum_data_in),
	.checksum_add(fcs_add),
	.checksum_clear(fcs_clear),

	.checksum_check(fcs_check),
	.checksum_out(checksum_data_out)
);

assign alu_op0 = { ( {8{~comp_mode[2]}} & op0_data[15:8] ), op0_data[7:0] };
assign alu_op1 = { ( {8{~comp_mode[2]}} & op1_data[15:8] ), op1_data[7:0] };

alunit alunit_inst
(
	.op0(alu_op0),
	.op1(alu_op1),
	.op(alu_op),
	.res(alu_res_data)
);

lpm_mux8 #(
	.WIDTH(16)
) main_mux
(
	.in0(const_word),
	.in1(checksum_data_out),
	.in2(reg_data_out),
	.in3(word_data),
	.in4({ 8'd0, sr_data_out}),
	.in5(alu_res_data),
	.in6({ 8'd0, flag_reg}),
	.in7(16'd0),
	.s(data_mux_s),
	.out(mux_output_data)
);

lpm_mux4 #(
	.WIDTH(16)
) mux_op0
(
	.in0(const_word),
	.in1(word_data),
	.in2({ 8'd0, flag_reg}),
	.in3(reg_data_out),
	.s(op_0_s),
	.out(op0_data)
);

lpm_mux2 #(
	.WIDTH(16)
) mux_op1
(
	.in0(const_word),
	.in1(reg_data_out),
	.s(op_1_s),
	.out(op1_data)
);

lpm_mux2 #(
	.WIDTH(8)
) mux_byte_select
(
	.in0(output_low_byte),
	.in1(output_high_byte),
	.s(output_byte_s),
	.out(out_data)
);

lpm_mux2 #(
	.WIDTH(8)
) sr_data_mux
(
	.in0(sr1_data_out),
	.in1(sr2_data_out),
	.s(sr2_out_en),
	.out(sr_data_out)
);

// Block Connections ---------------------------------------------------------
//

assign checksum_data_in = mux_output_data;
assign reg_data_in = mux_output_data;
assign sr1_data_in = mux_output_data[7:0];
assign sr2_data_in = mux_output_data[7:0];
assign output_low_byte = mux_output_data[7:0];
assign output_high_byte = mux_output_data[15:8];

// Flag Register -------------------------------------------------------------
//

always @(posedge clk)
begin
	if (rst || srst)
		flag_reg <= 0;
	else if (flag_reg_en)
	begin
		flag_reg <= {4'b0000, fcs_check, comp_res, in_eof, in_sof};
	end
end

// Port Address Registers ----------------------------------------------------
//
always @(posedge clk)
begin
	if (rst || srst)
	begin
		outport_reg <= 0;
		inport_reg <= 0;
	end
	else
	begin
		if (outport_reg_en)
			outport_reg <= mux_output_data[3:0];
		if (inport_reg_en)
			inport_reg <= mux_output_data[3:0];
	end
end

assign outport_addr = outport_reg;
assign inport_addr = inport_reg;

// Simulation Code -----------------------------------------------------------
//
integer file;

initial
begin
	file = $fopen("outframe.hex");
end

always @(posedge clk)
begin
	if (data_mux_s == 2 || op_1_s == 1)
	begin
		$display("Read from Reg %d: %h", reg_addr, reg_data_out);
	end
	if (reg_wen)
	begin
		$display("Written to Reg %d: %h", reg_addr, reg_data_in);
	end
	if (srst)
		$display("Reset Occured");
	if (out_src_rdy && out_dst_rdy)
	begin
		$display("Output to Port %d: %h", outport_addr, out_data);
		if (outport_addr == 0)
			$fdisplay(file, "%h", out_data);
	end
	if (in_src_rdy && in_dst_rdy)
	begin
		$display("Input From Port %d: %h", inport_addr, in_data);
	end
	if (data_mux_s == 5)
	begin
		$display("ALU Function: %d on Op0: %d and Op1: %d", alu_op, op_0_s, op_1_s);
	end
end


endmodule 

// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/alunit/alunit.v
// -----------------------------------------------------------------------------
// ALU for PATLPP

module alunit
(
	input				[15:0]	op0,
	input				[15:0]	op1,
	input				[1:0]		op,
	output	reg	[15:0]	res
);

always @(op0 or op1 or op)
begin
	case (op)
		0: res <= op0 + op1;
		1: res <= op0 - op1;
		2: res <= op0 & op1;
		3: res <= op0 | op1;
	endcase
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/checksum/checksum.v
// -----------------------------------------------------------------------------
// CHECKSUM - a checksum unit for the PATLPP processor
//

`timescale 1ns / 100ps

module checksum
(
	input		wire				clk,
	input		wire				rst,

	input		wire	[15:0]	data_in,
	input		wire				checksum_add,
	input		wire				checksum_clear,
	
	output	wire				checksum_check,
	output	wire	[15:0]	checksum_out
);

wire	[16:0]	wide_res;
reg	[15:0]	result;

assign wide_res = result + data_in; // compute the addition w/carry
assign checksum_out = ~result; // compute the 1's compliment
assign checksum_check = (result == 0);

always @(posedge clk)
begin
	if (rst)
	begin
		result <= 0;
	end
	else if (checksum_clear)
	begin
		result <= 0;
	end
	else if (checksum_add)
	begin
		result <= wide_res[15:0] + { 15'd0, wide_res[16] }; // add carry to result
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/comparelogic/comparelogic.v
// -----------------------------------------------------------------------------
// Compare logic

module comparelogic
(
	input		[15:0]		data,
	input		[1:0]			mode,
	output	reg			result
);

always @(data or mode)
begin
	case (mode)
		0: result = ~( | data ); // ==
		1: result = ~( data[15] && ( | data )); // >
		2: result = ( data[15] && ( | data )); // <
		3: result = ( | data ); // !=
		default: $display("Error in CompareLogic Case");
	endcase
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/microcodelogic/microcodelogic.v
// -----------------------------------------------------------------------------
// Microcode support logic
// Author: Peter Lieber
//

module microcodelogic
(
	input		wire				clk,
	input		wire				rst,
	output	wire				srst,

	input		wire				sof_in,
	input		wire				eof_in,
	input		wire				src_rdy_in,
	output	wire				dst_rdy_in, //

	output	wire				sof_out, //
	output	wire				eof_out, //
	output	wire				src_rdy_out, //
	input		wire				dst_rdy_out,
	
	output	wire				high_byte_reg_en, //
	output	wire				output_byte_s,
	output	wire				outport_reg_en,
	output	wire				inport_reg_en,
	output	wire	[2:0]		data_mux_s,
	output	wire	[1:0]		op_0_s,
	output	wire				op_1_s,
	
	output	wire	[3:0]		reg_addr, //
	output	wire	[1:0]		reg_wen, //
	
	output	wire				fcs_add,
	output	wire				fcs_clear,
	input		wire				fcs_check,
	
	output	wire				sr1_in_en, //
	output	wire				sr2_in_en, //
	output	wire				sr1_out_en, //
	output	wire				sr2_out_en, //
	
	output	wire				flag_reg_en,

	output	wire	[2:0]		comp_mode, //
	input		wire				comp_res,
	
	output	wire	[1:0]		alu_op, //

	output	wire	[7:0]		const_byte,
	output	wire	[15:0]	const_word//, // Word Constant
	//output	wire	[7:0]		chipscope_data
);

reg	[8:0]		pc;
wire	[66:0]	instruction_word; // entire instruction word
wire				pred_src_rdy; // source ready predicated execution
wire				pred_dst_rdy; // destination ready predicated execution
wire				pred_comp; // compare true predicated execution
wire				pred_sof; // Start of Frame predicated execution
wire				pred_eof; // End of Frame predicated execution
wire				pred_cs; // Checksum Predicate
wire				pred; // execution enabling predicate composite
wire	[1:0]		pred_type; // type of predication: until(0) or when(1) or if(2)
wire				reset; // reset program to pc=0
wire				jump; // Jump flag
wire	[8:0]		const_jmp;

// Chipscope
//assign chipscope_data = pc[7:0];

microcodesrc codesource (
	.addr(pc),
	.code(instruction_word)
);

assign pred					= ((pred_src_rdy == 0 && pred_dst_rdy == 0 && pred_comp == 0 && pred_sof == 0 && pred_eof == 0 && pred_cs == 0) || 
									!((pred_src_rdy == 1 && src_rdy_in == 0) || 
									  (pred_dst_rdy == 1 && dst_rdy_out == 0) || 
									  (pred_comp == 1 && comp_res == 0) || 
								     (pred_sof == 1 && sof_in == 0) || 
								     (pred_eof == 1 && eof_in == 0) ||
								  	  (pred_cs == 1 && fcs_check == 0)));

assign const_word				= instruction_word[15:0];
assign const_jmp				= instruction_word[24:16];

assign alu_op					= instruction_word[26:25];
assign comp_mode				= instruction_word[29:27];

assign flag_reg_en			= instruction_word[30] & (pred | (pred_type == 1));

assign sr2_out_en				= instruction_word[31] & (pred | (pred_type == 1));
assign sr1_out_en				= instruction_word[32] & (pred | (pred_type == 1));
assign sr2_in_en				= instruction_word[33] & (pred | (pred_type == 1));
assign sr1_in_en				= instruction_word[34] & (pred | (pred_type == 1));

assign fcs_clear				= instruction_word[35] & (pred | (pred_type == 1));
assign fcs_add					= instruction_word[36] & (pred | (pred_type == 1));

assign reg_wen					= instruction_word[38:37] & {2{(pred | (pred_type == 1))}};
assign reg_addr				= instruction_word[42:39];

assign op_1_s					= instruction_word[43];
assign op_0_s					= instruction_word[45:44];
assign data_mux_s				= instruction_word[48:46];
assign inport_reg_en			= instruction_word[49];
assign outport_reg_en		= instruction_word[50];
assign output_byte_s			= instruction_word[51];
assign high_byte_reg_en		= instruction_word[52];

assign pred_src_rdy			= instruction_word[53];
assign pred_dst_rdy			= instruction_word[54];
assign pred_comp				= instruction_word[55];
assign pred_sof				= instruction_word[56];
assign pred_eof				= instruction_word[57];
assign pred_cs					= instruction_word[58];
assign pred_type				= instruction_word[60:59];

assign eof_out					= instruction_word[61];// & (pred);// | pred_type);
assign sof_out					= instruction_word[62];// & (pred);// | pred_type);
assign src_rdy_out			= instruction_word[63];// & (pred | (pred_type == 1));
assign dst_rdy_in				= instruction_word[64];// & (pred | (pred_type == 1));

assign reset					= instruction_word[65] & (pred);
assign jump						= instruction_word[66] & (pred);

assign srst						= reset;
assign const_byte				= const_jmp[7:0];

// Microcode PC control
always@(posedge clk)
begin
	if (rst == 1)
	begin
		pc <= 0;
	end
	else	if (reset)
	begin
		pc <= 0;
	end
	else if (jump)
	begin
		pc <= const_jmp;
	end
	else if (pred || (pred_type == 2))
	begin
		pc <= pc + 1;
	end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/microcodelogic/microcodesrc/microcodesrc.v
// -----------------------------------------------------------------------------
//  #: Main
//  #: IP_PACKET
//  #: LAB_DAT
//  #: INI_DAT
//  #: BEG_DAT
//  #: END_DAT
//  #: LAB_ACK
//  #: LAB_CON
//  #: LAB_DRQ
//  #: DRQ_LOOP
//  #: END_DRQ
//  #: LAB_SENDACK
// labels:  {'DRQ_LOOP': 263, 'END_DRQ': 267, 'Main': 5, 'LAB_ACK': 161, 'LAB_SENDACK': 270, 'BEG_DAT': 153, 'LAB_DRQ': 190, 'LAB_CON': 168, 'INI_DAT': 149, 'LAB_DAT': 140, 'END_DAT': 157, 'IP_PACKET': 100}

module microcodesrc
(
	input		wire	[8:0]		addr,
	output	reg	[66:0]	code
);

always @(addr)
begin
	case (addr)

		// code: {	         <jmp,rst>
		//				         |      <in_rdy,out_rdy,aeof,asof>
		//				         |      |        <predmode>
		//				         |      |        |     <pred: fcs,eof,sof,equ,dst,src>
		//				         |      |        |     |          <High Byte Reg En>
		//				         |      |        |     |          |     <Output Byte Select>
		//				         |      |        |     |          |     |     <Outport_reg_en, Inport_eg_en>
		//				         |      |        |     |          |     |     |      <Data Mux Select>
		//				         |      |        |     |          |     |     |      |     <Op 0 Select>
		//				         |      |        |     |          |     |     |      |     |     <Op 1 Select>
		//				         |      |        |     |          |     |     |      |     |     |     <Register Address>
		//				         |      |        |     |          |     |     |      |     |     |     |       <Register Write Enables>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     <FCS Add, FCS Clear>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      <sr1ie,sr2ie,sr1oe,sr2oe>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        <Flag Register>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        |     <Compare Mode>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        |     |     <ALU Op>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        |     |     |     <Byte Constant>
		//				         |      |        |     |          |     |     |      |     |     |     |       |     |      |        |     |     |     |       <Word Constant> }
		000:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd10, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd005, 16'd00001}; // JMP(5, Cond=<IF: pred=[<<Constant: value=1>==<Register: address=10, high=True, low=True, high_byte_s=False>, Bytewide: False>]>, Flags=None)
		001:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd06, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Register: address=6, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		002:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd07, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Register: address=7, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		003:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd08, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Register: address=8, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		004:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd10, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // MOV(<Constant: value=1>,<Register: address=10, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		005:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b01, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Input Port Register>, Cond=None, Flags=None)
		006:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b10, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Output Port Register>, Cond=None, Flags=None)
		007:			code <= {2'b00, 4'b1000, 2'd1, 6'b001001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=<UNTIL: pred=[<SOF>, SRC]>, Flags=None)
		008:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		009:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		010:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		011:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		012:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		013:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		014:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		015:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		016:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		017:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		018:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		019:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		020:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		021:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd100, 16'd02048}; // JMP(100, Cond=<IF: pred=[<<Constant: value=2048>==<Register: address=0, high=True, low=True, high_byte_s=False>, Bytewide: False>]>, Flags=None)
		022:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd3, 2'd1, 9'd000, 16'd02054}; // RST(Cond=<IF: pred=[<<Constant: value=2054>!=<Register: address=0, high=True, low=True, high_byte_s=False>, Bytewide: False>]>, Flags=None)
		023:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		024:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		025:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		026:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		027:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd3, 2'd1, 9'd000, 16'd02048}; // RST(Cond=<IF: pred=[<<Constant: value=2048>!=<Register: address=0, high=True, low=True, high_byte_s=False>, Bytewide: False>]>, Flags=None)
		028:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		029:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		030:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		031:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		032:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd3, 2'd1, 9'd000, 16'd00001}; // RST(Cond=<IF: pred=[<<Constant: value=1>!=<Register: address=0, high=True, low=True, high_byte_s=False>, Bytewide: False>]>, Flags=None)
		033:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		034:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		035:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		036:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		037:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		038:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		039:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		040:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		041:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		042:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		043:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		044:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		045:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		046:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		047:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		048:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		049:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00010}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=10>, Bytewide: True>]>, Flags=None)
		050:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		051:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00000}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=0>, Bytewide: True>]>, Flags=None)
		052:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		053:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00001}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=1>, Bytewide: True>]>, Flags=None)
		054:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		055:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00042}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=42>, Bytewide: True>]>, Flags=None)
		056:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		057:			code <= {2'b00, 4'b0110, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=[<ASOF>])
		058:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		059:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		060:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		061:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		062:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		063:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		064:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00035}; // OUT(<Constant: value=35>, Cond=None, Flags=None)
		065:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00069}; // OUT(<Constant: value=69>, Cond=None, Flags=None)
		066:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00103}; // OUT(<Constant: value=103>, Cond=None, Flags=None)
		067:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00137}; // OUT(<Constant: value=137>, Cond=None, Flags=None)
		068:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00171}; // OUT(<Constant: value=171>, Cond=None, Flags=None)
		069:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00008}; // OUT(<Constant: value=8>, Cond=None, Flags=None)
		070:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00006}; // OUT(<Constant: value=6>, Cond=None, Flags=None)
		071:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		072:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		073:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00008}; // OUT(<Constant: value=8>, Cond=None, Flags=None)
		074:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		075:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00006}; // OUT(<Constant: value=6>, Cond=None, Flags=None)
		076:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00004}; // OUT(<Constant: value=4>, Cond=None, Flags=None)
		077:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		078:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00002}; // OUT(<Constant: value=2>, Cond=None, Flags=None)
		079:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		080:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00035}; // OUT(<Constant: value=35>, Cond=None, Flags=None)
		081:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00069}; // OUT(<Constant: value=69>, Cond=None, Flags=None)
		082:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00103}; // OUT(<Constant: value=103>, Cond=None, Flags=None)
		083:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00137}; // OUT(<Constant: value=137>, Cond=None, Flags=None)
		084:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00171}; // OUT(<Constant: value=171>, Cond=None, Flags=None)
		085:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00010}; // OUT(<Constant: value=10>, Cond=None, Flags=None)
		086:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		087:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		088:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00042}; // OUT(<Constant: value=42>, Cond=None, Flags=None)
		089:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		090:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		091:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		092:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		093:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		094:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		095:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		096:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		097:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		098:			code <= {2'b00, 4'b0101, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=[<AEOF>])
		099:			code <= {2'b01, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // RST(Cond=None, Flags=None)
		100:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		101:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		102:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		103:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		104:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		105:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		106:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		107:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		108:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		109:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00017}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=17>, Bytewide: True>]>, Flags=None)
		110:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		111:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		112:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		113:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		114:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		115:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		116:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		117:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00010}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=10>, Bytewide: True>]>, Flags=None)
		118:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		119:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00000}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=0>, Bytewide: True>]>, Flags=None)
		120:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		121:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00001}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=1>, Bytewide: True>]>, Flags=None)
		122:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		123:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd7, 2'd1, 9'd000, 16'd00042}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=42>, Bytewide: True>]>, Flags=None)
		124:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		125:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		126:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b1000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		127:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		128:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd3, 2'd1, 9'd000, 16'd12289}; // RST(Cond=<IF: pred=[<<Port>!=<Constant: value=12289>, Bytewide: False>]>, Flags=None)
		129:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		130:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		131:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		132:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		133:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		134:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		135:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd4, 2'd1, 9'd140, 16'd00000}; // JMP(140, Cond=<IF: pred=[<<Constant: value=0>==<Register: address=0, high=True, low=True, high_byte_s=False>, Bytewide: True>]>, Flags=None)
		136:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd4, 2'd1, 9'd161, 16'd00001}; // JMP(161, Cond=<IF: pred=[<<Constant: value=1>==<Register: address=0, high=True, low=True, high_byte_s=False>, Bytewide: True>]>, Flags=None)
		137:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd4, 2'd1, 9'd168, 16'd00002}; // JMP(168, Cond=<IF: pred=[<<Constant: value=2>==<Register: address=0, high=True, low=True, high_byte_s=False>, Bytewide: True>]>, Flags=None)
		138:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd1, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd4, 2'd1, 9'd190, 16'd00004}; // JMP(190, Cond=<IF: pred=[<<Constant: value=4>==<Register: address=0, high=True, low=True, high_byte_s=False>, Bytewide: True>]>, Flags=None)
		139:			code <= {2'b01, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // RST(Cond=None, Flags=None)
		140:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd09, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=9, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		141:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		142:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd1, 4'd06, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd3, 2'd1, 9'd000, 16'd00000}; // RST(Cond=<IF: pred=[<<Port>!=<Register: address=6, high=True, low=True, high_byte_s=False>, Bytewide: False>]>, Flags=None)
		143:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		144:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		145:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		146:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b10, 3'd2, 2'd0, 1'd0, 4'd09, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Register: address=9, high=True, low=True, high_byte_s=False>,<Output Port Register>, Cond=None, Flags=None)
		147:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd3, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd000, 16'd00001}; // SUB(<Register: address=0, high=True, low=True, high_byte_s=False>, <Constant: value=1>, <Register: address=0, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		148:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd3, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd157, 16'd00000}; // JMP(157, Cond=<IF: pred=[<<Register: address=0, high=True, low=True, high_byte_s=False>==<Constant: value=0>, Bytewide: False>]>, Flags=None)
		149:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0100, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=2>, Cond=None, Flags=None)
		150:			code <= {2'b00, 4'b0110, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0001, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=2>, Cond=None, Flags=[<ASOF>])
		151:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd3, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd000, 16'd00001}; // SUB(<Register: address=0, high=True, low=True, high_byte_s=False>, <Constant: value=1>, <Register: address=0, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		152:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd3, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd157, 16'd00000}; // JMP(157, Cond=<IF: pred=[<<Register: address=0, high=True, low=True, high_byte_s=False>==<Constant: value=0>, Bytewide: False>]>, Flags=None)
		153:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0100, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=2>, Cond=None, Flags=None)
		154:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0001, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=2>, Cond=None, Flags=None)
		155:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd3, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd000, 16'd00001}; // SUB(<Register: address=0, high=True, low=True, high_byte_s=False>, <Constant: value=1>, <Register: address=0, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		156:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd3, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd3, 2'd1, 9'd153, 16'd00000}; // JMP(153, Cond=<IF: pred=[<<Register: address=0, high=True, low=True, high_byte_s=False>!=<Constant: value=0>, Bytewide: False>]>, Flags=None)
		157:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0100, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=2>, Cond=None, Flags=None)
		158:			code <= {2'b00, 4'b0101, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0001, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=2>, Cond=None, Flags=[<AEOF>])
		159:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b10, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Output Port Register>, Cond=None, Flags=None)
		160:			code <= {2'b10, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd270, 16'd00000}; // JMP(270, Cond=None, Flags=None)
		161:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		162:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		163:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd08, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=8, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		164:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		165:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		166:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		167:			code <= {2'b01, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // RST(Cond=None, Flags=None)
		168:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		169:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		170:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		171:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		172:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		173:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd03, 2'd2, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=3, high=True, low=False, high_byte_s=False>
		174:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd03, 2'd1, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=3, high=False, low=True, high_byte_s=False>
		175:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd04, 2'd2, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=4, high=True, low=False, high_byte_s=False>
		176:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd04, 2'd1, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=4, high=False, low=True, high_byte_s=False>
		177:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd05, 2'd2, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=5, high=True, low=False, high_byte_s=False>
		178:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd05, 2'd1, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=5, high=False, low=True, high_byte_s=False>
		179:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd01, 2'd2, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=1, high=True, low=False, high_byte_s=False>
		180:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd01, 2'd1, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=1, high=False, low=True, high_byte_s=False>
		181:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd02, 2'd2, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=2, high=True, low=False, high_byte_s=False>
		182:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd02, 2'd1, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=2, high=False, low=True, high_byte_s=False>
		183:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd12, 2'd2, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=12, high=True, low=False, high_byte_s=False>
		184:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd12, 2'd1, 2'b00, 4'b1010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // Copy and Wrap SR:<Shif Register: sr_num=1> to R:<Register: address=12, high=False, low=True, high_byte_s=False>
		185:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd06, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Register: address=6, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		186:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd07, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Register: address=7, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		187:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd08, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Constant: value=0>,<Register: address=8, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		188:			code <= {2'b10, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd270, 16'd00000}; // JMP(270, Cond=None, Flags=None)
		189:			code <= {2'b01, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // RST(Cond=None, Flags=None)
		190:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd09, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=9, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		191:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		192:			code <= {2'b01, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd1, 1'd1, 4'd06, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd3, 2'd1, 9'd000, 16'd00000}; // RST(Cond=<IF: pred=[<<Port>!=<Register: address=6, high=True, low=True, high_byte_s=False>, Bytewide: False>]>, Flags=None)
		193:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		194:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b1, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<High Byte Register>, Cond=None, Flags=None)
		195:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		196:			code <= {2'b00, 4'b0110, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=[<ASOF>])
		197:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		198:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		199:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		200:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		201:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		202:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		203:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00035}; // OUT(<Constant: value=35>, Cond=None, Flags=None)
		204:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00069}; // OUT(<Constant: value=69>, Cond=None, Flags=None)
		205:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00103}; // OUT(<Constant: value=103>, Cond=None, Flags=None)
		206:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00137}; // OUT(<Constant: value=137>, Cond=None, Flags=None)
		207:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00171}; // OUT(<Constant: value=171>, Cond=None, Flags=None)
		208:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00008}; // OUT(<Constant: value=8>, Cond=None, Flags=None)
		209:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		210:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b01, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSC()
		211:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd17664}; // CSA(<Constant: value=17664>)
		212:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00069}; // OUT(<Constant: value=69>, Cond=None, Flags=None)
		213:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		214:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd0, 1'd1, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00034}; // ADD(<Constant: value=34>, <Register: address=0, high=True, low=True, high_byte_s=False>, <Register: address=0, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		215:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSA(<Register: address=0, high=True, low=True, high_byte_s=False>)
		216:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd1, 2'b00, 3'd2, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=0, high=True, low=True, high_byte_s=True>, Cond=None, Flags=None)
		217:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		218:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd3, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd000, 16'd00034}; // SUB(<Register: address=0, high=True, low=True, high_byte_s=False>, <Constant: value=34>, <Register: address=0, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		219:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		220:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		221:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		222:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		223:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd08209}; // CSA(<Constant: value=8209>)
		224:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00032}; // OUT(<Constant: value=32>, Cond=None, Flags=None)
		225:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00017}; // OUT(<Constant: value=17>, Cond=None, Flags=None)
		226:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd02560}; // CSA(<Constant: value=2560>)
		227:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00298}; // CSA(<Constant: value=298>)
		228:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd01, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSA(<Register: address=1, high=True, low=True, high_byte_s=False>)
		229:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd02, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSA(<Register: address=2, high=True, low=True, high_byte_s=False>)
		230:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd1, 2'b00, 3'd1, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Checksum: high_byte_s=True>, Cond=None, Flags=None)
		231:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd1, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Checksum: high_byte_s=False>, Cond=None, Flags=None)
		232:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00010}; // OUT(<Constant: value=10>, Cond=None, Flags=None)
		233:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		234:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		235:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00042}; // OUT(<Constant: value=42>, Cond=None, Flags=None)
		236:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		237:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		238:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		239:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		240:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b01, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSC()
		241:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd12289}; // CSA(<Constant: value=12289>)
		242:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd12, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSA(<Register: address=12, high=True, low=True, high_byte_s=False>)
		243:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00048}; // OUT(<Constant: value=48>, Cond=None, Flags=None)
		244:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		245:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		246:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		247:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd0, 1'd1, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00014}; // ADD(<Constant: value=14>, <Register: address=0, high=True, low=True, high_byte_s=False>, <Register: address=0, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		248:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd1, 2'b00, 3'd2, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=0, high=True, low=True, high_byte_s=True>, Cond=None, Flags=None)
		249:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		250:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSA(<Register: address=0, high=True, low=True, high_byte_s=False>)
		251:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd3, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd000, 16'd00014}; // SUB(<Register: address=0, high=True, low=True, high_byte_s=False>, <Constant: value=14>, <Register: address=0, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		252:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		253:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		254:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00005}; // OUT(<Constant: value=5>, Cond=None, Flags=None)
		255:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd09, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=9, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		256:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd1, 2'b00, 3'd2, 2'd0, 1'd0, 4'd06, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=6, high=True, low=True, high_byte_s=True>, Cond=None, Flags=None)
		257:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd06, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=6, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		258:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd0, 1'd1, 4'd06, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // ADD(<Constant: value=1>, <Register: address=6, high=True, low=True, high_byte_s=False>, <Register: address=6, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		259:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd1, 2'b00, 3'd2, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=0, high=True, low=True, high_byte_s=True>, Cond=None, Flags=None)
		260:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=0, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		261:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b01, 3'd2, 2'd0, 1'd0, 4'd09, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // MOV(<Register: address=9, high=True, low=True, high_byte_s=False>,<Input Port Register>, Cond=None, Flags=None)
		262:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd3, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd267, 16'd00001}; // JMP(267, Cond=<IF: pred=[<<Register: address=0, high=True, low=True, high_byte_s=False>==<Constant: value=1>, Bytewide: False>]>, Flags=None)
		263:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0100, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=2>, Cond=None, Flags=None)
		264:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0001, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=2>, Cond=None, Flags=None)
		265:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd3, 1'd0, 4'd00, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd1, 9'd000, 16'd00001}; // SUB(<Register: address=0, high=True, low=True, high_byte_s=False>, <Constant: value=1>, <Register: address=0, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		266:			code <= {2'b10, 4'b0000, 2'd2, 6'b000100, 1'b0, 1'd0, 2'b00, 3'd0, 2'd3, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd3, 2'd1, 9'd263, 16'd00001}; // JMP(263, Cond=<IF: pred=[<<Register: address=0, high=True, low=True, high_byte_s=False>!=<Constant: value=1>, Bytewide: False>]>, Flags=None)
		267:			code <= {2'b00, 4'b1000, 2'd0, 6'b000001, 1'b0, 1'd0, 2'b00, 3'd3, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0100, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // IN(<Shif Register: sr_num=2>, Cond=None, Flags=None)
		268:			code <= {2'b00, 4'b0101, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0001, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=2>, Cond=None, Flags=[<AEOF>])
		269:			code <= {2'b01, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // RST(Cond=None, Flags=None)
		270:			code <= {2'b00, 4'b0110, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=[<ASOF>])
		271:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		272:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		273:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		274:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		275:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		276:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		277:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00035}; // OUT(<Constant: value=35>, Cond=None, Flags=None)
		278:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00069}; // OUT(<Constant: value=69>, Cond=None, Flags=None)
		279:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00103}; // OUT(<Constant: value=103>, Cond=None, Flags=None)
		280:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00137}; // OUT(<Constant: value=137>, Cond=None, Flags=None)
		281:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00171}; // OUT(<Constant: value=171>, Cond=None, Flags=None)
		282:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00008}; // OUT(<Constant: value=8>, Cond=None, Flags=None)
		283:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		284:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b01, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSC()
		285:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd17664}; // CSA(<Constant: value=17664>)
		286:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00069}; // OUT(<Constant: value=69>, Cond=None, Flags=None)
		287:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		288:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00034}; // CSA(<Constant: value=34>)
		289:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		290:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00034}; // OUT(<Constant: value=34>, Cond=None, Flags=None)
		291:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		292:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		293:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		294:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		295:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd08209}; // CSA(<Constant: value=8209>)
		296:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00032}; // OUT(<Constant: value=32>, Cond=None, Flags=None)
		297:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00017}; // OUT(<Constant: value=17>, Cond=None, Flags=None)
		298:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd02560}; // CSA(<Constant: value=2560>)
		299:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00298}; // CSA(<Constant: value=298>)
		300:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd01, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSA(<Register: address=1, high=True, low=True, high_byte_s=False>)
		301:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd02, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSA(<Register: address=2, high=True, low=True, high_byte_s=False>)
		302:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd1, 2'b00, 3'd1, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Checksum: high_byte_s=True>, Cond=None, Flags=None)
		303:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd1, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Checksum: high_byte_s=False>, Cond=None, Flags=None)
		304:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00010}; // OUT(<Constant: value=10>, Cond=None, Flags=None)
		305:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		306:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		307:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00042}; // OUT(<Constant: value=42>, Cond=None, Flags=None)
		308:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		309:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		310:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		311:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		312:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00048}; // OUT(<Constant: value=48>, Cond=None, Flags=None)
		313:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		314:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b01, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSC()
		315:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd12289}; // CSA(<Constant: value=12289>)
		316:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd12, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // CSA(<Register: address=12, high=True, low=True, high_byte_s=False>)
		317:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		318:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd4, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0010, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Shif Register: sr_num=1>, Cond=None, Flags=None)
		319:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		320:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00014}; // OUT(<Constant: value=14>, Cond=None, Flags=None)
		321:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b10, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00006}; // CSA(<Constant: value=6>)
		322:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		323:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		324:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // OUT(<Constant: value=1>, Cond=None, Flags=None)
		325:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		326:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd1, 2'b00, 3'd2, 2'd0, 1'd0, 4'd06, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=6, high=True, low=True, high_byte_s=True>, Cond=None, Flags=None)
		327:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd2, 2'd0, 1'd0, 4'd06, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Register: address=6, high=True, low=True, high_byte_s=False>, Cond=None, Flags=None)
		328:			code <= {2'b00, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd5, 2'd0, 1'd1, 4'd06, 2'd3, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00001}; // ADD(<Constant: value=1>, <Register: address=6, high=True, low=True, high_byte_s=False>, <Register: address=6, high=True, low=True, high_byte_s=False>, Cond=NoneFlags=None)
		329:			code <= {2'b00, 4'b0100, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=None)
		330:			code <= {2'b00, 4'b0101, 2'd0, 6'b000010, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // OUT(<Constant: value=0>, Cond=None, Flags=[<AEOF>])
		331:			code <= {2'b01, 4'b0000, 2'd0, 6'b000000, 1'b0, 1'd0, 2'b00, 3'd0, 2'd0, 1'd0, 4'd00, 2'd0, 2'b00, 4'b0000, 1'b0, 3'd0, 2'd0, 9'd000, 16'd00000}; // RST(Cond=None, Flags=None)

	default: code <= 0;
	endcase
	
end
endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/regfile/regfile.v
// -----------------------------------------------------------------------------
// Register File
// Author: Peter Lieber
//

module regfile
(
	input				clk,
	input				rst,

	input				wren_low,
	input				wren_high,
	input		[3:0]	address,

	input		[15:0]	data_in,
	output	[15:0]	data_out
);

reg	[15:0]	mem[15:0];
wire				we;
wire	[15:0]	write_data;

assign data_out = mem[address];
assign we = wren_high | wren_low;
assign write_data = (wren_high & ~wren_low) ? {data_in[7:0], data_out[7:0]} :
							(~wren_high & wren_low) ? {data_out[15:8], data_in[7:0]} : 
							data_in;

always @(posedge clk)
begin
	if (we)
		mem[address] <= write_data;
end

endmodule 

// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/shiftr/gensrl.v
// -----------------------------------------------------------------------------
// Generic SRL 16 for use with V4/V5/?V6

module gensrl (
	input CLK,
	input D,
	input CE,
	input [3:0] A,
	output Q
);

reg [15:0] data;
assign Q = data[A];

always @(posedge CLK)
begin
	if (CE == 1'b1)
		data <= {data[14:0], D};
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/PATLPP/shiftr/shiftr.v
// -----------------------------------------------------------------------------
// Shift Register
// Author: Peter Lieber
//

module shiftr
(
	input				en_in,
	input				en_out,
	input				clk,
	input				rst,
	input				srst,

	input		[7:0]	data_in,
	output	[7:0] data_out
);

parameter DEPTH	= 16;
parameter DEPTHLOG = 4;

reg	[DEPTHLOG-1:0]		size;
reg							empty;

always @(posedge clk)
begin
	if (rst || srst)
	begin
		size <= 0;
		empty <= 1;
	end
	else if (empty == 1)
	begin
		if (en_in)
		begin
			empty <= 0;
		end
	end
	else
	begin
		if (en_in == 1 && en_out == 0)
		begin
			size <= size + 1;
		end
		else if (en_out == 1 && en_in == 0)
		begin
			if (size == 0)
				empty <= 1;
			else
				size <= size - 1;
		end
	end
end

genvar i;
generate
for (i=0; i<8; i=i+1)
begin : shiftregs
	gensrl shift_reg (
		.Q(data_out[i]),
		.A(size),
		.CE(en_in),
		.CLK(clk),
		.D(data_in[i])
	);
end
endgenerate

/*genvar i;
generate
for (i=0; i<8; i=i+1)
begin : shiftregs
	SRLC32E #(
		.INIT(32'h00000000)
	) shift_reg (
		.Q(data_out[i]),
		.Q31(),
		.A(size),
		.CE(en_in),
		.CLK(clk),
		.D(data_in[i])
	);
end
endgenerate*/

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/lpm/mux2/lpm_mux2.v
// -----------------------------------------------------------------------------
// LPM Mux
// Author: Peter Lieber
//

module lpm_mux2
(
	in0,
	in1,
	s,
	out
);

parameter WIDTH = 8;

input		wire		[WIDTH-1:0]		in0;
input		wire		[WIDTH-1:0]		in1;
input		wire							s;
output	reg 		[WIDTH-1:0] 	out;

always @(in0 or in1 or s)
begin
	case (s)
		0: out = in0;
		default: out = in1;
	endcase
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/lpm/mux4/lpm_mux4.v
// -----------------------------------------------------------------------------
// LPM Mux
// Author: Peter Lieber
//

module lpm_mux4
(
	in0,
	in1,
	in2,
	in3,
	s,
	out
);

parameter WIDTH = 8;

input		wire		[WIDTH-1:0]		in0;
input		wire		[WIDTH-1:0]		in1;
input		wire		[WIDTH-1:0]		in2;
input		wire		[WIDTH-1:0]		in3;
input		wire		[1:0]				s;
output	reg 		[WIDTH-1:0] 	out;

always @(in0 or in1 or in2 or in3 or s)
begin
	case (s)
		0: out = in0;
		1: out = in1;
		2: out = in2;
		default: out = in3;
	endcase
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/lpm/mux8/lpm_mux8.v
// -----------------------------------------------------------------------------
// LPM Mux
// Author: Peter Lieber
//

module lpm_mux8
(
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	s,
	out
);

parameter WIDTH = 8;

input		wire		[WIDTH-1:0]		in0;
input		wire		[WIDTH-1:0]		in1;
input		wire		[WIDTH-1:0]		in2;
input		wire		[WIDTH-1:0]		in3;
input		wire		[WIDTH-1:0]		in4;
input		wire		[WIDTH-1:0]		in5;
input		wire		[WIDTH-1:0]		in6;
input		wire		[WIDTH-1:0]		in7;
input		wire		[2:0]				s;
output	reg 		[WIDTH-1:0] 	out;

always @(in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 or s)
begin
	case (s)
		0: out = in0;
		1: out = in1;
		2: out = in2;
		3: out = in3;
		4: out = in4;
		5: out = in5;
		6: out = in6;
		default: out = in7;
	endcase
end

endmodule

// -----------------------------------------------------------------------------
// Source file: hdl/lpm/stopar/lpm_stopar.v
// -----------------------------------------------------------------------------
// Serial to Parallel Shift Register
// Author: Peter Lieber
//

module lpm_stopar(clk,rst,sin,en,pout);

parameter WIDTH = 8;
parameter DEPTH = 2;

input		wire								clk;
input		wire								rst;
input		wire	[(WIDTH-1):0]			sin;
input		wire								en;
output	wire	[(WIDTH*DEPTH-1):0]	pout;

reg	[(WIDTH-1):0]	highreg;

always @(posedge clk)
begin
	if (rst == 1)
		highreg <= 0;
	else if (en == 1)
	begin
		highreg <= sin;
	end
end

assign pout = {highreg, sin};

endmodule
