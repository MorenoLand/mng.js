import Foundation

public enum MNGError: Error {
    case notMNG
    case truncatedChunk
    case invalidChunkLength
    case invalidHeader
    case noFrames
}

public struct MNGFrame {
    public let png: Data
    public let delayMilliseconds: UInt64

    public init(png: Data, delayMilliseconds: UInt64) {
        self.png = png
        self.delayMilliseconds = delayMilliseconds
    }
}

public struct MNGAnimation {
    public let width: UInt32
    public let height: UInt32
    public let ticksPerSecond: UInt32
    public let nominalLayerCount: UInt32
    public let nominalFrameCount: UInt32
    public let nominalPlayTime: UInt32
    public let simplicityProfile: UInt32
    public let frames: [MNGFrame]

    public func frameIndex(at elapsedMilliseconds: UInt64) -> Int? {
        if frames.isEmpty { return nil }
        if frames.count == 1 { return 0 }
        let duration = frames.reduce(UInt64(0)) { $0 + $1.delayMilliseconds }
        if duration == 0 { return 0 }
        var elapsed = elapsedMilliseconds % duration
        for (index, frame) in frames.enumerated() {
            if elapsed < frame.delayMilliseconds { return index }
            elapsed -= frame.delayMilliseconds
        }
        return frames.count - 1
    }
}

public enum MNG {
    private static let mngSignature: [UInt8] = [0x8a, 0x4d, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]
    private static let pngSignature: [UInt8] = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]

    public static func isMNG(_ data: Data) -> Bool {
        data.count >= mngSignature.count && Array(data.prefix(mngSignature.count)) == mngSignature
    }

    public static func parse(_ data: Data) throws -> MNGAnimation {
        guard isMNG(data) else { throw MNGError.notMNG }
        var animation = MNGAnimation(width: 0, height: 0, ticksPerSecond: 100, nominalLayerCount: 0, nominalFrameCount: 0, nominalPlayTime: 0, simplicityProfile: 0, frames: [])
        var frame = Data()
        var pendingDelay: UInt32?
        var inPNG = false
        var offset = mngSignature.count
        while offset < data.count {
            guard data.count - offset >= 12 else { throw MNGError.truncatedChunk }
            let dataLength = Int(readU32(data, offset))
            let chunkLength = dataLength + 12
            guard chunkLength >= 12 && chunkLength <= data.count - offset else { throw MNGError.invalidChunkLength }
            let chunkType = Data(data[(offset + 4)..<(offset + 8)])
            let chunkData = Data(data[(offset + 8)..<(offset + 8 + dataLength)])
            if chunkType == Data("MHDR".utf8) {
                guard dataLength >= 28 else { throw MNGError.invalidHeader }
                animation = MNGAnimation(width: readU32(data, offset + 8), height: readU32(data, offset + 12), ticksPerSecond: max(1, readU32(data, offset + 16)), nominalLayerCount: readU32(data, offset + 20), nominalFrameCount: readU32(data, offset + 24), nominalPlayTime: readU32(data, offset + 28), simplicityProfile: readU32(data, offset + 32), frames: animation.frames)
            } else if chunkType == Data("FRAM".utf8) {
                pendingDelay = parseFrameDelay(chunkData)
            }
            if !inPNG && chunkType == Data("IHDR".utf8) {
                frame = Data(pngSignature)
                inPNG = true
            }
            if inPNG {
                frame.append(data.subdata(in: offset..<(offset + chunkLength)))
                if chunkType == Data("IEND".utf8) {
                    let delay = pendingDelay.map { (UInt64($0) * 1000 + UInt64(animation.ticksPerSecond) / 2) / UInt64(animation.ticksPerSecond) } ?? 100
                    var frames = animation.frames
                    frames.append(MNGFrame(png: frame, delayMilliseconds: delay))
                    animation = MNGAnimation(width: animation.width, height: animation.height, ticksPerSecond: animation.ticksPerSecond, nominalLayerCount: animation.nominalLayerCount, nominalFrameCount: animation.nominalFrameCount, nominalPlayTime: animation.nominalPlayTime, simplicityProfile: animation.simplicityProfile, frames: frames)
                    frame.removeAll(keepingCapacity: true)
                    pendingDelay = nil
                    inPNG = false
                }
            }
            offset += chunkLength
        }
        if inPNG || animation.frames.isEmpty { throw MNGError.noFrames }
        return animation
    }

    public static func firstPNGFrame(_ data: Data) throws -> Data {
        try parse(data).frames[0].png
    }

    private static func readU32(_ data: Data, _ offset: Int) -> UInt32 {
        UInt32(data[data.startIndex + offset]) << 24 | UInt32(data[data.startIndex + offset + 1]) << 16 | UInt32(data[data.startIndex + offset + 2]) << 8 | UInt32(data[data.startIndex + offset + 3])
    }

    private static func parseFrameDelay(_ data: Data) -> UInt32? {
        if data.isEmpty { return nil }
        var offset = 1
        while offset < data.count && data[data.startIndex + offset] != 0 { offset += 1 }
        if offset == data.count { return nil }
        offset += 1
        if offset >= data.count { return nil }
        let hasDelay = data[data.startIndex + offset] != 0
        offset += 1
        if data.count - offset < 3 { return nil }
        offset += 3
        if !hasDelay || data.count - offset < 4 { return nil }
        return readU32(data, offset)
    }
}
