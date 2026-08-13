# NexusV Full-System Simulation Complete Guide

After struggling for hours to get this working, here are some key 
findings and what I ended up doing to get it working. If you 
prefer a quick start, go to the "Quick run inst" section, but be sure to 
read the rest of the notes to fully understand what is going on.

## Quick run inst

```bash
# 1. Compile bare-metal test
cd sw/custom_c
make -f <(echo 'all:; riscv-none-elf-gcc -march=rv32imc_zicsr -mabi=ilp32 -O2 -nostdlib -T link.ld start.S minimal.c -o minimal.elf && riscv-none-elf-objcopy -O binary minimal.elf minimal.bin && hexdump -v -e "1/4 %08x\n" minimal.bin > minimal.hex')

# 2. Build full-system simulation
cd ../..
bash hw/tb_veril/build_nexus_sim.sh

# 3. Run
./hw/tb_veril/obj_dir/Vtb_nexus_system
# Output: EXIT SUCCESS
```

## Two Critical Changes Required

### 1. CPU Boot Address (`BOOT_ADDR`)

**File:** `hw/ext_xheep/build/openhwgroup.org_systems_core-v-mini-mcu_1.0.5/src/openhwgroup.org_systems_core-v-mini-mcu_1.0.5/hw/core-v-mini-mcu/core_v_mini_mcu.sv`

**Line 321 Change from:**
```systemverilog
localparam BOOT_ADDR = core_v_mini_mcu_pkg::BOOTROM_START_ADDRESS; // 0x20010000
```
**To:**
```systemverilog
localparam BOOT_ADDR = 32'h00000000; // Skip BootROM, boot directly from SRAM
```

Also change the same line in `hw/ext_xheep/hw/core-v-mini-mcu/core_v_mini_mcu.sv` (the template
source this ensures the change survives `make mcu-gen` re-runs).

**Why:** The BootROM (`0x20010000`) is 59 words of pre-compiled RISC-V hex that expects
SOC_CTRL at a different base address than what our X-HEEP configuration has. The OBI bus register interface
adapter doesn't handle BootROM instruction fetches correctly in Verilator, causing the CPU
to hang on the first instruction. Bypassing the BootROM entirely and booting from SRAM
avoids this problem.

### 2. SRAM Load Path (via `$readmemh`)

**File:** `hw/tb_veril/tb_nexus_system.sv`

The `$readmemh` loads the hex file into SRAM at time 0 via the hierarchy path:
```systemverilog
u_top.u_x_heep.core_v_mini_mcu_i.memory_subsystem_i.ram0_i.tc_ram_i.sram
```

**Note:** Verilator flattens generate blocks. Do NOT include `gen_sram[0]` in the path.
The correct path goes through `memory_subsystem_i.ram0_i.tc_ram_i.sram` directly.

### 3. Linker Script

**File:** `sw/custom_c/link.ld`

```ld
MEMORY {
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0x8000
}
```

Since `BOOT_ADDR = 0x0`, the program must be linked at `0x0`. No padding needed.

### 4. Verilator Warnings Suppressed

**File:** `hw/tb_veril/build_nexus_sim.sh`

Added `-Wno-SYNCASYNCNET` to suppress warnings from the DPI `force` on
`testbench_set_exit_loop`.

## Key Findings

### Memory Map
```
0x00000000 - 0x00007FFF : Internal SRAM (32 KB)
0x0F0000000 - 0x0F1000000 : External slave (testbench exit peripheral)
0x20000000 - 0x2000FFFF : SOC_CTRL
0x20010000 - 0x2001FFFF : BootROM (59 words, pre-compiled hex)
0x20040000 - 0x2004FFFF : Power Manager
```

### Boot Flow (Before Patch)
1. CPU reset vector = `BOOT_ADDR = 0x20010000` (BootROM)
2. BootROM checks power manager at `0x20040000`
3. Reads `boot_select` from SOC_CTRL offset 8
4. With `boot_select = 0`: goes to `_jump_to_debug_rom`
5. Polls `exit_loop` register (SOC_CTRL offset 0x0C)
6. When set, reads `boot_address` (SOC_CTRL offset 0x10, default `0x180`)
7. Jumps to boot_address

### Boot Flow (After Patch)
1. CPU reset vector = `BOOT_ADDR = 0x00000000` (SRAM)
2. Executes user code directly — no BootROM involved

### Why DPI BootROM Bypass Failed
1. `prim_subreg_arb` uses `wr_en = we | de` — `de` alone should latch
2. But `testbench_set_exit_loop` signal is in `ifndef SYNTHESIS` block;
   after reset, the `always_ff` stops driving it, making it undriven
3. Verilator doesn't reliably propagate DPI-written values through
   combinational chains (`assign hw2reg.de = testbench_set_exit_loop`)
4. The signal's `force`/`release` caused SYNCASYNCNET errors
5. Bottom line: hierarchical DPI writes into deeply nested X-HEEP
   register chains are unreliable in Verilator

### CV-X-IF Limitation
The X-HEEP is configured with `CpuType = cv32e20` (CV32E20 / CVE2), which does
**not** support the CV-X-IF coprocessor interface. Custom instructions
(opcode 0x0B) cause illegal instruction exceptions.

The `cvxif_nexus_shell.sv` and `nexus_mux.sv` connect to an `if_xif` interface,
but the CPU core doesn't drive it.

**To use custom instructions:** Change `CpuType` to `cv32e40px` in the X-HEEP
configuration and re-run `make mcu-gen`.

To change the CpuType for the X-HEEP configuration, you can modify the default configuration file. The file you need to edit is: hw/ext_xheep/configs/general.hjson
On line 30, change `cpu_type: cv32e20` to `cpu_type: cv32e40px`.

### Build Note
The `build_nexus_sim.sh` script uses the FuseSoC-generated `.vc` file which
points to COPIED sources in:
```
hw/ext_xheep/build/openhwgroup.org_systems_core-v-mini-mcu_1.0.5/src/...
```
Any edits to sources in `hw/ext_xheep/hw/` must ALSO be applied to the
corresponding copies in the build directory.

## Working Test Suite

### Julia (65/65 tests)
```bash
julia --project=. tests/runtests.jl
```

### Verilator Datapath (`mac_plus_5`)
```bash
verilator --cc hw/rtl/mac_plus_5.sv --exe hw/tb_veril/tb_generated.cpp --top-module mac_plus_5
make -C obj_dir -f Vmac_plus_5.mk Vmac_plus_5
./obj_dir/Vmac_plus_5   # TEST PASSED
```

### Verilator Shell + Datapath
```bash
cd hw/rtl
verilator --cc cvxif_nexus_shell.sv mac_plus_5.sv --exe tb_cvxif.cpp --top-module cvxif_nexus_shell -I../ext_xheep/hw/vendor/openhwgroup/cv32e40x/rtl/include
make -C obj_dir -f Vcvxif_nexus_shell.mk Vcvxif_nexus_shell
./obj_dir/Vcvxif_nexus_shell   # ALL TESTS PASSED
```

### Verilator Mux (6 datapaths, 0 errors)
```bash
cd hw/rtl
verilator --cc nexus_mux.sv mac_plus_5.sv crc_step.sv primitives/nexus_simd_mac.sv primitives/nexus_saturating_add.sv primitives/nexus_barrett_reduction.sv primitives/nexus_mont_adapter.sv primitives/nexus_mont_multiplier.sv --top-module nexus_mux -Wno-UNSIGNED
# Elaboration: 0 errors
```

### Full-System Sim
```bash
bash hw/tb_veril/build_nexus_sim.sh
./hw/tb_veril/obj_dir/Vtb_nexus_system   # EXIT SUCCESS (minimal.c)
```
### Software (`sw/custom_c/`)
```
link.ld                      # 0x00000000, 32 KB SRAM
start.S                      # Minimal CRT: set SP, call main
minimal.c                    # Just write to exit address — ALWAYS WORKS
main.c                       # Smoke test hitting all 4 funct3 datapaths (needs X-IF CPU)
Makefile                     # Cross-compilation with riscv-none-elf-gcc
```