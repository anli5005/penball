//
//  PenballScene.swift
//  PenballLib
//
//  Created by Anthony Li on 4/16/21.
//

import SpriteKit
import PencilKit

class PenballSceneDelegate: SKScene {
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
                
                var drawings = [PKDrawing]()
                var lastIndex = 0
                for i in 1..<stroke.path.count {
                    let a = stroke.path[i - 1].location.y
                    let b = stroke.path[i].location.y
                    let range = min(a, b)...max(a, b)
                    if splitY.contains(where: { range.contains($0) }) {
                        let path = PKStrokePath(controlPoints: stroke.path[lastIndex...i], creationDate: stroke.path.creationDate)
                        drawings.append(PKDrawing(strokes: [PKStroke(ink: stroke.ink, path: path)]))
                        lastIndex = i
                    }
                }
                if stroke.path.count == 1 || lastIndex != stroke.path.endIndex - 1 {
                    let path = PKStrokePath(controlPoints: stroke.path[lastIndex..<stroke.path.endIndex], creationDate: stroke.path.creationDate)
                    drawings.append(PKDrawing(strokes: [PKStroke(ink: stroke.ink, path: path)]))
                }
                
                let rects = drawings.map { $0.bounds }
                let textures = drawings.map { SKTexture(image: $0.image(from: $0.bounds, scale: UIScreen.main.scale)) }
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
