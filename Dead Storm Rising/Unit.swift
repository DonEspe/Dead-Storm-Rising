//
//  Unit.swift
//  Dead Storm Rising
//
//  Created by Don Espe on 8/15/23.
//

import SpriteKit    

class Unit: GameItem {
    var isAlive = true
    var hasMoved = false
    var hasFired = false

    var health = 3 {
        didSet {
            removeAllActions()

            if health > 0 {
//                let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.25 * Double(health))
//                let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.25 * Double(health))
//
//                let sequence = SKAction.sequence([fadeOut, fadeIn])
//                let repeatForever = SKAction.repeatForever(sequence)
//                run(repeatForever)
                if let smoke = SKEmitterNode(fileNamed: "SmallSmoke") {
                    smoke.zPosition = zPositions.smoke
                    smoke.position = CGPoint(x: 0, y: -15.0)
                    smoke.particleBirthRate = CGFloat((3 - health) * 2)
                    smoke.particleLifetime = CGFloat(3 - health) / 2.5

                    self.addChild(smoke)
                }
            } else {
                texture = SKTexture(imageNamed: "tankDead")

                alpha = 1

                isAlive = false
                removeAllChildren()
            }
        }
    }

    func takeDamage() {
        health -= 1
    }

    func move(to target: SKNode) {

        guard hasMoved == false else { return }
        hasMoved = true

        var sequence = [SKAction]()

        if position.x != target.position.x {
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: target.position.x - position.x, y: 0))
            sequence.append(SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200))
        }

        if position.y != target.position.y {
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: 0, y: target.position.y - position.y))
            sequence.append(SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200))
        }

        run(SKAction.sequence(sequence))

    }

    func attack(target: Unit) {
        guard hasFired == false else { return }
        hasFired = true

        rotate(toFace: target)

        let bullet: SKSpriteNode

        if owner == .red {
            bullet = SKSpriteNode(imageNamed: "bulletRed")
        } else {
            bullet = SKSpriteNode(imageNamed: "bulletBlue")
        }

        bullet.zPosition = zPositions.bullet
        parent?.addChild(bullet)

        let path = UIBezierPath()
        path.move(to: position)
        path.addLine(to: target.position)

        let move = SKAction.follow(path.cgPath, asOffset: false, orientToPath: true, speed: 500)

        let damageTarget = SKAction.run { [unowned target] in
            target.takeDamage()
        }

        let createExplosion = SKAction.run { [unowned self] in
            if let smoke = SKEmitterNode(fileNamed: "Smoke") {
                smoke.position = target.position
                smoke.zPosition = zPositions.smoke
                self.parent?.addChild(smoke)
            }

            if let fire = SKEmitterNode(fileNamed: "Fire") {
                fire.position = target.position
                fire.zPosition = zPositions.fire
                self.parent?.addChild(fire)
            }

        }
        let muzzleExplosion = SKAction.run { [unowned self] in
            if let muzzleSmoke = SKEmitterNode(fileNamed: "ShotSmoke") {
                muzzleSmoke.position = CGPoint(x: 0, y: 20)
                muzzleSmoke.zPosition = zPositions.smoke
                self.addChild(muzzleSmoke)
            }
        }

        let sequence = [muzzleExplosion, move, damageTarget, createExplosion, SKAction.removeFromParent()]

        bullet.run(SKAction.sequence(sequence))
    }

    func reset() {
        if isAlive == true {
            hasFired = false
            hasMoved = false
        } else {
            let fadeAway = SKAction.fadeOut(withDuration: 0.5)
            let sequence = [fadeAway, SKAction.removeFromParent()]
            run(SKAction.sequence(sequence))
        }
    }

    func rotate(toFace node: SKNode) {
        let angle = atan2(node.position.y - position.y, node.position.x - position.x)
        zRotation = angle - (CGFloat.pi / 2)
    }

}
