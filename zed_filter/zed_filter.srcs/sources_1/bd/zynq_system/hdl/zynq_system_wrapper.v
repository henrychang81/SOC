//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
//Date        : Tue Jul 25 17:16:38 2017
//Host        : CCW-PC running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target zynq_system_wrapper.bd
//Design      : zynq_system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module zynq_system_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    HD_CLK,
    HD_D,
    HD_DE,
    HD_HSYNC,
    HD_VSYNC,
    hd_iic_scl_io,
    hd_iic_sda_io);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output HD_CLK;
  output [15:0]HD_D;
  output HD_DE;
  output HD_HSYNC;
  output HD_VSYNC;
  inout hd_iic_scl_io;
  inout hd_iic_sda_io;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire HD_CLK;
  wire [15:0]HD_D;
  wire HD_DE;
  wire HD_HSYNC;
  wire HD_VSYNC;
  wire hd_iic_scl_i;
  wire hd_iic_scl_io;
  wire hd_iic_scl_o;
  wire hd_iic_scl_t;
  wire hd_iic_sda_i;
  wire hd_iic_sda_io;
  wire hd_iic_sda_o;
  wire hd_iic_sda_t;

  IOBUF hd_iic_scl_iobuf
       (.I(hd_iic_scl_o),
        .IO(hd_iic_scl_io),
        .O(hd_iic_scl_i),
        .T(hd_iic_scl_t));
  IOBUF hd_iic_sda_iobuf
       (.I(hd_iic_sda_o),
        .IO(hd_iic_sda_io),
        .O(hd_iic_sda_i),
        .T(hd_iic_sda_t));
  zynq_system zynq_system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .HD_CLK(HD_CLK),
        .HD_D(HD_D),
        .HD_DE(HD_DE),
        .HD_HSYNC(HD_HSYNC),
        .HD_VSYNC(HD_VSYNC),
        .hd_iic_scl_i(hd_iic_scl_i),
        .hd_iic_scl_o(hd_iic_scl_o),
        .hd_iic_scl_t(hd_iic_scl_t),
        .hd_iic_sda_i(hd_iic_sda_i),
        .hd_iic_sda_o(hd_iic_sda_o),
        .hd_iic_sda_t(hd_iic_sda_t));
endmodule
