// ============================================================================
// Designer : Cheng Chunwen
// Create   : 2014.05.03
// Ver      : 3.04.a
// Func     : Sobel Filter with AXI_VDMA
// History  :
//   2016.03.30 v4.0 : Revise axi_stream interface signals for compliant with VDMA 6.2 in Vivado 2015.01
// ============================================================================

`timescale 1 ns / 1 ps

//`define  DEBUG_EN

module filter_top
#(
        parameter IMG_H = 1080 ,  // image height
        parameter IMG_W = 1920 ,  // image width
        parameter TBITS = 32 ,
        parameter TBYTE = 4
) (

`ifdef DEBUG_EN
        output wire [26-1:0]    trig_0 ,
        output wire [49-1:0]    ila_data ,
`endif

        input  wire             rgb2y_bypass ,
        input  wire             filter_bypass ,

        input  wire             S_AXIS_MM2S_TVALID,
        output wire             S_AXIS_MM2S_TREADY,
        input  wire [TBITS-1:0] S_AXIS_MM2S_TDATA,
        input  wire [TBYTE-1:0] S_AXIS_MM2S_TKEEP,
        input  wire [1-1:0]     S_AXIS_MM2S_TLAST,
      //input  wire [1-1:0]     S_AXIS_MM2S_TUSER,

        output wire             M_AXIS_S2MM_TVALID,
        input  wire             M_AXIS_S2MM_TREADY,
        output wire [TBITS-1:0] M_AXIS_S2MM_TDATA,
        output wire [TBYTE-1:0] M_AXIS_S2MM_TKEEP,
        output wire [1-1:0]     M_AXIS_S2MM_TLAST,  // EOL
      //output wire [1-1:0]     M_AXIS_S2MM_TUSER,  // SOF

        input  wire             S_AXIS_MM2S_ACLK,
        input  wire             M_AXIS_S2MM_ACLK,
        input  wire             aclk,
        input  wire             aresetn
);

parameter RESET_ACTIVE_LOW = 1;

wire [TBITS - 1:0] isif_data_dout;
wire [TBYTE - 1:0] isif_strb_dout;
wire [1 - 1:0]     isif_last_dout;
wire [1 - 1:0]     isif_user_dout;
wire               isif_empty_n;
wire               isif_read;

wire [TBITS - 1:0] osif_data_din;
wire [TBYTE - 1:0] osif_strb_din;
wire               osif_full_n;
wire               osif_write;
wire [1 - 1:0]     osif_last_din;
wire [1 - 1:0]     osif_user_din;

wire ap_rst;


// ============================================================================
// Instantiation
//

localparam C_NUM_OF_TRIGPORTS  = 1;
localparam C_TRIG0_SIZE        = 26;
localparam C_DATA0_SIZE        = 49;

//output    [C_TRIG0_SIZE-1:0]       trig_0;
//output    [C_DATA0_SIZE-1:0]       ila_data;
//wire      [C_TRIG0_SIZE-1:0]       trig_0;
//wire      [C_DATA0_SIZE-1:0]       ila_data;

filter_core
#(
        .IMG_H (1080) ,
        .IMG_W (1920) ,
        .TBITS (32) ,
        .TBYTE (4)
)
filter_core_U (

`ifdef DEBUG_EN
        .trig_0 ( trig_0 ) ,
        .ila_data ( ila_data ) ,
`endif
        //
        .rgb2y_bypass ( rgb2y_bypass ) ,
        .filter_bypass ( filter_bypass ) ,

        //
        .isif_data_dout ( isif_data_dout ) ,
        .isif_strb_dout ( isif_strb_dout ) ,
        .isif_last_dout ( isif_last_dout ) ,
        .isif_user_dout ( isif_user_dout ) ,
        .isif_empty_n ( isif_empty_n ) ,
        .isif_read ( isif_read ) ,
        //
        .osif_data_din ( osif_data_din ) ,
        .osif_strb_din ( osif_strb_din ) ,
        .osif_last_din ( osif_last_din ) ,
        .osif_user_din ( osif_user_din ) ,
        .osif_full_n ( osif_full_n ) ,
        .osif_write ( osif_write ) ,

        //
        .rst ( ap_rst ) ,
        .clk ( aclk )
);  // filter_core_U


INPUT_STREAM_if
#(
        .TBITS (TBITS) ,
        .TBYTE (TBYTE)
)
INPUT_STREAM_if_U (

        .ACLK ( S_AXIS_MM2S_ACLK ) ,
        .ARESETN ( aresetn ) ,
        .TVALID ( S_AXIS_MM2S_TVALID ) ,
        .TREADY ( S_AXIS_MM2S_TREADY ) ,
        .TDATA ( S_AXIS_MM2S_TDATA ) ,
        .TKEEP ( S_AXIS_MM2S_TKEEP ) ,
        .TLAST ( S_AXIS_MM2S_TLAST ) ,
      //.TUSER ( S_AXIS_MM2S_TUSER ) ,
        .TUSER ( 1'b0 ) ,

        .isif_data_dout ( isif_data_dout ) ,
        .isif_strb_dout ( isif_strb_dout ) ,
        .isif_last_dout ( isif_last_dout ) ,
        .isif_user_dout ( isif_user_dout ) ,
        .isif_empty_n ( isif_empty_n ) ,
        .isif_read ( isif_read )
);  // input_stream_if_U

OUTPUT_STREAM_if
#(
        .TBITS (TBITS) ,
        .TBYTE (TBYTE)
)
OUTPUT_STREAM_if_U (

        .ACLK ( M_AXIS_S2MM_ACLK ) ,
        .ARESETN ( aresetn ) ,
        .TVALID ( M_AXIS_S2MM_TVALID ) ,
        .TREADY ( M_AXIS_S2MM_TREADY ) ,
        .TDATA ( M_AXIS_S2MM_TDATA ) ,
        .TKEEP ( M_AXIS_S2MM_TKEEP ) ,
        .TLAST ( M_AXIS_S2MM_TLAST ) ,
      //.TUSER ( M_AXIS_S2MM_TUSER ) ,
        .TUSER (  ) ,

        .osif_data_din ( osif_data_din ) ,
        .osif_strb_din ( osif_strb_din ) ,
        .osif_last_din ( osif_last_din ) ,
        .osif_user_din ( osif_user_din ) ,
        .osif_full_n ( osif_full_n ) ,
        .osif_write ( osif_write )
);  // output_stream_if_U

filter_rst_if #(
        .RESET_ACTIVE_LOW ( RESET_ACTIVE_LOW ) )
filter_rst_if_U(
        .dout ( ap_rst ) ,
        .din ( aresetn ) );  // filter_rst_if_U

endmodule  // filter_top
