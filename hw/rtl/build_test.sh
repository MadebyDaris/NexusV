#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
XHEEP="$ROOT/hw/ext_xheep"

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

verilator --cc --exe --build -Wno-DECLFILENAME -Wno-EOFNEWLINE -Wno-fatal $INCFLAGS --top-module cvxif_nexus_shell tb_cvxif.cpp "$XHEEP/hw/vendor/openhwgroup/cv32e40x/rtl/include/cv32e40x_pkg.sv" cvxif_nexus_shell.sv
./obj_dir/Vcvxif_nexus_shell
