//
//  PenballScene.swift
//  PenballLib
//
//  Created by Anthony Li on 4/16/21.
//

import SpriteKit
import PencilKit

class PenballScene: SKScene {
    var startPosition = CGPoint(x: 500, y: 500)
    var circleNode: SKShapeNode?
    var strokeNodes = [Double: [SKNode]]()
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        let radius: CGFloat = 20
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        circleNode = SKShapeNode(ellipseOf: CGSize(width: radius * 2, height: radius * 2))
        circleNode!.position = startPosition
        circleNode!.fillColor = .white
        circleNode!.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        addChild(circleNode!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !circleNode!.frame.intersects(frame) {
            circleNode!.position = startPosition
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
            let splitY = getSplitPoints().map { frame.height - $0.y }.sorted()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let drawing = PKDrawing(strokes: [stroke])
                var rects = [CGRect]()
                var lastY = self.frame.minY
                for y in splitY {
                    if y > drawing.bounds.minY && y < drawing.bounds.maxY {
                        rects.append(CGRect(x: self.frame.origin.x, y: lastY, width: self.frame.width, height: y - lastY))
                        lastY = y
                    }
                }
                rects.append(CGRect(x: self.frame.origin.x, y: lastY, width: self.frame.width, height: self.frame.maxY - lastY))
                
                let textures = rects.map { SKTexture(image: drawing.image(from: $0, scale: UIScreen.main.scale)) }
                let bodies = textures.map { SKPhysicsBody(texture: $0, alphaThreshold: 0.5, size: $0.size()) }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if self.strokeNodes[strokeID] != nil {
                        let nodes = zip(rects, bodies).map { item -> SKNode in
                            let (rect, body) = item
                            let node = SKNode()
                            node.position = CGPoint(x: rect.midX, y: self.frame.height - rect.midY)
                            node.physicsBody = body
                            node.physicsBody?.isDynamic = false
                            node.physicsBody?.friction = 0
                            return node
                        }
                        self.strokeNodes[strokeID] = nodes
                        nodes.forEach { self.addChild($0) }
                    }
                }
            }
        }
    }
}
