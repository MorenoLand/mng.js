# Godot MNG support

This directory contains versioned GDScript ports for Godot 3.x and Godot 4.x.

- [Godot 3.x](3.x/README.md) uses `Reference`, `PoolByteArray`, and the Godot 3 texture API.
- [Godot 4.x](4.x/README.md) uses `RefCounted`, `PackedByteArray`, and the Godot 4 texture API.

Use the implementation matching the Godot major version of the project. The scripts expose the same parser, PNG extraction, frame decoding, and looping timing API with version-specific engine syntax.
