//
//  Level.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import PencilKit
import SpriteKit

public struct Level: Identifiable {
    public let id: String
    public let name: String
    public let scene: PenballScene
    public let allowsDrawing: Bool
    
    public init(id: String, name: String, scene: PenballScene, allowsDrawing: Bool = true) {
        self.id = id
        self.name = name
        self.scene = scene
        self.allowsDrawing = allowsDrawing
    }
    
    public init(id: String, scene: PenballScene, allowsDrawing: Bool = true) {
        self.init(id: id, name: id, scene: scene, allowsDrawing: allowsDrawing)
    }
}

public struct LevelDefinition: Codable {
    public var drawing: PKDrawing
    public var strokeTypes: [Double: PenballObjectType]
    public var balls: [Ball]
    public var sceneHeight: CGFloat
    
    public struct Ball: Codable {
        public var red: CGFloat
        public var green: CGFloat
        public var blue: CGFloat
        public var start: CGPoint
        public var end: CGPoint
        
        public init(start: CGPoint, end: CGPoint, color: (CGFloat, CGFloat, CGFloat)) {
            let (r, g, b) = color
            red = r
            green = g
            blue = b
            self.start = start
            self.end = end
        }
    }
    
    public init(drawing: PKDrawing, strokeTypes: [Double: PenballObjectType], balls: [Ball], sceneHeight: CGFloat) {
        self.drawing = drawing
        self.strokeTypes = strokeTypes
        self.balls = balls
        self.sceneHeight = sceneHeight
    }
}

public class PenballLevelScene: PenballScene {
    var levelDefinition: LevelDefinition?
    var drawingNode: SKSpriteNode?
    
    public init(levelDefinition: LevelDefinition) {
        self.levelDefinition = levelDefinition
        super.init(size: CGSize(width: 100, height: 100))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    public override func sceneDidLoad() {
        var splitY = [CGFloat]()
        
        levelDefinition?.balls.enumerated().forEach { item in
            let (index, ball) = item
            let userData: NSDictionary = [PenballScene.redKey: ball.red, PenballScene.greenKey: ball.green, PenballScene.blueKey: ball.blue, PenballScene.ballKey: index + 1]
            
            let startNode = SKNode()
            startNode.position = ball.start
            startNode.name = PenballScene.startNodeName
            startNode.userData = (userData.mutableCopy() as! NSMutableDictionary)
            splitY.append(ball.start.y)
            addChild(startNode)
            
            let endNode = SKNode()
            endNode.position = ball.end
            endNode.name = PenballScene.finishNodeName
            endNode.userData = (userData.mutableCopy() as! NSMutableDictionary)
            addChild(endNode)
        }
        
        if let drawing = levelDefinition?.drawing {
            var image: UIImage?
            UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
                image = drawing.image(from: drawing.bounds, scale: UIScreen.main.scale)
            }
            let texture = SKTexture(image: image!)
            let node = SKSpriteNode(texture: texture)
            node.anchorPoint = .zero
            node.position = CGPoint(x: drawing.bounds.minX, y: levelDefinition!.sceneHeight - drawing.bounds.maxY)
            addChild(node)
            
            drawing.strokes.forEach { stroke in
                if let category = levelDefinition!.strokeTypes[stroke.path.creationDate.timeIntervalSince1970] {
                    addPhysicsBodies(getPhysicsBodies(strokes: [stroke], splitY: splitY), with: category, frame: CGRect(x: 0, y: 0, width: frame.width, height: levelDefinition!.sceneHeight))
                }
            }
        }
        
        super.sceneDidLoad()
    }
}

public extension Level {
    init(id: String, name: String, from definition: LevelDefinition, allowsDrawing: Bool = true) {
        self.init(id: id, name: name, scene: PenballLevelScene(levelDefinition: definition), allowsDrawing: allowsDrawing)
    }
    
    init(id: String, from definition: LevelDefinition, allowsDrawing: Bool = true) {
        self.init(id: id, name: id, from: definition, allowsDrawing: allowsDrawing)
    }
}
