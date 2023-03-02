//
//  CRC16Modbus.swift
//  

import Foundation

extension Array where Element == UInt8 {
    public var crc16Modbus: CRC16Modbus {
        let polynomial: UInt16 = 0xA001
        var crc: UInt16 = 0xFFFF

        for byte in self {
            crc ^= UInt16(byte)

            for _ in 0 ..< 8 {
                if crc & 0x0001 != 0 {
                    crc = (crc >> 1) ^ polynomial
                } else {
                    crc >>= 1
                }
            }
        }

        return crc
    }
}
