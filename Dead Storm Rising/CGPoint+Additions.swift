//
//  File.swift
//  Dead Storm Rising
//
//  Created by Don Espe on 8/15/23.
//

import UIKit

extension CGPoint {
    func manhattanDistance(to: CGPoint) -> CGFloat {
        return (abs(x - to.x) + abs(y - to.y))
    }
}
