#[
  2019,2021 by audin (http://mpu.seesaa.net)
  Nim language test program for Arduino UNO and its compatibles.
  AVR = atmega328p / 16MHz
  avr-gcc: ver.7.3.0 (arduino-1.8.16/hardware/tools/avr/bin)
  nim-1.6.0
]#

import iom328p,delay

# LED setting
proc led_setup() = DDRB.b5  = 1
proc led_on()    = PORTB.b5 = 1
proc led_off()   = PORTB.b5 = 0

# main program
proc main() =
    led_setup()
    while true:
        led_on()
        wait_ms(1000)
        led_off()
        wait_ms(1000)

main()

