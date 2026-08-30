# Python MNG support

This directory contains a standard-library MNG parser, PNG frame extractor, elapsed-time frame selector, and fixture tests.

## Usage

```python
from mng import first_png_frame, parse

animation = parse(data)
frame = animation.frame_index_at(250)
png = first_png_frame(data)
```

## API

- `is_mng(data)` checks the MNG signature.
- `parse(data)` returns MNG metadata, PNG frames, and delays.
- `first_png_frame(data)` returns the first embedded PNG frame.
- `MNGAnimation.frame_index_at(elapsed)` selects a looping frame.

Run the fixture tests from this directory with `python -m unittest test_mng.py`.
