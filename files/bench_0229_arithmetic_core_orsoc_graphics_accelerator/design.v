// Curated RTL benchmark case.
// case_id: bench_0229_arithmetic_core_orsoc_graphics_accelerator
// source_project: arithmetic_core_orsoc_graphics_accelerator
// top_module: gfx_top


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/mmc_boot_defines.v
// -----------------------------------------------------------------------------
// Copyright 2004-2005 Openchip
// http://www.openchip.org

`ifdef MMC_BOOT_DEFINES
`else
`define MMC_BOOT_DEFINES


// send 80 clocks ?
`define CMD_INIT	4'b1111  

// Initialize
`define CMD0	 			4'b0000  

// identify, loop until ready !
`define CMD1	 			4'b0001  

// just read the rest of response
`define CMD1_IDLE	 		4'b1001  

// read CID
`define CMD2	 			4'b0010  

// assign RCA
`define CMD3	 			4'b0011	

// go transfer
`define CMD7	 			4'b0111	

// stream read command
`define CMD11 			     4'b1011  

// stream read transfer in progress
`define CMD_TRANSFER 		4'b1100  

// config done, just idle wait for reset
`define CMD_CONFIG_DONE 	     4'b1101  

// config error, just idle wait for reset
`define CMD_CONFIG_ERROR 	4'b1110  


`endif

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/virtex_bitstream_const.v
// -----------------------------------------------------------------------------
// Copyright 2004-2005 Openchip
// http://www.openchip.org


// XAPP-151
`define VIRTEX_CFG_CMD_WCFG	4'b0001
`define VIRTEX_CFG_CMD_LFRM	4'b0011
`define VIRTEX_CFG_CMD_RCFG	4'b0100
`define VIRTEX_CFG_CMD_START	4'b0101
`define VIRTEX_CFG_CMD_RCAP	4'b0110
`define VIRTEX_CFG_CMD_RCRC	4'b0111
`define VIRTEX_CFG_CMD_AGHIGH	4'b1000
`define VIRTEX_CFG_CMD_SWITCH	4'b1001
// Virtex-II/Pro, S-3
`define VIRTEX_CFG_CMD_DESYNC	4'b1101 


// XAPP 151
`define VIRTEX_CFG_REG_CRC	4'b0000
`define VIRTEX_CFG_REG_FAR	4'b0001
`define VIRTEX_CFG_REG_FDRI	4'b0010
`define VIRTEX_CFG_REG_FDRO	4'b0011
`define VIRTEX_CFG_REG_CMD	4'b0100
`define VIRTEX_CFG_REG_CTL	4'b0101
`define VIRTEX_CFG_REG_MASK	4'b0110
`define VIRTEX_CFG_REG_STAT	4'b0111
`define VIRTEX_CFG_REG_LOUT	4'b1000
`define VIRTEX_CFG_REG_COR	4'b1001
`define VIRTEX_CFG_REG_FLR	4'b1011


// Virtex-II
`define VIRTEX_CFG_REG_RES_E	4'b1110


// XAPP 151
`define VIRTEX_CFG_OP_READ	2'b01
`define VIRTEX_CFG_OP_WRITE	2'b10






  

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_top.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

TOP MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

module gfx_top (wb_clk_i, wb_rst_i, wb_inta_o,
  // Wishbone master signals (interfaces with video memory, write)
  wbm_write_cyc_o, wbm_write_stb_o, wbm_write_cti_o, wbm_write_bte_o, wbm_write_we_o, wbm_write_adr_o, wbm_write_sel_o, wbm_write_ack_i, wbm_write_err_i, wbm_write_dat_o,
  // Wishbone master signals (interfaces with video memory, read)
  wbm_read_cyc_o, wbm_read_stb_o, wbm_read_cti_o, wbm_read_bte_o, wbm_read_we_o, wbm_read_adr_o, wbm_read_sel_o, wbm_read_ack_i, wbm_read_err_i, wbm_read_dat_i,
  // Wishbone slave signals (interfaces with main bus/CPU)
  wbs_cyc_i, wbs_stb_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_adr_i, wbs_sel_i, wbs_ack_o, wbs_err_o, wbs_dat_i, wbs_dat_o
);

// Set default parameters
parameter point_width    = 16;
parameter subpixel_width = 16;
parameter fifo_depth     = 10;

parameter REG_ADR_HIBIT = 9;

// Common wishbone signals
input         wb_clk_i;    // master clock input
input         wb_rst_i;    // Asynchronous active high reset
output        wb_inta_o;   // interrupt

// Wishbone master signals (write)
output        wbm_write_cyc_o;    // cycle output
output        wbm_write_stb_o;    // strobe output
output [ 2:0] wbm_write_cti_o;    // cycle type id
output [ 1:0] wbm_write_bte_o;    // burst type extension
output        wbm_write_we_o;     // write enable output
output [31:0] wbm_write_adr_o;    // address output
output [ 3:0] wbm_write_sel_o;    // byte select outputs (only 32bits accesses are supported)
input         wbm_write_ack_i;    // wishbone cycle acknowledge
input         wbm_write_err_i;    // wishbone cycle error
output [31:0] wbm_write_dat_o;    // wishbone data out

// Wishbone master signals (read)
output        wbm_read_cyc_o;    // cycle output
output        wbm_read_stb_o;    // strobe output
output [ 2:0] wbm_read_cti_o;    // cycle type id
output [ 1:0] wbm_read_bte_o;    // burst type extension
output        wbm_read_we_o;     // write enable output
output [31:0] wbm_read_adr_o;    // address output
output [ 3:0] wbm_read_sel_o;    // byte select outputs (only 32bits accesses are supported)
input         wbm_read_ack_i;    // wishbone cycle acknowledge
input         wbm_read_err_i;    // wishbone cycle error
input  [31:0] wbm_read_dat_i;    // wishbone data in

// Wishbone slave signals
input         wbs_cyc_i;    // cycle input
input         wbs_stb_i;    // strobe input
input  [ 2:0] wbs_cti_i;    // cycle type id
input  [ 1:0] wbs_bte_i;    // burst type extension
input         wbs_we_i;     // write enable input
input  [31:0] wbs_adr_i;    // address input
input  [ 3:0] wbs_sel_i;    // byte select input (only 32bits accesses are supported)
output        wbs_ack_o;    // wishbone cycle acknowledge
output        wbs_err_o;    // wishbone cycle error
input  [31:0] wbs_dat_i;    // wishbone data in
output [31:0] wbs_dat_o;    // wishbone data out

// Wires and variables

wire wbmwriter_sint; // connect to slave interface
wire wbmreader_sint;

wire vector_wbs_ack;
wire transform_wbs_ack;

wire            [31:2] target_base_reg;
wire [point_width-1:0] target_size_x_reg;
wire [point_width-1:0] target_size_y_reg;

wire            [31:2] wbs_fragment_tex0_base;
wire [point_width-1:0] wbs_fragment_tex0_size_x;
wire [point_width-1:0] wbs_fragment_tex0_size_y;

wire [31:2] render_wbmwriter_addr;
wire  [3:0] render_wbmwriter_sel;
wire [31:0] render_wbmwriter_dat;

wire [1:0] color_depth_reg;

wire render_wbmwriter_memory_pixel_write;
wire wbs_raster_rect_write;
wire wbs_raster_line_write;
wire wbs_raster_triangle_write;
wire wbs_raster_interpolate;

wire wbs_fragment_curve_write;

wire wbmwriter_render_ack;

// src pixel
wire [point_width-1:0] wbs_raster_src_pixel0_x;
wire [point_width-1:0] wbs_raster_src_pixel0_y;
wire [point_width-1:0] wbs_raster_src_pixel1_x;
wire [point_width-1:0] wbs_raster_src_pixel1_y;

// dest pixel
wire signed [point_width-1:-subpixel_width] wbs_transform_dest_pixel_x;
wire signed [point_width-1:-subpixel_width] wbs_transform_dest_pixel_y;
wire signed [point_width-1:-subpixel_width] wbs_transform_dest_pixel_z;
wire                           [1:0] wbs_transform_dest_pixel_id;

// transformation matrix
wire signed [point_width-1:-subpixel_width] wbs_transform_aa;
wire signed [point_width-1:-subpixel_width] wbs_transform_ab;
wire signed [point_width-1:-subpixel_width] wbs_transform_ac;
wire signed [point_width-1:-subpixel_width] wbs_transform_tx;
wire signed [point_width-1:-subpixel_width] wbs_transform_ba;
wire signed [point_width-1:-subpixel_width] wbs_transform_bb;
wire signed [point_width-1:-subpixel_width] wbs_transform_bc;
wire signed [point_width-1:-subpixel_width] wbs_transform_ty;
wire signed [point_width-1:-subpixel_width] wbs_transform_ca;
wire signed [point_width-1:-subpixel_width] wbs_transform_cb;
wire signed [point_width-1:-subpixel_width] wbs_transform_cc;
wire signed [point_width-1:-subpixel_width] wbs_transform_tz;

// clip pixel
wire [point_width-1:0] clip_pixel0_x_reg;
wire [point_width-1:0] clip_pixel0_y_reg;
wire [point_width-1:0] clip_pixel1_x_reg;
wire [point_width-1:0] clip_pixel1_y_reg;

wire [31:0] color0_reg;
wire [31:0] color1_reg;
wire [31:0] color2_reg;

wire [point_width-1:0] u0_reg;
wire [point_width-1:0] v0_reg;
wire [point_width-1:0] u1_reg;
wire [point_width-1:0] v1_reg;
wire [point_width-1:0] u2_reg;
wire [point_width-1:0] v2_reg;

wire [7:0] alpha0_reg;
wire [7:0] alpha1_reg;
wire [7:0] alpha2_reg;

wire texture_enable_reg;

wire        blending_enable_reg;
wire  [7:0] global_alpha_reg;
wire        colorkey_enable_reg;
wire [31:0] colorkey_reg;
wire        clipping_enable_reg;
wire        inside_reg;
wire        zbuffer_enable_reg;
wire [31:2] zbuffer_base_reg;

wire        wbs_transform_transform;
wire        wbs_transform_forward;

wire        raster_wbs_ack;

// Slave wishbone interface. Reads wishbone bus and fills registers
gfx_wbs wb_databus(
  .clk_i             (wb_clk_i),
  .rst_i             (wb_rst_i),
  .adr_i             (wbs_adr_i[REG_ADR_HIBIT:0]),
  .dat_i             (wbs_dat_i),
  .dat_o             (wbs_dat_o),
  .sel_i             (wbs_sel_i),
  .we_i              (wbs_we_i),
  .stb_i             (wbs_stb_i),
  .cyc_i             (wbs_cyc_i),
  .ack_o             (wbs_ack_o),
  .rty_o             (),
  .err_o             (wbs_err_o),
  .inta_o            (wb_inta_o),

  //source pixel
  .src_pixel0_x_o    (wbs_raster_src_pixel0_x),
  .src_pixel0_y_o    (wbs_raster_src_pixel0_y),
  .src_pixel1_x_o    (wbs_raster_src_pixel1_x),
  .src_pixel1_y_o    (wbs_raster_src_pixel1_y),
  //destination pixel
  .dest_pixel_x_o    (wbs_transform_dest_pixel_x),
  .dest_pixel_y_o    (wbs_transform_dest_pixel_y),
  .dest_pixel_z_o    (wbs_transform_dest_pixel_z),
  .dest_pixel_id_o   (wbs_transform_dest_pixel_id),
  //matrix
  .aa_o              (wbs_transform_aa),
  .ab_o              (wbs_transform_ab),
  .ac_o              (wbs_transform_ac),
  .tx_o              (wbs_transform_tx),
  .ba_o              (wbs_transform_ba),
  .bb_o              (wbs_transform_bb),
  .bc_o              (wbs_transform_bc),
  .ty_o              (wbs_transform_ty),
  .ca_o              (wbs_transform_ca),
  .cb_o              (wbs_transform_cb),
  .cc_o              (wbs_transform_cc),
  .tz_o              (wbs_transform_tz),
  .transform_point_o (wbs_transform_transform),
  .forward_point_o   (wbs_transform_forward),
  //clip pixel
  .clip_pixel0_x_o   (clip_pixel0_x_reg),
  .clip_pixel0_y_o   (clip_pixel0_y_reg),
  .clip_pixel1_x_o   (clip_pixel1_x_reg),
  .clip_pixel1_y_o   (clip_pixel1_y_reg),

  .color0_o          (color0_reg),
  .color1_o          (color1_reg),
  .color2_o          (color2_reg),

  .u0_o              (u0_reg),
  .v0_o              (v0_reg),
  .u1_o              (u1_reg),
  .v1_o              (v1_reg),
  .u2_o              (u2_reg),
  .v2_o              (v2_reg),

  .a0_o              (alpha0_reg),
  .a1_o              (alpha1_reg),
  .a2_o              (alpha2_reg),
  .global_alpha_o    (global_alpha_reg),

  .target_base_o     (target_base_reg),
  .target_size_x_o   (target_size_x_reg),
  .target_size_y_o   (target_size_y_reg),
  .tex0_base_o       (wbs_fragment_tex0_base),
  .tex0_size_x_o     (wbs_fragment_tex0_size_x),
  .tex0_size_y_o     (wbs_fragment_tex0_size_y),

  .color_depth_o     (color_depth_reg),

  .rect_write_o      (wbs_raster_rect_write),
  .line_write_o      (wbs_raster_line_write),
  .triangle_write_o  (wbs_raster_triangle_write),
  .curve_write_o     (wbs_fragment_curve_write),
  .interpolate_o     (wbs_raster_interpolate),

  .writer_sint_i     (wbmwriter_sint),
  .reader_sint_i     (wbmreader_sint),

  .pipeline_ack_i    (raster_wbs_ack),
  .transform_ack_i   (transform_wbs_ack),

  .texture_enable_o  (texture_enable_reg),
  .blending_enable_o (blending_enable_reg),
  .colorkey_enable_o (colorkey_enable_reg),
  .colorkey_o        (colorkey_reg),
  .clipping_enable_o (clipping_enable_reg),
  .inside_o          (inside_reg),
  .zbuffer_enable_o  (zbuffer_enable_reg),
  .zbuffer_base_o    (zbuffer_base_reg)
  );

defparam wb_databus.point_width    = point_width;
defparam wb_databus.subpixel_width = subpixel_width;
defparam wb_databus.fifo_depth     = fifo_depth;
defparam wb_databus.REG_ADR_HIBIT  = REG_ADR_HIBIT;

wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel0_x;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel0_y;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel1_x;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel1_y;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel2_x;
wire signed [point_width-1:-subpixel_width] transform_raster_dest_pixel2_y;

wire signed [point_width-1:0] transform_cuvz_dest_pixel0_z;
wire signed [point_width-1:0] transform_cuvz_dest_pixel1_z;
wire signed [point_width-1:0] transform_cuvz_dest_pixel2_z;

// Apply transforms to points
gfx_transform transform(
.clk_i           (wb_clk_i),
.rst_i           (wb_rst_i),
.x_i             (wbs_transform_dest_pixel_x),
.y_i             (wbs_transform_dest_pixel_y),
.z_i             (wbs_transform_dest_pixel_z),
.point_id_i      (wbs_transform_dest_pixel_id),
// Matrix
.aa              (wbs_transform_aa),
.ab              (wbs_transform_ab),
.ac              (wbs_transform_ac),
.tx              (wbs_transform_tx),
.ba              (wbs_transform_ba),
.bb              (wbs_transform_bb),
.bc              (wbs_transform_bc),
.ty              (wbs_transform_ty),
.ca              (wbs_transform_ca),
.cb              (wbs_transform_cb),
.cc              (wbs_transform_cc),
.tz              (wbs_transform_tz),
// Output points
.p0_x_o          (transform_raster_dest_pixel0_x),
.p0_y_o          (transform_raster_dest_pixel0_y),
.p0_z_o          (transform_cuvz_dest_pixel0_z),
.p1_x_o          (transform_raster_dest_pixel1_x),
.p1_y_o          (transform_raster_dest_pixel1_y),
.p1_z_o          (transform_cuvz_dest_pixel1_z),
.p2_x_o          (transform_raster_dest_pixel2_x),
.p2_y_o          (transform_raster_dest_pixel2_y),
.p2_z_o          (transform_cuvz_dest_pixel2_z),
.transform_i     (wbs_transform_transform),
.forward_i       (wbs_transform_forward),
.ack_o           (transform_wbs_ack)
);

defparam transform.point_width = point_width;
defparam transform.subpixel_width = subpixel_width;

wire raster_clip_write;
wire [point_width-1:0] raster_x_pixel;
wire [point_width-1:0] raster_y_pixel;
wire clip_ack;
wire raster_interp_write;
wire interp_raster_ack;
wire [point_width-1:0] raster_clip_u;
wire [point_width-1:0] raster_clip_v;

wire [2*point_width-1:0] raster_interp_edge0;
wire [2*point_width-1:0] raster_interp_edge1;
wire [2*point_width-1:0] raster_interp_area;

// Rasterizer generates pixels to calculate
gfx_rasterizer rasterizer0 (
  .clk_i            (wb_clk_i),
  .rst_i            (wb_rst_i),

  .clip_ack_i       (clip_ack),
  .interp_ack_i     (interp_raster_ack),
  .ack_o            (raster_wbs_ack),

  .rect_write_i	    (wbs_raster_rect_write),
  .line_write_i     (wbs_raster_line_write),
  .triangle_write_i (wbs_raster_triangle_write),
  .interpolate_i    (wbs_raster_interpolate),

  .texture_enable_i (texture_enable_reg),
  // source pixel coordinates
  .src_pixel0_x_i   (wbs_raster_src_pixel0_x),
  .src_pixel0_y_i   (wbs_raster_src_pixel0_y),
  .src_pixel1_x_i   (wbs_raster_src_pixel1_x),
  .src_pixel1_y_i   (wbs_raster_src_pixel1_y),

  // destination pixel coordinates
  .dest_pixel0_x_i  (transform_raster_dest_pixel0_x),
  .dest_pixel0_y_i  (transform_raster_dest_pixel0_y),
  .dest_pixel1_x_i  (transform_raster_dest_pixel1_x),
  .dest_pixel1_y_i  (transform_raster_dest_pixel1_y),
  .dest_pixel2_x_i  (transform_raster_dest_pixel2_x),
  .dest_pixel2_y_i  (transform_raster_dest_pixel2_y),

  // clip pixel coordinates
  .clipping_enable_i       (clipping_enable_reg),
  .clip_pixel0_x_i         (clip_pixel0_x_reg),
  .clip_pixel0_y_i         (clip_pixel0_y_reg),
  .clip_pixel1_x_i         (clip_pixel1_x_reg),
  .clip_pixel1_y_i         (clip_pixel1_y_reg),	

  // Screen size
  .target_size_x_i  (target_size_x_reg),
  .target_size_y_i  (target_size_y_reg),

  // Output pixel
  .x_counter_o 	    (raster_x_pixel),
  .y_counter_o 	    (raster_y_pixel),
  .u_o              (raster_clip_u),
  .v_o              (raster_clip_v),
  .clip_write_o     (raster_clip_write),
  // To interp
  .triangle_edge0_o (raster_interp_edge0),
  .triangle_edge1_o (raster_interp_edge1),
  .triangle_area_o  (raster_interp_area),
  .interp_write_o   (raster_interp_write)
  );

defparam rasterizer0.point_width = point_width;
defparam rasterizer0.subpixel_width = subpixel_width;
defparam rasterizer0.delay_width  = 5; // log2(point_width+1)

wire [point_width-1:0] interp_cuvz_x;
wire [point_width-1:0] interp_cuvz_y;

wire [point_width-1:0] interp_cuvz_factor0;
wire [point_width-1:0] interp_cuvz_factor1;

wire                   interp_cuvz_write;

wire                   cuvz_interp_ack;

gfx_interp interp(
.clk_i     (wb_clk_i),
.rst_i     (wb_rst_i),
.ack_i     (cuvz_interp_ack),
.ack_o     (interp_raster_ack),
.write_i   (raster_interp_write),
.edge0_i   (raster_interp_edge0),
.edge1_i   (raster_interp_edge1),
.area_i    (raster_interp_area),
.x_i       (raster_x_pixel),
.y_i       (raster_y_pixel),
.x_o       (interp_cuvz_x),
.y_o       (interp_cuvz_y),
.factor0_o (interp_cuvz_factor0),
.factor1_o (interp_cuvz_factor1),
.write_o   (interp_cuvz_write)
);

defparam interp.point_width  = point_width;
defparam interp.delay_width  = 5; // log2(point_width+1)
defparam interp.result_width = 4; // 16 pipeline slots

wire [point_width-1:0] cuvz_clip_x;
wire [point_width-1:0] cuvz_clip_y;
wire signed [point_width-1:0] cuvz_clip_z;
wire [point_width-1:0] cuvz_clip_u;
wire [point_width-1:0] cuvz_clip_v;
wire             [7:0] cuvz_clip_alpha;
wire [point_width-1:0] cuvz_clip_bezier_factor0;
wire [point_width-1:0] cuvz_clip_bezier_factor1;
wire                   cuvz_clip_write;

wire            [31:0] cuvz_clip_color;

gfx_cuvz cuvz(
.clk_i     (wb_clk_i),
.rst_i     (wb_rst_i),
.ack_i     (clip_ack),
.ack_o     (cuvz_interp_ack),
.write_i   (interp_cuvz_write),
// Variables needed for interpolation
.factor0_i (interp_cuvz_factor0),
.factor1_i (interp_cuvz_factor1),
// Color
.color0_i  (color0_reg),
.color1_i  (color1_reg),
.color2_i  (color2_reg),
.color_depth_i (color_depth_reg),
.color_o   (cuvz_clip_color),
// Depth
.z0_i      (transform_cuvz_dest_pixel0_z),
.z1_i      (transform_cuvz_dest_pixel1_z),
.z2_i      (transform_cuvz_dest_pixel2_z),
.z_o       (cuvz_clip_z),
// Alpha
.a0_i      (alpha0_reg),
.a1_i      (alpha1_reg),
.a2_i      (alpha2_reg),
.a_o       (cuvz_clip_alpha),
// Texture coordinates
.u0_i      (u0_reg),
.v0_i      (v0_reg),
.u1_i      (u1_reg),
.v1_i      (v1_reg),
.u2_i      (u2_reg),
.v2_i      (v2_reg),
.u_o       (cuvz_clip_u),
.v_o       (cuvz_clip_v),
// Bezier calculations
.bezier_factor0_o (cuvz_clip_bezier_factor0),
.bezier_factor1_o (cuvz_clip_bezier_factor1),
// Raster position
.x_i       (interp_cuvz_x),
.y_i       (interp_cuvz_y),
.x_o       (cuvz_clip_x),
.y_o       (cuvz_clip_y),

.write_o   (cuvz_clip_write)
);

defparam cuvz.point_width     = point_width;

wire                   clip_fragment_write_enable;
wire [point_width-1:0] clip_fragment_x_pixel;
wire [point_width-1:0] clip_fragment_y_pixel;
wire signed [point_width-1:0] clip_fragment_z_pixel;
wire                   fragment_clip_ack;
wire [point_width-1:0] clip_fragment_u;
wire [point_width-1:0] clip_fragment_v;
wire             [7:0] clip_fragment_a;
wire [point_width-1:0] clip_fragment_bezier_factor0;
wire [point_width-1:0] clip_fragment_bezier_factor1;

wire            [31:0] clip_fragment_color;

wire                   wbmreader_busy;

// Connected through arbiter
wire        wbmreader_clip_z_ack;
wire [31:2] clip_wbmreader_z_addr;
wire [31:0] wbmreader_clip_z_data;
wire  [3:0] clip_wbmreader_z_sel;
wire        clip_wbmreader_z_request;

// Apply clipping
gfx_clip clip(
.clk_i            (wb_clk_i),
.rst_i            (wb_rst_i),
.clipping_enable_i(clipping_enable_reg),
.zbuffer_enable_i (zbuffer_enable_reg),
.zbuffer_base_i   (zbuffer_base_reg),
.target_size_x_i  (target_size_x_reg),
.target_size_y_i  (target_size_y_reg),
.clip_pixel0_x_i  (clip_pixel0_x_reg),
.clip_pixel0_y_i  (clip_pixel0_y_reg),
.clip_pixel1_x_i  (clip_pixel1_x_reg),
.clip_pixel1_y_i  (clip_pixel1_y_reg),
.raster_pixel_x_i (raster_x_pixel),
.raster_pixel_y_i (raster_y_pixel),
.raster_u_i       (raster_clip_u),
.raster_v_i       (raster_clip_v),
.flat_color_i     (color0_reg),
.raster_write_i   (raster_clip_write),
.cuvz_pixel_x_i   (cuvz_clip_x),
.cuvz_pixel_y_i   (cuvz_clip_y),
.cuvz_pixel_z_i   (cuvz_clip_z),
.cuvz_u_i         (cuvz_clip_u),
.cuvz_v_i         (cuvz_clip_v),
.cuvz_a_i         (cuvz_clip_alpha),
.cuvz_color_i     (cuvz_clip_color),
.cuvz_write_i     (cuvz_clip_write),
.ack_o            (clip_ack),
.z_ack_i          (wbmreader_clip_z_ack),
.z_addr_o         (clip_wbmreader_z_addr),
.z_data_i         (wbmreader_clip_z_data),
.z_sel_o          (clip_wbmreader_z_sel),
.z_request_o      (clip_wbmreader_z_request),
.wbm_busy_i       (wbmreader_busy),
.pixel_x_o        (clip_fragment_x_pixel),
.pixel_y_o        (clip_fragment_y_pixel),
.pixel_z_o        (clip_fragment_z_pixel),
.u_o              (clip_fragment_u),
.v_o              (clip_fragment_v),
.a_o              (clip_fragment_a),
.bezier_factor0_i (cuvz_clip_bezier_factor0),
.bezier_factor1_i (cuvz_clip_bezier_factor1),
.bezier_factor0_o (clip_fragment_bezier_factor0),
.bezier_factor1_o (clip_fragment_bezier_factor1),
.color_o          (clip_fragment_color),
.write_o          (clip_fragment_write_enable),
.ack_i            (fragment_clip_ack)
);

defparam clip.point_width = point_width;

wire                   fragment_blender_write_enable;
wire [point_width-1:0] fragment_blender_x_pixel;
wire [point_width-1:0] fragment_blender_y_pixel;
wire signed [point_width-1:0] fragment_blender_z_pixel;
wire                   blender_fragment_ack;
wire            [31:0] fragment_blender_color;
wire             [7:0] fragment_blender_alpha;

wire        wbmreader_fragment_texture_ack;
wire [31:0] wbmreader_fragment_texture_data;
wire [31:2] fragment_wbmreader_texture_addr;
wire  [3:0] fragment_wbmreader_texture_sel;
wire        fragment_wbmreader_texture_request;


// Fragment processor generates color of pixel (requires RAM read for textures)
gfx_fragment_processor fp0 (
  .clk_i             (wb_clk_i),
  .rst_i             (wb_rst_i),
  .pixel_alpha_i     (clip_fragment_a),
  .x_counter_i       (clip_fragment_x_pixel),
  .y_counter_i       (clip_fragment_y_pixel),
  .z_i               (clip_fragment_z_pixel),
  .u_i               (clip_fragment_u),
  .v_i               (clip_fragment_v),
  .bezier_factor0_i  (clip_fragment_bezier_factor0),
  .bezier_factor1_i  (clip_fragment_bezier_factor1),
  .bezier_inside_i   (inside_reg),
  .ack_i             (blender_fragment_ack),
  .write_i           (clip_fragment_write_enable),
  .curve_write_i     (wbs_fragment_curve_write),
  .pixel_x_o         (fragment_blender_x_pixel),
  .pixel_y_o         (fragment_blender_y_pixel),
  .pixel_z_o         (fragment_blender_z_pixel),
  .pixel_color_i     (clip_fragment_color),
  .pixel_color_o     (fragment_blender_color),
  .pixel_alpha_o     (fragment_blender_alpha),
  .write_o           (fragment_blender_write_enable),
  .ack_o             (fragment_clip_ack),
  .texture_ack_i     (wbmreader_fragment_texture_ack), 
  .texture_data_i    (wbmreader_fragment_texture_data), 
  .texture_addr_o    (fragment_wbmreader_texture_addr), 
  .texture_sel_o     (fragment_wbmreader_texture_sel), 
  .texture_request_o (fragment_wbmreader_texture_request),
  .texture_enable_i  (texture_enable_reg),
  .tex0_base_i       (wbs_fragment_tex0_base), 
  .tex0_size_x_i     (wbs_fragment_tex0_size_x), 
  .tex0_size_y_i     (wbs_fragment_tex0_size_y),
  .color_depth_i     (color_depth_reg),
  .colorkey_enable_i (colorkey_enable_reg),
  .colorkey_i        (colorkey_reg)
  );

defparam fp0.point_width = point_width;

wire                   blender_render_write_enable;
wire [point_width-1:0] blender_render_x_pixel;
wire [point_width-1:0] blender_render_y_pixel;
wire signed [point_width-1:0] blender_render_z_pixel;
wire                   render_blender_ack;
wire            [31:0] blender_render_color;

// Connected through arbiter
wire        wbmreader_blender_target_ack;
wire [31:2] blender_wbmreader_target_addr;
wire [31:0] wbmreader_blender_target_data;
wire  [3:0] blender_wbmreader_target_sel;
wire        blender_wbmreader_target_request;

// Applies alpha blending if enabled (requires RAM read to get target pixel color)
// Fragment processor generates color of pixel (requires RAM read for textures)
gfx_blender blender0 (
  .clk_i            (wb_clk_i),
  .rst_i            (wb_rst_i),
  .blending_enable_i (blending_enable_reg),
  // Render target information
  .target_base_i    (target_base_reg),
  .target_size_x_i  (target_size_x_reg),
  .target_size_y_i  (target_size_y_reg),
  .color_depth_i    (color_depth_reg),
  .x_counter_i      (fragment_blender_x_pixel),
  .y_counter_i      (fragment_blender_y_pixel),
  .z_i              (fragment_blender_z_pixel),
  .alpha_i          (fragment_blender_alpha),
  .global_alpha_i   (global_alpha_reg),
  .ack_i            (render_blender_ack),
  .target_ack_i     (wbmreader_blender_target_ack),
  .target_addr_o    (blender_wbmreader_target_addr),
  .target_data_i    (wbmreader_blender_target_data),
  .target_sel_o     (blender_wbmreader_target_sel),
  .target_request_o (blender_wbmreader_target_request),
  .wbm_busy_i       (wbmreader_busy),
  .write_i          (fragment_blender_write_enable),
  .pixel_x_o        (blender_render_x_pixel),
  .pixel_y_o        (blender_render_y_pixel),
  .pixel_z_o        (blender_render_z_pixel),
  .pixel_color_i    (fragment_blender_color),
  .pixel_color_o    (blender_render_color),
  .write_o          (blender_render_write_enable),
  .ack_o            (blender_fragment_ack)
  );

defparam blender0.point_width = point_width;

// Write pixel to target (check for out of bounds)
gfx_renderer renderer (
  .clk_i           (wb_clk_i),
  .rst_i           (wb_rst_i),
  // Render target information
  .target_base_i   (target_base_reg),
  .zbuffer_base_i  (zbuffer_base_reg),
  .target_size_x_i (target_size_x_reg),
  .target_size_y_i (target_size_y_reg),
  .color_depth_i   (color_depth_reg),
  // Input pixel
  .pixel_x_i       (blender_render_x_pixel),
  .pixel_y_i       (blender_render_y_pixel),
  .pixel_z_i       (blender_render_z_pixel),
  .zbuffer_enable_i(zbuffer_enable_reg),
  .color_i         (blender_render_color),

  .render_addr_o   (render_wbmwriter_addr),
  .render_sel_o    (render_wbmwriter_sel),
  .render_dat_o    (render_wbmwriter_dat),
  .ack_o           (render_blender_ack),
  .ack_i           (wbmwriter_render_ack),
  .write_i         (blender_render_write_enable),
  .write_o         (render_wbmwriter_memory_pixel_write)
  );

defparam renderer.point_width = point_width;

// Instansiate wishbone master interface (write only)
gfx_wbm_write wbm_writer (
  .clk_i           (wb_clk_i),
  .rst_i           (wb_rst_i),
  .cyc_o           (wbm_write_cyc_o),
  .stb_o           (wbm_write_stb_o),
  .cti_o           (wbm_write_cti_o),
  .bte_o           (wbm_write_bte_o),
  .we_o            (wbm_write_we_o),
  .adr_o           (wbm_write_adr_o),
  .sel_o           (wbm_write_sel_o),
  .ack_i           (wbm_write_ack_i),
  .err_i           (wbm_write_err_i),
  .dat_o           (wbm_write_dat_o),
  .sint_o          (wbmwriter_sint),

  .write_i         (render_wbmwriter_memory_pixel_write),
  .ack_o           (wbmwriter_render_ack),

  // send ack to renderer when done writing to memory.
  .render_addr_i   (render_wbmwriter_addr),
  .render_sel_i    (render_wbmwriter_sel),
  .render_dat_i    (render_wbmwriter_dat)
  );

wire        wbmreader_arbiter_ack;
wire [31:2] arbiter_wbmreader_addr;
wire [31:0] wbmreader_arbiter_data;
wire  [3:0] arbiter_wbmreader_sel;
wire        arbiter_wbmreader_request;

// Instansiate wbm reader arbiter
gfx_wbm_read_arbiter wbm_arbiter (
  .master_busy_o     (wbmreader_busy),
  // Interface against the wbm read module
  .read_request_o    (arbiter_wbmreader_request),
  .addr_o            (arbiter_wbmreader_addr),
  .sel_o             (arbiter_wbmreader_sel),
  .dat_i             (wbmreader_arbiter_data),
  .ack_i             (wbmreader_arbiter_ack),
  // Interface against masters (clip)
  .m0_read_request_i (clip_wbmreader_z_request),
  .m0_addr_i         (clip_wbmreader_z_addr),
  .m0_sel_i          (clip_wbmreader_z_sel),
  .m0_dat_o          (wbmreader_clip_z_data),
  .m0_ack_o          (wbmreader_clip_z_ack),
  // Interface against masters (fragment processor)
  .m1_read_request_i (fragment_wbmreader_texture_request),
  .m1_addr_i         (fragment_wbmreader_texture_addr),
  .m1_sel_i          (fragment_wbmreader_texture_sel),
  .m1_dat_o          (wbmreader_fragment_texture_data),
  .m1_ack_o          (wbmreader_fragment_texture_ack),
  // Interface against masters (blender)
  .m2_read_request_i (blender_wbmreader_target_request),
  .m2_addr_i         (blender_wbmreader_target_addr),
  .m2_sel_i          (blender_wbmreader_target_sel),
  .m2_dat_o          (wbmreader_blender_target_data),
  .m2_ack_o          (wbmreader_blender_target_ack)
  );

// Instansiate wishbone master interface (read only for textures)
gfx_wbm_read wbm_reader (
  .clk_i            (wb_clk_i),
  .rst_i            (wb_rst_i),
  .cyc_o            (wbm_read_cyc_o),
  .stb_o            (wbm_read_stb_o),
  .cti_o            (wbm_read_cti_o),
  .bte_o            (wbm_read_bte_o),
  .we_o             (wbm_read_we_o),
  .adr_o            (wbm_read_adr_o),
  .sel_o            (wbm_read_sel_o),
  .ack_i            (wbm_read_ack_i),
  .err_i            (wbm_read_err_i),
  .dat_i            (wbm_read_dat_i),
  .sint_o           (wbmreader_sint),

  // send ack to renderer when done writing to memory.
  .read_request_i   (arbiter_wbmreader_request),
  .texture_addr_i   (arbiter_wbmreader_addr),
  .texture_sel_i    (arbiter_wbmreader_sel),
  .texture_dat_o    (wbmreader_arbiter_data),
  .texture_data_ack (wbmreader_arbiter_ack)
  );

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/basic_fifo.v
// -----------------------------------------------------------------------------
/* 
 Basic fifo
 Copyright 2005, Timothy Miller
 
 Updated 2012 by Per Lenander & Anton Fosselius (ORSoC)
      - basic fifo is no longer of a fixed depth  

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

module basic_fifo(
  clk_i,
  rst_i,

  data_i,
  enq_i,
  full_o,
  count_o,

  data_o,
  valid_o,
  deq_i
);

parameter fifo_width     = 32;
parameter fifo_bit_depth = 6;

input clk_i, rst_i;

input        [fifo_width-1:0] data_i;
input                         enq_i;
output                        full_o;
output reg [fifo_bit_depth:0] count_o;

output reg [fifo_width-1:0] data_o;
output reg                  valid_o;
input                       deq_i;



reg   [fifo_width-1:0] fifo_data [2**(fifo_bit_depth)-1:0];
reg [fifo_bit_depth:0] fifo_head, fifo_tail;
reg [fifo_bit_depth:0] next_tail;


// accept input
wire next_full = fifo_head[fifo_bit_depth-1:0] == next_tail[fifo_bit_depth-1:0] &&
                 fifo_head[fifo_bit_depth]     != next_tail[fifo_bit_depth];
always @(posedge clk_i or posedge rst_i)
  if (rst_i)
  begin
    fifo_tail <= 1'b0;
    next_tail <= 1'b1;
  end
  else if (!next_full && enq_i)
  begin
     // We can only enqueue when not full
     fifo_data[fifo_tail[fifo_bit_depth-1:0]] <= data_i;
     next_tail <= next_tail + 1'b1;
     fifo_tail <= next_tail;
   end

assign full_o = next_full;

always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    count_o <= 1'b0;
  else if(enq_i & ~deq_i & ~next_full)
    count_o <= count_o + 1'b1;
  else if(~enq_i & deq_i & valid_o)
    count_o <= count_o - 1'b1;

// provide output
wire is_empty = (fifo_head == fifo_tail);
always @(posedge clk_i or posedge rst_i)
  if (rst_i) begin
    valid_o <= 1'b0;
    fifo_head <= 1'b0;
  end 
  else
  begin        
    if (!is_empty)
    begin
      if (!valid_o || deq_i)
        fifo_head <= fifo_head + 1'b1;

      valid_o <= 1'b1;
    end
    else if (deq_i)
      valid_o <= 1'b0;
  end

always @(posedge clk_i)
    // If no valid out or we're dequeueing, we want to grab
    // the next data.  If we're empty, we don't get valid_o,
    // so we don't care if it's garbage.
  if (!valid_o || deq_i)
    data_o <= fifo_data[fifo_head[fifo_bit_depth-1:0]];

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/div_uu.v
// -----------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Non-restoring unsigned divider                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: div_uu.v,v 1.3 2003-09-17 13:08:53 rherveille Exp $
//
//  $Date: 2003-09-17 13:08:53 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/10/31 13:54:58  rherveille
//               Fixed a bug in the remainder output of div_su.v
//
//               Revision 1.1.1.1  2002/10/29 20:29:10  rherveille
//
//
//

//synopsys translate_off
`include "timescale.v"
//synopsys translate_on

module div_uu(clk, ena, z, d, q, s, div0, ovf);

	//
	// parameters
	//
	parameter z_width = 16;
	parameter d_width = z_width /2;
	
	//
	// inputs & outputs
	//
	input clk;               // system clock
	input ena;               // clock enable

	input  [z_width -1:0] z; // divident
	input  [d_width -1:0] d; // divisor
	output [d_width -1:0] q; // quotient
	output [d_width -1:0] s; // remainder
	output div0;
	output ovf;
	reg [d_width-1:0] q;
	reg [d_width-1:0] s;
	reg div0;
	reg ovf;

	//	
	// functions
	//
	function [z_width:0] gen_s;
		input [z_width:0] si;
		input [z_width:0] di;
	begin
	  if(si[z_width])
	    gen_s = {si[z_width-1:0], 1'b0} + di;
	  else
	    gen_s = {si[z_width-1:0], 1'b0} - di;
	end
	endfunction

	function [d_width-1:0] gen_q;
		input [d_width-1:0] qi;
		input [z_width:0] si;
	begin
	  gen_q = {qi[d_width-2:0], ~si[z_width]};
	end
	endfunction

	function [d_width-1:0] assign_s;
		input [z_width:0] si;
		input [z_width:0] di;
		reg [z_width:0] tmp;
	begin
	  if(si[z_width])
	    tmp = si + di;
	  else
	    tmp = si;

	  assign_s = tmp[z_width-1:z_width-d_width];
	end
	endfunction

	//
	// variables
	//
	reg [d_width-1:0] q_pipe  [d_width-1:0];
	reg [z_width:0] s_pipe  [d_width:0];
	reg [z_width:0] d_pipe  [d_width:0];

	reg [d_width:0] div0_pipe, ovf_pipe;
	//
	// perform parameter checks
	//
	// synopsys translate_off
	initial
	begin
	  if(d_width !== z_width / 2)
	    $display("div.v parameter error (d_width != z_width/2).");
	end
	// synopsys translate_on

	integer n0, n1, n2, n3;

	// generate divisor (d) pipe
	always @(d)
	  d_pipe[0] <= {1'b0, d, {(z_width-d_width){1'b0}} };

	always @(posedge clk)
	  if(ena)
	    for(n0=1; n0 <= d_width; n0=n0+1)
	       d_pipe[n0] <= #1 d_pipe[n0-1];

	// generate internal remainder pipe
	always @(z)
	  s_pipe[0] <= z;

	always @(posedge clk)
	  if(ena)
	    for(n1=1; n1 <= d_width; n1=n1+1)
	       s_pipe[n1] <= #1 gen_s(s_pipe[n1-1], d_pipe[n1-1]);

	// generate quotient pipe
	always @(posedge clk)
	  q_pipe[0] <= #1 0;

	always @(posedge clk)
	  if(ena)
	    for(n2=1; n2 < d_width; n2=n2+1)
	       q_pipe[n2] <= #1 gen_q(q_pipe[n2-1], s_pipe[n2]);


	// flags (divide_by_zero, overflow)
	always @(z or d)
	begin
	  ovf_pipe[0]  <= !(z[z_width-1:d_width] < d);
	  div0_pipe[0] <= ~|d;
	end

	always @(posedge clk)
	  if(ena)
	    for(n3=1; n3 <= d_width; n3=n3+1)
	    begin
	        ovf_pipe[n3] <= #1 ovf_pipe[n3-1];
	        div0_pipe[n3] <= #1 div0_pipe[n3-1];
	    end

	// assign outputs
	always @(posedge clk)
	  if(ena)
	    ovf <= #1 ovf_pipe[d_width];

	always @(posedge clk)
	  if(ena)
	    div0 <= #1 div0_pipe[d_width];

	always @(posedge clk)
	  if(ena)
	    q <= #1 gen_q(q_pipe[d_width-1], s_pipe[d_width]);

	always @(posedge clk)
	  if(ena)
	    s <= #1 assign_s(s_pipe[d_width], d_pipe[d_width]);
endmodule




// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_blender.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

PER-PIXEL COLORING MODULE, alpha blending


 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module performs alpha blending by fetching the pixel from the target and mixing it with the texel based on the current alpha value.

The exact formula is:
alpha = global_alpha_i * alpha_i
color_out = color_in * alpha + color_target * (1-alpha)       , where alpha is defined from 0 to 1 

alpha_i[7:0] is used, so the actual span is 0 (transparent) to 255 (opaque)

If alpha blending is disabled (blending_enable_i == 1'b0) the module just passes on the input pixel.
*/
module gfx_blender(clk_i, rst_i,
  blending_enable_i, target_base_i, target_size_x_i, target_size_y_i, color_depth_i,
  x_counter_i, y_counter_i, z_i, alpha_i, global_alpha_i, write_i, ack_o,                      // from fragment
  target_ack_i, target_addr_o, target_data_i, target_sel_o, target_request_o, wbm_busy_i, // from/to wbm reader
  pixel_x_o, pixel_y_o, pixel_z_o, pixel_color_i, pixel_color_o, write_o, ack_i                      // to render
  );

parameter point_width = 16;

input                   clk_i;
input                   rst_i;

input                   blending_enable_i;
input            [31:2] target_base_i;
input [point_width-1:0] target_size_x_i;
input [point_width-1:0] target_size_y_i;
input             [1:0] color_depth_i;

// from fragment
input [point_width-1:0] x_counter_i;
input [point_width-1:0] y_counter_i;
input signed [point_width-1:0] z_i;
input             [7:0] alpha_i;
input             [7:0] global_alpha_i;
input            [31:0] pixel_color_i;
input                   write_i;
output reg              ack_o;

// Interface against wishbone master (reader)
input             target_ack_i;
output     [31:2] target_addr_o;
input      [31:0] target_data_i;
output reg  [3:0] target_sel_o;
output reg        target_request_o;
input             wbm_busy_i;

//to render
output reg [point_width-1:0] pixel_x_o;
output reg [point_width-1:0] pixel_y_o;
output reg signed [point_width-1:0] pixel_z_o;
output reg            [31:0] pixel_color_o;
output reg                   write_o;
input                        ack_i;

// State machine
reg [1:0] state;
parameter wait_state = 2'b00,
          target_read_state = 2'b01,
          write_pixel_state = 2'b10;

// Calculate alpha
reg [15:0] combined_alpha_reg;
wire [7:0] alpha = combined_alpha_reg[15:8];

// Calculate address of target pixel
// Addr[31:2] = Base + (Y*width + X) * ppb
wire [31:0] pixel_offset;
assign pixel_offset = (color_depth_i == 2'b00) ? (target_size_x_i*y_counter_i + {16'h0, x_counter_i})      : // 8  bit
                      (color_depth_i == 2'b01) ? (target_size_x_i*y_counter_i + {16'h0, x_counter_i}) << 1 : // 16 bit
                      (target_size_x_i*y_counter_i + {16'h0, x_counter_i})                            << 2 ; // 32 bit

assign target_addr_o = target_base_i + pixel_offset[31:2];

// Split colors for alpha blending (render color)
wire [7:0] blend_color_r = (color_depth_i == 2'b00) ? pixel_color_i[7:0] :
                           (color_depth_i == 2'b01) ? pixel_color_i[15:11] :
                           pixel_color_i[23:16];
wire [7:0] blend_color_g = (color_depth_i == 2'b00) ? pixel_color_i[7:0] :
                           (color_depth_i == 2'b01) ? pixel_color_i[10:5] :
                           pixel_color_i[15:8];
wire [7:0] blend_color_b = (color_depth_i == 2'b00) ? pixel_color_i[7:0] :
                           (color_depth_i == 2'b01) ? pixel_color_i[4:0] :
                           pixel_color_i[7:0];

// Split colors for alpha blending (from target surface)
wire [7:0] target_color_r = (color_depth_i == 2'b00) ? dest_color[7:0] :
                            (color_depth_i == 2'b01) ? dest_color[15:11] :
                            target_data_i[23:16];
wire [7:0] target_color_g = (color_depth_i == 2'b00) ? dest_color[7:0] :
                            (color_depth_i == 2'b01) ? dest_color[10:5] :
                            target_data_i[15:8];
wire [7:0] target_color_b = (color_depth_i == 2'b00) ? dest_color[7:0] :
                            (color_depth_i == 2'b01) ? dest_color[4:0] :
                            target_data_i[7:0];

// Alpha blending (per color channel):
// rgb = (alpha1)(rgb1) + (1-alpha1)(rgb2)
wire [15:0] alpha_color_r = blend_color_r * alpha + target_color_r * (8'hff - alpha);
wire [15:0] alpha_color_g = blend_color_g * alpha + target_color_g * (8'hff - alpha);
wire [15:0] alpha_color_b = blend_color_b * alpha + target_color_b * (8'hff - alpha);

wire [31:0] dest_color;
// Memory to color converter
memory_to_color memory_proc(
.color_depth_i (color_depth_i),
.mem_i (target_data_i),
.mem_lsb_i (x_counter_i[1:0]),
.color_o (dest_color),
.sel_o ()
);

// Acknowledge when a command has completed
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
  begin
    ack_o            <= 1'b0;
    write_o          <= 1'b0;
    pixel_x_o        <= 1'b0;
    pixel_y_o        <= 1'b0;
    pixel_z_o        <= 1'b0;
    pixel_color_o    <= 1'b0;
    target_request_o <= 1'b0;
    target_sel_o     <= 4'b1111;
  end
  // Else, set outputs for next cycle
  else
  begin
    case (state)

      wait_state:
      begin
        ack_o <= 1'b0;

        if(write_i)
        begin
          if(!blending_enable_i)
          begin
            pixel_x_o     <= x_counter_i;
            pixel_y_o     <= y_counter_i;
            pixel_z_o     <= z_i;
            pixel_color_o <= pixel_color_i;
            write_o       <= 1'b1;
          end
          else
          begin
            target_request_o   <= !wbm_busy_i;
            combined_alpha_reg <= alpha_i * global_alpha_i;
          end
        end
      end

      // Read pixel color at target (request is sent through the wbm reader arbiter).
      target_read_state:
        if(target_ack_i)
        begin
          // When we receive an ack from memory, calculate the combined color and send the pixel forward in the pipeline (go to write state)
          write_o          <= 1'b1;
          pixel_x_o        <= x_counter_i;
          pixel_y_o        <= y_counter_i;
          pixel_z_o        <= z_i;
          target_request_o <= 1'b0;

      	  // Recombine colors
          pixel_color_o    <= (color_depth_i == 2'b00) ? {alpha_color_r[15:8]} : // 8 bit grayscale
                              (color_depth_i == 2'b01) ? {alpha_color_r[12:8], alpha_color_g[13:8], alpha_color_b[12:8]} : // 16 bit
                              {alpha_color_r[15:8], alpha_color_g[15:8], alpha_color_b[15:8]}; // 32 bit
        end
        else
          target_request_o <= !wbm_busy_i | target_request_o;

      // Ack and return to wait state
      write_pixel_state:
      begin
        write_o <= 1'b0;
        if(ack_i)
          ack_o <= 1'b1;    
      end

    endcase
  end
end

// State machine
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
    state <= wait_state;
  // Move in statemachine
  else
    case (state)

      wait_state:
        if(write_i & blending_enable_i)
          state <= target_read_state;
        else if(write_i)
          state <= write_pixel_state;

      target_read_state:
        if(target_ack_i)
          state <= write_pixel_state;

      write_pixel_state:
        if(ack_i)
          state <= wait_state;

    endcase
end

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_clip.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

CLIPPING/SCISSORING MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module performs clipping by applying the current cliprect and the target size.

This module also performs z-buffer culling (requires reading from memory)
*/
module gfx_clip(clk_i, rst_i,
  clipping_enable_i, zbuffer_enable_i,
  zbuffer_base_i, target_size_x_i, target_size_y_i,
  clip_pixel0_x_i, clip_pixel0_y_i, clip_pixel1_x_i, clip_pixel1_y_i,                              //clip pixel 0 and pixel 1
  raster_pixel_x_i, raster_pixel_y_i, raster_u_i, raster_v_i, flat_color_i, raster_write_i, ack_o, // from raster
  cuvz_pixel_x_i, cuvz_pixel_y_i, cuvz_pixel_z_i, cuvz_u_i, cuvz_v_i, cuvz_color_i, cuvz_write_i,  // from cuvz
  cuvz_a_i,                                                                                        // from cuvz
  z_ack_i, z_addr_o, z_data_i, z_sel_o, z_request_o, wbm_busy_i,                                   // from/to wbm reader
  pixel_x_o, pixel_y_o, pixel_z_o, u_o, v_o, a_o,                                                  // to fragment
  bezier_factor0_i, bezier_factor1_i, bezier_factor0_o, bezier_factor1_o,                          // bezier calculations
  color_o, write_o, ack_i                                                                          // from/to fragment
  );

parameter point_width = 16;

input                   clk_i;
input                   rst_i;

input                   clipping_enable_i;
input                   zbuffer_enable_i;
input            [31:2] zbuffer_base_i;
input [point_width-1:0] target_size_x_i;
input [point_width-1:0] target_size_y_i;
//clip pixels
input [point_width-1:0] clip_pixel0_x_i;
input [point_width-1:0] clip_pixel0_y_i;
input [point_width-1:0] clip_pixel1_x_i;
input [point_width-1:0] clip_pixel1_y_i;

// From cuvz
input [point_width-1:0] cuvz_pixel_x_i;
input [point_width-1:0] cuvz_pixel_y_i;
input signed [point_width-1:0] cuvz_pixel_z_i;
input [point_width-1:0] cuvz_u_i;
input [point_width-1:0] cuvz_v_i;
input             [7:0] cuvz_a_i;
input            [31:0] cuvz_color_i;
input                   cuvz_write_i;
// From raster
input [point_width-1:0] raster_pixel_x_i;
input [point_width-1:0] raster_pixel_y_i;
input [point_width-1:0] raster_u_i;
input [point_width-1:0] raster_v_i;
input            [31:0] flat_color_i;
input                   raster_write_i;
output reg              ack_o;

// Interface against wishbone master (reader)
input             z_ack_i;
output     [31:2] z_addr_o;
input      [31:0] z_data_i;
output reg  [3:0] z_sel_o;
output reg        z_request_o;
input             wbm_busy_i;

// To fragment
output reg [point_width-1:0] pixel_x_o;
output reg [point_width-1:0] pixel_y_o;
output reg [point_width-1:0] pixel_z_o;
output reg [point_width-1:0] u_o;
output reg [point_width-1:0] v_o;
output reg             [7:0] a_o;
input      [point_width-1:0] bezier_factor0_i;
input      [point_width-1:0] bezier_factor1_i;
output reg [point_width-1:0] bezier_factor0_o;
output reg [point_width-1:0] bezier_factor1_o;
output reg            [31:0] color_o;
output reg write_o;
input ack_i;

// 

// State machine
reg [1:0] state;
parameter wait_state = 2'b00, z_read_state = 2'b01, write_pixel_state = 2'b10;

// Calculate address of target pixel
// Addr[31:2] = Base + (Y*width + X) * ppb
wire [31:0] pixel_offset = (target_size_x_i*cuvz_pixel_y_i   + {16'h0,   cuvz_pixel_x_i}) << 1; // 16 bit
assign z_addr_o = zbuffer_base_i + pixel_offset[31:2];

wire [31:0] z_value_at_target32;
wire signed [point_width-1:0] z_value_at_target = z_value_at_target32[point_width-1:0];

// Memory to color converter
memory_to_color memory_proc(
.color_depth_i (2'b01),
.mem_i         (z_data_i),
.mem_lsb_i     (cuvz_pixel_x_i[1:0]),
.color_o       (z_value_at_target32),
.sel_o         ()
);

// Forward texture coordinates, color, alpha etc
always @(posedge clk_i or posedge rst_i)
if(rst_i)
begin
  u_o              <= 1'b0;
  v_o              <= 1'b0;
  bezier_factor0_o <= 1'b0;
  bezier_factor1_o <= 1'b0;
  pixel_x_o        <= 1'b0;
  pixel_y_o        <= 1'b0;
  pixel_z_o        <= 1'b0;
  color_o          <= 1'b0;
  a_o              <= 1'b0;
  z_sel_o          <= 4'b1111;
end
else
begin
  // Implement a MUX, send data from either the raster or from the cuvz module to the fragment processor
  if(raster_write_i)
  begin
    u_o              <= raster_u_i;
    v_o              <= raster_v_i;
    a_o              <= 8'hff;
    color_o          <= flat_color_i;
    pixel_x_o        <= raster_pixel_x_i;
    pixel_y_o        <= raster_pixel_y_i;
    pixel_z_o        <= 1'b0;
  end
  // If the cuvz module is being used, more parameters needs to be forwarded
  else if(cuvz_write_i)
  begin
    u_o              <= cuvz_u_i;
    v_o              <= cuvz_v_i;
    a_o              <= cuvz_a_i;
    color_o          <= cuvz_color_i;
    pixel_x_o        <= cuvz_pixel_x_i;
    pixel_y_o        <= cuvz_pixel_y_i;
    pixel_z_o        <= cuvz_pixel_z_i;
    bezier_factor0_o <= bezier_factor0_i;
    bezier_factor1_o <= bezier_factor1_i;
  end
end

// Check if we should discard this pixel due to failing depth check
wire fail_z_check   = z_value_at_target > cuvz_pixel_z_i;

// Check if we should discard this pixel due to falling outside render target/clip rect
wire outside_target = raster_write_i ? (raster_pixel_x_i >= target_size_x_i) | (raster_pixel_y_i >= target_size_y_i) :
                      (cuvz_pixel_x_i >= target_size_x_i) | (cuvz_pixel_y_i >= target_size_y_i);
wire outside_clip   = raster_write_i ? (raster_pixel_x_i < clip_pixel0_x_i) | (raster_pixel_y_i < clip_pixel0_y_i) | (raster_pixel_x_i >= clip_pixel1_x_i) | (raster_pixel_y_i >= clip_pixel1_y_i) :
                      (cuvz_pixel_x_i < clip_pixel0_x_i) | (cuvz_pixel_y_i < clip_pixel0_y_i) | (cuvz_pixel_x_i >= clip_pixel1_x_i) | (cuvz_pixel_y_i >= clip_pixel1_y_i);
wire discard_pixel  = outside_target | (clipping_enable_i & outside_clip);

// Check if there is a write signal
wire write_i        = raster_write_i | cuvz_write_i;

// Acknowledge when a command has completed
always @(posedge clk_i or posedge rst_i)
// reset, init component
if(rst_i)
begin
  ack_o            <= 1'b0;
  write_o          <= 1'b0;
  z_request_o      <= 1'b0;
  z_sel_o          <= 4'b1111;
end
// Else, set outputs for next cycle
else
begin
  case (state)

    wait_state:
    begin
      if(write_i)
        ack_o         <= discard_pixel;
      else
        ack_o         <= 1'b0;

      if(write_i & zbuffer_enable_i)
        z_request_o   <= ~discard_pixel;
      else if(write_i)
        write_o       <= ~discard_pixel;
        
    end

    // Do a depth check. If it fails, discard pixel, ack and go back to wait. If it succeeds, go to write state
    z_read_state:
      if(z_ack_i)
      begin
        write_o     <= ~fail_z_check;
        ack_o       <= fail_z_check;
        z_request_o <= 1'b0;
      end
      else
        z_request_o <= ~wbm_busy_i | z_request_o;

    // ack, then go back to wait state when the next module is ready
    write_pixel_state:
    begin
      write_o <= 1'b0;
      if(ack_i)
        ack_o <= 1'b1;    
    end

  endcase

end

// State machine
always @(posedge clk_i or posedge rst_i)
// reset, init component
if(rst_i)
  state <= wait_state;
// Move in statemachine
else
  case (state)

    wait_state:
      if(write_i & ~discard_pixel)
      begin
        if(zbuffer_enable_i)
          state <= z_read_state;
        else 
          state <= write_pixel_state;
      end

    z_read_state:
      if(z_ack_i)
        state <= fail_z_check ? wait_state : write_pixel_state;

    write_pixel_state:
      if(ack_i)
        state <= wait_state;

  endcase

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_color.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

Components for aligning colored pixels to memory and the inverse

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

module color_to_memory(color_depth_i, color_i, x_lsb_i,
                       mem_o, sel_o);

input  [1:0]  color_depth_i;
input  [31:0] color_i;
input  [1:0]  x_lsb_i;
output [31:0] mem_o;
output [3:0]  sel_o;

assign sel_o = (color_depth_i == 2'b00) && (x_lsb_i == 2'b00) ? 4'b1000 : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b01) ? 4'b0100 : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b10) ? 4'b0010 : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b11) ? 4'b0001 : // 8-bit
               (color_depth_i == 2'b01) && (x_lsb_i[0] == 1'b0)  ? 4'b1100  : // 16-bit, high word
               (color_depth_i == 2'b01) && (x_lsb_i[0] == 1'b1)  ? 4'b0011  : // 16-bit, low word
               4'b1111; // 32-bit

assign mem_o = (color_depth_i == 2'b00) && (x_lsb_i == 2'b00) ? {color_i[7:0], 24'h000000} : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b01) ? {color_i[7:0], 16'h0000}   : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b10) ? {color_i[7:0], 8'h00}      : // 8-bit
               (color_depth_i == 2'b00) && (x_lsb_i == 2'b11) ? {color_i[7:0]}             : // 8-bit
               (color_depth_i == 2'b01) && (x_lsb_i[0] == 1'b0)  ? {color_i[15:0], 16'h0000}   : // 16-bit, high word
               (color_depth_i == 2'b01) && (x_lsb_i[0] == 1'b1)  ? {color_i[15:0]}             : // 16-bit, low word
               color_i; // 32-bit

endmodule

module memory_to_color(color_depth_i, mem_i, mem_lsb_i,
                       color_o, sel_o);

input  [1:0]  color_depth_i;
input  [31:0] mem_i;
input  [1:0]  mem_lsb_i;
output [31:0] color_o;
output [3:0]  sel_o;

assign sel_o = color_depth_i == 2'b00 ? 4'b0001 : // 8-bit
               color_depth_i == 2'b01 ? 4'b0011 : // 16-bit, low word
               4'b1111; // 32-bit

assign color_o = (color_depth_i == 2'b00) && (mem_lsb_i == 2'b00) ? {mem_i[31:24]} : // 8-bit
                 (color_depth_i == 2'b00) && (mem_lsb_i == 2'b01) ? {mem_i[23:16]} : // 8-bit
                 (color_depth_i == 2'b00) && (mem_lsb_i == 2'b10) ? {mem_i[15:8]}  : // 8-bit
                 (color_depth_i == 2'b00) && (mem_lsb_i == 2'b11) ? {mem_i[7:0]}   : // 8-bit
                 (color_depth_i == 2'b01) && (mem_lsb_i[0] == 1'b0)  ? {mem_i[31:16]} : // 16-bit, high word
                 (color_depth_i == 2'b01) && (mem_lsb_i[0] == 1'b1)  ? {mem_i[15:0]}  : // 16-bit, low word
                 mem_i; // 32-bit

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_cuvz.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

INTERPOLATION MODULE - Color, UV and Z calculator

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module uses the interpolation factors from the divider to calculate color, depth and texture coordinates
*/
module gfx_cuvz(
  clk_i, rst_i,
  ack_i, ack_o,
  write_i,
  // Variables needed for interpolation
  factor0_i, factor1_i,
  // Color
  color0_i, color1_i, color2_i, color_depth_i,
  color_o,
  // Depth
  z0_i, z1_i, z2_i,
  z_o,
  // Texture coordinates
  u0_i, v0_i, u1_i, v1_i, u2_i, v2_i,
  u_o, v_o,
  // Alpha
  a0_i, a1_i, a2_i,
  a_o,
  // Bezier shape calculation
  bezier_factor0_o, bezier_factor1_o,
  // Raster position
  x_i, y_i, x_o, y_o,

  write_o
  );

parameter point_width = 16;

input                        clk_i;
input                        rst_i;

input                        ack_i;
output reg                   ack_o;

input                        write_i;

// Input barycentric coordinates used to interpolate values
input      [point_width-1:0] factor0_i;
input      [point_width-1:0] factor1_i;

// Color for each point
input                 [31:0] color0_i;
input                 [31:0] color1_i;
input                 [31:0] color2_i;
input                  [1:0] color_depth_i;
// Interpolated color
output reg            [31:0] color_o;

// Depth for each point
input signed [point_width-1:0] z0_i;
input signed [point_width-1:0] z1_i;
input signed [point_width-1:0] z2_i;
// Interpolated depth
output reg signed [point_width-1:0] z_o;

// Alpha for each point
input      [7:0] a0_i;
input      [7:0] a1_i;
input      [7:0] a2_i;
// Interpolated alpha
output reg [7:0] a_o;

// Texture coordinates for each point
input      [point_width-1:0] u0_i;
input      [point_width-1:0] u1_i;
input      [point_width-1:0] u2_i;
input      [point_width-1:0] v0_i;
input      [point_width-1:0] v1_i;
input      [point_width-1:0] v2_i;
// Interpolated texture coordinates
output reg [point_width-1:0] u_o;
output reg [point_width-1:0] v_o;

// Bezier factors, used to draw bezier shapes
output reg [point_width-1:0] bezier_factor0_o;
output reg [point_width-1:0] bezier_factor1_o;

// Input and output pixel coordinate (passed on)
input      [point_width-1:0] x_i;
input      [point_width-1:0] y_i;
output reg [point_width-1:0] x_o;
output reg [point_width-1:0] y_o;

// Write pixel output signal
output reg                   write_o;

// Holds the barycentric coordinates for interpolation
reg        [point_width:0] factor0;
reg        [point_width:0] factor1;
reg        [point_width:0] factor2;

// State machine
reg [1:0] state;
parameter wait_state   = 2'b00,
          prep_state   = 2'b01,
          write_state  = 2'b10;

// Manage states
always @(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case (state)

    wait_state:
      if(write_i)
        state <= prep_state;

    prep_state:
      state <= write_state;

    write_state:
      if(ack_i)
        state <= wait_state;

  endcase

// Interpolate texture coordinates, depth and alpha
wire [point_width*2-1:0] u = factor0 * u0_i + factor1 * u1_i + factor2 * u2_i;
wire [point_width*2-1:0] v = factor0 * v0_i + factor1 * v1_i + factor2 * v2_i;
wire [point_width+8-1:0] a = factor0 * a0_i + factor1 * a1_i + factor2 * a2_i;

// Note: special case here since z is signed. To prevent incorrect multiplication, factor is treated as a signed value (with a 0 added in front)
wire signed [point_width*2-1:0] z = $signed({1'b0, factor0}) * z0_i + $signed({1'b0, factor1}) * z1_i + $signed({1'b0, factor2}) * z2_i;

// REF: Loop & Blinn, for rendering quadratic bezier shapes
wire [point_width-1:0] bezier_factor0 = (factor1/2) + factor2;
wire [point_width-1:0] bezier_factor1 = factor2;

// ***************** //
// Interpolate color //
// ***************** //

// Split colors
wire [7:0] color0_r = (color_depth_i == 2'b00) ? color0_i[7:0] :
                      (color_depth_i == 2'b01) ? color0_i[15:11] :
                      color0_i[23:16];
wire [7:0] color0_g = (color_depth_i == 2'b00) ? color0_i[7:0] :
                      (color_depth_i == 2'b01) ? color0_i[10:5] :
                      color0_i[15:8];
wire [7:0] color0_b = (color_depth_i == 2'b00) ? color0_i[7:0] :
                      (color_depth_i == 2'b01) ? color0_i[4:0] :
                      color0_i[7:0];

// Split colors
wire [7:0] color1_r = (color_depth_i == 2'b00) ? color1_i[7:0] :
                      (color_depth_i == 2'b01) ? color1_i[15:11] :
                      color1_i[23:16];
wire [7:0] color1_g = (color_depth_i == 2'b00) ? color1_i[7:0] :
                      (color_depth_i == 2'b01) ? color1_i[10:5] :
                      color1_i[15:8];
wire [7:0] color1_b = (color_depth_i == 2'b00) ? color1_i[7:0] :
                      (color_depth_i == 2'b01) ? color1_i[4:0] :
                      color1_i[7:0];

// Split colors
wire [7:0] color2_r = (color_depth_i == 2'b00) ? color2_i[7:0] :
                      (color_depth_i == 2'b01) ? color2_i[15:11] :
                      color2_i[23:16];
wire [7:0] color2_g = (color_depth_i == 2'b00) ? color2_i[7:0] :
                      (color_depth_i == 2'b01) ? color2_i[10:5] :
                      color2_i[15:8];
wire [7:0] color2_b = (color_depth_i == 2'b00) ? color2_i[7:0] :
                      (color_depth_i == 2'b01) ? color2_i[4:0] :
                      color2_i[7:0];

// Interpolation
wire [8+point_width-1:0] color_r = factor0*color0_r +  factor1*color1_r +  factor2*color2_r;
wire [8+point_width-1:0] color_g = factor0*color0_g +  factor1*color1_g +  factor2*color2_g;
wire [8+point_width-1:0] color_b = factor0*color0_b +  factor1*color1_b +  factor2*color2_b;

always @(posedge clk_i or posedge rst_i)
begin
  // Reset
  if(rst_i)
  begin
    ack_o       <= 1'b0;
    write_o     <= 1'b0;
    x_o         <= 1'b0;
    y_o         <= 1'b0;
    color_o     <= 1'b0;
    z_o         <= 1'b0;
    u_o         <= 1'b0;
    v_o         <= 1'b0;
    a_o         <= 1'b0;
    factor0     <= 1'b0;
    factor1     <= 1'b0;
    factor2     <= 1'b0;
  end
  else
    case (state)

      wait_state:
      begin
        ack_o     <= 1'b0;
        if(write_i)
        begin
          x_o     <= x_i;
          y_o     <= y_i;
          factor0 <= factor0_i;
          factor1 <= factor1_i;
          factor2 <= (factor0_i + factor1_i >= (1 << point_width)) ? 1'b0 : (1 << point_width) - factor0_i - factor1_i;
        end
      end

      prep_state:
      begin
        // Assign outputs
        // --------------
        write_o <= 1'b1;
        // Texture coordinates
        u_o     <= u[point_width*2-1:point_width];
        v_o     <= v[point_width*2-1:point_width];
        // Bezier calculations
        bezier_factor0_o <= bezier_factor0;
        bezier_factor1_o <= bezier_factor1;
        // Depth
        z_o     <= z[point_width*2-1:point_width];
        // Alpha
        a_o     <= a[point_width+8-1:point_width];
        // Color
        color_o <= (color_depth_i == 2'b00) ? {color_r[8+point_width-1:point_width]} : // 8 bit grayscale
                   (color_depth_i == 2'b01) ? {color_r[5+point_width-1:point_width], color_g[6+point_width-1:point_width], color_b[5+point_width-1:point_width]} : // 16 bit
                   {color_r[8+point_width-1:point_width], color_g[8+point_width-1:point_width], color_b[8+point_width-1:point_width]}; // 32 bit
      end

      write_state:
      begin
        write_o   <= 1'b0;
        if(ack_i)
          ack_o   <= 1'b1;
      end
    endcase
   
end

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_fragment_processor.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

PER-PIXEL COLORING MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module adds color to the pixel generated by the rasterizer. It can either draw a flat color (using pixel_color_i) or
colors from a texture by using the u and v coordinates generated by the rasterizer. 
*/
module gfx_fragment_processor(clk_i, rst_i,
  pixel_alpha_i,
  x_counter_i, y_counter_i, z_i, u_i, v_i, bezier_factor0_i, bezier_factor1_i, bezier_inside_i, write_i, curve_write_i, ack_o, // from raster
  pixel_x_o, pixel_y_o, pixel_z_o, pixel_color_i, pixel_color_o, pixel_alpha_o, write_o, ack_i,  // to blender
  texture_ack_i, texture_data_i, texture_addr_o, texture_sel_o, texture_request_o, // to/from wishbone master read
  texture_enable_i, tex0_base_i, tex0_size_x_i, tex0_size_y_i, color_depth_i, colorkey_enable_i, colorkey_i // from wishbone slave
  );

parameter point_width = 16;

input clk_i;
input rst_i;

input [7:0]  pixel_alpha_i;

// from raster
input [point_width-1:0] x_counter_i;
input [point_width-1:0] y_counter_i;
input signed [point_width-1:0] z_i;
input [point_width-1:0] u_i; // x-ish texture coordinate
input [point_width-1:0] v_i; // y-ish texture coordinate
input [point_width-1:0] bezier_factor0_i; // Used for curve writing
input [point_width-1:0] bezier_factor1_i; // Used for curve writing
input                   bezier_inside_i;
input            [31:0] pixel_color_i;
input                   write_i;
input                   curve_write_i;
output reg              ack_o;

//to render
output reg [point_width-1:0] pixel_x_o;
output reg [point_width-1:0] pixel_y_o;
output reg signed [point_width-1:0] pixel_z_o;
output reg            [31:0] pixel_color_o;
output reg             [7:0] pixel_alpha_o;
output reg                   write_o;
input                        ack_i;

// to/from wishbone master read
input              texture_ack_i;
input       [31:0] texture_data_i;
output      [31:2] texture_addr_o;
output reg  [ 3:0] texture_sel_o;
output reg         texture_request_o;

// from wishbone slave
input                   texture_enable_i;
input            [31:2] tex0_base_i;
input [point_width-1:0] tex0_size_x_i;
input [point_width-1:0] tex0_size_y_i;
input            [ 1:0] color_depth_i;
input                   colorkey_enable_i;
input            [31:0] colorkey_i;

wire             [31:0] pixel_offset;

// Calculate the memory address of the texel to read 
assign pixel_offset = (color_depth_i == 2'b00) ? (tex0_size_x_i*v_i + {16'h0, u_i})      : // 8  bit
                      (color_depth_i == 2'b01) ? (tex0_size_x_i*v_i + {16'h0, u_i}) << 1 : // 16 bit
                      (tex0_size_x_i*v_i + {16'h0, u_i})                            << 2 ; // 32 bit
assign texture_addr_o = tex0_base_i + pixel_offset[31:2];

// State machine
reg [1:0] state;
parameter wait_state = 2'b00, texture_read_state = 2'b01, write_pixel_state = 2'b10;

wire [31:0] mem_conv_color_o;

// Color converter
memory_to_color color_proc(
.color_depth_i (color_depth_i),
.mem_i         (texture_data_i),
.mem_lsb_i     (u_i[1:0]),
.color_o       (mem_conv_color_o),
.sel_o         ()
);

// Does the fetched texel match the colorkey?
wire transparent_pixel = (color_depth_i == 2'b00) ? (mem_conv_color_o[7:0]  == colorkey_i[7:0])  : // 8  bit
                         (color_depth_i == 2'b01) ? (mem_conv_color_o[15:0] == colorkey_i[15:0]) : // 16 bit
                         (mem_conv_color_o == colorkey_i);                                         // 32 bit

// These variables are used when rendering bezier shapes. If bezier_draw is true, pixel is drawn, if it is false, pixel is discarded.
// These variables are only used if curve_write_i is high

// Calculate if factor0*factor0 > factor1
// Values are in the range [0..1], represented by a [point_width-1:0] bit array
wire [2*point_width-1:0] bezier_factor0_squared = bezier_factor0_i*bezier_factor0_i;
wire bezier_eval = bezier_factor0_squared[2*point_width-1:point_width] > bezier_factor1_i;
wire bezier_draw = bezier_inside_i ^ bezier_eval; // inside xor eval

// Acknowledge when a command has completed
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
  begin
    ack_o             <= 1'b0;
    write_o           <= 1'b0;
    pixel_x_o         <= 1'b0;
    pixel_y_o         <= 1'b0;
    pixel_z_o         <= 1'b0;
    pixel_color_o     <= 1'b0;
    pixel_alpha_o     <= 1'b0;
    texture_request_o <= 1'b0;
    texture_sel_o     <= 4'b1111;
  end
  // Else, set outputs for next cycle
  else
  begin
    case (state)

      wait_state:
      begin
        ack_o   <= write_i & curve_write_i & ~bezier_draw;

        if(write_i & texture_enable_i & (~curve_write_i | bezier_draw))
          texture_request_o <= 1'b1;
        else if(write_i & (~curve_write_i | bezier_draw))
        begin
          pixel_x_o         <= x_counter_i;
          pixel_y_o         <= y_counter_i;
          pixel_z_o         <= z_i;
          pixel_color_o     <= pixel_color_i;
          pixel_alpha_o     <= pixel_alpha_i;
          write_o           <= 1'b1; // Note, colorkey only supported for texture reads
        end
      end


      texture_read_state:
        if(texture_ack_i)
        begin
          pixel_x_o         <= x_counter_i;
          pixel_y_o         <= y_counter_i;
          pixel_z_o         <= z_i;
          pixel_color_o     <= mem_conv_color_o;
          pixel_alpha_o     <= pixel_alpha_i;
          texture_request_o <= 1'b0;
          if(colorkey_enable_i & transparent_pixel)
            ack_o           <= 1'b1; // Colorkey enabled: Only write if the pixel doesn't match the colorkey
          else
            write_o         <= 1'b1;
        end


      write_pixel_state:
      begin
        write_o  <= 1'b0;
        ack_o    <= ack_i;
      end

    endcase
  end
end

// State machine
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
    state <= wait_state;
  // Move in statemachine
  else
    case (state)

      wait_state:
        if(write_i & texture_enable_i & (~curve_write_i | bezier_draw))
          state <= texture_read_state;
        else if(write_i & (~curve_write_i | bezier_draw))
          state <= write_pixel_state;

      texture_read_state:
        // Check for texture ack. If we have colorkeying enabled, only goto the write state if the texture doesn't match the colorkey
        if(texture_ack_i & colorkey_enable_i)
          state <= transparent_pixel ? wait_state : write_pixel_state;
        else if(texture_ack_i)
          state <= write_pixel_state;

      write_pixel_state:
        if(ack_i)
          state <= wait_state;

    endcase
end

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_interp.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

INTERPOLATION MODULE - DIVIDER

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module interpolates by using div_uu division units

One division takes exactly point_width+1 ticks to complete, but many divisions can be pipelined at the same time.
*/
module gfx_interp(clk_i, rst_i,
  ack_i, ack_o,
  write_i,
  // Variables needed for interpolation
  edge0_i, edge1_i, area_i,
  // Raster position
  x_i, y_i, x_o, y_o,

  factor0_o, factor1_o,
  write_o
  );

parameter point_width  = 16;
parameter delay_width  = 5;
parameter div_delay    = point_width+1;
parameter result_width = 4;

input      clk_i;
input      rst_i;

input      ack_i;
output reg ack_o;

input      write_i;

input  [2*point_width-1:0] edge0_i;
input  [2*point_width-1:0] edge1_i;
input  [2*point_width-1:0] area_i;

input  [point_width-1:0] x_i;
input  [point_width-1:0] y_i;
output [point_width-1:0] x_o;
output [point_width-1:0] y_o;

// Generated pixel coordinates
output [point_width-1:0] factor0_o;
output [point_width-1:0] factor1_o;
// Write pixel output signal
output                   write_o;

// calculates factor0
wire   [point_width-1:0] interp0_quotient; // result
wire   [point_width-1:0] interp0_reminder;
wire                     interp0_div_by_zero;
wire                     interp0_overflow;
// calculates factor1
wire   [point_width-1:0] interp1_quotient; // result
wire   [point_width-1:0] interp1_reminder;
wire                     interp1_div_by_zero;
wire                     interp1_overflow;

reg  [delay_width-1:0] phase_counter;

wire                   division_enable;

always @(posedge clk_i or posedge rst_i)
if(rst_i)
  phase_counter <= 1'b0;
else if(division_enable)
  phase_counter <= (phase_counter + 1'b1 == div_delay) ? 1'b0 : phase_counter + 1'b1;

// State machine
reg state;
parameter wait_state   = 1'b0,
          write_state  = 1'b1;

// Manage states
always @(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case (state)

    wait_state:
      if(write_o)
        state <= write_state;

    write_state:
      if(ack_i)
        state <= wait_state;

  endcase

always @(posedge clk_i or posedge rst_i)
begin
  // Reset
  if(rst_i)
    ack_o       <= 1'b0;
  else
    case (state)

      wait_state:
        ack_o   <= 1'b0;

      write_state:
        if(ack_i)
          ack_o <= 1'b1;

    endcase
   
end

wire [point_width-1:0] zeroes = 1'b0;

// division unit 0
	div_uu #(2*point_width) dut0 (
		.clk  (clk_i),
		.ena  (division_enable),
		.z    ({edge0_i[point_width-1:0], zeroes}),
		.d    (area_i[point_width-1:0]),
		.q    (interp0_quotient),
		.s    (interp0_reminder),
		.div0 (interp0_div_by_zero),
		.ovf  (interp0_overflow)
	);
// division unit 1
	div_uu #(2*point_width) dut1 (
		.clk  (clk_i),
		.ena  (division_enable),
		.z    ({edge1_i[point_width-1:0], zeroes}),
		.d    (area_i[point_width-1:0]),
		.q    (interp1_quotient),
		.s    (interp1_reminder),
		.div0 (interp1_div_by_zero),
		.ovf  (interp1_overflow)
	);

wire                  result_full;
wire                  result_valid;
wire [result_width:0] result_count;
wire                  result_deque = result_valid & (state == wait_state);

assign write_o = result_deque;

assign division_enable = ~result_full;

wire                   delay_valid;
wire [delay_width-1:0] delay_phase_counter;
wire                   division_complete = division_enable & delay_valid & (phase_counter == delay_phase_counter);

wire [point_width-1:0] delay_x, delay_y;

// Fifo for finished results
basic_fifo result_fifo(
  .clk_i     ( clk_i ),
  .rst_i     ( rst_i ),

  .data_i    ( {interp0_quotient, interp1_quotient, delay_x, delay_y} ),
  .enq_i     ( division_complete ),
  .full_o    ( result_full ), // TODO: use?
  .count_o   ( result_count ),

  .data_o    ( {factor0_o, factor1_o, x_o, y_o} ),
  .valid_o   ( result_valid ),
  .deq_i     ( result_deque )
);

defparam result_fifo.fifo_width     = 4*point_width;
defparam result_fifo.fifo_bit_depth = result_width;

// Another Fifo for current calculations
basic_fifo queue_fifo(
  .clk_i     ( clk_i ),
  .rst_i     ( rst_i ),

  .data_i    ( {phase_counter, x_i, y_i} ),
  .enq_i     ( write_i ),
  .full_o    ( ), // TODO: use?
  .count_o   ( ),

  .data_o    ( {delay_phase_counter, delay_x, delay_y} ),
  .valid_o   ( delay_valid ),
  .deq_i     ( division_complete )
);

defparam queue_fifo.fifo_width     = delay_width + 2*point_width;
defparam queue_fifo.fifo_bit_depth = delay_width;

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_line.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

Bresenham line algarithm 

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/
// trigger on high

module bresenham_line(clk_i, rst_i,
pixel0_x_i, pixel0_y_i, pixel1_x_i, pixel1_y_i, 
draw_line_i, read_pixel_i, 
busy_o, x_major_o, major_o, minor_o, valid_o
);

parameter point_width = 16;
parameter subpixel_width = 16;

input clk_i;
input rst_i;

input signed [point_width-1:-subpixel_width] pixel0_x_i;
input signed [point_width-1:-subpixel_width] pixel1_x_i;
input signed [point_width-1:-subpixel_width] pixel0_y_i;
input signed [point_width-1:-subpixel_width] pixel1_y_i;

input draw_line_i;
input read_pixel_i;

output reg busy_o;
output reg valid_o;

output reg signed [point_width-1:0] major_o;
output reg signed [point_width-1:0] minor_o;

//line drawing reg & wires
reg [point_width-1:-subpixel_width] xdiff; // dx
reg [point_width-1:-subpixel_width] ydiff; // dy
output reg x_major_o; // if x is the major axis (for each x, y changes less then x)

reg signed [point_width-1:-subpixel_width] left_pixel_x; // this is the left most pixel of the two input pixels
reg signed [point_width-1:-subpixel_width] left_pixel_y; 
reg signed [point_width-1:-subpixel_width] right_pixel_x; // this is the right most pixel of the two input pixels
reg signed [point_width-1:-subpixel_width] right_pixel_y;

reg [point_width-1:-subpixel_width] delta_major; // if x is major this value is xdiff, else ydiff
reg [point_width-1:-subpixel_width] delta_minor; // if x is minor this value is xdiff, else ydiff

reg minor_slope_positive; // true if slope is in first quadrant 

reg  signed          [point_width-1:0] major_goal;
reg  signed [2*point_width-1:-subpixel_width] eps;
wire signed [2*point_width-1:-subpixel_width] eps_delta_minor;
wire done;

// State machine
reg [2:0] state;
parameter wait_state = 0, line_prep_state = 1, line_state = 2, raster_state = 3;

assign eps_delta_minor = eps+delta_minor;

always@(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case (state)

    wait_state:
      if(draw_line_i)
        state <= line_prep_state; // if request for drawing a line, go to line drawing state

    line_prep_state:
      state <= line_state;

    line_state:
      state <= raster_state;

    raster_state:
      if(!busy_o)
        state <= wait_state;

  endcase

wire is_inside_screen = (minor_o >= 0) & (major_o >= -1);
reg previously_outside_screen;

always@(posedge clk_i or posedge rst_i)
begin
  if(rst_i)
  begin
    minor_slope_positive <= 1'b0;
    eps                  <= 1'b0;
    major_o              <= 1'b0;
    minor_o              <= 1'b0;
    busy_o               <= 1'b0;
    major_goal           <= 1'b0;
    x_major_o            <= 1'b0;
    delta_minor          <= 1'b0;
    delta_major          <= 1'b0;
    valid_o              <= 1'b0;
    left_pixel_x         <= 1'b0;
    left_pixel_y         <= 1'b0;
    right_pixel_x        <= 1'b0;
    right_pixel_y        <= 1'b0;
    xdiff                <= 1'b0;
    ydiff                <= 1'b0;
    previously_outside_screen <= 1'b0;
  end
  else
  begin

// ## new magic
    // Start a raster line operation 
   case (state)

      wait_state:
        if(draw_line_i)
        begin
          // set busy!
          previously_outside_screen <= 1'b0;
          busy_o  <= 1'b1;
          valid_o <= 1'b0;
          // check diff in x and y
          if(pixel0_x_i > pixel1_x_i)
          begin
            xdiff         <= pixel0_x_i - pixel1_x_i;

            // pixel0 is greater then pixel1, pixel1 is left of pixel0.
            left_pixel_x  <= pixel1_x_i;
            left_pixel_y  <= pixel1_y_i;
            right_pixel_x <= pixel0_x_i;
            right_pixel_y <= pixel0_y_i;

            // check diff for y axis (swapped)
            if(pixel1_y_i > pixel0_y_i)
            begin
              ydiff                <= pixel1_y_i - pixel0_y_i;
              minor_slope_positive <= 1'b0;
            end
            else
            begin
              ydiff                <= pixel0_y_i - pixel1_y_i;
              minor_slope_positive <= 1'b1;
            end

          end
          else
          begin
            xdiff         <= pixel1_x_i - pixel0_x_i;

            // pixel1 is greater then pixel0, pixel0 is left of pixel1.
            left_pixel_x  <= pixel0_x_i;
            left_pixel_y  <= pixel0_y_i;
            right_pixel_x <= pixel1_x_i;
            right_pixel_y <= pixel1_y_i;

            // check diff for y axis
            if(pixel0_y_i > pixel1_y_i)
            begin
              ydiff                <= pixel0_y_i - pixel1_y_i;
              minor_slope_positive <= 1'b0; // the slope is "\" negative
            end
            else
            begin
              ydiff                <= pixel1_y_i - pixel0_y_i;
              minor_slope_positive <= 1'b1; // the slope is "/" positive
            end
          end
        end

    // Prepare linedrawing
      line_prep_state:
      begin
        if(xdiff > ydiff)
        begin // x major axis
          x_major_o    <= 1'b1;
          delta_major  <= xdiff;
          delta_minor  <= ydiff;
        end
        else
        begin // y major axis 
          x_major_o    <= 1'b0;    
          delta_major  <= ydiff;
          delta_minor  <= xdiff; 
        end
      end


      // Rasterize a line between dest_pixel0 and dest_pixel1 (rasterize = generate the pixels)
      line_state:
      begin
          if(x_major_o) 
          begin
            major_o    <= $signed(left_pixel_x[point_width-1:0]);
            minor_o    <= $signed(left_pixel_y[point_width-1:0]);
            major_goal <= $signed(right_pixel_x[point_width-1:0]);
          end
          else 
          begin
            major_o    <= $signed(left_pixel_y[point_width-1:0]);
            minor_o    <= $signed(left_pixel_x[point_width-1:0]);
            major_goal <= $signed(right_pixel_y[point_width-1:0]);
          end
          eps          <= 1'b0;
          busy_o       <= 1'b1;
          valid_o      <= (left_pixel_x >= 0 && left_pixel_y >= 0);

          previously_outside_screen <= ~(left_pixel_x >= 0 && left_pixel_y >= 0);
      end

    raster_state:
    begin
      // pixels is now valid!           
      valid_o <= (previously_outside_screen | read_pixel_i) & is_inside_screen;

      previously_outside_screen <= ~is_inside_screen;

      //bresenham magic
      if((read_pixel_i & is_inside_screen) | previously_outside_screen)
      begin
        if((major_o < major_goal) & minor_slope_positive & x_major_o & busy_o) // if we are between endpoints and want to draw a line, continue
        begin
          major_o   <=  major_o + 1'b1; // major axis increeses
    
          if((eps_delta_minor*2) >= $signed(delta_major))
          begin
            eps     <=  eps_delta_minor - delta_major;
            minor_o <=  minor_o + 1'b1; // minor axis increeses
          end
          else
            eps     <=  eps_delta_minor;
        end
        else if((major_o < major_goal) & minor_slope_positive & !x_major_o & busy_o) 
        begin
          major_o   <=  major_o + 1'b1; // major axis increeses
    
          if((eps_delta_minor*2) >= $signed(delta_major))
          begin
            eps     <=  eps_delta_minor - delta_major;
            minor_o <=  minor_o + 1'b1; // minor axis increeses
          end
          else
            eps     <=  eps_delta_minor;
        end
        else if((major_o > major_goal) & !minor_slope_positive & !x_major_o & busy_o)// the slope is negative
        begin
          major_o   <=  major_o - 1'b1; // major axis decreeses

          if((eps_delta_minor*2) >= $signed(delta_major))
          begin
            eps     <=  eps_delta_minor - delta_major;
            minor_o <=  minor_o + 1'b1; // minor axis increeses
          end
          else
            eps     <=  eps_delta_minor;
        end
        else if((major_o < major_goal) & !minor_slope_positive & x_major_o & busy_o)// special to fix ocant 4 & 8.
        begin
          major_o   <=  major_o + 1'b1; // major axis increeses

          if((eps_delta_minor*2) >= $signed(delta_major))
          begin
            eps     <=  eps_delta_minor - delta_major;
            minor_o <=  minor_o - 1'b1; // minor axis decreeses
          end
          else
            eps     <=  eps_delta_minor;
        end
        // if we have reached tho goal and are busy, stop being busy.
        else if(busy_o)
        begin
          busy_o <=  1'b0;
          valid_o <= 1'b0;
        end
      end
    end
    endcase
  end
end

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_rasterizer.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

RASTERIZER MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module takes a rect write or line write request and generates pixels in the span given by dest_pixel0-1.
Triangles can be declared by dest_pixel0-2, they are handled by the triangle module

The operation is clipped to the span given by clip_pixel0-1. Pixels outside the span are discarded.

If texturing is enabled, texture coordinates u (horizontal) and v (vertical) are emitted, offset and clipped by the span given by src_pixel0-1.

When all pixels have been generated and acked, the rasterizer acks the operation and returns to wait state.
*/
module gfx_rasterizer(clk_i, rst_i,
  clip_ack_i, interp_ack_i, ack_o,
  rect_write_i, line_write_i, triangle_write_i, interpolate_i, texture_enable_i,
  //source pixel 0 and pixel 1
  src_pixel0_x_i, src_pixel0_y_i, src_pixel1_x_i, src_pixel1_y_i,
  //destination point 0, 1, 2
  dest_pixel0_x_i, dest_pixel0_y_i,
  dest_pixel1_x_i, dest_pixel1_y_i,
  dest_pixel2_x_i, dest_pixel2_y_i,
  clipping_enable_i,
  //clip pixel 0 and pixel 1
  clip_pixel0_x_i, clip_pixel0_y_i, clip_pixel1_x_i, clip_pixel1_y_i,
  target_size_x_i, target_size_y_i, 
  x_counter_o, y_counter_o, u_o,v_o,
  clip_write_o, interp_write_o,
  triangle_edge0_o, triangle_edge1_o, triangle_area_o
  );

parameter point_width    = 16;
parameter subpixel_width = 16;
parameter delay_width    = 5;

input clk_i;
input rst_i;

input clip_ack_i;
input interp_ack_i;
output reg ack_o;

input rect_write_i;
input line_write_i;
input triangle_write_i;
input interpolate_i;
input texture_enable_i;

//src pixels
input [point_width-1:0] src_pixel0_x_i;
input [point_width-1:0] src_pixel0_y_i;
input [point_width-1:0] src_pixel1_x_i;
input [point_width-1:0] src_pixel1_y_i;

//dest pixels
input signed [point_width-1:-subpixel_width] dest_pixel0_x_i;
input signed [point_width-1:-subpixel_width] dest_pixel0_y_i;
input signed [point_width-1:-subpixel_width] dest_pixel1_x_i;
input signed [point_width-1:-subpixel_width] dest_pixel1_y_i;
input signed [point_width-1:-subpixel_width] dest_pixel2_x_i;
input signed [point_width-1:-subpixel_width] dest_pixel2_y_i;

wire signed [point_width-1:0] p0_x = $signed(dest_pixel0_x_i[point_width-1:0]);
wire signed [point_width-1:0] p0_y = $signed(dest_pixel0_y_i[point_width-1:0]);
wire signed [point_width-1:0] p1_x = $signed(dest_pixel1_x_i[point_width-1:0]);
wire signed [point_width-1:0] p1_y = $signed(dest_pixel1_y_i[point_width-1:0]);

//clip pixels
input                   clipping_enable_i;
input [point_width-1:0] clip_pixel0_x_i;
input [point_width-1:0] clip_pixel0_y_i;
input [point_width-1:0] clip_pixel1_x_i;
input [point_width-1:0] clip_pixel1_y_i;

input [point_width-1:0] target_size_x_i;
input [point_width-1:0] target_size_y_i;

// Generated pixel coordinates
output reg [point_width-1:0] x_counter_o;
output reg [point_width-1:0] y_counter_o;
// Generated texture coordinates
output reg [point_width-1:0] u_o;
output reg [point_width-1:0] v_o;
// Write pixel output signals
output reg                   clip_write_o;
output reg                   interp_write_o;

output [2*point_width-1:0] triangle_edge0_o;
output [2*point_width-1:0] triangle_edge1_o;
output [2*point_width-1:0] triangle_area_o;

wire ack_i = interpolate_i ? interp_ack_i : clip_ack_i;

// Variables used in rect drawing
reg [point_width-1:0] rect_p0_x;
reg [point_width-1:0] rect_p0_y;
reg [point_width-1:0] rect_p1_x;
reg [point_width-1:0] rect_p1_y;

//line drawing reg & wires
wire raster_line_busy; // busy, drawing a line.
wire x_major; // is true if x is the major axis
wire valid_out;
reg  draw_line; // trigger the line drawing.

wire [point_width-1:0] major_out; // the major axis
wire [point_width-1:0] minor_out; // the minor axis
wire                   request_next_pixel;

// State machine
reg [2:0] state;
parameter wait_state           = 3'b000,
          rect_state           = 3'b001,
          line_state           = 3'b010,
          triangle_state       = 3'b011,
          triangle_final_state = 3'b100;

// Write/ack counter
reg [delay_width-1:0] ack_counter;

always @(posedge clk_i or posedge rst_i)
if(rst_i)
  ack_counter <= 1'b0;
else if(interpolate_i & ack_i & ~triangle_write_o)
  ack_counter <= ack_counter - 1'b1;
else if(interpolate_i & triangle_write_o & ~ack_i)
  ack_counter <= ack_counter + 1'b1;

// Rect drawing variables
always @(posedge clk_i or posedge rst_i)
begin
  if(rst_i)
  begin
    rect_p0_x <= 1'b0;
    rect_p0_y <= 1'b0;
    rect_p1_x <= 1'b0;
    rect_p1_y <= 1'b0;
  end
  else
  begin
    if(clipping_enable_i)
    begin
    // pixel0 x
    if(p0_x < $signed(clip_pixel0_x_i)) // check if pixel is left of screen
      rect_p0_x <= clip_pixel0_x_i;
    else if(p0_x > $signed(clip_pixel1_x_i)) // check if pixel is right of screen
      rect_p0_x <= clip_pixel1_x_i;
    else
      rect_p0_x <= p0_x;

    // pixel0 y
    if(p0_y < $signed(clip_pixel0_y_i)) // check if pixel is above the screen
      rect_p0_y <= clip_pixel0_y_i;
    else if(p0_y > $signed(clip_pixel1_y_i)) // check if pixel is below the screen
      rect_p0_y <= clip_pixel1_y_i;
    else
      rect_p0_y <= p0_y;

    // pixel1 x
    if(p1_x < $signed(clip_pixel0_x_i)) // check if pixel is left of screen
      rect_p1_x <= clip_pixel0_x_i;
    else if(p1_x > $signed(clip_pixel1_x_i -1)) // check if pixel is right of screen
      rect_p1_x <= clip_pixel1_x_i -1'b1;
    else
      rect_p1_x <= dest_pixel1_x_i[point_width-1:0] - 1;

    // pixel1 y
    if(p1_y < $signed(clip_pixel0_y_i)) // check if pixel is above the screen
      rect_p1_y <= clip_pixel0_y_i;
    else if(p1_y > $signed(clip_pixel1_y_i -1)) // check if pixel is below the screen
      rect_p1_y <= clip_pixel1_y_i -1'b1;
    else
      rect_p1_y <= p1_y - 1;
    end
    else
    begin
      rect_p0_x <= p0_x       >= 0 ? p0_x     : 1'b0;
      rect_p0_y <= p0_y       >= 0 ? p0_y     : 1'b0;
      rect_p1_x <= (p1_x - 1) >= 0 ? p1_x - 1 : 1'b0;
      rect_p1_y <= (p1_y - 1) >= 0 ? p1_y - 1 : 1'b0;
    end
  end
end

// Checks if the current line in the rect being drawn is complete
wire raster_rect_line_done = (x_counter_o >= rect_p1_x) | (texture_enable_i && (u_o >= src_pixel1_x_i-1));
// Checks if the current rect is completely drawn
// TODO: ugly fix to prevent the an extra pixel being written when texturing is enabled. Ugly.
//wire raster_rect_done = ack_i & (x_counter_o >= rect_p1_x) & ((y_counter_o >= rect_p1_y) | (texture_enable_i && (v_o >= src_pixel1_y_i-1)));
wire raster_rect_done = (ack_i | texture_enable_i) &
                        (x_counter_o >= rect_p1_x) &
                        ((y_counter_o >= rect_p1_y) | (texture_enable_i && (v_o >= src_pixel1_y_i-1)));
// Special check if there are no pixels to draw at all (send ack immediately)
wire empty_raster = (rect_p0_x > rect_p1_x) | (rect_p0_y > rect_p1_y);

wire triangle_finished = ~interpolate_i | (ack_counter == 1'b0);

// Manage states
always @(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case (state)

    wait_state:
      if(triangle_write_i)
        state <= triangle_state;
      else if(rect_write_i & !empty_raster) // if request for drawing a rect, go to rect drawing state
        state <= rect_state;
      else if(line_write_i)
        state <= line_state; // if request for drawing a line, go to line drawing state

    rect_state:
      if(raster_rect_done) // if we are done drawing a rect, go to wait state
        state <= wait_state;

    line_state:
      if(!raster_line_busy & !draw_line)  // if we are done drawing a line, go to wait state
        state <= wait_state;

    triangle_state:
      if(triangle_ack & triangle_finished)
        state <= wait_state;
      else if(triangle_ack)
        state <= triangle_final_state;

    triangle_final_state:
      if(triangle_finished)
        state <= wait_state;

  endcase

// If interpolation is active, only write to interp module if queue is not full. 
wire interp_ready   = interpolate_i ? (ack_counter <= point_width)   & ~interp_write_o : ack_i;
wire triangle_ready = interpolate_i ? (ack_counter <= point_width-1) & ~interp_write_o : ack_i;

// Manage outputs (mealy machine)
always @(posedge clk_i or posedge rst_i)
begin
  // Reset
  if(rst_i)
  begin
    ack_o          <= 1'b0;
    x_counter_o    <= 1'b0;
    y_counter_o    <= 1'b0;
    clip_write_o   <= 1'b0;
    interp_write_o <= 1'b0;
    u_o            <= 1'b0;
    v_o            <= 1'b0;

    //reset line regs
    draw_line      <= 1'b0;
  end
  else
  begin
    case (state)

      // Wait for incoming instructions
      wait_state:
        
        if(rect_write_i & !empty_raster) // Start a raster rectangle operation
        begin
          ack_o        <= 1'b0;
          clip_write_o <= 1'b1;
          // Generate pixel coordinates
          x_counter_o  <= rect_p0_x;
          y_counter_o  <= rect_p0_y;
          // Generate texture coordinates
          u_o          <= (($signed(clip_pixel0_x_i) < p0_x) ? 1'b0 :
                            $signed(clip_pixel0_x_i) - p0_x) + src_pixel0_x_i;
          v_o          <= (($signed(clip_pixel0_y_i) < p0_y) ? 1'b0 :
                            $signed(clip_pixel0_y_i) - p0_y) + src_pixel0_y_i;
        end

        else if(rect_write_i & empty_raster & !ack_o) // Start a raster rectangle operation
          ack_o     <= 1'b1;

        // Start a raster line operation
        else if(line_write_i)
        begin
          draw_line <= 1'b1;
          ack_o     <= 1'b0;
        end

        else
          ack_o     <= 1'b0;


      // Rasterize a rectangle between p0 and p1 (rasterize = generate the pixels)
      rect_state:
      begin
        if(ack_i) // If our last coordinate was acknowledged by a fragment processor
        begin
          if(raster_rect_line_done) // iterate through width of rect
          begin
            x_counter_o <= rect_p0_x;
            y_counter_o <= y_counter_o + 1'b1;
            u_o         <= ($signed(clip_pixel0_x_i) < p0_x ? 1'b0 :
                            $signed(clip_pixel0_x_i) - p0_x) + $signed(src_pixel0_x_i);
            v_o         <= v_o + 1'b1;
          end
          else
          begin
            x_counter_o <= x_counter_o + 1'b1;
            u_o         <= u_o + 1'b1;
          end
        end
        
        if(raster_rect_done) // iterate through height of rect (are we done?)
        begin
          clip_write_o <= 1'b0; // Only send ack when we get ack_i (see wait state)
          ack_o        <= 1'b1;
        end
      end

      // Rasterize a line between dest_pixel0 and dest_pixel1 (rasterize = generate the pixels)
      line_state:
      begin
        draw_line    <= 1'b0;
        clip_write_o <= raster_line_busy & valid_out;
        x_counter_o  <= x_major ? major_out : minor_out;
        y_counter_o  <= x_major ? minor_out : major_out;
        ack_o        <= !raster_line_busy & !draw_line;
      end

      triangle_state:
      if(triangle_ack)
      begin
        interp_write_o <= 1'b0;
        clip_write_o   <= 1'b0;
        if(triangle_finished)
          ack_o <= 1'b1;
      end
      else if(~interpolate_i)
      begin
        x_counter_o    <= triangle_x_o;
        y_counter_o    <= triangle_y_o;
        clip_write_o   <= triangle_write_o ;
      end
      else if(interpolate_i & interp_ready)
      begin
        x_counter_o    <= triangle_x_o;
        y_counter_o    <= triangle_y_o;
        // edge0, edge1 and area are set by the triangle module
        interp_write_o <= triangle_write_o;
      end
      else
      begin
        interp_write_o <= 1'b0;
        clip_write_o   <= 1'b0;
      end

      triangle_final_state:
        if(triangle_finished)
          ack_o <= 1'b1;

    endcase
  end
end

// Request wire for line drawing module
assign request_next_pixel = ack_i & raster_line_busy;

// Instansiation of bresenham line drawing module
bresenham_line bresenham(
.clk_i                  ( clk_i                ),  //clock
.rst_i                  ( rst_i                ),  //rest
.pixel0_x_i             ( dest_pixel0_x_i      ),  // left pixel x
.pixel0_y_i             ( dest_pixel0_y_i      ),  // left pixel y
.pixel1_x_i             ( dest_pixel1_x_i      ),  // right pixel x
.pixel1_y_i             ( dest_pixel1_y_i      ),  // right pixel y
.draw_line_i            ( draw_line            ), // trigger for drawing a line
.read_pixel_i           ( request_next_pixel   ), // request next pixel
.busy_o                 ( raster_line_busy     ), // is true while line is drawn
.x_major_o              ( x_major              ), // is true if x is the major axis
.major_o                ( major_out            ), // the major axis pixel coordinate
.minor_o                ( minor_out            ), // the minor axis pixel coordinate
.valid_o                ( valid_out            )
);

defparam bresenham.point_width = point_width;
defparam bresenham.subpixel_width = subpixel_width;

wire                   triangle_ack;
wire [point_width-1:0] triangle_x_o;
wire [point_width-1:0] triangle_y_o;
wire                   triangle_write_o;

// Triangle module instanciated
gfx_triangle triangle(
.clk_i                  (clk_i),
.rst_i                  (rst_i),
.ack_i                  (triangle_ready),
.ack_o                  (triangle_ack),
.triangle_write_i       (triangle_write_i),
.texture_enable_i       (texture_enable_i),
.dest_pixel0_x_i        (dest_pixel0_x_i),
.dest_pixel0_y_i        (dest_pixel0_y_i),
.dest_pixel1_x_i        (dest_pixel1_x_i),
.dest_pixel1_y_i        (dest_pixel1_y_i),
.dest_pixel2_x_i        (dest_pixel2_x_i),
.dest_pixel2_y_i        (dest_pixel2_y_i),
.x_counter_o            (triangle_x_o),
.y_counter_o            (triangle_y_o),
.triangle_edge0_o       (triangle_edge0_o),
.triangle_edge1_o       (triangle_edge1_o),
.triangle_area_o        (triangle_area_o),
.write_o                (triangle_write_o)
);

defparam triangle.point_width    = point_width;
defparam triangle.subpixel_width = subpixel_width;

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_renderer.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

RENDERING MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

module gfx_renderer(clk_i, rst_i,
	target_base_i, zbuffer_base_i, target_size_x_i, target_size_y_i, color_depth_i,
	pixel_x_i, pixel_y_i, pixel_z_i, zbuffer_enable_i, color_i,
	render_addr_o, render_sel_o, render_dat_o,
	ack_o, ack_i,
	write_i, write_o
	);

parameter point_width = 16;

input clk_i;
input rst_i;

// Render target information, used for checking out of bounds and stride when writing pixels
input            [31:2] target_base_i;
input            [31:2] zbuffer_base_i;
input [point_width-1:0] target_size_x_i;
input [point_width-1:0] target_size_y_i;

input             [1:0] color_depth_i;

input [point_width-1:0] pixel_x_i;
input [point_width-1:0] pixel_y_i;
input [point_width-1:0] pixel_z_i;
input                   zbuffer_enable_i;
input            [31:0] color_i;

input      write_i;
output reg write_o;

// Output registers connected to the wbm
output reg [31:2] render_addr_o;
output reg  [3:0] render_sel_o;
output reg [31:0] render_dat_o;

wire        [3:0] target_sel;
wire       [31:0] target_dat;
wire        [3:0] zbuffer_sel;
wire       [31:0] zbuffer_dat;

output reg ack_o;
input      ack_i;

// TODO: Fifo for incoming pixel data?



// Define memory address
// Addr[31:2] = Base + (Y*width + X) * ppb
wire [31:0] pixel_offset;
assign pixel_offset = (color_depth_i == 2'b00) ? (target_size_x_i*pixel_y_i + pixel_x_i)      : // 8  bit
                      (color_depth_i == 2'b01) ? (target_size_x_i*pixel_y_i + pixel_x_i) << 1 : // 16 bit
                                                 (target_size_x_i*pixel_y_i + pixel_x_i) << 2 ; // 32 bit

wire [31:2] target_addr = target_base_i + pixel_offset[31:2];
wire [31:2] zbuffer_addr = zbuffer_base_i + pixel_offset[31:2];

// Color to memory converter
color_to_memory color_proc(
.color_depth_i  (color_depth_i),
.color_i        (color_i),
.x_lsb_i        (pixel_x_i[1:0]),
.mem_o          (target_dat),
.sel_o          (target_sel)
);



// Color to memory converter
color_to_memory depth_proc(
.color_depth_i  (2'b01),
// Note: Padding because z_i is only [15:0]
.color_i        ({ {point_width{1'b0}}, pixel_z_i[point_width-1:0] }),
.x_lsb_i        (pixel_x_i[1:0]),
.mem_o          (zbuffer_dat),
.sel_o          (zbuffer_sel)
);

// State machine
reg [1:0] state;
parameter wait_state        = 2'b00,
          write_pixel_state = 2'b01,
          write_z_state     = 2'b10;

// Acknowledge when a command has completed
always @(posedge clk_i or posedge rst_i)
begin
  //  reset, init component
  if(rst_i)
  begin
    write_o       <= 1'b0;
    ack_o         <= 1'b0;
    render_addr_o <= 1'b0;
    render_sel_o  <= 1'b0;
    render_dat_o  <= 1'b0;
  end
  // Else, set outputs for next cycle
  else
  begin
    case (state)

      wait_state:
      begin
        ack_o   <= 1'b0;
        if(write_i)
        begin
          render_addr_o <= target_addr;
          render_sel_o  <= target_sel;
          render_dat_o  <= target_dat;
          write_o <= 1'b1;
        end
      end

      // Write pixel to memory. If depth buffering is enabled, write z value too
      write_pixel_state:
      begin
        if(ack_i)
        begin
          render_addr_o <= zbuffer_addr;
          render_sel_o  <= zbuffer_sel;
          render_dat_o  <= zbuffer_dat;

          write_o       <= zbuffer_enable_i;
          ack_o         <= ~zbuffer_enable_i;
        end
        else
          write_o       <= 1'b0;
      end

      write_z_state:
      begin
        write_o       <= 1'b0;
        ack_o         <= ack_i;
      end

    endcase
  end
end

// State machine
always @(posedge clk_i or posedge rst_i)
begin
  // reset, init component
  if(rst_i)
    state <= wait_state;
  // Move in statemachine
  else
    case (state)

      wait_state:
        if(write_i)
          state <= write_pixel_state;

      write_pixel_state:
        if(ack_i & zbuffer_enable_i)
          state <= write_z_state;
        else if(ack_i)
          state <= wait_state;

      write_z_state:
        if(ack_i)
          state <= wait_state;

    endcase
end

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_transform.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

TRANSFORMATION PROCESSING MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*

Input matrix M:
    | aa ab ac tx |
M = | ba bb bc ty |
    | ca cb cc tz |

Input point X:
    | x |
X = | y |
    | z |
    | 1 |

Output point X':
     | x' |        | aa*x + ab*y + ac*z + tx |
X' = | y' | = MX = | ba*x + bb*y + bc*z + ty |
     | z' |        | ca*x + cb*y + cc*z + tz |

*/

/* Transforms points with a 4x3 matrix */
module gfx_transform(clk_i, rst_i,
// Input point
x_i, y_i, z_i, point_id_i,
// Matrix
aa, ab, ac, tx, ba, bb, bc, ty, ca, cb, cc, tz, // TODO: Make signed
// Output points
p0_x_o, p0_y_o, p0_z_o, p1_x_o, p1_y_o, p1_z_o, p2_x_o, p2_y_o, p2_z_o,
transform_i, forward_i,
ack_o
);

input clk_i;
input rst_i;

parameter point_width = 16;
parameter subpixel_width = 16;

input signed [point_width-1:-subpixel_width] x_i;
input signed [point_width-1:-subpixel_width] y_i;
input signed [point_width-1:-subpixel_width] z_i;
input                                  [1:0] point_id_i; // point 0,1,2

input signed [point_width-1:-subpixel_width] aa;
input signed [point_width-1:-subpixel_width] ab;
input signed [point_width-1:-subpixel_width] ac;
input signed [point_width-1:-subpixel_width] tx;
input signed [point_width-1:-subpixel_width] ba;
input signed [point_width-1:-subpixel_width] bb;
input signed [point_width-1:-subpixel_width] bc;
input signed [point_width-1:-subpixel_width] ty;
input signed [point_width-1:-subpixel_width] ca;
input signed [point_width-1:-subpixel_width] cb;
input signed [point_width-1:-subpixel_width] cc;
input signed [point_width-1:-subpixel_width] tz;

output reg signed [point_width-1:-subpixel_width] p0_x_o;
output reg signed [point_width-1:-subpixel_width] p0_y_o;
output reg signed               [point_width-1:0] p0_z_o;
output reg signed [point_width-1:-subpixel_width] p1_x_o;
output reg signed [point_width-1:-subpixel_width] p1_y_o;
output reg signed               [point_width-1:0] p1_z_o;
output reg signed [point_width-1:-subpixel_width] p2_x_o;
output reg signed [point_width-1:-subpixel_width] p2_y_o;
output reg signed               [point_width-1:0] p2_z_o;

input transform_i, forward_i;

output reg ack_o;

reg [1:0] state;
parameter wait_state = 2'b00, forward_state = 2'b01, transform_state = 2'b10;

reg signed [2*point_width-1:-subpixel_width*2] aax;
reg signed [2*point_width-1:-subpixel_width*2] aby;
reg signed [2*point_width-1:-subpixel_width*2] acz;
reg signed [2*point_width-1:-subpixel_width*2] bax;
reg signed [2*point_width-1:-subpixel_width*2] bby;
reg signed [2*point_width-1:-subpixel_width*2] bcz;
reg signed [2*point_width-1:-subpixel_width*2] cax;
reg signed [2*point_width-1:-subpixel_width*2] cby;
reg signed [2*point_width-1:-subpixel_width*2] ccz;

always @(posedge clk_i or posedge rst_i)
if(rst_i)
begin
  // Initialize registers
  ack_o             <= 1'b0;
  p0_x_o            <= 1'b0;
  p0_y_o            <= 1'b0;
  p0_z_o            <= 1'b0;
  p1_x_o            <= 1'b0;
  p1_y_o            <= 1'b0;
  p1_z_o            <= 1'b0;
  p2_x_o            <= 1'b0;
  p2_y_o            <= 1'b0;
  p2_z_o            <= 1'b0;

  aax               <= 1'b0;
  aby               <= 1'b0;
  acz               <= 1'b0;
  bax               <= 1'b0;
  bby               <= 1'b0;
  bcz               <= 1'b0;
  cax               <= 1'b0;
  cby               <= 1'b0;
  ccz               <= 1'b0;
end
else
  case(state)
    wait_state:
    begin
      ack_o <= 1'b0;

      // Begin transformation
      if(transform_i)
      begin
        aax <= aa * x_i;
        aby <= ab * y_i;
        acz <= ac * z_i;
        bax <= ba * x_i;
        bby <= bb * y_i;
        bcz <= bc * z_i;
        cax <= ca * x_i;
        cby <= cb * y_i;
        ccz <= cc * z_i;
      end
      // Forward the point
      else if(forward_i)
      begin
        if(point_id_i == 2'b00)
        begin
          p0_x_o <= x_i;
          p0_y_o <= y_i;
          p0_z_o <= z_i[point_width-1:0];
        end
        else if(point_id_i == 2'b01)
        begin
          p1_x_o <= x_i;
          p1_y_o <= y_i;
          p1_z_o <= z_i[point_width-1:0];
        end
        else if(point_id_i == 2'b10)
        begin
          p2_x_o <= x_i;
          p2_y_o <= y_i;
          p2_z_o <= z_i[point_width-1:0];
        end
      end
    end

    forward_state:
      ack_o <= 1'b1;

    transform_state:
    begin
      ack_o <= 1'b1;

      if(point_id_i == 2'b00)
        begin
          p0_x_o <= x_prime_trunc;
          p0_y_o <= y_prime_trunc;
          p0_z_o <= z_prime_trunc[point_width-1:0];
        end
        else if(point_id_i == 2'b01)
        begin
          p1_x_o <= x_prime_trunc;
          p1_y_o <= y_prime_trunc;
          p1_z_o <= z_prime_trunc[point_width-1:0];
        end
        else if(point_id_i == 2'b10)
        begin
          p2_x_o <= x_prime_trunc;
          p2_y_o <= y_prime_trunc;
          p2_z_o <= z_prime_trunc[point_width-1:0];
        end
    end
  endcase

wire [subpixel_width-1:0] zeroes = 1'b0;

wire signed [2*point_width-1:-subpixel_width*2] x_prime = aax + aby + acz + {tx,zeroes};
wire signed [2*point_width-1:-subpixel_width*2] y_prime = bax + bby + bcz + {ty,zeroes};
wire signed [2*point_width-1:-subpixel_width*2] z_prime = cax + cby + ccz + {tz,zeroes};

wire signed [point_width-1:-subpixel_width] x_prime_trunc = x_prime[point_width-1:-subpixel_width];
wire signed [point_width-1:-subpixel_width] y_prime_trunc = y_prime[point_width-1:-subpixel_width];
wire signed [point_width-1:-subpixel_width] z_prime_trunc = z_prime[point_width-1:-subpixel_width];

// State machine
always @(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case(state)
    wait_state:
      if(transform_i)
        state <= transform_state;
      else if(forward_i)
        state <= forward_state;

    forward_state:
      state <= wait_state;
    
    transform_state:
      state <= wait_state;
  endcase

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_triangle.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

TRIANGLE MODULE

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
This module rasterizes a triangle
*/
module gfx_triangle(clk_i, rst_i,
  ack_i, ack_o,
  triangle_write_i, texture_enable_i,
  //destination point 0, 1, 2
  dest_pixel0_x_i, dest_pixel0_y_i,
  dest_pixel1_x_i, dest_pixel1_y_i,
  dest_pixel2_x_i, dest_pixel2_y_i,

  x_counter_o, y_counter_o,
  write_o,
  triangle_edge0_o, triangle_edge1_o, triangle_area_o
  );

parameter point_width = 16;
parameter subpixel_width = 16;

input clk_i;
input rst_i;

input ack_i;
output reg ack_o;

input triangle_write_i;
input texture_enable_i;

//dest pixels
input signed [point_width-1:-subpixel_width] dest_pixel0_x_i;
input signed [point_width-1:-subpixel_width] dest_pixel0_y_i;
input signed [point_width-1:-subpixel_width] dest_pixel1_x_i;
input signed [point_width-1:-subpixel_width] dest_pixel1_y_i;
input signed [point_width-1:-subpixel_width] dest_pixel2_x_i;
input signed [point_width-1:-subpixel_width] dest_pixel2_y_i;

wire signed [point_width-1:0] p0_x = $signed(dest_pixel0_x_i[point_width-1:0]);
wire signed [point_width-1:0] p0_y = $signed(dest_pixel0_y_i[point_width-1:0]);
wire signed [point_width-1:0] p1_x = $signed(dest_pixel1_x_i[point_width-1:0]);
wire signed [point_width-1:0] p1_y = $signed(dest_pixel1_y_i[point_width-1:0]);
wire signed [point_width-1:0] p2_x = $signed(dest_pixel2_x_i[point_width-1:0]);
wire signed [point_width-1:0] p2_y = $signed(dest_pixel2_y_i[point_width-1:0]);

// Generated pixel coordinates
output reg [point_width-1:0] x_counter_o;
output reg [point_width-1:0] y_counter_o;
// Write pixel output signal
output reg write_o;

output     [2*point_width-1:0] triangle_edge0_o;
output     [2*point_width-1:0] triangle_edge1_o;
output reg [2*point_width-1:0] triangle_area_o;

// triangle raster reg & wires
reg triangle_ignore_pixel;
reg signed [point_width-1:0] triangle_bound_min_x;
reg signed [point_width-1:0] triangle_bound_min_y;
reg signed [point_width-1:0] triangle_bound_max_x;
reg signed [point_width-1:0] triangle_bound_max_y;

reg signed [2*point_width-1:0] triangle_area0;
reg signed [2*point_width-1:0] triangle_area1;

// edge0
reg signed [point_width-1:0] triangle_edge0_y2y1;
reg signed [point_width-1:0] triangle_edge0_xx1;
reg signed [point_width-1:0] triangle_edge0_x2x1;
reg signed [point_width-1:0] triangle_edge0_yy1;

// edge1
reg signed [point_width-1:0] triangle_edge1_y0y2;
reg signed [point_width-1:0] triangle_edge1_xx2;
reg signed [point_width-1:0] triangle_edge1_x0x2;
reg signed [point_width-1:0] triangle_edge1_yy2;

//edge2
reg signed [point_width-1:0] triangle_edge2_y1y0;
reg signed [point_width-1:0] triangle_edge2_xx0;
reg signed [point_width-1:0] triangle_edge2_x1x0;
reg signed [point_width-1:0] triangle_edge2_yy0;
reg        [point_width-1:0] triangle_x_counter;
reg        [point_width-1:0] triangle_y_counter;
reg                          triangle_line_active;

reg signed [point_width-1:-subpixel_width] diff_x1x0;
reg signed [point_width-1:-subpixel_width] diff_y2y0;
reg signed [point_width-1:-subpixel_width] diff_x2x0;
reg signed [point_width-1:-subpixel_width] diff_y1y0;

wire signed [point_width-1:0] diff_x1x0_int = diff_x1x0[point_width-1:0];
wire signed [point_width-1:0] diff_y2y0_int = diff_y2y0[point_width-1:0];
wire signed [point_width-1:0] diff_x2x0_int = diff_x2x0[point_width-1:0];
wire signed [point_width-1:0] diff_y1y0_int = diff_y1y0[point_width-1:0];

wire signed [2*point_width-1:0] triangle_edge0_val1 = triangle_edge0_y2y1 * triangle_edge0_xx1;
wire signed [2*point_width-1:0] triangle_edge0_val2 = triangle_edge0_x2x1 * triangle_edge0_yy1;
wire signed [2*point_width-1:0] triangle_edge1_val1 = triangle_edge1_y0y2 * triangle_edge1_xx2;
wire signed [2*point_width-1:0] triangle_edge1_val2 = triangle_edge1_x0x2 * triangle_edge1_yy2;
wire signed [2*point_width-1:0] triangle_edge2_val1 = triangle_edge2_y1y0 * triangle_edge2_xx0;
wire signed [2*point_width-1:0] triangle_edge2_val2 = triangle_edge2_x1x0 * triangle_edge2_yy0;


// e0(x,y) = -(p2y-p1y)(x-p1x)+(p2x-p1x)(y+p1y)
wire signed [2*point_width-1:0] triangle_edge0 = triangle_edge0_val2 - triangle_edge0_val1;
// e1(x,y) = -(p0y-p2y)(x-p2x)+(p0x-p2x)(y+p2y)
wire signed [2*point_width-1:0] triangle_edge1 = triangle_edge1_val2 - triangle_edge1_val1;
// e2(x,y) = -(p1y-p0y)(x-p0x)+(p1x-p0x)(y+p2y)
wire signed [2*point_width-1:0] triangle_edge2 = triangle_edge2_val2 - triangle_edge2_val1;

// Assign output (used in division in the interp module)
assign triangle_edge0_o = triangle_edge0;
assign triangle_edge1_o = triangle_edge1;

// Triangle iteration variables
wire triangle_done        = (triangle_y_counter >= triangle_bound_max_y ) & (triangle_line_done);
wire triangle_line_done   = (triangle_x_counter > triangle_bound_max_x) | (!triangle_valid_pixel & triangle_line_active);
wire triangle_valid_pixel = (triangle_edge0 >= 0 && triangle_edge1 >= 0 && triangle_edge2 >= 0)
                            && (triangle_x_counter >= 1'b0 && triangle_y_counter >= 1'b0);

// State machine
reg [1:0] state;
parameter wait_state           = 2'b00,
          triangle_prep_state  = 2'b01,
          triangle_calc_state  = 2'b10,
          triangle_write_state = 2'b11;

// Manage states
always @(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case (state)

    wait_state:
      if(triangle_write_i)
        state <= triangle_prep_state;

    // Preparation stage
    triangle_prep_state:
      state <= triangle_calc_state;

    // Per pixel preparation stage
    triangle_calc_state:
      // Backface culling
      if(triangle_area0 - triangle_area1 > 0)
      begin
        if(ack_i | triangle_ignore_pixel)
          state <= triangle_write_state;
      end
      else
        state <= wait_state;

    // Pixel write stage
    triangle_write_state:
      if(triangle_done)
        state <= wait_state;
      else
        state <= triangle_calc_state;

  endcase

// Manage outputs (mealy machine)
always @(posedge clk_i or posedge rst_i)
begin
  // Reset
  if(rst_i)
  begin
    ack_o       <= 1'b0;
    x_counter_o <= 1'b0;
    y_counter_o <= 1'b0;
    write_o     <= 1'b0;
    
    diff_x1x0   <= 1'b0;
    diff_y2y0   <= 1'b0;
    diff_x2x0   <= 1'b0;
    diff_y1y0   <= 1'b0;

    //reset triangle regs
    triangle_bound_min_x  <= 1'b0;
    triangle_bound_min_y  <= 1'b0;
    triangle_bound_max_x  <= 1'b0;
    triangle_bound_max_y  <= 1'b0;
    triangle_ignore_pixel <= 1'b0;
    triangle_line_active  <= 1'b0;
    triangle_area0        <= 1'b0;
    triangle_area1        <= 1'b0;

    triangle_edge0_y2y1   <= 1'b0;
    triangle_edge0_xx1    <= 1'b0;
    triangle_edge0_x2x1   <= 1'b0;
    triangle_edge0_yy1    <= 1'b0;

    triangle_edge1_y0y2   <= 1'b0;
    triangle_edge1_xx2    <= 1'b0;
    triangle_edge1_x0x2   <= 1'b0;
    triangle_edge1_yy2    <= 1'b0;

    triangle_edge2_y1y0   <= 1'b0;
    triangle_edge2_xx0    <= 1'b0;
    triangle_edge2_x1x0   <= 1'b0;
    triangle_edge2_yy0    <= 1'b0;

    triangle_x_counter    <= 1'b0;
    triangle_y_counter    <= 1'b0;

    triangle_area_o       <= 1'b0;
  end
  else
  begin
    case (state)

      // Wait for incoming instructions
      wait_state:
      begin
        ack_o       <= 1'b0;
        if(triangle_write_i)
        begin
          // Initialize bounds
          triangle_bound_min_x <= (dest_pixel0_x_i <= dest_pixel1_x_i && dest_pixel0_x_i <= dest_pixel2_x_i) ? p0_x :
                                  (dest_pixel1_x_i <= dest_pixel2_x_i) ? p1_x :
                                  p2_x;
          triangle_bound_max_x <= (dest_pixel0_x_i >= dest_pixel1_x_i && dest_pixel0_x_i >= dest_pixel2_x_i) ? p0_x :
                                  (dest_pixel1_x_i >= dest_pixel2_x_i) ? p1_x :
                                  p2_x;
          triangle_bound_min_y <= (dest_pixel0_y_i <= dest_pixel1_y_i && dest_pixel0_y_i <= dest_pixel2_y_i) ? p0_y :
                                  (dest_pixel1_y_i <= dest_pixel2_y_i) ? p1_y :
                                  p2_y;
          triangle_bound_max_y <= (dest_pixel0_y_i >= dest_pixel1_y_i && dest_pixel0_y_i >= dest_pixel2_y_i) ? p0_y :
                                  (dest_pixel1_y_i >= dest_pixel2_y_i) ? p1_y :
                                  p2_y;

          diff_x1x0 <= dest_pixel1_x_i - dest_pixel0_x_i;
          diff_y2y0 <= dest_pixel2_y_i - dest_pixel0_y_i;
          diff_x2x0 <= dest_pixel2_x_i - dest_pixel0_x_i;
          diff_y1y0 <= dest_pixel1_y_i - dest_pixel0_y_i;
        end
      end

      // Triangle preparation
      triangle_prep_state:
      begin
        triangle_x_counter    <= (triangle_bound_min_x > 0) ? triangle_bound_min_x : 1'b0;
        triangle_y_counter    <= (triangle_bound_min_y > 0) ? triangle_bound_min_y : 1'b0;
        triangle_ignore_pixel <= 1'b1;

        triangle_area0        <= diff_x1x0_int * diff_y2y0_int;
        triangle_area1        <= diff_x2x0_int * diff_y1y0_int;
      end
      
      // Rasterize triangle
      triangle_calc_state:
      begin
        // Backface culling
        ack_o           <= (triangle_area0 - triangle_area1 <= 0);
        triangle_area_o <= triangle_area0 - triangle_area1;

        write_o <= 1'b0;
        
        if(ack_i | triangle_ignore_pixel)
        begin
          triangle_edge0_y2y1 <= p2_y                        - p1_y;
          triangle_edge0_xx1  <= $signed(triangle_x_counter) - p1_x;
          triangle_edge0_x2x1 <= p2_x                        - p1_x;
          triangle_edge0_yy1  <= $signed(triangle_y_counter) - p1_y;

          triangle_edge1_y0y2 <= p0_y                        - p2_y;
          triangle_edge1_xx2  <= $signed(triangle_x_counter) - p2_x;
          triangle_edge1_x0x2 <= p0_x                        - p2_x;
          triangle_edge1_yy2  <= $signed(triangle_y_counter) - p2_y;

          triangle_edge2_y1y0 <= p1_y                        - p0_y;
          triangle_edge2_xx0  <= $signed(triangle_x_counter) - p0_x;
          triangle_edge2_x1x0 <= p1_x                        - p0_x;
          triangle_edge2_yy0  <= $signed(triangle_y_counter) - p0_y;
        end
      end

      triangle_write_state:
      if(triangle_done)
      begin
        ack_o   <= 1'b1;
        write_o <= 1'b0;
      end
      else
      begin
        x_counter_o            <= triangle_x_counter;
        y_counter_o            <= triangle_y_counter;
        write_o                <= triangle_valid_pixel;
        triangle_ignore_pixel  <= !triangle_valid_pixel;
        if(triangle_line_done) // iterate through width of rect
        begin
          triangle_x_counter   <= (triangle_bound_min_x > 0) ? triangle_bound_min_x : 1'b0;
          triangle_y_counter   <= triangle_y_counter + 1'b1;
          triangle_line_active <= 1'b0;
        end
        else
        begin
          triangle_x_counter   <= triangle_x_counter + 1'b1;
          triangle_line_active <= triangle_valid_pixel;
        end
      end
    endcase
  end
end

endmodule


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_wbm_read.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

WBM reader

Loosely based on the vga lcds wishbone reader (LGPL) in orpsocv2 by Julius Baxter, julius@opencores.org

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

//synopsys translate_off
`include "timescale.v"
//synopsys translate_on

module gfx_wbm_read (clk_i, rst_i,
  cyc_o, stb_o, cti_o, bte_o, we_o, adr_o, sel_o, ack_i, err_i, dat_i, sint_o,
  read_request_i,
  texture_addr_i, texture_sel_i, texture_dat_o, texture_data_ack);

  // inputs & outputs

  // wishbone signals
  input             clk_i;    // master clock input
  input             rst_i;    // asynchronous active high reset
  output reg        cyc_o;    // cycle output
  output            stb_o;    // strobe ouput
  output [ 2:0]     cti_o;    // cycle type id
  output [ 1:0]     bte_o;    // burst type extension
  output            we_o;     // write enable output
  output [31:0]     adr_o;    // address output
  output reg [ 3:0] sel_o;    // byte select outputs (only 32bits accesses are supported)
  input             ack_i;    // wishbone cycle acknowledge
  input             err_i;    // wishbone cycle error
  input [31:0]      dat_i;    // wishbone data in

  output        sint_o;     // non recoverable error, interrupt host

  // Request stuff
  input         read_request_i;

  input [31:2]  texture_addr_i;
  input [3:0]   texture_sel_i;
  output [31:0] texture_dat_o;
  output reg    texture_data_ack;

  //
  // variable declarations
  //
  reg busy;

  //
  // module body
  //

  assign adr_o  = {texture_addr_i, 2'b00};
  assign texture_dat_o = dat_i;
  // This interface is read only
  assign we_o   = 1'b0;
  assign stb_o  = 1'b1;
  assign sint_o = err_i;
  assign bte_o  = 2'b00;
  assign cti_o  = 3'b000;

  always @(posedge clk_i or posedge rst_i)
  if (rst_i) // Reset
    begin
      texture_data_ack <= 1'b0;
      cyc_o <= 1'b0;
      sel_o <= 4'b1111;
      busy  <= 1'b0;
    end
  else
  begin
    sel_o <= texture_sel_i;
	
    if(ack_i) // On ack, stop current read, send ack to arbiter
    begin
      cyc_o            <= 1'b0;
      texture_data_ack <= 1'b1;
      busy             <= 1'b0;
    end
    else if(read_request_i & !texture_data_ack) // Else, is there a pending request? Start a read
    begin
      cyc_o            <= 1'b1;
      texture_data_ack <= 1'b0;
      busy             <= 1'b1;
    end
    else if(!busy) // Else, are we done? Zero ack
      texture_data_ack <= 1'b0;
  end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_wbm_read_arbiter.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

WBM reader arbiter

Loosely based on the arbiter_dbus.v (LGPL) in orpsocv2 by Julius Baxter, julius@opencores.org

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

// 3 Masters, one slave
module gfx_wbm_read_arbiter
  (
   master_busy_o,
   // Interface against the wbm read module
   read_request_o,
   addr_o,
   sel_o,
   dat_i,
   ack_i,
   // Interface against masters (clip)
   m0_read_request_i,
   m0_addr_i,
   m0_sel_i,
   m0_dat_o,
   m0_ack_o,
   // Interface against masters (fragment processor)
   m1_read_request_i,
   m1_addr_i,
   m1_sel_i,
   m1_dat_o,
   m1_ack_o,
   // Interface against masters (blender)
   m2_read_request_i,
   m2_addr_i,
   m2_sel_i,
   m2_dat_o,
   m2_ack_o
   );

output        master_busy_o;
// Interface against the wbm read module
output        read_request_o;
output [31:2] addr_o;
output  [3:0] sel_o;
input  [31:0] dat_i;
input         ack_i;
// Interface against masters (clip)
input         m0_read_request_i;
input  [31:2] m0_addr_i;
input   [3:0] m0_sel_i;
output [31:0] m0_dat_o;
output        m0_ack_o;
// Interface against masters (fragment processor)
input         m1_read_request_i;
input  [31:2] m1_addr_i;
input   [3:0] m1_sel_i;
output [31:0] m1_dat_o;
output        m1_ack_o;
// Interface against masters (blender)
input         m2_read_request_i;
input  [31:2] m2_addr_i;
input   [3:0] m2_sel_i;
output [31:0] m2_dat_o;
output        m2_ack_o;

// Master ins -> |MUX> -> these wires
wire        rreq_w;
wire [31:2] addr_w;
wire  [3:0] sel_w;
// Slave ins -> |MUX> -> these wires
wire [31:0] dat_w;
wire        ack_w;

// Master select (MUX controls)
wire [2:0] master_sel;

assign master_busy_o = m0_read_request_i | m1_read_request_i | m2_read_request_i;

// priority to wbm1, the blender master
assign master_sel[0] = m0_read_request_i & !m1_read_request_i & !m2_read_request_i;
assign master_sel[1] = m1_read_request_i & !m2_read_request_i;
assign master_sel[2] = m2_read_request_i;

// Master input mux, priority to blender master
assign m0_dat_o = dat_i;
assign m0_ack_o = ack_i & master_sel[0];

assign m1_dat_o = dat_i;
assign m1_ack_o = ack_i & master_sel[1];

assign m2_dat_o = dat_i;
assign m2_ack_o = ack_i & master_sel[2];

assign read_request_o = master_sel[2] |
                        master_sel[1] |
                        master_sel[0];

assign addr_o = master_sel[2] ? m2_addr_i :
                master_sel[1] ? m1_addr_i :
	                              m0_addr_i;
assign sel_o  = master_sel[2] ? m2_sel_i :
                master_sel[1] ? m1_sel_i :
	                              m0_sel_i;
   
endmodule // gfx_wbm_read_arbiter


// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_wbm_write.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

The Wishbone master component will interface with the video memory, writing outgoing pixels to it.

Loosely based on the vga lcds wishbone writer (LGPL) in orpsocv2 by Julius Baxter, julius@opencores.org

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

//synopsys translate_off
`include "timescale.v"
//synopsys translate_on

module gfx_wbm_write (clk_i, rst_i,
                      cyc_o, stb_o, cti_o, bte_o, we_o, adr_o, sel_o, ack_i, err_i, dat_o, sint_o,
                      write_i, ack_o,
                      render_addr_i, render_sel_i, render_dat_i);

  // wishbone signals
  input         clk_i;    // master clock input
  input         rst_i;    // Asynchronous active high reset
  output reg    cyc_o;    // cycle output
  output        stb_o;    // strobe ouput
  output [ 2:0] cti_o;    // cycle type id
  output [ 1:0] bte_o;    // burst type extension
  output        we_o;     // write enable output
  output [31:0] adr_o;    // address output
  output [ 3:0] sel_o;    // byte select outputs
  input         ack_i;    // wishbone cycle acknowledge
  input         err_i;    // wishbone cycle error
  output [31:0] dat_o;    // wishbone data out           /// TEMP reg ///

  output        sint_o;     // non recoverable error, interrupt host

  // Renderer stuff
  input         write_i;
  output reg    ack_o;

  input [31:2]  render_addr_i;
  input [ 3:0]  render_sel_i;
  input [31:0]  render_dat_i;

  //
  // module body
  //

  assign adr_o  = {render_addr_i, 2'b00};
  assign dat_o  = render_dat_i;
  assign sel_o  = render_sel_i;
  assign sint_o = err_i;
  // We only write, these can be constant
  assign we_o   = 1'b1;
  assign stb_o  = 1'b1;
  assign cti_o  = 3'b000;
  assign bte_o  = 2'b00;

  // Acknowledge when a command has completed
  always @(posedge clk_i or posedge rst_i)
  begin
    //  reset, init component
    if(rst_i)
    begin
      ack_o <= 1'b0;
      cyc_o <= 1'b0;
    end
    // Else, set outputs for next cycle
    else
    begin
      cyc_o <= ack_i   ? 1'b0 : // TODO: connect to pixel fifo rreq instead
               write_i ? 1'b1 :
               cyc_o;
      ack_o <= ack_i; // TODO: always set when fifo isn't full
    end
  end

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/gfx/gfx_wbs.v
// -----------------------------------------------------------------------------
/*
ORSoC GFX accelerator core
Copyright 2012, ORSoC, Per Lenander, Anton Fosselius.

The Wishbone slave component accepts incoming register accesses and puts them in a FIFO queue

Loosely based on the vga lcds wishbone slave (LGPL) in orpsocv2 by Julius Baxter, julius@opencores.org

 This file is part of orgfx.

 orgfx is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version. 

 orgfx is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with orgfx.  If not, see <http://www.gnu.org/licenses/>.

*/

//synopsys translate_off
`include "timescale.v"

//synopsys translate_on

/*
This module acts as the main control interface of the orgfx core. It is built as a 32-bit wishbone slave interface with read and write capabilities.

The module has two states, wait and busy. The module enters busy state when a pipeline operation is triggered by a write to the control register.

In the busy state all incoming wishbone writes are queued up in a 64 item fifo. These will be processed in the order they were received when the module returns to wait state.

The module leaves the busy state and enters wait state when it receives an ack from the pipeline.
*/
module gfx_wbs(
  clk_i, rst_i, adr_i, dat_i, dat_o, sel_i, we_i, stb_i, cyc_i, ack_o, rty_o, err_o, inta_o,
  //src pixels
  src_pixel0_x_o, src_pixel0_y_o, src_pixel1_x_o, src_pixel1_y_o,
  // dest pixels
  dest_pixel_x_o, dest_pixel_y_o, dest_pixel_z_o,
  dest_pixel_id_o,
  // matrix
  aa_o, ab_o, ac_o, tx_o,
  ba_o, bb_o, bc_o, ty_o,
  ca_o, cb_o, cc_o, tz_o,
  transform_point_o,
  forward_point_o,
  // clip pixels
  clip_pixel0_x_o, clip_pixel0_y_o, clip_pixel1_x_o, clip_pixel1_y_o,
  color0_o, color1_o, color2_o,
  u0_o, v0_o, u1_o, v1_o, u2_o, v2_o,
  a0_o, a1_o, a2_o,
  target_base_o, target_size_x_o, target_size_y_o, tex0_base_o, tex0_size_x_o, tex0_size_y_o,
  color_depth_o,
  rect_write_o, line_write_o, triangle_write_o, curve_write_o, interpolate_o,
  writer_sint_i, reader_sint_i,

  pipeline_ack_i,
  transform_ack_i,

  texture_enable_o,
  blending_enable_o,
  global_alpha_o,
  colorkey_enable_o,
  colorkey_o,
  clipping_enable_o,
  inside_o,
  zbuffer_enable_o,
  zbuffer_base_o
  );

  // Load register addresses from gfx_params.v file
  `include "gfx_params.v"

  // Adjust these parameters in gfx_top!
  parameter REG_ADR_HIBIT = 9;
  parameter point_width = 16;
  parameter subpixel_width = 16;
  parameter fifo_depth = 10;

  //
  // inputs & outputs
  //

  // wishbone slave interface
  input                    clk_i;
  input                    rst_i;
  input  [REG_ADR_HIBIT:0] adr_i;
  input             [31:0] dat_i;
  output reg        [31:0] dat_o;
  input             [ 3:0] sel_i;
  input                    we_i;
  input                    stb_i;
  input                    cyc_i;
  output reg               ack_o;
  output reg               rty_o;
  output reg               err_o;
  output reg               inta_o;
  // source pixel
  output [point_width-1:0] src_pixel0_x_o;
  output [point_width-1:0] src_pixel0_y_o;
  output [point_width-1:0] src_pixel1_x_o;
  output [point_width-1:0] src_pixel1_y_o;
  // dest pixel
  output signed [point_width-1:-subpixel_width] dest_pixel_x_o;
  output signed [point_width-1:-subpixel_width] dest_pixel_y_o;
  output signed [point_width-1:-subpixel_width] dest_pixel_z_o;
  output                                  [1:0] dest_pixel_id_o;
  // matrix
  output signed [point_width-1:-subpixel_width] aa_o;
  output signed [point_width-1:-subpixel_width] ab_o;
  output signed [point_width-1:-subpixel_width] ac_o;
  output signed [point_width-1:-subpixel_width] tx_o;
  output signed [point_width-1:-subpixel_width] ba_o;
  output signed [point_width-1:-subpixel_width] bb_o;
  output signed [point_width-1:-subpixel_width] bc_o;
  output signed [point_width-1:-subpixel_width] ty_o;
  output signed [point_width-1:-subpixel_width] ca_o;
  output signed [point_width-1:-subpixel_width] cb_o;
  output signed [point_width-1:-subpixel_width] cc_o;
  output signed [point_width-1:-subpixel_width] tz_o;
  output                                 transform_point_o;
  output                                 forward_point_o;
  // clip pixel
  output [point_width-1:0] clip_pixel0_x_o;
  output [point_width-1:0] clip_pixel0_y_o;
  output [point_width-1:0] clip_pixel1_x_o;
  output [point_width-1:0] clip_pixel1_y_o;

  output [31:0] color0_o;
  output [31:0] color1_o;
  output [31:0] color2_o;

  output [point_width-1:0] u0_o;
  output [point_width-1:0] v0_o;
  output [point_width-1:0] u1_o;
  output [point_width-1:0] v1_o;
  output [point_width-1:0] u2_o;
  output [point_width-1:0] v2_o;

  output [7:0] a0_o;
  output [7:0] a1_o;
  output [7:0] a2_o;

  output            [31:2] target_base_o;
  output [point_width-1:0] target_size_x_o;
  output [point_width-1:0] target_size_y_o;
  output            [31:2] tex0_base_o;
  output [point_width-1:0] tex0_size_x_o;
  output [point_width-1:0] tex0_size_y_o;

  output [1:0]  color_depth_o;
	
  output        rect_write_o;
  output        line_write_o;
  output        triangle_write_o;
  output        curve_write_o;
  output        interpolate_o;

  // status register inputs
  input         writer_sint_i;       // system error interrupt request
  input         reader_sint_i;       // system error interrupt request

  // Pipeline feedback
  input         pipeline_ack_i;             // operation done
  input         transform_ack_i;            // transformation done

  // fragment 
  output        texture_enable_o;
  // blender
  output        blending_enable_o;
  output  [7:0] global_alpha_o;
  output        colorkey_enable_o;
  output [31:0] colorkey_o;

  output        clipping_enable_o;
  output        inside_o;
  output        zbuffer_enable_o;

  output [31:2] zbuffer_base_o;

  //
  // variable declarations
  //

  wire [REG_ADR_HIBIT:0] REG_ADR  = {adr_i[REG_ADR_HIBIT : 2], 2'b00};

  // Declaration of local registers
  reg        [31:0] control_reg, status_reg, target_base_reg, tex0_base_reg;
  reg        [31:0] target_size_x_reg, target_size_y_reg, tex0_size_x_reg, tex0_size_y_reg;
  reg        [31:0] src_pixel_pos_0_x_reg, src_pixel_pos_0_y_reg, src_pixel_pos_1_x_reg, src_pixel_pos_1_y_reg;
  reg        [31:0] clip_pixel_pos_0_x_reg, clip_pixel_pos_0_y_reg, clip_pixel_pos_1_x_reg, clip_pixel_pos_1_y_reg;
  reg signed [31:0] dest_pixel_pos_x_reg, dest_pixel_pos_y_reg, dest_pixel_pos_z_reg;
  reg signed [31:0] aa_reg, ab_reg, ac_reg, tx_reg;
  reg signed [31:0] ba_reg, bb_reg, bc_reg, ty_reg;
  reg signed [31:0] ca_reg, cb_reg, cc_reg, tz_reg;
  reg        [31:0] color0_reg, color1_reg, color2_reg;
  reg        [31:0] u0_reg, v0_reg, u1_reg, v1_reg, u2_reg, v2_reg; 
  reg        [31:0] alpha_reg;
  reg        [31:0] colorkey_reg;
  reg        [31:0] zbuffer_base_reg;

  wire        [1:0] active_point;

  // Wishbone access wires
  wire acc, acc32, reg_acc, reg_wacc;

  // State machine variables
  reg state;
  parameter wait_state = 1'b0, busy_state = 1'b1;

  //
  // Module body
  //

  // wishbone access signals
  assign acc      = cyc_i & stb_i;
  assign acc32    = (sel_i == 4'b1111);
  assign reg_acc  = acc & acc32;
  assign reg_wacc = reg_acc & we_i;

  // Generate wishbone ack
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    ack_o <= 1'b0;
  else
    ack_o <= reg_acc & acc32 & ~ack_o ;

  // Generate wishbone rty
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    rty_o <= 1'b0;
  else
    rty_o <= 1'b0; //reg_acc & acc32 & ~rty_o ;

  // Generate wishbone err
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    err_o <= 1'b0;
  else
    err_o <= acc & ~acc32 & ~err_o;

  // generate interrupt request signal
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    inta_o <= 1'b0;
  else
    inta_o <= writer_sint_i | reader_sint_i; // | other_int | (int_enable & int) | ...

  // generate registers
  always @(posedge clk_i or posedge rst_i)
  begin : gen_regs
    if (rst_i)
      begin
        control_reg             <= 32'h00000000;
        target_base_reg         <= 32'h00000000;
        target_size_x_reg       <= 32'h00000000;
        target_size_y_reg       <= 32'h00000000;
        tex0_base_reg           <= 32'h00000000;
        tex0_size_x_reg         <= 32'h00000000;
        tex0_size_y_reg         <= 32'h00000000;
        src_pixel_pos_0_x_reg   <= 32'h00000000;
        src_pixel_pos_0_y_reg   <= 32'h00000000;
        src_pixel_pos_1_x_reg   <= 32'h00000000;
        src_pixel_pos_1_y_reg   <= 32'h00000000;
        dest_pixel_pos_x_reg    <= 32'h00000000;
        dest_pixel_pos_y_reg    <= 32'h00000000;
        dest_pixel_pos_z_reg    <= 32'h00000000;
        aa_reg                  <= $signed(1'b1 << subpixel_width);
        ab_reg                  <= 32'h00000000;
        ac_reg                  <= 32'h00000000;
        tx_reg                  <= 32'h00000000;
        ba_reg                  <= 32'h00000000;
        bb_reg                  <= $signed(1'b1 << subpixel_width);
        bc_reg                  <= 32'h00000000;
        ty_reg                  <= 32'h00000000;
        ca_reg                  <= 32'h00000000;
        cb_reg                  <= 32'h00000000;
        cc_reg                  <= $signed(1'b1 << subpixel_width);
        tz_reg                  <= 32'h00000000;
        clip_pixel_pos_0_x_reg  <= 32'h00000000;
        clip_pixel_pos_0_y_reg  <= 32'h00000000;
        clip_pixel_pos_1_x_reg  <= 32'h00000000;
        clip_pixel_pos_1_y_reg  <= 32'h00000000;
        color0_reg              <= 32'h00000000;
        color1_reg              <= 32'h00000000;
        color2_reg              <= 32'h00000000;
        u0_reg                  <= 32'h00000000;
        v0_reg                  <= 32'h00000000;
        u1_reg                  <= 32'h00000000;
        v1_reg                  <= 32'h00000000;
        u2_reg                  <= 32'h00000000;
        v2_reg                  <= 32'h00000000;
        alpha_reg	              <= 32'hffffffff;
        colorkey_reg            <= 32'h00000000;
        zbuffer_base_reg        <= 32'h00000000;
      end
    // Read fifo to write to registers
    else if (instruction_fifo_rreq)
    begin
      case (instruction_fifo_q_adr) // synopsis full_case parallel_case
        GFX_CONTROL          : control_reg            <= instruction_fifo_q_data;
        GFX_TARGET_BASE      : target_base_reg        <= instruction_fifo_q_data;
        GFX_TARGET_SIZE_X    : target_size_x_reg      <= instruction_fifo_q_data;
        GFX_TARGET_SIZE_Y    : target_size_y_reg      <= instruction_fifo_q_data;
        GFX_TEX0_BASE        : tex0_base_reg          <= instruction_fifo_q_data;
        GFX_TEX0_SIZE_X      : tex0_size_x_reg        <= instruction_fifo_q_data;
        GFX_TEX0_SIZE_Y      : tex0_size_y_reg        <= instruction_fifo_q_data;
        GFX_SRC_PIXEL0_X     : src_pixel_pos_0_x_reg  <= instruction_fifo_q_data;
        GFX_SRC_PIXEL0_Y     : src_pixel_pos_0_y_reg  <= instruction_fifo_q_data;
        GFX_SRC_PIXEL1_X     : src_pixel_pos_1_x_reg  <= instruction_fifo_q_data;
        GFX_SRC_PIXEL1_Y     : src_pixel_pos_1_y_reg  <= instruction_fifo_q_data;
        GFX_DEST_PIXEL_X     : dest_pixel_pos_x_reg   <= $signed(instruction_fifo_q_data);
        GFX_DEST_PIXEL_Y     : dest_pixel_pos_y_reg   <= $signed(instruction_fifo_q_data);
        GFX_DEST_PIXEL_Z     : dest_pixel_pos_z_reg   <= $signed(instruction_fifo_q_data);
        GFX_AA               : aa_reg                 <= $signed(instruction_fifo_q_data);
        GFX_AB               : ab_reg                 <= $signed(instruction_fifo_q_data);
        GFX_AC               : ac_reg                 <= $signed(instruction_fifo_q_data);
        GFX_TX               : tx_reg                 <= $signed(instruction_fifo_q_data);
        GFX_BA               : ba_reg                 <= $signed(instruction_fifo_q_data);
        GFX_BB               : bb_reg                 <= $signed(instruction_fifo_q_data);
        GFX_BC               : bc_reg                 <= $signed(instruction_fifo_q_data);
        GFX_TY               : ty_reg                 <= $signed(instruction_fifo_q_data);
        GFX_CA               : ca_reg                 <= $signed(instruction_fifo_q_data);
        GFX_CB               : cb_reg                 <= $signed(instruction_fifo_q_data);
        GFX_CC               : cc_reg                 <= $signed(instruction_fifo_q_data);
        GFX_TZ               : tz_reg                 <= $signed(instruction_fifo_q_data);
        GFX_CLIP_PIXEL0_X    : clip_pixel_pos_0_x_reg <= instruction_fifo_q_data;
        GFX_CLIP_PIXEL0_Y    : clip_pixel_pos_0_y_reg <= instruction_fifo_q_data;
        GFX_CLIP_PIXEL1_X    : clip_pixel_pos_1_x_reg <= instruction_fifo_q_data;
        GFX_CLIP_PIXEL1_Y    : clip_pixel_pos_1_y_reg <= instruction_fifo_q_data;
        GFX_COLOR0           : color0_reg             <= instruction_fifo_q_data;
        GFX_COLOR1           : color1_reg             <= instruction_fifo_q_data;
        GFX_COLOR2           : color2_reg             <= instruction_fifo_q_data;
        GFX_U0               : u0_reg                 <= instruction_fifo_q_data;
        GFX_V0               : v0_reg                 <= instruction_fifo_q_data;
        GFX_U1               : u1_reg                 <= instruction_fifo_q_data;
        GFX_V1               : v1_reg                 <= instruction_fifo_q_data;
        GFX_U2               : u2_reg                 <= instruction_fifo_q_data;
        GFX_V2               : v2_reg                 <= instruction_fifo_q_data;
        GFX_ALPHA            : alpha_reg              <= instruction_fifo_q_data;
        GFX_COLORKEY         : colorkey_reg           <= instruction_fifo_q_data;
        GFX_ZBUFFER_BASE     : zbuffer_base_reg       <= instruction_fifo_q_data;
      endcase
    end
    else
    begin
      /* To prevent entering an infinite write cycle, the bits that start pipeline operations are cleared here */
      control_reg[GFX_CTRL_RECT]  <= 1'b0; // Reset rect write
      control_reg[GFX_CTRL_LINE]  <= 1'b0; // Reset line write
      control_reg[GFX_CTRL_TRI]   <= 1'b0; // Reset triangle write
      // Reset matrix transformation bits
      control_reg[GFX_CTRL_FORWARD_POINT]   <= 1'b0;
      control_reg[GFX_CTRL_TRANSFORM_POINT] <= 1'b0;
    end
  end

  // generate status register
  always @(posedge clk_i or posedge rst_i)
  if (rst_i)
    status_reg <= 32'h00000000;
  else
  begin
    status_reg[GFX_STAT_BUSY] <= (state == busy_state);
    status_reg[31:16]         <= instruction_fifo_count;
  end

  // Assign target and texture signals
  assign target_base_o   = target_base_reg[31:2];
  assign target_size_x_o = target_size_x_reg[point_width-1:0];
  assign target_size_y_o = target_size_y_reg[point_width-1:0];
  assign tex0_base_o     = tex0_base_reg[31:2];
  assign tex0_size_x_o   = tex0_size_x_reg[point_width-1:0];
  assign tex0_size_y_o   = tex0_size_y_reg[point_width-1:0];

  // Assign source pixel signals
  assign src_pixel0_x_o      = src_pixel_pos_0_x_reg[point_width-1:0];
  assign src_pixel0_y_o      = src_pixel_pos_0_y_reg[point_width-1:0];
  assign src_pixel1_x_o      = src_pixel_pos_1_x_reg[point_width-1:0];
  assign src_pixel1_y_o      = src_pixel_pos_1_y_reg[point_width-1:0];
  // Assign clipping pixel signals
  assign clip_pixel0_x_o     = clip_pixel_pos_0_x_reg[point_width-1:0];
  assign clip_pixel0_y_o     = clip_pixel_pos_0_y_reg[point_width-1:0];
  assign clip_pixel1_x_o     = clip_pixel_pos_1_x_reg[point_width-1:0];
  assign clip_pixel1_y_o     = clip_pixel_pos_1_y_reg[point_width-1:0];
  // Assign destination pixel signals
  assign dest_pixel_x_o[point_width-1:-subpixel_width] = $signed(dest_pixel_pos_x_reg);
  assign dest_pixel_y_o[point_width-1:-subpixel_width] = $signed(dest_pixel_pos_y_reg);
  assign dest_pixel_z_o[point_width-1:-subpixel_width] = $signed(dest_pixel_pos_z_reg);
  assign dest_pixel_id_o                               = active_point;

  // Assign matrix signals
  assign aa_o = $signed(aa_reg);
  assign ab_o = $signed(ab_reg);
  assign ac_o = $signed(ac_reg);
  assign tx_o = $signed(tx_reg);
  assign ba_o = $signed(ba_reg);
  assign bb_o = $signed(bb_reg);
  assign bc_o = $signed(bc_reg);
  assign ty_o = $signed(ty_reg);
  assign ca_o = $signed(ca_reg);
  assign cb_o = $signed(cb_reg);
  assign cc_o = $signed(cc_reg);
  assign tz_o = $signed(tz_reg);

  // Assign color signals
  assign color0_o            = color0_reg;
  assign color1_o            = color1_reg;
  assign color2_o            = color2_reg;

  assign u0_o                = u0_reg[point_width-1:0];
  assign v0_o                = v0_reg[point_width-1:0];
  assign u1_o                = u1_reg[point_width-1:0];
  assign v1_o                = v1_reg[point_width-1:0];
  assign u2_o                = u2_reg[point_width-1:0];
  assign v2_o                = v2_reg[point_width-1:0];

  assign a0_o                = alpha_reg[31:24];
  assign a1_o                = alpha_reg[23:16];
  assign a2_o                = alpha_reg[15:8];
  assign global_alpha_o      = alpha_reg[7:0];
  assign colorkey_o          = colorkey_reg;
  assign zbuffer_base_o      = zbuffer_base_reg[31:2];



  // decode control register
  assign color_depth_o      = control_reg[GFX_CTRL_COLOR_DEPTH+1:GFX_CTRL_COLOR_DEPTH];

  assign texture_enable_o   = control_reg[GFX_CTRL_TEXTURE ];
  assign blending_enable_o  = control_reg[GFX_CTRL_BLENDING];
  assign colorkey_enable_o  = control_reg[GFX_CTRL_COLORKEY];
  assign clipping_enable_o  = control_reg[GFX_CTRL_CLIPPING];
  assign zbuffer_enable_o   = control_reg[GFX_CTRL_ZBUFFER ];

  assign rect_write_o       = control_reg[GFX_CTRL_RECT    ];
  assign line_write_o       = control_reg[GFX_CTRL_LINE    ];
  assign triangle_write_o   = control_reg[GFX_CTRL_TRI     ];
  assign curve_write_o      = control_reg[GFX_CTRL_CURVE   ];
  assign interpolate_o      = control_reg[GFX_CTRL_INTERP  ];
  assign inside_o           = control_reg[GFX_CTRL_INSIDE  ];

  assign active_point       = control_reg[GFX_CTRL_ACTIVE_POINT+1:GFX_CTRL_ACTIVE_POINT];
  assign forward_point_o    = control_reg[GFX_CTRL_FORWARD_POINT];
  assign transform_point_o  = control_reg[GFX_CTRL_TRANSFORM_POINT];

  // decode status register TODO

  // assign output from wishbone reads. Note that this does not account for pending writes in the fifo!
  always @(posedge clk_i or posedge rst_i)
    if(rst_i)
      dat_o <= 32'h0000_0000;
    else
      case (REG_ADR) // synopsis full_case parallel_case
        GFX_CONTROL       : dat_o <= control_reg;
        GFX_STATUS        : dat_o <= status_reg;
        GFX_TARGET_BASE   : dat_o <= target_base_reg;
        GFX_TARGET_SIZE_X : dat_o <= target_size_x_reg;
        GFX_TARGET_SIZE_Y : dat_o <= target_size_y_reg;
        GFX_TEX0_BASE     : dat_o <= tex0_base_reg;
        GFX_TEX0_SIZE_X   : dat_o <= tex0_size_x_reg;
        GFX_TEX0_SIZE_Y   : dat_o <= tex0_size_y_reg;
        GFX_SRC_PIXEL0_X  : dat_o <= src_pixel_pos_0_x_reg;
        GFX_SRC_PIXEL0_Y  : dat_o <= src_pixel_pos_0_y_reg;
        GFX_SRC_PIXEL1_X  : dat_o <= src_pixel_pos_1_x_reg;
        GFX_SRC_PIXEL1_Y  : dat_o <= src_pixel_pos_1_y_reg;
        GFX_DEST_PIXEL_X  : dat_o <= dest_pixel_pos_x_reg;
        GFX_DEST_PIXEL_Y  : dat_o <= dest_pixel_pos_y_reg;
        GFX_DEST_PIXEL_Z  : dat_o <= dest_pixel_pos_z_reg;
        GFX_AA            : dat_o <= aa_reg;
        GFX_AB            : dat_o <= ab_reg;
        GFX_AC            : dat_o <= ac_reg;
        GFX_TX            : dat_o <= tx_reg;
        GFX_BA            : dat_o <= ba_reg;
        GFX_BB            : dat_o <= bb_reg;
        GFX_BC            : dat_o <= bc_reg;
        GFX_TY            : dat_o <= ty_reg;
        GFX_CA            : dat_o <= ca_reg;
        GFX_CB            : dat_o <= cb_reg;
        GFX_CC            : dat_o <= cc_reg;
        GFX_TZ            : dat_o <= tz_reg;
        GFX_CLIP_PIXEL0_X : dat_o <= clip_pixel_pos_0_x_reg;
        GFX_CLIP_PIXEL0_Y : dat_o <= clip_pixel_pos_0_y_reg;
        GFX_CLIP_PIXEL1_X : dat_o <= clip_pixel_pos_1_x_reg;
        GFX_CLIP_PIXEL1_Y : dat_o <= clip_pixel_pos_1_y_reg;
        GFX_COLOR0        : dat_o <= color0_reg;
        GFX_COLOR1        : dat_o <= color1_reg;
        GFX_COLOR2        : dat_o <= color2_reg;
        GFX_U0            : dat_o <= u0_reg;
        GFX_V0            : dat_o <= v0_reg;
        GFX_U1            : dat_o <= u1_reg;
        GFX_V1            : dat_o <= v1_reg;
        GFX_U2            : dat_o <= u2_reg;
        GFX_V2            : dat_o <= v2_reg;
        GFX_ALPHA         : dat_o <= alpha_reg;
        GFX_COLORKEY      : dat_o <= colorkey_reg;
        GFX_ZBUFFER_BASE  : dat_o <= zbuffer_base_reg;
        default           : dat_o <= 32'h0000_0000;
      endcase

  // State machine
  always @(posedge clk_i or posedge rst_i)
  if(rst_i)
    state <= wait_state;
  else
    case (state)
      wait_state:
        // Signals that trigger pipeline operations 
        if(rect_write_o | line_write_o | triangle_write_o |
           forward_point_o | transform_point_o)
          state <= busy_state;

      busy_state:
        // If a pipeline operation is finished, go back to wait state
        if(pipeline_ack_i | transform_ack_i)
          state <= wait_state;
    endcase

  /* Instruction fifo */
  wire        instruction_fifo_wreq;
  wire [31:0] instruction_fifo_q_data;
  wire        instruction_fifo_rreq;
  wire        instruction_fifo_valid_out;
  reg         fifo_read_ack;
  reg         fifo_write_ack;
  wire [REG_ADR_HIBIT:0] instruction_fifo_q_adr;
  wire    [fifo_depth:0] instruction_fifo_count;

  always @(posedge clk_i or posedge rst_i)
    if(rst_i)
      fifo_read_ack <= 1'b0;
    else
      fifo_read_ack <= instruction_fifo_rreq & !fifo_read_ack;

  wire ready_next_cycle = (state == wait_state) & ~rect_write_o & ~line_write_o & ~triangle_write_o & ~forward_point_o & ~transform_point_o;
  assign instruction_fifo_rreq = instruction_fifo_valid_out & ~fifo_read_ack & ready_next_cycle;

  always @(posedge clk_i or posedge rst_i)
    if(rst_i)
      fifo_write_ack <= 1'b0;
    else
      fifo_write_ack <= instruction_fifo_wreq ? !fifo_write_ack : reg_wacc;

  assign instruction_fifo_wreq = reg_wacc & ~fifo_write_ack;

  // TODO: 1024 places large enough?
  basic_fifo instruction_fifo(
  .clk_i     ( clk_i ),
  .rst_i     ( rst_i ),

  .data_i    ( {REG_ADR, dat_i} ),
  .enq_i     ( instruction_fifo_wreq ),
  .full_o    ( ), // TODO: use?
  .count_o   ( instruction_fifo_count ),

  .data_o    ( {instruction_fifo_q_adr, instruction_fifo_q_data} ),
  .valid_o   ( instruction_fifo_valid_out ),
  .deq_i     ( instruction_fifo_rreq )
  );

defparam instruction_fifo.fifo_width     = REG_ADR_HIBIT+1+32;
defparam instruction_fifo.fifo_bit_depth = fifo_depth;

endmodule



