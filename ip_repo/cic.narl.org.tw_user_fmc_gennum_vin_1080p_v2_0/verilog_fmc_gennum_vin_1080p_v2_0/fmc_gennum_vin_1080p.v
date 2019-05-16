// ============================================================================
// Copyright (C) 2014 NARLabs CIC. All rights reserved.
//
// Designer : Cheng Chunwen
//
// Module   : fmc_gennum_vin_1080p
//
// Date     : 2014.09.22
//
// Ver      : 1.01.a
//
// Func     :
//      Receive SDI fmc_gennum VHF video signals
//
// History  :
//   Date         Version   Description
//   2014.09.22   1.00.a    First release
//   2014.10.24   2.00.a    1.) Change videl_d = {Y , C} for style 3
//                          2.) Add input port vdma_clk, output port vdma_fs
// ============================================================================
//
//      in     |  tim861  |  vblank
// -----------------------------------
//  out tim861 |  regout  |  mode=1
//  out vblank |    X     |  regout
//
//


`define _1080p

module fmc_gennum_vin_1080p (
        //
        output  wire                    ila_clk ,
        output  wire    [17 - 1:0]      trig_0 ,
        output  wire    [30 - 1:0]      ila_data ,

        //
        input   wire            dly_rstn ,
        input   wire            sel_in_ch1 ,
        input   wire            yydebug ,

        //
        input   wire            vdma_clk ,
        output  reg             vdma_fs ,

        //
        output  wire            vclk ,
        output  wire            video_vblank ,
        output  wire            video_hblank ,
        output  wire            video_de ,
        output  wire    [31:0]  video_d ,

        input   wire    [19:0]  p2data ,
        input   wire            p2clk ,
        input   wire            p2H ,  // status[2]
        input   wire            p2V ,  // status[1]
        input   wire            p2F ,  // status[0]

        input   wire    [19:0]  p1data ,
        input   wire            p1clk ,
        input   wire            p1H ,
        input   wire            p1V ,
        input   wire            p1F
);  // fmc_gennum_vin_1080p


///////////////////////////////////////////////////////////////////////////////
// input parsing
///////////////////////////////////////////////////////////////////////////////
//wire            sel_in_ch1 = 0;
wire            sel_in_tim861 = 0;

wire            pclk;
wire            pV;
wire            pH;
wire            pF;
wire    [19:0]  pdata;
wire    [7:0]   lumina;  // Y
wire    [7:0]   chroma;  // CbCr

assign pclk  = sel_in_ch1 ? p1clk  : p2clk;
assign pV    = sel_in_ch1 ? p1V    : p2V;
assign pH    = sel_in_ch1 ? p1H    : p2H;
assign pF    = sel_in_ch1 ? p1F    : p2F;
assign pdata = sel_in_ch1 ? p1data : p2data;

assign lumina = pdata[19:12];
assign chroma = pdata[9:2];


///////////////////////////////////////////////////////////////////////////////
// video clock
///////////////////////////////////////////////////////////////////////////////
wire            vclkz;
wire            vclkx1;
wire            vclkx2;


BUFG vclk_BUFG_inst (
        . O ( vclk ) ,  // 1-bit output: Clock output
        . I ( vclkz )   // 1-bit input: Clock input
);


PLLE2_BASE #(
        . BANDWIDTH ( "OPTIMIZED" ) ,   // OPTIMIZED, HIGH, LOW
        . CLKFBOUT_MULT ( 12 ) ,        // Multiply value for all CLKOUT, (2-64)
        . CLKFBOUT_PHASE ( 0.0 ) ,      // Phase offset in degrees of CLKFB, (-360.000-360.000).
        . CLKIN1_PERIOD ( 13.468 ) ,    // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        . DIVCLK_DIVIDE ( 1 ) ,         // Master division value, (1-56)
        // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
        . CLKOUT0_DIVIDE ( 12 ) ,
        . CLKOUT1_DIVIDE ( 12 ) ,
        . CLKOUT2_DIVIDE ( 6 ) ,
        . CLKOUT3_DIVIDE ( 12 ) ,
        . CLKOUT4_DIVIDE ( 12 ) ,
        . CLKOUT5_DIVIDE ( 12 ) ,
        // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
        . CLKOUT0_DUTY_CYCLE ( 0.5 ) ,
        . CLKOUT1_DUTY_CYCLE ( 0.5 ) ,
        . CLKOUT2_DUTY_CYCLE ( 0.5 ) ,
        . CLKOUT3_DUTY_CYCLE ( 0.5 ) ,
        . CLKOUT4_DUTY_CYCLE ( 0.5 ) ,
        . CLKOUT5_DUTY_CYCLE ( 0.5 ) ,
        // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        . CLKOUT0_PHASE ( 180.0 ) ,
        . CLKOUT1_PHASE ( 0.0 ) ,
        . CLKOUT2_PHASE ( 0.0 ) ,
        . CLKOUT3_PHASE ( 0.0 ) ,
        . CLKOUT4_PHASE ( 0.0 ) ,
        . CLKOUT5_PHASE ( 0.0 ) ,
        . REF_JITTER1 ( 0.001 ) ,      // Reference input jitter in UI, (0.000-0.999).
        . STARTUP_WAIT ( "FALSE" )     // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
)
PLLE2_BASE_inst (
        // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        . CLKOUT0 ( vclkz ) ,
        . CLKOUT1 ( vclkx1 ) ,
        . CLKOUT2 ( vclkx2 ) ,
        . CLKOUT3 (  ) ,
        . CLKOUT4 (  ) ,
        . CLKOUT5 (  ) ,
        // Feedback Clocks: 1-bit (each) output: Clock feedback ports
        . CLKFBOUT ( clkfb2 ) ,  // 1-bit output: Feedback clock
        // Status Port: 1-bit (each) output: PLL status ports
        . LOCKED (  ) ,          // 1-bit output: LOCK
        // Clock Input: 1-bit (each) input: Clock input
        . CLKIN1 ( pclk ) ,      // 1-bit input: Input clock
        // Control Ports: 1-bit (each) input: PLL control ports
        . PWRDWN ( 1'b0 ) ,      // 1-bit input: Power-down
        . RST ( 1'b0 ) ,         // 1-bit input: Reset
        // Feedback Clocks: 1-bit (each) input: Clock feedback ports
        . CLKFBIN ( clkfb2 )     // 1-bit input: Feedback clock
);


///////////////////////////////////////////////////////////////////////////////
// latch input signals
///////////////////////////////////////////////////////////////////////////////
reg             rV , r0V , r1V;
reg             rH , r0H , r1H;
reg             rF , r0F , r1F;
reg     [15:0]  rdata , r0data , r1data;


always @(posedge vclk) rV    <= pV;
always @(posedge vclk) rH    <= pH;
always @(posedge vclk) rF    <= pF;
always @(posedge vclk) rdata <= {chroma , lumina};  // style2

always @(posedge vclk) r0V    <= rV;
always @(posedge vclk) r0H    <= rH;
always @(posedge vclk) r0F    <= rF;
always @(posedge vclk) r0data <= rdata;

always @(posedge vclk) r1V    <= r0V;
always @(posedge vclk) r1H    <= r0H;
always @(posedge vclk) r1F    <= sel_in_tim861 ? r0F : (~r0V & ~r0H);
always @(posedge vclk) r1data <= r0data;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
`ifdef _720p
localparam       h_total = 1650;
localparam       h_size  = 1280;
localparam       h_sync  =   40;
localparam       h_start =  260;
localparam       h_fp    =  110;
localparam       v_total =  750;
localparam       v_size  =  720;
localparam       v_sync  =    5;
localparam       v_start =   25;
localparam       v_fp    =    5;
`else
localparam       h_total = 2200;
localparam       h_size  = 1920;
localparam       h_sync  =   44;
localparam       h_start =  192;
localparam       h_fp    =   88;
localparam       v_total = 1125;
localparam       v_size  = 1080;
localparam       v_sync  =    5;
localparam       v_start =   41;
localparam       v_fp    =    4;
`endif

reg     [15:0]  hcnt;
reg     [15:0]  vcnt;
reg             h_err = 0;
reg             v_err = 0;


always @(posedge vclk or negedge dly_rstn)
  if (!dly_rstn)
    hcnt <= 0;
  else if (!r0V & r1V)
    hcnt <= 1;
  else
    hcnt <= (hcnt==0) ? 0 :
             (hcnt == h_total) ? 1 : hcnt + 1;

// 1-750
always @(posedge vclk or negedge dly_rstn)
  if (!dly_rstn)
    vcnt <= 0;
  else if (!r0V & r1V)
    vcnt <= 1;
  else
    vcnt <= (vcnt==0) ? 0 :
            ~(hcnt == h_total) ? vcnt :
              (vcnt == v_total) ? 1 : vcnt + 1;

always @(posedge vclk or negedge dly_rstn)
  if (!dly_rstn)
    h_err <= 0;
  else if (vcnt==0)
    h_err <= 0;
  else if (!r0H & r1H & hcnt!=h_total)
    h_err <= 1;
  else
    h_err <= h_err;

always @(posedge vclk or negedge dly_rstn)
  if (!dly_rstn)
    v_err <= 0;
  else if (vcnt==0)
    v_err <= 0;
  else if (!r0V & r1V & vcnt!=v_total)  // 1-720
    v_err <= 1;
  else
    v_err <= v_err;


//////////////////////////////////////////////////////////////////////////////
// generate vdma_fs signals
//////////////////////////////////////////////////////////////////////////////
wire            fs_s;
reg             fs_toggle = 0;


assign fs_s = (hcnt==h_fp) && (vcnt==(v_size+v_fp+v_sync)) ? 1 : 0;


always @(posedge vclk)
  fs_toggle <= fs_s ? ~fs_toggle : fs_toggle;


reg             vdma_fs_toggle_s1 = 'd0;
reg             vdma_fs_toggle_s2 = 'd0;
reg             vdma_fs_toggle_s3 = 'd0;

always @(posedge vdma_clk) begin
  vdma_fs_toggle_s1 <= fs_toggle;
  vdma_fs_toggle_s2 <= vdma_fs_toggle_s1;
  vdma_fs_toggle_s3 <= vdma_fs_toggle_s2;
  vdma_fs <= vdma_fs_toggle_s2 ^ vdma_fs_toggle_s3;
end


//////////////////////////////////////////////////////////////////////////////
// generate output signals
//////////////////////////////////////////////////////////////////////////////
//wire            yydebug = 0;
wire            vsync;
wire            hsync;
wire            de;
reg             rvsync;
reg             rhsync;
reg             rvblank;
reg             rhblank;
reg             rde;
reg     [15:0]  rdout;

//assign vsync = (vcnt>725) & (vcnt<=730) ? 1 : 0;

//assign hsync = (hcnt>110) & (hcnt<=150) ? 1 : 0;

//assign de    = (vcnt>=1) & (vcnt<=720) & (hcnt>370) & (hcnt<=1650) ? 1 : 0;

assign vsync = (vcnt>(v_size+v_fp)) & (vcnt<=(v_size+v_fp+v_sync)) ? 1 : 0;

assign hsync = (hcnt>h_fp) & (hcnt<=(h_fp+h_sync)) ? 1 : 0;

assign de    = (vcnt>=1) & (vcnt<=v_size) & (hcnt>(h_fp+h_start)) & (hcnt<=h_total) ? 1 : 0;

always @(posedge vclk) rvsync <= vsync;

always @(posedge vclk) rhsync <= hsync;

always @(posedge vclk) rvblank <= r1V;

always @(posedge vclk) rhblank <= r1H;

always @(posedge vclk) rde     <= r1F;

always @(posedge vclk) rdout <= yydebug & (vcnt <50)  ? 16'h80EA /*white C:Y*/ :
                                  yydebug & (vcnt <100) ? 16'h8010 /*black C:Y*/ :
                                   yydebug & (vcnt <150) ? (hcnt[0] ? 16'h5A51 : 16'hF051) /*red*/ :
                                    yydebug & (vcnt <200) ? 16'hEA80 /*white Y:C*/ :
                                     yydebug & (vcnt <250) ? {8'h80 , r1data[7:0]} :
                                      r1data;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
assign video_vblank = rvblank;

assign video_hblank = rhblank;

assign video_de = rde;

assign video_d = {16'b0, rdout};


///////////////////////////////////////////////////////////////////////////////
// chipscope
///////////////////////////////////////////////////////////////////////////////
localparam C_NUM_OF_TRIGPORTS  = 1;
localparam C_TRIG0_SIZE        = 17;
localparam C_DATA0_SIZE        = 30;

/*
wire                             ila_clk;
wire    [35:0]                   control_0;
wire    [C_TRIG0_SIZE-1:0]       trig_0;
wire    [C_DATA0_SIZE-1:0]       ila_data;
*/

assign ila_clk = vclkx2;

assign ila_data = { v_err , h_err , r1V , r1H , r1F , rvsync , rhsync , rde , vcnt[10:0] , hcnt[10:0] };

assign trig_0 = { r1V , r1H , r1F , rvsync , rhsync , rde , vcnt[10:0] };

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

endmodule  //fmc_gennum_vin_1080p
