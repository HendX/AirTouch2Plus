//
//  ErrorResponseMessage.swift
//  

import Foundation

public struct ErrorResponseMessage {
    public var unitID: UnitID
    public var error: String

    public init(
        unitID: UnitID,
        error: String
    ) {
        self.unitID = unitID
        self.error = error
    }
}

extension ErrorResponseMessage: ExtendedPacket{
    public static var command: UInt16 { [UInt8]([ 0xff, 0x10 ]).int16 }
}

extension ErrorResponseMessage: Hashable { }

extension ErrorResponseMessage: ByteCodable {
    public var bytes: [UInt8] {

        let errorBytes = error.bytes

        return Self.command.bytes
        + [
            unitID,
            UInt8(errorBytes.count)
        ]
        + errorBytes
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count >= 4 else {
            return nil
        }

        let commandBytes = Self.command.bytes

        var idx = 0
        guard Array(bytes[idx ..< idx + commandBytes.count]) == commandBytes else {
            return nil
        }
        idx += commandBytes.count

        self.unitID = bytes[idx]
        idx += 1

        let length = bytes[idx]
        idx += 1

        let maxIdx = min(idx + Int(length), bytes.count)

        guard maxIdx > idx else {
            return nil
        }

        let errorBytes: [UInt8] = Array(bytes[idx ..< maxIdx])
        self.error = .init(bytes: errorBytes)
    }
}
