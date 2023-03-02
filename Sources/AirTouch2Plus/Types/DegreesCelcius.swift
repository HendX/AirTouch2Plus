//
//  DegreesCelsius.swift
//  

import Foundation

public struct DegreesCelsius: SingleByteCodable, Hashable {
    public var value: Double

    public init(_ value: Double) {
        self.value = value
    }

    public var byte: UInt8 {
        UInt8((value * 10) - 100)
    }

    public init?(byte: UInt8) {
        value = (Double(byte) + 100) / 10
    }
}

// This is for the temperature on the unit status
extension DegreesCelsius: DoubleByteCodable {
    public var bytes: UInt16 {
        UInt16(value * 10 + 500)
    }

    public init?(bytes: UInt16) {
        value = (Double(bytes) - 500) / 10
    }
}
