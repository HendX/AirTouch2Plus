//
//  Packet+RepeatingData.swift
//  

import Foundation

extension Packet {
    public struct RepeatingData {
        var normalBytes: [UInt8]
        var repeatLength: UInt16
        var repeats: [ByteEncodable]
    }
}

extension Packet.RepeatingData: Hashable, Equatable {
    public static func == (lhs: Packet.RepeatingData, rhs: Packet.RepeatingData) -> Bool {
        lhs.bytes == rhs.bytes
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(bytes)
    }
}

extension Packet.RepeatingData: ByteEncodable {
    public var bytes: [UInt8] {
        var ret: [UInt8] = []

        let normalByteLength: UInt16 = UInt16(normalBytes.count)

        ret.append(contentsOf: normalByteLength.bytes)
        ret.append(contentsOf: UInt16(repeats.count).bytes)
        ret.append(contentsOf: UInt16(repeatLength).bytes)

        ret.append(contentsOf: normalBytes)

        for rep in repeats {
            ret.append(contentsOf: rep.bytes)
        }

        return ret
    }
}

extension Packet.RepeatingData {
    public init?<T: ByteCodable>(type: T.Type, bytes: [UInt8]) {

        var idx = 0

        let normalBytesLength = UInt16(
            bytes: [
                bytes[safe: idx] ?? 0x00,
                bytes[safe: idx + 1] ?? 0x00
            ]
        )

        idx += 2

        let repeatsCount = UInt16(
            bytes: [
                bytes[safe: idx] ?? 0x00,
                bytes[safe: idx + 1] ?? 0x00
            ]
        )

        idx += 2

        let repeatsLength = UInt16(
            bytes: [
                bytes[safe: idx] ?? 0x00,
                bytes[safe: idx + 1] ?? 0x00
            ]
        )

        idx += 2

        var normalBytes: [UInt8] = []

        if normalBytesLength > 0 {
            let maxIdx = idx + Int(normalBytesLength)

            if maxIdx < bytes.count {
                normalBytes = Array(bytes[idx ..< maxIdx])
            }

            idx = maxIdx
        }

        var repeats: [T] = []

        for _ in 0 ..< repeatsCount {
            let maxIdx = idx + Int(repeatsLength)

            if maxIdx <= bytes.count {
                let repeatBytes = Array(bytes[idx ..< maxIdx])

                if let rep = T(bytes: repeatBytes) {
                    repeats.append(rep)
                }
            }

            idx = maxIdx
        }

        self.init(
            normalBytes: normalBytes,
            repeatLength: repeatsLength,
            repeats: repeats
        )
    }
}
