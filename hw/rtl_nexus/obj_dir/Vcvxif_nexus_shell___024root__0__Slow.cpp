// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcvxif_nexus_shell.h for the primary calling header

#include "Vcvxif_nexus_shell__pch.h"

VL_ATTR_COLD void Vcvxif_nexus_shell___024root___eval_static(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_static\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__clk_i__0 = vlSelfRef.clk_i;
    vlSelfRef.__Vtrigprevexpr___TOP__rst_ni__0 = vlSelfRef.rst_ni;
}

VL_ATTR_COLD void Vcvxif_nexus_shell___024root___eval_initial(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_initial\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vcvxif_nexus_shell___024root___eval_final(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_final\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcvxif_nexus_shell___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vcvxif_nexus_shell___024root___eval_phase__stl(Vcvxif_nexus_shell___024root* vlSelf);

VL_ATTR_COLD void Vcvxif_nexus_shell___024root___eval_settle(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_settle\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vcvxif_nexus_shell___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("cvxif_nexus_shell.sv", 15, "", "DIDNOTCONVERGE: Settle region did not converge after '--converge-limit' of 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        vlSelfRef.__VstlPhaseResult = Vcvxif_nexus_shell___024root___eval_phase__stl(vlSelf);
        vlSelfRef.__VstlFirstIteration = 0U;
    } while (vlSelfRef.__VstlPhaseResult);
}

VL_ATTR_COLD void Vcvxif_nexus_shell___024root___eval_triggers_vec__stl(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_triggers_vec__stl\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered[0U]) 
                                     | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
}

VL_ATTR_COLD bool Vcvxif_nexus_shell___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcvxif_nexus_shell___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vcvxif_nexus_shell___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vcvxif_nexus_shell___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vcvxif_nexus_shell___024root___stl_sequent__TOP__0(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___stl_sequent__TOP__0\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.x_result_valid_o = 0U;
    vlSelfRef.x_issue_req_ready_o = 0U;
    vlSelfRef.x_issue_resp_id_o = vlSelfRef.x_issue_req_id_i;
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

VL_ATTR_COLD void Vcvxif_nexus_shell___024root___eval_stl(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_stl\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        vlSelfRef.x_result_valid_o = 0U;
        vlSelfRef.x_issue_req_ready_o = 0U;
        vlSelfRef.x_issue_resp_id_o = vlSelfRef.x_issue_req_id_i;
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

VL_ATTR_COLD bool Vcvxif_nexus_shell___024root___eval_phase__stl(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___eval_phase__stl\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vcvxif_nexus_shell___024root___eval_triggers_vec__stl(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vcvxif_nexus_shell___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
    __VstlExecute = Vcvxif_nexus_shell___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vcvxif_nexus_shell___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vcvxif_nexus_shell___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcvxif_nexus_shell___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vcvxif_nexus_shell___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vcvxif_nexus_shell___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcvxif_nexus_shell___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vcvxif_nexus_shell___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge clk_i)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge rst_ni)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vcvxif_nexus_shell___024root___ctor_var_reset(Vcvxif_nexus_shell___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcvxif_nexus_shell___024root___ctor_var_reset\n"); );
    Vcvxif_nexus_shell__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->clk_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11908517815223722933ull);
    vlSelf->rst_ni = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3161515032326629241ull);
    vlSelf->x_issue_req_valid_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8115366312372296375ull);
    vlSelf->x_issue_req_ready_o = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7803945065350390693ull);
    vlSelf->x_issue_req_instr_i = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 391118962075075366ull);
    vlSelf->x_issue_req_rs1_i = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5694744649868698368ull);
    vlSelf->x_issue_req_rs2_i = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15654571566932132437ull);
    vlSelf->x_issue_req_id_i = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 5110483706225849904ull);
    vlSelf->x_issue_resp_valid_o = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11286330300360146460ull);
    vlSelf->x_issue_resp_accept_o = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15454222072935857245ull);
    vlSelf->x_issue_resp_id_o = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 1661441840899586162ull);
    vlSelf->x_commit_valid_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7110644803556733657ull);
    vlSelf->x_commit_id_i = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 16827281275052538205ull);
    vlSelf->x_commit_kill_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5845346653174607192ull);
    vlSelf->x_result_valid_o = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18302626797124804351ull);
    vlSelf->x_result_ready_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4619954181223723635ull);
    vlSelf->x_result_id_o = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 12910852171893677667ull);
    vlSelf->x_result_data_o = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1175555631992258822ull);
    vlSelf->x_result_rd_o = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 3309193544015174294ull);
    vlSelf->cvxif_nexus_shell__DOT__state_q = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 7463231687229022638ull);
    vlSelf->cvxif_nexus_shell__DOT__state_n = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15523055472550694752ull);
    vlSelf->cvxif_nexus_shell__DOT__saved_rs1_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2065427701212339845ull);
    vlSelf->cvxif_nexus_shell__DOT__saved_rs2_q = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 17449729760249568198ull);
    vlSelf->cvxif_nexus_shell__DOT__saved_id_q = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 15736480775058350104ull);
    vlSelf->cvxif_nexus_shell__DOT__saved_rd_addr_q = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 5029078085947361270ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VicoTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__clk_i__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__rst_ni__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
}
