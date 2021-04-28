// Types of objects in a Penball level. Used to compute category bit masks for a physics body.
public struct PenballObjectType: OptionSet, Codable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    // A ball.
    public static let ball = PenballObjectType(rawValue: 1)
    
    // An object that can collide with the ball, drawn by the user.
    public static let userDrawn = PenballObjectType(rawValue: 2)
    
    // A goal for a ball.
    public static let finish = PenballObjectType(rawValue: 4)
    
    // An object that can collide with the ball, defined as part of the level.
    public static let preloadedObstacle = PenballObjectType(rawValue: 8)
    
    // An object which destroys any balls it comes into contact with.
    public static let hazard = PenballObjectType(rawValue: 16)
    
    // An object which launches a ball up.
    public static let bouncePad = PenballObjectType(rawValue: 32)
    
    public static let obstacles: PenballObjectType = [.userDrawn, .preloadedObstacle]
}
