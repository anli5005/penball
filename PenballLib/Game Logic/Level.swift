//
//  Level.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import PencilKit
import SpriteKit

// Structure representing a loaded level.
public struct Level: Identifiable {
    // ID of the level, used for keeping track of best scores.
    public let id: String
    
    // User-visible name of the level.
    public let name: String
    
    // SpriteKit scene for the level.
    public let scene: PenballScene
    
    // Whether this level allows users to draw obstacles on it.
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

// Structure representing a serialized level, which can be converted into a Level struct at runtime. Used to represent levels in JSON format.
public struct LevelDefinition: Codable {
    // Drawing accompanying this level.
    public var drawing: PKDrawing
    
    // A mapping of stroke creation times to object types. If a stroke is not present in this dictionary, it is purely decorative.
    public var strokeTypes: [Double: PenballObjectType]
    
    // A list of balls in the level.
    public var balls: [Ball]
    
    // Height of the scene, used to determine where to place the drawing in the scene.
    public var sceneHeight: CGFloat
    
    // Structure representing a ball.
    public struct Ball: Codable {
        public var red: CGFloat
        public var green: CGFloat
        public var blue: CGFloat
        public var start: CGPoint
        public var end: CGPoint
        
        // Tuples are an easy way to represent colors, so we use them
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

// Subclass of PenballScene that loads a level from a LevelDefinition.
public class PenballLevelScene: PenballScene {
    var levelDefinition: LevelDefinition?
    
    // Node that displays the drawing.
    var drawingNode: SKSpriteNode?
    
    public init(levelDefinition: LevelDefinition) {
        self.levelDefinition = levelDefinition
        super.init(size: CGSize(width: 100, height: 100))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    public override func sceneDidLoad() {
        // Split drawings when they intersect the y coordinates of the starting positions
        // This is to ensure that physics bodies with holes are properly accounted for
        // See PenballScene.getSplitPoints for more information
        var splitY = [CGFloat]()
        
        // Set up ball start/finish markers
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
        
        // Set up drawing
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
            
            // For each drawing with an associated object type, generate a physics body and add it to the scene
            drawing.strokes.forEach { stroke in
                if let category = levelDefinition!.strokeTypes[stroke.path.creationDate.timeIntervalSince1970] {
                    addPhysicsBodies(getPhysicsBodies(strokes: [stroke], splitY: splitY), with: category, frame: CGRect(x: 0, y: 0, width: frame.width, height: levelDefinition!.sceneHeight))
                }
            }
        }
        
        // Let PenballScene.sceneDidLoad take it from here
        super.sceneDidLoad()
    }
}

// Helper initializers to initialize a Level from a LevelDefinition.
public extension Level {
    init(id: String, name: String, from definition: LevelDefinition, allowsDrawing: Bool = true) {
        self.init(id: id, name: name, scene: PenballLevelScene(levelDefinition: definition), allowsDrawing: allowsDrawing)
    }
    
    init(id: String, from definition: LevelDefinition, allowsDrawing: Bool = true) {
        self.init(id: id, name: id, from: definition, allowsDrawing: allowsDrawing)
    }
}
