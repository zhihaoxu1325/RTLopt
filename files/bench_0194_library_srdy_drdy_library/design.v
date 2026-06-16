// Curated RTL benchmark case.
// case_id: bench_0194_library_srdy_drdy_library
// source_project: library_srdy-drdy_library
// top_module: port_macro


// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/port_macro.v
// -----------------------------------------------------------------------------
module port_macro
  #(parameter port_num = 0,
    parameter lpsz = 12,
    parameter lpdsz = 13)
  (input         clk,
   input         reset,

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                drf_drdy,               // To dealloc of deallocator.v
   input [`LL_PG_ASZ-1:0] f2d_data,             // To dealloc of deallocator.v
   input                f2d_srdy,               // To dealloc of deallocator.v
   input                gmii_rx_clk,            // To port_clocking of port_clocking.v, ...
   input                gmii_rx_dv,             // To rx_gigmac of sd_rx_gigmac.v
   input [7:0]          gmii_rxd,               // To rx_gigmac of sd_rx_gigmac.v
   input                lnp_drdy,               // To alloc of allocator.v
   input                par_drdy,               // To alloc of allocator.v
   input [`LL_PG_ASZ-1:0] parr_page,            // To alloc of allocator.v
   input                parr_srdy,              // To alloc of allocator.v
   input                pbra_drdy,              // To alloc of allocator.v
   input                pbrd_drdy,              // To dealloc of deallocator.v
   input [`PFW_SZ-1:0]  pbrr_data,              // To dealloc of deallocator.v
   input                pbrr_srdy,              // To dealloc of deallocator.v
   input                pm2f_drdy,              // To pm2f_join of sd_ajoin2.v
   input                rlp_drdy,               // To dealloc of deallocator.v
   input [`LL_PG_ASZ:0] rlpr_data,              // To dealloc of deallocator.v
   input                rlpr_srdy,              // To dealloc of deallocator.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [`LL_PG_ASZ*2-1:0] drf_page_list,     // From dealloc of deallocator.v
   output               drf_srdy,               // From dealloc of deallocator.v
   output               f2d_drdy,               // From dealloc of deallocator.v
   output               gmii_tx_en,             // From tx_gmii of sd_tx_gigmac.v
   output [7:0]         gmii_txd,               // From tx_gmii of sd_tx_gigmac.v
   output [`LL_LNP_SZ-1:0] lnp_pnp,             // From alloc of allocator.v
   output               lnp_srdy,               // From alloc of allocator.v
   output               par_srdy,               // From alloc of allocator.v
   output               parr_drdy,              // From alloc of allocator.v
   output [`PBR_SZ-1:0] pbra_data,              // From alloc of allocator.v
   output               pbra_srdy,              // From alloc of allocator.v
   output [`PBR_SZ-1:0] pbrd_data,              // From dealloc of deallocator.v
   output               pbrd_srdy,              // From dealloc of deallocator.v
   output               pbrr_drdy,              // From dealloc of deallocator.v
   output [(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0] pm2f_data,// From pm2f_join of sd_ajoin2.v
   output               pm2f_srdy,              // From pm2f_join of sd_ajoin2.v
   output [`LL_PG_ASZ-1:0] rlp_rd_page,         // From dealloc of deallocator.v
   output               rlp_srdy,               // From dealloc of deallocator.v
   output               rlpr_drdy              // From dealloc of deallocator.v
   // End of automatics
   );

  wire [`RX_USG_SZ-1:0] rx_usage;
  wire [`TX_USG_SZ-1:0] tx_usage;
  wire [`PFW_SZ-1:0]	prx_data;		// From fifo_rx of sd_fifo_b.v
  wire [`PFW_SZ-1:0]	ptx_data;		// From fifo_tx of sd_fifo_b.v
  wire [`PFW_SZ-1:0]	rttx_data;		// From ring_tap of port_ring_tap.v
  wire [1:0] 		rxg_code;		// From rx_sync_fifo of sd_fifo_s.v
  wire [7:0] 		rxg_data;		// From rx_sync_fifo of sd_fifo_s.v
  wire [`PFW_SZ-1:0]	ctx_data;		// From oflow of egr_oflow.v
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire                  a2f_drdy;               // From pm2f_join of sd_ajoin2.v
  wire [`LL_PG_ASZ-1:0] a2f_end;                // From alloc of allocator.v
  wire                  a2f_srdy;               // From alloc of allocator.v
  wire [`LL_PG_ASZ-1:0] a2f_start;              // From alloc of allocator.v
  wire                  crx_abort;              // From con of concentrator.v
  wire                  crx_commit;             // From con of concentrator.v
  wire [`PFW_SZ-1:0]    crx_data;               // From con of concentrator.v
  wire                  crx_drdy;               // From alloc of allocator.v
  wire                  crx_srdy;               // From con of concentrator.v
  wire                  gmii_rx_reset;          // From port_clocking of port_clocking.v
  wire [`PAR_DATA_SZ-1:0] p2f_data;             // From pkt_parse of pkt_parse.v
  wire                  p2f_drdy;               // From pm2f_join of sd_ajoin2.v
  wire                  p2f_srdy;               // From pkt_parse of pkt_parse.v
  wire [1:0]            pdo_code;               // From pkt_parse of pkt_parse.v
  wire [7:0]            pdo_data;               // From pkt_parse of pkt_parse.v
  wire                  pdo_drdy;               // From con of concentrator.v
  wire                  pdo_srdy;               // From pkt_parse of pkt_parse.v
  wire                  ptx_drdy;               // From dst of distributor.v
  wire                  ptx_srdy;               // From dealloc of deallocator.v
  wire [1:0]            rxc_rxg_code;           // From rx_gigmac of sd_rx_gigmac.v
  wire [7:0]            rxc_rxg_data;           // From rx_gigmac of sd_rx_gigmac.v
  wire                  rxc_rxg_drdy;           // From rx_sync_fifo of sd_fifo_s.v
  wire                  rxc_rxg_srdy;           // From rx_gigmac of sd_rx_gigmac.v
  wire                  rxg_drdy;               // From pkt_parse of pkt_parse.v
  wire                  rxg_srdy;               // From rx_sync_fifo of sd_fifo_s.v
  wire [1:0]            txg_code;               // From dst of distributor.v
  wire [7:0]            txg_data;               // From dst of distributor.v
  wire                  txg_drdy;               // From tx_gmii of sd_tx_gigmac.v
  wire                  txg_srdy;               // From dst of distributor.v
  // End of automatics


  port_clocking port_clocking
    (/*AUTOINST*/
     // Outputs
     .gmii_rx_reset                     (gmii_rx_reset),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .gmii_rx_clk                       (gmii_rx_clk));

/*  sd_rx_gigmac AUTO_TEMPLATE
 (
   .clk				(gmii_rx_clk),
   .reset			(gmii_rx_reset),
   .rxg_\(.*\)			(rxc_rxg_\1[]),
 );
 */
  sd_rx_gigmac rx_gigmac
    (
     .cfg_check_crc (1'b0),
     /*AUTOINST*/
     // Outputs
     .rxg_srdy                          (rxc_rxg_srdy),          // Templated
     .rxg_code                          (rxc_rxg_code[1:0]),     // Templated
     .rxg_data                          (rxc_rxg_data[7:0]),     // Templated
     // Inputs
     .clk                               (gmii_rx_clk),           // Templated
     .reset                             (gmii_rx_reset),         // Templated
     .gmii_rx_dv                        (gmii_rx_dv),
     .gmii_rxd                          (gmii_rxd[7:0]),
     .rxg_drdy                          (rxc_rxg_drdy));          // Templated

/* sd_fifo_s AUTO_TEMPLATE
 (
     .c_clk				(gmii_rx_clk),
     .c_reset				(gmii_rx_reset),
     .c_data				({rxc_rxg_code,rxc_rxg_data}),
     .p_data				({rxg_code,rxg_data}),
     .p_clk				(clk),
     .p_reset				(reset),
  .c_\(.*\)			(rxc_rxg_\1[]),
  .p_\(.*\)			(rxg_\1[]),
 );
 */
  sd_fifo_s #(8+2,16,1) rx_sync_fifo
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (rxc_rxg_drdy),          // Templated
     .p_srdy                            (rxg_srdy),              // Templated
     .p_data                            ({rxg_code,rxg_data}),   // Templated
     // Inputs
     .c_clk                             (gmii_rx_clk),           // Templated
     .c_reset                           (gmii_rx_reset),         // Templated
     .c_srdy                            (rxc_rxg_srdy),          // Templated
     .c_data                            ({rxc_rxg_code,rxc_rxg_data}), // Templated
     .p_clk                             (clk),                   // Templated
     .p_reset                           (reset),                 // Templated
     .p_drdy                            (rxg_drdy));              // Templated

  pkt_parse #(port_num) pkt_parse
    (
     /*AUTOINST*/
     // Outputs
     .rxg_drdy                          (rxg_drdy),
     .p2f_srdy                          (p2f_srdy),
     .p2f_data                          (p2f_data[`PAR_DATA_SZ-1:0]),
     .pdo_srdy                          (pdo_srdy),
     .pdo_code                          (pdo_code[1:0]),
     .pdo_data                          (pdo_data[7:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .rxg_srdy                          (rxg_srdy),
     .rxg_code                          (rxg_code[1:0]),
     .rxg_data                          (rxg_data[7:0]),
     .p2f_drdy                          (p2f_drdy),
     .pdo_drdy                          (pdo_drdy));

/* concentrator AUTO_TEMPLATE
 (
    .c_\(.*\)     (pdo_\1[]),
    .p_\(.*\)     (crx_\1[]),
 );
 */
  concentrator con
    (/*AUTOINST*/
     // Outputs
     .c_drdy                            (pdo_drdy),              // Templated
     .p_data                            (crx_data[`PFW_SZ-1:0]), // Templated
     .p_srdy                            (crx_srdy),              // Templated
     .p_commit                          (crx_commit),            // Templated
     .p_abort                           (crx_abort),             // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_data                            (pdo_data[7:0]),         // Templated
     .c_code                            (pdo_code[1:0]),         // Templated
     .c_srdy                            (pdo_srdy),              // Templated
     .p_drdy                            (crx_drdy));              // Templated

/* allocator AUTO_TEMPLATE
 (
 );
 */
  allocator alloc
    (/*AUTOINST*/
     // Outputs
     .crx_drdy                          (crx_drdy),
     .par_srdy                          (par_srdy),
     .parr_drdy                         (parr_drdy),
     .lnp_srdy                          (lnp_srdy),
     .lnp_pnp                           (lnp_pnp[`LL_LNP_SZ-1:0]),
     .pbra_data                         (pbra_data[`PBR_SZ-1:0]),
     .pbra_srdy                         (pbra_srdy),
     .a2f_start                         (a2f_start[`LL_PG_ASZ-1:0]),
     .a2f_end                           (a2f_end[`LL_PG_ASZ-1:0]),
     .a2f_srdy                          (a2f_srdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .crx_abort                         (crx_abort),
     .crx_commit                        (crx_commit),
     .crx_data                          (crx_data[`PFW_SZ-1:0]),
     .crx_srdy                          (crx_srdy),
     .par_drdy                          (par_drdy),
     .parr_srdy                         (parr_srdy),
     .parr_page                         (parr_page[`LL_PG_ASZ-1:0]),
     .lnp_drdy                          (lnp_drdy),
     .pbra_drdy                         (pbra_drdy),
     .a2f_drdy                          (a2f_drdy));

/* sd_ajoin2 AUTO_TEMPLATE
 (
   .c2_data                     ({a2f_end,a2f_start}),
   .c1_\(.*\)			(p2f_\1[]),
   .c2_\(.*\)			(a2f_\1[]),
   .p_\(.*\)			(pm2f_\1[]),
 );
 */
  sd_ajoin2 #(.c1_width(`PAR_DATA_SZ), .c2_width(`LL_PG_ASZ*2)) pm2f_join
    (/*AUTOINST*/
     // Outputs
     .c1_drdy                           (p2f_drdy),              // Templated
     .c2_drdy                           (a2f_drdy),              // Templated
     .p_srdy                            (pm2f_srdy),             // Templated
     .p_data                            (pm2f_data[(`PAR_DATA_SZ)+(`LL_PG_ASZ*2)-1:0]), // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c1_srdy                           (p2f_srdy),              // Templated
     .c1_data                           (p2f_data[(`PAR_DATA_SZ)-1:0]), // Templated
     .c2_srdy                           (a2f_srdy),              // Templated
     .c2_data                           ({a2f_end,a2f_start}),   // Templated
     .p_drdy                            (pm2f_drdy));             // Templated

  deallocator dealloc
    (/*AUTOINST*/
     // Outputs
     .f2d_drdy                          (f2d_drdy),
     .rlp_srdy                          (rlp_srdy),
     .rlp_rd_page                       (rlp_rd_page[`LL_PG_ASZ-1:0]),
     .rlpr_drdy                         (rlpr_drdy),
     .drf_srdy                          (drf_srdy),
     .drf_page_list                     (drf_page_list[`LL_PG_ASZ*2-1:0]),
     .pbrd_data                         (pbrd_data[`PBR_SZ-1:0]),
     .pbrd_srdy                         (pbrd_srdy),
     .pbrr_drdy                         (pbrr_drdy),
     .ptx_srdy                          (ptx_srdy),
     .ptx_data                          (ptx_data[`PFW_SZ-1:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .port_num                          (port_num[1:0]),
     .f2d_srdy                          (f2d_srdy),
     .f2d_data                          (f2d_data[`LL_PG_ASZ-1:0]),
     .rlp_drdy                          (rlp_drdy),
     .rlpr_srdy                         (rlpr_srdy),
     .rlpr_data                         (rlpr_data[`LL_PG_ASZ:0]),
     .drf_drdy                          (drf_drdy),
     .pbrd_drdy                         (pbrd_drdy),
     .pbrr_srdy                         (pbrr_srdy),
     .pbrr_data                         (pbrr_data[`PFW_SZ-1:0]),
     .ptx_drdy                          (ptx_drdy));

/* distributor AUTO_TEMPLATE
 (
    .p_\(.*\)    (txg_\1[]),
 );
 */
  distributor dst
    (/*AUTOINST*/
     // Outputs
     .ptx_drdy                          (ptx_drdy),
     .p_srdy                            (txg_srdy),              // Templated
     .p_code                            (txg_code[1:0]),         // Templated
     .p_data                            (txg_data[7:0]),         // Templated
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .ptx_srdy                          (ptx_srdy),
     .ptx_data                          (ptx_data[`PFW_SZ-1:0]),
     .p_drdy                            (txg_drdy));              // Templated

  sd_tx_gigmac tx_gmii
    (/*AUTOINST*/
     // Outputs
     .gmii_tx_en                        (gmii_tx_en),
     .gmii_txd                          (gmii_txd[7:0]),
     .txg_drdy                          (txg_drdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .txg_srdy                          (txg_srdy),
     .txg_code                          (txg_code[1:0]),
     .txg_data                          (txg_data[7:0]));
  
endmodule // port_macro
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/buffers" "../../../rtl/verilog/forks")
// End:  

// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/allocator.v
// -----------------------------------------------------------------------------
`timescale 1ns/100ps

module allocator
  (
   input         clk,    //% System clock
   input         reset,  //% Active high reset

   input	       	crx_abort,  //% asserted at end of packet, indicates packet drop
   input       		crx_commit, //% asserted at end of packet, indicates packet accept
   input [`PFW_SZ-1:0]	crx_data,   //% Incoming data from accumulator
   output 		crx_drdy,   //% destination flow control
   input		crx_srdy,   //% source data available

   // page request i/f
   output            par_srdy,
   input             par_drdy,

   input             parr_srdy,
   output            parr_drdy,
   input [`LL_PG_ASZ-1:0]  parr_page,

   // link to next page i/f
   output reg        lnp_srdy,
   input             lnp_drdy,
   output reg [`LL_LNP_SZ-1:0] lnp_pnp,

   // interface to packet buffer
   output [`PBR_SZ-1:0] pbra_data,
   output               pbra_srdy,
   input                pbra_drdy,

   output [`LL_PG_ASZ-1:0] a2f_start,
   output [`LL_PG_ASZ-1:0] a2f_end,
   output reg              a2f_srdy,
   input                   a2f_drdy
   );

  wire 			   icrx_srdy;

  reg 			   icrx_drdy;
  wire 			   icrx_commit, icrx_abort;
  wire [`PFW_SZ-1:0] 	   icrx_data;
   
  reg [2:0]                pcount;
  reg [1:0]                word_count;
  reg [`LL_PG_ASZ-1:0]     start_pg;
  reg [`LL_PG_ASZ-1:0]     cur_pg;
  reg [`LL_PG_ASZ-1:0]     nxt_start_pg;
  reg [`LL_PG_ASZ-1:0]     nxt_cur_pg;

  reg                      obuf_srdy;
  wire [`PB_ASZ-1:0]       obuf_addr;
  reg [1:0]                cur_line, nxt_cur_line;
  wire                     obuf_drdy;

  wire [`PBR_SZ-1:0]       obuf_pbr_word;

  wire                     pp_srdy;
  reg                      pp_drdy;
  wire [`LL_PG_ASZ-1:0]    pp_page;

  assign obuf_addr = { cur_pg, cur_line };

  //------------------------------------------------------------
  // icarus debug

/* -----\/----- EXCLUDED -----\/-----
  tape_record #(9+`PFW_SZ+`LL_PG_ASZ) record0
    (.clk (clk), 
    .data ({ reset,
             crx_abort,
             crx_commit,
             crx_srdy,
             par_drdy,
             parr_srdy,
             lnp_drdy,
             pbra_drdy,
             a2f_drdy, crx_data, parr_page }));
 -----/\----- EXCLUDED -----/\----- */

  //------------------------------------------------------------
  // page prefetch FIFO and state machine logic
  //------------------------------------------------------------

  wire                     pcount_inc = par_srdy & par_drdy;
  wire                     pcount_dec = pp_srdy & pp_drdy;
  assign par_srdy = (pcount < 4);

  always @(posedge clk)
    begin
      if (reset)
        pcount <= 0;
      else
        begin
          if (pcount_inc & !pcount_dec)
            pcount <= pcount + 1;
          else if (pcount_dec & !pcount_inc)
            pcount <= pcount - 1;
        end
    end

  sd_fifo_s #(.width(`LL_PG_ASZ), .depth(4)) page_prefetch
    (
     .c_clk      (clk),
     .c_reset    (reset),
     .p_clk      (clk),
     .p_reset    (reset),

     .c_srdy   (parr_srdy),
     .c_drdy   (parr_drdy),
     .c_data   (parr_page),

     .p_srdy   (pp_srdy),
     .p_drdy   (pp_drdy),
     .p_data   (pp_page));

  always @(posedge clk)
    begin
      if (pp_srdy & pp_drdy)
        $display ("%t %m: Storing in page %0d", $time, pp_page);
      if (crx_srdy & crx_drdy & crx_commit)
        $display ("%t %m: Sent packet (%0d,%0d)", $time, start_pg, cur_pg);
    end

  sd_iohalf #(.width(`PFW_SZ+2)) crx_buf
    (.clk (clk), .reset (reset),

     .c_srdy (crx_srdy),
     .c_drdy (crx_drdy),
     .c_data ({crx_commit,crx_abort,crx_data}),

     .p_srdy (icrx_srdy),
     .p_drdy (icrx_drdy),
     .p_data ({icrx_commit,icrx_abort,icrx_data}));
  
  //------------------------------------------------------------
  // 
  //------------------------------------------------------------

  assign a2f_start = start_pg;
  assign a2f_end   = cur_pg;

  reg [2:0] state, nxt_state;
  localparam s_idle = 0, s_noalloc = 1, s_link = 2, s_commit = 3,
    s_abort = 4, s_commit2 = 5;

  always @*
    begin
      icrx_drdy = 0;
      obuf_srdy = 0;
      lnp_srdy = 0;
      nxt_start_pg = start_pg;
      nxt_cur_pg = cur_pg;
      nxt_cur_line = cur_line;
      lnp_pnp = { cur_pg, 1'b0, pp_page };
      a2f_srdy = 0;
      pp_drdy = 0;

      case (state)
        s_idle :
          begin
            // if output buffer is ready and a page is allocated,
            // preload the address counters to get ready for a packet
            if (pp_srdy)
              begin
                nxt_start_pg = pp_page;
                nxt_cur_pg   = pp_page;
                nxt_cur_line = 0;
                nxt_state = s_noalloc;
                pp_drdy = 1;
              end
          end // case: s_idle

        s_noalloc :
          begin
            if (icrx_srdy & obuf_drdy)
              begin
                icrx_drdy = 1;
                obuf_srdy = 1;
                nxt_cur_line = cur_line + 1;
                if (`ANY_EOP(icrx_data[`PRW_PCC]))
                  begin
                    if (icrx_commit)
                      nxt_state = s_commit;
                    else
                      nxt_state = s_abort;
                  end
                else if (cur_line == 3)
                  begin
                    nxt_state = s_link;
                  end
              end // if (icrx_srdy & obuf_drdy)
          end // case: s_noalloc


        s_link :
          begin
            if (pp_srdy)
              begin
                lnp_srdy = 1;
                if (lnp_drdy)
                  begin
                    nxt_cur_pg = pp_page;
                    pp_drdy = 1;
                    nxt_state = s_noalloc;
                  end
              end   
          end // case: s_link

        s_commit :
          begin
            lnp_pnp = { cur_pg, `LL_ENDPAGE };
            lnp_srdy = 1;
            if (lnp_drdy)
              nxt_state = s_commit2;
          end

        s_commit2 :
          begin
            a2f_srdy = 1;
            if (a2f_drdy)
              nxt_state = s_idle;
          end

        s_abort :
          begin
            // need to reclaim pages here
          end

        default : nxt_state = s_idle;
      endcase // case (state)
    end
        
  always @(posedge clk)
    begin
      if (reset)
        begin
          state <= s_idle;
          /*AUTORESET*/
          // Beginning of autoreset for uninitialized flops
          cur_line <= 2'h0;
          cur_pg <= {(1+(`LL_PG_ASZ-1)){1'b0}};
          start_pg <= {(1+(`LL_PG_ASZ-1)){1'b0}};
          // End of automatics
        end
      else
        begin
          start_pg <= nxt_start_pg;
          cur_pg   <= nxt_cur_pg;
          cur_line <= nxt_cur_line;
          state    <= nxt_state;
        end
    end

  assign obuf_pbr_word[`PBR_DATA] = icrx_data;
  assign obuf_pbr_word[`PBR_ADDR] = obuf_addr;
  assign obuf_pbr_word[`PBR_WRITE] = 1'b1;
  assign obuf_pbr_word[`PBR_PORT]  = 0;

  sd_iohalf #(.width(`PBR_SZ)) obuf
    (.clk (clk), .reset (reset),

     .c_srdy (obuf_srdy),
     .c_drdy (obuf_drdy),
     .c_data (obuf_pbr_word),

     .p_srdy (pbra_srdy),
     .p_drdy (pbra_drdy),
     .p_data (pbra_data));
            
endmodule // allocator


// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/concentrator.v
// -----------------------------------------------------------------------------
module concentrator
  (input         clk,
   input         reset,
   input [7:0]	 c_data,
   input [1:0]   c_code,
   input		 c_srdy,			// To sdin of sd_input.v
   input		 p_drdy,			// To sdout of sd_output.v
   output  		 c_drdy,			// From sdin of sd_input.v
   output reg [`PFW_SZ-1:0] p_data,			// From sdout of sd_output.v
   output reg		 p_srdy,
   output reg            p_commit,
   output reg            p_abort
   // End of automatics
   );

  wire [7:0]	ip_data;		// From sdin of sd_input.v
  wire [1:0] 	ip_code;
  reg			ip_drdy;
  wire			ip_srdy;		// From sdin of sd_input.v

  reg [`PFW_SZ-1:0] 	nxt_p_data;
  reg 			nxt_p_srdy;
  reg [2:0] 		count, nxt_count;
  reg 			nxt_p_abort, nxt_p_commit;
  wire [1:0]            pkt_code = p_data[`PRW_PCC];

  sd_input #(8+2) sdin
    (
     // Outputs
     .c_drdy				(c_drdy),
     .ip_srdy				(ip_srdy),
     .ip_data				({ip_code,ip_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(c_srdy),
     .c_data				({c_code,c_data}),
     .ip_drdy				(ip_drdy));

  always @*
    begin
      nxt_p_data = p_data;
      nxt_p_srdy = p_srdy;
      nxt_p_data = p_data;
      nxt_count = count;
      nxt_p_commit = p_commit;
      nxt_p_abort  = 0;

      if (p_srdy)
	begin
	  if (p_drdy)
	    begin
	      nxt_p_srdy = 0;
	      nxt_p_commit = 0;
	      ip_drdy = 1;
	      nxt_p_data[`PRW_PCC] = `PCC_DATA;
	      nxt_count = 0;

	      if (ip_srdy)
		begin
		  nxt_count = 1;
		  if (ip_code != `PCC_DATA)
		    nxt_p_data[`PRW_PCC] = ip_code;
		  nxt_p_data[63:56] = ip_data;
		end
	    end
	end
      else if (ip_srdy)
	begin
	  ip_drdy = 1;
	  if (ip_code != `PCC_DATA)
	    nxt_p_data[`PRW_PCC] = ip_code;

	  nxt_count = count + 1;
	  case (count)
	    0 : nxt_p_data[63:56] = ip_data;
	    1 : nxt_p_data[55:48] = ip_data;
	    2 : nxt_p_data[47:40] = ip_data;
	    3 : nxt_p_data[39:32] = ip_data;
	    4 : nxt_p_data[31:24] = ip_data;
	    5 : nxt_p_data[23:16] = ip_data;
	    6 : nxt_p_data[15: 8] = ip_data;
	    7 : nxt_p_data[ 7: 0] = ip_data;
	  endcase // case (count)
	  if ((count == 7) | (ip_code == `PCC_BADEOP) | (ip_code == `PCC_EOP))
	    begin
	      if (ip_code == `PCC_EOP)
		begin
		  nxt_p_commit = 1;
		  nxt_p_srdy   = 1;
                  nxt_p_data[`PRW_VALID] = count + 1;
		end
	      else if ((ip_code == `PCC_BADEOP) || (pkt_code == `PCC_BADEOP))
		begin
		  nxt_p_abort = 1;
		end
	      else
                begin
		  nxt_p_srdy = 1;
                  nxt_p_data[`PRW_VALID] = 0;
                end
	    end
	end
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  /*AUTORESET*/
	  // Beginning of autoreset for uninitialized flops
	  count <= 3'h0;
	  p_abort <= 1'h0;
	  p_commit <= 1'h0;
	  p_data <= {(1+(`PFW_SZ-1)){1'b0}};
	  p_srdy <= 1'h0;
	  // End of automatics
	end
      else
	begin
	  p_commit <= #1 nxt_p_commit;
	  p_abort  <= #1 nxt_p_abort;
	  p_srdy   <= #1 nxt_p_srdy;
	  p_data   <= #1 nxt_p_data;
	  count    <= #1 nxt_count;
	end // else: !if(reset)
    end
  
endmodule // template_1i1o

// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/deallocator.v
// -----------------------------------------------------------------------------
module deallocator
  (
   input          clk,
   input          reset,

   input [1:0]    port_num,

   // packet input from FIB
   input            f2d_srdy,
   output reg       f2d_drdy,
   input [`LL_PG_ASZ-1:0] f2d_data,

   // read link page i/f
   output reg         rlp_srdy,
   input              rlp_drdy,
   output [`LL_PG_ASZ-1:0]  rlp_rd_page,

   // read link page reply i/f
   input                rlpr_srdy,
   output reg           rlpr_drdy,
   input [`LL_PG_ASZ:0] rlpr_data,
   
   // page dereference interface
   output reg           drf_srdy,
   input                drf_drdy,
   output [`LL_PG_ASZ*2-1:0]  drf_page_list,

   // interface to packet buffer
   output  [`PBR_SZ-1:0] pbrd_data,
   output reg            pbrd_srdy,
   input                 pbrd_drdy,

   // return interface from packet buffer
   input                 pbrr_srdy,
   output                pbrr_drdy,
   input [`PFW_SZ-1:0]   pbrr_data,

   // i/f to distributor
   output               ptx_srdy,
   input                ptx_drdy,
   output [`PFW_SZ-1:0] ptx_data
   
   );

  reg [2:0]             state, nxt_state;
  reg [`LL_PG_ASZ-1:0]        start, nxt_start;
  reg [`LL_PG_ASZ-1:0]        cur, nxt_cur;
  reg [1:0]             lcount, nxt_lcount;

  reg                   pb_req, eop_seen, nxt_eop_seen;

  assign rlp_rd_page = cur;
  assign drf_page_list = { start, cur };

  assign pbrd_data[`PBR_DATA] = 0;
  assign pbrd_data[`PBR_ADDR] = { cur, lcount };
  assign pbrd_data[`PBR_WRITE] = 1'b0;
  assign pbrd_data[`PBR_PORT] = port_num;

  sd_iohalf #(.width(`PFW_SZ)) pkt_rd_buf
    (.clk (clk), .reset (reset),

     .c_srdy (pbrr_srdy),
     .c_drdy (pbrr_drdy),
     .c_data (pbrr_data),

     .p_srdy (ptx_srdy),
     .p_drdy (ptx_drdy),
     .p_data (ptx_data));

  always @(posedge clk)
    begin
      if (reset)
        pb_req <= 0;
      else
        begin
          if (ptx_srdy & ptx_drdy)
            pb_req <= 0;
          else if (pbrd_srdy & pbrd_drdy)
            pb_req <= 1;
        end
    end // always @ (posedge clk)

  localparam s_idle = 0, s_fetch = 1, s_link = 2, s_link_reply = 3,
    s_return = 4;

  always @(posedge clk)
    begin
      if (f2d_srdy & f2d_drdy)
        $display ("%t %m: Dealloc packet %0d", $time, f2d_data);
      if (drf_srdy & drf_drdy)
        $display ("%t %m: Returning packet (%0d,%0d)", $time, start, cur);
    end

  always @*
    begin
      f2d_drdy = 0;
      nxt_state = state;
      nxt_start = start;
      nxt_cur = cur;
      nxt_lcount = lcount;
      nxt_eop_seen = eop_seen;
      rlp_srdy = 0;
      rlpr_drdy = 0;
      drf_srdy = 0;
      pbrd_srdy = 0;

      case (state)
        s_idle :
          begin
            f2d_drdy = 1;
            if (f2d_srdy)
              begin
                nxt_start = f2d_data;
                nxt_cur   = f2d_data;
                nxt_state = s_fetch;
                nxt_eop_seen = 0;
                nxt_lcount = 0;
              end
          end

        // if no requests to the packet buffer are outstanding,
        // then dispatch another request to the packet buffer.
        // If this was the last request of a page then go to
        // link page fetch state.
        s_fetch :
          begin
            if (ptx_srdy & (`ANY_EOP(ptx_data[`PRW_PCC])))
              nxt_eop_seen = 1;

            if (!pb_req & !eop_seen)
              begin
                pbrd_srdy = 1;
                if (pbrd_drdy)
                  begin
                    nxt_lcount = lcount + 1;
                    if (lcount == 3)
                      nxt_state = s_link;
                  end
              end
            else if (eop_seen)
              nxt_state = s_link;
          end // case: s_fetch

        s_link :
          begin
            rlp_srdy = 1;
            if (rlp_drdy)
              nxt_state = s_link_reply;
          end

        s_link_reply :
          begin
            rlpr_drdy = 1;
            if (rlpr_srdy)
              begin
                if (rlpr_data == `LL_ENDPAGE)
                  nxt_state = s_return;
                else
                  begin
                    nxt_cur = rlpr_data;
                    nxt_state = s_fetch;
                  end
              end
          end // case: s_link_reply

        s_return :
          begin
            drf_srdy = 1;
            if (drf_drdy)
              nxt_state = s_idle;
          end

        default : nxt_state = s_idle;
      endcase // case (state)
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
        begin
          state <= s_idle;
          /*AUTORESET*/
          // Beginning of autoreset for uninitialized flops
          cur <= {(1+(`LL_PG_ASZ-1)){1'b0}};
          eop_seen <= 1'h0;
          lcount <= 2'h0;
          start <= {(1+(`LL_PG_ASZ-1)){1'b0}};
          // End of automatics
        end
      else
        begin
          state <= nxt_state;
          start <= nxt_start;
          cur <= nxt_cur;
          lcount <= nxt_lcount;
          eop_seen <= nxt_eop_seen;
        end
    end

endmodule // deallocator

// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/distributor.v
// -----------------------------------------------------------------------------
module distributor
  (input         clk,
   input         reset,

   input         ptx_srdy,
   output        ptx_drdy,
   input [`PFW_SZ-1:0] ptx_data,

   output        p_srdy,
   input         p_drdy,
   output [1:0]  p_code,
   output [7:0]  p_data
   );

  reg [7:0]	ic_data;
  reg [1:0]     ic_code;
  wire          ic_drdy;
  reg           ic_srdy;
  wire [`PFW_SZ-1:0] ip_data;
  reg                ip_drdy;
  wire               ip_srdy;
  reg [7:0]          remain, nxt_remain;

  sd_input #(`PFW_SZ) sdin
    (
     // Outputs
     .c_drdy				(ptx_drdy),
     .ip_srdy				(ip_srdy),
     .ip_data				(ip_data),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(ptx_srdy),
     .c_data				(ptx_data),
     .ip_drdy				(ip_drdy));

  always @*
    begin
      nxt_remain = remain;
      ic_srdy = 0;
      ip_drdy = 0;

      case (remain)
        0 : ic_data = ip_data[63:56];
        7 : ic_data = ip_data[55:48];
        6 : ic_data = ip_data[47:40];
        5 : ic_data = ip_data[39:32];
        4 : ic_data = ip_data[31:24];
        3 : ic_data = ip_data[23:16];
        2 : ic_data = ip_data[15: 8];
        1 : ic_data = ip_data[ 7: 0];
        default : ic_data = ip_data[63:56];
      endcase
      
      if (ip_srdy & ic_drdy)
        begin
          if (remain == 0)
            begin
              ic_srdy = 1;
              if (ip_data[`PRW_VALID] == 0)
                nxt_remain = 7;
              else
                nxt_remain = ip_data[`PRW_VALID]-1;
              
              if (nxt_remain == 0)
                ip_drdy = 1;
              
              if (ip_data[`PRW_PCC] == `PCC_SOP)
                ic_code = `PCC_SOP;
              else
                ic_code = `PCC_DATA;
            end // if (remain == 0)
          else
            begin
              ic_srdy = 1;
              nxt_remain = remain - 1;
              if (nxt_remain == 0)
                begin
                  ip_drdy = 1;
                  if ((ip_data[`PRW_PCC] == `PCC_EOP) |
                      (ip_data[`PRW_PCC] == `PCC_BADEOP))
                    ic_code = ip_data[`PRW_PCC];
                  else
                    ic_code = `PCC_DATA;
                end
              else
                ic_code = `PCC_DATA;
            end // else: !if(remain == 0)
        end
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
        remain <= #1 0;
      else
        remain <= #1 nxt_remain;
    end

  sd_output #(8+2) sdout
    (
     // Outputs
     .ic_drdy				(ic_drdy),
     .p_srdy				(p_srdy),
     .p_data				({p_code,p_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .ic_srdy				(ic_srdy),
     .ic_data				({ic_code,ic_data}),
     .p_drdy				(p_drdy));

endmodule // template_1i1o

// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/memory" "../../../rtl/verilog/forks")
// End:  

// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/mac_crc32.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
//  8-bit parallel CRC generator
//----------------------------------------------------------------------

module mac_crc32
  (input         clk,
   input         clear,   // also functions as reset
   input [7:0]   data,
   input         valid,

   output [31:0] crc);

  reg [31:0] 	 icrc;
  reg [31:0] 	 nxt_icrc;
  integer 	 i;
  
  assign 	 crc = ~icrc;
  
  always @*
    begin
      nxt_icrc[7:0] = icrc[7:0] ^ data;
      nxt_icrc[31:8] = icrc[31:8];

      for (i=0; i<8; i=i+1)
	begin
	  if (nxt_icrc[0])
	    nxt_icrc = nxt_icrc[31:1] ^ 32'hEDB88320;
	  else
	    nxt_icrc = nxt_icrc[31:1];
	end
    end // always @ *
      
  always @(posedge clk)
    begin
      if (clear)
	icrc <= #1 {32{1'b1}};
      else if (valid)
	icrc <= nxt_icrc;
    end

endmodule

// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/pkt_parse.v
// -----------------------------------------------------------------------------
// packet parser
//
// Takes input packet on rxg interface and copies packet to pdo
// interface, without changing packet data.  If packet is too
// short to be parsed, converts packet to an error code.
//
// If packet parses correctly and is not an error packet, sends
// a parse result to the FIB for lookup.  Otherwise aborts the
// packet so it is flushed from the packet FIFO.
module pkt_parse
  #(parameter port_num=0)
  (input          clk,
   input          reset,

   input          rxg_srdy,
   output         rxg_drdy,
   input  [1:0]   rxg_code,
   input [7:0]    rxg_data,

   output reg     p2f_srdy,
   input          p2f_drdy,
   output reg [`PAR_DATA_SZ-1:0] p2f_data,

   output         pdo_srdy,
   input          pdo_drdy,
   output [1:0]   pdo_code,
   output [7:0]   pdo_data
   );

  wire 		  lp_srdy;
  reg 		  lp_drdy;
  wire [1:0] 	  lp_code;
  wire [7:0] 	  lp_data;
  reg 		  lc_srdy;
  wire 		  lc_drdy;
  reg [1:0] 	  lc_code;

  reg [3:0] 	  count, nxt_count;
  reg 		  nxt_p2f_srdy;
  reg [`PAR_DATA_SZ-1:0] nxt_p2f_data;

  sd_input #(8+2) rxg_in
    (
     // Outputs
     .c_drdy				(rxg_drdy),
     .ip_srdy				(lp_srdy),
     .ip_data				({lp_code,lp_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(rxg_srdy),
     .c_data				({rxg_code,rxg_data}),
     .ip_drdy				(lp_drdy));

  always @*
    begin
      nxt_p2f_srdy = p2f_srdy;
      nxt_p2f_data = p2f_data;
      nxt_count = count;
      lc_code = lp_code;

      if (p2f_srdy)
	begin
	  lp_drdy = 0;
	  lc_srdy = 0;
	  if (p2f_drdy)
	    nxt_p2f_srdy = 0;
	end
      else if (lp_srdy & lc_drdy)
	begin
	  lp_drdy = 1;
	  lc_srdy = 1;
	
	  case (count)
	    0, 1, 2, 3, 4, 5 : 
	      begin
		if (count == 0)
                  begin
		    nxt_p2f_data = 0;
                    nxt_p2f_data[`PAR_SRCPORT] = port_num;
                  end

		if ((lp_code == `PCC_EOP) || (lp_code == `PCC_BADEOP))
		  begin
		    lc_code = `PCC_BADEOP;
		    nxt_count = 0;
		  end
		else
		  begin
		    nxt_p2f_data[`PAR_MACDA] = { p2f_data[`PAR_MACDA] << 8, lp_data };
		    nxt_count = count + 1;
		  end
	      end // case: 0, 1, 2, 3, 4, 5

	    6, 7, 8, 9, 10, 11 : 
	      begin
		if ((lp_code == `PCC_EOP) || (lp_code == `PCC_BADEOP))
		  begin
		    lc_code = `PCC_BADEOP;
		    nxt_count = 0;
		  end
		else
		  begin
		    nxt_p2f_data[`PAR_MACSA] = { p2f_data[`PAR_MACSA] << 8, lp_data };
		    nxt_count = count + 1;
		  end
	      end // case: 6, 7, 8, 9, 10, 11

	    // done with parsing, wait for packet EOP
	    12 :
	      begin
		if (lp_code == `PCC_EOP)
		  begin
		    nxt_p2f_srdy = 1;
		    nxt_count = 0;
		  end
		else if (lp_code == `PCC_BADEOP)
		  nxt_count = 0;
	      end

	    default : nxt_count = 0;
	  endcase // case (count)
	end
      else
	begin
	  lp_drdy = 0;
	  lc_srdy = 0;
	end // else: !if(lp_srdy & lc_drdy)
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  /*AUTORESET*/
	  // Beginning of autoreset for uninitialized flops
	  count <= 4'h0;
	  p2f_data <= {(1+(`PAR_DATA_SZ-1)){1'b0}};
	  p2f_srdy <= 1'h0;
	  // End of automatics
	end
      else
	begin
	  p2f_srdy <= #1 nxt_p2f_srdy;
	  p2f_data <= #1 nxt_p2f_data;
	  count <= #1 nxt_count;
	end
    end

  sd_output #(8+2) par_out
    (
     // Outputs
     .ic_drdy				(lc_drdy),
     .p_srdy				(pdo_srdy),
     .p_data				({pdo_code,pdo_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .ic_srdy				(lc_srdy),
     .ic_data				({lp_code,lp_data}),
     .p_drdy				(pdo_drdy));

endmodule // pkt_parse
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/memory" "../../../rtl/verilog/forks")
// End:  

 

// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/port_clocking.v
// -----------------------------------------------------------------------------
module port_clocking
  (input         clk,
   input         reset,
   input         gmii_rx_clk,
   output        gmii_rx_reset
   );

  // if this were a testable design, clock muxing logic would go here as well

  reg 		 rx_sync1, rx_sync2;

  always @(posedge gmii_rx_clk)
    begin
      rx_sync1 <= #1 reset;
      rx_sync2 <= #1 rx_sync1;
    end

  assign gmii_rx_reset = reset | rx_sync2;

endmodule // port_clocking

// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/sd_rx_gigmac.v
// -----------------------------------------------------------------------------
// mock-up of RX portion of gigabit ethernet MAC
// performs packet reception and creates internal
// packet codes, as well as checking CRC on incoming
// packets.

// incoming data is synchronous to "clk", which should
// be the GMII RX clock.  Output data is also synchronous
// to this clock, so needs to go through a sync FIFO.

// If output is not ready while receiving data,
// truncates the packet and makes it an error packet.

module sd_rx_gigmac
  (
   input        clk,
   input        reset,
   input        gmii_rx_dv,
   input [7:0]  gmii_rxd,

   output       rxg_srdy,
   input        rxg_drdy,
   output [1:0] rxg_code,
   output [7:0] rxg_data,

   input        cfg_check_crc
   );

  reg 		rxdv1, rxdv2;
  reg [7:0] 	rxd1, rxd2;
  reg [31:0]    pkt_crc;
  reg [3:0] 	valid_bits, nxt_valid_bits;
  reg [31:0]    nxt_pkt_crc;

  reg [6:0] 	state, nxt_state;
  reg 		ic_srdy;
  wire 		ic_drdy;
  reg [1:0] 	ic_code;
  reg [7:0] 	ic_data;
  wire [31:0]   crc;

  reg           crc_valid;
  reg           crc_clear;
  
  mac_crc32 crc_chk
    (
     .clear                             (crc_clear),
     .data                              (rxd2),
     .valid                             (crc_valid),

     /*AUTOINST*/
     // Outputs
     .crc                               (crc[31:0]),
     // Inputs
     .clk                               (clk));

  always @(posedge clk)
    begin
      if (reset)
	begin
	  rxd1  <= #1 0;
	  rxdv1 <= #1 0;
	  rxd2  <= #1 0;
	  rxdv2 <= #1 0;
          pkt_crc <= #1 0;
	end
      else
	begin
	  rxd1  <= #1 gmii_rxd;
	  rxdv1 <= #1 gmii_rx_dv;
	  rxd2  <= #1 rxd1;
	  rxdv2 <= #1 rxdv1;
          pkt_crc <= #1 nxt_pkt_crc;
	end
    end // always @ (posedge clk)

  localparam s_idle = 0, s_preamble = 1, s_sop = 2, s_payload = 3, s_trunc = 4, s_sink = 5, s_eop = 6;
  localparam ns_idle = 1, ns_preamble = 2, ns_sop = 4, ns_payload = 8, ns_trunc = 16, ns_sink = 32;

  always @*
    begin
      ic_srdy = 0;
      ic_code = `PCC_DATA;
      ic_data = 0;
      nxt_valid_bits = valid_bits;
      nxt_pkt_crc = pkt_crc;
      crc_valid = 0;
      crc_clear = 0;

      case (1'b1)
	state[s_idle] :
	  begin
            crc_clear = 1;
	    nxt_pkt_crc  = 0;
	    nxt_valid_bits = 0;
	    if (rxdv2 & (rxd2 == `GMII_SFD))
	      begin
		nxt_state = ns_sop;
	      end
	    else if (rxdv2)
	      begin
		nxt_state = ns_preamble;
	      end
	  end // case: state[s_idle]
	
	state[s_preamble]:
	  begin
	    if (!rxdv2)
	      nxt_state = ns_idle;
	    else if (rxd2 == `GMII_SFD)
	      nxt_state = ns_sop;
	  end

	state[s_sop] :
	  begin
	    if (!rxdv2)
	      begin
		nxt_state = ns_idle;
	      end
	    else if (!ic_drdy)
	      nxt_state = ns_sink;
	    else
	      begin
		ic_srdy = 1;
		ic_code = `PCC_SOP;
		ic_data = rxd2;
                crc_valid = 1;
                nxt_pkt_crc = { rxd2, pkt_crc[31:8] };
		nxt_state = ns_payload;
	      end
	  end // case: state[ns_payload]

	state[s_payload] :
	  begin
	    if (!ic_drdy)
	      nxt_state = ns_trunc;
	    else if (!rxdv1)
	      begin
		//nxt_state = ns_idle;
		ic_srdy = 0;
		ic_data = rxd2;
                crc_valid = 1;
                nxt_pkt_crc = { rxd2, pkt_crc[31:8] };
                nxt_state = 1 << s_eop;
	      end
	    else
	      begin
		ic_srdy = 1;
		ic_code = `PCC_DATA;
		ic_data = rxd2;
                crc_valid = 1;
                nxt_pkt_crc = { rxd2, pkt_crc[31:8] };
	      end // else: !if(!rxdv1)
	  end // case: state[ns_payload]


        state[s_eop] :
          begin
            ic_srdy =1;
            ic_data = pkt_crc[31:24];
            if ((pkt_crc == crc) | !cfg_check_crc)
              begin
                ic_code = `PCC_EOP;
              end
            else
              ic_code = `PCC_BADEOP;

            if (ic_drdy)
              nxt_state = 1 << s_idle;
          end
          
	state[s_trunc] :
	  begin
	    ic_srdy = 1;
	    ic_code = `PCC_BADEOP;
	    ic_data = 0;
	    if (ic_drdy)
	      nxt_state = ns_sink;
	  end

	state[s_sink] :
	  begin
	    if (!rxdv2)
	      nxt_state = ns_idle;
	  end

	default : nxt_state = ns_idle;
      endcase // case (1'b1)	
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  state <= #1 1;
	  /*AUTORESET*/
          // Beginning of autoreset for uninitialized flops
          pkt_crc <= 32'h0;
          valid_bits <= 4'h0;
          // End of automatics
	end
      else
	begin
	  pkt_crc  <= #1 nxt_pkt_crc;
	  state    <= #1 nxt_state;
	  valid_bits <= #1 nxt_valid_bits;
	end // else: !if(reset)
    end // always @ (posedge clk)

  sd_output #(8+2) out_hold
    (.clk (clk), .reset (reset),
     .ic_srdy (ic_srdy),
     .ic_drdy (ic_drdy),
     .ic_data ({ic_code,ic_data}),
     .p_srdy  (rxg_srdy),
     .p_drdy  (rxg_drdy),
     .p_data  ({rxg_code, rxg_data}));

endmodule // sd_rx_gigmac

// -----------------------------------------------------------------------------
// Source file: examples/bridge/rtl/sd_tx_gigmac.v
// -----------------------------------------------------------------------------
// mock-up of RX portion of gigabit ethernet MAC
// performs packet reception and creates internal
// packet codes, as well as checking CRC on incoming
// packets.

// If output is not ready while receiving data,
// truncates the packet and makes it an error packet.

module sd_tx_gigmac
  (
   input        clk,
   input        reset,
   output reg        gmii_tx_en,
   output reg [7:0]  gmii_txd,

   input       txg_srdy,
   output      txg_drdy,
   input [1:0] txg_code,
   input [7:0] txg_data
   );

  wire 	       ip_srdy;
  reg 	       ip_drdy;
  wire [1:0]   ip_code;
  wire [7:0]   ip_data;
  reg [3:0]    count, nxt_count;

  reg [7:0]    nxt_gmii_txd;
  reg 	       nxt_gmii_tx_en;
  reg [5:0]    state, nxt_state;

  wire [31:0]  crc;
  reg          clear;
  reg          crc_valid;
  
  localparam s_idle = 0, s_preamble = 1, s_payload = 2, s_ipg = 3, s_badcrc = 4, s_goodcrc = 5;
  localparam ns_idle = 1, ns_preamble = 2, ns_payload = 4, ns_ipg = 8;

  sd_input #(8+2) in_hold
    (
     // Outputs
     .c_drdy				(txg_drdy),
     .ip_srdy				(ip_srdy),
     .ip_data				({ip_code,ip_data}),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(txg_srdy),
     .c_data				({txg_code,txg_data}),
     .ip_drdy				(ip_drdy));

  mac_crc32 crcgen
    (
     .data                              (ip_data[7:0]),
     .valid                             (crc_valid),
     /*AUTOINST*/
     // Outputs
     .crc                               (crc[31:0]),
     // Inputs
     .clk                               (clk),
     .clear                             (clear));

  always @*
    begin
      ip_drdy = 0;
      nxt_count = count;
      nxt_gmii_tx_en = 0;
      nxt_gmii_txd = gmii_txd;
      clear = 0;
      crc_valid = 0;

      case (1'b1)
	state[s_idle] :
	  begin
	    if (ip_srdy & (ip_code == `PCC_SOP))
	      begin
		nxt_gmii_tx_en = 1;
		nxt_gmii_txd = `GMII_PRE;
		nxt_count = 1;
		nxt_state = ns_preamble;
                clear = 1;
	      end
	    else
	      begin
		ip_drdy = 1;
	      end // else: !if(ip_srdy & (ip_code == `PCC_SOP))
	  end // case: state[s_idle]

	state[s_preamble] :
	  begin
	    nxt_count = count + 1;
	    nxt_gmii_tx_en = 1;
	    if (count == 6)
              begin
	        nxt_gmii_txd = `GMII_SFD;
	        nxt_state = ns_payload;
              end
	    else
	      nxt_gmii_txd = `GMII_PRE;
	  end // case: state[s_preamble]

	state[s_payload] :
	  begin
	    ip_drdy = 1;
	    nxt_gmii_tx_en = 1;
            nxt_gmii_txd = ip_data;
            crc_valid = 1;
            
	    if (!ip_srdy | ((ip_code == `PCC_EOP) | (ip_code == `PCC_BADEOP)))
	      begin
		nxt_count = 0;
                if (ip_code == `PCC_EOP)
                  nxt_state = 1 << s_goodcrc;
                else
		  nxt_state = 1 << s_badcrc;
	      end
	  end // case: state[s_payload]

        state[s_goodcrc] :
          begin
            nxt_count = count + 1;
            nxt_gmii_tx_en = 1;
            case (count)
              0 : nxt_gmii_txd = crc[7:0];
              1 : nxt_gmii_txd = crc[15:8];
              2 : nxt_gmii_txd = crc[23:16];
              3 : nxt_gmii_txd = crc[31:24];
            endcase // case (count)
            
            if (count == 3)
              begin
                nxt_state = 1 << s_ipg;
              end
          end

        state[s_badcrc] :
          begin
           nxt_count = count + 1;
            nxt_gmii_tx_en = 1;
            nxt_gmii_txd   = 8'h0;
            
            if (count == 3)
              begin
                nxt_state = 1 << s_ipg;
              end
          end

	state[s_ipg] :
	  begin
	    nxt_gmii_tx_en = 0;
	    ip_drdy = 0;
	    nxt_count = count + 1;
	    if (count == 11)
	      nxt_state = ns_idle;
	  end

	default : nxt_state = ns_idle;
      endcase // case (1'b1)
    end // always @ *

  always @(posedge clk)
    begin
      if (reset)
	begin
	  state <= #1 1;
	  /*AUTORESET*/
          // Beginning of autoreset for uninitialized flops
          count <= 4'h0;
          gmii_tx_en <= 1'h0;
          gmii_txd <= 8'h0;
          // End of automatics
	end
      else
	begin
	  state <= #1 nxt_state;
	  count <= #1 nxt_count;
	  gmii_tx_en <= #1 nxt_gmii_tx_en;
	  gmii_txd   <= #1 nxt_gmii_txd;
	end // else: !if(reset)
    end // always @ (posedge clk)

endmodule // sd_rx_gigmac
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/memory" "../../../rtl/verilog/forks")
// End:  

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/buffers/sd_fifo_head_s.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
// Srdy/Drdy FIFO Head "S"
//
// Building block for FIFOs.  The "S" (big) FIFO is design for smaller
// FIFOs based around memories or flops, with sizes that are a power of 2.
//
// The "S" FIFO can be used as a two-clock asynchronous FIFO.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_fifo_head_s
  #(parameter depth=16,
    parameter async=0,
    parameter asz=$clog2(depth)
    )
    (
     input       clk,
     input       reset,
     input       c_srdy,
     output      c_drdy,

     output [asz:0]     wrptr_head,
     output [asz-1:0]   wr_addr,
     output reg         wr_en,
     input [asz:0]      rdptr_tail

     );

  reg [asz:0] 		wrptr, nxt_wrptr;
  reg [asz:0] 		wrptr_p1;
  reg 			empty, full;
  wire [asz:0] 		rdptr;

  assign c_drdy = !full;
  assign wr_addr = wrptr[asz-1:0];
  
  always @*
    begin
      wrptr_p1 = wrptr + 1;
      
      full = ((wrptr[asz-1:0] == rdptr[asz-1:0]) && 
	      (wrptr[asz] == ~rdptr[asz]));
	  
      if (c_srdy & !full)
	nxt_wrptr = wrptr_p1;
      else
	nxt_wrptr = wrptr;

      wr_en = (c_srdy & !full);
    end
      
  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
	  wrptr <= `SDLIB_DELAY 0;
	end
      else
	begin
	  wrptr <= `SDLIB_DELAY nxt_wrptr;
	end // else: !if(reset)
    end // always @ (posedge clk)

  function [asz:0] bin2grey;
    input [asz:0] bin_in;
    integer 	  b;
    begin
      bin2grey[asz] = bin_in[asz];
      for (b=0; b<asz; b=b+1)
	bin2grey[b] = bin_in[b] ^ bin_in[b+1];
    end
  endfunction // for

  function [asz:0] grey2bin;
    input [asz:0] grey_in;
    integer 	  b;
    begin
      grey2bin[asz] = grey_in[asz];
      for (b=asz-1; b>=0; b=b-1)
	grey2bin[b] = grey_in[b] ^ grey2bin[b+1];
    end
  endfunction

  assign wrptr_head = (async) ? bin2grey(wrptr) : wrptr;
  assign rdptr = (async)? grey2bin(rdptr_tail) : rdptr_tail;
  
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/buffers/sd_fifo_s.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
// Srdy/Drdy FIFO "S"
//
// Building block for FIFOs.  The "S" (small or synchronizer) FIFO is 
// designed for smaller FIFOs based around memories or flops, with 
// sizes that are a power of 2.
//
// The "S" FIFO can be used as a two-clock asynchronous FIFO.  When the
// async parameter is set to 1, the pointers will be converted from
// binary to grey code and double-synchronized.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_fifo_s
  #(parameter width=8,
    parameter depth=16,
    parameter async=0
    )
    (
     input       c_clk,
     input       c_reset,
     input       c_srdy,
     output      c_drdy,
     input [width-1:0] c_data,

     input       p_clk,
     input       p_reset,
     output      p_srdy,
     input       p_drdy,
     output  [width-1:0] p_data
     );

  localparam asz = $clog2(depth);

  reg [width-1:0] 	mem [0:depth-1];
  wire [width-1:0] 	mem_rddata;
  wire 			rd_en;
  wire [asz:0] 		rdptr_tail, rdptr_tail_sync;
  wire			wr_en;
  wire [asz:0] 		wrptr_head, wrptr_head_sync;
  wire [asz-1:0] 	rd_addr, wr_addr;

/* -----\/----- EXCLUDED -----\/-----
  always @(posedge c_clk)
    if (wr_en)
      mem[wr_addr] <= `SDLIB_DELAY c_data;

  assign mem_rddata = mem[rd_addr];
 -----/\----- EXCLUDED -----/\----- */
  behave2p_mem #(width, depth) mem2p
    (.d_out (p_data),
     .wr_en (wr_en),
     .rd_en (rd_en),
     .wr_clk (c_clk),
     .wr_addr (wr_addr),
     .rd_clk  (p_clk),
     .rd_addr (rd_addr),
     .d_in    (c_data));


  sd_fifo_head_s #(depth, async) head
    (
     // Outputs
     .c_drdy				(c_drdy),
     .wrptr_head			(wrptr_head),
     .wr_en				(wr_en),
     .wr_addr                           (wr_addr),
     // Inputs
     .clk				(c_clk),
     .reset				(c_reset),
     .c_srdy				(c_srdy),
     .rdptr_tail			(rdptr_tail_sync));

  sd_fifo_tail_s #(depth, async) tail
    (
     // Outputs
     .rdptr_tail			(rdptr_tail),
     .rd_en				(rd_en),
     .rd_addr                           (rd_addr),
     .p_srdy				(p_srdy),
     // Inputs
     .clk				(p_clk),
     .reset				(p_reset),
     .wrptr_head			(wrptr_head_sync),
     .p_drdy				(p_drdy));

/* -----\/----- EXCLUDED -----\/-----
  always @(posedge p_clk)
    begin
      if (rd_en)
	p_data <= `SDLIB_DELAY mem_rddata;
    end
 -----/\----- EXCLUDED -----/\----- */

  generate
    if (async)
      begin : gen_sync
	reg [asz:0] r_sync1, r_sync2;
	reg [asz:0] w_sync1, w_sync2;

	always @(posedge p_clk)
	  begin
	    w_sync1 <= `SDLIB_DELAY wrptr_head;
	    w_sync2 <= `SDLIB_DELAY w_sync1;
	  end

	always @(posedge c_clk)
	  begin
	    r_sync1 <= `SDLIB_DELAY rdptr_tail;
	    r_sync2 <= `SDLIB_DELAY r_sync1;
	  end

	assign wrptr_head_sync = w_sync2;
	assign rdptr_tail_sync = r_sync2;
      end
    else
      begin : gen_nosync
	assign wrptr_head_sync = wrptr_head;
	assign rdptr_tail_sync = rdptr_tail;
      end
  endgenerate	

endmodule // sd_fifo_s

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/buffers/sd_fifo_tail_s.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
// Srdy/Drdy FIFO Head "S"
//
// Building block for FIFOs.  The "S" (big) FIFO is design for smaller
// FIFOs based around memories or flops, with sizes that are a power of 2.
//
// The "S" FIFO can be used as a two-clock asynchronous FIFO.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_fifo_tail_s
  #(parameter depth=16,
    parameter async=0,
    parameter asz=$clog2(depth)
    )
    (
     input                  clk,
     input                  reset,

     input [asz:0]          wrptr_head,
     output [asz:0]         rdptr_tail,

     output reg             rd_en,
     output [asz-1:0]       rd_addr,

     output reg             p_srdy,
     input                  p_drdy
     );

  reg [asz:0] 		rdptr;
  reg [asz:0] 		nxt_rdptr;
  reg [asz:0] 		rdptr_p1;
  reg 			empty;
  reg 			nxt_p_srdy;
  wire [asz:0] 		wrptr;

  assign rd_addr = nxt_rdptr[asz-1:0];

  always @*
    begin
      rdptr_p1 = rdptr + 1;
      
      empty = (wrptr == rdptr);

      if (p_drdy & p_srdy)
	nxt_rdptr = rdptr_p1;
      else
	nxt_rdptr = rdptr;
	  
      nxt_p_srdy = (wrptr != nxt_rdptr);
      rd_en = (p_drdy & p_srdy) | (!empty & !p_srdy);
    end
      
  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
	  rdptr <= `SDLIB_DELAY 0;
	  p_srdy  <= `SDLIB_DELAY 0;
	end
      else
	begin
	  rdptr <= `SDLIB_DELAY nxt_rdptr;
	  p_srdy <= `SDLIB_DELAY nxt_p_srdy;
	end // else: !if(reset)
    end // always @ (posedge clk)

  function [asz:0] bin2grey;
    input [asz:0] bin_in;
    integer 	  b;
    begin
      bin2grey[asz] = bin_in[asz];
      for (b=0; b<asz; b=b+1)
	bin2grey[b] = bin_in[b] ^ bin_in[b+1];
    end
  endfunction // for

  function [asz:0] grey2bin;
    input [asz:0] grey_in;
    integer 	  b;
    begin
      grey2bin[asz] = grey_in[asz];
      for (b=asz-1; b>=0; b=b-1)
	grey2bin[b] = grey_in[b] ^ grey2bin[b+1];
    end
  endfunction

  assign rdptr_tail = (async) ? bin2grey(rdptr) : rdptr;
  assign wrptr = (async)? grey2bin(wrptr_head) : wrptr_head;
  
endmodule // sd_fifo_head_s

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/closure/sd_input.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
// Srdy/Drdy input block
//
// Halts timing on c_drdy.  Intended to be used on the input side of
// a design block.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_input
  #(parameter width = 8)
  (
   input              clk,
   input              reset,
   input              c_srdy,
   output reg         c_drdy,
   input [width-1:0]  c_data,

   output reg         ip_srdy,
   input              ip_drdy,
   output reg [width-1:0] ip_data
   );

  reg 	  load;
  reg 	  drain;
  reg 	  occupied, nxt_occupied;
  reg [width-1:0] hold, nxt_hold;
  reg 		  nxt_c_drdy;

  
  always @*
    begin
      nxt_hold = hold;
      nxt_occupied = occupied;

      drain = occupied & ip_drdy;
      load = c_srdy & c_drdy & (!ip_drdy | drain);
      if (occupied)
	ip_data = hold;
      else
	ip_data = c_data;

      ip_srdy = (c_srdy & c_drdy) | occupied;

      if (load)
	begin
	  nxt_hold = c_data;
	  nxt_occupied =  1;
	end
      else if (drain)
	nxt_occupied = 0;

      nxt_c_drdy = (!occupied & !load) | (drain & !load);
    end

  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
	  hold     <= `SDLIB_DELAY 0;
	  occupied <= `SDLIB_DELAY 0;
	  c_drdy   <= `SDLIB_DELAY 0;
	end
      else
	begin
	  hold     <= `SDLIB_DELAY nxt_hold;
	  occupied <= `SDLIB_DELAY nxt_occupied;
	  c_drdy   <= `SDLIB_DELAY nxt_c_drdy;
	end // else: !if(reset)
    end // always @ (posedge clk)  
 
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/closure/sd_iohalf.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
// Srdy/Drdy input/output block
//
// Halts timing on all signals.  Efficiency of block is only 0.5, so
// it can produce data at most on every other cycle.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_iohalf
  #(parameter width = 8)
  (
   input              clk,
   input              reset,
   input              c_srdy,
   output             c_drdy,
   input [width-1:0]  c_data,

   output reg         p_srdy,
   input              p_drdy,
   output reg [width-1:0] p_data
   );

  reg 	  load;   // true when data will be loaded into p_data
  reg 	  nxt_p_srdy;

  always @*
    begin
      load  = c_srdy & !p_srdy;
      nxt_p_srdy = (p_srdy & !p_drdy) | (!p_srdy & c_srdy);
    end
  assign c_drdy = ~p_srdy;
  
  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
	  p_srdy <= `SDLIB_DELAY 0;
	end
      else
	begin
	  p_srdy <= `SDLIB_DELAY nxt_p_srdy;
	end // else: !if(reset)
    end // always @ (posedge clk)

  always @(posedge clk)
    if (load)
      p_data <= `SDLIB_DELAY c_data;

endmodule // it_output

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/closure/sd_output.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
// Srdy/Drdy output block
//
// Halts timing on all signals except ic_drdy
// ic_drdy is a combinatorial path from p_drdy
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_output
  #(parameter width = 8)
  (
   input              clk,
   input              reset,
   input              ic_srdy,
   output reg         ic_drdy,
   input [width-1:0]  ic_data,

   output reg         p_srdy,
   input              p_drdy,
   output reg [width-1:0] p_data
   );

  reg 	  load;   // true when data will be loaded into p_data
  reg 	  nxt_p_srdy;

  always @*
    begin
      ic_drdy = p_drdy | !p_srdy;
      load  = ic_srdy & ic_drdy;
      nxt_p_srdy = load | (p_srdy & !p_drdy);
    end
  
  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
	  p_srdy <= `SDLIB_DELAY 0;
	end
      else
	begin
	  p_srdy <= `SDLIB_DELAY nxt_p_srdy;
	end // else: !if(reset)
    end // always @ (posedge clk)

  always @(posedge clk)
    if (load)
      p_data <= `SDLIB_DELAY ic_data;

endmodule // it_output

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/forks/sd_ajoin2.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
//  Srdy/drdy assymetric join
//
//  Performs assymetric join of 2 inputs by concatination.  Efficiency
//  of 0.5.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
//  Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

// Clocking statement for synchronous blocks.  Default is for
// posedge clocking and positive async reset
`ifndef SDLIB_CLOCKING 
 `define SDLIB_CLOCKING posedge clk or posedge reset
`endif

// delay unit for nonblocking assigns, default is to #1
`ifndef SDLIB_DELAY 
 `define SDLIB_DELAY #1 
`endif

module sd_ajoin2
  #(parameter c1_width=8,
    parameter c2_width=8)
  (
   input              clk,
   input              reset,
  
   input              c1_srdy,
   output             c1_drdy,
   input [c1_width-1:0] c1_data,

   input              c2_srdy,
   output             c2_drdy,
   input [c2_width-1:0] c2_data,
  
   output             p_srdy,
  
   input              p_drdy,
   output reg [c1_width+c2_width-1:0] p_data
   );
  reg [c1_width+c2_width-1:0]    nxt_p_data;

  reg [1:0]          in_drdy, nxt_in_drdy;

  assign             {c2_drdy,c1_drdy} = in_drdy;

  always @*
    begin
      nxt_p_data = p_data;
      nxt_in_drdy = in_drdy;
      
      if (in_drdy[0])
        begin
          if (c1_srdy)
            begin
              nxt_in_drdy[0] = 0;
              nxt_p_data[c1_width-1:0] = c1_data;
            end
        end
      else if (p_srdy & p_drdy)
        nxt_in_drdy[0] = 1;

      if (in_drdy[1])
        begin
          if (c2_srdy)
            begin
              nxt_in_drdy[1] = 0;
              nxt_p_data[c2_width+c1_width-1:c1_width] = c2_data;
            end
        end
      else if (p_srdy & p_drdy)
        nxt_in_drdy[1] = 1;
    end
  
  always @(`SDLIB_CLOCKING)
    begin
      if (reset)
	begin
          in_drdy  <= `SDLIB_DELAY 2'b11;
	  p_data <= `SDLIB_DELAY 0;
	end
      else
	begin
          in_drdy  <= `SDLIB_DELAY nxt_in_drdy;
          p_data <= `SDLIB_DELAY nxt_p_data;
	end // else: !if(reset)
    end // always @ (posedge clk)

  assign p_srdy = & (~in_drdy);
	  
endmodule // it_output

// -----------------------------------------------------------------------------
// Source file: rtl/verilog/memory/behave2p_mem.v
// -----------------------------------------------------------------------------
//----------------------------------------------------------------------
// Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

module behave2p_mem
  #(parameter width=8,
    parameter depth=256,
    parameter addr_sz=$clog2(depth))
  (/*AUTOARG*/
  // Outputs
  d_out,
  // Inputs
  wr_en, rd_en, wr_clk, rd_clk, d_in, rd_addr, wr_addr
  );
  input        wr_en, rd_en, wr_clk;
  input        rd_clk;
  input [width-1:0] d_in;
  input [addr_sz-1:0] rd_addr, wr_addr;

  output [width-1:0]  d_out;

  reg [addr_sz-1:0] r_addr;

  reg [width-1:0]   array[0:depth-1];
  
  always @(posedge wr_clk)
    begin
      if (wr_en)
        begin
          array[wr_addr] <= #1 d_in;
        end
    end

  always @(posedge rd_clk)
    begin
      if (rd_en)
        begin
          r_addr <= #1 rd_addr;
        end
    end // always @ (posedge clk)

  assign d_out = array[r_addr];

endmodule
