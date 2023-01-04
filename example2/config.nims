import os,strutils

--hint:"Conf:off"
--verbosity:1
const
    TARGET    = "main"
    SRC_DIR   = "src"

const
    # Define binutils
    OBJCOPY   = "avr-objcopy"
    OBJDUMP   = "avr-objdump"
    OBJSIZE   = "avr-size"

    # build path
    BUILD_DIR = ".BUILD"
    target_build_path = os.joinPath(BUILD_DIR,TARGET)
    target_src_path   = os.joinPath(SRC_DIR,TARGET)

# switch "avr.any.gcc.path" , "D:/arduino-1.8.16/hardware/tools/avr/bin"

# Setting parmeters to upload with avrdude
const
    ARDUINO_VER = "1.8.16"
    #COM_PORT = "COM3"
    COM_PORT = "COM5"
    #AVRDUDE_BAUDRATE = "115200"
    AVRDUDE_BAUDRATE = "57600"
    AVR_GCC_DIR = "D:/arduino-$#/hardware/tools/avr" % ARDUINO_VER
    CONF = "$#/etc/avrdude.conf" % AVR_GCC_DIR

# Selectable compilation switch
const XPRINTF_FLOAT = false

switch "avr.any.gcc.exe"       ,"avr-gcc"
switch "avr.any.gcc.linkerexe" , "avr-gcc"
switch "gcc.options.linker"    ,"-static"

switch "gcc.options.always" ,""
switch "gcc.options.debug"  ,""
switch "gcc.options.size"   ,"-Os"
switch "gcc.options.speed"  ,"-Os"

# OS and cpu
--os:any
--cpu:avr

switch "threads","off" # for nim-2.0 or later

# Memory manager and signal handler
--mm:arc
switch "d","noSignalHandler"
switch "d","useMalloc"

# Size optimize
--opt:size
switch "d" ,"danger"
switch "panics", "on"

block:
    # avr-gcc settings for AVR ATMega328p
    --passC:"-DF_CPU=16000000UL"
    --passC:"-mmcu=atmega328p"
    --passL:"-mmcu=atmega328p"

    # General options for small code size
    --passC:"-std=gnu11"
    --passC:"-Os -g"
    --passC:"-ffunction-sections -fdata-sections"
    --passL:"-Wl,--gc-sections"
    --passC:"-flto -fno-fat-lto-objects"
    --passL:"-flto"
    block: # Note
        # This option was deleted at avr-gcc v11.0
        --passL:"-Wl,--relax"

# Set nimcache
--nimcache:".nimcache"

# Add source path
const COMMON_DIR = "common"
switch("path","$#/avr" % COMMON_DIR)
switch("path","$#/lib" % COMMON_DIR)
switch("path","$#" % projectDir())

# for selection of xprintf
if XPRINTF_FLOAT:
    switch "d","XPRINTF_FLOAT"
    switch("path",      "$#/lib/xprintf/xprintf_float" % COMMON_DIR)
    switch("passC","-I../$#/lib/xprintf/xprintf_float" % COMMON_DIR)
else:
    switch("path",      "$#/lib/xprintf/xprintf_int" % COMMON_DIR)
    switch("passC","-I../$#/lib/xprintf/xprintf_int" % COMMON_DIR)

# Set suffix .elf
switch "o", target_build_path & ".elf"

# Generate *.map file
switch "passL","-Wl,-Map=$#.map,--cref" % target_build_path

# Define tasks
task clean, "Clean target":
    echo "Removed $#, $#" % [BUILD_DIR,nimcacheDir()]
    rmDir BUILD_DIR
    rmDir nimcacheDir()

task make, "Build target":
    # Compile target
    exec "nim c " & target_src_path
    # Show target size
    exec "$# $#.elf" % [OBJSIZE,target_build_path]
    # Generate *.hex file
    exec "$# -O ihex -R .eeprom $#.elf $#.hex" % [OBJCOPY,target_build_path,target_build_path]
    # Generate *.lst file with source code
    var (output,res) = gorgeEx( "$# -hSC $#.elf" % [OBJDUMP,target_build_path])
    writeFile(target_build_path & ".lst", output)
    # Generate *.lst2 file without source code
    (output,res) = gorgeEx( "$# -hdC $#.elf" % [OBJDUMP,target_build_path])
    writeFile(target_build_path & ".lst2", output)

task w, "Upload to Flash":
    const AVRDUDE_EXE = toExe("avrdude")
    makeTask()
    exec "$#/bin/$# -c arduino -C $# -P $# -p m328p -b $#  -u -e -U flash:w:$#.elf:a" %
        [AVR_GCC_DIR,AVRDUDE_EXE,CONF,COM_PORT,AVRDUDE_BAUDRATE,target_build_path]

task t, "test anything":
    echo getEnv("OS")

