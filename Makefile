# 'Bare metal' ESP32 application Makefile

# Use the xtensa-esp32-elf toolchain.
TOOLCHAIN := xtensa-esp32-elf-

CFLAGS_PLATFORM  := -mlongcalls -mtext-section-literals -fstrict-volatile-bitfields
ASFLAGS_PLATFORM := $(CFLAGS_PLATFORM)
LDFLAGS_PLATFORM := $(CFLAGS_PLATFORM)

### General project build ###
CC := $(TOOLCHAIN)gcc
LD := $(TOOLCHAIN)ld
OC := $(TOOLCHAIN)objcopy
OS := $(TOOLCHAIN)size

# Linker script location.
LDSCRIPT       := ./src/ld/esp32.ld

# Set C/LD/AS flags.
CFLAGS += $(INC) -Wall -std=gnu11 -nostdlib $(CFLAGS_PLATFORM) $(COPT)
# (Allow access to the same memory location w/ different data widths.)
CFLAGS += -fno-strict-aliasing
CFLAGS += -fdata-sections -ffunction-sections
CFLAGS += -Os -g

ESP_IDF_PATH := $(HOME)/esp/esp-idf

CFLAGS += -I.
CFLAGS += -I$(ESP_IDF_PATH)
CFLAGS += -I$(ESP_IDF_PATH)/components
CFLAGS += -I$(ESP_IDF_PATH)/components/soc/include
CFLAGS += -I$(ESP_IDF_PATH)/components/soc/esp32/include
CFLAGS += -I$(ESP_IDF_PATH)/components/esp_common/include
CFLAGS += -I$(ESP_IDF_PATH)/components/esp_rom/include
CFLAGS += -I$(ESP_IDF_PATH)/components/esp_hw_support/include
CFLAGS += -I$(ESP_IDF_PATH)/components/esp_system/include

# Uncomment to view include paths for debugging
CFLAGS += -v

LDFLAGS += -nostdlib -T$(LDSCRIPT) -Wl,-Map=$@.map -Wl,--cref -Wl,--gc-sections
LDFLAGS += $(LDFLAGS_PLATFORM)
LDFLAGS += -lm -lc -lgcc

ASFLAGS += -c -O0 -Wall -fmessage-length=0
ASFLAGS += $(ASFLAGS_PLATFORM)

# Set C source files.
C_SRC := $(shell find ./src -name '*.c')

# Define object files
OBJS := $(patsubst ./src/%.c,./bin/objs/%.o,$(C_SRC))

# Set the first rule in the file to 'make all'
.PHONY: all
all: ./bin/main.elf

# Rules to build files.
./bin/objs/%.o: ./src/%.S
	@mkdir -p $(dir $@)
	$(CC) -x assembler-with-cpp $(ASFLAGS) $< -o $@

./bin/objs/%.o: ./src/%.c
	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

./bin/main.elf: $(OBJS)
	@mkdir -p ./bin
	$(CC) $^ $(LDFLAGS) -o $@

./bin/main.hex: ./bin/main.elf
	$(OC) -O ihex $< $@

.PHONY: all
all: ./bin/main.elf ./bin/main.hex

.PHONY: clean
clean:
	rm -rf ./bin

# Print variables for debugging
print-%:
	@echo '$*=$($*)'