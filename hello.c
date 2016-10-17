typedef unsigned char  u8;
typedef unsigned short u16;
typedef unsigned int   u32;

int main() {
  const u16 red = 31;

	// Write into the I/O registers, setting video display parameters.
	volatile u8* ioram = (u8*)0x04000000;
	ioram[0] = 0x03; // 240*160 16bpp
	ioram[1] = 0x04; // single framebuffer 

	// Write pixel colours into VRAM
	volatile u16* vram = (u16*)0x06000000;

  for(u16 i = 0; i < 40*240; i += 7){
    vram[i] = red;
  }

	while(1){}
}
