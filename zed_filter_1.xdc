
#set_property  -dict {PACKAGE_PIN Y9    IOSTANDARD LVCMOS33} [get_ports {CLK_100}]
#create_clock  -name CLK_100 -period 10.000 [get_ports {CLK_100}]

### HDMI
 set_property  -dict {PACKAGE_PIN W18   IOSTANDARD LVCMOS33} [get_ports {HD_CLK}]
 set_property  -dict {PACKAGE_PIN Y13   IOSTANDARD LVCMOS33} [get_ports HD_D[0]]
 set_property  -dict {PACKAGE_PIN AA13  IOSTANDARD LVCMOS33} [get_ports HD_D[1]]
 set_property  -dict {PACKAGE_PIN AA14  IOSTANDARD LVCMOS33} [get_ports HD_D[2]]
 set_property  -dict {PACKAGE_PIN Y14   IOSTANDARD LVCMOS33} [get_ports HD_D[3]]
 set_property  -dict {PACKAGE_PIN AB15  IOSTANDARD LVCMOS33} [get_ports HD_D[4]]
 set_property  -dict {PACKAGE_PIN AB16  IOSTANDARD LVCMOS33} [get_ports HD_D[5]]
 set_property  -dict {PACKAGE_PIN AA16  IOSTANDARD LVCMOS33} [get_ports HD_D[6]]
 set_property  -dict {PACKAGE_PIN AB17  IOSTANDARD LVCMOS33} [get_ports HD_D[7]]
 set_property  -dict {PACKAGE_PIN AA17  IOSTANDARD LVCMOS33} [get_ports HD_D[8]]
 set_property  -dict {PACKAGE_PIN Y15   IOSTANDARD LVCMOS33} [get_ports HD_D[9]]
 set_property  -dict {PACKAGE_PIN W13   IOSTANDARD LVCMOS33} [get_ports HD_D[10]]
 set_property  -dict {PACKAGE_PIN W15   IOSTANDARD LVCMOS33} [get_ports HD_D[11]]
 set_property  -dict {PACKAGE_PIN V15   IOSTANDARD LVCMOS33} [get_ports HD_D[12]]
 set_property  -dict {PACKAGE_PIN U17   IOSTANDARD LVCMOS33} [get_ports HD_D[13]]
 set_property  -dict {PACKAGE_PIN V14   IOSTANDARD LVCMOS33} [get_ports HD_D[14]]
 set_property  -dict {PACKAGE_PIN V13   IOSTANDARD LVCMOS33} [get_ports HD_D[15]]
 set_property  -dict {PACKAGE_PIN U16   IOSTANDARD LVCMOS33} [get_ports HD_DE]
 set_property  -dict {PACKAGE_PIN V17   IOSTANDARD LVCMOS33} [get_ports HD_HSYNC]
 set_property  -dict {PACKAGE_PIN W17   IOSTANDARD LVCMOS33} [get_ports HD_VSYNC]
 set_property  -dict {PACKAGE_PIN AA18  IOSTANDARD LVCMOS33} [get_ports {hd_iic_scl_io}]
 set_property  -dict {PACKAGE_PIN Y16   IOSTANDARD LVCMOS33} [get_ports {hd_iic_sda_io}]

 set_property  PULLUP true [get_ports {hd_iic_scl_io}]


###
#create_clock -name clk_fpga_0   -period 10.00 [get_pins zynq_system_i/processing_system7_0/inst/PS7_i/FCLKCLK[0]]
#create_clock -name clk_fpga_1   -period 10.00 [get_pins zynq_system_i/processing_system7_0/inst/PS7_i/FCLKCLK[1]]
#create_clock -name clk_fpga_2   -period  5.00 [get_pins zynq_system_i/processing_system7_0/inst/PS7_i/FCLKCLK[2]]
 create_clock -name hhclk        -period  6.73 [get_pins zynq_system_i/hdmitx_clkgen_U/U0/USER_LOGIC_I/i_clkgen/i_mmcm/CLKOUT0]

 set_clock_groups -asynchronous -group {clk_fpga_0} -group {clk_fpga_1} -group {clk_fpga_2} -group {hhclk}
