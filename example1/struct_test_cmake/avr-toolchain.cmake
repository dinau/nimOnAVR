# Makde by audin 2021/11
# For toolchain
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# For device
set(DEVICE atmega328p)
set(SYSTEM_CLOCK 16000000UL)

# For compiler and binutils
set(CMAKE_C_COMPILER avr-gcc)
set(CMAKE_CXX_COMPILER avr-gcc)
set(CMAKE_EXE_LINKER avr-g++)
set(OBJDUMP avr-objdump)
set(OBJCOPY avr-objcopy)
set(OBJSIZE avr-size)

# Compile options
set(cflags
        # Defines
        # -DENABLE_MAIN
        #-DXPRINTF_FLOAT

        # for compiler
        -Os -g
        -ffunction-sections -fdata-sections
        -Wno-discarded-qualifiers
        -flto -fno-fat-lto-objects

        # for linker
        -s
        -Wl,--gc-sections

        # for device
        -DF_CPU=${SYSTEM_CLOCK}
        -mmcu=${DEVICE}
        )

# memo
# [ avr-gcc (GCC) 7.3.0 ] # /d/arduino-1.8.16/hardware/tools/avr/bin/avr-gcc.exe
# [ GNU Make 4.3 ] /usr/bin/make.exe
# [ Nim Compiler Version 1.6.0 [Windows: i386] ]
# [ cmake version 3.22.0-rc2 ] /d/cmake/bin/cmake.exe
