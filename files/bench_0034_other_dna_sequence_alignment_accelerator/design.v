// Curated RTL benchmark case.
// case_id: bench_0034_other_dna_sequence_alignment_accelerator
// source_project: other_dna_sequence_alignment_accelerator
// top_module: sw_gen_affine


// -----------------------------------------------------------------------------
// Source file: sw_gen_affine.v
// -----------------------------------------------------------------------------
module sw_gen_affine(clk,
             rst,
             i_query_length,
				 i_local,
             query,
             i_vld,
             i_data,
             o_vld,
             m_result
                );

localparam
    SCORE_WIDTH = 11,
    N_A = 2'b00,        //nucleotide "A"
    N_G = 2'b01,        //nucleotide "G"
    N_T = 2'b10,        //nucleotide "T"
    N_C = 2'b11,        //nucleotide "C"
    INS = 1,            //insertion penalty
    DEL = 1,            //deletion penalty
    TB_UP = 2'b00,      //"UP" traceback pointer
    TB_DIAG = 2'b01,    //"DIAG" traceback pointer
    TB_LEFT = 2'b10;    //"LEFT" traceback pointer

parameter LOGLENGTH=6;                  //log2(total number of comparison blocks instantiated)
//parameter LENGTH = 1 << LOGLENGTH;      //total number of comparison blocks instantiated - query length must be less than this
parameter LENGTH = 48;

input wire rst;
input wire clk;
input wire [1:0] i_data;
input wire i_local;		//=1 if local alignment, =0 if global alignment
input wire [LOGLENGTH-1:0] i_query_length;            //this is the (length_of_the_actual_query_string - 1) (must be less than the max length value - 0=1 block, 1=2 blocks, etc)
input wire [(LENGTH*2-1):0] query;                  //this is the actual query sequence - query[1:0] goes into block0, query [3:2] goes into block1, etc.

output wire o_vld;
output wire [SCORE_WIDTH-1:0] m_result;

wire [2*(LENGTH-1)+1:0] data;

input wire i_vld;             //master valid signal at start of chain
wire vld[LENGTH-1:0];

wire [SCORE_WIDTH-1:0] right_m[LENGTH-1:0];			//the 'match' matrix cell value array 
wire [SCORE_WIDTH-1:0] right_i[LENGTH-1:0];			//the 'indel' matrix cell value array
wire [SCORE_WIDTH-1:0] high_score [LENGTH-1:0];		//the 'current highest score' array
wire [LENGTH-1:0] gap;
wire [LENGTH-1:0] reset;


assign o_vld = vld[i_query_length];
assign m_result = i_local ? high_score[i_query_length] : ((right_m[i_query_length] > right_i[i_query_length]) ? right_m[i_query_length] : right_i[i_query_length]);

//assign query={N_A,N_G,N_T,N_T};

genvar i;
generate
for (i=0; i < LENGTH; i = i + 1)
   begin: pe_block
      if (i == 0)                       //first processing element in auto-generated chain
		begin: pe_block0
         sw_pe_affine pe0(.clk(clk),
             .i_rst(rst),
				 .o_rst(reset[i]),
             .i_data(i_data[1:0]),
             .i_preload(query[1:0]),
             .i_left_m(11'b10000000000),
				 .i_left_i(11'b10000000000),
             .i_vld(i_vld),
				 .i_local(i_local),
				 .i_high(11'b0),
             .o_right_m(right_m[i]),
				 .o_right_i(right_i[i]),
				 .o_high(high_score[i]),
             .o_vld(vld[i]),
             .o_data(data[2*i+1:2*i]),
             .start(1'b1));
		end
		else         //processing elements other than first one
		begin: pe_block1
         sw_pe_affine pe1(.clk(clk),
             .i_rst(reset[i-1]),
				 .o_rst(reset[i]),
             .i_data(data[2*(i-1)+1:(i-1)*2]),
             .i_preload(query[i*2+1:i*2]),
             .i_left_m(right_m[i-1]),
				 .i_left_i(right_i[i-1]),
             .i_local(i_local),
             .i_vld(vld[i-1]),
				 .i_high(high_score[i-1]),
             .o_right_m(right_m[i]),
				 .o_right_i(right_i[i]),
				 .o_high(high_score[i]),
             .o_vld(vld[i]),
             .o_data(data[2*(i)+1:2*(i)]),
             .start(1'b0));
		end
   end
endgenerate


endmodule

// -----------------------------------------------------------------------------
// Source file: sw_pe_affine.v
// -----------------------------------------------------------------------------
module sw_pe_affine(clk,
             i_rst,
				 o_rst,
             i_data,
             i_preload,
             i_left_m,
				 i_left_i,
             i_high,
             i_vld,
             i_local,
             o_right_m,
				 o_right_i,
				 o_high,
             o_vld,
             o_data,
             start);

localparam
    SCORE_WIDTH = 11,
    N_A = 2'b00,        //nucleotide "A"
    N_G = 2'b01,        //nucleotide "G"
    N_T = 2'b10,        //nucleotide "T"
    N_C = 2'b11,        //nucleotide "C"
    INS_START = 3,            //insertion penalty
    INS_CONT  = 1,
    DEL_START = 3,            //deletion penalty
    DEL_CONT  = 1,
    TB_UP = 2'b00,      //"UP" traceback pointer
    TB_DIAG = 2'b01,    //"DIAG" traceback pointer
    TB_LEFT = 2'b10,    //"LEFT" traceback pointer
	 GOPEN = 12,
	 GEXT = 4;

input  wire clk;
input  wire i_rst;
output reg  o_rst;
input  wire [1:0] i_data;               //sequence being streamed in
input  wire [1:0] i_preload;            //fixed character assigned to this node
input  wire [SCORE_WIDTH-1:0] i_left_m;             //connection to left neighbor cell for M matrix
input  wire [SCORE_WIDTH-1:0] i_left_i;				//connection to left neighbor cell for I matrix
input  wire i_vld;                              //valid data coming from neighbor
input  wire i_local;			//=1 if local alignment, =0 if global alignment
input  wire start;                               //designate that you're on the left edge of the array
input  wire [SCORE_WIDTH-1:0] i_high;		//input of highest score from neighbor
output reg [SCORE_WIDTH-1:0] o_right_m;            //output of score from t-1 for M matrix
output reg [SCORE_WIDTH-1:0] o_right_i;				//output of score for t-1 for I matrix
output reg [SCORE_WIDTH-1:0] o_high;		//output of currently highest score

output reg  o_vld;                              //tells neighbor data is valid
output reg [1:0] o_data;



parameter LENGTH=48;
parameter LOGLENGTH = 6;

reg [1:0] state;        //just state counter

reg [SCORE_WIDTH-1:0] l_diag_score_m;
reg [SCORE_WIDTH-1:0] l_diag_score_i;

wire [SCORE_WIDTH-1:0] right_m_nxt;
wire [SCORE_WIDTH-1:0] right_i_nxt;
wire [SCORE_WIDTH-1:0] left_open;
wire [SCORE_WIDTH-1:0] left_ext;
wire [SCORE_WIDTH-1:0] up_open;
wire [SCORE_WIDTH-1:0] up_ext;
wire [SCORE_WIDTH-1:0] left_max;
wire [SCORE_WIDTH-1:0] up_max;
wire [SCORE_WIDTH-1:0] rightmax;
wire [SCORE_WIDTH-1:0] start_left;

reg [SCORE_WIDTH-1:0] match;
wire [SCORE_WIDTH-1:0] max_score_a;
wire [SCORE_WIDTH-1:0] max_score_b;
wire [SCORE_WIDTH-1:0] left_score;
wire [SCORE_WIDTH-1:0] up_score;
wire [SCORE_WIDTH-1:0] diag_score;
wire [SCORE_WIDTH-1:0] neutral_score;

wire [SCORE_WIDTH-1:0] left_score_b;


//compute new score options

assign neutral_score = 11'b10000000000;

assign start_left = (state==2'b01) ? (l_diag_score_m - GOPEN) : (l_diag_score_m - GEXT);

assign left_open = i_left_m  - GOPEN;
assign left_ext  = i_left_i  - GEXT;
assign up_open   = o_right_m - GOPEN;
assign up_ext    = o_right_i - GEXT;
assign left_max  = start ? start_left : ((left_open > left_ext) ? left_open : left_ext);
assign up_max    = (up_open   > up_ext)   ? up_open   : up_ext;

assign right_m_nxt = match + ((l_diag_score_m > l_diag_score_i) ? l_diag_score_m : l_diag_score_i);	//next m score
assign right_i_nxt = (left_max > up_max) ? left_max : up_max;
								



always@(posedge clk)
	o_rst <= i_rst;
	
always@*
    case({i_data[1:0],i_preload[1:0]})
//this is the match-score lookup table: +5 for a match, -4 for a mismatch
        {N_A,N_A}:match = 11'b101;	//+5
        {N_A,N_G}:match = 11'h7fc;	//-4
        {N_A,N_T}:match = 11'h7fc;
        {N_A,N_C}:match = 11'h7fc;
        {N_G,N_A}:match = 11'h7fc;
        {N_G,N_G}:match = 11'b101;
        {N_G,N_T}:match = 11'h7fc;
        {N_G,N_C}:match = 11'h7fc;
        {N_T,N_A}:match = 11'h7fc;
        {N_T,N_G}:match = 11'h7fc;
        {N_T,N_T}:match = 11'b101;
        {N_T,N_C}:match = 11'h7fc;
        {N_C,N_A}:match = 11'h7fc;
        {N_C,N_G}:match = 11'h7fc;
        {N_C,N_T}:match = 11'h7fc;
        {N_C,N_C}:match = 11'b101;
    endcase

//just propagate the valid signal
always@(posedge clk)
    if (i_rst==1'b1)
        o_vld <= 1'b0;
    else
        o_vld <= i_vld;           


//This continuously calculates the highest score to pass through the block
assign rightmax = (right_m_nxt > right_i_nxt) ? right_m_nxt : right_i_nxt;


always@(posedge clk)
begin
	if (i_rst==1'b1)
		o_high <= neutral_score;		//reset to "0"
	else if (i_vld==1'b1)
		o_high <= (o_high > rightmax) ? ( (o_high > i_high) ? o_high : i_high) : ((rightmax > i_high) ? rightmax : i_high);
end


always@(posedge clk) begin
       if (i_rst==1'b1) begin
								//This is where we initialize the matrix
                        o_right_m <= i_local ? neutral_score : (i_left_m - (start ? GOPEN : GEXT));	//init m matrix
                        o_right_i <= i_local ? neutral_score : (i_left_i - (start ? GOPEN : GEXT));	//init i matrix
			o_data[1:0] <= 2'b00;
                        l_diag_score_m <= start ? neutral_score : (i_local ? neutral_score : i_left_m);
			l_diag_score_i <= start ? neutral_score : (i_local ? neutral_score : i_left_i);
                      end
       else if (i_vld==1'b1) begin
                           o_data[1:0] <= i_data[1:0];
                           o_right_m <= (i_local ? ((right_m_nxt > neutral_score) ? right_m_nxt : neutral_score) : right_m_nxt);
			   o_right_i <= (i_local ? ((right_i_nxt > neutral_score) ? right_i_nxt : neutral_score) : right_i_nxt);
			   l_diag_score_m <= start ?  (i_local ? neutral_score : (l_diag_score_m - GEXT)) : i_left_m ;
			   l_diag_score_i <= start ?  (i_local ? neutral_score : (l_diag_score_i - GEXT)) : i_left_i ;									
                        end
                     end

always@(posedge clk) begin
    if (i_rst)
        state <= 2'b00;
    else begin
       case(state[1:0])
			 2'b00:state[1:0] <= 2'b01;										//reset state
          2'b01:if (i_vld==1'b1)        state[1:0] <= 2'b10;     //INIT state
          2'b10:if (i_vld==1'b0)        state[1:0] <= 2'b01;     //SCORE state   - i_vld must be held high from the start of the query sequence to the end of it
          2'b11:if (i_rst)              state[1:0] <= 2'b00;     //END state
       endcase
        end
    end
endmodule 
