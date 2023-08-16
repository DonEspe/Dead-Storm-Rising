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
    var selectedItem: GameItem? {
        didSet {
            selectedItemChanged()
        }
    }
    var selectionMarker: SKSpriteNode!
    var moveSquares = [SKSpriteNode]()

    var menuBar: SKSpriteNode!
    var menuBarPlayer: SKLabelNode!
    var menuBarEndTurn: SKLabelNode!
    var menuBarCapture: SKLabelNode!
    var menuBarBuild: SKLabelNode!

    override func didMove(to view: SKView) {
        cameraNode = camera!
        createStartingLayout()
        createMenuBar()

        selectionMarker = SKSpriteNode(imageNamed: "crosshair - white")
        selectionMarker.zPosition = zPositions.selectionMarker
        addChild(selectionMarker)
        hideSelectionMarker()

        for _ in 0 ..< 41 {
            let moveSquare = SKSpriteNode(color: UIColor.white, size: CGSize(width: 64, height: 64))
            moveSquare.alpha = 0
            moveSquare.name = "move"
            moveSquares.append(moveSquare)
            addChild(moveSquare)
        }
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchesMoved(touches, with: event)

        let distance = originalTouch.manhattanDistance(to: lastTouch)

        if distance < 44 {
            nodesTapped(at: touch.location(in: self))
        }
    }

    func createStartingLayout() {
        for i in 0 ..< 5 {
            let unit = Unit(imageNamed: "tank_red")
            unit.owner = .red

            unit.position = CGPoint(x: -128 + (i * 64), y: -320)

            unit.zPosition = zPositions.unit

            units.append(unit)

            addChild(unit)
        }

        for i in 0 ..< 5 {
            let unit = Unit(imageNamed: "tank_blue")
            unit.owner = .blue

            unit.position = CGPoint(x: -128 + (i * 64), y: 704) // y: 704

            unit.zPosition = zPositions.unit

            unit.zRotation = CGFloat.pi

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

    func nodesTapped(at point: CGPoint) {
        let tappedNodes = nodes(at: point)

        var tappedMove: SKNode!
        var tappedUnit: Unit!
        var tappedBase: Base!

        for node in tappedNodes {
            if node is Unit {
                tappedUnit = node as? Unit
            } else if node is Base {
                tappedBase = node as? Base
            } else if node.name == "move" {
                tappedMove = node
            } else if node.name == "endturn" {
                endTurn()
                return
            } else if node.name == "capture" {
                captureBase()
                return
            } else if node.name == "build" {
                guard let selectedBase = selectedItem as? Base else { return }

                if let unit = selectedBase.buildUnit() {
                    units.append(unit)
                    addChild(unit)
                }

                selectedItem = nil
                return
            }
        }

        if tappedMove != nil {
            // move or attack
            guard let selectedUnit = selectedItem as? Unit else { return }
            let tappedUnits = units.itemsAt(position: tappedMove.position)

            if tappedUnits.count == 0 {
                selectedUnit.move(to: tappedMove)
            } else {
                selectedUnit.attack(target: tappedUnits[0])
            }

            selectedItem = nil
        } else if tappedUnit != nil {
            // user tapped a unit
            if selectedItem != nil && tappedUnit == selectedItem {
                // it was already selected; deselect it
                selectedItem = nil
            } else {
                // don't let us control enemy units or dead units
                if tappedUnit.owner == currentPlayer && tappedUnit.isAlive {
                    selectedItem = tappedUnit
                }
            }
        } else if tappedBase != nil {
            // user tapped a base
            if tappedBase.owner == currentPlayer {
                // and it's theirs - select it
                selectedItem = tappedBase
            }
        } else {
            // user tapped something else; deselect
            selectedItem = nil
        }
    }

    func showSelectionMarker() {
        guard let item = selectedItem else { return }
        selectionMarker.removeAllActions()

        selectionMarker.position = item.position
        selectionMarker.alpha = 1

        let rotate = SKAction.rotate(byAngle: -CGFloat.pi, duration: 1)
        let repeatForever = SKAction.repeatForever(rotate)
        selectionMarker.run(repeatForever)
    }

    func hideSelectionMarker() {
        selectionMarker.removeAllActions()
        selectionMarker.alpha = 0
    }

    func selectedItemChanged() {
        hideMoveOptions()
        hideCaptureMenu()
        hideBuildMenu()

        if let item = selectedItem {
            showSelectionMarker()

            if selectedItem is Unit {
                showMoveOptions()

                let currentBases = bases.itemsAt(position: item.position)

                if currentBases.count > 0 {
                    if currentBases[0].owner != currentPlayer {
                        showCaptureMenu()
                    }
                }
            } else {
                showBuildMenu()
            }
        } else {
            hideSelectionMarker()
        }
    }

    func hideMoveOptions() {
        moveSquares.forEach {
            $0.alpha = 0
        }
    }

    func showMoveOptions() {
        guard let selectedUnit = selectedItem as? Unit else { return }

        var counter = 0

        for row in -5 ..< 5 {
            for col in -5 ..< 5 {
                let distance = abs(col) + abs(row)
                guard distance <= 4 else { continue }

                let squarePosition = CGPoint(x: selectedUnit.position.x + CGFloat(col * 64), y: selectedUnit.position.y + CGFloat(row * 64))
                let currentUnits = units.itemsAt(position: squarePosition)
                var isAttack = false

                if currentUnits.count > 0 {
                    if currentUnits[0].owner == currentPlayer || currentUnits[0].isAlive == false {
                        continue
                    } else {
                        isAttack = true
                    }
                }

                if isAttack {
                    guard selectedUnit.hasFired == false else { continue }
                    moveSquares[counter].color = UIColor.red
                } else {
                    guard selectedUnit.hasMoved == false else { continue }
                    moveSquares[counter].color = UIColor.white
                }

                moveSquares[counter].position = squarePosition
                moveSquares[counter].alpha = 0.35
                counter += 1
            }
        }
    }

    func createMenuBar() {
        menuBar = SKSpriteNode(color: UIColor(white: 0, alpha: 0.66), size: CGSize(width: 1024, height: 60))
        menuBar.position = CGPoint(x: 0, y: 325)
        menuBar.zPosition = zPositions.menuBar
        cameraNode.addChild(menuBar)

        menuBarPlayer = SKLabelNode(text: "RED")
        menuBarPlayer.fontColor = .red
        menuBarPlayer.fontName = "Arial-BoldMT"
        menuBarPlayer.position = CGPoint(x: -350 + 20, y: -10)
        menuBar.addChild(menuBarPlayer)

        menuBarEndTurn = SKLabelNode(text: "End Turn")
        menuBarEndTurn.fontColor = .red
        menuBarEndTurn.fontName = "Arial-BoldMT"
        menuBarEndTurn.position = CGPoint(x:300, y: -10)
        menuBarEndTurn.name = "endturn"
        menuBar.addChild(menuBarEndTurn)

        menuBarCapture = SKLabelNode(text: "Capture")
        menuBarCapture.fontColor = .white
        menuBarCapture.fontName = "Arial-BoldMT"
        menuBarCapture.position = CGPoint(x:0, y: -10)
        menuBarCapture.name = "capture"
        menuBar.addChild(menuBarCapture)
        hideCaptureMenu()

        menuBarBuild = SKLabelNode(text: "Build")
        menuBarBuild.fontColor = .white
        menuBarBuild.fontName = "Arial-BoldMT"
        menuBarBuild.position = CGPoint(x:0, y: -10)
        menuBarBuild.name = "build"
        menuBar.addChild(menuBarBuild)
        hideBuildMenu()

    }

    func hideCaptureMenu() {
        menuBarCapture.alpha = 0
    }

    func showCaptureMenu() {
        menuBarCapture.alpha = 1
    }

    func hideBuildMenu() {
        menuBarBuild.alpha = 0
    }

    func showBuildMenu() {
        menuBarBuild.alpha = 1
    }

    func captureBase() {
        guard let item = selectedItem else { return }
        let currentBases = bases.itemsAt(position: item.position)

        if currentBases.count > 0 {
            if currentBases[0].owner != currentPlayer {
                currentBases[0].setOwner(currentPlayer)
                selectedItem = nil
            }
        }
    }

    func endTurn() {
        if currentPlayer == .red {
            currentPlayer = .blue

            menuBarEndTurn.fontColor = .blue
            menuBarPlayer.text = "Blue"
            menuBarPlayer.fontColor = .blue
        } else {
            currentPlayer = .red
            menuBarEndTurn.fontColor = .red
            menuBarPlayer.text = "Red"
            menuBarPlayer.fontColor = .red
        }

        bases.forEach { $0.reset() }
        units.forEach { $0.reset() }

        units = units.filter { $0.isAlive }

        selectedItem = nil
    }
}
