# mng.js

Possibly the first client-side JavaScript MNG animation player.

MNG (Multiple-image Network Graphics) is an animation format from the early 2000s that never gained widespread browser support and was largely abandoned. This library parses and plays MNG files directly in the browser with no dependencies, using Canvas for rendering.

## Usage

```js
const canvas = await MNG.play(file); // File | ArrayBuffer
document.body.appendChild(canvas);

canvas.play();
canvas.pause();
canvas.stop();
```

## API

### MNG

| Method | Description |
|---|---|
| `MNG.play(src, autoplay?)` | Parses, loads, and returns an animated `<canvas>`. Autoplays by default. |
| `MNG.parse(src)` | Returns raw frame data `{ png: Uint8Array, delay: number }[]` |
| `MNG.toBlob(src)` | Returns the first frame as a PNG `Blob` |

`src` accepts a `File` or `ArrayBuffer`.

### Canvas (returned by `MNG.play`)

| Method | Description |
|---|---|
| `canvas.play()` | Start animation |
| `canvas.pause()` | Pause at current frame |
| `canvas.stop()` | Stop and reset to first frame |

## Features

- Parses MNG chunk structure (MHDR, FRAM, IHDR→IEND)
- Correct per-frame delay timing via FRAM chunk
- Falls back to 100 ticks/sec if MHDR omits tick rate (MNG spec default)
- Descriptive error on invalid signature showing actual file bytes
- Zero dependencies, ~80 lines

## Links

- **Userscript** (auto MNG support on any site): [MNG Support on GreasyFork](https://greasyfork.org/en/scripts/571788-mng-support)
- **Library**: [mng.js](https://raw.githubusercontent.com/MorenoLand/mng.js/refs/heads/feature/main/mng.js)

## Test Page

Open `mng-test.html` in a browser alongside `mng.js`. Drag and drop MNG files to preview them with frame count, dimensions, and playback controls.
