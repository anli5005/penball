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
    static let transitionTime: TimeInterval = 2
    
    var scene: PenballScene
    var drawing: PKDrawing
    @Binding var state: PenballState
    @Binding var timerText: String
    var onComplete: (Score) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        
        context.coordinator.parent = self
        scene.penballDelegate = context.coordinator
        scene.state = state
        
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        scene.updateDrawing(drawing)
        
        #if DEBUG
        view.showsFPS = true
        // view.showsDrawCount = true
        // view.showsNodeCount = true
        // view.showsQuadCount = true
        // view.showsPhysics = true
        // view.showsFields = true
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        context.coordinator.parent = self
        scene.penballDelegate = context.coordinator
        scene.state = state

        if uiView.scene !== scene {
            scene.scaleMode = .resizeFill
            let transition = SKTransition.push(with: .up, duration: Self.transitionTime)
            transition.pausesOutgoingScene = false
            uiView.presentScene(scene, transition: transition)
        }
        scene.updateDrawing(drawing)
    }
    
    class Coordinator: PenballSceneDelegate {
        var parent: PenballSpriteView
        var score: Score?
        
        init(_ parent: PenballSpriteView) {
            self.parent = parent
        }
        
        func changeState(to state: PenballState) {
            parent.state = state
            if state == .completed, let score = score {
                parent.onComplete(score)
            }
        }
        
        func updateScore(_ score: Score) {
            let text = score.timeString!
            if parent.timerText != text {
                parent.timerText = text
            }
            
            self.score = score
        }
    }
}
