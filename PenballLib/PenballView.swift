//
//  PenballView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import SwiftUI
import PencilKit

public struct PenballView: View {
    var levels: [Level]
    @State var currentLevel: Int = 0
    @State var strokes = [Double: PKStroke]()
    @State var state = PenballState.notStarted
    @State var tool: PKTool = PenballCanvasView.defaultTool
    
    public init(levels: [Level]) {
        self.levels = levels
    }
    
    public var body: some View {
        PenballLevelView(levels[currentLevel], strokes: $strokes, tool: $tool, state: $state, onContinue: currentLevel == levels.endIndex - 1 ? nil : {
            strokes = [:]
            tool = PenballCanvasView.defaultTool
            currentLevel += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + PenballSpriteView.transitionTime) {
                state = .notStarted
            }
        })
    }
}
