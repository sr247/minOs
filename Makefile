AFLAGS=-f elf64
EXEC=kernel
ASM=nasm

kernel.bin: linker.ld multiboot_header.o boot.o
	ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o

multiboot_header.o: multiboot_header.asm
	$(ASM) $(AFLAGS) multiboot_header.asm

boot.o: boot.asm
	$(ASM) $(AFLAGS) boot.asm

.PHONY: all create clean kernel

kernel: kernel.bin

all:
	$(EXEC)

@create:
	$(all)
	cp kernel.bin iso_minosv1/boot/
	grub-mkrescue -o minos.iso iso_minosv1/

clean:
	rm -rf *.o *.bin multiboot_header boot
