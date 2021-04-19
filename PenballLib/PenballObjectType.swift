//
//  PenballBitMask.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

public struct PenballObjectType: OptionSet, Codable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let ball = PenballObjectType(rawValue: 1)
    public static let userDrawn = PenballObjectType(rawValue: 2)
    public static let finish = PenballObjectType(rawValue: 4)
    public static let preloadedObstacle = PenballObjectType(rawValue: 8)
    public static let hazard = PenballObjectType(rawValue: 16)
    public static let bouncePad = PenballObjectType(rawValue: 32)
    
    public static let obstacles: PenballObjectType = [.userDrawn, .preloadedObstacle]
}
