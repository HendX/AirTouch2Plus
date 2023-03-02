//
//  GroupControlMessage.swift
//  

import Foundation

public struct GroupControlMessage {
    public var groups: [Group]

    public init(
        groups: [GroupControlMessage.Group]
    ) {
        self.groups = groups
    }
}

extension GroupControlMessage: StandardPacket {
    public static var command: UInt16 { [UInt8]([ 0x20, 0x00 ]).int16 }
}

extension GroupControlMessage {
    public struct Group {
        public var groupID: UInt8
        public var setting: SettingValue?
        public var power: PowerValue?

        public init(
            groupID: UInt8,
            setting: GroupControlMessage.SettingValue? = nil,
            power: GroupControlMessage.PowerValue? = nil
        ) {
            self.groupID = groupID
            self.setting = setting
            self.power = power
        }
    }
}

extension GroupControlMessage {
    public enum SettingValue: SingleByteEncodable, Hashable {
        case decrease5
        case increase5
        case percentage(Percentage)

        public var byte: UInt8 {
            switch self {
            case .decrease5:
                return 0b010
            case .increase5:
                return 0b011
            case .percentage:
                return 0b100
            }
        }

        var percentageByte: UInt8 {
            switch self {
            case .decrease5, .increase5:
                return 0x0
            case .percentage(let percentage):
                return percentage
            }
        }
    }
}

extension GroupControlMessage {
    public enum PowerValue: SingleByteCodable, Hashable, CaseIterable {
        case next
        case off
        case on
        case turbo

        public var byte: UInt8 {
            switch self {
            case .next:
                return 0b001
            case .off:
                return 0b010
            case .on:
                return 0b011
            case .turbo:
                return 0b101
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

extension GroupControlMessage: Hashable { }

extension GroupControlMessage.Group: Hashable { }

extension GroupControlMessage.Group: ByteCodable {
    public var bytes: [UInt8] {

        let powerByte = power?.byte ?? 0
        let settingByte = setting?.byte ?? 0

        return [
            groupID,
            (settingByte << 5) | powerByte,
            setting?.percentageByte ?? 0,
            0x00
        ]
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count == 4, bytes[3] == 0x00 else {
            return nil
        }

        self.groupID = bytes[0]

        let settingByte = (bytes[1] >> 5) & 0xf
        let powerByte = bytes[1] & 0xf

        self.power = .init(byte: powerByte)

        switch settingByte {
        case GroupControlMessage.SettingValue.increase5.byte:
            self.setting = .increase5
        case GroupControlMessage.SettingValue.decrease5.byte:
            self.setting = .decrease5
        case GroupControlMessage.SettingValue.percentage(0).byte:
            self.setting = .percentage(bytes[2])
        default:
            self.setting = nil
        }
    }
}

extension GroupControlMessage: ByteCodable {
    public var bytes: [UInt8] {
        let repeatingData = Packet.RepeatingData(
            normalBytes: [],
            repeatLength: 4,
            repeats: groups
        )

        return Self.command.bytes + repeatingData.bytes
    }

    public init?(bytes: [UInt8]) {
        let commandBytes = Self.command.bytes

        var idx = 0
        guard Array(bytes[idx ..< idx + commandBytes.count]) == commandBytes else {
            return nil
        }
        idx += commandBytes.count

        let remainingBytes = bytes[idx...]

        let repeatingData = Packet.RepeatingData(
            type: GroupControlMessage.Group.self,
            bytes: Array(remainingBytes)
        )

        guard let repeatingData else {
            return nil
        }

        self.groups = repeatingData.repeats.compactMap { $0 as? GroupControlMessage.Group }
    }
}
