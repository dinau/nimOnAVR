#[
  2019,2021 by audin (http://mpu.seesaa.net)
  Nim language test program for Arduino UNO and its compatibles.
  AVR = atmega328p / 16MHz
  avr-gcc: ver.7.3.0 (arduino-1.8.16/hardware/tools/avr/bin)
  nim-1.6.0
  UART baudrate 38400 bps
]#

import iom328p,delay

const UART_INFO = true
const F_CPU = 16_000_000'u32

{.compile:"xprintf.c".}
proc xprintf(formatstr: cstring){.header: "xprintf.h", importc: "xprintf", varargs,used.}
proc xputs(cstr: cstring){.header: "xprintf.h", importc: "xputs", used.}
###
proc UART_putc(c: int8) # forward definition

# Use ChaN's xprintf()
when UART_INFO:
    when defined(XPRINTF_FLOAT):
        let xfunc_output{.importc,used.} = UART_putc
    else:
        let xfunc_out{.importc,used.} = UART_putc

# UART setting
const BAUDRATE = 38400'u32
template TX_DATA():untyped = UDR0
template mBRate(baud:uint32):uint16 =
        (((F_CPU div 16'u32 ) div baud ) - 1'u32).uint16

proc initUart( baudFactor :uint16 ) =
    UBRR0H.v = baudFactor shr 8
    UBRR0L.v = baudFactor
    UCSR0B.v = (1 shl RXEN0) or (1 shl TXEN0) # enable TX,RX
    UCSR0C.v = (3 shl UCSZ00) or (0 shl USBS0) or (0 shl UPM00)

template isUART0_TxRx_FIFO_empty():bool =
    (UCSR0A.v and (1 shl UDRE0)) != 0

proc UART_putc(c: int8) =
    while not isUART0_TxRx_FIFO_empty():
        discard
    TX_DATA.v = c

# LED setting
proc led_setup() = DDRB.b5  = 1
proc led_on()    = PORTB.b5 = 1
proc led_off()   = PORTB.b5 = 0

# main program
proc main() =
    led_setup()
    initUart(mBRate(BAUDRATE))

    var num = 0
    while true:
        led_on()
        wait_ms(500)
        led_off()
        wait_ms(500)
        xprintf("\n Number = %d", num)
        xputs("---")
        num += 1

main()
