#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtb_nexus_system.h"
#include "svdpi.h"

extern "C" void tb_set_exit_loop();
extern "C" void tb_set_boot_address();

vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; }

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vtb_nexus_system* top = new Vtb_nexus_system;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("sim.vcd");

    auto runCycles = [&](int n) {
        for (int i = 0; i < 2 * n; i++) {
            top->clk_i = !top->clk_i;
            top->eval();
            tfp->dump(main_time);
            main_time++;
        }
    };

    // ── Hold in reset, configure boot BEFORE releasing ───────────────────
    top->clk_i = 0;
    top->rst_ni = 0;
    runCycles(10);

    // Get DPI scope
    svScope scope = svGetScopeFromName("TOP.tb_nexus_system");
    if (!scope) {
        std::cerr << "Error: Could not find scope TOP.tb_nexus_system" << std::endl;
        return 1;
    }
    svSetScope(scope);

    // Set boot address to 0x00000000 and bypass BootROM loop
    tb_set_boot_address();
    tb_set_exit_loop();
    std::cout << "[TB] BootROM bypassed, boot address = 0x00000000" << std::endl;

    // Release reset
    top->rst_ni = 1;
    runCycles(5);

    // ── Main simulation loop ─────────────────────────────────────────────
    bool test_finished = false;
    uint32_t exit_val = 0;
    int max_cycles = 500000;
    int cycles = 0;

    while (!Verilated::gotFinish() && cycles < max_cycles) {
        top->clk_i = !top->clk_i;
        top->eval();
        tfp->dump(main_time);
        main_time++;

        if (top->clk_i) {
            cycles++;
            if (top->exit_valid_o) {
                test_finished = true;
                exit_val = top->exit_value_o;
                break;
            }
        }
    }

    if (test_finished) {
        if (exit_val == 1) {
            std::cout << "EXIT SUCCESS" << std::endl;
        } else {
            std::cout << "EXIT FAILURE (Code: " << exit_val << ")" << std::endl;
        }
    } else {
        std::cout << "SIMULATION TIMEOUT (" << cycles << " cycles)" << std::endl;
    }

    top->final();
    tfp->close();
    delete tfp;
    delete top;

    return (exit_val == 1) ? 0 : 1;
}