//
//  UnitControlMessage.swift
//  

import Foundation

public struct UnitControlMessage {
    public var units: [Unit]

    public init(
        units: [UnitControlMessage.Unit]
    ) {
        self.units = units
    }
}

extension UnitControlMessage: StandardPacket {
    public static var command: UInt16 { [UInt8]([ 0x22, 0x00 ]).int16 }
}

extension UnitControlMessage {
    public struct Unit {
        public var unitID: UnitID
        public var powerSetting: PowerSettingValue?
        public var mode: Mode?
        public var fanSpeed: FanSpeed?
        public var setPoint: DegreesCelsius?

        public init(
            unitID: UnitID,
            powerSetting: UnitControlMessage.PowerSettingValue? = nil,
            mode: Mode? = nil,
            fanSpeed: FanSpeed? = nil,
            setPoint: DegreesCelsius? = nil
        ) {
            self.unitID = unitID
            self.powerSetting = powerSetting
            self.mode = mode
            self.fanSpeed = fanSpeed
            self.setPoint = setPoint
        }
    }
}

extension UnitControlMessage: Hashable { }

extension UnitControlMessage.Unit: Hashable { }

extension UnitControlMessage {
    public enum PowerSettingValue: SingleByteCodable, CaseIterable {
        case toggleOnOff
        case on
        case off
        case away
        case sleep

        public var byte: UInt8 {
            switch self {
            case .toggleOnOff:
                return 0b001
            case .off:
                return 0b010
            case .on:
                return 0b011
            case .away:
                return 0b100
            case .sleep:
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

extension UnitControlMessage.Unit: ByteCodable {
    public var bytes: [UInt8] {

        let powerByte = powerSetting?.byte ?? 0
        let modeByte = mode?.byte ?? Mode.keepValue
        let fanSpeedByte = fanSpeed?.byte ?? FanSpeed.keepValue

        return [
            (unitID << 0) | (powerByte << 4),
            (fanSpeedByte << 0) | (modeByte << 4),
            setPoint == nil ? 0x00 : 0x40,
            setPoint?.byte ?? 0xff
        ]
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count == 4 else {
            return nil
        }

        let unitIDByte       = bytes[0] & 0x0f
        let powerSettingByte = (bytes[0] >> 4) & 0x0f
        let fanSpeedByte     = bytes[1] & 0x0f
        let modeByte         = (bytes[1] >> 4) & 0x0f
        let hasSetPoint      = bytes[2] == 0x40
        let setPointByte     = bytes[3]

        self.unitID       = unitIDByte
        self.powerSetting = UnitControlMessage.PowerSettingValue(byte: powerSettingByte)
        self.fanSpeed     = FanSpeed(byte: fanSpeedByte)
        self.mode         = Mode(byte: modeByte)
        self.setPoint     = hasSetPoint ? DegreesCelsius(byte: setPointByte) : nil
    }
}

extension UnitControlMessage: ByteCodable {
    public var bytes: [UInt8] {
        let repeatingData = Packet.RepeatingData(
            normalBytes: [],
            repeatLength: 4,
            repeats: units
        )

        return Self.command.bytes + repeatingData.bytes
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count > 2 else {
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
            type: UnitControlMessage.Unit.self,
            bytes: Array(remainingBytes)
        )

        guard let repeatingData else {
            return nil
        }

        self.units = repeatingData.repeats.compactMap { $0 as? UnitControlMessage.Unit }
    }
}
