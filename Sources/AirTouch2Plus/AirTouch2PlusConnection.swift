//
//  AirTouch2PlusConnection.swift
//  

import Foundation
import Network

public class AirTouch2PlusConnection {
    public static let applicationServiceParameters: NWParameters = {
        let parameters = NWParameters.tcp

        let swOptions = NWProtocolFramer.Options(
            definition: AirTouch2PlusProtocol.definition
        )

        parameters.defaultProtocolStack.applicationProtocols.insert(swOptions, at: 0)

        return parameters
    }()

    public typealias StateUpdateHandler = ((_ connection: AirTouch2PlusConnection, _ state: NWConnection.State) -> Void)
    public typealias PacketReceivedHandler = ((_ connection: AirTouch2PlusConnection, _ packet: Packet) -> Void)

    public var stateUpdateHandler: StateUpdateHandler?
    public var packetReceivedHandler: PacketReceivedHandler?

    fileprivate var connection: NWConnection?

    public init(connection: NWConnection? = nil, stateUpdateHandler: StateUpdateHandler?, packetReceivedHandler: PacketReceivedHandler?) {
        self.stateUpdateHandler = stateUpdateHandler
        self.packetReceivedHandler = packetReceivedHandler
        self.connection = connection

        if let connection {
            self.startConnection(connection: connection)
        }
    }
}

extension AirTouch2PlusConnection {
    public func send(message: Packet, completion: @escaping (Swift.Error?) -> Void) {
        guard let connection else {
            return
        }

        let data = Data(message.bytes)
        print("Sending: \(message) (\(data))")

        connection.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .contentProcessed { error in
                completion(error)
            }
        )
    }

    public func disconnect() {
        self.connection?.cancel()
        self.connection = nil
    }

    public func connect(endpoint: NWEndpoint) {
        self.disconnect()

        let connection = NWConnection(to: endpoint, using: Self.applicationServiceParameters)
        self.connection = connection
        self.startConnection(connection: connection)
    }

    func startConnection(connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            guard let self else {
                connection.forceCancel()
                return
            }

            self.stateUpdateHandler?(self, state)

            switch state {
            case .ready:
                print("READY")
                self.receiveNextMessage(connection: connection)

            case .preparing:
                print("PREPARING")
                break

            case .cancelled:
                print("CANCELLED")
                break

            case .failed:
                print("FAILED")
                break

            case .setup:
                print("SETUP")
                break

            case .waiting:
                print("WAITING")
                break

            @unknown default:
                print("UNKNOWN")
                break
            }
        }

        connection.start(queue: .main)
    }
}

extension AirTouch2PlusConnection {
    fileprivate func receiveNextMessage(connection: NWConnection) {
        connection.receiveMessage { [weak self] content, context, isComplete, error in
            guard let self else {
                return
            }

            if let content, let message = context?.protocolMetadata(definition: AirTouch2PlusProtocol.definition) as? NWProtocolFramer.Message {

                if let header = message.header {
                    let bytes = header.bytes + [UInt8](content)

                    if let packet = Packet(bytes: bytes) {
                        self.packetReceivedHandler?(self, packet)
                    }
                }
            }

            guard error == nil else {
                return
            }

            self.receiveNextMessage(connection: connection)
        }
    }
}

