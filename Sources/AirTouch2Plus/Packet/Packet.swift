//
//  Packet.swift
//  

import Foundation

public struct Packet {
    public var header: Header
    public var data: [UInt8]
    public var crc16: CRC16Modbus

    public init(
        headerCode: UInt16 = Packet.standardHeaderCode,
        address: UInt16,
        messageID: UInt8? = nil,
        messageType: UInt8,
        length: UInt16? = nil,
        data: [UInt8],
        crc16: CRC16Modbus? = nil
    ) {
        let header = Header(
            headerCode: headerCode,
            body: .init(
                address: address,
                messageID: messageID ?? 0x0,
                messageType: messageType,
                length: length ?? UInt16(data.count)
            )
        )

        self.header = header
        self.data   = data
        self.crc16  = crc16 ?? (header.body.bytes + data).crc16Modbus
    }
}

extension Packet {
    public var modBussableBytes: [UInt8] {
        header.body.bytes + data
    }
}

extension Packet {
    public var airTouch2PlusPacket: (any AirTouch2PlusPacket)? {
        guard header.headerCode == Self.standardHeaderCode else {
            return nil
        }

        guard data.count >= 2 else {
            return nil
        }

        let command: UInt16 = .init(bytes: [ data[0], data[1] ])

        let candidates: Array<AirTouch2PlusPacket.Type>

        switch header.body.address {
        case Self.standardMessageRequestAddress:
            guard header.body.messageType == Self.standardMessageType else {
                return nil
            }

            candidates = [
                GroupControlMessage.self,
                GroupStatusMessage.self,
                UnitControlMessage.self,
                UnitStatusMessage.self
            ]

        case Self.standardMessageResponseAddress:
            guard header.body.messageType == Self.standardMessageType else {
                return nil
            }

            candidates = [
                GroupControlMessage.self,
                GroupStatusMessage.self,
                UnitControlMessage.self,
                UnitStatusMessage.self
            ]

        case Self.extendedMessageRequestAddress:
            guard header.body.messageType == Self.extendedMessageType else {
                return nil
            }

            candidates = [
                GroupNameRequestMessage.self,
                UnitAbilitiesRequestMessage.self,
                ErrorRequestMessage.self
            ]

        case Self.extendedMessageResponseAddress:
            guard header.body.messageType == Self.extendedMessageType else {
                return nil
            }

            candidates = [
                GroupNameResponseMessage.self,
                UnitAbilitiesResponseMessage.self,
                ErrorResponseMessage.self
            ]

        default:
            return nil
        }

        for candidate in candidates {
            if candidate.command == command {
                return candidate.init(bytes: data)
            }
        }

        return nil
    }
}

extension Packet {
    public static let standardHeaderCode: UInt16 = .init(bytes: [ 0x55, 0x55 ])

    public static let standardMessageRequestAddress: UInt16 = .init(bytes: [ 0x80, 0xb0 ])
    public static let standardMessageResponseAddress: UInt16 = .init(bytes: [ 0xb0, 0x80 ])

    public static let standardMessageType: UInt8 = 0xc0

    public static let extendedMessageRequestAddress: UInt16 = .init(bytes: [ 0x90, 0xb0 ])
    public static let extendedMessageResponseAddress: UInt16 = .init(bytes: [ 0xb0, 0x90 ])
    public static let extendedMessageType: UInt8 = 0x1f
}

extension Packet {
    public static func request(messageID: MessageID?, _ packet: AirTouch2PlusPacket) -> Self {
        .init(
            address: packet is StandardPacket ? Packet.standardMessageRequestAddress : Packet.extendedMessageRequestAddress,
            messageID: messageID,
            messageType: packet is StandardPacket ? Packet.standardMessageType : Packet.extendedMessageType,
            data: packet.bytes
        )
    }

    public static func response(messageID: MessageID?, _ packet: AirTouch2PlusPacket) -> Self {
        .init(
            address: packet is StandardPacket ? Packet.standardMessageResponseAddress : Packet.extendedMessageResponseAddress,
            messageID: messageID,
            messageType: packet is StandardPacket ? Packet.standardMessageType : Packet.extendedMessageType,
            data: packet.bytes
        )
    }
}

extension Packet: Hashable { }
