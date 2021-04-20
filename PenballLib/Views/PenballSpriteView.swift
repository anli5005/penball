import SwiftUI
import SpriteKit
import PencilKit

// View that encapsulates an SKView containing a PenballScene.
struct PenballSpriteView: UIViewRepresentable {
    // Duration of scene transitions.
    static let transitionTime: TimeInterval = 2
    
    // Current scene in the view.
    var scene: PenballScene
    
    // Drawing on the level, used to inform PenballScene of new strokes.
    var drawing: PKDrawing
    
    // Binding to the current state of the level.
    @Binding var state: PenballState
    
    // Binding to the text displayed in the reset button.
    @Binding var timerText: String
    
    // Function called when the level completes. This function is passed the current score.
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
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        context.coordinator.parent = self
        scene.penballDelegate = context.coordinator
        scene.state = state

        // If the scene was updated, transition to it.
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
        
        // Keeps track of the current score to call onComplete with.
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
