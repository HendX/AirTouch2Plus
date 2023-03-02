//
//  Mode.swift
//  

import Foundation

public enum Mode: CaseIterable {
    case cool
    case fan
    case dry
    case heat
    case auto

    static let keepValue: UInt8 = 0b1111
}

extension Mode: SingleByteCodable {
    public var byte: UInt8 {
        switch self {
        case .auto:
            return 0b000
        case .heat:
            return 0b001
        case .dry:
            return 0b010
        case .fan:
            return 0b011
        case .cool:
            return 0b100
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
