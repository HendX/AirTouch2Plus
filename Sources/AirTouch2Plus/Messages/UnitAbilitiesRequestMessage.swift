//
//  UnitAbilitiesRequestMessage.swift
//  

import Foundation

public enum UnitAbilitiesRequestMessage {
    case all
    case specific(UnitID)
}

extension UnitAbilitiesRequestMessage: ExtendedPacket {
    public static var command: UInt16 { [UInt8]([ 0xff, 0x11 ]).int16 }
}

extension UnitAbilitiesRequestMessage: ByteCodable {
    public var bytes: [UInt8] {
        switch self {
        case .all:
            return Self.command.bytes
        case .specific(let id):
            return Self.command.bytes + [ id ]
        }
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count >= 2 else {
            return nil
        }

        let commandBytes = Self.command.bytes

        var idx = 0
        guard Array(bytes[idx ..< idx + commandBytes.count]) == commandBytes else {
            return nil
        }
        idx += commandBytes.count

        if let unitID = bytes[safe: idx] {
            self = .specific(unitID)
        }
        else {
            self = .all
        }
    }
}

extension UnitAbilitiesRequestMessage: Hashable { }
