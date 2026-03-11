#include <intrin.h>
#include <stdbool.h>
#include <windows.h>

#define EXPORT __declspec(dllexport)

#define CPUID_BASIC_INFO  0
#define CPUID_FEATURES    1
#define CPUID_FEATURES_EX 7

#define EAX(info) ((info)[0])
#define EBX(info) ((info)[1])
#define ECX(info) ((info)[2])
#define EDX(info) ((info)[3])

static bool has(unsigned int mask) {
    int info[4];
    __cpuid(info, CPUID_BASIC_INFO);

    if (EAX(info) < CPUID_FEATURES) {
        return false;
    }

    __cpuid(info, CPUID_FEATURES);
    return !!(ECX(info) & mask);
}

EXPORT int cpu_features(void) {
    int info[4];
    __cpuid(info, CPUID_BASIC_INFO);

    if (EAX(info) >= CPUID_FEATURES) {
        __cpuid(info, CPUID_FEATURES);
        return ECX(info);
    }
    return false;
}

#define SSE4_2 (1u << 20)
#define POPCNT (1u << 23)
#define XSAVE  (1u << 26)

EXPORT bool has_sse4_2(void) { return has(SSE4_2); }
EXPORT bool has_popcnt(void) { return has(POPCNT); }
EXPORT bool has_xsave(void)  { return has(XSAVE);  }
