//
//  FanSpeed.swift
//  

import Foundation

public enum FanSpeed: CaseIterable {
    case auto
    case quiet
    case low
    case medium
    case high
    case powerful
    case turbo

    public static let keepValue: UInt8 = 0b1111
}

extension FanSpeed: SingleByteCodable {
    public var byte: UInt8 {
        switch self {
        case .auto:
            return 0b000
        case .quiet:
            return 0b001
        case .low:
            return 0b010
        case .medium:
            return 0b011
        case .high:
            return 0b100
        case .powerful:
            return 0b101
        case .turbo:
            return 0b110
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
