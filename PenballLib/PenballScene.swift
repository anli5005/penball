//
//  PenballScene.swift
//  PenballLib
//
//  Created by Anthony Li on 4/16/21.
//

import SpriteKit
import PencilKit

class PenballScene: SKScene {
    var startPosition = CGPoint(x: 0, y: 0)
    var circleNode: SKShapeNode?
    var strokeNodes = [Double: [SKNode]]()
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        let radius: CGFloat = 20
        backgroundColor = .init(red: 0, green: 0.3, blue: 0.75, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -1)
        circleNode = SKShapeNode(ellipseOf: CGSize(width: radius * 2, height: radius * 2))
        circleNode!.position = startPosition
        circleNode!.fillColor = .init(red: 0.8, green: 0.8, blue: 1, alpha: 1)
        circleNode!.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        addChild(circleNode!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !circleNode!.frame.intersects(frame) {
            circleNode!.position = CGPoint(x: frame.width / 2, y: 3 * frame.height / 4)
            circleNode!.physicsBody!.velocity = .zero
        }
    }
    
    func getSplitPoints() -> [CGPoint] {
        var points = [startPosition]
        circleNode.map { points.append($0.position) }
        return points
    }
    
    func updateStrokes(_ newStrokes: [Double: PKStroke]) {
        let newSet = Set(newStrokes.keys)
        let oldSet = Set(strokeNodes.keys)
        
        for toDelete in oldSet.subtracting(newSet) {
            if let nodes = strokeNodes[toDelete] {
                nodes.forEach { $0.removeFromParent() }
            }
            strokeNodes[toDelete] = nil
        }
        
        for strokeID in newSet.subtracting(oldSet) {
            strokeNodes[strokeID] = []
            let stroke = newStrokes[strokeID]!
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let drawing = PKDrawing(strokes: [stroke])
                let image = drawing.image(from: self.frame, scale: UIScreen.main.scale)
                let texture = SKTexture(image: image)
                let body = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: texture.size())
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if self.strokeNodes[strokeID] != nil {
                        let node = SKNode()
                        node.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
                        node.physicsBody = body
                        node.physicsBody!.isDynamic = false
                        node.physicsBody!.friction = 0
                        self.strokeNodes[strokeID] = [node]
                        self.addChild(node)
                    }
                }
            }
        }
    }
}
