//
//  UnitStatusMessage.swift
//  

import Foundation

public struct UnitStatusMessage {
    public var units: [Unit]

    public init(
        units: [Unit]
    ) {
        self.units = units
    }
}

extension UnitStatusMessage: StandardPacket {
    public static var command: UInt16 { [UInt8]([ 0x23, 0x00 ]).int16 }
}

extension UnitStatusMessage {
    public struct Unit {
        public var unitID: UnitID
        public var powerState: UnitStatusMessage.PowerState?
        public var mode: UnitStatusMessage.Mode?
        public var fanSpeed: FanSpeed?
        public var setPoint: DegreesCelsius?
        public var turboIsActive: Bool
        public var bypassIsActive: Bool
        public var spillIsActive: Bool
        public var timerIsSet: Bool
        public var temperature: DegreesCelsius?
        public var errorCode: ErrorCode?

        public init(
            unitID: UnitID,
            powerState: UnitStatusMessage.PowerState?,
            mode: UnitStatusMessage.Mode?,
            fanSpeed: FanSpeed?,
            setPoint: DegreesCelsius?,
            turboIsActive: Bool,
            bypassIsActive: Bool,
            spillIsActive: Bool,
            timerIsSet: Bool,
            temperature: DegreesCelsius?,
            errorCode: ErrorCode?
        ) {
            self.unitID = unitID
            self.powerState = powerState
            self.mode = mode
            self.fanSpeed = fanSpeed
            self.setPoint = setPoint
            self.turboIsActive = turboIsActive
            self.bypassIsActive = bypassIsActive
            self.spillIsActive = spillIsActive
            self.timerIsSet = timerIsSet
            self.temperature = temperature
            self.errorCode = errorCode
        }
    }
}

extension UnitStatusMessage.Unit: Hashable { }

extension UnitStatusMessage: Hashable { }

extension UnitStatusMessage {
    public enum PowerState: SingleByteCodable, CaseIterable {
        case off
        case on
        case awayOff
        case awayOn
        case sleep

        public var byte: UInt8 {
            switch self {
            case .off:
                return 0b000
            case .on:
                return 0b001
            case .awayOff:
                return 0b010
            case .awayOn:
                return 0b011
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

extension UnitStatusMessage {
    public enum Mode: SingleByteCodable, CaseIterable {
        case auto
        case heat
        case dry
        case fan
        case cool
        case autoHeat
        case autoCool

        public var byte: UInt8 {
            switch self {
            case .auto:
                return 0b0000
            case .heat:
                return 0b0001
            case .dry:
                return 0b0010
            case .fan:
                return 0b0011
            case .cool:
                return 0b0100
            case .autoHeat:
                return 0b1000
            case .autoCool:
                return 0b1001
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

extension UnitStatusMessage.Unit: ByteCodable {
    public var bytes: [UInt8] {

        let powerByte    = powerState?.byte ?? 0xff
        let modeByte     = mode?.byte ?? 0xff
        let fanSpeedByte = fanSpeed?.byte ?? 0xff
        let setPointByte = setPoint?.byte ?? 0xff

        let turboByte: UInt8  = turboIsActive  ? 0b1000 : 0b0000
        let bypassByte: UInt8 = bypassIsActive ? 0b0100 : 0b0000
        let spillByte: UInt8  = spillIsActive  ? 0b0010 : 0b0000
        let timerByte: UInt8  = timerIsSet     ? 0b0001 : 0b0000

        return [
            (powerByte << 4) | unitID,
            (modeByte << 4) | fanSpeedByte,
            setPointByte,
            0xc0 | (turboByte | bypassByte | spillByte | timerByte)
        ]
        + (temperature?.bytes.bytes ?? [ 0xff, 0xff ])
        + (errorCode?.bytes ?? [ 0x00, 0x00 ])
        + [ 0x80, 0x00 ]
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count == 10 else {
            return nil
        }

        var idx = 0

        self.unitID = bytes[idx] & 0b1111
        self.powerState = .init(byte: bytes[idx] >> 4)
        idx += 1

        self.fanSpeed = .init(byte: bytes[idx] & 0b1111)
        self.mode = .init(byte: bytes[idx] >> 4)
        idx += 1

        self.setPoint = .init(byte: bytes[idx])
        idx += 1

        self.turboIsActive  = (bytes[idx] & 0b1000) == 0b1000
        self.bypassIsActive = (bytes[idx] & 0b0100) == 0b0100
        self.spillIsActive  = (bytes[idx] & 0b0010) == 0b0010
        self.timerIsSet     = (bytes[idx] & 0b0001) == 0b0001
        idx += 1

        let temperatureValue: UInt16 = .init(bytes: [ bytes[idx], bytes[idx + 1]])
        self.temperature = .init(bytes: temperatureValue)
        idx += 2

        let errorValue: UInt16 = .init(bytes: [ bytes[idx], bytes[idx + 1]])
        self.errorCode = errorValue == 0 ? nil : errorValue
        idx += 2
    }
}

extension UnitStatusMessage: ByteCodable {
    public var bytes: [UInt8] {
        let repeatingData = Packet.RepeatingData(
            normalBytes: [],
            repeatLength: units.count == 0 ? 0 : 10,
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
            type: UnitStatusMessage.Unit.self,
            bytes: Array(remainingBytes)
        )

        guard let repeatingData else {
            return nil
        }

        self.units = repeatingData.repeats.compactMap { $0 as? UnitStatusMessage.Unit }
    }
}
