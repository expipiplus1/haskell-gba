  .text
  .global _start
@ The process starts execution with arm instructions. Branch to main which will
@ have the lowest bit set thanks to the .thumb_func attribute and enter thumb mode.
_start:
  .align
  .code 32 @ arm instructions
  ldr r0, =main
  bx r0
  .END
