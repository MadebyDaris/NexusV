#!/usr/bin/env bash
# build_nexus_sim.sh
#
# Stand-alone Verilator build script for tb_nexus_system.
# Compiles nexus_top + cvxif_nexus_shell + mac_plus_5 + the OBI SRAM testbench,
# driving it all via tb_nexus_system.cpp.
#
# Usage: bash hw/tb_veril/build_nexus_sim.sh   (from NexusV root)

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
XHEEP="$ROOT/hw/ext_xheep"
RTL="$ROOT/hw/rtl"
TB="$ROOT/hw/tb_veril"
OUT="$ROOT/hw/tb_veril/obj_dir"

echo "=== NexusV Verilator Build Process ==="
echo "Root: $ROOT"

# 1. Collect all SystemVerilog include directories
INCDIRS=(
    "$XHEEP/hw/core-v-mini-mcu/include"
    "$XHEEP/hw/vendor/lowrisc/opentitan/hw/ip/prim/rtl"
    "$XHEEP/hw/vendor/lowrisc/opentitan/hw/ip/prim_generic/rtl"
    "$XHEEP/hw/vendor/pulp_platform/register_interface/include"
    "$XHEEP/hw/vendor/pulp_platform/register_interface/src"
    "$XHEEP/hw/vendor/pulp_platform/common_cells/include"
    "$XHEEP/hw/vendor/openhwgroup/cve2/rtl"
    "$XHEEP/hw/vendor/openhwgroup/cve2/bhv"
    "$XHEEP/hw/vendor/openhwgroup/cv32e40p/rtl/include"
    "$XHEEP/hw/vendor/openhwgroup/cv32e40px/rtl/include"
)

INCFLAGS=""
for d in "${INCDIRS[@]}"; do
    [ -d "$d" ] && INCFLAGS="$INCFLAGS -I$d"
done

# 2. Extract Verilator arguments from FuseSoC output
VC_IN="$XHEEP/build/openhwgroup.org_systems_core-v-mini-mcu_1.0.5/sim-verilator/openhwgroup.org_systems_core-v-mini-mcu_1.0.5.vc"
VC_OUT="$OUT/filtered.vc"

mkdir -p "$OUT"

if [ ! -f "$VC_IN" ]; then
    echo "[ERROR] FuseSoC .vc file not found at $VC_IN"
    echo "Did you run 'make mcu-gen' successfully?"
    exit 1
fi

python3 "$TB/gen_vc.py" "$VC_IN" "$VC_OUT"

# 3. Run Verilator
echo "--- Running Verilator ---"
verilator \
    --cc \
    --timing \
    --exe "$TB/tb_nexus_system.cpp" \
    --top-module tb_nexus_system \
    --Mdir "$OUT" \
    --trace \
    --assert \
    -Wall \
    -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-UNUSED -Wno-PINCONNECTEMPTY \
    -Wno-UNDRIVEN -Wno-LITENDIAN -Wno-IMPLICIT \
    -Wno-IMPORTSTAR -Wno-VARHIDDEN -Wno-EOFNEWLINE \
    -Wno-ASSIGNIN -Wno-PINMISSING -Wno-UNOPTFLAT -Wno-DECLFILENAME \
    --language 1800-2012 \
    -f "$VC_OUT" \
    "$RTL/mac_plus_5.sv" \
    "$RTL/cvxif_nexus_shell.sv" \
    "$RTL/nexus_top.sv" \
    "$TB/tb_nexus_system.sv" \
    2>&1

echo "--- Compiling generated C++ ---"
make -C "$OUT" -f Vtb_nexus_system.mk Vtb_nexus_system 2>&1

echo "=== Build complete: $OUT/Vtb_nexus_system ==="
