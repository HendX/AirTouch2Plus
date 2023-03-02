//
//  Packet+Codable.swift
//  

import Foundation

extension Packet: ByteEncodable {
    public var bytes: [UInt8] {
        header.bytes + data + crc16.bytes
    }
}

extension Packet: ByteDecodable {
    public init?(bytes: [UInt8]) {

        var idx: Int = 0

        var maxIdx = idx + MemoryLayout<Header>.size

        guard bytes.count >= maxIdx else {
            return nil
        }

        let headerBytes = Array(bytes[idx ..< maxIdx])

        guard let header = Header(bytes: headerBytes) else {
            return nil
        }

        self.header = header

        idx = maxIdx

        let dataLength = header.body.length
        maxIdx = min(idx + Int(dataLength), bytes.count)

        guard maxIdx > idx else {
            self.data = []
            self.crc16 = 0
            return
        }

        self.data = Array(bytes[idx ..< maxIdx])
        idx = maxIdx

        let crc16Bytes: [UInt8] = [
            bytes[safe: idx] ?? 0x0,
            bytes[safe: idx + 1] ?? 0x0
        ]
        idx += 2

        self.crc16 = crc16Bytes.int16
    }
}
