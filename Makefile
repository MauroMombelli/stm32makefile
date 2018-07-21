BINARY := test

CSTD=c11
CPPSTD=c++11
OPTIMIZATION=-Os

# this is where you dump the content of the std_periph's driver folder (inc and src together)
STDPERIPH := stm32f4xx_std_periph
# this is the conf file, come in the ST std_periph library but under the folder like "Project/STM32F4xx_StdPeriph_Templates"
# copy this file into the STDPERIPH folder
TARGETCONF := stm32f4xx.h
# the definition for your chip, this is a value that can be found in ST std_periph library, file with name similar to stm32f4xx.h
TARGETCHIP := STM32F40_41xxx

# change MCU and FPU depending on your target. Just search online your chip, you should find that info easy
TARGETMCU := -mcpu=cortex-m4 -mthumb
TARGETFPU := -mfloat-abi=softfp -mfpu=fpv4-sp-d16

# this is a custom made startup script. Should work with a bit everything.
# in C because who care about performance on startup? Better show waht is going on!
STARTUPSCRIPTDIR := utils
# you get the linker script from st peripheric library or from the cmsis
LINKERSCRIPT := utils/STM32F401VC_FLASH.ld

#END OF USER SECTION. MODIFY AT YOUR OWN RISK

# both CMSIS and STDPERIPH can be found inside the STDPERIPH that you can download from ST.
SOURCEDIR := src
BUILDDIR := build
CMSISDIR := cmsis

CC := arm-none-eabi-gcc
CPP := arm-none-eabi-gcc
LD := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy
OBJSIZE := arm-none-eabi-size

SOURCESC := $(shell find $(SOURCEDIR) -name '*.c') $(shell find $(STDPERIPH) -name '*.c') $(shell find $(STARTUPSCRIPTDIR) -name '*.c')
SOURCESCPP := $(shell find $(SOURCEDIR) -name '*.cpp')

CFLAGS  := -g -Wall -Wno-missing-braces -nostdlib $(OPTIMIZATION)
CFLAGS += $(TARGETMCU)
CFLAGS += $(TARGETFPU)
CFLAGS += -D $(TARGETCHIP) -DUSE_STDPERIPH_DRIVER
# I dont like to include TARGETCONF in all files, but would take too much to go around it
CFLAGS += -I $(SOURCEDIR) -I $(CMSISDIR) -I $(STDPERIPH) --include $(STDPERIPH)/$(TARGETCONF)

LDFLAGS := -Wl,-Map,$(BUILDDIR)/$(BINARY).map -g -T$(LINKERSCRIPT)

# create object list by adding .o at the end of .c and .cpp files
OBJECTS := ${SOURCESC:.c=.c.o} ${SOURCESCPP:.cpp=.cpp.o}
# change the directory from SOURCEDIR to BUILDDIR
OBJECTS := ${addprefix $(BUILDDIR)/,$(OBJECTS)}
#$(info OBJECTS is $(OBJECTS))

.DEFAULT_GOAL := $(BUILDDIR)/$(BINARY).bin

.PHONY: clean

# special case to build STARTUPSCRIPT
$(BUILDDIR)/$(STARTUPSCRIPTDIR)/%.c.o: $(STARTUPSCRIPTDIR)/%.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -std=$(CSTD) $(LDFLAGS) $(SOURCETREE) -c $< -o $@

# special case to build STDPERIPH
$(BUILDDIR)/$(STDPERIPH)/%.c.o: $(STDPERIPH)/%.c
	@echo "building $<"
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -std=$(CSTD) $(LDFLAGS) $(SOURCETREE) -c $< -o $@

# build USER's C
$(BUILDDIR)/$(SOURCEDIR)/%.c.o: $(SOURCEDIR)/%.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -std=$(CSTD) $(LDFLAGS) $(SOURCETREE) -c $< -o $@

# build USER's CPP
$(BUILDDIR)/$(SOURCEDIR)/%.cpp.o: $(SOURCEDIR)/%.cpp
	@mkdir -p $(@D)
	@$(CPP) $(CFLAGS) -std=$(CPPSTD) $(LDFLAGS) $(SOURCETREE) -c $< -o $@

# build ELF and print its size by section
$(BUILDDIR)/$(BINARY).elf: $(OBJECTS)
	@echo "linking ELF"
	@$(LD) $(CFLAGS) $(LDFLAGS) $(OBJECTS) -o $@
	@$(OBJSIZE) $@

#build the BIN from the ELF, ready to be uploaded
$(BUILDDIR)/$(BINARY).bin: $(BUILDDIR)/$(BINARY).elf
	@echo "extracting BIN"
	@$(OBJCOPY) -O binary $< $@

clean:
	rm -rf $(BUILDDIR)
