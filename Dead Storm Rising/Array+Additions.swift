//
//  Array+Additions.swift
//  Dead Storm Rising
//
//  Created by Don Espe on 8/15/23.
//

import UIKit

extension Array where Element: GameItem {
    func itemsAt(position: CGPoint) -> [Element] {
        return filter {
            let diffX = abs($0.position.x - position.x)
            let diffY = abs($0.position.y - position.y)
            return diffX + diffY < 20
        }
    }
}
