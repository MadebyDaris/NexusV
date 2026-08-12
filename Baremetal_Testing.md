# Baremetal Testing & Shell Integration — Status & Workflow

## Current Status (2026-08-12)

| Component | Status | Notes |
|---|---|---|
| Julia DFG → RTL generation | PASS | Multi-cycle scheduling, 10 opcodes, latency-aware |
| Datapath Verilator sim | PASS | `mac_plus_5`: 4-cycle latency, `rd_o=17` |
| Shell Verilator sim | PASS | `cvxif_nexus_shell` + `mac_plus_5`: `rd_o=205` |
| Full-system Verilator build | Builds | 781 modules, compiles successfully |
| Full-system simulation | WIP | SRAM loads correctly, CPU doesn't reach exit |
| Baremetal C cross-compile | Works | `test_mac.hex` generated |

## Prerequisites

- **Julia 1.9+** with `GPUCompiler`, `LLVM`, `MacroTools`
- **Verilator 5.x**
- **RISC-V GCC** (`riscv-none-elf-gcc`) — used at `/tmp/xpack-riscv-none-elf-gcc-13.2.0-2/bin/`
- **Python 3** with `hjson` (in X-HEEP's `.venv`)
- **X-HEEP submodule** initialized and `make mcu-gen` run

## Quick Verification (Working)

```bash
# 1. Julia: generate RTL from dataflow graph
julia --project=. tests/test_dfg.jl
# → Emits hw/rtl/mac_plus_5.sv (latency = 4 cycles)

# 2. Verilator: test generated datapath standalone
verilator --cc hw/rtl/mac_plus_5.sv \
  --exe hw/tb_veril/tb_generated.cpp \
  --top-module mac_plus_5
make -C obj_dir -f Vmac_plus_5.mk Vmac_plus_5
./obj_dir/Vmac_plus_5
# TEST PASSED (rd_o = 17)

# 3. Verilator: test shell + datapath integration
cd hw/rtl
verilator --cc cvxif_nexus_shell.sv mac_plus_5.sv \
  --exe tb_cvxif.cpp \
  --top-module cvxif_nexus_shell \
  --Mdir obj_dir_local \
  -I../ext_xheep/hw/vendor/openhwgroup/cv32e40x/rtl/include
make -C obj_dir_local -f Vcvxif_nexus_shell.mk Vcvxif_nexus_shell
./obj_dir_local/Vcvxif_nexus_shell
# ALL TESTS PASSED (rd_o = 205)
```

## Full-System Simulation (In Progress)

```bash
# 1. Compile baremetal test
cd sw/custom_c
make
# Produces test_mac.hex

# 2. Build full system
cd ../..
bash hw/tb_veril/build_nexus_sim.sh
# Builds successfully

# 3. Run
./hw/tb_veril/obj_dir/Vtb_nexus_system
# → SRAM loaded correctly (verified: SRAM[0]=00008137)
# → BootROM bypass triggered
# → CPU does not reach exit condition (known issue)
```

### Known Issue: CPU Not Reaching Exit

The SRAM is loaded correctly (verified via `$display`), and the BootROM bypass DPI call succeeds. However, the CPU does not execute through to the `EXIT_SUCCESS` write at `0xF0000000`. This is a pre-existing `nexus_top.sv` integration issue noted in the README roadmap item #1: "Fix nexus_top.sv — resolve interface naming bug and missing ports, run full-system simulation."

## Multi-Cycle Scheduling (New)

The scheduler now supports per-opcode latencies:

| Opcode | Latency | Resource Class |
|---|---|---|
| OP_ADD, OP_SUB | 1 | ALU |
| OP_MUL | 2 | MUL |
| OP_SHR, OP_SHL | 1 | SHIFT |
| OP_AND, OP_OR, OP_XOR | 1 | ALU |
| OP_MOD | 3 | DIV |

### Resource-Constrained Scheduling

`ResourceAllocator.jl` implements list scheduling with a resource budget:

```julia
include("hw/src_hw/ResourceAllocator.jl")

schedule_asap!(graph)  # First pass: set latencies
budget = ResourceBudget(:ALU => 2, :MUL => 1, :SHIFT => 1, :DIV => 1)
schedule_list!(graph, budget)  # Re-schedule with resource constraints
```

Operations sharing the same resource class are serialized so no unit is oversubscribed in any cycle.