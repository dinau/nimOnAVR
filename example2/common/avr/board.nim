import conf_sys

proc ei*(){.used,inline.} =
    asm """
        "sei" : : : "memory"
    """
proc di*(){.used,inline.} =
    asm """
        "cli" : : : "memory"
    """
template setBit*(port,bit:untyped) =
    port.v =  port.v or BV(bit)

template clrBit*(port,bit:untyped) =
    port.v = port.v.uint and not BV(bit).uint

# LED pin setting PB5, D13
proc led_on*()  = PORTB.b5 = 1
proc led_off*() = PORTB.b5 = 0

# LED indicator pin setting PD6, D6
proc ind_on*()  = PORTD.b6 = 1
proc ind_off*() = PORTD.b6 = 0

proc ledToggle*()=
   if 0 == PIND.b6: ind_on() else: ind_off()

# test pin setting PD7, D7
proc test_on*() {.inline.} = PORTD.b7 = 1
proc test_off*(){.inline.} = PORTD.b7 = 0

template test_port*(s:int){.used.}=
    if s == 0: test_off() else: test_on()

# Push switch Play/Pause, PD2, D2
proc btn_bit_now*() :bool=
   0 != PIND.b2


