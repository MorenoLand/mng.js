# Kotlin MNG support

This directory contains a Kotlin/JVM MNG parser, PNG frame extractor, and elapsed-time frame selector.

## Usage

```kotlin
val animation = Mng.parse(data)
val frame = animation.frameIndexAt(Duration.ofMillis(elapsedMilliseconds))
val png = Mng.firstPngFrame(data)
```

## API

- `Mng.isMng(data)` checks the MNG signature.
- `Mng.parse(data)` returns MNG metadata, PNG frames, and delays.
- `Mng.firstPngFrame(data)` returns a copy of the first embedded PNG frame.
- `MngAnimation.frameIndexAt(elapsed)` selects a looping frame.

The source uses the Kotlin/JVM standard library and `java.time.Duration`.
