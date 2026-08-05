module NexusV

using MacroTools
using LLVM
using GPUCompiler

# ── Public API ────────────────────────────────────────────────────────────────
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
export DFGNode, HWGraph

# ── Internals ─────────────────────────────────────────────────────────────────

# Core components
include("Core/NexusV_macro.jl")
include("Core/DFG_Builder.jl")

# Compiler components
include("Compiler/NexusV_codegen.jl")
include("Compiler/NexusV_codegen_llvm.jl")

# Frontend components
include("Frontend/MockFrontend.jl")

end # module NexusV
