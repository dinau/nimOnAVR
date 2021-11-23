#[
  2019,2021 by audin (http://mpu.seesaa.net)
  Nim language test program for Arduino UNO and its compatibles.
  AVR = atmega328p / 16MHz
  avr-gcc: ver.7.3.0 (arduino-1.8.16/hardware/tools/avr/bin)
  nim-1.6.0
  UART baudrate 38400bps
]#
import iom328p

const F_CPU = 16_000_000'u32
# UART setting
const BAUDRATE = 38400'u32

proc xprintf(formatstr: cstring){.header: "xprintf.h", importc: "xprintf", varargs,used.}
proc xputs(cstr: cstring){.header: "xprintf.h", importc: "xputs", used.}
proc xprintf_test(){.importc.}
###
proc UART_putc(c: int8) # forward definition

# Use ChaN's xprintf()
when defined(XPRINTF_FLOAT):
    let xfunc_output{.importc,used.} = UART_putc
else:
    let xfunc_out{.importc,used.} = UART_putc

template TX_DATA():untyped = UDR0
template mBRate(baud:uint32):uint16 =
        (((F_CPU div 16'u32 ) div baud ) - 1'u32).uint16

proc initUart( baudFactor :uint16 ) =
    UBRR0H.v = baudFactor shr 8
    UBRR0L.v =  baudFactor
    UCSR0B.v = (1 shl RXEN0) or (1 shl TXEN0) # enable TX,RX
    UCSR0C.v = (3 shl UCSZ00) or (0 shl USBS0) or (0 shl UPM00)

template isUART0_TxRx_FIFO_empty():bool =
    (UCSR0A.v and (1 shl UDRE0)) != 0

proc UART_putc(c: int8) =
    while not isUART0_TxRx_FIFO_empty():
        discard
    TX_DATA.v = c

type
    Student* {.byref.} = object
        age*:uint16
        cstringName*:cstring
        arrayName*: array[7,char]

proc show_and_modify_by_c_lang(std:var Student){.importc,cdecl.}

proc struct_test() =
    var
        std:Student
        sName = "my_name_cstring"

    std.cstringName = sName.cstring
    std.age = 20
    std.arrayName[0] = 'A'
    std.arrayName[1] = 'B'
    std.arrayName[2] = '\0'
    xprintf "\n === Showing std object in Nim ==="
    xprintf "\n Age         = %d", std.age
    xprintf "\n cstringName = %s", ($std.cstringName).cstring
    xprintf "\n arrayName   = %s", ($std.arrayName).cstring
    block show_address:
        xprintf "\n"
        xprintf "\n &std.age            = 0x%08x" , std.age.addr
        xprintf "\n &std.cstringName    = 0x%08x" , std.cstringName.addr
        xprintf "\n &std.arrayName      = 0x%08x" , std.arrayName.addr
        xprintf "\n &std.cstringName[0] = 0x%08x" , std.cstringName[0].addr
        xprintf "\n &std.arrayName[0]   = 0x%08x" , std.arrayName[0].addr

    xprintf "\n\nCalling C function: show_and_modify_by_c_lang(std)"
    show_and_modify_by_c_lang(std)

    xprintf "\n=== Showing std object modified by C function ==="
    xprintf "\nAge         = %d" , std.age
    xprintf "\ncstringName = %s" , ($std.cstringName).cstring
    xprintf "\narrayName   = %s" , ($std.arrayName).cstring

# main program
proc main() =
    initUart(mBRate(BAUDRATE))
    struct_test()
    xprintf_test()
    while true:discard

main()

