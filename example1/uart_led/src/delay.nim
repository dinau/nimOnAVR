
proc delay_ms(ms:cdouble){.header:"<util/delay.h>",importc:"_delay_ms",used.}

proc wait_ms*(ms:int) =
    var i = ms
    while i > 0:
        dec(i)
        delay_ms(1)

