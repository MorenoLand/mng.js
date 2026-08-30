# Zig MNG support

This directory contains an allocator-aware Zig MNG parser, PNG frame extractor, and elapsed-time frame selector.

## Usage

```zig
var animation = try mng.parse(allocator, data);
defer animation.deinit();

const frame = animation.frameIndexAt(elapsed_milliseconds);
const png = try mng.firstPngFrame(allocator, data);
defer allocator.free(png);
```

## API

- `isMNG(data)` checks the MNG signature.
- `parse(allocator, data)` returns MNG metadata, PNG frames, and delays.
- `firstPngFrame(allocator, data)` allocates the first embedded PNG frame.
- `Animation.frameIndexAt(elapsed_milliseconds)` selects a looping frame.
- `Animation.deinit()` releases all parser allocations.

The source uses the Zig standard library and does not depend on an image package.
