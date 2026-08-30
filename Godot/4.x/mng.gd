class_name MNG
extends RefCounted

const MNG_SIGNATURE = PackedByteArray([0x8a, 0x4d, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
const PNG_SIGNATURE = PackedByteArray([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])

class MNGFrame:
    var png: PackedByteArray
    var delay_milliseconds: int

    func _init(frame_png: PackedByteArray, delay: int = 100):
        png = frame_png
        delay_milliseconds = delay

class MNGAnimation:
    var width: int = 0
    var height: int = 0
    var ticks_per_second: int = 100
    var nominal_layer_count: int = 0
    var nominal_frame_count: int = 0
    var nominal_play_time: int = 0
    var simplicity_profile: int = 0
    var frames: Array = []

    func frame_index_at(elapsed_milliseconds: int) -> int:
        if frames.is_empty():
            return -1
        if frames.size() == 1:
            return 0
        var duration := 0
        for frame in frames:
            duration += frame.delay_milliseconds
        if duration <= 0:
            return 0
        var elapsed := posmod(elapsed_milliseconds, duration)
        for index in frames.size():
            if elapsed < frames[index].delay_milliseconds:
                return index
            elapsed -= frames[index].delay_milliseconds
        return frames.size() - 1

static func is_mng(data: PackedByteArray) -> bool:
    if data.size() < MNG_SIGNATURE.size():
        return false
    for index in MNG_SIGNATURE.size():
        if data[index] != MNG_SIGNATURE[index]:
            return false
    return true

static func parse(data: PackedByteArray):
    if not is_mng(data):
        return null
    var animation = MNGAnimation.new()
    var frame := PackedByteArray()
    var pending_delay := 0
    var has_pending_delay := false
    var in_png := false
    var offset := MNG_SIGNATURE.size()
    while offset < data.size():
        if data.size() - offset < 12:
            return null
        var data_length := _read_u32(data, offset)
        var chunk_length := data_length + 12
        if chunk_length < 12 or chunk_length > data.size() - offset:
            return null
        var chunk_type := data.slice(offset + 4, offset + 8).get_string_from_ascii()
        var chunk_data := data.slice(offset + 8, offset + 8 + data_length)
        if chunk_type == "MHDR":
            if data_length < 28:
                return null
            animation.width = _read_u32(chunk_data, 0)
            animation.height = _read_u32(chunk_data, 4)
            var ticks := _read_u32(chunk_data, 8)
            if ticks > 0:
                animation.ticks_per_second = ticks
            animation.nominal_layer_count = _read_u32(chunk_data, 12)
            animation.nominal_frame_count = _read_u32(chunk_data, 16)
            animation.nominal_play_time = _read_u32(chunk_data, 20)
            animation.simplicity_profile = _read_u32(chunk_data, 24)
        elif chunk_type == "FRAM":
            var frame_delay = _parse_frame_delay(chunk_data)
            has_pending_delay = frame_delay[0]
            pending_delay = frame_delay[1]
        if not in_png and chunk_type == "IHDR":
            frame = PackedByteArray()
            frame.append_array(PNG_SIGNATURE)
            in_png = true
        if in_png:
            frame.append_array(data.slice(offset, offset + chunk_length))
            if chunk_type == "IEND":
                var delay := 100
                if has_pending_delay:
                    delay = maxi(0, roundi(float(pending_delay) * 1000.0 / float(animation.ticks_per_second)))
                animation.frames.append(MNGFrame.new(frame.duplicate(), delay))
                frame = PackedByteArray()
                has_pending_delay = false
                pending_delay = 0
                in_png = false
        offset += chunk_length
    if in_png or animation.frames.is_empty():
        return null
    return animation

static func first_png_frame(data: PackedByteArray) -> PackedByteArray:
    var animation = parse(data)
    if animation == null:
        return PackedByteArray()
    return animation.frames[0].png.duplicate()

static func decode_frames(animation) -> Array:
    var textures: Array = []
    if animation == null:
        return textures
    for frame in animation.frames:
        var image := Image.new()
        if image.load_png_from_buffer(frame.png) != OK:
            return []
        textures.append(ImageTexture.create_from_image(image))
    return textures

static func _read_u32(data: PackedByteArray, offset: int) -> int:
    return data.decode_u32(offset)

static func _parse_frame_delay(data: PackedByteArray) -> Array:
    if data.is_empty():
        return [false, 0]
    var offset := 1
    while offset < data.size() and data[offset] != 0:
        offset += 1
    if offset == data.size():
        return [false, 0]
    offset += 1
    if offset >= data.size():
        return [false, 0]
    var has_delay := data[offset] != 0
    offset += 1
    if data.size() - offset < 3:
        return [false, 0]
    offset += 3
    if not has_delay or data.size() - offset < 4:
        return [false, 0]
    return [true, _read_u32(data, offset)]
