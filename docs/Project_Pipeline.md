# NexusV Project Overview and Pipeline

This document gives a high-level view of the NexusV repository, the role of each subsystem, and the current development pipeline from Julia-based graph description to RTL generation and simulation.

## What NexusV is

NexusV is a research-oriented hardware generation toolchain for creating custom RISC-V coprocessor accelerators.

The core idea is simple:

1. Describe a computation as a dataflow graph in Julia.
2. Schedule the graph and emit pipelined SystemVerilog.
3. Connect the generated datapath to a CV-X-IF-compatible shell.
4. Simulate and integrate it with the X-HEEP ecosystem.

The result is a reusable accelerator template that can be tested as a standalone datapath or as part of a larger SoC integration flow.

## Repository Structure at a Glance

- `src/` — Julia implementation of the generator and frontend abstractions.
  - `src/NexusV.jl` — module entry point.
  - `src/Core/` — graph model, node definitions, and macro support.
  - `src/Compiler/` — experimental LLVM-oriented compiler work.
  - `src/Frontend/` — lightweight frontends and test helpers.
- `hw/` — hardware-specific assets and RTL-related code.
  - `hw/rtl/` — generated and hand-written RTL, including the CV-X-IF shell and integration top-level.
  - `hw/src_hw/` — scheduler and Verilog emitter logic.
  - `hw/ext_xheep/` — X-HEEP submodule used for integration testing.
  - `hw/tb_veril/` — Verilator testbench inputs and generated artifacts.
- `tests/` — Julia-based tests covering graph construction, scheduling, and RTL emission.
- `examples/` — example graphs and usage snippets.
- `docs/` — project documentation and workflow notes.
- `sw/` — software-side examples and custom C test scaffolding.

## End-to-End Pipeline

### 1. Frontend: describe the computation

The entry point is a Julia dataflow graph (`HWGraph`) with nodes representing operations such as:

- arguments
- constants
- arithmetic operations
- return nodes

The graph captures both the computation and the dependency structure between operations.

### 2. Scheduling

The scheduler (`Scheduler.jl`) assigns each operation to a clock cycle using an ASAP-style strategy. This produces a valid pipelined execution order and helps define latency.

### 3. RTL emission

The emitter (`VerilogEmitter.jl`) translates the scheduled graph into pipelined SystemVerilog. The generated module exposes a simple datapath-style interface:

- `clk_i`
- `rst_ni`
- `start_i`
- `rs1_i`
- `rs2_i`
- `rd_o`
- `done_o`

This becomes the reusable hardware block that the shell can invoke.

### 4. Shell integration

The hand-written shell (`hw/rtl/cvxif_nexus_shell.sv`) bridges between the CPU-facing CV-X-IF protocol and the generated datapath. It handles the handshake and mediates the issue/commit/result flow.

The integration top (`hw/rtl/nexus_top.sv`) connects:

- the X-HEEP CPU-side interface
- the shell
- the generated datapath

### 5. Simulation and testing

The repository currently supports:

- standalone datapath simulation with Verilator
- shell-level testbenches for the CV-X-IF protocol FSM
- Julia-based tests for graph scheduling and RTL emission

The typical simulation loop is:

1. Build or update the Julia graph.
2. Run the Julia test or emitter script.
3. Compile the generated RTL with Verilator.
4. Run the relevant C++ or SystemVerilog testbench.
5. Inspect waveforms if the behavior needs debugging.

## Current Development Flow

A typical developer workflow looks like this:

```text
Julia graph definition
  -> scheduler
  -> RTL emission
  -> Verilator simulation
  -> shell / integration validation
  -> optional X-HEEP system-level integration
```

## Key Files and Their Roles

| Area | Important paths |
|---|---|
| Julia entry point | `src/NexusV.jl` |
| Graph model | `src/Core/DFG_Builder.jl` |
| Macro support | `src/Core/NexusV_macro.jl` |
| Scheduler | `hw/src_hw/Scheduler.jl` |
| RTL emitter | `hw/src_hw/VerilogEmitter.jl` |
| Example graph | `examples/example.jl` |
| Generated sample datapath | `hw/rtl/mac_plus_5.sv` |
| CV-X-IF shell | `hw/rtl/cvxif_nexus_shell.sv` |
| Integration top | `hw/rtl/nexus_top.sv` |
| End-to-end Julia test | `tests/test_dfg.jl` |
| Hardware workflow doc | `docs/HW_Usage_Workflow.md` |

## Current Status

The repository already contains a working proof of concept for:

- Julia-defined dataflow graphs
- scheduling and RTL emission
- a simple generated datapath
- CV-X-IF shell-level verification

The integration path into full X-HEEP system simulation is still a work in progress and is documented in the hardware workflow notes.

## Suggested Contribution Pattern

When making changes to the project:

1. Keep the high-level pipeline intact: graph -> schedule -> emit -> simulate.
2. Prefer small, testable changes in the generator and RTL logic.
3. Update documentation when behavior or workflow changes.
4. Keep generated artifacts out of version control by relying on the repository ignore rules.

## Next Steps

Likely follow-up work includes:

- improving the full X-HEEP integration path
- adding more datapath examples
- expanding the shell dispatcher logic
- validating more complex custom instructions
- adding more end-to-end regression tests
