//
//  GroupStatusMessage.swift
//  

import Foundation

public struct GroupStatusMessage {
    public var groups: [Group]

    public init(
        groups: [GroupStatusMessage.Group]
    ) {
        self.groups = groups
    }
}

extension GroupStatusMessage: StandardPacket {
    public static var command: UInt16 { [UInt8]([ 0x21, 0x00 ]).int16 }
}

extension GroupStatusMessage {
    public struct Group {
        public var groupID: GroupID
        public var power: GroupStatusMessage.PowerValue
        public var openPercentage: UInt8
        public var turboIsSupported: Bool
        public var spillIsActive: Bool

        public init(
            groupID: GroupID,
            power: GroupStatusMessage.PowerValue,
            openPercentage: UInt8,
            turboIsSupported: Bool,
            spillIsActive: Bool
        ) {
            self.groupID = groupID
            self.power = power
            self.openPercentage = openPercentage
            self.turboIsSupported = turboIsSupported
            self.spillIsActive = spillIsActive
        }
    }
}

extension GroupStatusMessage.Group: Hashable { }

extension GroupStatusMessage: Hashable { }

extension GroupStatusMessage {
    public enum PowerValue: SingleByteCodable, Hashable, CaseIterable {
        case off
        case on
        case turbo

        public var byte: UInt8 {
            switch self {
            case .off:
                return 0b00
            case .on:
                return 0b01
            case .turbo:
                return 0b11
            }
        }

        public init?(byte: UInt8) {
            for item in Self.allCases {
                if item.byte == byte {
                    self = item
                    return
                }
            }

            return nil
        }
    }
}

extension GroupStatusMessage.Group: ByteCodable {
    public var bytes: [UInt8] {
        let turboByte: UInt8 = (turboIsSupported ? 1 : 0) << 7
        let spillByte: UInt8 = spillIsActive ? 0b10 : 0b00

        return [
            (power.byte << 6) | groupID,
            openPercentage,
            0x00, 0x00, 0x00, 0x00,
            turboByte | spillByte,
            0x00
        ]
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count == 8 else {
            return nil
        }

        var idx = 0

        self.groupID = bytes[idx] & 0b111111
        self.power = .init(byte: bytes[idx] >> 6) ?? .off
        idx += 1

        self.openPercentage = bytes[idx]
        idx += 1

        idx += 4

        self.turboIsSupported = ((bytes[6] >> 7) & 0x1) == 0x1
        self.spillIsActive = (bytes[6] & 0b11) == 0b10
    }
}

extension GroupStatusMessage: ByteCodable {
    public var bytes: [UInt8] {

        let repeatingData = Packet.RepeatingData(
            normalBytes: [],
            repeatLength: groups.count == 0 ? 0 : 8,
            repeats: groups
        )

        return Self.command.bytes + repeatingData.bytes
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

        let remainingBytes = bytes[idx...]

        let repeatingData = Packet.RepeatingData(
            type: GroupStatusMessage.Group.self,
            bytes: Array(remainingBytes)
        )

        guard let repeatingData else {
            return nil
        }

        self.groups = repeatingData.repeats.compactMap { $0 as? GroupStatusMessage.Group }
    }
}
