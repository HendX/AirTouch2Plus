//
//  ReponseTests.swift
//  

import XCTest
@testable import AirTouch2Plus

final class ReponseTests: XCTestCase {

    func testGroupStatus() throws {
        let bytes: [UInt8] = [
            0x55, 0x55, 0xB0, 0x80, 0x01, 0xC0, 0x00, 0x18,
            0x21, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x08,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00,
            0x41, 0x32, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00,
            0x83, 0x2F
        ]

        let response = GroupStatusMessage(
            groups: [
                .init(
                    groupID: 0,
                    power: .off,
                    openPercentage: 0,
                    turboIsSupported: true,
                    spillIsActive: false
                ),
                .init(
                    groupID: 1,
                    power: .on,
                    openPercentage: 50,
                    turboIsSupported: false,
                    spillIsActive: true
                )
            ]
        )

        let packet = Packet.response(messageID: 1, response)

        if let r = packet.airTouch2PlusPacket as? GroupStatusMessage {
            XCTAssertEqual(response, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            packet.bytes,
            bytes
        )

        let r = GroupStatusMessage(
            bytes: [
                0x21, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x08,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x41, 0x32, 0x00, 0x00, 0x00, 0x00,
                0x02, 0x00
            ]
        )

        if let r {
            XCTAssertEqual(response, r)
        }
        else {
            XCTFail("Unable to decode")
        }
    }

    func testUnitStatus() throws {
        let bytes: [UInt8] = [
            0x55, 0x55, 0xB0, 0x80, 0x01, 0xC0, 0x00, 0x1C,
            0x23, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x0A,
            0x10, 0x12, 0x78, 0xC0, 0x02, 0xDA, 0x00, 0x00, 0x80, 0x00,
            0x01, 0x42, 0x64, 0xC0, 0x02, 0xE4, 0x00, 0x00, 0x80, 0x00,
            0xD3, 0x97
        ]

        let response = UnitStatusMessage(
            units: [
                .init(
                    unitID: 0,
                    powerState: .on,
                    mode: .heat,
                    fanSpeed: .low,
                    setPoint: .init(22),
                    turboIsActive: false,
                    bypassIsActive: false,
                    spillIsActive: false,
                    timerIsSet: false,
                    temperature: .init(23),
                    errorCode: nil
                ),
                .init(
                    unitID: 1,
                    powerState: .off,
                    mode: .cool,
                    fanSpeed: .low,
                    setPoint: .init(20),
                    turboIsActive: false,
                    bypassIsActive: false,
                    spillIsActive: false,
                    timerIsSet: false,
                    temperature: .init(24),
                    errorCode: nil
                )
            ]
        )

        let packet = Packet.response(messageID: 1, response)

        if let r = packet.airTouch2PlusPacket as? UnitStatusMessage {
            XCTAssertEqual(response, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            packet.bytes,
            bytes
        )

        let r = UnitStatusMessage(bytes: [ 0x23, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x0A,
                                           0x10, 0x12, 0x78, 0xC0, 0x02, 0xDA, 0x00, 0x00, 0x80, 0x00,
                                           0x01, 0x42, 0x64, 0xC0, 0x02, 0xE4, 0x00, 0x00, 0x80, 0x00 ])

        if let r {
            XCTAssertEqual(response, r)
        }
        else {
            XCTFail("Unable to decode")
        }
    }

    func testUnitAbilities() throws {
        let bytes: [UInt8] = [
            0x55, 0x55, 0xb0, 0x90, 0x01, 0x1f, 0x00, 0x1a, 0xff, 0x11, 0x00, 0x16,
            0x55, 0x4e, 0x49, 0x54, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x17, 0x1d, 0x11, 0x1f, 0x6a, 0x54
        ]

        let response = UnitAbilitiesResponseMessage(units: [
            .init(
                unitID: 0,
                unitName: "UNIT",
                startGroupNumber: 0,
                numGroups: 4,
                supportedModes: [ .cool, .heat, .fan, .auto ],
                supportedFanSpeeds: [ .low, .medium, .high, .auto ],
                minSetPoint: .init(17),
                maxSetPoint: .init(31)
            )
        ])

        let packet = Packet.response(messageID: 1, response)

        if let r = packet.airTouch2PlusPacket as? UnitAbilitiesResponseMessage {
            XCTAssertEqual(response, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTExpectFailure("Sample data in AirTouch documentation has 0001 1011 for modes, which indicates cool, dry, heat, auto")
        XCTAssertEqual(
            packet.bytes,
            bytes
        )

        let r = UnitAbilitiesResponseMessage(bytes: [ 0xff, 0x11, 0x00, 0x16,
                                                      0x55, 0x4e, 0x49, 0x54, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                                      0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x17, 0x1d, 0x11, 0x1f ])

        XCTExpectFailure("Sample data in AirTouch documentation has 0001 1011 for modes, which indicates cool, dry, heat, auto")
        if let r {
            XCTAssertEqual(response, r)
        }
        else {
            XCTFail("Unable to decode")
        }
    }

    func testError() throws {
        let bytes: [UInt8] = [
            0x55, 0x55, 0xb0, 0x90, 0x01, 0x1f, 0x00, 0x1a, 0xff, 0x10, 0x00, 0x08,
            0x45, 0x52, 0x3a, 0x20, 0x46, 0x46, 0x46, 0x45, 0x60, 0xd3
        ]

        let response = ErrorResponseMessage(
            unitID: 0,
            error: "ER: FFFE"
        )

        let packet = Packet.response(messageID: 1, response)

        if let r = packet.airTouch2PlusPacket as? ErrorResponseMessage {
            XCTAssertEqual(response, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTExpectFailure("Sample data in AirTouch documentation has a data length of 0x1a (26), but should be 12 (0xc)")
        XCTAssertEqual(
            packet.bytes,
            bytes
        )

        let r = ErrorResponseMessage(bytes: [ 0xff, 0x10, 0x00, 0x08, 0x45, 0x52, 0x3a, 0x20, 0x46, 0x46, 0x46, 0x45 ])

        if let r {
            XCTAssertEqual(response, r)
        }
        else {
            XCTFail("Unable to decode")
        }
    }

    func testGroupNames() throws {
        let group0Bytes: [UInt8] = [
            0x55, 0x55, 0xb0, 0x90, 0x01, 0x1f, 0x00, 0x0b, 0xff, 0x12,
            0x00, 0x47, 0x72, 0x6f, 0x75, 0x70, 0x31, 0x00, 0x00, 0xfd, 0x18
        ]

        let group0Response = GroupNameResponseMessage(
            groups: [
                .init(groupID: 0, name: "Group1")
            ]
        )

        let group0Packet = Packet.response(messageID: 1, group0Response)

        if let r = group0Packet.airTouch2PlusPacket as? GroupNameResponseMessage {
            XCTAssertEqual(group0Response, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTAssertEqual(
            group0Packet.bytes,
            group0Bytes
        )

        let group0R = GroupNameResponseMessage(bytes: [ 0xff, 0x12, 0x00, 0x47, 0x72, 0x6f, 0x75, 0x70, 0x31, 0x00, 0x00 ])

        if let group0R {
            XCTAssertEqual(group0Response, group0R)
        }
        else {
            XCTFail("Unable to decode")
        }

        let allGroupsBytes: [UInt8] = [
            0x55, 0x55, 0xb0, 0x90, 0x01, 0x1f, 0x00, 0x0b, 0xff, 0x12, 0x00, 0x4c, 0x69, 0x76, 0x69, 0x6e, 0x67, 0x00, 0x00,
            0x01, 0x4b, 0x69, 0x74, 0x63, 0x68, 0x65, 0x6e, 0x00,
            0x02, 0x42, 0x65, 0x64, 0x72, 0x6f, 0x6f, 0x6d, 0x00, 0x39, 0x93
        ]

        let allGroupsResponse = GroupNameResponseMessage(
            groups: [
                .init(groupID: 0, name: "Living"),
                .init(groupID: 1, name: "Kitchen"),
                .init(groupID: 2, name: "Bedroom")
            ]
        )

        let allGroupsPacket = Packet.response(messageID: 1, allGroupsResponse)

        if let r = allGroupsPacket.airTouch2PlusPacket as? GroupNameResponseMessage {
            XCTAssertEqual(allGroupsResponse, r)
        }
        else {
            XCTFail("Unable to decode")
        }

        XCTExpectFailure("Sample data in AirTouch documentation appears to have incorrect length for multi-group response")
        XCTAssertEqual(
            allGroupsPacket.bytes,
            allGroupsBytes
        )

        let allGroupsR = GroupNameResponseMessage(bytes: [ 0xff, 0x12, 0x00, 0x4c, 0x69, 0x76, 0x69, 0x6e, 0x67, 0x00, 0x00,
                                                    0x01, 0x4b, 0x69, 0x74, 0x63, 0x68, 0x65, 0x6e, 0x00,
                                                    0x02, 0x42, 0x65, 0x64, 0x72, 0x6f, 0x6f, 0x6d, 0x00, ])

        if let allGroupsR {
            XCTAssertEqual(allGroupsResponse, allGroupsR)
        }
        else {
            XCTFail("Unable to decode")
        }
    }
}
