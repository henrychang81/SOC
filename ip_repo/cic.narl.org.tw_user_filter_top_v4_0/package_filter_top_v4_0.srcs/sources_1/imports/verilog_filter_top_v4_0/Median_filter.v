// ============================================================================
// Designer : Chang Chih Wei
// Date     : 2017.07.11
// Ver      : 1.00.a
// Func     : Median Filter with Comparator
//
// ============================================================================
`timescale 1ns / 1ps
module Median_Filter(
	RST,
	CLK,
	Pix_0_0,
	Pix_0_1,
	Pix_0_2,
	Pix_1_0,
	Pix_1_1,
	Pix_1_2,
	Pix_2_0,
	Pix_2_1,
	Pix_2_2,
	MedianValue
);

parameter DBITS = 8;

input RST;
input CLK;
input [DBITS-1:0] Pix_0_0,Pix_0_1,Pix_0_2;
input [DBITS-1:0] Pix_1_0,Pix_1_1,Pix_1_2;
input [DBITS-1:0] Pix_2_0,Pix_2_1,Pix_2_2;
 
wire [DBITS-1:0] first_row_max , first_row_mid , first_row_min ;
wire [DBITS-1:0] second_row_max, second_row_mid, second_row_min;
wire [DBITS-1:0] third_row_max , third_row_mid , third_row_min ;
wire [DBITS-1:0] min_in_Compare_max, mid_in_Compare_mid, max_in_Compare_min;

output [DBITS-1:0] MedianValue;

//Comparator 1 , compare first row
Comparator#(
	.DBITS ( DBITS ) )
Compare_first_row(
	.CLK( CLK ),
	.FIRST( Pix_0_0 ),
	.SECOND( Pix_0_1 ),
	.THIRD( Pix_0_2 ),
	.o_MAX( first_row_max ),
	.o_MID( first_row_mid ),
	.o_MIN( first_row_min )
);
//Comparator 2 , compare second row
Comparator#(
	.DBITS ( DBITS ) )
Compare_second_row(
	.CLK( CLK ),
	.FIRST( Pix_1_0 ),
	.SECOND( Pix_1_1 ),
	.THIRD( Pix_1_2 ),
	.o_MAX( second_row_max ),
	.o_MID( second_row_mid ),
	.o_MIN( second_row_min )
);
//Comparator 3 , compare third row
Comparator#(
	.DBITS ( DBITS ) )
Compare_third_row(
	.CLK( CLK ),
	.FIRST( Pix_2_0 ),
	.SECOND( Pix_2_1 ),
	.THIRD( Pix_2_2 ),
	.o_MAX( third_row_max ),
	.o_MID( third_row_mid ),
	.o_MIN( third_row_min )
);
//Comparator 4 , get the min value from 3 max
Comparator#(
	.DBITS ( DBITS ) )
Compare_max(
	.CLK( CLK ),
	.FIRST( first_row_max ),
	.SECOND( second_row_max ),
	.THIRD( third_row_max ),
	.o_MAX(),
	.o_MID(),
	.o_MIN( min_in_Compare_max )
);
//Comparator 5 , get the mid value from 3 mid
Comparator#(
	.DBITS ( DBITS ) )
Compare_mid(
	.CLK( CLK ),
	.FIRST( first_row_mid ),
	.SECOND( second_row_mid ),
	.THIRD( third_row_mid ),
	.o_MAX(),
	.o_MID( mid_in_Compare_mid ),
	.o_MIN()
);
//Comparator 6 , get the max value from 3 min
Comparator#(
	.DBITS ( DBITS ) )
Compare_min(
	.CLK(CLK),
	.FIRST( first_row_min ),
	.SECOND( second_row_min ),
	.THIRD( third_row_min ),
	.o_MAX( max_in_Compare_min ),
	.o_MID(),
	.o_MIN()
);
//Comparator 7 , compare 3 value : min_in_max , mid_in_mid , max_in_min
Comparator#(
	.DBITS ( DBITS ) )
Compare_Median(
	.CLK( CLK ),
	.FIRST( min_in_Compare_max ),
	.SECOND( mid_in_Compare_mid ),
	.THIRD( max_in_Compare_min ),
	.o_MAX(),
	.o_MID( MedianValue ),
	.o_MIN()
);
endmodule


// ============================================================================
`timescale 1ns / 1ps
module Comparator(
		CLK,FIRST,SECOND,THIRD,o_MAX,o_MID,o_MIN);


parameter DBITS = 8;
parameter CV = 3;

input                    CLK;
input        [DBITS-1:0] FIRST,SECOND,THIRD;
output  wire [DBITS-1:0] o_MAX,o_MID,o_MIN;
reg          [CV*DBITS-1:0] Com_result;

always @(posedge CLK)
begin
	if ( FIRST > SECOND > THIRD ) begin
		Com_result <= { FIRST, SECOND, THIRD };	
	end
	else if ( FIRST > THIRD > SECOND ) begin 
		Com_result <= { FIRST, THIRD, SECOND };	
	end
	else if ( SECOND > FIRST > THIRD ) begin
		Com_result <= { SECOND, FIRST, THIRD };
	end
	else if ( SECOND > THIRD > FIRST ) begin
		Com_result <= { SECOND, THIRD, FIRST };
	end
	else if ( THIRD > FIRST > SECOND ) begin
		Com_result <= { THIRD, FIRST, SECOND };	
	end
	else begin
		Com_result <= { THIRD, SECOND, FIRST };
	end
end

assign o_MAX = Com_result[DBITS*3 - 1:DBITS*2] ; // [23:16], it's max
assign o_MID = Com_result[DBITS*2 - 1:DBITS*1] ; // [15:8] , it's mid
assign o_MIN = Com_result[DBITS*1 - 1:DBITS*0] ; // [7:0]  , it's min


endmodule