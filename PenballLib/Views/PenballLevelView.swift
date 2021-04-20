//
//  PenballView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/15/21.
//

import SwiftUI
import PencilKit

// View that displays and manages a single Penball level.
public struct PenballLevelView: View {
    // Message displayed when the level is failed.
    let deathMessage = "Level failed"
    
    // Drawing on the current level.
    @Binding var drawing: PKDrawing
    
    // Current tool in use.
    @Binding var tool: PKTool
    
    // State of the level.
    @Binding var state: PenballState
    
    // Mapping of level IDs to best scores.
    @Binding var bests: [String: Score]
    
    // Text drawn on the reset button, displaying the time elapsed after the level starts.
    @State var timerText = ""
    
    @State var showingClearPopover = false
    
    @State var currentScore = Score(time: 0, strokes: 0)
    
    // Current level.
    var level: Level
    
    // Function called when the continue button is pressed. If nil, the continue button will not be shown.
    var onContinue: (() -> Void)?
    
    var scene: PenballScene {
        level.scene
    }
    
    public init(_ level: Level, drawing: Binding<PKDrawing>, tool: Binding<PKTool>, state: Binding<PenballState>, bests: Binding<[String: Score]>, onContinue: (() -> Void)? = nil) {
        self.level = level
        self._drawing = drawing
        self._tool = tool
        self._state = state
        self._bests = bests
        self.onContinue = onContinue
    }
    
    public var body: some View {
        ZStack {
            // SpriteKit scene w/ background, balls, and physics
            PenballSpriteView(scene: scene, drawing: drawing, state: $state, timerText: $timerText, onComplete: { score in
                currentScore = score
                if let oldBests = bests[level.id] {
                    bests[level.id]!.time = min(oldBests.time, score.time)
                    bests[level.id]!.strokes = min(oldBests.strokes, score.strokes)
                } else {
                    bests[level.id] = score
                }
            })
            
            // Canvas view that displays any drawings made, if the level allows it.
            if level.allowsDrawing {
                PenballCanvasView(drawing: $drawing, tool: tool, onPencilInteraction: {
                    // When the Pencil is double-tapped, switch between the eraser and the default tool (the pen).
                    if tool is PKEraserTool {
                        tool = PenballCanvasView.defaultTool
                    } else {
                        tool = PKEraserTool(.vector)
                    }
                }).environment(\.colorScheme, .light).animation(nil).opacity(state == .transitioning ? 0 : 1).animation(state == .transitioning ? .easeInOut(duration: 0.75) : nil)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Level failed message
                HintView(content: deathMessage, secondaryContent: "Tap button below to reset", visible: state == .failed)
                
                // Controls and level completion
                ZStack {
                    LevelCompletedView(level: level, bests: bests[level.id] ?? currentScore, currentScore: currentScore, onContinue: onContinue, state: $state)
                    GameControls(level: level, timerText: timerText, state: $state, tool: $tool, drawing: $drawing)
                }.background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), .clear]), startPoint: UnitPoint(x: 0, y: 1), endPoint: UnitPoint(x: 0, y: 0)))
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
