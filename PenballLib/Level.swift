//
//  Level.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

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
