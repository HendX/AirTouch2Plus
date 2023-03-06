//
//  main.swift
//

import Foundation
import AirTouch2Plus

func writeToStdError(_ str: String) {
    if let data = str.data(using: .utf8) {
        FileHandle.standardError.write(data)
    }
}

func writeToStdError(_ error: Swift.Error) {
    writeToStdError("\(error)")
}

func writeToStdOut(_ str: String) {
    if let data = str.data(using: .utf8) {
        FileHandle.standardOutput.write(data)
    }
}

let group = DispatchGroup()

group.enter()

signal(SIGINT) { signal in
    group.leave()
}

let server = AirTouch2PlusMockServer()
try server.startListening(port: AirTouch2PlusConnection.standardPort)

RunLoop.main.run()

group.notify(queue: .main) {
    server.stopListening()
    exit(0)
}

