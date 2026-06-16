// Curated RTL benchmark case.
// case_id: bench_0040_crypto_core_present_cipher_encryption_core
// source_project: crypto_core_present_cipher_encryption_core
// top_module: present_encryptor_top


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/present_encryptor_top.v
// -----------------------------------------------------------------------------
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Present Cipher Encryption Core                    //
// Module Name: present_encryptor_top                             //
// Language:    Verilog                                           //
// Date Created: 1/16/2011                                        //
// Author: Reza Ameli                                             //
//         Digital Systems Lab                                    //
//         Ferdowsi University of Mashhad, Iran                   //
//         http://commeng.um.ac.ir/dslab                          //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
//                                                                //
// This source file may be used and distributed without           //
// restriction provided that this copyright statement is not      //
// removed from the file and that any derivative work contains    //
// the original copyright notice and the associated disclaimer.   //
//                                                                //
// This source file is free software; you can redistribute it     //
// and/or modify it under the terms of the GNU Lesser General     //
// Public License as published by the Free Software Foundation;   //
// either version 2.1 of the License, or (at your option) any     //
// later version.                                                 //
//                                                                //
// This source is distributed in the hope that it will be         //
// useful, but WITHOUT ANY WARRANTY; without even the implied     //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        //
// PURPOSE. See the GNU Lesser General Public License for more    //
// details.                                                       //
//                                                                //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//

module present_encryptor_top(data_o,data_i,data_load,key_load,clk_i);
//- Module IOs ----------------------------------------------------------------

output wire[63:0] data_o; // ciphertext will appear here
input  wire[79:0] data_i; // plaintext and key must be fed here
input  wire clk_i; // clock signal
input  wire key_load; // when '1', data_i will loaded into key register
input  wire data_load; // when '1', first 64 bits of data_i will be loaded into state register

//- Variables, Registers and Parameters ---------------------------------------

reg  [63 : 0] state; // 64-bit state of the cipher
reg  [4  : 0] round_counter; // 5-bit round-counter (from 1 to 31)
reg  [79 : 0] key; // 80-bit register holding the key and updates of the key

wire [63 : 0] round_key; // 64-bit round-key. The round-keys are derived from the key register
wire [63 : 0] sub_per_input; // 64-bit input to the substitution-permutation network
wire [63 : 0] sub_per_output; // 64-bit output of the substitution-permutation network
wire [79 : 0] key_update_output; // 80-bit output of the keyupdate procedure. This value replaces the value of the key register

//- Instantiations ------------------------------------------------------------

sub_per present_cipher_sp(.data_o(sub_per_output),.data_i(sub_per_input)); 
    // instantion of  substitution and permutation module
    // this module is used 31 times iteratively

key_update present_cipher_key_update(.data_o(key_update_output),.data_i(key),.round_counter(round_counter)); 
    // instantiation of the key-update procedure
    // this module is used 31 times iteratively
    
//- Continuous Assigments------------------------------------------------------

assign round_key = key[79:16]; // iurrent round-key is the 64 left most bits of the key register

assign sub_per_input = state^round_key; // input to the Substitution-Permutation network is the cipher state xored by the round key

assign data_o = sub_per_input; // the output of the cipher will finally be one of the inputs to the Substitution-Permutation network.
                             // output will be valid when round-counter is 31

//- Behavioral Statements -----------------------------------------------------

always @(posedge clk_i)
begin
    if(key_load) // loading the key
    begin
        key <= data_i;
    end
    else if(!key_load) // not loading the key
    begin
        if(data_load) // loading plaintext
        begin
            state <= data_i[63:0];
            round_counter <= 5'b00001; // round_counter starts from 1 and ends at 31
        end
        else if(!data_load) // normal operation (neither loading the key nor loading the plaitext)
        begin                  
            round_counter <= round_counter + 1'b1; // round counter is increased by one
            state <= sub_per_output; // state is updated
            key <= key_update_output; // key register is updated
        end
    end
end
//-----------------------------------------------------------------------------
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/key_update.v
// -----------------------------------------------------------------------------
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Key Update Procedure for Present Cipher           //
// Module Name: key_update                                        //
// Language:    Verilog                                           //
// Date Created: 1/16/2011                                        //
// Author: Reza Ameli                                             //
//         Digital Systems Lab                                    //
//         Ferdowsi University of Mashhad, Iran                   //
//         http://commeng.um.ac.ir/dslab                          //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
//                                                                //
// This source file may be used and distributed without           //
// restriction provided that this copyright statement is not      //
// removed from the file and that any derivative work contains    //
// the original copyright notice and the associated disclaimer.   //
//                                                                //
// This source file is free software; you can redistribute it     //
// and/or modify it under the terms of the GNU Lesser General     //
// Public License as published by the Free Software Foundation;   //
// either version 2.1 of the License, or (at your option) any     //
// later version.                                                 //
//                                                                //
// This source is distributed in the hope that it will be         //
// useful, but WITHOUT ANY WARRANTY; without even the implied     //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        //
// PURPOSE. See the GNU Lesser General Public License for more    //
// details.                                                       //
//                                                                //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//

module key_update(data_o,data_i,round_counter);

//- Module IOs ----------------------------------------------------------------

output wire[79 : 0] data_o; // 80-bit input
input  wire[79 : 0] data_i; // 80-bit output (will be the updated value of current key)
input  wire[4  : 0] round_counter;

//- Variables, Registers and Parameters ---------------------------------------

wire [79:0] s1,s2,s3; // intermediate signals                                  

//- Instantiations ------------------------------------------------------------

sbox key_update_sbox(.data_o(s2[79:76]),.data_i(s1[79:76])); // four left-most bits are determined by the sbox output

//- Continuous Assigments------------------------------------------------------

assign s1 = {data_i[18:0],data_i[79:19]};
assign s2[75:0] = s1[75:0]; // four left-most bits are determined by the sbox output
assign s3 = {s2[79:20],(s2[19:15])^(round_counter),s2[14:0]};   
assign data_o = s3;

//-----------------------------------------------------------------------------
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/permutation.v
// -----------------------------------------------------------------------------
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Permutation Layer for Present Cipher              //
// Module Name: permutation                                       //
// Language:    Verilog                                           //
// Date Created: 1/16/2011                                        //
// Author: Reza Ameli                                             //
//         Digital Systems Lab                                    //
//         Ferdowsi University of Mashhad, Iran                   //
//         http://commeng.um.ac.ir/dslab                          //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
//                                                                //
// This source file may be used and distributed without           //
// restriction provided that this copyright statement is not      //
// removed from the file and that any derivative work contains    //
// the original copyright notice and the associated disclaimer.   //
//                                                                //
// This source file is free software; you can redistribute it     //
// and/or modify it under the terms of the GNU Lesser General     //
// Public License as published by the Free Software Foundation;   //
// either version 2.1 of the License, or (at your option) any     //
// later version.                                                 //
//                                                                //
// This source is distributed in the hope that it will be         //
// useful, but WITHOUT ANY WARRANTY; without even the implied     //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        //
// PURPOSE. See the GNU Lesser General Public License for more    //
// details.                                                       //
//                                                                //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//

module permutation(data_o,data_i);

//- Module IOs ----------------------------------------------------------------

output wire[63:0] data_o;
input  wire[63:0] data_i;

//- Continuous Assigments------------------------------------------------------

assign data_o[0 ] = data_i[0 ];
assign data_o[16] = data_i[1 ];
assign data_o[32] = data_i[2 ];
assign data_o[48] = data_i[3 ];
assign data_o[1 ] = data_i[4 ];
assign data_o[17] = data_i[5 ];
assign data_o[33] = data_i[6 ];
assign data_o[49] = data_i[7 ];
assign data_o[2 ] = data_i[8 ];
assign data_o[18] = data_i[9 ];
assign data_o[34] = data_i[10];
assign data_o[50] = data_i[11];
assign data_o[3 ] = data_i[12];
assign data_o[19] = data_i[13];
assign data_o[35] = data_i[14];
assign data_o[51] = data_i[15];

assign data_o[4 ] = data_i[16];
assign data_o[20] = data_i[17];
assign data_o[36] = data_i[18];
assign data_o[52] = data_i[19];
assign data_o[5 ] = data_i[20];
assign data_o[21] = data_i[21];
assign data_o[37] = data_i[22];
assign data_o[53] = data_i[23];
assign data_o[6 ] = data_i[24];
assign data_o[22] = data_i[25];
assign data_o[38] = data_i[26];
assign data_o[54] = data_i[27];
assign data_o[7 ] = data_i[28];
assign data_o[23] = data_i[29];
assign data_o[39] = data_i[30];
assign data_o[55] = data_i[31];

assign data_o[8 ] = data_i[32];
assign data_o[24] = data_i[33];
assign data_o[40] = data_i[34];
assign data_o[56] = data_i[35];
assign data_o[9 ] = data_i[36];
assign data_o[25] = data_i[37];
assign data_o[41] = data_i[38];
assign data_o[57] = data_i[39];
assign data_o[10] = data_i[40];
assign data_o[26] = data_i[41];
assign data_o[42] = data_i[42];
assign data_o[58] = data_i[43];
assign data_o[11] = data_i[44];
assign data_o[27] = data_i[45];
assign data_o[43] = data_i[46];
assign data_o[59] = data_i[47];

assign data_o[12] = data_i[48];
assign data_o[28] = data_i[49];
assign data_o[44] = data_i[50];
assign data_o[60] = data_i[51];
assign data_o[13] = data_i[52];
assign data_o[29] = data_i[53];
assign data_o[45] = data_i[54];
assign data_o[61] = data_i[55];
assign data_o[14] = data_i[56];
assign data_o[30] = data_i[57];
assign data_o[46] = data_i[58];
assign data_o[62] = data_i[59];
assign data_o[15] = data_i[60];
assign data_o[31] = data_i[61];
assign data_o[47] = data_i[62];
assign data_o[63] = data_i[63];

//-----------------------------------------------------------------------------
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sbox.v
// -----------------------------------------------------------------------------
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Present Cipher S-BOX                              //
// Module Name: sbox                                              //
// Language:    Verilog                                           //
// Date Created: 1/16/2011                                        //
// Author: Reza Ameli                                             //
//         Digital Systems Lab                                    //
//         Ferdowsi University of Mashhad, Iran                   //
//         http://commeng.um.ac.ir/dslab                          //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
//                                                                //
// This source file may be used and distributed without           //
// restriction provided that this copyright statement is not      //
// removed from the file and that any derivative work contains    //
// the original copyright notice and the associated disclaimer.   //
//                                                                //
// This source file is free software; you can redistribute it     //
// and/or modify it under the terms of the GNU Lesser General     //
// Public License as published by the Free Software Foundation;   //
// either version 2.1 of the License, or (at your option) any     //
// later version.                                                 //
//                                                                //
// This source is distributed in the hope that it will be         //
// useful, but WITHOUT ANY WARRANTY; without even the implied     //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        //
// PURPOSE. See the GNU Lesser General Public License for more    //
// details.                                                       //
//                                                                //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//

module sbox (data_o,data_i);

//- Module IOs ----------------------------------------------------------------

output reg [3:0] data_o;
input  wire [3:0] data_i;

//- Continuous Assigments------------------------------------------------------

always @(data_i)
    case (data_i)
        4'h0 : data_o = 4'hC;
        4'h1 : data_o = 4'h5;
        4'h2 : data_o = 4'h6;
        4'h3 : data_o = 4'hB;
        4'h4 : data_o = 4'h9;
        4'h5 : data_o = 4'h0;
        4'h6 : data_o = 4'hA;
        4'h7 : data_o = 4'hD;
        4'h8 : data_o = 4'h3;
        4'h9 : data_o = 4'hE;
        4'hA : data_o = 4'hF;
        4'hB : data_o = 4'h8;
        4'hC : data_o = 4'h4;
        4'hD : data_o = 4'h7;
        4'hE : data_o = 4'h1;
        4'hF : data_o = 4'h2;
    endcase 

//-----------------------------------------------------------------------------
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/sub_per.v
// -----------------------------------------------------------------------------
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Substitution & Permutation  for Present Cipher    //
// Module Name: sub_per                                           //
// Language:    Verilog                                           //
// Date Created: 1/16/2011                                        //
// Author: Reza Ameli                                             //
//         Digital Systems Lab                                    //
//         Ferdowsi University of Mashhad, Iran                   //
//         http://commeng.um.ac.ir/dslab                          //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
//                                                                //
// This source file may be used and distributed without           //
// restriction provided that this copyright statement is not      //
// removed from the file and that any derivative work contains    //
// the original copyright notice and the associated disclaimer.   //
//                                                                //
// This source file is free software; you can redistribute it     //
// and/or modify it under the terms of the GNU Lesser General     //
// Public License as published by the Free Software Foundation;   //
// either version 2.1 of the License, or (at your option) any     //
// later version.                                                 //
//                                                                //
// This source is distributed in the hope that it will be         //
// useful, but WITHOUT ANY WARRANTY; without even the implied     //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        //
// PURPOSE. See the GNU Lesser General Public License for more    //
// details.                                                       //
//                                                                //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//

module sub_per(data_o,data_i); // this module cascades the substitution and permutation layers of the cipher and builds a 
                               // single entity containing both of them

//- Module IOs ----------------------------------------------------------------

output wire[63:0] data_o;
input  wire[63:0] data_i;              

//- Variables, Registers and Parameters ---------------------------------------

wire [63:0] s; // intermediate signal

//- Instantiations ------------------------------------------------------------

substitution sub_per_substitution(.data_o(s)   ,.data_i(data_i)); // input of the S-Box is data_i
permutation  sub_per_permutation (.data_o(data_o),.data_i(s)); // output os Permutation layer is data_o

//-----------------------------------------------------------------------------
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/substitution.v
// -----------------------------------------------------------------------------
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
// Design Name: Substitution Layer for Present Cipher             //
// Module Name: substitution                                      //
// Language:    Verilog                                           //
// Date Created: 1/16/2011                                        //
// Author: Reza Ameli                                             //
//         Digital Systems Lab                                    //
//         Ferdowsi University of Mashhad, Iran                   //
//         http://commeng.um.ac.ir/dslab                          //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//
//                                                                //
// This source file may be used and distributed without           //
// restriction provided that this copyright statement is not      //
// removed from the file and that any derivative work contains    //
// the original copyright notice and the associated disclaimer.   //
//                                                                //
// This source file is free software; you can redistribute it     //
// and/or modify it under the terms of the GNU Lesser General     //
// Public License as published by the Free Software Foundation;   //
// either version 2.1 of the License, or (at your option) any     //
// later version.                                                 //
//                                                                //
// This source is distributed in the hope that it will be         //
// useful, but WITHOUT ANY WARRANTY; without even the implied     //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR        //
// PURPOSE. See the GNU Lesser General Public License for more    //
// details.                                                       //
//                                                                //
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@//

module substitution(data_o,data_i); // Present cipher uses 16 S-Boxes in parallel to process the data
                                    // this module implements those 16 S-Boxes using the sbox module

//- Module IOs ----------------------------------------------------------------

output wire [63:0] data_o;
input  wire [63:0] data_i;

//- Variables, Registers and Parameters ---------------------------------------

genvar j;

//- Instantiations ------------------------------------------------------------

generate
    for (j = 0; j < 16; j = j+1)
    begin : boxes
        sbox substitution_sbox (.data_o(data_o[j*4+3 : j*4]),.data_i(data_i[j*4+3 : j*4]));    
    end
endgenerate

//-----------------------------------------------------------------------------
endmodule
