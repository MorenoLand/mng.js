# C MNG support

This directory contains a dependency-free C11 MNG parser, PNG frame extractor, and elapsed-time frame selector.

## Usage

```c
#include "mng.h"

mng_animation animation = {0};
if (mng_parse(data, data_size, &animation)) {
    size_t frame = mng_frame_index_at(&animation, elapsed_milliseconds);
    mng_animation_free(&animation);
}
```

## API

- `mng_is_mng(data, length)` checks the MNG signature.
- `mng_parse(data, length, animation)` fills metadata and extracted PNG frames.
- `mng_first_png_frame(data, length, png, png_size)` allocates the first PNG frame; free it with `free`.
- `mng_frame_index_at(animation, elapsed_milliseconds)` selects a looping frame.
- `mng_animation_free(animation)` releases parsed frames.

Build with a C11 compiler and link only the standard C library.
