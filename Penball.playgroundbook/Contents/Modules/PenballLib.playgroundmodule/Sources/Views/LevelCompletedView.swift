//
//  LevelCompletedView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import SwiftUI

// View that appears when a level is completed.
struct LevelCompletedView: View {
    // Current level.
    var level: Level
    
    // Best score for this level.
    var bests: Score
    
    // Current score for this level.
    var currentScore: Score
    
    // Function called when the continue button is pressed. If nil, the continue button will not be shown.
    var onContinue: (() -> Void)?
    
    // Binding to the current state of the level.
    @Binding var state: PenballState
    
    var body: some View {
        let isBestTime = currentScore.time <= bests.time
        let isBestStrokes = currentScore.strokes <= bests.strokes
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Level complete!").bold().font(.largeTitle)
                
                // Scores
                if level.allowsDrawing {
                    HStack(spacing: 8) {
                        Text("Time: \(currentScore.timeString!)")
                        Text("Best: \(bests.timeString!)").fontWeight(isBestTime ? .bold : .regular).opacity(isBestTime ? 1 : 0.6).foregroundColor(isBestTime ? .yellow : .white)
                    }
                    HStack(spacing: 8) {
                        Text("Strokes: \(currentScore.strokes)")
                        Text("Best: \(bests.strokes)").fontWeight(isBestStrokes ? .bold : .regular).opacity(isBestStrokes ? 1 : 0.6).foregroundColor(isBestStrokes ? .yellow : .white)
                    }
                }
            }.foregroundColor(.white)
            
            Spacer()
            
            // Retry
            Button {
                state = .notStarted
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise").accessibilityLabel("Retry")
                }.padding().foregroundColor(Color.black)
            }.buttonStyle(PillButtonStyle(background: Color.white))
            
            // Continue
            if let onContinue = onContinue {
                Button {
                    state = .transitioning
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        onContinue()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.right").accessibilityLabel("Continue")
                    }.padding().foregroundColor(Color.white)
                }.buttonStyle(PillButtonStyle(background: Color.green))
            }
        }.padding(.top, 8).padding([.horizontal, .bottom], 24).animation(nil).opacity(state == .completed ? 1 : 0).animation(.easeInOut(duration: state == .notStarted ? 0.25 : 0.75))
    }
}
