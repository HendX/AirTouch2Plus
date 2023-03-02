//
//  PacketTests.swift
//  

import XCTest
@testable import AirTouch2Plus

final class PacketTests: XCTestCase {

    let packet = Packet(
        headerCode: .init(bytes: [0x55, 0x55]),
        address: .init(bytes: [0x80, 0xb0]),
        messageID: 0x01,
        messageType: 0xc0,
        length: 0x8,
        data: [
            0x21, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
        ],
        crc16: .init(bytes: [ 0xa4, 0x31 ])
    )

    func testCrc16() throws {
        var bytes: [UInt8] = [ 0x90, 0xb0, 0x01, 0x1f, 0x00, 0x03, 0xff, 0x10, 0x00 ]

        XCTAssertEqual(
            bytes.crc16Modbus.bytes,
            [ 0x99, 0x82 ]
        )

        bytes = [ 0x80, 0xB0, 0x01, 0xC0, 0x00, 0x0C, 0x20, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x01, 0x02, 0x00, 0x00 ]

        XCTAssertEqual(
            bytes.crc16Modbus.bytes,
            [ 0x64, 0xfd ]
        )

        bytes = [ 0x80, 0xb0, 0x01, 0xc0, 0x00, 0x08, 0x21, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]

        XCTAssertEqual(
            bytes.crc16Modbus.bytes,
            [ 0xa4, 0x31 ]
        )
    }

    func testPacketEncoding() throws {
        XCTAssertEqual(
            packet.modBussableBytes.crc16Modbus.bytes,
            [ 0xa4, 0x31 ]
        )

        XCTAssertEqual(
            packet.bytes,
            [
                0x55, 0x55,
                0x80, 0xb0, 0x01, 0xc0, 0x00, 0x08,
                0x21, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                0xa4, 0x31
            ]
        )
    }

    func testBytes() throws {
        if let p = Packet(bytes: packet.bytes) {
            XCTAssertEqual(p, packet)
        }
        else {
            XCTFail("Unable to decode packet")
        }
    }

    func testBodyCodable() throws {
        let body = Packet.Header.Body(address: 5, messageID: 6, messageType: 7, length: 1)

        if let b = Packet.Header.Body(bytes: body.bytes) {
            XCTAssertEqual(body, b)
        }
        else {
            XCTFail("Unable to decode")
        }
    }

    func testHeaderBuffer() throws {

        let header = Packet.Header(
            headerCode: 12,
            body: .init(
                address: 34, messageID: 56, messageType: 78, length: 90
            )
        )

        let bytes = header.bytes

        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: bytes.count, alignment: 1)
        buffer.copyBytes(from: bytes)

        XCTAssertEqual(header, .init(buffer: buffer))

        buffer.deallocate()

    }
}
