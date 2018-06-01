arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso := build/minos-$(arch).iso

linker := src/debian/$(arch)/linker.ld
grub_cfg := src/debian/$(arch)/grub.cfg
sources := $(wildcard src/debian/$(arch)/*.asm)
objects := $(patsubst src/debian/$(arch)/%.asm, \
    build/debian/$(arch)/%.o, $(sources))

.PHONY: all clean run iso

all: $(kernel)

clean:
	rm -r build

run: $(iso)
	qemu-system-x86_64 -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	mkdir -p build/isofiles/boot/grub
	cp $(kernel) build/isofiles/boot/kernel.bin
	cp $(grub_cfg) build/isofiles/boot/grub
	grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	rm -r build/isofiles

$(kernel): $(objects)
	ld -n -T $(linker) -o $(kernel) $(objects)

# compile assembly files
build/debian/$(arch)/%.o: src/debian/$(arch)/%.asm
	mkdir -p $(shell dirname $@)
	nasm -felf64 $< -o $@
