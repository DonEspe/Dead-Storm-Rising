//
//  Base.swift
//  Dead Storm Rising
//
//  Created by Don Espe on 8/15/23.
//

import SpriteKit

class Base: GameItem {
    var hasBuilt = false

    func reset() {
        hasBuilt = false
    }

    func setOwner(_ owner: Player) {
        self.owner = owner
        hasBuilt = true
        self.colorBlendFactor = 0.9

        if owner == .red {
            color = UIColor(red: 1, green: 0.4, blue: 0.1, alpha: 1)
        } else {
            color = UIColor(red: 0.1, green: 0.5, blue: 1, alpha: 1)
        }
    }

    func buildUnit() -> Unit? {
        guard hasBuilt == false else { return nil }
        hasBuilt = true

        let unit: Unit

        if owner == .red {
            unit = Unit(imageNamed: "tank_Red")
        } else {
            unit = Unit(imageNamed: "tank_Blue")
        }

        unit.hasMoved = true
        unit.hasFired = true

        unit.owner = owner
        unit.position = position

        unit.zPosition = zPositions.unit

        return unit
    }

}
