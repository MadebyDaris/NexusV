# 1. Hardware Technology Stack

- Target Core: CV32E40X (inside X-HEEP) – natively supports CV-X-IF.
- Hardware Description Language: SystemVerilog (IEEE 1800-2017). Synthesizable, professional grade.
- Generation Engine: Julia (specifically IO streams and string interpolation to write .sv files dynamically).
- Simulation Engine: Verilator (Translates RTL to C++ for massive speedups) + standard GCC for the RISC-V software.
- Waveform Viewing: GTKWave or Surfer (to inspect FST/VCD dumps of your accelerators).

# Introduction

We will use the Core-V eXtension interface,or for short CV-X-IF, aimed primarly at extending a CPU with (custom or standardized) instructions implemented in a coprocessor.

The goal of CV-X-IF is to enable the design and verification of instruction extensions in a coprocessor in a standardized manner without the need to modify the CPU itself. Having a common interface allows designers of RISC-V CPUs to reuse existing co-processor and vice versa. Please note that the CPU and coprocessor can have different license models. For example, the coprocessor could be closed source, connected to an open-source CPU.

This project consists of two main concepts: The Shell and the Generated Datapaths.

# The duality of NexusV hardware
## The Shell (The Docking Station)

It consists of three parallel finite state machines (FSMs) compliant with the OpenHW CV-X-IF standard:
1. Issue Interface: Receives the instruction opcode, rs1, rs2, and an ID tag from the CPU.
2. Commit/Kill Interface: The CPU tells your hardware, "Instruction ID 4 is committed, you can write the result," OR "Instruction ID 4 was a branch misprediction, flush it."
3. Result Interface: Pushes the final rd (Destination Register) data back to the CPU pipeline.

## The RTL Emitter & Datapaths (The Xtensa Magic)
When given a final optimized Data Flow Graph (DFG) of an instruction,nu;erous steps must be taken,

1. Schedule: Determine how many clock cycles the operation needs. If it's a massive Kyber modular multiplication, maybe it takes 3 clock cycles. Your Julia script inserts pipeline registers automatically.

2. Allocate: Map the DFG nodes to hardware. A DFG * node becomes assign res = a * b; in Verilog.

3. Emit & Route: The tool generates a new .sv file for the math. It then updates nexus_mux.sv to route the specific custom opcode (e.g., CUSTOM_0) to this new datapath.