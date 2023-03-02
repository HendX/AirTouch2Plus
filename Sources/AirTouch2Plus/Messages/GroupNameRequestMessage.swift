//
//  GroupNameRequestMessage.swift
//  

import Foundation

public enum GroupNameRequestMessage {
    case all
    case specific(GroupID)
}

extension GroupNameRequestMessage: ExtendedPacket {
    public static var command: UInt16 { [UInt8]([ 0xff, 0x12 ]).int16 }
}

extension GroupNameRequestMessage: Hashable { }

extension GroupNameRequestMessage: ByteCodable {
    public var bytes: [UInt8] {
        switch self {
        case .all:
            return Self.command.bytes
        case .specific(let id):
            return Self.command.bytes + [ id ]
        }
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count >= 2 && bytes.count <= 3 else {
            return nil
        }

        let commandBytes = Self.command.bytes

        var idx = 0
        guard Array(bytes[idx ..< idx + commandBytes.count]) == commandBytes else {
            return nil
        }
        idx += commandBytes.count

        if let groupID = bytes[safe: idx] {
            self = .specific(groupID)
        }
        else {
            self = .all
        }
    }
}
