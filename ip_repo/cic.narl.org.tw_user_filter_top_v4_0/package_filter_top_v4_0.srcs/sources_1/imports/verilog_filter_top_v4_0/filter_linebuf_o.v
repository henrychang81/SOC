// ============================================================================
// Designer : Cheng Chunwen
// Date     : 2014.05.03
// Ver      : 1.00.a
// Func     : Sobel Filter with AXI_VDMA
//
// ============================================================================

`timescale 1 ns / 1 ps
module o_lineram (
        CLK, AA, CEA, WEA, D, AB, CEB, Q);

parameter DBITS = 8;
parameter ABITS = 11;
parameter ASIZE = 1920;

input                   CLK;
input [ABITS - 1:0]     AA;
input                   CEA;
input                   WEA;
input [DBITS - 1:0]     D;
input [ABITS - 1:0]     AB;
input                   CEB;
output[DBITS - 1:0]     Q;


(* ram_style = "block" *)reg [DBITS-1:0] ram[ASIZE-1:0];

reg   [DBITS - 1:0] Q;


//assign Q = ram[AB];
always @(posedge CLK)  
begin 
    if (CEB) 
        Q <= ram[AB];
end

always @(posedge CLK)  
begin 
    if (CEA) 
    begin
        if (WEA) 
            ram[AA] <= D; 
    end
end

endmodule  // o_lineram


`timescale 1 ns / 1 ps
module filter_linebuf_o (
    RST,
    CLK,
    AA,
    CEA,
    WEA,
    D ,
    AB,
    CEB,
    Q
);

//
parameter MM = 1;
parameter DBITS = 32'd8;
parameter ABITS = 32'd11;
parameter ASIZE = 32'd1920;

//
input                   RST;
input                   CLK;
input [ABITS - 1:0]     AA;
input [MM - 1:0]        CEA;
input [MM - 1:0]        WEA;
input [DBITS*MM - 1:0]  D;
input [ABITS - 1:0]     AB;
input [MM - 1:0]        CEB;
output[DBITS*MM - 1:0]  Q;

//
o_lineram #(
        .DBITS ( DBITS ) ,
        .ABITS ( ABITS ) ,
        .ASIZE ( ASIZE ) )
o_lineRam_U0 (
    .CLK ( CLK ) ,
    .AA ( AA ) ,
    .CEA ( CEA[0] ) ,
    .WEA ( WEA[0] ) ,
    .D ( D[DBITS*1 - 1:DBITS*0] ) ,
    .AB ( AB ) ,
    .CEB ( CEB[0] ) ,
    .Q ( Q[DBITS*1 - 1:DBITS*0] )
);  // o_lineRam_0

endmodule  // filter_linebuf_o
