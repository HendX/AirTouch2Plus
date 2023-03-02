//
//  Packet+Header.swift
//  

import Foundation

extension Packet {
    public struct Header {
        public var headerCode: UInt16
        public var body: Body

        public init(headerCode: UInt16, body: Packet.Header.Body) {
            self.headerCode = headerCode
            self.body = body
        }
    }
}

extension Packet.Header: Hashable { }

extension Packet.Header: ByteCodable {
    public var bytes: [UInt8] {
        headerCode.bytes + body.bytes
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count >= MemoryLayout<Self>.size else {
            return nil
        }

        var idx: Int = 0

        let headerBytes: [UInt8] = [
            bytes[safe: idx] ?? 0x0,
            bytes[safe: idx + 1] ?? 0x0
        ]
        idx += headerBytes.count

        let numBytes = MemoryLayout<Packet.Header.Body>.size
        let maxIdx = idx + numBytes
        let bodyBytes = Array(bytes[idx ..< maxIdx])

        guard let body = Packet.Header.Body(bytes: bodyBytes) else {
            return nil
        }

        idx = maxIdx

        self.headerCode = headerBytes.int16
        self.body = body
    }
}


extension Packet.Header {
    init(buffer: UnsafeMutableRawBufferPointer) {
        var tempHeaderCode: UInt16 = 0
        var tempHeaderBody: Body = .init(address: 0, messageID: 0, messageType: 0, length: 0)

        withUnsafeMutableBytes(of: &tempHeaderCode) { ptr in
            ptr.copyMemory(
                from: UnsafeRawBufferPointer(
                    start: buffer.baseAddress!.advanced(by: 0),
                    count: MemoryLayout<UInt16>.size
                )
            )
        }

        withUnsafeMutableBytes(of: &tempHeaderBody) { ptr in
            ptr.copyMemory(
                from: UnsafeRawBufferPointer(
                    start: buffer.baseAddress!.advanced(by: MemoryLayout<UInt16>.size),
                    count: MemoryLayout<Body>.size
                )
            )
        }

        headerCode = tempHeaderCode.byteSwapped
        tempHeaderBody.address = tempHeaderBody.address.byteSwapped
        tempHeaderBody.length = tempHeaderBody.length.byteSwapped

        body = tempHeaderBody
    }
}
