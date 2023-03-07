//
//  ContentView.swift
//

import SwiftUI
import AirTouch2Plus

struct ContentView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack {
            VStack {
                Text("Groups")
                    .font(.headline)

                if model.groups.count == 0 {
                    Text("Unknown")
                }
                else {
                    VStack(alignment: .leading) {
                        ForEach(model.groups, id: \.self) { group in
                            Text("\(group.groupID). \(group.name)")
                        }
                    }
                }
            }

            Spacer()

            if let state = model.state {
                switch state {
                case .setup:
                    Text("Setup")
                case .waiting(let error):
                    Text("Waiting: \(error.debugDescription)")
                case .preparing:
                    Text("Preparing")
                case .ready:

                    Spacer()

                    VStack(spacing: 10) {
                        Button {
                            let message = GroupNameRequestMessage.all
                            let packet = Packet.request(messageID: nil, message)

                            self.model.client.connection?.send(packet: packet) { error in
                                if let error {
                                    print("Error: \(error)")
                                }
                            }

                        } label: {
                            Text("Group Names")
                        }

                        Button {
                            let message = GroupStatusMessage(groups: [])
                            let packet = Packet.request(messageID: nil, message)

                            self.model.client.connection?.send(packet: packet) { error in
                                if let error {
                                    print("Error: \(error)")
                                }
                            }

                        } label: {
                            Text("Group Status")
                        }

                        Button {
                            let message = UnitStatusMessage(units: [])
                            let packet = Packet.request(messageID: nil, message)

                            self.model.client.connection?.send(packet: packet) { error in
                                if let error {
                                    print("Error: \(error)")
                                }
                            }

                        } label: {
                            Text("Unit Status")
                        }
                    }

                    Spacer()

                case .failed(let error):
                    Text("Failed: \(error.debugDescription)")
                case .cancelled:
                    Text("Cancelled")
                @unknown default:
                    Text("Unknown State")
                }

                Button {
                    self.model.disconnect()
                } label: {
                    Text("Disconnect")
                }
            }
            else {
                Button {
                    self.model.connect()
                } label: {
                    Text("Connect")
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: .init())
    }
}
