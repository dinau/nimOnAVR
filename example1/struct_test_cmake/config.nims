import os,strutils

--hint:"Conf:off"
--verbosity:1

const
    TARGET    = "main"
    SRC_DIR   = "src"

const
    # build path
    BUILD_DIR = ".build_cmake"
    target_build_path = os.joinPath(BUILD_DIR,TARGET)
    target_src_path   = os.joinPath(SRC_DIR,TARGET)

const
    GENERATOR = "-G \"Unix Makefiles\""
    #GENERATOR = "-G \"Ninja\""
    #GENERATOR = "-G \"MSYS Makefiles\""
    #GENERATOR = "-G \"MinGW Makefiles\""

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
const XPRINTF_FLOAT{.used.} = false

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
# Set nimcache
--nimcache:".nimcache"

# Add source path
--path:"src/avr"
--path:"src/lib"

when false:
    # for selection of xprintf
    if XPRINTF_FLOAT:
        switch "d","XPRINTF_FLOAT"
        --path:"src/lib/xprintf/xprintf_float"
        --passC:"-Isrc/lib/xprintf/xprintf_float"
    else:
        --path:"src/lib/xprintf/xprintf_int"
        --passC:"-Isrc/lib/xprintf/xprintf_int"

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
    exec "nim c -c " & target_src_path
    exec "cmake -S . -B $# $# -DCMAKE_TOOLCHAIN_FILE=./avr-toolchain.cmake" %
        [ BUILD_DIR, GENERATOR]
    exec "cmake --build $#" % BUILD_DIR

task w, "Upload to Flash":
    const AVRDUDE_EXE = toExe("avrdude")
    makeTask()
    exec "$#/bin/$# -c arduino -C $# -P $# -p m328p -b $#  -u -e -U flash:w:$#.elf:a" %
        [AVR_GCC_DIR,AVRDUDE_EXE,CONF,COM_PORT,AVRDUDE_BAUDRATE,target_build_path]

task t, "test anything":
    echo getEnv("OS")

