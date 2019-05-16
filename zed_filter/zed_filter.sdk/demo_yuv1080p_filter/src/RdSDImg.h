#include <xil_io.h>


u32 SD_Init(const char *filename);
u32 SD_Access(u32 SourceAddress, u32 DestinationAddress, u32 LengthBytes);
u32 SD_Release(void);
u32 RdSDImg(const char *filename);
u32 RdSDVideo(const char *filename, int FrmIdx);


