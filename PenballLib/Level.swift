//
//  Level.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

public struct Level {
    public let name: String
    public let scene: PenballScene
    public let allowsDrawing: Bool
    
    public init(name: String, scene: PenballScene, allowsDrawing: Bool = true) {
        self.name = name
        self.scene = scene
        self.allowsDrawing = allowsDrawing
    }
}
