#[
  2019,2021 by audin (http://mpu.seesaa.net)
  Nim language test program for Arduino UNO and its compatibles.
  AVR = atmega328p / 16MHz
  avr-gcc: ver.7.3.0 (arduino-1.8.16/hardware/tools/avr/bin)
  nim-1.6.0
  UART baudrate 38400 bps
]#

import conf_sys,systick,spi,uart
import sd_card,fat_lib
#[ /* SD card pin
 Pin side
 --------------\
         9     = \    DAT2/NC
             1 ===|   CS/DAT3    [CS]
             2 ===|   CMD/DI     [DI]
             3 ===|   VSS1
 Bottom      4 ===|   VDD
 View        5 ===|   CLK        [CLK]
             6 ===|   VSS2
             7 ===|   DO/DAT0    [DO]
         8       =|   DAT1/IRQ
 -----------------

                                         Arduino      NUCLEO-F411       NUCLEO-F030R8
 Logo side
 -----------------
         8       =|   DAT1/IRQ
             7 ===|   DO/DAT0    [DO]     D12           D12/PA_6           D12/PA_6
             6 ===|   VSS2
 Top         5 ===|   CLK        [CLK]    D13           D13/PA_5           D13/PA_5
 View        4 ===|   VDD
             3 ===|   VSS1
             2 ===|   CMD/DI     [DI]     D11           D11/PA_7           D11/PA_7
             1 ===|   CS/DAT3    [CS]     D8/D4         D10/PB_6           D10/PB_6
         9     = /    DAT2/NC
 --------------/
 */
]#

when UART_INFO:
    {.compile:"xprintf.c".}

template initPort*() =
# set pull up to i/o port.
    PORTB.v = 0xFF
    PORTC.v = 0xFF
    PORTD.v = 0xFF
    DDRB.v =  0xEF # all output except PB4
    DDRD.v =  0xFF # all output port

# main program
proc main() =
    initPort()
    initSystick()
    when UART_INFO:
        initUart(mBRate(UART_BAUDRATE)) # 38400bps
    initSpi()                       # SCK=8MHz
    ei()                            # enable all interrupt

    while not sd_init():            # SDSC,SDHC initialize
        wait_ms(1500)
    FAT_init()                      # Accept FAT16 and FAT32
    for _ in 1..3:                  # Show the information of first 3 file
        searchNextFile()

# Run main
main()

