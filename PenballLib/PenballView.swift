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
    
    public init() {}
    
    public var body: some View {
        ZStack {
            PenballSpriteView(strokes: strokes)
            PenballCanvasView(strokes: $strokes, tool: $tool).environment(\.colorScheme, .light)
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
            }).background(Color.white).cornerRadius(5).padding().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea().statusBar(hidden: true)
    }
}
