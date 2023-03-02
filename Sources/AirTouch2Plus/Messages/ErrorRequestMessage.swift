//
//  ErrorRequestMessage.swift
//  

import Foundation

public enum ErrorRequestMessage {
    case specific(UnitID)
}

extension ErrorRequestMessage: ExtendedPacket {
    public static var command: UInt16 { [UInt8]([ 0xff, 0x10 ]).int16 }
}

extension ErrorRequestMessage: ByteCodable {
    public var bytes: [UInt8] {
        switch self {
        case .specific(let id):
            return Self.command.bytes + [ id ]
        }
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count == 3 else {
            return nil
        }

        let commandBytes = Self.command.bytes

        var idx = 0
        guard Array(bytes[idx ..< idx + commandBytes.count]) == commandBytes else {
            return nil
        }
        idx += commandBytes.count

        self = .specific(bytes[idx])
    }
}

extension ErrorRequestMessage: Hashable { }
