// Curated RTL benchmark case.
// case_id: bench_0212_other_an_alternative_oscilloscope
// source_project: other_an_alternative_oscilloscope
// top_module: TopLevel


// -----------------------------------------------------------------------------
// Source file: d_TopLevel.v
// -----------------------------------------------------------------------------
//==================================================================//
// File:    d_TopLevel.v                                            //
// Version: 0.0.0.3                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 08, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     Apr   , 2005   Under Development                 //
// Ver 0.0.0.2     Jun 08, 2005    Updates                          //
// Ver 0.0.0.3     Jun 19, 2005    Added Character Display          //
//                                                                  //
//==================================================================//

module TopLevel(
    CLK_50MHZ_IN, MASTER_RST,
    H_SYNC, V_SYNC, VGA_OUTPUT,
    PS2C, PS2D,
//    TIME_BASE,
    ADC_DATA, CLK_ADC,
    VGA_RAM_ADDR, VGA_RAM_DATA,
    VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS,
    
    SEG_OUT, SEG_SEL, leds, SHOW_LEVELS_BUTTON
    );

//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//

//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ_IN, MASTER_RST;
output H_SYNC, V_SYNC;
output[2:0] VGA_OUTPUT;
//input[5:0] TIME_BASE;
inout PS2C, PS2D;
input[8:0] ADC_DATA;
output CLK_ADC;
output[17:0] VGA_RAM_ADDR;
inout[15:0] VGA_RAM_DATA;
output VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;

output[7:0] leds;
output[6:0] SEG_OUT;
output[3:0] SEG_SEL;
input SHOW_LEVELS_BUTTON;
wire SHOW_LEVELS_BUTTON;


//----------------------//
// WIRES / NODES        //
//----------------------//
wire      CLK_50MHZ_IN, MASTER_RST;
wire      H_SYNC, V_SYNC;
wire[2:0] VGA_OUTPUT;
wire[5:0] TIME_BASE;
wire      PS2C, PS2D;
wire[8:0] ADC_DATA;
wire      CLK_ADC;
wire[17:0] VGA_RAM_ADDR;
wire[15:0] VGA_RAM_DATA;
wire       VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;


//----------------------//
// VARIABLES            //
//----------------------//
assign TIME_BASE = 6'b0;


//==================================================================//
// TEMP                                                             //
//==================================================================//
reg[8:0] fake_adcData;

wire[17:0] VGA_RAM_ADDRESS_w;
wire[15:0] VGA_RAM_DATA_w;
wire L_BUTTON, R_BUTTON, M_BUTTON;

wire VGA_RAM_ACCESS_OK;
wire CLK_50MHZ, CLK_64MHZ, CLK180_64MHZ;
reg CLK_VGA;
wire[6:0] SEG_OUT;
wire[3:0] SEG_SEL;

wire[7:0] data_charRamRead;
reg[7:0] data_charRamRead_buf;
wire[7:0] mask_charMap;
reg[7:0] mask_charMap_buf;


always @ (posedge CLK_50MHZ) begin
    if(R_BUTTON) begin
        data_charRamRead_buf <= data_charRamRead_buf;
        mask_charMap_buf <= mask_charMap_buf;
    end else begin
        data_charRamRead_buf <= data_charRamRead;
        mask_charMap_buf <= mask_charMap;
    end
end

sub_SegDriver segs(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .DATA_IN(fake_adcData[7:0]),
    .SEG_OUT(SEG_OUT), .SEG_SEL(SEG_SEL)
    );

wire[7:0] leds;
assign leds[7:0] = 8'b0;

/*- - - - - - - - - - - - - */
/* Fake ADC data            */
/*- - - - - - - - - - - - - */
always @ (posedge CLK_64MHZ or posedge MASTER_RST) begin
    if(MASTER_RST)
        fake_adcData <= 9'd0;
    else
        fake_adcData <= fake_adcData+1;
end



//==================================================================//
// SUBROUTINES                                                      //
//==================================================================//
//d_DCM_VGA clock_gen_VGA (
//    .CLKIN_IN(CLK_50MHZ_IN), 
//    .RST_IN(MASTER_RST), 
//    .CLKFX_OUT(CLK_VGA), 
//    .CLKIN_IBUFG_OUT(CLK_50MHZ_B), 
//    .LOCKED_OUT(CLK_VGA_LOCKED)
//    );

always @ (posedge CLK_50MHZ or posedge MASTER_RST)
    if(MASTER_RST) CLK_VGA <= 1'b0;
    else           CLK_VGA <= ~CLK_VGA;


wire CLK_64MHZ_LOCKED;
d_DCM clock_generator(
    .CLKIN_IN(CLK_50MHZ_IN),
    .RST_IN(MASTER_RST),
    .CLKIN_IBUFG_OUT(CLK_50MHZ),
    .CLK_64MHZ(CLK_64MHZ),
    .CLK180_64MHZ(CLK180_64MHZ),
    .LOCKED_OUT(CLK_64MHZ_LOCKED)
    );

wire[11:0] XCOORD, YCOORD;
wire[9:0] TRIGGER_LEVEL, HORZ_OFFSET, VERT_OFFSET;
wire[3:0] TIMESCALE;
wire[1:0] TRIGGERSTYLE;
Driver_mouse driver_MOUSE(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .PS2C(PS2C), .PS2D(PS2D),
    .XCOORD(XCOORD), .YCOORD(YCOORD),
    .L_BUTTON(L_BUTTON), .M_BUTTON(M_BUTTON), .R_BUTTON(R_BUTTON)
    );
    
Driver_MouseInput Driver_MouseInput_inst(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .XCOORD(XCOORD[9:0]), .YCOORD(YCOORD[9:0]),
    .L_BUTTON(L_BUTTON), .M_BUTTON(M_BUTTON), .R_BUTTON(R_BUTTON),
    .TRIGGER_LEVEL(TRIGGER_LEVEL), .HORZ_OFFSET(HORZ_OFFSET), .VERT_OFFSET(VERT_OFFSET),
    .TIMESCALE(TIMESCALE),
    .TRIGGERSTYLE(TRIGGERSTYLE)
    );



wire[8:0] ADC_RAM_DATA;
wire[10:0] ADC_RAM_ADDR;
wire ADC_RAM_CLK;
wire[10:0] TRIG_ADDR;
wire VGA_WRITE_DONE;

ADCDataBuffer ADC_Data_Buffer(
    .CLK_64MHZ(CLK_64MHZ),  .MASTER_CLK(MASTER_CLK), .MASTER_RST(MASTER_RST),
    .TIMESCALE(TIMESCALE), .TRIGGER_LEVEL(TRIGGER_LEVEL),
    .VERT_OFFSET(VERT_OFFSET), .HORZ_OFFSET(HORZ_OFFSET),
//    .ADC_DATA(ADC_DATA[7:0]),
    .ADC_DATA(fake_adcData),
    .CLK_ADC(CLK_ADC),
    .SNAP_DATA_EXT(ADC_RAM_DATA), .SNAP_ADDR_EXT(ADC_RAM_ADDR), .SNAP_CLK_EXT(ADC_RAM_CLK),
    .TRIGGERSTYLE(TRIGGERSTYLE)
    );


//------------------------------------------------------------------//
//   VGA                                                            //
//------------------------------------------------------------------//
wire[9:0] HCNT, VCNT;
wire[2:0] RGB_CHAR;


CharacterDisplay charTest(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .CLK_VGA(CLK_VGA), .HCNT(HCNT), .VCNT(VCNT),
    .RGB_OUT(RGB_CHAR),
    .TIMESCALE(TIMESCALE),
    .TRIGGERSTYLE(TRIGGERSTYLE),
    .XCOORD(XCOORD), .YCOORD(YCOORD)
    );


wire VGA_RAM_OE_w, VGA_RAM_WE_w, VGA_RAM_CS_w;
wire[17:0] VGA_RAM_ADDRESS_r;
wire VGA_RAM_OE_r, VGA_RAM_WE_r, VGA_RAM_CS_r;

assign VGA_RAM_ADDR = (VGA_RAM_ACCESS_OK) ? VGA_RAM_ADDRESS_w : VGA_RAM_ADDRESS_r;
assign VGA_RAM_DATA = (VGA_RAM_ACCESS_OK) ? VGA_RAM_DATA_w : 16'bZ;
assign VGA_RAM_OE = (VGA_RAM_ACCESS_OK) ? VGA_RAM_OE_w : VGA_RAM_OE_r;
assign VGA_RAM_WE = (VGA_RAM_ACCESS_OK) ? VGA_RAM_WE_w : VGA_RAM_WE_r;
assign VGA_RAM_CS = (VGA_RAM_ACCESS_OK) ? VGA_RAM_CS_w : VGA_RAM_CS_r;

VGADataBuffer ram_VGA_ramwrite(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .VGA_RAM_DATA(VGA_RAM_DATA_w), .VGA_RAM_ADDR(VGA_RAM_ADDRESS_w),
    .VGA_RAM_OE(VGA_RAM_OE_w), .VGA_RAM_WE(VGA_RAM_WE_w), .VGA_RAM_CS(VGA_RAM_CS_w),
    .VGA_RAM_ACCESS_OK(VGA_RAM_ACCESS_OK),
    .ADC_RAM_DATA(ADC_RAM_DATA), .ADC_RAM_ADDR(ADC_RAM_ADDR), .ADC_RAM_CLK(ADC_RAM_CLK),
    .TIME_BASE(TIME_BASE)
    );

Driver_VGA driver_VGA(
    .CLK_50MHZ(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .CLK_VGA(CLK_VGA),
    .H_SYNC(H_SYNC), .V_SYNC(V_SYNC), .VGA_OUTPUT(VGA_OUTPUT),
    .XCOORD(XCOORD), .YCOORD(YCOORD),
    .VGA_RAM_DATA(VGA_RAM_DATA), .VGA_RAM_ADDR(VGA_RAM_ADDRESS_r),
    .VGA_RAM_OE(VGA_RAM_OE_r), .VGA_RAM_WE(VGA_RAM_WE_r), .VGA_RAM_CS(VGA_RAM_CS_r),
    .VGA_RAM_ACCESS_OK(VGA_RAM_ACCESS_OK),
    .TRIGGER_LEVEL(TRIGGER_LEVEL), .HORZ_OFFSET(HORZ_OFFSET), .VERT_OFFSET(VERT_OFFSET),
    .SHOW_LEVELS(SHOW_LEVELS_BUTTON),
    .HCNT(HCNT), .VCNT(VCNT),
    .RGB_CHAR(RGB_CHAR)
    );



    


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

endmodule


// -----------------------------------------------------------------------------
// Source file: AdcDriver/d_Driver_ADC.v
// -----------------------------------------------------------------------------
//==================================================================
// File:    d_Driver_ADC.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================

module Driver_ADC(
    CLK_64MHZ, MASTER_RST,
    TIMESCALE,
    CLK_ADC, ADC_DATA,
    DATA_OUT
    );

//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//
parameter US1       = 4'd0;
parameter US2       = 4'd1;
parameter US4       = 4'd2;
parameter US8       = 4'd3;
parameter US16      = 4'd4;
parameter US32      = 4'd5;
parameter US64      = 4'd6;
parameter US128     = 4'd7;
parameter US512     = 4'd8;
parameter US1024    = 4'd9;
parameter US2048    = 4'd10;
parameter US4096    = 4'd11;
parameter US8192    = 4'd12;
parameter US16384   = 4'd13;
parameter US32768   = 4'd14;
parameter US65536   = 4'd15;
parameter US131072  = 4'd16;
parameter US262144  = 4'd17;
parameter US524288  = 4'd18;
parameter US1048576 = 4'd19;
parameter US2097152 = 4'd20;
parameter US4194304 = 4'd21;
parameter US8388608 = 4'd22;


//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input       CLK_64MHZ;          // Global System Clock
input       MASTER_RST;         // Global Asyncronous Reset
input[3:0]  TIMESCALE;          // The selected V/Div
input[8:0]  ADC_DATA;           // Data recieved from ADC
output      CLK_ADC;            // Clock out to the ADC
output[8:0] DATA_OUT;           // Data output (essentially buffered from ADC by one clk)

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_64MHZ, MASTER_RST;
wire[3:0] TIMESCALE;
wire[8:0] ADC_DATA;
reg  CLK_ADC;
reg [8:0] DATA_OUT;

//----------------------//
// VARIABLES            //
//----------------------//
reg[15:0] Counter_CLK;
wire CLK_32MHZ, CLK_16MHZ, CLK_8MHZ, CLK_4MHZ, CLK_2MHZ, CLK_1MHZ, CLK_500KHZ, CLK_250KHZ, CLK_125KHZ,
     CLK_62KHZ, CLK_31KHZ, CLK_16KHZ, CLK_8KHZ, CLK_4KHZ, CLK_2KHZ, CLK_1KHZ;




//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)  DATA_OUT <= 9'b0;
    else            DATA_OUT <= ADC_DATA;
end
/*
assign CLK_ADC = CLK_62KHZ;
*/

//------------------------------------------------------------------//
// CLOCK GENERATION AND SELECTION                                   //
//------------------------------------------------------------------//

always @ (posedge CLK_64MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        Counter_CLK <= 16'b0;
    end else begin
        Counter_CLK <= Counter_CLK + 1;
    end
end


assign CLK_32MHZ    = Counter_CLK[0];
assign CLK_16MHZ    = Counter_CLK[1];
assign CLK_8MHZ     = Counter_CLK[2];
assign CLK_4MHZ     = Counter_CLK[3];
assign CLK_2MHZ     = Counter_CLK[4];
assign CLK_1MHZ     = Counter_CLK[5];
assign CLK_500KHZ   = Counter_CLK[6];
assign CLK_250KHZ   = Counter_CLK[7];
assign CLK_125KHZ   = Counter_CLK[8];
assign CLK_62KHZ    = Counter_CLK[9];
assign CLK_31KHZ    = Counter_CLK[10];
assign CLK_16KHZ    = Counter_CLK[11];
assign CLK_8KHZ     = Counter_CLK[12];
assign CLK_4KHZ     = Counter_CLK[13];
assign CLK_2KHZ     = Counter_CLK[14];
assign CLK_1KHZ     = Counter_CLK[15];
//assign CLK_500HZ    = Counter_CLK[16];

always @ (TIMESCALE or MASTER_RST or CLK_64MHZ or CLK_32MHZ or CLK_16MHZ or
            CLK_8MHZ or CLK_4MHZ or CLK_2MHZ or CLK_1MHZ or CLK_500KHZ or CLK_250KHZ or
            CLK_125KHZ or CLK_62KHZ or CLK_31KHZ or CLK_16KHZ or CLK_8KHZ or CLK_4KHZ or
            CLK_2KHZ or CLK_1KHZ) begin
    if(MASTER_RST == 1'b1) begin
        CLK_ADC = 1'b0;
    end else if(TIMESCALE == 4'd0) begin    // 1us/Div, 1samp/pxl
        CLK_ADC = CLK_64MHZ;
    end else if(TIMESCALE == 4'd1) begin    // 2us/Div, 2samp/pxl
        CLK_ADC = CLK_64MHZ;
    end else if(TIMESCALE == 4'd2) begin    // 4us/Div, 2samp/pxl
        CLK_ADC = CLK_32MHZ;
    end else if(TIMESCALE == 4'd3) begin    // 8us/Div, 2samp/pxl
        CLK_ADC = CLK_16MHZ;
    end else if(TIMESCALE == 4'd4) begin    // 16us/Div, 2samp/pxl
        CLK_ADC = CLK_8MHZ;
    end else if(TIMESCALE == 4'd5) begin    // 32us/Div, 2samp/pxl
        CLK_ADC = CLK_4MHZ;
    end else if(TIMESCALE == 4'd6) begin    // 64us/Div, 2samp/pxl
        CLK_ADC = CLK_2MHZ;
    end else if(TIMESCALE == 4'd7) begin    // 128us/Div, 2samp/pxl
        CLK_ADC = CLK_1MHZ;
    end else if(TIMESCALE == 4'd8) begin    // 256us/Div, 2samp/pxl
        CLK_ADC = CLK_500KHZ;
    end else if(TIMESCALE == 4'd9) begin    // 512us/Div, 2samp/pxl
        CLK_ADC = CLK_250KHZ;
    end else if(TIMESCALE == 4'd10) begin   //      ...
        CLK_ADC = CLK_125KHZ;
    end else if(TIMESCALE == 4'd11) begin
        CLK_ADC = CLK_62KHZ;
    end else if(TIMESCALE == 4'd12) begin
        CLK_ADC = CLK_31KHZ;
    end else if(TIMESCALE == 4'd13) begin
        CLK_ADC = CLK_16KHZ;
    end else if(TIMESCALE == 4'd14) begin
        CLK_ADC = CLK_8KHZ;
    end else if(TIMESCALE == 4'd15) begin
        CLK_ADC = CLK_4KHZ;
/*
    end else if(TIMESCALE == 4'd16) begin
        CLK_ADC = CLK_2KHZ;
    end else if(TIMESCALE == 4'd17) begin
        CLK_ADC = CLK_1KHZ;
//    end else if(TIMESCALE == 4'd18) begin
//        CLK_ADC = CLK_500HZ;
    end else if(TIMESCALE == 4'd19) begin
        CLK_ADC = CLK_US524288;
    end else if(TIMESCALE == 4'd20) begin
        CLK_ADC = CLK_US1048576;
    end else if(TIMESCALE == 4'd21) begin
        CLK_ADC = CLK_US2097152;
    end else if(TIMESCALE == 4'd22) begin
        CLK_ADC = CLK_US4194304;
    end else if(TIMESCALE == 4'd23) begin
        CLK_ADC = CLK_US8388608;
*/
    end else begin
        CLK_ADC = 1'b0;
    end
end
  /*  
//------------------------------------------------------------------//
// ADC DATA READING                                                 //
//------------------------------------------------------------------//
always @ (negedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        DATA_OUT <= 8'b0;
    end else begin
        DATA_OUT <= ADC_DATA;
    end
end

//assign DATA_OUT = ADC_DATA;
*/
endmodule




// -----------------------------------------------------------------------------
// Source file: AdcDriver/d_Driver_ADCRamBuffer.v
// -----------------------------------------------------------------------------
//==================================================================//
// File:    d_Driver_ADCRamBuffer.v                                 //
// Version: X                                                       //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   July 15, 2005                                                  //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver X          July 15, 2005   Initial Development Release       //
//                                                                  //
//==================================================================//

module ADCDataBuffer(
    CLK_64MHZ, MASTER_CLK, MASTER_RST,
    TIMESCALE, TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET,
    ADC_DATA,
    CLK_ADC,
    SNAP_DATA_EXT, SNAP_ADDR_EXT, SNAP_CLK_EXT,
    TRIGGERSTYLE
    );
    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter ss_fifo_fill      = 2'b00;
parameter ss_fifo_half      = 2'b01;
parameter ss_save_snapshot  = 2'b11;
parameter ss_invalid        = 2'b10;

    
    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input       CLK_64MHZ;
input       MASTER_CLK;
input       MASTER_RST;
input[3:0]  TIMESCALE;
input[10:0]  TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET;
input[8:0]  ADC_DATA;

output      CLK_ADC;

output[8:0] SNAP_DATA_EXT;
input[10:0] SNAP_ADDR_EXT;
input       SNAP_CLK_EXT;

input[1:0] TRIGGERSTYLE;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_64MHZ, MASTER_CLK, MASTER_RST;
wire[3:0]  TIMESCALE;
wire[10:0]  TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET;
wire[8:0]  ADC_DATA;
wire CLK_ADC;
wire[8:0] SNAP_DATA_EXT;
wire[10:0] SNAP_ADDR_EXT;
wire SNAP_CLK_EXT;
wire[1:0] TRIGGERSTYLE;


//----------------------//
// VARIABLES            //
//----------------------//
wire[8:0]   data_from_adc;
reg triggered;
reg[1:0]    sm_adc_ram;
reg[10:0]   fifo_addr;
reg[8:0]    data_from_adc_buffered;
reg[10:0]   trig_addr;
wire[8:0]   buf_adc_data;
reg[10:0]   snap_addr, buf_adc_addr;



//==================================================================//
// 'SUB-ROUTINES'                                                   //
//==================================================================//
//------------------------------------------------------------------//
// Instanstiate the ADC                                             //
//------------------------------------------------------------------//

Driver_ADC ADC(
    .CLK_64MHZ(CLK_64MHZ),
    .MASTER_RST(MASTER_RST),
    .TIMESCALE(TIMESCALE),
    .CLK_ADC(CLK_ADC),
    .ADC_DATA(ADC_DATA),
    .DATA_OUT(data_from_adc)
    );

//------------------------------------------------------------------//
// Initialize the RAMs WE WILL NEED MORE!                           //
//   RAM is structured as follows:                                  //
//     Dual-Access RAM                                              //
//     18kBits -> 2048Bytes + 1Parity/Byte                          //
//     Access A: 8bit + 1parity (ADC_Write)                         //
//     Access B: 8bit + 1parity (Read)                              //
//------------------------------------------------------------------//
wire VCC, GND;
assign VCC = 1'b1;
assign GND = 1'b0;

// move the following into a more organized area
wire[10:0] vert_adjustment;
assign vert_adjustment = (VERT_OFFSET);

RAMB16_S9_S9 ADC_QuasiFifo_Buffer(
    .DOA(),                     .DOB(buf_adc_data[7:0]),
    .DOPA(),                    .DOPB(buf_adc_data[8]),
    .ADDRA(fifo_addr),          .ADDRB(buf_adc_addr),
    .CLKA(CLK_ADC),             .CLKB(CLK_ADC),
    .DIA(data_from_adc[7:0]),   .DIB(8'b0),
    .DIPA(data_from_adc[8]),    .DIPB(GND),
    .ENA(VCC),                  .ENB(VCC),
    .WEA(VCC),                  .WEB(GND),
    .SSRA(GND),                 .SSRB(GND)
    );
    
RAMB16_S9_S9 ADC_Data_Snapshot(
    .DOA(),                                             .DOB(SNAP_DATA_EXT[7:0]),
    .DOPA(),                                            .DOPB(SNAP_DATA_EXT[8]),
    .ADDRA(snap_addr),                                  .ADDRB(SNAP_ADDR_EXT),
    .CLKA(CLK_ADC),                                     .CLKB(SNAP_CLK_EXT),
    .DIA(buf_adc_data[7:0]+vert_adjustment[7:0]),       .DIB(8'b0),   /* VERTICAL OFFSET */
    .DIPA(buf_adc_data[8]+vert_adjustment[8]),          .DIPB(GND),   /* VERTICAL OFFSET */
    .ENA(VCC),                                          .ENB(VCC),
    .WEA(VCC),                                          .WEB(GND),
    .SSRA(GND),                                         .SSRB(GND)
    );


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

/* STATE_MACHINE */
always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)
        sm_adc_ram <= ss_fifo_fill;
    else begin
//        if(sm_adc_ram != ss_fifo_fill || sm_adc_ram != ss_fifo_half || sm_adc_ram != ss_save_snapshot)
//            sm_adc_ram <= ss_fifo_fill;
        if(sm_adc_ram == ss_fifo_fill && triggered)
            sm_adc_ram <= ss_fifo_half;
        else if(sm_adc_ram == ss_fifo_half && (fifo_addr == (trig_addr + 11'd1023)))
            sm_adc_ram <= ss_save_snapshot;
        else if(sm_adc_ram == ss_save_snapshot && snap_addr == 11'd2047)
            sm_adc_ram <= ss_fifo_fill;
        else if(sm_adc_ram == ss_invalid)
            sm_adc_ram <= ss_fifo_fill;
        else 
            sm_adc_ram <= sm_adc_ram;
    end
end

/* FIFO ADDR */
always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)
        fifo_addr <= 11'b0;
    else if(sm_adc_ram == ss_fifo_fill || sm_adc_ram == ss_fifo_half)
        fifo_addr <= fifo_addr + 1;
    else
        fifo_addr <= fifo_addr;
end

/* TRIGGER */
always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)
        data_from_adc_buffered <= 9'b0;
    else
        data_from_adc_buffered <= data_from_adc;
end

always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST)
        triggered <= 1'b0;
    else
        triggered <= (TRIGGERSTYLE == 2'b00) && (data_from_adc_buffered < TRIGGER_LEVEL && data_from_adc >= TRIGGER_LEVEL) || // >=
                     (TRIGGERSTYLE == 2'b01) && (data_from_adc_buffered > TRIGGER_LEVEL && data_from_adc <= TRIGGER_LEVEL);   // <=
end

always @ (posedge triggered or posedge MASTER_RST) begin
    if(MASTER_RST)
        trig_addr <= 11'b0;
    else if(sm_adc_ram == ss_fifo_fill)
        trig_addr <= fifo_addr;
    else
        trig_addr <= trig_addr;
end
        
/* SNAPSHOT */
always @ (posedge CLK_ADC or posedge MASTER_RST) begin
    if(MASTER_RST) begin
        snap_addr <= 11'b0;
        buf_adc_addr <= 11'b0;
    end else if(sm_adc_ram == ss_save_snapshot) begin
        snap_addr <= snap_addr + 1;
        buf_adc_addr <= buf_adc_addr + 1;
    end else begin
        buf_adc_addr <= trig_addr - (HORZ_OFFSET-11'd319);        /* HORIZONTAL OFFSET */
        snap_addr <= 11'b0;
    end
end

endmodule

// -----------------------------------------------------------------------------
// Source file: AdcDriver/d_Driver_RamBuffer.v
// -----------------------------------------------------------------------------
//==================================================================
// File:    d_Driver_RamBuffer.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================

module ADCDataBuffer(
    CLK_64MHZ, MASTER_RST,
    CLK180_64MHZ,
    TIME_BASE,
    RAM_ADDR, RAM_DATA, RAM_CLK,
    ADC_DATA, ADC_CLK,
    TRIG_ADDR,
    VGA_WRITE_DONE,
    TRIGGER_LEVEL,
    sm_trig
    );
    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter ss_wait_for_trig  = 2'b00;
parameter ss_fill_mem_half  = 2'b01;
parameter ss_write_buffer   = 2'b11;
parameter ss_invalid        = 2'b10;
parameter P_trigger_level   = 8'h80;


    
    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//

//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input        CLK_64MHZ;
input        CLK180_64MHZ;
input        MASTER_RST;         // Global Asyncronous Reset
input[5:0]   TIME_BASE;          // The selected V/Div
input[10:0]  RAM_ADDR;
output[7:0]  RAM_DATA;
input        RAM_CLK;
input[7:0]   ADC_DATA;
output       ADC_CLK;
output[10:0] TRIG_ADDR;
input        VGA_WRITE_DONE;
input[8:0]   TRIGGER_LEVEL;

output[1:0] sm_trig;


//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_64MHZ, MASTER_RST, CLK180_64MHZ;
wire[5:0]  TIME_BASE;
wire[10:0] RAM_ADDR;
wire[7:0]  RAM_DATA;
wire       RAM_CLK;
wire[7:0]  ADC_DATA;
wire       ADC_CLK;
reg[10:0]  TRIG_ADDR;
wire       VGA_WRITE_DONE;
wire[8:0]  TRIGGER_LEVEL;

//----------------------//
// VARIABLES            //
//----------------------//



//==================================================================//
// 'SUB-ROUTINES'                                                   //
//==================================================================//
//------------------------------------------------------------------//
// Instanstiate the ADC                                             //
//------------------------------------------------------------------//
wire[7:0] DATA_FROM_ADC;
Driver_ADC ADC(
    .CLK_64MHZ(CLK_64MHZ),
    .MASTER_RST(MASTER_RST),
    .TIME_BASE(TIME_BASE),
    .ADC_CLK(ADC_CLK),
    .ADC_DATA(ADC_DATA),
    .DATA_OUT(DATA_FROM_ADC)
    );

//------------------------------------------------------------------//
// Initialize the RAMs WE WILL NEED MORE!                           //
//   RAM is structured as follows:                                  //
//     Dual-Access RAM                                              //
//     18kBits -> 2048Bytes + 1Parity/Byte                          //
//     Access A: 8bit + 1parity (ADC_Write)                         //
//     Access B: 8bit + 1parity (Read)                              //
//------------------------------------------------------------------//
reg[10:0] ADDRA;	
wire VCC, GND;
assign VCC = 1'b1;
assign GND = 1'b0;

RAMB16_S9_S9 ADC_QuasiFifo_Buffer(
    .DOA(),                 .DOB(RAM_DATA),
    .DOPA(),                .DOPB(),
    .ADDRA(ADDRA),          .ADDRB(RAM_ADDR),
    .CLKA(CLK180_64MHZ),    .CLKB(RAM_CLK),
    .DIA(DATA_FROM_ADC),    .DIB(8'b0),
    .DIPA(GND),             .DIPB(GND),
    .ENA(VCC),              .ENB(VCC),
    .WEA(VCC),              .WEB(GND),
    .SSRA(GND),             .SSRB(GND)
    );

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

reg[1:0] sm_trig;
reg trigger_detected;
reg[9:0] cnt_1024bytes;
reg mem_half_full;

/* THE RAM WRITING TRIGGERING STATE MACHINE */
always @ (posedge CLK_64MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        sm_trig <= ss_wait_for_trig;
    else if(sm_trig == ss_wait_for_trig && trigger_detected == 1'b1)
        sm_trig <= ss_fill_mem_half;
    else if(sm_trig == ss_fill_mem_half && mem_half_full == 1'b1)
        sm_trig <= ss_write_buffer;
    else if(sm_trig == ss_write_buffer && /*trigger_detected == 1'b0 &&*/ VGA_WRITE_DONE == 1'b1)
        sm_trig <= ss_wait_for_trig;
    else if(sm_trig == ss_invalid)
        sm_trig <= ss_wait_for_trig;
    else
        sm_trig <= sm_trig;
end


/* THIS PART DEALS WITH THE ADDRESS OF THE ADC BUFFER   */
/* Write in a Circular Buffer soft of way               */
always @ (posedge ADC_CLK or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ADDRA <= 11'b0;
    end else if(sm_trig == ss_wait_for_trig || sm_trig == ss_fill_mem_half)
        ADDRA <= ADDRA + 1;
    else
        ADDRA <= ADDRA;
//        ADDRA <= ADDRA + 1;
end

/* LATCHING THE TRIGGER  */
always @ (ADC_DATA) begin
    if(ADC_DATA >= TRIGGER_LEVEL)
        trigger_detected = 1'b1;
    else
        trigger_detected = 1'b0;
end

/* GATHERING 1024 MORE BYTES OF MEMORY */
always @ (posedge ADC_CLK or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        cnt_1024bytes <= 10'b0;
    else if(sm_trig == ss_fill_mem_half)
        cnt_1024bytes <= cnt_1024bytes + 1;
    else
        cnt_1024bytes <= 10'b0;
//        cnt_1024bytes <= cnt_1024bytes;
end

always @ (cnt_1024bytes) begin
    if(cnt_1024bytes == 10'h3FF)
        mem_half_full = 1'b1;
    else
        mem_half_full = 1'b0;
end

/* STORING THE TRIGGER ADDRESS */
always @ (posedge trigger_detected or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        TRIG_ADDR <= 11'd0;
    else
        TRIG_ADDR <= ADDRA;
end



















endmodule

// -----------------------------------------------------------------------------
// Source file: Mouse/d_DriverMouse.v
// -----------------------------------------------------------------------------
//==================================================================//
// File:    d_MouseDriver.v                                         //
// Version: 0.0.0.1                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Apr 28, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     Apr 28, 2005   Under Development                 //
//                                                                  //
//==================================================================//

module Driver_mouse(
    CLK_50MHZ, MASTER_RST,
    PS2C, PS2D,
    XCOORD, YCOORD,
    L_BUTTON, R_BUTTON, M_BUTTON
    );
    
//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//
parameter ss_CLK_LOW_100US    = 4'b0000;
parameter ss_DATA_LOW         = 4'b0001;
parameter ss_SET_BIT_0        = 4'b0011;
parameter ss_SET_BIT_1        = 4'b0010;
parameter ss_SET_BIT_2        = 4'b0110;
parameter ss_SET_BIT_3        = 4'b0111;
parameter ss_SET_BIT_4        = 4'b0101;
parameter ss_SET_BIT_5        = 4'b0100;
parameter ss_SET_BIT_6        = 4'b1100;
parameter ss_SET_BIT_7        = 4'b1101;
parameter ss_SET_BIT_PARITY   = 4'b1111;
parameter ss_SET_BIT_STOP     = 4'b1110;
parameter ss_WAIT_BIT_ACK     = 4'b1010;
parameter ss_GET_MOVEMENT     = 4'b1000;

parameter P_Lbut_index  = 1;
parameter P_Mbut_index  = 2;
parameter P_Rbut_index  = 3;

    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS               //
//----------------------//
input CLK_50MHZ;            // System wide clock
input MASTER_RST;           // System wide reset
inout PS2C;                 // PS2 clock
inout PS2D;                 // PS2 data

//----------------------//
// OUTPUTS              //
//----------------------//
output[11:0] XCOORD;        // X coordinate of the cursor
output[11:0] YCOORD;        // Y coordinate of the cursor
output L_BUTTON, R_BUTTON, M_BUTTON;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ, MASTER_RST;
wire PS2C, PS2D;
reg[11:0] XCOORD;
reg[11:0] YCOORD;
reg L_BUTTON, R_BUTTON, M_BUTTON;

//----------------------//
// REGISTERS            //
//----------------------//
reg[12:0] Counter_timer;
reg[5:0]  Counter_bits;
reg[3:0]  sm_ps2mouse; 
reg[32:0] data_in_buf;




//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

//------------------------------------------------------------------//
// INTERMEDIATE VALUES                                              //
//------------------------------------------------------------------//
reg[7:0]  Counter_PS2C;
reg       CLK_ps2c_debounced;

// Debounce the PS2C line.
//  The mouse is generally not outputting a nice rising clock edge.
//  To eliminate the false edge detection, make sure it is high/low
//  for at least 256 counts (5.12us off 50MHz) before triggering the CLK.
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        Counter_PS2C <= 8'b0;
    end else begin
        if(PS2C == 1'b1) begin
            if(Counter_PS2C == 8'hFF)
                Counter_PS2C <= Counter_PS2C;
            else
                Counter_PS2C <= Counter_PS2C + 1;
        end else begin
            if(Counter_PS2C == 8'b0)
                Counter_PS2C <= Counter_PS2C;
            else
                Counter_PS2C <= Counter_PS2C - 1;
        end
    end
end

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        CLK_ps2c_debounced <= 1'b0;
    else if(Counter_PS2C == 8'b0)
        CLK_ps2c_debounced <= 1'b0;
    else if(Counter_PS2C == 8'hFF)
        CLK_ps2c_debounced <= 1'b1;
    else
        CLK_ps2c_debounced <= CLK_ps2c_debounced;
end


//------------------------------------------------------------------//
// INTERPRETING MOVEMENTS                                           //
//------------------------------------------------------------------//
reg[7:0] xcoord_buf;
reg[7:0] ycoord_buf;

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        xcoord_buf <= 8'b0;
    end else if(data_in_buf[5] == 1'b0) begin
        xcoord_buf <= data_in_buf[19:12];
    end else begin
        xcoord_buf <= ((~(data_in_buf[19:12]))+1);
    end
end

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ycoord_buf <= 8'b0;
    end else if(data_in_buf[6] == 1'b0) begin
        ycoord_buf <= data_in_buf[30:23];
    end else begin
        ycoord_buf <= ((~(data_in_buf[30:23]))+1);
    end
end


always @ (posedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        XCOORD <= 12'd320;
    end else if(Counter_bits == 6'd32 && (data_in_buf[7] == 1'b0)) begin
        if(data_in_buf[5] == 1'b1) begin    // NEGITIVE
            if(XCOORD <= xcoord_buf)
                XCOORD <= 12'b0;
            else
                XCOORD <= XCOORD - xcoord_buf;
        end else begin  // POSITIVE
            if((XCOORD + xcoord_buf) >= 12'd639)
                XCOORD <= 12'd639;
            else
                XCOORD <= XCOORD + xcoord_buf;
        end
    end else begin
        XCOORD <= XCOORD;
    end
end

always @ (posedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        YCOORD <= 12'd199;
    end else if(Counter_bits == 6'd32 && (data_in_buf[8] == 1'b0)) begin
        if(data_in_buf[6] == 1'b0) begin
            if( (YCOORD < 12'd401) && ((YCOORD + ycoord_buf) >= 12'd401) )
                YCOORD <= 12'd400;
            else if( ((YCOORD >= 12'd441) /*&& (YCOORD <= 12'd520)*/) && ((YCOORD + ycoord_buf) > 12'd520) )
                YCOORD <= (YCOORD + ycoord_buf) - 12'd521;
            else
                YCOORD <= YCOORD + ycoord_buf;
        end else begin
            if( /*(YCOORD < 12'd401) &&*/ (YCOORD < ycoord_buf) )
                YCOORD <= 12'd521 - ycoord_buf;
            else if( (YCOORD >= 12'd441) && ((YCOORD-12'd441) < ycoord_buf) )
                YCOORD <= 12'd441;
            else
                YCOORD <= YCOORD - ycoord_buf;
        end
    end else begin
        YCOORD <= YCOORD;
    end
end

//------------------------------------------------------------------//
// INTERPRETING BUTTONS                                             //
//------------------------------------------------------------------//
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        L_BUTTON <= 1'b0;
        M_BUTTON <= 1'b0;
        R_BUTTON <= 1'b0;
    end else if(Counter_bits == 6'd32) begin
        L_BUTTON <= data_in_buf[P_Lbut_index];
        M_BUTTON <= data_in_buf[P_Mbut_index];
        R_BUTTON <= data_in_buf[P_Rbut_index];
    end else begin
        L_BUTTON <= L_BUTTON;
        M_BUTTON <= M_BUTTON;
        R_BUTTON <= R_BUTTON;
    end
end
        
        


//------------------------------------------------------------------//
// SENDING DATA                                                     //
//------------------------------------------------------------------//
reg PS2C_out, PS2D_out;

assign PS2C = PS2C_out;
assign PS2D = PS2D_out;
              

always @ (Counter_timer or MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        PS2C_out = 1'bZ;
    end else if((Counter_timer <= 13'd5500) && (MASTER_RST == 1'b0))
        PS2C_out = 1'b0;
    else
        PS2C_out = 1'bZ;
end

always @ (sm_ps2mouse or Counter_timer or MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        PS2D_out = 1'bZ;
    end else if(Counter_timer >= 13'd5000 && sm_ps2mouse == ss_DATA_LOW) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_0) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_1) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_2) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_3) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_4) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_5) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_6) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_7) begin
        PS2D_out = 1'b1;
    end else if(sm_ps2mouse == ss_SET_BIT_PARITY) begin
        PS2D_out = 1'b0;
    end else if(sm_ps2mouse == ss_SET_BIT_STOP) begin
        PS2D_out = 1'b1;
    end else begin
        PS2D_out = 1'bZ;
    end
end

//------------------------------------------------------------------//
// RECIEVING DATA                                                   //
//------------------------------------------------------------------//
always @ (negedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        data_in_buf <= 33'b0;
    end else if(sm_ps2mouse == ss_GET_MOVEMENT) begin
        data_in_buf <= data_in_buf >> 1;
        data_in_buf[32] <= PS2D;
    end else
        data_in_buf <= data_in_buf;
end



//------------------------------------------------------------------//
// COUNTERS FOR STATE MACHINE                                       //
//------------------------------------------------------------------//
// COUNTER: timer
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        Counter_timer <= 13'b0;
    else if(Counter_timer == 13'd6000)
        Counter_timer <= Counter_timer;
    else
        Counter_timer <= Counter_timer + 1;
end

// COUNTER: rec_data_bit_cnt
always @ (negedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        Counter_bits <= 6'd22;
    end else if(sm_ps2mouse == ss_GET_MOVEMENT) begin
        if(Counter_bits == 6'd32)
            Counter_bits <= 6'd0;
        else
            Counter_bits <= Counter_bits + 1;
    end else begin
        Counter_bits <= Counter_bits;
    end
end


//------------------------------------------------------------------//
// MOUSE STATE MACHINE                                              //
//------------------------------------------------------------------//
always @ (negedge CLK_ps2c_debounced or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
            sm_ps2mouse <= ss_DATA_LOW;
    end else if(sm_ps2mouse == ss_DATA_LOW) begin
            sm_ps2mouse <= ss_SET_BIT_0;
    end else if(sm_ps2mouse == ss_SET_BIT_0) begin
            sm_ps2mouse <= ss_SET_BIT_1;
    end else if(sm_ps2mouse == ss_SET_BIT_1) begin
            sm_ps2mouse <= ss_SET_BIT_2;
    end else if(sm_ps2mouse == ss_SET_BIT_2) begin
            sm_ps2mouse <= ss_SET_BIT_3;
    end else if(sm_ps2mouse == ss_SET_BIT_3) begin
            sm_ps2mouse <= ss_SET_BIT_4;
    end else if(sm_ps2mouse == ss_SET_BIT_4) begin
            sm_ps2mouse <= ss_SET_BIT_5;
    end else if(sm_ps2mouse == ss_SET_BIT_5) begin
            sm_ps2mouse <= ss_SET_BIT_6;
    end else if(sm_ps2mouse == ss_SET_BIT_6) begin
            sm_ps2mouse <= ss_SET_BIT_7;
    end else if(sm_ps2mouse == ss_SET_BIT_7) begin
            sm_ps2mouse <= ss_SET_BIT_PARITY;
    end else if(sm_ps2mouse == ss_SET_BIT_PARITY) begin
            sm_ps2mouse <= ss_SET_BIT_STOP;
    end else if(sm_ps2mouse == ss_SET_BIT_STOP) begin
            sm_ps2mouse <= ss_WAIT_BIT_ACK;
    end else if(sm_ps2mouse == ss_WAIT_BIT_ACK) begin
            sm_ps2mouse <= ss_GET_MOVEMENT;
    end else if(sm_ps2mouse == ss_GET_MOVEMENT) begin
            sm_ps2mouse <= sm_ps2mouse;
    end else begin
        sm_ps2mouse <= ss_DATA_LOW;
    end
end

















endmodule


// -----------------------------------------------------------------------------
// Source file: SegDriver/d_HexSeg.v
// -----------------------------------------------------------------------------
//==================================================================
// File:    d_MouseDriver.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett, Clarke Ellis
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================

module sub_HexSeg(
    DATA_IN,
    SEG_OUT
    );
    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS               //
//----------------------//
input[3:0] DATA_IN;
//----------------------//
// OUTPUTS              //
//----------------------//
output[6:0] SEG_OUT;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire[3:0] DATA_IN;
reg[6:0] SEG_OUT;

//----------------------//
// REGISTERS            //
//----------------------//

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
//     ____
//  5 | 0  | 1
//    |____|
//  4 | 6  | 2
//    |____|
//      3

always @ (DATA_IN) begin
SEG_OUT[6] = !((DATA_IN == 4'h2) |
               (DATA_IN == 4'h3) |
               (DATA_IN == 4'h4) |
               (DATA_IN == 4'h5) |
               (DATA_IN == 4'h6) |
               (DATA_IN == 4'h8) |
               (DATA_IN == 4'h9) |
               (DATA_IN == 4'hA) |
               (DATA_IN == 4'hB) |
               (DATA_IN == 4'hD) |
               (DATA_IN == 4'hE) |
               (DATA_IN == 4'hF));

SEG_OUT[5] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h4) ||
             (DATA_IN == 4'h5) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hB) ||
             (DATA_IN == 4'hC) ||
             (DATA_IN == 4'hE) ||
             (DATA_IN == 4'hF));

SEG_OUT[4] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h2) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hB) ||
             (DATA_IN == 4'hC) ||
             (DATA_IN == 4'hD) ||
             (DATA_IN == 4'hE) ||
             (DATA_IN == 4'hF));

SEG_OUT[3] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h2) ||
             (DATA_IN == 4'h3) ||
             (DATA_IN == 4'h5) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hB) ||
             (DATA_IN == 4'hC) ||
             (DATA_IN == 4'hD) ||
             (DATA_IN == 4'hE));

SEG_OUT[2] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h1) ||
             (DATA_IN == 4'h3) ||
             (DATA_IN == 4'h4) ||
             (DATA_IN == 4'h5) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h7) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hB) ||
             (DATA_IN == 4'hD));

SEG_OUT[1] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h1) ||
             (DATA_IN == 4'h2) ||
             (DATA_IN == 4'h3) ||
             (DATA_IN == 4'h4) ||
             (DATA_IN == 4'h7) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hD));

SEG_OUT[0] = !((DATA_IN == 4'h0) ||
             (DATA_IN == 4'h2) ||
             (DATA_IN == 4'h3) ||
             (DATA_IN == 4'h5) ||
             (DATA_IN == 4'h6) ||
             (DATA_IN == 4'h7) ||
             (DATA_IN == 4'h8) ||
             (DATA_IN == 4'h9) ||
             (DATA_IN == 4'hA) ||
             (DATA_IN == 4'hC) ||
             (DATA_IN == 4'hE) ||
             (DATA_IN == 4'hF));


end

endmodule








// -----------------------------------------------------------------------------
// Source file: SegDriver/d_SegDriver.v
// -----------------------------------------------------------------------------
//==================================================================
// File:    d_MouseDriver.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett, Clarke Ellis
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================

module sub_SegDriver(
    CLK_50MHZ, MASTER_RST,
    DATA_IN,
    SEG_OUT, SEG_SEL
    );
    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS               //
//----------------------//
input CLK_50MHZ;    // System wide clock
input MASTER_RST;   // System wide reset
input[15:0] DATA_IN;
//----------------------//
// OUTPUTS              //
//----------------------//
output[6:0] SEG_OUT;
output[3:0] SEG_SEL;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ, MASTER_RST;
wire[15:0] DATA_IN;
reg [6:0]  SEG_OUT;
reg [3:0]  SEG_SEL;

//----------------------//
// REGISTERS            //
//----------------------//
wire[6:0]  seg0, seg1, seg2, seg3;
reg[7:0] clk_390kHz;

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        clk_390kHz <= 8'b0;
    else
        clk_390kHz <= clk_390kHz + 1;
end

always @ (posedge clk_390kHz[7] or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1)
        SEG_SEL <= 4'b1110;
    else begin
        SEG_SEL[3:1] <= SEG_SEL[2:0];
        SEG_SEL[0] <= SEG_SEL[3];
    end
end

always @ (SEG_SEL or seg0 or seg1 or seg2 or seg3) begin
    if(SEG_SEL == 4'b1110)
        SEG_OUT = seg0;
    else if(SEG_SEL == 4'b1101)
        SEG_OUT = seg1;
    else if(SEG_SEL == 4'b1011)
        SEG_OUT = seg2;
    else if(SEG_SEL == 4'b0111)
        SEG_OUT = seg3;
    else
        SEG_OUT = 7'b1111111;
end

sub_HexSeg sub_seg3( .DATA_IN(DATA_IN[15:12]),
                     .SEG_OUT(seg3)
                    );
sub_HexSeg sub_seg2( .DATA_IN(DATA_IN[11:8]),
                     .SEG_OUT(seg2)
                   );
sub_HexSeg sub_seg1( .DATA_IN(DATA_IN[7:4]),
                     .SEG_OUT(seg1)
                   );
sub_HexSeg sub_seg0( .DATA_IN(DATA_IN[3:0]),
                     .SEG_OUT(seg0)
                   );

endmodule






// -----------------------------------------------------------------------------
// Source file: UserInput/d_MouseInput.v
// -----------------------------------------------------------------------------
//==================================================================//
// File:    d_MouseInput.v                                          //
// Version: 0.0.0.2                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 08, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     May   , 2005   Under Development                 //
// Ver 0.0.0.2     Jun 08, 2005    Modulized 'UserLines'            //
//                                                                  //
//==================================================================//

module Driver_MouseInput(
    CLK_50MHZ, MASTER_RST,
    XCOORD, YCOORD, L_BUTTON, R_BUTTON, M_BUTTON,
    TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET,
    TIMESCALE, TRIGGERSTYLE
    );


//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter P_clickLimit_left     = 10'd556;
parameter P_clickLimit_right    = 10'd558;
parameter P_clickLimit_leftV    = 10'd559;
parameter P_clickLimit_rightV   = 10'd561;
parameter P_clickLimit_top      = 10'd102;
parameter P_clickLimit_bot      = 10'd100;


//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ;            // System wide clock
input MASTER_RST;           // System wide reset
input[9:0] XCOORD;          // X coordinate of the cursor
input[9:0] YCOORD;          // Y coordinate of the cursor
input L_BUTTON;             // Left Mouse Button Press
input R_BUTTON;             // Right Mouse Button Press
input M_BUTTON;             // Middle Mouse Button Press
output[9:0] TRIGGER_LEVEL;  // Current Trigger Level
output[9:0] VERT_OFFSET;    // VERTICAL OFFSET
output[9:0] HORZ_OFFSET;    // HORIZONTAL OFFSET
output[3:0] TIMESCALE;      // Current Tiemscale value
output[1:0] TRIGGERSTYLE;   // Style (rise/fall) of trigger

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ, MASTER_RST;
wire[9:0] XCOORD;
wire[9:0] YCOORD;
wire L_BUTTON, R_BUTTON, M_BUTTON;
wire[9:0] TRIGGER_LEVEL, VERT_OFFSET, HORZ_OFFSET;
wire[3:0] TIMESCALE;
wire[1:0] TRIGGERSTYLE;

//----------------------//
// REGISTERS            //
//----------------------//


//----------------------//
// TESTING              //
//----------------------//




//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//

//------------------------------------------------------------------//
// INTERMEDIATES                                                    //
//------------------------------------------------------------------//

// -- LEFT BUTTON --
wire Lrise, Lfall;
reg  Lbuf;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) Lbuf <= 1'b0;
    else                   Lbuf <= L_BUTTON;
end

assign Lrise = (!Lbuf &  L_BUTTON);
assign Lfall = ( Lbuf & !L_BUTTON);

// -- RIGHT BUTTON --
wire Rrise, Rfall;
reg  Rbuf;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) Rbuf <= 1'b0;
    else                   Rbuf <= R_BUTTON;
end

assign Rrise = (!Rbuf &  R_BUTTON);
assign Rfall = ( Rbuf & !R_BUTTON);


// -- MIDDLE BUTTON --
wire Mrise, Mfall;
reg  Mbuf;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) Mbuf <= 1'b0;
    else                   Mbuf <= M_BUTTON;
end

assign Mrise = (!Mbuf &  M_BUTTON);
assign Mfall = ( Mbuf & !M_BUTTON);


//------------------------------------------------------------------//
// USER MODIFIABLE LINES                                            //
//------------------------------------------------------------------//
sub_UserLines set_trigger(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .LINE_VALUE_OUT(TRIGGER_LEVEL),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD),
    .RESET_VALUE(10'd99),
    .LEFT(P_clickLimit_left),
	.RGHT(P_clickLimit_right),
    .BOT(TRIGGER_LEVEL),
//    .BOT(TRIGGER_LEVEL-1'b1),
	.TOP(TRIGGER_LEVEL+1'b1),
    .SETXnY(1'b0)
    );
    
sub_UserLines set_Voffset(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .LINE_VALUE_OUT(VERT_OFFSET),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD),
    .RESET_VALUE(10'd0),
    .LEFT(P_clickLimit_leftV),
	.RGHT(P_clickLimit_rightV),
    .BOT(VERT_OFFSET),
//	  .BOT(VERT_OFFSET-1'b1),
	.TOP(VERT_OFFSET+1'b1),
    .SETXnY(1'b0)
    );
    
sub_UserLines set_Hoffset(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .LINE_VALUE_OUT(HORZ_OFFSET),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD),
    .RESET_VALUE(10'd319),
//    .LEFT(HORZ_OFFSET-1'b1),
    .LEFT(HORZ_OFFSET),
	.RGHT(HORZ_OFFSET+1'b1),
	.BOT(P_clickLimit_bot),
	.TOP(P_clickLimit_top),
    .SETXnY(1'b1)
    );
    
sub_UserTimeScaleBox TSBox(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .VALUE_OUT(TIMESCALE),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD)
    );
    
sub_UserTriggerStyleBox TrigStyleBox(
    .MASTER_CLK(CLK_50MHZ), .MASTER_RST(MASTER_RST),
    .VALUE_OUT(TRIGGERSTYLE),
    .BUTTON_RISE(Lrise),
	.BUTTON_FALL(Lfall),
    .XCOORD(XCOORD),
	.YCOORD(YCOORD)
    );




endmodule


// -----------------------------------------------------------------------------
// Source file: UserInput/sub_UserBoxes.v
// -----------------------------------------------------------------------------
//==================================================================//
// File:    sub_UserBoxes.v                                         //
// Version: 0.0.0.1                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jul 15, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
//                                                                  //
//==================================================================//

module sub_UserTimeScaleBox(
    MASTER_CLK, MASTER_RST,
    VALUE_OUT,
    BUTTON_RISE, BUTTON_FALL,
    XCOORD, YCOORD
);
    
//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//
parameter P_UPleft   = 10'h99;
parameter P_UPright  = 10'h9D;
parameter P_UPbot    = 10'h1E8;
parameter P_UPtop    = 10'h1EE;
parameter P_DNleft   = 10'h9F;
parameter P_DNright  = 10'hA3;
parameter P_DNbot    = 10'h1E8;
parameter P_DNtop    = 10'h1EE;



//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input MASTER_CLK;       // global master clock
input MASTER_RST;       // global master reset
input[9:0] XCOORD, YCOORD;   // X and Y coordinates of the current mouse
                        // position. See the documentation for details
input BUTTON_RISE;      // Trigger has risen
input BUTTON_FALL;      // Trigger has fallen

output[3:0] VALUE_OUT;  //

//----------------------//
//        NODES         //
//----------------------//
wire      MASTER_CLK, MASTER_RST;
wire[9:0] XCOORD, YCOORD;
wire      BUTTON_RISE, BUTTON_FALL;

reg[3:0]  VALUE_OUT;




//==================================================================//
//                         T E S T I N G                            //
//==================================================================//
// NOTHING TO TEST

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
wire in_range_up, in_range_dn;

assign in_range_up = (((YCOORD >= P_UPbot) && (YCOORD <= P_UPtop)) && ((XCOORD >= P_UPleft && XCOORD <= P_UPright)));
assign in_range_dn = (((YCOORD >= P_DNbot) && (YCOORD <= P_DNtop)) && ((XCOORD >= P_DNleft && XCOORD <= P_DNright)));

always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        VALUE_OUT <= 4'b0;
    else if(BUTTON_RISE && in_range_up)
        VALUE_OUT <= VALUE_OUT + 1;
    else if(BUTTON_RISE && in_range_dn)
        VALUE_OUT <= VALUE_OUT - 1;
    else
        VALUE_OUT <= VALUE_OUT;
end


endmodule

//==================================================================//
//==================================================================//
//==================================================================//
//==================================================================//
//==================================================================//
//==================================================================//


module sub_UserTriggerStyleBox(
    MASTER_CLK, MASTER_RST,
    VALUE_OUT,
    BUTTON_RISE, BUTTON_FALL,
    XCOORD, YCOORD
);
    
//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//
parameter P_RISEleft   = 10'h39;
parameter P_RISEright  = 10'h3D;
parameter P_RISEbot    = 10'h1DF;
parameter P_RISEtop    = 10'h1E5;
parameter P_FALLleft   = 10'h3F;
parameter P_FALLright  = 10'h43;
parameter P_FALLbot    = 10'h1DF;
parameter P_FALLtop    = 10'h1E5;



//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input MASTER_CLK;           // global master clock
input MASTER_RST;           // global master reset
input[9:0] XCOORD, YCOORD;  // X and Y coordinates of the current mouse
                            // position. See the documentation for details
input BUTTON_RISE;          // Trigger has risen
input BUTTON_FALL;          // Trigger has fallen

output[1:0] VALUE_OUT;      //

//----------------------//
//        NODES         //
//----------------------//
wire      MASTER_CLK, MASTER_RST;
wire[9:0] XCOORD, YCOORD;
wire      BUTTON_RISE, BUTTON_FALL;

reg[1:0]  VALUE_OUT;




//==================================================================//
//                         T E S T I N G                            //
//==================================================================//
// NOTHING TO TEST

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
wire in_range_rise, in_range_fall;

assign in_range_rise = (((YCOORD >= P_RISEbot) && (YCOORD <= P_RISEtop)) && ((XCOORD >= P_RISEleft && XCOORD <= P_RISEright)));
assign in_range_fall = (((YCOORD >= P_FALLbot) && (YCOORD <= P_FALLtop)) && ((XCOORD >= P_FALLleft && XCOORD <= P_FALLright)));

always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        VALUE_OUT <= 2'b00;
    else if(BUTTON_RISE && in_range_rise)
        VALUE_OUT <= 2'b00;
    else if(BUTTON_RISE && in_range_fall)
        VALUE_OUT <= 2'b01;
    else
        VALUE_OUT <= VALUE_OUT;
end


endmodule



// -----------------------------------------------------------------------------
// Source file: UserInput/sub_UserLines.v
// -----------------------------------------------------------------------------
//==================================================================//
// File:    sub_UserLines.v                                         //
// Version: 0.0.0.1                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 08, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     Jun 08, 2005   Under Development                 //
//                                                                  //
//==================================================================//

module sub_UserLines(
    MASTER_CLK, MASTER_RST,
    LINE_VALUE_OUT,
    BUTTON_RISE, BUTTON_FALL,
    XCOORD, YCOORD, RESET_VALUE,
    LEFT, RGHT, BOT, TOP,
    SETXnY
);
    
//==================================================================//
// DEFINITIONS                                                      //
//==================================================================//

    
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input MASTER_CLK;       // global master clock
input MASTER_RST;       // global master reset
input XCOORD, YCOORD;   // X and Y coordinates of the current mouse
                        // position. See the documentation for details
input LEFT, RGHT;       // Left and Right limits for 'InRange'
input TOP, BOT;         // Top and Bottom limits for 'InRange'
input SETXnY;           // Upon trigger, either set the 'Value' to the
                        // X or Y coord.
input BUTTON_RISE;      // Trigger has risen
input BUTTON_FALL;      // Trigger has fallen

output[9:0] LINE_VALUE_OUT;    // a 10 bit register to store the X or Y value

input[9:0] RESET_VALUE; // Reset value

//----------------------//
//        NODES         //
//----------------------//
wire      MASTER_CLK, MASTER_RST;
wire[9:0] XCOORD, YCOORD, RESET_VALUE;
wire[9:0] LEFT, RGHT, TOP, BOT;
wire      SETXnY;
wire      BUTTON_RISE, BUTTON_FALL;

reg[9:0] LINE_VALUE_OUT;




//==================================================================//
//                         T E S T I N G                            //
//==================================================================//
// NOTHING TO TEST

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
wire in_range;
reg drag;

assign in_range = (((YCOORD >= BOT) && (YCOORD <= TOP)) && ((XCOORD >= LEFT && XCOORD <= RGHT)));

// the 'DRAG' state machine
always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        drag <= 1'b0;
    else if(BUTTON_RISE && in_range)
        drag <= 1'b1;
    else if(BUTTON_FALL)
        drag <= 1'b0;
    else
        drag <= drag;
end

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Until this is figured out, it is bad to have the lines at 'zero'
   (due to the comparison for 'in range')
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)
        LINE_VALUE_OUT <= RESET_VALUE;
    else if(drag && SETXnY)
        LINE_VALUE_OUT <= XCOORD;
    else if(drag && !SETXnY && (YCOORD<=10'd400))
        LINE_VALUE_OUT <= YCOORD;
    else
        LINE_VALUE_OUT <= LINE_VALUE_OUT;
end



endmodule


// -----------------------------------------------------------------------------
// Source file: VGA/CharDecode/d_CharDecode.v
// -----------------------------------------------------------------------------
//==================================================================//
// File:    d_CharDecodeSmall.v                                     //
// Version: 0.0.0.1                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 17, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     Jun 17, 2005   Initial Development Release       //
//                                Based on "d_CharDecode.v"         //
//                                                                  //
//==================================================================//

module CharacterDisplay(
    MASTER_CLK, MASTER_RST,
    CLK_VGA, HCNT, VCNT,
    RGB_OUT,
    TIMESCALE, TRIGGERSTYLE,
    XCOORD, YCOORD
    );
                                                                    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter P_black   = 3'b000;
parameter P_yellow  = 3'b110;
parameter P_cyan    = 3'b011;
parameter P_green   = 3'b010;
parameter P_white   = 3'b111;
parameter P_blue    = 3'b111;

//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input MASTER_CLK;                // System wide clock
input MASTER_RST;               // System wide reset
input CLK_VGA;                  // Pixel Clk
input[9:0] HCNT;                // Horizontal Sync Counter
input[9:0] VCNT;                // Vertical Sync Counter
output[2:0] RGB_OUT;            // The RGB data
input[3:0] TIMESCALE;           // TIMESCALE display
input[1:0] TRIGGERSTYLE;        // Style of Trigger
input[11:0] XCOORD;             // XCOORD display
input[11:0] YCOORD;             // XCOORD display



//----------------------//
// WIRES / NODES        //
//----------------------//
wire MASTER_CLK, MASTER_RST, CLK_VGA;
wire[9:0]  HCNT, VCNT;
reg [2:0]  RGB_OUT;
wire[3:0]  TIMESCALE;
wire[1:0]  TRIGGERSTYLE;
wire[11:0] XCOORD, YCOORD;



//----------------------//
// REGISTERS            //
//----------------------//
reg[3:0] cnt_charPxls;
reg[6:0] cnt_Hchar;
reg[10:0] cnt_Vchar;
wire     charRow1, charRow2, charRow3, charRow4, charRow5, charRow6, charRow7, charRow8;

wire[10:0] addr_charRamRead;
wire[7:0]  data_charRamRead;

reg[7:0]   mask_charMap;
wire[10:0] addr_charMap;
wire[7:0]  data_charMap;


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//



//------------------------------------------------------------------//
// Character Input / Storage                                        //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// A useful description could go here!                              //
//------------------------------------------------------------------//





//------------------------------------------------------------------//
// Character Decode                                                 //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// A useful description could go here!                              //
//------------------------------------------------------------------//

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// DECODE the Character RAM Address via HCNT and VCNT               //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //

always @ (posedge CLK_VGA or posedge MASTER_RST) begin
    if(MASTER_RST) begin
        cnt_charPxls <= 4'd5;
    end else if(HCNT >= 10'd1) begin //6
        if(cnt_charPxls == 4'd0)
            cnt_charPxls <= 4'd5;
        else
            cnt_charPxls <= cnt_charPxls-1;
    end else begin
        cnt_charPxls <= 4'd5;
    end
end

always @ (posedge CLK_VGA or posedge MASTER_RST) begin
    if(MASTER_RST) begin
        cnt_Hchar <= 7'd0;
    end else if(HCNT >= 10'd1 && cnt_charPxls == 4'd0) begin
        if(cnt_Hchar == 7'd105)
            cnt_Hchar <= 7'd0;
        else
            cnt_Hchar <= cnt_Hchar+1;
    end else if(HCNT < 10'd1) begin
        cnt_Hchar <= 7'd0;
    end else begin
        cnt_Hchar <= cnt_Hchar;
    end
end

assign charRow1 = ((VCNT <= 10'd512) && (VCNT >= 10'd506));
assign charRow2 = ((VCNT <= 10'd503) && (VCNT >= 10'd497));
assign charRow3 = ((VCNT <= 10'd494) && (VCNT >= 10'd488));
assign charRow4 = ((VCNT <= 10'd485) && (VCNT >= 10'd479));
assign charRow5 = ((VCNT <= 10'd476) && (VCNT >= 10'd470));
assign charRow6 = ((VCNT <= 10'd467) && (VCNT >= 10'd461));
assign charRow7 = ((VCNT <= 10'd458) && (VCNT >= 10'd452));
assign charRow8 = ((VCNT <= 10'd449) && (VCNT >= 10'd443));

always @ (charRow1 or charRow2 or charRow3 or charRow4 or charRow5 or charRow6 or charRow7 or charRow8) begin
         if(charRow1) cnt_Vchar = 11'd0;
    else if(charRow2) cnt_Vchar = 11'd106;
    else if(charRow3) cnt_Vchar = 11'd212;
    else if(charRow4) cnt_Vchar = 11'd318;
    else if(charRow5) cnt_Vchar = 11'd424;
    else if(charRow6) cnt_Vchar = 11'd530;
    else if(charRow7) cnt_Vchar = 11'd636;
    else if(charRow8) cnt_Vchar = 11'd742;
    else              cnt_Vchar = 11'd0;
end

assign addr_charRamRead = cnt_Vchar + cnt_Hchar;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// DECODE the Character Map via HCNT and VCNT and CHAR_DATA         //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
always @ (posedge CLK_VGA or posedge MASTER_RST) begin
    if(MASTER_RST) begin
        mask_charMap <= 8'd0;
    end else if(VCNT <= 10'd512) begin
        if(HCNT == 10'd0) begin
            if(mask_charMap == 8'd0)
                mask_charMap <= 8'b10000000;
            else
                mask_charMap <= mask_charMap >> 1;
        end else
            mask_charMap <= mask_charMap;
    end else begin
        mask_charMap <= 8'd0;
    end
end



assign addr_charMap = ((data_charRamRead * 8'd5) + cnt_charPxls);


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// DECODE the VGA_OUTPUT via the Character Map                      //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
reg[2:0] rgb_buf;

always @ (mask_charMap or data_charMap or charRow1 or charRow2 or charRow3 or charRow4 or charRow5 or charRow6 or charRow7 or charRow8 or cnt_charPxls or HCNT) begin
    if((charRow1 | charRow2 | charRow3 | charRow4 | charRow5 | charRow6 | charRow7 | charRow8) && ((mask_charMap & data_charMap) != 8'b0) && (cnt_charPxls != 4'd5) && (HCNT >= 10'd2) && (HCNT <= 10'd637))
        rgb_buf = P_yellow;
    else
        rgb_buf = P_black;
end
always @ (posedge CLK_VGA) begin
    RGB_OUT <= rgb_buf;
end


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// VALUE DISPLAY                                                    //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
reg[10:0] test_cntAddr;
reg[7:0]  data_time;

always @ (posedge MASTER_CLK or posedge MASTER_RST) begin
    if(MASTER_RST)                    test_cntAddr <= 11'd11;
    else if(test_cntAddr == 11'd15)   test_cntAddr <= 11'd117;
    else if(test_cntAddr == 11'd121)  test_cntAddr <= 11'd223;
    else if(test_cntAddr == 11'd228)  test_cntAddr <= 11'd327;
    else if(test_cntAddr == 11'd328)  test_cntAddr <= 11'd11;
    else                              test_cntAddr <= test_cntAddr + 1;
end

always @ (test_cntAddr or TIMESCALE or XCOORD or YCOORD or TRIGGERSTYLE) begin
             if(test_cntAddr == 11'd11)  begin data_time[7:4] = 4'h0; data_time[3:0] = XCOORD[11:8];
    end else if(test_cntAddr == 11'd12)  begin data_time[7:4] = 4'h0; data_time[3:0] = XCOORD[7:4];
    end else if(test_cntAddr == 11'd13)  begin data_time[7:4] = 4'h0; data_time[3:0] = XCOORD[3:0];
    
    end else if(test_cntAddr == 11'd117) begin data_time[7:4] = 4'h0; data_time[3:0] = YCOORD[11:8];
    end else if(test_cntAddr == 11'd118) begin data_time[7:4] = 4'h0; data_time[3:0] = YCOORD[7:4];
    end else if(test_cntAddr == 11'd119) begin data_time[7:4] = 4'h0; data_time[3:0] = YCOORD[3:0];
    
    end else if(test_cntAddr == 11'd228) begin data_time[7:4] = 4'h0; data_time[3:0] = TIMESCALE[3:0];
    
    end else if(test_cntAddr == 11'd327) begin if(TRIGGERSTYLE == 2'b00) data_time = 8'h2D; else data_time = 8'h2C;
    end else if(test_cntAddr == 11'd328) begin if(TRIGGERSTYLE == 2'b00) data_time = 8'h2E; else data_time = 8'h2F;
    
    end else                            data_time = 8'h24;
end







//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// Character Decode RAM INSTANTIATION                               //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
// A useful description could go here!                              //
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //
wire VCC, GND;
assign VCC = 1'b1;
assign GND = 1'b0;

RAMB16_S9_S9 #(
//                  6666555555555544444444443333333333222222222211111111110000000000
      .INIT_00(256'h920de29292928ee0101010fe449292927c668A9292660042FE02007C86BAC27C),
//                  CCCCCCCCBBBBBBBBBBAAAAAAAAAA999999999988888888887777777777666666
      .INIT_01(256'h828282c6Fe9292926c7e9090907e609292927d6d9292926d808698a0C07d9292),
//                  JJIIIIIIIIIIHHHHHHHHHHGGGGGGGGGGFFFFFFFFFFEEEEEEEEEEDDDDDDDDDDCC
      .INIT_02(256'h808282Fe8282Fe101010Fe7c829294deFe909090c0Fe929292c6FE8282827c7c),
//                  PPPPPPOOOOOOOOOONNNNNNNNNNMMMMMMMMMMLLLLLLLLLLKKKKKKKKKKJJJJJJJJ
      .INIT_03(256'h9090607C8282827CFe403804FeFe402040FeFe02020206Fe102844828482FC80),
//                  VVVVVVVVVVUUUUUUUUUUTTTTTTTTTTSSSSSSSSSSRRRRRRRRRRQQQQQQQQQQPPPP
      .INIT_04(256'hf8040204f8fC020202fCC080Fe80C0649292924c7e909894627C828A7C027C90),
//                  BLOC!!!!!!!!!!--space---ZZZZZZZZZZYYYYYYYYYYXXXXXXXXXWWWWWWWWWWW
      .INIT_05(256'hffff00f6f600000000000000868a92a2c2c0201e20c0c628102cC6Fe040804Fe),
//                  TrigUp-|//////////\\\\\\\\\\::::::::::|---DN---||---UP---|BLOCKB
      .INIT_06(256'h147c5040020C1060808060100C02006C6C0000181c1e1c183070f07030FFFFFF),
//                                                  |-TSelDN-||-TrigDN-||-TSelUP-||-
      .INIT_07(256'h00000000000000000000000000000000beae82eafa40507c1404faea82aebe04),
      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000)
) RAM_Character_Map (
    .DOA(),         .DOB(data_charMap),
    .DOPA(),        .DOPB(),
    .ADDRA(),       .ADDRB(addr_charMap),
    .CLKA(GND),     .CLKB(MASTER_CLK),
    .DIA(8'b0),     .DIB(8'b0),
    .DIPA(GND),     .DIPB(GND),
    .ENA(GND),      .ENB(VCC),
    .WEA(GND),      .WEB(GND),
    .SSRA(GND),     .SSRB(GND)
    );

//  A 0A  L 15  W     20  /      2B
//  B 0B  M 16  X     21  TrigUP 2C
//  C 0C  N 17  Y     22  TSelUP 2D
//  D 0D  O 18  Z     23  TrigDN 2E
//  E 0E  P 19  Space 24  TSelDN 2F
//  F 0F  Q 1A  !     25
//  G 10  R 1B  Block 26
//  H 11  S 1C  UpArr 27
//  I 12  T 1D  DnArr 28
//  J 13  U 1E  :     29
//  K 14  V 1F  \     2A



    
RAMB16_S9_S9 #(
//                                                  ##########   : X   R O S R U C  
      .INIT_00(256'h242424242424242424242424242424242424242424242921241B181C1B1E0C24),
//
      .INIT_01(256'h2424242424242424242424242424242424242424242424242424242424242424),
//
      .INIT_02(256'h2424242424242424242424242424242424242424242424242424242424242424),
//                              ##########   : Y                |- Line 1 end
      .INIT_03(256'h2424242424242424242424242922242424242424242426242424242424242424),
//
      .INIT_04(256'h2424242424242424242424242424242424242424242424242424242424242424),
    //.INIT_04(256'h201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a090807060504030201),
//
      .INIT_05(256'h2424242424242424242424242424242424242424242424242424242424242424),
    //.INIT_05(256'h2424242424242424242424242424242424242424242B2A292827262524232221),
//                  ##   : E S A B   E M I T|- Line 2 end
      .INIT_06(256'h2424290E1C0A0B240E16121D2624242424242424242424242424242424242424),
//                                                    VV^^   V I D / S U############
      .INIT_07(256'h24242424242424242424242424242424242827241F120D2A1C1E242424242424),
//
      .INIT_08(256'h2424242424242424242424242424242424242424242424242424242424242424),
//                   T  |- Line 3 end
      .INIT_09(256'h1D24262424242424242424242424242424242424242424242424242424242424),
//                                                            ########   R E G G I R
      .INIT_0A(256'h24242424242424242424242424242424242424242424242424241B0E1010121B),
//
      .INIT_0B(256'h2424242424242424242424242424242424242424242424242424242424242424),
//
      .INIT_0C(256'h2424242424242424242424242424242424242424242424242424242424242424),
//                                                                  |- Line 4 end
      .INIT_0D(256'h2424242424242424242424242424242424242424242424242624242424242424),
//
      .INIT_0E(256'h2424242424242424242424242424242424242424242424242424242424242424),
//
      .INIT_0F(256'h2424242424242424242424242424242424242424242424242424242424242424),
//                                              |- Line 5 end
      .INIT_10(256'h2424242424242424242424242424262424242424242424242424242424242424),
//
      .INIT_11(256'h2424242424242424242424242424242424242424242424242424242424242424),
//
      .INIT_12(256'h2424242424242424242424242424242424242424242424242424242424242424),
//                          |- Line 6 end
      .INIT_13(256'h2424242426242424242424242424242424242424242424242424242424242424),
//
      .INIT_14(256'h2424242424242424242424242424242424242424242424242424242424242424),
//
      .INIT_15(256'h2424242424242424242424242424242424242424242424242424242424242424),
//
      .INIT_16(256'h2424242424242424242424242424242424242424242424242424242424242424),
//                                                                      |- Line 7 end
      .INIT_17(256'h2424242424242424242424242424242424242424242424242424262424242424),
//
      .INIT_18(256'h2424242424242424242424242424242424242424242424242424242424242424),
//
      .INIT_19(256'h2424242424242424242424242424242424242424242424242424242424242424),
//                                                  |- Line 8 end
      .INIT_1A(256'h0000000000000000000000000000000026242424242424242424242424242424),
      .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000)
) RAM_Character_Test (
    .DOA(),                 .DOB(data_charRamRead),
    .DOPA(),                .DOPB(),
    .ADDRA(test_cntAddr),   .ADDRB(addr_charRamRead),
    .CLKA(MASTER_CLK),      .CLKB(MASTER_CLK),
    .DIA(data_time),        .DIB(8'b0),
    .DIPA(GND),             .DIPB(GND),
    .ENA(VCC),              .ENB(VCC),
    .WEA(VCC),              .WEB(GND),
    .SSRA(GND),             .SSRB(GND)
    );
    
    
    
/*
RAMB16_S9_S9 #(
                                                        // P U   E L A C S   E M I T
      .INIT_00(256'h24242424242424242424242424242424242424191E240E150A0C1C240E16121D),
      .INIT_01(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_02(256'h2424242424242424242424242424242424242424242424242424242424242424),
                                    // N D
      .INIT_03(256'h242424242424242424170D242424242424242424242424242424242424242424),
      .INIT_04(256'h201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a090807060504030201),
      .INIT_05(256'h2424242424242424242424242424242424242424242424242424242424232221),
      .INIT_06(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_07(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_08(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_09(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_0A(256'h2424242424242424242424250e17121b0e111d0a14241e1822240e1f18152412),
      .INIT_0B(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_0C(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_0D(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_0E(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_0F(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_10(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_11(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_12(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_13(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_14(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_15(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_16(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_17(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_18(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_19(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_1A(256'h2424242424242424242424242424242424242424242424242424242424242424),
      .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000)
) RAM_Character_Test (
    .DOA(),                 .DOB(data_charRamRead),
    .DOPA(),                .DOPB(),
    .ADDRA(test_cntAddr),   .ADDRB(addr_charRamRead),
    .CLKA(MASTER_CLK),      .CLKB(MASTER_CLK),
    .DIA(data_time),        .DIB(8'b0),
    .DIPA(GND),             .DIPB(GND),
    .ENA(VCC),              .ENB(VCC),
    .WEA(VCC),              .WEB(GND),
    .SSRA(GND),             .SSRB(GND)
    );
*/







endmodule

// -----------------------------------------------------------------------------
// Source file: VGA/d_VGAdriver.v
// -----------------------------------------------------------------------------
//==================================================================//
// File:    d_VGAdriver.v                                           //
// Version: 0.0.0.3                                                 //
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
// Copyright (C) Stephen Pickett                                    //
//   Jun 09, 2005                                                   //
//                                                                  //
// This program is free software; you can redistribute it and/or    //
// modify it under the terms of the GNU General Public License      //
// as published by the Free Software Foundation; either version 2   //
// of the License, or (at your option) any later version.           //
//                                                                  //
// This program is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of   //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    //
// GNU General Public License for more details.                     //
//                                                                  //
// If you have not received a copy of the GNU General Public License//
// along with this program; write to:                               //
//     Free Software Foundation, Inc.,                              //
//     51 Franklin Street, Fifth Floor,                             //
//     Boston, MA  02110-1301, USA.                                 //
//                                                                  //
//------------------------------------------------------------------//
// Revisions:                                                       //
// Ver 0.0.0.1     Apr 28, 2005   Under Development                 //
//     0.0.0.2     Jun 09, 2005   Cleaning                          //
//     0.0.0.3     Jun 10, 2005   Re-structuerd the VCNT and HCNT   //
//                                so they line up with the PXLs.    //
//                                                                  //
//==================================================================//

module Driver_VGA(
    CLK_50MHZ, MASTER_RST,
    CLK_VGA,
    VGA_RAM_DATA, VGA_RAM_ADDR,
    VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS,
    VGA_RAM_ACCESS_OK,
    H_SYNC, V_SYNC, VGA_OUTPUT,
    XCOORD, YCOORD,
    TRIGGER_LEVEL,
    VERT_OFFSET,
    HORZ_OFFSET,
    SHOW_LEVELS,
    HCNT, VCNT,
    RGB_CHAR
    );
    
//==================================================================//
// PARAMETER DEFINITIONS                                            //
//==================================================================//
parameter P_black   = 3'b000;
parameter P_yellow  = 3'b110;
parameter P_cyan    = 3'b011;
parameter P_green   = 3'b010;
parameter P_white   = 3'b111;

//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ;                // System wide clock
input MASTER_RST;               // System wide reset
input CLK_VGA;
output H_SYNC;                  // The H_SYNC timing signal to the VGA monitor
output V_SYNC;                  // The V_SYNC timing signal to the VGA monitor
output[2:0]  VGA_OUTPUT;        // The 3-bit VGA output
input[11:0]  XCOORD, YCOORD;
input[15:0]  VGA_RAM_DATA;
output[17:0] VGA_RAM_ADDR;
output VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
output VGA_RAM_ACCESS_OK;
input[9:0] TRIGGER_LEVEL, HORZ_OFFSET, VERT_OFFSET;
input SHOW_LEVELS;
output[9:0] HCNT, VCNT;
input[2:0] RGB_CHAR;




//----------------------//
// WIRES / NODES        //
//----------------------//
reg H_SYNC, V_SYNC;
reg [2:0]  VGA_OUTPUT;
wire CLK_50MHZ, MASTER_RST;
wire CLK_VGA;
wire[11:0] XCOORD, YCOORD;
wire[15:0] VGA_RAM_DATA;
reg[17:0]  VGA_RAM_ADDR;
reg VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
reg VGA_RAM_ACCESS_OK;
wire[9:0] TRIGGER_LEVEL, HORZ_OFFSET, VERT_OFFSET;
wire SHOW_LEVELS;
wire[9:0] HCNT, VCNT;
wire[2:0] RGB_CHAR;


//----------------------//
// REGISTERS            //
//----------------------//
wire CLK_25MHZ = CLK_VGA;
reg [9:0] hcnt;     // Counter - generates the H_SYNC signal
reg [9:0] vcnt;     // Counter - counts the H_SYNC pulses to generate V_SYNC signal
reg[2:0]  vga_out;

//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
assign HCNT = hcnt;
assign VCNT = vcnt;


//------------------------------------------------------------------//
// SYNC TIMING COUNTERS                                             //
//------------------------------------------------------------------//
always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if (MASTER_RST == 1'b1) begin
        hcnt <= 10'd0;
        vcnt <= 10'd430;
    end else if (hcnt == 10'd0799) begin
        hcnt <= 10'd0;
        if (vcnt == 10'd0)
            vcnt <= 10'd520;
        else
            vcnt <= vcnt - 1'b1;
    end else
        hcnt <= hcnt + 1'b1;
end


//------------------------------------------------------------------//
// HORIZONTAL SYNC TIMING                                           //
//------------------------------------------------------------------//
always @ (hcnt)
    if (hcnt >= 10'd656 && hcnt <= 10'd751)
        H_SYNC = 1'b0;
    else
        H_SYNC = 1'b1;


//------------------------------------------------------------------//
// VERTICAL SYNC TIMING                                             //
//------------------------------------------------------------------//
always @ (vcnt)
    if (vcnt == 10'd430 || vcnt == 10'd429)
        V_SYNC = 1'b0;
    else
        V_SYNC = 1'b1;


//------------------------------------------------------------------//
// VGA DATA SIGNAL TIMING                                           //
//------------------------------------------------------------------//
always @ (hcnt or vcnt or XCOORD or YCOORD or MASTER_RST or vga_out or SHOW_LEVELS or TRIGGER_LEVEL or VERT_OFFSET or HORZ_OFFSET or RGB_CHAR) begin
    if(MASTER_RST == 1'b1) begin
        VGA_OUTPUT = P_black;
    //------------------------------------------------------------------------------//
    // UNSEEN BORDERS                                                               //
    end else if( (vcnt >= 10'd400) && (vcnt <= 10'd440) ) begin
        VGA_OUTPUT = P_black;
    end else if( (hcnt >= 10'd640) ) begin
        VGA_OUTPUT = P_black;
    //------------------------------------------------------------------------------//
    // MOUSE CURSORS                                                                //
    end else if(vcnt == YCOORD) begin
        VGA_OUTPUT = P_green;
    end else if(hcnt == XCOORD) begin
        VGA_OUTPUT = P_green;
    //------------------------------------------------------------------------------//
    // TRIGGER SPRITE         (shows as ------T------ )                             //
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL) && hcnt != 10'd556 && hcnt != 10'd558) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL+1'b1) && hcnt >= 10'd556 && hcnt <= 10'd558) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (TRIGGER_LEVEL-1'b1) && hcnt == 10'd557) begin
        VGA_OUTPUT = P_yellow;
    //------------------------------------------------------------------------------//
    // VERTICAL OFFSET SPRITE         (shows as ------V------ )                     //
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (VERT_OFFSET) && hcnt != 10'd560) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (VERT_OFFSET+1'b1) && (hcnt == 10'd559 || hcnt == 10'd561)) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && vcnt == (VERT_OFFSET-1'b1) && hcnt == 10'd560) begin
        VGA_OUTPUT = P_yellow;
   //------------------------------------------------------------------------------//
    // HORIZONTAL1 OFFSET SPRITE         (shows as ------H------ )                 //
    end else if(SHOW_LEVELS == 1'b1 && hcnt == (HORZ_OFFSET) && vcnt != 10'd102 && vcnt != 10'd100) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && hcnt == (HORZ_OFFSET+1'b1) && (vcnt == 10'd100 || vcnt == 10'd101 || vcnt == 10'd102)) begin
        VGA_OUTPUT = P_yellow;
    end else if(SHOW_LEVELS == 1'b1 && hcnt == (HORZ_OFFSET-1'b1) && (vcnt == 10'd100 || vcnt == 10'd101 || vcnt == 10'd102)) begin
        VGA_OUTPUT = P_yellow;
    //------------------------------------------------------------------------------//
    // TOP, BOTTOM, LEFT AND RIGHT GRID LINES                                       //
    end else if(vcnt == 10'd0 || vcnt == 10'd399 || vcnt == 10'd441) begin
        VGA_OUTPUT = P_cyan;
    end else if(hcnt == 10'd0 || hcnt == 10'd639) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // CHARACTER DISPLAY
    end else if(vcnt <= 10'd520 && vcnt >= 10'd441) begin
        VGA_OUTPUT = RGB_CHAR;
    //------------------------------------------------------------------------------//
    // THE WAVEFORM                                                                 //
    end else if(vga_out != 0) begin
        VGA_OUTPUT = vga_out;
    //------------------------------------------------------------------------------//
    // MIDDLE GRID LINES (dashed at 8pxls)                                          //
    end else if(vcnt == 10'd199 && hcnt[3] == 1'b1) begin
        VGA_OUTPUT = P_cyan;
    end else if((hcnt == 10'd319) && (vcnt <= 10'd399) && (vcnt[3] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHER HORIZONTAL LINES (dashed at 4pxls)                                     //
    end else if((vcnt == 10'd39 || vcnt == 10'd79 || vcnt == 10'd119 || vcnt == 10'd159 || vcnt == 10'd239 || vcnt == 10'd279 || vcnt == 10'd319 || vcnt == 10'd359) && (hcnt[2] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHER VERTICAL LINES (dashed at 4pxls)                                       //
    end else if(((hcnt[5:0] == 6'b111111) && (vcnt <= 10'd399)) && (vcnt[2] == 1'b1)) begin
        VGA_OUTPUT = P_cyan;
    //------------------------------------------------------------------------------//
    // OTHERWISE...                                                                 //
    end else
        VGA_OUTPUT = P_black;
end

//------------------------------------------------------------------//
// RAM DATA READING                                                 //
//------------------------------------------------------------------//
// on reset, ram_addr = 24 and add 25 on each pxl
//     row 0: ram_addr = 24 and 25 for each pxl
//     row 1: ram_addr = 24 and 25 for each pxl
//       ...
//     row 15: ram_addr = 24 and 25 for each pxl
//     row 16: ram_addr = 23 and 25 for each pxl *
//     row 17: ram_addr = 23 and 25 for each pxl *
//       ...
reg[4:0]  ram_vcnt;
reg[15:0] ram_vshift;

always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ram_vshift <= 16'h8000;
    end else if(vcnt > 10'd399) begin
        ram_vshift <= 16'h8000;
    end else if(/*(vcnt <= 10'd399) && */(hcnt == 10'd640)) begin
        if(ram_vshift == 16'h0001)
            ram_vshift <= 16'h8000;
        else
            ram_vshift <= (ram_vshift >> 1);
    end else
        ram_vshift <= ram_vshift;
end

always @ (posedge CLK_25MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ram_vcnt <= 5'd24;//5'b0
    end else if(vcnt > 10'd399) begin
        ram_vcnt <= 5'd24;
    end else if(/*(vcnt >= 10'd30) &&*/ (hcnt == 10'd640) && (ram_vshift == 16'h0001)) begin
        if(ram_vcnt == 5'd0)
            ram_vcnt <= 5'd24;
        else
            ram_vcnt <= ram_vcnt - 1'b1;
    end else begin
        ram_vcnt <= ram_vcnt;
    end
end



always @ (hcnt or ram_vcnt) begin
    VGA_RAM_ADDR = ram_vcnt + (hcnt * 7'd25);
//    VGA_RAM_ADDR = vcnt * hcnt;
end


always @ (VGA_RAM_DATA or ram_vshift) begin
    if((VGA_RAM_DATA & ram_vshift) != 16'b0)
        vga_out = P_white;
    else
        vga_out = 3'b0;
end


always begin
    VGA_RAM_CS = 1'b0;  // #CS
    VGA_RAM_OE = 1'b0;  // #OE
    VGA_RAM_WE = 1'b1;  // #WE
end


//------------------------------------------------------------------//
// ALL CLEAR?                                                       //
//------------------------------------------------------------------//
always @ (vcnt) begin
    if(vcnt > 10'd399)
        VGA_RAM_ACCESS_OK = 1'b1;
    else
        VGA_RAM_ACCESS_OK = 1'b0;
end


endmodule

// -----------------------------------------------------------------------------
// Source file: VGA/d_VgaRamBuffer.v
// -----------------------------------------------------------------------------
//==================================================================
// File:    d_VgaRamBuffer.v
// Version: 0.01
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Copyright Stephen Pickett
//   April 28, 2005
//------------------------------------------------------------------
// Revisions:
// Ver 0.01     Apr 28, 2005    Initial Release
//
//==================================================================
module VGADataBuffer(
    CLK_50MHZ, MASTER_RST,
    VGA_RAM_DATA, VGA_RAM_ADDR, VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS,
    VGA_RAM_ACCESS_OK,
    ADC_RAM_DATA, ADC_RAM_ADDR, ADC_RAM_CLK,
    TIME_BASE
    );
//==================================================================//
// VARIABLE DEFINITIONS                                             //
//==================================================================//
//----------------------//
// INPUTS / OUTPUTS     //
//----------------------//
input CLK_50MHZ;                // System wide clock
input MASTER_RST;               // System wide reset

output[15:0] VGA_RAM_DATA;
output[17:0] VGA_RAM_ADDR;
output       VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
input        VGA_RAM_ACCESS_OK;

input[8:0]   ADC_RAM_DATA;
output[10:0] ADC_RAM_ADDR;
output       ADC_RAM_CLK;

input[5:0] TIME_BASE;

//----------------------//
// WIRES / NODES        //
//----------------------//
wire CLK_50MHZ;                // System wide clock
wire MASTER_RST;               // System wide reset
wire[15:0] VGA_RAM_DATA;
reg[17:0] VGA_RAM_ADDR;
reg VGA_RAM_OE, VGA_RAM_WE, VGA_RAM_CS;
wire  VGA_RAM_ACCESS_OK;
wire[8:0] ADC_RAM_DATA;
reg[10:0] ADC_RAM_ADDR;
wire ADC_RAM_CLK;
wire[5:0] TIME_BASE;


//----------------------//
// REGISTERS            //
//----------------------//
reg[4:0]  vcnt;
reg[9:0]  hcnt;
reg[15:0] data_to_ram;
reg[8:0]  adc_data_scale;
reg[10:0] TRIG_ADDR_buffered;


//==================================================================//
// FUNCTIONAL DEFINITIONS                                           //
//==================================================================//
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        vcnt <= 5'd0;
    end else if(VGA_RAM_ACCESS_OK && hcnt != 10'd640) begin
        if(vcnt == 5'd24)
            vcnt <= 5'b0;
        else
            vcnt <= vcnt + 1'b1;
    end else begin
        vcnt <= 5'd0;
    end
end

always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        hcnt <= 10'd0;
    end else if(VGA_RAM_ACCESS_OK) begin
        if(hcnt == 10'd640)
            hcnt <= hcnt;
        else if(vcnt == 5'd24)
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= hcnt;
    end else begin
        hcnt <= 10'b0;
    end
end


always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        ADC_RAM_ADDR <= 11'b0;
    end else if(VGA_RAM_ACCESS_OK) begin
        if((hcnt == 10'd640) || !(vcnt == 5'd24))
            ADC_RAM_ADDR <= ADC_RAM_ADDR;
        else
            ADC_RAM_ADDR <= ADC_RAM_ADDR + 1'b1;
    end else begin
        ADC_RAM_ADDR <= 11'd1727;
    end
end

reg[7:0] TESTING_CNT;
always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        TESTING_CNT <= 8'd0;
    end else if(VGA_RAM_ACCESS_OK) begin
        if(vcnt == 5'd24)
            TESTING_CNT <= TESTING_CNT+1;
        else
            TESTING_CNT <= TESTING_CNT;
    end else begin
        TESTING_CNT <= 8'b0;
    end
end


always @ (ADC_RAM_DATA) begin
//      adc_data_scale = TESTING_CNT + (TESTING_CNT>>1) + (TESTING_CNT>>4) + (TESTING_CNT>>6);
//      adc_data_scale = ADC_RAM_DATA + (ADC_RAM_DATA>>1) + (ADC_RAM_DATA>>4) + (ADC_RAM_DATA>>6);
      adc_data_scale = ADC_RAM_DATA;
end




always @ (posedge CLK_50MHZ or posedge MASTER_RST) begin
    if(MASTER_RST == 1'b1) begin
        VGA_RAM_ADDR <= 18'b0;
    end else if(VGA_RAM_ACCESS_OK) begin
        if(hcnt == 10'd640)
            VGA_RAM_ADDR <= VGA_RAM_ADDR;
        else
            VGA_RAM_ADDR <= VGA_RAM_ADDR + 1'b1;
    end else begin
        VGA_RAM_ADDR <= 18'b0;
    end
end
/*
always @ (vcnt or VGA_RAM_ACCESS_OK or adc_data_scale) begin
    if(VGA_RAM_ACCESS_OK) begin
        if(vcnt == adc_data_scale[8:4]) begin
            data_to_ram = (adc_data_scale[3:0] == 4'd0)  & 16'h0001 |
                          (adc_data_scale[3:0] == 4'd1)  & 16'h0002 |
                          (adc_data_scale[3:0] == 4'd2)  & 16'h0004 |
                          (adc_data_scale[3:0] == 4'd3)  & 16'h0008 |
                          (adc_data_scale[3:0] == 4'd4)  & 16'h0010 |
                          (adc_data_scale[3:0] == 4'd5)  & 16'h0020 |
                          (adc_data_scale[3:0] == 4'd6)  & 16'h0040 |
                          (adc_data_scale[3:0] == 4'd7)  & 16'h0080 |
                          (adc_data_scale[3:0] == 4'd8)  & 16'h0100 |
                          (adc_data_scale[3:0] == 4'd9)  & 16'h0200 |
                          (adc_data_scale[3:0] == 4'd10) & 16'h0400 |
                          (adc_data_scale[3:0] == 4'd11) & 16'h0800 |
                          (adc_data_scale[3:0] == 4'd12) & 16'h1000 |
                          (adc_data_scale[3:0] == 4'd13) & 16'h2000 |
                          (adc_data_scale[3:0] == 4'd14) & 16'h4000 |
                          (adc_data_scale[3:0] == 4'd15) & 16'h8000;
        end else begin
            data_to_ram = 16'b0;
        end
    end else begin
        data_to_ram = 16'bZ;
    end
end
*/

always @ (vcnt or VGA_RAM_ACCESS_OK or adc_data_scale) begin
    if(VGA_RAM_ACCESS_OK) begin
        if(vcnt == adc_data_scale[8:4]) begin
            if(adc_data_scale[3:0] == 4'd0)
                data_to_ram = 16'h0001;
            else if(adc_data_scale[3:0] == 4'd1)
                data_to_ram = 16'h0002;
            else if(adc_data_scale[3:0] == 4'd2)
                data_to_ram = 16'h0004;
            else if(adc_data_scale[3:0] == 4'd3)
                data_to_ram = 16'h0008;
            else if(adc_data_scale[3:0] == 4'd4)
                data_to_ram = 16'h0010;
            else if(adc_data_scale[3:0] == 4'd5)
                data_to_ram = 16'h0020;
            else if(adc_data_scale[3:0] == 4'd6)
                data_to_ram = 16'h0040;
            else if(adc_data_scale[3:0] == 4'd7)
                data_to_ram = 16'h0080;
            else if(adc_data_scale[3:0] == 4'd8)
                data_to_ram = 16'h0100;
            else if(adc_data_scale[3:0] == 4'd9)
                data_to_ram = 16'h0200;
            else if(adc_data_scale[3:0] == 4'd10)
                data_to_ram = 16'h0400;
            else if(adc_data_scale[3:0] == 4'd11)
                data_to_ram = 16'h0800;
            else if(adc_data_scale[3:0] == 4'd12)
                data_to_ram = 16'h1000;
            else if(adc_data_scale[3:0] == 4'd13)
                data_to_ram = 16'h2000;
            else if(adc_data_scale[3:0] == 4'd14)
                data_to_ram = 16'h4000;
            else if(adc_data_scale[3:0] == 4'd15)
                data_to_ram = 16'h8000;
            else
                data_to_ram = 16'hFFFF;
        end else //end bigIF
            data_to_ram = 16'b0;
    end else begin
        data_to_ram = 16'bZ;
    end
end

/*
always @ (vcnt or VGA_RAM_ACCESS_OK or ADC_RAM_DATA) begin
    if(VGA_RAM_ACCESS_OK) begin
        if((vcnt[3:0] == ADC_RAM_DATA[7:4]) && vcnt[4] != 1'b1) begin
            if(ADC_RAM_DATA[3:0] == 4'd0)
                data_to_ram = 16'h0001;
            else if(ADC_RAM_DATA[3:0] == 4'd1)
                data_to_ram = 16'h0002;
            else if(ADC_RAM_DATA[3:0] == 4'd2)
                data_to_ram = 16'h0004;
            else if(ADC_RAM_DATA[3:0] == 4'd3)
                data_to_ram = 16'h0008;
            else if(ADC_RAM_DATA[3:0] == 4'd4)
                data_to_ram = 16'h0010;
            else if(ADC_RAM_DATA[3:0] == 4'd5)
                data_to_ram = 16'h0020;
            else if(ADC_RAM_DATA[3:0] == 4'd6)
                data_to_ram = 16'h0040;
            else if(ADC_RAM_DATA[3:0] == 4'd7)
                data_to_ram = 16'h0080;
            else if(ADC_RAM_DATA[3:0] == 4'd8)
                data_to_ram = 16'h0100;
            else if(ADC_RAM_DATA[3:0] == 4'd9)
                data_to_ram = 16'h0200;
            else if(ADC_RAM_DATA[3:0] == 4'd10)
                data_to_ram = 16'h0400;
            else if(ADC_RAM_DATA[3:0] == 4'd11)
                data_to_ram = 16'h0800;
            else if(ADC_RAM_DATA[3:0] == 4'd12)
                data_to_ram = 16'h1000;
            else if(ADC_RAM_DATA[3:0] == 4'd13)
                data_to_ram = 16'h2000;
            else if(ADC_RAM_DATA[3:0] == 4'd14)
                data_to_ram = 16'h4000;
            else if(ADC_RAM_DATA[3:0] == 4'd15)
                data_to_ram = 16'h8000;
            else
                data_to_ram = 16'hFFFF;
        end else //end bigIF
            data_to_ram = 16'b0;
    end else begin
        data_to_ram = 16'bZ;
    end
end
*/
/*
always @ (vcnt) begin
    if(vcnt == 5'd00 && hcnt <= 10'd319)
        data_to_ram = 16'h000F;
    else
        data_to_ram = 16'b0;
end
*/

assign ADC_RAM_CLK = CLK_50MHZ;

assign VGA_RAM_DATA = data_to_ram;

always begin
    VGA_RAM_OE = 1'b1;
    VGA_RAM_WE = 1'b0;
    VGA_RAM_CS = 1'b0;
end












endmodule
