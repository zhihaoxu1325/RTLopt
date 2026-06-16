// Curated RTL benchmark case.
// case_id: bench_0037_crypto_core_csa
// source_project: crypto_core_csa
// top_module: sboxes


// -----------------------------------------------------------------------------
// Source file: rtl/sboxes.v
// -----------------------------------------------------------------------------
`include "../bench/timescale.v"

//this moudule preform the s-boxes transform

module sboxes(A, s1, s2, s3, s4, s5, s6, s7);
input [9*4-1:0] A;

output [2-1:0] s1;
output [2-1:0] s2;
output [2-1:0] s3;
output [2-1:0] s4;
output [2-1:0] s5;
output [2-1:0] s6;
output [2-1:0] s7;

sbox1 b1({A[(4-1)*4+0], A[(1-1)*4+2], A[(6-1)*4+1], A[(7-1)*4+3], A[(9-1)*4+0]}, s1);
sbox2 b2({A[(2-1)*4+1], A[(3-1)*4+2], A[(6-1)*4+3], A[(7-1)*4+0], A[(9-1)*4+1]}, s2);
sbox3 b3({A[(1-1)*4+3], A[(2-1)*4+0], A[(5-1)*4+1], A[(5-1)*4+3], A[(6-1)*4+2]}, s3);
sbox4 b4({A[(3-1)*4+3], A[(1-1)*4+1], A[(2-1)*4+3], A[(4-1)*4+2], A[(8-1)*4+0]}, s4);
sbox5 b5({A[(5-1)*4+2], A[(4-1)*4+3], A[(6-1)*4+0], A[(8-1)*4+1], A[(9-1)*4+2]}, s5);
sbox6 b6({A[(3-1)*4+1], A[(4-1)*4+1], A[(5-1)*4+0], A[(7-1)*4+2], A[(9-1)*4+3]}, s6);
sbox7 b7({A[(2-1)*4+2], A[(3-1)*4+0], A[(7-1)*4+1], A[(8-1)*4+2], A[(8-1)*4+3]}, s7);

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/sbox1.v
// -----------------------------------------------------------------------------
`include "../bench/timescale.v"
module sbox1(in,out);
input [4:0]in;
output [1:0]out;
reg [1:0]out;

always @(in)
        case (in)          // synthesis full_case
        5'h00:out=2'h2;
        5'h01:out=2'h0;
        5'h02:out=2'h1;
        5'h03:out=2'h1;
        5'h04:out=2'h2;
        5'h05:out=2'h3;
        5'h06:out=2'h3;
        5'h07:out=2'h0;
        5'h08:out=2'h3;
        5'h09:out=2'h2;
        5'h0a:out=2'h2;
        5'h0b:out=2'h0;
        5'h0c:out=2'h1;
        5'h0d:out=2'h1;
        5'h0e:out=2'h0;
        5'h0f:out=2'h3;
        5'h10:out=2'h0;
        5'h11:out=2'h3;
        5'h12:out=2'h3;
        5'h13:out=2'h0;
        5'h14:out=2'h2;
        5'h15:out=2'h2;
        5'h16:out=2'h1;
        5'h17:out=2'h1;
        5'h18:out=2'h2;
        5'h19:out=2'h2;
        5'h1a:out=2'h0;
        5'h1b:out=2'h3;
        5'h1c:out=2'h1;
        5'h1d:out=2'h1;
        5'h1e:out=2'h3;
        5'h1f:out=2'h0;
        endcase
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/sbox2.v
// -----------------------------------------------------------------------------
`include "../bench/timescale.v"
module sbox2(in,out);
input [4:0]in;
output [1:0]out;
reg [1:0]out;

always @(in)
        case (in)          // synthesis full_case
        5'h00:out=2'h3;
        5'h01:out=2'h1;
        5'h02:out=2'h0;
        5'h03:out=2'h2;
        5'h04:out=2'h2;
        5'h05:out=2'h3;
        5'h06:out=2'h3;
        5'h07:out=2'h0;
        5'h08:out=2'h1;
        5'h09:out=2'h3;
        5'h0a:out=2'h2;
        5'h0b:out=2'h1;
        5'h0c:out=2'h0;
        5'h0d:out=2'h0;
        5'h0e:out=2'h1;
        5'h0f:out=2'h2;
        5'h10:out=2'h3;
        5'h11:out=2'h1;
        5'h12:out=2'h0;
        5'h13:out=2'h3;
        5'h14:out=2'h3;
        5'h15:out=2'h2;
        5'h16:out=2'h0;
        5'h17:out=2'h2;
        5'h18:out=2'h0;
        5'h19:out=2'h0;
        5'h1a:out=2'h1;
        5'h1b:out=2'h2;
        5'h1c:out=2'h2;
        5'h1d:out=2'h1;
        5'h1e:out=2'h3;
        5'h1f:out=2'h1;
        endcase
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/sbox3.v
// -----------------------------------------------------------------------------
`include "../bench/timescale.v"
module sbox3(in,out);
input [4:0]in;
output [1:0]out;
reg [1:0]out;

always @(in)
        case (in)          // synthesis full_case
        5'h00:out=2'h2;
        5'h01:out=2'h0;
        5'h02:out=2'h1;
        5'h03:out=2'h2;
        5'h04:out=2'h2;
        5'h05:out=2'h3;
        5'h06:out=2'h3;
        5'h07:out=2'h1;
        5'h08:out=2'h1;
        5'h09:out=2'h1;
        5'h0a:out=2'h0;
        5'h0b:out=2'h3;
        5'h0c:out=2'h3;
        5'h0d:out=2'h0;
        5'h0e:out=2'h2;
        5'h0f:out=2'h0;
        5'h10:out=2'h1;
        5'h11:out=2'h3;
        5'h12:out=2'h0;
        5'h13:out=2'h1;
        5'h14:out=2'h3;
        5'h15:out=2'h0;
        5'h16:out=2'h2;
        5'h17:out=2'h2;
        5'h18:out=2'h2;
        5'h19:out=2'h0;
        5'h1a:out=2'h1;
        5'h1b:out=2'h2;
        5'h1c:out=2'h0;
        5'h1d:out=2'h3;
        5'h1e:out=2'h3;
        5'h1f:out=2'h1;
        endcase
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/sbox4.v
// -----------------------------------------------------------------------------
`include "../bench/timescale.v"
module sbox4(in,out);
input [4:0]in;
output [1:0]out;
reg [1:0]out;

always @(in)
        case (in)          // synthesis full_case
        5'h00:out=2'h3;
        5'h01:out=2'h1;
        5'h02:out=2'h2;
        5'h03:out=2'h3;
        5'h04:out=2'h0;
        5'h05:out=2'h2;
        5'h06:out=2'h1;
        5'h07:out=2'h2;
        5'h08:out=2'h1;
        5'h09:out=2'h2;
        5'h0a:out=2'h0;
        5'h0b:out=2'h1;
        5'h0c:out=2'h3;
        5'h0d:out=2'h0;
        5'h0e:out=2'h0;
        5'h0f:out=2'h3;
        5'h10:out=2'h1;
        5'h11:out=2'h0;
        5'h12:out=2'h3;
        5'h13:out=2'h1;
        5'h14:out=2'h2;
        5'h15:out=2'h3;
        5'h16:out=2'h0;
        5'h17:out=2'h3;
        5'h18:out=2'h0;
        5'h19:out=2'h3;
        5'h1a:out=2'h2;
        5'h1b:out=2'h0;
        5'h1c:out=2'h1;
        5'h1d:out=2'h2;
        5'h1e:out=2'h2;
        5'h1f:out=2'h1;
        endcase
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/sbox5.v
// -----------------------------------------------------------------------------
`include "../bench/timescale.v"
module sbox5(in,out);
input [4:0]in;
output [1:0]out;
reg [1:0]out;

always @(in)
        case (in)          // synthesis full_case
        5'h00:out=2'h2;
        5'h01:out=2'h0;
        5'h02:out=2'h0;
        5'h03:out=2'h1;
        5'h04:out=2'h3;
        5'h05:out=2'h2;
        5'h06:out=2'h3;
        5'h07:out=2'h2;
        5'h08:out=2'h0;
        5'h09:out=2'h1;
        5'h0a:out=2'h3;
        5'h0b:out=2'h3;
        5'h0c:out=2'h1;
        5'h0d:out=2'h0;
        5'h0e:out=2'h2;
        5'h0f:out=2'h1;
        5'h10:out=2'h2;
        5'h11:out=2'h3;
        5'h12:out=2'h2;
        5'h13:out=2'h0;
        5'h14:out=2'h0;
        5'h15:out=2'h3;
        5'h16:out=2'h1;
        5'h17:out=2'h1;
        5'h18:out=2'h1;
        5'h19:out=2'h0;
        5'h1a:out=2'h3;
        5'h1b:out=2'h2;
        5'h1c:out=2'h3;
        5'h1d:out=2'h1;
        5'h1e:out=2'h0;
        5'h1f:out=2'h2;
        endcase
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/sbox6.v
// -----------------------------------------------------------------------------
`include "../bench/timescale.v"
module sbox6(in,out);
input [4:0]in;
output [1:0]out;
reg [1:0]out;

always @(in)
        case (in)          // synthesis full_case
        5'h00:out=2'h0;
        5'h01:out=2'h1;
        5'h02:out=2'h2;
        5'h03:out=2'h3;
        5'h04:out=2'h1;
        5'h05:out=2'h2;
        5'h06:out=2'h2;
        5'h07:out=2'h0;
        5'h08:out=2'h0;
        5'h09:out=2'h1;
        5'h0a:out=2'h3;
        5'h0b:out=2'h0;
        5'h0c:out=2'h2;
        5'h0d:out=2'h3;
        5'h0e:out=2'h1;
        5'h0f:out=2'h3;
        5'h10:out=2'h2;
        5'h11:out=2'h3;
        5'h12:out=2'h0;
        5'h13:out=2'h2;
        5'h14:out=2'h3;
        5'h15:out=2'h0;
        5'h16:out=2'h1;
        5'h17:out=2'h1;
        5'h18:out=2'h2;
        5'h19:out=2'h1;
        5'h1a:out=2'h1;
        5'h1b:out=2'h2;
        5'h1c:out=2'h0;
        5'h1d:out=2'h3;
        5'h1e:out=2'h3;
        5'h1f:out=2'h0;
        endcase
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/sbox7.v
// -----------------------------------------------------------------------------
`include "../bench/timescale.v"
module sbox7(in,out);
input [4:0]in;
output [1:0]out;
reg [1:0]out;

always @(in)
        case (in)          // synthesis full_case
        5'h00:out=2'h0;
        5'h01:out=2'h3;
        5'h02:out=2'h2;
        5'h03:out=2'h2;
        5'h04:out=2'h3;
        5'h05:out=2'h0;
        5'h06:out=2'h0;
        5'h07:out=2'h1;
        5'h08:out=2'h3;
        5'h09:out=2'h0;
        5'h0a:out=2'h1;
        5'h0b:out=2'h3;
        5'h0c:out=2'h1;
        5'h0d:out=2'h2;
        5'h0e:out=2'h2;
        5'h0f:out=2'h1;
        5'h10:out=2'h1;
        5'h11:out=2'h0;
        5'h12:out=2'h3;
        5'h13:out=2'h3;
        5'h14:out=2'h0;
        5'h15:out=2'h1;
        5'h16:out=2'h1;
        5'h17:out=2'h2;
        5'h18:out=2'h2;
        5'h19:out=2'h3;
        5'h1a:out=2'h1;
        5'h1b:out=2'h0;
        5'h1c:out=2'h2;
        5'h1d:out=2'h3;
        5'h1e:out=2'h0;
        5'h1f:out=2'h2;
        endcase
endmodule
