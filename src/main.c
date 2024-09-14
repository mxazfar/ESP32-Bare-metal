#include <stdlib.h>

#define LED_PIN 2

#include "soc/gpio_reg.h"
#include "soc/soc.h"

int main(void) {
  REG_WRITE(GPIO_ENABLE_W1TS_REG, (1 << LED_PIN));  // Set as output
  REG_WRITE(GPIO_OUT_W1TS_REG, (1 << LED_PIN));     // Set high

  while ( 1 ) {
  }

  return 0;
}