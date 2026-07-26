// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vcvxif_nexus_shell.h for the primary calling header

#ifndef VERILATED_VCVXIF_NEXUS_SHELL___024ROOT_H_
#define VERILATED_VCVXIF_NEXUS_SHELL___024ROOT_H_  // guard

#include "verilated.h"


class Vcvxif_nexus_shell__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vcvxif_nexus_shell___024root final {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk_i,0,0);
    VL_IN8(rst_ni,0,0);
    VL_IN8(x_issue_req_valid_i,0,0);
    VL_OUT8(x_issue_req_ready_o,0,0);
    VL_IN8(x_issue_req_id_i,4,0);
    VL_OUT8(x_issue_resp_valid_o,0,0);
    VL_OUT8(x_issue_resp_accept_o,0,0);
    VL_OUT8(x_issue_resp_id_o,4,0);
    VL_IN8(x_commit_valid_i,0,0);
    VL_IN8(x_commit_id_i,4,0);
    VL_IN8(x_commit_kill_i,0,0);
    VL_OUT8(x_result_valid_o,0,0);
    VL_IN8(x_result_ready_i,0,0);
    VL_OUT8(x_result_id_o,4,0);
    VL_OUT8(x_result_rd_o,4,0);
    CData/*1:0*/ cvxif_nexus_shell__DOT__state_q;
    CData/*1:0*/ cvxif_nexus_shell__DOT__state_n;
    CData/*4:0*/ cvxif_nexus_shell__DOT__saved_id_q;
    CData/*4:0*/ cvxif_nexus_shell__DOT__saved_rd_addr_q;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VstlPhaseResult;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VicoPhaseResult;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk_i__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rst_ni__0;
    CData/*0:0*/ __VactPhaseResult;
    CData/*0:0*/ __VnbaPhaseResult;
    VL_IN(x_issue_req_instr_i,31,0);
    VL_IN(x_issue_req_rs1_i,31,0);
    VL_IN(x_issue_req_rs2_i,31,0);
    VL_OUT(x_result_data_o,31,0);
    IData/*31:0*/ cvxif_nexus_shell__DOT__saved_rs1_q;
    IData/*31:0*/ cvxif_nexus_shell__DOT__saved_rs2_q;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vcvxif_nexus_shell__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vcvxif_nexus_shell___024root(Vcvxif_nexus_shell__Syms* symsp, const char* namep);
    ~Vcvxif_nexus_shell___024root();
    VL_UNCOPYABLE(Vcvxif_nexus_shell___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
