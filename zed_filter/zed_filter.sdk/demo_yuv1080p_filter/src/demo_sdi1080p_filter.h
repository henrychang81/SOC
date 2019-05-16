
#define DDR_BASEADDR        0x00000000
#define UART_BASEADDR       0xe0001000
#define IIC_BASEADDR        0x41600000
#define CF_CLKGEN_BASEADDR  0x79000000
#define CFV_BASEADDR        0x70e00000
#define HDMITXVDMA_BASEADDR 0x43000000
#define SDICH2VDMA_BASEADDR 0x43040000
#define SDICH1VDMA_BASEADDR 0x43080000
#define FILTERVDMA_BASEADDR 0x430c0000

#define _1920x1080
//#define _1280x720
#ifdef _1920x1080
	#define H_STRIDE            1920
	#define H_COUNT             2200
	#define H_ACTIVE            1920
	#define H_WIDTH             44
	#define H_FP                88
	#define H_BP                148
	#define V_COUNT             1125
	#define V_ACTIVE            1080
	#define V_WIDTH             5
	#define V_FP                4
	#define V_BP                36
#endif
#ifdef _1280x720
	#define H_STRIDE            1280
	#define H_COUNT             1650
	#define H_ACTIVE            1280
	#define H_WIDTH             40
	#define H_FP                110
	#define H_BP                220
	#define V_COUNT             750
	#define V_ACTIVE            720
	#define V_WIDTH             5
	#define V_FP                5
	#define V_BP                20
#endif

#define H_DE_MIN (H_WIDTH+H_BP)
#define H_DE_MAX (H_WIDTH+H_BP+H_ACTIVE)
#define V_DE_MIN (V_WIDTH+V_BP)
#define V_DE_MAX (V_WIDTH+V_BP+V_ACTIVE)
#define VIDEO_DDRBASE    DDR_BASEADDR + 0x08000000
#define IMGFILE_DDRBASE  DDR_BASEADDR + 0x07000000
#define IMGSWIP_DDRBASE  DDR_BASEADDR + 0x07800000
#define IMGTEMP_DDRBASE  DDR_BASEADDR + 0x07800000
#define FILTERRX_DDRBASE DDR_BASEADDR + 0x07800000
#define CH1SDIRX_DDRBASE DDR_BASEADDR + 0x06000000
#define CH2SDIRX_DDRBASE DDR_BASEADDR + 0x06800000


//#define YUV422
#define YUV420
//#define BMP444

#ifdef _1920x1080
  #ifdef BMP444
    #define IMGFILE_SIZE     0x5EEC36  // BMP444
  #else
    #ifdef YUV420
    #define IMGFILE_SIZE     0x2F7600  // YUV420
    #else
    #define IMGFILE_SIZE     0x3F4800  // YUV422
    #endif
  #endif
    #define IMGVDMA_SIZE     0x800000
    #define IMG_SIZE         0x7E9000
#endif
#ifdef _1280x720
  #ifdef BMP444
    #define IMGFILE_SIZE     0x2A3036  // BMP444
  #else
    #ifdef YUV420
    #define IMGFILE_SIZE     0x151800  // YUV420
    #else
    #define IMGFILE_SIZE     0x1C2000  // YUV422
    #endif
  #endif
    #define IMGVDMA_SIZE     0x3A0000
    #define IMG_SIZE         0x384000
#endif
