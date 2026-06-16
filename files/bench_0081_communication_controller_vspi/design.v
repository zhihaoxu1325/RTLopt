// Curated RTL benchmark case.
// case_id: bench_0081_communication_controller_vspi
// source_project: communication_controller_vspi
// top_module: spiwrap


// -----------------------------------------------------------------------------
// Source file: src/spi_base/spiwrap.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:49:15 11/02/2011 
// Design Name: 
// Module Name:    spiwrap 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spiwrap(
    input Reset,
    input SysClk,
    input spi_ss,
    input spi_mosi,
    input spi_clk,
    output spi_miso,
    output [7:0] leds
    );

wire [31:0] douta_dummy;

wire [11:0] spi_addr;
wire [ 7:0] spi_data;
wire [31:0] rcMem_douta;

reg        initMem;
reg [ 9:0] initMemAddr;
reg [31:0] initMemData;

always @(posedge SysClk) begin
  if (Reset) begin
    initMem <= 1'b1;
    initMemAddr <= 10'h000;
    initMemData <= 32'h5A6C_C6A5;
  end else begin
    if (initMem == 1'b1) begin
      // Turn off init mem mode if formatted memory 
      if (initMemAddr == 10'h3FF) begin
        initMem <= 1'b0;
      end
    
      // Increment init mem addr/data
      initMemAddr <= initMemAddr + 10'h001;
    end
  end
end

buffermem spiMemTx (
  .clka(SysClk), // input clkb
  .ena(1'b1), // input enb
  .wea(1'b0), // input [0 : 0] web
  .addra(spi_addr), // input [11 : 0] addrb
  .dina(8'h00), // input [7 : 0] dinb
  .douta(spi_data), // output [7 : 0] doutb
  .clkb(SysClk), // input clka 
  .enb(1'b1), // input ena
  .web(initMem), // input [0 : 0] wea
  .addrb(initMemAddr), // input [9 : 0] addra
  .dinb(initMemData), // input [31 : 0] dina
  .doutb(douta_dummy) // output [31 : 0] douta
);

wire        spi_rcMem_we;
wire [11:0] spi_rcMem_addr; 
wire [ 7:0] spi_rcMem_data;
wire [ 7:0] debug_out;
wire [ 7:0] spi_rcMem_doutb_dummy;
buffermem spiMemRc (
  .clka(SysClk),
  .ena(1'b1),
  .wea(spi_rcMem_we),
  .addra(spi_rcMem_addr),
  .dina(spi_rcMem_data),
  .douta(spi_rcMem_doutb_dummy),
  .clkb(SysClk),
  .enb(1'b1),
  .web(1'b0),
  .addrb(10'h001),
  .doutb(rcMem_douta)
);

spiifc mySpiIfc (
  .Reset(Reset),
  .SysClk(SysClk),
  .SPI_CLK(spi_clk),
  .SPI_MISO(spi_miso),
  .SPI_MOSI(spi_mosi),
  .SPI_SS(spi_ss),
  .txMemAddr(spi_addr),
  .txMemData(spi_data),
  .rcMemAddr(spi_rcMem_addr),
  .rcMemData(spi_rcMem_data),
  .rcMemWE(spi_rcMem_we),
  .debug_out(debug_out)
);

assign leds =  rcMem_douta[7:0] /* debug_out */;

endmodule

// -----------------------------------------------------------------------------
// Source file: projnav/xps/pcores/spiifc_v1_00_a/devl/projnav/ipcore_dir/buffermem.v
// -----------------------------------------------------------------------------
/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used solely      *
*     for design, simulation, implementation and creation of design files      *
*     limited to Xilinx devices or technologies. Use with non-Xilinx           *
*     devices or technologies is expressly prohibited and immediately          *
*     terminates your license.                                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY     *
*     FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY     *
*     PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE              *
*     IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS       *
*     MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY       *
*     CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY        *
*     RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY        *
*     DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE    *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A    *
*     PARTICULAR PURPOSE.                                                      *
*                                                                              *
*     Xilinx products are not intended for use in life support appliances,     *
*     devices, or systems.  Use in such applications are expressly             *
*     prohibited.                                                              *
*                                                                              *
*     (c) Copyright 1995-2012 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// You must compile the wrapper file buffermem.v when simulating
// the core, buffermem. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

// The synthesis directives "translate_off/translate_on" specified below are
// supported by Xilinx, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

`timescale 1ns/1ps

module buffermem(
  clka,
  ena,
  wea,
  addra,
  dina,
  douta,
  clkb,
  enb,
  web,
  addrb,
  dinb,
  doutb
);

input clka;
input ena;
input [0 : 0] wea;
input [11 : 0] addra;
input [7 : 0] dina;
output [7 : 0] douta;
input clkb;
input enb;
input [0 : 0] web;
input [9 : 0] addrb;
input [31 : 0] dinb;
output [31 : 0] doutb;

// synthesis translate_off

  BLK_MEM_GEN_V6_2 #(
    .C_ADDRA_WIDTH(12),
    .C_ADDRB_WIDTH(10),
    .C_ALGORITHM(1),
    .C_AXI_ID_WIDTH(4),
    .C_AXI_SLAVE_TYPE(0),
    .C_AXI_TYPE(1),
    .C_BYTE_SIZE(9),
    .C_COMMON_CLK(1),
    .C_DEFAULT_DATA("0"),
    .C_DISABLE_WARN_BHV_COLL(0),
    .C_DISABLE_WARN_BHV_RANGE(0),
    .C_FAMILY("spartan6"),
    .C_HAS_AXI_ID(0),
    .C_HAS_ENA(1),
    .C_HAS_ENB(1),
    .C_HAS_INJECTERR(0),
    .C_HAS_MEM_OUTPUT_REGS_A(0),
    .C_HAS_MEM_OUTPUT_REGS_B(0),
    .C_HAS_MUX_OUTPUT_REGS_A(0),
    .C_HAS_MUX_OUTPUT_REGS_B(0),
    .C_HAS_REGCEA(0),
    .C_HAS_REGCEB(0),
    .C_HAS_RSTA(0),
    .C_HAS_RSTB(0),
    .C_HAS_SOFTECC_INPUT_REGS_A(0),
    .C_HAS_SOFTECC_OUTPUT_REGS_B(0),
    .C_INIT_FILE_NAME("no_coe_file_loaded"),
    .C_INITA_VAL("0"),
    .C_INITB_VAL("0"),
    .C_INTERFACE_TYPE(0),
    .C_LOAD_INIT_FILE(0),
    .C_MEM_TYPE(2),
    .C_MUX_PIPELINE_STAGES(0),
    .C_PRIM_TYPE(1),
    .C_READ_DEPTH_A(4096),
    .C_READ_DEPTH_B(1024),
    .C_READ_WIDTH_A(8),
    .C_READ_WIDTH_B(32),
    .C_RST_PRIORITY_A("CE"),
    .C_RST_PRIORITY_B("CE"),
    .C_RST_TYPE("SYNC"),
    .C_RSTRAM_A(0),
    .C_RSTRAM_B(0),
    .C_SIM_COLLISION_CHECK("ALL"),
    .C_USE_BYTE_WEA(0),
    .C_USE_BYTE_WEB(0),
    .C_USE_DEFAULT_DATA(0),
    .C_USE_ECC(0),
    .C_USE_SOFTECC(0),
    .C_WEA_WIDTH(1),
    .C_WEB_WIDTH(1),
    .C_WRITE_DEPTH_A(4096),
    .C_WRITE_DEPTH_B(1024),
    .C_WRITE_MODE_A("WRITE_FIRST"),
    .C_WRITE_MODE_B("WRITE_FIRST"),
    .C_WRITE_WIDTH_A(8),
    .C_WRITE_WIDTH_B(32),
    .C_XDEVICEFAMILY("spartan6")
  )
  inst (
    .CLKA(clka),
    .ENA(ena),
    .WEA(wea),
    .ADDRA(addra),
    .DINA(dina),
    .DOUTA(douta),
    .CLKB(clkb),
    .ENB(enb),
    .WEB(web),
    .ADDRB(addrb),
    .DINB(dinb),
    .DOUTB(doutb),
    .RSTA(),
    .REGCEA(),
    .RSTB(),
    .REGCEB(),
    .INJECTSBITERR(),
    .INJECTDBITERR(),
    .SBITERR(),
    .DBITERR(),
    .RDADDRECC(),
    .S_ACLK(),
    .S_ARESETN(),
    .S_AXI_AWID(),
    .S_AXI_AWADDR(),
    .S_AXI_AWLEN(),
    .S_AXI_AWSIZE(),
    .S_AXI_AWBURST(),
    .S_AXI_AWVALID(),
    .S_AXI_AWREADY(),
    .S_AXI_WDATA(),
    .S_AXI_WSTRB(),
    .S_AXI_WLAST(),
    .S_AXI_WVALID(),
    .S_AXI_WREADY(),
    .S_AXI_BID(),
    .S_AXI_BRESP(),
    .S_AXI_BVALID(),
    .S_AXI_BREADY(),
    .S_AXI_ARID(),
    .S_AXI_ARADDR(),
    .S_AXI_ARLEN(),
    .S_AXI_ARSIZE(),
    .S_AXI_ARBURST(),
    .S_AXI_ARVALID(),
    .S_AXI_ARREADY(),
    .S_AXI_RID(),
    .S_AXI_RDATA(),
    .S_AXI_RRESP(),
    .S_AXI_RLAST(),
    .S_AXI_RVALID(),
    .S_AXI_RREADY(),
    .S_AXI_INJECTSBITERR(),
    .S_AXI_INJECTDBITERR(),
    .S_AXI_SBITERR(),
    .S_AXI_DBITERR(),
    .S_AXI_RDADDRECC()
  );

// synthesis translate_on

endmodule

// -----------------------------------------------------------------------------
// Source file: projnav/xps/pcores/spiifc_v1_00_a/hdl/verilog/buffermem.v
// -----------------------------------------------------------------------------
/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used solely      *
*     for design, simulation, implementation and creation of design files      *
*     limited to Xilinx devices or technologies. Use with non-Xilinx           *
*     devices or technologies is expressly prohibited and immediately          *
*     terminates your license.                                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY     *
*     FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY     *
*     PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE              *
*     IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS       *
*     MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY       *
*     CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY        *
*     RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY        *
*     DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE    *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A    *
*     PARTICULAR PURPOSE.                                                      *
*                                                                              *
*     Xilinx products are not intended for use in life support appliances,     *
*     devices, or systems.  Use in such applications are expressly             *
*     prohibited.                                                              *
*                                                                              *
*     (c) Copyright 1995-2012 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// You must compile the wrapper file buffermem.v when simulating
// the core, buffermem. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

// The synthesis directives "translate_off/translate_on" specified below are
// supported by Xilinx, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

`timescale 1ns/1ps

module buffermem(
  clka,
  ena,
  wea,
  addra,
  dina,
  douta,
  clkb,
  enb,
  web,
  addrb,
  dinb,
  doutb
);

input clka;
input ena;
input [0 : 0] wea;
input [11 : 0] addra;
input [7 : 0] dina;
output [7 : 0] douta;
input clkb;
input enb;
input [0 : 0] web;
input [9 : 0] addrb;
input [31 : 0] dinb;
output [31 : 0] doutb;

// synthesis translate_off

  BLK_MEM_GEN_V6_2 #(
    .C_ADDRA_WIDTH(12),
    .C_ADDRB_WIDTH(10),
    .C_ALGORITHM(1),
    .C_AXI_ID_WIDTH(4),
    .C_AXI_SLAVE_TYPE(0),
    .C_AXI_TYPE(1),
    .C_BYTE_SIZE(9),
    .C_COMMON_CLK(1),
    .C_DEFAULT_DATA("0"),
    .C_DISABLE_WARN_BHV_COLL(0),
    .C_DISABLE_WARN_BHV_RANGE(0),
    .C_FAMILY("spartan6"),
    .C_HAS_AXI_ID(0),
    .C_HAS_ENA(1),
    .C_HAS_ENB(1),
    .C_HAS_INJECTERR(0),
    .C_HAS_MEM_OUTPUT_REGS_A(0),
    .C_HAS_MEM_OUTPUT_REGS_B(0),
    .C_HAS_MUX_OUTPUT_REGS_A(0),
    .C_HAS_MUX_OUTPUT_REGS_B(0),
    .C_HAS_REGCEA(0),
    .C_HAS_REGCEB(0),
    .C_HAS_RSTA(0),
    .C_HAS_RSTB(0),
    .C_HAS_SOFTECC_INPUT_REGS_A(0),
    .C_HAS_SOFTECC_OUTPUT_REGS_B(0),
    .C_INIT_FILE_NAME("no_coe_file_loaded"),
    .C_INITA_VAL("0"),
    .C_INITB_VAL("0"),
    .C_INTERFACE_TYPE(0),
    .C_LOAD_INIT_FILE(0),
    .C_MEM_TYPE(2),
    .C_MUX_PIPELINE_STAGES(0),
    .C_PRIM_TYPE(1),
    .C_READ_DEPTH_A(4096),
    .C_READ_DEPTH_B(1024),
    .C_READ_WIDTH_A(8),
    .C_READ_WIDTH_B(32),
    .C_RST_PRIORITY_A("CE"),
    .C_RST_PRIORITY_B("CE"),
    .C_RST_TYPE("SYNC"),
    .C_RSTRAM_A(0),
    .C_RSTRAM_B(0),
    .C_SIM_COLLISION_CHECK("ALL"),
    .C_USE_BYTE_WEA(0),
    .C_USE_BYTE_WEB(0),
    .C_USE_DEFAULT_DATA(0),
    .C_USE_ECC(0),
    .C_USE_SOFTECC(0),
    .C_WEA_WIDTH(1),
    .C_WEB_WIDTH(1),
    .C_WRITE_DEPTH_A(4096),
    .C_WRITE_DEPTH_B(1024),
    .C_WRITE_MODE_A("WRITE_FIRST"),
    .C_WRITE_MODE_B("WRITE_FIRST"),
    .C_WRITE_WIDTH_A(8),
    .C_WRITE_WIDTH_B(32),
    .C_XDEVICEFAMILY("spartan6")
  )
  inst (
    .CLKA(clka),
    .ENA(ena),
    .WEA(wea),
    .ADDRA(addra),
    .DINA(dina),
    .DOUTA(douta),
    .CLKB(clkb),
    .ENB(enb),
    .WEB(web),
    .ADDRB(addrb),
    .DINB(dinb),
    .DOUTB(doutb),
    .RSTA(),
    .REGCEA(),
    .RSTB(),
    .REGCEB(),
    .INJECTSBITERR(),
    .INJECTDBITERR(),
    .SBITERR(),
    .DBITERR(),
    .RDADDRECC(),
    .S_ACLK(),
    .S_ARESETN(),
    .S_AXI_AWID(),
    .S_AXI_AWADDR(),
    .S_AXI_AWLEN(),
    .S_AXI_AWSIZE(),
    .S_AXI_AWBURST(),
    .S_AXI_AWVALID(),
    .S_AXI_AWREADY(),
    .S_AXI_WDATA(),
    .S_AXI_WSTRB(),
    .S_AXI_WLAST(),
    .S_AXI_WVALID(),
    .S_AXI_WREADY(),
    .S_AXI_BID(),
    .S_AXI_BRESP(),
    .S_AXI_BVALID(),
    .S_AXI_BREADY(),
    .S_AXI_ARID(),
    .S_AXI_ARADDR(),
    .S_AXI_ARLEN(),
    .S_AXI_ARSIZE(),
    .S_AXI_ARBURST(),
    .S_AXI_ARVALID(),
    .S_AXI_ARREADY(),
    .S_AXI_RID(),
    .S_AXI_RDATA(),
    .S_AXI_RRESP(),
    .S_AXI_RLAST(),
    .S_AXI_RVALID(),
    .S_AXI_RREADY(),
    .S_AXI_INJECTSBITERR(),
    .S_AXI_INJECTDBITERR(),
    .S_AXI_SBITERR(),
    .S_AXI_DBITERR(),
    .S_AXI_RDADDRECC()
  );

// synthesis translate_on

endmodule

// -----------------------------------------------------------------------------
// Source file: projnav/xps/pcores/spiifc_v1_00_a/hdl/verilog/spiifc.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:46:12 03/02/2012 
// Design Name: 
// Module Name:    spiifc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spiifc(
  Reset,
  SysClk,
  SPI_CLK,
  SPI_MISO,
  SPI_MOSI,
  SPI_SS,
  txMemAddr,
  txMemData,
  rcMemAddr,
  rcMemData,
  rcMemWE,
  regAddr,
  regReadData,
  regWriteEn,
  regWriteData,
  debug_out
);

//
// Parameters
//
parameter AddrBits = 12;
parameter RegAddrBits = 4;

//
// Defines
//
`define CMD_READ_START    8'd1
`define CMD_READ_MORE     8'd2
`define CMD_WRITE_START   8'd3
`define CMD_WRITE_MORE    8'd4
`define CMD_INTERRUPT     8'd5

`define CMD_REG_BASE      8'd128
`define CMD_REG_BIT       7
`define CMD_REG_WE_BIT    6
`define CMD_REG_ID_MASK   8'h3F

`define STATE_GET_CMD     8'd0
`define STATE_READING     8'd1
`define STATE_WRITING     8'd2
`define STATE_WRITE_INTR  8'd3
`define STATE_BUILD_WORD  8'd4
`define STATE_SEND_WORD   8'd5

//
// Input/Outputs
//
input                    Reset;
input                    SysClk;

input                    SPI_CLK;
output                   SPI_MISO;     // outgoing (from respect of this module)
input                    SPI_MOSI;     // incoming (from respect of this module)
input                    SPI_SS;

output [AddrBits-1:0]    txMemAddr;    // outgoing data
input           [7:0]    txMemData;
output [AddrBits-1:0]    rcMemAddr;    // incoming data
output          [7:0]    rcMemData;
output                   rcMemWE;

output [RegAddrBits-1:0] regAddr;       // Register read address (combinational)
input             [31:0] regReadData;   // Result of register read
output                   regWriteEn;    // Enable write to register, otherwise read
output            [31:0] regWriteData;  // Register write data


output          [7:0] debug_out;

//
// Registers
//
reg                   SPI_CLK_reg;    // Stabalized version of SPI_CLK
reg                   SPI_SS_reg;     // Stabalized version of SPI_SS
reg                   SPI_MOSI_reg;   // Stabalized version of SPI_MOSI

reg                   prev_spiClk;    // Value of SPI_CLK during last SysClk cycle
reg                   prev_spiSS;     // Value of SPI_SS during last SysClk cycle
reg             [7:0] state_reg;      // Register backing the 'state' wire
reg             [7:0] rcByte_reg;     // Register backing 'rcByte'
reg             [2:0] rcBitIndex_reg; // Register backing 'rcBitIndex'
reg    [AddrBits-1:0] rcMemAddr_reg;  // Byte addr to write MOSI data to
reg             [7:0] debug_reg;      // register backing debug_out signal
reg             [2:0] txBitIndex_reg; // Register backing txBitIndex
reg    [AddrBits-1:0] txMemAddr_reg;  // Register backing txAddr

reg             [7:0] command;        // Command being handled
reg            [31:0] rcWord;         // Incoming word being built
reg             [1:0] rcWordByteId;   // Which byte the in the rcWord to map to
reg [RegAddrBits-1:0] regAddr_reg;    // Address of register to read/write to

//
// Wires
//
wire                  risingSpiClk;       // Did the SPI_CLK rise since last SysClk cycle?
wire                  validSpiBit;        // Are the SPI MOSI/MISO bits new and valid?
reg             [7:0] state;              // Current state in the module's state machine (always @* effectively wire)
wire                  rcByteValid;        // rcByte is valid and new
wire            [7:0] rcByte;             // Byte received from master
wire            [2:0] rcBitIndex;         // Bit of rcByte to write to next
reg             [2:0] txBitIndex;         // bit of txByte to send to master next
reg    [AddrBits-1:0] txMemAddr_oreg;     // Wirereg piped to txMemAddr output
reg             [7:0] regReadByte_oreg;   // Which byte of the reg word we're reading out master

// Save buffered SPI inputs
always @(posedge SysClk) begin
  SPI_CLK_reg <= SPI_CLK;
  SPI_SS_reg <= SPI_SS;
  SPI_MOSI_reg <= SPI_MOSI;
end

// Detect new valid bit
always @(posedge SysClk) begin
  prev_spiClk <= SPI_CLK_reg;
end
assign risingSpiClk = SPI_CLK_reg & (~prev_spiClk);
assign validSpiBit = risingSpiClk & (~SPI_SS_reg);

// Detect new SPI packet (SS dropped low)
always @(posedge SysClk) begin
  prev_spiSS <= SPI_SS_reg;
end
assign packetStart = prev_spiSS & (~SPI_SS_reg);

// Build incoming byte
always @(posedge SysClk) begin
  if (validSpiBit) begin
    rcByte_reg[rcBitIndex] <= SPI_MOSI_reg;
    rcBitIndex_reg <= (rcBitIndex > 0 ? rcBitIndex - 1 : 7);
  end else begin
    rcBitIndex_reg <= rcBitIndex;
  end
end
assign rcBitIndex = (Reset || packetStart ? 7 : rcBitIndex_reg); 
assign rcByte = {rcByte_reg[7:1], SPI_MOSI_reg};
assign rcByteValid = (validSpiBit && rcBitIndex == 0 ? 1 : 0);

// Incoming MOSI data buffer management
assign rcMemAddr = rcMemAddr_reg;
assign rcMemData = rcByte;
assign rcMemWE = (state == `STATE_READING && rcByteValid ? 1 : 0);
always @(posedge SysClk) begin
  if (Reset || (`STATE_GET_CMD == state && rcByteValid)) begin
    rcMemAddr_reg <= 0;
  end else if (rcMemWE) begin
    rcMemAddr_reg <= rcMemAddr + 1;
  end else begin
    rcMemAddr_reg <= rcMemAddr;
  end
end

// Outgoing MISO data buffer management
always @(*) begin
  if (Reset || (state == `STATE_GET_CMD && rcByteValid && 
                  (rcByte == `CMD_WRITE_START || 
                   rcByte[`CMD_REG_BIT:`CMD_REG_WE_BIT] == 2'b11)
                )) begin
    txBitIndex <= 3'd7;
    txMemAddr_oreg <= 0;
  end else begin
    txBitIndex <= txBitIndex_reg;

    //txMemAddr_oreg <= txMemAddr_reg;
    if ((state == `STATE_WRITING || state == `STATE_SEND_WORD) && 
        validSpiBit && txBitIndex == 0) begin
      txMemAddr_oreg <= txMemAddr_reg + 1;
    end else begin
      txMemAddr_oreg <= txMemAddr_reg;
    end
    
  end
end
always @(posedge SysClk) begin
  if (validSpiBit && (state == `STATE_WRITING || state == `STATE_SEND_WORD)) begin
    txBitIndex_reg <= (txBitIndex == 0 ? 7 : txBitIndex - 1);
  end else begin
    txBitIndex_reg <= txBitIndex;
  end

  txMemAddr_reg <= txMemAddr;
//  if (state == `STATE_WRITING && validSpiBit && txBitIndex == 0) begin
//    txMemAddr_reg <= txMemAddr + 1;
//  end else begin
//    txMemAddr_reg <= txMemAddr;  
//  end
end
assign txMemAddr = txMemAddr_oreg;
assign SPI_MISO = (state == `STATE_SEND_WORD ? regReadByte_oreg[txBitIndex] : txMemData[txBitIndex]);

// State machine
always @(*) begin
  if (Reset || packetStart) begin
    state <= `STATE_GET_CMD;
// Handled in state_reg logic, should be latched, not immediate.
//  end else if (state_reg == `STATE_GET_CMD && rcByteValid) begin
//    state <= rcByte;
  end else begin
    state <= state_reg;
  end
end
always @(posedge SysClk) begin
  if (`STATE_GET_CMD == state && rcByteValid) begin
    if (`CMD_READ_START == rcByte) begin
      state_reg <= `STATE_READING;
    end else if (`CMD_READ_MORE == rcByte) begin
      state_reg <= `STATE_READING;
    end else if (`CMD_WRITE_START == rcByte) begin
      state_reg <= `STATE_WRITING;
    end else if (`CMD_WRITE_MORE == rcByte) begin
      state_reg <= `STATE_WRITING;
    end else if (rcByte[`CMD_REG_BIT] != 0) begin
      // Register access
      rcWordByteId <= 0;
      command <= `CMD_REG_BASE;               // Write reg           Read reg
      state_reg <= (rcByte[`CMD_REG_WE_BIT] ? `STATE_BUILD_WORD : `STATE_SEND_WORD);      
    end else if (`CMD_INTERRUPT == rcByte) begin
      // TODO: NYI
    end
  end else if (`STATE_BUILD_WORD == state && rcByteValid) begin
    if (0 == rcWordByteId) begin
      rcWord[31:24] <= rcByte;
      rcWordByteId <= 1;
    end else if (1 == rcWordByteId) begin
      rcWord[23:16] <= rcByte;
      rcWordByteId <= 2;
    end else if (2 == rcWordByteId) begin
      rcWord[15:8] <= rcByte;
      rcWordByteId <= 3;
    end else if (3 == rcWordByteId) begin
      rcWord[7:0] <= rcByte;
      state_reg <= `STATE_GET_CMD;
    end
  end else if (`STATE_SEND_WORD == state && rcByteValid) begin
    rcWordByteId <= rcWordByteId + 1;
    state_reg <= (rcWordByteId == 3 ? `STATE_GET_CMD : `STATE_SEND_WORD);
      
  end else begin
    state_reg <= state;
  end
end

// Register logic
assign regAddr = (`STATE_GET_CMD == state && rcByteValid && rcByte[`CMD_REG_BIT] ? (rcByte & `CMD_REG_ID_MASK) : regAddr_reg);
assign regWriteEn = (`STATE_BUILD_WORD == state && rcByteValid && 3 == rcWordByteId ? 1 : 0);
assign regWriteData = {rcWord[31:8], rcByte};
always @(posedge SysClk) begin
  regAddr_reg <= regAddr;
end
always @(*) begin
  case (rcWordByteId)
    0: regReadByte_oreg <= regReadData[31:24];
    1: regReadByte_oreg <= regReadData[23:16];
    2: regReadByte_oreg <= regReadData[15:8];
    3: regReadByte_oreg <= regReadData[7:0];
  endcase
end

// Debugging
always @(posedge SysClk) begin
  if (rcByteValid) begin
    debug_reg <= rcByte;
  end
end
assign debug_out = debug_reg;

endmodule

// -----------------------------------------------------------------------------
// Source file: src/spi_base/spiifc.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:46:12 03/02/2012 
// Design Name: 
// Module Name:    spiifc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spiifc(
  Reset,
  SysClk,
  SPI_CLK,
  SPI_MISO,
  SPI_MOSI,
  SPI_SS,
  txMemAddr,
  txMemData,
  rcMemAddr,
  rcMemData,
  rcMemWE,
  regAddr,
  regReadData,
  regWriteEn,
  regWriteData,
  debug_out
);

//
// Parameters
//
parameter AddrBits = 12;
parameter RegAddrBits = 4;

//
// Defines
//
`define CMD_READ_START    8'd1
`define CMD_READ_MORE     8'd2
`define CMD_WRITE_START   8'd3
`define CMD_WRITE_MORE    8'd4
`define CMD_INTERRUPT     8'd5

`define CMD_REG_BASE      8'd128
`define CMD_REG_BIT       7
`define CMD_REG_WE_BIT    6
`define CMD_REG_ID_MASK   8'h3F

`define STATE_GET_CMD     8'd0
`define STATE_READING     8'd1
`define STATE_WRITING     8'd2
`define STATE_WRITE_INTR  8'd3
`define STATE_BUILD_WORD  8'd4
`define STATE_SEND_WORD   8'd5

//
// Input/Outputs
//
input                    Reset;
input                    SysClk;

input                    SPI_CLK;
output                   SPI_MISO;     // outgoing (from respect of this module)
input                    SPI_MOSI;     // incoming (from respect of this module)
input                    SPI_SS;

output [AddrBits-1:0]    txMemAddr;    // outgoing data
input           [7:0]    txMemData;
output [AddrBits-1:0]    rcMemAddr;    // incoming data
output          [7:0]    rcMemData;
output                   rcMemWE;

output [RegAddrBits-1:0] regAddr;       // Register read address (combinational)
input             [31:0] regReadData;   // Result of register read
output                   regWriteEn;    // Enable write to register, otherwise read
output            [31:0] regWriteData;  // Register write data


output          [7:0] debug_out;

//
// Registers
//
reg                   SPI_CLK_reg;    // Stabalized version of SPI_CLK
reg                   SPI_SS_reg;     // Stabalized version of SPI_SS
reg                   SPI_MOSI_reg;   // Stabalized version of SPI_MOSI

reg                   prev_spiClk;    // Value of SPI_CLK during last SysClk cycle
reg                   prev_spiSS;     // Value of SPI_SS during last SysClk cycle
reg             [7:0] state_reg;      // Register backing the 'state' wire
reg             [7:0] rcByte_reg;     // Register backing 'rcByte'
reg             [2:0] rcBitIndex_reg; // Register backing 'rcBitIndex'
reg    [AddrBits-1:0] rcMemAddr_reg;  // Byte addr to write MOSI data to
reg             [7:0] debug_reg;      // register backing debug_out signal
reg             [2:0] txBitIndex_reg; // Register backing txBitIndex
reg    [AddrBits-1:0] txMemAddr_reg;  // Register backing txAddr

reg             [7:0] command;        // Command being handled
reg            [31:0] rcWord;         // Incoming word being built
reg             [1:0] rcWordByteId;   // Which byte the in the rcWord to map to
reg [RegAddrBits-1:0] regAddr_reg;    // Address of register to read/write to

//
// Wires
//
wire                  risingSpiClk;       // Did the SPI_CLK rise since last SysClk cycle?
wire                  validSpiBit;        // Are the SPI MOSI/MISO bits new and valid?
reg             [7:0] state;              // Current state in the module's state machine (always @* effectively wire)
wire                  rcByteValid;        // rcByte is valid and new
wire            [7:0] rcByte;             // Byte received from master
wire            [2:0] rcBitIndex;         // Bit of rcByte to write to next
reg             [2:0] txBitIndex;         // bit of txByte to send to master next
reg    [AddrBits-1:0] txMemAddr_oreg;     // Wirereg piped to txMemAddr output
reg             [7:0] regReadByte_oreg;   // Which byte of the reg word we're reading out master

// Save buffered SPI inputs
always @(posedge SysClk) begin
  SPI_CLK_reg <= SPI_CLK;
  SPI_SS_reg <= SPI_SS;
  SPI_MOSI_reg <= SPI_MOSI;
end

// Detect new valid bit
always @(posedge SysClk) begin
  prev_spiClk <= SPI_CLK_reg;
end
assign risingSpiClk = SPI_CLK_reg & (~prev_spiClk);
assign validSpiBit = risingSpiClk & (~SPI_SS_reg);

// Detect new SPI packet (SS dropped low)
always @(posedge SysClk) begin
  prev_spiSS <= SPI_SS_reg;
end
assign packetStart = prev_spiSS & (~SPI_SS_reg);

// Build incoming byte
always @(posedge SysClk) begin
  if (validSpiBit) begin
    rcByte_reg[rcBitIndex] <= SPI_MOSI_reg;
    rcBitIndex_reg <= (rcBitIndex > 0 ? rcBitIndex - 1 : 7);
  end else begin
    rcBitIndex_reg <= rcBitIndex;
  end
end
assign rcBitIndex = (Reset || packetStart ? 7 : rcBitIndex_reg); 
assign rcByte = {rcByte_reg[7:1], SPI_MOSI_reg};
assign rcByteValid = (validSpiBit && rcBitIndex == 0 ? 1 : 0);

// Incoming MOSI data buffer management
assign rcMemAddr = rcMemAddr_reg;
assign rcMemData = rcByte;
assign rcMemWE = (state == `STATE_READING && rcByteValid ? 1 : 0);
always @(posedge SysClk) begin
  if (Reset || (`STATE_GET_CMD == state && rcByteValid)) begin
    rcMemAddr_reg <= 0;
  end else if (rcMemWE) begin
    rcMemAddr_reg <= rcMemAddr + 1;
  end else begin
    rcMemAddr_reg <= rcMemAddr;
  end
end

// Outgoing MISO data buffer management
always @(*) begin
  if (Reset || (state == `STATE_GET_CMD && rcByteValid && 
                  (rcByte == `CMD_WRITE_START || 
                   rcByte[`CMD_REG_BIT:`CMD_REG_WE_BIT] == 2'b11)
                )) begin
    txBitIndex <= 3'd7;
    txMemAddr_oreg <= 0;
  end else begin
    txBitIndex <= txBitIndex_reg;

    //txMemAddr_oreg <= txMemAddr_reg;
    if ((state == `STATE_WRITING || state == `STATE_SEND_WORD) && 
        validSpiBit && txBitIndex == 0) begin
      txMemAddr_oreg <= txMemAddr_reg + 1;
    end else begin
      txMemAddr_oreg <= txMemAddr_reg;
    end
    
  end
end
always @(posedge SysClk) begin
  if (validSpiBit && (state == `STATE_WRITING || state == `STATE_SEND_WORD)) begin
    txBitIndex_reg <= (txBitIndex == 0 ? 7 : txBitIndex - 1);
  end else begin
    txBitIndex_reg <= txBitIndex;
  end

  txMemAddr_reg <= txMemAddr;
//  if (state == `STATE_WRITING && validSpiBit && txBitIndex == 0) begin
//    txMemAddr_reg <= txMemAddr + 1;
//  end else begin
//    txMemAddr_reg <= txMemAddr;  
//  end
end
assign txMemAddr = txMemAddr_oreg;
assign SPI_MISO = (state == `STATE_SEND_WORD ? regReadByte_oreg[txBitIndex] : txMemData[txBitIndex]);

// State machine
always @(*) begin
  if (Reset || packetStart) begin
    state <= `STATE_GET_CMD;
// Handled in state_reg logic, should be latched, not immediate.
//  end else if (state_reg == `STATE_GET_CMD && rcByteValid) begin
//    state <= rcByte;
  end else begin
    state <= state_reg;
  end
end
always @(posedge SysClk) begin
  if (`STATE_GET_CMD == state && rcByteValid) begin
    if (`CMD_READ_START == rcByte) begin
      state_reg <= `STATE_READING;
    end else if (`CMD_READ_MORE == rcByte) begin
      state_reg <= `STATE_READING;
    end else if (`CMD_WRITE_START == rcByte) begin
      state_reg <= `STATE_WRITING;
    end else if (`CMD_WRITE_MORE == rcByte) begin
      state_reg <= `STATE_WRITING;
    end else if (rcByte[`CMD_REG_BIT] != 0) begin
      // Register access
      rcWordByteId <= 0;
      command <= `CMD_REG_BASE;               // Write reg           Read reg
      state_reg <= (rcByte[`CMD_REG_WE_BIT] ? `STATE_BUILD_WORD : `STATE_SEND_WORD);      
    end else if (`CMD_INTERRUPT == rcByte) begin
      // TODO: NYI
    end
  end else if (`STATE_BUILD_WORD == state && rcByteValid) begin
    if (0 == rcWordByteId) begin
      rcWord[31:24] <= rcByte;
      rcWordByteId <= 1;
    end else if (1 == rcWordByteId) begin
      rcWord[23:16] <= rcByte;
      rcWordByteId <= 2;
    end else if (2 == rcWordByteId) begin
      rcWord[15:8] <= rcByte;
      rcWordByteId <= 3;
    end else if (3 == rcWordByteId) begin
      rcWord[7:0] <= rcByte;
      state_reg <= `STATE_GET_CMD;
    end
  end else if (`STATE_SEND_WORD == state && rcByteValid) begin
    rcWordByteId <= rcWordByteId + 1;
    state_reg <= (rcWordByteId == 3 ? `STATE_GET_CMD : `STATE_SEND_WORD);
      
  end else begin
    state_reg <= state;
  end
end

// Register logic
assign regAddr = (`STATE_GET_CMD == state && rcByteValid && rcByte[`CMD_REG_BIT] ? (rcByte & `CMD_REG_ID_MASK) : regAddr_reg);
assign regWriteEn = (`STATE_BUILD_WORD == state && rcByteValid && 3 == rcWordByteId ? 1 : 0);
assign regWriteData = {rcWord[31:8], rcByte};
always @(posedge SysClk) begin
  regAddr_reg <= regAddr;
end
always @(*) begin
  case (rcWordByteId)
    0: regReadByte_oreg <= regReadData[31:24];
    1: regReadByte_oreg <= regReadData[23:16];
    2: regReadByte_oreg <= regReadData[15:8];
    3: regReadByte_oreg <= regReadData[7:0];
  endcase
end

// Debugging
always @(posedge SysClk) begin
  if (rcByteValid) begin
    debug_reg <= rcByte;
  end
end
assign debug_out = debug_reg;

endmodule

// -----------------------------------------------------------------------------
// Source file: src/spi_base/spiifc_twoclock.v
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:33 10/18/2011 
// Design Name: 
// Module Name:    spiifc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spiifc(
  Reset,
  SysClk,
  SPI_CLK,
  SPI_MISO,
  SPI_MOSI,
  SPI_SS,
  txMemAddr,
  txMemData,
  rcMemAddr,
  rcMemData,
  rcMemWE,
  debug_out
  );
  
  //
  // Parameters
  //
  parameter AddrBits = 12;
  
  // Defines
  `define  CMD_READ_START   8'd1
  `define  CMD_READ_MORE    8'd2
  `define  CMD_WRITE_START  8'd3
  
  `define  STATE_GET_CMD    8'd0
  `define  STATE_READING    8'd1
  `define  STATE_WRITING    8'd2
  
  //
  // Input/Output defs
  //
  input  Reset;
  input  SysClk;
  
  input  SPI_CLK;
  output SPI_MISO;
  input  SPI_MOSI;
  input  SPI_SS;
  
  output [AddrBits-1:0] txMemAddr;
  input  [7:0]          txMemData;
  
  output  [AddrBits-1:0] rcMemAddr;
  output  [7:0]          rcMemData;
  output                 rcMemWE;
  
  output  [7:0]          debug_out;
  
  //
  // Registers
  // 
  
  reg  [ 7: 0] debug_reg;
  
  reg  [ 7: 0] rcByteReg;
  reg          rcStarted;
  reg  [ 2: 0] rcBitIndexReg;
  reg  [11: 0] rcMemAddrReg;
  reg  [11: 0] rcMemAddrNext;
  reg  [ 7: 0] rcMemDataReg;
  reg          rcMemWEReg;
  
  reg          ssPrev;
  
  reg          ssFastToggleReg;
  reg          ssSlowToggle;
  
  reg          ssTurnOnReg;
  reg          ssTurnOnHandled;
  
  reg  [ 7: 0] cmd;
  reg  [ 7: 0] stateReg;
  
  reg  [11: 0] txMemAddrReg;
  reg  [ 2: 0] txBitAddr;
  
  //
  // Wires
  //
  wire         rcByteValid; 
  wire [ 7: 0] rcByte;
  wire         rcStarting;
  wire [ 2: 0] rcBitIndex;
  
  wire         ssTurnOn;
  
  wire         ssFastToggle;
  
  wire [ 7: 0] state;
  
  wire         txMemAddrReset;
  
  //
  // Output assigns
  //
  assign debug_out = debug_reg;
  
  assign rcMemAddr = rcMemAddrReg;
  assign rcMemData = rcMemDataReg;
  assign rcMemWE = rcMemWEReg;
  
  assign txMemAddrReset = (rcByteValid && rcByte == `CMD_WRITE_START ? 1 : 0);
  assign txMemAddr = (txMemAddrReset ? 0 : txMemAddrReg);
  assign SPI_MISO = txMemData[txBitAddr];
  
  assign ssFastToggle = 
      (ssPrev == 1 && SPI_SS == 0 ? ~ssFastToggleReg : ssFastToggleReg);
  
  //
  // Wire assigns
  //
  assign rcByteValid = rcStarted && rcBitIndex == 0;
  assign rcByte = {rcByteReg[7:1], SPI_MOSI};
  assign rcStarting = ssTurnOn;
  assign rcBitIndex = (rcStarting ? 3'd7 : rcBitIndexReg);
  
  assign ssTurnOn = ssSlowToggle ^ ssFastToggle;
  assign state = (rcStarting ? `STATE_GET_CMD : stateReg);
  
  initial begin
    ssSlowToggle <= 0;
  end
  
  always @(posedge SysClk) begin
    ssPrev <= SPI_SS;
    
    if (Reset) begin
      ssTurnOnReg <= 0;
      ssFastToggleReg <= 0;

    end else begin
      if (ssPrev & (~SPI_SS)) begin
        ssTurnOnReg <= 1;
        ssFastToggleReg <= ~ssFastToggleReg;
        
      end else if (ssTurnOnHandled) begin
        ssTurnOnReg <= 0;
      end
    end
    
  end
  
  always @(posedge SPI_CLK) begin
    ssSlowToggle <= ssFastToggle;
  
    if (Reset) begin
      // Resetting
      rcByteReg <= 8'h00;
      rcStarted <= 0;
      rcBitIndexReg <= 3'd7;
      ssTurnOnHandled <= 0;
      debug_reg <= 8'hFF;
      
    end else begin
      // Not resetting
      
      ssTurnOnHandled <= ssTurnOn;
      stateReg <= state;
      rcMemAddrReg <= rcMemAddrNext;
          
      if (~SPI_SS) begin
        rcByteReg[rcBitIndex] <= SPI_MOSI;
        rcBitIndexReg <= rcBitIndex - 3'd1;
        rcStarted <= 1;
        
        // Update txBitAddr if writing out
        if (`STATE_WRITING == state) begin
          if (txBitAddr == 3'd1) begin
            txMemAddrReg <= txMemAddr + 1;
          end 
          txBitAddr <= txBitAddr - 1;
        end
      end
      
      // We've just received a byte (well, currently receiving the last bit)
      
      if (rcByteValid) begin
        // For now, just display on LEDs
        debug_reg <= rcByte;
      
        if (`STATE_GET_CMD == state) begin
          cmd <= rcByte;    // Will take effect next cycle
          
          if (`CMD_READ_START == rcByte) begin
            rcMemAddrNext <= 0;
            stateReg <= `STATE_READING;
          end else if (`CMD_READ_MORE == rcByte) begin
            stateReg <= `STATE_READING;
          end else if (`CMD_WRITE_START == rcByte) begin
            txBitAddr <= 3'd7;
            stateReg <= `STATE_WRITING;
            txMemAddrReg <= txMemAddr;  // Keep at 0
          end
         
        end else if (`STATE_READING == state) begin
          rcMemDataReg <= rcByte;
          rcMemAddrNext <= rcMemAddr + 1;
          rcMemWEReg <= 1;
        
        end else if (`STATE_WRITING == state) begin
          txBitAddr <= 3'd7;
          stateReg <= `STATE_WRITING;
        end
      
      end else begin
        // Not a valid byte
        rcMemWEReg <= 0;
        
      end // valid/valid' byte
      
    end // Reset/Reset'
  end
  
endmodule
