CC = /tmp/xpack-riscv-none-elf-gcc-13.2.0-2/bin/riscv-none-elf-gcc
OBJCOPY = /tmp/xpack-riscv-none-elf-gcc-13.2.0-2/bin/riscv-none-elf-objcopy

CFLAGS = -march=rv32imc_zicsr -mabi=ilp32 -O2 -nostdlib -ffreestanding
LDFLAGS = -T link.ld -nostdlib -ffreestanding

all: main.hex

# ── PoC smoke test (hits all 4 funct3 datapaths) ─────────────────────────
main.elf: start.S main.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

main.bin: main.elf
	$(OBJCOPY) -O binary $< $@

main.hex: main.bin
	hexdump -v -e '1/4 "%08x\n"' $< > $@

# ── Old single-datapath test ──────────────────────────────────────────────
test_mac.elf: start.S test_mac.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

test_mac.bin: test_mac.elf
	$(OBJCOPY) -O binary $< $@

test_mac.hex: test_mac.bin
	hexdump -v -e '1/4 "%08x\n"' $< > $@

clean:
	rm -f *.elf *.bin *.hex