//
//  AirTouchDemoApp.swift
//

import SwiftUI

@main
struct AirTouchDemoApp: App {
    @ObservedObject var model: AppModel = .init()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
