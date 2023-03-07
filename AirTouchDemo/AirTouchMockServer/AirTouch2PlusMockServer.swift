//
//  AirTouch2PlusMockServer.swift
//

import Foundation
import Network
import AirTouch2Plus

public class AirTouch2PlusMockServer {

    public var connections: [AirTouch2PlusConnection] = []

    var listener: NWListener?

    let systemState: SystemState

    public init() {
        systemState = .init()
    }

    public func startListening(port: NWEndpoint.Port) throws {
        try self.setupApplicationServiceListener(port: port)
    }

    func setupApplicationServiceListener(port: NWEndpoint.Port) throws {
        let listener = try NWListener(using: AirTouch2PlusConnection.applicationServiceParameters, on: port)

        self.listener = listener

//        listener.stateUpdateHandler = listenerStateChanged

        // The system calls this when a new connection arrives at the listener.
        // Start the connection to accept it, cancel to reject it.
        listener.newConnectionHandler = { [weak self] newConnection in
            guard let self else {
                return
            }

            self.writeToStdError("Received new connection: \(newConnection)\n")

            let connection = AirTouch2PlusConnection(connection: newConnection) { [weak self] connection, state in
                self?.didUpdateState(connection: connection, state: state)
            } packetReceivedHandler: { [weak self] connection, packet in
                self?.didReceivePacket(connection: connection, packet: packet)
            }

            self.connections.append(connection)
        }

        // Start listening, and request updates on the main queue.
        listener.start(queue: .main)
    }

    func didUpdateState(connection: AirTouch2PlusConnection, state: NWConnection.State) {
        self.writeToStdError("Updated to state: \(state)\n")
    }

    func didReceivePacket(connection: AirTouch2PlusConnection, packet: Packet) {
        self.writeToStdError("Received packet: \(packet)\n")

        var message: AirTouch2PlusPacket?
        let messageID = packet.header.body.messageID


        switch packet.airTouch2PlusPacket {
        case let m as ErrorRequestMessage:
            switch m {
            case .specific(let unitID):
                message = ErrorResponseMessage(unitID: unitID, error: "TODO") // TODO:
            }

        case let m as GroupControlMessage:
            message = GroupStatusMessage(groups: [])

        case let m as GroupNameRequestMessage:
            var groups: [GroupNameResponseMessage.Group] = []

            switch m {
            case .all:
                for groupID: GroupID in 0 ..< 16 {
                    groups.append(
                        .init(groupID: groupID, name: systemState.groupName(id: groupID))
                    )
                }
            case .specific(let groupID):
                groups.append(
                    .init(groupID: groupID, name: systemState.groupName(id: groupID))
                )
            }

            message = GroupNameResponseMessage(groups: groups)

        case let m as GroupStatusMessage:
            message = GroupStatusMessage(groups: [])

        case let m as UnitAbilitiesRequestMessage:
            message = UnitAbilitiesResponseMessage(units: [])

        case let m as UnitControlMessage:
            message = UnitStatusMessage(units: [])

        case let m as UnitStatusMessage:
            message = UnitStatusMessage(units: [])

        case .none:
            break

        default:
            break
        }

        if let message {
            let response = Packet.response(messageID: messageID, message)

            connection.send(packet: response) { error in
                
            }
        }
    }

    public func disconnectAll() {
        connections.forEach { $0.disconnect() }
        connections = []
    }

    public func stopListening() {
        self.disconnectAll()
        self.listener?.cancel()
        self.listener = nil
    }
}

extension AirTouch2PlusMockServer {
    func writeToStdError(_ str: String) {
        if let data = str.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
}
