//
//  AirTouch2PlusProtocol.swift
//

import Foundation
import Network

public class AirTouch2PlusProtocol: NWProtocolFramerImplementation {
    public static var label: String { "AirTouch 2+ Communication Protocol"}

    public static let definition = NWProtocolFramer.Definition(implementation: AirTouch2PlusProtocol.self)

    public required init(framer: NWProtocolFramer.Instance) { }

    public func start(framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult { .ready }

    public func wakeup(framer: NWProtocolFramer.Instance) { }

    public func stop(framer: NWProtocolFramer.Instance) -> Bool { true }

    public func cleanup(framer: NWProtocolFramer.Instance) { }

    public func handleInput(framer: NWProtocolFramer.Instance) -> Int {
        let headerSize: Int = MemoryLayout<Packet.Header>.size

        while true {
            var tempHeader: Packet.Header?

            let parsed = framer.parseInput(minimumIncompleteLength: headerSize, maximumLength: headerSize) { buffer, isComplete in

                guard let buffer else {
                    return 0
                }

                guard buffer.count >= headerSize else {
                    return 0
                }

                tempHeader = Packet.Header(buffer: buffer)
                return headerSize
            }

            guard parsed, let tempHeader else {
                return headerSize
            }

            let message = NWProtocolFramer.Message(header: tempHeader)
            let remainingLength = Int(tempHeader.body.length) + MemoryLayout<CRC16Modbus>.size

            let delivered = framer.deliverInputNoCopy(length: remainingLength, message: message, isComplete: true)

            if !delivered {
                return 0
            }
        }
    }

    public func handleOutput(framer: NWProtocolFramer.Instance, message: NWProtocolFramer.Message, messageLength: Int, isComplete: Bool) {
        do {
            try framer.writeOutputNoCopy(length: messageLength)
        }
        catch {
            print("Error: \(error)")
        }
    }
}

@available(iOS 13, tvOS 13, watchOS 6, *)
extension NWProtocolFramer.Message {
    static let messageHeaderKey = "AirTouch2PlusHeader"

    convenience init(header: Packet.Header) {
        self.init(definition: AirTouch2PlusProtocol.definition)
        self[Self.messageHeaderKey] = header
    }

    public var header: Packet.Header? {
        self[Self.messageHeaderKey] as? Packet.Header
    }
}
