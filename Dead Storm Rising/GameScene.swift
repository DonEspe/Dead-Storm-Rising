//
//  GameScene.swift
//  Dead Storm Rising
//
//  Created by Don Espe on 8/14/23.
//

import SpriteKit

enum Player {
    case none, red, blue
}

enum zPositions {
    static let base: CGFloat = 10
    static let bullet: CGFloat = 20
    static let unit: CGFloat = 30
    static let smoke: CGFloat = 40
    static let fire: CGFloat = 50
    static let selectionMarker: CGFloat = 60
    static let menuBar: CGFloat = 100
}

class GameScene: SKScene {
    var lastTouch = CGPoint.zero
    var originalTouch = CGPoint.zero
    var cameraNode: SKCameraNode!
    var currentPlayer = Player.red
    var units = [Unit]()
    var bases = [Base]()

    override func didMove(to view: SKView) {
        cameraNode = camera!
        createStartingLayout()

    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouch = touch.location(in: self.view)
        originalTouch = lastTouch

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self.view)

        let newX = cameraNode.position.x + (lastTouch.x - touchLocation.x)
        let newY = cameraNode.position.y + (touchLocation.y - lastTouch.y)
        cameraNode.position = CGPoint(x: newX, y: newY)

        lastTouch = touchLocation
    }

    func createStartingLayout() {
        for i in 0 ..< 5 {
            let unit = Unit(imageNamed: "tank_red")
            unit.owner = .red

            unit.position = CGPoint(x: -128 + (i * 64), y: -320)

            unit.zPosition = zPositions.unit

            unit.zRotation = CGFloat.pi

            units.append(unit)

            addChild(unit)
        }

        for i in 0 ..< 5 {
            let unit = Unit(imageNamed: "tank_blue")
            unit.owner = .blue

            unit.position = CGPoint(x: -128 + (i * 64), y: 704)

            unit.zPosition = zPositions.unit

            units.append(unit)

            addChild(unit)
        }

        for row in 0 ..< 3 {
            for col in 0 ..< 3 {
                let base = Base(imageNamed: "base")
                base.position = CGPoint(x: -256 + (col * 256), y: -64 + (row * 256))
                base.zPosition = zPositions.base
                bases.append(base)
                addChild(base)
            }
        }
    }
}
