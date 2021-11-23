<!-- TOC -->

- [Nim On AVR](#nim-on-avr)
    - [Nim language test program for Arduino UNO/Nano or its compatibles.](#nim-language-test-program-for-arduino-unonano-or-its-compatibles)
        - [Prerequisite](#prerequisite)
        - [Example1](#example1)
            - [**led** folder](#led-folder)
            - [**nimOnArduino** folder](#nimonarduino-folder)
            - [**uart** folder](#uart-folder)
            - [**uart_led** folder](#uart_led-folder)
            - [**struct_test_cmake** folder](#struct_test_cmake-folder)
        - [Example2](#example2)
            - [**intr_test** folder](#intr_test-folder)
            - [**sd_card** folder](#sd_card-folder)

<!-- /TOC -->
  

#                            Nim On AVR
##    Nim language test program for Arduino UNO/Nano or its compatibles.

### Prerequisite
* [nim-1.6.0 or nim-1.4.8](https://nim-lang.org/install.html)  
    * **Important**:  
        * It must be used above nim version otherwise it won't work well.
* avr-gcc v7.3.0 (inclued in [arduino-1.8.16 IDE](https://www.arduino.cc/en/software))  
    * For example, if on windows set executable path to  
         **d:\arduino-1.8.16\hardware\tools\avr\bin**  
* make,rm and etc Linux tool commands
* cmake version 3.13 or later  

### AVR Peripheral register access
* Load / Store operation
    * Load from Peripheral register
        ```Nim
         var 
            inData1 = PORTB.v
            inData2 = PORTB.ld  # same as above
         ```
    * Store to Peripheral register 
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

### Example1
#### **led** folder
* Simple <span style="color: darkgreen; ">LED</span> blinker program.  

    ```
    $ cd example1/led  
    $ make  
    ```
    ```
    nim c --passL:"-Wl,-Map=.BUILD/main.map,--cref" src/main
    Hint: used config file 'C:\Users\foo\.choosenim\toolchains\nim-1.6.0\config\nim.cfg' [Conf]
    Hint: used config file 'C:\Users\foo\.choosenim\toolchains\nim-1.6.0\config\config.nims' [Conf]
    Hint: used config file 'D:\nim-data\avr\nimOnAVR\example1\led\nim.cfg' [Conf]
    ........................................................
    CC: stdlib_system.nim
    CC: delay.nim
    CC: main.nim
    Hint:  [Link]
    Hint: gc: arc; opt: speed; options: -d:danger
    24649 lines; 3.141s; 20.727MiB peakmem; proj: src\main; out: D:\nim-data\avr\nimOnAVR\example1\led\.BUILD\main.elf [SuccessX]
       text    data     bss     dec     hex filename
        234       0       0     234      ea .BUILD/main.elf
    ```

* Artifacts (`*`.hex,`*`.lst files etc) would be generate to <span style="color: darkgreen; ">.BUILD</span> folder.
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
        $ make w ARDUINO_VER=1.8.16 COM_PORT=COM5 AVRDUDE_BAUDRATE=115200
        ```
        * Variable **ARDUINO_VER, COM_PORT, AVRDUDE_BAUDRATE** must be properly set
            accoding to your envionment.  
            See also **led/Makefile**.
            * cf.
                ```
                  Arduino Uno:       AVRDUDE_BAUDRATE=115200
                  Arduino Nano:      AVRDUDE_BAUDRATE=115200 
                  Arduino Nano(old): AVRDUDE_BAUDRATE=57600 
                ```
        ```  
        $ make w ARDUINO_VER=1.8.16 COM_PORT=COM5 AVRDUDE_BAUDRATE=57600
        nim c --passL:"-Wl,-Map=.BUILD/main.map,--cref" src/main
        Hint: used config file 'C:\Users\foo\.choosenim\toolchains\nim-1.6.0\config\nim.cfg' [Conf]
        Hint: used config file 'C:\Users\foo\.choosenim\toolchains\nim-1.6.0\config\config.nims' [Conf]
        Hint: used config file 'D:\nim-data\avr\nimOnAVR\example1\led\nim.cfg' [Conf]
        ........................................................
        Hint:  [Link]
        Hint: gc: arc; opt: speed; options: -d:danger
        24649 lines; 0.680s; 20.715MiB peakmem; proj: src\main; out: D:\nim-data\avr\nimOnAVR\example1\led\.BUILD\main.elf [SuccessX]
           text    data     bss     dec     hex filename
            234       0       0     234      ea .BUILD/main.elf
        D:/arduino-1.8.16/hardware/tools/avr/bin/avrdude.exe -c arduino -C "D:/arduino-1.8.16/hardware/tools/avr/etc/avrdude.conf" -P COM5 \
                -p m328p -b 57600  -u -e -U flash:w:.BUILD/main.elf:a

        avrdude.exe: AVR device initialized and ready to accept instructions

        Reading | ################################################## | 100% 0.02s

        avrdude.exe: Device signature = 0x1e950f (probably m328p)
        avrdude.exe: erasing chip
        avrdude.exe: reading input file ".BUILD/main.elf"
        avrdude.exe: input file .BUILD/main.elf auto detected as ELF
        avrdude.exe: writing flash (234 bytes):

        Writing | ################################################## | 100% 0.08s

        avrdude.exe: 234 bytes of flash written
        avrdude.exe: verifying flash memory against .BUILD/main.elf:
        avrdude.exe: load data flash data from input file .BUILD/main.elf:
        avrdude.exe: input file .BUILD/main.elf auto detected as ELF
        avrdude.exe: input file .BUILD/main.elf contains 234 bytes
        avrdude.exe: reading on-chip flash data:

        Reading | ################################################## | 100% 0.08s

        avrdude.exe: verifying ...
        avrdude.exe: 234 bytes of flash verified

        avrdude.exe done.  Thank you.
    ``` 

#### **nimOnArduino** folder 
* Simple <span style="color: darkgreen; ">LED</span> blinker program.  
    * [Referred from 'Nim on Arduino'](https://disconnected.systems/blog/nim-on-adruino/)
        ```
        $ cd example1/nimOnArduino  
        $ make
        ```
        ```
        nim c --passL:"-Wl,-Map=.BUILD/blink.map,--cref" blink
        Hint: used config file 'C:\Users\foo\.choosenim\toolchains\nim-1.6.0\config\nim.cfg' [Conf]
        Hint: used config file 'C:\Users\foo\.choosenim\toolchains\nim-1.6.0\config\config.nims' [Conf]
        Hint: used config file 'D:\nim-data\avr\nimOnAVR\example1\nimOnArduino\nim.cfg' [Conf]
        ...................................................
        CC: led
        CC: stdlib_system.nim
        CC: blink.nim
        Hint:  [Link]
        Hint: gc: arc; opt: speed; options: -d:danger
        23380 lines; 2.439s; 16.695MiB peakmem; proj: blink; out: D:\nim-data\avr\nimOnAVR\example1\nimOnArduino\.BUILD\blink.elf [SuccessX]
           text    data     bss     dec     hex filename
            234       0       0     234      ea .BUILD/blink.elf
        ```

    * Code: ./blink.nim

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

#### **uart** folder
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

#### **uart_led** folder
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
#### **struct_test_cmake** folder
* Simple test, object(struct) data interchanging between Nim and C language. 
    * Set baudrate 38400bps to your terminal program.
        ```
        $ cd example1/struct_test_cmake  
        $ make
        ```
        * This project is using [**cmake**](https://cmake.org/) to resolve dependency for C language files.
            * It's needed to install cmake v3.13 or later. 
        * Artifacts (`*`.hex,`*`.lst files etc) would be generate to <span style="color: darkgreen; ">.build_cmake</span> folder.

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
####  **intr_test** folder
* Simple <span style="color: darkgreen; ">Interrupt/SPI/PWM/UART</span> test program with ChaN's xprintf() functions.
    * Set baudrate 38400bps to your terminal program.
        ```
        $ cd example2/intr_test
        $ make
        ```
        * Terminal output:
            * If you wires D11(MOSI) with D12(MISO), SPI error will be gone away (=>0) because of loopback connection established.
                ```
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

        * If you have oscilloscope, it can be observe PWM signal(period=44.1kHz) at D9,D10 pin.
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

#### **sd\_card** folder
* This program shows <span style="color: darkgreen; ">SD card</span> low-level initialize info and file list.
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
            for _ in 1..3:                  # Show the information of first 3 file
                searchNextFile()

        # Run main
        main()
        ```

    * Terminal output: [(Full output)](https://github.com/dinau/nimOnAVR/blob/main/example2/sd_card/sd_card_show_init_info.txt)
        ```
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



2019/01, 2021/11 by audin



