//
//  PenballView.swift
//  PenballLib
//
//  Created by Anthony Li on 4/15/21.
//

import SwiftUI
import PencilKit

public struct PenballView: View {
    @State var strokes = [Double: PKStroke]()
    @State var tool: PKTool = PenballCanvasView.defaultTool
    @State var state = PenballState.notStarted
    
    var scene: PenballScene
    
    public init(scene: PenballScene) {
        self.scene = scene
    }
    
    public var body: some View {
        ZStack {
            PenballSpriteView(scene: scene, strokes: strokes, state: $state)
            PenballCanvasView(strokes: $strokes, tool: $tool).environment(\.colorScheme, .light)
            VStack {
                Button(action: {
                    state = (state == .notStarted) ? .started : .notStarted
                }, label: {
                    if state == .notStarted {
                        Text("Start").padding()
                    } else {
                        Text("Reset").padding()
                    }
                }).background(Color.white).cornerRadius(5).padding()
                Spacer()
                Button(action: {
                    if tool is PKEraserTool {
                        tool = PenballCanvasView.defaultTool
                    } else {
                        tool = PKEraserTool(.vector)
                    }
                }, label: {
                    if tool is PKEraserTool {
                        Text("Eraser").padding()
                    } else {
                        Text("Pen").padding()
                    }
                }).background(Color.white).cornerRadius(5).padding()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea().statusBar(hidden: true)
    }
}
