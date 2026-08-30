# Shared MNG fixtures

The `.mng.hex` files are source-controlled byte fixtures. Convert them to bytes with a language-native hexadecimal decoder before passing them to an implementation.

- `minimal-1x1.mng.hex` contains one valid 1x1 PNG frame and no FRAM chunk, so the default delay is 100 milliseconds.
- `timed-2-frame.mng.hex` contains two valid 1x1 PNG frames with FRAM delays of 25 and 50 ticks at 100 ticks per second, producing 250 and 500 milliseconds.

All MNG and embedded PNG chunk CRC fields are valid; the current parser implementations do not require MNG CRC verification, so the fixtures also exercise the extracted frames with image libraries.
