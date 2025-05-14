CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld
AS = arm-none-eabi-as
OBJCOPY = arm-none-eabi-objcopy
QEMU = qemu-system-arm

CFLAGS = -g
LDFLAGS = -Ttext=0x00000000

all: bootloader.elf bootloader.bin

bootloader.elf: bootloader.o
	$(LD) $(LDFLAGS) -o $@ $^

bootloader.o: bootloader.s
	$(AS) $(CFLAGS) -o $@ $<

bootloader.bin: bootloader.elf
	$(OBJCOPY) -O binary $< $@

run: bootloader.elf
	$(QEMU) -M versatilepb -kernel bootloader.elf -serial mon:stdio \
	-display gtk,gl=off -cpu arm926 -m 128M \
	-nodefaults -vga none -no-reboot -no-shutdown \
	-audiodev driver=none,id=audio0 -nographic

clean:
	rm -f bootloader.o bootloader.elf bootloader.bin
