//
//  PenballView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/15/21.
//

import SwiftUI
import PencilKit

public struct PenballLevelView: View {
    let deathMessage = ["Oh no!"].randomElement()!
    
    @Binding var strokes: [Double: PKStroke]
    @Binding var tool: PKTool
    @Binding var state: PenballState
    @Binding var bests: [String: Score]
    @State var timerText = ""
    @State var showingClearPopover = false
    @State var currentScore = Score(time: 0, strokes: 0)
    
    var level: Level
    var onContinue: (() -> Void)?
    
    var scene: PenballScene {
        level.scene
    }
    
    public init(_ level: Level, strokes: Binding<[Double: PKStroke]>, tool: Binding<PKTool>, state: Binding<PenballState>, bests: Binding<[String: Score]>, onContinue: (() -> Void)? = nil) {
        self.level = level
        self._strokes = strokes
        self._tool = tool
        self._state = state
        self._bests = bests
        self.onContinue = onContinue
    }
    
    public var body: some View {
        ZStack {
            PenballSpriteView(scene: scene, strokes: strokes, state: $state, timerText: $timerText, onComplete: { score in
                currentScore = score
                if let oldBests = bests[level.id] {
                    bests[level.id]!.time = min(oldBests.time, score.time)
                    bests[level.id]!.strokes = min(oldBests.strokes, score.strokes)
                } else {
                    bests[level.id] = score
                }
            })
            if level.allowsDrawing {
                PenballCanvasView(strokes: $strokes, tool: $tool).environment(\.colorScheme, .light).animation(nil).opacity(state == .transitioning ? 0 : 1).animation(state == .transitioning ? .easeInOut(duration: 0.75) : nil)
            }
            VStack(spacing: 0) {
                Spacer()
                HintView(content: deathMessage, secondaryContent: "Tap button below to reset", visible: state == .failed)
                ZStack {
                    LevelCompletedView(level: level, bests: bests[level.id] ?? currentScore, currentScore: currentScore, onContinue: onContinue, state: $state)
                    GameControls(level: level, timerText: timerText, state: $state, tool: $tool, strokes: $strokes)
                }.background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), .clear]), startPoint: UnitPoint(x: 0, y: 1), endPoint: UnitPoint(x: 0, y: 0)))
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea().statusBar(hidden: true)
    }
}
