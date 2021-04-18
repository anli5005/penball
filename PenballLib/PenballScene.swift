//
//  PenballScene.swift
//  PenballLib
//
//  Created by Anthony Li on 4/16/21.
//

import SpriteKit
import PencilKit

extension Optional where Wrapped == NSMutableDictionary {
    func getColor() -> UIColor {
        let r = (self?[PenballScene.redKey] as? CGFloat) ?? 0
        let g = (self?[PenballScene.greenKey] as? CGFloat) ?? 0
        let b = (self?[PenballScene.blueKey] as? CGFloat) ?? 0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

extension SKNode {
    var ballID: Int? {
        userData?[PenballScene.ballKey] as? Int
    }
}

func *(_ mag: CGFloat, _ vec: CGVector) -> CGVector {
    CGVector(dx: mag * vec.dx, dy: mag * vec.dy)
}

extension PenballObjectType {
    static let ballContactTest: PenballObjectType = [.finish, .hazard, .bouncePad]
}

public class PenballScene: SKScene, SKPhysicsContactDelegate {
    static let startNodeName = "Start"
    static let finishNodeName = "Finish"
    
    static let redKey = "red"
    static let greenKey = "green"
    static let blueKey = "blue"
    static let ballKey = "ball"
    
    weak var penballDelegate: PenballSceneDelegate?
    var state = PenballState.notStarted {
        didSet {
            if state != oldValue {
                stateDidChange()
            }
        }
    }
    
    var ballNodes = [Int: SKShapeNode]()
    var finishNodes = [Int: SKShapeNode]()
    var startingConfigurations = [Int: (CGPoint, UIColor)]()
    var strokeNodes = [Double: [SKNode]]()
    var completedBalls = Set<Int>()
    
    var startTime: TimeInterval?
    
    var score = Score(time: 0, strokes: 0)

    var explosionEmitter: SKEmitterNode?
    var successEmitter: SKEmitterNode?
    var emitters = [SKEmitterNode]()
    
    let radius: CGFloat = 20
    let lineWidth: CGFloat = 5
    
    static let ballZ: CGFloat = 1000
    
    public override func sceneDidLoad() {
        super.sceneDidLoad()
        
        physicsWorld.contactDelegate = self
                
        backgroundColor = .black
        
        explosionEmitter = SKEmitterNode(fileNamed: "Explosion")!
        explosionEmitter!.isPaused = true
        explosionEmitter!.isHidden = true
        
        successEmitter = SKEmitterNode(fileNamed: "Success")!
        successEmitter!.isPaused = true
        successEmitter!.isHidden = true
        
        enumerateChildNodes(withName: PenballScene.startNodeName, using: { node, _ in
            self.startingConfigurations[node.ballID ?? 0] = (node.position, node.userData.getColor())
        })
        
        enumerateChildNodes(withName: PenballScene.finishNodeName, using: { node, _ in
            let id = node.ballID ?? 0
            let color = node.userData.getColor()
            
            let finishNode = SKShapeNode(ellipseOf: CGSize(width: self.radius * 2, height: self.radius * 2))
            finishNode.position = node.position
            finishNode.fillColor = .clear
            finishNode.strokeColor = color
            finishNode.physicsBody = SKPhysicsBody(circleOfRadius: self.radius + self.lineWidth / 2)
            finishNode.physicsBody!.categoryBitMask = PenballObjectType.finish.rawValue
            finishNode.physicsBody!.collisionBitMask = 0
            finishNode.physicsBody!.isDynamic = false
            finishNode.userData = [PenballScene.ballKey: id]
            
            self.finishNodes[id] = finishNode
        })
        finishNodes.values.forEach { addChild($0) }
        
        stateDidChange()
    }
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupBalls()
        emitters.forEach { $0.removeFromParent() }
        emitters = []
    }
    
    func setupBalls() {
        ballNodes.values.forEach { $0.removeFromParent() }
        ballNodes = [Int: SKShapeNode](uniqueKeysWithValues: startingConfigurations.map { configuration in
            let (position, color) = configuration.value
            let ballNode = SKShapeNode(ellipseOf: CGSize(width: radius * 2, height: radius * 2))
            ballNode.fillColor = color
            ballNode.strokeColor = color
            ballNode.lineWidth = lineWidth
            ballNode.position = position
            ballNode.zPosition = PenballScene.ballZ
            ballNode.userData = [PenballScene.ballKey: configuration.key]
            return (configuration.key, ballNode)
        })
        ballNodes.values.forEach { addChild($0) }
        completedBalls = []
    }
    
    func stateDidChange() {
        switch state {
        case .notStarted:
            score = Score(time: 0, strokes: 0)
            startTime = nil
            emitters.forEach { $0.removeFromParent() }
            emitters = []
            setupBalls()
        case .started:
            score = Score(time: 0, strokes: strokeNodes.count)
            ballNodes.values.forEach { ballNode in
                ballNode.physicsBody = SKPhysicsBody(circleOfRadius: radius + lineWidth / 2)
                ballNode.physicsBody!.categoryBitMask = PenballObjectType.ball.rawValue
                ballNode.physicsBody!.collisionBitMask = PenballObjectType.obstacles.union(.ball).rawValue
                ballNode.physicsBody!.contactTestBitMask = PenballObjectType.ballContactTest.rawValue
            }
        case .completed:
            ballNodes.values.forEach { $0.physicsBody = nil }
        default:
            break
        }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        if state == .started && ballNodes.values.contains(where: { !$0.frame.intersects(frame) }) {
            state = .failed
            penballDelegate?.changeState(to: .failed)
        }
        
        switch state {
        case .started, .failed:
            if startTime == nil {
                startTime = currentTime
            }
            score.time = currentTime - startTime!
            penballDelegate?.updateScore(score)
        case .notStarted:
            penballDelegate?.updateScore(score)
        default:
            break
        }
    }
    
    func getSplitPoints() -> [CGPoint] {
        return startingConfigurations.values.map(\.0) + ballNodes.values.map(\.position)
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
            score.strokes += 1
            strokeNodes[strokeID] = []
            let stroke = newStrokes[strokeID]!
            let splitY = getSplitPoints().map { frame.maxY - $0.y }.sorted()
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
                            node.position = CGPoint(x: self.frame.minX + rect.midX, y: self.frame.maxY - rect.midY)
                            node.physicsBody = body
                            node.physicsBody?.isDynamic = false
                            node.physicsBody?.categoryBitMask = PenballObjectType.userDrawn.rawValue
                            node.physicsBody?.collisionBitMask = 0
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
    
    public func didBegin(_ contact: SKPhysicsContact) {
        let categories = PenballObjectType(rawValue: contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
        
        if categories == [.ball, .finish] && contact.bodyA.node!.ballID == contact.bodyB.node!.ballID {
            let id = contact.bodyA.node!.ballID!
            let ball = ballNodes[id]!
            let finish = finishNodes[id]!
            ball.physicsBody?.isDynamic = false
            let moveAction = SKAction.move(to: finish.position, duration: 0.1)
            moveAction.timingMode = .easeOut
            ball.run(moveAction)
            completedBalls.insert(id)
            if !completedBalls.isStrictSubset(of: startingConfigurations.keys) {
                state = .completed
                penballDelegate?.changeState(to: .completed)
            }
            
            let emitter = successEmitter!.copy() as! SKEmitterNode
            emitter.position = .zero
            emitter.particleColor = startingConfigurations[id]!.1
            ball.addChild(emitter)
            emitter.isPaused = false
            emitter.isHidden = false
            emitter.resetSimulation()
            emitters.append(emitter)
        }
        
        if categories == [.ball, .hazard] {
            let id = (contact.bodyA.node!.ballID ?? contact.bodyB.node!.ballID)!
            let ball = ballNodes[id]!
            ball.physicsBody = nil
            ball.lineWidth = 0
            ball.run(.fadeOut(withDuration: 0.2))
            state = .failed
            penballDelegate?.changeState(to: .failed)
            
            let emitter = explosionEmitter!.copy() as! SKEmitterNode
            emitter.position = ball.position
            emitter.particleColor = startingConfigurations[id]!.1
            addChild(emitter)
            emitter.isPaused = false
            emitter.isHidden = false
            emitter.resetSimulation()
            emitters.append(emitter)
        }
        
        if categories == [.ball, .bouncePad] {
            let id = (contact.bodyA.node!.ballID ?? contact.bodyB.node!.ballID)!
            let ball = ballNodes[id]!
            if let velocity = ball.physicsBody?.velocity {
                ball.physicsBody!.velocity = (-1000 / sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)) * velocity
            }
        }
    }
}

protocol PenballSceneDelegate: AnyObject {
    func changeState(to state: PenballState)
    func updateScore(_ score: Score)
}
