//
//  RequestTests.swift
//  

import XCTest
@testable import AirTouch2Plus

final class RequestTests: XCTestCase {

    func testGroupControl() throws {
        let secondGroupOff: GroupControlMessage = .init(groups: [
            .init(
                groupID: 1,
                setting: nil,
                power: .off
            )
        ])

        let secondGroupOffBytes: [UInt8] = [ 0x55, 0x55, 0x80, 0xB0, 0x01, 0xC0, 0x00, 0x0C, 0x20, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x01, 0x02, 0x00, 0x00, 0x64, 0xFD ]

        let secondGroupOffPacket = Packet.request(messageID: 1, secondGroupOff)

        XCTAssertEqual(
            secondGroupOffPacket.bytes,
            secondGroupOffBytes
        )

        XCTAssertEqual(
            secondGroupOff,
            GroupControlMessage(bytes: [0x20, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x01, 0x02, 0x00, 0x00])
        )

        XCTAssertEqual(
            secondGroupOff,
            GroupControlMessage(bytes: Packet(bytes: secondGroupOffBytes)!.data)
        )

        let firstAndSecond10: GroupControlMessage = .init(groups: [
            .init(
                groupID: 0,
                setting: .percentage(10),
                power: nil
            ),
            .init(
                groupID: 1,
                setting: .percentage(10),
                power: nil
            )
        ])

        let firstAndSecond10Bytes: [UInt8] = [ 0x55, 0x55, 0x80, 0xB0, 0x01, 0xC0, 0x00, 0x10, 0x20, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x80, 0x0A, 0x00, 0x01, 0x80, 0x0A, 0x00, 0x2B, 0xD2 ]

        let firstAndSecond10Packet = Packet.request(messageID: 1, firstAndSecond10)
        XCTAssertEqual(
            firstAndSecond10Packet.bytes,
            firstAndSecond10Bytes
        )

        XCTAssertEqual(firstAndSecond10, GroupControlMessage(bytes: [ 0x20, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x80, 0x0A, 0x00, 0x01, 0x80, 0x0A, 0x00 ]))
    }

    func testGroupStatus() throws {
        let request = GroupStatusMessage(groups: [])
        let requestBytes: [UInt8] = [ 0x55, 0x55, 0x80, 0xB0, 0x01, 0xC0, 0x00, 0x08, 0x21, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA4, 0x31, ]
        let packet = Packet.request(messageID: 1, request)

        if let r = packet.airTouch2PlusPacket as? GroupStatusMessage {
            XCTAssertEqual(request, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            packet.bytes,
            requestBytes
        )
    }

    func testUnitControl() throws {
        let unit2Off: UnitControlMessage = .init(units: [
            .init(
                unitID: 1,
                powerSetting: .off,
                mode: nil,
                fanSpeed: nil,
                setPoint: nil
            )
        ])

        let repeatingBytes: [UInt8] = [ 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x21, 0xFF, 0x00, 0xFF ]
        if let repeatingData = Packet.RepeatingData(type: UnitControlMessage.Unit.self, bytes: repeatingBytes) {
            XCTAssertEqual(repeatingData.repeats.count, 1)

            if let u = repeatingData.repeats.first as? UnitControlMessage.Unit {
                XCTAssertEqual(u, unit2Off.units[0])
            }
            else {
                XCTFail("Repeat not decoded")
            }

        }
        else {
            XCTFail("Unable to decode")
        }


        let unit2OffBytes: [UInt8] = [ 0x55, 0x55, 0x80, 0xb0, 0x01, 0xC0, 0x00, 0x0C, 0x22, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x21, 0xFF, 0x00, 0xFF, 0xD3, 0xDE ]

        let unit2OffPacket = Packet.request(messageID: 1, unit2Off)

        if let r = unit2OffPacket.airTouch2PlusPacket as? UnitControlMessage {
            XCTAssertEqual(unit2Off, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            unit2OffPacket.bytes,
            unit2OffBytes
        )

        XCTAssertEqual(unit2Off, UnitControlMessage(bytes: [ 0x22, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x04, 0x21, 0xFF, 0x00, 0xFF ]))


        let unit1CoolUnit226: UnitControlMessage = .init(units: [
            .init(
                unitID: 0,
                powerSetting: nil,
                mode: .cool,
                fanSpeed: nil,
                setPoint: nil
            ),
            .init(
                unitID: 1,
                powerSetting: nil,
                mode: nil,
                fanSpeed: nil,
                setPoint: .init(26)
            )
        ])

        let unit1CoolUnit226Bytes: [UInt8] = [ 0x55, 0x55, 0x80, 0xb0, 0x01, 0xC0, 0x00, 0x10, 0x22, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x4F, 0x00, 0xFF, 0x01, 0xFF, 0x40, 0xA0, 0x38, 0x7E ]

        let unit1CoolUnit226Packet = Packet.request(messageID: 1, unit1CoolUnit226)

        if let r = unit1CoolUnit226Packet.airTouch2PlusPacket as? UnitControlMessage {
            XCTAssertEqual(unit1CoolUnit226, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            unit1CoolUnit226Packet.bytes,
            unit1CoolUnit226Bytes
        )

        XCTAssertEqual(unit1CoolUnit226, UnitControlMessage(bytes: [ 0x22, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x04, 0x00, 0x4F, 0x00, 0xFF, 0x01, 0xFF, 0x40, 0xA0 ]))
    }

    func testUnitStatus() throws {
        let request = UnitStatusMessage(units: [])
        let packet = Packet.request(messageID: 1, request)

        if let r = packet.airTouch2PlusPacket as? UnitStatusMessage {
            XCTAssertEqual(request, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            packet.bytes,
            [ 0x55, 0x55, 0x80, 0xB0, 0x01, 0xC0, 0x00, 0x08, 0x23, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7D, 0xB0 ]
        )
    }

    func testAbilities() throws {
        let request = UnitAbilitiesRequestMessage.specific(0)
        let requestBytes: [UInt8] = [ 0x55, 0x55, 0x90, 0xb0, 0x01, 0x1f, 0x00, 0x03, 0xff, 0x11, 0x00, 0x09, 0x83 ]

        let packet = Packet.request(messageID: 1, request)

        if let r = packet.airTouch2PlusPacket as? UnitAbilitiesRequestMessage {
            XCTAssertEqual(request, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            packet.bytes,
            requestBytes
        )
    }

    func testError() throws {
        let request = ErrorRequestMessage.specific(0)
        let requestBytes: [UInt8] = [ 0x55, 0x55, 0x90, 0xb0, 0x01, 0x1f, 0x00, 0x03, 0xff, 0x10, 0x00, 0x99, 0x82 ]
        let packet = Packet.request(messageID: 1, request)

        if let r = packet.airTouch2PlusPacket as? ErrorRequestMessage {
            XCTAssertEqual(request, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            packet.bytes,
            requestBytes
        )
    }

    func testGroupName() throws {
        let request = GroupNameRequestMessage.specific(0)
        let requestBytes: [UInt8] = [ 0x55, 0x55, 0x90, 0xb0, 0x01, 0x1f, 0x00, 0x03, 0xff, 0x12, 0x00, 0xf9, 0x83 ]

        let packet = Packet.request(messageID: 1, request)

        if let r = packet.airTouch2PlusPacket as? GroupNameRequestMessage {
            XCTAssertEqual(request, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            packet.bytes,
            requestBytes
        )

        let allRequest = GroupNameRequestMessage.all
        let allRequestBytes: [UInt8] = [ 0x55, 0x55, 0x90, 0xb0, 0x01, 0x1f, 0x00, 0x02, 0xff, 0x12, 0x82, 0x0c ]

        let allRequestPacket = Packet.request(messageID: 1, allRequest)

        if let r = allRequestPacket.airTouch2PlusPacket as? GroupNameRequestMessage {
            XCTAssertEqual(allRequest, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            allRequestPacket.bytes,
            allRequestBytes
        )
    }
}
