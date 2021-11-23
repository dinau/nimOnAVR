import conf_sys

const INTERVAL_1MSEC  = (( (F_CPU div 1000) + (256 shr 1).uint32 ) div 256 ).uint8

template initSystick*() =
  TCCR0B.v = BV(CS02) ##  clk / 256
  setBit(TIFR0,TOV0) # Note: Setting TOV0=1 by software is equal to clear TOV0 flag.
  TIMSK0.v = BV(TOIE0)
  TCNT0.v = (255'u8 - INTERVAL_1MSEC) ##  1msec

# Define tick variable with 8bit width
var bTicks*{.volatile,exportc.}: uint8

template getTickCounter*():uint8 =
    bTicks

template setTickcounter*(ms:uint8) =
    bTicks = ms

proc millis8bit*(): uint8 =
    bTicks


proc wait_ms8bit*(ms8bit:uint8)=
    bTicks = ms8bit
    while bTicks > 0: discard

proc wait_ms*(ms:uint16)=
    var ms16bit = ms
    while ms16bit > 0:
        wait_ms8bit(1)
        dec(ms16bit)

# Define Timer0 interrupt
# Use Timer0
# Interrupt routin
proc systickIntr(){.exportc,inline.} =
    TCNT0.v = (255'u8 - INTERVAL_1MSEC)
    bTicks -= 1

{.emit: """
#include <avr/interrupt.h>

void systickIntr(void);
#pragma GCC optimize ("O3")
ISR(TIMER0_OVF_vect){
    systickIntr();
}""".}

# Use Timer1
# Interrupt routin
proc pwmPeriodIntr(){.exportc,inline.} =
    discard

{.emit:"""
#include <avr/interrupt.h>

void pwmPeriodIntr(void);
#pragma GCC optimize ("O3")
    ISR(TIMER1_OVF_vect){
        pwmPeriodIntr();
}""".}


