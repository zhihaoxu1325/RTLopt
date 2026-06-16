// Curated RTL benchmark case.
// case_id: bench_0076_crypto_core_high_throughput_and_low_area_aes_core
// source_project: crypto_core_high_throughput_and_low_area_aes_core
// top_module: aes


// -----------------------------------------------------------------------------
// Source file: verilog/rtl/aes.v
// -----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
// 
//	AES core top module 
// 
//	Description: 
//		AES core top module with direct interface to key and data buses. 
// 
//	To Do: 
//		- done 
//
//	Author(s):
//		- Luo Dongjun,   dongjun_luo@hotmail.com 
//
//---------------------------------------------------------------------------------------

// uncomment the following define to enable use of distributed RAM implementation 
// for XILINX FPGAs instead of block memory.
// NOTE: when commenting the following define, core size is slightly smaller but maximum 
// achievable clock frequency is also slightly lower. 
`define XILINX		1 

module aes (
	clk, reset,
	i_start, i_enable,
	i_ende, i_key,
	i_key_mode, i_data,
	i_data_valid, o_ready, 
	o_data, o_data_valid, 
	o_key_ready
);
 
//---------------------------------------------------------------------------------------
// module interfaces 
input			clk;		// core global clock 
input			reset;		// core global async reset control 
input			i_start;	// key expansion start pulse 
input			i_enable;	// enable encryption / decryption core operation 
input	[1:0]	i_key_mode; // key length: 0 => 128; 1 => 192; 2 => 256
input	[255:0]	i_key; 		// if key size is 128/192, upper bits are the inputs 
input	[127:0]	i_data;		// plain/cipher text data input 
input			i_data_valid;	// data input valid 
input			i_ende;		// core mode of operation: 0 => encryption; 1 => decryption
output			o_ready;	// indicates core is ready for new input data at the next clock cycle 
output	[127:0]	o_data;		// data output 
output			o_data_valid;	// data output valid 
output			o_key_ready;	// key expansion procedure done 

//---------------------------------------------------------------------------------------
// module registers and signals 
genvar i;
wire           final_round;
reg   [3:0]    max_round;
wire  [127:0]  en_sb_data,de_sb_data,sr_data,mc_data,imc_data,ark_data;
reg   [127:0]  sb_data,o_data,i_data_L;
reg            i_data_valid_L;
reg            round_valid;
reg   [2:0]    sb_valid;
reg            o_data_valid;
reg   [3:0]    round_cnt,sb_round_cnt1,sb_round_cnt2,sb_round_cnt3;
wire  [127:0]  round_key;
wire  [63:0]   rd_data0,rd_data1;
wire           wr;
wire  [4:0]    wr_addr;
wire  [63:0]   wr_data;
wire  [127:0]  imc_round_key,en_ark_data,de_ark_data,ark_data_final,ark_data_init;

//---------------------------------------------------------------------------------------
// module implementation 
assign final_round = sb_round_cnt3[3:0] == max_round[3:0];
//assign o_ready = ~sb_valid[1]; // if ready is asserted, user can input data for the same cycle
assign o_ready = ~sb_valid[0]; // if ready is asserted, user can input data for the next cycle
 
// round count is Nr - 1
always @ (*)
begin
   case (i_key_mode)
      2'b00: max_round[3:0] = 4'd10;
      2'b01: max_round[3:0] = 4'd12;
      default: max_round[3:0] = 4'd14;
   endcase
end
 
//---------------------------------------------------------------------------------------
// Sub Bytes
//
//
generate
for (i=0;i<16;i=i+1)
begin : sbox_block
   sbox u_sbox (
      .clk(clk),
      .reset(reset),
      .enable(i_enable),
      .ende(i_ende),
      .din(o_data[i*8+7:i*8]),
      .en_dout(en_sb_data[i*8+7:i*8]),
      .de_dout(de_sb_data[i*8+7:i*8])
   );
end
endgenerate
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      sb_data[127:0] <= 128'b0;
   else if (i_enable)
      sb_data[127:0] <= i_ende ? de_sb_data[127:0] : en_sb_data[127:0];
end
 
//---------------------------------------------------------------------------------------
// Shift Rows
//
//
wire [127:0] shrows, ishrows;

shift_rows u_shrows (.si(sb_data[127:0]), .so(shrows));
inv_shift_rows u_ishrows (.si(sb_data[127:0]), .so(ishrows));

assign sr_data[127:0] = i_ende ? ishrows : shrows;
 
//---------------------------------------------------------------------------------------
// Mix Columns
//
//
mix_columns mxc_u (.in(sr_data), .out(mc_data));
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      i_data_valid_L  <= 1'b0;
      i_data_L[127:0] <= 128'b0;
   end
   else
   begin
      i_data_valid_L  <= i_data_valid;
      i_data_L[127:0] <=i_data[127:0];
   end
end
 
//---------------------------------------------------------------------------------------
// Inverse Mix Columns
//
//
inv_mix_columns imxc_u (.in(sr_data), .out(imc_data));

//---------------------------------------------------------------------------------------
// add round key for decryption
//
inv_mix_columns imxk_u (.in(round_key), .out(imc_round_key));

assign ark_data_final[127:0] = sr_data[127:0] ^ round_key[127:0];
assign ark_data_init[127:0] = i_data_L[127:0] ^ round_key[127:0];
assign en_ark_data[127:0] = mc_data[127:0] ^ round_key[127:0];
assign de_ark_data[127:0] = imc_data[127:0] ^ imc_round_key[127:0];
assign ark_data[127:0] = i_data_valid_L ? ark_data_init[127:0] : 
                           (final_round ? ark_data_final[127:0] : 
                                (i_ende ? de_ark_data[127:0] : en_ark_data[127:0]));
 
//---------------------------------------------------------------------------------------
// Data outputs after each round
//
always @ (posedge clk or posedge reset)
begin
   if (reset)
      o_data[127:0] <= 128'b0;
   else if (i_enable && (i_data_valid_L || sb_valid[2]))
      o_data[127:0] <= ark_data[127:0];
end
 
//---------------------------------------------------------------------------------------
// in sbox, we have 3 stages (sb_valid),
// before the end of each round, we have another stage (round_valid)
//
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      round_valid  <= 1'b0;
      sb_valid[2:0] <= 3'b0;
      o_data_valid  <= 1'b0;
   end
   else if (i_enable)
   begin
      o_data_valid  <= sb_valid[2] && final_round;
      round_valid   <= (sb_valid[2] && !final_round) || i_data_valid_L;
      sb_valid[2:0] <= {sb_valid[1:0],round_valid};
   end
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)                      round_cnt[3:0] <= 4'd0;
   else if (i_data_valid_L) round_cnt[3:0] <= 4'd1;
   else if (i_enable && sb_valid[2])  round_cnt[3:0] <= sb_round_cnt3[3:0] + 1'b1;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      sb_round_cnt1[3:0] <= 4'd0;
      sb_round_cnt2[3:0] <= 4'd0;
      sb_round_cnt3[3:0] <= 4'd0;
   end
   else if (i_enable)
   begin
      if (round_valid) sb_round_cnt1[3:0] <= round_cnt[3:0];
      if (sb_valid[0]) sb_round_cnt2[3:0] <= sb_round_cnt1[3:0];
      if (sb_valid[1]) sb_round_cnt3[3:0] <= sb_round_cnt2[3:0];
   end
end
 
//---------------------------------------------------------------------------------------
// round key generation: the expansion keys are stored in 4 16*32 rams or 
// 2 16*64 rams or 1 16*128 rams
//
//assign rd_addr[3:0] = i_ende ? (max_round[3:0] - sb_round_cnt2[3:0]) : sb_round_cnt2[3:0];

assign round_key[127:0] = {rd_data0[63:0],rd_data1[63:0]};

`ifdef XILINX 
reg [3:0] rd_addr;

always @ (posedge clk or posedge reset)
begin 
	if (reset)
		rd_addr <= 4'b0;
	else if (sb_valid[1] | i_data_valid) 
	begin 
		if (i_ende) 
		begin 
			if (i_data_valid)
				rd_addr <= max_round[3:0];
			else 
				rd_addr <= max_round[3:0] - sb_round_cnt2[3:0];
		end 
		else 
		begin 
			if (i_data_valid) 
				rd_addr <= 4'b0;
			else 
				rd_addr <= sb_round_cnt2[3:0];
		end 
	end 
end 

xram_16x64 u_ram_0 
(
	.clk(clk),
	.wr(wr & ~wr_addr[0]),
	.wr_addr(wr_addr[4:1]),
	.wr_data(wr_data[63:0]),
	.rd_addr(rd_addr[3:0]),
	.rd_data(rd_data0[63:0])
);
xram_16x64 u_ram_1 
(
	.clk(clk),
	.wr(wr & wr_addr[0]),
	.wr_addr(wr_addr[4:1]),
	.wr_data(wr_data[63:0]),
	.rd_addr(rd_addr[3:0]),
	.rd_data(rd_data1[63:0])
);
`else 
wire [3:0] rd_addr;

assign rd_addr[3:0] = i_ende ? (i_data_valid ? max_round[3:0] : (max_round[3:0] - sb_round_cnt2[3:0])) : 
                               (i_data_valid ? 4'b0 : sb_round_cnt2[3:0]);

ram_16x64 u_ram_0 
(
	.clk(clk),
	.wr(wr & ~wr_addr[0]),
	.wr_addr(wr_addr[4:1]),
	.wr_data(wr_data[63:0]),
	.rd_addr(rd_addr[3:0]),
	.rd_data(rd_data0[63:0]),
	.rd(sb_valid[1] | i_data_valid)
);
ram_16x64 u_ram_1 
(
	.clk(clk),
	.wr(wr & wr_addr[0]),
	.wr_addr(wr_addr[4:1]),
	.wr_data(wr_data[63:0]),
	.rd_addr(rd_addr[3:0]),
	.rd_data(rd_data1[63:0]),
	.rd(sb_valid[1] | i_data_valid)
);
`endif 
//---------------------------------------------------------------------------------------
// Key Expansion module
//
//
key_exp u_key_exp (
   .clk(clk),
   .reset(reset),
   .key_in(i_key[255:0]),
   .key_mode(i_key_mode[1:0]),
   .key_start(i_start),
   .wr(wr),
   .wr_addr(wr_addr[4:0]),
   .wr_data(wr_data[63:0]),
   .key_ready(o_key_ready)
);
 
endmodule
//---------------------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Source file: verilog/rtl/inv_shift_rows.v
// -----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//
//  inv_shift_rows module file (converted from inv_shift_rows function)
//
//  Description:
//     shift rows for encryption
//
//  Author(s):
//      - Moti Litochevski
//
//---------------------------------------------------------------------------------------

module inv_shift_rows (
	si, so 
);
 
input	[127:0]	si;
output	[127:0]	so;
 
wire [127:0] so;

assign 	so[127:96] = {si[127:120],si[23:16],si[47:40],si[71:64]};
assign 	so[95:64] = {si[95:88],si[119:112],si[15:8],si[39:32]};
assign 	so[63:32] = {si[63:56],si[87:80],si[111:104],si[7:0]};
assign 	so[31:0] = {si[31:24],si[55:48],si[79:72],si[103:96]};
                                                                 
endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/rtl/key_exp.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Key expansion module                                        ////
////                                                              ////
////  Description:                                                ////
////  Used to expand the key based on key expansion procudure     ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Luo Dongjun,   dongjun_luo@hotmail.com                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module key_exp (
   clk,
   reset,
   key_in,
   key_mode,
   key_start,
   wr,
   wr_addr,
   wr_data,
   key_ready
);
 
input             clk;
input             reset;
input   [255:0]   key_in;   // initial key value
input   [1:0]     key_mode; // 0:128, 1:192, 2:256
input             key_start;// start key expansion
output            wr;       // key expansion ram interface
output  [4:0]     wr_addr;
output  [63:0]    wr_data;
output            key_ready;
 
reg [31:0]  rcon;
reg         rcon_is_1b;
reg [1:0]   state,nstate,pstate;
reg [3:0]   round;
reg         sbox_in_valid;
reg [31:0]  sbox_in;
reg [4:0]   valid;
wire        sbox_out_valid;
wire [31:0] sbox_out;
wire [31:0] w0_next,w1_next,w2_next,w3_next,w4_next1,w5_next1,w6_next,w7_next;
wire [31:0] w4_next2,w5_next2;
reg [31:0]  w0,w1,w2,w3,w4,w5,w6,w7;
wire        wr1,wr2,wr3,init_wr1,init_wr2,init_wr3,init_wr4;
reg         wr;
wire [63:0] wr_data1,wr_data2,wr_data3;
reg         key_start_L,key_start_L2,key_start_L3;
reg         wr_256;
reg [4:0]   wr_addr;
reg [63:0]  wr_data;
reg         key_ready;
wire   [3:0] max_round_p1;
 
parameter   IDLE       = 2'b00,
            START      = 2'b01,
            GENKEY1    = 2'b10,
            GENKEY_256 = 2'b11;
 
assign max_round_p1[3:0] = (key_mode == 2'b00) ? 4'd11 : (key_mode == 2'b01 ? 4'd13 : 4'd15);
 
// rcon generation
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      rcon[31:0] <= 32'h01000000;
      rcon_is_1b <= 1'b0;
   end
   else if (key_start)
   begin
      rcon[31:0] <= 32'h01000000;
      rcon_is_1b <= 1'b0;
   end
   else if (sbox_out_valid && (state[1:0] == GENKEY1))
   begin
      if (rcon[31])
      begin
         rcon[31:0] <= 32'h1b000000;
         rcon_is_1b <= 1'b1;
      end
      else if (rcon_is_1b)
      begin
         rcon[31:0] <= 32'h36000000;
         rcon_is_1b <= 1'b1;
      end
      else
         rcon[31:0] <= {rcon[30:0],1'b0};
   end
end
 
/*****************************************************************************/
// State machine for Key expansion
//
//
always @ (posedge clk or posedge reset)
begin
   if (reset)   
   begin
      state[1:0]  <= IDLE;
      pstate[1:0] <= IDLE;
   end
   else
   begin
      state[1:0]  <= nstate[1:0];
      pstate[1:0] <= state[1:0];
   end
end
 
always @ (*)
begin
   nstate[1:0] = state[1:0];
   case (state[1:0])
      IDLE: 
         if (key_start) nstate[1:0] = START;
      START:
      begin
         nstate[1:0] = GENKEY1;
      end
      GENKEY1:
      begin
         if (sbox_out_valid)
         begin
            if (key_mode == 2'b00) //128 bit mode 4 x 10 + 4
               if (round[3:0] == 4'd10)   nstate[1:0] = IDLE;
               else                       nstate[1:0] = START;
            else if (key_mode == 2'b01) // 192 bit mode 6 + 6 x 8 = 54 > 52
               if (round[3:0] == 4'd8) nstate[1:0] = IDLE;
               else                    nstate[1:0] = START;
            else if (round[3:0] == 4'd7)// 256 bit mode 8 + 8 x 7 = 64 > 60
               nstate[1:0] = IDLE;
            else
               nstate[1:0] = GENKEY_256;
         end
      end
      GENKEY_256:
      begin
         if (sbox_out_valid)
            nstate[1:0] = START;
      end
   endcase
end
 
// round counter: 10/12/14
always @ (posedge clk or posedge reset)
begin
   if (reset)
      round[3:0] <= 1'b0;
   else if (nstate[1:0] == IDLE)
      round[3:0] <= 4'b0;
   else if (state[1:0] == START)
      round[3:0] <= round[3:0] + 1'b1;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      sbox_in_valid <= 1'b0;
      sbox_in[31:0] <= 32'b0;
   end
   else if (state[1:0] == START) // rotword
   begin
      sbox_in_valid <= 1'b1;
      if (key_mode == 2'b00) //128
         sbox_in[31:0] <= {w3[23:0],w3[31:24]};
      else if (key_mode == 2'b01) //192
         sbox_in[31:0] <= {w5[23:0],w5[31:24]};
      else //256
         sbox_in[31:0] <= {w7[23:0],w7[31:24]};
   end
   else if ((state[1:0] == GENKEY_256) && (pstate[1:0] ==GENKEY1))
   begin
      sbox_in_valid <= 1'b1;
      sbox_in[31:0] <= w3[31:0];
   end
   else
      sbox_in_valid <= 1'b0;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      valid[4:0] <= 5'b0;
   else
      valid[4:0] <= {valid[3:0],sbox_in_valid};
end
assign sbox_out_valid = valid[1];
 
sbox u_0(.clk(clk),.reset(reset),.enable(1'b1),.din(sbox_in[7:0]),.ende(1'b0),.en_dout(sbox_out[7:0]),.de_dout());
sbox u_1(.clk(clk),.reset(reset),.enable(1'b1),.din(sbox_in[15:8]),.ende(1'b0),.en_dout(sbox_out[15:8]),.de_dout());
sbox u_2(.clk(clk),.reset(reset),.enable(1'b1),.din(sbox_in[23:16]),.ende(1'b0),.en_dout(sbox_out[23:16]),.de_dout());
sbox u_3(.clk(clk),.reset(reset),.enable(1'b1),.din(sbox_in[31:24]),.ende(1'b0),.en_dout(sbox_out[31:24]),.de_dout());
 
/*****************************************************************************/
// key expansion calculation
//
//
assign w0_next[31:0]  = sbox_out[31:0] ^ rcon[31:0]^w0[31:0];
assign w1_next[31:0]  = w0_next[31:0]  ^ w1[31:0];
assign w2_next[31:0]  = w1_next[31:0]  ^ w2[31:0];
assign w3_next[31:0]  = w2_next[31:0]  ^ w3[31:0];
assign w4_next1[31:0] = w3_next[31:0]  ^ w4[31:0];
assign w5_next1[31:0] = w4_next1[31:0] ^ w5[31:0];
assign w4_next2[31:0] = sbox_out[31:0] ^ w4[31:0];
assign w5_next2[31:0] = w4_next2[31:0] ^ w5[31:0];
assign w6_next[31:0]  = w5_next2[31:0] ^ w6[31:0];
assign w7_next[31:0]  = w6_next[31:0]  ^ w7[31:0];
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      {w0[31:0],w1[31:0],w2[31:0],w3[31:0],w4[31:0],w5[31:0],w6[31:0],w7[31:0]} <= 256'b0;
   end
   else if (key_start)
   begin
      {w0[31:0],w1[31:0],w2[31:0],w3[31:0],w4[31:0],w5[31:0],w6[31:0],w7[31:0]} <= key_in[255:0];
   end
   else if ((key_mode[1:0] == 2'b10) && sbox_out_valid)
   begin
      if (state[1:0] == GENKEY1)
      begin
         w0[31:0] <= w0_next[31:0];
         w1[31:0] <= w1_next[31:0];
         w2[31:0] <= w2_next[31:0];
         w3[31:0] <= w3_next[31:0];
      end
      else
      begin
         w4[31:0] <= w4_next2[31:0];
         w5[31:0] <= w5_next2[31:0];
         w6[31:0] <= w6_next[31:0];
         w7[31:0] <= w7_next[31:0];
      end
   end
   else if (sbox_out_valid)
   begin
      w0[31:0] <= w0_next[31:0];
      w1[31:0] <= w1_next[31:0];
      w2[31:0] <= w2_next[31:0];
      w3[31:0] <= w3_next[31:0];
      if (key_mode[1:0] == 2'b01)
      begin
         w4[31:0] <= w4_next1[31:0];
         w5[31:0] <= w5_next1[31:0];
      end
   end
end
 
// write to external ram
assign init_wr1 = key_start;
assign init_wr2 = key_start_L;
assign init_wr3 = key_start_L2 && (key_mode[1:0] != 2'b00);
assign init_wr4 = key_start_L3 && (key_mode[1:0] == 2'b10);
assign wr1 = valid[2];
assign wr2 = valid[3];
assign wr3 = valid[4] && (key_mode[1:0] == 2'b01) && (state[1:0] != IDLE); // remove the last write 
 
assign wr_data1[63:0] = wr_256 ?{w4[31:0],w5[31:0]} : {w0[31:0],w1[31:0]};
assign wr_data2[63:0] = wr_256 ?{w6[31:0],w7[31:0]} : {w2[31:0],w3[31:0]};
assign wr_data3[63:0] = {w4[31:0],w5[31:0]};
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      wr_256 <= 1'b0;
   else if (key_start)
      wr_256 <= 1'b0;
   else if (sbox_out_valid && (state[1:0] == GENKEY_256))
      wr_256 <= 1'b1;
   else if (sbox_out_valid)
      wr_256 <= 1'b0;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      {key_start_L3,key_start_L2,key_start_L} <= 3'b0;
   else
      {key_start_L3,key_start_L2,key_start_L} <= {key_start_L2,key_start_L,key_start};
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      wr <= 1'b0;
   else 
      wr <= wr1 || wr2 || wr3 || init_wr1 || init_wr2 || init_wr3 || init_wr4;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
   begin
      wr_data[63:0] <= 64'b0;
   end
   else
   begin
      if (init_wr1)
         wr_data[63:0] <= key_in[255:192];
      else if (init_wr2)
         wr_data[63:0] <= key_in[191:128];
      else if (init_wr3)
         wr_data[63:0] <= key_in[127:64];
      else if (init_wr4)
         wr_data[63:0] <= key_in[63:0];
      else if (wr1)
         wr_data[63:0] <= wr_data1[63:0];
      else if (wr2)
         wr_data[63:0] <= wr_data2[63:0];
      else if (wr3)
         wr_data[63:0] <= wr_data3[63:0];
   end
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      wr_addr[4:0] <= 5'b0;
   else if (key_start)
      wr_addr[4:0] <= 5'd0;
   else if (wr)
      wr_addr[4:0] <= wr_addr[4:0] + 1'b1;
end
 
always @ (posedge clk or posedge reset)
begin
   if (reset)
      key_ready <= 1'b0;
   else if (key_start)
      key_ready <= 1'b0;
   else if (wr_addr[4:1] == max_round_p1[3:0])
      key_ready <= 1'b1;
end
endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/rtl/mix_columns.v
// -----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//
//	mix_columns modules file (converted from mix_columns functions)
//
//	Description:
//		This file includes all functions implemented in the mix_columns.v original file 
//		but implemented as modules. 
//
//  Author(s):
//      - Moti Litochevski
//
//---------------------------------------------------------------------------------------

// (multiply 2)
module xtimes (
	in, out
);
 
input	[7:0]	in;
output	[7:0]	out;
 
wire [3:0] xt;

assign xt[3] = in[7];
assign xt[2] = in[7];
assign xt[1] = 1'b0;
assign xt[0] = in[7];

assign out[7:5] = in[6:4];
assign out[4:1] = xt[3:0] ^ in[3:0];
assign out[0]   = in[7];

endmodule
//---------------------------------------------------------------------------------------
// multiply 3
module MUL3 (
	in, out
);
 
input	[7:0]	in;
output	[7:0]	out;
 
wire [7:0] xt;

xtimes xt_u (.in(in), .out(xt));

assign out = xt ^ in;

endmodule
//---------------------------------------------------------------------------------------
// multiply E
module MULE (
	in, out
);
 
input	[7:0]	in;
output	[7:0]	out;
 
wire [7:0] xt1, xt2, xt3;

xtimes xt_u1 (.in(in), .out(xt1));
xtimes xt_u2 (.in(xt1), .out(xt2));
xtimes xt_u3 (.in(xt2), .out(xt3));

assign out = xt3 ^ xt2 ^ xt1;

endmodule
//---------------------------------------------------------------------------------------
// multiply B
module MULB (
	in, out
);
 
input	[7:0]	in;
output	[7:0]	out;
 
wire [7:0] xt1, xt2, xt3;

xtimes xt_u1 (.in(in), .out(xt1));
xtimes xt_u2 (.in(xt1), .out(xt2));
xtimes xt_u3 (.in(xt2), .out(xt3));

assign out = xt3 ^ xt1 ^ in;

endmodule
//---------------------------------------------------------------------------------------
// multiply D
module MULD (
	in, out
);
 
input	[7:0]	in;
output	[7:0]	out;
 
wire [7:0] xt1, xt2, xt3;

xtimes xt_u1 (.in(in), .out(xt1));
xtimes xt_u2 (.in(xt1), .out(xt2));
xtimes xt_u3 (.in(xt2), .out(xt3));

assign out = xt3 ^ xt2 ^ in;

endmodule
//---------------------------------------------------------------------------------------
// multiply 9
module MUL9 (
	in, out
);
 
input	[7:0]	in;
output	[7:0]	out;
 
wire [7:0] xt1, xt2, xt3;

xtimes xt_u1 (.in(in), .out(xt1));
xtimes xt_u2 (.in(xt1), .out(xt2));
xtimes xt_u3 (.in(xt2), .out(xt3));

assign out = xt3 ^ in;

endmodule
//---------------------------------------------------------------------------------------
module byte_mix_columns (
	a, b, c, d, out
);
 
input	[7:0]	a, b, c, d;
output	[7:0]	out;
 
wire [7:0] mul2, mul3;

xtimes xt_u (.in(a), .out(mul2));
MUL3 mul3_u (.in(b), .out(mul3));

assign out = mul2 ^ mul3 ^ c ^ d;

endmodule
//---------------------------------------------------------------------------------------
module inv_byte_mix_columns (
	a, b, c, d, out
);
 
input	[7:0]	a, b, c, d;
output	[7:0]	out;
 
wire [7:0] mule, mulb, muld, mul9;

MULE mule_u (.in(a), .out(mule));
MULB mulb_u (.in(b), .out(mulb));
MULD muld_u (.in(c), .out(muld));
MUL9 mul9_u (.in(d), .out(mul9));

assign out = mule ^ mulb ^ muld ^ mul9;

endmodule
//---------------------------------------------------------------------------------------
// Mix Columns for encryption word
module word_mix_columns (
	in, out
);
 
input	[31:0]	in;
output	[31:0]	out;
 
wire [7:0] si0,si1,si2,si3;
wire [7:0] so0,so1,so2,so3;

assign si0[7:0] = in[31:24];
assign si1[7:0] = in[23:16];
assign si2[7:0] = in[15:8];
assign si3[7:0] = in[7:0];

byte_mix_columns so0_u (.a(si0), .b(si1), .c(si2), .d(si3), .out(so0));
byte_mix_columns so1_u (.a(si1), .b(si2), .c(si3), .d(si0), .out(so1));
byte_mix_columns so2_u (.a(si2), .b(si3), .c(si0), .d(si1), .out(so2));
byte_mix_columns so3_u (.a(si3), .b(si0), .c(si1), .d(si2), .out(so3));

assign out = {so0, so1, so2, so3};

endmodule
//---------------------------------------------------------------------------------------
// inverse Mix Columns for decryption word
module inv_word_mix_columns (
	in, out
);
 
input	[31:0]	in;
output	[31:0]	out;
 
wire [7:0] si0,si1,si2,si3;
wire [7:0] so0,so1,so2,so3;

assign si0 = in[31:24];
assign si1 = in[23:16];
assign si2 = in[15:8];
assign si3 = in[7:0];
	
inv_byte_mix_columns so0_u (.a(si0), .b(si1), .c(si2), .d(si3), .out(so0));
inv_byte_mix_columns so1_u (.a(si1), .b(si2), .c(si3), .d(si0), .out(so1));
inv_byte_mix_columns so2_u (.a(si2), .b(si3), .c(si0), .d(si1), .out(so2));
inv_byte_mix_columns so3_u (.a(si3), .b(si0), .c(si1), .d(si2), .out(so3));
	
assign out = {so0, so1, so2, so3};

endmodule
//---------------------------------------------------------------------------------------
// Mix columns size: 4 words
module mix_columns (
	in, out
);
 
input	[127:0]	in;
output	[127:0]	out;

wire [31:0] so0,so1,so2,so3;

word_mix_columns so0_u (.in(in[127:96]), .out(so0));
word_mix_columns so1_u (.in(in[95:64]),  .out(so1));
word_mix_columns so2_u (.in(in[63:32]),  .out(so2));
word_mix_columns so3_u (.in(in[31:0]),   .out(so3));

assign out = {so0, so1, so2, so3};

endmodule
//---------------------------------------------------------------------------------------
// Inverse Mix columns size: 4 words
module inv_mix_columns (
	in, out
);
 
input	[127:0]	in;
output	[127:0]	out;

wire [31:0] so0,so1,so2,so3;

inv_word_mix_columns so0_u (.in(in[127:96]), .out(so0));
inv_word_mix_columns so1_u (.in(in[95:64]),  .out(so1));
inv_word_mix_columns so2_u (.in(in[63:32]),  .out(so2));
inv_word_mix_columns so3_u (.in(in[31:0]),   .out(so3));

assign out = {so0, so1, so2, so3};

endmodule
//---------------------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Source file: verilog/rtl/ram_16x64.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Ram module                                                  ////
////                                                              ////
////  Description:                                                ////
////  this is 16x64, we can use a 16x128 to replace two of this   ////
////    module, also, can use specific foundry libs instead       ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Luo Dongjun,   dongjun_luo@hotmail.com                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module ram_16x64 (clk,wr,wr_addr,wr_data,rd,rd_addr,rd_data);
 
input clk,wr,rd;
input [3:0] wr_addr,rd_addr;
input [63:0] wr_data;
output [63:0] rd_data;
 
reg [63:0] mem[15:0];
wire [63:0] rd_data;
 
// behavioral code for 16x64 mem
always @ (posedge clk)
begin
   if (wr)
      mem[wr_addr] <= wr_data;
end
 
reg [3:0] srd_addr;

always @ (posedge clk)
begin
	if (rd) 
		srd_addr <= rd_addr;
end 

assign rd_data = mem[srd_addr];

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/rtl/sbox.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Sub Bytes Box file                                          ////
////                                                              ////
////  Description:                                                ////
////  Implement sub byte box look up table                        ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Luo Dongjun,   dongjun_luo@hotmail.com                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module sbox(
	clk,
	reset,
	enable,
	din,
	ende,
	en_dout,
	de_dout);
 
input		clk;
input		reset;
input		enable;
input	[7:0]	din;
input		ende;  //0: encryption;  1: decryption
output	[7:0]	en_dout;
output	[7:0]	de_dout;
 
wire [7:0] first_matrix_out,first_matrix_in,last_matrix_out_enc,last_matrix_out_dec;
wire [3:0] p,q,p2,q2,sumpq,sump2q2,inv_sump2q2,p_new,q_new,mulpq,q2B;
reg [7:0]  first_matrix_out_L;
reg [3:0]  p_new_L,q_new_L;
 
// GF(256) to GF(16) transformation
assign first_matrix_in[7:0] = ende ? INV_AFFINE(din[7:0]): din[7:0];
assign first_matrix_out[7:0] = GF256_TO_GF16(first_matrix_in[7:0]);
 
// pipeline 1
always @ (posedge clk or posedge reset)
begin
	if (reset)
		first_matrix_out_L[7:0] <= 8'b0;
	else if (enable)
		first_matrix_out_L[7:0] <= first_matrix_out[7:0];
end
 
/*****************************************************************************/
// GF16 inverse logic
/*****************************************************************************/
//                     p+q _____ 
//                              \
//  p --> p2 ___                 \
//   \          \                 x --> p_new
//    x -> p*q -- + --> inverse -/
//   /          /                \
//  q --> q2*B-/                  x --> q_new 
//   \___________________________/
//
assign p[3:0] = first_matrix_out_L[3:0];
assign q[3:0] = first_matrix_out_L[7:4];
assign p2[3:0] = SQUARE(p[3:0]);
assign q2[3:0] = SQUARE(q[3:0]);
//p+q
assign sumpq[3:0] = p[3:0] ^ q[3:0];
//p*q
assign mulpq[3:0] = MUL(p[3:0],q[3:0]);
//q2B calculation
assign q2B[0]=q2[1]^q2[2]^q2[3];
assign q2B[1]=q2[0]^q2[1];
assign q2B[2]=q2[0]^q2[1]^q2[2];
assign q2B[3]=q2[0]^q2[1]^q2[2]^q2[3];
//p2+p*q+q2B
assign sump2q2[3:0] = q2B[3:0] ^ mulpq[3:0] ^ p2[3:0];
// inverse p2+pq+q2B
assign inv_sump2q2[3:0] = INVERSE(sump2q2[3:0]);
// results
assign p_new[3:0] = MUL(sumpq[3:0],inv_sump2q2[3:0]);
assign q_new[3:0] = MUL(q[3:0],inv_sump2q2[3:0]);
 
// pipeline 2
always @ (posedge clk or posedge reset)
begin
	if (reset)
		{p_new_L[3:0],q_new_L[3:0]} <= 8'b0;
	else if (enable)
		{p_new_L[3:0],q_new_L[3:0]} <= {p_new[3:0],q_new[3:0]};
end
 
// GF(16) to GF(256) transformation
assign last_matrix_out_dec[7:0] = GF16_TO_GF256(p_new_L[3:0],q_new_L[3:0]);
assign last_matrix_out_enc[7:0] = AFFINE(last_matrix_out_dec[7:0]);
assign en_dout[7:0] = last_matrix_out_enc[7:0];
assign de_dout[7:0] = last_matrix_out_dec[7:0];
 
/*****************************************************************************/
// Functions
/*****************************************************************************/
 
// convert GF(256) to GF(16)
function [7:0] GF256_TO_GF16;
input [7:0] data;
reg a,b,c;
begin
	a = data[1]^data[7];
	b = data[5]^data[7];
	c = data[4]^data[6];
	GF256_TO_GF16[0] = c^data[0]^data[5];
	GF256_TO_GF16[1] = data[1]^data[2];
	GF256_TO_GF16[2] = a;
	GF256_TO_GF16[3] = data[2]^data[4];
	GF256_TO_GF16[4] = c^data[5]; 
	GF256_TO_GF16[5] = a^c;
	GF256_TO_GF16[6] = b^data[2]^data[3];
	GF256_TO_GF16[7] = b;
end
endfunction
 
// squre 
function [3:0] SQUARE;
input [3:0] data;
begin
	SQUARE[0] = data[0]^data[2];
	SQUARE[1] = data[2];
	SQUARE[2] = data[1]^data[3];
	SQUARE[3] = data[3];
end
endfunction
 
// inverse
function [3:0] INVERSE;
input [3:0] data;
reg a;
begin
	a=data[1]^data[2]^data[3]^(data[1]&data[2]&data[3]);
	INVERSE[0]=a^data[0]^(data[0]&data[2])^(data[1]&data[2])^(data[0]&data[1]&data[2]);
	INVERSE[1]=(data[0]&data[1])^(data[0]&data[2])^(data[1]&data[2])^data[3]^
		(data[1]&data[3])^(data[0]&data[1]&data[3]);
	INVERSE[2]=(data[0]&data[1])^data[2]^(data[0]&data[2])^data[3]^
		(data[0]&data[3])^(data[0]&data[2]&data[3]);
	INVERSE[3]=a^(data[0]&data[3])^(data[1]&data[3])^(data[2]&data[3]);
end
endfunction
 
// multiply
function [3:0] MUL;
input [3:0] d1,d2;
reg a,b;
begin
	a=d1[0]^d1[3];
	b=d1[2]^d1[3];
 
	MUL[0]=(d1[0]&d2[0])^(d1[3]&d2[1])^(d1[2]&d2[2])^(d1[1]&d2[3]);
	MUL[1]=(d1[1]&d2[0])^(a&d2[1])^(b&d2[2])^((d1[1]^d1[2])&d2[3]);
	MUL[2]=(d1[2]&d2[0])^(d1[1]&d2[1])^(a&d2[2])^(b&d2[3]);
	MUL[3]=(d1[3]&d2[0])^(d1[2]&d2[1])^(d1[1]&d2[2])^(a&d2[3]);
end
endfunction
 
// GF16 to GF256 transform
function [7:0] GF16_TO_GF256;
input [3:0] p,q;
reg a,b;
begin
	a=p[1]^q[3];
	b=q[0]^q[1];
 
	GF16_TO_GF256[0]=p[0]^q[0];
	GF16_TO_GF256[1]=b^q[3];
	GF16_TO_GF256[2]=a^b;
	GF16_TO_GF256[3]=b^p[1]^q[2];
	GF16_TO_GF256[4]=a^b^p[3];
	GF16_TO_GF256[5]=b^p[2];
	GF16_TO_GF256[6]=a^p[2]^p[3]^q[0];
	GF16_TO_GF256[7]=b^p[2]^q[3];
end
endfunction
 
// affine transformation
function [7:0] AFFINE;
input [7:0] data;
begin
	//affine trasformation
	AFFINE[0]=(!data[0])^data[4]^data[5]^data[6]^data[7];
	AFFINE[1]=(!data[0])^data[1]^data[5]^data[6]^data[7];
	AFFINE[2]=data[0]^data[1]^data[2]^data[6]^data[7];
	AFFINE[3]=data[0]^data[1]^data[2]^data[3]^data[7];
	AFFINE[4]=data[0]^data[1]^data[2]^data[3]^data[4];
	AFFINE[5]=(!data[1])^data[2]^data[3]^data[4]^data[5];
	AFFINE[6]=(!data[2])^data[3]^data[4]^data[5]^data[6];
	AFFINE[7]=data[3]^data[4]^data[5]^data[6]^data[7];
end
endfunction
 
// inverse affine transformation
function [7:0] INV_AFFINE;
input [7:0] data;
reg a,b,c,d;
begin
	a=data[0]^data[5];
	b=data[1]^data[4];
	c=data[2]^data[7];
	d=data[3]^data[6];
	INV_AFFINE[0]=(!data[5])^c;
	INV_AFFINE[1]=data[0]^d;
	INV_AFFINE[2]=(!data[7])^b;
	INV_AFFINE[3]=data[2]^a;
	INV_AFFINE[4]=data[1]^d;
	INV_AFFINE[5]=data[4]^c;
	INV_AFFINE[6]=data[3]^a;
	INV_AFFINE[7]=data[6]^b;
end
endfunction
endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/rtl/shift_rows.v
// -----------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//
//  shift_rows module file (converted from shift_rows function)
//
//  Description:
//     shift rows for encryption
//
//  Author(s):
//      - Moti Litochevski
//
//---------------------------------------------------------------------------------------

module shift_rows (
	si, so 
);
 
input	[127:0]	si;
output	[127:0]	so;
 
wire [127:0] so;

assign so[127:96] = {si[127:120],si[87:80],si[47:40],si[7:0]};
assign so[95:64] = {si[95:88],si[55:48],si[15:8],si[103:96]};
assign so[63:32] = {si[63:56],si[23:16],si[111:104],si[71:64]};
assign so[31:0] = {si[31:24],si[119:112],si[79:72],si[39:32]};

endmodule

// -----------------------------------------------------------------------------
// Source file: verilog/rtl/xram_16x64.v
// -----------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Ram module                                                  ////
////                                                              ////
////  Description:                                                ////
////  this is 16x64, we can use a 16x128 to replace two of this   ////
////    module, also, can use specific foundry libs instead       ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Luo Dongjun,   dongjun_luo@hotmail.com                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module xram_16x64 
(
	clk, wr,
	wr_addr, wr_data,
	rd_addr, rd_data
);
 
input clk, wr;
input [3:0] wr_addr, rd_addr;
input [63:0] wr_data;
output [63:0] rd_data;
 
reg [63:0] mem [15:0];
wire [63:0] rd_data;
 
// behavioral code for 16x64 mem
always @ (posedge clk)
begin
   if (wr)
      mem[wr_addr] <= wr_data;
end

assign rd_data = mem[rd_addr];

endmodule
