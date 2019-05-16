#include <stdio.h>
#include <xil_io.h>

//#define ZC702
#define IIC_BASEADDR        0x41600000
#define SLAVE_ID            0x39

#define HDMI_MODE
#define CSC_ENABLE
#define CSC_SET1
//#define CSC_SET2


extern void delay_ms(u32 ms_count);


//===========================================================================//
void iic_write(u32 daddr, u32 waddr, u32 wdata) {
  Xil_Out32((IIC_BASEADDR + 0x100), 0x002); // reset tx fifo
  Xil_Out32((IIC_BASEADDR + 0x100), 0x001); // enable iic
  Xil_Out32((IIC_BASEADDR + 0x108), (0x100 | (daddr<<1))); // select
  Xil_Out32((IIC_BASEADDR + 0x108), waddr); // address
  Xil_Out32((IIC_BASEADDR + 0x108), (0x200 | wdata)); // data
  while ((Xil_In32(IIC_BASEADDR + 0x104) & 0x80) == 0x00) {delay_ms(1);}
  delay_ms(10);
}


//===========================================================================//
u32 iic_read(u32 daddr, u32 raddr, u32 display) {
  u32 rdata;
  Xil_Out32((IIC_BASEADDR + 0x100), 0x002); // reset tx fifo
  Xil_Out32((IIC_BASEADDR + 0x100), 0x001); // enable iic
  Xil_Out32((IIC_BASEADDR + 0x108), (0x100 | (daddr<<1))); // select
  Xil_Out32((IIC_BASEADDR + 0x108), raddr); // address
  Xil_Out32((IIC_BASEADDR + 0x108), (0x101 | (daddr<<1))); // select
  Xil_Out32((IIC_BASEADDR + 0x108), 0x201); // data
  while ((Xil_In32(IIC_BASEADDR + 0x104) & 0x40) == 0x40) {delay_ms(1);}
  delay_ms(10);
  rdata = Xil_In32(IIC_BASEADDR + 0x10c) & 0xff;
  if (display == 1) {
    xil_printf("iic_read: addr(%02x) data(%02x)\n\r", raddr, rdata);
  }
  delay_ms(10);
  return(rdata);
}


//===========================================================================//
void SetAdv7511() {
  print("\r\n");
  print("##### Set ADV7511 HDMITx Starts #####\r\n");

#ifdef ZC702
  iic_write(0x74, 0x02, 0x02);  // ZC702 Enable Channel 1 (HDMI)
#endif

  // wait for hpd
  while ((iic_read(0x39, 0x96, 0x00) & 0x80) != 0x80) {
    delay_ms(1);
  }

  // Audio
  iic_write(0x39, 0x01, 0x00);
  iic_write(0x39, 0x02, 0x18);
  iic_write(0x39, 0x03, 0x00);

  // [7:4]: I2S sampling freq. 44.1KHz, [3:0]: Input format 16b, YCrCb, 4:2:2 (separate syncs)
  iic_write(0x39, 0x15, 0x01);
  // [4:3]: right justified
  iic_write(0x39, 0x48, 0x08);
  // Output 4:4:4, 8-bit, style 2, DDR falling, RGB clipping
  iic_write(0x39, 0x16, 0x34);  // cwcheng
  // [1]: aspect ratio 16:9, external DE
  iic_write(0x39, 0x17, 0x02);

#ifndef CSC_ENABLE
  // Color Space Converter disabled
  iic_write(0x39, 0x18, 0x46);
#else

#ifdef CSC_SET1
  iic_write(0x39, 0x18, 0xE7);
  iic_write(0x39, 0x19, 0x34);
  iic_write(0x39, 0x1A, 0x04);
  iic_write(0x39, 0x1B, 0xAD);
  iic_write(0x39, 0x1C, 0x00);
  iic_write(0x39, 0x1D, 0x00);
  iic_write(0x39, 0x1E, 0x1C);
  iic_write(0x39, 0x1F, 0x1B);

  iic_write(0x39, 0x20, 0x1D);
  iic_write(0x39, 0x21, 0xDC);
  iic_write(0x39, 0x22, 0x04);
  iic_write(0x39, 0x23, 0xAD);
  iic_write(0x39, 0x24, 0x1F);
  iic_write(0x39, 0x25, 0x24);
  iic_write(0x39, 0x26, 0x01);
  iic_write(0x39, 0x27, 0x35);

  iic_write(0x39, 0x28, 0x00);
  iic_write(0x39, 0x29, 0x00);
  iic_write(0x39, 0x2A, 0x04);
  iic_write(0x39, 0x2B, 0xAD);
  iic_write(0x39, 0x2C, 0x08);
  iic_write(0x39, 0x2D, 0x7C);
  iic_write(0x39, 0x2E, 0x1B);
  iic_write(0x39, 0x2F, 0x77);
#endif

#endif

  iic_write(0x39, 0x40, 0x80);
  iic_write(0x39, 0x41, 0x10);  // [6]: Power Down
  iic_write(0x39, 0x49, 0xa8);
  iic_write(0x39, 0x4c, 0x00);
  iic_write(0x39, 0x55, 0x00);	// Y1Y0 (AVI InfoFrame) = RGB
  iic_write(0x39, 0x56, 0x08);
  iic_write(0x39, 0x96, 0x20);
  iic_write(0x39, 0x98, 0x03);
  iic_write(0x39, 0x99, 0x02);
  iic_write(0x39, 0x9a, 0xe0);
  iic_write(0x39, 0x9c, 0x30);
  iic_write(0x39, 0x9d, 0x61);
  iic_write(0x39, 0xa2, 0xa4);
  iic_write(0x39, 0xa3, 0xa4);
  iic_write(0x39, 0xa4, 0x04);
  iic_write(0x39, 0xa5, 0x44);
  iic_write(0x39, 0xab, 0x40);

#ifdef HDMI_MODE
  iic_write(0x39, 0xaf, 0x06);		// HDCP disabled, HDMI mode
#else
  iic_write(0x39, 0xaf, 0x04);		// HDCP disabled, DVI mode
#endif

  iic_write(0x39, 0xba, 0x00);
  iic_write(0x39, 0xd0, 0x3c);
  iic_write(0x39, 0xd1, 0xff);
  iic_write(0x39, 0xde, 0x9c);
  iic_write(0x39, 0xe0, 0xd0);
  iic_write(0x39, 0xe4, 0x60);
  iic_write(0x39, 0xf9, 0x00);
  iic_write(0x39, 0xfa, 0x00);

  iic_write(0x39, 0x0a, 0x10);
  iic_write(0x39, 0x0b, 0x8e);
  iic_write(0x39, 0x0c, 0x00);
  iic_write(0x39, 0x73, 0x01);
  iic_write(0x39, 0x14, 0x02);

  iic_read(0x39, 0x42, 0x01);
  iic_read(0x39, 0xc8, 0x01);
  iic_read(0x39, 0x9e, 0x01);
  iic_read(0x39, 0x96, 0x01);
  iic_read(0x39, 0x3e, 0x01);
  iic_read(0x39, 0x3d, 0x01);
  iic_read(0x39, 0x3c, 0x01);
  print("##### Set ADV7511 HDMITx Ends ##### \n\r");
  print("\r\n");
}