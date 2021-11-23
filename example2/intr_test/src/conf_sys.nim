import iom328p
export iom328p
import system
export system
import board
export board

const PWM_FREQ*:int32 = 44100 # Hz
# ----------------------
# -- Selectable Options
# ----------------------
const
    UART_INFO*                = true



# ----------------------
# -- xprintf
# ----------------------
proc xprintf*(formatstr: cstring){.header: "xprintf.h", importc: "xprintf", varargs,used.}


