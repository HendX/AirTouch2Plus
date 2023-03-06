//
//  AppModel.swift
//

import Foundation
import Network
import AirTouch2Plus

class AppModel: ObservableObject {
    var client: AirTouch2PlusClient

    @Published var state: NWConnection.State?

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
            case let p as ErrorResponseMessage:
                print("ErrorResponseMessage")

            case let p as GroupNameResponseMessage:
                print("GroupNameResponseMessage")

            case let p as GroupStatusMessage:
                print("GroupStatusMessage")

            case let p as UnitAbilitiesResponseMessage:
                print("UnitAbilitiesResponseMessage")

            case let p as UnitStatusMessage:
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
