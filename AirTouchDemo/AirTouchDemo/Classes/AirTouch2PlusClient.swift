//
//  AirTouch2PlusClient.swift
//

import Foundation
import Network
import AirTouch2Plus

public class AirTouch2PlusClient {
    public var connection: AirTouch2PlusConnection?

    public var stateUpdateHandler: AirTouch2PlusConnection.StateUpdateHandler?
    public var packetReceivedHandler: AirTouch2PlusConnection.PacketReceivedHandler?

    public init() {

    }

    public func connect(endpoint: NWEndpoint) {
        self.connection?.disconnect()

        let connec = AirTouch2PlusConnection() { connection, state in

        } packetReceivedHandler: { connection, packet in
            switch packet.airTouch2PlusPacket {
            case let message as GroupStatusMessage:
                // Handle message here
                break

            case let message as UnitStatusMessage:
                // Handle message here
                break

            default:
                break
            }
        }

        // Request uni status
        let message = UnitStatusMessage(units: [])
        let packet = Packet.request(messageID: nil, message)

        connec.send(packet: packet) { error in

        }

        let connection = AirTouch2PlusConnection(stateUpdateHandler: stateUpdateHandler, packetReceivedHandler: packetReceivedHandler)
        connection.connect(endpoint: endpoint)
        self.connection = connection
    }

    public func disconnect() {
        self.connection?.disconnect()
        self.connection = nil
    }
}

