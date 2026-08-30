# C++ MNG support

This directory contains a C++17 MNG parser and first-frame PNG extractor.

## Usage

```cpp
#include "TMng.h"

auto animation = TMng::parse(data.data(), data.size());
if (animation.has_value()) {
    const auto& frame = animation->frames.front();
}
```

`data` is any contiguous byte container such as `std::vector<std::uint8_t>`.

## API

- `TMng::isMNG(content, length)` checks the MNG signature.
- `TMng::parse(content, length)` returns `TMng::Animation` metadata and extracted PNG frames.
- `TMng::firstPngFrame(content, length)` returns the first embedded PNG frame or an empty vector on failure.

`TMng.cpp` and `TMng.h` require C++17 for `std::optional` and have no third-party dependencies.
