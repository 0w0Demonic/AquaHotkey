// https://www.github.com/0w0Demonic/AquaHotkey
// <Collections/BitSet>

#include <intrin.h>
#include <stdint.h>

/**
 * @brief Counts the number of set bits in a buffer.
 * @param data pointer to memory buffer
 * @param len number of bytes in the buffer
 * @returns numbers of bits set to 1
 */
__declspec(dllexport)
size_t popcount(
        const uint8_t* data,
        size_t len
) {
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
