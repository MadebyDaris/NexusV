// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vcvxif_nexus_shell__pch.h"

Vcvxif_nexus_shell__Syms::Vcvxif_nexus_shell__Syms(VerilatedContext* contextp, const char* namep, Vcvxif_nexus_shell* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(250);
    // Setup sub module instances
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-12);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
}

Vcvxif_nexus_shell__Syms::~Vcvxif_nexus_shell__Syms() {
    // Tear down scopes
    // Tear down sub module instances
}
