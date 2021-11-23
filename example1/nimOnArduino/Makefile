ARDUINO_VER = 1.8.16
COM_PORT ?= COM3
AVRDUDE_BAUDRATE ?= 115200
AVR_GCC_DIR = D:/arduino-$(ARDUINO_VER)/hardware/tools/avr
CONF = "$(AVR_GCC_DIR)/etc/avrdude.conf"

TARGET = blink

BUILD_DIR = .BUILD
NIMFLAGS += --passL:"-Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref"
NIMCACHE = .nimcache
BUILD_TARGET = $(BUILD_DIR)/$(TARGET)

all: $(BUILD_TARGET).elf


$(BUILD_TARGET).elf: nimc
	@avr-size $(@)
	@avr-objcopy -O ihex -R .eeprom $(@) $(@:%.elf=%.hex)
	@avr-objdump -hSC $(@) > $(@:%.elf=%.lst)
	@avr-objdump -hdC $(@) > $(@:%.elf=%.lst2)

.PHONY: nimc cclean w
nimc:
	nim c $(NIMFLAGS) $(TARGET)

clean:
	-@rm -fr $(BUILD_DIR) $(NIMCACHE)

w: all
	$(AVR_GCC_DIR)/bin/avrdude.exe -c arduino -C $(CONF) -P $(COM_PORT) \
	   	-p m328p -b $(AVRDUDE_BAUDRATE)  -u -e -U flash:w:$(BUILD_TARGET).elf:a
