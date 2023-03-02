//
//  Packet+Header+Body.swift
//  

import Foundation

extension Packet.Header {
    public struct Body {
        public var address: UInt16
        public var messageID: UInt8
        public var messageType: UInt8
        public var length: UInt16

        public init(
            address: UInt16,
            messageID: UInt8,
            messageType: UInt8,
            length: UInt16
        ) {
            self.address = address
            self.messageID = messageID
            self.messageType = messageType
            self.length = length
        }
    }
}

extension Packet.Header.Body: ByteCodable {
    public var bytes: [UInt8] {
        address.bytes
        + [ messageID, messageType ]
        + length.bytes
    }

    public init?(bytes: [UInt8]) {
        var idx = 0

        self.address = .init(
            bytes: [
                bytes[safe: idx] ?? 0x0,
                bytes[safe: idx + 1] ?? 0x0
            ]
        )

        idx += 2

        self.messageID = bytes[safe: idx] ?? 0x0
        idx += 1

        self.messageType = bytes[safe: idx] ?? 0x0
        idx += 1

        let length: UInt16 = .init(bytes: [
            bytes[safe: idx] ?? 0x0,
            bytes[safe: idx + 1] ?? 0x0
        ])
        self.length = length
        
        idx += 2
    }
}

extension Packet.Header.Body: Hashable { }
