CC = /tmp/xpack-riscv-none-elf-gcc-13.2.0-2/bin/riscv-none-elf-gcc
OBJCOPY = /tmp/xpack-riscv-none-elf-gcc-13.2.0-2/bin/riscv-none-elf-objcopy

CFLAGS = -march=rv32imc_zicsr -mabi=ilp32 -O2 -nostdlib -ffreestanding
LDFLAGS = -T ../common/link.ld -nostdlib -ffreestanding

%.elf: ../common/start.S %.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.hex: %.bin
	hexdump -v -e '1/4 "%08x\n"' $< > $@

clean:
	rm -f *.elf *.bin *.hex
