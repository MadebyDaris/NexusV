// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcvxif_nexus_shell.h for the primary calling header

#include "Vcvxif_nexus_shell__pch.h"

void Vcvxif_nexus_shell___024root___eval_triggers_vec__ico(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_triggers_vec__ico\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(vlSelfRef.__VicoFirstIteration)));
}

bool Vcvxif_nexus_shell___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___trigger_anySet__ico\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vcvxif_nexus_shell___024root___ico_sequent__TOP__0(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___ico_sequent__TOP__0\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.x_issue_resp_id_o = vlSelfRef.x_issue_req_id_i;
    vlSelfRef.x_issue_resp_valid_o = 0U;
    vlSelfRef.x_issue_resp_accept_o = 0U;
    vlSelfRef.cvxif_nexus_shell__DOT__state_n = vlSelfRef.cvxif_nexus_shell__DOT__state_q;
    if ((0U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
        if (vlSelfRef.x_issue_req_valid_i) {
            vlSelfRef.x_issue_resp_valid_o = 1U;
            if ((0x0bU == (0x0000007fU & vlSelfRef.x_issue_req_instr_i))) {
                vlSelfRef.x_issue_resp_accept_o = 1U;
                vlSelfRef.cvxif_nexus_shell__DOT__state_n = 1U;
            } else {
                vlSelfRef.x_issue_resp_accept_o = 0U;
            }
        }
    } else if ((1U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
        if (((IData)(vlSelfRef.x_commit_valid_i) & 
             ((IData)(vlSelfRef.x_commit_id_i) == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q)))) {
            vlSelfRef.cvxif_nexus_shell__DOT__state_n 
                = ((IData)(vlSelfRef.x_commit_kill_i)
                    ? 0U : 2U);
        }
    } else if ((2U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
        if (vlSelfRef.x_result_ready_i) {
            vlSelfRef.cvxif_nexus_shell__DOT__state_n = 0U;
        }
    }
}

void Vcvxif_nexus_shell___024root___eval_ico(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_ico\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VicoTriggered[0U])) {
        vlSelfRef.x_issue_resp_id_o = vlSelfRef.x_issue_req_id_i;
        vlSelfRef.x_issue_resp_valid_o = 0U;
        vlSelfRef.x_issue_resp_accept_o = 0U;
        vlSelfRef.cvxif_nexus_shell__DOT__state_n = vlSelfRef.cvxif_nexus_shell__DOT__state_q;
        if ((0U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
            if (vlSelfRef.x_issue_req_valid_i) {
                vlSelfRef.x_issue_resp_valid_o = 1U;
                if ((0x0bU == (0x0000007fU & vlSelfRef.x_issue_req_instr_i))) {
                    vlSelfRef.x_issue_resp_accept_o = 1U;
                    vlSelfRef.cvxif_nexus_shell__DOT__state_n = 1U;
                } else {
                    vlSelfRef.x_issue_resp_accept_o = 0U;
                }
            }
        } else if ((1U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
            if (((IData)(vlSelfRef.x_commit_valid_i) 
                 & ((IData)(vlSelfRef.x_commit_id_i) 
                    == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q)))) {
                vlSelfRef.cvxif_nexus_shell__DOT__state_n 
                    = ((IData)(vlSelfRef.x_commit_kill_i)
                        ? 0U : 2U);
            }
        } else if ((2U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
            if (vlSelfRef.x_result_ready_i) {
                vlSelfRef.cvxif_nexus_shell__DOT__state_n = 0U;
            }
        }
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcvxif_nexus_shell___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vcvxif_nexus_shell___024root___eval_phase__ico(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_phase__ico\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VicoExecute;
    // Body
    Vcvxif_nexus_shell___024root___eval_triggers_vec__ico(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vcvxif_nexus_shell___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    __VicoExecute = Vcvxif_nexus_shell___024root___trigger_anySet__ico(vlSelfRef.__VicoTriggered);
    if (__VicoExecute) {
        Vcvxif_nexus_shell___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Vcvxif_nexus_shell___024root___eval_triggers_vec__act(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_triggers_vec__act\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    ((((~ (IData)(vlSelfRef.rst_ni)) 
                                                       & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__rst_ni__0)) 
                                                      << 1U) 
                                                     | ((IData)(vlSelfRef.clk_i) 
                                                        & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__clk_i__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__clk_i__0 = vlSelfRef.clk_i;
    vlSelfRef.__Vtrigprevexpr___TOP__rst_ni__0 = vlSelfRef.rst_ni;
}

bool Vcvxif_nexus_shell___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vcvxif_nexus_shell___024root___nba_sequent__TOP__0(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___nba_sequent__TOP__0\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.rst_ni) {
        if (((IData)(vlSelfRef.x_issue_req_valid_i) 
             & (IData)(vlSelfRef.x_issue_req_ready_o))) {
            vlSelfRef.cvxif_nexus_shell__DOT__saved_rd_addr_q 
                = (0x0000001fU & (vlSelfRef.x_issue_req_instr_i 
                                  >> 7U));
            vlSelfRef.cvxif_nexus_shell__DOT__saved_rs2_q 
                = vlSelfRef.x_issue_req_rs2_i;
            vlSelfRef.cvxif_nexus_shell__DOT__saved_rs1_q 
                = vlSelfRef.x_issue_req_rs1_i;
            vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q 
                = vlSelfRef.x_issue_req_id_i;
        }
        vlSelfRef.cvxif_nexus_shell__DOT__state_q = vlSelfRef.cvxif_nexus_shell__DOT__state_n;
    } else {
        vlSelfRef.cvxif_nexus_shell__DOT__saved_rd_addr_q = 0U;
        vlSelfRef.cvxif_nexus_shell__DOT__saved_rs2_q = 0U;
        vlSelfRef.cvxif_nexus_shell__DOT__saved_rs1_q = 0U;
        vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q = 0U;
        vlSelfRef.cvxif_nexus_shell__DOT__state_q = 0U;
    }
    vlSelfRef.x_result_valid_o = 0U;
    vlSelfRef.x_issue_req_ready_o = 0U;
    vlSelfRef.x_result_id_o = 0U;
    vlSelfRef.x_issue_resp_valid_o = 0U;
    vlSelfRef.x_result_rd_o = 0U;
    vlSelfRef.x_issue_resp_accept_o = 0U;
    vlSelfRef.x_result_data_o = 0U;
    if ((0U != (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
        if ((1U != (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
            if ((2U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
                vlSelfRef.x_result_valid_o = 1U;
                vlSelfRef.x_result_id_o = vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q;
                vlSelfRef.x_result_rd_o = vlSelfRef.cvxif_nexus_shell__DOT__saved_rd_addr_q;
                vlSelfRef.x_result_data_o = (vlSelfRef.cvxif_nexus_shell__DOT__saved_rs1_q 
                                             + vlSelfRef.cvxif_nexus_shell__DOT__saved_rs2_q);
            }
        }
    }
    vlSelfRef.cvxif_nexus_shell__DOT__state_n = vlSelfRef.cvxif_nexus_shell__DOT__state_q;
    if ((0U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
        vlSelfRef.x_issue_req_ready_o = 1U;
        if (vlSelfRef.x_issue_req_valid_i) {
            vlSelfRef.x_issue_resp_valid_o = 1U;
            if ((0x0bU == (0x0000007fU & vlSelfRef.x_issue_req_instr_i))) {
                vlSelfRef.x_issue_resp_accept_o = 1U;
                vlSelfRef.cvxif_nexus_shell__DOT__state_n = 1U;
            } else {
                vlSelfRef.x_issue_resp_accept_o = 0U;
            }
        }
    } else if ((1U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
        if (((IData)(vlSelfRef.x_commit_valid_i) & 
             ((IData)(vlSelfRef.x_commit_id_i) == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q)))) {
            vlSelfRef.cvxif_nexus_shell__DOT__state_n 
                = ((IData)(vlSelfRef.x_commit_kill_i)
                    ? 0U : 2U);
        }
    } else if ((2U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
        if (vlSelfRef.x_result_ready_i) {
            vlSelfRef.cvxif_nexus_shell__DOT__state_n = 0U;
        }
    }
}

void Vcvxif_nexus_shell___024root___eval_nba(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_nba\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        if (vlSelfRef.rst_ni) {
            if (((IData)(vlSelfRef.x_issue_req_valid_i) 
                 & (IData)(vlSelfRef.x_issue_req_ready_o))) {
                vlSelfRef.cvxif_nexus_shell__DOT__saved_rd_addr_q 
                    = (0x0000001fU & (vlSelfRef.x_issue_req_instr_i 
                                      >> 7U));
                vlSelfRef.cvxif_nexus_shell__DOT__saved_rs2_q 
                    = vlSelfRef.x_issue_req_rs2_i;
                vlSelfRef.cvxif_nexus_shell__DOT__saved_rs1_q 
                    = vlSelfRef.x_issue_req_rs1_i;
                vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q 
                    = vlSelfRef.x_issue_req_id_i;
            }
            vlSelfRef.cvxif_nexus_shell__DOT__state_q 
                = vlSelfRef.cvxif_nexus_shell__DOT__state_n;
        } else {
            vlSelfRef.cvxif_nexus_shell__DOT__saved_rd_addr_q = 0U;
            vlSelfRef.cvxif_nexus_shell__DOT__saved_rs2_q = 0U;
            vlSelfRef.cvxif_nexus_shell__DOT__saved_rs1_q = 0U;
            vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q = 0U;
            vlSelfRef.cvxif_nexus_shell__DOT__state_q = 0U;
        }
        vlSelfRef.x_result_valid_o = 0U;
        vlSelfRef.x_issue_req_ready_o = 0U;
        vlSelfRef.x_result_id_o = 0U;
        vlSelfRef.x_issue_resp_valid_o = 0U;
        vlSelfRef.x_result_rd_o = 0U;
        vlSelfRef.x_issue_resp_accept_o = 0U;
        vlSelfRef.x_result_data_o = 0U;
        if ((0U != (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
            if ((1U != (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
                if ((2U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
                    vlSelfRef.x_result_valid_o = 1U;
                    vlSelfRef.x_result_id_o = vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q;
                    vlSelfRef.x_result_rd_o = vlSelfRef.cvxif_nexus_shell__DOT__saved_rd_addr_q;
                    vlSelfRef.x_result_data_o = (vlSelfRef.cvxif_nexus_shell__DOT__saved_rs1_q 
                                                 + vlSelfRef.cvxif_nexus_shell__DOT__saved_rs2_q);
                }
            }
        }
        vlSelfRef.cvxif_nexus_shell__DOT__state_n = vlSelfRef.cvxif_nexus_shell__DOT__state_q;
        if ((0U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
            vlSelfRef.x_issue_req_ready_o = 1U;
            if (vlSelfRef.x_issue_req_valid_i) {
                vlSelfRef.x_issue_resp_valid_o = 1U;
                if ((0x0bU == (0x0000007fU & vlSelfRef.x_issue_req_instr_i))) {
                    vlSelfRef.x_issue_resp_accept_o = 1U;
                    vlSelfRef.cvxif_nexus_shell__DOT__state_n = 1U;
                } else {
                    vlSelfRef.x_issue_resp_accept_o = 0U;
                }
            }
        } else if ((1U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
            if (((IData)(vlSelfRef.x_commit_valid_i) 
                 & ((IData)(vlSelfRef.x_commit_id_i) 
                    == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__saved_id_q)))) {
                vlSelfRef.cvxif_nexus_shell__DOT__state_n 
                    = ((IData)(vlSelfRef.x_commit_kill_i)
                        ? 0U : 2U);
            }
        } else if ((2U == (IData)(vlSelfRef.cvxif_nexus_shell__DOT__state_q))) {
            if (vlSelfRef.x_result_ready_i) {
                vlSelfRef.cvxif_nexus_shell__DOT__state_n = 0U;
            }
        }
    }
}

void Vcvxif_nexus_shell___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcvxif_nexus_shell___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vcvxif_nexus_shell___024root___eval_phase__act(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_phase__act\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vcvxif_nexus_shell___024root___eval_triggers_vec__act(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vcvxif_nexus_shell___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vcvxif_nexus_shell___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    return (0U);
}

void Vcvxif_nexus_shell___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vcvxif_nexus_shell___024root___eval_phase__nba(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_phase__nba\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vcvxif_nexus_shell___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vcvxif_nexus_shell___024root___eval_nba(vlSelf);
        Vcvxif_nexus_shell___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vcvxif_nexus_shell___024root___eval(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VicoIterCount;
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VicoIterCount = 0U;
    vlSelfRef.__VicoFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VicoIterCount)))) {
#ifdef VL_DEBUG
            Vcvxif_nexus_shell___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
            VL_FATAL_MT("cvxif_nexus_shell.sv", 15, "", "DIDNOTCONVERGE: Input combinational region did not converge after '--converge-limit' of 100 tries");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        vlSelfRef.__VicoPhaseResult = Vcvxif_nexus_shell___024root___eval_phase__ico(vlSelf);
        vlSelfRef.__VicoFirstIteration = 0U;
    } while (vlSelfRef.__VicoPhaseResult);
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vcvxif_nexus_shell___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("cvxif_nexus_shell.sv", 15, "", "DIDNOTCONVERGE: NBA region did not converge after '--converge-limit' of 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vcvxif_nexus_shell___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("cvxif_nexus_shell.sv", 15, "", "DIDNOTCONVERGE: Active region did not converge after '--converge-limit' of 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactPhaseResult = Vcvxif_nexus_shell___024root___eval_phase__act(vlSelf);
        } while (vlSelfRef.__VactPhaseResult);
        vlSelfRef.__VnbaPhaseResult = Vcvxif_nexus_shell___024root___eval_phase__nba(vlSelf);
    } while (vlSelfRef.__VnbaPhaseResult);
}

#ifdef VL_DEBUG
void Vcvxif_nexus_shell___024root___eval_debug_assertions(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_debug_assertions\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk_i & 0xfeU)))) {
        Verilated::overWidthError("clk_i");
    }
    if (VL_UNLIKELY(((vlSelfRef.rst_ni & 0xfeU)))) {
        Verilated::overWidthError("rst_ni");
    }
    if (VL_UNLIKELY(((vlSelfRef.x_issue_req_valid_i 
                      & 0xfeU)))) {
        Verilated::overWidthError("x_issue_req_valid_i");
    }
    if (VL_UNLIKELY(((vlSelfRef.x_issue_req_id_i & 0xe0U)))) {
        Verilated::overWidthError("x_issue_req_id_i");
    }
    if (VL_UNLIKELY(((vlSelfRef.x_commit_valid_i & 0xfeU)))) {
        Verilated::overWidthError("x_commit_valid_i");
    }
    if (VL_UNLIKELY(((vlSelfRef.x_commit_id_i & 0xe0U)))) {
        Verilated::overWidthError("x_commit_id_i");
    }
    if (VL_UNLIKELY(((vlSelfRef.x_commit_kill_i & 0xfeU)))) {
        Verilated::overWidthError("x_commit_kill_i");
    }
    if (VL_UNLIKELY(((vlSelfRef.x_result_ready_i & 0xfeU)))) {
        Verilated::overWidthError("x_result_ready_i");
    }
}
#endif  // VL_DEBUG
