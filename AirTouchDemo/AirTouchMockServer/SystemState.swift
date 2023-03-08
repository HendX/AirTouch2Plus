//
//  SystemState.swift
//
//  Created by Quentin Zervaas on 8/3/2023.
//

import Foundation
import AirTouch2Plus

class SystemState {

    var unitStatuses: [UnitID: UnitStatusMessage.Unit]
    var unitAbilities: [UnitID: UnitAbilitiesResponseMessage.Unit]

    public init() {
        unitStatuses = [
            0: .init(
                unitID: 0,
                powerState: .off,
                mode: .cool,
                fanSpeed: .low,
                setPoint: DegreesCelsius(22.5),
                turboIsActive: false,
                bypassIsActive: false,
                spillIsActive: false,
                timerIsSet: false,
                temperature: DegreesCelsius(24),
                errorCode: nil
            )
        ]

        unitAbilities = [
            0: .init(
                unitID: 0,
                unitName: "UNIT",
                startGroupNumber: 0,
                numGroups: 4,
                supportedModes: [ .cool, .heat, .fan, .auto, .dry ],
                supportedFanSpeeds: [ .low, .medium, .high, .turbo ],
                minSetPoint: .init(12),
                maxSetPoint: .init(30)
            )
        ]
    }

    func groupName(id: GroupID) -> String {
        String(format: "Group \(id)")
    }

    var sortedUnitStatuses: [UnitStatusMessage.Unit] {
        unitStatuses.map { $0.value }.sorted { a, b in
            a.unitID < b.unitID
        }
    }

    var sortedUnitAbilities: [UnitAbilitiesResponseMessage.Unit] {
        unitAbilities.map { $0.value }.sorted { a, b in
            a.unitID < b.unitID
        }
    }


}
