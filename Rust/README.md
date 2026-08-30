# Rust MNG support

This directory contains a dependency-free Rust MNG parser, PNG frame extractor, and elapsed-time frame selector.

## Usage

```rust
use std::time::Duration;

let animation = mng::parse_mng(&data)?;
let frame = animation.frame_index_at(Duration::from_millis(elapsed_milliseconds));
let png = mng::first_png_frame(&data)?;
```

## API

- `is_mng(data)` checks the MNG signature.
- `parse_mng(data)` returns MNG metadata, PNG frames, and delays.
- `first_png_frame(data)` returns the first embedded PNG frame.
- `Animation::frame_index_at(elapsed)` selects a looping frame.

The crate uses only the Rust standard library and targets Rust 2021.
