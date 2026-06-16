// Curated RTL benchmark case.
// case_id: bench_0231_communication_controller_serial_ata_host_bus_adapter_core_for_virtex_6
// source_project: communication_controller_serial_ata_host_bus_adapter_core_for_virtex_6
// top_module: sata_phy


// -----------------------------------------------------------------------------
// Source file: sata2_bus_v1_00_a/base_system/pcores/sata_core_v1_00_a/hdl/verilog/sata_phy.v
// -----------------------------------------------------------------------------
//*****************************************************************************/
// Module :     sata_phy
// Version:     1.0
// Author:      Ashwin Mendon 
// Description: This module provides a wrapper for the SATA GTX wrapper modules
//              the Out of Band Signaling controller module and the clock generating
//              modules
//              It has been modified from Xilinx XAPP870 to support Virtex 6 GTX
//              transceivers 
//*****************************************************************************/

module sata_phy 
(
	sata_phy_ila_control,
	oob_control_ila_control,
        REFCLK_PAD_P_IN,	       
	REFCLK_PAD_N_IN,	       
	TXP0_OUT,
	TXN0_OUT,
	RXP0_IN,
	RXN0_IN,		
	PLLLKDET_OUT_N,			
	DCMLOCKED_OUT,
	LINKUP_led,
 	GEN2_led,
	sata_user_clk,
	LINKUP,
	align_en_out,
        tx_datain,
        tx_charisk_in,
	rx_dataout,
	rx_charisk_out,
        CurrentState_out,
        rxelecidle_out,
	GTXRESET_IN,			
        CLKIN_150
 );
    
        parameter  CHIPSCOPE            = "TRUE";
        input  [35:0]   sata_phy_ila_control;
        input  [35:0]   oob_control_ila_control;
	input		REFCLK_PAD_P_IN;	// GTX reference clock input
	input		REFCLK_PAD_N_IN;	// GTX reference clock input
	input           RXP0_IN;		// Receiver input
	input           RXN0_IN;		// Receiver input
	input		GTXRESET_IN;		// Main GTX reset
        input           CLKIN_150;              // GTX reference clock input
        // Input from Link Layer
        input  [31:0]   tx_datain;              
        input           tx_charisk_in;          
       	
	output		DCMLOCKED_OUT;		// DCM locked 
	output 		PLLLKDET_OUT_N;	        // PLL Lock Detect
	output		TXP0_OUT;
	output		TXN0_OUT;
	output		LINKUP;
	output		LINKUP_led;
	output		GEN2_led;
	output		align_en_out;
	output		sata_user_clk;
        // Outputs to Link Layer
        output  [31:0]  rx_dataout;       
	output  [3:0]   rx_charisk_out;
	output	[7:0]	CurrentState_out;
        output          rxelecidle_out;
        

	wire	[3:0]	rxcharisk;
        // OOB generate and detect
	wire		txcominit, txcomwake;
	wire		cominitdet, comwakedet;
        // OOB generate and detect
	wire		sync_det_out, align_det_out;
	wire		tx_charisk_out;
	wire		txelecidle,   rxelecidle0, rxelecidle1, rxenelecidleresetb; 
	wire		resetdone0, resetdone1;
	wire	[31:0]	txdata, rxdata; // TX/RX data
	wire	[31:0]	rxdataout; // RX USER data
	wire	[4:0]	state_out;
	wire		PLLLKDET_OUT;
 	wire 		linkup, linkup_led_out;
 	wire 		align_en_out;
	wire		clk0, clk2x, dcm_clk0, dcm_clkdv, dcm_clk2x; // DCM output clocks
	wire		mmcm_locked;
	wire		GEN2; //this is the selection for GEN2 when set to 1
	wire		speed_neg_rst;
	wire		rxreset;	//GTX Rxreset
	wire 	        RXBYTEREALIGN0, RXBYTEISALIGNED0;
	wire 		RXRECCLK0;
	wire 		mmcm_reset;
	wire 		rst_debounce;
	wire 		mmcm_clk_in;   
	wire 		gtx_refclk;   
	wire 		gtx_refclk_bufg;   
	wire 		gtx_reset;   
   
	wire 		rst_0;
	reg  		rst_1;  
	reg  		rst_2;
	reg  		rst_3;

        // Clock counters to check clock toggle
        reg    [15:0]   gtx_refclk_count;
        reg    [15:0]   gtx_refclk_bufg_count;
        reg    [15:0]   gtx_txoutclk_count;
        reg    [15:0]   gtx_txusrclk_count;
        reg    [15:0]   gtx_txusrclk2_count;
        reg    [15:0]   CLKIN_150_count;

	
//------------------------ MGT Wrapper Wires ------------------------------
    //________________________________________________________________________
    //________________________________________________________________________
    //GTX0   (X0Y4)

    //---------------------- Loopback and Powerdown Ports ----------------------
    wire    [2:0]   gtx0_loopback_i;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    wire    [3:0]   gtx0_rxdisperr_i;
    wire    [3:0]   gtx0_rxnotintable_i;
    //----------------- Receive Ports - Clock Correction Ports -----------------
    wire    [2:0]   gtx0_rxclkcorcnt_i;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    wire            gtx0_rxbyteisaligned_i;
    wire            gtx0_rxbyterealign_i;
    wire            gtx0_rxenmcommaalign_i;
    wire            gtx0_rxenpcommaalign_i;
    //----------------- Receive Ports - RX Data Path interface -----------------
    wire    [31:0]  gtx0_rxdata_i;
    wire            gtx0_rxrecclk_i;
    wire            gtx0_rxreset_i;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    wire            gtx0_rxelecidle_i;
    wire    [2:0]   gtx0_rxeqmix_i;
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    wire            gtx0_rxbufreset_i;
    wire    [2:0]   gtx0_rxstatus_i;
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    wire            gtx0_gtxrxreset_i;
    wire            gtx0_pllrxreset_i;
    wire            gtx0_rxplllkdet_i;
    wire            gtx0_rxresetdone_i;
    //------------------- Receive Ports - RX Ports for SATA --------------------
    wire            gtx0_cominitdet_i;
    wire            gtx0_comwakedet_i;
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    wire    [3:0]   gtx0_txcharisk_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [31:0]  gtx0_txdata_i;
    wire            gtx0_txoutclk_i;
    wire            gtx0_txreset_i;
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    wire    [3:0]   gtx0_txdiffctrl_i;
    wire    [4:0]   gtx0_txpostemphasis_i;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    wire    [3:0]   gtx0_txpreemphasis_i;
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    wire            gtx0_gtxtxreset_i;
    wire            gtx0_txresetdone_i;
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    wire            gtx0_txelecidle_i;
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    wire            comfinish;
    wire            gtx0_txcominit_i;
    wire            gtx0_txcomwake_i;


    //________________________________________________________________________
    //________________________________________________________________________
    //GTX1   (X0Y5)

    //---------------------- Loopback and Powerdown Ports ----------------------
    wire    [2:0]   gtx1_loopback_i;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    wire    [3:0]   gtx1_rxdisperr_i;
    wire    [3:0]   gtx1_rxnotintable_i;
    //----------------- Receive Ports - Clock Correction Ports -----------------
    wire    [2:0]   gtx1_rxclkcorcnt_i;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    wire            gtx1_rxbyteisaligned_i;
    wire            gtx1_rxbyterealign_i;
    wire            gtx1_rxenmcommaalign_i;
    wire            gtx1_rxenpcommaalign_i;
    //----------------- Receive Ports - RX Data Path interface -----------------
    wire    [31:0]  gtx1_rxdata_i;
    wire            gtx1_rxrecclk_i;
    wire            gtx1_rxreset_i;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    wire            gtx1_rxelecidle_i;
    wire    [2:0]   gtx1_rxeqmix_i;
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    wire            gtx1_rxbufreset_i;
    wire    [2:0]   gtx1_rxstatus_i;
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    wire            gtx1_gtxrxreset_i;
    wire            gtx1_pllrxreset_i;
    wire            gtx1_rxplllkdet_i;
    wire            gtx1_rxresetdone_i;
    //------------------- Receive Ports - RX Ports for SATA --------------------
    wire            gtx1_cominitdet_i;
    wire            gtx1_comwakedet_i;
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    wire    [3:0]   gtx1_txcharisk_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [31:0]  gtx1_txdata_i;
    wire            gtx1_txoutclk_i;
    wire            gtx1_txreset_i;
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    wire    [3:0]   gtx1_txdiffctrl_i;
    wire    [4:0]   gtx1_txpostemphasis_i;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    wire    [3:0]   gtx1_txpreemphasis_i;
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    wire            gtx1_gtxtxreset_i;
    wire            gtx1_txresetdone_i;
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    wire            gtx1_txelecidle_i;
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    wire            gtx1_comfinish_i;
    wire            gtx1_txcominit_i;
    wire            gtx1_txcomwake_i;



    //----------------------------- Global Signals -----------------------------
    wire            gtx0_tx_system_reset_c;
    wire            gtx0_rx_system_reset_c;
    wire            gtx1_tx_system_reset_c;
    wire            gtx1_rx_system_reset_c;
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [7:0]   tied_to_vcc_vec_i;
    wire            drp_clk_in_i;

    //--------------------------- User Clocks ---------------------------------
    wire            gtx0_txusrclk_i;
    wire            gtx0_txusrclk2_i;
    wire            txoutclk_mmcm0_locked_i;
    wire            txoutclk_mmcm0_reset_i;
    wire            gtx0_txoutclk_to_mmcm_i;


    //--------------------------- Reference Clocks ----------------------------
    
    wire            q1_clk1_refclk_i;
    wire            q1_clk1_refclk_i_bufg;
    //--------------------------- Reference Clocks ----------------------------


        // Static signal Assigments    
        assign tied_to_ground_i             = 1'b0;
        assign tied_to_ground_vec_i         = 64'h0000000000000000;
        assign tied_to_vcc_i                = 1'b1;
        assign tied_to_vcc_vec_i            = 8'hff;
 
        // GTX Reset
        assign rst_0 = GTXRESET_IN;  
         
        always @(posedge CLKIN_150)
        begin
            rst_1 <= rst_0;
            rst_2 <= rst_1;
            rst_3 <= rst_2;
        end

        assign rst_debounce = (rst_1 & rst_2 & rst_3);

	//assign gtx_reset = rst_debounce|| speed_neg_rst;	
	assign gtx_reset = rst_debounce;	
	//assign mmcm_reset = ~PLLLKDET_OUT || speed_neg_rst;
	assign mmcm_reset = ~PLLLKDET_OUT;
	
	assign	GEN2_led =  GEN2;
	assign LINKUP    = linkup;	
	assign LINKUP_led = linkup_led_out;	
	assign align_en_out = align_en_out;	
	assign	DCMLOCKED_OUT	=  mmcm_locked; // LED active high 

	assign PLLLKDET_OUT_N = PLLLKDET_OUT;         
	assign  rxelecidlereset0          =   (rxelecidle0 && resetdone0);
	assign  rxenelecidleresetb        =   !rxelecidlereset0; 

        assign rx_dataout = rxdataout;

        // SATA PHY output clock assignments
        assign sata_user_clk = gtx0_txusrclk2_i;


OOB_control OOB_control_i 
    (
 	.oob_control_ila_control        (oob_control_ila_control),
       //-------- GTX Ports --------/
     	.clk				(gtx0_txusrclk2_i),
 	.reset		      		(gtx_reset),
	.rxreset			(rxreset),
 	.rx_locked			(PLLLKDET_OUT),
         // OOB generation and detection signals from GTX
 	.txcominit			(txcominit),
 	.txcomwake			(txcomwake),
 	.cominitdet                     (cominitdet),
 	.comwakedet                     (comwakedet),

 	.rxelecidle			(rxelecidle0),
 	.txelecidle_out			(txelecidle),
 	.rxbyteisaligned		(RXBYTEISALIGNED0), 	
 	.tx_dataout			(txdata),		// outgoing GTX data
 	.tx_charisk_out			(tx_charisk_out),       // GTX charisk out    
 	.rx_datain			(rxdata),              	// incoming GTX data 
 	.rx_charisk_in			(rxcharisk),            // GTX charisk in 	
	.gen2             		(1'b1),                 // for SATA Generation 2
        
       //----- USER DATA PORTS---------//        
 	.tx_datain			(tx_datain),		// User datain port
        .tx_charisk_in                  (tx_charisk_in),        // User charisk in port 
 	.rx_dataout			(rxdataout),         	// User dataout port
 	.rx_charisk_out			(rx_charisk_out),       // User charisk out port 	
 	.linkup                 	(linkup),
 	.linkup_led_out                 (linkup_led_out),
 	.align_en_out                   (align_en_out),
	.CurrentState_out       	(CurrentState_out)
 );

    assign rxelecidle_out  = rxelecidle0;


    
//---------------------Dedicated GTX Reference Clock Inputs ---------------
    // The dedicated reference clock inputs you selected in the GUI are implemented using
    // IBUFDS_GTXE1 instances.
    //
    // In the UCF file for this example design, you will see that each of
    // these IBUFDS_GTXE1 instances has been LOCed to a particular set of pins. By LOCing to these
    // locations, we tell the tools to use the dedicated input buffers to the GTX reference
    // clock network, rather than general purpose IOs. To select other pins, consult the 
    // Implementation chapter of UG___, or rerun the wizard.
    //
    // This network is the highest performace (lowest jitter) option for providing clocks
    // to the GTX transceivers.
    
    IBUFDS_GTXE1 gtx_refclk_ibufds_i
    (
        .O                              (gtx_refclk),
        .ODIV2                          (),
        .CEB                            (tied_to_ground_i),
        .I                              (REFCLK_PAD_P_IN),
        .IB                             (REFCLK_PAD_N_IN)
    );

 
    BUFG gtx_refclk_bufg_i
    (
        .I                              (gtx_refclk),
        .O                              (gtx_refclk_bufg)
    );

   

    //--------------------------------- User Clocks ---------------------------
    
    // The clock resources in this section were added based on userclk source selections on
    // the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
    // * The userclk and userclk2 for each GTX datapath (TX and RX) must be phase aligned to 
    //   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
    // * To minimize clock resources, you can share clocks between GTXs. GTXs using the same frequency
    //   or multiples of the same frequency can be accomadated using MMCMs. Use caution when
    //   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
    //   the channels using the clock are receiving data from TX channels that share a reference clock 
    //   source with each other.

   // assign  txoutclk_mmcm0_reset_i               =  !gtx0_rxplllkdet_i;



    BUFG txoutclk_bufg_i
    (
        .I                              (gtx0_txoutclk_i),
        .O                              (mmcm_clk_in)
    );


    MGT_USRCLK_SOURCE_MMCM #
    (
        .MULT                           (8.0),
        .DIVIDE                         (2),
        .CLK_PERIOD                     (6.666),
        .OUT0_DIVIDE                    (4.0),
        .OUT1_DIVIDE                    (2.0),
        .OUT2_DIVIDE                    (1),
        .OUT3_DIVIDE                    (1)
    )
    txoutclk_mmcm0_i
    (
        .CLK0_OUT                       (gtx0_txusrclk2_i),
        .CLK1_OUT                       (gtx0_txusrclk_i),
        .CLK2_OUT                       (),
        .CLK3_OUT                       (),
        .CLK_IN                         (mmcm_clk_in),
        .MMCM_LOCKED_OUT                (mmcm_locked),
        .MMCM_RESET_IN                  (mmcm_reset)
    );


//instantiate GTX tile(two transceivers)

SATA_GTX_DUAL #
    (
        .WRAPPER_SIM_GTXRESET_SPEEDUP (0),
    )
    sata_gtx_dual_i
    (
 
 
        //_____________________________________________________________________
        //_____________________________________________________________________
        //GTX0  (X0Y4)
        //---------------------- Loopback and Powerdown Ports ----------------------
        .GTX0_LOOPBACK_IN               (gtx0_loopback_i),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .GTX0_RXCHARISK_OUT             (rxcharisk),
        .GTX0_RXDISPERR_OUT             (gtx0_rxdisperr_i),
        .GTX0_RXNOTINTABLE_OUT          (gtx0_rxnotintable_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .GTX0_RXCLKCORCNT_OUT           (gtx0_rxclkcorcnt_i),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .GTX0_RXBYTEISALIGNED_OUT       (RXBYTEISALIGNED0),
        .GTX0_RXBYTEREALIGN_OUT         (gtx0_rxbyterealign_i),
        .GTX0_RXENMCOMMAALIGN_IN        (gtx0_rxenmcommaalign_i),
        .GTX0_RXENPCOMMAALIGN_IN        (gtx0_rxenpcommaalign_i),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .GTX0_RXDATA_OUT                (rxdata),
        .GTX0_RXRECCLK_OUT              (gtx0_rxrecclk_i),
        .GTX0_RXRESET_IN                (rxreset),
        .GTX0_RXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX0_RXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GTX0_RXELECIDLE_OUT            (rxelecidle0),
        .GTX0_RXEQMIX_IN                (gtx0_rxeqmix_i),
        .GTX0_RXN_IN                    (RXN0_IN),
        .GTX0_RXP_IN                    (RXP0_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .GTX0_RXBUFRESET_IN             (gtx_reset),
        .GTX0_RXSTATUS_OUT              (gtx0_rxstatus_i),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTX0_GTXRXRESET_IN             (gtx_reset),
        .GTX0_MGTREFCLKRX_IN            (CLKIN_150),
        .GTX0_PLLRXRESET_IN             (),
        .GTX0_RXPLLLKDET_OUT            (PLLLKDET_OUT),
        .GTX0_RXRESETDONE_OUT           (gtx0_rxresetdone_i),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .GTX0_COMINITDET_OUT            (cominitdet),
        .GTX0_COMWAKEDET_OUT            (comwakedet),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        // Speed Negotiation Control module is disabled here and the design is fixed for 
        //  SATA GEN2 disks
        .DADDR                          (7'b0),
        .DCLK                           (mmcm_clk_in),
        .DEN                            (1'b0),
        .DI                             (16'b0),
        .DRDY                           (),
        .DO                             (),
        .DWE                            (1'b0),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .GTX0_TXCHARISK_IN              ({1'b0,1'b0,1'b0,tx_charisk_out}),
        //.GTX0_TXCHARISK_IN              ({1'b0,tx_charisk_out,1'b0,tx_charisk_out}),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .GTX0_TXDATA_IN                 (txdata),
        .GTX0_TXOUTCLK_OUT              (gtx0_txoutclk_i),
        .GTX0_TXRESET_IN                (),
        .GTX0_TXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX0_TXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .GTX0_TXDIFFCTRL_IN             (gtx0_txdiffctrl_i),
        .GTX0_TXN_OUT                   (TXN0_OUT),
        .GTX0_TXP_OUT                   (TXP0_OUT),
        .GTX0_TXPOSTEMPHASIS_IN         (gtx0_txpostemphasis_i),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .GTX0_TXPREEMPHASIS_IN          (gtx0_txpreemphasis_i),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTX0_GTXTXRESET_IN             (gtx_reset),
        .GTX0_TXRESETDONE_OUT           (gtx0_txresetdone_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .GTX0_TXELECIDLE_IN             (txelecidle),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .GTX0_COMFINISH_OUT             (comfinish),
        .GTX0_TXCOMINIT_IN              (txcominit),
        .GTX0_TXCOMWAKE_IN              (txcomwake),

 
        //_____________________________________________________________________
        //_____________________________________________________________________
        //GTX1  (X0Y5)
        //---------------------- Loopback and Powerdown Ports ----------------------
        .GTX1_LOOPBACK_IN               (gtx1_loopback_i),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .GTX1_RXDISPERR_OUT             (gtx1_rxdisperr_i),
        .GTX1_RXNOTINTABLE_OUT          (gtx1_rxnotintable_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .GTX1_RXCLKCORCNT_OUT           (gtx1_rxclkcorcnt_i),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .GTX1_RXBYTEISALIGNED_OUT       (),
        .GTX1_RXBYTEREALIGN_OUT         (gtx1_rxbyterealign_i),
        .GTX1_RXENMCOMMAALIGN_IN        (gtx1_rxenmcommaalign_i),
        .GTX1_RXENPCOMMAALIGN_IN        (gtx1_rxenpcommaalign_i),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .GTX1_RXDATA_OUT                (),
        .GTX1_RXRECCLK_OUT              (gtx1_rxrecclk_i),
        .GTX1_RXRESET_IN                (rxreset),
        .GTX1_RXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX1_RXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GTX1_RXELECIDLE_OUT            (rxelecidle1),
        .GTX1_RXEQMIX_IN                (gtx1_rxeqmix_i),
        .GTX1_RXN_IN                    (),
        .GTX1_RXP_IN                    (),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .GTX1_RXBUFRESET_IN             (gtx_reset),
        .GTX1_RXSTATUS_OUT              (),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTX1_GTXRXRESET_IN             (gtx_reset),
        .GTX1_MGTREFCLKRX_IN            (CLKIN_150),
        .GTX1_PLLRXRESET_IN             (),
        .GTX1_RXPLLLKDET_OUT            (gtx1_rxplllkdet_i),
        .GTX1_RXRESETDONE_OUT           (gtx1_rxresetdone_i),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .GTX1_COMINITDET_OUT            (gtx1_cominitdet_i),
        .GTX1_COMWAKEDET_OUT            (gtx1_comwakedet_i),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .GTX1_TXCHARISK_IN              ({1'b0,1'b0,1'b0,tx_charisk_out}),
        //.GTX1_TXCHARISK_IN              ({1'b0,tx_charisk_out,1'b0,tx_charisk_out}),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .GTX1_TXDATA_IN                 (txdata),
        .GTX1_TXOUTCLK_OUT              (gtx1_txoutclk_i),
        .GTX1_TXRESET_IN                (),
        .GTX1_TXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX1_TXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .GTX1_TXDIFFCTRL_IN             (gtx1_txdiffctrl_i),
        .GTX1_TXN_OUT                   (),
        .GTX1_TXP_OUT                   (),
        .GTX1_TXPOSTEMPHASIS_IN         (gtx1_txpostemphasis_i),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .GTX1_TXPREEMPHASIS_IN          (gtx1_txpreemphasis_i),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTX1_GTXTXRESET_IN             (gtx_reset),
        .GTX1_TXRESETDONE_OUT           (gtx1_txresetdone_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .GTX1_TXELECIDLE_IN             (txelecidle),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .GTX1_COMFINISH_OUT             (gtx1_comfinish_i),
        .GTX1_TXCOMINIT_IN              (gtx1_txcominit_i),
        .GTX1_TXCOMWAKE_IN              (gtx1_txcomwake_i)

    );
/* Note: The Transmitter Differential Voltage Swing is set by the TXDIFFCTRL parameter
         in the GTX transceivers. It defaults to 4'b0000 resulting in a voltage of 110 mV p-p. 
         Set it to 4'b1000 to raise the voltage to 810 mV p-p. (Refer Pg 174 of V6 GTX user guide). 
         This is necessary for the transmission of OOB signals during PHY Initialization. */ 
assign gtx0_txdiffctrl_i = 4'b1000; 
assign gtx1_txdiffctrl_i = 4'b1000; 



// Debugging
always @(posedge gtx_refclk_bufg)
begin : GTX_REF_CLK_CNT
      begin
            gtx_refclk_count <= gtx_refclk_count + 1;
      end 
end

always @(posedge mmcm_clk_in)
begin : GTX_TXOUTCLK_CNT
      begin
            gtx_txoutclk_count <= gtx_txoutclk_count + 1;
      end 
end


always @(posedge gtx0_txusrclk_i)
begin : GTX_TXUSRCLK_CNT
      begin
            gtx_txusrclk_count <= gtx_txusrclk_count + 1;
      end 
end

always @(posedge gtx0_txusrclk2_i)
begin : GTX_TXUSRCLK2_CNT
      begin
            gtx_txusrclk2_count <= gtx_txusrclk2_count + 1;
      end 
end


always @(posedge CLKIN_150)
begin : CLKIN_150_CNT
      begin
            CLKIN_150_count <= CLKIN_150_count + 1;
      end 
end


// SATA PHY ILA
wire [7:0] trig0;
wire [15:0] trig1;
wire [1:0] trig2;
wire [15:0] trig3;
wire [15:0] trig4;
wire [15:0] trig5;
wire [15:0] trig6;
wire [15:0] trig7;
wire [15:0] trig8;
wire [15:0] trig9;
wire [15:0] trig10;
wire [35:0] control;

if (CHIPSCOPE == "TRUE") begin
 sata_phy_ila  i_sata_phy_ila  
    (
      .control(sata_phy_ila_control),
      .clk(gtx0_txusrclk2_i),
      .trig0(trig0),
      .trig1(trig1),
      .trig2(trig2),
      .trig3(trig3),
      .trig4(trig4),
      .trig5(trig5),
      .trig6(trig6),
      .trig7(trig7),
      .trig8(trig8),
      .trig9(trig9),
      .trig10(trig10)
    );
end

assign trig0  = CurrentState_out;
assign trig1[0] = gtx0_rxstatus_i;
assign trig1[1] = gtx0_txusrclk_i;
assign trig1[2] = gtx0_txusrclk2_i;
assign trig1[3] = gtx_reset; 
assign trig1[4] = comfinish;
assign trig1[5] = PLLLKDET_OUT;
assign trig1[6] = mmcm_reset;
assign trig1[7] = mmcm_locked;
assign trig1[8] = rxelecidle0;
assign trig1[9] = RXBYTEISALIGNED0;
assign trig1[10] = gtx0_rxresetdone_i;
assign trig1[11] = txelecidle;
assign trig1[12] = txcominit;
assign trig1[13] = txcomwake;
assign trig1[14] = cominitdet;
assign trig1[15] = comwakedet;
assign trig2     = 2'b0;
assign trig3[0]  = gtx0_txresetdone_i;
assign trig3[1]  = speed_neg_rst;
assign trig3[2]  = GTXRESET_IN;
assign trig3[3]  = rst_1;
assign trig3[6:4]  = rxcharisk;
assign trig3[15:7] = 9'b0;
assign trig4     = gtx_refclk_count;
assign trig5     = gtx_txoutclk_count;
assign trig6     = gtx_txusrclk_count;
assign trig7     = gtx_txusrclk2_count;
assign trig8     = 16'b0;
assign trig9     = 16'b0;
assign trig10    = CLKIN_150_count;

endmodule


module sata_phy_ila 
  (
    control,
    clk,
    trig0,
    trig1,
    trig2,
    trig3,
    trig4,
    trig5,
    trig6,
    trig7,
    trig8,
    trig9,
    trig10
  );
  input [35:0] control;
  input clk;
  input [7:0]  trig0;
  input [15:0] trig1;
  input [1:0]  trig2;
  input [15:0] trig3;
  input [15:0] trig4;
  input [15:0] trig5;
  input [15:0] trig6;
  input [15:0] trig7;
  input [15:0] trig8;
  input [15:0] trig9;
  input [15:0] trig10;
  
endmodule

// -----------------------------------------------------------------------------
// Source file: sata2_bus_v1_00_a/base_system/pcores/sata_core_v1_00_a/hdl/verilog/mgt_usrclk_source_mmcm.v
// -----------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 1.8
//  \   \         Application :  Virtex-6 FPGA GTX Transceiver Wizard
//  /   /         Filename : mgt_usrclk_source_mmcm.v
// /___/   /\     Timestamp : 
// \   \  /  \ 
//  \___\/\___\ 
//
//
// Module MGT_USRCLK_SOURCE (for use with GTX Transceivers)
// Generated by Xilinx Virtex-6 FPGA GTX Transceiver Wizard
// 
// 
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps

//***********************************Entity Declaration*******************************
module MGT_USRCLK_SOURCE_MMCM #
(
    parameter   MULT            =   2,
    parameter   DIVIDE          =   2,
    parameter   CLK_PERIOD      =   6.4,
    parameter   OUT0_DIVIDE     =   2,
    parameter   OUT1_DIVIDE     =   2,
    parameter   OUT2_DIVIDE     =   2,
    parameter   OUT3_DIVIDE     =   2   
)
(
    output          CLK0_OUT,
    output          CLK1_OUT,
    output          CLK2_OUT,
    output          CLK3_OUT,
    input           CLK_IN,
    output          MMCM_LOCKED_OUT,
    input           MMCM_RESET_IN
);


`define DLY #1

//*********************************Wire Declarations**********************************

    wire    [15:0]  tied_to_ground_vec_i;
    wire            tied_to_ground_i;
    wire            clkout0_i;
    wire            clkout1_i;
    wire            clkout2_i;
    wire            clkout3_i;
    wire            clkfbout_i;

//*********************************** Beginning of Code *******************************

    //  Static signal Assigments    
    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 16'h0000;

    // Instantiate a MMCM module to divide the reference clock. Uses internal feedback
    // for improved jitter performance, and to avoid consuming an additional BUFG
    MMCM_ADV #
    (
         .COMPENSATION      ("ZHOLD"),
         .CLKFBOUT_MULT_F   (MULT),
         .DIVCLK_DIVIDE     (DIVIDE),
         .CLKFBOUT_PHASE    (0),
         
         .CLKIN1_PERIOD     (CLK_PERIOD),
         .CLKIN2_PERIOD     (10),   //Not used
         
         .CLKOUT0_DIVIDE_F  (OUT0_DIVIDE),
         .CLKOUT0_PHASE     (0),
         
         .CLKOUT1_DIVIDE    (OUT1_DIVIDE),
         .CLKOUT1_PHASE     (0),

         .CLKOUT2_DIVIDE    (OUT2_DIVIDE),
         .CLKOUT2_PHASE     (0),
         
         .CLKOUT3_DIVIDE    (OUT3_DIVIDE),
         .CLKOUT3_PHASE     (0),
         .CLOCK_HOLD        ("TRUE")        
    )
    mmcm_adv_i   
    (
         .CLKIN1            (CLK_IN),
         .CLKIN2            (1'b0),
         .CLKINSEL          (1'b1),
         .CLKFBIN           (clkfbout_i),
         .CLKOUT0           (clkout0_i),
         .CLKOUT0B          (),
         .CLKOUT1           (clkout1_i),
         .CLKOUT1B          (),         
         .CLKOUT2           (clkout2_i),
         .CLKOUT2B          (),         
         .CLKOUT3           (clkout3_i),
         .CLKOUT3B          (),         
         .CLKOUT4           (),
         .CLKOUT5           (),
         .CLKOUT6           (),
         .CLKFBOUT          (clkfbout_i),
         .CLKFBOUTB         (),
         .CLKFBSTOPPED      (),
         .CLKINSTOPPED      (),
         .DO                (),
         .DRDY              (),
         .DADDR             (7'd0),
         .DCLK              (1'b0),
         .DEN               (1'b0),
         .DI                (16'd0),
         .DWE               (1'b0),
         .LOCKED            (MMCM_LOCKED_OUT),
         .PSCLK             (1'b0),
         .PSEN              (1'b0),         
         .PSINCDEC          (1'b0), 
         .PSDONE            (),         
         .PWRDWN            (1'b0),         
         .RST               (MMCM_RESET_IN)
    );
    
    BUFG clkout0_bufg_i  
    (
        .O              (CLK0_OUT), 
        .I              (clkout0_i)
    ); 


    BUFG clkout1_bufg_i
    (
        .O              (CLK1_OUT),
        .I              (clkout1_i)
    );


    BUFG clkout2_bufg_i 
    (
        .O              (CLK2_OUT),
        .I              (clkout2_i)
    );
    
    
    BUFG clkout3_bufg_i
    (
        .O              (CLK3_OUT),
        .I              (clkout3_i)
    );    

endmodule


// -----------------------------------------------------------------------------
// Source file: sata2_bus_v1_00_a/base_system/pcores/sata_core_v1_00_a/hdl/verilog/mux_21.v
// -----------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Entity   mux_21 
// Version: 1.0
// Author:  Ashwin Mendon 
// Description: 2 bit 2:1 Multiplexer
//--------------------------------------------------------------------------------

module mux_21 
   (
    input wire [1:0] a,
    input wire [1:0] b,
    input wire   sel,
    output reg [1:0] o
    );

  always @ (a or b or sel)
  begin
    case (sel)
      1'b0: 
          o = a;
      1'b1: 
          o = b;
    endcase
  end

endmodule


// -----------------------------------------------------------------------------
// Source file: sata2_bus_v1_00_a/base_system/pcores/sata_core_v1_00_a/hdl/verilog/mux_41.v
// -----------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Entity   mux_21 
// Version: 1.0
// Author:  Ashwin Mendon 
// Description: 32 bit 4:1 Multiplexer
//--------------------------------------------------------------------------------

module mux_41 
   (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] c,
    input wire [31:0] d,
    input wire [1:0] sel,
    output reg [31:0] o
    );

  always @ (a or b or c or d or sel)
  begin
    case (sel)
      2'b00: 
          o = a;
      2'b01: 
          o = b;
      2'b10: 
          o = c; 
      2'b11:
          o = d;  
     endcase     
  end

endmodule


// -----------------------------------------------------------------------------
// Source file: sata2_bus_v1_00_a/base_system/pcores/sata_core_v1_00_a/hdl/verilog/oob_control.v
// -----------------------------------------------------------------------------
//*****************************************************************************/
// Module :     OOB_control 
// Version:     1.0
// Author:      Ashwin Mendon 
// Description: This module handles the Out-Of-Band (OOB) sinaling requirements
//               for link initialization and synchronization 
//              It has been modified from Xilinx XAPP870 to support Virtex 6 GTX
//              transceivers 
//*****************************************************************************/

module OOB_control (

 clk,	// Clock
 reset,	// reset	
 oob_control_ila_control,
 
 /**** GTX ****/
 rxreset,	// GTX PCS reset
 rx_locked,	// GTX PLL is locked
 gen2,		// Generation 2 speed
 txcominit,	// TX OOB issue  RESET/INIT
 txcomwake,	// TX OOB issue  WAKE
 cominitdet,	// RX OOB detect INIT 
 comwakedet,	// RX OOB detect WAKE 
 rxelecidle,	// RX electrical idle
 txelecidle_out,// TX electircal idel
 rxbyteisaligned,// RX byte alignment completed

 tx_dataout,	// Outgoing TX data to GTX
 tx_charisk_out,// TX byted is K character
 
 rx_datain,    // Data from GTX            
 rx_charisk_in,   // K character from GTX                        
 /**** GTX ****/

 /**** LINK LAYER ****/
 // INPUT 
 tx_datain,	// Incoming TX data from SATA Link Layer 
 tx_charisk_in, // K character indicator                          
 // OUTPUT 
 rx_dataout,   // Data to SATA Link Layer
 rx_charisk_out, 

 linkup,	// SATA link is established
 linkup_led_out, // LINKUP LED output
 align_en_out,
 CurrentState_out // Current state for Chipscope
 /**** LINK LAYER ****/ 

);

        parameter       CHIPSCOPE  = "TRUE";	
	input		clk;
	input 		reset;
        input   [35:0]  oob_control_ila_control;
	input 		rx_locked;
	input           gen2;
        // Added for GTX	
	input		cominitdet;
	input		comwakedet;
        // Added for GTX	
	input		rxelecidle;
	input		rxbyteisaligned;
	input	[31:0]  tx_datain;
	input	        tx_charisk_in;
	input	[3:0]   rx_charisk_in;   		
	input	[31:0]  rx_datain;      //changed for GTX 
      
	output		rxreset;
        // Added for GTX	
	output		txcominit;
	output		txcomwake;
        // Added for GTX	
	output 		txelecidle_out;
	output	[31:0]  tx_dataout;     //changed for GTX 
	output          tx_charisk_out;                                
                                         
	output	[31:0]  rx_dataout;
	output	[3:0]   rx_charisk_out;
	output          linkup;
	output          linkup_led_out;
	output          align_en_out;
	output	[7:0]   CurrentState_out;
	
	parameter [3:0]
	host_comreset		= 8'h00,
	wait_dev_cominit	= 8'h01,
	host_comwake 		= 8'h02, 
	wait_dev_comwake 	= 8'h03,
	wait_after_comwake 	= 8'h04,
	wait_after_comwake1 	= 8'h05,
	host_d10_2 		= 8'h06,
	host_send_align 	= 8'h07,
	link_ready 		= 8'h08,
        link_idle               = 8'h09;

        // Primitves
        parameter ALIGN      = 4'b00;
        parameter SYNC       = 4'b01;
        parameter DIAL       = 4'b10;
        //parameter R_RDY      = 4'b11;
        parameter LINK_LAYER = 4'b11;

	reg	[7:0]	CurrentState, NextState;
	reg	[17:0]	count;
	reg	[3:0]	align_char_cnt_reg;
	reg		align_char_cnt_rst, align_char_cnt_inc;
	reg		count_en;
	reg		tx_charisk, tx_charisk_next;
	reg		txelecidle, txelecidle_next;
	reg        	linkup_r, linkup_r_next;
	reg		rxreset; 
	reg	[31:0]  tx_datain_r;
	wire	[31:0]  tx_dataout_i;
	reg	[31:0]  rx_dataout_i;
	wire	[31:0]  tx_align, tx_sync, tx_dial, tx_r_rdy;
	reg     [3:0]   rx_charisk_r;
	reg		txcominit_r, txcomwake_r;
        wire    [1:0]   align_count_mux_out;
        reg     [8:0]   align_count;
        reg     [1:0]   prim_type, prim_type_next;
      
	wire		align_det, sync_det, cont_det, sof_det, eof_det, x_rdy_det, r_err_det, r_ok_det;
        reg             align_en, align_en_r;
        reg             rxelecidle_r;
        reg     [31:0]  rx_datain_r;
        reg     [3:0]   rx_charisk_in_r;
        reg             rxbyteisaligned_r;
        reg             comwakedet_r, cominitdet_r;

// OOB FSM Logic Process
				
always @ ( CurrentState or count or rxelecidle_r or rx_locked or rx_datain_r or
           cominitdet_r or comwakedet_r or 
           align_det or sync_det or cont_det or 
           tx_charisk_in )
begin : Comb_FSM
 
	count_en = 1'b0;
	NextState = host_comreset;
	linkup_r_next = linkup_r;
	txcominit_r =1'b0;
	txcomwake_r = 1'b0;
	rxreset = 1'b0;
	txelecidle_next = txelecidle;
        prim_type_next = prim_type;
        tx_charisk_next = tx_charisk;			
        rx_dataout_i  = 32'b0;
        rx_charisk_r = 4'b0;

       case (CurrentState)
		host_comreset :
			begin
			        txelecidle_next = 1'b1;
			        prim_type_next = ALIGN; 
				if (rx_locked)
					begin 
						if ((~gen2 && count == 18'h00051) || (gen2 && count == 18'h000A2))
						begin
							txcominit_r =1'b0;	
							NextState = wait_dev_cominit;
						end
						else  //Issue COMRESET  
						begin
							txcominit_r =1'b1;	
							count_en = 1'b1;
							NextState = host_comreset;						
						end
					end
				else
					begin
						txcominit_r =1'b0;	
						NextState = host_comreset;
					end													
			end						

		wait_dev_cominit : //1
			begin
				if (cominitdet_r == 1'b1) //device cominit detected				
				begin
					NextState = host_comwake;
				end
				else
				begin
					`ifdef SIM
					if(count == 18'h001ff) 
					`else
					if(count == 18'h203AD) //restart comreset after no cominit for at least 880us
					`endif
					begin
						count_en = 1'b0;
						NextState = host_comreset;
					end
					else
					begin
						count_en = 1'b1;
						NextState = wait_dev_cominit;
					end
				end
			end

		host_comwake : //2
			begin
				if ((~gen2 && count == 18'h0004E) || (gen2 && count == 18'h0009B))
				begin
					txcomwake_r =1'b0;	
					NextState = wait_dev_comwake;
				end
				else
				begin
					txcomwake_r =1'b1;	
					count_en = 1'b1;
					NextState = host_comwake;						
				end

			end

		wait_dev_comwake : //3 
			begin
				if (comwakedet_r == 1'b1) //device comwake detected				
				begin
					NextState = wait_after_comwake;
				end
				else
				begin
					if(count == 18'h203AD) //restart comreset after no cominit for 880us
					begin
						count_en = 1'b0;
						NextState = host_comreset;
					end
					else
					begin
						count_en = 1'b1;
						NextState = wait_dev_comwake;
					end
				end
			end


		wait_after_comwake : // 4
			begin
				if (count == 6'h3F)
				begin
					NextState = wait_after_comwake1;
				end
				else
				begin
					count_en = 1'b1;
					
					NextState = wait_after_comwake;
				end
			end		


		wait_after_comwake1 : //5
			begin
				if (rxelecidle_r == 1'b0)
				begin
					rxreset = 1'b1;
					NextState = host_d10_2;
				end
				else
					NextState = wait_after_comwake1; 	
			end

		host_d10_2 : //6
		begin
			txelecidle_next = 1'b0;

                        // D10.2-D10.2 "dial tone"
			rx_dataout_i  = rx_datain_r;
			prim_type_next = DIAL; 
			tx_charisk_next = 1'b0;			

			if (align_det)
			begin
				NextState = host_send_align;
			end
			else
			begin
				if(count == 18'h203AD) // restart comreset after 880us
				begin
					count_en = 1'b0;
					NextState = host_comreset;						
				end
				else
				begin
					count_en = 1'b1;
					NextState = host_d10_2;
				end
			end				
		end	
				
		host_send_align : //7
		begin
                        rx_dataout_i  = rx_datain_r;
                        
                	// Send Align primitives. Align is 
			// K28.5, D10.2, D10.2, D27.3
                        prim_type_next = ALIGN;
			tx_charisk_next = 1'b1;			
			
			if (sync_det) // SYNC detected
			begin
				linkup_r_next = 1'b1;
				NextState = link_ready;
			end
			else
				NextState = host_send_align;
		end
			
			
		link_ready : // 8
		begin
			if (rxelecidle_r == 1'b1)
			begin
				NextState = link_ready;
				linkup_r_next = 1'b0;
			end
			else
			begin
				NextState = link_ready;
				linkup_r_next = 1'b1;
				rx_charisk_r = rx_charisk_in_r;
				rx_dataout_i = rx_datain_r;
                                // Send LINK_LAYER DATA
                                prim_type_next = LINK_LAYER;
                                if (align_en)
			           tx_charisk_next = 1'b1;
                                else
			           tx_charisk_next = tx_charisk_in;
			end
		end
            
	        
		default : NextState = host_comreset;	
	endcase
end	


// OOB FSM Synchronous Process

always@(posedge clk or posedge reset)
begin : Seq_FSM 
	if (reset)
        begin
		CurrentState       <= host_comreset;
                prim_type          <= ALIGN;
                tx_charisk         <= 1'b0;
                txelecidle         <= 1'b1;
                linkup_r           <= 1'b0;
                align_en_r         <= 1'b0;
                rxelecidle_r       <= 1'b0;
                rx_datain_r        <= 32'b0;
                rx_charisk_in_r    <= 4'b0;
                rxbyteisaligned_r  <= 1'b0; 
                cominitdet_r       <= 1'b0;
                comwakedet_r       <= 1'b0;
	end
	else
        begin
		CurrentState      <= NextState;
                prim_type         <= prim_type_next;
                tx_charisk        <= tx_charisk_next;
                txelecidle        <= txelecidle_next;
	        linkup_r          <= linkup_r_next;
                align_en_r        <= align_en;
                rxelecidle_r      <= rxelecidle;
                rx_datain_r       <= rx_datain;
                rx_charisk_in_r   <= rx_charisk_in; 
                rxbyteisaligned_r <= rxbyteisaligned; 
                cominitdet_r      <= cominitdet;
                comwakedet_r      <= comwakedet;
        end
end


always@(posedge clk or posedge reset)
begin : freecount
	if (reset)
	begin
		count <= 18'b0;
	end	
	else if (count_en)
	begin  
		count <= count + 1;
	end
     	else
     	begin
		count <= 18'b0;

	end
end



assign txcominit = txcominit_r;
assign txcomwake = txcomwake_r;
assign txelecidle_out = txelecidle;
//Primitive detection
// Changed for 32-bit GTX
assign align_det = (rx_datain_r == 32'h7B4A4ABC) && (rxbyteisaligned_r == 1'b1); //prevent invalid align at wrong speed
assign sync_det  = (rx_datain_r == 32'hB5B5957C);
assign cont_det  = (rx_datain_r == 32'h9999AA7C);
assign sof_det   = (rx_datain_r == 32'h3737B57C);
assign eof_det   = (rx_datain_r == 32'hD5D5B57C);
assign x_rdy_det = (rx_datain_r == 32'h5757B57C);
assign r_err_det = (rx_datain_r == 32'h5656B57C);
assign r_ok_det  = (rx_datain_r == 32'h3535B57C);

assign linkup = linkup_r;
assign linkup_led_out = ((CurrentState == link_ready) && (rxelecidle_r == 1'b0)) ? 1'b1 : 1'b0;
assign CurrentState_out = CurrentState;
assign rx_charisk_out = rx_charisk_r;
assign tx_charisk_out = tx_charisk;
assign rx_dataout  = rx_dataout_i;

// SATA Primitives 

// ALIGN
assign tx_align  = 32'h7B4A4ABC;

// SYNC
assign tx_sync   = 32'hB5B5957C;

// Dial Tone
assign tx_dial   = 32'h4A4A4A4A;

// R_RDY
assign tx_r_rdy  = 32'h4A4A957C;

// Mux to switch between ALIGN and other primitives/data
mux_21 i_align_count
  (
   .a   (prim_type),
   .b   (ALIGN),
   .sel (align_en_r),
   .o   (align_count_mux_out)
  );
 // Output to Link Layer to Pause writing data frame
 assign align_en_out = align_en;

//ALIGN Primitives transmitted every 256 DWORDS for speed alignment
always@(posedge clk or posedge reset)
begin : align_cnt
	if (reset)
        begin
           align_count <= 9'b0;
        end 
	else if (align_count < 9'h0FF) //255
        begin       
           if (align_count == 9'h001) //de-assert after 2 ALIGN primitives
           begin
                align_en <= 1'b0;
           end  
           align_count <= align_count + 1;
        end
     	else
        begin     
           align_count <= 9'b0;
           align_en <= 1'b1;
        end
end


//OUTPUT MUX
mux_41 i_tx_out
  (
    .a    (tx_align),
    .b    (tx_sync),
    .c    (tx_dial),
    //.d    (tx_r_rdy),
    .d    (tx_datain),
    .sel  (align_count_mux_out),
    .o    (tx_dataout_i)
  );

assign tx_dataout = tx_dataout_i;


// OOB ILA
wire [15:0] trig0;
wire [15:0] trig1;
wire [15:0] trig2;
wire [15:0] trig3;
wire [31:0] trig4;
wire [3:0]  trig5;
wire [31:0] trig6;
wire [31:0] trig7;
wire [35:0] control;

if (CHIPSCOPE == "TRUE") begin
 oob_control_ila  i_oob_control_ila  
    (
      .control(oob_control_ila_control),
      .clk(clk),
      .trig0(trig0),
      .trig1(trig1),
      .trig2(trig2),
      .trig3(trig3),
      .trig4(trig4),
      .trig5(trig5),
      .trig6(trig6),
      .trig7(trig7)
    );
end

assign trig0[0] = txcomwake_r;
assign trig0[1] = tx_charisk;
assign trig0[2] = rxbyteisaligned_r;
assign trig0[3] = count_en;
assign trig0[4] = tx_charisk_in;
assign trig0[5] = txelecidle;
assign trig0[6] = rx_locked;
assign trig0[7] = gen2;
assign trig0[11:8] = rx_charisk_in_r;
assign trig0[15:12] = 4'b0;
assign trig1[15:12] =  prim_type;
assign trig1[11:10] = 2'b0;
assign trig1[9] = align_en_r;
assign trig1[8]  = rxelecidle_r;
assign trig1[7:0] = CurrentState_out;
assign trig2[15:7] = align_count;
assign trig2[6:5] = 2'b0;
assign trig2[4] = cominitdet_r;
assign trig2[3] = comwakedet_r;
assign trig2[2] = align_det;
assign trig2[1] = sync_det;
assign trig2[0] = cont_det;
assign trig3[0] = sof_det;
assign trig3[1] = eof_det;
assign trig3[2] = x_rdy_det;
assign trig3[3] = r_err_det;
assign trig3[4] = r_ok_det;
assign trig3[15:5] =  11'b0;
assign trig4 =  rx_datain_r;
assign trig5[0] = txcominit_r;
assign trig5[1] = linkup_r;
assign trig5[2] = align_en;
assign trig5[3] = 1'b0;
assign trig6 =  tx_datain;
assign trig7  = tx_dataout_i;

endmodule

module oob_control_ila 
  (
    control,
    clk,
    trig0,
    trig1,
    trig2,
    trig3,
    trig4,
    trig5,
    trig6,
    trig7
  );
  input [35:0] control;
  input clk;
  input [15:0] trig0;
  input [15:0] trig1;
  input [15:0] trig2;
  input [15:0] trig3;
  input [31:0] trig4;
  input [3:0]  trig5;
  input [31:0] trig6;
  input [31:0] trig7;
  
endmodule

// -----------------------------------------------------------------------------
// Source file: sata2_bus_v1_00_a/base_system/pcores/sata_core_v1_00_a/hdl/verilog/sata_gtx.v
// -----------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version : 1.8
//  \   \         Application : Virtex-6 FPGA GTX Transceiver Wizard
//  /   /         Filename : sata_gtx.v
// /___/   /\     Timestamp :
// \   \  /  \ 
//  \___\/\___\
//
//
// Module SATA_GTX (a GTX Wrapper)
// Generated by Xilinx Virtex-6 FPGA GTX Transceiver Wizard
// 
// 
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps


//***************************** Entity Declaration ****************************

module SATA_GTX #
(
    // Simulation attributes
    parameter   GTX_SIM_GTXRESET_SPEEDUP   =   0,      // Set to 1 to speed up sim reset
    
    // Share RX PLL parameter
    parameter   GTX_TX_CLK_SOURCE          =   "TXPLL",
    // Save power parameter
    parameter   GTX_POWER_SAVE             =   10'b0000000000
)
(
    //---------------------- Loopback and Powerdown Ports ----------------------
    input   [2:0]   LOOPBACK_IN,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output  [3:0]   RXCHARISK_OUT,
    output  [3:0]   RXDISPERR_OUT,
    output  [3:0]   RXNOTINTABLE_OUT,
    //----------------- Receive Ports - Clock Correction Ports -----------------
    output  [2:0]   RXCLKCORCNT_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    output          RXBYTEISALIGNED_OUT,
    output          RXBYTEREALIGN_OUT,
    input           RXENMCOMMAALIGN_IN,
    input           RXENPCOMMAALIGN_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [31:0]  RXDATA_OUT,
    output          RXRECCLK_OUT,
    input           RXRESET_IN,
    input           RXUSRCLK_IN,
    input           RXUSRCLK2_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    output          RXELECIDLE_OUT,
    input   [2:0]   RXEQMIX_IN,
    input           RXN_IN,
    input           RXP_IN,
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    input           RXBUFRESET_IN,
    output  [2:0]   RXSTATUS_OUT,
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    input           GTXRXRESET_IN,
    input   [1:0]   MGTREFCLKRX_IN,
    input           PLLRXRESET_IN,
    output          RXPLLLKDET_OUT,
    output          RXRESETDONE_OUT,
    //------------------- Receive Ports - RX Ports for SATA --------------------
    output          COMINITDET_OUT,
    output          COMWAKEDET_OUT,
    // -------------- Speed Neg Module ports ------------------------
    input [6:0]    DADDR,       //DRP address                     
    input          DEN,		//DRP enable
    input [15:0]   DI,		//DRP data in
    output[15:0]   DO,		//DRP data out
    output         DRDY,	//DRP ready
    input          DWE,		//DRP write enable
    input          DCLK,                           

    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    input   [3:0]   TXCHARISK_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [31:0]  TXDATA_IN,
    output          TXOUTCLK_OUT,
    input           TXRESET_IN,
    input           TXUSRCLK_IN,
    input           TXUSRCLK2_IN,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    input   [3:0]   TXDIFFCTRL_IN,
    output          TXN_OUT,
    output          TXP_OUT,
    input   [4:0]   TXPOSTEMPHASIS_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    input   [3:0]   TXPREEMPHASIS_IN,
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    input           GTXTXRESET_IN,
    input   [1:0]   MGTREFCLKTX_IN,
    input           PLLTXRESET_IN,
    output          TXPLLLKDET_OUT,
    output          TXRESETDONE_OUT,
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    input           TXELECIDLE_IN,
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    output          COMFINISH_OUT,
    input           TXCOMINIT_IN,
    input           TXCOMWAKE_IN


);


//***************************** Wire Declarations *****************************

    // ground and vcc signals
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;


    //RX Datapath signals
    wire    [31:0]  rxdata_i;


    //TX Datapath signals
    wire    [31:0]  txdata_i;           
        
// 
//********************************* Main Body of Code**************************
                       
    //-------------------------  Static signal Assigments ---------------------   

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;
    
    //-------------------  GTX Datapath byte mapping  -----------------
    // The GTX provides little endian data (first byte received on RXDATA[7:0])
    assign  RXDATA_OUT    =   rxdata_i;

    // The GTX transmits little endian data (TXDATA[7:0] transmitted first)
    assign  txdata_i    =   TXDATA_IN;





    //------------------------- GTX Instantiations  --------------------------
        GTXE1 #
        (
            //_______________________ Simulation-Only Attributes __________________
    
            //.SIM_RECEIVER_DETECT_PASS   ("TRUE"),
            
            //.SIM_TX_ELEC_IDLE_LEVEL     ("X"),
    
            //.SIM_GTXRESET_SPEEDUP       (GTX_SIM_GTXRESET_SPEEDUP),
            //.SIM_VERSION                ("2.0"),
            //.SIM_TXREFCLK_SOURCE        (3'b000),
            //.SIM_RXREFCLK_SOURCE        (3'b000),
            

           //--------------------------TX PLL----------------------------
            .TX_CLK_SOURCE                          (GTX_TX_CLK_SOURCE),
            .TX_OVERSAMPLE_MODE                     ("FALSE"),
            .TXPLL_COM_CFG                          (24'h21680a),
            .TXPLL_CP_CFG                           (8'h0D),
            .TXPLL_DIVSEL_FB                        (2),
            .TXPLL_DIVSEL_OUT                       (1),
            .TXPLL_DIVSEL_REF                       (1),
            .TXPLL_DIVSEL45_FB                      (5),
            .TXPLL_LKDET_CFG                        (3'b111),
            .TX_CLK25_DIVIDER                       (6),
            .TXPLL_SATA                             (2'b01),
            .TX_TDCC_CFG                            (2'b11),
            .PMA_CAS_CLK_EN                         ("FALSE"),
            .POWER_SAVE                             (GTX_POWER_SAVE),

           //-----------------------TX Interface-------------------------
            .GEN_TXUSRCLK                           ("FALSE"),
            .TX_DATA_WIDTH                          (40),
            .TX_USRCLK_CFG                          (6'h00),
            //.TXOUTCLK_CTRL                          ("TXOUTCLKPMA_DIV2"),
            .TXOUTCLK_CTRL                          ("TXPLLREFCLK_DIV2"),
            .TXOUTCLK_DLY                           (10'b0000000000),

           //------------TX Buffering and Phase Alignment----------------
            .TX_PMADATA_OPT                         (1'b0),
            .PMA_TX_CFG                             (20'h80082),
            .TX_BUFFER_USE                          ("TRUE"),
            .TX_BYTECLK_CFG                         (6'h00),
            .TX_EN_RATE_RESET_BUF                   ("TRUE"),
            .TX_XCLK_SEL                            ("TXOUT"),
            .TX_DLYALIGN_CTRINC                     (4'b0100),
            .TX_DLYALIGN_LPFINC                     (4'b0110),
            .TX_DLYALIGN_MONSEL                     (3'b000),
            .TX_DLYALIGN_OVRDSETTING                (8'b10000000),

           //-----------------------TX Gearbox---------------------------
            .GEARBOX_ENDEC                          (3'b000),
            .TXGEARBOX_USE                          ("FALSE"),

           //--------------TX Driver and OOB Signalling------------------
            .TX_DRIVE_MODE                          ("DIRECT"),
            .TX_IDLE_ASSERT_DELAY                   (3'b100),
            .TX_IDLE_DEASSERT_DELAY                 (3'b010),
            .TXDRIVE_LOOPBACK_HIZ                   ("FALSE"),
            .TXDRIVE_LOOPBACK_PD                    ("FALSE"),

           //------------TX Pipe Control for PCI Express/SATA------------
            .COM_BURST_VAL                          (4'b0101),

           //----------------TX Attributes for PCI Express---------------
            .TX_DEEMPH_0                            (5'b11010),
            .TX_DEEMPH_1                            (5'b10000),
            .TX_MARGIN_FULL_0                       (7'b1001110),
            .TX_MARGIN_FULL_1                       (7'b1001001),
            .TX_MARGIN_FULL_2                       (7'b1000101),
            .TX_MARGIN_FULL_3                       (7'b1000010),
            .TX_MARGIN_FULL_4                       (7'b1000000),
            .TX_MARGIN_LOW_0                        (7'b1000110),
            .TX_MARGIN_LOW_1                        (7'b1000100),
            .TX_MARGIN_LOW_2                        (7'b1000010),
            .TX_MARGIN_LOW_3                        (7'b1000000),
            .TX_MARGIN_LOW_4                        (7'b1000000),

           //--------------------------RX PLL----------------------------
            .RX_OVERSAMPLE_MODE                     ("FALSE"),
            .RXPLL_COM_CFG                          (24'h21680a),
            .RXPLL_CP_CFG                           (8'h0D),
            .RXPLL_DIVSEL_FB                        (2),
            .RXPLL_DIVSEL_OUT                       (1),
            .RXPLL_DIVSEL_REF                       (1),
            .RXPLL_DIVSEL45_FB                      (5),
            .RXPLL_LKDET_CFG                        (3'b111),
            .RX_CLK25_DIVIDER                       (6),

           //-----------------------RX Interface-------------------------
            .GEN_RXUSRCLK                           ("FALSE"),
            .RX_DATA_WIDTH                          (40),
            .RXRECCLK_CTRL                          ("RXRECCLKPMA_DIV2"),
            .RXRECCLK_DLY                           (10'b0000000000),
            .RXUSRCLK_DLY                           (16'h0000),

           //--------RX Driver,OOB signalling,Coupling and Eq.,CDR-------
            .AC_CAP_DIS                             ("FALSE"),
            .CDR_PH_ADJ_TIME                        (5'b10100),
            .OOBDETECT_THRESHOLD                    (3'b111),
            //.PMA_CDR_SCAN                           (27'h640404C),
            .PMA_CDR_SCAN                           (27'h6C08040),
            //.PMA_RX_CFG                             (25'h05ce049),
            .PMA_RX_CFG                             (25'h0DCE111),
            .RCV_TERM_GND                           ("FALSE"),
            .RCV_TERM_VTTRX                         ("TRUE"),
            .RX_EN_IDLE_HOLD_CDR                    ("FALSE"),
            .RX_EN_IDLE_RESET_FR                    ("TRUE"),
            .RX_EN_IDLE_RESET_PH                    ("TRUE"),
            .TX_DETECT_RX_CFG                       (14'h1832),
            .TERMINATION_CTRL                       (5'b00000),
            .TERMINATION_OVRD                       ("FALSE"),
            .CM_TRIM                                (2'b01),
            .PMA_RXSYNC_CFG                         (7'h00),
            .PMA_CFG                                (76'h0040000040000000003),
            .BGTEST_CFG                             (2'b00),
            .BIAS_CFG                               (17'h00000),

           //------------RX Decision Feedback Equalizer(DFE)-------------
            .DFE_CAL_TIME                           (5'b01100),
            .DFE_CFG                                (8'b00011011),
            .RX_EN_IDLE_HOLD_DFE                    ("TRUE"),
            .RX_EYE_OFFSET                          (8'h4C),
            .RX_EYE_SCANMODE                        (2'b00),

           //-----------------------PRBS Detection-----------------------
            .RXPRBSERR_LOOPBACK                     (1'b0),

           //----------------Comma Detection and Alignment---------------
            .ALIGN_COMMA_WORD                       (2),
            .COMMA_10B_ENABLE                       (10'b1111111111),
            .COMMA_DOUBLE                           ("FALSE"),
            .DEC_MCOMMA_DETECT                      ("TRUE"),  //changed
            .DEC_PCOMMA_DETECT                      ("TRUE"),  //changed
            .DEC_VALID_COMMA_ONLY                   ("FALSE"),
            //.MCOMMA_10B_VALUE                       (10'b0110000011),
            .MCOMMA_10B_VALUE                       (10'b1010000011),
            .MCOMMA_DETECT                          ("TRUE"),
            .PCOMMA_10B_VALUE                       (10'b0101111100),
            .PCOMMA_DETECT                          ("TRUE"),
            .RX_DECODE_SEQ_MATCH                    ("TRUE"),
            .RX_SLIDE_AUTO_WAIT                     (5),
            //.RX_SLIDE_MODE                          ("OFF"),
            .RX_SLIDE_MODE                          ("PCS"),
            .SHOW_REALIGN_COMMA                     ("FALSE"),

           //---------------RX Loss-of-sync State Machine----------------
            .RX_LOS_INVALID_INCR                    (8),
            .RX_LOS_THRESHOLD                       (128),
            .RX_LOSS_OF_SYNC_FSM                    ("FALSE"),

           //-----------------------RX Gearbox---------------------------
            .RXGEARBOX_USE                          ("FALSE"),

           //-----------RX Elastic Buffer and Phase alignment------------
            .RX_BUFFER_USE                          ("TRUE"),
            .RX_EN_IDLE_RESET_BUF                   ("TRUE"),
            .RX_EN_MODE_RESET_BUF                   ("TRUE"),
            .RX_EN_RATE_RESET_BUF                   ("TRUE"),
            .RX_EN_REALIGN_RESET_BUF                ("FALSE"),
            .RX_EN_REALIGN_RESET_BUF2               ("FALSE"),
            .RX_FIFO_ADDR_MODE                      ("FULL"),
            .RX_IDLE_HI_CNT                         (4'b1000),
            .RX_IDLE_LO_CNT                         (4'b0000),
            .RX_XCLK_SEL                            ("RXREC"),
            .RX_DLYALIGN_CTRINC                     (4'b1110),
            .RX_DLYALIGN_EDGESET                    (5'b00010),
            .RX_DLYALIGN_LPFINC                     (4'b1110),
            .RX_DLYALIGN_MONSEL                     (3'b000),
            .RX_DLYALIGN_OVRDSETTING                (8'b10000000),

           //----------------------Clock Correction----------------------
            .CLK_COR_ADJ_LEN                        (4),
            .CLK_COR_DET_LEN                        (4),
            .CLK_COR_INSERT_IDLE_FLAG               ("FALSE"),
            .CLK_COR_KEEP_IDLE                      ("FALSE"),
            //.CLK_COR_MAX_LAT                        (20),
            .CLK_COR_MAX_LAT                        (18),
            //.CLK_COR_MIN_LAT                        (14),
            .CLK_COR_MIN_LAT                        (16),
            .CLK_COR_PRECEDENCE                     ("TRUE"),
            .CLK_COR_REPEAT_WAIT                    (0),
            .CLK_COR_SEQ_1_1                        (10'b0110111100),
            .CLK_COR_SEQ_1_2                        (10'b0001001010),
            .CLK_COR_SEQ_1_3                        (10'b0001001010),
            .CLK_COR_SEQ_1_4                        (10'b0001111011),
            .CLK_COR_SEQ_1_ENABLE                   (4'b1111),
            .CLK_COR_SEQ_2_1                        (10'b0100000000),
            .CLK_COR_SEQ_2_2                        (10'b0100000000),
            .CLK_COR_SEQ_2_3                        (10'b0100000000),
            .CLK_COR_SEQ_2_4                        (10'b0100000000),
            //.CLK_COR_SEQ_2_ENABLE                   (4'b1111),
            .CLK_COR_SEQ_2_ENABLE                   (4'b0000),
            .CLK_COR_SEQ_2_USE                      ("FALSE"),
            .CLK_CORRECT_USE                        ("TRUE"),

           //----------------------Channel Bonding----------------------
            .CHAN_BOND_1_MAX_SKEW                   (1),
            .CHAN_BOND_2_MAX_SKEW                   (1),
            .CHAN_BOND_KEEP_ALIGN                   ("FALSE"),
            .CHAN_BOND_SEQ_1_1                      (10'b0000000000),
            .CHAN_BOND_SEQ_1_2                      (10'b0000000000),
            .CHAN_BOND_SEQ_1_3                      (10'b0000000000),
            .CHAN_BOND_SEQ_1_4                      (10'b0000000000),
            .CHAN_BOND_SEQ_1_ENABLE                 (4'b1111),
            .CHAN_BOND_SEQ_2_1                      (10'b0000000000),
            .CHAN_BOND_SEQ_2_2                      (10'b0000000000),
            .CHAN_BOND_SEQ_2_3                      (10'b0000000000),
            .CHAN_BOND_SEQ_2_4                      (10'b0000000000),
            .CHAN_BOND_SEQ_2_CFG                    (5'b00000),
            .CHAN_BOND_SEQ_2_ENABLE                 (4'b1111),
            .CHAN_BOND_SEQ_2_USE                    ("FALSE"),
            .CHAN_BOND_SEQ_LEN                      (1),
            .PCI_EXPRESS_MODE                       ("FALSE"),

           //-----------RX Attributes for PCI Express/SATA/SAS----------
            .SAS_MAX_COMSAS                         (52),
            .SAS_MIN_COMSAS                         (40),
            .SATA_BURST_VAL                         (3'b100),
            .SATA_IDLE_VAL                          (3'b100),
            .SATA_MAX_BURST                         (7),
            .SATA_MAX_INIT                          (22),
            .SATA_MAX_WAKE                          (7),
            .SATA_MIN_BURST                         (4),
            .SATA_MIN_INIT                          (12),
            .SATA_MIN_WAKE                          (4),
            .TRANS_TIME_FROM_P2                     (12'h03c),
            .TRANS_TIME_NON_P2                      (8'h19),
            .TRANS_TIME_RATE                        (8'hff),
            .TRANS_TIME_TO_P2                       (10'h064)

            
        ) 
        gtxe1_i 
        (
        
        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK                       (LOOPBACK_IN),
        .RXPOWERDOWN                    (2'b00),
        .TXPOWERDOWN                    (2'b00),
        //------------ Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
        .RXDATAVALID                    (),
        .RXGEARBOXSLIP                  (tied_to_ground_i),
        .RXHEADER                       (),
        .RXHEADERVALID                  (),
        .RXSTARTOFSEQ                   (),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXCHARISCOMMA                  (),
        .RXCHARISK                      (RXCHARISK_OUT),
        .RXDEC8B10BUSE                  (tied_to_vcc_i),
        .RXDISPERR                      (RXDISPERR_OUT),
        .RXNOTINTABLE                   (RXNOTINTABLE_OUT),
        .RXRUNDISP                      (),
        .USRCODEERR                     (tied_to_ground_i),
        //----------------- Receive Ports - Channel Bonding Ports ------------------
        .RXCHANBONDSEQ                  (),
        .RXCHBONDI                      (tied_to_ground_vec_i[3:0]),
        .RXCHBONDLEVEL                  (tied_to_ground_vec_i[2:0]),
        .RXCHBONDMASTER                 (tied_to_ground_i),
        .RXCHBONDO                      (),
        .RXCHBONDSLAVE                  (tied_to_ground_i),
        .RXENCHANSYNC                   (tied_to_ground_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT                    (RXCLKCORCNT_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED                (RXBYTEISALIGNED_OUT),
        .RXBYTEREALIGN                  (RXBYTEREALIGN_OUT),
        .RXCOMMADET                     (),
        .RXCOMMADETUSE                  (tied_to_vcc_i),
        .RXENMCOMMAALIGN                (RXENMCOMMAALIGN_IN),
        .RXENPCOMMAALIGN                (RXENPCOMMAALIGN_IN),
        .RXSLIDE                        (tied_to_ground_i),
        //--------------------- Receive Ports - PRBS Detection ---------------------
        .PRBSCNTRESET                   (tied_to_ground_i),
        .RXENPRBSTST                    (tied_to_ground_vec_i[2:0]),
        .RXPRBSERR                      (),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA                         (rxdata_i),
        .RXRECCLK                       (RXRECCLK_OUT),
        .RXRECCLKPCS                    (),
        .RXRESET                        (RXRESET_IN),
        .RXUSRCLK                       (RXUSRCLK_IN),
        .RXUSRCLK2                      (RXUSRCLK2_IN),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .DFECLKDLYADJ                   (tied_to_ground_vec_i[5:0]),
        .DFECLKDLYADJMON                (),
        .DFEDLYOVRD                     (tied_to_vcc_i),
        .DFEEYEDACMON                   (),
        .DFESENSCAL                     (),
        .DFETAP1                        (tied_to_ground_vec_i[4:0]),
        .DFETAP1MONITOR                 (),
        .DFETAP2                        (tied_to_ground_vec_i[4:0]),
        .DFETAP2MONITOR                 (),
        .DFETAP3                        (tied_to_ground_vec_i[3:0]),
        .DFETAP3MONITOR                 (),
        .DFETAP4                        (tied_to_ground_vec_i[3:0]),
        .DFETAP4MONITOR                 (),
        .DFETAPOVRD                     (tied_to_vcc_i),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GATERXELECIDLE                 (tied_to_ground_i),
        .IGNORESIGDET                   (tied_to_ground_i),
        .RXCDRRESET                     (RXBUFRESET_IN),
        .RXELECIDLE                     (RXELECIDLE_OUT),
        .RXEQMIX                        ({tied_to_ground_vec_i[6:0],RXEQMIX_IN}),
        .RXN                            (RXN_IN),
        .RXP                            (RXP_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET                     (RXBUFRESET_IN),
        .RXBUFSTATUS                    (),
        .RXCHANISALIGNED                (),
        .RXCHANREALIGN                  (),
        .RXDLYALIGNDISABLE              (tied_to_ground_i),
        .RXDLYALIGNMONENB               (tied_to_ground_i),
        .RXDLYALIGNMONITOR              (),
        .RXDLYALIGNOVERRIDE             (tied_to_vcc_i),
        .RXDLYALIGNRESET                (tied_to_ground_i),
        .RXDLYALIGNSWPPRECURB           (tied_to_vcc_i),
        .RXDLYALIGNUPDSW                (tied_to_ground_i),
        .RXENPMAPHASEALIGN              (tied_to_ground_i),
        .RXPMASETPHASE                  (tied_to_ground_i),
        .RXSTATUS                       (RXSTATUS_OUT),
        //------------- Receive Ports - RX Loss-of-sync State Machine --------------
        .RXLOSSOFSYNC                   (),
        //-------------------- Receive Ports - RX Oversampling ---------------------
        .RXENSAMPLEALIGN                (tied_to_ground_i),
        .RXOVERSAMPLEERR                (),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GREFCLKRX                      (tied_to_ground_i),
        .GTXRXRESET                     (GTXRXRESET_IN),
        .MGTREFCLKRX                    (MGTREFCLKRX_IN),
        .NORTHREFCLKRX                  (tied_to_ground_vec_i[1:0]),
        .PERFCLKRX                      (tied_to_ground_i),
        .PLLRXRESET                     (PLLRXRESET_IN),
        .RXPLLLKDET                     (RXPLLLKDET_OUT),
        .RXPLLLKDETEN                   (tied_to_vcc_i),
        .RXPLLPOWERDOWN                 (tied_to_ground_i),
        .RXPLLREFSELDY                  (tied_to_ground_vec_i[2:0]),
        .RXRATE                         (tied_to_ground_vec_i[1:0]),
        .RXRATEDONE                     (),
        .RXRESETDONE                    (RXRESETDONE_OUT),
        .SOUTHREFCLKRX                  (tied_to_ground_vec_i[1:0]),
        //------------ Receive Ports - RX Pipe Control for PCI Express -------------
        .PHYSTATUS                      (),
        .RXVALID                        (),
        //--------------- Receive Ports - RX Polarity Control Ports ----------------
        .RXPOLARITY                     (tied_to_ground_i),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .COMINITDET                     (COMINITDET_OUT),
        .COMSASDET                      (),
        .COMWAKEDET                     (COMWAKEDET_OUT),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        .DADDR                          (DADDR),
        .DCLK                           (DCLK),
        .DEN                            (DEN),
        .DI                             (DI),
        .DRDY                           (DRDY),
        .DRPDO                          (DO),
        .DWE                            (DWE),
        //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
        .TXGEARBOXREADY                 (),
        .TXHEADER                       (tied_to_ground_vec_i[2:0]),
        .TXSEQUENCE                     (tied_to_ground_vec_i[6:0]),
        .TXSTARTSEQ                     (tied_to_ground_i),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXBYPASS8B10B                  (tied_to_ground_vec_i[3:0]),
        .TXCHARDISPMODE                 (tied_to_ground_vec_i[3:0]),
        .TXCHARDISPVAL                  (tied_to_ground_vec_i[3:0]),
        .TXCHARISK                      (TXCHARISK_IN),
        .TXENC8B10BUSE                  (tied_to_vcc_i),
        .TXKERR                         (),
        .TXRUNDISP                      (),
        //----------------------- Transmit Ports - GTX Ports -----------------------
        .GTXTEST                        (13'b1000000000000),
        .MGTREFCLKFAB                   (),
        .TSTCLK0                        (tied_to_ground_i),
        .TSTCLK1                        (tied_to_ground_i),
        .TSTIN                          (20'b11111111111111111111),
        .TSTOUT                         (),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA                         (txdata_i),
        .TXOUTCLK                       (TXOUTCLK_OUT),
        .TXOUTCLKPCS                    (),
        .TXRESET                        (TXRESET_IN),
        .TXUSRCLK                       (TXUSRCLK_IN),
        .TXUSRCLK2                      (TXUSRCLK2_IN),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .TXBUFDIFFCTRL                  (3'b100),
        .TXDIFFCTRL                     (TXDIFFCTRL_IN),
        .TXINHIBIT                      (tied_to_ground_i),
        .TXN                            (TXN_OUT),
        .TXP                            (TXP_OUT),
        .TXPOSTEMPHASIS                 (TXPOSTEMPHASIS_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXPREEMPHASIS                  (TXPREEMPHASIS_IN),
        //--------- Transmit Ports - TX Elastic Buffer and Phase Alignment ---------
        .TXBUFSTATUS                    (),
        //------ Transmit Ports - TX Elastic Buffer and Phase Alignment Ports ------
        .TXDLYALIGNDISABLE              (tied_to_vcc_i),
        .TXDLYALIGNMONENB               (tied_to_ground_i),
        .TXDLYALIGNMONITOR              (),
        .TXDLYALIGNOVERRIDE             (tied_to_ground_i),
        .TXDLYALIGNRESET                (tied_to_ground_i),
        .TXDLYALIGNUPDSW                (tied_to_vcc_i),
        .TXENPMAPHASEALIGN              (tied_to_ground_i),
        .TXPMASETPHASE                  (tied_to_ground_i),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GREFCLKTX                      (tied_to_ground_i),
        .GTXTXRESET                     (GTXTXRESET_IN),
        .MGTREFCLKTX                    (MGTREFCLKTX_IN),
        .NORTHREFCLKTX                  (tied_to_ground_vec_i[1:0]),
        .PERFCLKTX                      (tied_to_ground_i),
        .PLLTXRESET                     (PLLTXRESET_IN),
        .SOUTHREFCLKTX                  (tied_to_ground_vec_i[1:0]),
        .TXPLLLKDET                     (TXPLLLKDET_OUT),
        .TXPLLLKDETEN                   (tied_to_vcc_i),
        .TXPLLPOWERDOWN                 (tied_to_ground_i),
        .TXPLLREFSELDY                  (tied_to_ground_vec_i[2:0]),
        .TXRATE                         (tied_to_ground_vec_i[1:0]),
        .TXRATEDONE                     (),
        .TXRESETDONE                    (TXRESETDONE_OUT),
        //------------------- Transmit Ports - TX PRBS Generator -------------------
        .TXENPRBSTST                    (tied_to_ground_vec_i[2:0]),
        .TXPRBSFORCEERR                 (tied_to_ground_i),
        //------------------ Transmit Ports - TX Polarity Control ------------------
        .TXPOLARITY                     (tied_to_ground_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXDEEMPH                       (tied_to_ground_i),
        .TXDETECTRX                     (tied_to_ground_i),
        .TXELECIDLE                     (TXELECIDLE_IN),
        .TXMARGIN                       (tied_to_ground_vec_i[2:0]),
        .TXPDOWNASYNCH                  (tied_to_ground_i),
        .TXSWING                        (tied_to_ground_i),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .COMFINISH                      (COMFINISH_OUT),
        .TXCOMINIT                      (TXCOMINIT_IN),
        .TXCOMSAS                       (tied_to_ground_i),
        .TXCOMWAKE                      (TXCOMWAKE_IN)

     );
     
endmodule     

 

// -----------------------------------------------------------------------------
// Source file: sata2_bus_v1_00_a/base_system/pcores/sata_core_v1_00_a/hdl/verilog/sata_gtx_dual.v
// -----------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version : 1.8
//  \   \         Application : Virtex-6 FPGA GTX Transceiver Wizard
//  /   /         Filename : sata_gtx_dual.v
// /___/   /\     
// \   \  /  \ 
//  \___\/\___\
//
//
// Module SATA_GTX_DUAL (a GTX Wrapper)
// Generated by Xilinx Virtex-6 FPGA GTX Transceiver Wizard
// 
// 
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps


//***************************** Entity Declaration ****************************

(* CORE_GENERATION_INFO = "SATA_PHY,v6_gtxwizard_v1_8,{protocol_file=sata2}" *) 
module SATA_GTX_DUAL #
(
    // Simulation attributes
    parameter   WRAPPER_SIM_GTXRESET_SPEEDUP    = 0    // Set to 1 to speed up sim reset
)
(
    
    //_________________________________________________________________________
    //_________________________________________________________________________
    //GTX0  (X0Y4)

    //---------------------- Loopback and Powerdown Ports ----------------------
    input   [2:0]   GTX0_LOOPBACK_IN,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output  [3:0]   GTX0_RXCHARISK_OUT,
    output  [3:0]   GTX0_RXDISPERR_OUT,
    output  [3:0]   GTX0_RXNOTINTABLE_OUT,
    //----------------- Receive Ports - Clock Correction Ports -----------------
    output  [2:0]   GTX0_RXCLKCORCNT_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    output          GTX0_RXBYTEISALIGNED_OUT,
    output          GTX0_RXBYTEREALIGN_OUT,
    input           GTX0_RXENMCOMMAALIGN_IN,
    input           GTX0_RXENPCOMMAALIGN_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [31:0]  GTX0_RXDATA_OUT,
    output          GTX0_RXRECCLK_OUT,
    input           GTX0_RXRESET_IN,
    input           GTX0_RXUSRCLK_IN,
    input           GTX0_RXUSRCLK2_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    output          GTX0_RXELECIDLE_OUT,
    input   [2:0]   GTX0_RXEQMIX_IN,
    input           GTX0_RXN_IN,
    input           GTX0_RXP_IN,
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    input           GTX0_RXBUFRESET_IN,
    output  [2:0]   GTX0_RXSTATUS_OUT,
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    input           GTX0_GTXRXRESET_IN,
    input           GTX0_MGTREFCLKRX_IN,
    input           GTX0_PLLRXRESET_IN,
    output          GTX0_RXPLLLKDET_OUT,
    output          GTX0_RXRESETDONE_OUT,
    //------------------- Receive Ports - RX Ports for SATA --------------------
    output          GTX0_COMINITDET_OUT,
    output          GTX0_COMWAKEDET_OUT,
    // -------------- Speed Neg Module ports ------------------------
    input [6:0]    DADDR,       //DRP address                     
    input          DEN,		//DRP enable
    input [15:0]   DI,		//DRP data in
    output[15:0]   DO,		//DRP data out
    output         DRDY,	//DRP ready
    input          DWE,		//DRP write enable
    input          DCLK,                           

    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    input   [3:0]   GTX0_TXCHARISK_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [31:0]  GTX0_TXDATA_IN,
    output          GTX0_TXOUTCLK_OUT,
    input           GTX0_TXRESET_IN,
    input           GTX0_TXUSRCLK_IN,
    input           GTX0_TXUSRCLK2_IN,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    input   [3:0]   GTX0_TXDIFFCTRL_IN,
    output          GTX0_TXN_OUT,
    output          GTX0_TXP_OUT,
    input   [4:0]   GTX0_TXPOSTEMPHASIS_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    input   [3:0]   GTX0_TXPREEMPHASIS_IN,
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    input           GTX0_GTXTXRESET_IN,
    output          GTX0_TXRESETDONE_OUT,
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    input           GTX0_TXELECIDLE_IN,
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    output          GTX0_COMFINISH_OUT,
    input           GTX0_TXCOMINIT_IN,
    input           GTX0_TXCOMWAKE_IN,


    
    //_________________________________________________________________________
    //_________________________________________________________________________
    //GTX1  (X0Y5)

    //---------------------- Loopback and Powerdown Ports ----------------------
    input   [2:0]   GTX1_LOOPBACK_IN,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output  [3:0]   GTX1_RXDISPERR_OUT,
    output  [3:0]   GTX1_RXNOTINTABLE_OUT,
    //----------------- Receive Ports - Clock Correction Ports -----------------
    output  [2:0]   GTX1_RXCLKCORCNT_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    output          GTX1_RXBYTEISALIGNED_OUT,
    output          GTX1_RXBYTEREALIGN_OUT,
    input           GTX1_RXENMCOMMAALIGN_IN,
    input           GTX1_RXENPCOMMAALIGN_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [31:0]  GTX1_RXDATA_OUT,
    output          GTX1_RXRECCLK_OUT,
    input           GTX1_RXRESET_IN,
    input           GTX1_RXUSRCLK_IN,
    input           GTX1_RXUSRCLK2_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    output          GTX1_RXELECIDLE_OUT,
    input   [2:0]   GTX1_RXEQMIX_IN,
    input           GTX1_RXN_IN,
    input           GTX1_RXP_IN,
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    input           GTX1_RXBUFRESET_IN,
    output  [2:0]   GTX1_RXSTATUS_OUT,
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    input           GTX1_GTXRXRESET_IN,
    input           GTX1_MGTREFCLKRX_IN,
    input           GTX1_PLLRXRESET_IN,
    output          GTX1_RXPLLLKDET_OUT,
    output          GTX1_RXRESETDONE_OUT,
    //------------------- Receive Ports - RX Ports for SATA --------------------
    output          GTX1_COMINITDET_OUT,
    output          GTX1_COMWAKEDET_OUT,
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    input   [3:0]   GTX1_TXCHARISK_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [31:0]  GTX1_TXDATA_IN,
    output          GTX1_TXOUTCLK_OUT,
    input           GTX1_TXRESET_IN,
    input           GTX1_TXUSRCLK_IN,
    input           GTX1_TXUSRCLK2_IN,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    input   [3:0]   GTX1_TXDIFFCTRL_IN,
    output          GTX1_TXN_OUT,
    output          GTX1_TXP_OUT,
    input   [4:0]   GTX1_TXPOSTEMPHASIS_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    input   [3:0]   GTX1_TXPREEMPHASIS_IN,
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    input           GTX1_GTXTXRESET_IN,
    output          GTX1_TXRESETDONE_OUT,
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    input           GTX1_TXELECIDLE_IN,
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    output          GTX1_COMFINISH_OUT,
    input           GTX1_TXCOMINIT_IN,
    input           GTX1_TXCOMWAKE_IN


);

//***************************** Wire Declarations *****************************

    // ground and vcc signals
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;
 
//********************************* Main Body of Code**************************

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;


//------------------------- GTX Instances  -------------------------------



    //_________________________________________________________________________
    //_________________________________________________________________________
    //GTX0  (X0Y4)

    SATA_GTX #
    (
        // Simulation attributes
        .GTX_SIM_GTXRESET_SPEEDUP   (WRAPPER_SIM_GTXRESET_SPEEDUP),
        
        // Share RX PLL parameter
        .GTX_TX_CLK_SOURCE           ("RXPLL"),
        // Save power parameter
        .GTX_POWER_SAVE              (10'b0000110100)
    )
    gtx0_sata_i
    (
        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK_IN                    (GTX0_LOOPBACK_IN),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXCHARISK_OUT                  (GTX0_RXCHARISK_OUT),
        .RXDISPERR_OUT                  (GTX0_RXDISPERR_OUT),
        .RXNOTINTABLE_OUT               (GTX0_RXNOTINTABLE_OUT),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT_OUT                (GTX0_RXCLKCORCNT_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED_OUT            (GTX0_RXBYTEISALIGNED_OUT),
        .RXBYTEREALIGN_OUT              (GTX0_RXBYTEREALIGN_OUT),
        .RXENMCOMMAALIGN_IN             (GTX0_RXENMCOMMAALIGN_IN),
        .RXENPCOMMAALIGN_IN             (GTX0_RXENPCOMMAALIGN_IN),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA_OUT                     (GTX0_RXDATA_OUT),
        .RXRECCLK_OUT                   (GTX0_RXRECCLK_OUT),
        .RXRESET_IN                     (GTX0_RXRESET_IN),
        .RXUSRCLK_IN                    (GTX0_RXUSRCLK_IN),
        .RXUSRCLK2_IN                   (GTX0_RXUSRCLK2_IN),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .RXELECIDLE_OUT                 (GTX0_RXELECIDLE_OUT),
        .RXEQMIX_IN                     (GTX0_RXEQMIX_IN),
        .RXN_IN                         (GTX0_RXN_IN),
        .RXP_IN                         (GTX0_RXP_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET_IN                  (GTX0_RXBUFRESET_IN),
        .RXSTATUS_OUT                   (GTX0_RXSTATUS_OUT),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTXRXRESET_IN                  (GTX0_GTXRXRESET_IN),
        .MGTREFCLKRX_IN                 ({tied_to_ground_i , GTX0_MGTREFCLKRX_IN}),
        .PLLRXRESET_IN                  (GTX0_PLLRXRESET_IN),
        .RXPLLLKDET_OUT                 (GTX0_RXPLLLKDET_OUT),
        .RXRESETDONE_OUT                (GTX0_RXRESETDONE_OUT),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .COMINITDET_OUT                 (GTX0_COMINITDET_OUT),
        .COMWAKEDET_OUT                 (GTX0_COMWAKEDET_OUT),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        .DADDR                          (DADDR),
        .DCLK                           (DCLK),
        .DEN                            (DEN),
        .DI                             (DI),
        .DRDY                           (DRDY),
        .DO                             (DO),
        .DWE                            (DWE),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXCHARISK_IN                   (GTX0_TXCHARISK_IN),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA_IN                      (GTX0_TXDATA_IN),
        .TXOUTCLK_OUT                   (GTX0_TXOUTCLK_OUT),
        .TXRESET_IN                     (GTX0_TXRESET_IN),
        .TXUSRCLK_IN                    (GTX0_TXUSRCLK_IN),
        .TXUSRCLK2_IN                   (GTX0_TXUSRCLK2_IN),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .TXDIFFCTRL_IN                  (GTX0_TXDIFFCTRL_IN),
        .TXN_OUT                        (GTX0_TXN_OUT),
        .TXP_OUT                        (GTX0_TXP_OUT),
        .TXPOSTEMPHASIS_IN              (GTX0_TXPOSTEMPHASIS_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXPREEMPHASIS_IN               (GTX0_TXPREEMPHASIS_IN),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTXTXRESET_IN                  (GTX0_GTXTXRESET_IN),
        .MGTREFCLKTX_IN                 ({tied_to_ground_i , GTX0_MGTREFCLKRX_IN}),
        .PLLTXRESET_IN                  (tied_to_ground_i),
        .TXPLLLKDET_OUT                 (),
        .TXRESETDONE_OUT                (GTX0_TXRESETDONE_OUT),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXELECIDLE_IN                  (GTX0_TXELECIDLE_IN),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .COMFINISH_OUT                  (GTX0_COMFINISH_OUT),
        .TXCOMINIT_IN                   (GTX0_TXCOMINIT_IN),
        .TXCOMWAKE_IN                   (GTX0_TXCOMWAKE_IN)

    );



    //_________________________________________________________________________
    //_________________________________________________________________________
    //GTX1  (X0Y5)

    SATA_GTX #
    (
        // Simulation attributes
        .GTX_SIM_GTXRESET_SPEEDUP   (WRAPPER_SIM_GTXRESET_SPEEDUP),
        
        // Share RX PLL parameter
        .GTX_TX_CLK_SOURCE           ("RXPLL"),
        // Save power parameter
        .GTX_POWER_SAVE              (10'b0000110100)
    )
    gtx1_sata_i
    (
        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK_IN                    (GTX1_LOOPBACK_IN),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXDISPERR_OUT                  (GTX1_RXDISPERR_OUT),
        .RXNOTINTABLE_OUT               (GTX1_RXNOTINTABLE_OUT),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT_OUT                (GTX1_RXCLKCORCNT_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED_OUT            (GTX1_RXBYTEISALIGNED_OUT),
        .RXBYTEREALIGN_OUT              (GTX1_RXBYTEREALIGN_OUT),
        .RXENMCOMMAALIGN_IN             (GTX1_RXENMCOMMAALIGN_IN),
        .RXENPCOMMAALIGN_IN             (GTX1_RXENPCOMMAALIGN_IN),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA_OUT                     (GTX1_RXDATA_OUT),
        .RXRECCLK_OUT                   (GTX1_RXRECCLK_OUT),
        .RXRESET_IN                     (GTX1_RXRESET_IN),
        .RXUSRCLK_IN                    (GTX1_RXUSRCLK_IN),
        .RXUSRCLK2_IN                   (GTX1_RXUSRCLK2_IN),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .RXELECIDLE_OUT                 (GTX1_RXELECIDLE_OUT),
        .RXEQMIX_IN                     (GTX1_RXEQMIX_IN),
        .RXN_IN                         (GTX1_RXN_IN),
        .RXP_IN                         (GTX1_RXP_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET_IN                  (GTX1_RXBUFRESET_IN),
        .RXSTATUS_OUT                   (GTX1_RXSTATUS_OUT),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTXRXRESET_IN                  (GTX1_GTXRXRESET_IN),
        .MGTREFCLKRX_IN                 ({tied_to_ground_i , GTX1_MGTREFCLKRX_IN}),
        .PLLRXRESET_IN                  (GTX1_PLLRXRESET_IN),
        .RXPLLLKDET_OUT                 (GTX1_RXPLLLKDET_OUT),
        .RXRESETDONE_OUT                (GTX1_RXRESETDONE_OUT),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .COMINITDET_OUT                 (GTX1_COMINITDET_OUT),
        .COMWAKEDET_OUT                 (GTX1_COMWAKEDET_OUT),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXCHARISK_IN                   (GTX1_TXCHARISK_IN),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA_IN                      (GTX1_TXDATA_IN),
        .TXOUTCLK_OUT                   (GTX1_TXOUTCLK_OUT),
        .TXRESET_IN                     (GTX1_TXRESET_IN),
        .TXUSRCLK_IN                    (GTX1_TXUSRCLK_IN),
        .TXUSRCLK2_IN                   (GTX1_TXUSRCLK2_IN),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .TXDIFFCTRL_IN                  (GTX1_TXDIFFCTRL_IN),
        .TXN_OUT                        (GTX1_TXN_OUT),
        .TXP_OUT                        (GTX1_TXP_OUT),
        .TXPOSTEMPHASIS_IN              (GTX1_TXPOSTEMPHASIS_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXPREEMPHASIS_IN               (GTX1_TXPREEMPHASIS_IN),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTXTXRESET_IN                  (GTX1_GTXTXRESET_IN),
        .MGTREFCLKTX_IN                 ({tied_to_ground_i , GTX1_MGTREFCLKRX_IN}),
        .PLLTXRESET_IN                  (tied_to_ground_i),
        .TXPLLLKDET_OUT                 (),
        .TXRESETDONE_OUT                (GTX1_TXRESETDONE_OUT),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXELECIDLE_IN                  (GTX1_TXELECIDLE_IN),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .COMFINISH_OUT                  (GTX1_COMFINISH_OUT),
        .TXCOMINIT_IN                   (GTX1_TXCOMINIT_IN),
        .TXCOMWAKE_IN                   (GTX1_TXCOMWAKE_IN)

    );



endmodule

    

// -----------------------------------------------------------------------------
// Source file: sata2_fifo_v1_00_a/hdl/verilog/mgt_usrclk_source_mmcm.v
// -----------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 1.8
//  \   \         Application :  Virtex-6 FPGA GTX Transceiver Wizard
//  /   /         Filename : mgt_usrclk_source_mmcm.v
// /___/   /\     Timestamp : 
// \   \  /  \ 
//  \___\/\___\ 
//
//
// Module MGT_USRCLK_SOURCE (for use with GTX Transceivers)
// Generated by Xilinx Virtex-6 FPGA GTX Transceiver Wizard
// 
// 
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps

//***********************************Entity Declaration*******************************
module MGT_USRCLK_SOURCE_MMCM #
(
    parameter   MULT            =   2,
    parameter   DIVIDE          =   2,
    parameter   CLK_PERIOD      =   6.4,
    parameter   OUT0_DIVIDE     =   2,
    parameter   OUT1_DIVIDE     =   2,
    parameter   OUT2_DIVIDE     =   2,
    parameter   OUT3_DIVIDE     =   2   
)
(
    output          CLK0_OUT,
    output          CLK1_OUT,
    output          CLK2_OUT,
    output          CLK3_OUT,
    input           CLK_IN,
    output          MMCM_LOCKED_OUT,
    input           MMCM_RESET_IN
);


`define DLY #1

//*********************************Wire Declarations**********************************

    wire    [15:0]  tied_to_ground_vec_i;
    wire            tied_to_ground_i;
    wire            clkout0_i;
    wire            clkout1_i;
    wire            clkout2_i;
    wire            clkout3_i;
    wire            clkfbout_i;

//*********************************** Beginning of Code *******************************

    //  Static signal Assigments    
    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 16'h0000;

    // Instantiate a MMCM module to divide the reference clock. Uses internal feedback
    // for improved jitter performance, and to avoid consuming an additional BUFG
    MMCM_ADV #
    (
         .COMPENSATION      ("ZHOLD"),
         .CLKFBOUT_MULT_F   (MULT),
         .DIVCLK_DIVIDE     (DIVIDE),
         .CLKFBOUT_PHASE    (0),
         
         .CLKIN1_PERIOD     (CLK_PERIOD),
         .CLKIN2_PERIOD     (10),   //Not used
         
         .CLKOUT0_DIVIDE_F  (OUT0_DIVIDE),
         .CLKOUT0_PHASE     (0),
         
         .CLKOUT1_DIVIDE    (OUT1_DIVIDE),
         .CLKOUT1_PHASE     (0),

         .CLKOUT2_DIVIDE    (OUT2_DIVIDE),
         .CLKOUT2_PHASE     (0),
         
         .CLKOUT3_DIVIDE    (OUT3_DIVIDE),
         .CLKOUT3_PHASE     (0),
         .CLOCK_HOLD        ("TRUE")        
    )
    mmcm_adv_i   
    (
         .CLKIN1            (CLK_IN),
         .CLKIN2            (1'b0),
         .CLKINSEL          (1'b1),
         .CLKFBIN           (clkfbout_i),
         .CLKOUT0           (clkout0_i),
         .CLKOUT0B          (),
         .CLKOUT1           (clkout1_i),
         .CLKOUT1B          (),         
         .CLKOUT2           (clkout2_i),
         .CLKOUT2B          (),         
         .CLKOUT3           (clkout3_i),
         .CLKOUT3B          (),         
         .CLKOUT4           (),
         .CLKOUT5           (),
         .CLKOUT6           (),
         .CLKFBOUT          (clkfbout_i),
         .CLKFBOUTB         (),
         .CLKFBSTOPPED      (),
         .CLKINSTOPPED      (),
         .DO                (),
         .DRDY              (),
         .DADDR             (7'd0),
         .DCLK              (1'b0),
         .DEN               (1'b0),
         .DI                (16'd0),
         .DWE               (1'b0),
         .LOCKED            (MMCM_LOCKED_OUT),
         .PSCLK             (1'b0),
         .PSEN              (1'b0),         
         .PSINCDEC          (1'b0), 
         .PSDONE            (),         
         .PWRDWN            (1'b0),         
         .RST               (MMCM_RESET_IN)
    );
    
    BUFG clkout0_bufg_i  
    (
        .O              (CLK0_OUT), 
        .I              (clkout0_i)
    ); 


    BUFG clkout1_bufg_i
    (
        .O              (CLK1_OUT),
        .I              (clkout1_i)
    );


    BUFG clkout2_bufg_i 
    (
        .O              (CLK2_OUT),
        .I              (clkout2_i)
    );
    
    
    BUFG clkout3_bufg_i
    (
        .O              (CLK3_OUT),
        .I              (clkout3_i)
    );    

endmodule


// -----------------------------------------------------------------------------
// Source file: sata2_fifo_v1_00_a/hdl/verilog/mux_21.v
// -----------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Entity   mux_21 
// Version: 1.0
// Author:  Ashwin Mendon 
// Description: 2 bit 2:1 Multiplexer
//--------------------------------------------------------------------------------

// Copyright (C) 2012
// Ashwin A. Mendon
//
// This file is part of SATA2 core.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.  


module mux_21 
   (
    input wire [1:0] a,
    input wire [1:0] b,
    input wire   sel,
    output reg [1:0] o
    );

  always @ (a or b or sel)
  begin
    case (sel)
      1'b0: 
          o = a;
      1'b1: 
          o = b;
    endcase
  end

endmodule


// -----------------------------------------------------------------------------
// Source file: sata2_fifo_v1_00_a/hdl/verilog/mux_41.v
// -----------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Entity   mux_21 
// Version: 1.0
// Author:  Ashwin Mendon 
// Description: 32 bit 4:1 Multiplexer
//--------------------------------------------------------------------------------

// Copyright (C) 2012
// Ashwin A. Mendon
//
// This file is part of SATA2 core.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.  


module mux_41 
   (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] c,
    input wire [31:0] d,
    input wire [1:0] sel,
    output reg [31:0] o
    );

  always @ (a or b or c or d or sel)
  begin
    case (sel)
      2'b00: 
          o = a;
      2'b01: 
          o = b;
      2'b10: 
          o = c; 
      2'b11:
          o = d;  
     endcase     
  end

endmodule


// -----------------------------------------------------------------------------
// Source file: sata2_fifo_v1_00_a/hdl/verilog/oob_control.v
// -----------------------------------------------------------------------------
//*****************************************************************************/
// Module :     OOB_control 
// Version:     1.0
// Author:      Ashwin Mendon 
// Description: This module handles the Out-Of-Band (OOB) sinaling requirements
//               for link initialization and synchronization 
//              It has been modified from Xilinx XAPP870 to support Virtex 6 GTX
//              transceivers 
//*****************************************************************************/

module OOB_control (

 clk,	// Clock
 reset,	// reset	
 oob_control_ila_control,
 
 /**** GTX ****/
 rxreset,	// GTX PCS reset
 rx_locked,	// GTX PLL is locked
 gen2,		// Generation 2 speed
 txcominit,	// TX OOB issue  RESET/INIT
 txcomwake,	// TX OOB issue  WAKE
 cominitdet,	// RX OOB detect INIT 
 comwakedet,	// RX OOB detect WAKE 
 rxelecidle,	// RX electrical idle
 txelecidle_out,// TX electircal idel
 rxbyteisaligned,// RX byte alignment completed

 tx_dataout,	// Outgoing TX data to GTX
 tx_charisk_out,// TX byted is K character
 
 rx_datain,    // Data from GTX            
 rx_charisk_in,   // K character from GTX                        
 /**** GTX ****/

 /**** LINK LAYER ****/
 // INPUT 
 tx_datain,	// Incoming TX data from SATA Link Layer 
 tx_charisk_in, // K character indicator                          
 // OUTPUT 
 rx_dataout,   // Data to SATA Link Layer
 rx_charisk_out, 

 linkup,	// SATA link is established
 linkup_led_out, // LINKUP LED output
 align_en_out,
 CurrentState_out // Current state for Chipscope
 /**** LINK LAYER ****/ 

);

        parameter       CHIPSCOPE  = "FALSE";	
	input		clk;
	input 		reset;
        input   [35:0]  oob_control_ila_control;
	input 		rx_locked;
	input           gen2;
        // Added for GTX	
	input		cominitdet;
	input		comwakedet;
        // Added for GTX	
	input		rxelecidle;
	input		rxbyteisaligned;
	input	[31:0]  tx_datain;
	input	        tx_charisk_in;
	input	[3:0]   rx_charisk_in;   		
	input	[31:0]  rx_datain;      //changed for GTX 
      
	output		rxreset;
        // Added for GTX	
	output		txcominit;
	output		txcomwake;
        // Added for GTX	
	output 		txelecidle_out;
	output	[31:0]  tx_dataout;     //changed for GTX 
	output          tx_charisk_out;                                
                                         
	output	[31:0]  rx_dataout;
	output	[3:0]   rx_charisk_out;
	output          linkup;
	output          linkup_led_out;
	output          align_en_out;
	output	[7:0]   CurrentState_out;
	
	parameter [3:0]
	host_comreset		= 8'h00,
	wait_dev_cominit	= 8'h01,
	host_comwake 		= 8'h02, 
	wait_dev_comwake 	= 8'h03,
	wait_after_comwake 	= 8'h04,
	wait_after_comwake1 	= 8'h05,
	host_d10_2 		= 8'h06,
	host_send_align 	= 8'h07,
	link_ready 		= 8'h08,
        link_idle               = 8'h09;

        // Primitves
        parameter ALIGN      = 4'b00;
        parameter SYNC       = 4'b01;
        parameter DIAL       = 4'b10;
        //parameter R_RDY      = 4'b11;
        parameter LINK_LAYER = 4'b11;

	reg	[7:0]	CurrentState, NextState;
	reg	[17:0]	count;
	reg	[3:0]	align_char_cnt_reg;
	reg		align_char_cnt_rst, align_char_cnt_inc;
	reg		count_en;
	reg		tx_charisk, tx_charisk_next;
	reg		txelecidle, txelecidle_next;
	reg        	linkup_r, linkup_r_next;
	reg		rxreset; 
	reg	[31:0]  tx_datain_r;
	wire	[31:0]  tx_dataout_i;
	reg	[31:0]  rx_dataout_i;
	wire	[31:0]  tx_align, tx_sync, tx_dial, tx_r_rdy;
	reg     [3:0]   rx_charisk_r;
	reg		txcominit_r, txcomwake_r;
        wire    [1:0]   align_count_mux_out;
        reg     [8:0]   align_count;
        reg     [1:0]   prim_type, prim_type_next;
      
	wire		align_det, sync_det, cont_det, sof_det, eof_det, x_rdy_det, r_err_det, r_ok_det;
        reg             align_en, align_en_r;
        reg             rxelecidle_r;
        reg     [31:0]  rx_datain_r;
        reg     [3:0]   rx_charisk_in_r;
        reg             rxbyteisaligned_r;
        reg             comwakedet_r, cominitdet_r;

// OOB FSM Logic Process
				
always @ ( CurrentState or count or rxelecidle_r or rx_locked or rx_datain_r or
           cominitdet_r or comwakedet_r or 
           align_det or sync_det or cont_det or 
           tx_charisk_in )
begin : Comb_FSM
 
	count_en = 1'b0;
	NextState = host_comreset;
	linkup_r_next = linkup_r;
	txcominit_r =1'b0;
	txcomwake_r = 1'b0;
	rxreset = 1'b0;
	txelecidle_next = txelecidle;
        prim_type_next = prim_type;
        tx_charisk_next = tx_charisk;			
        rx_dataout_i  = 32'b0;
        rx_charisk_r = 4'b0;

       case (CurrentState)
		host_comreset :
			begin
			        txelecidle_next = 1'b1;
			        prim_type_next = ALIGN; 
				if (rx_locked)
					begin 
						if ((~gen2 && count == 18'h00051) || (gen2 && count == 18'h000A2))
						begin
							txcominit_r =1'b0;	
							NextState = wait_dev_cominit;
						end
						else  //Issue COMRESET  
						begin
							txcominit_r =1'b1;	
							count_en = 1'b1;
							NextState = host_comreset;						
						end
					end
				else
					begin
						txcominit_r =1'b0;	
						NextState = host_comreset;
					end													
			end						

		wait_dev_cominit : //1
			begin
				if (cominitdet_r == 1'b1) //device cominit detected				
				begin
					NextState = host_comwake;
				end
				else
				begin
					`ifdef SIM
					if(count == 18'h001ff) 
					`else
					if(count == 18'h203AD) //restart comreset after no cominit for at least 880us
					`endif
					begin
						count_en = 1'b0;
						NextState = host_comreset;
					end
					else
					begin
						count_en = 1'b1;
						NextState = wait_dev_cominit;
					end
				end
			end

		host_comwake : //2
			begin
				if ((~gen2 && count == 18'h0004E) || (gen2 && count == 18'h0009B))
				begin
					txcomwake_r =1'b0;	
					NextState = wait_dev_comwake;
				end
				else
				begin
					txcomwake_r =1'b1;	
					count_en = 1'b1;
					NextState = host_comwake;						
				end

			end

		wait_dev_comwake : //3 
			begin
				if (comwakedet_r == 1'b1) //device comwake detected				
				begin
					NextState = wait_after_comwake;
				end
				else
				begin
					if(count == 18'h203AD) //restart comreset after no cominit for 880us
					begin
						count_en = 1'b0;
						NextState = host_comreset;
					end
					else
					begin
						count_en = 1'b1;
						NextState = wait_dev_comwake;
					end
				end
			end


		wait_after_comwake : // 4
			begin
				if (count == 6'h3F)
				begin
					NextState = wait_after_comwake1;
				end
				else
				begin
					count_en = 1'b1;
					
					NextState = wait_after_comwake;
				end
			end		


		wait_after_comwake1 : //5
			begin
				if (rxelecidle_r == 1'b0)
				begin
					rxreset = 1'b1;
					NextState = host_d10_2;
				end
				else
					NextState = wait_after_comwake1; 	
			end

		host_d10_2 : //6
		begin
			txelecidle_next = 1'b0;

                        // D10.2-D10.2 "dial tone"
			rx_dataout_i  = rx_datain_r;
			prim_type_next = DIAL; 
			tx_charisk_next = 1'b0;			

			if (align_det)
			begin
				NextState = host_send_align;
			end
			else
			begin
				if(count == 18'h203AD) // restart comreset after 880us
				begin
					count_en = 1'b0;
					NextState = host_comreset;						
				end
				else
				begin
					count_en = 1'b1;
					NextState = host_d10_2;
				end
			end				
		end	
				
		host_send_align : //7
		begin
                        rx_dataout_i  = rx_datain_r;
                        
                	// Send Align primitives. Align is 
			// K28.5, D10.2, D10.2, D27.3
                        prim_type_next = ALIGN;
			tx_charisk_next = 1'b1;			
			
			if (sync_det) // SYNC detected
			begin
				linkup_r_next = 1'b1;
				NextState = link_ready;
			end
			else
				NextState = host_send_align;
		end
			
			
		link_ready : // 8
		begin
			if (rxelecidle_r == 1'b1)
			begin
				NextState = link_ready;
				linkup_r_next = 1'b0;
			end
			else
			begin
				NextState = link_ready;
				linkup_r_next = 1'b1;
				rx_charisk_r = rx_charisk_in_r;
				rx_dataout_i = rx_datain_r;
                                // Send LINK_LAYER DATA
                                prim_type_next = LINK_LAYER;
                                if (align_en)
			           tx_charisk_next = 1'b1;
                                else
			           tx_charisk_next = tx_charisk_in;
			end
		end
            
	        
		default : NextState = host_comreset;	
	endcase
end	


// OOB FSM Synchronous Process

always@(posedge clk or posedge reset)
begin : Seq_FSM 
	if (reset)
        begin
		CurrentState       <= host_comreset;
                prim_type          <= ALIGN;
                tx_charisk         <= 1'b0;
                txelecidle         <= 1'b1;
                linkup_r           <= 1'b0;
                align_en_r         <= 1'b0;
                rxelecidle_r       <= 1'b0;
                rx_datain_r        <= 32'b0;
                rx_charisk_in_r    <= 4'b0;
                rxbyteisaligned_r  <= 1'b0; 
                cominitdet_r       <= 1'b0;
                comwakedet_r       <= 1'b0;
	end
	else
        begin
		CurrentState      <= NextState;
                prim_type         <= prim_type_next;
                tx_charisk        <= tx_charisk_next;
                txelecidle        <= txelecidle_next;
	        linkup_r          <= linkup_r_next;
                align_en_r        <= align_en;
                rxelecidle_r      <= rxelecidle;
                rx_datain_r       <= rx_datain;
                rx_charisk_in_r   <= rx_charisk_in; 
                rxbyteisaligned_r <= rxbyteisaligned; 
                cominitdet_r      <= cominitdet;
                comwakedet_r      <= comwakedet;
        end
end


always@(posedge clk or posedge reset)
begin : freecount
	if (reset)
	begin
		count <= 18'b0;
	end	
	else if (count_en)
	begin  
		count <= count + 1;
	end
     	else
     	begin
		count <= 18'b0;

	end
end



assign txcominit = txcominit_r;
assign txcomwake = txcomwake_r;
assign txelecidle_out = txelecidle;
//Primitive detection
// Changed for 32-bit GTX
assign align_det = (rx_datain_r == 32'h7B4A4ABC) && (rxbyteisaligned_r == 1'b1); //prevent invalid align at wrong speed
assign sync_det  = (rx_datain_r == 32'hB5B5957C);
assign cont_det  = (rx_datain_r == 32'h9999AA7C);
assign sof_det   = (rx_datain_r == 32'h3737B57C);
assign eof_det   = (rx_datain_r == 32'hD5D5B57C);
assign x_rdy_det = (rx_datain_r == 32'h5757B57C);
assign r_err_det = (rx_datain_r == 32'h5656B57C);
assign r_ok_det  = (rx_datain_r == 32'h3535B57C);

assign linkup = linkup_r;
assign linkup_led_out = ((CurrentState == link_ready) && (rxelecidle_r == 1'b0)) ? 1'b1 : 1'b0;
assign CurrentState_out = CurrentState;
assign rx_charisk_out = rx_charisk_r;
assign tx_charisk_out = tx_charisk;
assign rx_dataout  = rx_dataout_i;

// SATA Primitives 

// ALIGN
assign tx_align  = 32'h7B4A4ABC;

// SYNC
assign tx_sync   = 32'hB5B5957C;

// Dial Tone
assign tx_dial   = 32'h4A4A4A4A;

// R_RDY
assign tx_r_rdy  = 32'h4A4A957C;

// Mux to switch between ALIGN and other primitives/data
mux_21 i_align_count
  (
   .a   (prim_type),
   .b   (ALIGN),
   .sel (align_en_r),
   .o   (align_count_mux_out)
  );
 // Output to Link Layer to Pause writing data frame
 assign align_en_out = align_en;

//ALIGN Primitives transmitted every 256 DWORDS for speed alignment
always@(posedge clk or posedge reset)
begin : align_cnt
	if (reset)
        begin
           align_count <= 9'b0;
        end 
	else if (align_count < 9'h0FF) //255
        begin       
           if (align_count == 9'h001) //de-assert after 2 ALIGN primitives
           begin
                align_en <= 1'b0;
           end  
           align_count <= align_count + 1;
        end
     	else
        begin     
           align_count <= 9'b0;
           align_en <= 1'b1;
        end
end


//OUTPUT MUX
mux_41 i_tx_out
  (
    .a    (tx_align),
    .b    (tx_sync),
    .c    (tx_dial),
    //.d    (tx_r_rdy),
    .d    (tx_datain),
    .sel  (align_count_mux_out),
    .o    (tx_dataout_i)
  );

assign tx_dataout = tx_dataout_i;


// OOB ILA
wire [15:0] trig0;
wire [15:0] trig1;
wire [15:0] trig2;
wire [15:0] trig3;
wire [31:0] trig4;
wire [3:0]  trig5;
wire [31:0] trig6;
wire [31:0] trig7;
wire [35:0] control;

if (CHIPSCOPE == "TRUE") begin
 oob_control_ila  i_oob_control_ila  
    (
      .control(oob_control_ila_control),
      .clk(clk),
      .trig0(trig0),
      .trig1(trig1),
      .trig2(trig2),
      .trig3(trig3),
      .trig4(trig4),
      .trig5(trig5),
      .trig6(trig6),
      .trig7(trig7)
    );
end

assign trig0[0] = txcomwake_r;
assign trig0[1] = tx_charisk;
assign trig0[2] = rxbyteisaligned_r;
assign trig0[3] = count_en;
assign trig0[4] = tx_charisk_in;
assign trig0[5] = txelecidle;
assign trig0[6] = rx_locked;
assign trig0[7] = gen2;
assign trig0[11:8] = rx_charisk_in_r;
assign trig0[15:12] = 4'b0;
assign trig1[15:12] =  prim_type;
assign trig1[11:10] = 2'b0;
assign trig1[9] = align_en_r;
assign trig1[8]  = rxelecidle_r;
assign trig1[7:0] = CurrentState_out;
assign trig2[15:7] = align_count;
assign trig2[6:5] = 2'b0;
assign trig2[4] = cominitdet_r;
assign trig2[3] = comwakedet_r;
assign trig2[2] = align_det;
assign trig2[1] = sync_det;
assign trig2[0] = cont_det;
assign trig3[0] = sof_det;
assign trig3[1] = eof_det;
assign trig3[2] = x_rdy_det;
assign trig3[3] = r_err_det;
assign trig3[4] = r_ok_det;
assign trig3[15:5] =  11'b0;
assign trig4 =  rx_datain_r;
assign trig5[0] = txcominit_r;
assign trig5[1] = linkup_r;
assign trig5[2] = align_en;
assign trig5[3] = 1'b0;
assign trig6 =  tx_datain;
assign trig7  = tx_dataout_i;

endmodule

module oob_control_ila 
  (
    control,
    clk,
    trig0,
    trig1,
    trig2,
    trig3,
    trig4,
    trig5,
    trig6,
    trig7
  );
  input [35:0] control;
  input clk;
  input [15:0] trig0;
  input [15:0] trig1;
  input [15:0] trig2;
  input [15:0] trig3;
  input [31:0] trig4;
  input [3:0]  trig5;
  input [31:0] trig6;
  input [31:0] trig7;
  
endmodule

// -----------------------------------------------------------------------------
// Source file: sata2_fifo_v1_00_a/hdl/verilog/sata_gtx.v
// -----------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version : 1.8
//  \   \         Application : Virtex-6 FPGA GTX Transceiver Wizard
//  /   /         Filename : sata_gtx.v
// /___/   /\     Timestamp :
// \   \  /  \ 
//  \___\/\___\
//
//
// Module SATA_GTX (a GTX Wrapper)
// Generated by Xilinx Virtex-6 FPGA GTX Transceiver Wizard
// 
// 
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps


//***************************** Entity Declaration ****************************

module SATA_GTX #
(
    // Simulation attributes
    parameter   GTX_SIM_GTXRESET_SPEEDUP   =   0,      // Set to 1 to speed up sim reset
    
    // Share RX PLL parameter
    parameter   GTX_TX_CLK_SOURCE          =   "TXPLL",
    // Save power parameter
    parameter   GTX_POWER_SAVE             =   10'b0000000000
)
(
    //---------------------- Loopback and Powerdown Ports ----------------------
    input   [2:0]   LOOPBACK_IN,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output  [3:0]   RXCHARISK_OUT,
    output  [3:0]   RXDISPERR_OUT,
    output  [3:0]   RXNOTINTABLE_OUT,
    //----------------- Receive Ports - Clock Correction Ports -----------------
    output  [2:0]   RXCLKCORCNT_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    output          RXBYTEISALIGNED_OUT,
    output          RXBYTEREALIGN_OUT,
    input           RXENMCOMMAALIGN_IN,
    input           RXENPCOMMAALIGN_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [31:0]  RXDATA_OUT,
    output          RXRECCLK_OUT,
    input           RXRESET_IN,
    input           RXUSRCLK_IN,
    input           RXUSRCLK2_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    output          RXELECIDLE_OUT,
    input   [2:0]   RXEQMIX_IN,
    input           RXN_IN,
    input           RXP_IN,
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    input           RXBUFRESET_IN,
    output  [2:0]   RXSTATUS_OUT,
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    input           GTXRXRESET_IN,
    input   [1:0]   MGTREFCLKRX_IN,
    input           PLLRXRESET_IN,
    output          RXPLLLKDET_OUT,
    output          RXRESETDONE_OUT,
    //------------------- Receive Ports - RX Ports for SATA --------------------
    output          COMINITDET_OUT,
    output          COMWAKEDET_OUT,
    // -------------- Speed Neg Module ports ------------------------
    input [6:0]    DADDR,       //DRP address                     
    input          DEN,		//DRP enable
    input [15:0]   DI,		//DRP data in
    output[15:0]   DO,		//DRP data out
    output         DRDY,	//DRP ready
    input          DWE,		//DRP write enable
    input          DCLK,                           

    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    input   [3:0]   TXCHARISK_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [31:0]  TXDATA_IN,
    output          TXOUTCLK_OUT,
    input           TXRESET_IN,
    input           TXUSRCLK_IN,
    input           TXUSRCLK2_IN,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    input   [3:0]   TXDIFFCTRL_IN,
    output          TXN_OUT,
    output          TXP_OUT,
    input   [4:0]   TXPOSTEMPHASIS_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    input   [3:0]   TXPREEMPHASIS_IN,
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    input           GTXTXRESET_IN,
    input   [1:0]   MGTREFCLKTX_IN,
    input           PLLTXRESET_IN,
    output          TXPLLLKDET_OUT,
    output          TXRESETDONE_OUT,
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    input           TXELECIDLE_IN,
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    output          COMFINISH_OUT,
    input           TXCOMINIT_IN,
    input           TXCOMWAKE_IN


);


//***************************** Wire Declarations *****************************

    // ground and vcc signals
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;


    //RX Datapath signals
    wire    [31:0]  rxdata_i;


    //TX Datapath signals
    wire    [31:0]  txdata_i;           
        
// 
//********************************* Main Body of Code**************************
                       
    //-------------------------  Static signal Assigments ---------------------   

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;
    
    //-------------------  GTX Datapath byte mapping  -----------------
    // The GTX provides little endian data (first byte received on RXDATA[7:0])
    assign  RXDATA_OUT    =   rxdata_i;

    // The GTX transmits little endian data (TXDATA[7:0] transmitted first)
    assign  txdata_i    =   TXDATA_IN;





    //------------------------- GTX Instantiations  --------------------------
        GTXE1 #
        (
            //_______________________ Simulation-Only Attributes __________________
    
            //.SIM_RECEIVER_DETECT_PASS   ("TRUE"),
            
            //.SIM_TX_ELEC_IDLE_LEVEL     ("X"),
    
            //.SIM_GTXRESET_SPEEDUP       (GTX_SIM_GTXRESET_SPEEDUP),
            //.SIM_VERSION                ("2.0"),
            //.SIM_TXREFCLK_SOURCE        (3'b000),
            //.SIM_RXREFCLK_SOURCE        (3'b000),
            

           //--------------------------TX PLL----------------------------
            .TX_CLK_SOURCE                          (GTX_TX_CLK_SOURCE),
            .TX_OVERSAMPLE_MODE                     ("FALSE"),
            .TXPLL_COM_CFG                          (24'h21680a),
            .TXPLL_CP_CFG                           (8'h0D),
            .TXPLL_DIVSEL_FB                        (2),
            .TXPLL_DIVSEL_OUT                       (1),
            .TXPLL_DIVSEL_REF                       (1),
            .TXPLL_DIVSEL45_FB                      (5),
            .TXPLL_LKDET_CFG                        (3'b111),
            .TX_CLK25_DIVIDER                       (6),
            .TXPLL_SATA                             (2'b01),
            .TX_TDCC_CFG                            (2'b11),
            .PMA_CAS_CLK_EN                         ("FALSE"),
            .POWER_SAVE                             (GTX_POWER_SAVE),

           //-----------------------TX Interface-------------------------
            .GEN_TXUSRCLK                           ("FALSE"),
            .TX_DATA_WIDTH                          (40),
            .TX_USRCLK_CFG                          (6'h00),
            //.TXOUTCLK_CTRL                          ("TXOUTCLKPMA_DIV2"),
            .TXOUTCLK_CTRL                          ("TXPLLREFCLK_DIV2"),
            .TXOUTCLK_DLY                           (10'b0000000000),

           //------------TX Buffering and Phase Alignment----------------
            .TX_PMADATA_OPT                         (1'b0),
            .PMA_TX_CFG                             (20'h80082),
            .TX_BUFFER_USE                          ("TRUE"),
            .TX_BYTECLK_CFG                         (6'h00),
            .TX_EN_RATE_RESET_BUF                   ("TRUE"),
            .TX_XCLK_SEL                            ("TXOUT"),
            .TX_DLYALIGN_CTRINC                     (4'b0100),
            .TX_DLYALIGN_LPFINC                     (4'b0110),
            .TX_DLYALIGN_MONSEL                     (3'b000),
            .TX_DLYALIGN_OVRDSETTING                (8'b10000000),

           //-----------------------TX Gearbox---------------------------
            .GEARBOX_ENDEC                          (3'b000),
            .TXGEARBOX_USE                          ("FALSE"),

           //--------------TX Driver and OOB Signalling------------------
            .TX_DRIVE_MODE                          ("DIRECT"),
            .TX_IDLE_ASSERT_DELAY                   (3'b100),
            .TX_IDLE_DEASSERT_DELAY                 (3'b010),
            .TXDRIVE_LOOPBACK_HIZ                   ("FALSE"),
            .TXDRIVE_LOOPBACK_PD                    ("FALSE"),

           //------------TX Pipe Control for PCI Express/SATA------------
            .COM_BURST_VAL                          (4'b0101),

           //----------------TX Attributes for PCI Express---------------
            .TX_DEEMPH_0                            (5'b11010),
            .TX_DEEMPH_1                            (5'b10000),
            .TX_MARGIN_FULL_0                       (7'b1001110),
            .TX_MARGIN_FULL_1                       (7'b1001001),
            .TX_MARGIN_FULL_2                       (7'b1000101),
            .TX_MARGIN_FULL_3                       (7'b1000010),
            .TX_MARGIN_FULL_4                       (7'b1000000),
            .TX_MARGIN_LOW_0                        (7'b1000110),
            .TX_MARGIN_LOW_1                        (7'b1000100),
            .TX_MARGIN_LOW_2                        (7'b1000010),
            .TX_MARGIN_LOW_3                        (7'b1000000),
            .TX_MARGIN_LOW_4                        (7'b1000000),

           //--------------------------RX PLL----------------------------
            .RX_OVERSAMPLE_MODE                     ("FALSE"),
            .RXPLL_COM_CFG                          (24'h21680a),
            .RXPLL_CP_CFG                           (8'h0D),
            .RXPLL_DIVSEL_FB                        (2),
            .RXPLL_DIVSEL_OUT                       (1),
            .RXPLL_DIVSEL_REF                       (1),
            .RXPLL_DIVSEL45_FB                      (5),
            .RXPLL_LKDET_CFG                        (3'b111),
            .RX_CLK25_DIVIDER                       (6),

           //-----------------------RX Interface-------------------------
            .GEN_RXUSRCLK                           ("FALSE"),
            .RX_DATA_WIDTH                          (40),
            .RXRECCLK_CTRL                          ("RXRECCLKPMA_DIV2"),
            .RXRECCLK_DLY                           (10'b0000000000),
            .RXUSRCLK_DLY                           (16'h0000),

           //--------RX Driver,OOB signalling,Coupling and Eq.,CDR-------
            .AC_CAP_DIS                             ("FALSE"),
            .CDR_PH_ADJ_TIME                        (5'b10100),
            .OOBDETECT_THRESHOLD                    (3'b111),
            //.PMA_CDR_SCAN                           (27'h640404C),
            .PMA_CDR_SCAN                           (27'h6C08040),
            //.PMA_RX_CFG                             (25'h05ce049),
            .PMA_RX_CFG                             (25'h0DCE111),
            .RCV_TERM_GND                           ("FALSE"),
            .RCV_TERM_VTTRX                         ("TRUE"),
            .RX_EN_IDLE_HOLD_CDR                    ("FALSE"),
            .RX_EN_IDLE_RESET_FR                    ("TRUE"),
            .RX_EN_IDLE_RESET_PH                    ("TRUE"),
            .TX_DETECT_RX_CFG                       (14'h1832),
            .TERMINATION_CTRL                       (5'b00000),
            .TERMINATION_OVRD                       ("FALSE"),
            .CM_TRIM                                (2'b01),
            .PMA_RXSYNC_CFG                         (7'h00),
            .PMA_CFG                                (76'h0040000040000000003),
            .BGTEST_CFG                             (2'b00),
            .BIAS_CFG                               (17'h00000),

           //------------RX Decision Feedback Equalizer(DFE)-------------
            .DFE_CAL_TIME                           (5'b01100),
            .DFE_CFG                                (8'b00011011),
            .RX_EN_IDLE_HOLD_DFE                    ("TRUE"),
            .RX_EYE_OFFSET                          (8'h4C),
            .RX_EYE_SCANMODE                        (2'b00),

           //-----------------------PRBS Detection-----------------------
            .RXPRBSERR_LOOPBACK                     (1'b0),

           //----------------Comma Detection and Alignment---------------
            .ALIGN_COMMA_WORD                       (2),
            .COMMA_10B_ENABLE                       (10'b1111111111),
            .COMMA_DOUBLE                           ("FALSE"),
            .DEC_MCOMMA_DETECT                      ("TRUE"),  //changed
            .DEC_PCOMMA_DETECT                      ("TRUE"),  //changed
            .DEC_VALID_COMMA_ONLY                   ("FALSE"),
            //.MCOMMA_10B_VALUE                       (10'b0110000011),
            .MCOMMA_10B_VALUE                       (10'b1010000011),
            .MCOMMA_DETECT                          ("TRUE"),
            .PCOMMA_10B_VALUE                       (10'b0101111100),
            .PCOMMA_DETECT                          ("TRUE"),
            .RX_DECODE_SEQ_MATCH                    ("TRUE"),
            .RX_SLIDE_AUTO_WAIT                     (5),
            //.RX_SLIDE_MODE                          ("OFF"),
            .RX_SLIDE_MODE                          ("PCS"),
            .SHOW_REALIGN_COMMA                     ("FALSE"),

           //---------------RX Loss-of-sync State Machine----------------
            .RX_LOS_INVALID_INCR                    (8),
            .RX_LOS_THRESHOLD                       (128),
            .RX_LOSS_OF_SYNC_FSM                    ("FALSE"),

           //-----------------------RX Gearbox---------------------------
            .RXGEARBOX_USE                          ("FALSE"),

           //-----------RX Elastic Buffer and Phase alignment------------
            .RX_BUFFER_USE                          ("TRUE"),
            .RX_EN_IDLE_RESET_BUF                   ("TRUE"),
            .RX_EN_MODE_RESET_BUF                   ("TRUE"),
            .RX_EN_RATE_RESET_BUF                   ("TRUE"),
            .RX_EN_REALIGN_RESET_BUF                ("FALSE"),
            .RX_EN_REALIGN_RESET_BUF2               ("FALSE"),
            .RX_FIFO_ADDR_MODE                      ("FULL"),
            .RX_IDLE_HI_CNT                         (4'b1000),
            .RX_IDLE_LO_CNT                         (4'b0000),
            .RX_XCLK_SEL                            ("RXREC"),
            .RX_DLYALIGN_CTRINC                     (4'b1110),
            .RX_DLYALIGN_EDGESET                    (5'b00010),
            .RX_DLYALIGN_LPFINC                     (4'b1110),
            .RX_DLYALIGN_MONSEL                     (3'b000),
            .RX_DLYALIGN_OVRDSETTING                (8'b10000000),

           //----------------------Clock Correction----------------------
            .CLK_COR_ADJ_LEN                        (4),
            .CLK_COR_DET_LEN                        (4),
            .CLK_COR_INSERT_IDLE_FLAG               ("FALSE"),
            .CLK_COR_KEEP_IDLE                      ("FALSE"),
            //.CLK_COR_MAX_LAT                        (20),
            .CLK_COR_MAX_LAT                        (18),
            //.CLK_COR_MIN_LAT                        (14),
            .CLK_COR_MIN_LAT                        (16),
            .CLK_COR_PRECEDENCE                     ("TRUE"),
            .CLK_COR_REPEAT_WAIT                    (0),
            .CLK_COR_SEQ_1_1                        (10'b0110111100),
            .CLK_COR_SEQ_1_2                        (10'b0001001010),
            .CLK_COR_SEQ_1_3                        (10'b0001001010),
            .CLK_COR_SEQ_1_4                        (10'b0001111011),
            .CLK_COR_SEQ_1_ENABLE                   (4'b1111),
            .CLK_COR_SEQ_2_1                        (10'b0100000000),
            .CLK_COR_SEQ_2_2                        (10'b0100000000),
            .CLK_COR_SEQ_2_3                        (10'b0100000000),
            .CLK_COR_SEQ_2_4                        (10'b0100000000),
            //.CLK_COR_SEQ_2_ENABLE                   (4'b1111),
            .CLK_COR_SEQ_2_ENABLE                   (4'b0000),
            .CLK_COR_SEQ_2_USE                      ("FALSE"),
            .CLK_CORRECT_USE                        ("TRUE"),

           //----------------------Channel Bonding----------------------
            .CHAN_BOND_1_MAX_SKEW                   (1),
            .CHAN_BOND_2_MAX_SKEW                   (1),
            .CHAN_BOND_KEEP_ALIGN                   ("FALSE"),
            .CHAN_BOND_SEQ_1_1                      (10'b0000000000),
            .CHAN_BOND_SEQ_1_2                      (10'b0000000000),
            .CHAN_BOND_SEQ_1_3                      (10'b0000000000),
            .CHAN_BOND_SEQ_1_4                      (10'b0000000000),
            .CHAN_BOND_SEQ_1_ENABLE                 (4'b1111),
            .CHAN_BOND_SEQ_2_1                      (10'b0000000000),
            .CHAN_BOND_SEQ_2_2                      (10'b0000000000),
            .CHAN_BOND_SEQ_2_3                      (10'b0000000000),
            .CHAN_BOND_SEQ_2_4                      (10'b0000000000),
            .CHAN_BOND_SEQ_2_CFG                    (5'b00000),
            .CHAN_BOND_SEQ_2_ENABLE                 (4'b1111),
            .CHAN_BOND_SEQ_2_USE                    ("FALSE"),
            .CHAN_BOND_SEQ_LEN                      (1),
            .PCI_EXPRESS_MODE                       ("FALSE"),

           //-----------RX Attributes for PCI Express/SATA/SAS----------
            .SAS_MAX_COMSAS                         (52),
            .SAS_MIN_COMSAS                         (40),
            .SATA_BURST_VAL                         (3'b100),
            .SATA_IDLE_VAL                          (3'b100),
            .SATA_MAX_BURST                         (7),
            .SATA_MAX_INIT                          (22),
            .SATA_MAX_WAKE                          (7),
            .SATA_MIN_BURST                         (4),
            .SATA_MIN_INIT                          (12),
            .SATA_MIN_WAKE                          (4),
            .TRANS_TIME_FROM_P2                     (12'h03c),
            .TRANS_TIME_NON_P2                      (8'h19),
            .TRANS_TIME_RATE                        (8'hff),
            .TRANS_TIME_TO_P2                       (10'h064)

            
        ) 
        gtxe1_i 
        (
        
        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK                       (LOOPBACK_IN),
        .RXPOWERDOWN                    (2'b00),
        .TXPOWERDOWN                    (2'b00),
        //------------ Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
        .RXDATAVALID                    (),
        .RXGEARBOXSLIP                  (tied_to_ground_i),
        .RXHEADER                       (),
        .RXHEADERVALID                  (),
        .RXSTARTOFSEQ                   (),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXCHARISCOMMA                  (),
        .RXCHARISK                      (RXCHARISK_OUT),
        .RXDEC8B10BUSE                  (tied_to_vcc_i),
        .RXDISPERR                      (RXDISPERR_OUT),
        .RXNOTINTABLE                   (RXNOTINTABLE_OUT),
        .RXRUNDISP                      (),
        .USRCODEERR                     (tied_to_ground_i),
        //----------------- Receive Ports - Channel Bonding Ports ------------------
        .RXCHANBONDSEQ                  (),
        .RXCHBONDI                      (tied_to_ground_vec_i[3:0]),
        .RXCHBONDLEVEL                  (tied_to_ground_vec_i[2:0]),
        .RXCHBONDMASTER                 (tied_to_ground_i),
        .RXCHBONDO                      (),
        .RXCHBONDSLAVE                  (tied_to_ground_i),
        .RXENCHANSYNC                   (tied_to_ground_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT                    (RXCLKCORCNT_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED                (RXBYTEISALIGNED_OUT),
        .RXBYTEREALIGN                  (RXBYTEREALIGN_OUT),
        .RXCOMMADET                     (),
        .RXCOMMADETUSE                  (tied_to_vcc_i),
        .RXENMCOMMAALIGN                (RXENMCOMMAALIGN_IN),
        .RXENPCOMMAALIGN                (RXENPCOMMAALIGN_IN),
        .RXSLIDE                        (tied_to_ground_i),
        //--------------------- Receive Ports - PRBS Detection ---------------------
        .PRBSCNTRESET                   (tied_to_ground_i),
        .RXENPRBSTST                    (tied_to_ground_vec_i[2:0]),
        .RXPRBSERR                      (),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA                         (rxdata_i),
        .RXRECCLK                       (RXRECCLK_OUT),
        .RXRECCLKPCS                    (),
        .RXRESET                        (RXRESET_IN),
        .RXUSRCLK                       (RXUSRCLK_IN),
        .RXUSRCLK2                      (RXUSRCLK2_IN),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .DFECLKDLYADJ                   (tied_to_ground_vec_i[5:0]),
        .DFECLKDLYADJMON                (),
        .DFEDLYOVRD                     (tied_to_vcc_i),
        .DFEEYEDACMON                   (),
        .DFESENSCAL                     (),
        .DFETAP1                        (tied_to_ground_vec_i[4:0]),
        .DFETAP1MONITOR                 (),
        .DFETAP2                        (tied_to_ground_vec_i[4:0]),
        .DFETAP2MONITOR                 (),
        .DFETAP3                        (tied_to_ground_vec_i[3:0]),
        .DFETAP3MONITOR                 (),
        .DFETAP4                        (tied_to_ground_vec_i[3:0]),
        .DFETAP4MONITOR                 (),
        .DFETAPOVRD                     (tied_to_vcc_i),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GATERXELECIDLE                 (tied_to_ground_i),
        .IGNORESIGDET                   (tied_to_ground_i),
        .RXCDRRESET                     (RXBUFRESET_IN),
        .RXELECIDLE                     (RXELECIDLE_OUT),
        .RXEQMIX                        ({tied_to_ground_vec_i[6:0],RXEQMIX_IN}),
        .RXN                            (RXN_IN),
        .RXP                            (RXP_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET                     (RXBUFRESET_IN),
        .RXBUFSTATUS                    (),
        .RXCHANISALIGNED                (),
        .RXCHANREALIGN                  (),
        .RXDLYALIGNDISABLE              (tied_to_ground_i),
        .RXDLYALIGNMONENB               (tied_to_ground_i),
        .RXDLYALIGNMONITOR              (),
        .RXDLYALIGNOVERRIDE             (tied_to_vcc_i),
        .RXDLYALIGNRESET                (tied_to_ground_i),
        .RXDLYALIGNSWPPRECURB           (tied_to_vcc_i),
        .RXDLYALIGNUPDSW                (tied_to_ground_i),
        .RXENPMAPHASEALIGN              (tied_to_ground_i),
        .RXPMASETPHASE                  (tied_to_ground_i),
        .RXSTATUS                       (RXSTATUS_OUT),
        //------------- Receive Ports - RX Loss-of-sync State Machine --------------
        .RXLOSSOFSYNC                   (),
        //-------------------- Receive Ports - RX Oversampling ---------------------
        .RXENSAMPLEALIGN                (tied_to_ground_i),
        .RXOVERSAMPLEERR                (),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GREFCLKRX                      (tied_to_ground_i),
        .GTXRXRESET                     (GTXRXRESET_IN),
        .MGTREFCLKRX                    (MGTREFCLKRX_IN),
        .NORTHREFCLKRX                  (tied_to_ground_vec_i[1:0]),
        .PERFCLKRX                      (tied_to_ground_i),
        .PLLRXRESET                     (PLLRXRESET_IN),
        .RXPLLLKDET                     (RXPLLLKDET_OUT),
        .RXPLLLKDETEN                   (tied_to_vcc_i),
        .RXPLLPOWERDOWN                 (tied_to_ground_i),
        .RXPLLREFSELDY                  (tied_to_ground_vec_i[2:0]),
        .RXRATE                         (tied_to_ground_vec_i[1:0]),
        .RXRATEDONE                     (),
        .RXRESETDONE                    (RXRESETDONE_OUT),
        .SOUTHREFCLKRX                  (tied_to_ground_vec_i[1:0]),
        //------------ Receive Ports - RX Pipe Control for PCI Express -------------
        .PHYSTATUS                      (),
        .RXVALID                        (),
        //--------------- Receive Ports - RX Polarity Control Ports ----------------
        .RXPOLARITY                     (tied_to_ground_i),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .COMINITDET                     (COMINITDET_OUT),
        .COMSASDET                      (),
        .COMWAKEDET                     (COMWAKEDET_OUT),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        .DADDR                          (DADDR),
        .DCLK                           (DCLK),
        .DEN                            (DEN),
        .DI                             (DI),
        .DRDY                           (DRDY),
        .DRPDO                          (DO),
        .DWE                            (DWE),
        //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
        .TXGEARBOXREADY                 (),
        .TXHEADER                       (tied_to_ground_vec_i[2:0]),
        .TXSEQUENCE                     (tied_to_ground_vec_i[6:0]),
        .TXSTARTSEQ                     (tied_to_ground_i),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXBYPASS8B10B                  (tied_to_ground_vec_i[3:0]),
        .TXCHARDISPMODE                 (tied_to_ground_vec_i[3:0]),
        .TXCHARDISPVAL                  (tied_to_ground_vec_i[3:0]),
        .TXCHARISK                      (TXCHARISK_IN),
        .TXENC8B10BUSE                  (tied_to_vcc_i),
        .TXKERR                         (),
        .TXRUNDISP                      (),
        //----------------------- Transmit Ports - GTX Ports -----------------------
        .GTXTEST                        (13'b1000000000000),
        .MGTREFCLKFAB                   (),
        .TSTCLK0                        (tied_to_ground_i),
        .TSTCLK1                        (tied_to_ground_i),
        .TSTIN                          (20'b11111111111111111111),
        .TSTOUT                         (),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA                         (txdata_i),
        .TXOUTCLK                       (TXOUTCLK_OUT),
        .TXOUTCLKPCS                    (),
        .TXRESET                        (TXRESET_IN),
        .TXUSRCLK                       (TXUSRCLK_IN),
        .TXUSRCLK2                      (TXUSRCLK2_IN),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .TXBUFDIFFCTRL                  (3'b100),
        .TXDIFFCTRL                     (TXDIFFCTRL_IN),
        .TXINHIBIT                      (tied_to_ground_i),
        .TXN                            (TXN_OUT),
        .TXP                            (TXP_OUT),
        .TXPOSTEMPHASIS                 (TXPOSTEMPHASIS_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXPREEMPHASIS                  (TXPREEMPHASIS_IN),
        //--------- Transmit Ports - TX Elastic Buffer and Phase Alignment ---------
        .TXBUFSTATUS                    (),
        //------ Transmit Ports - TX Elastic Buffer and Phase Alignment Ports ------
        .TXDLYALIGNDISABLE              (tied_to_vcc_i),
        .TXDLYALIGNMONENB               (tied_to_ground_i),
        .TXDLYALIGNMONITOR              (),
        .TXDLYALIGNOVERRIDE             (tied_to_ground_i),
        .TXDLYALIGNRESET                (tied_to_ground_i),
        .TXDLYALIGNUPDSW                (tied_to_vcc_i),
        .TXENPMAPHASEALIGN              (tied_to_ground_i),
        .TXPMASETPHASE                  (tied_to_ground_i),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GREFCLKTX                      (tied_to_ground_i),
        .GTXTXRESET                     (GTXTXRESET_IN),
        .MGTREFCLKTX                    (MGTREFCLKTX_IN),
        .NORTHREFCLKTX                  (tied_to_ground_vec_i[1:0]),
        .PERFCLKTX                      (tied_to_ground_i),
        .PLLTXRESET                     (PLLTXRESET_IN),
        .SOUTHREFCLKTX                  (tied_to_ground_vec_i[1:0]),
        .TXPLLLKDET                     (TXPLLLKDET_OUT),
        .TXPLLLKDETEN                   (tied_to_vcc_i),
        .TXPLLPOWERDOWN                 (tied_to_ground_i),
        .TXPLLREFSELDY                  (tied_to_ground_vec_i[2:0]),
        .TXRATE                         (tied_to_ground_vec_i[1:0]),
        .TXRATEDONE                     (),
        .TXRESETDONE                    (TXRESETDONE_OUT),
        //------------------- Transmit Ports - TX PRBS Generator -------------------
        .TXENPRBSTST                    (tied_to_ground_vec_i[2:0]),
        .TXPRBSFORCEERR                 (tied_to_ground_i),
        //------------------ Transmit Ports - TX Polarity Control ------------------
        .TXPOLARITY                     (tied_to_ground_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXDEEMPH                       (tied_to_ground_i),
        .TXDETECTRX                     (tied_to_ground_i),
        .TXELECIDLE                     (TXELECIDLE_IN),
        .TXMARGIN                       (tied_to_ground_vec_i[2:0]),
        .TXPDOWNASYNCH                  (tied_to_ground_i),
        .TXSWING                        (tied_to_ground_i),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .COMFINISH                      (COMFINISH_OUT),
        .TXCOMINIT                      (TXCOMINIT_IN),
        .TXCOMSAS                       (tied_to_ground_i),
        .TXCOMWAKE                      (TXCOMWAKE_IN)

     );
     
endmodule     

 

// -----------------------------------------------------------------------------
// Source file: sata2_fifo_v1_00_a/hdl/verilog/sata_gtx_dual.v
// -----------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version : 1.8
//  \   \         Application : Virtex-6 FPGA GTX Transceiver Wizard
//  /   /         Filename : sata_gtx_dual.v
// /___/   /\     
// \   \  /  \ 
//  \___\/\___\
//
//
// Module SATA_GTX_DUAL (a GTX Wrapper)
// Generated by Xilinx Virtex-6 FPGA GTX Transceiver Wizard
// 
// 
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`timescale 1ns / 1ps


//***************************** Entity Declaration ****************************

(* CORE_GENERATION_INFO = "SATA_PHY,v6_gtxwizard_v1_8,{protocol_file=sata2}" *) 
module SATA_GTX_DUAL #
(
    // Simulation attributes
    parameter   WRAPPER_SIM_GTXRESET_SPEEDUP    = 0    // Set to 1 to speed up sim reset
)
(
    
    //_________________________________________________________________________
    //_________________________________________________________________________
    //GTX0  (X0Y4)

    //---------------------- Loopback and Powerdown Ports ----------------------
    input   [2:0]   GTX0_LOOPBACK_IN,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output  [3:0]   GTX0_RXCHARISK_OUT,
    output  [3:0]   GTX0_RXDISPERR_OUT,
    output  [3:0]   GTX0_RXNOTINTABLE_OUT,
    //----------------- Receive Ports - Clock Correction Ports -----------------
    output  [2:0]   GTX0_RXCLKCORCNT_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    output          GTX0_RXBYTEISALIGNED_OUT,
    output          GTX0_RXBYTEREALIGN_OUT,
    input           GTX0_RXENMCOMMAALIGN_IN,
    input           GTX0_RXENPCOMMAALIGN_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [31:0]  GTX0_RXDATA_OUT,
    output          GTX0_RXRECCLK_OUT,
    input           GTX0_RXRESET_IN,
    input           GTX0_RXUSRCLK_IN,
    input           GTX0_RXUSRCLK2_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    output          GTX0_RXELECIDLE_OUT,
    input   [2:0]   GTX0_RXEQMIX_IN,
    input           GTX0_RXN_IN,
    input           GTX0_RXP_IN,
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    input           GTX0_RXBUFRESET_IN,
    output  [2:0]   GTX0_RXSTATUS_OUT,
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    input           GTX0_GTXRXRESET_IN,
    input           GTX0_MGTREFCLKRX_IN,
    input           GTX0_PLLRXRESET_IN,
    output          GTX0_RXPLLLKDET_OUT,
    output          GTX0_RXRESETDONE_OUT,
    //------------------- Receive Ports - RX Ports for SATA --------------------
    output          GTX0_COMINITDET_OUT,
    output          GTX0_COMWAKEDET_OUT,
    // -------------- Speed Neg Module ports ------------------------
    input [6:0]    DADDR,       //DRP address                     
    input          DEN,		//DRP enable
    input [15:0]   DI,		//DRP data in
    output[15:0]   DO,		//DRP data out
    output         DRDY,	//DRP ready
    input          DWE,		//DRP write enable
    input          DCLK,                           

    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    input   [3:0]   GTX0_TXCHARISK_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [31:0]  GTX0_TXDATA_IN,
    output          GTX0_TXOUTCLK_OUT,
    input           GTX0_TXRESET_IN,
    input           GTX0_TXUSRCLK_IN,
    input           GTX0_TXUSRCLK2_IN,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    input   [3:0]   GTX0_TXDIFFCTRL_IN,
    output          GTX0_TXN_OUT,
    output          GTX0_TXP_OUT,
    input   [4:0]   GTX0_TXPOSTEMPHASIS_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    input   [3:0]   GTX0_TXPREEMPHASIS_IN,
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    input           GTX0_GTXTXRESET_IN,
    output          GTX0_TXRESETDONE_OUT,
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    input           GTX0_TXELECIDLE_IN,
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    output          GTX0_COMFINISH_OUT,
    input           GTX0_TXCOMINIT_IN,
    input           GTX0_TXCOMWAKE_IN,


    
    //_________________________________________________________________________
    //_________________________________________________________________________
    //GTX1  (X0Y5)

    //---------------------- Loopback and Powerdown Ports ----------------------
    input   [2:0]   GTX1_LOOPBACK_IN,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output  [3:0]   GTX1_RXDISPERR_OUT,
    output  [3:0]   GTX1_RXNOTINTABLE_OUT,
    //----------------- Receive Ports - Clock Correction Ports -----------------
    output  [2:0]   GTX1_RXCLKCORCNT_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    output          GTX1_RXBYTEISALIGNED_OUT,
    output          GTX1_RXBYTEREALIGN_OUT,
    input           GTX1_RXENMCOMMAALIGN_IN,
    input           GTX1_RXENPCOMMAALIGN_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [31:0]  GTX1_RXDATA_OUT,
    output          GTX1_RXRECCLK_OUT,
    input           GTX1_RXRESET_IN,
    input           GTX1_RXUSRCLK_IN,
    input           GTX1_RXUSRCLK2_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    output          GTX1_RXELECIDLE_OUT,
    input   [2:0]   GTX1_RXEQMIX_IN,
    input           GTX1_RXN_IN,
    input           GTX1_RXP_IN,
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    input           GTX1_RXBUFRESET_IN,
    output  [2:0]   GTX1_RXSTATUS_OUT,
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    input           GTX1_GTXRXRESET_IN,
    input           GTX1_MGTREFCLKRX_IN,
    input           GTX1_PLLRXRESET_IN,
    output          GTX1_RXPLLLKDET_OUT,
    output          GTX1_RXRESETDONE_OUT,
    //------------------- Receive Ports - RX Ports for SATA --------------------
    output          GTX1_COMINITDET_OUT,
    output          GTX1_COMWAKEDET_OUT,
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    input   [3:0]   GTX1_TXCHARISK_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [31:0]  GTX1_TXDATA_IN,
    output          GTX1_TXOUTCLK_OUT,
    input           GTX1_TXRESET_IN,
    input           GTX1_TXUSRCLK_IN,
    input           GTX1_TXUSRCLK2_IN,
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    input   [3:0]   GTX1_TXDIFFCTRL_IN,
    output          GTX1_TXN_OUT,
    output          GTX1_TXP_OUT,
    input   [4:0]   GTX1_TXPOSTEMPHASIS_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    input   [3:0]   GTX1_TXPREEMPHASIS_IN,
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    input           GTX1_GTXTXRESET_IN,
    output          GTX1_TXRESETDONE_OUT,
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    input           GTX1_TXELECIDLE_IN,
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    output          GTX1_COMFINISH_OUT,
    input           GTX1_TXCOMINIT_IN,
    input           GTX1_TXCOMWAKE_IN


);

//***************************** Wire Declarations *****************************

    // ground and vcc signals
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;
 
//********************************* Main Body of Code**************************

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;


//------------------------- GTX Instances  -------------------------------



    //_________________________________________________________________________
    //_________________________________________________________________________
    //GTX0  (X0Y4)

    SATA_GTX #
    (
        // Simulation attributes
        .GTX_SIM_GTXRESET_SPEEDUP   (WRAPPER_SIM_GTXRESET_SPEEDUP),
        
        // Share RX PLL parameter
        .GTX_TX_CLK_SOURCE           ("RXPLL"),
        // Save power parameter
        .GTX_POWER_SAVE              (10'b0000110100)
    )
    gtx0_sata_i
    (
        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK_IN                    (GTX0_LOOPBACK_IN),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXCHARISK_OUT                  (GTX0_RXCHARISK_OUT),
        .RXDISPERR_OUT                  (GTX0_RXDISPERR_OUT),
        .RXNOTINTABLE_OUT               (GTX0_RXNOTINTABLE_OUT),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT_OUT                (GTX0_RXCLKCORCNT_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED_OUT            (GTX0_RXBYTEISALIGNED_OUT),
        .RXBYTEREALIGN_OUT              (GTX0_RXBYTEREALIGN_OUT),
        .RXENMCOMMAALIGN_IN             (GTX0_RXENMCOMMAALIGN_IN),
        .RXENPCOMMAALIGN_IN             (GTX0_RXENPCOMMAALIGN_IN),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA_OUT                     (GTX0_RXDATA_OUT),
        .RXRECCLK_OUT                   (GTX0_RXRECCLK_OUT),
        .RXRESET_IN                     (GTX0_RXRESET_IN),
        .RXUSRCLK_IN                    (GTX0_RXUSRCLK_IN),
        .RXUSRCLK2_IN                   (GTX0_RXUSRCLK2_IN),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .RXELECIDLE_OUT                 (GTX0_RXELECIDLE_OUT),
        .RXEQMIX_IN                     (GTX0_RXEQMIX_IN),
        .RXN_IN                         (GTX0_RXN_IN),
        .RXP_IN                         (GTX0_RXP_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET_IN                  (GTX0_RXBUFRESET_IN),
        .RXSTATUS_OUT                   (GTX0_RXSTATUS_OUT),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTXRXRESET_IN                  (GTX0_GTXRXRESET_IN),
        .MGTREFCLKRX_IN                 ({tied_to_ground_i , GTX0_MGTREFCLKRX_IN}),
        .PLLRXRESET_IN                  (GTX0_PLLRXRESET_IN),
        .RXPLLLKDET_OUT                 (GTX0_RXPLLLKDET_OUT),
        .RXRESETDONE_OUT                (GTX0_RXRESETDONE_OUT),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .COMINITDET_OUT                 (GTX0_COMINITDET_OUT),
        .COMWAKEDET_OUT                 (GTX0_COMWAKEDET_OUT),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        .DADDR                          (DADDR),
        .DCLK                           (DCLK),
        .DEN                            (DEN),
        .DI                             (DI),
        .DRDY                           (DRDY),
        .DO                             (DO),
        .DWE                            (DWE),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXCHARISK_IN                   (GTX0_TXCHARISK_IN),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA_IN                      (GTX0_TXDATA_IN),
        .TXOUTCLK_OUT                   (GTX0_TXOUTCLK_OUT),
        .TXRESET_IN                     (GTX0_TXRESET_IN),
        .TXUSRCLK_IN                    (GTX0_TXUSRCLK_IN),
        .TXUSRCLK2_IN                   (GTX0_TXUSRCLK2_IN),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .TXDIFFCTRL_IN                  (GTX0_TXDIFFCTRL_IN),
        .TXN_OUT                        (GTX0_TXN_OUT),
        .TXP_OUT                        (GTX0_TXP_OUT),
        .TXPOSTEMPHASIS_IN              (GTX0_TXPOSTEMPHASIS_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXPREEMPHASIS_IN               (GTX0_TXPREEMPHASIS_IN),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTXTXRESET_IN                  (GTX0_GTXTXRESET_IN),
        .MGTREFCLKTX_IN                 ({tied_to_ground_i , GTX0_MGTREFCLKRX_IN}),
        .PLLTXRESET_IN                  (tied_to_ground_i),
        .TXPLLLKDET_OUT                 (),
        .TXRESETDONE_OUT                (GTX0_TXRESETDONE_OUT),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXELECIDLE_IN                  (GTX0_TXELECIDLE_IN),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .COMFINISH_OUT                  (GTX0_COMFINISH_OUT),
        .TXCOMINIT_IN                   (GTX0_TXCOMINIT_IN),
        .TXCOMWAKE_IN                   (GTX0_TXCOMWAKE_IN)

    );



    //_________________________________________________________________________
    //_________________________________________________________________________
    //GTX1  (X0Y5)

    SATA_GTX #
    (
        // Simulation attributes
        .GTX_SIM_GTXRESET_SPEEDUP   (WRAPPER_SIM_GTXRESET_SPEEDUP),
        
        // Share RX PLL parameter
        .GTX_TX_CLK_SOURCE           ("RXPLL"),
        // Save power parameter
        .GTX_POWER_SAVE              (10'b0000110100)
    )
    gtx1_sata_i
    (
        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK_IN                    (GTX1_LOOPBACK_IN),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXDISPERR_OUT                  (GTX1_RXDISPERR_OUT),
        .RXNOTINTABLE_OUT               (GTX1_RXNOTINTABLE_OUT),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT_OUT                (GTX1_RXCLKCORCNT_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED_OUT            (GTX1_RXBYTEISALIGNED_OUT),
        .RXBYTEREALIGN_OUT              (GTX1_RXBYTEREALIGN_OUT),
        .RXENMCOMMAALIGN_IN             (GTX1_RXENMCOMMAALIGN_IN),
        .RXENPCOMMAALIGN_IN             (GTX1_RXENPCOMMAALIGN_IN),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA_OUT                     (GTX1_RXDATA_OUT),
        .RXRECCLK_OUT                   (GTX1_RXRECCLK_OUT),
        .RXRESET_IN                     (GTX1_RXRESET_IN),
        .RXUSRCLK_IN                    (GTX1_RXUSRCLK_IN),
        .RXUSRCLK2_IN                   (GTX1_RXUSRCLK2_IN),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .RXELECIDLE_OUT                 (GTX1_RXELECIDLE_OUT),
        .RXEQMIX_IN                     (GTX1_RXEQMIX_IN),
        .RXN_IN                         (GTX1_RXN_IN),
        .RXP_IN                         (GTX1_RXP_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET_IN                  (GTX1_RXBUFRESET_IN),
        .RXSTATUS_OUT                   (GTX1_RXSTATUS_OUT),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTXRXRESET_IN                  (GTX1_GTXRXRESET_IN),
        .MGTREFCLKRX_IN                 ({tied_to_ground_i , GTX1_MGTREFCLKRX_IN}),
        .PLLRXRESET_IN                  (GTX1_PLLRXRESET_IN),
        .RXPLLLKDET_OUT                 (GTX1_RXPLLLKDET_OUT),
        .RXRESETDONE_OUT                (GTX1_RXRESETDONE_OUT),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .COMINITDET_OUT                 (GTX1_COMINITDET_OUT),
        .COMWAKEDET_OUT                 (GTX1_COMWAKEDET_OUT),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXCHARISK_IN                   (GTX1_TXCHARISK_IN),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA_IN                      (GTX1_TXDATA_IN),
        .TXOUTCLK_OUT                   (GTX1_TXOUTCLK_OUT),
        .TXRESET_IN                     (GTX1_TXRESET_IN),
        .TXUSRCLK_IN                    (GTX1_TXUSRCLK_IN),
        .TXUSRCLK2_IN                   (GTX1_TXUSRCLK2_IN),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .TXDIFFCTRL_IN                  (GTX1_TXDIFFCTRL_IN),
        .TXN_OUT                        (GTX1_TXN_OUT),
        .TXP_OUT                        (GTX1_TXP_OUT),
        .TXPOSTEMPHASIS_IN              (GTX1_TXPOSTEMPHASIS_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXPREEMPHASIS_IN               (GTX1_TXPREEMPHASIS_IN),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTXTXRESET_IN                  (GTX1_GTXTXRESET_IN),
        .MGTREFCLKTX_IN                 ({tied_to_ground_i , GTX1_MGTREFCLKRX_IN}),
        .PLLTXRESET_IN                  (tied_to_ground_i),
        .TXPLLLKDET_OUT                 (),
        .TXRESETDONE_OUT                (GTX1_TXRESETDONE_OUT),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXELECIDLE_IN                  (GTX1_TXELECIDLE_IN),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .COMFINISH_OUT                  (GTX1_COMFINISH_OUT),
        .TXCOMINIT_IN                   (GTX1_TXCOMINIT_IN),
        .TXCOMWAKE_IN                   (GTX1_TXCOMWAKE_IN)

    );



endmodule

    

// -----------------------------------------------------------------------------
// Source file: sata2_fifo_v1_00_a/hdl/verilog/sata_phy.v
// -----------------------------------------------------------------------------
//*****************************************************************************/
// Module :     sata_phy
// Version:     1.0
// Author:      Ashwin Mendon 
// Description: This module provides a wrapper for the SATA GTX wrapper modules
//              the Out of Band Signaling controller module and the clock generating
//              modules
//              It has been modified from Xilinx XAPP870 to support Virtex 6 GTX
//              transceivers 
//*****************************************************************************/

module sata_phy 
(
	sata_phy_ila_control,
	oob_control_ila_control,
        REFCLK_PAD_P_IN,	       
	REFCLK_PAD_N_IN,	       
	TXP0_OUT,
	TXN0_OUT,
	RXP0_IN,
	RXN0_IN,		
	PLLLKDET_OUT_N,			
	DCMLOCKED_OUT,
	LINKUP_led,
 	GEN2_led,
	sata_user_clk,
	LINKUP,
	align_en_out,
        tx_datain,
        tx_charisk_in,
	rx_dataout,
	rx_charisk_out,
        CurrentState_out,
        rxelecidle_out,
	GTXRESET_IN,			
        CLKIN_150
 );
    
        parameter  CHIPSCOPE            = "FALSE";
        input  [35:0]   sata_phy_ila_control;
        input  [35:0]   oob_control_ila_control;
	input		REFCLK_PAD_P_IN;	// GTX reference clock input
	input		REFCLK_PAD_N_IN;	// GTX reference clock input
	input           RXP0_IN;		// Receiver input
	input           RXN0_IN;		// Receiver input
	input		GTXRESET_IN;		// Main GTX reset
        input           CLKIN_150;              // GTX reference clock input
        // Input from Link Layer
        input  [31:0]   tx_datain;              
        input           tx_charisk_in;          
       	
	output		DCMLOCKED_OUT;		// DCM locked 
	output 		PLLLKDET_OUT_N;	        // PLL Lock Detect
	output		TXP0_OUT;
	output		TXN0_OUT;
	output		LINKUP;
	output		LINKUP_led;
	output		GEN2_led;
	output		align_en_out;
	output		sata_user_clk;
        // Outputs to Link Layer
        output  [31:0]  rx_dataout;       
	output  [3:0]   rx_charisk_out;
	output	[7:0]	CurrentState_out;
        output          rxelecidle_out;
        

	wire	[3:0]	rxcharisk;
        // OOB generate and detect
	wire		txcominit, txcomwake;
	wire		cominitdet, comwakedet;
        // OOB generate and detect
	wire		sync_det_out, align_det_out;
	wire		tx_charisk_out;
	wire		txelecidle,   rxelecidle0, rxelecidle1, rxenelecidleresetb; 
	wire		resetdone0, resetdone1;
	wire	[31:0]	txdata, rxdata; // TX/RX data
	wire	[31:0]	rxdataout; // RX USER data
	wire	[4:0]	state_out;
	wire		PLLLKDET_OUT;
 	wire 		linkup, linkup_led_out;
 	wire 		align_en_out;
	wire		clk0, clk2x, dcm_clk0, dcm_clkdv, dcm_clk2x; // DCM output clocks
	wire		mmcm_locked;
	wire		GEN2; //this is the selection for GEN2 when set to 1
	wire		speed_neg_rst;
	wire		rxreset;	//GTX Rxreset
	wire 	        RXBYTEREALIGN0, RXBYTEISALIGNED0;
	wire 		RXRECCLK0;
	wire 		mmcm_reset;
	wire 		rst_debounce;
	wire 		mmcm_clk_in;   
	wire 		gtx_refclk;   
	wire 		gtx_refclk_bufg;   
	wire 		gtx_reset;   
   
	wire 		rst_0;
	reg  		rst_1;  
	reg  		rst_2;
	reg  		rst_3;

        // Clock counters to check clock toggle
        reg    [15:0]   gtx_refclk_count;
        reg    [15:0]   gtx_refclk_bufg_count;
        reg    [15:0]   gtx_txoutclk_count;
        reg    [15:0]   gtx_txusrclk_count;
        reg    [15:0]   gtx_txusrclk2_count;
        reg    [15:0]   CLKIN_150_count;

	
//------------------------ MGT Wrapper Wires ------------------------------
    //________________________________________________________________________
    //________________________________________________________________________
    //GTX0   (X0Y4)

    //---------------------- Loopback and Powerdown Ports ----------------------
    wire    [2:0]   gtx0_loopback_i;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    wire    [3:0]   gtx0_rxdisperr_i;
    wire    [3:0]   gtx0_rxnotintable_i;
    //----------------- Receive Ports - Clock Correction Ports -----------------
    wire    [2:0]   gtx0_rxclkcorcnt_i;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    wire            gtx0_rxbyteisaligned_i;
    wire            gtx0_rxbyterealign_i;
    wire            gtx0_rxenmcommaalign_i;
    wire            gtx0_rxenpcommaalign_i;
    //----------------- Receive Ports - RX Data Path interface -----------------
    wire    [31:0]  gtx0_rxdata_i;
    wire            gtx0_rxrecclk_i;
    wire            gtx0_rxreset_i;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    wire            gtx0_rxelecidle_i;
    wire    [2:0]   gtx0_rxeqmix_i;
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    wire            gtx0_rxbufreset_i;
    wire    [2:0]   gtx0_rxstatus_i;
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    wire            gtx0_gtxrxreset_i;
    wire            gtx0_pllrxreset_i;
    wire            gtx0_rxplllkdet_i;
    wire            gtx0_rxresetdone_i;
    //------------------- Receive Ports - RX Ports for SATA --------------------
    wire            gtx0_cominitdet_i;
    wire            gtx0_comwakedet_i;
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    wire    [3:0]   gtx0_txcharisk_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [31:0]  gtx0_txdata_i;
    wire            gtx0_txoutclk_i;
    wire            gtx0_txreset_i;
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    wire    [3:0]   gtx0_txdiffctrl_i;
    wire    [4:0]   gtx0_txpostemphasis_i;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    wire    [3:0]   gtx0_txpreemphasis_i;
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    wire            gtx0_gtxtxreset_i;
    wire            gtx0_txresetdone_i;
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    wire            gtx0_txelecidle_i;
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    wire            comfinish;
    wire            gtx0_txcominit_i;
    wire            gtx0_txcomwake_i;


    //________________________________________________________________________
    //________________________________________________________________________
    //GTX1   (X0Y5)

    //---------------------- Loopback and Powerdown Ports ----------------------
    wire    [2:0]   gtx1_loopback_i;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    wire    [3:0]   gtx1_rxdisperr_i;
    wire    [3:0]   gtx1_rxnotintable_i;
    //----------------- Receive Ports - Clock Correction Ports -----------------
    wire    [2:0]   gtx1_rxclkcorcnt_i;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    wire            gtx1_rxbyteisaligned_i;
    wire            gtx1_rxbyterealign_i;
    wire            gtx1_rxenmcommaalign_i;
    wire            gtx1_rxenpcommaalign_i;
    //----------------- Receive Ports - RX Data Path interface -----------------
    wire    [31:0]  gtx1_rxdata_i;
    wire            gtx1_rxrecclk_i;
    wire            gtx1_rxreset_i;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    wire            gtx1_rxelecidle_i;
    wire    [2:0]   gtx1_rxeqmix_i;
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    wire            gtx1_rxbufreset_i;
    wire    [2:0]   gtx1_rxstatus_i;
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    wire            gtx1_gtxrxreset_i;
    wire            gtx1_pllrxreset_i;
    wire            gtx1_rxplllkdet_i;
    wire            gtx1_rxresetdone_i;
    //------------------- Receive Ports - RX Ports for SATA --------------------
    wire            gtx1_cominitdet_i;
    wire            gtx1_comwakedet_i;
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    wire    [3:0]   gtx1_txcharisk_i;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [31:0]  gtx1_txdata_i;
    wire            gtx1_txoutclk_i;
    wire            gtx1_txreset_i;
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    wire    [3:0]   gtx1_txdiffctrl_i;
    wire    [4:0]   gtx1_txpostemphasis_i;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    wire    [3:0]   gtx1_txpreemphasis_i;
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    wire            gtx1_gtxtxreset_i;
    wire            gtx1_txresetdone_i;
    //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    wire            gtx1_txelecidle_i;
    //------------------- Transmit Ports - TX Ports for SATA -------------------
    wire            gtx1_comfinish_i;
    wire            gtx1_txcominit_i;
    wire            gtx1_txcomwake_i;



    //----------------------------- Global Signals -----------------------------
    wire            gtx0_tx_system_reset_c;
    wire            gtx0_rx_system_reset_c;
    wire            gtx1_tx_system_reset_c;
    wire            gtx1_rx_system_reset_c;
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [7:0]   tied_to_vcc_vec_i;
    wire            drp_clk_in_i;

    //--------------------------- User Clocks ---------------------------------
    wire            gtx0_txusrclk_i;
    wire            gtx0_txusrclk2_i;
    wire            txoutclk_mmcm0_locked_i;
    wire            txoutclk_mmcm0_reset_i;
    wire            gtx0_txoutclk_to_mmcm_i;


    //--------------------------- Reference Clocks ----------------------------
    
    wire            q1_clk1_refclk_i;
    wire            q1_clk1_refclk_i_bufg;
    //--------------------------- Reference Clocks ----------------------------


        // Static signal Assigments    
        assign tied_to_ground_i             = 1'b0;
        assign tied_to_ground_vec_i         = 64'h0000000000000000;
        assign tied_to_vcc_i                = 1'b1;
        assign tied_to_vcc_vec_i            = 8'hff;
 
        // GTX Reset
        assign rst_0 = GTXRESET_IN;  
         
        always @(posedge CLKIN_150)
        begin
            rst_1 <= rst_0;
            rst_2 <= rst_1;
            rst_3 <= rst_2;
        end

        assign rst_debounce = (rst_1 & rst_2 & rst_3);

	//assign gtx_reset = rst_debounce|| speed_neg_rst;	
	assign gtx_reset = rst_debounce;	
	//assign mmcm_reset = ~PLLLKDET_OUT || speed_neg_rst;
	assign mmcm_reset = ~PLLLKDET_OUT;
	
	assign	GEN2_led =  GEN2;
	assign LINKUP    = linkup;	
	assign LINKUP_led = linkup_led_out;	
	assign align_en_out = align_en_out;	
	assign	DCMLOCKED_OUT	=  mmcm_locked; // LED active high 

	assign PLLLKDET_OUT_N = PLLLKDET_OUT;         
	assign  rxelecidlereset0          =   (rxelecidle0 && resetdone0);
	assign  rxenelecidleresetb        =   !rxelecidlereset0; 

        assign rx_dataout = rxdataout;

        // SATA PHY output clock assignments
        assign sata_user_clk = gtx0_txusrclk2_i;


OOB_control OOB_control_i 
    (
 	.oob_control_ila_control        (oob_control_ila_control),
       //-------- GTX Ports --------/
     	.clk				(gtx0_txusrclk2_i),
 	.reset		      		(gtx_reset),
	.rxreset			(rxreset),
 	.rx_locked			(PLLLKDET_OUT),
         // OOB generation and detection signals from GTX
 	.txcominit			(txcominit),
 	.txcomwake			(txcomwake),
 	.cominitdet                     (cominitdet),
 	.comwakedet                     (comwakedet),

 	.rxelecidle			(rxelecidle0),
 	.txelecidle_out			(txelecidle),
 	.rxbyteisaligned		(RXBYTEISALIGNED0), 	
 	.tx_dataout			(txdata),		// outgoing GTX data
 	.tx_charisk_out			(tx_charisk_out),       // GTX charisk out    
 	.rx_datain			(rxdata),              	// incoming GTX data 
 	.rx_charisk_in			(rxcharisk),            // GTX charisk in 	
	.gen2             		(1'b1),                 // for SATA Generation 2
        
       //----- USER DATA PORTS---------//        
 	.tx_datain			(tx_datain),		// User datain port
        .tx_charisk_in                  (tx_charisk_in),        // User charisk in port 
 	.rx_dataout			(rxdataout),         	// User dataout port
 	.rx_charisk_out			(rx_charisk_out),       // User charisk out port 	
 	.linkup                 	(linkup),
 	.linkup_led_out                 (linkup_led_out),
 	.align_en_out                   (align_en_out),
	.CurrentState_out       	(CurrentState_out)
 );

    assign rxelecidle_out  = rxelecidle0;


    
//---------------------Dedicated GTX Reference Clock Inputs ---------------
    // The dedicated reference clock inputs you selected in the GUI are implemented using
    // IBUFDS_GTXE1 instances.
    //
    // In the UCF file for this example design, you will see that each of
    // these IBUFDS_GTXE1 instances has been LOCed to a particular set of pins. By LOCing to these
    // locations, we tell the tools to use the dedicated input buffers to the GTX reference
    // clock network, rather than general purpose IOs. To select other pins, consult the 
    // Implementation chapter of UG___, or rerun the wizard.
    //
    // This network is the highest performace (lowest jitter) option for providing clocks
    // to the GTX transceivers.
    
    IBUFDS_GTXE1 gtx_refclk_ibufds_i
    (
        .O                              (gtx_refclk),
        .ODIV2                          (),
        .CEB                            (tied_to_ground_i),
        .I                              (REFCLK_PAD_P_IN),
        .IB                             (REFCLK_PAD_N_IN)
    );

 
    BUFG gtx_refclk_bufg_i
    (
        .I                              (gtx_refclk),
        .O                              (gtx_refclk_bufg)
    );

   

    //--------------------------------- User Clocks ---------------------------
    
    // The clock resources in this section were added based on userclk source selections on
    // the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
    // * The userclk and userclk2 for each GTX datapath (TX and RX) must be phase aligned to 
    //   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
    // * To minimize clock resources, you can share clocks between GTXs. GTXs using the same frequency
    //   or multiples of the same frequency can be accomadated using MMCMs. Use caution when
    //   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
    //   the channels using the clock are receiving data from TX channels that share a reference clock 
    //   source with each other.

   // assign  txoutclk_mmcm0_reset_i               =  !gtx0_rxplllkdet_i;



    BUFG txoutclk_bufg_i
    (
        .I                              (gtx0_txoutclk_i),
        .O                              (mmcm_clk_in)
    );


    MGT_USRCLK_SOURCE_MMCM #
    (
        .MULT                           (8.0),
        .DIVIDE                         (2),
        .CLK_PERIOD                     (6.666),
        .OUT0_DIVIDE                    (4.0),
        .OUT1_DIVIDE                    (2.0),
        .OUT2_DIVIDE                    (1),
        .OUT3_DIVIDE                    (1)
    )
    txoutclk_mmcm0_i
    (
        .CLK0_OUT                       (gtx0_txusrclk2_i),
        .CLK1_OUT                       (gtx0_txusrclk_i),
        .CLK2_OUT                       (),
        .CLK3_OUT                       (),
        .CLK_IN                         (mmcm_clk_in),
        .MMCM_LOCKED_OUT                (mmcm_locked),
        .MMCM_RESET_IN                  (mmcm_reset)
    );


//instantiate GTX tile(two transceivers)

SATA_GTX_DUAL #
    (
        .WRAPPER_SIM_GTXRESET_SPEEDUP (0),
    )
    sata_gtx_dual_i
    (
 
 
        //_____________________________________________________________________
        //_____________________________________________________________________
        //GTX0  (X0Y4)
        //---------------------- Loopback and Powerdown Ports ----------------------
        .GTX0_LOOPBACK_IN               (gtx0_loopback_i),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .GTX0_RXCHARISK_OUT             (rxcharisk),
        .GTX0_RXDISPERR_OUT             (gtx0_rxdisperr_i),
        .GTX0_RXNOTINTABLE_OUT          (gtx0_rxnotintable_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .GTX0_RXCLKCORCNT_OUT           (gtx0_rxclkcorcnt_i),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .GTX0_RXBYTEISALIGNED_OUT       (RXBYTEISALIGNED0),
        .GTX0_RXBYTEREALIGN_OUT         (gtx0_rxbyterealign_i),
        .GTX0_RXENMCOMMAALIGN_IN        (gtx0_rxenmcommaalign_i),
        .GTX0_RXENPCOMMAALIGN_IN        (gtx0_rxenpcommaalign_i),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .GTX0_RXDATA_OUT                (rxdata),
        .GTX0_RXRECCLK_OUT              (gtx0_rxrecclk_i),
        .GTX0_RXRESET_IN                (rxreset),
        .GTX0_RXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX0_RXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GTX0_RXELECIDLE_OUT            (rxelecidle0),
        .GTX0_RXEQMIX_IN                (gtx0_rxeqmix_i),
        .GTX0_RXN_IN                    (RXN0_IN),
        .GTX0_RXP_IN                    (RXP0_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .GTX0_RXBUFRESET_IN             (gtx_reset),
        .GTX0_RXSTATUS_OUT              (gtx0_rxstatus_i),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTX0_GTXRXRESET_IN             (gtx_reset),
        .GTX0_MGTREFCLKRX_IN            (CLKIN_150),
        .GTX0_PLLRXRESET_IN             (),
        .GTX0_RXPLLLKDET_OUT            (PLLLKDET_OUT),
        .GTX0_RXRESETDONE_OUT           (gtx0_rxresetdone_i),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .GTX0_COMINITDET_OUT            (cominitdet),
        .GTX0_COMWAKEDET_OUT            (comwakedet),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        // Speed Negotiation Control module is disabled here and the design is fixed for 
        //  SATA GEN2 disks
        .DADDR                          (7'b0),
        .DCLK                           (mmcm_clk_in),
        .DEN                            (1'b0),
        .DI                             (16'b0),
        .DRDY                           (),
        .DO                             (),
        .DWE                            (1'b0),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .GTX0_TXCHARISK_IN              ({1'b0,1'b0,1'b0,tx_charisk_out}),
        //.GTX0_TXCHARISK_IN              ({1'b0,tx_charisk_out,1'b0,tx_charisk_out}),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .GTX0_TXDATA_IN                 (txdata),
        .GTX0_TXOUTCLK_OUT              (gtx0_txoutclk_i),
        .GTX0_TXRESET_IN                (),
        .GTX0_TXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX0_TXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .GTX0_TXDIFFCTRL_IN             (gtx0_txdiffctrl_i),
        .GTX0_TXN_OUT                   (TXN0_OUT),
        .GTX0_TXP_OUT                   (TXP0_OUT),
        .GTX0_TXPOSTEMPHASIS_IN         (gtx0_txpostemphasis_i),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .GTX0_TXPREEMPHASIS_IN          (gtx0_txpreemphasis_i),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTX0_GTXTXRESET_IN             (gtx_reset),
        .GTX0_TXRESETDONE_OUT           (gtx0_txresetdone_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .GTX0_TXELECIDLE_IN             (txelecidle),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .GTX0_COMFINISH_OUT             (comfinish),
        .GTX0_TXCOMINIT_IN              (txcominit),
        .GTX0_TXCOMWAKE_IN              (txcomwake),

 
        //_____________________________________________________________________
        //_____________________________________________________________________
        //GTX1  (X0Y5)
        //---------------------- Loopback and Powerdown Ports ----------------------
        .GTX1_LOOPBACK_IN               (gtx1_loopback_i),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .GTX1_RXDISPERR_OUT             (gtx1_rxdisperr_i),
        .GTX1_RXNOTINTABLE_OUT          (gtx1_rxnotintable_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .GTX1_RXCLKCORCNT_OUT           (gtx1_rxclkcorcnt_i),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .GTX1_RXBYTEISALIGNED_OUT       (),
        .GTX1_RXBYTEREALIGN_OUT         (gtx1_rxbyterealign_i),
        .GTX1_RXENMCOMMAALIGN_IN        (gtx1_rxenmcommaalign_i),
        .GTX1_RXENPCOMMAALIGN_IN        (gtx1_rxenpcommaalign_i),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .GTX1_RXDATA_OUT                (),
        .GTX1_RXRECCLK_OUT              (gtx1_rxrecclk_i),
        .GTX1_RXRESET_IN                (rxreset),
        .GTX1_RXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX1_RXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GTX1_RXELECIDLE_OUT            (rxelecidle1),
        .GTX1_RXEQMIX_IN                (gtx1_rxeqmix_i),
        .GTX1_RXN_IN                    (),
        .GTX1_RXP_IN                    (),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .GTX1_RXBUFRESET_IN             (gtx_reset),
        .GTX1_RXSTATUS_OUT              (),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .GTX1_GTXRXRESET_IN             (gtx_reset),
        .GTX1_MGTREFCLKRX_IN            (CLKIN_150),
        .GTX1_PLLRXRESET_IN             (),
        .GTX1_RXPLLLKDET_OUT            (gtx1_rxplllkdet_i),
        .GTX1_RXRESETDONE_OUT           (gtx1_rxresetdone_i),
        //------------------- Receive Ports - RX Ports for SATA --------------------
        .GTX1_COMINITDET_OUT            (gtx1_cominitdet_i),
        .GTX1_COMWAKEDET_OUT            (gtx1_comwakedet_i),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .GTX1_TXCHARISK_IN              ({1'b0,1'b0,1'b0,tx_charisk_out}),
        //.GTX1_TXCHARISK_IN              ({1'b0,tx_charisk_out,1'b0,tx_charisk_out}),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .GTX1_TXDATA_IN                 (txdata),
        .GTX1_TXOUTCLK_OUT              (gtx1_txoutclk_i),
        .GTX1_TXRESET_IN                (),
        .GTX1_TXUSRCLK_IN               (gtx0_txusrclk_i),
        .GTX1_TXUSRCLK2_IN              (gtx0_txusrclk2_i),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .GTX1_TXDIFFCTRL_IN             (gtx1_txdiffctrl_i),
        .GTX1_TXN_OUT                   (),
        .GTX1_TXP_OUT                   (),
        .GTX1_TXPOSTEMPHASIS_IN         (gtx1_txpostemphasis_i),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .GTX1_TXPREEMPHASIS_IN          (gtx1_txpreemphasis_i),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .GTX1_GTXTXRESET_IN             (gtx_reset),
        .GTX1_TXRESETDONE_OUT           (gtx1_txresetdone_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .GTX1_TXELECIDLE_IN             (txelecidle),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .GTX1_COMFINISH_OUT             (gtx1_comfinish_i),
        .GTX1_TXCOMINIT_IN              (gtx1_txcominit_i),
        .GTX1_TXCOMWAKE_IN              (gtx1_txcomwake_i)

    );
/* Note: The Transmitter Differential Voltage Swing is set by the TXDIFFCTRL parameter
         in the GTX transceivers. It defaults to 4'b0000 resulting in a voltage of 110 mV p-p. 
         Set it to 4'b1000 to raise the voltage to 810 mV p-p. (Refer Pg 174 of V6 GTX user guide). 
         This is necessary for the transmission of OOB signals during PHY Initialization. */ 
assign gtx0_txdiffctrl_i = 4'b1000; 
assign gtx1_txdiffctrl_i = 4'b1000; 



// Debugging
always @(posedge gtx_refclk_bufg)
begin : GTX_REF_CLK_CNT
      begin
            gtx_refclk_count <= gtx_refclk_count + 1;
      end 
end

always @(posedge mmcm_clk_in)
begin : GTX_TXOUTCLK_CNT
      begin
            gtx_txoutclk_count <= gtx_txoutclk_count + 1;
      end 
end


always @(posedge gtx0_txusrclk_i)
begin : GTX_TXUSRCLK_CNT
      begin
            gtx_txusrclk_count <= gtx_txusrclk_count + 1;
      end 
end

always @(posedge gtx0_txusrclk2_i)
begin : GTX_TXUSRCLK2_CNT
      begin
            gtx_txusrclk2_count <= gtx_txusrclk2_count + 1;
      end 
end


always @(posedge CLKIN_150)
begin : CLKIN_150_CNT
      begin
            CLKIN_150_count <= CLKIN_150_count + 1;
      end 
end


// SATA PHY ILA
wire [7:0] trig0;
wire [15:0] trig1;
wire [1:0] trig2;
wire [15:0] trig3;
wire [15:0] trig4;
wire [15:0] trig5;
wire [15:0] trig6;
wire [15:0] trig7;
wire [15:0] trig8;
wire [15:0] trig9;
wire [15:0] trig10;
wire [35:0] control;

if (CHIPSCOPE == "TRUE") begin
 sata_phy_ila  i_sata_phy_ila  
    (
      .control(sata_phy_ila_control),
      .clk(gtx0_txusrclk2_i),
      .trig0(trig0),
      .trig1(trig1),
      .trig2(trig2),
      .trig3(trig3),
      .trig4(trig4),
      .trig5(trig5),
      .trig6(trig6),
      .trig7(trig7),
      .trig8(trig8),
      .trig9(trig9),
      .trig10(trig10)
    );
end

assign trig0  = CurrentState_out;
assign trig1[0] = gtx0_rxstatus_i;
assign trig1[1] = gtx0_txusrclk_i;
assign trig1[2] = gtx0_txusrclk2_i;
assign trig1[3] = gtx_reset; 
assign trig1[4] = comfinish;
assign trig1[5] = PLLLKDET_OUT;
assign trig1[6] = mmcm_reset;
assign trig1[7] = mmcm_locked;
assign trig1[8] = rxelecidle0;
assign trig1[9] = RXBYTEISALIGNED0;
assign trig1[10] = gtx0_rxresetdone_i;
assign trig1[11] = txelecidle;
assign trig1[12] = txcominit;
assign trig1[13] = txcomwake;
assign trig1[14] = cominitdet;
assign trig1[15] = comwakedet;
assign trig2     = 2'b0;
assign trig3[0]  = gtx0_txresetdone_i;
assign trig3[1]  = speed_neg_rst;
assign trig3[2]  = GTXRESET_IN;
assign trig3[3]  = rst_1;
assign trig3[6:4]  = rxcharisk;
assign trig3[15:7] = 9'b0;
assign trig4     = gtx_refclk_count;
assign trig5     = gtx_txoutclk_count;
assign trig6     = gtx_txusrclk_count;
assign trig7     = gtx_txusrclk2_count;
assign trig8     = 16'b0;
assign trig9     = 16'b0;
assign trig10    = CLKIN_150_count;

endmodule


module sata_phy_ila 
  (
    control,
    clk,
    trig0,
    trig1,
    trig2,
    trig3,
    trig4,
    trig5,
    trig6,
    trig7,
    trig8,
    trig9,
    trig10
  );
  input [35:0] control;
  input clk;
  input [7:0]  trig0;
  input [15:0] trig1;
  input [1:0]  trig2;
  input [15:0] trig3;
  input [15:0] trig4;
  input [15:0] trig5;
  input [15:0] trig6;
  input [15:0] trig7;
  input [15:0] trig8;
  input [15:0] trig9;
  input [15:0] trig10;
  
endmodule
