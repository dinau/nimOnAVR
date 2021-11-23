#[
  2019,2021 by audin (http://mpu.seesaa.net)
  Nim language test program for Arduino UNO and its compatibles.
  AVR = atmega328p / 16MHz
  avr-gcc: ver.7.3.0 (arduino-1.8.16/hardware/tools/avr/bin)
  nim-1.6.0
  UART baudrate 38400 bps
]#

#[/* PWM out
 * OC1A: PB1, 15pin, D9, Lch
 * OC1B: PB2, 16pin, D10,Rch
 */ ]#

#[/* SPI out
 * SCK:  PB5, 19pin, D13
 * MISO: PB4, 18pin, D12
 * MOSI: PB3, 17pin, D11

 * CS:	 PB0, 14pin, D8
 * or
 * CS:	 PD4,  6pin, D4 [actually hardware]

 * test: PD7, 13pin, D7
]#

import conf_sys,pwm,systick,spi,uart


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
    initSpi()                           # SCK=8MHz

    initPwm()                           # PWM setting
    setPwmPeriod(PWM_FREQ)              # PWM frequency = 44100 Hz
    enablePwmPeriodIntr()               # Enable PWM period interrupt
    pwm_period_timer_start()            # PWM period Timer start

    pwm_dutyL(200)                      # D9
    pwm_dutyR(50)                       # D10

    setUserTicks(1000)
    ei()                                # Enable all interrupt

    var
        ix:int16 = 0
        prev:int32 = 0
    while true:
        if isTickTrigger():
            clearTickTrigger()
            disablePwmPeriodIntr()
            let pwmCounter = pwmIntrCounter #int32
            enablePwmPeriodIntr()
            xprintf("\n[%05d]",ix)
            xprintf("\n     %5ld Hz: PWM [44100 Hz] period interrupt freq.(Approximately)", pwmCounter - prev)
            prev = pwmCounter
            xprintf("\n    %9ld:     SPI [D11->D12] error count in PWM period interrupt.",spi_err)
            inc(ix)

# Run main
main()
