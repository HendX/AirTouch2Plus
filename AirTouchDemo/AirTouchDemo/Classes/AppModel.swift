//
//  AppModel.swift
//

import Foundation
import Network
import AirTouch2Plus

class AppModel: ObservableObject {
    var client: AirTouch2PlusClient

    @Published var state: NWConnection.State?
    @Published var groups: [GroupNameResponseMessage.Group] = []

    init() {
        self.client = .init()

        self.client.stateUpdateHandler = { connection, state in
            DispatchQueue.main.async {
                self.state = state
            }
        }

        self.client.packetReceivedHandler = { connection, packet in
            print("Received packet: \(packet)\n")

            switch packet.airTouch2PlusPacket {
            case let m as ErrorResponseMessage:
                print("ErrorResponseMessage")

            case let m as GroupNameResponseMessage:
                self.groups = m.groups

            case let m as GroupStatusMessage:
                print("GroupStatusMessage")

            case let m as UnitAbilitiesResponseMessage:
                print("UnitAbilitiesResponseMessage")

            case let m as UnitStatusMessage:
                print("UnitStatusMessage")

            case .none:
                break

            default:
                break
            }
        }
    }

    func connect() {
        self.client.connect(
            endpoint: .hostPort(
                host: .init("localhost"),
                port: AirTouch2PlusConnection.standardPort
            )
        )

    }

    func disconnect() {
        self.client.disconnect()
        self.state = nil
    }
}
