class_name MNG
extends Reference

const MNG_SIGNATURE = PoolByteArray([0x8a, 0x4d, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
const PNG_SIGNATURE = PoolByteArray([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])

class MNGFrame:
    var png = PoolByteArray()
    var delay_milliseconds = 100

    func _init(frame_png, delay = 100):
        png = frame_png
        delay_milliseconds = delay

class MNGAnimation:
    var width = 0
    var height = 0
    var ticks_per_second = 100
    var nominal_layer_count = 0
    var nominal_frame_count = 0
    var nominal_play_time = 0
    var simplicity_profile = 0
    var frames = []

    func frame_index_at(elapsed_milliseconds):
        if frames.empty():
            return -1
        if frames.size() == 1:
            return 0
        var duration = 0
        for frame in frames:
            duration += frame.delay_milliseconds
        if duration <= 0:
            return 0
        var elapsed = posmod(elapsed_milliseconds, duration)
        for index in range(frames.size()):
            if elapsed < frames[index].delay_milliseconds:
                return index
            elapsed -= frames[index].delay_milliseconds
        return frames.size() - 1

static func is_mng(data):
    if data.size() < MNG_SIGNATURE.size():
        return false
    for index in range(MNG_SIGNATURE.size()):
        if data[index] != MNG_SIGNATURE[index]:
            return false
    return true

static func parse(data):
    if not is_mng(data):
        return null
    var animation = MNGAnimation.new()
    var frame = PoolByteArray()
    var pending_delay = 0
    var has_pending_delay = false
    var in_png = false
    var offset = MNG_SIGNATURE.size()
    while offset < data.size():
        if data.size() - offset < 12:
            return null
        var data_length = _read_u32(data, offset)
        var chunk_length = data_length + 12
        if chunk_length < 12 or chunk_length > data.size() - offset:
            return null
        var chunk_type = _bytes(data, offset + 4, 4).get_string_from_ascii()
        var chunk_data = _bytes(data, offset + 8, data_length)
        if chunk_type == "MHDR":
            if data_length < 28:
                return null
            animation.width = _read_u32(chunk_data, 0)
            animation.height = _read_u32(chunk_data, 4)
            var ticks = _read_u32(chunk_data, 8)
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
            frame = PoolByteArray()
            frame.append_array(PNG_SIGNATURE)
            in_png = true
        if in_png:
            frame.append_array(_bytes(data, offset, chunk_length))
            if chunk_type == "IEND":
                var delay = 100
                if has_pending_delay:
                    delay = max(0, int(round(float(pending_delay) * 1000.0 / float(animation.ticks_per_second))))
                animation.frames.append(MNGFrame.new(frame, delay))
                frame = PoolByteArray()
                has_pending_delay = false
                pending_delay = 0
                in_png = false
        offset += chunk_length
    if in_png or animation.frames.empty():
        return null
    return animation

static func first_png_frame(data):
    var animation = parse(data)
    if animation == null:
        return PoolByteArray()
    return _bytes(animation.frames[0].png, 0, animation.frames[0].png.size())

static func decode_frames(animation):
    var textures = []
    if animation == null:
        return textures
    for frame in animation.frames:
        var image = Image.new()
        if image.load_png_from_buffer(frame.png) != OK:
            return []
        var texture = ImageTexture.new()
        texture.create_from_image(image)
        textures.append(texture)
    return textures

static func _read_u32(data, offset):
    return (int(data[offset]) << 24) | (int(data[offset + 1]) << 16) | (int(data[offset + 2]) << 8) | int(data[offset + 3])

static func _bytes(data, start, length):
    var result = PoolByteArray()
    for index in range(length):
        result.append(data[start + index])
    return result

static func _parse_frame_delay(data):
    if data.empty():
        return [false, 0]
    var offset = 1
    while offset < data.size() and data[offset] != 0:
        offset += 1
    if offset == data.size():
        return [false, 0]
    offset += 1
    if offset >= data.size():
        return [false, 0]
    var has_delay = data[offset] != 0
    offset += 1
    if data.size() - offset < 3:
        return [false, 0]
    offset += 3
    if not has_delay or data.size() - offset < 4:
        return [false, 0]
    return [true, _read_u32(data, offset)]
