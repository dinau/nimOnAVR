import conf_sys

#[/* PWM out
 * OC1A: PB1, 15pin, D9, Lch
 * OC1B: PB2, 16pin, D10,Rch
 */ ]#

template pwm_dutyL*(d:uint8)= pwm1_duty(d)
template pwm_dutyR*(d:uint8)= pwm2_duty(d)

proc pwm1_duty*(d:uint8){.inline.} =
    OCR1A.v = d

proc pwm2_duty*(d:uint8){.inline} =
    OCR1B.v = d

template pwmPeriod*(m: untyped): untyped =
  ICR1.v = (m)

template getPwmPeriod*(): untyped =
  ICR1.v

proc is_pwm_period_timer_start*():bool =
   1 == TCCR1B.b0

proc pwm_period_timer_start*() =
  TCCR1B.b0 = 1 ##  clk_io / 1

proc pwm_period_timer_stop*() =
  TCCR1B.v = TCCR1B.v and 0x000000F8

proc setPwmPeriod*(sample_rate:int32){.inline.} =
    pwmPeriod( (( ( F_CPU + ( sample_rate.uint32 shr 1 ) ) div sample_rate.uint32 ) - 1 ).uint16 )

proc enablePwmPeriodIntr*(){.inline.} =
    clrBit(TIFR1,TOV1)
    TIMSK1.v = BV(TOIE1)

proc disablePwmPeriodIntr*(){.inline.} =
    TIMSK1.bclr [TOIE1]

proc initPwm*(){.inline.}=
    #/* clear when match and FAST PWM TOP=ICR1 */
    TCCR1A.v =  (0b1010 shl 4) or BV(WGM11)
    TCCR1B.v =  BV(WGM13) or BV(WGM12)  #    /* FAST PWM and stop pwm */
    TCNT1.v = 0
