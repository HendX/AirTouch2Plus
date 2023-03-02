//
//  UInt16.swift
//  

import Foundation

extension UInt16 {
    public init(bytes: [UInt8]) {
        self = bytes.int16
    }
    
    public var bytes: [UInt8] {
        [ UInt8(self >> 8), UInt8(self & 0xff) ]
    }
}

extension Array where Element == UInt8 {
    public var int16: UInt16 {
        let byte1: UInt8 = count > 0 ? self[0] : 0
        let byte2: UInt8 = count > 1 ? self[1] : 0

        return UInt16(byte1) << 8 + UInt16(byte2)
    }
}
