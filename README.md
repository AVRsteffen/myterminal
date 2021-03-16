MyTerminal on a SiPeed Tang Primer FPGA Board
==========
This is only a modified copy in tft_640x480 Branch of impressive work of Zigazou!

'''MyTerminal is a serial terminal implemented on an Anlogic EG4S20BG256 FPGA.'''

![MyTerminal_TFT_640x480_NEC](https://github.com/AVRsteffen/myterminal/blob/tft_640x480/Wiki/Display_Test_NEC_01.jpg)

Characteristics
---------------

- emulated 24bit paralell RGB display interface Data output
  - 640×480 @60Hz,
  - 16 colors from a 512 colors/9 bits palette
  - 16×20 1024 character set
  - semi-graphic characters
- serial input (tested at 115200 kbps)
  - CTSRTS control signal when doing “intensive” operations
  - 8 characters FIFO 
  - UTF-8 support
- 888 RGB interface with 25Mhz clock and Hsync, Vsync and DEN
- written in Verilog
- inspired by Videotex and text mode video card

Requirements
------------

- Tang SiPeed Primer (Anlogic Eagle EG4S20BG256)
- Tang Dynasty 5.0.3


Notes
-----

This is work in progress!
Wiki is in work!
