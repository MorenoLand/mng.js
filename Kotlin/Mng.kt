package mng

import java.io.ByteArrayOutputStream
import java.time.Duration

data class MngFrame(val png: ByteArray, val delayMilliseconds: Long)

class MngAnimation(
    val width: Long,
    val height: Long,
    val ticksPerSecond: Long,
    val nominalLayerCount: Long,
    val nominalFrameCount: Long,
    val nominalPlayTime: Long,
    val simplicityProfile: Long,
    val frames: List<MngFrame>
) {
    fun frameIndexAt(elapsed: Duration): Int {
        if (frames.isEmpty()) return -1
        if (frames.size == 1) return 0
        val duration = frames.sumOf { it.delayMilliseconds }
        if (duration <= 0) return 0
        var milliseconds = elapsed.toMillis() % duration
        if (milliseconds < 0) milliseconds += duration
        for ((index, frame) in frames.withIndex()) {
            if (milliseconds < frame.delayMilliseconds) return index
            milliseconds -= frame.delayMilliseconds
        }
        return frames.lastIndex
    }
}

class MngException(message: String) : Exception(message)

object Mng {
    private val mngSignature = byteArrayOf(0x8a.toByte(), 0x4d, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a)
    private val pngSignature = byteArrayOf(0x89.toByte(), 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a)

    fun isMng(data: ByteArray): Boolean = data.size >= mngSignature.size && data.copyOfRange(0, mngSignature.size).contentEquals(mngSignature)

    @Throws(MngException::class)
    fun parse(data: ByteArray): MngAnimation {
        if (!isMng(data)) throw MngException("not an MNG image")
        var width = 0L
        var height = 0L
        var ticksPerSecond = 100L
        var nominalLayerCount = 0L
        var nominalFrameCount = 0L
        var nominalPlayTime = 0L
        var simplicityProfile = 0L
        val frames = mutableListOf<MngFrame>()
        val frame = ByteArrayOutputStream()
        var pendingDelay: Long? = null
        var inPng = false
        var offset = mngSignature.size
        while (offset < data.size) {
            if (data.size - offset < 12) throw MngException("truncated MNG chunk")
            val dataLength = data.readU32(offset).toInt()
            val chunkLength = dataLength + 12
            if (chunkLength < 12 || chunkLength > data.size - offset) throw MngException("invalid MNG chunk length")
            val type = data.copyOfRange(offset + 4, offset + 8).toString(Charsets.US_ASCII)
            val chunkData = data.copyOfRange(offset + 8, offset + 8 + dataLength)
            if (type == "MHDR") {
                if (dataLength < 28) throw MngException("invalid MNG header")
                width = data.readU32(offset + 8)
                height = data.readU32(offset + 12)
                val ticks = data.readU32(offset + 16)
                if (ticks > 0) ticksPerSecond = ticks
                nominalLayerCount = data.readU32(offset + 20)
                nominalFrameCount = data.readU32(offset + 24)
                nominalPlayTime = data.readU32(offset + 28)
                simplicityProfile = data.readU32(offset + 32)
            } else if (type == "FRAM") {
                pendingDelay = parseFrameDelay(chunkData)
            }
            if (!inPng && type == "IHDR") {
                frame.write(pngSignature)
                inPng = true
            }
            if (inPng) {
                frame.write(data, offset, chunkLength)
                if (type == "IEND") {
                    val delay = pendingDelay?.let { Math.max(0L, Math.round(it * 1000.0 / ticksPerSecond)) } ?: 100L
                    frames += MngFrame(frame.toByteArray(), delay)
                    frame.reset()
                    pendingDelay = null
                    inPng = false
                }
            }
            offset += chunkLength
        }
        if (inPng || frames.isEmpty()) throw MngException("MNG contains no complete frames")
        return MngAnimation(width, height, ticksPerSecond, nominalLayerCount, nominalFrameCount, nominalPlayTime, simplicityProfile, frames)
    }

    fun firstPngFrame(data: ByteArray): ByteArray = parse(data).frames.first().png.copyOf()

    private fun parseFrameDelay(data: ByteArray): Long? {
        if (data.isEmpty()) return null
        var offset = 1
        while (offset < data.size && data[offset].toInt() != 0) offset++
        if (offset == data.size) return null
        offset++
        if (offset >= data.size) return null
        val hasDelay = data[offset].toInt() != 0
        offset++
        if (data.size - offset < 3) return null
        offset += 3
        if (!hasDelay || data.size - offset < 4) return null
        return data.readU32(offset)
    }

    private fun ByteArray.readU32(offset: Int): Long = ((this[offset].toLong() and 0xff) shl 24) or ((this[offset + 1].toLong() and 0xff) shl 16) or ((this[offset + 2].toLong() and 0xff) shl 8) or (this[offset + 3].toLong() and 0xff)
}
