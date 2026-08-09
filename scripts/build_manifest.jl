"""
scripts/build_manifest.jl

Build manifest → generate nexus_mux.sv.

Run this whenever you add a new datapath to the system.
Edit the `manifest` list below to add/remove datapaths.
"""

include("../src/Core/DFG_Builder.jl")
using .DFG_Builder

include("../hw/src_hw/Scheduler.jl")
include("../hw/src_hw/VerilogEmitter.jl")
include("../hw/src_hw/DispatcherEmitter.jl")

# ── Build Manifest ────────────────────────────────────────────────────────────
# Each entry maps a funct3 ID to a datapath module.
# funct3 0 is reserved for mac_plus_5 (the default).
# funct3 1–3 are available for primitives and custom graphs.

manifest = DatapathEntry[
    DatapathEntry("mac_plus_5",       0, 4, false, "mac_plus_5.sv"),
    DatapathEntry("crc_step",         1, 4, false, "crc_step.sv"),
    DatapathEntry("nexus_simd_mac",   2, 3, false, "primitives/nexus_simd_mac.sv"),
    DatapathEntry("nexus_saturating_add", 3, 2, false, "primitives/nexus_saturating_add.sv"),
]

# ── Generate ──────────────────────────────────────────────────────────────────
out_sv = joinpath(@__DIR__, "..", "hw", "rtl", "nexus_mux.sv")
emit_dispatcher(manifest, out_sv)
println("Done — $(length(manifest)) datapaths in mux")