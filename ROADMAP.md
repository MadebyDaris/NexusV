# NexusV — Ambitious Roadmap & Future Ideas

## Current Status (2026-08-13)

### What Works End-to-End
| Component | Status |
|---|---|
| Julia DFG → RTL (multi-cycle, 13 opcodes) | ✅ |
| VerilogEmitter (canonical 2-input + stall_i interface) | ✅ |
| ASAP scheduler (latency-aware) | ✅ |
| Resource-constrained list scheduler | ✅ |
| DispatcherEmitter (auto-generate nexus_mux.sv) | ✅ |
| Datapath Verilator sim (mac_plus_5) | ✅ PASS |
| Shell Verilator sim (cvxif_nexus_shell + datapath) | ✅ PASS |
| Mux elaboration (6 datapaths behind mux) | ✅ 0 errors |
| Barrett reduction (sequential FSM wrapper) | ✅ |
| Montgomery adapter (canonical iface → internal memory ports) | ✅ |
| Skid buffer (clean valid/ready, no stall_i) | ✅ |
| AXI-Lite master (clock bug fixed) | ✅ |
| Julia runtests.jl (65 tests) | ✅ |
| bare-metal C cross-compilation (RISC-V GCC) | ✅ |
| Stall_i threaded through entire stack | ✅ |

### WIP
| Component | Status |
|---|---|
| Full-system X-HEEP sim (nexus_top + main.c) | ⚠️ Code loads at 0x180, BootROM DPI works, CPU stalls before exit |

---

## 🔥 Tier 1 — Low-Hanging Fruit (1–2 days each)

### 1.1 Fix Full-System Simulation
**Root cause candidate:** The BootROM bypass DPI may not propagate correctly through the soc_ctrl register hierarchy. The original X-HEEP testbench loads firmware via debug unit (`tb_loadHEX`) and sets `exit_loop` AFTER reset. Try:
- Use the debug unit (JTAG DPI) to load SRAM instead of `$readmemh`
- Set `exit_loop` after reset release (matching X-HEEP's tb_top.sv timing)
- Add VCD probes on `soc_ctrl.reg2hw.boot_exit_loop.q` to verify DPI propagation

### 1.2 Run `main.c` PoC Smoke Test Through Sim
Once the CPU boots, `main.c` hits all 4 funct3 datapaths and prints PASS/FAIL.

### 1.3 Barrett Reduction Verification
- Write a Julia testbench that compares `nexus_barrett_reduction` output against Julia's `%` operator
- Add to `runtests.jl`

### 1.4 SIMD MAC Testbench
- Write a C++ Verilator testbench for `nexus_simd_mac` (packed inputs, expected accumulated output)
- Add to CI

---

## 🚀 Tier 2 — Feature Expansion (3–7 days each)

### 2.1 Conditional Select Opcode (OP_SEL)
Already have `OP_MUX` — expand to `OP_SEL` with comparison operators (`OP_EQ`, `OP_LT`, `OP_GTU`). Enables:
- Saturating arithmetic in generic graphs
- CRC with proper conditional XOR
- Min/max reduction

### 2.2 Stateful Datapath Support in Mux
Add a second architectural class in `nexus_mux.sv` for "Stateful Multi-Instruction" datapaths:
- `is_stateful` flag in `DatapathEntry` already exists
- Stateful datapaths need extra ports: `cmd_i`, `addr_i`, `len_i`
- Mux routes these based on `funct3`

### 2.3 Scratchpad-Driven Primitives
Wire `nexus_scratchpad.sv` behind the AXI-Lite master:
- Tier 3 graphs (array reduction, NTT butterfly, dot product) need scratchpad
- CPU streams data in via custom instructions, primitive reads/writes scratchpad

### 2.4 Barrett + Montgomery as Hardware Graphs
Instead of black-box primitives, decompose Barrett reduction into generic DFG nodes (`OP_MUL`, `OP_SHR`, `OP_SUB`, `OP_MUX`). The scheduler handles pipelining automatically — proves the scheduler can handle real algorithms.

### 2.5 Automated Resource Sharing in Emitter
If 10 `OP_ADD` exist across 10 cycles, instantiate ONE physical adder + mux. The emitter already tracks per-cycle usage; add:
- `resource_usage_timeline` from `ResourceAllocator`
- Generate shared functional units + input muxing

---

## 🏗️ Tier 3 — Architectural Upgrades (2–4 weeks each)

### 3.1 Shell-Level Pipelining (Out-of-Order Issue)
Current shell FSM: one instruction at a time (IDLE → WAIT_COMMIT → WAIT_DATAPATH → SEND_RESULT).
- Use CV-X-IF's `id` field to track multiple in-flight instructions
- Accept new instruction while previous ones drain through pipeline
- Result queue for out-of-order completion
- **Metrics to publish:** instructions/cycle before vs. after

### 3.2 Chained Execution (Fused Custom Instructions)
Allow a sequence of custom instructions to chain without CPU intervention:
- First instruction loads operands
- Second instruction triggers compute
- Third instruction reads result
- Shell FSM tracks the sequence state

### 3.3 DMA Engine for Bulk Data
Add a DMA controller that moves data between SRAM and scratchpad:
- CPU writes DMA descriptor (src, dst, len) via custom instruction
- DMA engine transfers data independently
- CV-X-IF memory channel for DMA ↔ SRAM

### 3.4 LLVM → DFG Frontend (Revive)
The `@nexus_accelerate` macro and GPUCompiler pipeline exist but need an LLVM → `HWGraph` translation layer:
- LLVM IR → dataflow graph extraction
- Loop unrolling → parallel ops in DFG
- Memory ops → scratchpad load/store nodes

---

## 🔮 Tier 4 — Ambitious / Research-Grade (months)

### 4.1 Kyber / NTT Hardware Accelerator
- Full NTT butterfly in hardware (multiplicative + additive transforms)
- Barrett reduction for modular arithmetic
- Montgomery multiplication for fast modular multiply
- Scratchpad for coefficient storage
- **Demonstrator:** Kyber-512 encapsulation in hardware

### 4.2 Multi-Core Nexus Fabric
- Multiple X-HEEP cores, each with its own NexusV coprocessor
- Shared scratchpad via AXI interconnect
- Work-stealing scheduler in software

### 4.3 ML Inference Accelerator
- SIMD MAC arrays (4×4, 8×8) for matrix multiply
- Activation function primitives (ReLU, sigmoid via LUT)
- Quantization support (INT8, INT4)
- **Target:** TinyML models (MobileNetV1 at 250MHz)

### 4.4 FPGA Bitstream Generation
- Auto-generate FPGA constraints + bitstream from `nexus_mux` manifest
- Target: Xilinx Artix-7 / Lattice ECP5
- PPA analysis: compare ASIC vs. FPGA for each datapath

### 4.5 High-Level Synthesis (HLS) Bridge
- Export `HWGraph` → C++ for Catapult HLS / Vivado HLS
- Compare NexusV-generated RTL against HLS output (area, latency, Fmax)

---

## 📋 Tooling & Infrastructure

### 5.1 CI/CD Pipeline
- GitHub Actions: Julia tests + Verilator elaboration on every push
- Golden file tests for generated RTL (diff against baseline)
- Weekly full-system regression with bare-metal C tests

### 5.2 PPA Analysis Harness
- Yosys synthesis → area + cell count
- OpenSTA → timing analysis → Fmax
- Sweep resource budgets (1 ALU vs. 2 ALUs, 1 MUL vs. 2 MULs)

### 5.3 Documentation Site
- Documentarian.jl or Docsify for auto-generated API docs
- Tutorial: "Your First Custom Instruction" (Julia → RTL → Sim)
- Gallery of example datapaths with waveforms

### 5.4 Package Registration
- Register `NexusV.jl` in Julia General Registry
- Versioned releases with Semantic Versioning
- `] add NexusV` for any Julia user

---

## 🧪 Research Questions Worth Exploring

1. **Can the scheduler optimize for Fmax?** — Artificially pipeline deep combinational paths to meet timing.
2. **Can we do cross-datapath resource sharing?** — If `mac_plus_5` and `crc_step` both use a multiplier, share it.
3. **What's the smallest CV-X-IF coprocessor that's still useful?** — Single-instruction accelerators vs. full subgraph accelerators.
4. **Can we auto-partition between CPU and coprocessor?** — Profile a C function, identify hot DFG subgraphs, offload to NexusV.

---

## Immediate Next Steps (Ordered by Impact)

1. **Fix full-system sim** — VCD analysis of CPU PC / BootROM execution (highest priority)
2. **Run `main.c` PoC** — prove end-to-end: C → custom instruction → datapath → result
3. **Barrett + SIMD MAC Verilator testbenches** — standalone verification before integration
4. **Resource sharing in emitter** — immediate area savings for multi-op graphs
5. **`@nexus_accelerate` revival** — connect the LLVM frontend to the DFG backend