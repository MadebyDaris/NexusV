// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vcvxif_nexus_shell__pch.h"

//============================================================
// Constructors

Vcvxif_nexus_shell::Vcvxif_nexus_shell(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vcvxif_nexus_shell__Syms(contextp(), _vcname__, this)}
    , clk_i{vlSymsp->TOP.clk_i}
    , rst_ni{vlSymsp->TOP.rst_ni}
    , x_issue_req_valid_i{vlSymsp->TOP.x_issue_req_valid_i}
    , x_issue_req_ready_o{vlSymsp->TOP.x_issue_req_ready_o}
    , x_issue_req_id_i{vlSymsp->TOP.x_issue_req_id_i}
    , x_issue_resp_valid_o{vlSymsp->TOP.x_issue_resp_valid_o}
    , x_issue_resp_accept_o{vlSymsp->TOP.x_issue_resp_accept_o}
    , x_issue_resp_id_o{vlSymsp->TOP.x_issue_resp_id_o}
    , x_commit_valid_i{vlSymsp->TOP.x_commit_valid_i}
    , x_commit_id_i{vlSymsp->TOP.x_commit_id_i}
    , x_commit_kill_i{vlSymsp->TOP.x_commit_kill_i}
    , x_result_valid_o{vlSymsp->TOP.x_result_valid_o}
    , x_result_ready_i{vlSymsp->TOP.x_result_ready_i}
    , x_result_id_o{vlSymsp->TOP.x_result_id_o}
    , x_result_rd_o{vlSymsp->TOP.x_result_rd_o}
    , x_issue_req_instr_i{vlSymsp->TOP.x_issue_req_instr_i}
    , x_issue_req_rs1_i{vlSymsp->TOP.x_issue_req_rs1_i}
    , x_issue_req_rs2_i{vlSymsp->TOP.x_issue_req_rs2_i}
    , x_result_data_o{vlSymsp->TOP.x_result_data_o}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vcvxif_nexus_shell::Vcvxif_nexus_shell(const char* _vcname__)
    : Vcvxif_nexus_shell(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vcvxif_nexus_shell::~Vcvxif_nexus_shell() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vcvxif_nexus_shell___024root___eval_debug_assertions(Vcvxif_nexus_shell___024root* vlSelf);
#endif  // VL_DEBUG
void Vcvxif_nexus_shell___024root___eval_static(Vcvxif_nexus_shell___024root* vlSelf);
void Vcvxif_nexus_shell___024root___eval_initial(Vcvxif_nexus_shell___024root* vlSelf);
void Vcvxif_nexus_shell___024root___eval_settle(Vcvxif_nexus_shell___024root* vlSelf);
void Vcvxif_nexus_shell___024root___eval(Vcvxif_nexus_shell___024root* vlSelf);

void Vcvxif_nexus_shell::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vcvxif_nexus_shell::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vcvxif_nexus_shell___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vcvxif_nexus_shell___024root___eval_static(&(vlSymsp->TOP));
        Vcvxif_nexus_shell___024root___eval_initial(&(vlSymsp->TOP));
        Vcvxif_nexus_shell___024root___eval_settle(&(vlSymsp->TOP));
        vlSymsp->__Vm_didInit = true;
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vcvxif_nexus_shell___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vcvxif_nexus_shell::eventsPending() { return false; }

uint64_t Vcvxif_nexus_shell::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vcvxif_nexus_shell::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vcvxif_nexus_shell___024root___eval_final(Vcvxif_nexus_shell___024root* vlSelf);

VL_ATTR_COLD void Vcvxif_nexus_shell::final() {
    Vcvxif_nexus_shell___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vcvxif_nexus_shell::hierName() const { return vlSymsp->name(); }
const char* Vcvxif_nexus_shell::modelName() const { return "Vcvxif_nexus_shell"; }
unsigned Vcvxif_nexus_shell::threads() const { return 1; }
void Vcvxif_nexus_shell::prepareClone() const { contextp()->prepareClone(); }
void Vcvxif_nexus_shell::atClone() const {
    contextp()->threadPoolpOnClone();
}
