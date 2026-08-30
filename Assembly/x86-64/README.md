# x86-64 assembly MNG scanning

This directory contains real x86-64 assembly implementations of MNG signature validation and complete embedded-PNG frame scanning.

The functions use the Windows x64 calling convention:

- `mng_is_mng(const uint8_t *data, size_t length)` returns `1` for an MNG signature and `0` otherwise.
- `mng_frame_count(const uint8_t *data, size_t length)` validates chunk bounds and returns the number of complete `IHDR` through `IEND` PNG frames, or `0` for invalid/incomplete data.

Assemble `mng.asm` with NASM or `mng_masm.asm` with Microsoft `ml64.exe` for a Windows x64 object file. The scanners have no runtime or library dependency.
