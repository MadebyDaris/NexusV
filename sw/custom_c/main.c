/*
 * main.c — NexusV PoC bare-metal smoke test
 *
 * Cycles through all 4 standard funct3 datapaths and verifies results.
 *
 * Custom instruction encoding (opcode 0x0B = custom-0):
 *   .insn r CUSTOM_0, funct3, rd, rs1, rs2
 *
 * funct3 map:
 *   0 → mac_plus_5      (rs1 * rs2) + 5
 *   1 → crc_step         (data >> 1) ^ (POLY if LSB else 0)
 *   2 → nexus_simd_mac   4x8-bit SIMD multiply-accumulate
 *   3 → nexus_saturating_add  4x8-bit saturating signed add
 */

#define EXIT_SUCCESS_ADDR ((volatile int*)0xF0000000)
#define EXIT_FAILURE_ADDR ((volatile int*)0xF0000004)

// ── Custom instruction wrappers ──────────────────────────────────────────────

static inline int nexus_call(int funct3, int rs1, int rs2) {
    int result;
    asm volatile (
        ".insn r 0x0B, %[f3], %[f7], %[rd], %[rs1], %[rs2]\n\t"
        : [rd] "=r" (result)
        : [f3] "i" (funct3), [f7] "i" (0),
          [rs1] "r" (rs1), [rs2] "r" (rs2)
    );
    return result;
}

// ── Test helpers ─────────────────────────────────────────────────────────────

static int tests_passed = 0;
static int tests_failed = 0;

#define TEST(name, cond) do {                              \
    if (cond) {                                            \
        tests_passed++;                                    \
    } else {                                               \
        tests_failed++;                                    \
        *EXIT_FAILURE_ADDR = __LINE__;                     \
    }                                                      \
} while(0)

// ── Main ─────────────────────────────────────────────────────────────────────

int main(void) {
    int result;

    // Test 1: funct3=0 — mac_plus_5: (rs1 * rs2) + 5
    result = nexus_call(0, 3, 4);
    TEST("mac_plus_5 (3*4+5)", result == 17);

    // Test 2: funct3=1 — crc_step
    // For data=0x00000001 (odd, LSB=1): (1>>1) ^ POLY = 0 ^ 0x04C11DB7 = 0x04C11DB7
    result = nexus_call(1, 1, 0);
    TEST("crc_step (data=1, LSB=1)", result == 0x04C11DB7);

    // Test 3: funct3=2 — nexus_simd_mac (4x8-bit SIMD MAC)
    // Packed: rs1 = {0,0,0,2}, rs2 = {0,0,0,3} → 2*3 = 6
    result = nexus_call(2, 0x00000002, 0x00000003);
    TEST("simd_mac (2*3)", result == 6);

    // Test 4: funct3=3 — nexus_saturating_add (4x8-bit)
    // Packed: rs1 = 0x7F010101 (127,1,1,1), rs2 = 0x01010101 (1,1,1,1)
    // Lane 0: 127+1=128 → saturates to 127
    // Lane 1: 1+1=2
    // Expected: 0x7F020202
    result = nexus_call(3, 0x7F010101, 0x01010101);
    TEST("saturating_add", result == 0x7F020202);

    // Summary
    if (tests_failed == 0) {
        *EXIT_SUCCESS_ADDR = tests_passed;
    } else {
        *EXIT_FAILURE_ADDR = tests_failed;
    }

    while (1) {}
    return 0;
}