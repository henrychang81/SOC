// (c) Copyright 1995-2017 Xilinx, Inc. All rights reserved.
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
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: cic.narl.org.tw:user:filter_top:4.0
// IP Revision: 1

(* X_CORE_INFO = "filter_top,Vivado 2015.2" *)
(* CHECK_LICENSE_TYPE = "zynq_system_filter_top_U_0,filter_top,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module zynq_system_filter_top_U_0 (
  rgb2y_bypass,
  filter_bypass,
  S_AXIS_MM2S_TVALID,
  S_AXIS_MM2S_TREADY,
  S_AXIS_MM2S_TDATA,
  S_AXIS_MM2S_TKEEP,
  S_AXIS_MM2S_TLAST,
  M_AXIS_S2MM_TVALID,
  M_AXIS_S2MM_TREADY,
  M_AXIS_S2MM_TDATA,
  M_AXIS_S2MM_TKEEP,
  M_AXIS_S2MM_TLAST,
  S_AXIS_MM2S_ACLK,
  M_AXIS_S2MM_ACLK,
  aclk,
  aresetn
);

input wire rgb2y_bypass;
input wire filter_bypass;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_MM2S TVALID" *)
input wire S_AXIS_MM2S_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_MM2S TREADY" *)
output wire S_AXIS_MM2S_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_MM2S TDATA" *)
input wire [31 : 0] S_AXIS_MM2S_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_MM2S TKEEP" *)
input wire [3 : 0] S_AXIS_MM2S_TKEEP;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_MM2S TLAST" *)
input wire [0 : 0] S_AXIS_MM2S_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM TVALID" *)
output wire M_AXIS_S2MM_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM TREADY" *)
input wire M_AXIS_S2MM_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM TDATA" *)
output wire [31 : 0] M_AXIS_S2MM_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM TKEEP" *)
output wire [3 : 0] M_AXIS_S2MM_TKEEP;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM TLAST" *)
output wire [0 : 0] M_AXIS_S2MM_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXIS_MM2S_ACLK CLK" *)
input wire S_AXIS_MM2S_ACLK;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M_AXIS_S2MM_ACLK CLK" *)
input wire M_AXIS_S2MM_ACLK;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
input wire aclk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
input wire aresetn;

  filter_top #(
    .IMG_H(1080),
    .IMG_W(1920),
    .TBITS(32),
    .TBYTE(4)
  ) inst (
    .rgb2y_bypass(rgb2y_bypass),
    .filter_bypass(filter_bypass),
    .S_AXIS_MM2S_TVALID(S_AXIS_MM2S_TVALID),
    .S_AXIS_MM2S_TREADY(S_AXIS_MM2S_TREADY),
    .S_AXIS_MM2S_TDATA(S_AXIS_MM2S_TDATA),
    .S_AXIS_MM2S_TKEEP(S_AXIS_MM2S_TKEEP),
    .S_AXIS_MM2S_TLAST(S_AXIS_MM2S_TLAST),
    .M_AXIS_S2MM_TVALID(M_AXIS_S2MM_TVALID),
    .M_AXIS_S2MM_TREADY(M_AXIS_S2MM_TREADY),
    .M_AXIS_S2MM_TDATA(M_AXIS_S2MM_TDATA),
    .M_AXIS_S2MM_TKEEP(M_AXIS_S2MM_TKEEP),
    .M_AXIS_S2MM_TLAST(M_AXIS_S2MM_TLAST),
    .S_AXIS_MM2S_ACLK(S_AXIS_MM2S_ACLK),
    .M_AXIS_S2MM_ACLK(M_AXIS_S2MM_ACLK),
    .aclk(aclk),
    .aresetn(aresetn)
  );
endmodule
