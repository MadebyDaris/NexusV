// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcvxif_nexus_shell.h for the primary calling header

#include "Vcvxif_nexus_shell__pch.h"

void Vcvxif_nexus_shell___024root___ctor_var_reset(Vcvxif_nexus_shell___024root* vlSelf);

Vcvxif_nexus_shell___024root::Vcvxif_nexus_shell___024root(Vcvxif_nexus_shell__Syms* symsp, const char* namep)
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vcvxif_nexus_shell___024root___ctor_var_reset(this);
}

void Vcvxif_nexus_shell___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vcvxif_nexus_shell___024root::~Vcvxif_nexus_shell___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
