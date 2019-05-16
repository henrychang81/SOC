// ============================================================================
// Copyright (C) 2014 NARLabs CIC. All rights reserved.
//
// Designer : Cheng Chunwen
// Date     : 2014.05.03
// Ver      : 3.04.a
// Module   : filter_core
// Func     : 
//            1.) Input linebuffer, depth=4
//            2.) Output linebuffer, depth=1
//            3.) RGB2Y transform
//            4.) Implement 3x3 sobel filter alg.
//
// History  :
//   Date         Version   Description
//   2014.06.04   1.00.a    Create
//   2014.07.24   3.02.a    First release
//   2014.11.17   3.04.a    Add input rgb2y_bypass, filter_bypass
//   2016.03.27   4.0       Modify AXI_STREAM Interface signals for compliant with VDMA 6.2(Vivado 2015.01)
//
// ============================================================================

`timescale 1 ns / 1 ps

//`define BYPASS_EN

module filter_core #(
        parameter IMG_H = 1080 ,  // image height
        parameter IMG_W = 1920 ,  // image width
        parameter TBITS = 32 ,
        parameter TBYTE = 4
) (

        output wire [26-1:0]    trig_0 ,
        output wire [49-1:0]    ila_data ,

        //
        input  wire             rgb2y_bypass ,
        input  wire             filter_bypass ,

        //
        input  wire [TBITS-1:0] isif_data_dout ,  // {last,user,strb,data}
        input  wire [TBYTE-1:0] isif_strb_dout ,
        input  wire [1 - 1:0]   isif_last_dout ,  // eol
        input  wire [1 - 1:0]   isif_user_dout ,  // sof
        input  wire             isif_empty_n ,
        output wire             isif_read ,

        //
        output wire [TBITS-1:0] osif_data_din ,
        output wire [TBYTE-1:0] osif_strb_din ,
        output wire [1 - 1:0]   osif_last_din ,
        output wire [1 - 1:0]   osif_user_din ,
        input  wire             osif_full_n ,
        output wire             osif_write ,

        //
        input  wire             rst ,
        input  wire             clk
);  // filter_core


// ============================================================================
// Parameter
//
localparam NN = 3 - 1;   // linereg depth 3x3 filter 
localparam MM = 4;       // linebuf depth
localparam LINEDLY = 3;  // total line delay
localparam DBITS = 8;
localparam ASIZE = IMG_W;
localparam ABITS = 11;

// state
localparam [4:0]        ZERO   = 5'b00001;  // rx first line
localparam [4:0]        ONE    = 5'b00010;  // rx-only
localparam [4:0]        TWO    = 5'b00100;  // rx-tx
localparam [4:0]        THREE  = 5'b01000;  // tx-only
localparam [4:0]        FOUR   = 5'b10000;  // trna


// ============================================================================
// local signal
//
reg     [4:0]           state;
reg     [4:0]           next;

// pixel control
reg                     io_stop;
reg     [ABITS - 1:0]   io_pcnt;  // is & os
reg     [ABITS - 1:0]   io_line;

wire                    end_of_line;
wire                    end_of_frame;

// ISIF
wire                    s_is_empty_n;
wire                    s_is_read;
wire                    s_is_xfer;

// OSIF
wire                    s_os_full_n;
wire                    s_os_write;
wire                    s_os_xfer;
reg                     r_os_write;
reg                     r_os_dlast;
reg                     r_os_tuser;


// i_linebuf
wire                    iram_write;
reg     [ABITS - 1:0]   iram_wpcnt;
/*
reg     [ABITS - 1:0]   iram_wline;
*/
reg     [MM - 1 :0]     iram_wsel;

wire    [ABITS - 1:0]   iram_waddr;
wire    [MM - 1 :0]     iram_wce;
wire    [MM - 1 :0]     iram_we;
wire    [DBITS*MM - 1:0]iram_d;
wire    [DBITS - 1:0]   iram_0_d = iram_d[DBITS - 1:0];

wire                    iram_read;
reg     [ABITS - 1:0]   iram_rpcnt;
/*
reg     [ABITS - 1:0]   iram_rline;
reg     [MM - 1 :0]     iram_rsel;
*/

wire    [ABITS - 1:0]   iram_raddr;
wire    [MM - 1 :0]     iram_rce;
wire    [DBITS - 1:0]   iram_0_q;
wire    [DBITS - 1:0]   iram_1_q;
wire    [DBITS - 1:0]   iram_2_q;
wire    [DBITS - 1:0]   iram_3_q;

// linereg
reg                     iram_read_d1;
reg                     iram_read_d2;
reg     [DBITS - 1:0]   lineram_0_q;
reg     [DBITS - 1:0]   lineram_1_q;
reg     [DBITS - 1:0]   lineram_2_q;

// 3x3 filter
localparam  SOBEL_H = 200;
localparam  SOBEL_L = 100;

//wire                    filter_bypass = 0;
// p0
wire                    filter_e_p0;
reg     [DBITS - 1:0]   r_Pix_0_0 , r_Pix_0_1 , r_Pix_0_2;
reg     [DBITS - 1:0]   r_Pix_1_0 , r_Pix_1_1 , r_Pix_1_2;
reg     [DBITS - 1:0]   r_Pix_2_0 , r_Pix_2_1 , r_Pix_2_2;

wire    [DBITS+3 - 1:0] s_sum_Gx;
wire    [DBITS+3 - 1:0] s_sum_Gy;
wire    [DBITS+2 - 1:0] s_abs_Gx;
wire    [DBITS+2 - 1:0] s_abs_Gy;
wire    [DBITS+3 - 1:0] s_sum_edge;
wire    [DBITS+0 - 1:0] s_val_edge;
wire    [DBITS+0 - 1:0] s_out_edge;

// p1
reg                     filter_e_p1;
reg     [DBITS+3 - 1:0] sum_Gx;
reg     [DBITS+3 - 1:0] sum_Gy;
// p2
reg                     filter_e_p2;
reg     [DBITS+3 - 1:0] sum_edge;
// p3
reg                     filter_e_p3;
reg     [DBITS+0 - 1:0] val_edge;
// p4
reg                     filter_e_p4;
reg     [DBITS+0 - 1:0] out_edge;


// o_linebuf
wire                    oram_write;
reg     [ABITS - 1:0]   oram_wpcnt;
reg     [ABITS - 1:0]   oram_wline;
wire                    oram_read;
/*
reg     [ABITS - 1:0]   oram_rpcnt;
reg     [ABITS - 1:0]   oram_rline;
*/

wire    [ABITS - 1:0]   oram_waddr;
wire    [1 - 1 :0]      oram_wce;
wire    [1 - 1 :0]      oram_we;
wire    [DBITS*1 - 1:0] oram_d;

wire    [ABITS - 1:0]   oram_raddr;
wire    [1 - 1 :0]      oram_rce;
wire    [DBITS - 1:0]   oram_0_q;



// ============================================================================
// Instantiation
//
filter_linebuf_i
#(
        . MM ( MM ) ,
        . DBITS ( DBITS ) ,
        . ABITS ( ABITS ) ,
        . ASIZE ( IMG_W ) )
filter_linebuf_i_U
(
        . RST ( rst ) ,
        . CLK ( clk ) ,
        . AA ( iram_waddr ) ,
        . CEA ( iram_wce ) ,
        . WEA ( iram_we ) ,
        . D ( iram_d ) ,
        . AB ( iram_raddr ) ,
        . CEB ( iram_rce ) ,
        . Q ( {iram_3_q , iram_2_q , iram_1_q , iram_0_q} )
);  // u_filter_linebuf_i


filter_linebuf_o
#(
        . MM ( 1 ) ,
        . DBITS ( DBITS ) ,
        . ABITS ( ABITS ) ,
        . ASIZE ( IMG_W ) )
filter_linebuf_o_U
(
        . RST ( rst ) ,
        . CLK ( clk ) ,
        . AA ( oram_waddr ) ,
        . CEA ( oram_wce ) ,
        . WEA ( oram_we ) ,
        . D ( oram_d ) ,
        . AB ( oram_raddr ) ,
        . CEB ( oram_rce ) ,
        . Q ( oram_0_q )
);  // u_filter_linebuf_o


// ============================================================================
// Body
//

`ifdef BYPASS_EN

wire                    xfer_en;

assign s_is_empty_n = isif_empty_n;
assign s_os_full_n = osif_full_n;
assign xfer_en = s_is_empty_n & s_os_full_n;
assign s_is_xfer = 0;
assign s_os_xfer = 0;

assign isif_read = xfer_en;

assign osif_write = xfer_en;

assign osif_data_din = isif_data_dout;
assign osif_strb_din = isif_strb_dout;
assign osif_last_din = isif_last_dout;
assign osif_user_din = isif_user_dout;

`else

// ============================================================================
// ISIF
//
assign s_is_empty_n = isif_empty_n;

assign s_is_read = (state==ZERO || state==ONE) ? (~io_stop & s_is_empty_n) :
                     state==TWO ? (~io_stop & s_is_empty_n & s_os_full_n) : 0;

assign s_is_xfer = s_is_read;

assign isif_read = s_is_read;


// ============================================================================
// OSIF
//
assign s_os_full_n = osif_full_n;

assign s_os_write = (state==TWO) ? (~io_stop & s_is_empty_n & s_os_full_n) :
                     (state==THREE) ? (~io_stop & s_os_full_n) : 0;

assign s_os_xfer = s_os_write;

assign osif_write = r_os_write;

assign osif_data_din = {8'hff, oram_0_q , oram_0_q , oram_0_q};
assign osif_strb_din = 4'b1111;
assign osif_last_din = r_os_dlast;
assign osif_user_din = r_os_tuser;  // 1'b0

`endif  //BYPASS_EN

always @(posedge clk)
    if (rst)
        r_os_write <= 0;
    else
        r_os_write <= s_os_write;

// r_os_dlast
always @(posedge clk)
    if (rst)
        r_os_dlast <= 0;
    else if ((io_pcnt == IMG_W - 1) && s_os_xfer)
        r_os_dlast <= 0;
    else if ((io_pcnt == IMG_W - 2) && s_os_xfer)
        r_os_dlast <= 1;
    else
        r_os_dlast <= r_os_dlast;

// r_os_tuser
always @(posedge clk)
    if (rst)
        r_os_tuser <= 0;
    else if (r_os_tuser & s_os_xfer)
        r_os_tuser <= 0;
    else if (isif_user_dout && s_is_empty_n)
        r_os_tuser <= 1;
    else
        r_os_tuser <= r_os_tuser;


// ============================================================================
// RGB2Y 3 stage pipe
// p3
wire                    rgb2y_e_p3;
wire    [DBITS - 1:0]   s_outy;

filter_rgb2y
#(
        . DBITS ( DBITS ) )
filter_rgb2y_U
(
        . rgb2y_bypass ( rgb2y_bypass ) ,

        . rgb2y_e_p0 ( s_is_xfer ) ,
        . rgb2y_d_p0 ( isif_data_dout[DBITS*3 - 1:0] ) ,

        . rgb2y_e_p3 ( rgb2y_e_p3 ) ,
        . s_outy ( s_outy ) ,

       . clk ( clk ) ,
       . rst ( rst )
);  // filter_rgb2y_U


// ============================================================================
// ilinebuf
//
assign iram_write = rgb2y_e_p3 || (state == THREE && s_os_xfer);  // s_is_xfer_p3

assign iram_waddr = iram_wpcnt;

assign iram_wce = (io_line == 0) ? {MM{1'b1}} : iram_wsel;

assign iram_we = {MM{iram_write}};

// iram_3 store the last input line data
assign iram_d = (state == THREE) ? {MM{iram_3_q}} : {MM{s_outy[DBITS - 1:0]}};

assign iram_read = (io_line >= NN && s_is_xfer) || (state == THREE && s_os_xfer);

assign iram_raddr = io_pcnt;

assign iram_rce = {MM{iram_read}};


// iram_wpcnt
always @(posedge clk)
    if (rst)
        iram_wpcnt <= 0;
    else if (state == FOUR)
        iram_wpcnt <= 0;
    else if (io_pcnt == IMG_W+8 - 1)
        iram_wpcnt <= 0;
    else if (iram_write)  // s_is_xfer_p3  || s_os_xfer_d1
        iram_wpcnt <= iram_wpcnt + 1;
    else
        iram_wpcnt <= iram_wpcnt;

/*
// iram_wline
always @(posedge clk)
    if (rst)
        iram_wline <= 0;
    else if (state == FOUR)
        iram_wline <= 0;
    else if (io_pcnt == IMG_W+8 - 1)
        iram_wline <= iram_wline + 1;
    else
        iram_wline <= iram_wline;
*/

// iram_wsel
always @(posedge clk)
    if (rst)
        iram_wsel <= 1;
    else if (state == FOUR)
        iram_wsel <= 1;
    else if (io_pcnt == IMG_W+8 - 1)
        iram_wsel <= {iram_wsel[MM - 2:0] , iram_wsel[MM - 1]};
    else
        iram_wsel <= iram_wsel;

// iram_rpcnt: 0-IMG_W
always @(posedge clk)
    if (rst)
        iram_rpcnt <= 0;
    else if (state == FOUR)
        iram_rpcnt <= 0;
    else if (io_pcnt == IMG_W+8 - 1)  // end_of_line
        iram_rpcnt <= 0;
  //else if (iram_rpcnt == IMG_W)
  //    iram_rpcnt <= iram_rpcnt + 1;
    else if (iram_read_d1)
        iram_rpcnt <= iram_rpcnt + 1;
    else
        iram_rpcnt <= iram_rpcnt;

/*
// iram_rline
always @(posedge clk)
    if (rst)
        iram_rline <= 0;
    else if (state == FOUR)
        iram_rline <= 0;
    else if (io_pcnt == IMG_W+8 - 1)
        iram_rline <= iram_rline + 1;
    else
        iram_rline <= iram_rline;
*/


// ============================================================================
// 3x3 linereg
//
// p0
// lineram transform
always @(*) begin
    case (io_line[1:0])
        2'd0 :
            { lineram_0_q , lineram_1_q , lineram_2_q } <= { iram_1_q , iram_2_q , iram_3_q };  // iram_read_d1
        2'd1 :
            { lineram_0_q , lineram_1_q , lineram_2_q } <= { iram_2_q , iram_3_q , iram_0_q };
        2'd2 :
            { lineram_0_q , lineram_1_q , lineram_2_q } <= { iram_3_q , iram_0_q , iram_1_q };
        2'd3 :
            { lineram_0_q , lineram_1_q , lineram_2_q } <= { iram_0_q , iram_1_q , iram_2_q };
        default:
            { lineram_0_q , lineram_1_q , lineram_2_q } <= { iram_0_q , iram_1_q , iram_2_q };
    endcase  // io_line[1:0]
end

// p0
always @(posedge clk)
    if (rst) begin
      //filter_e_p0 <= 0;
        { r_Pix_0_0 , r_Pix_0_1 , r_Pix_0_2 } <= 0;
        { r_Pix_1_0 , r_Pix_1_1 , r_Pix_1_2 } <= 0;
        { r_Pix_2_0 , r_Pix_2_1 , r_Pix_2_2 } <= 0;
    end
    else begin
      //filter_e_p0 <= iram_read_d1;

        if (iram_rpcnt == 0 & iram_read_d1) begin
            { r_Pix_0_0 , r_Pix_0_1 , r_Pix_0_2 } <= { lineram_0_q , lineram_0_q , lineram_0_q };
            { r_Pix_1_0 , r_Pix_1_1 , r_Pix_1_2 } <= { lineram_1_q , lineram_1_q , lineram_1_q };
            { r_Pix_2_0 , r_Pix_2_1 , r_Pix_2_2 } <= { lineram_2_q , lineram_2_q , lineram_2_q };
        end
        else if (iram_rpcnt >= IMG_W & iram_read_d1) begin
            { r_Pix_0_0 , r_Pix_0_1 , r_Pix_0_2 } <= { r_Pix_0_1 , r_Pix_0_2 , r_Pix_0_2 };
            { r_Pix_1_0 , r_Pix_1_1 , r_Pix_1_2 } <= { r_Pix_1_1 , r_Pix_1_2 , r_Pix_1_2 };
            { r_Pix_2_0 , r_Pix_2_1 , r_Pix_2_2 } <= { r_Pix_2_1 , r_Pix_2_2 , r_Pix_2_2 };
        end
        else if (iram_read_d1) begin
            { r_Pix_0_0 , r_Pix_0_1 , r_Pix_0_2 } <= { r_Pix_0_1 , r_Pix_0_2 , lineram_0_q };
            { r_Pix_1_0 , r_Pix_1_1 , r_Pix_1_2 } <= { r_Pix_1_1 , r_Pix_1_2 , lineram_1_q };
            { r_Pix_2_0 , r_Pix_2_1 , r_Pix_2_2 } <= { r_Pix_2_1 , r_Pix_2_2 , lineram_2_q };
        end
        else begin
            { r_Pix_0_0 , r_Pix_0_1 , r_Pix_0_2 } <= { r_Pix_0_0 , r_Pix_0_1 , r_Pix_0_2 };
            { r_Pix_1_0 , r_Pix_1_1 , r_Pix_1_2 } <= { r_Pix_1_0 , r_Pix_1_1 , r_Pix_1_2 };
            { r_Pix_2_0 , r_Pix_2_1 , r_Pix_2_2 } <= { r_Pix_2_0 , r_Pix_2_1 , r_Pix_2_2 };
        end
    end

always @(posedge clk)
    if (rst)
        {iram_read_d2 , iram_read_d1} <= 0;
    else
        {iram_read_d2 , iram_read_d1} <= {(iram_read_d1 && iram_rpcnt!=0) , (iram_read || io_pcnt == IMG_W)};

// ============================================================================
//Median Filter
wire    [DBITS - 1:0]   MedianValue;
reg     [DBITS - 1:0]   MedianValue_core;

wire    [DBITS - 1:0]   MF_Pix_0_0,MF_Pix_0_1,MF_Pix_0_2;
wire    [DBITS - 1:0]   MF_Pix_1_0,MF_Pix_1_1,MF_Pix_1_2;
wire    [DBITS - 1:0]   MF_Pix_2_0,MF_Pix_2_1,MF_Pix_2_2;

assign MF_Pix_0_0 = r_Pix_0_0;
assign MF_Pix_0_1 = r_Pix_0_1;
assign MF_Pix_0_2 = r_Pix_0_2;
assign MF_Pix_1_0 = r_Pix_1_0;
assign MF_Pix_1_1 = r_Pix_1_1;
assign MF_Pix_1_2 = r_Pix_1_2;
assign MF_Pix_2_0 = r_Pix_2_0;
assign MF_Pix_2_1 = r_Pix_2_1;
assign MF_Pix_2_2 = r_Pix_2_2;


Median_Filter#(
    .DBITS ( DBITS ))
Median_filter_i(
	.RST( RST ),
	.CLK( CLK ),
	.Pix_0_0( MF_Pix_0_0 ),
	.Pix_0_1( MF_Pix_0_1 ),
	.Pix_0_2( MF_Pix_0_2 ),
	.Pix_1_0( MF_Pix_1_0 ),
	.Pix_1_1( MF_Pix_1_1 ),
	.Pix_1_2( MF_Pix_1_2 ),
	.Pix_2_0( MF_Pix_2_0 ),
	.Pix_2_1( MF_Pix_2_1 ),
	.Pix_2_2( MF_Pix_2_2 ),
	.MedianValue( MedianValue )
);

//Median_Filter
always @(posedge clk)
    if (rst)
	    MedianValue_core <= 0;
	else 
	    MedianValue_core <= MedianValue;

// ============================================================================
// filter formula
//
//      [ P_0_0 P_0_1 P_0_2 ]   [ -1 -2 -1 ]
// Gx = [ P_1_0 P_1_1 P_1_2 ] . [  0  0  0 ]
//      [ P_2_0 P_2_1 P_2_2 ]   [  1  2  1 ]
//
//      [ P_0_0 P_0_1 P_0_2 ]   [ -1  0  1 ]
// Gy = [ P_1_0 P_1_1 P_1_2 ] . [ -2  0  2 ]
//      [ P_2_0 P_2_1 P_2_2 ]   [ -1  0  1 ]
//
// edge = |Gx| + |Gy| if (SOBEL_L <= edge <= SOBEL_H)
//
// edge = (edge < SOBEL_L) ? 0 : (edge > SOBEL_H) ? 255 : edge
//
// p0
assign filter_e_p0 = iram_read_d2;
/*
assign s_sum_Gx = filter_bypass ? {3'b0 , r_Pix_1_1} :
                  ( {3'b0 , r_Pix_0_2} - {3'b0 , r_Pix_0_0} +
                    {2'b0 , r_Pix_1_2 , 1'b0} - {2'b0 , r_Pix_1_0 , 1'b0} +
                    {3'b0 , r_Pix_2_2} - {3'b0 , r_Pix_2_0} );

assign s_sum_Gy = filter_bypass ? {3'b0 ,  r_Pix_1_1} :
                  ( {3'b0 , r_Pix_0_0} - {3'b0 , r_Pix_2_0} +
                    {2'b0 , r_Pix_0_1 , 1'b0} - {2'b0 , r_Pix_2_1 , 1'b0} +
                    {3'b0 , r_Pix_0_2} - {3'b0 , r_Pix_2_2} );
*/
assign s_sum_Gx = filter_bypass ? {3'b0 , r_Pix_1_1} :
                                                        ( {3'b0 , MedianValue_core }  );
	
assign s_sum_Gy = filter_bypass ? {3'b0 , r_Pix_1_1} :
                                                        ({2'b0 , r_Pix_1_1 , 1'b0} - {3'b0 , r_Pix_1_2} - {3'b0 , r_Pix_1_0} +
                                                         {2'b0 , r_Pix_1_1 , 1'b0} - {3'b0 , r_Pix_0_1} + {3'b0 , r_Pix_2_1} );
                                                        
                                                        
// p1
assign s_abs_Gx = sum_Gx[DBITS+3 - 1] ? (~sum_Gx[DBITS+2 - 1:0] + 1) : sum_Gx[DBITS+2 - 1:0];

assign s_abs_Gy = sum_Gy[DBITS+3 - 1] ? (~sum_Gy[DBITS+2 - 1:0] + 1) : sum_Gy[DBITS+2 - 1:0];

assign s_sum_edge = s_abs_Gx[DBITS+2 - 1:0] + s_abs_Gy[DBITS+2 - 1:0];

// p2
// val = (val>255) ? 0 : (255 - val)
assign s_val_edge = filter_bypass ? sum_edge[DBITS+1 - 1:1] :
                     sum_edge[DBITS+3 - 1] ? 0 :
                     sum_edge[DBITS+2 - 1] ? 0 :
		     sum_edge[DBITS+1 - 1] ? 0 : ~sum_edge[DBITS - 1:0];

// p3
assign s_out_edge = filter_bypass ? val_edge :
                     (val_edge > SOBEL_H) ? 255 :
                      (val_edge < SOBEL_L) ? 0 : val_edge;

// p1
always @(posedge clk)
    if (rst) begin
        filter_e_p1 <= 0;
        sum_Gx <= 0;
        sum_Gy <= 0;
    end
    else begin
        filter_e_p1 <= filter_e_p0;

        if (filter_e_p0) begin
            sum_Gx <= s_sum_Gx;
            sum_Gy <= s_sum_Gy;
        end
        else begin
            sum_Gx <= sum_Gx;
            sum_Gy <= sum_Gy;
        end
    end

// p2
always @(posedge clk)
    if (rst) begin
        filter_e_p2 <= 0;
        sum_edge <= 0;
    end
    else begin
        filter_e_p2 <= filter_e_p1;

        if (filter_e_p1)
            sum_edge <= s_sum_edge;
        else
            sum_edge <= sum_edge;
    end

// p3
always @(posedge clk)
    if (rst) begin
        filter_e_p3 <= 0;
        val_edge <= 0;
    end
    else begin
        filter_e_p3 <= filter_e_p2;

        if (filter_e_p2) begin
            val_edge <= s_val_edge;
        end
        else begin
            val_edge <= val_edge;
        end
    end

// p4
always @(posedge clk)
    if (rst) begin
        filter_e_p4 <= 0;
        out_edge <= 0;
    end
    else begin
        filter_e_p4 <= filter_e_p3;

        if (filter_e_p3) begin
            out_edge <= s_out_edge;
        end
        else begin
            out_edge <= out_edge;
        end
    end


// ============================================================================
// olinebuf
//
assign oram_write = filter_e_p3;

assign oram_waddr = oram_wpcnt;

assign oram_wce = oram_write;

assign oram_we = oram_write;

assign oram_d = s_out_edge;

assign oram_read = s_os_xfer;

assign oram_raddr = io_pcnt;

assign oram_rce = oram_read;

// oram_wpcnt
always @(posedge clk)
    if (rst)
        oram_wpcnt <= 0;
    else if (state == FOUR)
        oram_wpcnt <= 0;
    else if (io_pcnt == IMG_W+8 - 1)
        oram_wpcnt <= 0;
    else if (oram_write)
        oram_wpcnt <= oram_wpcnt + 1;
    else
        oram_wpcnt <= oram_wpcnt;

/*
// oram_wline
always @(posedge clk)
    if (rst)
        oram_wline <= 0;
    else if (state == FOUR)
        oram_wline <= 0;
    else if (io_pcnt == IMG_W+8 - 1)
        oram_wline <= oram_wline + 1;
    else
        oram_wline <= oram_wline;

// oram_rpcnt
always @(posedge clk)
    if (rst)
        oram_rpcnt <= 0;
    else if (state == FOUR)
        oram_rpcnt <= 0;
    else if (oram_read)  // s_os_xfer
        oram_rpcnt <= (oram_rpcnt == IMG_W - 1) ? 0 : oram_rpcnt + 1;
    else
        oram_rpcnt <= oram_rpcnt;

// oram_rline
always @(posedge clk)
    if (rst)
        oram_rline <= 0;
    else if (state == FOUR)
        oram_rline <= 0;
    else if (oram_read & oram_rpcnt== IMG_W - 1)  // s_os_xfer
        oram_rline <= oram_rline + 1;
    else
        oram_rline <= oram_rline;
*/


// ============================================================================
// state
//
assign end_of_line = (io_pcnt == IMG_W+8 - 1);

assign end_of_frame = (io_pcnt == IMG_W+8 - 1) & (io_line == IMG_H + LINEDLY - 1);

// io pixel control
always @(posedge clk)
    if (rst)
        io_stop <= 0;
    else if (io_pcnt == IMG_W+8 - 1)
        io_stop <= 0;
    else if ((s_is_xfer | (state==THREE & s_os_xfer)) & (io_pcnt == IMG_W - 1))
        io_stop <= 1;
    else
        io_stop <= io_stop;

// io_pcnt
always @(posedge clk)
    if (rst)
        io_pcnt <= 0;
    else if (state == FOUR)
        io_pcnt <= 0;
    else if (io_pcnt == IMG_W+8 - 1) 
        io_pcnt <= 0;
    else if (io_pcnt >= IMG_W)
        io_pcnt <= io_pcnt + 1;
    else if (s_is_xfer || (state==THREE & s_os_xfer))
        io_pcnt <= io_pcnt + 1;
    else
        io_pcnt <= io_pcnt;

// io_line
always @(posedge clk)
    if (rst)
        io_line <= 0;
    else if (state==FOUR)
        io_line <= 0;
    else if (io_pcnt == IMG_W+8 - 1)
        io_line <= io_line + 1;
    else
        io_line <= io_line;


always @(posedge clk)
    if (rst)
        state <= ZERO;
    else
        state <= next;

// next
always @(*) begin
    case (state)
        ZERO:  // line = 0
            if (io_line == 0 && io_pcnt == IMG_W+8 - 1)
                next = ONE;
            else
                next = ZERO;
        ONE:  // line = 1
            if (io_line == LINEDLY - 1&& io_pcnt == IMG_W+8 - 1)
                next = TWO;
            else
                next = ONE;
        TWO:  // line = LINEDLY ~ IMG_H-1
            if (io_line == IMG_H - 1 && io_pcnt == IMG_W+8 - 1)
                next = THREE;
            else
                next = TWO;
        THREE:  // line = IMG_H ~ IMG_H+LINEDLY-1
            if (io_line == IMG_H + LINEDLY - 1 && io_pcnt == IMG_W+8 - 1)
                next = FOUR;
            else
                next = THREE;
        FOUR:  // line = IMG_H + LINEDLY
            next = ZERO;
        default:
            next = ZERO;
    endcase  // state
end


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
parameter C_NUM_OF_TRIGPORTS  = 1;
parameter C_TRIG0_SIZE        = 26;
parameter C_DATA0_SIZE        = 49;

wire            ila_clk;
wire    [35:0]  control_0;
//wire    [C_TRIG0_SIZE-1:0]       trig_0;
//wire    [C_DATA0_SIZE-1:0]       ila_data;

assign ila_clk = clk;

assign ila_data = { r_os_dlast,  s_os_write, s_os_full_n, s_is_read , s_is_empty_n, state, io_line, io_pcnt , //48:18
                     iram_wce, iram_we, iram_1_q[7:0] , iram_0_q[7:0]};  //17:0

assign trig_0 = { s_os_xfer, s_is_xfer , io_line, io_pcnt};

/*
  icon ICON_inst (
      . CONTROL0 ( control_0 )
  );

  ila ILA_inst (
      . CONTROL ( control_0 ) ,
      . CLK     ( ila_clk ) ,
      . DATA    ( ila_data ) ,
      . TRIG0   ( trig_0 )
  );
*/
endmodule  // filter_core


module filter_rgb2y #(
        parameter DBITS = 8
) (
        input  wire                 rgb2y_bypass ,

        input  wire                 rgb2y_e_p0 ,
        input  wire [DBITS*3 - 1:0] rgb2y_d_p0 ,

        output reg                  rgb2y_e_p3 ,
        output wire [DBITS - 1:0]   s_outy ,

        input  wire                 clk ,
        input  wire                 rst
);  //filter_rgb2y

// ============================================================================
// local signal
//
// RGB2Y 3 stage pipe
// p0
//wire                    rgb2y_e_p0;
//wire    [DBITS*3 - 1:0] rgb2y_d_p0;

// p1
reg                     rgb2y_e_p1;
reg     [DBITS*3 - 1:0] rgb2y_d_p1;

wire    [DBITS - 1:0]   pix_y;
wire    [DBITS - 1:0]   pix_c;
wire    [DBITS - 1:0]   pix_b;
wire    [DBITS - 1:0]   pix_g;
wire    [DBITS - 1:0]   pix_r;
wire    [DBITS*2 - 1:0] s_y_yb;
wire    [DBITS*2 - 1:0] s_y_yg;
wire    [DBITS*2 - 1:0] s_y_yr;

// p2
reg                     rgb2y_e_p2;
reg     [DBITS*2 - 1:0] r_y_yb;  // 16
reg     [DBITS*2 - 1:0] r_y_yg;
reg     [DBITS*2 - 1:0] r_y_yr;

wire    [DBITS*2+2 - 1:0]s_tmp_yrygyb;  // 18
wire    [DBITS+2 - 1:0] s_sum_yrygyb;  // 10

// p3
//reg                     rgb2y_e_p3;
reg     [DBITS+2 - 1:0] r_sum_yrygyb;  // 10
wire    [DBITS+2 - 1:0] s_tmp_outy;
//wire    [DBITS - 1:0]   s_outy;

// p4, nouse for debug
reg                     rgb2y_e_p4;
reg     [DBITS - 1:0]   r_outy;

// ============================================================================
// Body
//

// ============================================================================
// RGB2Y
//
// Y =      ( 0.257 * R) + ( 0.504 * G) + ( 0.098 * B) + 16
// U = Cb = (-0.148 * R) + (-0.291 * G) + ( 0.439 * B) + 128
// V = Cr = ( 0.439 * R) + (-0.368 * G) + (-0.071 * B) + 128
//
// Y = CLIP(( (  66 * R + 129 * G +  25 * B + 128) >> 8) +  16) 
// U = CLIP(( ( -38 * R -  74 * G + 112 * B + 128) >> 8) + 128) 
// V = CLIP(( ( 112 * R -  94 * G -  18 * B + 128) >> 8) + 128)
//

// p0
//assign rgb2y_e_p0 = s_is_xfer;

//assign rgb2y_d_p0 = isif_data_dout[DBITS*3 - 1:0];

// p1
assign pix_y = rgb2y_d_p1[08 - 1:00];

assign pix_c = rgb2y_d_p1[16 - 1:08];

assign pix_b = rgb2y_d_p1[08 - 1:00];

assign pix_g = rgb2y_d_p1[16 - 1:08];

assign pix_r = rgb2y_d_p1[24 - 1:16];

// s_y_yb = 25 * b
assign s_y_yb = rgb2y_bypass ? {pix_y , 8'b0} : {3'b0 , pix_b * 5'd25};

// s_y_yg = 129 * g
assign s_y_yg = rgb2y_bypass ? 0 : {1'b0, pix_g, 7'b0} + {8'b0, pix_g};

// s_y_yr = 66 * r
assign s_y_yr = rgb2y_bypass ? 0 : {2'b0, pix_r, 6'b0} + {7'b0, pix_r, 1'b0};

// p2
assign s_tmp_yrygyb = r_y_yr + r_y_yg + r_y_yb + 128;

assign s_sum_yrygyb = s_tmp_yrygyb[18 - 1:8];

// p3
assign s_tmp_outy = rgb2y_bypass ? r_sum_yrygyb : (r_sum_yrygyb + 16);

assign s_outy = s_tmp_outy[10 - 1] ? 8'hff :
                 s_tmp_outy[9 - 1] ? 8'hff : s_tmp_outy[8 - 1:0];

// p1
always @(posedge clk)
    if (rst) begin
        rgb2y_e_p1 <= 0;
        rgb2y_d_p1 <= 0;
    end
    else begin
        rgb2y_e_p1 <= rgb2y_e_p0;

        if (rgb2y_e_p0)
            rgb2y_d_p1 <= rgb2y_d_p0;
        else
            rgb2y_d_p1 <= rgb2y_d_p1;
    end

// p2
always @(posedge clk)
    if (rst) begin
        rgb2y_e_p2 <= 0;
        r_y_yb <= 0;
        r_y_yg <= 0;
        r_y_yr <= 0;
    end
    else begin
        rgb2y_e_p2 <= rgb2y_e_p1;

        if (rgb2y_e_p1) begin
            r_y_yb <= s_y_yb;
            r_y_yg <= s_y_yg;
            r_y_yr <= s_y_yr;
        end
        else begin
            r_y_yb <= r_y_yb;
            r_y_yg <= r_y_yg;
            r_y_yr <= r_y_yr;
        end
    end

// p3
always @(posedge clk)
    if (rst) begin
        rgb2y_e_p3 <= 0;
        r_sum_yrygyb <= 0;
    end
    else begin
        rgb2y_e_p3 <= rgb2y_e_p2;

        if (rgb2y_e_p2)
            r_sum_yrygyb <= s_sum_yrygyb;
        else
            r_sum_yrygyb <= r_sum_yrygyb;
    end

// p4
always @(posedge clk)
    if (rst) begin
        rgb2y_e_p4 <= 0;
        r_outy <= 0;
    end
    else begin
        rgb2y_e_p4 <= rgb2y_e_p3;

        if (rgb2y_e_p3)
            r_outy <= s_outy;
        else
            r_outy <= r_outy;
    end

endmodule  // filter_rgb2y

