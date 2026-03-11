// https://www.github.com/0w0Demonic/AquaHotkey
// <Collections/BitSet>
// cl /LD /O2 /W4 /MD BitSet.c

#include <intrin.h>
#include <stdint.h>
#include <windows.h>

#define CPUID_BASIC_INFO 0
#define CPUID_FEATURES   1

#define EAX(info) ((info)[0])
#define EBX(info) ((info)[1])
#define ECX(info) ((info)[2])
#define EDX(info) ((info)[3])

#define POPCNT (1u << 23)

// determines whether the CPU supports POPCNT
static BOOL gSupportsPopcnt = FALSE;

// check for POPCNT support via CPUID
static void checkSupportForPopcnt(void)
{
    int info[4];

    __cpuid(info, CPUID_BASIC_INFO);
    if (CPUID_FEATURES <= EAX(info)) {
        __cpuid(info, CPUID_FEATURES);
        gSupportsPopcnt = ECX(info) & POPCNT;
    }
}

// DLL entry point
BOOL WINAPI
DllMain(HINSTANCE hinstDLL,
        DWORD fdwReason,
        LPVOID lpvReserved)
{
    UNREFERENCED_PARAMETER(hinstDLL);
    UNREFERENCED_PARAMETER(lpvReserved);
    if (fdwReason == DLL_PROCESS_ATTACH) {
        checkSupportForPopcnt();
    }
    return TRUE;
}

// "standard" implementation through POPCNT'ing things in blocks of 64 bit
static size_t popcount_std(
        const uint8_t* data,
        size_t len)
{
    size_t count = 0;
    const uint64_t* p64 = (const uint64_t*) data;
    size_t n64 = (len / 8);

    for (size_t i = 0; i < n64; i++) {
        count += __popcnt64(p64[i]);
    }

    const uint8_t* tail = data + (n64 * 8);
    for (size_t i = 0; i < len % 8; i++) {
        count += __popcnt16(tail[i]);
    }

    return count;
}

// fallback implementation, if CPU happens to be absolutely ancient.
static size_t popcount_fallback(
        const uint8_t* data,
        size_t len)
{
    // table of all bytes -> population count
    #define B2(n)    n,     n+1,     n+1,     n+2
    #define B4(n) B2(n), B2(n+1), B2(n+1), B2(n+2)
    #define B6(n) B4(n), B4(n+1), B4(n+1), B4(n+2)

    static const uint8_t table[256] = { B6(0), B6(1), B6(1), B6(2) };

    size_t count = 0;
    for (size_t i = 0; i < len; i++) {
        count += table[data[i]];
    }
    return count;
}

// determines the population count (1-bits) of the given segment in memory.
__declspec(dllexport)
size_t popcount(
        const uint8_t* data,
        size_t len)
{
    if (!data || !len) {
        return 0;
    }

    if (gSupportsPopcnt) {
        return popcount_std(data, len);
    } else {
        return popcount_fallback(data, len);
    }
}
