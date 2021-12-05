<!-- TOC -->

- [Nim On AVR](#nim-on-avr)
    - [Nim language test program for Arduino UNO/Nano](#nim-language-test-program-for-arduino-unonano)
        - [Prerequisite](#prerequisite)
        - [AVR peripheral register access](#avr-peripheral-register-access)
        - [Example1](#example1)
            - [**LED blink** ](#led-blink)
            - [**nimOnArduino** ](#nimonarduino)
            - [**UART** ](#uart)
            - [**UART_LED** ](#uart_led)
            - [**Struct_Test_CMake** ](#struct_test_cmake)
        - [Example2](#example2)
            - [**Intr_Test** ](#intr_test)
            - [**SD_Card** ](#sd_card)
        - [Other links1](#other-links1)
        - [Other links2](#other-links2)

<!-- /TOC -->
  

#                            Nim On AVR
##    Nim language test program for Arduino UNO/Nano

### Prerequisite
* [nim-1.6.0](https://nim-lang.org/install.html)  
    * **Important**:  
        * It must be used above nim version otherwise it won't work well.
* avr-gcc v7.3.0 (inclued in [arduino-1.8.16 IDE](https://www.arduino.cc/en/software))  
    * For example, if on Windows10 set executable path to  
         **d:\arduino-1.8.16\hardware\tools\avr\bin**  
* make,rm and etc Linux tool commands
* [CMake](https://cmake.org/download/) version 3.13 or later  

### AVR peripheral register access
* Load / Store operation
    * Load from peripheral register
        ```Nim
         var 
            inData1 = PORTB.v
            inData2 = PORTB.ld  # same as above
         ```
    * Store to peripheral register 
        ```Nim
         PORTD.v = 123  
         PORTD.st 123   # same as above
         PORTD.st(123)  # same as above
         ```
* Bit operation
    * 1 bit
        ```Nim
        PORTB.b3 = 1             # bit set
        PORTB.b7 = 0             # bit clear 
        # Note: (bx: x = 0..7 )
        var 
            bitdata = PORTD.b2   # bit read
        ```
    * Multi bits
        ```Nim
            # Set / clear multi bits at a time specifiying bit name.
            PORTC.bset [PORTC0,PORTC1,PORTC6,PORTC7]  
            SPCR.bclr [SPR0,SPR1] 
        ```
    * BV() function
        ```Nim
        SPCR.v = BV(SPE) + BV(MSTR)
        ```
    * See also [reg_utils.nim](https://github.com/dinau/nimOnAVR/blob/main/example2/common/lib/reg_utils.nim)

    * Peripheral register definition file
        * [iom328p.nim](https://github.com/dinau/nimOnAVR/blob/main/example2/common/avr/iom328p.nim) converted from [iom328.h](https://github.com/vancegroup-mirrors/avr-libc/blob/master/avr-libc/include/avr/iom328p.h) by c2nim and by hand (-:
        * [str_defs.nim](https://github.com/dinau/nimOnAVR/blob/main/example2/common/avr/sfr_defs.nim) converted from [str_defs.h](https://github.com/vancegroup-mirrors/avr-libc/blob/master/avr-libc/include/avr/sfr_defs.h) 
        
### Example1
#### **LED blink** 
* Simple <span style="color: darkgreen; ">LED</span> blinker program.  

    ```
    $ cd example1/led  
    $ make  
    ```
    ```sh
    $ make 
    ........................................................
    CC: stdlib_system.nim
    CC: delay.nim
    CC: main.nim
    Hint:  [Link]
    Hint: gc: arc; opt: speed; options: -d:danger
    51065 lines; 2.461s; 49.953MiB peakmem; proj: src\main; out: D:\nim-data\avr\nimOnAVR\example1\led\.BUILD\main.elf [SuccessX]
       text    data     bss     dec     hex filename
        234       0       0     234      ea .BUILD\main.elf
    ```
    You can use make command for build management as follows,
    ```sh
    $ make # build target
    $ make clean # clean target
    $ make w # upload to flash
    ```
    or,
    ```sh
    $ nim make # build target
    $ nim clean # clean target
    $ nim w # upload to flash
    ```
* Artifacts (`*`.hex,`*`.lst files etc) would be generate to **.BUILD** folder.
* Code: src/main.nim

    ```Nim
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
    ```
* Upload(write to Flash) the generated file to Arduino board
    * For instance Arduino Uno,
        ```
        $ make w 
        ```
        * Constant **ARDUINO_VER, COM_PORT, AVRDUDE_BAUDRATE** in **config.nims** must be properly set
            accoding to your envionment.  
            See ./[config.nims](https://github.com/dinau/nimOnAVR/blob/main/example1/led/config.nims)
            * cf.
                ```
                  Arduino Uno:       AVRDUDE_BAUDRATE=115200
                  Arduino Nano:      AVRDUDE_BAUDRATE=115200 
                  Arduino Nano(old): AVRDUDE_BAUDRATE=57600 
                ```
        ```sh  
        $ make w
        ........................................................
        Hint:  [Link]
        Hint: gc: arc; opt: speed; options: -d:danger
        51065 lines; 3.046s; 49.906MiB peakmem; proj: src\main; out: nimOnAVR\example1\led\.BUILD\main.elf [SuccessX]
           text    data     bss     dec     hex filename
            234       0       0     234      ea .BUILD\main.elf

        avrdude.exe: AVR device initialized and ready to accept instructions

        Reading | ################################################## | 100% 0.01s

        avrdude.exe: Device signature = 0x1e950f (probably m328p)
        avrdude.exe: erasing chip
        avrdude.exe: reading input file ".BUILD\main.elf"
        avrdude.exe: input file .BUILD\main.elf auto detected as ELF
        avrdude.exe: writing flash (234 bytes):

        Writing | ################################################## | 100% 0.10s

        avrdude.exe: 234 bytes of flash written
        avrdude.exe: verifying flash memory against .BUILD\main.elf:
        avrdude.exe: load data flash data from input file .BUILD\main.elf:
        avrdude.exe: input file .BUILD\main.elf auto detected as ELF
        avrdude.exe: input file .BUILD\main.elf contains 234 bytes
        avrdude.exe: reading on-chip flash data:

        Reading | ################################################## | 100% 0.08s

        avrdude.exe: verifying ...
        avrdude.exe: 234 bytes of flash verified

        avrdude.exe done.  Thank you.
        ``` 

#### **nimOnArduino** 
* Simple <span style="color: darkgreen; ">LED</span> blinker program.  
    * [Referred from 'Nim on Arduino'](https://disconnected.systems/blog/nim-on-adruino/)
        ```
        $ cd example1/nimOnArduino  
        $ make
        ```
        ```sh
        $ make
        ...................................................
        CC: led
        CC: stdlib_system.nim
        CC: blink.nim
        Hint:  [Link]
        Hint: gc: arc; opt: speed; options: -d:danger
        49796 lines; 2.468s; 49.953MiB peakmem; proj: .\blink; out: nimOnAVR\example1\nimOnArduino\.BUILD\blink.elf [SuccessX]
           text    data     bss     dec     hex filename
            234       0       0     234      ea .BUILD\blink.elf

        ```
    * Code: ./blink.nim , [led.c](https://github.com/dinau/nimOnAVR/blob/main/example1/nimOnArduino/led.c)

        ```Nim
        {.compile: "led.c".}
        proc led_setup():   void {.importc.}
        proc led_on():      void {.importc.}
        proc led_off():     void {.importc.}
        proc delay(ms:int): void {.importc.}

        when isMainModule: 
            led_setup()
            while true:
                led_on()
                delay(1000)
                led_off()
                delay(1000)
        ```

#### **UART** 
* Simple <span style="color: darkgreen; ">UART</span> test program with ChaN's xprintf() functions.
    * Set baudrate 38400bps to your terminal program.
        ```
        $ cd example1/uart  
        $ make
        ```
    * Code: [src/main.nim](https://github.com/dinau/nimOnAVR/blob/main/example1/uart/src/main.nim)

        ```Nim
        ...
        # UART setting
        ...
        # main program
        proc main() =
            initUart(mBRate(BAUDRATE))
            var num = 0
            while true:
                xprintf("\n Number = %d", num)
                xputs("---")
                num += 1
                wait_ms(1000)
        main()
        ```

#### **UART_LED** 
* Just mixed <span style="color: darkgreen; ">UART</span> and <span style="color: darkgreen; ">LED</span> blinker test program.
    * Set baudrate 38400bps to your terminal program.
        ```
        $ cd example1/uart_led  
        $ make
        ```
    * Code: [src/main.nim](https://github.com/dinau/nimOnAVR/blob/main/example1/uart_led/src/main.nim)
        ```Nim
        ...
        # UART setting
        ...
        # LED setting
        proc led_setup() = DDRB.b5  = 1
        proc led_on()    = PORTB.b5 = 1
        proc led_off()   = PORTB.b5 = 0

        # main program
        proc main() =
            led_setup()
            initUart(mBRate(BAUDRATE))

            var num = 0
            while true:
                led_on()
                wait_ms(500)
                led_off()
                wait_ms(500)
                xprintf("\n Number = %d", num)
                xputs("---")
                num += 1
        main()
        ``` 
#### **Struct_Test_CMake** 
* Simple test, object(struct) data interchanging between Nim and C language. 
    * Set baudrate 38400bps to your terminal program.
        ```
        $ cd example1/struct_test_cmake  
        $ make
        ```
        * This project is using [**CMake**](https://cmake.org/) to resolve dependency for C language files.
            * It's needed to install CMake v3.13 or later. 
        * Artifacts (`*`.hex,`*`.lst files etc) would be generate to **.build_cmake** folder.
    * Type definition on Nim
        * Code [src/main.nim](https://github.com/dinau/nimOnAVR/blob/main/example1/struct_test_cmake/src/main.nim)
            ```Nim
            type
                Student* {.byref.} = object
                    age*:uint16
                    cstringName*:cstring
                    arrayName*: array[7,char]
            ...
            var
                std:Student
            ...
            show_and_modify_by_c_lang(std)
            ...

            ```
            ```Nim
            proc show_and_modify_by_c_lang(std:var Student){.importc,cdecl.}
            ```
    * Type definition on C language
        * Code [src/student.h](https://github.com/dinau/nimOnAVR/blob/main/example1/struct_test_cmake/src/student.h)
            ```C
            typedef struct Student {
                uint16_t age;
                char *cstringName;
                char arrayName[7];
            } Student;
            ```
        * Code [src/student.c](https://github.com/dinau/nimOnAVR/blob/main/example1/struct_test_cmake/src/student.c)
            ```C
            void show_and_modify_by_c_lang(Student *std){
                ...
            }
            ```
    * Terminal output:
        ```
         === Showing std object in Nim ===
         Age         = 20
         cstringName = my_name_cstring
         arrayName   = ['A', 'B', '\x00', '\x00', '\x00', '\x00', '\x00']

         &std.age            = 0x000008d9
         &std.cstringName    = 0x000008db
         &std.arrayName      = 0x000008dd
         &std.cstringName[0] = 0x00000636
         &std.arrayName[0]   = 0x000008dd

        Calling C function: show_and_modify_by_c_lang(std)

         ======= Received the object pointer of std from Nim at C language function =======
            std.Age = 20
            std.cstrinName  = my_name_cstring
            std.arrayName   = AB

            &std.Age            = 0x000008d9
            &std.cstringNname   = 0x000008db
            &std.arrayName      = 0x000008dd
            &std.ctringNname[0] = 0x00000636
            &std.arrayName[0]   = 0x000008dd

            Now changing the object data as follows,
              std->age += 50;
              std->cstringName[0]='0';
              std->cstringName[1]='1';
              std->cstringName[2]='\0';

              std->arrayName[0]  ='1';
              std->arrayName[1]  ='2';
              std->arrayName[2]  ='3';
              std->arrayName[3]  ='4';
              std->arrayName[4]  ='5';
              std->arrayName[5]  ='\0';

         ============ in C language function end =======

        === Showing std object modified by C function ===
        Age         = 70
        cstringName = 01
        arrayName   = ['1', '2', '3', '4', '5', '\x00', '\x00']
        --- [ xprintf test ! ] ---
        ```

### Example2
####  **Intr_Test** 
* Simple <span style="color: darkgreen; ">Interrupt/SPI/PWM/UART</span> test program with ChaN's xprintf() functions.
    * Set baudrate 38400bps to your terminal program.
        ```
        $ cd example2/intr_test
        $ make
        ```
        * Terminal output:
            * If you wires D11(MOSI) with D12(MISO), SPI error will be gone away (=>0) because of loopback connection established.
                ```sh
                ...
                [00181]
                     45504 Hz: PWM [44100 Hz] period interrupt freq.(Approximately)
                  8282546:     SPI [D11->D12] error count in PWM period interrupt.
                ...
                ```
        * SPI pins
            * Chip select: D8(PB0) and D4(PD4)
            * MISO: D12(PB4), MOSI: D11(PB3)
            * SCK: D13(PB5)
        * If you have oscilloscope, it could be observed PWM signal(period=44.1kHz) at D9,D10 pin.
    * Code: [src/main.nim](https://github.com/dinau/nimOnAVR/blob/main/example2/intr_test/src/main.nim)
        ```Nim
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
                    let pwmCounter = pwmIntrCounter # int32
                    enablePwmPeriodIntr()
                    xprintf("\n[%05d]",ix)
                    xprintf("\n     %5ld Hz: PWM [44100 Hz] period interrupt freq.(Approximately)", pwmCounter - prev)
                    prev = pwmCounter
                    xprintf("\n    %9ld:     SPI [D11<-D12] error count in PWM period interrupt.",spi_err)
                    inc(ix)
        # Run main
        main()
        ```

#### **SD\_Card** 
* This program shows <span style="color: darkgreen; ">SD card</span> low-level initialize info and file list in root folder.
    * Set baudrate 38400bps to your terminal program.
        ```
        $ cd example2/sd_card
        $ make
        ```
    * Code [src/main.nim](https://github.com/dinau/nimOnAVR/blob/main/example2/sd_card/src/main.nim)
        ```Nim
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
            initSpi()                       # SCK=8MHz
            ei()                            # enable all interrupt

            while not sd_init():            # SDSC,SDHC initialize
                wait_ms(1500)
            FAT_init()                      # Accept FAT16 and FAT32
            for _ in 1..3:                  # Show the information of first 3 files.
                searchNextFile()

        # Run main
        main()
        ```

    * Terminal output: [(Full output)](https://github.com/dinau/nimOnAVR/blob/main/example2/sd_card/sd_card_show_init_info.txt)
        ```sh
        [sd_card.nim] Start SD card init
        --- Found: SDv2 !
        --- --- ACMD41 OK
        --- --- --- Found: SDSC None Block Mode : CMD58
        [Finished!]: OK!  SD card init
        [fat_lib.nim/FAT_init()] Start MBR/FAT read
        MBR is:
         0000:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0010:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0020:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0030:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0040:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0050:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0060:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0070:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0080:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0090:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         00A0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         00B0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         00C0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         00D0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         00E0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         00F0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0100:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0110:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0120:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0130:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0140:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0150:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0160:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0170:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0180:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         0190:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         01A0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         01B0:00 00 00 00 00 00 00 00 FD 3D DE 19 00 00 00 03
         01C0:3F 00 06 17 D7 D7 FB 00 00 00 05 7F 3C 00 00 00
         01D0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         01E0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         01F0:00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 AA
        BPB_Sector[0x01C6] = 0x00FB [th sector]
        BPB_Info is:
         EB 00 90 4D 53 57 49 4E 34 2E 31 00 02 40 01 00 02 00 02 00 00 F8 F2 00 3F 00 40 00 FB 00 00 00
            dwBPB_SecPerFats32 = 242
            bBPB_NumFATs       = 2
            wBPB_RsvdSecCnt    = 1
            dwBPB_HiddSec      = 251
            lgdwRootdir_sector = 736
            lgwSize_of_root    = 16384
            lgwBPB_RootEntCnt  = 512
            lgbBPB_SecPerClus  = 64
            lgwBPB_BytesPerSec = 512
        File entries(FENT) of 32byte are:
        FENT: 42 20 00 49 00 6E 00 66 00 6F 00 0F 00 72 72 00 6D 00 61 00 74 00 69 00 6F 00 00 00 6E 00 00 00
        asci:  B        I     n     f     o           r  r     m     a     t     i     o           n
        File entries(FENT) of 32byte are:
        ....
        ....
        skip the rest
        ```
    * SD card setup procedure
        1. Format SD card using [SDFormatter](https://www.sdcard.org/downloads/formatter/)
        program.
        1. Copy sample files to root folder on your PC.

    * FAT Filesystem reference
        [FAT Filesystem](http://elm-chan.org/docs/fat_e.html)

### Other links1
* [Arduino for Nim](https://github.com/markspanbroek/nim-arduino)
* [Nim for PlatformIO](https://github.com/markspanbroek/nim-platformio)
* [Nim for Arduino](https://github.com/zevv/nim-arduino)
* [Arduino temp](https://github.com/Sinsjr2/arduino_temp)

### Other links2
* Wave player project Super lite series
    * Nim language
        * [Arduino Wave Player PWM Super Lite Nim / Nim](https://github.com/dinau/arduino-wave-player-pwm-super-lite-nim) Completed.
        * [STM32 Wave Player PWM Super Lite Nim / STM32(F0,L1,F3,F4)  Nim](https://github.com/dinau/stm32-wave-player-pwm-super-lite-nim) Completed. 
    * C++ language
        * [Wave Player Super Lite / STM32(F0,L1,F4) / Mbed2 / C++](https://os.mbed.com/users/mimi3/code/wave_player_super_lite) Completed.
    * Jal language
        * [Pwm Wave Player Jalv2 / PIC16F1xxx / Jal](https://github.com/dinau/16f-wave-player-pwm-super-lite-jalv2)
