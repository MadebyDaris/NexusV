// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VCVXIF_NEXUS_SHELL__SYMS_H_
#define VERILATED_VCVXIF_NEXUS_SHELL__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vcvxif_nexus_shell.h"

// INCLUDE MODULE CLASSES
#include "Vcvxif_nexus_shell___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vcvxif_nexus_shell__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vcvxif_nexus_shell* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vcvxif_nexus_shell___024root   TOP;

    // CONSTRUCTORS
    Vcvxif_nexus_shell__Syms(VerilatedContext* contextp, const char* namep, Vcvxif_nexus_shell* modelp);
    ~Vcvxif_nexus_shell__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
