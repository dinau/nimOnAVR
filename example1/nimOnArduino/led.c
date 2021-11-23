#include <avr/io.h>
#include <util/delay.h>

void led_setup(void) {
  DDRB |= _BV(DDB5);
}

void led_on() {
    PORTB |= _BV(PORTB5);
}

void led_off() {
  PORTB &= ~_BV(PORTB5);
}

void delay(int ms) {
  // Not the best way to do this, but it does not matter for this example
  for (int i = 0; i < ms; i++) {
    _delay_ms(1);
  }
}

