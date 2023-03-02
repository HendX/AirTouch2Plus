//
//  GroupNameResponseMessage.swift
//  

import Foundation

public struct GroupNameResponseMessage {
    public var groups: [Group]

    public init(
        groups: [GroupNameResponseMessage.Group]
    ) {
        self.groups = groups
    }
}

extension GroupNameResponseMessage: ExtendedPacket {
    public static var command: UInt16 { [UInt8]([ 0xff, 0x12 ]).int16 }
}

extension GroupNameResponseMessage {
    public struct Group {
        public var groupID: GroupID
        public var name: String

        public init(
            groupID: GroupID,
            name: String
        ) {
            self.groupID = groupID
            self.name = name
        }
    }
}

extension GroupNameResponseMessage: Hashable { }

extension GroupNameResponseMessage.Group: Hashable { }

extension GroupNameResponseMessage.Group: ByteCodable {
    public var bytes: [UInt8] {
        [ groupID ] + name.bytes(bufferLength: 8)
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count == 9 else {
            return nil
        }

        self.groupID = bytes[0]

        let groupNameBytes = Array(bytes[1 ..< 9])
        self.name = .init(bytes: groupNameBytes)
    }
}

extension GroupNameResponseMessage: ByteCodable {
    public var bytes: [UInt8] {
        var ret: [UInt8] = Self.command.bytes
        groups.forEach { ret.append(contentsOf: $0.bytes )}
        return ret
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


        let repeatingLength = 9

        guard (bytes.count - 2) % repeatingLength == 0 else {
            return nil
        }

        var groups: [Group] = []

        while idx < bytes.count {
            defer {
                idx += repeatingLength
            }

            let bytes = bytes[idx ..< idx + repeatingLength]

            let group = Group(bytes: Array(bytes))

            if let group {
                groups.append(group)
            }
        }

        self.groups = groups
    }
}
