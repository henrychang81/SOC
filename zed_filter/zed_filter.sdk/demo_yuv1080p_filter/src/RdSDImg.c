#include <stdio.h>
#include <xil_io.h>
#include "xstatus.h"
#include "xil_cache.h"
#include "ff.h"
#include "demo_sdi1080p_filter.h"


static FIL fil;		/* File object */
static FATFS fatfs;
static char buffer[32];
static char *FileName = buffer;


//===========================================================================//
u32 SD_Init(const char *filename)
{
	FRESULT rc;

	/* Register volume work area, initialize device */
	rc = f_mount(0, &fatfs);
	if (rc != FR_OK) {
		printf(" :( ERROR : f_mount Fail: rc = %d\r\n", rc);
		return XST_FAILURE;
	}

	FileName = (char *)filename;
	rc = f_open(&fil, FileName, FA_READ);
	if (rc) {
		printf(" :( ERROR: f_open file [%s] rc = [%d]\r\n", FileName, rc);
		return XST_FAILURE;
	}
	//printf(" SD_Init call f_open (%s)\r\n", FileName);

	return XST_SUCCESS;
}


//===========================================================================//
u32 SD_Access(u32 SourceAddress, u32 DestinationAddress, u32 LengthBytes)
{
	FRESULT rc;        /* Result code */
	UINT br;

	rc = f_lseek(&fil, SourceAddress);
	if (rc) {
		xil_printf(" :( ERROR: f_lseek returned %d\r\n", rc);
		return XST_FAILURE;
	}

	rc = f_read(&fil, (void*) DestinationAddress, LengthBytes, &br);
	if (rc) {
		xil_printf(" :( ERROR: f_read returned %d\r\n", rc);
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


//===========================================================================//
u32 SD_Release(void) {
	FRESULT rc;        /* Result code */

	rc = f_close(&fil);
	if (rc) {
		xil_printf(" :( ERROR: f_close returned %d\r\n", rc);
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


typedef u32 (*BmpMoverType)( u32 SourceAddress, u32 DestinationAddress, u32 LengthBytes);
BmpMoverType MoveBmp;


//===========================================================================//
u32 RdSDImg(const char *filename) {

	printf("\r\n======== Read IMG File (%s) @SD-card ========\r\n", filename);
	u32 Status = XST_SUCCESS;

	/* Disable Data Cache */
	Xil_DCacheDisable();

	Status = SD_Init(filename);
	if (Status != XST_SUCCESS){
		printf(" :( SD_INIT_FAIL\r\n");
		return  XST_FAILURE;
	}
	MoveBmp = SD_Access;
	MoveBmp((u32 *)(0x0), (u32 *)(IMGFILE_DDRBASE), (u32)IMGFILE_SIZE);
	SD_Release();
	/*int ii;
	for (ii=0; ii<4; ii++) {
	  printf(" DDR 0x%08x = %08x\r\n", (IMGFILE_BASEADDR+ii*4), Xil_In32(IMGFILE_BASEADDR+ii*4));
	}*/
	//printf("======== Read IMG File Done ========\r\n\n");

	/* Enable Data Cache */
	Xil_DCacheEnable();

	return XST_SUCCESS;
}


//===========================================================================//
u32 RdSDVideo(const char *filename, int FrmIdx) {

	printf("\r\n======== Read YUV420 Video File (%s) Frame (%d) @SD-card ========\r\n", filename, FrmIdx);
	u32 Status = XST_SUCCESS;

	/* Disable Data Cache */
	Xil_DCacheDisable();

	Status = SD_Init(filename);
	if (Status != XST_SUCCESS){
		printf(" :( SD_INIT_FAIL\r\n");
		return  XST_FAILURE;
	}
	MoveBmp = SD_Access;
    MoveBmp((u32 *)(IMGFILE_SIZE*FrmIdx), (u32 *)(IMGFILE_DDRBASE), (u32)IMGFILE_SIZE);
	SD_Release();
		//printf("======== Read YUV420 Video File Done ========\r\n\n");

	/* Enable Data Cache */
	Xil_DCacheEnable();

	return XST_SUCCESS;
}
