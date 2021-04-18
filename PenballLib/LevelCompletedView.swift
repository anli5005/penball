//
//  LevelCompletedView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import SwiftUI

struct LevelCompletedView: View {
    var level: Level
    var bests: Score
    var currentScore: Score
    var onContinue: (() -> Void)?
    @Binding var state: PenballState
    
    var body: some View {
        let isBestTime = currentScore.time <= bests.time
        let isBestStrokes = currentScore.strokes <= bests.strokes
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Level complete!").bold().font(.largeTitle)
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
            Button {
                state = .notStarted
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry").fontWeight(.bold)
                }.padding().foregroundColor(Color.black)
            }.buttonStyle(PillButtonStyle(background: Color.white))
            if let onContinue = onContinue {
                Button {
                    state = .transitioning
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        onContinue()
                    }
                } label: {
                    HStack {
                        Text("Continue").fontWeight(.bold)
                        Image(systemName: "arrow.right")
                    }.padding().foregroundColor(Color.white)
                }.buttonStyle(PillButtonStyle(background: Color.green))
            }
        }.padding(.top, 8).padding([.horizontal, .bottom], 24).animation(nil).opacity(state == .completed ? 1 : 0).animation(.easeInOut(duration: state == .notStarted ? 0.25 : 0.75))
    }
}
