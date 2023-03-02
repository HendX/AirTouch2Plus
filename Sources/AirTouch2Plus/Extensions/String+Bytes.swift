//
//  String+Bytes.swift
//  

import Foundation

extension String {
    public init(bytes: [UInt8]) {
        var chars: [Character] = []

        for byte in bytes {
            guard byte > 0 else {
                continue
            }

            chars.append(Character(UnicodeScalar(byte)))
        }

        self = String(chars)
    }

    public var bytes: [UInt8] {
        let data: Data = data(using: .utf8) ?? .init()
        return [UInt8](data)
    }

    public func bytes(bufferLength: Int) -> [UInt8] {
        var nameBuffer: [UInt8] = .init(repeating: 0x00, count: bufferLength)

        let nameBytes = bytes
        let maxIdx = min(nameBuffer.count, nameBytes.count)

        for i in 0 ..< maxIdx {
            nameBuffer[i] = nameBytes[i]
        }

        return nameBuffer
    }
}
