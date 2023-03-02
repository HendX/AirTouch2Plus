//
//  Protocols.swift
//  

import Foundation

public protocol ByteEncodable {
    var bytes: [UInt8] { get }
}

public protocol ByteDecodable {
    init?(bytes: [UInt8])
}

public typealias ByteCodable = ByteEncodable & ByteDecodable

public protocol SingleByteEncodable {
    var byte: UInt8 { get }
}

public protocol SingleByteDecodable {
    init?(byte: UInt8)
}

public typealias SingleByteCodable = SingleByteEncodable & SingleByteDecodable

public protocol DoubleByteEncodable {
    var bytes: UInt16 { get }
}

public protocol DoubleByteDecodable {
    init?(bytes: UInt16)
}

public typealias DoubleByteCodable = DoubleByteEncodable & DoubleByteDecodable

public protocol AirTouch2PlusPacket: ByteCodable {
    static var command: UInt16 { get }
}

public protocol StandardPacket: AirTouch2PlusPacket {
}

public protocol ExtendedPacket: AirTouch2PlusPacket {
}
