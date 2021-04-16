//
//  PenballSpriteView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/16/21.
//

import SwiftUI
import SpriteKit
import PencilKit

struct PenballSpriteView: UIViewRepresentable {
    var strokes: [Double: PKStroke]
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        
        let scene = PenballScene()
        scene.scaleMode = .resizeFill
        scene.updateStrokes(strokes)
        view.presentScene(scene)
        
        #if DEBUG
        view.showsFPS = true
        view.showsDrawCount = true
        view.showsNodeCount = true
        view.showsQuadCount = true
        // view.showsPhysics = true
        // view.showsFields = true
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        let scene = uiView.scene as! PenballScene
        scene.updateStrokes(strokes)
    }
}
