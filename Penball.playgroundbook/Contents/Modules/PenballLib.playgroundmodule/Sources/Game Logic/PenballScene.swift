// This file defines much of the game logic, particularly in PenballScene, a subclass of SKScene.

import SpriteKit
import PencilKit

extension Optional where Wrapped == NSMutableDictionary {
    // Extracts a UIColor from a userData dictionary.
    func getColor() -> UIColor {
        let r = (self?[PenballScene.redKey] as? CGFloat) ?? 0
        let g = (self?[PenballScene.greenKey] as? CGFloat) ?? 0
        let b = (self?[PenballScene.blueKey] as? CGFloat) ?? 0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

extension SKNode {
    // Extracts the ball ID from the node's userData dictionary, if it exists.
    var ballID: Int? {
        userData?[PenballScene.ballKey] as? Int
    }
}

extension PenballObjectType {
    // List of objects a ball can trigger a contact notification with.
    static let ballContactTest: PenballObjectType = [.finish, .hazard, .bouncePad]
}

// Given an array of strokes and an array of Y positions to split those strokes at, returns an array of physics bodies along with their bounding boxes.
func getPhysicsBodies(strokes: [PKStroke], splitY: [CGFloat]) -> [(CGRect, SKPhysicsBody)] {
    var drawings = [PKDrawing]()
    
    strokes.forEach { stroke in
        // Split the strokes
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
    }
    
    // Generate physics bodies
    let rects = drawings.map { $0.bounds }
    let textures = drawings.map { SKTexture(image: $0.image(from: $0.bounds, scale: UIScreen.main.scale)) }
    let bodies = textures.map { SKPhysicsBody(texture: $0, alphaThreshold: 0.5, size: $0.size()) }
    
    return Array(zip(rects, bodies))
}

// Main SpriteKit scene encapsulating the logic of a Penball game.
public class PenballScene: SKScene, SKPhysicsContactDelegate {
    static let startNodeName = "Start"
    static let finishNodeName = "Finish"
    
    // Keys for the userData dictionary
    static let redKey = "red"
    static let greenKey = "green"
    static let blueKey = "blue"
    static let ballKey = "ball"
    
    weak var penballDelegate: PenballSceneDelegate?
    
    // State of the current level.
    var state = PenballState.notStarted {
        didSet {
            if state != oldValue {
                stateDidChange()
            }
        }
    }
    
    // Mapping of ball IDs to their corresponding ball nodes.
    var ballNodes = [Int: SKShapeNode]()
    
    // Mapping of ball IDs to their corresponding goals.
    var finishNodes = [Int: SKShapeNode]()
    
    // Mapping of ball IDs to their starting positions and colors.
    var startingConfigurations = [Int: (CGPoint, UIColor)]()
    
    // Mapping of stroke creation times to their corresponding nodes.
    var strokeNodes = [Double: [SKNode]]()
    
    // Set of ball IDs that have reached their goals.
    var completedBalls = Set<Int>()
    
    // Time the level was started at.
    var startTime: TimeInterval?
    
    // Current score.
    var score = Score(time: 0, strokes: 0)

    // Emitters
    var explosionEmitter: SKEmitterNode?
    var successEmitter: SKEmitterNode?
    var emitters = [SKEmitterNode]() // This array keeps track of all emitters in the scene so that they can be removed at the end of a level
    
    // Radius and line width of a ball.
    let radius: CGFloat = 20
    let lineWidth: CGFloat = 5
    
    // Sound effect that plays when a ball reaches its goal.
    let soundEffect = SKAction.playSoundFileNamed("hint", waitForCompletion: false)
    
    // Z position of each ball.
    static let ballZ: CGFloat = 1000
    
    public override func sceneDidLoad() {
        super.sceneDidLoad()
        
        physicsWorld.contactDelegate = self
        
        backgroundColor = .black
        
        // Initialize emitters.
        
        explosionEmitter = SKEmitterNode(fileNamed: "Explosion")!
        explosionEmitter!.isPaused = true
        explosionEmitter!.isHidden = true
        
        successEmitter = SKEmitterNode(fileNamed: "Success")!
        successEmitter!.isPaused = true
        successEmitter!.isHidden = true
        
        // Populate startingConfigurations using the start markers in the scene.s
        enumerateChildNodes(withName: PenballScene.startNodeName, using: { node, _ in
            self.startingConfigurations[node.ballID ?? 0] = (node.position, node.userData.getColor())
        })
        
        // Set up finish/goal nodes.
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
        
        // Do setup for the current state.
        stateDidChange()
    }
    
    public override func didMove(to view: SKView) {
        // Reset the level when the level is transitioned to, regardless of state.
        super.didMove(to: view)
        resetLevel()
    }
    
    // Resets the balls and clears any emitters in the scene.
    func resetLevel() {
        setupBalls()
        emitters.forEach { $0.removeFromParent() }
        emitters = []
    }
    
    // Clears any balls in the scene and creates balls at their starting positions.
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
    
    // Performs state-specific setup after a state transition.
    func stateDidChange() {
        switch state {
        case .notStarted:
            // Reset the score, start time, balls, and emitters.
            score = Score(time: 0, strokes: 0)
            startTime = nil
            resetLevel()
        case .started:
            // Update the current stroke count.
            score = Score(time: 0, strokes: strokeNodes.count)
            
            // Give each ball a physics body.
            ballNodes.values.forEach { ballNode in
                ballNode.physicsBody = SKPhysicsBody(circleOfRadius: radius + lineWidth / 2)
                ballNode.physicsBody!.categoryBitMask = PenballObjectType.ball.rawValue
                ballNode.physicsBody!.collisionBitMask = PenballObjectType.obstacles.union(.ball).rawValue
                ballNode.physicsBody!.contactTestBitMask = PenballObjectType.ballContactTest.rawValue
            }
        case .completed:
            // Remove the physics body from each ball.
            ballNodes.values.forEach { $0.physicsBody = nil }
        default:
            break
        }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Fail the level if a ball left the frame.
        if state == .started && ballNodes.values.contains(where: { !$0.frame.intersects(frame) }) {
            state = .failed
            penballDelegate?.changeState(to: .failed)
        }
        
        // Update the level's time elapsed if it is currently running.
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
    
    // Computes the Y coordinates at which to split each stroke. The results of this method are passed into the getPhysicsBodies function.
    // Why do we need to split the strokes before converting them to physics bodies? SpriteKit can't handle physics bodies with holes in them, so splitting them into multiple parts alleviates this problem by avoiding holes if the drawing encloses the ball (or any position where the ball could go.)
    func getSplitPoints() -> [CGPoint] {
        return startingConfigurations.values.map(\.0) + ballNodes.values.map(\.position)
    }
    
    // Adds the given physics bodies (with accompanying bounding boxes from the PKDrawing) to the scene with the given object type, positioned using frame.
    @discardableResult func addPhysicsBodies(_ bodies: [(CGRect, SKPhysicsBody)], with type: PenballObjectType, frame: CGRect) -> [SKNode] {
        let nodes = bodies.map { item -> SKNode in
            let (rect, body) = item
            let node = SKNode()
            
            // Convert from the drawing coordinate space to SpriteKit's
            node.position = CGPoint(x: frame.minX + rect.midX, y: frame.maxY - rect.midY)
            
            node.physicsBody = body
            node.physicsBody?.isDynamic = false
            node.physicsBody?.categoryBitMask = type.rawValue
            node.physicsBody?.collisionBitMask = 0
            node.physicsBody?.friction = 0
            return node
        }
        nodes.forEach { self.addChild($0) }
        return nodes
    }
    
    // Updates the scene with a new drawing.
    func updateDrawing(_ drawing: PKDrawing) {
        // Compute the strokes that have been added or removed, using each stroke's creation time as an identifier.
        let strokes = [Double: [PKStroke]](grouping: drawing.strokes, by: \.path.creationDate.timeIntervalSince1970)
        let oldSet = Set(strokeNodes.keys)
        
        // Remove nodes associated with erased strokes.
        for toDelete in oldSet.subtracting(strokes.keys) {
            if let nodes = strokeNodes[toDelete] {
                nodes.forEach { $0.removeFromParent() }
            }
            strokeNodes[toDelete] = nil
        }
        
        // For each new stroke, add corresponding physics bodies to the scene.
        for strokeID in Set(strokes.keys).subtracting(oldSet) {
            // Increment the number of strokes in the score.
            score.strokes += 1
            
            // Set the nodes associated with the stroke ID to an empty array (so that we know if the stroke is erased later down the line).
            strokeNodes[strokeID] = []
            
            let strokes = strokes[strokeID]!
            
            // Get split coordinates and convert them to the SpriteKit coordinate space.
            let splitY = getSplitPoints().map { frame.maxY - $0.y }.sorted()
            
            // Generate physics bodies in a background thread; while this isn't that slow, doing this in the main thread causes a drop in FPS.
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else { return }
                let items = getPhysicsBodies(strokes: strokes, splitY: splitY)
                
                // In the main thread, add the physics bodies to the scene if the corresponding strokes haven't been erased yet.
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if self.strokeNodes[strokeID] != nil {
                        self.strokeNodes[strokeID] = self.addPhysicsBodies(items, with: .userDrawn, frame: self.frame)
                    }
                }
            }
        }
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        let categories = PenballObjectType(rawValue: contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
        
        // Ball + Goal
        if categories == [.ball, .finish] && contact.bodyA.node?.ballID == contact.bodyB.node?.ballID {
            guard let id = (contact.bodyA.node?.ballID ?? contact.bodyB.node?.ballID) else { return }
            let ball = ballNodes[id]!
            let finish = finishNodes[id]!
            
            // Make the ball's physics body static, and animate a move to the goal node's position
            ball.physicsBody?.isDynamic = false
            let moveAction = SKAction.move(to: finish.position, duration: 0.1)
            moveAction.timingMode = .easeOut
            ball.run(moveAction)
            
            // Add the ball's ID to completedBalls, and change the state if all the balls have reached their goals
            completedBalls.insert(id)
            if !completedBalls.isStrictSubset(of: startingConfigurations.keys) {
                state = .completed
                penballDelegate?.changeState(to: .completed)
            }
            
            // Particle effects! :D
            let emitter = successEmitter!.copy() as! SKEmitterNode
            emitter.position = .zero
            emitter.particleColor = startingConfigurations[id]!.1
            ball.addChild(emitter)
            emitter.isPaused = false
            emitter.isHidden = false
            emitter.resetSimulation()
            emitters.append(emitter)
            
            // Sound effects too!
            run(soundEffect)
        }
        
        // Ball + Hazard
        if categories == [.ball, .hazard] {
            guard let id = (contact.bodyA.node?.ballID ?? contact.bodyB.node?.ballID) else { return }
            let ball = ballNodes[id]!
            
            // Unset the ball's physics body and fade it out.
            ball.physicsBody = nil
            ball.lineWidth = 0
            ball.run(.fadeOut(withDuration: 0.2))
            
            // Fail the level
            state = .failed
            penballDelegate?.changeState(to: .failed)
            
            // Particle effects
            let emitter = explosionEmitter!.copy() as! SKEmitterNode
            emitter.position = ball.position
            emitter.particleColor = startingConfigurations[id]!.1
            addChild(emitter)
            emitter.isPaused = false
            emitter.isHidden = false
            emitter.resetSimulation()
            emitters.append(emitter)
        }
        
        // Ball + Bounce Pad
        if categories == [.ball, .bouncePad] {
            guard let id = (contact.bodyA.node?.ballID ?? contact.bodyB.node?.ballID) else { return }
            let ball = ballNodes[id]!
            
            // Launch the ball into the air
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        }
    }
}

// Delegate for PenballScene, used to coordinate with PenballSpriteView.
protocol PenballSceneDelegate: AnyObject {
    // Called when the scene changes its state.
    func changeState(to state: PenballState)
    
    // Called periodically with the current score of the scene.
    func updateScore(_ score: Score)
}
