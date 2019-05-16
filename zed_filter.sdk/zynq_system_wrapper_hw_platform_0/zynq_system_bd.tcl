
################################################################
# This is a generated script based on design: zynq_system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source zynq_system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name zynq_system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set hd_iic [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 hd_iic ]

  # Create ports
  set HD_CLK [ create_bd_port -dir O HD_CLK ]
  set HD_D [ create_bd_port -dir O -from 15 -to 0 HD_D ]
  set HD_DE [ create_bd_port -dir O HD_DE ]
  set HD_HSYNC [ create_bd_port -dir O HD_HSYNC ]
  set HD_VSYNC [ create_bd_port -dir O HD_VSYNC ]

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list CONFIG.NUM_MI {1}  ] $axi_mem_intercon

  # Create instance: axi_mem_intercon_1, and set properties
  set axi_mem_intercon_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_1 ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}  ] $axi_mem_intercon_1

  # Create instance: const_gnd_U, and set properties
  set const_gnd_U [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_gnd_U ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {1}  ] $const_gnd_U

  # Create instance: const_vcc_U, and set properties
  set const_vcc_U [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_vcc_U ]
  set_property -dict [ list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}  ] $const_vcc_U

  # Create instance: filter_top_U, and set properties
  set filter_top_U [ create_bd_cell -type ip -vlnv cic.narl.org.tw:user:filter_top:4.0 filter_top_U ]

  # Create instance: filter_vdma_U, and set properties
  set filter_vdma_U [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 filter_vdma_U ]
  set_property -dict [ list CONFIG.c_m_axi_mm2s_data_width {64} CONFIG.c_m_axi_s2mm_data_width {64} CONFIG.c_m_axis_mm2s_tdata_width {32} CONFIG.c_mm2s_max_burst_length {16} CONFIG.c_s2mm_max_burst_length {16} CONFIG.c_use_mm2s_fsync {1} CONFIG.c_use_s2mm_fsync {1}  ] $filter_vdma_U

  # Create instance: hdmitx_U, and set properties
  set hdmitx_U [ create_bd_cell -type ip -vlnv cic.narl.org.tw:user:axi_hdmi_tx:1.0 hdmitx_U ]

  # Create instance: hdmitx_clkgen_U, and set properties
  set hdmitx_clkgen_U [ create_bd_cell -type ip -vlnv cic.narl.org.tw:user:axi_clkgen:3.0 hdmitx_clkgen_U ]

  # Create instance: hdmitx_iic_U, and set properties
  set hdmitx_iic_U [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 hdmitx_iic_U ]

  # Create instance: hdmitx_vdma_U, and set properties
  set hdmitx_vdma_U [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 hdmitx_vdma_U ]
  set_property -dict [ list CONFIG.c_include_s2mm {0} CONFIG.c_m_axi_mm2s_data_width {64} CONFIG.c_m_axis_mm2s_tdata_width {64} CONFIG.c_mm2s_max_burst_length {16} CONFIG.c_use_mm2s_fsync {1}  ] $hdmitx_vdma_U

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_EN_CLK0_PORT {1} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_EN_RST1_PORT {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {150} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_USE_S_AXI_HP1 {1} CONFIG.preset {ZedBoard}  ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {5}  ] $processing_system7_0_axi_periph

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create instance: rst_processing_system7_0_142M, and set properties
  set rst_processing_system7_0_142M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_142M ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_mem_intercon_1_M00_AXI [get_bd_intf_pins axi_mem_intercon_1/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP1]
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net filter_top_U_M_AXIS_S2MM [get_bd_intf_pins filter_top_U/M_AXIS_S2MM] [get_bd_intf_pins filter_vdma_U/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net filter_vdma_U_M_AXIS_MM2S [get_bd_intf_pins filter_top_U/S_AXIS_MM2S] [get_bd_intf_pins filter_vdma_U/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net filter_vdma_U_M_AXI_MM2S [get_bd_intf_pins axi_mem_intercon_1/S00_AXI] [get_bd_intf_pins filter_vdma_U/M_AXI_MM2S]
  connect_bd_intf_net -intf_net filter_vdma_U_M_AXI_S2MM [get_bd_intf_pins axi_mem_intercon_1/S01_AXI] [get_bd_intf_pins filter_vdma_U/M_AXI_S2MM]
  connect_bd_intf_net -intf_net hdmitx_iic_U_IIC [get_bd_intf_ports hd_iic] [get_bd_intf_pins hdmitx_iic_U/IIC]
  connect_bd_intf_net -intf_net hdmitx_vdma_U_M_AXIS_MM2S [get_bd_intf_pins hdmitx_U/m_axis_mm2s] [get_bd_intf_pins hdmitx_vdma_U/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net hdmitx_vdma_U_M_AXI_MM2S [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins hdmitx_vdma_U/M_AXI_MM2S]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins hdmitx_iic_U/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins hdmitx_clkgen_U/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins hdmitx_U/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins hdmitx_vdma_U/S_AXI_LITE] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M04_AXI [get_bd_intf_pins filter_vdma_U/S_AXI_LITE] [get_bd_intf_pins processing_system7_0_axi_periph/M04_AXI]

  # Create port connections
  connect_bd_net -net const_gnd_s [get_bd_pins const_gnd_U/dout] [get_bd_pins filter_top_U/filter_bypass]
  connect_bd_net -net const_vcc_s [get_bd_pins const_vcc_U/dout] [get_bd_pins filter_top_U/rgb2y_bypass]
  connect_bd_net -net hdmitx_U_hdmi_16_data [get_bd_ports HD_D] [get_bd_pins hdmitx_U/hdmi_16_data]
  connect_bd_net -net hdmitx_U_hdmi_16_data_e [get_bd_ports HD_DE] [get_bd_pins hdmitx_U/hdmi_16_data_e]
  connect_bd_net -net hdmitx_U_hdmi_16_hsync [get_bd_ports HD_HSYNC] [get_bd_pins hdmitx_U/hdmi_16_hsync]
  connect_bd_net -net hdmitx_U_hdmi_16_vsync [get_bd_ports HD_VSYNC] [get_bd_pins hdmitx_U/hdmi_16_vsync]
  connect_bd_net -net hdmitx_U_hdmi_out_clk [get_bd_ports HD_CLK] [get_bd_pins hdmitx_U/hdmi_out_clk]
  connect_bd_net -net hdmitx_U_m_axis_mm2s_fsync [get_bd_pins filter_vdma_U/mm2s_fsync] [get_bd_pins filter_vdma_U/s2mm_fsync] [get_bd_pins hdmitx_U/m_axis_mm2s_fsync] [get_bd_pins hdmitx_U/m_axis_mm2s_fsync_ret] [get_bd_pins hdmitx_vdma_U/mm2s_fsync]
  connect_bd_net -net hdmitx_clkgen_U_clk [get_bd_pins hdmitx_U/hdmi_clk] [get_bd_pins hdmitx_clkgen_U/clk]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins filter_vdma_U/s_axi_lite_aclk] [get_bd_pins hdmitx_U/s_axi_aclk] [get_bd_pins hdmitx_clkgen_U/S_AXI_ACLK] [get_bd_pins hdmitx_iic_U/s_axi_aclk] [get_bd_pins hdmitx_vdma_U/s_axi_lite_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_mem_intercon_1/ACLK] [get_bd_pins axi_mem_intercon_1/M00_ACLK] [get_bd_pins axi_mem_intercon_1/S00_ACLK] [get_bd_pins axi_mem_intercon_1/S01_ACLK] [get_bd_pins filter_top_U/M_AXIS_S2MM_ACLK] [get_bd_pins filter_top_U/S_AXIS_MM2S_ACLK] [get_bd_pins filter_top_U/aclk] [get_bd_pins filter_vdma_U/m_axi_mm2s_aclk] [get_bd_pins filter_vdma_U/m_axi_s2mm_aclk] [get_bd_pins filter_vdma_U/m_axis_mm2s_aclk] [get_bd_pins filter_vdma_U/s_axis_s2mm_aclk] [get_bd_pins hdmitx_U/m_axis_mm2s_clk] [get_bd_pins hdmitx_vdma_U/m_axi_mm2s_aclk] [get_bd_pins hdmitx_vdma_U/m_axis_mm2s_aclk] [get_bd_pins processing_system7_0/FCLK_CLK1] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP1_ACLK] [get_bd_pins rst_processing_system7_0_142M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_CLK2 [get_bd_pins hdmitx_clkgen_U/ref_clk] [get_bd_pins processing_system7_0/FCLK_CLK2]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net processing_system7_0_FCLK_RESET1_N [get_bd_pins processing_system7_0/FCLK_RESET1_N] [get_bd_pins rst_processing_system7_0_142M/ext_reset_in]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins filter_vdma_U/axi_resetn] [get_bd_pins hdmitx_U/s_axi_aresetn] [get_bd_pins hdmitx_clkgen_U/S_AXI_ARESETN] [get_bd_pins hdmitx_iic_U/s_axi_aresetn] [get_bd_pins hdmitx_vdma_U/axi_resetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
  connect_bd_net -net rst_processing_system7_0_142M_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins axi_mem_intercon_1/ARESETN] [get_bd_pins rst_processing_system7_0_142M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_142M_peripheral_aresetn [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_mem_intercon_1/M00_ARESETN] [get_bd_pins axi_mem_intercon_1/S00_ARESETN] [get_bd_pins axi_mem_intercon_1/S01_ARESETN] [get_bd_pins filter_top_U/aresetn] [get_bd_pins rst_processing_system7_0_142M/peripheral_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces filter_vdma_U/Data_MM2S] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces filter_vdma_U/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces hdmitx_vdma_U/Data_MM2S] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000 -offset 0x430C0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs filter_vdma_U/S_AXI_LITE/Reg] SEG_filter_vdma_U_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x70E00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs hdmitx_U/s_axi/reg0] SEG_hdmitx_U_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x79000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs hdmitx_clkgen_U/S_AXI/reg0] SEG_hdmitx_clkgen_U_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x41600000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs hdmitx_iic_U/S_AXI/Reg] SEG_hdmitx_iic_U_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs hdmitx_vdma_U/S_AXI_LITE/Reg] SEG_hdmitx_vdma_U_Reg
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


