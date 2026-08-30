# Go MNG support

This directory contains the Go MNG parser and animation timing types used by the `engine` package.

## Usage

```go
animation, err := ParseMNG(data)
if err != nil {
    return err
}

frameIndex := animation.FrameIndexAt(elapsed)
pngFrame, err := FirstMNGPNGFrame(data)
```

`data` is a `[]byte`, and `elapsed` is a `time.Duration`.

## API

- `IsMNG(data)` checks the MNG signature.
- `ParseMNG(data)` returns MNG metadata, PNG frames, and frame delays.
- `FirstMNGPNGFrame(data)` returns the first embedded PNG frame.
- `TMNGAnimation.FrameIndexAt(elapsed)` selects the looping frame for an elapsed duration.

`TMNG.go` uses the standard library for parsing and PNG decoding and includes the existing Ebiten adventure integration used by the surrounding engine package.
