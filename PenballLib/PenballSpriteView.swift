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
    var strokes: [Double: PKStroke]
    @Binding var state: PenballState
    @Binding var timerText: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.preferredFramesPerSecond = 120
        
        context.coordinator.parent = self
        scene.penballDelegate = context.coordinator
        scene.state = state
        
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        scene.updateStrokes(strokes)
        
        #if DEBUG
        // view.showsFPS = true
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
        scene.updateStrokes(strokes)
    }
    
    class Coordinator: PenballSceneDelegate {
        var parent: PenballSpriteView
        let formatter: DateComponentsFormatter
        
        init(parent: PenballSpriteView) {
            self.parent = parent
            formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
        }
        
        func changeState(to state: PenballState) {
            parent.state = state
        }
        
        func updateTimer(elapsedTime: TimeInterval) {
            let text = formatter.string(from: elapsedTime)!
            if parent.timerText != text {
                parent.timerText = text
            }
        }
    }
}
