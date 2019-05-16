// ***************************************************************************
// ***************************************************************************

#include <stdio.h>
#include <xil_io.h>
#include "platform.h"
#include "xparameters.h"
#include "xbasic_types.h"
#include "xstatus.h"
#include "xuartps.h"
#include "xparameters_ps.h"
#include "xil_cache.h"

#include "demo_yuv1080p.h"
#include "SetAdv7511.h"
#include "RdSDImg.h"

#define AXI_HDMI_REG_RESET			0x040
#define AXI_HDMI_REG_CTRL			0x044
#define AXI_HDMI_REG_SOURCE_SEL		0x048
#define AXI_HDMI_REG_COLORPATTERN	0x04c
#define AXI_HDMI_REG_STATUS			0x05c
#define AXI_HDMI_REG_VDMA_STATUS	0x060
#define AXI_HDMI_REG_TPM_STATUS		0x064
#define AXI_HDMI_REG_HTIMING1		0x400
#define AXI_HDMI_REG_HTIMING2		0x404
#define AXI_HDMI_REG_HTIMING3		0x408
#define AXI_HDMI_REG_VTIMING1		0x440
#define AXI_HDMI_REG_VTIMING2		0x444
#define AXI_HDMI_REG_VTIMING3		0x448

// ***************************************************************************
// ***************************************************************************
void Xil_DCacheFlush(void);
void xil_printf( const char *ctrl1, ...);
char inbyte(void);

void delay_ms(u32 ms_count) {
  u32 count;
  for (count = 0; count < ((ms_count * 800000) + 1); count++) {
    asm("nop");
  }
}

u32 user_exit(void) {
  while (XUartPs_IsReceiveData(UART_BASEADDR)) {
    if (inbyte() == 'q') {
      return(1);
    }
  }
  return(0);
}


//===========================================================================//
void SetHdmiTxVdma(int VdmaBase) {
  Xil_Out32((HDMITXVDMA_BASEADDR + 0x000), 0x00000003); // enable circular mode
  Xil_Out32((HDMITXVDMA_BASEADDR + 0x05c), VdmaBase); // start address
  Xil_Out32((HDMITXVDMA_BASEADDR + 0x060), VdmaBase); // start address
  Xil_Out32((HDMITXVDMA_BASEADDR + 0x064), VdmaBase); // start address
  Xil_Out32((HDMITXVDMA_BASEADDR + 0x058), (H_STRIDE*4)); // h offset (2048 * 4) bytes
  Xil_Out32((HDMITXVDMA_BASEADDR + 0x054), (H_ACTIVE*4)); // h size (1920 * 4) bytes
  Xil_Out32((HDMITXVDMA_BASEADDR + 0x050), V_ACTIVE); // v size (1080)
//printf("VDMA MM2S CTRL REG = [%08x]\r\n", Xil_In32(HDMITXVDMA_BASEADDR + 0x000));
}


void SetHdmiTx() {

/*Xil_Out32((CFV_BASEADDR + 0x08), ((H_WIDTH << 16) | H_COUNT));
  Xil_Out32((CFV_BASEADDR + 0x0c), ((H_DE_MIN << 16) | H_DE_MAX));
  Xil_Out32((CFV_BASEADDR + 0x10), ((V_WIDTH << 16) | V_COUNT));
  Xil_Out32((CFV_BASEADDR + 0x14), ((V_DE_MIN << 16) | V_DE_MAX));
  Xil_Out32((CFV_BASEADDR + 0x04), 0x00000000); // disable
  Xil_Out32((CFV_BASEADDR + 0x04), 0x00000001); // enable*/

	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_HTIMING1), ((H_ACTIVE << 16) | H_COUNT));
	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_HTIMING2), H_WIDTH);
	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_HTIMING3), ((H_DE_MAX << 16) | H_DE_MIN));
	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_VTIMING1), ((V_ACTIVE << 16) | V_COUNT));
	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_VTIMING2), V_WIDTH);
	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_VTIMING3), ((V_DE_MAX << 16) | V_DE_MIN));
	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_RESET), 0x1);
	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_SOURCE_SEL), 0x0);
	Xil_Out32((CFV_BASEADDR + AXI_HDMI_REG_SOURCE_SEL), 0x1);
}


//===========================================================================//
void f_swip (SrcBase , DestBase) {
	int i;
	char data;

	for (i=0; i<IMGFILE_SIZE; i++) {
		data = Xil_In8(SrcBase+i);
		Xil_Out8(DestBase+i, data);
	}
}


//===========================================================================//
int f_yuv2rgb_8b (char *yPtr, char *uPtr, char *vPtr) {
//char coff[3][3] = {1,  -0,  359,
//                   1, -88, -183,
//                   1, 454,    0};
  unsigned char y;
  signed char u, v;
  short dr, dg, db;
  char r, g, b;
  int pixel;

  y = *yPtr;
  u = *uPtr - 128;
  v = *vPtr - 128;

  dr =        (359*v) >> 8;
  dg = (88*u + 183*v) >> 8;
  db = (454*u)        >> 8;

  dr = y + dr;
  dg = y - dg;
  db = y + db;

  r = (dr>255) ? 255 : (dr<0) ? 0 : dr;
  g = (dg>255) ? 255 : (dg<0) ? 0 : dg;
  b = (db>255) ? 255 : (db<0) ? 0 : db;

  pixel = ((int)r<<16) | ((int)g<<8) | ((int)b<<0);
  return pixel;
}


//===========================================================================//
int ddr_yuv420_wr(int ImgIdx, int IMGBASEDDR) {

  int vSize, hSize;
  int uOffset, vOffset;
  int pcnt=0;
  int x, y;
  u8 y0, u0, v0;
  int pixel;

#ifdef _1920x1080
  vSize = 1080;
  hSize = 1920;
  uOffset = 0x1FA400;  // 1920*1080=2073600=0x1FA400
  vOffset = 0x278D00;  // 1920*1080+1920*1080*0.25=0x278D00
#endif
#ifdef _1280x720
  vSize = 720;
  hSize = 1280;
  uOffset = 0xE1000;  // 1280*720=921600=0xE1000
  vOffset = 0x119400;  // 1280*720+1280*720*0.25=0x119400
#endif

  //xil_printf("DDR write: started (byte length %d) \n\r", bitmapHeader.bfSize-bitmapHeader.bdOffset);
  pcnt = 0;
  for(y=0; y<vSize; y++)
  	for(x=0; x<hSize; x++) {
  		y0 = Xil_In8(IMGBASEDDR+pcnt);
  		u0 = Xil_In8(IMGBASEDDR+uOffset+(int)((y/2)*(hSize/2)+(x/2)));
  		v0 = Xil_In8(IMGBASEDDR+vOffset+(int)((y/2)*(hSize/2)+(x/2)));
        pixel = f_yuv2rgb_8b((char *)&y0, (char *)&u0, (char *)&v0);
  		Xil_Out32((VIDEO_DDRBASE+(IMGVDMA_SIZE*ImgIdx)+((y*hSize+x)*4)), (pixel & 0xffffff));
  		pcnt = pcnt + 1;
    }

  Xil_DCacheFlush();
  //xil_printf("DDR write: completed (total %d)\n\r", pcnt);
  return XST_SUCCESS;
}


// ***************************************************************************
// ***************************************************************************
//Step1: RdSDVideo
//Step2: DDRVideoWr
//Step3: SetVDMA
//Step4: SetHDMITx
//Step5: SetADV7511
int main() {
  u32 Status;
  int i = 0;
  int max_total = 49;   // zed_1080p
//int max_total = 106;  // zed_720p
  int total = 48;
  total = total % max_total;

  init_platform();
  Xil_ICacheEnable();
  Xil_DCacheEnable();

  /* Flush the Caches */
  Xil_DCacheFlush();

  /* Configure Source */
  for (i=0; i<total; i++) {               // max. 96 frames
    Status = RdSDVideo("1080p.yuv", i+0);  // from 0th frame
    if (Status == XST_FAILURE) {
      print(" :( RdSDImg Fail \r\n");
      return XST_FAILURE;
    }
#ifdef SWIP_EN
    f_swip(IMGFILE_DDRBASE , IMGSWIP_DDRBASE);
    Status = (u32)ddr_yuv420_wr(i, IMGSWIP_DDRBASE);
#else
    Status = (u32)ddr_yuv420_wr(i, IMGFILE_DDRBASE);
#endif
    if (Status == XST_FAILURE) {
      print(" :( ddr_yuv420_wr FAIL \r\n");
      return XST_FAILURE;
    }
  }

  SetHdmiTxVdma(VIDEO_DDRBASE+(IMGVDMA_SIZE*0));

  SetHdmiTx();

  SetAdv7511();

  Xil_Out32((CFV_BASEADDR + 0x18), 0xff); // clear status

  delay_ms(200);
  i = 0;
  while (1) {
    SetHdmiTxVdma(VIDEO_DDRBASE+(IMGVDMA_SIZE*i));

	delay_ms(5);
	i=i+1;
	i=(i%total);
  }

  print(" Demo End \r\n");
  cleanup_platform();
  return(0);
}

// ***************************************************************************
// ***************************************************************************
