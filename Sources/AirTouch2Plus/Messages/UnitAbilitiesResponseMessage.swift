//
//  ControllerAbilitiesResponseMessage.swift
//  

import Foundation

public struct UnitAbilitiesResponseMessage {
    public var units: [Unit]

    public init(
        units: [UnitAbilitiesResponseMessage.Unit]
    ) {
        self.units = units
    }
}

extension UnitAbilitiesResponseMessage: ExtendedPacket {
    public static var command: UInt16 { [UInt8]([ 0xff, 0x11 ]).int16 }
}

extension UnitAbilitiesResponseMessage {
    public struct Unit {
        public var unitID: UnitID
        public var unitName: String

        public var startGroupNumber: GroupID
        public var numGroups: UInt8

        public var supportedModes: Set<Mode>
        public var supportedFanSpeeds: Set<FanSpeed>

        public var minSetPoint: DegreesCelsius
        public var maxSetPoint: DegreesCelsius

        public init(
            unitID: UnitID,
            unitName: String,
            startGroupNumber: GroupID,
            numGroups: UInt8,
            supportedModes: Set<Mode>,
            supportedFanSpeeds: Set<FanSpeed>,
            minSetPoint: DegreesCelsius,
            maxSetPoint: DegreesCelsius
        ) {
            self.unitID = unitID
            self.unitName = unitName
            self.startGroupNumber = startGroupNumber
            self.numGroups = numGroups
            self.supportedModes = supportedModes
            self.supportedFanSpeeds = supportedFanSpeeds
            self.minSetPoint = minSetPoint
            self.maxSetPoint = maxSetPoint
        }
    }
}

extension UnitAbilitiesResponseMessage.Unit: Hashable { }

extension UnitAbilitiesResponseMessage: Hashable { }

extension Mode {
    fileprivate var bitIndex: Int {
        switch self {
        case .cool: return 4
        case .fan: return 3
        case .dry: return 2
        case .heat: return 1
        case .auto: return 0
        }
    }
}

extension FanSpeed {
    fileprivate var bitIndex: Int {
        switch self {
        case .auto: return 0
        case .quiet: return 1
        case .low: return 2
        case .medium: return 3
        case .high: return 4
        case .powerful: return 5
        case .turbo: return 6
        }
    }
}

extension UnitAbilitiesResponseMessage.Unit: ByteCodable {
    public var bytes: [UInt8] {
        var modesByte: UInt8 = 0x0

        for mode in supportedModes {
            modesByte |= 0x1 << mode.bitIndex
        }

        var fanSpeedsByte: UInt8 = 0x0

        for fanSpeed in supportedFanSpeeds {
            fanSpeedsByte |= 0x1 << fanSpeed.bitIndex
        }

        return [
            unitID,
            22
        ]
        + unitName.bytes(bufferLength: 16)
        + [
            startGroupNumber,
            numGroups,
            modesByte,
            fanSpeedsByte,
            UInt8(minSetPoint.value),
            UInt8(maxSetPoint.value)
        ]
    }

    public init?(bytes: [UInt8]) {
        guard bytes.count >= 2 else {
            return nil
        }

        var idx = 0
        self.unitID = bytes[idx]
        idx += 1

        let numBytes = bytes[idx]
        idx += 1

        guard bytes.count == idx + Int(numBytes) else {
            return nil
        }

        let maxNameLength = 16

        let nameBytes = Array(bytes[idx ..< idx + maxNameLength])
        idx += maxNameLength

        self.unitName = .init(bytes: nameBytes)

        self.startGroupNumber = bytes[idx]
        idx += 1

        self.numGroups = bytes[idx]
        idx += 1

        let modesByte = bytes[idx]
        idx += 1

        var supportedModes: Set<Mode> = []

        for mode in Mode.allCases {
            let mask: UInt8 = 0b1 << mode.bitIndex

            if (modesByte & mask) == mask {
                supportedModes.insert(mode)
            }
        }

        self.supportedModes = supportedModes

        let fanSpeedsByte = bytes[idx]
        idx += 1

        var supportedFanSpeeds: Set<FanSpeed> = []

        for fanSpeed in FanSpeed.allCases {
            let mask: UInt8 = 0b1 << fanSpeed.bitIndex

            if (fanSpeedsByte & mask) == mask {
                supportedFanSpeeds.insert(fanSpeed)
            }
        }

        self.supportedFanSpeeds = supportedFanSpeeds

        self.minSetPoint = .init(Double(bytes[idx]))
        idx += 1
        self.maxSetPoint = .init(Double(bytes[idx]))
        idx += 1
    }
}

extension UnitAbilitiesResponseMessage: ByteCodable {
    public var bytes: [UInt8] {
        Self.command.bytes + units.map { $0.bytes }.flatMap { $0 }
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

        let repeatingLength = 24

        guard (bytes.count - 2) % repeatingLength == 0 else {
            return nil
        }

        var units: [Unit] = []

        while idx < bytes.count {
            defer {
                idx += repeatingLength
            }

            let bytes = bytes[idx ..< idx + repeatingLength]

            let unit = Unit(bytes: Array(bytes))

            if let unit {
                units.append(unit)
            }
        }

        self.units = units
    }
}
