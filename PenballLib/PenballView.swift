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
    
    public init() {}
    
    public var body: some View {
        ZStack {
            PenballSpriteView(strokes: strokes)
            PenballCanvasView(strokes: $strokes).environment(\.colorScheme, .light)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea().statusBar(hidden: true)
    }
}
