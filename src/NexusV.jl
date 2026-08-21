module NexusV

using MacroTools
using LLVM
using GPUCompiler

# Public API
# Core macros
export @nexus_accelerate

# LLVM code generation
export get_llvm_module, get_llvm_ir

# Optimization passes
export apply_unroll_pass

# Loop annotation macro
export @nexus_unroll

# Hint registry helpers (useful for tests / downstream tooling)
export register_unroll_hint!, get_unroll_hint, clear_unroll_hints!

# DFG types
export Opcode, OP_ARG, OP_CONST, OP_ADD, OP_SUB, OP_MUL, OP_RET
export OP_SHR, OP_SHL, OP_AND, OP_OR, OP_XOR, OP_MOD, OP_MUX
export DFGNode, HWGraph, OP_LATENCY

# HW Generation
export schedule_asap!, topological_sort, finish_cycle
export schedule_list!, ResourceBudget
export emit_verilog
export emit_dispatcher, DatapathEntry
export PrimitiveSpec, PRIMITIVES, register_primitive!

# Internals

# Core components
include("Core/NexusV_macro.jl")
include("Core/DFG_Builder.jl")
using .DFG_Builder

# Compiler components
include("Compiler/NexusV_codegen.jl")
include("Compiler/NexusV_codegen_llvm.jl")

# Frontend components
include("Frontend/MockFrontend.jl")

# Hardware Generation
include("HWGen/PrimitiveLibrary.jl")
include("HWGen/Scheduler.jl")
include("HWGen/ResourceAllocator.jl")
include("HWGen/VerilogEmitter.jl")
include("HWGen/DispatcherEmitter.jl")

end # module NexusV