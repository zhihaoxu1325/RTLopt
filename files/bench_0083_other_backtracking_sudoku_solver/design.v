// Curated RTL benchmark case.
// case_id: bench_0083_other_backtracking_sudoku_solver
// source_project: other_backtracking_sudoku_solver
// top_module: sudoku


// -----------------------------------------------------------------------------
// Source file: rtl/sudoku.v
// -----------------------------------------------------------------------------
module sudoku(/*AUTOARG*/
   // Outputs
   outGrid, unsolvedCells, timeOut, allDone, anyChanged, anyError,
   minIdx, minPoss,
   // Inputs
   clk, rst, clr, start, inGrid
   );
   input clk;
   input rst;
   input clr;
   
   input start;
   
   input [728:0] inGrid;
   output [728:0] outGrid;
   output [6:0]   unsolvedCells;
   output 	  timeOut;
   output 	  allDone;
   output 	  anyChanged;
   output 	  anyError;

   output [6:0]   minIdx;
   output [3:0]   minPoss;
      
   wire [8:0] 	  grid2d [80:0];
   wire [8:0] 	  currGrid [80:0];
   wire [80:0] 	  done;
   wire [80:0] 	  changed;
   wire [80:0] 	  error;
   
   wire [71:0] 	  rows [80:0];
   wire [71:0] 	  cols [80:0];
   wire [71:0] 	  sqrs [80:0];
   

   assign allDone = &done;
   assign anyChanged = |changed;
   //assign anyError = |error;
   
   reg [3:0] 	  r_cnt;
   assign timeOut = (r_cnt == 4'b1111);
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_cnt <= 4'd0;
	  end
	else
	  begin
	     r_cnt <= start ? 4'd0 : (|changed ? 4'd0 : r_cnt + 4'd1);
	  end
     end // always@ (posedge clk)

   minPiece mP0 
     (
      .minPoss(minPoss),
      .minIdx(minIdx),
      .clk(clk),
      .rst(rst),
      .inGrid(outGrid)
      );
         
   
   genvar 	  i;
   generate
      for(i=0;i<81;i=i+1)
	begin: unflatten
	   assign grid2d[i] = inGrid[(9*(i+1))-1:9*i];
	end
   endgenerate

   wire [6:0] w_unSolvedCells;
   reg [6:0]  r_unSolvedCells;
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_unSolvedCells <= 7'd81;
	  end
	else
	  begin
	     r_unSolvedCells <= start ? 7'd81 : w_unSolvedCells;
	  end
     end // always@ (posedge clk)
   assign unsolvedCells = r_unSolvedCells;
   
   ones_count81 oc0 (.in(~done), .out(w_unSolvedCells));
   
   generate
      for(i=0;i<81;i=i+1)
	begin: pieces
	   piece pg (
		  // Outputs
		     .changed			(changed[i]),
		     .done			(done[i]),
		     .curr_value			(currGrid[i]),
		     .error                     (error[i]),
		     // Inputs
		     .clk				(clk),
		     .rst				(rst),
		     .clr                               (clr),
		     .start			(start),
		     .start_value			(grid2d[i]),
		     .my_row			(rows[i]),
		     .my_col			(cols[i]),
		     .my_square			(sqrs[i])
		  );
	end // block: pieces
    endgenerate
   
   assign cols[0] = {currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[0] = {currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[0] = {currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[1] = {currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[1] = {currGrid[0],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[1] = {currGrid[0],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[2] = {currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[2] = {currGrid[0],currGrid[1],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[2] = {currGrid[0],currGrid[1],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[3] = {currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[3] = {currGrid[0],currGrid[1],currGrid[2],currGrid[4],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[3] = {currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[4] = {currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[4] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[5],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[4] = {currGrid[3],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[5] = {currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[5] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[6],currGrid[7],currGrid[8]};
assign sqrs[5] = {currGrid[3],currGrid[4],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[6] = {currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[6] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[7],currGrid[8]};
assign sqrs[6] = {currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[7] = {currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[7] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[8]};
assign sqrs[7] = {currGrid[6],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[8] = {currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[8] = {currGrid[0],currGrid[1],currGrid[2],currGrid[3],currGrid[4],currGrid[5],currGrid[6],currGrid[7]};
assign sqrs[8] = {currGrid[6],currGrid[7],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[9] = {currGrid[0],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[9] = {currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[9] = {currGrid[0],currGrid[1],currGrid[2],currGrid[10],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[10] = {currGrid[1],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[10] = {currGrid[9],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[10] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[11],currGrid[18],currGrid[19],currGrid[20]};
assign cols[11] = {currGrid[2],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[11] = {currGrid[9],currGrid[10],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[11] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[18],currGrid[19],currGrid[20]};
assign cols[12] = {currGrid[3],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[12] = {currGrid[9],currGrid[10],currGrid[11],currGrid[13],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[12] = {currGrid[3],currGrid[4],currGrid[5],currGrid[13],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[13] = {currGrid[4],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[13] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[14],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[13] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[14],currGrid[21],currGrid[22],currGrid[23]};
assign cols[14] = {currGrid[5],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[14] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[15],currGrid[16],currGrid[17]};
assign sqrs[14] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[21],currGrid[22],currGrid[23]};
assign cols[15] = {currGrid[6],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[15] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[16],currGrid[17]};
assign sqrs[15] = {currGrid[6],currGrid[7],currGrid[8],currGrid[16],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[16] = {currGrid[7],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[16] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[17]};
assign sqrs[16] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[17],currGrid[24],currGrid[25],currGrid[26]};
assign cols[17] = {currGrid[8],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[17] = {currGrid[9],currGrid[10],currGrid[11],currGrid[12],currGrid[13],currGrid[14],currGrid[15],currGrid[16]};
assign sqrs[17] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[24],currGrid[25],currGrid[26]};
assign cols[18] = {currGrid[0],currGrid[9],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[18] = {currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[18] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[19],currGrid[20]};
assign cols[19] = {currGrid[1],currGrid[10],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[19] = {currGrid[18],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[19] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[20]};
assign cols[20] = {currGrid[2],currGrid[11],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[20] = {currGrid[18],currGrid[19],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[20] = {currGrid[0],currGrid[1],currGrid[2],currGrid[9],currGrid[10],currGrid[11],currGrid[18],currGrid[19]};
assign cols[21] = {currGrid[3],currGrid[12],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[21] = {currGrid[18],currGrid[19],currGrid[20],currGrid[22],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[21] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[22],currGrid[23]};
assign cols[22] = {currGrid[4],currGrid[13],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[22] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[23],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[22] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[23]};
assign cols[23] = {currGrid[5],currGrid[14],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[23] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[24],currGrid[25],currGrid[26]};
assign sqrs[23] = {currGrid[3],currGrid[4],currGrid[5],currGrid[12],currGrid[13],currGrid[14],currGrid[21],currGrid[22]};
assign cols[24] = {currGrid[6],currGrid[15],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[24] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[25],currGrid[26]};
assign sqrs[24] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[25],currGrid[26]};
assign cols[25] = {currGrid[7],currGrid[16],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[25] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[26]};
assign sqrs[25] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[26]};
assign cols[26] = {currGrid[8],currGrid[17],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[26] = {currGrid[18],currGrid[19],currGrid[20],currGrid[21],currGrid[22],currGrid[23],currGrid[24],currGrid[25]};
assign sqrs[26] = {currGrid[6],currGrid[7],currGrid[8],currGrid[15],currGrid[16],currGrid[17],currGrid[24],currGrid[25]};
assign cols[27] = {currGrid[0],currGrid[9],currGrid[18],currGrid[36],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[27] = {currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[27] = {currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[28] = {currGrid[1],currGrid[10],currGrid[19],currGrid[37],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[28] = {currGrid[27],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[28] = {currGrid[27],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[29] = {currGrid[2],currGrid[11],currGrid[20],currGrid[38],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[29] = {currGrid[27],currGrid[28],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[29] = {currGrid[27],currGrid[28],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[30] = {currGrid[3],currGrid[12],currGrid[21],currGrid[39],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[30] = {currGrid[27],currGrid[28],currGrid[29],currGrid[31],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[30] = {currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[31] = {currGrid[4],currGrid[13],currGrid[22],currGrid[40],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[31] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[32],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[31] = {currGrid[30],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[32] = {currGrid[5],currGrid[14],currGrid[23],currGrid[41],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[32] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[33],currGrid[34],currGrid[35]};
assign sqrs[32] = {currGrid[30],currGrid[31],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[33] = {currGrid[6],currGrid[15],currGrid[24],currGrid[42],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[33] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[34],currGrid[35]};
assign sqrs[33] = {currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[34] = {currGrid[7],currGrid[16],currGrid[25],currGrid[43],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[34] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[35]};
assign sqrs[34] = {currGrid[33],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[35] = {currGrid[8],currGrid[17],currGrid[26],currGrid[44],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[35] = {currGrid[27],currGrid[28],currGrid[29],currGrid[30],currGrid[31],currGrid[32],currGrid[33],currGrid[34]};
assign sqrs[35] = {currGrid[33],currGrid[34],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[36] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[45],currGrid[54],currGrid[63],currGrid[72]};
assign rows[36] = {currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[36] = {currGrid[27],currGrid[28],currGrid[29],currGrid[37],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[37] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[46],currGrid[55],currGrid[64],currGrid[73]};
assign rows[37] = {currGrid[36],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[37] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[38],currGrid[45],currGrid[46],currGrid[47]};
assign cols[38] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[47],currGrid[56],currGrid[65],currGrid[74]};
assign rows[38] = {currGrid[36],currGrid[37],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[38] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[45],currGrid[46],currGrid[47]};
assign cols[39] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[48],currGrid[57],currGrid[66],currGrid[75]};
assign rows[39] = {currGrid[36],currGrid[37],currGrid[38],currGrid[40],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[39] = {currGrid[30],currGrid[31],currGrid[32],currGrid[40],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[40] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[49],currGrid[58],currGrid[67],currGrid[76]};
assign rows[40] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[41],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[40] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[41],currGrid[48],currGrid[49],currGrid[50]};
assign cols[41] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[50],currGrid[59],currGrid[68],currGrid[77]};
assign rows[41] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[42],currGrid[43],currGrid[44]};
assign sqrs[41] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[48],currGrid[49],currGrid[50]};
assign cols[42] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[51],currGrid[60],currGrid[69],currGrid[78]};
assign rows[42] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[43],currGrid[44]};
assign sqrs[42] = {currGrid[33],currGrid[34],currGrid[35],currGrid[43],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[43] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[52],currGrid[61],currGrid[70],currGrid[79]};
assign rows[43] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[44]};
assign sqrs[43] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[44],currGrid[51],currGrid[52],currGrid[53]};
assign cols[44] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[53],currGrid[62],currGrid[71],currGrid[80]};
assign rows[44] = {currGrid[36],currGrid[37],currGrid[38],currGrid[39],currGrid[40],currGrid[41],currGrid[42],currGrid[43]};
assign sqrs[44] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[51],currGrid[52],currGrid[53]};
assign cols[45] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[54],currGrid[63],currGrid[72]};
assign rows[45] = {currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[45] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[46],currGrid[47]};
assign cols[46] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[55],currGrid[64],currGrid[73]};
assign rows[46] = {currGrid[45],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[46] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[47]};
assign cols[47] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[56],currGrid[65],currGrid[74]};
assign rows[47] = {currGrid[45],currGrid[46],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[47] = {currGrid[27],currGrid[28],currGrid[29],currGrid[36],currGrid[37],currGrid[38],currGrid[45],currGrid[46]};
assign cols[48] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[57],currGrid[66],currGrid[75]};
assign rows[48] = {currGrid[45],currGrid[46],currGrid[47],currGrid[49],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[48] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[49],currGrid[50]};
assign cols[49] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[58],currGrid[67],currGrid[76]};
assign rows[49] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[50],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[49] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[50]};
assign cols[50] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[59],currGrid[68],currGrid[77]};
assign rows[50] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[51],currGrid[52],currGrid[53]};
assign sqrs[50] = {currGrid[30],currGrid[31],currGrid[32],currGrid[39],currGrid[40],currGrid[41],currGrid[48],currGrid[49]};
assign cols[51] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[60],currGrid[69],currGrid[78]};
assign rows[51] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[52],currGrid[53]};
assign sqrs[51] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[52],currGrid[53]};
assign cols[52] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[61],currGrid[70],currGrid[79]};
assign rows[52] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[53]};
assign sqrs[52] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[53]};
assign cols[53] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[62],currGrid[71],currGrid[80]};
assign rows[53] = {currGrid[45],currGrid[46],currGrid[47],currGrid[48],currGrid[49],currGrid[50],currGrid[51],currGrid[52]};
assign sqrs[53] = {currGrid[33],currGrid[34],currGrid[35],currGrid[42],currGrid[43],currGrid[44],currGrid[51],currGrid[52]};
assign cols[54] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[63],currGrid[72]};
assign rows[54] = {currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[54] = {currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[55] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[64],currGrid[73]};
assign rows[55] = {currGrid[54],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[55] = {currGrid[54],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[56] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[65],currGrid[74]};
assign rows[56] = {currGrid[54],currGrid[55],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[56] = {currGrid[54],currGrid[55],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[57] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[66],currGrid[75]};
assign rows[57] = {currGrid[54],currGrid[55],currGrid[56],currGrid[58],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[57] = {currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[58] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[67],currGrid[76]};
assign rows[58] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[59],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[58] = {currGrid[57],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[59] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[68],currGrid[77]};
assign rows[59] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[60],currGrid[61],currGrid[62]};
assign sqrs[59] = {currGrid[57],currGrid[58],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[60] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[69],currGrid[78]};
assign rows[60] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[61],currGrid[62]};
assign sqrs[60] = {currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[61] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[70],currGrid[79]};
assign rows[61] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[62]};
assign sqrs[61] = {currGrid[60],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[62] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[71],currGrid[80]};
assign rows[62] = {currGrid[54],currGrid[55],currGrid[56],currGrid[57],currGrid[58],currGrid[59],currGrid[60],currGrid[61]};
assign sqrs[62] = {currGrid[60],currGrid[61],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[63] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[72]};
assign rows[63] = {currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[63] = {currGrid[54],currGrid[55],currGrid[56],currGrid[64],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[64] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[73]};
assign rows[64] = {currGrid[63],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[64] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[65],currGrid[72],currGrid[73],currGrid[74]};
assign cols[65] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[74]};
assign rows[65] = {currGrid[63],currGrid[64],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[65] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[72],currGrid[73],currGrid[74]};
assign cols[66] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[75]};
assign rows[66] = {currGrid[63],currGrid[64],currGrid[65],currGrid[67],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[66] = {currGrid[57],currGrid[58],currGrid[59],currGrid[67],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[67] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[76]};
assign rows[67] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[68],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[67] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[68],currGrid[75],currGrid[76],currGrid[77]};
assign cols[68] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[77]};
assign rows[68] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[69],currGrid[70],currGrid[71]};
assign sqrs[68] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[75],currGrid[76],currGrid[77]};
assign cols[69] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[78]};
assign rows[69] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[70],currGrid[71]};
assign sqrs[69] = {currGrid[60],currGrid[61],currGrid[62],currGrid[70],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[70] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[79]};
assign rows[70] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[71]};
assign sqrs[70] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[71],currGrid[78],currGrid[79],currGrid[80]};
assign cols[71] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[80]};
assign rows[71] = {currGrid[63],currGrid[64],currGrid[65],currGrid[66],currGrid[67],currGrid[68],currGrid[69],currGrid[70]};
assign sqrs[71] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[78],currGrid[79],currGrid[80]};
assign cols[72] = {currGrid[0],currGrid[9],currGrid[18],currGrid[27],currGrid[36],currGrid[45],currGrid[54],currGrid[63]};
assign rows[72] = {currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[72] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[73],currGrid[74]};
assign cols[73] = {currGrid[1],currGrid[10],currGrid[19],currGrid[28],currGrid[37],currGrid[46],currGrid[55],currGrid[64]};
assign rows[73] = {currGrid[72],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[73] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[74]};
assign cols[74] = {currGrid[2],currGrid[11],currGrid[20],currGrid[29],currGrid[38],currGrid[47],currGrid[56],currGrid[65]};
assign rows[74] = {currGrid[72],currGrid[73],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[74] = {currGrid[54],currGrid[55],currGrid[56],currGrid[63],currGrid[64],currGrid[65],currGrid[72],currGrid[73]};
assign cols[75] = {currGrid[3],currGrid[12],currGrid[21],currGrid[30],currGrid[39],currGrid[48],currGrid[57],currGrid[66]};
assign rows[75] = {currGrid[72],currGrid[73],currGrid[74],currGrid[76],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[75] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[76],currGrid[77]};
assign cols[76] = {currGrid[4],currGrid[13],currGrid[22],currGrid[31],currGrid[40],currGrid[49],currGrid[58],currGrid[67]};
assign rows[76] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[77],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[76] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[77]};
assign cols[77] = {currGrid[5],currGrid[14],currGrid[23],currGrid[32],currGrid[41],currGrid[50],currGrid[59],currGrid[68]};
assign rows[77] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[78],currGrid[79],currGrid[80]};
assign sqrs[77] = {currGrid[57],currGrid[58],currGrid[59],currGrid[66],currGrid[67],currGrid[68],currGrid[75],currGrid[76]};
assign cols[78] = {currGrid[6],currGrid[15],currGrid[24],currGrid[33],currGrid[42],currGrid[51],currGrid[60],currGrid[69]};
assign rows[78] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[79],currGrid[80]};
assign sqrs[78] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[79],currGrid[80]};
assign cols[79] = {currGrid[7],currGrid[16],currGrid[25],currGrid[34],currGrid[43],currGrid[52],currGrid[61],currGrid[70]};
assign rows[79] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[80]};
assign sqrs[79] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[80]};
assign cols[80] = {currGrid[8],currGrid[17],currGrid[26],currGrid[35],currGrid[44],currGrid[53],currGrid[62],currGrid[71]};
assign rows[80] = {currGrid[72],currGrid[73],currGrid[74],currGrid[75],currGrid[76],currGrid[77],currGrid[78],currGrid[79]};
assign sqrs[80] = {currGrid[60],currGrid[61],currGrid[62],currGrid[69],currGrid[70],currGrid[71],currGrid[78],currGrid[79]};

  generate
     for(i=0;i<81;i=i+1)
       begin: outGridGen
	  assign outGrid[(9*(i+1)-1):(9*i)] = currGrid[i];

       end
  endgenerate
      
   
   genvar ii,jj;
   wire [80:0] c_rows [8:0];
   wire [80:0] c_cols [8:0];
   wire [80:0] c_grds [8:0];
   wire [26:0] w_correct;
   
   generate
      for(ii=0;ii<9;ii=ii+1)
	begin: row_check
	   assign c_rows[0][(9*(ii+1)-1):9*ii] = currGrid[ii];
	   assign c_rows[1][(9*(ii+1)-1):9*ii] = currGrid[9+ii];
	   assign c_rows[2][(9*(ii+1)-1):9*ii] = currGrid[18+ii];
	   assign c_rows[3][(9*(ii+1)-1):9*ii] = currGrid[27+ii];
	   assign c_rows[4][(9*(ii+1)-1):9*ii] = currGrid[36+ii];
	   assign c_rows[5][(9*(ii+1)-1):9*ii] = currGrid[45+ii];
	   assign c_rows[6][(9*(ii+1)-1):9*ii] = currGrid[54+ii];
	   assign c_rows[7][(9*(ii+1)-1):9*ii] = currGrid[63+ii];
	   assign c_rows[8][(9*(ii+1)-1):9*ii] = currGrid[72+ii];
	end
   endgenerate
   
   generate
      for(ii=0;ii<9;ii=ii+1)
	begin: col_check
	   assign c_cols[0][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 0];
	   assign c_cols[1][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 1];
	   assign c_cols[2][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 2];
	   assign c_cols[3][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 3];
	   assign c_cols[4][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 4];
	   assign c_cols[5][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 5];
	   assign c_cols[6][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 6];
	   assign c_cols[7][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 7];
	   assign c_cols[8][(9*(ii+1)-1):9*ii] = currGrid[9*ii + 8];
	end
   endgenerate

   genvar iii,jjj;
   generate
      for(ii=0; ii < 3; ii=ii+1)
	begin: grd_check_y
	   for(jj = 0; jj < 3; jj=jj+1)
	     begin: grd_check_x
		for(iii=3*ii; iii < 3*(ii+1); iii=iii+1)
		  begin: gg_y
		     for(jjj=3*jj; jjj < 3*(jj+1); jjj=jjj+1)
		       begin: gg_x
			  			  
			  //(3*(iii-3*ii) + (jjj-3*jj))
			  assign c_grds[3*ii+jj][9*(3*(iii-3*ii) + (jjj-3*jj)+1)-1:9*(3*(iii-3*ii) + (jjj-3*jj))] = 														   currGrid[9*iii + jjj];
		       end 
		  end
	     end
	end
   endgenerate
         
   generate
      for(ii=0;ii<9;ii=ii+1)
	begin: checks
	   checkCorrect cC_R (.y(w_correct[ii]), .in(c_rows[ii]));
	   checkCorrect cC_C (.y(w_correct[9+ii]), .in(c_cols[ii]));
	   checkCorrect cC_G (.y(w_correct[18+ii]), .in(c_grds[ii]));
	end
   endgenerate
   
   assign anyError = ~(&w_correct);
   
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/minPiece.v
// -----------------------------------------------------------------------------
module minPiece(/*AUTOARG*/
   // Outputs
   minPoss, minIdx,
   // Inputs
   clk, rst, inGrid
   );

   input clk;
   input rst;
   
   input [728:0] inGrid;
   
   output [3:0]  minPoss;
   output [6:0]  minIdx;
   
   reg [3:0] 	 r_minPoss;
   reg [6:0] 	 r_minIdx;

   assign minPoss = r_minPoss;
   assign minIdx = r_minIdx;
   
   
   wire [8:0] 	 grid2d [80:0];

   wire [6:0] 	 gridIndices [80:0];
   wire [3:0] 	 gridPoss [80:0];
      
   genvar 	 i;

   /* unflatten */
   generate
      for(i=0;i<81;i=i+1)
	begin: unflatten
	   assign grid2d[i] = inGrid[(9*(i+1))-1:9*i];
	   assign gridIndices[i] = i;
	   countPoss cP (.clk(clk), .rst(rst), .in(grid2d[i]), .out(gridPoss[i]));
	end
   endgenerate

   wire [6:0] 	 stage1_gridIndices [39:0];
   wire [3:0] 	 stage1_gridPoss [39:0];

   generate
      for(i=0;i<40;i=i+1)
	begin: stage1
	   cmpPiece cP_stage1
	    (
	     .outPoss(stage1_gridPoss[i]),
	     .outIdx(stage1_gridIndices[i]),
	     .inPoss_0(gridPoss[2*i]),
	     .inIdx_0(gridIndices[2*i]),
	     .inPoss_1(gridPoss[2*i+1]),
	     .inIdx_1(gridIndices[2*i+1])
	     );
	end
   endgenerate

   wire [6:0] 	 stage2_gridIndices [19:0];
   wire [3:0] 	 stage2_gridPoss [19:0];

   generate
      for(i=0;i<20;i=i+1)
	begin: stage2
	   cmpPiece cP_stage2
	    (
	     .outPoss(stage2_gridPoss[i]),
	     .outIdx(stage2_gridIndices[i]),
	     .inPoss_0(stage1_gridPoss[2*i]),
	     .inIdx_0(stage1_gridIndices[2*i]),
	     .inPoss_1(stage1_gridPoss[2*i+1]),
	     .inIdx_1(stage1_gridIndices[2*i+1])
	     );
	end
   endgenerate

   wire [6:0] 	 stage3_gridIndices [9:0];
   wire [3:0] 	 stage3_gridPoss [9:0];
   
   generate
      for(i=0;i<10;i=i+1)
	begin: stage3
	   cmpPiece cP_stage3
	    (
	     .outPoss(stage3_gridPoss[i]),
	     .outIdx(stage3_gridIndices[i]),
	     .inPoss_0(stage2_gridPoss[2*i]),
	     .inIdx_0(stage2_gridIndices[2*i]),
	     .inPoss_1(stage2_gridPoss[2*i+1]),
	     .inIdx_1(stage2_gridIndices[2*i+1])
	     );
	end
   endgenerate

   wire [6:0] 	 stage4_gridIndices [4:0];
   wire [3:0] 	 stage4_gridPoss [4:0];

   generate
      for(i=0;i<5;i=i+1)
	begin: stage4
	   cmpPiece cP_stage4
	    (
	     .outPoss(stage4_gridPoss[i]),
	     .outIdx(stage4_gridIndices[i]),
	     .inPoss_0(stage3_gridPoss[2*i]),
	     .inIdx_0(stage3_gridIndices[2*i]),
	     .inPoss_1(stage3_gridPoss[2*i+1]),
	     .inIdx_1(stage3_gridIndices[2*i+1])
	     );
	end
   endgenerate

   wire [6:0] 	 stage5_gridIndices [1:0];
   wire [3:0] 	 stage5_gridPoss [1:0];

   
   generate
      for(i=0;i<2;i=i+1)
	begin: stage5
	   cmpPiece cP_stage5
	    (
	     .outPoss(stage5_gridPoss[i]),
	     .outIdx(stage5_gridIndices[i]),
	     .inPoss_0(stage4_gridPoss[2*i]),
	     .inIdx_0(stage4_gridIndices[2*i]),
	     .inPoss_1(stage4_gridPoss[2*i+1]),
	     .inIdx_1(stage4_gridIndices[2*i+1])
	     );
	end
   endgenerate


   wire [6:0] stage6_gridIndices_A;
   wire [3:0] stage6_gridPoss_A;

   cmpPiece cP_stage6_A
     (
      .outPoss(stage6_gridPoss_A),
      .outIdx(stage6_gridIndices_A),
      .inPoss_0(stage5_gridPoss[0]),
      .inIdx_0(stage5_gridIndices[0]),
      .inPoss_1(stage5_gridPoss[1]),
      .inIdx_1(stage5_gridIndices[1])
      );
   
   wire [6:0] stage6_gridIndices_B;
   wire [3:0] stage6_gridPoss_B;
   
   cmpPiece cP_stage6_B
     (
      .outPoss(stage6_gridPoss_B),
      .outIdx(stage6_gridIndices_B),
      .inPoss_0(stage4_gridPoss[4]),
      .inIdx_0(stage4_gridIndices[4]),
      .inPoss_1(gridPoss[80]),
      .inIdx_1(gridIndices[80])
      );
   
   wire [6:0] stage7_gridIndices;
   wire [3:0] stage7_gridPoss;
   
   cmpPiece cP_stage7
     (
      .outPoss(stage7_gridPoss),
      .outIdx(stage7_gridIndices),
      .inPoss_0(stage6_gridPoss_A),
      .inIdx_0(stage6_gridIndices_A),
      .inPoss_1(stage6_gridPoss_B),
      .inIdx_1(stage6_gridIndices_B)
      );

   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_minIdx <= 7'd0;
	     r_minPoss <= 4'hf;
	  end
	else
	  begin
	     r_minIdx <= stage7_gridIndices;
	     r_minPoss <= stage7_gridPoss;
	  end
     end // always@ (posedge clk)
      
endmodule

module cmpPiece(/*AUTOARG*/
   // Outputs
   outPoss, outIdx,
   // Inputs
   inPoss_0, inIdx_0, inPoss_1, inIdx_1
   );
   input [3:0] inPoss_0;
   input [6:0] inIdx_0;

   input [3:0] inPoss_1;
   input [6:0] inIdx_1;

   output [3:0] outPoss;
   output [6:0] outIdx;

   wire 	w_cmp = (inPoss_0 < inPoss_1);

   assign outPoss = w_cmp ? inPoss_0 : inPoss_1;
   assign outIdx = w_cmp ? inIdx_0 : inIdx_1;
   
endmodule // cmpPiece

module countPoss(clk,rst,in,out);
   input [8:0] in;
   input       clk;
   input       rst;
   
   output [3:0] out;
   reg [3:0] 	r_out;
   assign out = r_out;
   
   wire [3:0] 	w_cnt;
      
   one_count9 c0(in, w_cnt);
   wire [3:0] w_out = (w_cnt == 4'd1) ? 4'd15 : w_cnt;

   always@(posedge clk)
     begin
	r_out <= rst ? 4'd15 : w_out;
     end
   
endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/piece.v
// -----------------------------------------------------------------------------
module piece(/*AUTOARG*/
   // Outputs
   changed, done, curr_value, error,
   // Inputs
   clk, rst, start, clr, start_value, my_row, my_col, my_square
   );
   input clk;
   input rst;
   input start;
   input clr;
   
   output changed;
   output done;
   output error;
   
   input [8:0] start_value;
   output [8:0] curr_value;
      
   input [71:0] my_row;
   input [71:0] my_col;
   input [71:0] my_square;
   
   wire [8:0] 	row2d [7:0];
   wire [8:0] 	col2d [7:0];
   wire [8:0] 	sqr2d [7:0];

   wire [8:0] 	row2d_solv [7:0];
   wire [8:0] 	col2d_solv [7:0];
   wire [8:0] 	sqr2d_solv [7:0];

   reg [8:0] 	r_curr_value;
   reg [8:0] 	t_next_value;
   assign curr_value = r_curr_value;

   reg [2:0] 	r_state, n_state;
   reg 		r_solved, t_solved;
   reg 		t_changed,r_changed;
   reg 		t_error,r_error;
   
   assign done = r_solved;
   assign changed = r_changed;
   assign error = r_error;
      
   wire [8:0] 	w_solved;
   wire 	w_piece_solved = (w_solved != 9'd0);
   one_set s0 (r_curr_value, w_solved);
   
   
   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_curr_value <= 9'd0;
	     r_state <= 3'd0;
	     r_solved <= 1'b0;
	     r_changed <= 1'b0;
	     r_error <= 1'b0;
	  end
	else
	  begin
	     r_curr_value <= clr ? 9'd0 : t_next_value;
	     r_state <= clr ? 3'd0 : n_state;
	     r_solved <= clr ? 1'b0 : t_solved;
	     r_changed <= clr ? 1'b0 : t_changed;
	     r_error <= clr ? 1'b0 : t_error;
	  end
     end // always@ (posedge clk)
   

   
   genvar 	i;
   generate
      for(i=0;i<8;i=i+1)
	begin: unflatten
	   assign row2d[i] = my_row[(9*(i+1))-1:9*i];
	   assign col2d[i] = my_col[(9*(i+1))-1:9*i];
	   assign sqr2d[i] = my_square[(9*(i+1))-1:9*i];
	end
   endgenerate

   generate
      for(i=0;i<8;i=i+1)
	begin: unique_rows
	   one_set rs (row2d[i], row2d_solv[i]);
	   one_set cs (col2d[i], col2d_solv[i]);
	   one_set ss (sqr2d[i], sqr2d_solv[i]);
	end
   endgenerate

   /* OR output of one_set to find cells
    * that are already set in col, grid, row */

   
   wire [8:0] set_row = 
	      row2d_solv[0] | row2d_solv[1] | row2d_solv[2] |
   	      row2d_solv[3] | row2d_solv[4] | row2d_solv[5] |
   	      row2d_solv[6] | row2d_solv[7];
   
   wire [8:0] set_col = 
	      col2d_solv[0] | col2d_solv[1] | col2d_solv[2] |
	      col2d_solv[3] | col2d_solv[4] | col2d_solv[5] |
	      col2d_solv[6] | col2d_solv[7];
      
   wire [8:0] set_sqr = 
	      sqr2d_solv[0] | sqr2d_solv[1] | sqr2d_solv[2] |
	      sqr2d_solv[3] | sqr2d_solv[4] | sqr2d_solv[5] |
	      sqr2d_solv[6] | sqr2d_solv[7];
   

   integer    ii;
   
   always@(posedge clk)
     begin
	if(rst==1'b0)
	  begin
	     for(ii=0;ii<8;ii=ii+1)
	       begin
		  if(row2d_solv[ii] === 9'dx)
		    begin
		       $display("row %d", ii);
		       $stop();
		    end
	       end
	  end
	//$display("row2d_solv[0] = %x", row2d_solv[0]);
     end

   

   /* finding unique */
   wire [8:0] row_or = 
	      row2d[0] | row2d[1] | row2d[2] |
	      row2d[3] | row2d[4] | row2d[5] |
	      row2d[6] | row2d[7] ;

   wire [8:0] col_or = 
	      col2d[0] | col2d[1] | col2d[2] |
	      col2d[3] | col2d[4] | col2d[5] |
	      col2d[6] | col2d[7] ;
   
   wire [8:0] sqr_or = 
	      sqr2d[0] | sqr2d[1] | sqr2d[2] |
	      sqr2d[3] | sqr2d[4] | sqr2d[5] |
	      sqr2d[6] | sqr2d[7] ;
   


   wire [8:0] row_nor = ~row_or;
   wire [8:0] col_nor = ~col_or;
   wire [8:0] sqr_nor = ~sqr_or;

   wire [8:0] row_singleton;
   wire [8:0] col_singleton;
   wire [8:0] sqr_singleton;
   
   one_set s1 (r_curr_value & row_nor, row_singleton);
   one_set s2 (r_curr_value & col_nor, col_singleton);
   one_set s3 (r_curr_value & sqr_nor, sqr_singleton);
   
   /* these are the values of the set rows, columns, and 
    * squares */
   
   wire [8:0] not_poss = set_row | set_col | set_sqr;
   
   wire [8:0] new_poss = r_curr_value & (~not_poss);
   wire       w_piece_zero = (r_curr_value == 9'd0);
   
   always@(*)
     begin
	t_next_value = r_curr_value;
	n_state = r_state;
	t_solved = r_solved;
	t_changed = 1'b0;
	t_error = r_error;
	
	case(r_state)
	  3'd0:
	    begin
	       if(start)
		 begin
		    t_next_value = start_value;
		    n_state = 3'd1;
		    t_changed = 1'b1;
		    t_error = 1'b0;
		 end
	    end
	  3'd1:
	    begin
	       if(w_piece_solved | w_piece_zero)
		 begin
		    t_solved = 1'b1;
		    n_state = 3'd7;
		    t_changed = 1'b1;
		    t_error = w_piece_zero;
		 end
	       else
		 begin
		    t_changed = (new_poss != r_curr_value);
		    t_next_value = new_poss;
		    n_state = 3'd2;
		 end
	    end // case: 3'd1
	  3'd2:
	    begin
	       if(w_piece_solved | w_piece_zero)
		 begin
		    t_solved = 1'b1;
		    n_state = 3'd7;
		    t_error = w_piece_zero;
		 end
	       else
		 begin
		    if(row_singleton != 9'd0)
		      begin
			 //$display("used row singleton");
			 t_next_value = row_singleton;
			 t_changed = 1'b1;
			 t_solved = 1'b1;
			 n_state = 3'd7;
		      end
		    else if(col_singleton != 9'd0)
		      begin
			 //$display("used col singleton");
			 t_next_value = col_singleton;
			 t_changed = 1'b1;
		      	 t_solved = 1'b1;
			 n_state = 3'd7;
		      end
		    else if(sqr_singleton != 9'd0)
		      begin
			 //$display("used sqr singleton");
			 t_next_value = sqr_singleton;
			 t_changed = 1'b1;
		      	 t_solved = 1'b1;
			 n_state = 3'd7;
		      end
		    else
		      begin
			 n_state = 3'd1;
		      end
		 end
	    end
	  3'd7:
	    begin
	       t_solved = 1'b1;
	       n_state = 3'd7;
	    end

	endcase // case (r_state)
     end
          
         
   
endmodule // piece

module one_set(input [8:0] in, output [8:0] out);
   wire is_pow2 = 
	(in == 9'd1) | (in == 9'd2) | (in == 9'd4) |
	(in == 9'd8) | (in == 9'd16)  | (in == 9'd32) |
	(in == 9'd64) | (in == 9'd128) | (in == 9'd256);
   
   assign out = {9{is_pow2}} & in;
endmodule // one_set

module two_set(input [8:0] in, output [8:0] out);
   wire [3:0] c;
   one_count9 oc (.in(in), .out(c));
   assign out = (c==4'd2) ? in : 9'd0;
endmodule

module ones_count81(input [80:0] in, output [6:0] out);
   wire [83:0] w_in = {3'd0, in};
   wire [2:0]  ps [20:0];

   integer     x;
   reg [6:0]   t_sum;
   genvar      i;
   generate
      for(i=0;i<21;i=i+1)
	begin : builders
	   one_count4 os (w_in[(4*(i+1)) - 1 : 4*i], ps[i]);
	end
   endgenerate
   always@(*)
		       begin
			  t_sum = 7'd0;
			  for(x = 0; x < 21; x=x+1)
			    begin
			       t_sum = t_sum + {3'd0, ps[x]};
			    end
		       end
   assign out = t_sum;
      
endmodule // ones_count81

module one_count4(input [3:0] in, output [2:0] out);
   assign out = 
		(in == 4'b0000) ? 3'd0 :
		(in == 4'b0001) ? 3'd1 :
		(in == 4'b0010) ? 3'd1 :
		(in == 4'b0011) ? 3'd2 :
		(in == 4'b0100) ? 3'd1 :
		(in == 4'b0101) ? 3'd2 :
		(in == 4'b0110) ? 3'd2 :
		(in == 4'b0111) ? 3'd3 :
		(in == 4'b1000) ? 3'd1 :
		(in == 4'b1001) ? 3'd2 :
		(in == 4'b1010) ? 3'd2 :
		(in == 4'b1011) ? 3'd3 :
		(in == 4'b1100) ? 3'd2 :
		(in == 4'b1101) ? 3'd3 :
		(in == 4'b1110) ? 3'd3 :
		3'd4;
endmodule // one_count4

module one_count9(input [8:0] in, output [3:0] out);
   
   wire [2:0] o0, o1;
   
   one_count4 m0 (in[3:0], o0);
   one_count4 m1 (in[7:4], o1);

   assign out = {3'd0,in[8]} + {1'd0,o1} + {1'd0,o0};

endmodule

// -----------------------------------------------------------------------------
// Source file: rtl/sudoku_search.v
// -----------------------------------------------------------------------------
module sudoku_search(/*AUTOARG*/
   // Outputs
   outGrid, done, error,
   // Inputs
   clk, rst, start, inGrid
   );
   parameter LG_DEPTH = 6;
   localparam DEPTH = 1 << LG_DEPTH;
   
   input clk;
   input rst;
   input start;
   
   input [728:0] inGrid;
   output [728:0] outGrid;
   output 	  done;
   output 	  error;
   

   reg [4:0] 	  r_state, n_state;
   reg [31:0] 	  r_stack_pos, t_stack_pos;
   reg [31:0] 	  t_stack_addr;

   
   reg 		  t_write_stack, t_read_stack;
   reg 		  t_clr, t_start;
   reg [6:0] 	  r_minIdx, t_minIdx;
   reg [8:0] 	  r_cell, t_cell;
   wire [3:0] 	  w_ffs;
   wire [8:0] 	  w_ffs_mask;
   
      
   reg [728:0] 	  r_board, n_board;
   wire [728:0]   w_stack_out;
   reg [728:0] 	  t_stack_in;


   wire [728:0]   s_outGrid;
   wire [8:0] 	  s_outGrid2d[80:0];
   wire [728:0]   w_nGrid;
   
   reg [8:0] 	  t_outGrid2d[80:0];

   reg 		  t_done, r_done;
   reg 		  t_error, r_error;
   
   assign done = r_done;
   assign error = r_error;
   
   genvar 	  i;

   assign outGrid = s_outGrid;
         
   wire [6:0] 	  w_minIdx, w_unsolvedCells;
   wire [3:0] 	  w_minPoss;
   wire 	  w_allDone, w_anyChanged, w_anyError, w_timeOut;

   generate
      for(i=0;i<81;i=i+1)
	begin: unflatten
	   assign s_outGrid2d[i] = s_outGrid[(9*(i+1))-1:9*i];
	end
   endgenerate

   integer j;
   always@(*)
     begin
	for(j=0;j<81;j=j+1)
	  begin
	     t_outGrid2d[j] = s_outGrid2d[j];
	  end
	t_outGrid2d[r_minIdx] = w_ffs_mask;
     end

   generate
      for(i=0;i<81;i=i+1)
	begin: flatten
	   assign w_nGrid[(9*(i+1)-1):(9*i)] = t_outGrid2d[i];
	end
   endgenerate
   

   
   find_first_set ffs0
     (
      .in(r_cell),
      .out(w_ffs),
      .out_mask(w_ffs_mask)
      );
   
   always@(*)
     begin
	t_clr = 1'b0;
	t_start = 1'b0;
		
	t_write_stack = 1'b0;
	t_read_stack = 1'b0;
	t_stack_in = 729'd0;
	
	t_stack_pos = r_stack_pos;
	t_stack_addr = t_stack_pos;
	
	n_state = r_state;
	n_board = r_board;

	t_minIdx = r_minIdx;
	t_cell = r_cell;

	t_done = r_done;
	t_error = r_error;
	
	case(r_state)
	  /* copy input to stack */
	  5'd0:
	    begin
	       if(start)
		 begin
		    t_write_stack = 1'b1;
		    t_stack_pos = r_stack_pos + 32'd1;
		    n_state = 5'd1;
		    t_stack_in = inGrid;
		 end
	       else
		 begin
		    n_state = 5'd0;
		 end
	    end
	  /* pop state off the top of the stack,
	   * data valid in the next state */
	  5'd1:
	    begin
	       t_read_stack = 1'b1;
	       //$display("reading new board");
	       
	       t_stack_pos = r_stack_pos - 32'd1;
	       t_stack_addr = t_stack_pos;
	       	       
	       n_state = (r_stack_pos == 32'd0) ? 5'd31 : 5'd2;
	    end
	  /* data out of stack ram is 
	   * valid .. save in register */
	  5'd2:
	    begin
	       t_clr = 1'b1;
	       
	       n_board = w_stack_out;
	       n_state = 5'd3;
	    end

	  /* stack read..valid in r_state */
	  5'd3:
	    begin
	       t_start = 1'b1;
	       n_state = 5'd4;
	       if(r_board === 729'dx)
		 begin
		    $display("GOT X!");
		    $display("%b", r_board);
		    
		    $finish();
		 end
	    end
	  
	  /* wait for exact cover
	   * hardware to complete */
	  5'd4:
	    begin
	       if(w_allDone)
		 begin
		    n_state = w_anyError ? 5'd1 : 5'd8;
		 end
	       else if(w_timeOut)
		 begin
		    t_minIdx = w_minIdx;
		    n_state = 5'd5;
		 end
	       else
		 begin
		    n_state = 5'd4;
		 end
	    end // case: 5'd4

	  5'd5:
	    begin
	       /* extra cycle */
	       t_cell = s_outGrid2d[r_minIdx];
	       n_state = 5'd6;
	    end
	  
	  /* timeOut -> push next states onto the stack */
	  5'd6:
	    begin
	       /* if min cell is zero, the board is incorrect
		* and we have no need to push successors */
	       if(r_cell == 9'd0)
		 begin
		    n_state = 5'd1;
		 end
	       else
		 begin
		    t_cell = r_cell & (~w_ffs_mask);
	       	    t_stack_in = w_nGrid;
		    t_write_stack = 1'b1;
		    t_stack_pos = r_stack_pos + 32'd1;
	            n_state = (t_stack_pos == (DEPTH-1)) ? 5'd31: 5'd7;
		 end
	    end

	  5'd7:
	    begin
	       n_state = (r_cell == 9'd0) ? 5'd1 : 5'd6;
	    end

	  5'd8:
	    begin
	       t_done = 1'b1;
	       n_state = 5'd8;
	    end
	  
	  5'd31:
	    begin
	       n_state = 5'd31;
	       t_error = 1'b1;
	    end
	  
	  default:
	    begin
	       n_state = 5'd0;
	    end
	endcase // case (r_state)
     end
   

   always@(posedge clk)
     begin
	if(rst)
	  begin
	     r_board <= 729'd0;
	     r_state <= 5'd0;
	     r_stack_pos <= 32'd0;
	     r_minIdx <= 7'd0;
	     r_cell <= 9'd0;
	     r_done <= 1'b0;
	     r_error <= 1'b0;
	  end
	else
	  begin
	     r_board <= n_board;
	     r_state <= n_state;
	     r_stack_pos <= t_stack_pos;
	     r_minIdx <= t_minIdx;
	     r_cell <= t_cell;
	     r_done <= t_done;
	     r_error <= t_error;
	  end
     end // always@ (posedge clk)

   /* stack ram */
 
   stack_ram #(.LG_DEPTH(LG_DEPTH)) stack0 
     (
      // Outputs
      .d_out		(w_stack_out),
      // Inputs
      .clk		(clk),
      .w			(t_write_stack),
      .addr		(t_stack_addr[(LG_DEPTH-1):0] ),
      .d_in		(t_stack_in)
      );

   
   sudoku cover0 (
		  // Outputs
		  .outGrid		(s_outGrid),
		  .unsolvedCells	(w_unsolvedCells),
		  .timeOut		(w_timeOut),
		  .allDone		(w_allDone),
		  .anyChanged		(w_anyChanged),
		  .anyError		(w_anyError),
		  .minIdx		(w_minIdx),
		  .minPoss		(w_minPoss),
		  // Inputs
		  .clk			(clk),
		  .rst			(rst),
		  .clr			(t_clr),
		  .start		(t_start),
		  .inGrid		(r_board)
		  );
         
endmodule // sudoku_search



module stack_ram(/*AUTOARG*/
   // Outputs
   d_out,
   // Inputs
   clk, w, addr, d_in
   );
   parameter LG_DEPTH = 4;
   localparam DEPTH = 1 << LG_DEPTH;
   
   input clk;
   input w;
   input [(LG_DEPTH-1):0] addr;
   
   input [728:0] d_in;
   output [728:0] d_out;

   reg [728:0] 	  r_dout;
   assign d_out = r_dout;

   reg [728:0] 	  mem [(DEPTH-1):0];
      
   always@(posedge clk)
     begin
	if(w)
	  begin
	     if(d_in == 729'dx)
	       begin
		  $display("pushing X!!!");
		  $finish();
	       end
	     mem[addr] <= d_in;
	  end
	else
	  begin
	     r_dout <= mem[addr];
	  end
     end // always@ (posedge clk)

endmodule // stack_ram

module find_first_set(out,out_mask,in);
   input [8:0] in;
   output [3:0] out;
   output [8:0] out_mask;
   
   genvar 	i;
   wire [8:0] 	w_fz;
   wire [8:0] 	w_fzo;
   assign w_fz[0] = in[0];
   assign w_fzo[0] = in[0];

   assign out = (w_fzo == 9'd1) ? 4'd1 :
		(w_fzo == 9'd2) ? 4'd2 :
		(w_fzo == 9'd4) ? 4'd3 :
		(w_fzo == 9'd8) ? 4'd4 :
		(w_fzo == 9'd16) ? 4'd5 :
		(w_fzo == 9'd32) ? 4'd6 :
		(w_fzo == 9'd64) ? 4'd7 :
		(w_fzo == 9'd128) ? 4'd8 :
		(w_fzo == 9'd256) ? 4'd9 :
		4'hf;

   assign out_mask = w_fzo;
      
   generate
      for(i=1;i<9;i=i+1)
	begin : www
	   fz fzN (
		   .out(w_fzo[i]),
		   .f_out(w_fz[i]),
		   .f_in(w_fz[i-1]),
		   .in(in[i])
		   );
	end
   endgenerate
endmodule // find_first_set

module fz(/*AUTOARG*/
   // Outputs
   out, f_out,
   // Inputs
   f_in, in
   );
   input f_in;
   input in;
   output out;
   output f_out;
   
   assign out = in & (~f_in);
   assign f_out = f_in | in;
   
endmodule
   


module checkCorrect(/*AUTOARG*/
   // Outputs
   y,
   // Inputs
   in
   );
   input [80:0] in;
      
   output 	y;
   
   wire [8:0] 	grid1d [8:0];
   wire [8:0] 	w_set;
   
   
   wire [8:0] w_gridOR = 
	      grid1d[0] |
	      grid1d[1] |
	      grid1d[2] |
	      grid1d[3] |
	      grid1d[4] |
	      grid1d[5] |
	      grid1d[6] |
	      grid1d[7] |
	      grid1d[8];
   
   wire       w_allSet = (w_gridOR == 9'b111111111);
   wire       w_allAssign = (w_set == 9'b111111111);
   
   assign y = w_allSet & w_allAssign;

   genvar     i;
   
   generate
      for(i=0;i<9;i=i+1)
	begin: unflatten
	   assign grid1d[i] = in[(9*(i+1))-1:9*i];
	   assign w_set[i] = 	
			     (grid1d[i] == 9'd1)   | 
			     (grid1d[i] == 9'd2)   | 
			     (grid1d[i] == 9'd4)   |
			     (grid1d[i] == 9'd8)   | 
			     (grid1d[i] == 9'd16)  | 
			     (grid1d[i] == 9'd32)  |
			     (grid1d[i] == 9'd64)  |
			     (grid1d[i] == 9'd128) | 
			     (grid1d[i] == 9'd256);
	end
   endgenerate
endmodule // correct
