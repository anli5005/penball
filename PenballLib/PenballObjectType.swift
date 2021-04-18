//
//  PenballBitMask.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

struct PenballObjectType: OptionSet {
    let rawValue: UInt32
    
    static let ball = PenballObjectType(rawValue: 1)
    static let userDrawn = PenballObjectType(rawValue: 2)
    static let finish = PenballObjectType(rawValue: 4)
    static let preloadedObstacle = PenballObjectType(rawValue: 8)
    static let hazard = PenballObjectType(rawValue: 16)
    static let bouncePad = PenballObjectType(rawValue: 32)
    
    static let obstacles: PenballObjectType = [.userDrawn, .preloadedObstacle]
}
