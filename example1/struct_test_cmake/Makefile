ARDUINO_VER = 1.8.16
COM_PORT ?= COM3
AVRDUDE_BAUDRATE ?= 115200
AVR_GCC_DIR = D:/arduino-$(ARDUINO_VER)/hardware/tools/avr
CONF = "$(AVR_GCC_DIR)/etc/avrdude.conf"

TARGET = struct_test

BUILD_DIR  = .build_cmake
BUILD_TARGET = $(BUILD_DIR)/$(TARGET)
NIMCACHE = .nimcache

GENERATOR = -G "Unix Makefiles"

#GENERATOR = -G "Ninja"
#GENERATOR = -G "MSYS Makefiles"
#GENERATOR = -G "MinGW Makefiles"

NIMFLAGS += --nimcache:$(NIMCACHE)
NIMFLAGS += --panics:on

.PHONY: nim cmakeconf clean cleanall

all: nim cmakeconf
	@cmake --build $(BUILD_DIR)

nim:
	nim c -c $(NIMFLAGS) src/main

cmakeconf:
	@cmake -S . -B $(BUILD_DIR) $(GENERATOR) -DCMAKE_TOOLCHAIN_FILE=./avr-toolchain.cmake

clean:
	-@make -C $(BUILD_DIR) clean

cleanall:
	-@rm -fr $(BUILD_DIR)
	-@rm -fr $(NIMCACHE)

w: all
	$(AVR_GCC_DIR)/bin/avrdude.exe -c arduino -C $(CONF) -P $(COM_PORT) \
	   	-p m328p -b $(AVRDUDE_BAUDRATE)  -u -e -U flash:w:$(BUILD_TARGET):a

