# AirTouch2Plus

This package implements the Polyaire AirTouch 2+ Communication Protocol.

It is based on v1.0 of their API documentation, dated 24/8/2020.

The unit tests are based on the example requests/responses in this same document.

This project was built purely as a programming exercise and has not been tested a real AirTouch 2+ unit.

No warranty is given nor liability is accepted for this code. By using this code you agree to these terms.

## Usage

```swift
import Network
import AirTouch2Plus

// Set the endpoint to your AirTouch 2+ unit
let endpoint: NWEndpoint = .hostPort(
    host: .init("192.168.0.123"),
    port: AirTouch2PlusConnection.standardPort
) 

// Create the connection and packet handlers
let connection = AirTouch2PlusConnection() { connection, state in
    
    // You can start sending messages once the connection is ready
    switch state {
    case .ready:
        // Request unit status
        let message = UnitStatusMessage(units: [])
        let packet = Packet.request(messageID: nil, message)

        connection.send(message: packet) { error in

        }

    default:
        // break
    }
} packetReceivedHandler: { connection, packet in

    // Packet is received with the raw packet data. Use `airTouch2PlusPacket` to make it more usful
    
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

// Initiate the connection to the AirTouch 2+ unit
connection.connect(endpoint: endpoint)
```

## Demo Project

This repository contains a demo project with two targets:

* A sample SwiftUI client app.
* A mock AirTouch 2+ unit

Run the AirTouchMockServer target to start the fake unit. This will wait for connections and respond to queries from the client.

Next, run the client app in the iOS simulator and tap "Connect" (this will connect to "localhost" by default).

You can then issue commands and receive responses accordingly.
