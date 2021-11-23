import conf_sys

#[/*
 * SCK:  PB5, 19pin, D13
 * MISO: PB4, 18pin, D12
 * MOSI: PB3, 17pin, D11

 * CS:	 PB0, 14pin, D8
 * or
 * CS:	 PD4,  6pin, D4 [actually hardware]

 * test: PD7, 13pin, D7
 */]#

template cs_on*() =
    setBit(PORTD,PORTD4)
    setBit(PORTB,PORTB0)

template cs_off*()=
    clrBit(PORTD,PORTD4)
    clrBit(PORTB,PORTB0)

template spiBusyWait*() =
    while 0'u8 == (SPSR.v and BV(SPIF) ).uint8:
    #while SPSR.bitIsClr [SPIF]:
        discard

template getSPIBUF*(): uint8   = SPDR.v
template setSPIBUF*(dat:SomeInteger) = SPDR.v = dat
template send*(d:SomeInteger):uint8 =
        setSPIBUF(d)
        spiBusyWait()
        getSPIBUF()

template send_ff*():uint8 =
    send(0xff)

proc sdLowSpeed*() {.inline.} =
    # set F_CPU / 64 = 16MHz / 64 = 250KHz
    when true:
        setBit(SPCR,SPR0)
        setBit(SPCR,SPR1)
    else:
        SPCR.bset [SPR0,SPR1]

proc sdHiSpeed*(){.inline.}=
    # set F_CPU / 2 = 16MHz / 2 = 8MHz
    when true:
        clrBit(SPCR,SPR0)
        clrBit(SPCR,SPR1)
    else:
        SPCR.bclr [SPR0,SPR1]

proc spi_write*(d:byte){.inline.}=
    discard send(d)

proc spi_read*():byte{.inline.}=
    send(0xFF)

proc sd_chip_select*(state:int){.inline.} =
    if state==1: cs_on() else: cs_off()

template spiEnable*() =
    discard # dummy

proc sdSpiEnable*(){.inline.} =
    spiEnable()

proc initSpi*(){.inline} =
#/* SPI mode 0 CPOL = , CPHA=0 */
    SPCR.v = BV(SPE) + BV(MSTR)
    SPSR.v = BV(SPI2X)  #/* SPI clock = fosc/2 = 8MHz*/

