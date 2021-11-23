import iom328p
export iom328p
import system
export system
import board
export board

# ----------------------
# -- Selectable Options
# ----------------------
const
    UART_INFO*                = true # (+200 bytes) Display "*.wav" filename with xprintf() (UART)

    HAVE_BUTTON_SW*           = true  # (+150 bytes)

    # ---
    HAVE_LED_IND_PWM*         = true  # (+120 bytes) Select HAVE_LED_IND_PWM or HAVE_LED_IND_BLINK
    HAVE_LED_IND_BLINK*       = false
    # ---

    HAVE_LED_IND_BLINK_PAUSE_INDICATOR* = true   # When pause state, speed up the period of LED blinking
    HAVE_POWER_OFF_MODE*      = false  # N/A

    HAVE_FAT32*               = true # (+100 bytes) if true:FAT32/FAT16, false:FAT16 only
    READ_WAV_HEADER_INFO*     = true # (+140 bytes)

# ----------------------
# -- For debug purpose
# ----------------------
const
    TEST_PORT_ENABLE* = true
    WPM_INFO*         = true
    SD_CARD_INFO*     = true # Display SD card initialization info to UART.

# ----------------------
# -- For system type
# ----------------------
type
  word*  = uint16
  dword* = uint32
  sbyte* = int8
  sbit*  = bool
  sword* = int16

# ----------------------
# -- xprintf
# ----------------------
proc xprintf*(formatstr: cstring){.header: "xprintf.h", importc: "xprintf", varargs,used.}


