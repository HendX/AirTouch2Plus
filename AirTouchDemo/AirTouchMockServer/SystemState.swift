//
//  SystemState.swift
//
//  Created by Quentin Zervaas on 8/3/2023.
//

import Foundation
import AirTouch2Plus

class SystemState {

    public init() {

    }

    func groupName(id: GroupID) -> String {
        String(format: "Group \(id)")
    }
}
