# Godot 4.x MNG support

`mng.gd` targets Godot 4.x and provides an MNG parser with PNG frame decoding and looping frame timing.

## Usage

```gdscript
var data := FileAccess.get_file_as_bytes("res://animation.mng")
var animation = MNG.parse(data)
if animation == null:
    return

var textures := MNG.decode_frames(animation)
var frame_index := animation.frame_index_at(Time.get_ticks_msec())
var first_png := MNG.first_png_frame(data)
```

## API

- `MNG.is_mng(data)` checks the MNG signature.
- `MNG.parse(data)` returns an animation with MHDR metadata, PNG frames, and delays, or `null` for invalid/incomplete data.
- `MNG.first_png_frame(data)` returns the first embedded PNG frame as a `PackedByteArray`.
- `MNG.decode_frames(animation)` converts embedded PNG frames into Godot `Texture2D` objects.
- `MNGAnimation.frame_index_at(elapsed_milliseconds)` selects the looping frame for elapsed milliseconds.

The script uses Godot 4.x APIs and has no add-on or third-party dependency.
